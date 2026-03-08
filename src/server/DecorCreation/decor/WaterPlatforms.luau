local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local WaterPlatforms = {}

local CONVEYOR_TEXTURE = "rbxassetid://122309393401046"

function WaterPlatforms.createWaterPlatformsDrift(x, z, scale, direction)
	if not DecorUtils.decorFolder then return nil end
	scale = scale or 1
	direction = direction or 1 -- 1 = right, -1 = left
	local PLAYABLE_WIDTH = DecorUtils.PLAYABLE_WIDTH
	local BUILDING_BASE = DecorUtils.BUILDING_BASE
	local activePlatformAnimations = DecorUtils.activePlatformAnimations
	local model = Instance.new("Model")
	model.Name = "WaterPlatformsDrift"

	local LANE_DEPTH = 12
	local PLATFORM_W = 12
	local PLATFORM_D = 8
	local PLATFORM_H = 1.5
	local GAP = 4 -- gap between platforms
	local DRIFT_SPEED = 6 -- studs/s
	local halfPlayable = PLAYABLE_WIDTH / 2
	local OFFSCREEN_MARGIN = 30 -- spawn/despawn well outside camera view
	local step = PLATFORM_W + GAP
	local centerZ = z -- centered in the narrow lane
	-- Fill enough platforms to cover width + offscreen margins for seamless wrap
	local totalWidth = PLAYABLE_WIDTH + OFFSCREEN_MARGIN * 2
	local count = math.ceil(totalWidth / step) + 1

	for i = 0, count - 1 do
		local px = -halfPlayable - OFFSCREEN_MARGIN + i * step

		local platform = Instance.new("Part")
		platform.Name = "DriftPlatform_" .. i
		platform.Size = Vector3.new(PLATFORM_W, PLATFORM_H, PLATFORM_D)
		platform.Position = Vector3.new(px, BUILDING_BASE + 0.75, centerZ)
		platform.Anchored = true
		platform.CanCollide = true
		platform.Material = Enum.Material.Wood
		platform.Color = Color3.fromRGB(139, 90, 43)
		platform.Parent = model

		activePlatformAnimations[platform] = {
			type = "drifting",
			speed = DRIFT_SPEED * direction,
			minX = -halfPlayable - OFFSCREEN_MARGIN - PLATFORM_W / 2,
			maxX = halfPlayable + OFFSCREEN_MARGIN + PLATFORM_W / 2,
			wrapWidth = count * step,
			baseY = BUILDING_BASE + 0.75,
			baseZ = centerZ,
		}
	end

	model.Parent = DecorUtils.decorFolder
	return model
end

-- Convenience wrappers for left/right
function WaterPlatforms.createWaterPlatformsDriftRight(x, z, scale)
	return WaterPlatforms.createWaterPlatformsDrift(x, z, scale, 1)
end

function WaterPlatforms.createWaterPlatformsDriftLeft(x, z, scale)
	return WaterPlatforms.createWaterPlatformsDrift(x, z, scale, -1)
end

function WaterPlatforms.createWaterPlatformsWide(x, z, scale)
	if not DecorUtils.decorFolder then return nil end
	scale = scale or 1
	local PLAYABLE_WIDTH = DecorUtils.PLAYABLE_WIDTH
	local BUILDING_BASE = DecorUtils.BUILDING_BASE
	local model = Instance.new("Model")
	model.Name = "WaterPlatformsWide"

	local LANE_DEPTH = 64
	local ROW_COUNT = 4
	local rowSpacing = LANE_DEPTH / ROW_COUNT
	local halfPlayable = PLAYABLE_WIDTH / 2 -- 40
	local halfDepth = LANE_DEPTH / 2

	for row = 0, ROW_COUNT - 1 do
		local rowZ = z + halfDepth - (row + 0.5) * rowSpacing
		local count = math.random(3, 5)
		local slotWidth = PLAYABLE_WIDTH / count

		for i = 0, count - 1 do
			local slotCenter = -halfPlayable + (i + 0.5) * slotWidth
			local jitter = (math.random() - 0.5) * (slotWidth * 0.4)
			local px = slotCenter + jitter

			local platform = Instance.new("Part")
			platform.Name = "Platform_" .. row .. "_" .. i
			platform.Size = Vector3.new(10, 1.5, 10)
			platform.Position = Vector3.new(px, BUILDING_BASE + 0.75, rowZ)
			platform.Anchored = true
			platform.CanCollide = true
			platform.Material = Enum.Material.Wood
			platform.Color = Color3.fromRGB(139, 90, 43)
			platform.Parent = model
		end
	end

	model.Parent = DecorUtils.decorFolder
	return model
