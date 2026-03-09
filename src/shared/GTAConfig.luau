-- GTAConfig.luau
-- Full GTA island world configuration: grid, districts, lanes, pools.

local GTAConfig = {}

--------------------------------------------------------------------------------
-- WORLD GRID
--------------------------------------------------------------------------------

GTAConfig.BLOCK_SIZE   = 100     -- building block footprint (studs)
GTAConfig.STREET_WIDTH = 24      -- standard road width
GTAConfig.HIGHWAY_WIDTH = 36     -- highway / ring-road width
GTAConfig.CELL_SIZE    = 124     -- BLOCK_SIZE + STREET_WIDTH
GTAConfig.GRID_COLS    = 12      -- city columns
GTAConfig.GRID_ROWS    = 9       -- city rows
GTAConfig.GROUND_Y     = 4       -- terrain surface
GTAConfig.METRO_HEIGHT = 22      -- elevated metro track Y

-- Total city extents
GTAConfig.CITY_WIDTH = GTAConfig.CELL_SIZE * GTAConfig.GRID_COLS   -- 1488
GTAConfig.CITY_DEPTH = GTAConfig.CELL_SIZE * GTAConfig.GRID_ROWS   -- 1116

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

-- Water channel (east-west canal between central & south rows)
GTAConfig.WATER_CHANNEL_Z_ROW = 5.5   -- between row 5 and row 6
GTAConfig.WATER_CHANNEL_WIDTH = 36

--------------------------------------------------------------------------------
-- PLAYER SPAWN  (downtown center)
--------------------------------------------------------------------------------

-- Downtown = cols 3-6, rows 3-5 → center col 4.5, row 4
local _spawnX = -GTAConfig.CITY_WIDTH / 2 + 4.5 * GTAConfig.CELL_SIZE + GTAConfig.CELL_SIZE / 2
local _spawnZ = -GTAConfig.CITY_DEPTH / 2 + 4 * GTAConfig.CELL_SIZE + GTAConfig.CELL_SIZE / 2
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
-- DISTRICTS  (15 districts on a 12×9 grid)
-- colMin/colMax & rowMin/rowMax are inclusive block indices.
-- color is for the minimap overlay.
--------------------------------------------------------------------------------

GTAConfig.DISTRICTS = {
	-- Row 0-2 (North — airport, industry, utilities, restricted)
	{ colMin = 0,  colMax = 3,  rowMin = 0, rowMax = 2, name = "airport",      color = Color3.fromRGB(150, 150, 150) },
	{ colMin = 4,  colMax = 6,  rowMin = 0, rowMax = 2, name = "industrial",   color = Color3.fromRGB(140, 120, 90)  },
	{ colMin = 7,  colMax = 8,  rowMin = 0, rowMax = 2, name = "power_plant",  color = Color3.fromRGB(220, 160, 40)  },
	{ colMin = 9,  colMax = 10, rowMin = 0, rowMax = 2, name = "military",     color = Color3.fromRGB(80, 100, 60)   },
	{ colMin = 11, colMax = 11, rowMin = 0, rowMax = 2, name = "nuclear",      color = Color3.fromRGB(80, 200, 60)   },

	-- Row 3-5 (Central — city core)
	{ colMin = 0,  colMax = 2,  rowMin = 3, rowMax = 5, name = "commercial",   color = Color3.fromRGB(200, 180, 100) },
	{ colMin = 3,  colMax = 6,  rowMin = 3, rowMax = 5, name = "downtown",     color = Color3.fromRGB(100, 140, 200) },
	{ colMin = 7,  colMax = 8,  rowMin = 3, rowMax = 5, name = "government",   color = Color3.fromRGB(220, 220, 220) },
	{ colMin = 9,  colMax = 9,  rowMin = 3, rowMax = 5, name = "prison",       color = Color3.fromRGB(100, 100, 100) },
	{ colMin = 10, colMax = 11, rowMin = 3, rowMax = 5, name = "residential",  color = Color3.fromRGB(160, 200, 140) },

	-- Row 6-8 (South — coastal)
	{ colMin = 0,  colMax = 2,  rowMin = 6, rowMax = 8, name = "harbor",       color = Color3.fromRGB(120, 100, 80)  },
	{ colMin = 3,  colMax = 4,  rowMin = 6, rowMax = 8, name = "water_plant",  color = Color3.fromRGB(60, 160, 200)  },
	{ colMin = 5,  colMax = 7,  rowMin = 6, rowMax = 8, name = "waterfront",   color = Color3.fromRGB(100, 180, 200) },
	{ colMin = 8,  colMax = 9,  rowMin = 6, rowMax = 8, name = "beach",        color = Color3.fromRGB(240, 220, 160) },
	{ colMin = 10, colMax = 11, rowMin = 6, rowMax = 8, name = "space",        color = Color3.fromRGB(60, 60, 80)    },
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
-- HELPERS
--------------------------------------------------------------------------------

-- Lookup district name for a grid cell
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

return GTAConfig
