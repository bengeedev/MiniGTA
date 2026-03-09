-- PlayerController.client.luau
-- GTA-style tank controls: A/D rotate, W/S forward/back, Shift sprint, Space jump.
-- Uses AlignOrientation for rotation (works with physics, no moonwalk).
-- Camera (FreeCam) untouched — smooth auto-follow.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

--------------------------------------------------------------------------------
-- CONFIG
--------------------------------------------------------------------------------

local WALK_SPEED      = 16
local SPRINT_SPEED    = 32
local BACK_SPEED_MULT = 0.5
local TURN_SPEED      = math.rad(200)   -- rotation speed

--------------------------------------------------------------------------------
-- STATE
--------------------------------------------------------------------------------

local characterYaw = 0
local isSprinting  = false
local alignOrientation = nil   -- AlignOrientation constraint (created per character)

--------------------------------------------------------------------------------
-- DISABLE ROBLOX DEFAULT MOVEMENT
--------------------------------------------------------------------------------

task.spawn(function()
	local ok, err = pcall(function()
		local playerScripts = player:WaitForChild("PlayerScripts", 10)
		local PlayerModule = require(playerScripts:WaitForChild("PlayerModule"))
		PlayerModule:GetControls():Disable()
	end)
	if not ok then
		warn("[PlayerController] Could not disable default controls:", err)
	end
end)

--------------------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------------------

local function isDown(keyCode)
	return UserInputService:IsKeyDown(keyCode)
end

local function initYaw(hrp)
	local look = hrp.CFrame.LookVector
	characterYaw = math.atan2(-look.X, -look.Z)
end

--------------------------------------------------------------------------------
-- SPRINT
--------------------------------------------------------------------------------

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
		isSprinting = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
		isSprinting = false
	end
end)

--------------------------------------------------------------------------------
-- CHARACTER SETUP
--------------------------------------------------------------------------------

local function setupCharacter(character)
	local hrp = character:WaitForChild("HumanoidRootPart", 5)
	if not hrp then return end

	initYaw(hrp)

	local humanoid = character:WaitForChild("Humanoid", 5)
	if humanoid then
		humanoid.AutoRotate = false
	end

	-- AlignOrientation: rotates character via physics (no CFrame fighting)
	local attachment = hrp:FindFirstChild("RootRigAttachment")
		or hrp:FindFirstChildWhichIsA("Attachment")
	if not attachment then
		attachment = Instance.new("Attachment")
		attachment.Name = "RootRigAttachment"
		attachment.Parent = hrp
	end

	alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Name = "TankControlGyro"
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.Attachment0 = attachment
	alignOrientation.RigidityEnabled = true
	alignOrientation.CFrame = CFrame.Angles(0, characterYaw, 0)
	alignOrientation.Parent = hrp
end

player.CharacterAdded:Connect(setupCharacter)
if player.Character then setupCharacter(player.Character) end

--------------------------------------------------------------------------------
-- MAIN UPDATE LOOP
--------------------------------------------------------------------------------

RunService.RenderStepped:Connect(function(dt)
	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end

	-- Skip if typing or seated
	if UserInputService:GetFocusedTextBox() then return end
	if humanoid.Sit then return end

	-- Rotation: A/D or arrow keys
	if isDown(Enum.KeyCode.A) or isDown(Enum.KeyCode.Left) then
		characterYaw = characterYaw + TURN_SPEED * dt
	end
	if isDown(Enum.KeyCode.D) or isDown(Enum.KeyCode.Right) then
		characterYaw = characterYaw - TURN_SPEED * dt
	end

	-- Apply rotation via AlignOrientation (physics-friendly, no moonwalk)
	if alignOrientation then
		alignOrientation.CFrame = CFrame.Angles(0, characterYaw, 0)
	end

	-- Compute facing direction from our yaw (not from hrp.CFrame which may lag)
	local lookDir = CFrame.Angles(0, characterYaw, 0).LookVector

	-- Movement: W/S or arrow keys
	local speed = isSprinting and SPRINT_SPEED or WALK_SPEED
	local moveDir = Vector3.zero

	if isDown(Enum.KeyCode.W) or isDown(Enum.KeyCode.Up) then
		moveDir = lookDir
	elseif isDown(Enum.KeyCode.S) or isDown(Enum.KeyCode.Down) then
		moveDir = -lookDir
		speed = speed * BACK_SPEED_MULT
	end

	humanoid.WalkSpeed = speed
	humanoid:Move(moveDir)

	-- Jump
	if isDown(Enum.KeyCode.Space) then
		humanoid.Jump = true
	end
end)

print("[PlayerController] GTA tank controls (A/D turn, W/S move, Shift sprint)")
