local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local Office = {}

function Office.createOffice(x, z, scale)
	local decorFolder = DecorUtils.decorFolder
	if not decorFolder then return nil end
	scale = scale or 1
	local BUILDING_BASE = DecorUtils.BUILDING_BASE
	local pickRandom = DecorUtils.pickRandom
	local WALL_COLORS = DecorUtils.WALL_COLORS
	local WINDOW_COLORS = DecorUtils.WINDOW_COLORS
	local getFrontX = DecorUtils.getFrontX

	local building = Instance.new("Model")
	building.Name = "Building_Office"

	local facadeLen = math.random(18, 26) * scale
	local bDepth = math.random(14, 20) * scale
	local floors = math.random(4, 8)
	local floorHeight = 5.5 * scale
	local height = floors * floorHeight
	local wallColor = pickRandom(WALL_COLORS)

	-- Main body
	local main = Instance.new("Part")
	main.Size = Vector3.new(bDepth, height, facadeLen)
	main.Position = Vector3.new(x, BUILDING_BASE + height / 2, z)
	main.Anchored = true
	main.Material = Enum.Material.SmoothPlastic
	main.Color = wallColor
	main.Parent = building

	local frontX = getFrontX(x, bDepth)

	-- Glass strip across each floor on inward face
	local windowColor = pickRandom(WINDOW_COLORS)
	for floor = 1, floors do
		local floorY = BUILDING_BASE + (floor - 0.5) * floorHeight
		local strip = Instance.new("Part")
		strip.Size = Vector3.new(0.5, floorHeight * 0.5, facadeLen * 0.9)
		strip.Position = Vector3.new(frontX, floorY, z)
		strip.Anchored = true
		strip.CanCollide = false
		strip.Material = Enum.Material.Neon
		strip.Color = windowColor
		if math.random() < 0.2 then
			strip.Color = Color3.fromRGB(30, 35, 45)
			strip.Material = Enum.Material.Glass
		end
		strip.Parent = building
	end

	building.Parent = decorFolder
	return building
end

function Office.createTower(x, z, scale)
	local decorFolder = DecorUtils.decorFolder
	if not decorFolder then return nil end
	scale = scale or 1
	local BUILDING_BASE = DecorUtils.BUILDING_BASE
	local pickRandom = DecorUtils.pickRandom
	local WALL_COLORS = DecorUtils.WALL_COLORS
	local WINDOW_COLORS = DecorUtils.WINDOW_COLORS
	local addWindowsToFace = DecorUtils.addWindowsToFace
	local getFrontX = DecorUtils.getFrontX

	local building = Instance.new("Model")
	building.Name = "Building_Tower"

	local facadeLen = math.random(10, 16) * scale
	local bDepth = math.random(10, 16) * scale
	local floors = math.random(10, 18)
	local floorHeight = 4.5 * scale
	local height = floors * floorHeight
	local wallColor = pickRandom(WALL_COLORS)

	-- Main body
	local main = Instance.new("Part")
	main.Size = Vector3.new(bDepth, height, facadeLen)
	main.Position = Vector3.new(x, BUILDING_BASE + height / 2, z)
	main.Anchored = true
	main.Material = Enum.Material.Metal
	main.Color = wallColor
	main.Parent = building

	-- Windows on all 4 faces (fixed: was calling undefined addAllWindows)
	local winW = 2 * scale
	local winH = 2 * scale
	local winGap = 2 * scale
	local litColor = pickRandom(WINDOW_COLORS)
	local litChance = 0.7
	local frontX = getFrontX(x, bDepth)
	local backX = x + (x > 0 and 1 or -1) * (bDepth / 2 + 0.2)
	-- Front face (inward, along X axis)
	addWindowsToFace(building, "x", frontX, z, facadeLen, BUILDING_BASE, floors, floorHeight, winW, winH, winGap, litColor, litChance)
	-- Back face
	addWindowsToFace(building, "x", backX, z, facadeLen, BUILDING_BASE, floors, floorHeight, winW, winH, winGap, litColor, litChance)
	-- Side faces (along Z axis)
	addWindowsToFace(building, "z", z + facadeLen / 2 + 0.2, x, bDepth, BUILDING_BASE, floors, floorHeight, winW, winH, winGap, litColor, litChance)
	addWindowsToFace(building, "z", z - facadeLen / 2 - 0.2, x, bDepth, BUILDING_BASE, floors, floorHeight, winW, winH, winGap, litColor, litChance)

	-- Antenna
	local antenna = Instance.new("Part")
	antenna.Size = Vector3.new(0.5, 8 * scale, 0.5)
	antenna.Position = Vector3.new(x, BUILDING_BASE + height + 4 * scale, z)
	antenna.Anchored = true
	antenna.Material = Enum.Material.Metal
	antenna.Color = Color3.fromRGB(80, 80, 85)
	antenna.Parent = building

	-- Blinking red light on antenna
	local light = Instance.new("Part")
	light.Size = Vector3.new(1, 1, 1)
	light.Position = Vector3.new(x, BUILDING_BASE + height + 8 * scale + 0.5, z)
	light.Anchored = true
	light.CanCollide = false
	light.Shape = Enum.PartType.Ball
	light.Material = Enum.Material.Neon
	light.Color = Color3.fromRGB(255, 0, 0)
	light.Parent = building

	building.Parent = decorFolder
	return building
end

return Office
