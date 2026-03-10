-- VehicleTrafficClient.client.luau
-- Renders NPC traffic vehicles with client-side interpolation.
-- Server sends data-only position updates; client creates/moves model clones.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared", 10)
local GTAConfig = require(Shared:WaitForChild("GTAConfig"))
local TrafficConfig = require(Shared:WaitForChild("TrafficConfig"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--------------------------------------------------------------------------------
-- STATE
--------------------------------------------------------------------------------

-- Template cache: [templateName] = template model reference
local templateCache = {}

-- Active vehicles: [id] = { model, targetCF, currentCF, visible }
local activeVehicles = {}

-- Local folder for traffic models (client-only, not replicated)
local trafficFolder = Instance.new("Folder")
trafficFolder.Name = "TrafficVehicles"
trafficFolder.Parent = Workspace

local GROUND_Y = GTAConfig.GROUND_Y
local VEHICLE_SURFACE = GROUND_Y + 2  -- terrain voxel top + clearance (same as DashOrCrash)

-- Per-template Y: world Y to place PrimaryPart so the model bottom sits on surface.
local templatePlaceY = {}   -- [templateName] = world Y for PivotTo

--------------------------------------------------------------------------------
-- TEMPLATE LOADING
--------------------------------------------------------------------------------

-- Check if a part belongs to a seated NPC model (exclude from vehicle bbox)
local function isNPCPart(part, vehicle)
	local parent = part.Parent
	while parent and parent ~= vehicle do
		if parent:IsA("Model") and parent.Name:find("NPC_") then
			return true
		end
		parent = parent.Parent
	end
	return false
end

-- Compute Y so model bottom touches GROUND_Y (scans visible non-NPC parts)
local function computePlaceY(model)
	local lowestBottom = math.huge
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") and part.Transparency < 1 and not isNPCPart(part, model) then
			local cf = part.CFrame
			local s = part.Size / 2
			local yExtent = math.abs(cf.RightVector.Y) * s.X
						  + math.abs(cf.UpVector.Y) * s.Y
						  + math.abs(cf.LookVector.Y) * s.Z
			local bottomY = cf.Position.Y - yExtent
			if bottomY < lowestBottom then
				lowestBottom = bottomY
			end
		end
	end

	if model.PrimaryPart and lowestBottom < math.huge then
		local ppToBottom = model.PrimaryPart.Position.Y - lowestBottom
		return VEHICLE_SURFACE + ppToBottom
	end

	return VEHICLE_SURFACE + 3  -- fallback
end

local function loadTemplates()
	local folder = ReplicatedStorage:WaitForChild("VehicleTemplates", 15)
	if not folder then
		warn("[TrafficClient] VehicleTemplates folder not found")
		return
	end

	for _, child in ipairs(folder:GetChildren()) do
		if child:IsA("Model") then
			templateCache[child.Name] = child
			templatePlaceY[child.Name] = computePlaceY(child)
		end
	end

	print(string.format("[TrafficClient] Cached %d vehicle templates", #folder:GetChildren()))
end

local function getTemplate(name)
	return templateCache[name]
end

--------------------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------------------

local function makeCFrame(x, z, yaw, templateName)
	local y = templatePlaceY[templateName] or (GROUND_Y + 3)
	return CFrame.new(x, y, z) * CFrame.Angles(0, yaw, 0)
end

local function setModelCFrame(model, cf)
	if model.PrimaryPart then
		model:PivotTo(cf)
	else
		for _, child in ipairs(model:GetDescendants()) do
			if child:IsA("BasePart") then
				model.PrimaryPart = child
				model:PivotTo(cf)
				return
			end
		end
	end
end

--------------------------------------------------------------------------------
-- VEHICLE MANAGEMENT
--------------------------------------------------------------------------------

local function createVehicle(id, templateName, x, z, yaw)
	local template = getTemplate(templateName)
	if not template then
		warn("[TrafficClient] Template not found:", templateName)
		return
	end

	local cf = makeCFrame(x, z, yaw, templateName)

	local model = template:Clone()
	setModelCFrame(model, cf)

	-- Anchor all parts (client-rendered, no physics)
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
		end
	end

	model.Parent = trafficFolder

	activeVehicles[id] = {
		model = model,
		templateName = templateName,
		targetCF = cf,
		currentCF = cf,
		visible = true,
	}
end

local function destroyVehicle(id)
	local entry = activeVehicles[id]
	if not entry then return end

	if entry.model then
		entry.model:Destroy()
	end
	activeVehicles[id] = nil
end

--------------------------------------------------------------------------------
-- REMOTE HANDLERS
--------------------------------------------------------------------------------

local function onTrafficSpawn(id, templateName, x, z, yaw)
	if activeVehicles[id] then return end  -- already exists
	createVehicle(id, templateName, x, z, yaw)
end

local function onTrafficDespawn(id)
	destroyVehicle(id)
end

local function onTrafficSync(payload)
	-- Flat array: id, x, z, yaw, id, x, z, yaw, ...
	for i = 1, #payload, 4 do
		local id  = payload[i]
		local x   = payload[i + 1]
		local z   = payload[i + 2]
		local yaw = payload[i + 3]

		local entry = activeVehicles[id]
		if entry then
			entry.targetCF = makeCFrame(x, z, yaw, entry.templateName)
		end
	end
end

local function onTrafficFullState(data)
	-- Clear existing vehicles (collect IDs first to avoid modifying during iteration)
	local ids = {}
	for id in pairs(activeVehicles) do
		table.insert(ids, id)
	end
	for _, id in ipairs(ids) do
		destroyVehicle(id)
	end

	-- Spawn all vehicles from snapshot
	for _, v in ipairs(data.vehicles) do
		createVehicle(v.id, v.templateName, v.x, v.z, v.yaw)
	end

	print(string.format("[TrafficClient] Full state: %d vehicles, light phase %d",
		#data.vehicles, data.lightPhase or 0))
end

local function onTrafficLightSync(_phase)
	-- Traffic light phase received. Currently used by server for vehicle stop logic.
	-- Visual traffic light models can use this in the future.
end

--------------------------------------------------------------------------------
-- RENDER LOOP (interpolation + distance culling)
--------------------------------------------------------------------------------

local function updateRendering(dt)
	local camPos = Camera and Camera.CFrame.Position or Vector3.zero
	local cullDist2 = TrafficConfig.CULL_DISTANCE * TrafficConfig.CULL_DISTANCE

	-- Frame-rate adaptive lerp: normalize to 60fps baseline
	local dtNorm = dt / (1 / 60)
	local alpha = math.clamp(TrafficConfig.LERP_SPEED * dtNorm, 0, 1)

	for _id, entry in pairs(activeVehicles) do
		if not entry.model or not entry.model.Parent then continue end

		-- Distance culling
		local pos = entry.targetCF.Position
		local dx = pos.X - camPos.X
		local dz = pos.Z - camPos.Z
		local dist2 = dx * dx + dz * dz

		if dist2 > cullDist2 then
			-- Hide
			if entry.visible then
				entry.visible = false
				for _, part in ipairs(entry.model:GetDescendants()) do
					if part:IsA("BasePart") then
						part.Transparency = 1
					end
				end
			end
		else
			-- Show
			if not entry.visible then
				entry.visible = true
				for _, part in ipairs(entry.model:GetDescendants()) do
					if part:IsA("BasePart") then
						-- Restore original transparency (assume 0 for vehicle parts)
						part.Transparency = 0
					end
				end
			end

			-- Interpolate toward target
			entry.currentCF = entry.currentCF:Lerp(entry.targetCF, alpha)
			setModelCFrame(entry.model, entry.currentCF)
		end
	end
end

--------------------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------------------

-- Load templates immediately
loadTemplates()

-- Connect remotes
local spawnR = Remotes.waitFor("TrafficSpawn")
if spawnR then spawnR.OnClientEvent:Connect(onTrafficSpawn) end

local despawnR = Remotes.waitFor("TrafficDespawn")
if despawnR then despawnR.OnClientEvent:Connect(onTrafficDespawn) end

local syncR = Remotes.waitFor("TrafficSync")
if syncR then syncR.OnClientEvent:Connect(onTrafficSync) end

local fullR = Remotes.waitFor("TrafficFullState")
if fullR then fullR.OnClientEvent:Connect(onTrafficFullState) end

local lightR = Remotes.waitFor("TrafficLightSync")
if lightR then lightR.OnClientEvent:Connect(onTrafficLightSync) end

-- Render loop
RunService.RenderStepped:Connect(updateRendering)

print("[TrafficClient] Ready")
