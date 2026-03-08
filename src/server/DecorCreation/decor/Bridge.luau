local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local Bridge = {}

function Bridge.createBridgeRailings(x, z, scale)
	if not DecorUtils.decorFolder then return nil end
	scale = scale or 1

	local PLAYABLE_WIDTH = DecorUtils.PLAYABLE_WIDTH
	local model = Instance.new("Model")
	model.Name = "BridgeRailings"

	local DECK_Y = 14
	local RAIL_H = 3
	local POST_SPACING = 8
	-- Use the lane depth from the decor system (bridge_main depth = 40)
	local laneDepth = 40 * scale
	local halfDepth = laneDepth / 2
	local halfWidth = PLAYABLE_WIDTH / 2

	-- Two rows of railings at edges of playable width
	for _, sideX in ipairs({ -halfWidth, halfWidth }) do
		-- Vertical posts
		local numPosts = math.floor(laneDepth / POST_SPACING) + 1
		for i = 0, numPosts - 1 do
			local postZ = z + halfDepth - i * POST_SPACING
			local post = Instance.new("Part")
			post.Name = "RailPost"
			post.Size = Vector3.new(0.4 * scale, RAIL_H * scale, 0.4 * scale)
			post.Position = Vector3.new(sideX, DECK_Y + RAIL_H / 2 * scale, postZ)
			post.Anchored = true
			post.Material = Enum.Material.Metal
			post.Color = Color3.fromRGB(120, 120, 130)
			post.Parent = model
		end

		-- Horizontal top rail
		local topRail = Instance.new("Part")
		topRail.Name = "TopRail"
		topRail.Size = Vector3.new(0.3 * scale, 0.3 * scale, laneDepth)
		topRail.Position = Vector3.new(sideX, DECK_Y + RAIL_H * scale, z)
		topRail.Anchored = true
		topRail.Material = Enum.Material.Metal
		topRail.Color = Color3.fromRGB(130, 130, 140)
		topRail.Parent = model

		-- Horizontal mid rail
		local midRail = Instance.new("Part")
		midRail.Name = "MidRail"
		midRail.Size = Vector3.new(0.2 * scale, 0.2 * scale, laneDepth)
		midRail.Position = Vector3.new(sideX, DECK_Y + RAIL_H / 2 * scale, z)
		midRail.Anchored = true
		midRail.Material = Enum.Material.Metal
		midRail.Color = Color3.fromRGB(130, 130, 140)
		midRail.Parent = model
	end

	model.Parent = DecorUtils.decorFolder
	return model
end

function Bridge.createBridgePillars(x, z, scale)
	if not DecorUtils.decorFolder then return nil end
	scale = scale or 1

	local model = Instance.new("Model")
	model.Name = "BridgePillars"

	local DECK_Y = 14
	local PILLAR_SPACING = 12
	local laneDepth = 40 * scale
	local halfDepth = laneDepth / 2
	local PILLAR_X_OFFSET = 15  -- pillars at X = ±15

	local numPillars = math.floor(laneDepth / PILLAR_SPACING) + 1

	for i = 0, numPillars - 1 do
		local pillarZ = z + halfDepth - i * PILLAR_SPACING

		for _, sideX in ipairs({ -PILLAR_X_OFFSET, PILLAR_X_OFFSET }) do
			-- Concrete support column from Y=0 up to just under deck
			local pillarH = DECK_Y - 0.5
			local col = Instance.new("Part")
			col.Name = "BridgePillar"
			-- Cylinder rotated 90° on Z: Size.X = height, Size.Y/Z = diameter
			col.Size = Vector3.new(pillarH, 2.5 * scale, 2.5 * scale)
			col.Shape = Enum.PartType.Cylinder
			col.CFrame = CFrame.new(sideX, pillarH / 2, pillarZ) * CFrame.Angles(0, 0, math.rad(90))
			col.Anchored = true
			col.Material = Enum.Material.Concrete
			col.Color = Color3.fromRGB(160, 155, 150)
			col.Parent = model
		end

		-- Cross-beam between each pair, just under deck
		local beam = Instance.new("Part")
		beam.Name = "CrossBeam"
		beam.Size = Vector3.new(PILLAR_X_OFFSET * 2, 1 * scale, 1.5 * scale)
		beam.Position = Vector3.new(0, DECK_Y - 1.5, pillarZ)
		beam.Anchored = true
		beam.Material = Enum.Material.Concrete
		beam.Color = Color3.fromRGB(145, 140, 135)
		beam.Parent = model
	end

	model.Parent = DecorUtils.decorFolder
	return model
end

return Bridge
