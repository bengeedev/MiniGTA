local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))
local Tree = require(script.Parent:WaitForChild("Tree"))
local Lamp = require(script.Parent:WaitForChild("Lamp"))

local Park = {}

local function makePart(props)
	local p = Instance.new("Part")
	p.Size = props.size
	p.Position = props.position
	p.Anchored = true
	p.CanCollide = false
	p.Material = props.material or Enum.Material.SmoothPlastic
	p.Color = props.color or Color3.new(1, 1, 1)
	p.Parent = props.parent
	return p
end

function Park.createParkBench(x, z, scale, parent)
	scale = scale or 1
	local TERRAIN_TOP = DecorUtils.TERRAIN_TOP

	local bench = Instance.new("Model")
	bench.Name = "ParkBench"

	-- Seat
	makePart({
		size = Vector3.new(4 * scale, 0.3 * scale, 1.5 * scale),
		position = Vector3.new(x, TERRAIN_TOP + 1.5 * scale, z),
		material = Enum.Material.Wood,
		color = Color3.fromRGB(120, 80, 50),
		parent = bench,
	})

	-- Back rest
	makePart({
		size = Vector3.new(4 * scale, 1.2 * scale, 0.2 * scale),
		position = Vector3.new(x, TERRAIN_TOP + 2.2 * scale, z - 0.65 * scale),
		material = Enum.Material.Wood,
		color = Color3.fromRGB(120, 80, 50),
		parent = bench,
	})

	-- Legs
	for _, lx in ipairs({ -1.5, 1.5 }) do
		makePart({
			size = Vector3.new(0.3 * scale, 1.5 * scale, 1.5 * scale),
			position = Vector3.new(x + lx * scale, TERRAIN_TOP + 0.75 * scale, z),
			material = Enum.Material.Metal,
			color = Color3.fromRGB(50, 50, 55),
			parent = bench,
		})
	end

	bench.Parent = parent or DecorUtils.decorFolder
	return bench
end

function Park.createPark(x, z, scale)
	local decorFolder = DecorUtils.decorFolder
	if not decorFolder then return nil end
	scale = scale or 1
	local TERRAIN_TOP = DecorUtils.TERRAIN_TOP
	local half = DecorUtils.PLAYABLE_WIDTH / 2

	-- Central walkway (decorative cobblestone strip)
	local walkway = makePart({
		size = Vector3.new(6, 0.2, 70),
		position = Vector3.new(0, TERRAIN_TOP + 0.1, z),
		material = Enum.Material.Cobblestone,
		color = Color3.fromRGB(170, 165, 155),
		parent = decorFolder,
	})
	walkway.Name = "ParkWalkway"

	-- Lamp posts along the walkway (outside player path)
	for _, lz in ipairs({ -25, 0, 25 }) do
		Lamp.createStreetLamp(-5, z + lz, 0.9)
		Lamp.createStreetLamp(5, z + lz, 0.9)
	end

	-- Trees: keep inside playable width for visual, CanCollide=false via Tree builder
	local treePositions = {
		{ dx = -30, dz = -15, s = 1.3 },
		{ dx = -20, dz = 10,  s = 1.0 },
		{ dx = -14, dz = -25, s = 1.1 },
		{ dx = -18, dz = 22,  s = 0.9 },
		{ dx =  14, dz = -20, s = 1.2 },
		{ dx =  20, dz = 5,   s = 1.0 },
		{ dx =  30, dz = 18,  s = 1.3 },
		{ dx =  25, dz = -10, s = 0.8 },
		{ dx = -35, dz = 0,   s = 1.1 },
		{ dx =  35, dz = -5,  s = 1.0 },
	}
	for _, t in ipairs(treePositions) do
		Tree.createTree(t.dx, z + t.dz, t.s)
	end

	-- Bushes
	local bushPositions = {
		{ dx = -18, dz = -8,  s = 0.8 },
		{ dx = -25, dz = 15,  s = 0.7 },
		{ dx =  18, dz = 12,  s = 0.8 },
		{ dx =  25, dz = -18, s = 0.7 },
		{ dx = -10, dz = 28,  s = 0.6 },
		{ dx =  10, dz = -28, s = 0.6 },
	}
	for _, b in ipairs(bushPositions) do
		Tree.createBush(b.dx, z + b.dz, b.s)
	end

	-- Park benches (off the walkway, not blocking player)
	Park.createParkBench(-10, z - 10, 1.0, decorFolder)
	Park.createParkBench(10, z + 10, 1.0, decorFolder)
	Park.createParkBench(-10, z + 22, 1.0, decorFolder)
	Park.createParkBench(10, z - 22, 1.0, decorFolder)

	return walkway
end

return Park
