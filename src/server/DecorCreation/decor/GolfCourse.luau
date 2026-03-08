local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))
local Tree = require(script.Parent:WaitForChild("Tree"))

local GolfCourse = {}

--------------------------------------------------------------------------------
-- Golf Course decor — above-ground objects only.
-- Terrain (sand, water, hills) is handled by LaneCreation.
-- This places: flag pins, tee markers, benches, trees, cart paths.
--------------------------------------------------------------------------------

function GolfCourse.createGolfCourse(x, z, scale)
	if not DecorUtils.decorFolder then return nil end
	scale = scale or 1

	local TERRAIN_TOP = DecorUtils.TERRAIN_TOP
	local surfaceY = TERRAIN_TOP

	local model = Instance.new("Model")
	model.Name = "GolfCourse"

	-- Colors
	local C_WHITE    = Color3.fromRGB(245, 245, 245)
	local C_RED      = Color3.fromRGB(200, 40, 30)
	local C_BLUE     = Color3.fromRGB(60, 120, 200)
	local C_POLE     = Color3.fromRGB(180, 180, 185)
	local C_WOOD     = Color3.fromRGB(120, 80, 40)
	local C_PATH     = Color3.fromRGB(190, 180, 165)

	local rng = Random.new(math.floor(math.abs(z) * 7 + 13))

	---------------------------------------------------------------------------
	-- 1. CART PATHS (gravel strips)
	---------------------------------------------------------------------------
	for _, side in ipairs({-1, 1}) do
		for i = 0, 3 do
			local pathZ = z - 25 + i * 18
			local pathX = side * rng:NextNumber(18, 30)
			local p = Instance.new("Part")
			p.Name = "CartPath"
			p.Size = Vector3.new(10 * scale, 0.15, 5 * scale)
			p.Position = Vector3.new(pathX, surfaceY + 0.1, pathZ)
			p.Anchored = true
			p.CanCollide = false
			p.Material = Enum.Material.Concrete
			p.Color = C_PATH
			p.Parent = model
		end
	end

	---------------------------------------------------------------------------
	-- 2. PUTTING GREEN + FLAG
	---------------------------------------------------------------------------
	do
		local fx = 25
		local fz = z + 10

		-- Putting green is handled by LaneCreation terrain (Ground material)

		-- Flag pole (tall, visible from distance)
		local pole = Instance.new("Part")
		pole.Name = "FlagPole"
		pole.Size = Vector3.new(0.15, 12 * scale, 0.15)
		pole.Position = Vector3.new(fx, surfaceY + 6 * scale, fz)
		pole.Anchored = true
		pole.CanCollide = false
		pole.Material = Enum.Material.Metal
		pole.Color = C_POLE
		pole.Parent = model

		-- Flag (red rectangle at top of pole)
		local flag = Instance.new("Part")
		flag.Name = "Flag"
		flag.Size = Vector3.new(0.08, 1.5 * scale, 2.5 * scale)
		flag.Position = Vector3.new(fx, surfaceY + 11.5 * scale, fz + 1.25 * scale)
		flag.Anchored = true
		flag.CanCollide = false
		flag.Material = Enum.Material.SmoothPlastic
		flag.Color = C_RED
		flag.Parent = model
	end

	---------------------------------------------------------------------------
	-- 3. TREES (around edges on both sides)
	---------------------------------------------------------------------------
	local treeData = {
		{ dx = 15, dz = -35 },
		{ dx = 35, dz = 33 },
		{ dx = 55, dz = -30 },
		{ dx = 75, dz = 32 },
		{ dx = 90, dz = -28 },
		{ dx = 100, dz = 5 },
	}
	for _, tp in ipairs(treeData) do
		for _, side in ipairs({-1, 1}) do
			Tree.createTree(side * tp.dx, z + tp.dz, rng:NextNumber(0.8, 1.3))
		end
	end

	model.Parent = DecorUtils.decorFolder
	return model
end

return GolfCourse
