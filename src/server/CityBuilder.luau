-- CityBuilder.luau
-- Phase 1: builds a test area with grass terrain, roads, buildings, water edge.
-- Phase 2 will expand this into the full city grid.

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared", 10)
local GTAConfig = require(Shared:WaitForChild("GTAConfig"))

local DecorCreation = require(script.Parent:WaitForChild("DecorCreation"))
local DecorUtils = require(script.Parent:WaitForChild("DecorCreation"):WaitForChild("decor"):WaitForChild("DecorUtils"))
local Buildings = require(script.Parent:WaitForChild("DecorCreation"):WaitForChild("decor"):WaitForChild("Buildings"))
local Skyscrapers = require(script.Parent:WaitForChild("DecorCreation"):WaitForChild("decor"):WaitForChild("Skyscrapers"))
local Tree = require(script.Parent:WaitForChild("DecorCreation"):WaitForChild("decor"):WaitForChild("Tree"))
local Lamp = require(script.Parent:WaitForChild("DecorCreation"):WaitForChild("decor"):WaitForChild("Lamp"))
local Shops = require(script.Parent:WaitForChild("DecorCreation"):WaitForChild("decor"):WaitForChild("Shops"))

local CityBuilder = {}

local GROUND_Y = GTAConfig.GROUND_Y
local CELL_SIZE = GTAConfig.CELL_SIZE
local BLOCK_SIZE = GTAConfig.BLOCK_SIZE
local STREET_WIDTH = GTAConfig.STREET_WIDTH

--------------------------------------------------------------------------------
-- TERRAIN
--------------------------------------------------------------------------------

local function fillTerrain(position, size, material)
	local region = Region3.new(
		position - size / 2,
		position + size / 2
	):ExpandToGrid(4)
	Workspace.Terrain:FillRegion(region, 4, material)
end

local function buildGround()
	-- Fill city area with grass terrain
	local cityW = GTAConfig.CITY_WIDTH + 200  -- extra margin
	local cityD = GTAConfig.CITY_DEPTH + 200
	fillTerrain(
		Vector3.new(0, GROUND_Y - 10, 0),
		Vector3.new(cityW, 20, cityD),
		Enum.Material.Grass
	)
	print("[CityBuilder] Ground terrain filled")
end

local function buildWater()
	-- Ocean south of city
	local oceanCenterZ = GTAConfig.OCEAN_START_Z + GTAConfig.OCEAN_DEPTH / 2
	fillTerrain(
		Vector3.new(0, GTAConfig.WATER_LEVEL - 20, oceanCenterZ),
		Vector3.new(GTAConfig.CITY_WIDTH + 400, 40, GTAConfig.OCEAN_DEPTH),
		Enum.Material.Water
	)

	-- Beach sand transition at the southern edge of city
	fillTerrain(
		Vector3.new(200, GROUND_Y - 6, GTAConfig.OCEAN_START_Z - 25),
		Vector3.new(300, 12, 50),
		Enum.Material.Sand
	)

	print("[CityBuilder] Water and beach terrain filled")
end

--------------------------------------------------------------------------------
-- ROADS
--------------------------------------------------------------------------------

local function createRoadSegment(x, z, width, length, direction)
	local road = Instance.new("Part")
	road.Name = "Road"
	road.Anchored = true
	road.Material = Enum.Material.Asphalt
	road.Color = Color3.fromRGB(45, 45, 50)
	road.TopSurface = Enum.SurfaceType.Smooth
	road.BottomSurface = Enum.SurfaceType.Smooth

	if direction == "x" then
		road.Size = Vector3.new(length, 0.2, width)
	else
		road.Size = Vector3.new(width, 0.2, length)
	end

	road.Position = Vector3.new(x, GROUND_Y + 0.1, z)
	return road
end

