-- FreeCam.client.luau
-- GTA-style third-person camera with gentle auto-follow.
-- Camera slowly drifts behind the character — no snapping, no nausea.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- Camera config
local distance = 10
local HEIGHT = 6
local LOOK_OFFSET_Y = 2
local FOLLOW_SPEED = 0.8 -- Smooth and gentle follow
local MIN_ZOOM = 6
local MAX_ZOOM = 50

local camera = Workspace.CurrentCamera
local yaw = 0

local function initYaw(hrp)
	local look = hrp.CFrame.LookVector
	yaw = math.atan2(-look.X, -look.Z)
end

local function update(dt)
	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	camera.CameraType = Enum.CameraType.Scriptable

	-- Gently rotate camera behind character when moving
	if humanoid.MoveDirection.Magnitude > 0.1 then
		local look = hrp.CFrame.LookVector
		local targetYaw = math.atan2(-look.X, -look.Z)

		local diff = targetYaw - yaw
		if diff > math.pi then diff = diff - 2 * math.pi end
		if diff < -math.pi then diff = diff + 2 * math.pi end

		yaw = yaw + diff * math.clamp(FOLLOW_SPEED * dt, 0, 1)
	end

	-- Position camera behind and above character
	local charPos = hrp.Position
	local offset = Vector3.new(
		math.sin(yaw) * distance,
		HEIGHT,
		math.cos(yaw) * distance
	)

	camera.CFrame = CFrame.new(charPos + offset, charPos + Vector3.new(0, LOOK_OFFSET_Y, 0))
end

-- Scroll to zoom
UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseWheel then
		distance = math.clamp(distance - input.Position.Z * 2, MIN_ZOOM, MAX_ZOOM)
	end
end)

-- Initialize on spawn
player.CharacterAdded:Connect(function(character)
	local hrp = character:WaitForChild("HumanoidRootPart", 5)
	if hrp then
		initYaw(hrp)
		task.wait(0.1)
	end
end)

if player.Character then
	local hrp = player.Character:FindFirstChild("HumanoidRootPart")
	if hrp then initYaw(hrp) end
end

RunService.RenderStepped:Connect(update)

print("[FreeCam] GTA-style camera loaded (gentle auto-follow)")
