-- CityBuilder.luau
-- Builds the full GTA island: terrain, roads, districts, landmarks, vehicles.

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared", 10)
local GTAConfig = require(Shared:WaitForChild("GTAConfig"))
local DecorCreation = require(script.Parent:WaitForChild("DecorCreation"))
local DecorUtils = require(script.Parent:WaitForChild("DecorCreation"):WaitForChild("decor"):WaitForChild("DecorUtils"))

local CityBuilder = {}

-- Shortcuts
local GROUND_Y     = GTAConfig.GROUND_Y
local CELL_SIZE    = GTAConfig.CELL_SIZE
local BLOCK_SIZE   = GTAConfig.BLOCK_SIZE
local STREET_WIDTH = GTAConfig.STREET_WIDTH
local COLS         = GTAConfig.GRID_COLS
local ROWS         = GTAConfig.GRID_ROWS
local ORIGIN_X     = GTAConfig.CITY_ORIGIN_X
local ORIGIN_Z     = GTAConfig.CITY_ORIGIN_Z
local CITY_W       = GTAConfig.CITY_WIDTH
local CITY_D       = GTAConfig.CITY_DEPTH

-- Folder refs set in build()
local vehicleFolder = nil

--------------------------------------------------------------------------------
-- OCCUPANCY GRID
-- Tracks which cells are reserved (infrastructure, landmarks).
-- Buildings only go in free cells.
-- Values: nil/false = free, string = reason reserved
--------------------------------------------------------------------------------

local occupancy = {}  -- occupancy[col][row] = "reason" or nil

local function reserveCell(col, row, reason)
	if col < 0 or col >= COLS or row < 0 or row >= ROWS then return end
	if not occupancy[col] then occupancy[col] = {} end
	occupancy[col][row] = reason or "reserved"
end

local function isCellFree(col, row)
	if not occupancy[col] then return true end
	return not occupancy[col][row]
end

-- Reserve cells for infrastructure lanes BEFORE placing buildings
local function reserveInfrastructure()
	-- Railway at col 4 boundary → reserve cells on both sides (col 3 and col 4)
	for row = 0, ROWS - 1 do
		reserveCell(3, row, "railway_adj")
		reserveCell(4, row, "railway_adj")
	end

	-- Elevated metro E-W at row 4 → reserve row 4 cells along the metro path
	for col = 0, COLS - 1 do
		reserveCell(col, 4, "metro_ew")
	end

	-- Elevated metro N-S at col 5 → reserve col 5 cells
	for row = 0, ROWS - 1 do
		reserveCell(5, row, "metro_ns")
	end

	-- Water channel at row 5.5 → reserve rows 5 and 6 (both sides of channel)
	for col = 0, COLS - 1 do
		reserveCell(col, 5, "water_channel")
		reserveCell(col, 6, "water_channel")
	end

	-- Special compound districts (no standard block placement at all)
	local compoundDistricts = { "military", "prison", "space" }
	for _, dName in ipairs(compoundDistricts) do
		local d = GTAConfig.getDistrictDef(dName)
		if d then
			for col = d.colMin, d.colMax do
				for row = d.rowMin, d.rowMax do
					reserveCell(col, row, "compound_" .. dName)
				end
			end
		end
	end

	-- Government: reserve center cells for White House compound
	local gov = GTAConfig.getDistrictDef("government")
	if gov then
		local midCol = math.floor((gov.colMin + gov.colMax) / 2)
		local midRow = math.floor((gov.rowMin + gov.rowMax) / 2)
		reserveCell(midCol, midRow, "whitehouse")
		reserveCell(midCol + 1, midRow, "whitehouse")
		reserveCell(midCol, midRow + 1, "national_mall")
		reserveCell(midCol + 1, midRow + 1, "monument")
	end

	-- Airport: reserve runway cells (cols 0-2, center row of airport)
	local apt = GTAConfig.getDistrictDef("airport")
	if apt then
		local runwayRow = math.floor((apt.rowMin + apt.rowMax) / 2)
		for col = apt.colMin, apt.colMin + 2 do
			reserveCell(col, runwayRow, "runway")
		end
	end

	local count = 0
	for c, rows in pairs(occupancy) do
		for r, _ in pairs(rows) do count += 1 end
	end
	print("[CityBuilder] Occupancy grid: ", count, "cells reserved")
