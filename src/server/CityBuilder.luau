-- CityBuilder.luau
-- Phase 1: Infrastructure skeleton — terrain, major roads, railway, metro, water.
-- No buildings, no decor, no vehicles. Districts get filled in later.

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared", 10)
local GTAConfig = require(Shared:WaitForChild("GTAConfig"))
local DecorCreation = require(script.Parent:WaitForChild("DecorCreation"))
local DecorUtils = require(script.Parent:WaitForChild("DecorCreation"):WaitForChild("decor"):WaitForChild("DecorUtils"))

local CityBuilder = {}

-- Shortcuts
local GROUND_Y     = GTAConfig.GROUND_Y
local CELL         = GTAConfig.CELL_SIZE
local COLS         = GTAConfig.GRID_COLS
local ROWS         = GTAConfig.GRID_ROWS
local ORIGIN_X     = GTAConfig.CITY_ORIGIN_X
local ORIGIN_Z     = GTAConfig.CITY_ORIGIN_Z
local CITY_W       = GTAConfig.CITY_WIDTH
local CITY_D       = GTAConfig.CITY_DEPTH
local STREET_W     = GTAConfig.STREET_WIDTH
local HIGHWAY_W    = GTAConfig.HIGHWAY_WIDTH

local roadFolder = nil

--------------------------------------------------------------------------------
-- TERRAIN MATERIALS PER DISTRICT
--------------------------------------------------------------------------------

local DISTRICT_TERRAIN = {
	airport      = Enum.Material.Concrete,
	industrial   = Enum.Material.Slate,
	power_plant  = Enum.Material.Slate,
	military     = Enum.Material.Sand,
	nuclear      = Enum.Material.Ground,
	commercial   = Enum.Material.Ground,
	downtown     = Enum.Material.Concrete,
	government   = Enum.Material.Grass,
	prison       = Enum.Material.Slate,
	residential  = Enum.Material.Grass,
	harbor       = Enum.Material.Slate,
	water_plant  = Enum.Material.Mud,
	waterfront   = Enum.Material.Grass,
	beach        = Enum.Material.Sand,
	space        = Enum.Material.Basalt,
}

--------------------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------------------

local function fillTerrain(position, size, material)
	local region = Region3.new(position - size / 2, position + size / 2):ExpandToGrid(4)
	Workspace.Terrain:FillRegion(region, 4, material)
end

local function createRoad(x, z, sizeX, sizeZ, isHighway)
	local road = Instance.new("Part")
	road.Name = isHighway and "Highway" or "Road"
	road.Anchored = true
	road.Material = Enum.Material.Asphalt
	road.Color = isHighway and Color3.fromRGB(55, 55, 60) or Color3.fromRGB(45, 45, 50)
	road.TopSurface = Enum.SurfaceType.Smooth
	road.BottomSurface = Enum.SurfaceType.Smooth
	road.Size = Vector3.new(sizeX, 0.3, sizeZ)
	road.Position = Vector3.new(x, GROUND_Y + 0.15, z)
	road.Parent = roadFolder
	return road
end

local function createSidewalk(x, z, sizeX, sizeZ)
	local sw = Instance.new("Part")
	sw.Name = "Sidewalk"
	sw.Anchored = true
	sw.Material = Enum.Material.Concrete
	sw.Color = Color3.fromRGB(170, 165, 155)
	sw.TopSurface = Enum.SurfaceType.Smooth
	sw.BottomSurface = Enum.SurfaceType.Smooth
	sw.Size = Vector3.new(sizeX, 0.5, sizeZ)
	sw.Position = Vector3.new(x, GROUND_Y + 0.05, z)
	sw.Parent = roadFolder
end

local function createLaneMarkings(x, z, length, direction)
	local DASH = 4
	local GAP = 6
	local count = math.floor(length / (DASH + GAP))
	for i = 0, count - 1 do
		local mark = Instance.new("Part")
		mark.Name = "LaneMark"
		mark.Anchored = true
		mark.CanCollide = false
		mark.Material = Enum.Material.SmoothPlastic
		mark.Color = Color3.fromRGB(220, 210, 160)
		mark.TopSurface = Enum.SurfaceType.Smooth
		mark.BottomSurface = Enum.SurfaceType.Smooth
		local offset = -length / 2 + i * (DASH + GAP) + DASH / 2
		if direction == "z" then
			mark.Size = Vector3.new(0.3, 0.05, DASH)
			mark.Position = Vector3.new(x, GROUND_Y + 0.32, z + offset)
		else
			mark.Size = Vector3.new(DASH, 0.05, 0.3)
			mark.Position = Vector3.new(x + offset, GROUND_Y + 0.32, z)
		end
		mark.Parent = roadFolder
	end