local function createLaneMarkings(x, z, length, direction, parent)
	local DASH_LENGTH = 4
	local DASH_GAP = 6
	local DASH_TOTAL = DASH_LENGTH + DASH_GAP

	local markingCount = math.floor(length / DASH_TOTAL)

	for i = 0, markingCount - 1 do
		local mark = Instance.new("Part")
		mark.Name = "LaneMark"
		mark.Anchored = true
		mark.CanCollide = false
		mark.Material = Enum.Material.SmoothPlastic
		mark.Color = Color3.fromRGB(220, 210, 160)
		mark.TopSurface = Enum.SurfaceType.Smooth
		mark.BottomSurface = Enum.SurfaceType.Smooth

		local offset = -length / 2 + i * DASH_TOTAL + DASH_LENGTH / 2

		if direction == "z" then
			mark.Size = Vector3.new(0.3, 0.05, DASH_LENGTH)
			mark.Position = Vector3.new(x, GROUND_Y + 0.22, z + offset)
		else
			mark.Size = Vector3.new(DASH_LENGTH, 0.05, 0.3)
			mark.Position = Vector3.new(x + offset, GROUND_Y + 0.22, z)
		end

		mark.Parent = parent
	end
end

local function createSidewalk(x, z, width, length, direction, parent)
	local sidewalk = Instance.new("Part")
	sidewalk.Name = "Sidewalk"
	sidewalk.Anchored = true
	sidewalk.Material = Enum.Material.Concrete
	sidewalk.Color = Color3.fromRGB(170, 165, 155)
	sidewalk.TopSurface = Enum.SurfaceType.Smooth
	sidewalk.BottomSurface = Enum.SurfaceType.Smooth

	if direction == "x" then
		sidewalk.Size = Vector3.new(length, 0.4, width)
	else
		sidewalk.Size = Vector3.new(width, 0.4, length)
	end

	sidewalk.Position = Vector3.new(x, GROUND_Y + 0.05, z)
	sidewalk.Parent = parent
end

local function buildRoads(parent)
	local originX = GTAConfig.CITY_ORIGIN_X
	local originZ = GTAConfig.CITY_ORIGIN_Z
	local cityW = GTAConfig.CITY_WIDTH
	local cityD = GTAConfig.CITY_DEPTH

	-- Vertical streets (running north-south along Z)
	for col = 0, GTAConfig.GRID_COLS do
		local x = originX + col * CELL_SIZE
		local road = createRoadSegment(x, 0, STREET_WIDTH, cityD + 100, "z")
		road.Parent = parent

		-- Center lane markings
		createLaneMarkings(x, 0, cityD + 100, "z", parent)

		-- Sidewalks on both sides
		createSidewalk(x - STREET_WIDTH / 2 - 2, 0, 4, cityD + 100, "z", parent)
		createSidewalk(x + STREET_WIDTH / 2 + 2, 0, 4, cityD + 100, "z", parent)
	end

	-- Horizontal streets (running east-west along X)
	for row = 0, GTAConfig.GRID_ROWS do
		local z = originZ + row * CELL_SIZE
		local road = createRoadSegment(0, z, STREET_WIDTH, cityW + 100, "x")
		road.Parent = parent

		-- Center lane markings
		createLaneMarkings(0, z, cityW + 100, "x", parent)

		-- Sidewalks on both sides
		createSidewalk(0, z - STREET_WIDTH / 2 - 2, 4, cityW + 100, "x", parent)
		createSidewalk(0, z + STREET_WIDTH / 2 + 2, 4, cityW + 100, "x", parent)
	end

	print("[CityBuilder] Roads built:", GTAConfig.GRID_COLS + 1, "vertical,", GTAConfig.GRID_ROWS + 1, "horizontal")
end

--------------------------------------------------------------------------------
-- BUILDINGS (test placement — Phase 2 will use district-based pools)
--------------------------------------------------------------------------------

