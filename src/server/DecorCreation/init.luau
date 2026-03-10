-- DecorCreation Module
-- Standalone decor placement system for Dash or Crash.
-- Template-first: checks DecorTemplates folder, then falls back to procedural builders.
-- Builder implementations live in decor/ submodules; this file is the thin dispatcher.

local DecorCreation = {}

local DecorUtils = require(script:WaitForChild("decor"):WaitForChild("DecorUtils"))
local Tree = require(script:WaitForChild("decor"):WaitForChild("Tree"))
local Lamp = require(script:WaitForChild("decor"):WaitForChild("Lamp"))
local BillboardMod = require(script:WaitForChild("decor"):WaitForChild("Billboard"))
local RailTrackMod = require(script:WaitForChild("decor"):WaitForChild("RailTrack"))
local BridgeMod = require(script:WaitForChild("decor"):WaitForChild("Bridge"))
local AirportLinesMod = require(script:WaitForChild("decor"):WaitForChild("AirportLines"))
local WaterPlatformsMod = require(script:WaitForChild("decor"):WaitForChild("WaterPlatforms"))
local BuildingsMod = require(script:WaitForChild("decor"):WaitForChild("Buildings"))
local SkyscrapersMod = require(script:WaitForChild("decor"):WaitForChild("Skyscrapers"))
local ShopsMod = require(script:WaitForChild("decor"):WaitForChild("Shops"))
local ParkMod = require(script:WaitForChild("decor"):WaitForChild("Park"))
local HoodBuildingMod = require(script:WaitForChild("decor"):WaitForChild("HoodBuilding"))
local ParkingGarageMod = require(script:WaitForChild("decor"):WaitForChild("ParkingGarage"))
local JunkyardMod = require(script:WaitForChild("decor"):WaitForChild("Junkyard"))
local BasketballCourtMod = require(script:WaitForChild("decor"):WaitForChild("BasketballCourt"))
local AirportTerminalMod = require(script:WaitForChild("decor"):WaitForChild("AirportTerminal"))
local AirportTowerMod = require(script:WaitForChild("decor"):WaitForChild("AirportTower"))
local GlassCubeStoreMod = require(script:WaitForChild("decor"):WaitForChild("GlassCubeStore"))
local FountainMod = require(script:WaitForChild("decor"):WaitForChild("Fountain"))
local JunkCarsMod = require(script:WaitForChild("decor"):WaitForChild("JunkCars"))
local ShuttleLaunchpadMod = require(script:WaitForChild("decor"):WaitForChild("ShuttleLaunchpad"))
local CommandCenterMod = require(script:WaitForChild("decor"):WaitForChild("CommandCenter"))
local FactoryMod = require(script:WaitForChild("decor"):WaitForChild("Factory"))
local NuclearPlantMod = require(script:WaitForChild("decor"):WaitForChild("NuclearPlant"))
local WarehouseMod = require(script:WaitForChild("decor"):WaitForChild("Warehouse"))
local PowerPlantMod = require(script:WaitForChild("decor"):WaitForChild("PowerPlant"))
local WaterPlantMod = require(script:WaitForChild("decor"):WaitForChild("WaterPlant"))
local ConstructionSiteMod = require(script:WaitForChild("decor"):WaitForChild("ConstructionSite"))
local HighSpeedTrackMod = require(script:WaitForChild("decor"):WaitForChild("HighSpeedTrack"))
local TrainStationMod = require(script:WaitForChild("decor"):WaitForChild("TrainStation"))
local StationPlatformMod = require(script:WaitForChild("decor"):WaitForChild("StationPlatform"))
local GolfCourseMod = require(script:WaitForChild("decor"):WaitForChild("GolfCourse"))
local MilitaryBaseMod = require(script:WaitForChild("decor"):WaitForChild("MilitaryBase"))
local MilitaryWarningMod = require(script:WaitForChild("decor"):WaitForChild("MilitaryWarning"))
local CrashedUFOMod = require(script:WaitForChild("decor"):WaitForChild("CrashedUFO"))
local WatchtowerMod = require(script:WaitForChild("decor"):WaitForChild("Watchtower"))
local NationalMallMod = require(script:WaitForChild("decor"):WaitForChild("NationalMall"))
local WhiteHouseMod = require(script:WaitForChild("decor"):WaitForChild("WhiteHouse"))
local WashingtonMonumentMod = require(script:WaitForChild("decor"):WaitForChild("WashingtonMonument"))
local MansionMod = require(script:WaitForChild("decor"):WaitForChild("Mansion"))
local MiamiBuildingMod = require(script:WaitForChild("decor"):WaitForChild("MiamiBuilding"))
local DockBuildingMod = require(script:WaitForChild("decor"):WaitForChild("DockBuilding"))
local BurningBarrelMod = require(script:WaitForChild("decor"):WaitForChild("BurningBarrel"))
local PrisonFenceMod = require(script:WaitForChild("decor"):WaitForChild("PrisonFence"))
local PrisonBuildingMod = require(script:WaitForChild("decor"):WaitForChild("PrisonBuilding"))
local SkylineApproachMod = require(script:WaitForChild("decor"):WaitForChild("SkylineApproach"))
local LobbyHallMod = require(script:WaitForChild("decor"):WaitForChild("LobbyHall"))
local TrafficLightMod = require(script:WaitForChild("decor"):WaitForChild("TrafficLight"))
local SpeedboatBuilder = require(script.Parent:WaitForChild("ProceduralVehicles"):WaitForChild("vehicles"):WaitForChild("Speedboat"))

