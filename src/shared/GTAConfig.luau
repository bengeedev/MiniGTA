-- GTAConfig.luau
-- World constants and vehicle speed settings for MiniGTA.

local GTAConfig = {}

--------------------------------------------------------------------------------
-- WORLD GRID
--------------------------------------------------------------------------------

GTAConfig.BLOCK_SIZE = 100       -- building block footprint (studs)
GTAConfig.STREET_WIDTH = 24      -- road width between blocks
GTAConfig.CELL_SIZE = 124        -- BLOCK_SIZE + STREET_WIDTH
GTAConfig.GRID_COLS = 8          -- city columns
GTAConfig.GRID_ROWS = 6          -- city rows
GTAConfig.GROUND_Y = 4           -- terrain surface / ground level

-- Total city extents
GTAConfig.CITY_WIDTH = GTAConfig.CELL_SIZE * GTAConfig.GRID_COLS   -- ~992
GTAConfig.CITY_DEPTH = GTAConfig.CELL_SIZE * GTAConfig.GRID_ROWS   -- ~744

-- City origin (top-left corner of grid at 0,0 — city centered on X)
GTAConfig.CITY_ORIGIN_X = -GTAConfig.CITY_WIDTH / 2
GTAConfig.CITY_ORIGIN_Z = -GTAConfig.CITY_DEPTH / 2

--------------------------------------------------------------------------------
-- WATER / OCEAN
--------------------------------------------------------------------------------

GTAConfig.WATER_LEVEL = -2       -- terrain water surface Y
GTAConfig.OCEAN_START_Z = GTAConfig.CITY_ORIGIN_Z + GTAConfig.CITY_DEPTH  -- south of city
GTAConfig.OCEAN_DEPTH = 400      -- ocean extends this far south
GTAConfig.DEEP_SEA_Y = -80       -- bottom of deep sea trench
GTAConfig.BEACH_Z_START = GTAConfig.OCEAN_START_Z - 50  -- beach transition zone

--------------------------------------------------------------------------------
-- PLAYER SPAWN
--------------------------------------------------------------------------------

GTAConfig.SPAWN_POSITION = Vector3.new(0, GTAConfig.GROUND_Y + 5, 0)

--------------------------------------------------------------------------------
-- VEHICLE SPEEDS (studs/second)
--------------------------------------------------------------------------------

GTAConfig.VEHICLE_SPEEDS = {
	car         = 60,
	motorcycle  = 70,
	bus         = 45,
	truck       = 40,
	monstertruck = 55,
	jetski      = 50,
	speedboat   = 55,
	helicopter  = 80,
	jumbojet    = 120,
	submarine   = 30,
}

GTAConfig.TURN_RATE = math.rad(120)   -- degrees/sec heading change for ground vehicles

--------------------------------------------------------------------------------
-- DISTRICTS (grid position → district name)
-- Row 0 = top (north), Col 0 = left (west)
--------------------------------------------------------------------------------

GTAConfig.DISTRICTS = {
	-- { colMin, colMax, rowMin, rowMax, name }
	{ 0, 2, 0, 1, "airport" },
	{ 3, 5, 0, 1, "industrial" },
	{ 6, 7, 0, 1, "military" },
	{ 0, 2, 2, 3, "commercial" },
	{ 3, 4, 2, 3, "downtown" },
	{ 5, 7, 2, 3, "residential" },
	{ 0, 2, 4, 5, "harbor" },
	{ 3, 5, 4, 5, "waterfront" },
	{ 6, 7, 4, 5, "beach" },
}

-- Look up district for a grid cell
function GTAConfig.getDistrict(col: number, row: number): string
	for _, d in ipairs(GTAConfig.DISTRICTS) do
		if col >= d[1] and col <= d[2] and row >= d[3] and row <= d[4] then
			return d[5]
		end
	end
	return "downtown"  -- fallback
end

return GTAConfig
