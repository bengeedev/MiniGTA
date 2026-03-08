-- PlayerController.client.luau
-- Camera-relative WASD movement + sprint.
-- Default Roblox controls are disabled in FreeCam.client.luau,
-- so this is the only thing driving Humanoid:Move().

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

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
		-- Auto-rotate character to face movement direction
		humanoid.AutoRotate = true
	end
end)

--------------------------------------------------------------------------------
-- MOVEMENT (every frame)
--------------------------------------------------------------------------------

local function isMovementKey(keyCode)
	return keyCode == Enum.KeyCode.W
		or keyCode == Enum.KeyCode.A
		or keyCode == Enum.KeyCode.S
		or keyCode == Enum.KeyCode.D
end

RunService.Heartbeat:Connect(function()
	local character = player.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end

	-- Read WASD
	local forward = UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0
	local backward = UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0
	local left = UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0
	local right = UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0

	local inputX = right - left
	local inputZ = backward - forward  -- negative Z = forward in Roblox

	if inputX == 0 and inputZ == 0 then
		humanoid:Move(Vector3.zero)
		return
	end

	-- Get camera's flat (XZ) look and right vectors
	local camCF = camera.CFrame
	local camLook = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z)
	if camLook.Magnitude < 0.001 then
		camLook = Vector3.new(0, 0, -1)
	end
	camLook = camLook.Unit

	local camRight = Vector3.new(-camLook.Z, 0, camLook.X)

	-- World-space movement direction
	local moveDir = camLook * -inputZ + camRight * inputX
	if moveDir.Magnitude > 0.001 then
		moveDir = moveDir.Unit
	end

	-- Move in world space (false = not relative to camera, we already computed world dir)
	humanoid:Move(moveDir, false)
end)

--------------------------------------------------------------------------------
-- INPUT: Sprint + Jump
--------------------------------------------------------------------------------

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
		setSprint(true)
	end

	-- Jump (since default controls are disabled)
	if input.KeyCode == Enum.KeyCode.Space then
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.Jump = true
			end
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
		setSprint(false)
	end
end)

print("[PlayerController] Camera-relative movement loaded — Shift=sprint, Space=jump")
