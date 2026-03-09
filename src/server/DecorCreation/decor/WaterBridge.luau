-- WaterBridge.luau
-- Bridge crossing block: where a road/highway crosses a river.
-- Road deck, railings, support pillars.

local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local WaterBridge = {}

function WaterBridge.create(x, z, roadWidth, riverWidth, scale)
	if not DecorUtils.decorFolder then return nil end
	scale = scale or 1

	local GROUND_Y = DecorUtils.TERRAIN_TOP  -- 4

	local C_DECK    = Color3.fromRGB(140, 140, 145)
	local C_PILLAR  = Color3.fromRGB(160, 155, 150)
	local C_RAILING = Color3.fromRGB(120, 120, 130)

	local model = Instance.new("Model")
	model.Name = "WaterBridge"

	---------------------------------------------------------------------------
	-- 1. ROAD DECK (concrete slab, top flush with ground level)
	---------------------------------------------------------------------------
	local deckH = 1.5 * scale
	local deck = Instance.new("Part")
	deck.Name = "BridgeDeck"
	deck.Size = Vector3.new(roadWidth, deckH, riverWidth + 6)
	deck.Position = Vector3.new(x, GROUND_Y - deckH / 2, z)
	deck.Anchored = true
	deck.CanCollide = true
	deck.Material = Enum.Material.Concrete
	deck.Color = C_DECK
	deck.Parent = model

	---------------------------------------------------------------------------
	-- 2. SUPPORT PILLARS (columns going down into the water)
	---------------------------------------------------------------------------
	local pillarH = 8 * scale
	local pillarW = 2 * scale
	local pillarSpacing = riverWidth / 3

	for _, px in ipairs({x - roadWidth / 4, x + roadWidth / 4}) do
		for pz = z - riverWidth / 3, z + riverWidth / 3, pillarSpacing do
			local pillar = Instance.new("Part")
			pillar.Name = "BridgePillar"
			pillar.Size = Vector3.new(pillarW, pillarH, pillarW)
			pillar.Position = Vector3.new(px, GROUND_Y - deckH - pillarH / 2, pz)
			pillar.Anchored = true
			pillar.CanCollide = false
			pillar.Material = Enum.Material.Concrete
			pillar.Color = C_PILLAR
			pillar.Parent = model
		end
	end

	---------------------------------------------------------------------------
	-- 3. RAILINGS (both sides of road, spanning the river)
	---------------------------------------------------------------------------
	local railH = 3 * scale
	local postSpacing = 8

	for _, sideX in ipairs({-1, 1}) do
		local railX = x + sideX * roadWidth / 2

		-- Top rail
		local topRail = Instance.new("Part")
		topRail.Name = "BridgeRail"
		topRail.Size = Vector3.new(0.3 * scale, 0.3 * scale, riverWidth + 6)
		topRail.Position = Vector3.new(railX, GROUND_Y + railH, z)
		topRail.Anchored = true
		topRail.CanCollide = false
		topRail.Material = Enum.Material.Metal
		topRail.Color = C_RAILING
		topRail.Parent = model

		-- Mid rail
		local midRail = Instance.new("Part")
		midRail.Name = "BridgeMidRail"
		midRail.Size = Vector3.new(0.2 * scale, 0.2 * scale, riverWidth + 6)
		midRail.Position = Vector3.new(railX, GROUND_Y + railH / 2, z)
		midRail.Anchored = true
		midRail.CanCollide = false
		midRail.Material = Enum.Material.Metal
		midRail.Color = C_RAILING
		midRail.Parent = model

		-- Posts
		for pz = z - riverWidth / 2, z + riverWidth / 2, postSpacing do
			local post = Instance.new("Part")
			post.Name = "RailPost"
			post.Size = Vector3.new(0.4 * scale, railH, 0.4 * scale)
			post.Position = Vector3.new(railX, GROUND_Y + railH / 2, pz)
			post.Anchored = true
			post.CanCollide = false
			post.Material = Enum.Material.Metal
			post.Color = C_RAILING
			post.Parent = model
		end
	end

	model.Parent = DecorUtils.decorFolder
	return model
end

return WaterBridge
