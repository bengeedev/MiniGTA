-- VehicleDrivingClient.client.luau
-- Camera follow + exit handling while driving.
-- WASD input is handled natively by VehicleSeat (seat.Steer / seat.Throttle)
-- read directly by the server — no network latency.

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
local exitVehicleRemote = nil

-- Camera follow
local CAM_DISTANCE = 25
local CAM_HEIGHT = 12
local CAM_LERP = 0.08
local lastCamCF = nil

--------------------------------------------------------------------------------
-- EXIT INPUT (E key)
--------------------------------------------------------------------------------

local function onInputBegan(input, gameProcessed)
	if gameProcessed then return end
	if not isDriving then return end

	if input.KeyCode == Enum.KeyCode.E then
		if exitVehicleRemote then
			exitVehicleRemote:FireServer()
		end
	end
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
-- ENTER / EXIT HANDLERS
--------------------------------------------------------------------------------

local function onVehicleEntered(_templateName)
	isDriving = true
	lastCamCF = nil
	print("[DrivingClient] Entered vehicle")
end

local function onVehicleExited()
	isDriving = false
	Camera.CameraType = Enum.CameraType.Custom
	lastCamCF = nil
	print("[DrivingClient] Exited vehicle")
end

--------------------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------------------

exitVehicleRemote = Remotes.waitFor("ExitVehicle")

local enteredR = Remotes.waitFor("VehicleEntered")
if enteredR then enteredR.OnClientEvent:Connect(onVehicleEntered) end

local exitedR = Remotes.waitFor("VehicleExited")
if exitedR then exitedR.OnClientEvent:Connect(onVehicleExited) end

UserInputService.InputBegan:Connect(onInputBegan)

RunService.RenderStepped:Connect(updateCamera)

print("[DrivingClient] Ready")
