-- VehicleDriving.luau
-- Server: spawns drivable vehicles in the world with ProximityPrompts.
-- Handles enter/exit, receives input from client, moves vehicle via PivotTo.

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared", 10)
local GTAConfig = require(Shared:WaitForChild("GTAConfig"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local VehicleDriving = {}

--------------------------------------------------------------------------------
-- CONSTANTS
--------------------------------------------------------------------------------

local GROUND_Y = GTAConfig.GROUND_Y
local VEHICLE_SURFACE = GROUND_Y + 2   -- terrain voxel top + clearance (matches client)
local MAX_SPEED = GTAConfig.VEHICLE_SPEEDS.car          -- 60 studs/sec
local TURN_RATE = GTAConfig.TURN_RATE                    -- rad/sec (~120°/sec)
local ACCELERATION = 40       -- studs/sec² to reach max speed
local BRAKE_DECEL = 80        -- studs/sec² when braking / reversing
local FRICTION_DECEL = 20     -- studs/sec² passive slowdown (no input)
local REVERSE_MAX = 20        -- max reverse speed
local PROMPT_DISTANCE = 10    -- studs to see the ProximityPrompt
local STEER_LERP = 4          -- smoothing factor for steering input
local ACCEL_LERP = 4          -- smoothing factor for throttle input

--------------------------------------------------------------------------------
-- STATE
--------------------------------------------------------------------------------

-- All spawned drivable vehicles: [model] = { speed, yaw, driver, ... }
local drivables = {}

-- Per-player input: [player] = { throttle, steer }  (-1..1 each)
local playerInput = {}

-- Per-player vehicle reference: [player] = drivable entry
local playerVehicle = {}

-- Folder for drivable vehicles in Workspace
local vehicleFolder = nil

-- Remotes
local vehicleEnteredRemote = nil
local vehicleExitedRemote = nil
local exitVehicleRemote = nil
local driveInputRemote = nil  -- new: client sends input

--------------------------------------------------------------------------------
-- VEHICLE SPAWNING
--------------------------------------------------------------------------------

local function computePlaceY(model)
	-- Find lowest part bottom to place model on ground
	local lowestBottom = math.huge
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") and part.Transparency < 1 then
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
	return VEHICLE_SURFACE + 3
end

-- Spawn a drivable vehicle at a world position
function VehicleDriving.spawnVehicle(templateName, worldX, worldZ, yaw)
	local templates = ReplicatedStorage:FindFirstChild("VehicleTemplates")
	if not templates then
		warn("[VehicleDriving] VehicleTemplates folder not found")
		return nil
	end

	local template = templates:FindFirstChild(templateName)
	if not template then
		warn("[VehicleDriving] Template not found:", templateName)
		return nil
	end

	local model = template:Clone()
	local placeY = computePlaceY(model)
	yaw = yaw or 0

	-- Position model BEFORE welding (so weld offsets are captured at correct positions)
	model:PivotTo(CFrame.new(worldX, placeY, worldZ) * CFrame.Angles(0, yaw, 0))

	-- Find chassis (same as DashOrCrash: PrimaryPart or explicit "Chassis" part)
	local chassis = model.PrimaryPart or model:FindFirstChild("Chassis")
	if not chassis then
		for _, p in ipairs(model:GetDescendants()) do
			if p:IsA("BasePart") then
				chassis = p
				break
			end
		end
	end
	model.PrimaryPart = chassis

	-- Weld all parts to chassis so CFrame moves everything atomically (no flicker)
	if chassis then
		for _, part in ipairs(model:GetDescendants()) do
			if part:IsA("BasePart") and part ~= chassis then
				part.Anchored = false
				local weld = Instance.new("WeldConstraint")
				weld.Part0 = chassis
				weld.Part1 = part
				weld.Parent = part
			end
		end
		chassis.Anchored = true
	end

	-- Add ProximityPrompt to the chassis / PrimaryPart
	local promptParent = root or model:FindFirstChildWhichIsA("BasePart")
	if promptParent then
		local prompt = Instance.new("ProximityPrompt")
		prompt.ObjectText = model.Name:gsub("_Drivable", ""):gsub("_", " ")
		prompt.ActionText = "Drive"
		prompt.KeyboardKeyCode = Enum.KeyCode.E
		prompt.MaxActivationDistance = PROMPT_DISTANCE
		prompt.HoldDuration = 0
		prompt.RequiresLineOfSight = false
		prompt.Parent = promptParent
	end

	model.Parent = vehicleFolder

	local entry = {
		model = model,
		templateName = templateName,
		speed = 0,
		yaw = yaw,
		placeY = placeY,
		driver = nil,     -- Player or nil
		prompt = promptParent and promptParent:FindFirstChildOfClass("ProximityPrompt"),
	}

	drivables[model] = entry

	-- Connect prompt
	if entry.prompt then
		entry.prompt.Triggered:Connect(function(player)
			VehicleDriving.enterVehicle(player, entry)
		end)
	end

	print("[VehicleDriving] Spawned", templateName, "at", worldX, worldZ)
	return entry
end

--------------------------------------------------------------------------------
-- ENTER / EXIT
--------------------------------------------------------------------------------

function VehicleDriving.enterVehicle(player, entry)
	-- Already occupied?
	if entry.driver then return end
	-- Player already in a vehicle?
	if playerVehicle[player] then return end

	local character = player.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end

	-- Find the DrivingSeat
	local seat = entry.model:FindFirstChild("DrivingSeat")
	if not seat then
		warn("[VehicleDriving] No DrivingSeat in", entry.model.Name)
		return
	end

	-- Sit the player
	seat:Sit(humanoid)

	entry.driver = player
	entry.smoothThrottle = 0
	entry.smoothSteer = 0
	playerVehicle[player] = entry
	playerInput[player] = { throttle = 0, steer = 0 }

	-- Hide prompt while occupied
	if entry.prompt then
		entry.prompt.Enabled = false
	end

	-- Notify client
	if vehicleEnteredRemote then
		vehicleEnteredRemote:FireClient(player, entry.templateName)
	end

	print("[VehicleDriving]", player.Name, "entered", entry.templateName)
end

function VehicleDriving.exitVehicle(player)
	local entry = playerVehicle[player]
	if not entry then return end

	local character = player.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.Sit = false
		end

		-- Teleport player to the side of the vehicle
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp and entry.model.PrimaryPart then
			local vehCF = entry.model.PrimaryPart.CFrame
			-- Exit to the left side (driver side)
			local exitPos = vehCF * CFrame.new(-5, 0, 0)
			hrp.CFrame = CFrame.new(exitPos.X, GROUND_Y + 5, exitPos.Z)
		end
	end

	entry.driver = nil
	entry.speed = 0
	playerVehicle[player] = nil
	playerInput[player] = nil

	-- Re-enable prompt
	if entry.prompt then
		entry.prompt.Enabled = true
	end

	-- Notify client
	if vehicleExitedRemote then
		vehicleExitedRemote:FireClient(player)
	end

	print("[VehicleDriving]", player.Name, "exited", entry.templateName)
end

--------------------------------------------------------------------------------
-- PHYSICS UPDATE (server-authoritative)
--------------------------------------------------------------------------------

local function updateVehicles(dt)
	for _, entry in pairs(drivables) do
		if not entry.driver then continue end

		local chassis = entry.model and entry.model.PrimaryPart
		if not chassis then continue end

		-- Read input directly from VehicleSeat (no network latency)
		local seat = entry.model:FindFirstChild("DrivingSeat")
		if not seat then continue end

		local rawThrottle = seat.Throttle  -- -1 (S), 0, 1 (W)
		local rawSteer = seat.Steer        -- -1 (A), 0, 1 (D)

		-- Smooth input via LERP (prevents jitter from discrete key presses)
		local lerpAlpha = math.min(1, ACCEL_LERP * dt)
		local steerAlpha = math.min(1, STEER_LERP * dt)
		entry.smoothThrottle = entry.smoothThrottle + (rawThrottle - entry.smoothThrottle) * lerpAlpha
		entry.smoothSteer = entry.smoothSteer + (rawSteer - entry.smoothSteer) * steerAlpha

		local throttle = entry.smoothThrottle
		local steer = entry.smoothSteer

		-- Acceleration / braking
		if throttle > 0.05 then
			entry.speed = entry.speed + ACCELERATION * throttle * dt
			entry.speed = math.min(entry.speed, MAX_SPEED)
		elseif throttle < -0.05 then
			if entry.speed > 1 then
				entry.speed = entry.speed - BRAKE_DECEL * math.abs(throttle) * dt
				entry.speed = math.max(entry.speed, 0)
			else
				entry.speed = entry.speed + ACCELERATION * throttle * dt
				entry.speed = math.max(entry.speed, -REVERSE_MAX)
			end
		else
			-- Friction: coast to stop
			if entry.speed > 0 then
				entry.speed = math.max(0, entry.speed - FRICTION_DECEL * dt)
			elseif entry.speed < 0 then
				entry.speed = math.min(0, entry.speed + FRICTION_DECEL * dt)
			end
		end

		-- Steering (only when moving)
		local speedFraction = math.abs(entry.speed) / MAX_SPEED
		if speedFraction > 0.01 then
			local turnMult = math.clamp(1.2 - speedFraction * 0.5, 0.5, 1.2)
			entry.yaw = entry.yaw - steer * TURN_RATE * turnMult * dt
		end

		-- Move — direct CFrame on chassis (NOT PivotTo, which causes micro-shake)
		local fwdX = math.sin(entry.yaw)
		local fwdZ = math.cos(entry.yaw)
		local pos = chassis.Position

		local newX = pos.X + fwdX * entry.speed * dt
		local newZ = pos.Z + fwdZ * entry.speed * dt

		chassis.CFrame = CFrame.new(newX, entry.placeY, newZ) * CFrame.Angles(0, entry.yaw, 0)
	end
end

--------------------------------------------------------------------------------
-- CLEANUP
--------------------------------------------------------------------------------

local function onPlayerLeaving(player)
	if playerVehicle[player] then
		VehicleDriving.exitVehicle(player)
	end
end

--------------------------------------------------------------------------------
-- PUBLIC API
--------------------------------------------------------------------------------

-- Returns a list of { x, z } for all drivable vehicles (for NPC traffic avoidance)
function VehicleDriving.getVehiclePositions()
	local positions = {}
	for _, entry in pairs(drivables) do
		if entry.model and entry.model.Parent then
			local pos = entry.model:GetPivot().Position
			positions[#positions + 1] = { x = pos.X, z = pos.Z }
		end
	end
	return positions
end

function VehicleDriving.init(vehFolder)
	vehicleFolder = vehFolder or Workspace

	-- Cache remotes
	vehicleEnteredRemote = Remotes.get("VehicleEntered")
	vehicleExitedRemote = Remotes.get("VehicleExited")
	exitVehicleRemote = Remotes.get("ExitVehicle")
	driveInputRemote = Remotes.get("DriveInput")

	-- Client requests exit
	if exitVehicleRemote then
		exitVehicleRemote.OnServerEvent:Connect(function(player)
			VehicleDriving.exitVehicle(player)
		end)
	end

	-- Client sends driving input (throttle, steer)
	if driveInputRemote then
		driveInputRemote.OnServerEvent:Connect(function(player, throttle, steer)
			if not playerInput[player] then return end
			playerInput[player].throttle = math.clamp(throttle or 0, -1, 1)
			playerInput[player].steer = math.clamp(steer or 0, -1, 1)
		end)
	end

	-- Cleanup on leave
	Players.PlayerRemoving:Connect(onPlayerLeaving)

	-- Physics loop
	RunService.Heartbeat:Connect(updateVehicles)

	print("[VehicleDriving] Initialized")
end

return VehicleDriving
