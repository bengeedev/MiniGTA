-- ProceduralVehicles Module
-- Builds vehicle models from Parts and inserts them into VehicleTemplates.
-- Called once at server startup before clients connect.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NPCManager = require(script.Parent.NPCManager)

local PoliceMotorcycle = require(script.vehicles.PoliceMotorcycle)
local EscortSUV        = require(script.vehicles.EscortSUV)
local Beast            = require(script.vehicles.Beast)
local HighSpeedTrain   = require(script.vehicles.HighSpeedTrain)
local SubwayTrain      = require(script.vehicles.SubwayTrain)
local GolfCart          = require(script.vehicles.GolfCart)
local Forklift          = require(script.vehicles.Forklift)
local MilitaryJeep      = require(script.vehicles.MilitaryJeep)
local UFO               = require(script.vehicles.UFO)
local HazmatTruck       = require(script.vehicles.HazmatTruck)
local WaterTanker       = require(script.vehicles.WaterTanker)
local Convertible       = require(script.vehicles.Convertible)
local HazmatRunner      = require(script.vehicles.HazmatRunner)
local NasaRover         = require(script.vehicles.NasaRover)
local WaterRunner       = require(script.vehicles.WaterRunner)
local RocketFuelTanker  = require(script.vehicles.RocketFuelTanker)
local TeslaCoilTruck    = require(script.vehicles.TeslaCoilTruck)
local Sedan             = require(script.vehicles.Sedan)
local StationWagon      = require(script.vehicles.StationWagon)
local Crossover         = require(script.vehicles.Crossover)
local SUVLuxury         = require(script.vehicles.SUVLuxury)
local SchoolBus         = require(script.vehicles.SchoolBus)
local UrbanBus          = require(script.vehicles.UrbanBus)
local DoubleDecker      = require(script.vehicles.DoubleDecker)
local PoliceCar         = require(script.vehicles.PoliceCar)
local Taxi              = require(script.vehicles.Taxi)
local UtilityVan        = require(script.vehicles.UtilityVan)
local SemiTruck         = require(script.vehicles.SemiTruck)
local JumboJet          = require(script.vehicles.JumboJet)
local Jetski            = require(script.vehicles.Jetski)
local Speedboat         = require(script.vehicles.Speedboat)
local Helicopter        = require(script.vehicles.Helicopter)
local MonsterTruck      = require(script.vehicles.MonsterTruck)
local WoodLog           = require(script.vehicles.WoodLog)

local ProceduralVehicles = {}

-- Tag all parts matching bodyColor with ThemeRole for per-player theming
local function tagVehicleBody(model, bodyColor)
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") and part.Color == bodyColor then
			part:SetAttribute("ThemeRole", "vehicle_body")
			part:SetAttribute("BaseColor", bodyColor)
			part:SetAttribute("BaseMaterial", part.Material.Name)
		end
	end
end

-- Loading step definitions for progress reporting
local LOADING_STEPS = {
	{ name = "Police Motorcycle", key = "Motorcycle_Police_1" },
	{ name = "Presidential Limo", key = "Limo_Beast_1" },
	{ name = "Escort SUV", key = "SUV_Escort_1" },
	{ name = "High Speed Train", key = "Train_HighSpeed" },
	{ name = "Subway", key = "Subway_1" },
	{ name = "Golf Cart", key = "GolfCart_1" },
	{ name = "Forklift", key = "Forklift_1" },
	{ name = "Military Jeep", key = "Jeep_Military_1" },
	{ name = "UFOs", key = "UFO_1" },
	{ name = "Tesla Coil Truck", key = "TeslaCoilTruck_1" },
	{ name = "Hazmat Truck", key = "HazmatTruck_1" },
	{ name = "Rocket Fuel Tanker", key = "RocketFuelTanker_1" },
	{ name = "Water Tanker", key = "WaterTanker_1" },
	{ name = "Sedans", key = "Sedan_Red_1" },
	{ name = "Convertible", key = "Convertible_1" },
	{ name = "Hazmat Runner", key = "HazmatRunner_1" },
	{ name = "NASA Rover", key = "NasaRover_1" },
	{ name = "Water Runner", key = "WaterRunner_1" },
	{ name = "Station Wagons", key = "Wagon_White_1" },
	{ name = "Crossovers", key = "Crossover_White_1" },
	{ name = "Luxury SUVs", key = "SUV_Black_1" },
	{ name = "School Bus", key = "SchoolBus_1" },
	{ name = "Urban Bus", key = "UrbanBus_1" },
	{ name = "Double Decker", key = "DoubleDecker_1" },
	{ name = "Police Car", key = "PoliceCar_1" },
	{ name = "Taxi", key = "Taxi_1" },
	{ name = "Delivery Vans", key = "DeliveryVan_White_1" },
	{ name = "Ambulance", key = "Ambulance_1" },
	{ name = "Semi Trucks", key = "SemiTruck_Red_1" },
	{ name = "Jumbo Jets", key = "JumboJet_AF1" },
	{ name = "Jetski", key = "Jetski_1" },
	{ name = "Speedboat", key = "Speedboat_1" },
	{ name = "Helicopters", key = "Helicopter_Police_1" },
	{ name = "Monster Truck", key = "Monstertruck_1" },
	{ name = "Wood Log", key = "WoodLog" },
}