local decorFolder = nil
local decorTemplates = nil
local NPCManager = nil -- lazy-loaded to avoid circular deps
local PLAYABLE_WIDTH = 80
local activePlatformAnimations = {} -- { [part] = { type, ... } }

--------------------------------------------------------------------------------
-- PROCEDURAL BUILDERS — local aliases wired to submodules
--------------------------------------------------------------------------------

local createTree = Tree.createTree
local createBush = Tree.createBush
local createStreetLamp = Lamp.createStreetLamp
local createBuilding = BuildingsMod.createBuilding
local createBuilding2 = BuildingsMod.createBuilding2
local createBuilding3 = BuildingsMod.createBuilding3
local createBuildingSkyscraper = SkyscrapersMod.createBuildingSkyscraper
local createBuildingSkyscraperTimesSquare = SkyscrapersMod.createBuildingSkyscraperTimesSquare
local createBuildingSkyscraperShibuya = SkyscrapersMod.createBuildingSkyscraperShibuya
local createShop = ShopsMod.createShop
local createShopLuxury = ShopsMod.createShopLuxury
local createPark = ParkMod.createPark
local createBench = ParkMod.createParkBench
local createRailTrack = RailTrackMod.createRailTrack
local createTaxiLines = AirportLinesMod.createTaxiLines
local createRunwayLines = AirportLinesMod.createRunwayLines
local createAirportTerminal = AirportTerminalMod.createAirportTerminal
local createAirportTower = AirportTowerMod.createAirportTower
local createWaterPlatformsDriftRight = WaterPlatformsMod.createWaterPlatformsDriftRight
local createWaterPlatformsDriftLeft = WaterPlatformsMod.createWaterPlatformsDriftLeft
local createWaterPlatformsWide = WaterPlatformsMod.createWaterPlatformsWide
local createWaterPlatformsSinking = WaterPlatformsMod.createWaterPlatformsSinking
local createWaterPlatformsRotating = WaterPlatformsMod.createWaterPlatformsRotating
local createWaterPlatformsMill = WaterPlatformsMod.createWaterPlatformsMill
local createWaterPlatformsConveyor = WaterPlatformsMod.createWaterPlatformsConveyor
local createWaterPlatformsSwamp = WaterPlatformsMod.createWaterPlatformsSwamp
local createJunkyard = JunkyardMod.createJunkyard
local createBasketballCourt = BasketballCourtMod.createBasketballCourt
local createHoodBuilding = HoodBuildingMod.createHoodBuilding
local createParkingGarage = ParkingGarageMod.createParkingGarage
local createBridgeRailings = BridgeMod.createBridgeRailings
local createBridgePillars = BridgeMod.createBridgePillars
local createBillboard = BillboardMod.createBillboard
local createGlassCubeStore = GlassCubeStoreMod.createGlassCubeStore
local createFountain = FountainMod.createFountain
local createJunkCars = JunkCarsMod.createJunkCars
local createShuttleLaunchpad = ShuttleLaunchpadMod.createShuttleLaunchpad
local createCommandCenter = CommandCenterMod.createCommandCenter
local createFactory = FactoryMod.createFactory
local createNuclearPlant = NuclearPlantMod.createNuclearPlant
local createWarehouse = WarehouseMod.createWarehouse
local createPowerPlant = PowerPlantMod.createPowerPlant
local createWaterPlant = WaterPlantMod.createWaterPlant
local createConstructionSite = ConstructionSiteMod.createConstructionSite
local createHighSpeedTrack = HighSpeedTrackMod.createHighSpeedTrack
local createStationHall = TrainStationMod.createStationHall
local createStationPlatform = StationPlatformMod.createStationPlatform
local createGolfCourse = GolfCourseMod.createGolfCourse
local createMilitaryBase = MilitaryBaseMod.createMilitaryBase
local createMilitaryWarning = MilitaryWarningMod.createMilitaryWarning
local createCrashedUFO = CrashedUFOMod.createCrashedUFO
local createWatchtower = WatchtowerMod.createWatchtower
local createSingleWatchtower = WatchtowerMod.createSingleTower
local createNationalMall = NationalMallMod.createNationalMall
local createWhiteHouse = WhiteHouseMod.createWhiteHouse
local createWashingtonMonument = WashingtonMonumentMod.createWashingtonMonument
local createMansion = MansionMod.createMansion
local createMiamiBuilding = MiamiBuildingMod.createRandom
local createMiamiBuildingPink = MiamiBuildingMod.createPink
local createMiamiBuildingMint = MiamiBuildingMod.createMint
local createMiamiBuildingCream = MiamiBuildingMod.createCream
local createMiamiBuildingCoral = MiamiBuildingMod.createCoral
local createMiamiBuildingLavender = MiamiBuildingMod.createLavender
local createMiamiBuildingBlue = MiamiBuildingMod.createBlue
local createDockBuilding = DockBuildingMod.createRandom
local createDockBuildingBrick = DockBuildingMod.createBrick
local createDockBuildingConcrete = DockBuildingMod.createConcrete
local createDockBuildingRust = DockBuildingMod.createRust
local createDockBuildingBlueSteel = DockBuildingMod.createBlueSteel
local createDockBuildingOlive = DockBuildingMod.createOlive
local createDockBuildingTan = DockBuildingMod.createTan
local createBurningBarrel = BurningBarrelMod.create
local createPrisonBuilding = PrisonBuildingMod.createPrisonBuilding
local createSkylineWall = SkylineApproachMod.createSkylineWall
local createSkylineGlassBlue = SkylineApproachMod.createGlassBlue
local createSkylineCityGrid = SkylineApproachMod.createCityGrid
local createLobbyHall = LobbyHallMod.createLobbyHall
local createPoleTrafficLight = TrafficLightMod.createPoleLight
local createOverheadTrafficLight = TrafficLightMod.createOverheadLight

