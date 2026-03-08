local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local AirportLines = {}

function AirportLines.createTaxiLines(x, z, scale)
	if not DecorUtils.decorFolder then return nil end
	scale = scale or 1

	local TERRAIN_TOP = DecorUtils.TERRAIN_TOP
	local group = Instance.new("Model")
	group.Name = "TaxiLines"

	local LANE_SPAN = 500
	local LANE_HALF_DEPTH = 12  -- inset from road edges (road is 64 wide)
	local DASH_LEN = 4
	local DASH_GAP = 3
	local DASH_WIDTH = 0.6 * scale
	local DASH_HEIGHT = 0.2
	local EDGE_WIDTH = 0.4 * scale
	local YELLOW = Color3.fromRGB(230, 200, 50)
	local terrainOffset = 2  -- same offset as rail tracks; terrain voxels sit above fill Y

	local lineY = TERRAIN_TOP + terrainOffset + DASH_HEIGHT / 2

	-- Dashed center line running along X at lane center Z
	local halfSpan = LANE_SPAN / 2
	local pos = -halfSpan
	while pos < halfSpan do
		local dash = Instance.new("Part")
		dash.Name = "CenterDash"
		dash.Size = Vector3.new(DASH_LEN * scale, DASH_HEIGHT, DASH_WIDTH)
		dash.Position = Vector3.new(pos + (DASH_LEN * scale) / 2, lineY, z)
		dash.Anchored = true
		dash.CanCollide = false
		dash.Material = Enum.Material.Neon
		dash.Color = YELLOW
		dash.Parent = group
		pos = pos + (DASH_LEN + DASH_GAP) * scale
	end

	-- Solid edge lines at front/back Z boundaries of the lane
	for _, edgeZ in ipairs({ z - LANE_HALF_DEPTH, z + LANE_HALF_DEPTH }) do
		local edge = Instance.new("Part")
		edge.Name = "EdgeLine"
		edge.Size = Vector3.new(LANE_SPAN, DASH_HEIGHT, EDGE_WIDTH)
		edge.Position = Vector3.new(0, lineY, edgeZ)
		edge.Anchored = true
		edge.CanCollide = false
		edge.Material = Enum.Material.Neon
		edge.Color = YELLOW
		edge.Parent = group
	end

	group.Parent = DecorUtils.decorFolder
	return group
end

function AirportLines.createRunwayLines(x, z, scale)
	if not DecorUtils.decorFolder then return nil end
	scale = scale or 1

	local TERRAIN_TOP = DecorUtils.TERRAIN_TOP
	local PLAYABLE_WIDTH = DecorUtils.PLAYABLE_WIDTH
	local group = Instance.new("Model")
	group.Name = "RunwayLines"

	local LANE_SPAN = 500
	local LANE_HALF_DEPTH = 12  -- inset from lane edges (lane is 64 deep)
	local DASH_LEN = 6
	local DASH_GAP = 4
	local DASH_WIDTH = 0.8 * scale
	local DASH_HEIGHT = 0.2
	local EDGE_WIDTH = 0.5 * scale
	local WHITE = Color3.fromRGB(240, 240, 240)
	local terrainOffset = 2

	local lineY = TERRAIN_TOP + terrainOffset + DASH_HEIGHT / 2

	-- Dashed center line running along X
	local halfSpan = LANE_SPAN / 2
	local pos = -halfSpan
	while pos < halfSpan do
		local dash = Instance.new("Part")
		dash.Name = "CenterDash"
		dash.Size = Vector3.new(DASH_LEN * scale, DASH_HEIGHT, DASH_WIDTH)
		dash.Position = Vector3.new(pos + (DASH_LEN * scale) / 2, lineY, z)
		dash.Anchored = true
		dash.CanCollide = false
		dash.Material = Enum.Material.Neon
		dash.Color = WHITE
		dash.Parent = group
		pos = pos + (DASH_LEN + DASH_GAP) * scale
	end

	-- Solid edge lines
	for _, edgeZ in ipairs({ z - LANE_HALF_DEPTH, z + LANE_HALF_DEPTH }) do
		local edge = Instance.new("Part")
		edge.Name = "EdgeLine"
		edge.Size = Vector3.new(LANE_SPAN, DASH_HEIGHT, EDGE_WIDTH)
		edge.Position = Vector3.new(0, lineY, edgeZ)
		edge.Anchored = true
		edge.CanCollide = false
		edge.Material = Enum.Material.Neon
		edge.Color = WHITE
		edge.Parent = group
	end

	-- Threshold bars (wide white bars at each end of the playable area)
	local THRESHOLD_COUNT = 4
	local BAR_WIDTH = 8 * scale
	local BAR_DEPTH = 1.5 * scale
	local BAR_GAP = 2 * scale
	local thresholdStartX = PLAYABLE_WIDTH / 2 - 4

	for side = -1, 1, 2 do
		for i = 0, THRESHOLD_COUNT - 1 do
			local bar = Instance.new("Part")
			bar.Name = "ThresholdBar"
			bar.Size = Vector3.new(BAR_WIDTH, DASH_HEIGHT, BAR_DEPTH)
			bar.Position = Vector3.new(
				side * (thresholdStartX + i * (BAR_DEPTH + BAR_GAP)),
				lineY,
				z
			)
			bar.Anchored = true
			bar.CanCollide = false
			bar.Material = Enum.Material.Neon
			bar.Color = WHITE
			bar.Parent = group
		end
	end

	group.Parent = DecorUtils.decorFolder
	return group
end

return AirportLines
