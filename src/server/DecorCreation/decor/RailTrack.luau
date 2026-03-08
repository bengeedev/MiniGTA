local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local RailTrack = {}

function RailTrack.createRailTrack(x, z, scale, offsetY)
	if not DecorUtils.decorFolder then return nil end
	scale = scale or 1
	offsetY = offsetY or 0

	local TERRAIN_TOP = DecorUtils.TERRAIN_TOP
	local TRACK_SPAN = 500       -- full lane width so tracks run under the train
	local SLEEPER_SPAN = 500     -- match rail length

	local track = Instance.new("Model")
	track.Name = "RailTrack"

	-- Rail gauge: distance between the two rails (Z axis)
	local railGauge = 4 * scale
	local railHeight = 1 * scale
	local railWidth = 0.8 * scale
	local sleeperHeight = 0.6 * scale

	-- Terrain voxels extend above the fill Y, so offset everything up
	local terrainOffset = 2
	local sleeperY = TERRAIN_TOP + terrainOffset + sleeperHeight / 2 + offsetY
	local railY = TERRAIN_TOP + terrainOffset + sleeperHeight + railHeight / 2 + offsetY

	-- Left rail
	local leftRail = Instance.new("Part")
	leftRail.Name = "RailL"
	leftRail.Size = Vector3.new(TRACK_SPAN, railHeight, railWidth)
	leftRail.Position = Vector3.new(0, railY, z - railGauge)
	leftRail.Anchored = true
	leftRail.CanCollide = false
	leftRail.Material = Enum.Material.Metal
	leftRail.Color = Color3.fromRGB(160, 155, 150)
	leftRail.Parent = track

	-- Right rail
	local rightRail = Instance.new("Part")
	rightRail.Name = "RailR"
	rightRail.Size = Vector3.new(TRACK_SPAN, railHeight, railWidth)
	rightRail.Position = Vector3.new(0, railY, z + railGauge)
	rightRail.Anchored = true
	rightRail.CanCollide = false
	rightRail.Material = Enum.Material.Metal
	rightRail.Color = Color3.fromRGB(160, 155, 150)
	rightRail.Parent = track

	-- Wooden sleepers / ties (perpendicular to rails)
	local sleeperLength = 12 * scale   -- crosses both rails (Z axis)
	local sleeperWidth = 2 * scale     -- thickness along X
	local sleeperSpacing = 6
	local halfSleeper = SLEEPER_SPAN / 2

	for sx = -halfSleeper, halfSleeper, sleeperSpacing do
		local sleeper = Instance.new("Part")
		sleeper.Name = "Sleeper"
		sleeper.Size = Vector3.new(sleeperWidth, sleeperHeight, sleeperLength)
		sleeper.Position = Vector3.new(sx, sleeperY, z)
		sleeper.Anchored = true
		sleeper.CanCollide = false
		sleeper.Material = Enum.Material.Wood
		sleeper.Color = Color3.fromRGB(80, 55, 35)
		sleeper.Parent = track
	end

	track.Parent = DecorUtils.decorFolder
	return track
end

return RailTrack