-- Speedboat display (showroom decor — places procedural Speedboat model with 2 NPCs)
local function createSpeedboatDisplay(x, z, scale, offsetY)
	local boat = SpeedboatBuilder.build()
	scale = scale or 1
	offsetY = offsetY or 0
	-- Rotate 90° so broadside faces the player running in +Z
	boat:PivotTo(CFrame.new(x, offsetY, z) * CFrame.Angles(0, math.rad(90), 0))
	if scale ~= 1 then
		for _, part in boat:GetDescendants() do
			if part:IsA("BasePart") then
				part.Size = part.Size * scale
			end
		end
	end
	boat.Parent = decorFolder

	-- Spawn 2 NPCs on the bench (side-by-side)
	if NPCManager then
		local facing = CFrame.Angles(0, math.rad(180), 0)
		NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), boat,
			CFrame.new(SpeedboatBuilder.DRIVER_X, SpeedboatBuilder.SEAT_Y, SpeedboatBuilder.SEAT_Z) * facing)
		NPCManager.spawnSeatedInVehicle(NPCManager.randomCivilian(), boat,
			CFrame.new(SpeedboatBuilder.PASSENGER_X, SpeedboatBuilder.SEAT_Y, SpeedboatBuilder.PASSENGER_Z) * facing)
	end

	return boat
end

local PROCEDURAL_BUILDERS = {
	tree = createTree,
	bush = createBush,
	lamp = createStreetLamp,
	building = createBuilding,
	building2 = createBuilding2,
	building3 = createBuilding3,
	skyscraper = createBuildingSkyscraper,
	skyscraper_times_square = createBuildingSkyscraperTimesSquare,
	skyscraper_shibuya = createBuildingSkyscraperShibuya,
	shop = createShop,
	shop_luxury = createShopLuxury,
	park = createPark,
	bench = createBench,
	railtrack = createRailTrack,
	taxilines = createTaxiLines,
	runwaylines = createRunwayLines,
	airport_terminal = createAirportTerminal,
	airport_tower = createAirportTower,
	water_platforms_drift_right = createWaterPlatformsDriftRight,
	water_platforms_drift_left = createWaterPlatformsDriftLeft,
	water_platforms_wide = createWaterPlatformsWide,
	water_platforms_sinking = createWaterPlatformsSinking,
	water_platforms_rotating = createWaterPlatformsRotating,
	water_platforms_mill = createWaterPlatformsMill,
	water_platforms_conveyor = createWaterPlatformsConveyor,
	water_platforms_swamp = createWaterPlatformsSwamp,
	junkyard = createJunkyard,
	basketball_court = createBasketballCourt,
	hood_building = createHoodBuilding,
	parking_garage = createParkingGarage,
	bridge_railings = createBridgeRailings,
	bridge_pillars = createBridgePillars,
	billboard = createBillboard,
	glass_cube_store = createGlassCubeStore,
	fountain = createFountain,
	junk_cars = createJunkCars,
	shuttle_launchpad = createShuttleLaunchpad,
	command_center = createCommandCenter,
	factory = createFactory,
	nuclear_plant = createNuclearPlant,
	warehouse = createWarehouse,
	power_plant = createPowerPlant,
	water_plant = createWaterPlant,
	construction_site = createConstructionSite,
	highspeed_track = createHighSpeedTrack,
	station_hall = createStationHall,
	station_platform = createStationPlatform,
	golf_course = createGolfCourse,
	military_base = createMilitaryBase,
	military_warning = createMilitaryWarning,
	crashed_ufo = createCrashedUFO,
	watchtower = createWatchtower,
	prison_tower = createSingleWatchtower,
	national_mall = createNationalMall,
	whitehouse = createWhiteHouse,
	washington_monument = createWashingtonMonument,
	mansion = createMansion,
	lobby_hall = createLobbyHall,
	miami_building = createMiamiBuilding,
	miami_building_pink = createMiamiBuildingPink,
	miami_building_mint = createMiamiBuildingMint,
	miami_building_cream = createMiamiBuildingCream,
	miami_building_coral = createMiamiBuildingCoral,
	miami_building_lavender = createMiamiBuildingLavender,
	miami_building_blue = createMiamiBuildingBlue,
	dock_building = createDockBuilding,
	dock_building_brick = createDockBuildingBrick,
	dock_building_concrete = createDockBuildingConcrete,
	dock_building_rust = createDockBuildingRust,
	dock_building_bluesteel = createDockBuildingBlueSteel,
	dock_building_olive = createDockBuildingOlive,
	dock_building_tan = createDockBuildingTan,
	burning_barrel = createBurningBarrel,
	prison_building = createPrisonBuilding,
	skyline_wall = createSkylineWall,
	skyline_glass_blue = createSkylineGlassBlue,
	skyline_city_grid = createSkylineCityGrid,
	speedboat_display = createSpeedboatDisplay,
	traffic_light_pole = createPoleTrafficLight,
	traffic_light_overhead = createOverheadTrafficLight,
}

