local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local HighSpeedTrack = {}

function HighSpeedTrack.createHighSpeedTrack(x, z, scale)
	if not DecorUtils.decorFolder then return nil end
	scale = scale or 1

	local TERRAIN_TOP = DecorUtils.TERRAIN_TOP
	local TRACK_SPAN = 500
	local terrainOffset = 2

	local track = Instance.new("Model")
	track.Name = "HighSpeedTrack"

	-- Colors
	local C_RAIL    = Color3.fromRGB(160, 155, 150)
	local C_CONCRETE = Color3.fromRGB(175, 175, 180)
	local C_SLEEPER = Color3.fromRGB(155, 155, 160)
	local C_POLE    = Color3.fromRGB(120, 125, 135)
	local C_WIRE    = Color3.fromRGB(50, 50, 55)

	local railGauge = 4 * scale
	local railHeight = 1 * scale
	local railWidth = 0.6 * scale
	local sleeperHeight = 0.4 * scale

	local sleeperY = TERRAIN_TOP + terrainOffset + sleeperHeight / 2
	local railY = TERRAIN_TOP + terrainOffset + sleeperHeight + railHeight / 2

	---------------------------------------------------------------------------
	-- 1. CONCRETE TRACK BED (slab track, modern look)
	---------------------------------------------------------------------------
	local bedH = 0.8 * scale
	local bedW = 14 * scale
	local bed = Instance.new("Part")
	bed.Name = "TrackBed"
	bed.Size = Vector3.new(TRACK_SPAN, bedH, bedW)
	bed.Position = Vector3.new(0, TERRAIN_TOP + terrainOffset - bedH / 2 + 0.2, z)
	bed.Anchored = true
	bed.CanCollide = false
	bed.Material = Enum.Material.Concrete
	bed.Color = C_CONCRETE
	bed.Parent = track

	---------------------------------------------------------------------------
	-- 2. RAILS (thinner, sleeker than regular railtrack)
	---------------------------------------------------------------------------
	for _, side in ipairs({-1, 1}) do
		local rail = Instance.new("Part")
		rail.Name = "Rail"
		rail.Size = Vector3.new(TRACK_SPAN, railHeight, railWidth)
		rail.Position = Vector3.new(0, railY, z + side * railGauge)
		rail.Anchored = true
		rail.CanCollide = false
		rail.Material = Enum.Material.Metal
		rail.Color = C_RAIL
		rail.Parent = track
	end

	---------------------------------------------------------------------------
	-- 3. CONCRETE SLEEPERS (closer spacing than wood)
	---------------------------------------------------------------------------
	local sleeperLength = 10 * scale
	local sleeperWidth = 1.5 * scale
	local sleeperSpacing = 4

	for sx = -TRACK_SPAN / 2, TRACK_SPAN / 2, sleeperSpacing do
		local sleeper = Instance.new("Part")
		sleeper.Name = "Sleeper"
		sleeper.Size = Vector3.new(sleeperWidth, sleeperHeight, sleeperLength)
		sleeper.Position = Vector3.new(sx, sleeperY, z)
		sleeper.Anchored = true
		sleeper.CanCollide = false
		sleeper.Material = Enum.Material.Concrete
		sleeper.Color = C_SLEEPER
		sleeper.Parent = track
	end

	---------------------------------------------------------------------------
	-- 4. CATENARY POLES + WIRES
	---------------------------------------------------------------------------
	local poleSpacing = 40
	local poleHeight = 18 * scale
	local poleWidth = 0.8 * scale
	local armLength = 8 * scale
	local wireY = TERRAIN_TOP + terrainOffset + poleHeight
	local poleOffset = 10 * scale  -- distance from track center (Z)

	for px = -TRACK_SPAN / 2, TRACK_SPAN / 2, poleSpacing do
		for _, side in ipairs({-1, 1}) do
			-- Vertical pole
			local pole = Instance.new("Part")
			pole.Name = "CatenaryPole"
			pole.Size = Vector3.new(poleWidth, poleHeight, poleWidth)
			pole.Position = Vector3.new(px, TERRAIN_TOP + terrainOffset + poleHeight / 2, z + side * poleOffset)
			pole.Anchored = true
			pole.CanCollide = false
			pole.Material = Enum.Material.Metal
			pole.Color = C_POLE
			pole.Parent = track

			-- Horizontal arm reaching over track
			local arm = Instance.new("Part")
			arm.Name = "CatenaryArm"
			arm.Size = Vector3.new(poleWidth * 0.7, poleWidth * 0.7, armLength)
			arm.Position = Vector3.new(px, wireY - 0.5, z + side * (poleOffset - armLength / 2))
			arm.Anchored = true
			arm.CanCollide = false
			arm.Material = Enum.Material.Metal
			arm.Color = C_POLE
			arm.Parent = track
		end

		-- Wire spanning between the two arms (over the track)
		local wire = Instance.new("Part")
		wire.Name = "CatenaryWire"
		wire.Size = Vector3.new(0.15, 0.15, poleOffset * 2 - armLength)
		wire.Position = Vector3.new(px, wireY - 0.5, z)
		wire.Anchored = true
		wire.CanCollide = false
		wire.Material = Enum.Material.Metal
		wire.Color = C_WIRE
		wire.Parent = track
	end

	-- Longitudinal contact wire (runs along X, the wire the pantograph touches)
	local contactWire = Instance.new("Part")
	contactWire.Name = "ContactWire"
	contactWire.Size = Vector3.new(TRACK_SPAN, 0.1, 0.1)
	contactWire.Position = Vector3.new(0, wireY - 1.5, z)
	contactWire.Anchored = true
	contactWire.CanCollide = false
	contactWire.Material = Enum.Material.Metal
	contactWire.Color = C_WIRE
	contactWire.Parent = track

	track.Parent = DecorUtils.decorFolder
	return track
end

return HighSpeedTrack
