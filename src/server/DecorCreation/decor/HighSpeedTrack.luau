local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local HighSpeedTrack = {}

-- Colors
local C_RAIL     = Color3.fromRGB(160, 155, 150)
local C_CONCRETE = Color3.fromRGB(175, 175, 180)
local C_SLEEPER  = Color3.fromRGB(155, 155, 160)
local C_POLE     = Color3.fromRGB(120, 125, 135)
local C_WIRE     = Color3.fromRGB(50, 50, 55)
local C_RED      = Color3.fromRGB(200, 40, 40)
local C_YELLOW   = Color3.fromRGB(255, 220, 40)

---------------------------------------------------------------------------
-- INTERNAL: build track parts for an arbitrary X range
---------------------------------------------------------------------------

local function buildTrackParts(model, startX, endX, z, scale)
	local TERRAIN_TOP = DecorUtils.TERRAIN_TOP
	local terrainOffset = 2
	local spanX = endX - startX
	local centerX = (startX + endX) / 2

	local railGauge = 4 * scale
	local railHeight = 1 * scale
	local railWidth = 0.6 * scale
	local sleeperHeight = 0.4 * scale

	local sleeperY = TERRAIN_TOP + terrainOffset + sleeperHeight / 2
	local railY = TERRAIN_TOP + terrainOffset + sleeperHeight + railHeight / 2

	-- 1. CONCRETE TRACK BED (slab track, modern look)
	local bedH = 0.8 * scale
	local bedW = 14 * scale
	local bed = Instance.new("Part")
	bed.Name = "TrackBed"
	bed.Size = Vector3.new(spanX, bedH, bedW)
	bed.Position = Vector3.new(centerX, TERRAIN_TOP + terrainOffset - bedH / 2 + 0.2, z)
	bed.Anchored = true
	bed.CanCollide = false
	bed.Material = Enum.Material.Concrete
	bed.Color = C_CONCRETE
	bed.Parent = model

	-- 2. RAILS
	for _, side in ipairs({-1, 1}) do
		local rail = Instance.new("Part")
		rail.Name = "Rail"
		rail.Size = Vector3.new(spanX, railHeight, railWidth)
		rail.Position = Vector3.new(centerX, railY, z + side * railGauge)
		rail.Anchored = true
		rail.CanCollide = false
		rail.Material = Enum.Material.Metal
		rail.Color = C_RAIL
		rail.Parent = model
	end

	-- 3. CONCRETE SLEEPERS
	local sleeperLength = 10 * scale
	local sleeperWidth = 1.5 * scale
	local sleeperSpacing = 4

	for sx = startX, endX, sleeperSpacing do
		local sleeper = Instance.new("Part")
		sleeper.Name = "Sleeper"
		sleeper.Size = Vector3.new(sleeperWidth, sleeperHeight, sleeperLength)
		sleeper.Position = Vector3.new(sx, sleeperY, z)
		sleeper.Anchored = true
		sleeper.CanCollide = false
		sleeper.Material = Enum.Material.Concrete
		sleeper.Color = C_SLEEPER
		sleeper.Parent = model
	end

	-- 4. CATENARY POLES + WIRES
	local poleSpacing = 40
	local poleHeight = 18 * scale
	local poleWidth = 0.8 * scale
	local armLength = 8 * scale
	local wireY = TERRAIN_TOP + terrainOffset + poleHeight
	local poleOffset = 10 * scale

	for px = startX, endX, poleSpacing do
		for _, side in ipairs({-1, 1}) do
			local pole = Instance.new("Part")
			pole.Name = "CatenaryPole"
			pole.Size = Vector3.new(poleWidth, poleHeight, poleWidth)
			pole.Position = Vector3.new(px, TERRAIN_TOP + terrainOffset + poleHeight / 2, z + side * poleOffset)
			pole.Anchored = true
			pole.CanCollide = false
			pole.Material = Enum.Material.Metal
			pole.Color = C_POLE
			pole.Parent = model

			local arm = Instance.new("Part")
			arm.Name = "CatenaryArm"
			arm.Size = Vector3.new(poleWidth * 0.7, poleWidth * 0.7, armLength)
			arm.Position = Vector3.new(px, wireY - 0.5, z + side * (poleOffset - armLength / 2))
			arm.Anchored = true
			arm.CanCollide = false
			arm.Material = Enum.Material.Metal
			arm.Color = C_POLE
			arm.Parent = model
		end

		local wire = Instance.new("Part")
		wire.Name = "CatenaryWire"
		wire.Size = Vector3.new(0.15, 0.15, poleOffset * 2 - armLength)
		wire.Position = Vector3.new(px, wireY - 0.5, z)
		wire.Anchored = true
		wire.CanCollide = false
		wire.Material = Enum.Material.Metal
		wire.Color = C_WIRE
		wire.Parent = model
	end

	-- Longitudinal contact wire
	local contactWire = Instance.new("Part")
	contactWire.Name = "ContactWire"
	contactWire.Size = Vector3.new(spanX, 0.1, 0.1)
	contactWire.Position = Vector3.new(centerX, wireY - 1.5, z)
	contactWire.Anchored = true
	contactWire.CanCollide = false
	contactWire.Material = Enum.Material.Metal
	contactWire.Color = C_WIRE
	contactWire.Parent = model
