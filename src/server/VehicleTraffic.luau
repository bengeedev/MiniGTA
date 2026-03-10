-- VehicleTraffic.luau
-- Server: data-only NPC traffic simulation.
-- No models in Workspace — broadcasts state to clients for rendering.
-- Clients create/destroy/interpolate vehicle clones locally.

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared", 10)
local GTAConfig = require(Shared:WaitForChild("GTAConfig"))
local TrafficConfig = require(Shared:WaitForChild("TrafficConfig"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local RoadNetwork = require(script.Parent:WaitForChild("RoadNetwork"))

local VehicleTraffic = {}

--------------------------------------------------------------------------------
-- STATE
--------------------------------------------------------------------------------

local vehicles = {}        -- [id] = vehicle data table
local vehicleCount = 0
local nextId = 1

-- Train
local trainId = nil
local railwayZ = nil
local railwayMinX = nil
local railwayMaxX = nil

-- Railway crossings (physical models — toggled directly by server)
local crossings = {}

-- Traffic lights (global synchronized cycle)
local lightPhase = TrafficConfig.PHASE_H_GREEN
local lightTimer = 0

-- Timers
local syncTimer = 0
local spawnTimer = 0

-- Cached remotes
local syncRemote = nil        -- UnreliableRemoteEvent (position batches)
local spawnRemote = nil       -- RemoteEvent (vehicle appeared)
local despawnRemote = nil     -- RemoteEvent (vehicle removed)
local lightRemote = nil       -- RemoteEvent (light phase changed)
local fullStateRemote = nil   -- RemoteEvent (late-join snapshot)

--------------------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------------------

local function getSpeed(laneType)
	if laneType == "highway" then return TrafficConfig.HIGHWAY_SPEED end
	return TrafficConfig.ROAD_SPEED
end

local function dirToYaw(dir)
	if dir == "east"  then return  math.pi / 2 end
	if dir == "west"  then return -math.pi / 2 end
	if dir == "south" then return  0 end
	if dir == "north" then return  math.pi end
	return 0
end

--------------------------------------------------------------------------------
-- CROSSING LIGHTS (physical model toggle — shared world state)
--------------------------------------------------------------------------------

local function setCrossingLights(crossing, on)
	if crossing.lightsOn == on then return end
	crossing.lightsOn = on

	for _, model in ipairs(crossing.models) do
		for _, part in ipairs(model:GetDescendants()) do
			if part.Name == "WarningLight" and part:IsA("BasePart") then
				if on then
					part.Color = Color3.fromRGB(255, 50, 40)
					part.Material = Enum.Material.Neon
				else
					part.Color = Color3.fromRGB(80, 30, 30)
					part.Material = Enum.Material.SmoothPlastic
				end
			end
		end
	end
end

local function findCrossings()
	crossings = {}
	if not railwayZ then return end

	-- Railway crosses each driveable V-lane
	local vLanes = GTAConfig.V_LANES
	for _, v in ipairs(vLanes) do
		local vx = GTAConfig.getColEdgeX(v.col)
		if not GTAConfig.isInsideCompound(vx, railwayZ) then
			table.insert(crossings, {
				x = vx,
				z = railwayZ,
				lightsOn = false,
				models = {},
			})
		end
	end

	-- Match crossing models from Decor folder
	local decorFolder = Workspace:FindFirstChild("World") and Workspace.World:FindFirstChild("Decor")
	if decorFolder then
		for _, child in ipairs(decorFolder:GetChildren()) do
			if child.Name == "RailwayCrossing" and child:IsA("Model") then
				local cx = child:GetPivot().Position.X
				local bestDist = math.huge
				local bestCrossing = nil
				for _, c in ipairs(crossings) do
					local dist = math.abs(c.x - cx)
					if dist < bestDist then
						bestDist = dist
						bestCrossing = c
					end
				end
				if bestCrossing and bestDist < 50 then
					table.insert(bestCrossing.models, child)
				end
			end
		end
	end

	print(string.format("[VehicleTraffic] Found %d railway crossings", #crossings))
end

--------------------------------------------------------------------------------
-- TRAFFIC LIGHTS
--------------------------------------------------------------------------------

local PHASE_DURATIONS = {
	[1] = TrafficConfig.LIGHT_GREEN_TIME,
	[2] = TrafficConfig.LIGHT_YELLOW_TIME,
	[3] = TrafficConfig.LIGHT_ALL_RED_TIME,
	[4] = TrafficConfig.LIGHT_GREEN_TIME,
	[5] = TrafficConfig.LIGHT_YELLOW_TIME,
	[6] = TrafficConfig.LIGHT_ALL_RED_TIME,
}

local function isGreenFor(direction)
	if direction == "east" or direction == "west" then
		return lightPhase == TrafficConfig.PHASE_H_GREEN
	else
		return lightPhase == TrafficConfig.PHASE_V_GREEN
	end
end

local function updateTrafficLights(dt)
	lightTimer = lightTimer + dt
	local duration = PHASE_DURATIONS[lightPhase]
	if lightTimer >= duration then
		lightTimer = lightTimer - duration
		lightPhase = (lightPhase % 6) + 1
		-- Broadcast phase change to all clients
		if lightRemote then
			lightRemote:FireAllClients(lightPhase)
		end
	end
end

--------------------------------------------------------------------------------
-- VEHICLE SPAWN / DESPAWN
--------------------------------------------------------------------------------

local function spawnRoadVehicle()
	if vehicleCount >= TrafficConfig.MAX_ROAD_VEHICLES then return end

	local node = RoadNetwork.getRandomNode()
	if not node or #node.connections == 0 then return end

	local conn = node.connections[math.random(#node.connections)]
	local templates = TrafficConfig.ROAD_TEMPLATES
	local templateName = templates[math.random(#templates)]

	local x, z = RoadNetwork.getPosition(node, conn.node, 0, conn.dir, conn.laneType)
	local yaw = dirToYaw(conn.dir)

	local id = nextId
	nextId = nextId + 1

	vehicles[id] = {
		id = id,
		templateName = templateName,
		x = x, z = z, yaw = yaw,
		fromNode = node,
		toNode = conn.node,
		progress = 0,
		direction = conn.dir,
		laneType = conn.laneType,
		speed = getSpeed(conn.laneType),
		segLen = conn.length,
	}
	vehicleCount = vehicleCount + 1

	if spawnRemote then
		spawnRemote:FireAllClients(id, templateName, x, z, yaw)
	end
end

local function despawnVehicle(id)
	if not vehicles[id] then return end
	vehicles[id] = nil
	vehicleCount = vehicleCount - 1
	if despawnRemote then
		despawnRemote:FireAllClients(id)
	end
end

--------------------------------------------------------------------------------
-- ROAD VEHICLE UPDATE
--------------------------------------------------------------------------------

local function updateRoadVehicles(dt)
	local toRemove = {}

	for id, v in pairs(vehicles) do
		if v.isTrain then continue end

		-- Stop at red light when approaching intersection
		local stopped = false
		if v.progress > 0.85 and v.progress < 1.0 then
			if not isGreenFor(v.direction) then
				stopped = true
			end
		end

		if not stopped then
			-- Advance along segment
			if v.segLen > 0 then
				v.progress = v.progress + (v.speed * dt) / v.segLen
			end
		end

		if v.progress >= 1 then
			-- Arrived at next node — pick next connection
			local arriveNode = v.toNode
			local excludeDir = RoadNetwork.oppositeDir(v.direction)
			local nextConn = RoadNetwork.pickRandomConnection(arriveNode, excludeDir)

			if nextConn then
				v.fromNode = arriveNode
				v.toNode = nextConn.node
				v.direction = nextConn.dir
				v.laneType = nextConn.laneType
				v.speed = getSpeed(nextConn.laneType)
				v.segLen = nextConn.length
				v.progress = 0
			else
				-- Dead end — despawn
				table.insert(toRemove, id)
			end
		end

		-- Update world position from road network
		local x, z = RoadNetwork.getPosition(
			v.fromNode, v.toNode,
			math.clamp(v.progress, 0, 1),
			v.direction, v.laneType
		)
		v.x = x
		v.z = z
		v.yaw = dirToYaw(v.direction)
	end

	for _, id in ipairs(toRemove) do
		despawnVehicle(id)
	end
end

--------------------------------------------------------------------------------
-- TRAIN
--------------------------------------------------------------------------------

local function spawnTrain()
	if trainId then return end
	if not railwayZ then return end

	local id = nextId
	nextId = nextId + 1

	local startX = railwayMinX

	vehicles[id] = {
		id = id,
		templateName = "Train_HighSpeed",
		x = startX,
		z = railwayZ,
		yaw = math.pi / 2,    -- facing east
		trainDir = 1,          -- 1=east, -1=west
		speed = TrafficConfig.TRAIN_SPEED,
		isTrain = true,
	}
	trainId = id
	vehicleCount = vehicleCount + 1

	if spawnRemote then
		spawnRemote:FireAllClients(id, "Train_HighSpeed", startX, railwayZ, math.pi / 2)
	end

	print("[VehicleTraffic] Train spawned, id =", id)
end

local function updateTrain(dt)
	if not trainId then return end
	local t = vehicles[trainId]
	if not t then return end

	t.x = t.x + t.trainDir * t.speed * dt

	-- Reverse at ends
	if t.trainDir == 1 and t.x >= railwayMaxX then
		t.x = railwayMaxX
		t.trainDir = -1
	elseif t.trainDir == -1 and t.x <= railwayMinX then
		t.x = railwayMinX
		t.trainDir = 1
	end

	t.yaw = t.trainDir == 1 and (math.pi / 2) or (-math.pi / 2)

	-- Toggle crossing warning lights
	for _, c in ipairs(crossings) do
		local dist = math.abs(t.x - c.x)
		local approaching = (t.trainDir == 1 and t.x < c.x) or (t.trainDir == -1 and t.x > c.x)
		setCrossingLights(c, dist < TrafficConfig.CROSSING_WARN_DIST and approaching)
	end
end

--------------------------------------------------------------------------------
-- RAILWAY INIT
--------------------------------------------------------------------------------

local function initRailway()
	for _, h in ipairs(GTAConfig.H_LANES) do
		if h.type == "railway" then
			railwayZ = GTAConfig.getRowEdgeZ(h.row)
			break
		end
	end

	if not railwayZ then
		print("[VehicleTraffic] No railway lane found")
		return
	end

	railwayMinX = GTAConfig.CITY_ORIGIN_X - 50
	railwayMaxX = GTAConfig.CITY_ORIGIN_X + GTAConfig.CITY_WIDTH + 50

	findCrossings()
end

--------------------------------------------------------------------------------
-- NETWORK BROADCAST
--------------------------------------------------------------------------------

local function broadcastPositions()
	if not syncRemote then return end

	-- Flat array: id, x, z, yaw, id, x, z, yaw, ...
	local payload = {}
	for id, v in pairs(vehicles) do
		table.insert(payload, id)
		table.insert(payload, v.x)
		table.insert(payload, v.z)
		table.insert(payload, v.yaw)
	end

	syncRemote:FireAllClients(payload)
end

-- Send full snapshot to a specific player (late join)
function VehicleTraffic.sendFullState(player)
	if not fullStateRemote then return end

	local vehicleList = {}
	for id, v in pairs(vehicles) do
		table.insert(vehicleList, {
			id = v.id,
			templateName = v.templateName,
			x = v.x, z = v.z, yaw = v.yaw,
		})
	end

	fullStateRemote:FireClient(player, {
		vehicles = vehicleList,
		lightPhase = lightPhase,
	})
end

--------------------------------------------------------------------------------
-- PUBLIC API
--------------------------------------------------------------------------------

function VehicleTraffic.init()
	-- Cache remotes
	syncRemote      = Remotes.get("TrafficSync")
	spawnRemote     = Remotes.get("TrafficSpawn")
	despawnRemote   = Remotes.get("TrafficDespawn")
	lightRemote     = Remotes.get("TrafficLightSync")
	fullStateRemote = Remotes.get("TrafficFullState")

	-- Init railway + crossings
	initRailway()

	-- Spawn train
	spawnTrain()

	-- Spawn initial road vehicles
	for _ = 1, math.min(10, TrafficConfig.MAX_ROAD_VEHICLES) do
		spawnRoadVehicle()
	end

	print(string.format("[VehicleTraffic] Started: %d road vehicles, train %s",
		vehicleCount - (trainId and 1 or 0), trainId and "active" or "none"))

	-- Heartbeat loop
	RunService.Heartbeat:Connect(function(dt)
		-- Simulate
		updateRoadVehicles(dt)
		updateTrain(dt)
		updateTrafficLights(dt)

		-- Spawn timer
		spawnTimer = spawnTimer + dt
		if spawnTimer >= TrafficConfig.SPAWN_INTERVAL then
			spawnTimer = 0
			spawnRoadVehicle()
		end

		-- Broadcast positions at SYNC_RATE Hz
		syncTimer = syncTimer + dt
		if syncTimer >= TrafficConfig.SYNC_INTERVAL then
			syncTimer = 0
			broadcastPositions()
		end
	end)
end

return VehicleTraffic
