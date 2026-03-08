-- PlayerController.client.luau
-- Camera-relative movement (WASD moves toward camera look direction),
-- sprint (Shift), interaction (E).

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local Shared = ReplicatedStorage:WaitForChild("Shared", 10)
local GTAConfig = require(Shared:WaitForChild("GTAConfig"))

--------------------------------------------------------------------------------
-- SPRINT
--------------------------------------------------------------------------------

local DEFAULT_WALK_SPEED = 16
local SPRINT_SPEED = 32
local isSprinting = false

local function setSprint(sprinting)
	isSprinting = sprinting
	local character = player.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	humanoid.WalkSpeed = sprinting and SPRINT_SPEED or DEFAULT_WALK_SPEED
end

player.CharacterAdded:Connect(function(character)
	local humanoid = character:WaitForChild("Humanoid", 5)
	if humanoid then
		humanoid.WalkSpeed = isSprinting and SPRINT_SPEED or DEFAULT_WALK_SPEED
	end
end)

--------------------------------------------------------------------------------
-- CAMERA-RELATIVE MOVEMENT
-- Roblox default Humanoid:Move() uses world-space. We override it each frame
-- so WASD is relative to where the camera is looking.
--------------------------------------------------------------------------------

RunService.RenderStepped:Connect(function()
	local character = player.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	-- Build move vector from keyboard input
	local moveX, moveZ = 0, 0

	if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveZ -= 1 end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveZ += 1 end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveX -= 1 end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveX += 1 end

	if moveX == 0 and moveZ == 0 then
		humanoid:Move(Vector3.zero)
		return
	end

	-- Get camera's flat look/right vectors (ignore pitch)
	local camCF = camera.CFrame
	local camLook = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z)
	if camLook.Magnitude > 0.001 then
		camLook = camLook.Unit
	else
		camLook = Vector3.new(0, 0, -1)
	end
	local camRight = Vector3.new(camLook.Z, 0, -camLook.X) -- 90° rotated

	-- Combine into world-space direction
	local worldDir = (camLook * -moveZ + camRight * moveX)
	if worldDir.Magnitude > 0.001 then
		worldDir = worldDir.Unit
	end

	humanoid:Move(worldDir, false)
end)

--------------------------------------------------------------------------------
-- INPUT
--------------------------------------------------------------------------------

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
		setSprint(true)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
		setSprint(false)
	end
end)

print("[PlayerController] Camera-relative movement loaded — Shift to sprint")
