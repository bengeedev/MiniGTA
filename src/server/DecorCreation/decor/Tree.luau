local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local Tree = {}

function Tree.createTree(x, z, scale)
	if not DecorUtils.decorFolder then return nil end
	scale = scale or 1
	local tree = Instance.new("Model")
	tree.Name = "Tree"

	local trunkColor = Color3.fromRGB(101, 67, 33)
	local trunk = Instance.new("Part")
	trunk.Size = Vector3.new(2 * scale, 12 * scale, 2 * scale)
	trunk.Position = Vector3.new(x, 6 * scale, z)
	trunk.Anchored = true
	trunk.Material = Enum.Material.Wood
	trunk.Color = trunkColor
	trunk:SetAttribute("ThemeRole", "tree_trunk")
	trunk:SetAttribute("BaseColor", trunkColor)
	trunk.Parent = tree

	local leavesColor = Color3.fromRGB(50, 120, 50)
	local leaves = Instance.new("Part")
	leaves.Size = Vector3.new(8 * scale, 10 * scale, 8 * scale)
	leaves.Position = Vector3.new(x, 14 * scale, z)
	leaves.Anchored = true
	leaves.Material = Enum.Material.Grass
	leaves.Color = leavesColor
	leaves.Shape = Enum.PartType.Ball
	leaves:SetAttribute("ThemeRole", "tree_leaves")
	leaves:SetAttribute("BaseColor", leavesColor)
	leaves.Parent = tree

	tree.Parent = DecorUtils.decorFolder
	return tree
end

function Tree.createBush(x, z, scale)
	if not DecorUtils.decorFolder then return nil end
	scale = scale or 1
	local bushColor = Color3.fromRGB(60, 100, 60)
	local bush = Instance.new("Part")
	bush.Name = "Bush"
	bush.Size = Vector3.new(4 * scale, 3 * scale, 4 * scale)
	bush.Position = Vector3.new(x, 1.5 * scale, z)
	bush.Anchored = true
	bush.Material = Enum.Material.Grass
	bush.Color = bushColor
	bush.Shape = Enum.PartType.Ball
	bush:SetAttribute("ThemeRole", "tree_bush")
	bush:SetAttribute("BaseColor", bushColor)
	bush.Parent = DecorUtils.decorFolder
	return bush
end

return Tree
