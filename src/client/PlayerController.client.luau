-- PlayerController.client.luau
-- GTA-style tank controls: A/D rotate, W/S forward/back, Shift sprint, Space jump.
-- Disables Roblox default WASD — we handle everything.
-- Camera (FreeCam) is untouched — it smoothly drifts behind the character.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

--------------------------------------------------------------------------------
-- CONFIG
--------------------------------------------------------------------------------

local WALK_SPEED      = 16
local SPRINT_SPEED    = 32
local BACK_SPEED_MULT = 0.5              -- backward is slower
local TURN_SPEED      = math.rad(200)    -- rotation speed (degrees/s)

--------------------------------------------------------------------------------
-- STATE
--------------------------------------------------------------------------------

local characterYaw = 0
local isSprinting  = false

--------------------------------------------------------------------------------
-- DISABLE ROBLOX DEFAULT MOVEMENT (we replace it entirely)
--------------------------------------------------------------------------------

local function disableDefaultControls()
	local ok, err = pcall(function()
		local playerScripts = player:WaitForChild("PlayerScripts", 10)
		local PlayerModule = require(playerScripts:WaitForChild("PlayerModule"))
		local controls = PlayerModule:GetControls()
		controls:Disable()
	end)
	if not ok then
		warn("[PlayerController] Could not disable default controls:", err)
	end
end

task.spawn(disableDefaultControls)

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
-- SPRINT (Shift toggle)
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
	if hrp then initYaw(hrp) end

	local humanoid = character:WaitForChild("Humanoid", 5)
	if humanoid then
		humanoid.AutoRotate = false  -- we handle rotation
	end
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

	-- Skip if typing in chat or seated in vehicle
	if UserInputService:GetFocusedTextBox() then return end
	if humanoid.Sit then return end

	-- Rotation: A/D or Left/Right arrows
	local turning = false
	if isDown(Enum.KeyCode.A) or isDown(Enum.KeyCode.Left) then
		characterYaw = characterYaw + TURN_SPEED * dt
		turning = true
	end
	if isDown(Enum.KeyCode.D) or isDown(Enum.KeyCode.Right) then
		characterYaw = characterYaw - TURN_SPEED * dt
		turning = true
	end

	-- Apply rotation (preserve physics position, only change facing)
	hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, characterYaw, 0)

	-- Movement: W/S or Up/Down arrows
	local speed = isSprinting and SPRINT_SPEED or WALK_SPEED
	local lookDir = hrp.CFrame.LookVector
	local moveDir = Vector3.zero

	if isDown(Enum.KeyCode.W) or isDown(Enum.KeyCode.Up) then
		moveDir = lookDir
	elseif isDown(Enum.KeyCode.S) or isDown(Enum.KeyCode.Down) then
		moveDir = -lookDir
		speed = speed * BACK_SPEED_MULT
	end

	humanoid.WalkSpeed = speed
	humanoid:Move(moveDir)

	-- Jump: Space
	if isDown(Enum.KeyCode.Space) then
		humanoid.Jump = true
	end
end)

print("[PlayerController] GTA tank controls (A/D turn, W/S move, Shift sprint)")
