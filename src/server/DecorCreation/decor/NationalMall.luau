local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))
local Tree = require(script.Parent:WaitForChild("Tree"))

local NationalMall = {}

local BUILDING_BASE = DecorUtils.BUILDING_BASE

-- Park bench with wood slats and iron frame
local function createMallBench(x, z, scale, faceZ)
	local decorFolder = DecorUtils.decorFolder
	if not decorFolder then return nil end
	scale = scale or 1

	local bench = Instance.new("Model")
	bench.Name = "MallBench"

	local ironColor = Color3.fromRGB(35, 35, 40)
	local woodColor = Color3.fromRGB(110, 70, 40)
	local seatY = BUILDING_BASE + 1.4 * scale
	local rot = faceZ and CFrame.Angles(0, 0, 0) or CFrame.Angles(0, math.rad(90), 0)

	-- Iron legs (3 along the bench)
	for _, lx in ipairs({-1.8, 0, 1.8}) do
		local leg = Instance.new("Part")
		leg.Name = "IronLeg"
		leg.Size = Vector3.new(0.25 * scale, 1.4 * scale, 1.6 * scale)
		leg.CFrame = CFrame.new(x, BUILDING_BASE + 0.7 * scale, z) * rot * CFrame.new(lx * scale, 0, 0)
		leg.Anchored = true
		leg.Material = Enum.Material.Metal
		leg.Color = ironColor
		leg.Parent = bench
	end

	-- Iron armrests at ends
	for _, side in ipairs({-1, 1}) do
		local arm = Instance.new("Part")
		arm.Name = "Armrest"
		arm.Size = Vector3.new(0.2 * scale, 1.2 * scale, 0.2 * scale)
		arm.CFrame = CFrame.new(x, seatY + 0.4 * scale, z) * rot * CFrame.new(side * 2 * scale, 0, -0.5 * scale)
		arm.Anchored = true
		arm.Material = Enum.Material.Metal
		arm.Color = ironColor
		arm.Parent = bench
	end

	-- Seat: 4 wood slats
	for i = 0, 3 do
		local slat = Instance.new("Part")
		slat.Name = "SeatSlat"
		slat.Size = Vector3.new(4 * scale, 0.15 * scale, 0.35 * scale)
		slat.CFrame = CFrame.new(x, seatY, z) * rot * CFrame.new(0, 0, -0.6 * scale + i * 0.4 * scale)
		slat.Anchored = true
		slat.Material = Enum.Material.Wood
		slat.Color = woodColor
		slat.Parent = bench
	end

	-- Back: 3 wood slats
	for i = 0, 2 do
		local slat = Instance.new("Part")
		slat.Name = "BackSlat"
		slat.Size = Vector3.new(4 * scale, 0.15 * scale, 0.3 * scale)
		slat.CFrame = CFrame.new(x, seatY + 0.5 * scale + i * 0.35 * scale, z)
			* rot * CFrame.new(0, 0, -0.8 * scale)
			* CFrame.Angles(math.rad(-10), 0, 0)
		slat.Anchored = true
		slat.Material = Enum.Material.Wood
		slat.Color = woodColor
		slat.Parent = bench
	end

	bench.Parent = decorFolder
	return bench
end

-- Subtle park lamp (dimmer than street lamp)
local function createMallLamp(x, z, scale)
	local decorFolder = DecorUtils.decorFolder
	if not decorFolder then return nil end
	scale = scale or 1

	local lamp = Instance.new("Model")
	lamp.Name = "MallLamp"

	local poleColor = Color3.fromRGB(35, 35, 40)

	local pole = Instance.new("Part")
	pole.Size = Vector3.new(0.4 * scale, 10 * scale, 0.4 * scale)
	pole.Position = Vector3.new(x, BUILDING_BASE + 5 * scale, z)
	pole.Anchored = true
	pole.Material = Enum.Material.Metal
	pole.Color = poleColor
	pole.Parent = lamp

	-- Globe on top
	local globe = Instance.new("Part")
	globe.Name = "Globe"
	globe.Shape = Enum.PartType.Ball
	globe.Size = Vector3.new(1.5 * scale, 1.5 * scale, 1.5 * scale)
	globe.Position = Vector3.new(x, BUILDING_BASE + 10.5 * scale, z)
	globe.Anchored = true
	globe.Material = Enum.Material.Neon
	globe.Color = Color3.fromRGB(255, 235, 190)
	globe.Transparency = 0.3
	globe.Parent = lamp

	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 235, 190)
	light.Brightness = 0.4
	light.Range = 18
	light.Parent = globe

	lamp.Parent = decorFolder
	return lamp
end

function NationalMall.createNationalMall(x, z, scale)
	if not DecorUtils.decorFolder then return nil end
	scale = scale or 1

	local depth = 80 * scale
	local halfDepth = depth / 2

	-- Central concrete walkway
	local walkway = Instance.new("Part")
	walkway.Name = "MallWalkway"
	walkway.Size = Vector3.new(6 * scale, 0.3 * scale, depth)
	walkway.Position = Vector3.new(0, BUILDING_BASE + 0.25, z)
	walkway.Anchored = true
	walkway.Material = Enum.Material.Concrete
	walkway.Color = Color3.fromRGB(180, 175, 168)
	walkway.Parent = DecorUtils.decorFolder

	-- Tree rows at multiple distances from center
	local treeRows = { 12, 35, 60, 90, 130, 170 }
	local treeSpacing = 16 * scale

	for _, rowX in ipairs(treeRows) do
		local numTrees = math.floor(depth / treeSpacing)
		for i = 0, numTrees - 1 do
			local tz = z + halfDepth - treeSpacing / 2 - i * treeSpacing
			tz = tz + (math.random() - 0.5) * 3
			local s = 0.8 + math.random() * 0.4
			for _, side in ipairs({-1, 1}) do
				local tx = side * (rowX + (math.random() - 0.5) * 4)
				Tree.createTree(tx, tz, s)
			end
		end
	end

	-- Mall lamps along walkway and outer paths
	local lampSpacing = 22 * scale
	local lampRows = { 5, 50, 110 }
	local numLamps = math.floor(depth / lampSpacing)
	for _, rowX in ipairs(lampRows) do
		for i = 0, numLamps - 1 do
			local lz = z + halfDepth - lampSpacing / 2 - i * lampSpacing
			for _, side in ipairs({-1, 1}) do
				createMallLamp(side * rowX, lz, 0.8)
			end
		end
	end

	-- Bushes scattered throughout
	local bushRows = { 20, 45, 75, 100, 145 }
	local bushSpacing = 14 * scale
	for _, rowX in ipairs(bushRows) do
		local numBushes = math.floor(depth / bushSpacing)
		for i = 0, numBushes - 1 do
			local bz = z + halfDepth - bushSpacing / 2 - i * bushSpacing
			bz = bz + (math.random() - 0.5) * 5
			for _, side in ipairs({-1, 1}) do
				local bxOff = (math.random() - 0.5) * 6
				Tree.createBush(side * (rowX + bxOff), bz, 0.5 + math.random() * 0.4)
			end
		end
	end

	return walkway
end

return NationalMall
