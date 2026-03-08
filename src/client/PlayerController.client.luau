-- PlayerController.client.luau
-- Sprint (Shift), interaction (E key) for MiniGTA.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

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

-- Re-apply walk speed on respawn
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

	-- Shift = sprint
	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
		setSprint(true)
	end

	-- E = interact (ProximityPrompts handle this natively, but we can add custom logic)
	if input.KeyCode == Enum.KeyCode.E then
		-- Future: custom interaction logic beyond ProximityPrompts
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
		setSprint(false)
	end
end)

print("[PlayerController] Controls loaded — Shift to sprint")
