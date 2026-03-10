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
-- COLLISION AVOIDANCE (segment-based spatial index)
--------------------------------------------------------------------------------

local intersectionOccupied = {}  -- [nodeId] = true when a vehicle is turning there

local function buildIntersectionIndex()
	for k in pairs(intersectionOccupied) do intersectionOccupied[k] = nil end

	for _, v in pairs(vehicles) do
		if v.isTrain then continue end
		if v.turning and v.turnFromNode then
			intersectionOccupied[v.turnFromNode.id] = true
		end
	end
end

-- World-space forward proximity: scan ALL vehicles, find nearest one ahead.
-- "Ahead" = within a forward cone based on vehicle's yaw direction.
local PROXIMITY_RANGE = 40  -- max scan range (studs)
local CONE_DOT = 0.7        -- cos(~45°) — how wide the "ahead" cone is

local function distToVehicleAhead(v)
	-- Vehicle's forward direction from yaw (sin=X, cos=Z in Roblox convention)
	local fwdX = math.sin(v.yaw)
	local fwdZ = math.cos(v.yaw)

	local nearest = math.huge

	for _, other in pairs(vehicles) do
		if other == v or other.isTrain then continue end

		local dx = other.x - v.x
		local dz = other.z - v.z
		local dist = math.sqrt(dx * dx + dz * dz)

		if dist < PROXIMITY_RANGE and dist > 0.1 then
			-- Is 'other' in front of us? (dot product with forward vector)
			local dot = (dx * fwdX + dz * fwdZ) / dist
			if dot > CONE_DOT then
				if dist < nearest then
					nearest = dist
				end
			end
		end
	end

	return nearest
end

--------------------------------------------------------------------------------
-- BEZIER TURN HELPERS
--------------------------------------------------------------------------------

local TURN_SPEED_FACTOR = 0.6  -- vehicles slow down during turns
local TURN_RADIUS = 20         -- studs before/after intersection for smooth arc

-- Quadratic Bezier: position at t
local function bezierPos(t, p0x, p0z, p1x, p1z, p2x, p2z)
	local mt = 1 - t
	return mt * mt * p0x + 2 * mt * t * p1x + t * t * p2x,
	       mt * mt * p0z + 2 * mt * t * p1z + t * t * p2z
end

-- Quadratic Bezier: tangent at t (unnormalized)
local function bezierTan(t, p0x, p0z, p1x, p1z, p2x, p2z)
	local mt = 1 - t
	return 2 * mt * (p1x - p0x) + 2 * t * (p2x - p1x),
	       2 * mt * (p1z - p0z) + 2 * t * (p2z - p1z)
end

-- Approximate Bezier arc length (8 linear segments)
local function bezierLen(p0x, p0z, p1x, p1z, p2x, p2z)
	local len = 0
	local px, pz = p0x, p0z
	for i = 1, 8 do
		local nx, nz = bezierPos(i / 8, p0x, p0z, p1x, p1z, p2x, p2z)
		local dx, dz = nx - px, nz - pz
		len = len + math.sqrt(dx * dx + dz * dz)
		px, pz = nx, nz
	end
	return len
end

-- Build turn curve: P0 is TURN_RADIUS before intersection on incoming lane,
-- P2 is TURN_RADIUS after intersection on outgoing lane,
-- P1 is the corner where the two lane lines meet (tangent-correct).
-- This ensures tangent at P0 = incoming direction, tangent at P2 = outgoing direction.
local function buildTurnCurve(v, arriveNode, nextConn)
	local inDir = v.direction
	local outDir = nextConn.dir
	local inLaneType = v.laneType
	local outLaneType = nextConn.laneType

	-- Clamp entry/exit fractions so turn doesn't eat more than 40% of segment
	local entryFrac = math.clamp(TURN_RADIUS / v.segLen, 0.05, 0.4)
	local exitFrac  = math.clamp(TURN_RADIUS / nextConn.length, 0.05, 0.4)

	-- P0: position on current segment at (1 - entryFrac)
	local p0x, p0z = RoadNetwork.getPosition(
		v.fromNode, arriveNode, 1 - entryFrac, inDir, inLaneType
	)

	-- P2: position on next segment at exitFrac
	local p2x, p2z = RoadNetwork.getPosition(
		arriveNode, nextConn.node, exitFrac, outDir, outLaneType
	)

	-- P1: corner where the incoming lane line meets the outgoing lane line.
	-- Incoming H (east/west) → P1 has same Z as P0, same X as P2.
	-- Incoming V (north/south) → P1 has same X as P0, same Z as P2.
	local p1x, p1z
	if inDir == "east" or inDir == "west" then
		p1x, p1z = p2x, p0z
	else
		p1x, p1z = p0x, p2z
	end

	return p0x, p0z, p1x, p1z, p2x, p2z, entryFrac, exitFrac
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