local function buildTestBuildings(decorFolder)
	-- Place a few buildings in the center blocks to verify the pipeline
	local originX = GTAConfig.CITY_ORIGIN_X
	local originZ = GTAConfig.CITY_ORIGIN_Z

	-- Downtown area (cols 3-4, rows 2-3) — skyscrapers
	for col = 3, 4 do
		for row = 2, 3 do
			local cellCenterX = originX + col * CELL_SIZE + CELL_SIZE / 2
			local cellCenterZ = originZ + row * CELL_SIZE + CELL_SIZE / 2

			-- Place buildings on both sides of the block
			local buildX = cellCenterX - BLOCK_SIZE / 4
			Buildings.buildFromSpec(
				{ facade = 40, floors = math.random(8, 15), color = Color3.fromRGB(150, 155, 165), mat = Enum.Material.Concrete, winColor = Color3.fromRGB(200, 230, 255), litPct = 0.5, winW = 2.5, winH = 4.0 },
				buildX, cellCenterZ, 1, 20
			)

			local buildX2 = cellCenterX + BLOCK_SIZE / 4
			Buildings.buildFromSpec(
				{ facade = 35, floors = math.random(6, 12), color = Color3.fromRGB(180, 170, 155), mat = Enum.Material.Brick, winColor = Color3.fromRGB(255, 220, 140), litPct = 0.45, winW = 2.0, winH = 3.5 },
				buildX2, cellCenterZ, 1, 18
			)
		end
	end

	-- Commercial area (cols 0-2, rows 2-3) — shops
	for col = 0, 2 do
		for row = 2, 3 do
			local cellCenterX = originX + col * CELL_SIZE + CELL_SIZE / 2
			local cellCenterZ = originZ + row * CELL_SIZE + CELL_SIZE / 2
			Shops.createShop(cellCenterX, cellCenterZ, 1)
		end
	end

	-- Residential area (cols 5-7, rows 2-3) — smaller buildings
	for col = 5, 7 do
		for row = 2, 3 do
			local cellCenterX = originX + col * CELL_SIZE + CELL_SIZE / 2
			local cellCenterZ = originZ + row * CELL_SIZE + CELL_SIZE / 2
			Buildings.buildFromSpec(
				{ facade = 30, floors = math.random(3, 6), color = Color3.fromRGB(210, 200, 185), mat = Enum.Material.SmoothPlastic, winColor = Color3.fromRGB(255, 200, 100), litPct = 0.4, winW = 2.5, winH = 3.5 },
				cellCenterX, cellCenterZ, 1, 14
			)
		end
	end

	print("[CityBuilder] Test buildings placed")
end

--------------------------------------------------------------------------------
-- STREET FURNITURE
--------------------------------------------------------------------------------

local function buildStreetFurniture(decorFolder)
	local originX = GTAConfig.CITY_ORIGIN_X
	local originZ = GTAConfig.CITY_ORIGIN_Z

	-- Street lamps along main roads
	for col = 0, GTAConfig.GRID_COLS do
		local x = originX + col * CELL_SIZE
		for row = 0, GTAConfig.GRID_ROWS do
			local z = originZ + row * CELL_SIZE
			-- Lamp on each corner
			Lamp.createStreetLamp(x + STREET_WIDTH / 2 + 3, z + STREET_WIDTH / 2 + 3, 1)
			Lamp.createStreetLamp(x - STREET_WIDTH / 2 - 3, z + STREET_WIDTH / 2 + 3, 1)
		end
	end

	-- Trees along some sidewalks (every other intersection)
	for col = 0, GTAConfig.GRID_COLS, 2 do
		local x = originX + col * CELL_SIZE
		for row = 0, GTAConfig.GRID_ROWS, 2 do
			local z = originZ + row * CELL_SIZE
			Tree.createTree(x + STREET_WIDTH / 2 + 6, z + 15, 1)
			Tree.createTree(x - STREET_WIDTH / 2 - 6, z - 15, 1)
		end
	end

	print("[CityBuilder] Street furniture placed")
end

--------------------------------------------------------------------------------
-- PUBLIC API
--------------------------------------------------------------------------------

function CityBuilder.build(decorFolder, vehicleFolder, npcFolder)
	-- Initialize DecorUtils so builders can parent to decorFolder
	DecorUtils.decorFolder = decorFolder

	-- 1. Terrain
	buildGround()
	buildWater()

	-- 2. Roads
	local roadFolder = Instance.new("Folder")
	roadFolder.Name = "Roads"
	roadFolder.Parent = Workspace:FindFirstChild("World") or Workspace
	buildRoads(roadFolder)

	-- 3. Buildings
	buildTestBuildings(decorFolder)

	-- 4. Street furniture
	buildStreetFurniture(decorFolder)

	print("[CityBuilder] City build complete!")
end

return CityBuilder
