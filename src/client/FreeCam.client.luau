-- FreeCam.client.luau
-- Third-person orbit camera: mouse rotate, scroll zoom, collision avoidance.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local mouse = player:GetMouse()

--------------------------------------------------------------------------------
-- CONFIG
--------------------------------------------------------------------------------

local MIN_DISTANCE = 5
local MAX_DISTANCE = 30
local DEFAULT_DISTANCE = 15
local ZOOM_STEP = 2
local SENSITIVITY_X = 0.4   -- degrees per pixel
local SENSITIVITY_Y = 0.25
local MIN_PITCH = -60
local MAX_PITCH = 70
local CAMERA_HEIGHT_OFFSET = 2  -- look above character center

--------------------------------------------------------------------------------
-- STATE
--------------------------------------------------------------------------------

local distance = DEFAULT_DISTANCE
local yaw = 0       -- horizontal angle (degrees)
local pitch = 15     -- vertical angle (degrees, positive = looking down)
local isRightMouseDown = false
local lastMousePos = Vector2.zero

-- Raycast params for collision
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

--------------------------------------------------------------------------------
-- INPUT
--------------------------------------------------------------------------------

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		isRightMouseDown = true
		lastMousePos = UserInputService:GetMouseLocation()
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		isRightMouseDown = false
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end
end)

UserInputService.InputChanged:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseWheel then
		distance = math.clamp(distance - input.Position.Z * ZOOM_STEP, MIN_DISTANCE, MAX_DISTANCE)
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement and isRightMouseDown then
		local delta = input.Delta
		yaw = yaw - delta.X * SENSITIVITY_X
		pitch = math.clamp(pitch + delta.Y * SENSITIVITY_Y, MIN_PITCH, MAX_PITCH)
	end
end)

-- Touch support: pinch zoom, drag rotate
local touchStartPositions = {}
local touchStartDistance = nil

UserInputService.TouchStarted:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	touchStartPositions[input] = input.Position

	-- Check for two-finger pinch
	local touches = {}
	for inp, _ in pairs(touchStartPositions) do
		table.insert(touches, inp)
	end
	if #touches == 2 then
		local p1 = touches[1].Position
		local p2 = touches[2].Position
		touchStartDistance = (p1 - p2).Magnitude
	end
end)

UserInputService.TouchMoved:Connect(function(input, gameProcessed)
	if not touchStartPositions[input] then return end

	-- Single finger: rotate
	local touches = {}
	for inp, _ in pairs(touchStartPositions) do
		table.insert(touches, inp)
	end

	if #touches == 1 then
		local delta = input.Position - touchStartPositions[input]
		yaw = yaw - delta.X * 0.3
		pitch = math.clamp(pitch + delta.Y * 0.2, MIN_PITCH, MAX_PITCH)
		touchStartPositions[input] = input.Position
	elseif #touches == 2 and touchStartDistance then
		local p1 = touches[1].Position
		local p2 = touches[2].Position
		local currentDist = (p1 - p2).Magnitude
		local scale = touchStartDistance / math.max(currentDist, 1)
		distance = math.clamp(distance * scale, MIN_DISTANCE, MAX_DISTANCE)
		touchStartDistance = currentDist
	end
end)

UserInputService.TouchEnded:Connect(function(input)
	touchStartPositions[input] = nil
	if not next(touchStartPositions) then
		touchStartDistance = nil
	end
end)

--------------------------------------------------------------------------------
-- CAMERA UPDATE
--------------------------------------------------------------------------------

RunService.RenderStepped:Connect(function()
	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	camera.CameraType = Enum.CameraType.Scriptable

	-- Target position (character + height offset)
	local targetPos = hrp.Position + Vector3.new(0, CAMERA_HEIGHT_OFFSET, 0)

	-- Calculate camera position from yaw/pitch/distance
	local yawRad = math.rad(yaw)
	local pitchRad = math.rad(pitch)
	local cosP = math.cos(pitchRad)

	local offset = Vector3.new(
		math.sin(yawRad) * cosP * distance,
		math.sin(pitchRad) * distance,
		math.cos(yawRad) * cosP * distance
	)

	local desiredPos = targetPos + offset

	-- Collision check: cast ray from target to desired camera position
	rayParams.FilterDescendantsInstances = { character }
	local direction = desiredPos - targetPos
	local result = Workspace:Raycast(targetPos, direction, rayParams)

	local finalPos = desiredPos
	if result then
		-- Pull camera in front of the hit, with a small margin
		finalPos = result.Position + result.Normal * 0.5
	end

	camera.CFrame = CFrame.lookAt(finalPos, targetPos)
end)

print("[FreeCam] Third-person camera loaded")