end

--------------------------------------------------------------------------------
-- 1. ISLAND TERRAIN (ocean + base island)
--------------------------------------------------------------------------------

local function buildIslandTerrain()
	local margin = GTAConfig.OCEAN_MARGIN
	local totalW = CITY_W + margin * 2
	local totalD = CITY_D + margin * 2

	-- Ocean
	fillTerrain(
		Vector3.new(0, GTAConfig.WATER_LEVEL - 20, 0),
		Vector3.new(totalW, 40, totalD),
		Enum.Material.Water
	)

	-- Island base (grass, elevated above water)
	fillTerrain(
		Vector3.new(0, GROUND_Y - 10, 0),
		Vector3.new(CITY_W + 100, 20, CITY_D + 100),
		Enum.Material.Grass
	)

	-- Coastline sand on all 4 edges
	local coast = GTAConfig.COASTLINE_WIDTH
	local halfW = CITY_W / 2 + 50
	local halfD = CITY_D / 2 + 50
	fillTerrain(Vector3.new(0, GROUND_Y - 6, -halfD), Vector3.new(CITY_W + 100, 12, coast), Enum.Material.Sand)
	fillTerrain(Vector3.new(0, GROUND_Y - 6,  halfD), Vector3.new(CITY_W + 100, 12, coast), Enum.Material.Sand)
	fillTerrain(Vector3.new(-halfW, GROUND_Y - 6, 0), Vector3.new(coast, 12, CITY_D + 100), Enum.Material.Sand)
	fillTerrain(Vector3.new( halfW, GROUND_Y - 6, 0), Vector3.new(coast, 12, CITY_D + 100), Enum.Material.Sand)

	print("[CityBuilder] Island terrain built")
end

--------------------------------------------------------------------------------
-- 2. PER-DISTRICT TERRAIN
--------------------------------------------------------------------------------

local function buildDistrictTerrain()
	for _, d in ipairs(GTAConfig.DISTRICTS) do
		local mat = DISTRICT_TERRAIN[d.name]
		if not mat then continue end

		local x1 = ORIGIN_X + d.colMin * CELL
		local z1 = ORIGIN_Z + d.rowMin * CELL
		local x2 = ORIGIN_X + (d.colMax + 1) * CELL
		local z2 = ORIGIN_Z + (d.rowMax + 1) * CELL

		local cx = (x1 + x2) / 2
		local cz = (z1 + z2) / 2
		local w = x2 - x1
		local d_depth = z2 - z1

		fillTerrain(
			Vector3.new(cx, GROUND_Y - 4, cz),
			Vector3.new(w, 8, d_depth),
			mat
		)
	end
	print("[CityBuilder] District terrain painted (15 zones)")
end

--------------------------------------------------------------------------------
-- 3. MAJOR ROADS (zone-boundary avenues + perimeter highway)
--------------------------------------------------------------------------------