function ProceduralVehicles.build(onProgress)
	local templates = ReplicatedStorage:FindFirstChild("VehicleTemplates")
	if not templates then
		warn("[ProceduralVehicles] VehicleTemplates folder not found in ReplicatedStorage")
		return
	end

	local totalSteps = #LOADING_STEPS
	local currentStep = 0

	local function reportProgress(stepName)
		currentStep += 1
		if onProgress then
			onProgress(stepName, currentStep, totalSteps)
		end
	end

	-- Only create if not already present (e.g. from rbxlx)
	-- IMPORTANT: Add NPCs BEFORE parenting to templates to avoid race condition where
	-- clients clone the template before NPCs are fully added.
	if not templates:FindFirstChild("Motorcycle_Police_1") then
		local moto = PoliceMotorcycle.build()

		-- Add NPC rider from template (instant clone, no deferred R15 upgrade needed)
		local seatCFrame = CFrame.new(0, 5.5, -0.5)
			* CFrame.Angles(0, math.rad(180), 0)
			* CFrame.Angles(math.rad(15), 0, 0)
		local rider = NPCManager.spawnSeatedInVehicle("police_officer_01", moto, seatCFrame)
		if rider then
			moto.Parent = templates
			print("[ProceduralVehicles] Created Motorcycle_Police_1 with template rider")
		else
			-- Fallback to part-based rider if template not available
			PoliceMotorcycle.addPartBasedRider(moto)
			moto.Parent = templates
			print("[ProceduralVehicles] Created Motorcycle_Police_1 (Part-based rider, template fallback)")
		end
	end

	if not templates:FindFirstChild("PoliceMotorcycle_Drivable") then
		local drivable = PoliceMotorcycle.buildDrivable()
		drivable.Parent = templates
		print("[ProceduralVehicles] Created PoliceMotorcycle_Drivable")
	end

	if not templates:FindFirstChild("EnemyMotorcycle_1") then
		local enemy = PoliceMotorcycle.buildEnemy()

		-- Add NPC rider (same seat pose as police motorcycle)
		local seatCFrame = CFrame.new(0, 5.5, -0.5)
			* CFrame.Angles(0, math.rad(180), 0)
			* CFrame.Angles(math.rad(15), 0, 0)
		local rider = NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), enemy, seatCFrame)
		if rider then
			enemy.Parent = templates
			print("[ProceduralVehicles] Created EnemyMotorcycle_1 with NPC rider")
		else
			enemy.Parent = templates
			print("[ProceduralVehicles] Created EnemyMotorcycle_1 (no rider)")
		end
	end
	reportProgress("Police Motorcycle")

	if not templates:FindFirstChild("Limo_Beast_1") then
		local beast = Beast.build()
		beast.Parent = templates
		print("[ProceduralVehicles] Created Limo_Beast_1")
	end
	reportProgress("Presidential Limo")

	if not templates:FindFirstChild("SUV_Escort_1") then
		local suv = EscortSUV.build()
		suv.Parent = templates
		print("[ProceduralVehicles] Created SUV_Escort_1")
	end
	reportProgress("Escort SUV")

	if not templates:FindFirstChild("Train_HighSpeed") then
		local train, wagonCenters = HighSpeedTrain.build()
		-- IMPORTANT: Add NPCs BEFORE parenting to templates to avoid race condition.
		local seatX = 2.5    -- bodyW=8 → wall at ±4, arm edge at 2.5+1.3=3.8 (inside)
		local seatY = 5.0
		local facing = CFrame.Angles(0, math.rad(180), 0)
		local npcCount = 0

		-- Drivers in head wagon cabs
		for _, info in ipairs({{z = 47, rot = math.rad(180)}, {z = 3, rot = 0}}) do
			NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), train,
				CFrame.new(0, seatY, info.z) * CFrame.Angles(0, info.rot, 0))
			npcCount += 1
		end

		-- 3 passengers per wagon at window seats, evenly spaced
		for _, wZ in ipairs(wagonCenters) do
			for _, dz in ipairs({-12, 0, 12}) do
				local side = (dz == 0) and -1 or 1
				NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), train,
					CFrame.new(side * seatX, seatY, wZ + dz) * facing)
				npcCount += 1
			end
		end

		train.Parent = templates
		print("[ProceduralVehicles] Created Train_HighSpeed with", npcCount, "NPCs")
	end
	reportProgress("High Speed Train")

	if not templates:FindFirstChild("Subway_1") then
		local subway, carCenters = SubwayTrain.build()
		-- IMPORTANT: Add NPCs BEFORE parenting to templates to avoid race condition.
		local seatX = 2.5    -- bodyW=8 → wall at ±4, arm edge at 2.5+1.3=3.8 (inside)
		local seatY = 5.0
		local facing = CFrame.Angles(0, math.rad(180), 0)
		local npcCount = 0

		-- Drivers in head car cabs
		for _, info in ipairs({{z = 47, rot = math.rad(180)}, {z = 3, rot = 0}}) do
			NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), subway,
				CFrame.new(0, seatY, info.z) * CFrame.Angles(0, info.rot, 0))
			npcCount += 1
		end

		-- 3 passengers per car at window seats, evenly spaced
		for _, cZ in ipairs(carCenters) do
			for _, dz in ipairs({-12, 0, 12}) do
				local side = (dz == 0) and -1 or 1
				NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), subway,
					CFrame.new(side * seatX, seatY, cZ + dz) * facing)
				npcCount += 1
			end
		end

		subway.Parent = templates
		print("[ProceduralVehicles] Created Subway_1 with", npcCount, "NPCs")
	end
	reportProgress("Subway")

	if not templates:FindFirstChild("GolfCart_1") then
		local cart = GolfCart.build()
		NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), cart,
			CFrame.new(-2, GolfCart.FLOOR_Y + 2.5, 0) * CFrame.Angles(0, math.rad(180), 0))
		NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), cart,
			CFrame.new(2, GolfCart.FLOOR_Y + 2.5, 0) * CFrame.Angles(0, math.rad(180), 0))
		cart.Parent = templates
		print("[ProceduralVehicles] Created GolfCart_1")
	end
	reportProgress("Golf Cart")

	if not templates:FindFirstChild("Forklift_1") then
		local forklift = Forklift.build()
		NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), forklift,
			CFrame.new(0, 4.0, -0.2) * CFrame.Angles(0, math.rad(180), 0))
		forklift.Parent = templates
		print("[ProceduralVehicles] Created Forklift_1")
	end
	reportProgress("Forklift")

	if not templates:FindFirstChild("Jeep_Military_1") then
		local jeep = MilitaryJeep.build()
		NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), jeep,
			CFrame.new(-1.5, 5.0, 0) * CFrame.Angles(0, math.rad(180), 0))
		NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), jeep,
			CFrame.new(1.5, 5.0, 0) * CFrame.Angles(0, math.rad(180), 0))
		jeep.Parent = templates
		print("[ProceduralVehicles] Created Jeep_Military_1")
	end
	reportProgress("Military Jeep")

	if not templates:FindFirstChild("UFO_1") then
		local ufo = UFO.build("UFO_1", UFO.GREEN, Color3.fromRGB(200, 255, 200))
		ufo.Parent = templates
		print("[ProceduralVehicles] Created UFO_1")
	end

	if not templates:FindFirstChild("UFO_Blue_1") then
		local ufo2 = UFO.build("UFO_Blue_1", UFO.BLUE, Color3.fromRGB(180, 210, 255))
		ufo2.Parent = templates
		print("[ProceduralVehicles] Created UFO_Blue_1")
	end
	reportProgress("UFOs")

	if not templates:FindFirstChild("TeslaCoilTruck_1") then
		local truck = TeslaCoilTruck.build()
		-- floorY=2.2, cabZ=3.5, cabH=5, roof~7.35 — lower seat so head stays under roof
		NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), truck,
			CFrame.new(0, 4.7, 3.5) * CFrame.Angles(0, math.rad(180), 0))
		truck.Parent = templates
		print("[ProceduralVehicles] Created TeslaCoilTruck_1")
	end
	reportProgress("Tesla Coil Truck")

	if not templates:FindFirstChild("HazmatTruck_1") then
		local truck = HazmatTruck.build()
		-- floorY=2.2, cabZ=3.5 — seat driver inside cab
		NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), truck,
			CFrame.new(0, 5.2, 3.5) * CFrame.Angles(0, math.rad(180), 0))
		truck.Parent = templates
		print("[ProceduralVehicles] Created HazmatTruck_1")
	end
	reportProgress("Hazmat Truck")

	if not templates:FindFirstChild("RocketFuelTanker_1") then
		local tanker = RocketFuelTanker.build()
		-- floorY=2.4, cabZ=4 — seat driver inside cab
		NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), tanker,
			CFrame.new(0, 5.4, 4.0) * CFrame.Angles(0, math.rad(180), 0))
		tanker.Parent = templates
		print("[ProceduralVehicles] Created RocketFuelTanker_1")
	end
	reportProgress("Rocket Fuel Tanker")

	if not templates:FindFirstChild("WaterTanker_1") then
		local wt = WaterTanker.build()
		-- floorY=2.3, cabZ=3.5 — seat well forward near windshield
		NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), wt,
			CFrame.new(0, 4.8, 5.0) * CFrame.Angles(0, math.rad(180), 0))
		wt.Parent = templates
		print("[ProceduralVehicles] Created WaterTanker_1")
	end
	reportProgress("Water Tanker")

	-- SEDANS (parameterized: body color variants)
	-- Left-hand drive (France): driver on left side (+X in vehicle local space)
	local sedanConfigs = {
		{"Sedan_Red_1", Color3.fromRGB(200, 30, 30), {{1.5, 0.8}, {-1.5, 0.8}, {1.5, -2.5}, {-1.5, -2.5}}},
		{"Sedan_Blue_1", Color3.fromRGB(30, 80, 200), {{1.5, 0.8}, {-1.5, 0.8}}},
		{"Sedan_White_1", Color3.fromRGB(235, 235, 240), {{1.5, 0.8}}},
		{"Sedan_Black_1", Color3.fromRGB(25, 25, 30), {{1.5, 0.8}, {-1.5, 0.8}, {1.5, -2.5}, {-1.5, -2.5}}},
		{"Sedan_Silver_1", Color3.fromRGB(180, 180, 185), {{1.5, 0.8}, {-1.5, 0.8}}},
		{"Sedan_Green_1", Color3.fromRGB(40, 120, 50), {{1.5, 0.8}}},
		{"Sedan_Yellow_1", Color3.fromRGB(230, 200, 40), {{1.5, 0.8}, {-1.5, 0.8}}},
		{"Sedan_Orange_1", Color3.fromRGB(220, 100, 30), {{1.5, 0.8}}},
		{"Sedan_Burgundy_1", Color3.fromRGB(100, 30, 40), {{1.5, 0.8}, {-1.5, 0.8}, {1.5, -2.5}}},
	}
	for _, cfg in ipairs(sedanConfigs) do
		local name, color, seats = cfg[1], cfg[2], cfg[3]
		if not templates:FindFirstChild(name) then
			local sedan = Sedan.build(name, color)
			tagVehicleBody(sedan, color)
			local seatY = Sedan.SEAT_Y
			local facing = CFrame.Angles(0, math.rad(180), 0)
			for _, pos in ipairs(seats) do
				NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), sedan,
					CFrame.new(pos[1], seatY, pos[2]) * facing)
			end
			sedan.Parent = templates
			print("[ProceduralVehicles] Created", name, "with", #seats, "NPCs")
		end
	end
	reportProgress("Sedans")

	if not templates:FindFirstChild("Convertible_1") then
		local conv = Convertible.build()
		-- Driver on left (French/European)
		NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), conv,
			CFrame.new(Convertible.DRIVER_X, Convertible.SEAT_Y, Convertible.SEAT_Z)
				* CFrame.Angles(0, math.rad(180), 0))
		conv.Parent = templates
		print("[ProceduralVehicles] Created Convertible_1")
	end

	if not templates:FindFirstChild("Convertible_Drivable") then
		local drivable = Convertible.buildDrivable()
		drivable.Parent = templates
		print("[ProceduralVehicles] Created Convertible_Drivable")
	end
	reportProgress("Convertible")

	if not templates:FindFirstChild("HazmatRunner_1") then
		local runner = HazmatRunner.build()
		NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), runner,
			CFrame.new(HazmatRunner.DRIVER_X, HazmatRunner.SEAT_Y, HazmatRunner.SEAT_Z)
				* CFrame.Angles(0, math.rad(180), 0))
		runner.Parent = templates
		print("[ProceduralVehicles] Created HazmatRunner_1")
	end

	if not templates:FindFirstChild("HazmatRunner_Drivable") then
		local drivable = HazmatRunner.buildDrivable()
		drivable.Parent = templates
		print("[ProceduralVehicles] Created HazmatRunner_Drivable")
	end
	reportProgress("Hazmat Runner")

	if not templates:FindFirstChild("NasaRover_1") then
		local rover = NasaRover.build()
		NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), rover,
			CFrame.new(NasaRover.DRIVER_X, NasaRover.SEAT_Y, NasaRover.SEAT_Z)
				* CFrame.Angles(0, math.rad(180), 0))
		rover.Parent = templates
		print("[ProceduralVehicles] Created NasaRover_1")
	end

	if not templates:FindFirstChild("NasaRover_Drivable") then
		local drivable = NasaRover.buildDrivable()
		drivable.Parent = templates
		print("[ProceduralVehicles] Created NasaRover_Drivable")
	end
	reportProgress("NASA Rover")

	if not templates:FindFirstChild("WaterRunner_1") then
		local runner = WaterRunner.build()
		NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), runner,
			CFrame.new(WaterRunner.DRIVER_X, WaterRunner.SEAT_Y, WaterRunner.SEAT_Z)
				* CFrame.Angles(0, math.rad(180), 0))
		runner.Parent = templates
		print("[ProceduralVehicles] Created WaterRunner_1")
	end

	if not templates:FindFirstChild("WaterRunner_Drivable") then
		local drivable = WaterRunner.buildDrivable()
		drivable.Parent = templates
		print("[ProceduralVehicles] Created WaterRunner_Drivable")
	end
	reportProgress("Water Runner")

	-- STATION WAGONS (break/estate cars)
	-- Left-hand drive (France): driver on left side
	-- IMPORTANT: Add NPCs BEFORE parenting to templates.
	local wagonConfigs = {
		{"Wagon_White_1", Color3.fromRGB(235, 235, 240), {{1.5, 1.0}, {-1.5, 1.0}}},
		{"Wagon_Beige_1", Color3.fromRGB(210, 195, 170), {{1.5, 1.0}, {-1.5, 1.0}, {1.5, -2.5}, {-1.5, -2.5}}},
		{"Wagon_Blue_1", Color3.fromRGB(60, 90, 140), {{1.5, 1.0}}},
		{"Wagon_Green_1", Color3.fromRGB(70, 100, 70), {{1.5, 1.0}, {-1.5, 1.0}}},
		{"Wagon_Red_1", Color3.fromRGB(180, 45, 45), {{1.5, 1.0}, {-1.5, 1.0}, {1.5, -2.5}, {-1.5, -2.5}}},
		{"Wagon_Brown_1", Color3.fromRGB(130, 90, 60), {{1.5, 1.0}, {-1.5, 1.0}}},
		{"Wagon_Burgundy_1", Color3.fromRGB(100, 35, 50), {{1.5, 1.0}, {-1.5, 1.0}, {1.5, -2.5}}},
		{"Wagon_Silver_1", Color3.fromRGB(170, 170, 175), {{1.5, 1.0}}},
		{"Wagon_Teal_1", Color3.fromRGB(60, 130, 130), {{1.5, 1.0}, {-1.5, 1.0}}},
	}
	for _, cfg in ipairs(wagonConfigs) do
		local name, color, seats = cfg[1], cfg[2], cfg[3]
		if not templates:FindFirstChild(name) then
			local wagon = StationWagon.build(name, color)
			tagVehicleBody(wagon, color)
			local seatY = StationWagon.SEAT_Y
			local facing = CFrame.Angles(0, math.rad(180), 0)
			for _, pos in ipairs(seats) do
				NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), wagon,
					CFrame.new(pos[1], seatY, pos[2]) * facing)
			end
			wagon.Parent = templates
			print("[ProceduralVehicles] Created", name, "with", #seats, "NPCs")
		end
	end
	reportProgress("Station Wagons")

	-- CROSSOVERS (modern SUV style)
	-- Left-hand drive (France): driver on left side
	-- IMPORTANT: Add NPCs BEFORE parenting to templates.
	local crossoverConfigs = {
		{"Crossover_White_1", Color3.fromRGB(235, 235, 240), {{1.5, 0.5}, {-1.5, 0.5}}},
		{"Crossover_Black_1", Color3.fromRGB(30, 30, 35), {{1.5, 0.5}, {-1.5, 0.5}, {1.5, -3.0}, {-1.5, -3.0}}},
		{"Crossover_Silver_1", Color3.fromRGB(175, 175, 180), {{1.5, 0.5}}},
		{"Crossover_Gray_1", Color3.fromRGB(90, 90, 95), {{1.5, 0.5}, {-1.5, 0.5}}},
		{"Crossover_Red_1", Color3.fromRGB(180, 35, 35), {{1.5, 0.5}, {-1.5, 0.5}, {1.5, -3.0}}},
		{"Crossover_Blue_1", Color3.fromRGB(40, 60, 110), {{1.5, 0.5}, {-1.5, 0.5}}},
		{"Crossover_Green_1", Color3.fromRGB(50, 80, 55), {{1.5, 0.5}}},
		{"Crossover_Bronze_1", Color3.fromRGB(140, 100, 70), {{1.5, 0.5}, {-1.5, 0.5}, {1.5, -3.0}, {-1.5, -3.0}}},
		{"Crossover_Pearl_1", Color3.fromRGB(245, 240, 230), {{1.5, 0.5}, {-1.5, 0.5}}},
	}
	for _, cfg in ipairs(crossoverConfigs) do
		local name, color, seats = cfg[1], cfg[2], cfg[3]
		if not templates:FindFirstChild(name) then
			local suv = Crossover.build(name, color)
			tagVehicleBody(suv, color)
			local seatY = Crossover.SEAT_Y
			local facing = CFrame.Angles(0, math.rad(180), 0)
			for _, pos in ipairs(seats) do
				NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), suv,
					CFrame.new(pos[1], seatY, pos[2]) * facing)
			end
			suv.Parent = templates
			print("[ProceduralVehicles] Created", name, "with", #seats, "NPCs")
		end
	end
	reportProgress("Crossovers")

	-- LUXURY SUV (3-row, large, chrome accents)
	-- Seat positions: front z=1.5, middle z=-2.0, rear z=-5.5
	-- IMPORTANT: Add NPCs BEFORE parenting to templates.
	local suvLuxuryConfigs = {
		{"SUV_Black_1", Color3.fromRGB(25, 25, 30), {{1.8, 1.5}, {-1.8, 1.5}, {1.8, -2.0}, {-1.8, -2.0}, {1.8, -5.5}, {-1.8, -5.5}}},
		{"SUV_White_1", Color3.fromRGB(240, 240, 245), {{1.8, 1.5}, {-1.8, 1.5}, {1.8, -2.0}, {-1.8, -2.0}}},
		{"SUV_Silver_1", Color3.fromRGB(180, 180, 185), {{1.8, 1.5}, {-1.8, 1.5}}},
		{"SUV_Champagne_1", Color3.fromRGB(210, 190, 160), {{1.8, 1.5}, {-1.8, 1.5}, {1.8, -2.0}, {-1.8, -2.0}}},
		{"SUV_Burgundy_1", Color3.fromRGB(80, 25, 35), {{1.8, 1.5}, {-1.8, 1.5}, {1.8, -2.0}, {-1.8, -2.0}, {1.8, -5.5}, {-1.8, -5.5}}},
		{"SUV_Navy_1", Color3.fromRGB(25, 40, 70), {{1.8, 1.5}, {-1.8, 1.5}, {1.8, -2.0}}},
		{"SUV_Charcoal_1", Color3.fromRGB(55, 55, 60), {{1.8, 1.5}, {-1.8, 1.5}}},
		{"SUV_Midnight_1", Color3.fromRGB(15, 20, 40), {{1.8, 1.5}, {-1.8, 1.5}, {1.8, -2.0}, {-1.8, -2.0}}},
		{"SUV_Pearl_1", Color3.fromRGB(250, 248, 240), {{1.8, 1.5}, {-1.8, 1.5}}},
	}
	for _, cfg in ipairs(suvLuxuryConfigs) do
		local name, color, seats = cfg[1], cfg[2], cfg[3]
		if not templates:FindFirstChild(name) then
			local suv = SUVLuxury.build(name, color)
			tagVehicleBody(suv, color)
			local seatY = SUVLuxury.SEAT_Y
			local facing = CFrame.Angles(0, math.rad(180), 0)
			for _, pos in ipairs(seats) do
				NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), suv,
					CFrame.new(pos[1], seatY, pos[2]) * facing)
			end
			suv.Parent = templates
			print("[ProceduralVehicles] Created", name, "with", #seats, "NPCs")
		end
	end
	reportProgress("Luxury SUVs")

	-- SCHOOL BUS (classic American yellow)
	-- Half-full: driver + window seats on every other row
	-- IMPORTANT: Add NPCs BEFORE parenting to templates.
	if not templates:FindFirstChild("SchoolBus_1") then
		local bus = SchoolBus.build("SchoolBus_1")
		local seatY = SchoolBus.SEAT_Y
		local facing = CFrame.Angles(0, math.rad(180), 0)
		local windowX = SchoolBus.SEAT_X_WINDOW  -- 3.2
		local rowSpacing = SchoolBus.ROW_SPACING -- 3.0
		local firstRowZ = SchoolBus.FIRST_ROW_Z  -- 2.0 (behind driver)
		local driverZ = SchoolBus.DRIVER_Z       -- 7.0 (front cabin)

		local npcCount = 0

		-- Driver (front left, in black hood area)
		NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), bus,
			CFrame.new(windowX, seatY, driverZ) * facing)
		npcCount += 1

		-- Window seats on every other row (8 NPCs)
		for row = 0, SchoolBus.ROWS - 1, 2 do
			local rowZ = firstRowZ - row * rowSpacing
			for _, xPos in ipairs({windowX, -windowX}) do
				NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), bus,
					CFrame.new(xPos, seatY, rowZ) * facing)
				npcCount += 1
			end
		end

		bus.Parent = templates
		print("[ProceduralVehicles] Created SchoolBus_1 with", npcCount, "NPCs")
	end
	reportProgress("School Bus")

	-- URBAN BUS (city transit, flat front)
	-- Half-full: driver + window seats on every other row
	-- IMPORTANT: Add NPCs BEFORE parenting to templates.
	if not templates:FindFirstChild("UrbanBus_1") then
		local bus = UrbanBus.build("UrbanBus_1")
		local seatY = UrbanBus.SEAT_Y
		local facing = CFrame.Angles(0, math.rad(180), 0)
		local windowX = UrbanBus.SEAT_X_WINDOW  -- 3.2
		local rowSpacing = UrbanBus.ROW_SPACING -- 3.0
		local firstRowZ = UrbanBus.FIRST_ROW_Z  -- 4.0
		local driverZ = UrbanBus.DRIVER_Z       -- 9.0

		local npcCount = 0

		-- Driver (front left)
		NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), bus,
			CFrame.new(windowX, seatY, driverZ) * facing)
		npcCount += 1

		-- Window seats on every other row (8 NPCs)
		for row = 0, UrbanBus.ROWS - 1, 2 do
			local rowZ = firstRowZ - row * rowSpacing
			for _, xPos in ipairs({windowX, -windowX}) do
				NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), bus,
					CFrame.new(xPos, seatY, rowZ) * facing)
				npcCount += 1
			end
		end

		bus.Parent = templates
		print("[ProceduralVehicles] Created UrbanBus_1 with", npcCount, "NPCs")
	end
	reportProgress("Urban Bus")

	-- DOUBLE DECKER (British two-level bus)
	-- Half-full: driver + window seats on every other row per deck
	-- IMPORTANT: Add NPCs BEFORE parenting to templates.
	if not templates:FindFirstChild("DoubleDecker_1") then
		local bus = DoubleDecker.build("DoubleDecker_1")
		local facing = CFrame.Angles(0, math.rad(180), 0)
		local windowX = DoubleDecker.SEAT_X_WINDOW  -- 3.0
		local rowSpacing = DoubleDecker.ROW_SPACING -- 2.8

		local npcCount = 0

		-- Driver (lower deck, front left)
		NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), bus,
			CFrame.new(windowX, DoubleDecker.LOWER_SEAT_Y, DoubleDecker.DRIVER_Z) * facing)
		npcCount += 1

		-- Lower deck: window seats on every other row (4 NPCs)
		for row = 0, DoubleDecker.LOWER_ROWS - 1, 2 do
			local rowZ = DoubleDecker.LOWER_FIRST_ROW_Z - row * rowSpacing
			for _, xPos in ipairs({windowX, -windowX}) do
				NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), bus,
					CFrame.new(xPos, DoubleDecker.LOWER_SEAT_Y, rowZ) * facing)
				npcCount += 1
			end
		end

		-- Upper deck: window seats on every other row (6 NPCs)
		for row = 0, DoubleDecker.UPPER_ROWS - 1, 2 do
			local rowZ = DoubleDecker.UPPER_FIRST_ROW_Z - row * rowSpacing
			for _, xPos in ipairs({windowX, -windowX}) do
				NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), bus,
					CFrame.new(xPos, DoubleDecker.UPPER_SEAT_Y, rowZ) * facing)
				npcCount += 1
			end
		end

		bus.Parent = templates
		print("[ProceduralVehicles] Created DoubleDecker_1 with", npcCount, "NPCs")
	end
	reportProgress("Double Decker")

	-- POLICE CAR (black/white livery with light bar)
	-- 2 officers: driver + passenger (front seats)
	-- IMPORTANT: Add NPCs BEFORE parenting to templates.
	if not templates:FindFirstChild("PoliceCar_1") then
		local car = PoliceCar.build("PoliceCar_1")
		local seatY = PoliceCar.SEAT_Y
		local facing = CFrame.Angles(0, math.rad(180), 0)

		-- Driver (front left) and passenger (front right)
		for _, xPos in ipairs({1.5, -1.5}) do
			NPCManager.spawnSeatedInVehicle("police_officer_01", car,
				CFrame.new(xPos, seatY, 0.8) * facing)
		end

		car.Parent = templates
		print("[ProceduralVehicles] Created PoliceCar_1 with 2 NPCs")
	end
	reportProgress("Police Car")

	-- TAXI (yellow cab with roof sign)
	-- Driver + 1 passenger in back seat
	-- IMPORTANT: Add NPCs BEFORE parenting to templates.
	if not templates:FindFirstChild("Taxi_1") then
		local cab = Taxi.build("Taxi_1")
		local seatY = Taxi.SEAT_Y
		local facing = CFrame.Angles(0, math.rad(180), 0)

		-- Driver (front left) and passenger (rear right)
		local seats = {{1.5, 0.8}, {-1.5, -2.5}}
		for _, pos in ipairs(seats) do
			NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), cab,
				CFrame.new(pos[1], seatY, pos[2]) * facing)
		end

		cab.Parent = templates
		print("[ProceduralVehicles] Created Taxi_1 with 2 NPCs")
	end
	reportProgress("Taxi")

	-- DELIVERY VANS (various liveries)
	-- bodyColor, accentColor (trim), stripeColor (optional)
	local deliveryVanConfigs = {
		{"DeliveryVan_White_1", Color3.fromRGB(235, 235, 240), Color3.fromRGB(30, 30, 35), nil},
		{"DeliveryVan_Orange_1", Color3.fromRGB(240, 130, 30), Color3.fromRGB(30, 80, 160), Color3.fromRGB(30, 80, 160)},  -- orange + blue
		{"DeliveryVan_Yellow_1", Color3.fromRGB(240, 200, 40), Color3.fromRGB(40, 100, 50), Color3.fromRGB(40, 100, 50)},  -- yellow + green
		{"DeliveryVan_Blue_1", Color3.fromRGB(40, 90, 170), Color3.fromRGB(235, 235, 240), Color3.fromRGB(235, 235, 240)}, -- blue + white
		{"DeliveryVan_Red_1", Color3.fromRGB(200, 40, 40), Color3.fromRGB(30, 30, 35), Color3.fromRGB(240, 200, 40)},      -- red + yellow stripe
		{"DeliveryVan_Green_1", Color3.fromRGB(50, 130, 60), Color3.fromRGB(235, 235, 240), nil},                          -- green + white trim
		{"DeliveryVan_Brown_1", Color3.fromRGB(120, 80, 50), Color3.fromRGB(240, 200, 40), Color3.fromRGB(240, 200, 40)},  -- brown + yellow (like UPS)
	}
	for _, cfg in ipairs(deliveryVanConfigs) do
		local name, bodyColor, accentColor, stripeColor = cfg[1], cfg[2], cfg[3], cfg[4]
		if not templates:FindFirstChild(name) then
			local options = stripeColor and { stripeColor = stripeColor } or nil
			local van = UtilityVan.build(name, bodyColor, accentColor, options)
			tagVehicleBody(van, bodyColor)
			local seatY = UtilityVan.SEAT_Y
			local driverZ = UtilityVan.DRIVER_Z
			local facing = CFrame.Angles(0, math.rad(180), 0)

			NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), van,
				CFrame.new(1.8, seatY, driverZ) * facing)

			van.Parent = templates
			print("[ProceduralVehicles] Created", name)
		end
	end
	reportProgress("Delivery Vans")

	-- AMBULANCE (white with red stripe, emergency lights, cargo windows)
	-- Driver + paramedic in back
	if not templates:FindFirstChild("Ambulance_1") then
		local ambulance = UtilityVan.build("Ambulance_1",
			Color3.fromRGB(240, 240, 245),  -- white body
			Color3.fromRGB(30, 30, 35),     -- dark trim
			{
				cargoWindows = true,
				emergencyLights = Color3.fromRGB(255, 40, 40),  -- red lights
				stripeColor = Color3.fromRGB(220, 30, 30),      -- red side stripe
			}
		)
		local seatY = UtilityVan.SEAT_Y
		local driverZ = UtilityVan.DRIVER_Z
		local facing = CFrame.Angles(0, math.rad(180), 0)

		-- Driver
		NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), ambulance,
			CFrame.new(1.8, seatY, driverZ) * facing)

		-- Paramedic in cargo area
		NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), ambulance,
			CFrame.new(1.5, seatY, -4.0) * facing)

		ambulance.Parent = templates
		print("[ProceduralVehicles] Created Ambulance_1 with 2 NPCs")
	end
	reportProgress("Ambulance")

	-- SEMI TRUCKS with cargo trailers
	-- {name, bodyColor, trailerCount}
	local semiTruckConfigs = {
		-- 1 trailer variants
		{"SemiTruck_Red_1", Color3.fromRGB(180, 30, 30), 1},
		{"SemiTruck_Green_1", Color3.fromRGB(40, 100, 50), 1},
		{"SemiTruck_Yellow_1", Color3.fromRGB(230, 190, 40), 1},
		{"SemiTruck_Orange_1", Color3.fromRGB(220, 110, 30), 1},
		{"SemiTruck_Silver_1", Color3.fromRGB(180, 180, 185), 1},
		-- 2 trailer variants
		{"SemiTruck_Blue_2", Color3.fromRGB(40, 70, 140), 2},
		{"SemiTruck_Black_2", Color3.fromRGB(30, 30, 35), 2},
		{"SemiTruck_Burgundy_2", Color3.fromRGB(100, 30, 45), 2},
		{"SemiTruck_Teal_2", Color3.fromRGB(40, 120, 130), 2},
		{"SemiTruck_Purple_2", Color3.fromRGB(80, 40, 110), 2},
		-- Cab only variants
		{"SemiTruck_White_0", Color3.fromRGB(235, 235, 240), 0},
		{"SemiTruck_Gray_0", Color3.fromRGB(90, 90, 95), 0},
	}
	for _, cfg in ipairs(semiTruckConfigs) do
		local name, bodyColor, trailerCount = cfg[1], cfg[2], cfg[3]
		if not templates:FindFirstChild(name) then
			local truck = SemiTruck.build(name, bodyColor, trailerCount)
			tagVehicleBody(truck, bodyColor)
			local seatY = SemiTruck.SEAT_Y
			local driverZ = SemiTruck.DRIVER_Z
			local facing = CFrame.Angles(0, math.rad(180), 0)

			NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), truck,
				CFrame.new(1.5, seatY, driverZ) * facing)

			truck.Parent = templates
			print("[ProceduralVehicles] Created", name, "(" .. trailerCount .. " trailer" .. (trailerCount == 1 and "" or "s") .. ")")
		end
	end
	reportProgress("Semi Trucks")

	-- JUMBO JETS (one template per livery, NPC passengers visible through windows)
	for _, livery in JumboJet.LIVERIES do
		local templateName = "JumboJet_" .. livery.name
		if not templates:FindFirstChild(templateName) then
			local jet, seatPositions = JumboJet.build(livery.name)
			local jetSeatY = 15.6  -- BASE_Y(12) + FLOOR_Y_OFFSET(0.8) + SEATED_HRP(2.8)
			for _, sp in ipairs(seatPositions) do
				NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), jet,
					CFrame.new(sp.x, jetSeatY, sp.z)
						* CFrame.Angles(0, math.rad(180), 0))
			end
			jet.Parent = templates
			print("[ProceduralVehicles] Created", templateName, "with", #seatPositions, "NPC passengers")
		end
	end
	reportProgress("Jumbo Jets")

	-- JETSKI (personal watercraft for driving lanes)
	if not templates:FindFirstChild("Jetski_1") then
		local jetski = Jetski.build()
		jetski.Parent = templates
		print("[ProceduralVehicles] Created Jetski_1")
	end

	if not templates:FindFirstChild("Jetski_Drivable") then
		local drivable = Jetski.buildDrivable()
		drivable.Parent = templates
		print("[ProceduralVehicles] Created Jetski_Drivable")
	end
	reportProgress("Jetski")

	-- SPEEDBOAT (center-console offshore, drawbridge boats)
	if not templates:FindFirstChild("Speedboat_1") then
		local boat = Speedboat.build()
		local facing = CFrame.Angles(0, math.rad(180), 0)

		-- Driver at helm
		NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), boat,
			CFrame.new(Speedboat.DRIVER_X, Speedboat.SEAT_Y, Speedboat.SEAT_Z) * facing)

		-- Passenger on bow
		NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), boat,
			CFrame.new(Speedboat.PASSENGER_X, Speedboat.SEAT_Y, Speedboat.PASSENGER_Z) * facing)

		boat.Parent = templates
		print("[ProceduralVehicles] Created Speedboat_1 with 2 NPCs")
	end
	reportProgress("Speedboat")

	-- POLICE HELICOPTER (searchlight beam, NPC pilot + co-pilot)
	if not templates:FindFirstChild("Helicopter_Police_1") then
		local heli = Helicopter.build("Helicopter_Police_1",
			Helicopter.SEARCHLIGHT, Color3.fromRGB(255, 255, 240))
		-- Pilot (left seat) + co-pilot (right seat) — police officers
		local seatY = 0  -- cabin center Y
		for _, xPos in ipairs({-1.5, 1.5}) do
			NPCManager.spawnSeatedInVehicle("police_officer_01", heli,
				CFrame.new(xPos, seatY, 1.5) * CFrame.Angles(0, math.rad(180), 0))
		end
		heli.Parent = templates
		print("[ProceduralVehicles] Created Helicopter_Police_1 with 2 NPCs")
	end
	reportProgress("Helicopters")

	-- MONSTER TRUCKS (color variants)
	local monsterColors = {
		{ name = "Monstertruck_Yellow", color = Color3.fromRGB(230, 200, 40) },
		{ name = "Monstertruck_Red",    color = Color3.fromRGB(200, 30, 30) },
		{ name = "Monstertruck_Blue",   color = Color3.fromRGB(40, 80, 200) },
		{ name = "Monstertruck_Green",  color = Color3.fromRGB(30, 160, 50) },
		{ name = "Monstertruck_Orange", color = Color3.fromRGB(230, 120, 20) },
		{ name = "Monstertruck_Black",  color = Color3.fromRGB(30, 30, 35) },
	}
	for _, mt in ipairs(monsterColors) do
		if not templates:FindFirstChild(mt.name) then
			local truck = MonsterTruck.build(mt.name, mt.color)
			tagVehicleBody(truck, mt.color)
			NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), truck,
				CFrame.new(MonsterTruck.DRIVER_X, MonsterTruck.SEAT_Y, MonsterTruck.SEAT_Z)
					* CFrame.Angles(0, math.rad(180), 0))
			truck.Parent = templates
			print("[ProceduralVehicles] Created " .. mt.name)
		end
	end
	-- Keep legacy name for backward compat
	if not templates:FindFirstChild("Monstertruck_1") then
		local legacy = templates:FindFirstChild("Monstertruck_Yellow")
		if legacy then
			legacy:Clone().Name = "Monstertruck_1"
			legacy.Parent = templates
		end
	end
	reportProgress("Monster Trucks")

	-- WOOD LOG (rideable floating log for water river lanes, no NPCs)
	if not templates:FindFirstChild("WoodLog") then
		local log = WoodLog.build()
		log.Parent = templates
		print("[ProceduralVehicles] Created WoodLog")
	end
	reportProgress("Wood Log")

end

return ProceduralVehicles
