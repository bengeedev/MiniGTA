-- VehicleDrivingClient.client.luau
-- Sends WASD / arrow input to server while player is driving a vehicle.
-- Also handles exit (E key) and camera follow.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared", 10)
local Remotes = require(Shared:WaitForChild("Remotes"))

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--------------------------------------------------------------------------------
-- STATE
--------------------------------------------------------------------------------

local isDriving = false
local driveInputRemote = nil
local exitVehicleRemote = nil

-- Input state
local keyState = {
	W = false, A = false, S = false, D = false,
	Up = false, Down = false, Left = false, Right = false,
}

-- Camera follow
local CAM_DISTANCE = 25
local CAM_HEIGHT = 12
local CAM_LERP = 0.08
local lastCamCF = nil

--------------------------------------------------------------------------------
-- INPUT HANDLING
--------------------------------------------------------------------------------

local KEY_MAP = {
	[Enum.KeyCode.W] = "W",
	[Enum.KeyCode.A] = "A",
	[Enum.KeyCode.S] = "S",
	[Enum.KeyCode.D] = "D",
	[Enum.KeyCode.Up] = "Up",
	[Enum.KeyCode.Down] = "Down",
	[Enum.KeyCode.Left] = "Left",
	[Enum.KeyCode.Right] = "Right",
}

local function onInputBegan(input, gameProcessed)
	if gameProcessed then return end
	if not isDriving then return end

	local mapped = KEY_MAP[input.KeyCode]
	if mapped then
		keyState[mapped] = true
	end

	-- Exit vehicle with E
	if input.KeyCode == Enum.KeyCode.E then
		if exitVehicleRemote then
			exitVehicleRemote:FireServer()
		end
	end
end

local function onInputEnded(input, _gameProcessed)
	local mapped = KEY_MAP[input.KeyCode]
	if mapped then
		keyState[mapped] = false
	end
end

local function getThrottle()
	local fwd = (keyState.W or keyState.Up) and 1 or 0
	local back = (keyState.S or keyState.Down) and 1 or 0
	return fwd - back
end

local function getSteer()
	local left = (keyState.A or keyState.Left) and 1 or 0
	local right = (keyState.D or keyState.Right) and 1 or 0
	return right - left
end

--------------------------------------------------------------------------------
-- CAMERA FOLLOW
--------------------------------------------------------------------------------

local function updateCamera()
	if not isDriving then return end

	local character = LocalPlayer.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	-- Get vehicle position (player is seated so HRP follows vehicle)
	local vehPos = hrp.Position
	local vehCF = hrp.CFrame

	-- Camera behind and above the vehicle
	local backDir = -vehCF.LookVector
	local targetPos = vehPos + backDir * CAM_DISTANCE + Vector3.new(0, CAM_HEIGHT, 0)
	local targetCF = CFrame.new(targetPos, vehPos)

	if lastCamCF then
		lastCamCF = lastCamCF:Lerp(targetCF, CAM_LERP)
	else
		lastCamCF = targetCF
	end

	Camera.CameraType = Enum.CameraType.Scriptable
	Camera.CFrame = lastCamCF
end

--------------------------------------------------------------------------------
-- SEND INPUT LOOP
--------------------------------------------------------------------------------

local INPUT_SEND_RATE = 1 / 20  -- 20 Hz
local inputTimer = 0
local lastThrottle = 0
local lastSteer = 0

local function updateInput(dt)
	if not isDriving then return end

	inputTimer = inputTimer + dt
	if inputTimer < INPUT_SEND_RATE then return end
	inputTimer = 0

	local throttle = getThrottle()
	local steer = getSteer()

	-- Only send if changed (reduce network)
	if throttle ~= lastThrottle or steer ~= lastSteer then
		lastThrottle = throttle
		lastSteer = steer
		if driveInputRemote then
			driveInputRemote:FireServer(throttle, steer)
		end
	end
end

--------------------------------------------------------------------------------
-- ENTER / EXIT HANDLERS
--------------------------------------------------------------------------------

local function onVehicleEntered(_templateName)
	isDriving = true
	lastCamCF = nil
	lastThrottle = 0
	lastSteer = 0
	inputTimer = 0
	-- Reset key state
	for k in pairs(keyState) do keyState[k] = false end
	print("[DrivingClient] Entered vehicle")
end

local function onVehicleExited()
	isDriving = false
	-- Restore camera
	Camera.CameraType = Enum.CameraType.Custom
	lastCamCF = nil
	-- Reset key state
	for k in pairs(keyState) do keyState[k] = false end
	-- Send zero input
	if driveInputRemote then
		driveInputRemote:FireServer(0, 0)
	end
	print("[DrivingClient] Exited vehicle")
end

--------------------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------------------

-- Connect remotes
driveInputRemote = Remotes.waitFor("DriveInput")
exitVehicleRemote = Remotes.waitFor("ExitVehicle")

local enteredR = Remotes.waitFor("VehicleEntered")
if enteredR then enteredR.OnClientEvent:Connect(onVehicleEntered) end

local exitedR = Remotes.waitFor("VehicleExited")
if exitedR then exitedR.OnClientEvent:Connect(onVehicleExited) end

-- Input
UserInputService.InputBegan:Connect(onInputBegan)
UserInputService.InputEnded:Connect(onInputEnded)

-- Update loops
RunService.RenderStepped:Connect(function(dt)
	updateCamera()
	updateInput(dt)
end)

print("[DrivingClient] Ready")
