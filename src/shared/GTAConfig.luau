-- GTAConfig.luau
-- Full GTA island world configuration: grid, lane-zone architecture, districts, pools.

local GTAConfig = {}

--------------------------------------------------------------------------------
-- WORLD GRID
--------------------------------------------------------------------------------

GTAConfig.BLOCK_SIZE   = 140     -- building block footprint (studs)
GTAConfig.STREET_WIDTH = 40      -- standard road width
GTAConfig.HIGHWAY_WIDTH = 50     -- highway / ring-road width
GTAConfig.CELL_SIZE    = 180     -- BLOCK_SIZE + STREET_WIDTH
GTAConfig.GRID_COLS    = 14      -- city columns
GTAConfig.GRID_ROWS    = 10      -- city rows
GTAConfig.GROUND_Y     = 4       -- terrain surface
GTAConfig.METRO_HEIGHT = 22      -- elevated metro track Y

-- Total city extents
GTAConfig.CITY_WIDTH = GTAConfig.CELL_SIZE * GTAConfig.GRID_COLS   -- 2520
GTAConfig.CITY_DEPTH = GTAConfig.CELL_SIZE * GTAConfig.GRID_ROWS   -- 1800

-- City origin (top-left corner of grid — city centered)
GTAConfig.CITY_ORIGIN_X = -GTAConfig.CITY_WIDTH / 2
GTAConfig.CITY_ORIGIN_Z = -GTAConfig.CITY_DEPTH / 2

--------------------------------------------------------------------------------
-- WATER / OCEAN  (island surrounded by water)
--------------------------------------------------------------------------------

GTAConfig.WATER_LEVEL      = -2
GTAConfig.OCEAN_MARGIN     = 400   -- water ring around island
GTAConfig.COASTLINE_WIDTH  = 30    -- sand transition
GTAConfig.DEEP_SEA_Y       = -80

--------------------------------------------------------------------------------
-- PLAYER SPAWN  (downtown center)
--------------------------------------------------------------------------------

-- Downtown = blockRow 2, blockCols 3-5 → center col 5.5, row 4.5
local _spawnX = -GTAConfig.CITY_WIDTH / 2 + 5.5 * GTAConfig.CELL_SIZE + GTAConfig.CELL_SIZE / 2
local _spawnZ = -GTAConfig.CITY_DEPTH / 2 + 4.5 * GTAConfig.CELL_SIZE + GTAConfig.CELL_SIZE / 2
GTAConfig.SPAWN_POSITION = Vector3.new(_spawnX, GTAConfig.GROUND_Y + 5, _spawnZ)

--------------------------------------------------------------------------------
-- VEHICLE SPEEDS (studs / second)
--------------------------------------------------------------------------------

GTAConfig.VEHICLE_SPEEDS = {
	car          = 60,
	motorcycle   = 70,
	bus          = 45,
	truck        = 40,
	monstertruck = 55,
	jetski       = 50,
	speedboat    = 55,
	helicopter   = 80,
	jumbojet     = 120,
	submarine    = 30,
	train        = 65,
	metro        = 50,
}

GTAConfig.TURN_RATE = math.rad(120)

--------------------------------------------------------------------------------
-- LANE-ZONE ARCHITECTURE
-- The world is defined by column edges and row edges. Each edge is a lane zone.
-- The spaces between edges are block zones grouped into districts.
--------------------------------------------------------------------------------

-- Lane types — each has rendering properties for both 3D world and 2D map
GTAConfig.LANE_TYPES = {
	road = {
		width = 40,
		material = Enum.Material.Asphalt,
		color = Color3.fromRGB(45, 45, 50),
		mapColor = Color3.fromRGB(200, 200, 190),
		mapThickness = 3,
		sidewalks = true,
		laneMarkings = true,
	},
	highway = {
		width = 50,
		material = Enum.Material.Asphalt,
		color = Color3.fromRGB(55, 55, 60),
		mapColor = Color3.fromRGB(240, 210, 80),
		mapThickness = 4,
		sidewalks = true,
		laneMarkings = true,
	},
	railway = {
		width = 40,
		material = Enum.Material.Pebble,
		color = Color3.fromRGB(120, 110, 95),
		mapColor = Color3.fromRGB(139, 69, 19),
		mapThickness = 6,
		rails = true,
		bufferStops = true,
	},
	water = {
		width = 50,
		material = Enum.Material.Water,
		color = Color3.fromRGB(40, 130, 210),
		mapColor = Color3.fromRGB(40, 130, 210),
		mapThickness = 0, -- uses real width on map
		bridges = true,
	},
	elevated_highway = {
		width = 50,
		material = Enum.Material.Concrete,
		color = Color3.fromRGB(150, 145, 135),
		mapColor = Color3.fromRGB(255, 140, 40),
		mapThickness = 5,
		elevated = true,
		height = 14,
		barriers = true,
		ramps = true,
	},
	metro = {
		width = 14,
		material = Enum.Material.Concrete,
		color = Color3.fromRGB(160, 155, 145),
		mapColor = Color3.fromRGB(0, 200, 255),
		mapThickness = 3,
		elevated = true,
		height = 22,
		rails = true,
		bufferStops = true,
	},
}