local function buildMajorRoads()
	-- Collect all unique district boundary edges
	-- Rows: horizontal E-W roads at district top/bottom edges
	-- Cols: vertical N-S roads at district left/right edges

	local hEdges = {}  -- hEdges[row] = { {xMin, xMax}, ... }
	local vEdges = {}  -- vEdges[col] = { {zMin, zMax}, ... }

	for _, d in ipairs(GTAConfig.DISTRICTS) do
		-- Top edge (row boundary)
		local topRow = d.rowMin
		if not hEdges[topRow] then hEdges[topRow] = {} end
		table.insert(hEdges[topRow], {
			x1 = ORIGIN_X + d.colMin * CELL,
			x2 = ORIGIN_X + (d.colMax + 1) * CELL,
		})

		-- Bottom edge
		local botRow = d.rowMax + 1
		if not hEdges[botRow] then hEdges[botRow] = {} end
		table.insert(hEdges[botRow], {
			x1 = ORIGIN_X + d.colMin * CELL,
			x2 = ORIGIN_X + (d.colMax + 1) * CELL,
		})

		-- Left edge
		local leftCol = d.colMin
		if not vEdges[leftCol] then vEdges[leftCol] = {} end
		table.insert(vEdges[leftCol], {
			z1 = ORIGIN_Z + d.rowMin * CELL,
			z2 = ORIGIN_Z + (d.rowMax + 1) * CELL,
		})

		-- Right edge
		local rightCol = d.colMax + 1
		if not vEdges[rightCol] then vEdges[rightCol] = {} end
		table.insert(vEdges[rightCol], {
			z1 = ORIGIN_Z + d.rowMin * CELL,
			z2 = ORIGIN_Z + (d.rowMax + 1) * CELL,
		})
	end

	local roadCount = 0
	local SW_THICK = 5  -- sidewalk thickness

	-- Build horizontal roads (E-W)
	for row, segments in pairs(hEdges) do
		local z = ORIGIN_Z + row * CELL
		local isPerimeter = (row == 0 or row == ROWS)
		local w = isPerimeter and HIGHWAY_W or STREET_W

		-- Merge overlapping segments into one full-width road
		local minX, maxX = math.huge, -math.huge
		for _, seg in ipairs(segments) do
			minX = math.min(minX, seg.x1)
			maxX = math.max(maxX, seg.x2)
		end

		local cx = (minX + maxX) / 2
		local length = maxX - minX + 60  -- extend slightly past edges

		createRoad(cx, z, length, w, isPerimeter)
		createLaneMarkings(cx, z, length, "x")
		createSidewalk(cx, z - w / 2 - SW_THICK / 2, length, SW_THICK)
		createSidewalk(cx, z + w / 2 + SW_THICK / 2, length, SW_THICK)
		roadCount += 1
	end

	-- Build vertical roads (N-S)
	for col, segments in pairs(vEdges) do
		local x = ORIGIN_X + col * CELL
		local isPerimeter = (col == 0 or col == COLS)
		local w = isPerimeter and HIGHWAY_W or STREET_W

		local minZ, maxZ = math.huge, -math.huge
		for _, seg in ipairs(segments) do
			minZ = math.min(minZ, seg.z1)
			maxZ = math.max(maxZ, seg.z2)
		end

		local cz = (minZ + maxZ) / 2
		local length = maxZ - minZ + 60

		createRoad(x, cz, w, length, isPerimeter)
		createLaneMarkings(x, cz, length, "z")
		createSidewalk(x - w / 2 - SW_THICK / 2, cz, SW_THICK, length)
		createSidewalk(x + w / 2 + SW_THICK / 2, cz, SW_THICK, length)
		roadCount += 1
	end

	print("[CityBuilder] Major roads built:", roadCount, "avenues")
end

--------------------------------------------------------------------------------
-- 4. WATER CHANNEL (canal between central & south bands)
--------------------------------------------------------------------------------

local function buildWaterChannel()
	local chanZ = ORIGIN_Z + GTAConfig.WATER_CHANNEL_Z_ROW * CELL
	local chanW = GTAConfig.WATER_CHANNEL_WIDTH

	-- Dig out terrain and fill with water
	fillTerrain(
		Vector3.new(0, GROUND_Y - 8, chanZ),
		Vector3.new(CITY_W - CELL * 2, 16, chanW),
		Enum.Material.Air
	)
	fillTerrain(
		Vector3.new(0, GTAConfig.WATER_LEVEL - 4, chanZ),
		Vector3.new(CITY_W - CELL * 2, 8, chanW),
		Enum.Material.Water
	)

	-- Stone walls on both banks
	for _, side in ipairs({-1, 1}) do
		local wallZ = chanZ + side * (chanW / 2 + 1)
		local wall = Instance.new("Part")
		wall.Name = "CanalWall"
		wall.Anchored = true
		wall.Material = Enum.Material.Slate
		wall.Color = Color3.fromRGB(80, 75, 70)
		wall.Size = Vector3.new(CITY_W - CELL * 2, 6, 2)
		wall.Position = Vector3.new(0, GROUND_Y - 2, wallZ)
		wall.Parent = roadFolder
	end

	print("[CityBuilder] Water channel built")
end

--------------------------------------------------------------------------------
-- 5. BRIDGES (over water channel at major road crossings)
--------------------------------------------------------------------------------

