-- FreeCam.client.luau
-- GTA-style third-person camera: auto-follows behind player movement,
-- mouse/touch to look around, auto-returns behind player, scroll zoom, collision.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

--------------------------------------------------------------------------------
-- CONFIG
--------------------------------------------------------------------------------

local MIN_DISTANCE = 5
local MAX_DISTANCE = 30
local DEFAULT_DISTANCE = 12
local ZOOM_STEP = 2
local SENSITIVITY_X = 0.4   -- degrees per pixel
local SENSITIVITY_Y = 0.25
local MIN_PITCH = -30
local MAX_PITCH = 60
local DEFAULT_PITCH = 20
local CAMERA_HEIGHT_OFFSET = 3  -- look above character center

-- Auto-follow: camera smoothly rotates behind player when moving
local AUTO_FOLLOW_SPEED = 4      -- how fast camera catches up (radians/sec)
local AUTO_FOLLOW_DELAY = 1.0    -- seconds after manual look before auto-follow resumes
local MOVE_THRESHOLD = 0.5       -- min speed to trigger auto-follow

--------------------------------------------------------------------------------
-- STATE
--------------------------------------------------------------------------------

local distance = DEFAULT_DISTANCE
local yaw = 0       -- horizontal angle (degrees)
local pitch = DEFAULT_PITCH
local isManualLook = false       -- player is actively looking with mouse/touch
local lastManualLookTime = 0     -- when player last touched the camera
local lastHrpPosition = nil      -- for tracking movement direction

-- Raycast params for collision
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

--------------------------------------------------------------------------------
-- INPUT: Mouse
--------------------------------------------------------------------------------

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		isManualLook = true
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		isManualLook = false
		lastManualLookTime = tick()
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseWheel then
		distance = math.clamp(distance - input.Position.Z * ZOOM_STEP, MIN_DISTANCE, MAX_DISTANCE)
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement and isManualLook then
		local delta = input.Delta
		yaw = yaw - delta.X * SENSITIVITY_X
		pitch = math.clamp(pitch + delta.Y * SENSITIVITY_Y, MIN_PITCH, MAX_PITCH)
	end
end)

--------------------------------------------------------------------------------
-- INPUT: Touch (single finger = look, pinch = zoom)
--------------------------------------------------------------------------------

local touchStartPositions = {}
local touchStartDistance = nil

UserInputService.TouchStarted:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	touchStartPositions[input] = input.Position

	local touches = {}
	for inp, _ in pairs(touchStartPositions) do
		table.insert(touches, inp)
	end
	if #touches == 2 then
		touchStartDistance = (touches[1].Position - touches[2].Position).Magnitude
	end
end)

UserInputService.TouchMoved:Connect(function(input)
	if not touchStartPositions[input] then return end

	local touches = {}
	for inp, _ in pairs(touchStartPositions) do
		table.insert(touches, inp)
	end

	if #touches == 1 then
		local delta = input.Position - touchStartPositions[input]
		yaw = yaw - delta.X * 0.3
		pitch = math.clamp(pitch + delta.Y * 0.2, MIN_PITCH, MAX_PITCH)
		touchStartPositions[input] = input.Position
		lastManualLookTime = tick()
	elseif #touches == 2 and touchStartDistance then
		local currentDist = (touches[1].Position - touches[2].Position).Magnitude
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

RunService.RenderStepped:Connect(function(dt)
	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	camera.CameraType = Enum.CameraType.Scriptable

	-- Track movement direction for auto-follow
	local currentPos = hrp.Position
	local moveDir = nil
	local moveSpeed = 0

	if lastHrpPosition then
		local delta = Vector3.new(currentPos.X - lastHrpPosition.X, 0, currentPos.Z - lastHrpPosition.Z)
		moveSpeed = delta.Magnitude / math.max(dt, 0.001)
		if moveSpeed > MOVE_THRESHOLD then
			moveDir = delta.Unit
		end
	end
	lastHrpPosition = currentPos

	-- Auto-follow: smoothly rotate camera behind player when moving
	local timeSinceManual = tick() - lastManualLookTime
	if not isManualLook and timeSinceManual > AUTO_FOLLOW_DELAY and moveDir then
		-- Calculate target yaw from movement direction
		local targetYaw = math.deg(math.atan2(moveDir.X, moveDir.Z))

		-- Smooth rotation towards target (shortest path)
		local diff = targetYaw - yaw
		-- Normalize to [-180, 180]
		while diff > 180 do diff -= 360 end
		while diff < -180 do diff += 360 end

		-- Lerp speed scales with how fast the player is moving
		local speedFactor = math.clamp(moveSpeed / 20, 0.3, 1.0)
		local step = AUTO_FOLLOW_SPEED * speedFactor * dt * 60

		if math.abs(diff) < step then
			yaw = targetYaw
		else
			yaw = yaw + math.sign(diff) * step
		end
	end

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
		finalPos = result.Position + result.Normal * 0.5
	end

	camera.CFrame = CFrame.lookAt(finalPos, targetPos)
end)

print("[FreeCam] GTA-style follow camera loaded")