--------------------------------------------------------------------------------
-- PUBLIC API
--------------------------------------------------------------------------------

-- Initialize with workspace folder and template folder references
function DecorCreation.init(folder, templates)
	decorFolder = folder
	decorTemplates = templates
	-- Sync shared state to DecorUtils so extracted modules can access it
	DecorUtils.decorFolder = folder
	DecorUtils.decorTemplates = templates
	DecorUtils.activePlatformAnimations = activePlatformAnimations
	-- Lazy-load NPCManager (avoid circular require at module top)
	if not NPCManager then
		local ok, mod = pcall(function()
			return require(script.Parent:WaitForChild("NPCManager"))
		end)
		if ok and mod then
			NPCManager = mod
			DecorUtils.NPCManager = mod
		end
	end

	-- Preload skyline building templates (build once, clone later for instant placement)
	SkylineApproachMod.preloadTemplates()

	-- Build diorama preview templates for client ThemeSelect
	DecorCreation.buildDioramaTemplates()
end

-- Place a single decor asset at (x, z) with scale.
-- Tries DecorTemplates first, then procedural fallback.
function DecorCreation.place(assetName, x, z, scale, offsetY)
	if not decorFolder then return nil end
	scale = scale or 1
	offsetY = offsetY or 0

	-- Try template first
	if decorTemplates then
		local template = decorTemplates:FindFirstChild(assetName)
		if template then
			local decor = template:Clone()
			if decor:IsA("Model") then
				local cf = CFrame.new(x, offsetY, z)
				decor:PivotTo(cf)
				if scale ~= 1 then
					for _, part in pairs(decor:GetDescendants()) do
						if part:IsA("BasePart") then
							part.Size = part.Size * scale
						end
					end
				end
			elseif decor:IsA("BasePart") then
				decor.Position = Vector3.new(x, decor.Size.Y / 2, z)
				if scale ~= 1 then
					decor.Size = decor.Size * scale
				end
			end
			-- Anchor all parts
			for _, part in pairs(decor:IsA("Model") and decor:GetDescendants() or {decor}) do
				if part:IsA("BasePart") then
					part.Anchored = true
				end
			end
			decor.Parent = decorFolder
			return decor
		end
	end

	-- Procedural fallback
	local builder = PROCEDURAL_BUILDERS[assetName]
	if builder then
		return builder(x, z, scale, offsetY)
	end

	warn("[DecorCreation] No template or builder for: " .. tostring(assetName))
	return nil
end

-- Place all decor entries for a lane at laneZ.
-- Reads the decor array and handles side/chance/scale per entry.
function DecorCreation.placeForLane(decorEntries, laneZ)
	if not decorFolder or not decorEntries then return end
	local half = PLAYABLE_WIDTH / 2

	for _, entry in ipairs(decorEntries) do
		local chance = entry.chance or 1
		local offsetX = entry.offsetX or 12
		local oY = entry.offsetY or 0
		local scaleMin = entry.scaleMin or entry.scale or 1
		local scaleMax = entry.scaleMax or entry.scale or 1
		local side = entry.side or "both"

		if side == "center" then
			if math.random() <= chance then
				local s = scaleMin + math.random() * (scaleMax - scaleMin)
				DecorCreation.place(entry.asset, 0, laneZ, s, oY)
			end
		end
		if side == "left" or side == "both" then
			if math.random() <= chance then
				local s = scaleMin + math.random() * (scaleMax - scaleMin)
				DecorCreation.place(entry.asset, -(half + offsetX), laneZ, s, oY)
			end
		end
		if side == "right" or side == "both" then
			if math.random() <= chance then
				local s = scaleMin + math.random() * (scaleMax - scaleMin)
				DecorCreation.place(entry.asset, half + offsetX, laneZ, s, oY)
			end
		end
	end
end

-- Public API: let other modules register platform animations
function DecorCreation.registerAnimation(part, data)
	activePlatformAnimations[part] = data
end