local function buildBridges()
	local chanZ = ORIGIN_Z + GTAConfig.WATER_CHANNEL_Z_ROW * CELL
	local chanW = GTAConfig.WATER_CHANNEL_WIDTH

	-- Find which vertical roads cross the water channel
	-- Use same boundary detection as major roads
	local bridgeCols = {}
	for _, d in ipairs(GTAConfig.DISTRICTS) do
		bridgeCols[d.colMin] = true
		bridgeCols[d.colMax + 1] = true
	end

	for col, _ in pairs(bridgeCols) do
		local x = ORIGIN_X + col * CELL
		-- Only build bridge if road actually spans the channel zone
		if col > 0 and col < COLS then
			-- Bridge deck
			local deck = Instance.new("Part")
			deck.Name = "BridgeDeck"
			deck.Anchored = true
			deck.Material = Enum.Material.Concrete
			deck.Color = Color3.fromRGB(160, 155, 145)
			deck.Size = Vector3.new(STREET_W + 10, 1, chanW + 20)
			deck.Position = Vector3.new(x, GROUND_Y + 0.5, chanZ)
			deck.Parent = roadFolder

			-- Bridge railings
			for _, side in ipairs({-1, 1}) do
				local rail = Instance.new("Part")
				rail.Name = "BridgeRail"
				rail.Anchored = true
				rail.Material = Enum.Material.Metal
				rail.Color = Color3.fromRGB(100, 100, 110)
				rail.Size = Vector3.new(1, 3, chanW + 20)
				rail.Position = Vector3.new(x + side * (STREET_W / 2 + 5), GROUND_Y + 2, chanZ)
				rail.Parent = roadFolder
			end
		end
	end

	print("[CityBuilder] Bridges built over water channel")
end

--------------------------------------------------------------------------------
-- 6. RAILWAY (ground-level N-S freight line)
--------------------------------------------------------------------------------

local function buildRailway()
	-- Railway runs along the col-4 boundary (airport/industrial divide)
	-- extends full island height
	local railX = ORIGIN_X + 4 * CELL

	-- Rail bed (gravel strip)
	local bed = Instance.new("Part")
	bed.Name = "RailBed"
	bed.Anchored = true
	bed.Material = Enum.Material.Pebble
	bed.Color = Color3.fromRGB(120, 110, 95)
	bed.Size = Vector3.new(12, 0.2, CITY_D + 40)
	bed.Position = Vector3.new(railX, GROUND_Y + 0.1, 0)
	bed.Parent = roadFolder

	-- Rails (two steel lines)
	for _, offset in ipairs({-2, 2}) do
		local rail = Instance.new("Part")
		rail.Name = "Rail"
		rail.Anchored = true
		rail.Material = Enum.Material.Metal
		rail.Color = Color3.fromRGB(140, 140, 150)
		rail.Size = Vector3.new(0.4, 0.3, CITY_D + 40)
		rail.Position = Vector3.new(railX + offset, GROUND_Y + 0.25, 0)
		rail.Parent = roadFolder
	end

	-- Cross-ties every 8 studs
	local tieCount = math.floor(CITY_D / 8)
	for i = 0, tieCount do
		local z = ORIGIN_Z - 20 + i * 8
		local tie = Instance.new("Part")
		tie.Name = "Tie"
		tie.Anchored = true
		tie.CanCollide = false
		tie.Material = Enum.Material.Wood
		tie.Color = Color3.fromRGB(90, 60, 30)
		tie.Size = Vector3.new(8, 0.15, 1.5)
		tie.Position = Vector3.new(railX, GROUND_Y + 0.12, z)
		tie.Parent = roadFolder
	end

	print("[CityBuilder] Railway built along col 4 (N-S)")
end

--------------------------------------------------------------------------------
-- 7. ELEVATED METRO (NYC-style, E-W + N-S crossing)
--------------------------------------------------------------------------------