end

function WaterPlatforms.createWaterPlatformsSinking(x, z, scale)
	if not DecorUtils.decorFolder then return nil end
	scale = scale or 1
	local PLAYABLE_WIDTH = DecorUtils.PLAYABLE_WIDTH
	local BUILDING_BASE = DecorUtils.BUILDING_BASE
	local activePlatformAnimations = DecorUtils.activePlatformAnimations
	local model = Instance.new("Model")
	model.Name = "WaterPlatformsSinking"

	local LANE_DEPTH = 64
	local ROW_COUNT = 4
	local COL_COUNT = 5
	local rowSpacing = LANE_DEPTH / ROW_COUNT
	local halfPlayable = PLAYABLE_WIDTH / 2
	local halfDepth = LANE_DEPTH / 2
	local colSpacing = PLAYABLE_WIDTH / COL_COUNT
	local CYCLE_DURATION = 7

	for row = 0, ROW_COUNT - 1 do
		local rowZ = z + halfDepth - (row + 0.5) * rowSpacing
		for col = 0, COL_COUNT - 1 do
			local px = -halfPlayable + (col + 0.5) * colSpacing

			local platform = Instance.new("Part")
			platform.Name = "SinkPlatform_" .. row .. "_" .. col
			platform.Size = Vector3.new(10, 1.5, 10)
			platform.Position = Vector3.new(px, BUILDING_BASE + 0.75, rowZ)
			platform.Anchored = true
			platform.CanCollide = true
			platform.Material = Enum.Material.Wood
			platform.Color = Color3.fromRGB(139, 90, 43)
			platform.Parent = model

			local phaseOffset = math.random() * CYCLE_DURATION
			activePlatformAnimations[platform] = {
				type = "sinking",
				baseY = BUILDING_BASE + 0.75,
				sunkY = BUILDING_BASE - 3,
				phaseOffset = phaseOffset,
				cycleDuration = CYCLE_DURATION,
			}
		end
	end

	model.Parent = DecorUtils.decorFolder
	return model
end

function WaterPlatforms.createWaterPlatformsRotating(x, z, scale)
	if not DecorUtils.decorFolder then return nil end
	scale = scale or 1
	local PLAYABLE_WIDTH = DecorUtils.PLAYABLE_WIDTH
	local BUILDING_BASE = DecorUtils.BUILDING_BASE
	local activePlatformAnimations = DecorUtils.activePlatformAnimations
	local model = Instance.new("Model")
	model.Name = "WaterPlatformsRotating"

	local LANE_DEPTH = 64
	local ROW_COUNT = 4
	local COL_COUNT = 4
	local rowSpacing = LANE_DEPTH / ROW_COUNT
	local halfPlayable = PLAYABLE_WIDTH / 2
	local halfDepth = LANE_DEPTH / 2
	local colSpacing = PLAYABLE_WIDTH / COL_COUNT

	for row = 0, ROW_COUNT - 1 do
		local rowZ = z + halfDepth - (row + 0.5) * rowSpacing
		for col = 0, COL_COUNT - 1 do
			local px = -halfPlayable + (col + 0.5) * colSpacing

			local platform = Instance.new("Part")
			platform.Name = "RotPlatform_" .. row .. "_" .. col
			platform.Size = Vector3.new(10, 1.5, 10)
			platform.Position = Vector3.new(px, BUILDING_BASE + 0.75, rowZ)
			platform.Anchored = true
			platform.CanCollide = true
			platform.Material = Enum.Material.Slate
			platform.Color = Color3.fromRGB(120, 120, 125)
			platform.Parent = model

			local speed = math.rad(20 + math.random() * 40) -- 20-60 deg/s in radians
			local direction = math.random() < 0.5 and 1 or -1
			activePlatformAnimations[platform] = {
				type = "rotating",
				centerX = px,
				centerY = BUILDING_BASE + 0.75,
				centerZ = rowZ,
				angle = 0,
				speed = speed * direction,
			}
		end
	end

	model.Parent = DecorUtils.decorFolder
	return model