end

---------------------------------------------------------------------------
-- INTERNAL: buffer stop at end of track
-- xSign: 1 = buffer faces right (train comes from left), -1 = faces left
---------------------------------------------------------------------------

local function buildBufferStop(model, x, z, xSign, scale)
	local TERRAIN_TOP = DecorUtils.TERRAIN_TOP
	local terrainOffset = 2
	local surfaceY = TERRAIN_TOP + terrainOffset

	local bufferW = 3 * scale
	local bufferH = 4 * scale
	local bedW = 14 * scale

	local block = Instance.new("Part")
	block.Name = "BufferStop"
	block.Size = Vector3.new(bufferW, bufferH, bedW * 0.6)
	block.Position = Vector3.new(x, surfaceY + bufferH / 2, z)
	block.Anchored = true
	block.Material = Enum.Material.Concrete
	block.Color = C_CONCRETE
	block.Parent = model

	local face = Instance.new("Part")
	face.Name = "BufferFace"
	face.Size = Vector3.new(0.3, bufferH * 0.7, bedW * 0.5)
	face.Position = Vector3.new(x + xSign * (bufferW / 2 + 0.15), surfaceY + bufferH * 0.45, z)
	face.Anchored = true
	face.CanCollide = false
	face.Material = Enum.Material.SmoothPlastic
	face.Color = C_RED
	face.Parent = model

	local stripe = Instance.new("Part")
	stripe.Name = "BufferStripe"
	stripe.Size = Vector3.new(0.05, 0.6 * scale, bedW * 0.5)
	stripe.Position = Vector3.new(x + xSign * (bufferW / 2 + 0.3), surfaceY + bufferH * 0.6, z)
	stripe.Anchored = true
	stripe.CanCollide = false
	stripe.Material = Enum.Material.Neon
	stripe.Color = C_YELLOW
	stripe.Parent = model
end

---------------------------------------------------------------------------
-- PUBLIC: create a track segment from startX to endX at given Z
-- leftBuffer / rightBuffer: place buffer stop at that end
---------------------------------------------------------------------------

function HighSpeedTrack.createSegment(startX, endX, z, scale, leftBuffer, rightBuffer)
	if not DecorUtils.decorFolder then return nil end
	scale = scale or 1

	local track = Instance.new("Model")
	track.Name = "HighSpeedTrack"

	buildTrackParts(track, startX, endX, z, scale)

	if leftBuffer then
		buildBufferStop(track, startX + 2, z, -1, scale)
	end
	if rightBuffer then
		buildBufferStop(track, endX - 2, z, 1, scale)
	end

	track.Parent = DecorUtils.decorFolder
	return track
end

-- Legacy: centered 500-stud track (backward compatible)
function HighSpeedTrack.createHighSpeedTrack(x, z, scale)
	return HighSpeedTrack.createSegment(-250, 250, z, scale, false, false)
end

return HighSpeedTrack
