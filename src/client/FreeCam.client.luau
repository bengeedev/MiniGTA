-- FreeCam.client.luau
-- GTA-style third-person camera.
-- Camera stays behind the character's facing direction.
-- Right-click to free-look; releases and smoothly returns behind player.
-- Scroll to zoom. Collision avoidance.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

--------------------------------------------------------------------------------
-- Disable default Roblox camera + controls (we handle everything)
--------------------------------------------------------------------------------

local playerScripts = player:WaitForChild("PlayerScripts", 5)
if playerScripts then
	local ok, PlayerModule = pcall(function()
		return require(playerScripts:WaitForChild("PlayerModule", 5))
	end)
	if ok and PlayerModule then
		local controls = PlayerModule:GetControls()
		if controls then
			controls:Disable()
		end
	end
end

--------------------------------------------------------------------------------
-- CONFIG
--------------------------------------------------------------------------------

local MIN_DISTANCE = 6
local MAX_DISTANCE = 30
local DEFAULT_DISTANCE = 14
local ZOOM_STEP = 2
local SENSITIVITY_X = 0.3
local SENSITIVITY_Y = 0.2
local MIN_PITCH = -20
local MAX_PITCH = 60
local DEFAULT_PITCH = 18
local CAMERA_HEIGHT_OFFSET = 3

-- How fast camera returns behind player after free-look (deg/sec)
local RETURN_SPEED = 120
local RETURN_DELAY = 0.8  -- seconds after releasing right-click before returning

--------------------------------------------------------------------------------
-- STATE
--------------------------------------------------------------------------------

local distance = DEFAULT_DISTANCE
local yaw = 0        -- camera yaw offset from character facing (0 = directly behind)
local pitch = DEFAULT_PITCH
local isFreeLook = false
local lastFreeLookTime = 0

-- Raycast params
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

--------------------------------------------------------------------------------
-- INPUT: Mouse
--------------------------------------------------------------------------------

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		isFreeLook = true
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		isFreeLook = false
		lastFreeLookTime = tick()
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseWheel then
		distance = math.clamp(distance - input.Position.Z * ZOOM_STEP, MIN_DISTANCE, MAX_DISTANCE)
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement and isFreeLook then
		yaw = yaw - input.Delta.X * SENSITIVITY_X
		pitch = math.clamp(pitch + input.Delta.Y * SENSITIVITY_Y, MIN_PITCH, MAX_PITCH)
	end
end)

--------------------------------------------------------------------------------
-- INPUT: Touch
--------------------------------------------------------------------------------

local touchStartPositions = {}
local touchStartDistance = nil

UserInputService.TouchStarted:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	touchStartPositions[input] = input.Position
	local touches = {}
	for inp, _ in pairs(touchStartPositions) do table.insert(touches, inp) end
	if #touches == 2 then
		touchStartDistance = (touches[1].Position - touches[2].Position).Magnitude
	end
end)

UserInputService.TouchMoved:Connect(function(input)
	if not touchStartPositions[input] then return end
	local touches = {}
	for inp, _ in pairs(touchStartPositions) do table.insert(touches, inp) end

	if #touches == 1 then
		local delta = input.Position - touchStartPositions[input]
		yaw = yaw - delta.X * 0.3
		pitch = math.clamp(pitch + delta.Y * 0.2, MIN_PITCH, MAX_PITCH)
		touchStartPositions[input] = input.Position
		lastFreeLookTime = tick()
	elseif #touches == 2 and touchStartDistance then
		local currentDist = (touches[1].Position - touches[2].Position).Magnitude
		distance = math.clamp(distance * (touchStartDistance / math.max(currentDist, 1)), MIN_DISTANCE, MAX_DISTANCE)
		touchStartDistance = currentDist
	end
end)

UserInputService.TouchEnded:Connect(function(input)
	touchStartPositions[input] = nil
	if not next(touchStartPositions) then touchStartDistance = nil end
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

	-- Get character facing angle (Y rotation)
	local _, charYaw, _ = hrp.CFrame:ToEulerAnglesYXZ()
	local charYawDeg = math.deg(charYaw)

	-- Return yaw to 0 (behind character) when not free-looking
	if not isFreeLook and (tick() - lastFreeLookTime) > RETURN_DELAY then
		if math.abs(yaw) > 0.5 then
			local step = RETURN_SPEED * dt
			if math.abs(yaw) < step then
				yaw = 0
			else
				yaw = yaw - math.sign(yaw) * step
			end
		else
			yaw = 0
		end
	end

	-- Final camera angle = character facing + yaw offset + 180° (behind)
	local cameraYawDeg = charYawDeg + yaw + 180
	local cameraYawRad = math.rad(cameraYawDeg)
	local pitchRad = math.rad(pitch)
	local cosP = math.cos(pitchRad)

	-- Target = character position + height
	local targetPos = hrp.Position + Vector3.new(0, CAMERA_HEIGHT_OFFSET, 0)

	-- Camera offset from target
	local offset = Vector3.new(
		math.sin(cameraYawRad) * cosP * distance,
		math.sin(pitchRad) * distance,
		math.cos(cameraYawRad) * cosP * distance
	)

	local desiredPos = targetPos + offset

	-- Collision
	rayParams.FilterDescendantsInstances = { character }
	local result = Workspace:Raycast(targetPos, desiredPos - targetPos, rayParams)
	local finalPos = result and (result.Position + result.Normal * 0.5) or desiredPos

	camera.CFrame = CFrame.lookAt(finalPos, targetPos)
end)

print("[FreeCam] GTA-style camera loaded")