end

function WaterPlatforms.createWaterPlatformsMill(x, z, scale)
	if not DecorUtils.decorFolder then return nil end
	scale = scale or 1
	local PLAYABLE_WIDTH = DecorUtils.PLAYABLE_WIDTH
	local BUILDING_BASE = DecorUtils.BUILDING_BASE
	local activePlatformAnimations = DecorUtils.activePlatformAnimations
	local model = Instance.new("Model")
	model.Name = "WaterPlatformsMill"

	local LANE_DEPTH = 64
	local ROW_COUNT = 4
	local COL_COUNT = 4
	local rowSpacing = LANE_DEPTH / ROW_COUNT
	local halfPlayable = PLAYABLE_WIDTH / 2
	local halfDepth = LANE_DEPTH / 2
	local colSpacing = PLAYABLE_WIDTH / COL_COUNT

	for row = 0, ROW_COUNT - 1 do
		local rowZ = z + halfDepth - (row + 0.5) * rowSpacing
		for col = 0, COL_COUNT - 1 do
			local px = -halfPlayable + (col + 0.5) * colSpacing

			local platform = Instance.new("Part")
			platform.Name = "MillPlatform_" .. row .. "_" .. col
			platform.Size = Vector3.new(10, 1.5, 10)
			platform.Position = Vector3.new(px, BUILDING_BASE + 0.75, rowZ)
			platform.Anchored = true
			platform.CanCollide = true
			platform.Material = Enum.Material.Wood
			platform.Color = Color3.fromRGB(100, 65, 30)
			platform.Parent = model

			local phaseOffset = math.random() * 6 -- random phase for variety
			activePlatformAnimations[platform] = {
				type = "mill",
				centerX = px,
				centerY = BUILDING_BASE + 0.75,
				centerZ = rowZ,
				angle = 0,
				maxAngle = math.rad(20 + math.random() * 10), -- oscillate ±20-30 degrees
				oscillateSpeed = 1.5 + math.random() * 1.0, -- 1.5-2.5 rad/s cycle speed
				phaseOffset = phaseOffset,
			}
		end
	end

	model.Parent = DecorUtils.decorFolder
	return model
end