--------------------------------------------------------------------------------
-- EDGES: Column edges and Row edges define the grid skeleton
--------------------------------------------------------------------------------

-- Column edges — union of all district boundaries: {0, 3, 4, 6, 7, 8, 9, 10, 12, 14}
-- Each edge is at column * CELL_SIZE offset from CITY_ORIGIN_X
GTAConfig.COL_EDGES = { 0, 3, 4, 6, 7, 8, 9, 10, 12, 14 }

-- Row edges — zone separators (major band boundaries): {0, 3, 7, 10}
GTAConfig.ROW_EDGES = { 0, 3, 7, 10 }

-- All row boundaries (every cell row) for the full road grid
GTAConfig.ALL_ROW_EDGES = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }

--------------------------------------------------------------------------------
-- LANE ASSIGNMENTS
-- H_LANES: horizontal lanes at row boundaries (roads + special lanes)
-- V_LANES: vertical lanes at column edges
--------------------------------------------------------------------------------

-- Horizontal lanes — FULL GRID: road at every cell row boundary + special lanes
GTAConfig.H_LANES = {
	-- North perimeter
	{ row = 0,  type = "highway" },
	-- Internal North band roads
	{ row = 1,  type = "road" },
	{ row = 2,  type = "road" },
	-- North/Central separator
	{ row = 3,  type = "railway" },
	-- Internal Central band roads
	{ row = 4,  type = "road" },
	{ row = 5,  type = "road" },
	{ row = 6,  type = "road" },
	-- Central/South separator
	{ row = 7,  type = "water" },
	-- Internal South band roads
	{ row = 8,  type = "road" },
	{ row = 9,  type = "road" },
	-- South perimeter
	{ row = 10, type = "elevated_highway" },
}

-- Vertical lanes — keyed by column edge value
-- Each entry: { col = <col edge>, type = <lane type name> }
GTAConfig.V_LANES = {
	{ col = 0,  type = "highway" },   -- west perimeter
	{ col = 3,  type = "road" },
	{ col = 4,  type = "road" },
	{ col = 6,  type = "road" },
	{ col = 7,  type = "road" },
	{ col = 8,  type = "road" },
	{ col = 9,  type = "road" },
	{ col = 10, type = "road" },
	{ col = 12, type = "road" },
	{ col = 14, type = "highway" },   -- east perimeter
}

-- Overlay lanes — pass THROUGH bands, not separators
GTAConfig.OVERLAY_LANES = {
	{
		type = "metro",
		direction = "horizontal",
		position = 4.5, -- row 4.5 (center of cell row 4, in central band)
		stations = {
			{ col = 2,  name = "Airport" },
			{ col = 5,  name = "Downtown" },
			{ col = 8,  name = "Government" },
			{ col = 11, name = "Residential" },
			{ col = 13, name = "East End" },
		},
	},
}

--------------------------------------------------------------------------------
-- INTERSECTION RULES
-- What happens when an H-lane crosses a V-lane
--------------------------------------------------------------------------------

-- Keyed by "hType_vType" → result action
GTAConfig.INTERSECTION_RULES = {
	-- road crossings
	road_road             = "intersection",
	road_highway          = "intersection",
	highway_road          = "intersection",
	highway_highway       = "continue",    -- perimeter corners

	-- water crossings → bridges
	water_road            = "bridge",
	water_highway         = "bridge",

	-- railway crossings → level crossing
	railway_road          = "crossing",
	railway_highway       = "crossing",

	-- elevated lanes fly over everything
	elevated_highway_road    = "flyover",
	elevated_highway_highway = "flyover",
}

-- Elevated highway ramp positions (col edges where ramps connect to ground)
GTAConfig.ELEVATED_RAMPS = { 3, 10 }