end

--------------------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------------------

local function cellCenter(col, row)
	return GTAConfig.getCellCenter(col, row)
end

local function pickRandom(t)
	if #t == 0 then return nil end
	return t[math.random(1, #t)]
end

local function fillTerrain(position, size, material)
	local region = Region3.new(position - size / 2, position + size / 2):ExpandToGrid(4)
	Workspace.Terrain:FillRegion(region, 4, material)
end

local function placeVehicle(templateName, x, z, rotY)
	local templates = ReplicatedStorage:FindFirstChild("VehicleTemplates")
	if not templates then return nil end
	local template = templates:FindFirstChild(templateName)
	if not template then return nil end
	local clone = template:Clone()
	clone:PivotTo(CFrame.new(x, GROUND_Y + 2, z) * CFrame.Angles(0, math.rad(rotY or 0), 0))
	clone.Parent = vehicleFolder
	return clone
end

--------------------------------------------------------------------------------
-- 1. TERRAIN — island + surrounding ocean
--------------------------------------------------------------------------------

local function buildIslandTerrain()
	local margin = GTAConfig.OCEAN_MARGIN
	local totalW = CITY_W + margin * 2
	local totalD = CITY_D + margin * 2

	-- Ocean (water everywhere at low Y)
	fillTerrain(
		Vector3.new(0, GTAConfig.WATER_LEVEL - 20, 0),
		Vector3.new(totalW, 40, totalD),
		Enum.Material.Water
	)

	-- Island grass (elevated above water)
	fillTerrain(
		Vector3.new(0, GROUND_Y - 10, 0),
		Vector3.new(CITY_W + 100, 20, CITY_D + 100),
		Enum.Material.Grass
	)

	-- Coastline sand on all 4 edges
	local coast = GTAConfig.COASTLINE_WIDTH
	local halfW = CITY_W / 2 + 50
	local halfD = CITY_D / 2 + 50

	-- North coast
	fillTerrain(Vector3.new(0, GROUND_Y - 6, -halfD), Vector3.new(CITY_W + 100, 12, coast), Enum.Material.Sand)
	-- South coast
	fillTerrain(Vector3.new(0, GROUND_Y - 6, halfD), Vector3.new(CITY_W + 100, 12, coast), Enum.Material.Sand)
	-- West coast
	fillTerrain(Vector3.new(-halfW, GROUND_Y - 6, 0), Vector3.new(coast, 12, CITY_D + 100), Enum.Material.Sand)
	-- East coast
	fillTerrain(Vector3.new(halfW, GROUND_Y - 6, 0), Vector3.new(coast, 12, CITY_D + 100), Enum.Material.Sand)

	print("[CityBuilder] Island terrain built")
end

--------------------------------------------------------------------------------
-- 2. WATER CHANNEL (canal between central & south districts)
--------------------------------------------------------------------------------

local function buildWaterChannel()
	local chanZ = ORIGIN_Z + GTAConfig.WATER_CHANNEL_Z_ROW * CELL_SIZE
	local chanW = GTAConfig.WATER_CHANNEL_WIDTH

	-- Dig out grass and fill with water
	fillTerrain(
		Vector3.new(0, GROUND_Y - 8, chanZ),
		Vector3.new(CITY_W - CELL_SIZE * 2, 16, chanW),
		Enum.Material.Air
	)
	fillTerrain(
		Vector3.new(0, GTAConfig.WATER_LEVEL - 4, chanZ),
		Vector3.new(CITY_W - CELL_SIZE * 2, 8, chanW),
		Enum.Material.Water
	)

	print("[CityBuilder] Water channel built")
end

--------------------------------------------------------------------------------
-- 3. ROADS — grid of streets + highway ring
--------------------------------------------------------------------------------

local function createRoadPart(x, z, sizeX, sizeZ, parent)
	local road = Instance.new("Part")
	road.Name = "Road"
	road.Anchored = true
	road.Material = Enum.Material.Asphalt
	road.Color = Color3.fromRGB(45, 45, 50)
	road.TopSurface = Enum.SurfaceType.Smooth
	road.BottomSurface = Enum.SurfaceType.Smooth
	road.Size = Vector3.new(sizeX, 0.2, sizeZ)
	road.Position = Vector3.new(x, GROUND_Y + 0.1, z)
	road.Parent = parent
	return road
end

local function createSidewalk(x, z, sizeX, sizeZ, parent)
	local sw = Instance.new("Part")
	sw.Name = "Sidewalk"
	sw.Anchored = true
	sw.Material = Enum.Material.Concrete
	sw.Color = Color3.fromRGB(170, 165, 155)
	sw.TopSurface = Enum.SurfaceType.Smooth
	sw.BottomSurface = Enum.SurfaceType.Smooth
	sw.Size = Vector3.new(sizeX, 0.4, sizeZ)
	sw.Position = Vector3.new(x, GROUND_Y + 0.05, z)
	sw.Parent = parent
end

local function createLaneMarkings(x, z, length, direction, parent)
	local DASH_LEN = 4
	local DASH_GAP = 6
	local count = math.floor(length / (DASH_LEN + DASH_GAP))

	for i = 0, count - 1 do
		local mark = Instance.new("Part")
		mark.Name = "LaneMark"
		mark.Anchored = true
		mark.CanCollide = false
		mark.Material = Enum.Material.SmoothPlastic
		mark.Color = Color3.fromRGB(220, 210, 160)
		mark.TopSurface = Enum.SurfaceType.Smooth
		mark.BottomSurface = Enum.SurfaceType.Smooth

		local offset = -length / 2 + i * (DASH_LEN + DASH_GAP) + DASH_LEN / 2

		if direction == "z" then
			mark.Size = Vector3.new(0.3, 0.05, DASH_LEN)
			mark.Position = Vector3.new(x, GROUND_Y + 0.22, z + offset)
		else
			mark.Size = Vector3.new(DASH_LEN, 0.05, 0.3)
			mark.Position = Vector3.new(x + offset, GROUND_Y + 0.22, z)
		end
		mark.Parent = parent
	end
end

local function buildRoads(roadFolder)
	local extra = 60  -- extend roads past grid edge

	-- Determine which rows/cols are perimeter (highway width)
	local function roadWidth(idx, maxIdx)
		if idx == 0 or idx == maxIdx then
			return GTAConfig.HIGHWAY_WIDTH
		end
		return STREET_WIDTH
	end

	-- Vertical streets (N-S along Z)
	for col = 0, COLS do
		local x = ORIGIN_X + col * CELL_SIZE
		local w = roadWidth(col, COLS)
		createRoadPart(x, 0, w, CITY_D + extra, roadFolder)
		createLaneMarkings(x, 0, CITY_D + extra, "z", roadFolder)
		createSidewalk(x - w / 2 - 2, 0, 4, CITY_D + extra, roadFolder)
		createSidewalk(x + w / 2 + 2, 0, 4, CITY_D + extra, roadFolder)
	end

	-- Horizontal streets (E-W along X)
	for row = 0, ROWS do
		local z = ORIGIN_Z + row * CELL_SIZE
		local w = roadWidth(row, ROWS)
		createRoadPart(0, z, CITY_W + extra, w, roadFolder)
		createLaneMarkings(0, z, CITY_W + extra, "x", roadFolder)
		createSidewalk(0, z - w / 2 - 2, CITY_W + extra, 4, roadFolder)
		createSidewalk(0, z + w / 2 + 2, CITY_W + extra, 4, roadFolder)
	end

	print("[CityBuilder] Roads built:", COLS + 1, "vertical,", ROWS + 1, "horizontal")
end

--------------------------------------------------------------------------------
-- 4. RAILWAY (ground-level freight rail N-S through industrial → harbor)
--------------------------------------------------------------------------------

local function buildRailway(roadFolder)
	-- Rail runs at the col-4 boundary (between industrial and other districts)
	local railX = ORIGIN_X + 4 * CELL_SIZE
	-- Place rail track segments every CELL_SIZE along Z
	for row = 0, ROWS - 1 do
		local _, z = cellCenter(4, row)
		DecorCreation.place("railtrack", railX - 8, z, 1)
	end
	print("[CityBuilder] Railway built along col 4")
end

--------------------------------------------------------------------------------
-- 5. ELEVATED METRO (NYC-style, crosses city E-W and N-S)
--------------------------------------------------------------------------------

local function buildElevatedMetro()
	local metroY = GTAConfig.METRO_HEIGHT

	-- E-W metro line at row 4 center (through commercial → downtown → government → residential)
	local ewZ = ORIGIN_Z + 4 * CELL_SIZE + CELL_SIZE / 2
	for col = 0, COLS - 1 do
		local x, _ = cellCenter(col, 4)
		DecorCreation.place("highspeed_track", x, ewZ, 1, metroY)
	end

	-- N-S metro line at col 5 center (through industrial → downtown → waterfront)
	local nsX = ORIGIN_X + 5 * CELL_SIZE + CELL_SIZE / 2
	for row = 0, ROWS - 1 do
		local _, z = cellCenter(5, row)
		DecorCreation.place("highspeed_track", nsX, z, 1, metroY)
	end

	-- Metro stations at key intersections
	local stations = {
		{ col = 1,   row = 4, name = "Commercial" },
		{ col = 4,   row = 4, name = "Downtown Central" },
		{ col = 6.5, row = 4, name = "Government" },
		{ col = 5,   row = 1, name = "Industrial" },
		{ col = 5,   row = 4, name = "Metro Hub" },
		{ col = 5,   row = 7, name = "Waterfront" },
	}
	for _, s in ipairs(stations) do
		local sx, sz = cellCenter(s.col, s.row)
		DecorCreation.place("station_platform", sx, sz, 1, metroY)
	end

	print("[CityBuilder] Elevated metro built with", #stations, "stations")
end

--------------------------------------------------------------------------------
-- 6. BRIDGES (over water channel)
--------------------------------------------------------------------------------

local function buildBridges()
	local chanZ = ORIGIN_Z + GTAConfig.WATER_CHANNEL_Z_ROW * CELL_SIZE

	-- Place bridges where major roads cross the water channel
	for col = 1, COLS - 1, 2 do
		local x = ORIGIN_X + col * CELL_SIZE
		DecorCreation.place("bridge_railings", x, chanZ, 1)
		DecorCreation.place("bridge_pillars", x, chanZ, 1)
	end

	print("[CityBuilder] Bridges built over water channel")
end

--------------------------------------------------------------------------------
-- 7. DISTRICT BUILDING PLACEMENT
--------------------------------------------------------------------------------

-- Place standard block buildings for a district (respects occupancy grid)
local function buildStandardBlocks(districtName)
	local def = GTAConfig.getDistrictDef(districtName)
	if not def then return end

	local pool = GTAConfig.DISTRICT_BUILDINGS[districtName]
	if not pool or #pool == 0 then return end

	-- Keep buildings well inside the block (away from roads at cell edges)
	-- Block is 100 studs, roads at edges. Place at ±20 from center = 40 studs from road.
	local INSET = 20

	local placed = 0
	for col = def.colMin, def.colMax do
		for row = def.rowMin, def.rowMax do
			-- Skip reserved cells (infrastructure, landmarks)
			if not isCellFree(col, row) then continue end

			local cx, cz = cellCenter(col, row)

			-- Quadrant offsets within the block (well inside, not near road edges)
			local offsets = {
				{ -INSET, -INSET },
				{  INSET, -INSET },
				{ -INSET,  INSET },
				{  INSET,  INSET },
			}

			-- Place 2-3 buildings per block (not all 4, for variety/performance)
			local count = math.random(2, 3)
			-- Shuffle offsets
			for i = #offsets, 2, -1 do
				local j = math.random(1, i)
				offsets[i], offsets[j] = offsets[j], offsets[i]
			end

			for i = 1, count do
				local ox, oz = offsets[i][1], offsets[i][2]
				local asset = pickRandom(pool)
				if asset then
					DecorCreation.place(asset, cx + ox, cz + oz, 1)
					placed += 1
				end
			end
		end
	end

	print("[CityBuilder]", districtName, "blocks:", placed, "buildings")
end

--------------------------------------------------------------------------------
-- 8. SPECIAL DISTRICT BUILDERS (landmarks & compounds)
--------------------------------------------------------------------------------

local function buildAirport()
	buildStandardBlocks("airport") -- a few terminal-area buildings

	local cx, cz = GTAConfig.getDistrictCenter("airport")

	-- Runway lines (long strip across cols 0-3)
	local runwayX = ORIGIN_X + 1.5 * CELL_SIZE + CELL_SIZE / 2
	DecorCreation.place("runwaylines", runwayX, cz, 1.5)
	DecorCreation.place("taxilines", runwayX + CELL_SIZE, cz, 1)

	-- Terminal & tower
	DecorCreation.place("airport_terminal", cx + CELL_SIZE, cz, 1)
	DecorCreation.place("airport_tower", cx + CELL_SIZE + 50, cz - 40, 1)

	-- Parked jumbo jet on runway
	placeVehicle("JumboJet_AF1", runwayX, cz, 0)

	-- Parking garage near terminal
	DecorCreation.place("parking_garage", cx + CELL_SIZE * 1.5, cz + CELL_SIZE / 2, 1)

	print("[CityBuilder] Airport district built")
end

local function buildIndustrial()
	buildStandardBlocks("industrial")

	local def = GTAConfig.getDistrictDef("industrial")
	local cx, cz = GTAConfig.getDistrictCenter("industrial")

	-- Key landmarks spread across district
	DecorCreation.place("power_plant", cx - CELL_SIZE, cz - CELL_SIZE / 2, 1)
	DecorCreation.place("nuclear_plant", cx + CELL_SIZE, cz - CELL_SIZE, 1)
	DecorCreation.place("water_plant", cx, cz + CELL_SIZE, 1)
	DecorCreation.place("junkyard", cx - CELL_SIZE / 2, cz + CELL_SIZE / 2, 1)
	DecorCreation.place("junk_cars", cx + CELL_SIZE / 2, cz + CELL_SIZE, 1)

	print("[CityBuilder] Industrial district built")
end

local function buildMilitary()
	local cx, cz = GTAConfig.getDistrictCenter("military")

	-- Military base compound (fills most of the district)
	DecorCreation.place("military_base", cx, cz, 1)
	DecorCreation.place("command_center", cx + 40, cz - 40, 1)

	-- Watchtowers at corners
	local def = GTAConfig.getDistrictDef("military")
	local topLeft_x = ORIGIN_X + def.colMin * CELL_SIZE + 20
	local topLeft_z = ORIGIN_Z + def.rowMin * CELL_SIZE + 20
	local botRight_x = ORIGIN_X + (def.colMax + 1) * CELL_SIZE - 20
	local botRight_z = ORIGIN_Z + (def.rowMax + 1) * CELL_SIZE - 20

	DecorCreation.place("watchtower", topLeft_x, topLeft_z, 1)
	DecorCreation.place("watchtower", botRight_x, topLeft_z, 1)
	DecorCreation.place("watchtower", topLeft_x, botRight_z, 1)
	DecorCreation.place("watchtower", botRight_x, botRight_z, 1)

	-- Warning signs along edges
	DecorCreation.place("military_warning", cx - 60, cz, 1)
	DecorCreation.place("military_warning", cx + 60, cz, 1)
	DecorCreation.place("military_warning", cx, cz - 60, 1)
	DecorCreation.place("military_warning", cx, cz + 60, 1)

	print("[CityBuilder] Military district built")
end

local function buildPrison()
	local cx, cz = GTAConfig.getDistrictCenter("prison")

	-- Prison compound
	DecorCreation.place("prison_building", cx, cz, 1)

	-- Prison towers at corners
	local def = GTAConfig.getDistrictDef("prison")
	local x1 = ORIGIN_X + def.colMin * CELL_SIZE + 15
	local z1 = ORIGIN_Z + def.rowMin * CELL_SIZE + 15
	local x2 = ORIGIN_X + (def.colMax + 1) * CELL_SIZE - 15
	local z2 = ORIGIN_Z + (def.rowMax + 1) * CELL_SIZE - 15

	DecorCreation.place("prison_tower", x1, z1, 1)
	DecorCreation.place("prison_tower", x2, z1, 1)
	DecorCreation.place("prison_tower", x1, z2, 1)
	DecorCreation.place("prison_tower", x2, z2, 1)

	-- Prison fence runs (N-S on east and west edges)
	DecorCreation.createPrisonFenceRun(x1, z1, z2)
	DecorCreation.createPrisonFenceRun(x2, z1, z2)

	-- Burning barrels in yard
	DecorCreation.place("burning_barrel", cx - 15, cz + 10, 1)
	DecorCreation.place("burning_barrel", cx + 15, cz - 10, 1)

	print("[CityBuilder] Prison district built")
end

local function buildCommercial()
	buildStandardBlocks("commercial")

	local cx, cz = GTAConfig.getDistrictCenter("commercial")

	-- Extra shops & parking
	DecorCreation.place("parking_garage", cx + CELL_SIZE, cz + CELL_SIZE, 1)
	DecorCreation.place("billboard", cx - CELL_SIZE / 2, cz - CELL_SIZE, 1)
	DecorCreation.place("billboard", cx + CELL_SIZE, cz, 1)

	print("[CityBuilder] Commercial district built")
end

local function buildDowntown()
	buildStandardBlocks("downtown")

	local cx, cz = GTAConfig.getDistrictCenter("downtown")

	-- Extra skyscrapers for skyline density
	DecorCreation.place("skyscraper", cx - 30, cz - 30, 1)
	DecorCreation.place("skyscraper", cx + 30, cz + 30, 1)

	-- Glass cube flagship store
	DecorCreation.place("glass_cube_store", cx, cz - CELL_SIZE / 2, 1)

	-- Central fountain
	DecorCreation.place("fountain", cx, cz, 1)

	print("[CityBuilder] Downtown district built")
end

local function buildGovernment()
	local cx, cz = GTAConfig.getDistrictCenter("government")

	-- White House compound (center of district)
	DecorCreation.place("whitehouse", cx, cz, 1)

	-- Washington Monument (east of White House)
	DecorCreation.place("washington_monument", cx + CELL_SIZE * 0.7, cz, 1)

	-- National Mall (south of White House)
	DecorCreation.place("national_mall", cx, cz + CELL_SIZE * 0.8, 1)

	-- Fountain in front of White House
	DecorCreation.place("fountain", cx, cz - 40, 1)

	-- Government buildings around the compound edges (only in free cells)
	local def = GTAConfig.getDistrictDef("government")
	local pool = GTAConfig.DISTRICT_BUILDINGS["government"]
	for col = def.colMin, def.colMax do
		for row = def.rowMin, def.rowMax do
			if isCellFree(col, row) then
				local bx, bz = cellCenter(col, row)
				local asset = pickRandom(pool)
				if asset then
					DecorCreation.place(asset, bx, bz, 1)
				end
			end
		end
	end

	print("[CityBuilder] Government district built")
end

local function buildResidential()
	buildStandardBlocks("residential")

	local cx, cz = GTAConfig.getDistrictCenter("residential")

	-- Park
	DecorCreation.place("park", cx, cz - CELL_SIZE / 2, 1)

	-- Basketball courts
	DecorCreation.place("basketball_court", cx - CELL_SIZE / 2, cz + CELL_SIZE / 2, 1)
	DecorCreation.place("basketball_court", cx + CELL_SIZE / 2, cz + CELL_SIZE / 2, 1)

	-- Mansions on the north edge
	local def = GTAConfig.getDistrictDef("residential")
	for col = def.colMin, def.colMax do
		local mx, mz = cellCenter(col, def.rowMin)
		DecorCreation.place("mansion", mx, mz, 1)
	end

	print("[CityBuilder] Residential district built")
end

local function buildHarbor()
	buildStandardBlocks("harbor")

	local cx, cz = GTAConfig.getDistrictCenter("harbor")

	-- Train station
	DecorCreation.place("station_hall", cx, cz - CELL_SIZE / 2, 1)
	DecorCreation.place("station_platform", cx, cz - CELL_SIZE / 2 + 25, 1)

	-- Dock buildings along waterfront
	for i = -1, 1 do
		DecorCreation.place("dock_building", cx + i * CELL_SIZE * 0.8, cz + CELL_SIZE, 1)
	end

	print("[CityBuilder] Harbor district built")
end

local function buildWaterfront()
	buildStandardBlocks("waterfront")

	local cx, cz = GTAConfig.getDistrictCenter("waterfront")

	-- Miami-style buildings along the water edge
	local def = GTAConfig.getDistrictDef("waterfront")
	for col = def.colMin, def.colMax do
		local mx, mz = cellCenter(col, def.rowMax)
		DecorCreation.place("miami_building", mx, mz, 1)
	end

	-- Bridges along waterfront
	DecorCreation.place("bridge_railings", cx, cz + CELL_SIZE, 1)

	-- Fountain promenade
	DecorCreation.place("fountain", cx, cz, 1)
	DecorCreation.place("fountain", cx + CELL_SIZE, cz, 1)

	print("[CityBuilder] Waterfront district built")
end

local function buildBeach()
	buildStandardBlocks("beach")

	local cx, cz = GTAConfig.getDistrictCenter("beach")

	-- Golf course
	DecorCreation.place("golf_course", cx, cz, 1)

	-- Beach sand terrain
	local def = GTAConfig.getDistrictDef("beach")
	local bx1 = ORIGIN_X + def.colMin * CELL_SIZE
	local bz1 = ORIGIN_Z + def.rowMin * CELL_SIZE
	local bx2 = ORIGIN_X + (def.colMax + 1) * CELL_SIZE
	local bz2 = ORIGIN_Z + (def.rowMax + 1) * CELL_SIZE
	local sandCX = (bx1 + bx2) / 2
	local sandCZ = (bz1 + bz2) / 2
	fillTerrain(
		Vector3.new(sandCX, GROUND_Y - 4, sandCZ),
		Vector3.new(bx2 - bx1, 8, bz2 - bz1),
		Enum.Material.Sand
	)

	-- Extra palm trees
	for i = 1, 6 do
		DecorCreation.place("tree", cx + math.random(-80, 80), cz + math.random(-80, 80), 1)
	end

	print("[CityBuilder] Beach district built")
end

local function buildSpace()
	local cx, cz = GTAConfig.getDistrictCenter("space")

	-- Shuttle launchpad (center)
	DecorCreation.place("shuttle_launchpad", cx, cz, 1)

	-- Crashed UFO (easter egg, offset)
	DecorCreation.place("crashed_ufo", cx + 50, cz + 40, 1)

	-- Warning signs around the perimeter
	DecorCreation.place("military_warning", cx - 50, cz, 1)
	DecorCreation.place("military_warning", cx + 50, cz, 1)
	DecorCreation.place("military_warning", cx, cz - 60, 1)
	DecorCreation.place("military_warning", cx, cz + 60, 1)

	-- Watchtower
	DecorCreation.place("watchtower", cx - 40, cz - 40, 1)

	print("[CityBuilder] Space district built")
end

--------------------------------------------------------------------------------
-- 9. STREET FURNITURE (lamps, trees, etc. per district)
--------------------------------------------------------------------------------

local function buildStreetFurniture()
	local placed = 0

	for col = 0, COLS do
		for row = 0, ROWS do
			local x = ORIGIN_X + col * CELL_SIZE
			local z = ORIGIN_Z + row * CELL_SIZE
			local district = GTAConfig.getDistrict(math.min(col, COLS - 1), math.min(row, ROWS - 1))
			local pool = GTAConfig.DISTRICT_DECOR[district]

			-- Lamps at intersection corners
			DecorCreation.place("lamp", x + STREET_WIDTH / 2 + 3, z + STREET_WIDTH / 2 + 3, 1)
			DecorCreation.place("lamp", x - STREET_WIDTH / 2 - 3, z + STREET_WIDTH / 2 + 3, 1)
			placed += 2

			-- District-specific decor (chance-based, every other intersection)
			if pool and #pool > 0 and (col + row) % 2 == 0 then
				local asset = pickRandom(pool)
				if asset and asset ~= "lamp" then
					DecorCreation.place(asset, x + STREET_WIDTH / 2 + 8, z + 15, 1)
					placed += 1
				end
			end

			-- Trees along sidewalks (every 2nd intersection)
			if col % 2 == 0 and row % 2 == 0 then
				DecorCreation.place("tree", x + STREET_WIDTH / 2 + 6, z + 15, 1)
				DecorCreation.place("tree", x - STREET_WIDTH / 2 - 6, z - 15, 1)
				placed += 2
			end
		end
	end

	print("[CityBuilder] Street furniture placed:", placed, "items")
end

--------------------------------------------------------------------------------
-- 10. VEHICLE PLACEMENT (parked vehicles per district)
--------------------------------------------------------------------------------

local function placeDistrictVehicles()
	local count = 0

	for _, d in ipairs(GTAConfig.DISTRICTS) do
		local pool = GTAConfig.DISTRICT_VEHICLES[d.name]
		if not pool or #pool == 0 then continue end

		-- Place 2-4 vehicles per district along streets
		local numVehicles = math.random(2, 4)
		for i = 1, numVehicles do
			local col = math.random(d.colMin, d.colMax)
			local row = math.random(d.rowMin, d.rowMax)
			local cx, cz = cellCenter(col, row)

			-- Park on the street side (offset from block center)
			local side = (i % 2 == 0) and 1 or -1
			local px = cx + side * (BLOCK_SIZE / 2 + 4)
			local pz = cz + math.random(-20, 20)

			local template = pickRandom(pool)
			if template then
				local rotY = (side > 0) and 90 or -90
				if placeVehicle(template, px, pz, rotY) then
					count += 1
				end
			end
		end
	end

	print("[CityBuilder] Parked vehicles placed:", count)
end

--------------------------------------------------------------------------------
-- PUBLIC API
--------------------------------------------------------------------------------

function CityBuilder.build(decorFolderRef, vehicleFolderRef, npcFolderRef)
	-- Store refs
	vehicleFolder = vehicleFolderRef
	DecorUtils.decorFolder = decorFolderRef

	-- Create road folder
	local worldFolder = Workspace:FindFirstChild("World") or Workspace
	local roadFolder = Instance.new("Folder")
	roadFolder.Name = "Roads"
	roadFolder.Parent = worldFolder

	-- 1. Terrain (island + ocean)
	buildIslandTerrain()

	-- 2. Water channel
	buildWaterChannel()

	-- 3. Roads
	buildRoads(roadFolder)

	-- 4. Railway
	buildRailway(roadFolder)

	-- 5. Elevated metro
	buildElevatedMetro()

	-- 6. Bridges over water channel
	buildBridges()

	-- 7. Reserve infrastructure cells BEFORE placing buildings
	reserveInfrastructure()

	-- 8. Districts (special first, then standard blocks)
	buildAirport()
	buildIndustrial()
	buildMilitary()
	buildPrison()
	buildCommercial()
	buildDowntown()
	buildGovernment()
	buildResidential()
	buildHarbor()
	buildWaterfront()
	buildBeach()
	buildSpace()

	-- 9. Street furniture
	buildStreetFurniture()

	-- 10. Parked vehicles
	placeDistrictVehicles()

	print("[CityBuilder] === Full island build complete! ===")
end

return CityBuilder