function WaterPlatforms.createWaterPlatformsConveyor(x, z, scale)
	if not DecorUtils.decorFolder then return nil end
	scale = scale or 1
	local PLAYABLE_WIDTH = DecorUtils.PLAYABLE_WIDTH
	local BUILDING_BASE = DecorUtils.BUILDING_BASE
	local activePlatformAnimations = DecorUtils.activePlatformAnimations
	local model = Instance.new("Model")
	model.Name = "WaterPlatformsConveyor"

	local LANE_DEPTH = 64
	local ROW_COUNT = 4
	local COL_COUNT = 4
	local rowSpacing = LANE_DEPTH / ROW_COUNT
	local halfPlayable = PLAYABLE_WIDTH / 2
	local halfDepth = LANE_DEPTH / 2
	local colSpacing = PLAYABLE_WIDTH / COL_COUNT
	local PLATFORM_SIZE = 10
	local PLATFORM_HEIGHT = 1.5

	for row = 0, ROW_COUNT - 1 do
		local rowZ = z + halfDepth - (row + 0.5) * rowSpacing
		for col = 0, COL_COUNT - 1 do
			local px = -halfPlayable + (col + 0.5) * colSpacing
			local dirX = math.random() < 0.5 and 1 or -1
			local conveyorSpeed = 3 + math.random() * 3 -- 3-6 studs/s

			-- Main platform
			local platform = Instance.new("Part")
			platform.Name = "ConveyorPlatform_" .. row .. "_" .. col
			platform.Size = Vector3.new(PLATFORM_SIZE, PLATFORM_HEIGHT, PLATFORM_SIZE)
			platform.Position = Vector3.new(px, BUILDING_BASE + 0.75, rowZ)
			platform.Anchored = true
			platform.CanCollide = true
			platform.Material = Enum.Material.DiamondPlate
			platform.Color = Color3.fromRGB(90, 90, 95)
			platform.AssemblyLinearVelocity = Vector3.new(conveyorSpeed * dirX, 0, 0)
			platform.Parent = model

			-- Scrolling chevron texture on top face
			local tex = Instance.new("Texture")
			tex.Name = "ConveyorTex"
			tex.Texture = CONVEYOR_TEXTURE
			tex.Face = Enum.NormalId.Top
			tex.StudsPerTileU = 5
			tex.StudsPerTileV = 5
			tex.Color3 = Color3.fromRGB(255, 200, 0)
			tex.Transparency = 0.15
			tex.Parent = platform

			-- Track for scrolling animation
			activePlatformAnimations[tex] = {
				type = "conveyor",
				speed = conveyorSpeed * dirX,
			}
		end
	end

	model.Parent = DecorUtils.decorFolder
	return model
end

function WaterPlatforms.createWaterPlatformsSwamp(x, z, scale)
	if not DecorUtils.decorFolder then return nil end
	scale = scale or 1
	local PLAYABLE_WIDTH = DecorUtils.PLAYABLE_WIDTH
	local BUILDING_BASE = DecorUtils.BUILDING_BASE
	local activePlatformAnimations = DecorUtils.activePlatformAnimations
	local model = Instance.new("Model")
	model.Name = "WaterPlatformsSwamp"

	local LANE_DEPTH = 64
	local ROW_COUNT = 4
	local COL_COUNT = 5
	local rowSpacing = LANE_DEPTH / ROW_COUNT
	local halfPlayable = PLAYABLE_WIDTH / 2
	local halfDepth = LANE_DEPTH / 2
	local colSpacing = PLAYABLE_WIDTH / COL_COUNT
	local CYCLE_DURATION = 16 -- slow swamp: 8s safe, 8s sunk

	local swampColors = {
		Color3.fromRGB(70, 65, 40),
		Color3.fromRGB(60, 55, 35),
		Color3.fromRGB(80, 70, 45),
		Color3.fromRGB(55, 50, 30),
	}

	for row = 0, ROW_COUNT - 1 do
		local rowZ = z + halfDepth - (row + 0.5) * rowSpacing
		for col = 0, COL_COUNT - 1 do
			local px = -halfPlayable + (col + 0.5) * colSpacing
			-- Irregular sizes for swamp debris feel
			local sizeX = (8 + math.random() * 4) * scale
			local sizeZ = (8 + math.random() * 4) * scale

			local platform = Instance.new("Part")
			platform.Name = "SwampPlatform_" .. row .. "_" .. col
			platform.Size = Vector3.new(sizeX, 1.2, sizeZ)
			platform.Position = Vector3.new(px, BUILDING_BASE + 0.6, rowZ)
			platform.Anchored = true
			platform.CanCollide = true
			platform.Material = Enum.Material.Mud
			platform.Color = swampColors[math.random(#swampColors)]
			platform.Parent = model

			local phaseOffset = math.random() * CYCLE_DURATION
			activePlatformAnimations[platform] = {
				type = "sinking",
				baseY = BUILDING_BASE + 0.6,
				sunkY = BUILDING_BASE - 3,
				phaseOffset = phaseOffset,
				cycleDuration = CYCLE_DURATION,
				sinkDuration = 3, -- slow smooth sink/rise (default is 0.5)
			}
		end
	end

	model.Parent = DecorUtils.decorFolder
	return model
end

return WaterPlatforms