--------------------------------------------------------------------------------
-- DISTRICTS (15 districts — now using blockRow/blockCol ranges)
-- blockRow: 1=North(rows 0-2), 2=Central(rows 3-6), 3=South(rows 7-9)
-- blockColMin/blockColMax: indices into block-columns between COL_EDGES
-- Block-columns: 1(0→3), 2(3→4), 3(4→6), 4(6→7), 5(7→8), 6(8→9), 7(9→10), 8(10→12), 9(12→14)
--
-- We ALSO keep colMin/colMax/rowMin/rowMax for backward compatibility with
-- DecorCreation, WorldLoader, and other systems that use cell coordinates.
--------------------------------------------------------------------------------

GTAConfig.DISTRICTS = {
	-- Row 0-2 (North — airport, industry, utilities, restricted)
	{ blockRow = 1, blockColMin = 1, blockColMax = 2, colMin = 0,  colMax = 3,  rowMin = 0, rowMax = 2, name = "airport",      color = Color3.fromRGB(150, 150, 150) },
	{ blockRow = 1, blockColMin = 3, blockColMax = 4, colMin = 4,  colMax = 6,  rowMin = 0, rowMax = 2, name = "industrial",   color = Color3.fromRGB(140, 120, 90)  },
	{ blockRow = 1, blockColMin = 5, blockColMax = 7, colMin = 7,  colMax = 9,  rowMin = 0, rowMax = 2, name = "power_plant",  color = Color3.fromRGB(220, 160, 40)  },
	{ blockRow = 1, blockColMin = 8, blockColMax = 8, colMin = 10, colMax = 11, rowMin = 0, rowMax = 2, name = "military",     color = Color3.fromRGB(80, 100, 60)   },
	{ blockRow = 1, blockColMin = 9, blockColMax = 9, colMin = 12, colMax = 13, rowMin = 0, rowMax = 2, name = "nuclear",      color = Color3.fromRGB(80, 200, 60)   },

	-- Row 3-6 (Central — city core)
	{ blockRow = 2, blockColMin = 1, blockColMax = 2, colMin = 0,  colMax = 3,  rowMin = 3, rowMax = 6, name = "commercial",   color = Color3.fromRGB(200, 180, 100) },
	{ blockRow = 2, blockColMin = 3, blockColMax = 5, colMin = 4,  colMax = 7,  rowMin = 3, rowMax = 6, name = "downtown",     color = Color3.fromRGB(100, 140, 200) },
	{ blockRow = 2, blockColMin = 6, blockColMax = 7, colMin = 8,  colMax = 9,  rowMin = 3, rowMax = 6, name = "government",   color = Color3.fromRGB(220, 220, 220) },
	{ blockRow = 2, blockColMin = 8, blockColMax = 8, colMin = 10, colMax = 11, rowMin = 3, rowMax = 6, name = "prison",       color = Color3.fromRGB(100, 100, 100) },
	{ blockRow = 2, blockColMin = 9, blockColMax = 9, colMin = 12, colMax = 13, rowMin = 3, rowMax = 6, name = "residential",  color = Color3.fromRGB(160, 200, 140) },

	-- Row 7-9 (South — coastal)
	{ blockRow = 3, blockColMin = 1, blockColMax = 2, colMin = 0,  colMax = 2,  rowMin = 7, rowMax = 9, name = "harbor",       color = Color3.fromRGB(120, 100, 80)  },
	{ blockRow = 3, blockColMin = 3, blockColMax = 4, colMin = 3,  colMax = 5,  rowMin = 7, rowMax = 9, name = "water_plant",  color = Color3.fromRGB(60, 160, 200)  },
	{ blockRow = 3, blockColMin = 5, blockColMax = 6, colMin = 6,  colMax = 8,  rowMin = 7, rowMax = 9, name = "waterfront",   color = Color3.fromRGB(100, 180, 200) },
	{ blockRow = 3, blockColMin = 7, blockColMax = 8, colMin = 9,  colMax = 11, rowMin = 7, rowMax = 9, name = "beach",        color = Color3.fromRGB(240, 220, 160) },
	{ blockRow = 3, blockColMin = 9, blockColMax = 9, colMin = 12, colMax = 13, rowMin = 7, rowMax = 9, name = "space",        color = Color3.fromRGB(60, 60, 80)    },
}