-- Update animated platforms each frame
function DecorCreation.update(deltaTime)
	local currentTime = tick()
	for part, data in pairs(activePlatformAnimations) do
		if not part or not part.Parent then
			activePlatformAnimations[part] = nil
			continue
		end
		if data.type == "sinking" then
			local cd = data.cycleDuration
			local sd = data.sinkDuration or 0.5 -- how long the sink/rise transition takes
			local phase = (currentTime + data.phaseOffset) % cd
			local safeTime = cd * 0.5 -- half cycle is safe
			if phase < safeTime then
				part.Position = Vector3.new(part.Position.X, data.baseY, part.Position.Z)
				part.Transparency = 0
				part.CanCollide = true
			elseif phase < safeTime + sd then
				local t = (phase - safeTime) / sd
				t = t * t * (3 - 2 * t) -- smoothstep ease
				local y = data.baseY + (data.sunkY - data.baseY) * t
				part.Position = Vector3.new(part.Position.X, y, part.Position.Z)
				part.Transparency = 0.7 * t
				part.CanCollide = t < 0.5
			elseif phase < cd - sd then
				part.Position = Vector3.new(part.Position.X, data.sunkY, part.Position.Z)
				part.Transparency = 0.7
				part.CanCollide = false
			else
				local t = (phase - (cd - sd)) / sd
				t = t * t * (3 - 2 * t) -- smoothstep ease
				local y = data.sunkY + (data.baseY - data.sunkY) * t
				part.Position = Vector3.new(part.Position.X, y, part.Position.Z)
				part.Transparency = 0.7 * (1 - t)
				part.CanCollide = t > 0.5
			end
		elseif data.type == "rotating" then
			data.angle = data.angle + data.speed * deltaTime
			part.CFrame = CFrame.new(data.centerX, data.centerY, data.centerZ) * CFrame.Angles(0, data.angle, 0)
		elseif data.type == "mill" then
			local angle = math.sin(currentTime * data.oscillateSpeed + data.phaseOffset) * data.maxAngle
			part.CFrame = CFrame.new(data.centerX, data.centerY, data.centerZ) * CFrame.Angles(angle, 0, 0)
		elseif data.type == "drifting" then
			local newX = part.Position.X + data.speed * deltaTime
			-- Wrap around when platform exits the playable area
			if data.speed > 0 and newX > data.maxX then
				newX = newX - data.wrapWidth
			elseif data.speed < 0 and newX < data.minX then
				newX = newX + data.wrapWidth
			end
			part.Position = Vector3.new(newX, data.baseY, data.baseZ)
		elseif data.type == "conveyor" then
			part.OffsetStudsU = part.OffsetStudsU + data.speed * deltaTime
		elseif data.type == "elevator" then
			local range = data.maxY - data.minY
			local cycleTime = range / data.speed * 2
			local phase = ((currentTime + data.phaseOffset) % cycleTime) / cycleTime
			local t = phase < 0.5 and (phase * 2) or (2 - phase * 2)
			t = t * t * (3 - 2 * t)
			local y = data.minY + t * range
			part.Position = Vector3.new(data.baseX, y, data.baseZ)
			local floorY = y - data.elevH / 2 + 0.1
			if data.linkedParts then
				for _, linked in ipairs(data.linkedParts) do
					if linked and linked.Parent then
						local ly
						if linked.Name == "ElevatorFloor" then
							ly = floorY
						elseif linked.Name == "ElevatorLight" then
							ly = y + data.elevH / 2 - 0.2
						end
						if ly then
							linked.Position = Vector3.new(data.baseX, ly, data.baseZ)
						end
					end
				end
			end
			if data.npcModel and data.npcModel.Parent and data.npcFaceCFrame then
				data.npcModel:PivotTo(
					CFrame.new(data.baseX, floorY + 3, data.baseZ) * data.npcFaceCFrame
				)
			end
		elseif data.type == "drawbridge" then
			local CYCLE = 12
			local phase = (currentTime + data.phaseOffset) % CYCLE
			local angle = 0
			local MAX_ANGLE = math.rad(70)

			if phase < 5 then
				angle = 0
			elseif phase < 6 then
				local t = (phase - 5) / 1
				angle = MAX_ANGLE * t * t * (3 - 2 * t)
			elseif phase < 9 then
				angle = MAX_ANGLE
			elseif phase < 10 then
				local t = (phase - 9) / 1
				angle = MAX_ANGLE * (1 - t * t * (3 - 2 * t))
			else
				angle = 0
			end

			local isOpen = angle > math.rad(5)
			part.CFrame = data.frontHinge * CFrame.Angles(-angle, 0, 0) * CFrame.new(0, 0, -data.halfDepth / 2)
			part.CanCollide = not isOpen
			if data.backPart and data.backPart.Parent then
				data.backPart.CFrame = data.backHinge * CFrame.Angles(angle, 0, 0) * CFrame.new(0, 0, data.halfDepth / 2)
				data.backPart.CanCollide = not isOpen
			end
		elseif data.type == "ticker" then
			data.offset = data.offset + data.speed * deltaTime
			if data.offset > 2.0 then
				data.offset = data.offset - 2.0
			end
			part.Position = UDim2.new(-data.offset, 0, 0, 0)
		elseif data.type == "ad_rotate" then
			if currentTime - data.lastSwitch >= data.interval then
				data.lastSwitch = currentTime
				data.idx = data.idx % #data.slides + 1
				local slide = data.slides[data.idx]
				if data.label and data.label.Parent then
					data.label.Text = slide.text
				end
				if data.frame and data.frame.Parent then
					data.frame.BackgroundColor3 = slide.color
				end
			end
		elseif data.type == "mission_control" then
			-- Update ~2x per second for a realistic data-refresh feel
			local now = currentTime
			if now - data.lastTick >= 0.5 then
				data.lastTick = now

				-- Countdown timer (cycles every 10 minutes = 600s)
				local elapsed = now - data.startTime
				local remaining = 600 - (elapsed % 600)
				local mins = math.floor(remaining / 60)
				local secs = math.floor(remaining % 60)
				local frac = math.floor((remaining * 100) % 100)
				data.countdownLabel.Text = string.format("T- %02d:%02d.%02d", mins, secs, frac)

				-- Fluctuate telemetry values
				for _, lbl in data.valueLabels do
					local name = lbl.Name
					if name == "ALTValue" then
						lbl.Text = string.format("%.3f km", 0.000 + math.random() * 0.002)
					elseif name == "VELValue" then
						lbl.Text = string.format("%.3f km/s", math.random() * 0.001)
					elseif name == "ACCValue" then
						lbl.Text = string.format("%.2f g", 0.98 + math.random() * 0.04)
					elseif name == "FUELValue" then
						lbl.Text = string.format("%.1f%%", 99.5 + math.random() * 0.5)
					elseif name == "TEMPValue" then
						lbl.Text = string.format("%.1f C", 21.5 + math.random() * 2)
					elseif name == "PITCHValue" then
						lbl.Text = string.format("%.2f deg", 89.95 + math.random() * 0.1)
					elseif name == "YAWValue" then
						lbl.Text = string.format("%.2f deg", -0.05 + math.random() * 0.1)
					elseif name == "ROLLValue" then
						lbl.Text = string.format("%.2f deg", -0.03 + math.random() * 0.06)
					end
				end
			end
		elseif data.type == "launch_warning" then
			-- Pulse diode lights (on/off every 0.6s)
			local pulse = math.floor(currentTime / 0.6) % 2
			for _, diode in data.diodes do
				if diode and diode.Parent then
					diode.Transparency = pulse == 0 and 0 or 0.8
					local light = diode:FindFirstChildWhichIsA("PointLight")
					if light then
						light.Brightness = pulse == 0 and 2 or 0.1
					end
				end
			end

			-- Cycle warning messages every 3 seconds
			if currentTime - data.lastTick >= 3 then
				data.lastTick = currentTime
				local messages = data.messages or {
					{ main = "LAUNCH AREA", sub = "KEEP CLEAR", mainColor = Color3.fromRGB(255, 60, 30), subColor = Color3.fromRGB(0, 200, 255) },
					{ main = "⚠ DANGER ⚠", sub = "ACTIVE PAD", mainColor = Color3.fromRGB(255, 200, 0), subColor = Color3.fromRGB(255, 80, 40) },
					{ main = "T-MINUS", sub = "LAUNCHING SOON", mainColor = Color3.fromRGB(255, 60, 30), subColor = Color3.fromRGB(0, 255, 120) },
					{ main = "RESTRICTED", sub = "AUTHORIZED ONLY", mainColor = Color3.fromRGB(255, 40, 20), subColor = Color3.fromRGB(200, 200, 200) },
					{ main = "STAND BY", sub = "FUELING IN PROGRESS", mainColor = Color3.fromRGB(0, 200, 255), subColor = Color3.fromRGB(255, 200, 0) },
				}
				data.phase = (data.phase + 1) % #messages
				local msg = messages[data.phase + 1]
				for _, lbl in data.warningLabels do
					if lbl and lbl.Parent then
						lbl.Text = msg.main
						lbl.TextColor3 = msg.mainColor
					end
				end
				for _, lbl in data.subLabels do
					if lbl and lbl.Parent then
						lbl.Text = msg.sub
						lbl.TextColor3 = msg.subColor
					end
				end
			end
		elseif data.type == "hazard_pulse" then
			-- Pulsing yellow hazard lights (smooth sine wave)
			local glow = (math.sin(currentTime * 3) + 1) / 2  -- 0..1
			for _, light in data.lights do
				if light and light.Parent then
					light.Transparency = 0.2 + (1 - glow) * 0.6
					local pl = light:FindFirstChildWhichIsA("PointLight")
					if pl then
						pl.Brightness = 0.3 + glow * 2
					end
				end
			end

		elseif data.type == "rocket_launch" then
			-- Rocket launch cycle: idle → countdown → steam → liftoff → hidden → reset
			local CYCLE = 40
			local IDLE = 5         -- quiet standby
			local COUNTDOWN = 5    -- 5, 4, 3, 2, 1
			local STEAM = 3        -- pre-launch venting
			local LAUNCH_DUR = 13
			local SMOKE_LINGER = 4
			local MAX_H = 600

			local elapsed = (currentTime - data.startTime) % CYCLE
			local cdLabel = data.countdownLabel

			if elapsed < IDLE then
				-- Quiet standby
				if data.state ~= "idle" then
					data.rocketModel:PivotTo(data.initialPivot)
					data.exhaustEmitter.Enabled = false
					data.smokeEmitter.Enabled = false
					data.steamEmitter.Enabled = false
					data.state = "idle"
				end
				if cdLabel then
					cdLabel.Text = "STANDBY"
					cdLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
				end
			elseif elapsed < IDLE + COUNTDOWN then
				-- Countdown: 5, 4, 3, 2, 1
				data.state = "countdown"
				if cdLabel then
					local num = COUNTDOWN - math.floor(elapsed - IDLE)
					cdLabel.Text = tostring(num)
					-- Color shifts from cyan → yellow → red
					local t = (elapsed - IDLE) / COUNTDOWN
					local r = math.floor(50 + 205 * t)
					local g = math.floor(255 * (1 - t * 0.7))
					local b = math.floor(255 * (1 - t))
					cdLabel.TextColor3 = Color3.fromRGB(r, g, b)
				end
			elseif elapsed < IDLE + COUNTDOWN + STEAM then
				-- Pre-launch: steam venting
				if data.state ~= "steam" then
					data.steamEmitter.Enabled = true
					data.state = "steam"
				end
				if cdLabel then
					cdLabel.Text = "IGNITION"
					cdLabel.TextColor3 = Color3.fromRGB(255, 40, 20)
				end
			elseif elapsed < IDLE + COUNTDOWN + STEAM + LAUNCH_DUR then
				-- Liftoff with exhaust + ground smoke
				if data.state ~= "launch" then
					data.exhaustEmitter.Enabled = true
					data.smokeEmitter.Enabled = true
					data.steamEmitter.Enabled = false
					data.state = "launch"
				end
				local t = (elapsed - IDLE - COUNTDOWN - STEAM) / LAUNCH_DUR
				local offset = MAX_H * t * t * t
				data.rocketModel:PivotTo(data.initialPivot + Vector3.new(0, offset, 0))
				if cdLabel then
					cdLabel.Text = "LIFTOFF!"
					cdLabel.TextColor3 = Color3.fromRGB(255, 160, 30)
				end
			elseif elapsed < IDLE + COUNTDOWN + STEAM + LAUNCH_DUR + SMOKE_LINGER then
				-- Rocket gone, smoke lingers on pad
				if data.state ~= "linger" then
					data.rocketModel:PivotTo(data.initialPivot + Vector3.new(0, 2000, 0))
					data.exhaustEmitter.Enabled = false
					data.smokeEmitter.Enabled = false
					data.state = "linger"
				end
				if cdLabel then
					cdLabel.Text = "CLEAR"
					cdLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
				end
			else
				-- Hidden, waiting for next cycle
				if data.state ~= "hidden" then
					data.state = "hidden"
				end
				if cdLabel then
					cdLabel.Text = "STANDBY"
					cdLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
				end
			end

			-- Animate blast gate: open after launch, closed otherwise
			if data.gatePart and data.gatePart.Parent then
				local gateOpen = (data.state == "linger" or data.state == "hidden")
				local targetY = gateOpen and data.gateOpenY or data.gateClosedY
				local curY = data.gatePart.Position.Y
				local newY = curY + (targetY - curY) * math.min(1, deltaTime * 2.5)
				if math.abs(targetY - newY) < 0.1 then newY = targetY end
				data.gatePart.Position = Vector3.new(0, newY, data.gatePart.Position.Z)
				data.gatePart.CanCollide = not gateOpen
			end
		elseif data.type == "radiation_pulse" then
			local pulse = (math.sin(currentTime * 3) + 1) / 2
			for _, blade in data.blades do
				if blade and blade.Parent then
					blade.Transparency = 0.15 * (1 - pulse)
				end
			end
			if data.light and data.light.Parent then
				data.light.Brightness = 1.0 + 2.0 * pulse
				data.light.Range = 10 + 8 * pulse
			end
			if data.centerDot and data.centerDot.Parent then
				data.centerDot.Transparency = 0.2 * (1 - pulse)
			end
			if data.borderRing and data.borderRing.Parent then
				data.borderRing.Transparency = 0.2 + 0.3 * (1 - pulse)
			end
		elseif data.type == "electrical_arc" then
			-- Randomize beam curves every frame for chaotic dancing arcs
			local s = data.baseScale
			local r1 = (math.random() - 0.5) * 12 * s
			local r2 = (math.random() - 0.5) * 12 * s
			if data.beam1 and data.beam1.Parent then
				data.beam1.CurveSize0 = r1
				data.beam1.CurveSize1 = r2
			end
			if data.beam2 and data.beam2.Parent then
				data.beam2.CurveSize0 = -r2
				data.beam2.CurveSize1 = r1 * 0.7
			end
			-- Pulse glow lights with the arcs
			local flicker = 0.6 + 0.4 * math.random()
			if data.glow1 and data.glow1.Parent then
				data.glow1.Brightness = 2 * flicker
				data.glow1.Range = 14 + 8 * flicker
			end
			if data.glow2 and data.glow2.Parent then
				data.glow2.Brightness = 2 * flicker
				data.glow2.Range = 14 + 8 * flicker
			end
		elseif data.type == "clarifier_arm" then
			data.angle = data.angle + data.speed * deltaTime
			part.CFrame = CFrame.new(data.centerX, data.centerY, data.centerZ)
				* CFrame.Angles(0, data.angle, 0)
				* CFrame.new(data.armOffset, 0, 0)
		elseif data.type == "station_clock" then
			-- Analog clock: 3D hand parts rotated via CFrame
			local t = currentTime
			local seconds = t % 60
			local minutes = (t / 60) % 60
			local hours = (t / 3600) % 12

			local cx, cy, cz = data.centerX, data.centerY, data.centerZ

			-- Hour hand: rotates clockwise, pivots from center
			local hAngle = math.rad(hours * 30 + minutes * 0.5)
			if data.hourHand and data.hourHand.Parent then
				data.hourHand.CFrame = CFrame.new(cx, cy, cz + 0.8)
					* CFrame.Angles(0, 0, -hAngle)
					* CFrame.new(0, data.hourLen / 2, 0)
			end

			-- Minute hand: rotates clockwise, pivots from center
			local mAngle = math.rad(minutes * 6 + seconds * 0.1)
			if data.minuteHand and data.minuteHand.Parent then
				data.minuteHand.CFrame = CFrame.new(cx, cy, cz + 0.9)
					* CFrame.Angles(0, 0, -mAngle)
					* CFrame.new(0, data.minuteLen / 2, 0)
			end
		elseif data.type == "departure_board" then
			-- Cycle train statuses every 3 seconds
			if currentTime - data.lastTick >= 3 then
				data.lastTick = currentTime

				local statuses = {
					{ text = "ON TIME",   color = Color3.fromRGB(0, 255, 120) },
					{ text = "BOARDING",  color = Color3.fromRGB(255, 200, 0) },
					{ text = "DELAYED",   color = Color3.fromRGB(255, 80, 40) },
					{ text = "DEPARTED",  color = Color3.fromRGB(100, 110, 130) },
					{ text = "ON TIME",   color = Color3.fromRGB(0, 255, 120) },
					{ text = "ARRIVING",  color = Color3.fromRGB(0, 200, 255) },
				}

				-- Each row cycles at a different rate based on elapsed time
				local elapsed = currentTime - data.startTime
				for i, lbl in ipairs(data.statusLabels) do
					if lbl and lbl.Parent then
						local offset = math.floor((elapsed / 3) + i * 1.7) % #statuses
						local s = statuses[offset + 1]
						lbl.Text = s.text
						lbl.TextColor3 = s.color
					end
				end

				-- Update clock
				if data.clockLabel and data.clockLabel.Parent then
					local mins = math.floor(elapsed / 60)
					local secs = math.floor(elapsed) % 60
					local h = (8 + math.floor(mins / 60)) % 24
					local m = (14 + mins) % 60
					local messages = {
						"WELCOME  |  ALL SERVICES RUNNING",
						"MIND THE GAP  |  STAY BEHIND THE LINE",
						"NEXT: TGV 6201 TO PARIS",
						"INFORMATION  |  TICKET OFFICE LEVEL 0",
						"WI-FI AVAILABLE  |  STATION_FREE",
					}
					local msgIdx = (math.floor(elapsed / 5) % #messages) + 1
					data.clockLabel.Text = string.format("%02d:%02d  |  %s", h, m, messages[msgIdx])
				end
			end
		elseif data.type == "crane_boom" then
			data.angle = data.angle + data.speed * deltaTime
			part.CFrame = CFrame.new(data.centerX, data.centerY, data.centerZ)
				* CFrame.Angles(0, data.angle, 0)
				* CFrame.new(data.armOffset, 0, 0)
			if data.linkedParts then
				for _, linked in ipairs(data.linkedParts) do
					if linked.part and linked.part.Parent then
						local cf = CFrame.new(data.centerX, data.centerY + (linked.offsetY or 0), data.centerZ)
							* CFrame.Angles(0, data.angle, 0)
							* CFrame.new(linked.offsetX or 0, 0, 0)
						if linked.tiltAngle then
							cf = cf * CFrame.Angles(0, 0, linked.tiltAngle)
						end
						linked.part.CFrame = cf
					end
				end
			end
		elseif data.type == "searchlight" then
			data.angle = data.angle + data.speed * deltaTime
			part.CFrame = CFrame.new(data.centerX, data.centerY, data.centerZ)
				* CFrame.Angles(0, data.angle, 0)
				* CFrame.Angles(math.rad(data.tiltDeg), 0, 0)
			if data.beamTarget and data.beamTarget.Parent then
				data.beamTarget.Position = Vector3.new(
					data.centerX + math.sin(data.angle) * data.beamRange,
					data.groundY,
					data.centerZ + math.cos(data.angle) * data.beamRange
				)
			end
		end
	end
end

-- Clear all decor
function DecorCreation.clearAll()
	activePlatformAnimations = {}
	DecorUtils.activePlatformAnimations = activePlatformAnimations
	if decorFolder then
		for _, child in ipairs(decorFolder:GetChildren()) do
			child:Destroy()
		end
	end
end

-- Prison fence exports (special signature, called directly from WorldLoader)
DecorCreation.createPrisonFenceRun = PrisonFenceMod.createFenceRun
DecorCreation.createPrisonGate = PrisonFenceMod.createGate
DecorCreation.openLobbyDoor = LobbyHallMod.openDoor

-- Build small diorama templates for client-side ThemeSelect preview.
-- Uses real builders so the preview matches actual game geometry.
function DecorCreation.buildDioramaTemplates()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local folder = Instance.new("Folder")
	folder.Name = "DioramaTemplates"

	local S = 0.5 -- diorama scale

	-- Tree (built at origin, client repositions)
	local tree = Tree.createTree(0, 0, S)
	if tree then tree.Name = "DioramaTree"; tree.Parent = folder end

	-- Second tree (different spot)
	local tree2 = Tree.createTree(0, 0, S * 0.8)
	if tree2 then tree2.Name = "DioramaTree2"; tree2.Parent = folder end

	-- Bush
	local bush = Tree.createBush(0, 0, S)
	if bush then bush.Name = "DioramaBush"; bush.Parent = folder end

	-- Lamp
	local lamp = Lamp.createStreetLamp(0, 0, S)
	if lamp then lamp.Name = "DioramaLamp"; lamp.Parent = folder end

	-- Shop (z-facing, glass faces +Z toward camera)
	local shop = ShopsMod.buildShopUnit(0, 0, S, 20 * S, "z", {})
	if shop then shop.Name = "DioramaShop"; shop.Parent = folder end

	-- Second shop
	local shop2 = ShopsMod.buildShopUnit(0, 0, S, 18 * S, "z", {})
	if shop2 then shop2.Name = "DioramaShop2"; shop2.Parent = folder end

	folder.Parent = ReplicatedStorage
	print("[DecorCreation] Diorama templates built:", #folder:GetChildren(), "models")
end

-- Legacy exports for buildMap() and other existing code
DecorCreation.createTree = createTree
DecorCreation.createBush = createBush
DecorCreation.createStreetLamp = createStreetLamp
DecorCreation.createBuilding = createBuilding

return DecorCreation