-- Cached physical traffic light models (found after city is built)
local trafficLightModels = nil  -- { { model, dir="H"|"V" }, ... }

local function findTrafficLightModels()
	trafficLightModels = {}
	local decorFolder = Workspace:FindFirstChild("World") and Workspace.World:FindFirstChild("Decor")
	if not decorFolder then return end

	for _, child in ipairs(decorFolder:GetChildren()) do
		if child:IsA("Model") and child.Name:find("TrafficLight") then
			local dir = child:GetAttribute("TrafficDir")
			if dir then
				table.insert(trafficLightModels, { model = child, dir = dir })
			end
		end
	end

	print(string.format("[VehicleTraffic] Found %d physical traffic lights", #trafficLightModels))
end

-- Toggle physical light colors based on current phase
local function updatePhysicalLights()
	if not trafficLightModels then return end

	for _, entry in ipairs(trafficLightModels) do
		local isGreen = (entry.dir == "H" and lightPhase == TrafficConfig.PHASE_H_GREEN)
			or (entry.dir == "V" and lightPhase == TrafficConfig.PHASE_V_GREEN)
		local isYellow = (entry.dir == "H" and lightPhase == TrafficConfig.PHASE_H_YELLOW)
			or (entry.dir == "V" and lightPhase == TrafficConfig.PHASE_V_YELLOW)
		local isRed = not isGreen and not isYellow

		for _, part in ipairs(entry.model:GetDescendants()) do
			if part.Name == "GreenLight" then
				part.Material = isGreen and Enum.Material.Neon or Enum.Material.SmoothPlastic
				part.Color = isGreen and part:GetAttribute("OnColor") or part:GetAttribute("OffColor")
			elseif part.Name == "YellowLight" then
				part.Material = isYellow and Enum.Material.Neon or Enum.Material.SmoothPlastic
				part.Color = isYellow and part:GetAttribute("OnColor") or part:GetAttribute("OffColor")
			elseif part.Name == "RedLight" then
				part.Material = isRed and Enum.Material.Neon or Enum.Material.SmoothPlastic
				part.Color = isRed and part:GetAttribute("OnColor") or part:GetAttribute("OffColor")
			end
		end
	end
end

local function updateTrafficLights(dt)
	lightTimer = lightTimer + dt
	local duration = PHASE_DURATIONS[lightPhase]
	if lightTimer >= duration then
		lightTimer = lightTimer - duration
		lightPhase = (lightPhase % 6) + 1

		-- Update physical traffic light models
		updatePhysicalLights()

		-- Broadcast phase change to all clients
		if lightRemote then
			lightRemote:FireAllClients(lightPhase)
		end
	end
end

--------------------------------------------------------------------------------
-- VEHICLE SPAWN / DESPAWN
--------------------------------------------------------------------------------

-- Check if a segment+progress spot is too close to an existing vehicle
local MIN_SPAWN_GAP = 25  -- studs between spawned vehicles on same segment
local function isSpawnClear(node, toNode, progress, segLen)
	local key = node.id .. "_" .. toNode.id
	for _, v in pairs(vehicles) do
		if v.isTrain then continue end
		if v.fromNode.id == node.id and v.toNode.id == toNode.id then
			local dist = math.abs(v.progress - progress) * segLen
			if dist < MIN_SPAWN_GAP then
				return false
			end
		end
	end
	return true
end

-- spread=true: random progress along segment (for initial spawn)
local function spawnRoadVehicle(spread)
	if vehicleCount >= TrafficConfig.MAX_ROAD_VEHICLES then return end

	-- Try a few times to find a clear spot (avoid overlapping spawns)
	local node, conn, progress
	for _attempt = 1, 5 do
		node = RoadNetwork.getRandomNode()
		if not node or #node.connections == 0 then continue end

		conn = node.connections[math.random(#node.connections)]
		progress = spread and (0.1 + math.random() * 0.8) or 0

		if isSpawnClear(node, conn.node, progress, conn.length) then
			break
		end
		conn = nil  -- mark as failed
	end
	if not conn then return end

	local templates = TrafficConfig.ROAD_TEMPLATES
	local templateName = templates[math.random(#templates)]

	local x, z = RoadNetwork.getPosition(node, conn.node, progress, conn.dir, conn.laneType)
	local yaw = dirToYaw(conn.dir)

	-- Per-vehicle speed variation so not all cars move identically
	local baseSpeed = getSpeed(conn.laneType)
	local speedFactor = 1 + (math.random() * 2 - 1) * TrafficConfig.SPEED_VARIATION

	local id = nextId
	nextId = nextId + 1

	vehicles[id] = {
		id = id,
		templateName = templateName,
		x = x, z = z, yaw = yaw,
		fromNode = node,
		toNode = conn.node,
		progress = progress,
		direction = conn.dir,
		laneType = conn.laneType,
		speed = baseSpeed * speedFactor,
		speedFactor = speedFactor,
		segLen = conn.length,
		-- Pre-compute next turn at destination
		pendingConn = RoadNetwork.pickRandomConnection(
			conn.node, RoadNetwork.oppositeDir(conn.dir)
		),
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

local function startTurn(v, arriveNode, nextConn)
	local p0x, p0z, p1x, p1z, p2x, p2z, _entryFrac, exitFrac = buildTurnCurve(
		v, arriveNode, nextConn
	)
	local arcLen = bezierLen(p0x, p0z, p1x, p1z, p2x, p2z)

	v.turning = true
	v.turnT = 0
	v.turnLen = math.max(arcLen, 1)
	v.turnSpeed = v.speed * TURN_SPEED_FACTOR
	v.tp0x, v.tp0z = p0x, p0z
	v.tp1x, v.tp1z = p1x, p1z
	v.tp2x, v.tp2z = p2x, p2z

	-- Stash the next segment so we can resume after the turn
	v.nextNode = nextConn.node
	v.nextDir = nextConn.dir
	v.nextLane = nextConn.laneType
	v.nextSegLen = nextConn.length
	v.turnFromNode = arriveNode
	v.turnExitFrac = exitFrac
end

local function finishTurn(v)
	v.fromNode = v.turnFromNode
	v.toNode = v.nextNode
	v.direction = v.nextDir
	v.laneType = v.nextLane
	v.speed = getSpeed(v.nextLane) * (v.speedFactor or 1)
	v.segLen = v.nextSegLen
	v.progress = v.turnExitFrac  -- resume part-way into next segment (curve ended here)
	v.turning = false
	-- Clean up turn fields
	v.turnT, v.turnLen, v.turnSpeed = nil, nil, nil
	v.tp0x, v.tp0z, v.tp1x, v.tp1z, v.tp2x, v.tp2z = nil, nil, nil, nil, nil, nil
	v.nextNode, v.nextDir, v.nextLane, v.nextSegLen, v.turnFromNode = nil, nil, nil, nil, nil
	v.turnExitFrac = nil

	-- Pre-compute next connection for this new segment
	v.pendingConn = RoadNetwork.pickRandomConnection(v.toNode, RoadNetwork.oppositeDir(v.direction))
end

local function updateRoadVehicles(dt)
	local toRemove = {}

	for id, v in pairs(vehicles) do
		if v.isTrain then continue end

		if v.turning then
			-- Advance along Bezier arc
			v.turnT = v.turnT + (v.turnSpeed * dt) / v.turnLen
			if v.turnT >= 1 then
				finishTurn(v)
			end
		else
			-- Pre-compute next connection if not done yet
			if not v.pendingConn and v.toNode then
				v.pendingConn = RoadNetwork.pickRandomConnection(
					v.toNode, RoadNetwork.oppositeDir(v.direction)
				)
			end

			-- Determine if a turn is needed and when it starts
			local willTurn = v.pendingConn and v.pendingConn.dir ~= v.direction
			local turnStart = 1.0  -- straight-through: go all the way to progress=1
			if willTurn then
				turnStart = 1 - math.clamp(TURN_RADIUS / v.segLen, 0.05, 0.4)
			end

			-- Traffic lights: roads stop at red, highways flow freely
			local stopped = false
			if v.laneType ~= "highway" and v.progress > 0.75 and v.progress < turnStart then
				if not isGreenFor(v.direction) then
					stopped = true
				end
			end

			-- Intersection occupancy: if another vehicle is turning at our destination
			-- intersection, stop before entering (prevents cross-traffic clipping)
			if not stopped and v.toNode and v.progress > 0.8 then
				if intersectionOccupied[v.toNode.id] then
					stopped = true
				end
			end

			-- Collision avoidance: slow down / stop if vehicle ahead is too close
			local followMult = 1.0
			if not stopped then
				local dist = distToVehicleAhead(v)
				if dist < TrafficConfig.FOLLOW_DIST then
					if dist <= TrafficConfig.STOP_DIST then
						followMult = 0
					else
						followMult = (dist - TrafficConfig.STOP_DIST)
							/ (TrafficConfig.FOLLOW_DIST - TrafficConfig.STOP_DIST)
					end
				end
			end

			if not stopped then
				if v.segLen > 0 then
					v.progress = v.progress + (v.speed * followMult * dt) / v.segLen
				end
			end

			-- Check if we should start a turn (before reaching the intersection)
			if willTurn and v.progress >= turnStart and not stopped then
				startTurn(v, v.toNode, v.pendingConn)
				v.pendingConn = nil
			elseif v.progress >= 1 then
				-- Reached intersection — straight through or dead end
				local nextConn = v.pendingConn
				v.pendingConn = nil

				if nextConn then
					v.fromNode = v.toNode
					v.toNode = nextConn.node
					v.direction = nextConn.dir
					v.laneType = nextConn.laneType
					v.speed = getSpeed(nextConn.laneType) * (v.speedFactor or 1)
					v.segLen = nextConn.length
					v.progress = 0
					-- Pre-compute next connection
					v.pendingConn = RoadNetwork.pickRandomConnection(
						v.toNode, RoadNetwork.oppositeDir(v.direction)
					)
				else
					table.insert(toRemove, id)
				end
			end
		end

		-- Update position (after state transitions, covers both turning and straight)
		if v.turning then
			local t = v.turnT
			v.x, v.z = bezierPos(t, v.tp0x, v.tp0z, v.tp1x, v.tp1z, v.tp2x, v.tp2z)
			local dx, dz = bezierTan(t, v.tp0x, v.tp0z, v.tp1x, v.tp1z, v.tp2x, v.tp2z)
			v.yaw = math.atan2(dx, dz)
		elseif not v.isTrain then
			local x, z = RoadNetwork.getPosition(
				v.fromNode, v.toNode,
				math.clamp(v.progress, 0, 1),
				v.direction, v.laneType
			)
			v.x = x
			v.z = z
			v.yaw = dirToYaw(v.direction)
		end
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

local BATCH_SIZE = 20  -- max vehicles per UnreliableRemoteEvent (~720 bytes)

local function broadcastPositions()
	if not syncRemote then return end

	-- Split into batches to stay under UnreliableRemoteEvent size limit (~900 bytes)
	local payload = {}
	local count = 0
	for _, v in pairs(vehicles) do
		payload[#payload + 1] = v.id
		payload[#payload + 1] = v.x
		payload[#payload + 1] = v.z
		payload[#payload + 1] = v.yaw
		count += 1

		if count >= BATCH_SIZE then
			syncRemote:FireAllClients(payload)
			payload = {}
			count = 0
		end
	end

	-- Send remaining
	if count > 0 then
		syncRemote:FireAllClients(payload)
	end
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

	-- Find physical traffic light models (placed by CityBuilder)
	findTrafficLightModels()
	updatePhysicalLights()  -- set initial light state

	-- Spawn train
	spawnTrain()

	-- Spawn ALL road vehicles immediately with spread positions (no gradual pop-in)
	for _ = 1, TrafficConfig.MAX_ROAD_VEHICLES do
		spawnRoadVehicle(true)
	end

	print(string.format("[VehicleTraffic] Started: %d road vehicles, train %s",
		vehicleCount - (trainId and 1 or 0), trainId and "active" or "none"))

	-- Heartbeat loop
	RunService.Heartbeat:Connect(function(dt)
		-- Build spatial index for collision avoidance
		buildIntersectionIndex()

		-- Simulate
		updateRoadVehicles(dt)
		updateTrain(dt)
		updateTrafficLights(dt)

		-- Replenish despawned vehicles slowly (spread across road)
		spawnTimer = spawnTimer + dt
		if spawnTimer >= TrafficConfig.REPLENISH_INTERVAL then
			spawnTimer = 0
			if vehicleCount < TrafficConfig.MAX_ROAD_VEHICLES then
				spawnRoadVehicle(true)
			end
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