-- Building pools per district (asset names matching DecorCreation PROCEDURAL_BUILDERS)
GTAConfig.DISTRICT_BUILDINGS = {
	airport      = { "building", "building2" },
	industrial   = { "factory", "warehouse", "construction_site" },
	power_plant  = {},  -- compound
	nuclear      = {},  -- compound
	military     = {},  -- compound
	prison       = {},  -- compound
	commercial   = { "shop", "shop_luxury", "glass_cube_store", "building", "parking_garage" },
	downtown     = { "skyscraper", "building", "building2", "building3", "glass_cube_store" },
	government   = { "building", "building2", "building3" },
	residential  = { "hood_building", "mansion", "building" },
	harbor       = { "dock_building", "warehouse", "building" },
	water_plant  = {},  -- compound
	waterfront   = { "miami_building", "building", "shop" },
	beach        = { "miami_building" },
	space        = {},  -- compound
}

-- Street decor pools
GTAConfig.DISTRICT_DECOR = {
	airport      = { "lamp", "billboard" },
	industrial   = { "lamp", "junk_car", "burning_barrel", "billboard" },
	power_plant  = { "lamp", "military_warning" },
	nuclear      = { "lamp", "military_warning" },
	military     = { "military_warning", "lamp" },
	prison       = { "lamp" },
	commercial   = { "lamp", "tree", "billboard", "fountain" },
	downtown     = { "lamp", "tree", "billboard", "fountain" },
	government   = { "lamp", "tree", "fountain" },
	residential  = { "lamp", "tree", "burning_barrel" },
	harbor       = { "lamp" },
	water_plant  = { "lamp" },
	waterfront   = { "lamp", "tree", "fountain" },
	beach        = { "tree", "lamp" },
	space        = { "lamp", "military_warning" },
}

-- Parked vehicle templates per district
GTAConfig.DISTRICT_VEHICLES = {
	airport      = { "Taxi_1" },
	industrial   = { "SemiTruck_Red_1", "HazmatTruck_1", "Forklift_1", "WaterTanker_1" },
	power_plant  = { "HazmatTruck_1" },
	nuclear      = { "HazmatTruck_1" },
	military     = { "Jeep_Military_1" },
	prison       = { "PoliceCar_1" },
	commercial   = { "Taxi_1", "Sedan_Red_1", "UrbanBus_1", "DeliveryVan_White_1" },
	downtown     = { "Sedan_Black_1", "SUV_Black_1", "Taxi_1", "DoubleDecker_1" },
	government   = { "SUV_Escort_1", "PoliceCar_1" },
	residential  = { "Sedan_Blue_1", "Wagon_White_1", "SchoolBus_1", "Crossover_White_1" },
	harbor       = { "SemiTruck_Blue_2" },
	water_plant  = { "WaterTanker_1" },
	waterfront   = { "Sedan_Silver_1", "Convertible_1" },
	beach        = { "GolfCart_1", "Monstertruck_Yellow" },
	space        = { "NasaRover_1" },
}

--------------------------------------------------------------------------------
-- COMPOUND ZONES (no internal roads — one big open block)
--------------------------------------------------------------------------------

GTAConfig.COMPOUND_DISTRICTS = {
	airport = true,
	military = true,
	nuclear = true,
	power_plant = true,
	prison = true,
	space = true,
	water_plant = true,
	beach = true,
}

-- Compound rectangles: world-space rects computed from boundary lane inner edges.
-- Lazy-computed and cached. Used by both server (CityBuilder) and client (MapUI).
local _compoundRects = nil

function GTAConfig.getCompoundRects()
	if _compoundRects then return _compoundRects end
	_compoundRects = {}

	local hLanes = GTAConfig.H_LANES
	local vLanes = GTAConfig.V_LANES

	local function laneWidth(laneType)
		local def = GTAConfig.LANE_TYPES[laneType]
		return def and def.width or GTAConfig.STREET_WIDTH
	end

	for _, d in ipairs(GTAConfig.DISTRICTS) do
		if not GTAConfig.COMPOUND_DISTRICTS[d.name] then continue end

		local leftVCol, leftVW, rightVCol, rightVW = nil, 0, nil, 0
		for _, v in ipairs(vLanes) do
			if v.col <= d.colMin then
				leftVCol = v.col
				leftVW = laneWidth(v.type)
			end
		end
		for _, v in ipairs(vLanes) do
			if v.col >= d.colMax + 1 and not rightVCol then
				rightVCol = v.col
				rightVW = laneWidth(v.type)
			end
		end

		local topHRow, topHW, botHRow, botHW = nil, 0, nil, 0
		for _, h in ipairs(hLanes) do
			if h.row <= d.rowMin then
				topHRow = h.row
				topHW = laneWidth(h.type)
			end
		end
		for _, h in ipairs(hLanes) do
			if h.row >= d.rowMax + 1 and not botHRow then
				botHRow = h.row
				botHW = laneWidth(h.type)
			end
		end

		if not (leftVCol and rightVCol and topHRow and botHRow) then continue end

		local rect = {
			x1 = GTAConfig.getColEdgeX(leftVCol) + leftVW / 2,
			x2 = GTAConfig.getColEdgeX(rightVCol) - rightVW / 2,
			z1 = GTAConfig.getRowEdgeZ(topHRow) + topHW / 2,
			z2 = GTAConfig.getRowEdgeZ(botHRow) - botHW / 2,
			name = d.name,
		}

		if rect.x2 > rect.x1 and rect.z2 > rect.z1 then
			table.insert(_compoundRects, rect)
		end
	end

	return _compoundRects
