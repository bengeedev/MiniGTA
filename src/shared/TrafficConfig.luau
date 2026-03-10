-- TrafficConfig.luau
-- Shared traffic system constants (server + client).

local TrafficConfig = {}

--------------------------------------------------------------------------------
-- NETWORK
--------------------------------------------------------------------------------

TrafficConfig.SYNC_RATE      = 8                   -- position broadcasts per second
TrafficConfig.SYNC_INTERVAL  = 1 / 8               -- 0.125s between syncs

--------------------------------------------------------------------------------
-- ROAD VEHICLES
--------------------------------------------------------------------------------

TrafficConfig.MAX_ROAD_VEHICLES = 25
TrafficConfig.ROAD_SPEED        = 30               -- studs/sec
TrafficConfig.HIGHWAY_SPEED     = 50               -- studs/sec
TrafficConfig.SPAWN_INTERVAL    = 2                 -- seconds between spawn attempts
TrafficConfig.FOLLOW_DIST       = 18                -- start slowing (studs to vehicle ahead)
TrafficConfig.STOP_DIST         = 7                 -- full stop distance (studs)
TrafficConfig.SPEED_VARIATION   = 0.15              -- ±15% random speed per vehicle
TrafficConfig.REPLENISH_INTERVAL = 10               -- seconds between replenish checks

--------------------------------------------------------------------------------
-- TRAIN
--------------------------------------------------------------------------------

TrafficConfig.TRAIN_SPEED        = 80              -- studs/sec
TrafficConfig.CROSSING_WARN_DIST = 200             -- activate crossing lights this far ahead

--------------------------------------------------------------------------------
-- TRAFFIC LIGHTS (global synchronized cycle)
--------------------------------------------------------------------------------

TrafficConfig.LIGHT_GREEN_TIME    = 15
TrafficConfig.LIGHT_YELLOW_TIME   = 3
TrafficConfig.LIGHT_ALL_RED_TIME  = 1

-- Phase IDs (cycle: 1→2→3→4→5→6→1...)
TrafficConfig.PHASE_H_GREEN   = 1    -- H-lanes green, V-lanes red
TrafficConfig.PHASE_H_YELLOW  = 2    -- H-lanes yellow
TrafficConfig.PHASE_ALL_RED_1 = 3    -- all red (safety gap)
TrafficConfig.PHASE_V_GREEN   = 4    -- V-lanes green, H-lanes red
TrafficConfig.PHASE_V_YELLOW  = 5    -- V-lanes yellow
TrafficConfig.PHASE_ALL_RED_2 = 6    -- all red (safety gap)

--------------------------------------------------------------------------------
-- CLIENT RENDERING
--------------------------------------------------------------------------------

TrafficConfig.CULL_DISTANCE = 500                  -- hide vehicles beyond this (studs)
TrafficConfig.LERP_SPEED    = 0.15                 -- base lerp factor at 60 fps

--------------------------------------------------------------------------------
-- ROAD VEHICLE TEMPLATES (must exist in ReplicatedStorage.VehicleTemplates)
--------------------------------------------------------------------------------

TrafficConfig.ROAD_TEMPLATES = {
	"Sedan_Red_1", "Sedan_Blue_1", "Sedan_White_1", "Sedan_Black_1",
	"Sedan_Silver_1", "Sedan_Green_1", "Sedan_Yellow_1", "Sedan_Orange_1",
	"Sedan_Burgundy_1",
	"Wagon_White_1", "Wagon_Beige_1", "Wagon_Blue_1", "Wagon_Green_1",
	"Wagon_Red_1", "Wagon_Brown_1", "Wagon_Burgundy_1", "Wagon_Silver_1",
	"Wagon_Teal_1",
	"Crossover_White_1", "Crossover_Black_1", "Crossover_Silver_1",
	"Crossover_Gray_1", "Crossover_Red_1", "Crossover_Blue_1",
	"Crossover_Green_1", "Crossover_Bronze_1", "Crossover_Pearl_1",
	"SUV_Black_1", "SUV_White_1", "SUV_Silver_1",
	"Taxi_1",
	"DeliveryVan_White_1", "DeliveryVan_Orange_1", "DeliveryVan_Blue_1",
	"SchoolBus_1", "UrbanBus_1",
}

return TrafficConfig