local function buildElevatedMetro()
	local metroY = GTAConfig.METRO_HEIGHT
	local metroColor = Color3.fromRGB(60, 65, 75)
	local pillarColor = Color3.fromRGB(80, 80, 90)

	-- E-W line through central band center (row 4.5 → between rows 4 and 5)
	local ewZ = ORIGIN_Z + 4.5 * CELL + CELL / 2

	-- Track deck
	local ewDeck = Instance.new("Part")
	ewDeck.Name = "MetroEW"
	ewDeck.Anchored = true
	ewDeck.Material = Enum.Material.Metal
	ewDeck.Color = metroColor
	ewDeck.Size = Vector3.new(CITY_W + 40, 1, 10)
	ewDeck.Position = Vector3.new(0, metroY, ewZ)
	ewDeck.Parent = roadFolder

	-- Pillars for E-W line
	for col = 0, COLS, 2 do
		local px = ORIGIN_X + col * CELL
		local pillar = Instance.new("Part")
		pillar.Name = "MetroPillar"
		pillar.Anchored = true
		pillar.Material = Enum.Material.Concrete
		pillar.Color = pillarColor
		pillar.Size = Vector3.new(3, metroY - GROUND_Y, 3)
		pillar.Position = Vector3.new(px, GROUND_Y + (metroY - GROUND_Y) / 2, ewZ)
		pillar.Parent = roadFolder
	end

	-- N-S line through downtown center (col 6 → between cols 5 and 6)
	local nsX = ORIGIN_X + 6 * CELL

	local nsDeck = Instance.new("Part")
	nsDeck.Name = "MetroNS"
	nsDeck.Anchored = true
	nsDeck.Material = Enum.Material.Metal
	nsDeck.Color = metroColor
	nsDeck.Size = Vector3.new(10, 1, CITY_D + 40)
	nsDeck.Position = Vector3.new(nsX, metroY, 0)
	nsDeck.Parent = roadFolder

	-- Pillars for N-S line
	for row = 0, ROWS, 2 do
		local pz = ORIGIN_Z + row * CELL
		local pillar = Instance.new("Part")
		pillar.Name = "MetroPillar"
		pillar.Anchored = true
		pillar.Material = Enum.Material.Concrete
		pillar.Color = pillarColor
		pillar.Size = Vector3.new(3, metroY - GROUND_Y, 3)
		pillar.Position = Vector3.new(nsX, GROUND_Y + (metroY - GROUND_Y) / 2, pz)
		pillar.Parent = roadFolder
	end

	-- Station platforms at key intersections
	local stations = {
		{ x = ORIGIN_X + 2 * CELL,  z = ewZ, name = "Airport" },
		{ x = ORIGIN_X + 5 * CELL,  z = ewZ, name = "Downtown West" },
		{ x = ORIGIN_X + 8 * CELL,  z = ewZ, name = "Government" },
		{ x = ORIGIN_X + 11 * CELL, z = ewZ, name = "Residential" },
		{ x = nsX, z = ORIGIN_Z + 1.5 * CELL, name = "Industrial" },
		{ x = nsX, z = ewZ, name = "Metro Hub" },
		{ x = nsX, z = ORIGIN_Z + 8 * CELL, name = "Waterfront" },
	}

	for _, s in ipairs(stations) do
		-- Platform
		local plat = Instance.new("Part")
		plat.Name = "Station_" .. s.name
		plat.Anchored = true
		plat.Material = Enum.Material.Concrete
		plat.Color = Color3.fromRGB(180, 175, 165)
		plat.Size = Vector3.new(20, 0.5, 20)
		plat.Position = Vector3.new(s.x, metroY + 0.5, s.z)
		plat.Parent = roadFolder

		-- Station sign
		local sign = Instance.new("Part")
		sign.Name = "StationSign"
		sign.Anchored = true
		sign.Material = Enum.Material.SmoothPlastic
		sign.Color = Color3.fromRGB(0, 150, 220)
		sign.Size = Vector3.new(12, 3, 0.5)
		sign.Position = Vector3.new(s.x, metroY + 3, s.z - 10)
		sign.Parent = roadFolder

		local sg = Instance.new("SurfaceGui")
		sg.Face = Enum.NormalId.Front
		sg.Parent = sign
		local tl = Instance.new("TextLabel")
		tl.Size = UDim2.new(1, 0, 1, 0)
		tl.BackgroundTransparency = 1
		tl.Text = s.name
		tl.TextColor3 = Color3.fromRGB(255, 255, 255)
		tl.Font = Enum.Font.GothamBold
		tl.TextScaled = true
		tl.Parent = sg
	end

	print("[CityBuilder] Elevated metro built with", #stations, "stations")
end

--------------------------------------------------------------------------------
-- PUBLIC API
--------------------------------------------------------------------------------

function CityBuilder.build(decorFolderRef, vehicleFolderRef, npcFolderRef)
	DecorUtils.decorFolder = decorFolderRef

	-- Road folder for all infrastructure parts
	local worldFolder = Workspace:FindFirstChild("World") or Workspace
	roadFolder = Instance.new("Folder")
	roadFolder.Name = "Roads"
	roadFolder.Parent = worldFolder

	-- Phase 1: Infrastructure only
	print("[CityBuilder] === Building infrastructure skeleton ===")

	buildIslandTerrain()
	buildDistrictTerrain()
	buildMajorRoads()
	buildWaterChannel()
	buildBridges()
	buildRailway()
	buildElevatedMetro()

	print("[CityBuilder] === Infrastructure complete! ===")
	print("[CityBuilder] Island size:", CITY_W, "x", CITY_D, "studs")
	print("[CityBuilder] Grid:", COLS, "x", ROWS, "cells @", CELL, "studs each")
end

return CityBuilder