end

function GTAConfig.isInsideCompound(worldX: number, worldZ: number): boolean
	for _, r in ipairs(GTAConfig.getCompoundRects()) do
		if worldX > r.x1 and worldX < r.x2 and worldZ > r.z1 and worldZ < r.z2 then
			return true
		end
	end
	return false
end

--------------------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------------------

-- Lookup district name for a grid cell (backward compatible)
function GTAConfig.getDistrict(col: number, row: number): string
	for _, d in ipairs(GTAConfig.DISTRICTS) do
		if col >= d.colMin and col <= d.colMax and row >= d.rowMin and row <= d.rowMax then
			return d.name
		end
	end
	return "downtown"
end

-- Lookup full district definition by name
function GTAConfig.getDistrictDef(name: string)
	for _, d in ipairs(GTAConfig.DISTRICTS) do
		if d.name == name then return d end
	end
	return nil
end

-- Cell center in world coordinates
function GTAConfig.getCellCenter(col: number, row: number): (number, number)
	local x = GTAConfig.CITY_ORIGIN_X + col * GTAConfig.CELL_SIZE + GTAConfig.CELL_SIZE / 2
	local z = GTAConfig.CITY_ORIGIN_Z + row * GTAConfig.CELL_SIZE + GTAConfig.CELL_SIZE / 2
	return x, z
end

-- District center in world coordinates
function GTAConfig.getDistrictCenter(name: string): (number, number)
	local d = GTAConfig.getDistrictDef(name)
	if not d then return 0, 0 end
	local midCol = (d.colMin + d.colMax) / 2
	local midRow = (d.rowMin + d.rowMax) / 2
	return GTAConfig.getCellCenter(midCol, midRow)
end

-- Get world X for a column edge
function GTAConfig.getColEdgeX(col: number): number
	return GTAConfig.CITY_ORIGIN_X + col * GTAConfig.CELL_SIZE
end

-- Get world Z for a row edge
function GTAConfig.getRowEdgeZ(row: number): number
	return GTAConfig.CITY_ORIGIN_Z + row * GTAConfig.CELL_SIZE
end

-- Get lane type definition
function GTAConfig.getLaneType(typeName: string)
	return GTAConfig.LANE_TYPES[typeName]
end

-- Get intersection rule for two lane types crossing
function GTAConfig.getIntersectionRule(hType: string, vType: string): string
	return GTAConfig.INTERSECTION_RULES[hType .. "_" .. vType] or "intersection"
end

-- Get the world rect for a block (space between two col edges and two row edges)
-- Returns x1, z1, x2, z2 (top-left to bottom-right)
function GTAConfig.getBlockWorldRect(colEdgeIdx1: number, colEdgeIdx2: number, rowEdgeIdx1: number, rowEdgeIdx2: number)
	local col1 = GTAConfig.COL_EDGES[colEdgeIdx1]
	local col2 = GTAConfig.COL_EDGES[colEdgeIdx2]
	local row1 = GTAConfig.ROW_EDGES[rowEdgeIdx1]
	local row2 = GTAConfig.ROW_EDGES[rowEdgeIdx2]
	local x1 = GTAConfig.getColEdgeX(col1)
	local x2 = GTAConfig.getColEdgeX(col2)
	local z1 = GTAConfig.getRowEdgeZ(row1)
	local z2 = GTAConfig.getRowEdgeZ(row2)
	return x1, z1, x2, z2
end

return GTAConfig
