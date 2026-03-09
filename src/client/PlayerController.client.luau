-- PlayerController.client.luau
-- Sprint (Shift) on top of Roblox's default movement.
-- Default controls handle WASD, jump, camera-relative movement.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

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

print("[PlayerController] Sprint loaded (Shift)")
