local VU = require(script.Parent:WaitForChild("VehicleUtils"))

local Convertible = {}

--------------------------------------------------------------------------------
-- OUTRUN-STYLE CONVERTIBLE (faces +Z forward, wheels on ground at Y=0)
-- Player-drivable sports car. Built iteratively:
-- Phase 1: Chassis + Seat + Steering wheel (functional core)
-- Phase 2: Wheels
-- Phase 3: Body panels
-- Phase 4: Details (lights, mirrors, etc.)
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- R15 SEATED REFERENCE (from Sedan.luau):
-- - HumanoidRootPart (HRP) = SEAT_Y position
-- - Head top = SEAT_Y + 2.1 studs
-- - Feet = SEAT_Y - 1.5 studs
-- So for feet to be hidden by chassis at Y=1.8, SEAT_Y should be ~3.3+
--------------------------------------------------------------------------------

-- Core dimensions (OutRun Ferrari Testarossa style)
local CHASSIS_LENGTH = 18      -- long sports car (extended hood)
local CHASSIS_WIDTH = 8        -- wider to fit 2 seats + arms
local FLOOR_Y = 1.5            -- raised floor (feet at ~1.7 will be inside)

-- Seat positions (left-hand drive: driver on LEFT side)
local DRIVER_X = -1.5          -- left side (European/French)
local PASSENGER_X = 1.5        -- right side
local SEAT_Z = -0.5            -- slightly back so legs don't clip with seat
local SEAT_CUSHION_Y = FLOOR_Y + 0.8  -- seat cushion surface = 2.3

-- Export for NPC seating (HRP position for R15)
-- HRP at 3.2 → feet at 1.7 (inside car), head at 5.3 (visible for convertible)
Convertible.FLOOR_Y = FLOOR_Y
Convertible.SEAT_Y = 3.5
Convertible.DRIVER_X = DRIVER_X
Convertible.PASSENGER_X = PASSENGER_X
Convertible.SEAT_Z = SEAT_Z

--------------------------------------------------------------------------------
-- COLORS
--------------------------------------------------------------------------------
local C_CHASSIS = Color3.fromRGB(40, 40, 45)       -- dark chassis
local C_SEAT = Color3.fromRGB(180, 40, 40)         -- red leather seats (like reference)
local C_SEAT_FRAME = Color3.fromRGB(30, 30, 35)    -- black seat frame
local C_STEERING = Color3.fromRGB(25, 25, 30)      -- steering wheel
local C_METAL = Color3.fromRGB(60, 60, 65)         -- metal accents
local C_TIRE = Color3.fromRGB(25, 25, 25)          -- black tire
local C_RIM = Color3.fromRGB(200, 200, 205)        -- bright silver rim (for chrome)
local C_RIM_DARK = Color3.fromRGB(60, 60, 65)      -- dark rim accent
local C_BODY = Color3.fromRGB(240, 240, 245)       -- white body (like reference)
local C_TRIM = Color3.fromRGB(30, 30, 35)          -- black trim

--------------------------------------------------------------------------------
-- BUILD FUNCTION
--------------------------------------------------------------------------------
function Convertible.build()
	local model = Instance.new("Model")
	model.Name = "Convertible_1"

	local frontZ = CHASSIS_LENGTH / 2      -- 7
	local rearZ = -CHASSIS_LENGTH / 2      -- -7
	local halfW = CHASSIS_WIDTH / 2        -- 3

	---------------------------------------------------------------------------
	-- PHASE 1: CHASSIS (floor + sides for feet to be hidden)
	---------------------------------------------------------------------------
	-- Floor plate
	local chassis = VU.part(model, "Chassis",
		Vector3.new(CHASSIS_WIDTH, 0.4, CHASSIS_LENGTH),
		CFrame.new(0, FLOOR_Y, 0),
		C_CHASSIS, Enum.Material.Metal)

	local sideH = 1.5  -- door sill height (used by rear deck calc too)
	local sideBottomY = FLOOR_Y + 0.21  -- just above chassis top

	---------------------------------------------------------------------------
	-- PHASE 1: SEATS (driver left, passenger right)
	---------------------------------------------------------------------------
	local seatBackHeight = 2.5
	local seatBackAngle = math.rad(-15)
	local seatWidth = 2.0  -- narrower to fit 2 seats

	-- Helper to create a bucket seat at given X position
	local function createSeat(name, seatX)
		-- Seat base (cushion)
		VU.part(model, name .. "_Base",
			Vector3.new(seatWidth, 0.5, 2.5),
			CFrame.new(seatX, SEAT_CUSHION_Y, SEAT_Z),
			C_SEAT, Enum.Material.Fabric)

		-- Seat back (slightly reclined)
		VU.part(model, name .. "_Back",
			Vector3.new(seatWidth, seatBackHeight, 0.5),
			CFrame.new(seatX, SEAT_CUSHION_Y + seatBackHeight / 2 + 0.2, SEAT_Z - 1.0)
				* CFrame.Angles(seatBackAngle, 0, 0),
			C_SEAT, Enum.Material.Fabric)

		-- Headrest
		VU.part(model, name .. "_Headrest",
			Vector3.new(1.2, 0.8, 0.4),
			CFrame.new(seatX, SEAT_CUSHION_Y + seatBackHeight + 0.6, SEAT_Z - 1.3),
			C_SEAT_FRAME, Enum.Material.Fabric)
	end

	createSeat("DriverSeat", DRIVER_X)
	createSeat("PassengerSeat", PASSENGER_X)

	---------------------------------------------------------------------------
	-- PHASE 1: STEERING WHEEL (in front of driver)
	---------------------------------------------------------------------------
	local steeringZ = SEAT_Z + 1.5
	local steeringY = Convertible.SEAT_Y + 0.4
	local steeringTilt = math.rad(20)

	-- Steering wheel disc
	local wheelRadius = 0.6
	local wheelCFrame = CFrame.new(DRIVER_X, steeringY, steeringZ)
		* CFrame.Angles(0, math.rad(-90), 0)  -- face toward driver
		* CFrame.Angles(steeringTilt, 0, 0)   -- tilt
	VU.cylinder(model, "SteeringWheel",
		Vector3.new(0.08, wheelRadius * 2, wheelRadius * 2),
		wheelCFrame,
		C_STEERING, Enum.Material.SmoothPlastic)

	-- Steering column: from wheel toward dashboard
	local columnLength = 1.5
	local columnThickness = 0.2
	local columnCFrame = CFrame.new(DRIVER_X, steeringY, steeringZ + columnLength/2)
		* CFrame.Angles(0, math.rad(90), 0)  -- axis points along Z
		* CFrame.Angles(math.rad(-15), 0, 0) -- tilt down toward dashboard
	VU.cylinder(model, "SteeringColumn",
		Vector3.new(columnLength, columnThickness, columnThickness),
		columnCFrame,
		C_METAL, Enum.Material.Metal)

	---------------------------------------------------------------------------
	-- PHASE 2: WHEELS
	---------------------------------------------------------------------------
	local wheelRadius = 1.5
	local wheelWidth = 1.0
	local rimRadius = 1.0  -- smaller than tire for visible rim

	-- Axle positions
	local frontAxleZ = 7.0   -- front wheels (moved forward for longer hood)
	local rearAxleZ = -5.0   -- rear wheels
	local wheelX = halfW + 0.2  -- slightly outside chassis

	-- Helper to create a wheel (tire + hub + spokes) as a Model for animation
	-- side: 1 for right, -1 for left
	local function createWheel(name, x, z, side)
		local wheelY = wheelRadius  -- center at radius so bottom at Y=0
		local rimX = x + (wheelWidth / 2) * side  -- outer face of wheel

		-- Create wheel Model (VehicleSystem animates models with "Wheel" in name)
		local wheelModel = Instance.new("Model")
		wheelModel.Name = name
		wheelModel.Parent = model

		-- Tire (black donut) - this is the PrimaryPart for rotation
		local tire = VU.cylinder(wheelModel, "Tire",
			Vector3.new(wheelWidth, wheelRadius * 2, wheelRadius * 2),
			CFrame.new(x, wheelY, z),
			C_TIRE, Enum.Material.Rubber)
		wheelModel.PrimaryPart = tire

		-- Center hub (chrome cylinder)
		VU.cylinder(wheelModel, "Hub",
			Vector3.new(0.2, 0.7, 0.7),
			CFrame.new(rimX, wheelY, z),
			C_RIM, Enum.Material.Foil)

		-- 5 spokes: bars from center to edge
		local spokeCount = 5
		local spokeLength = rimRadius - 0.2
		for i = 0, spokeCount - 1 do
			local angle = (i / spokeCount) * math.pi * 2
			local spokeCFrame = CFrame.new(rimX, wheelY, z)
				* CFrame.Angles(angle, 0, 0)
				* CFrame.new(0, spokeLength / 2 + 0.2, 0)
			VU.part(wheelModel, "Spoke" .. i,
				Vector3.new(0.15, spokeLength, 0.2),
				spokeCFrame,
				C_RIM, Enum.Material.Foil)
		end
	end

	-- Create 4 wheels
	createWheel("WheelFL", -wheelX, frontAxleZ, -1)  -- Front Left
	createWheel("WheelFR", wheelX, frontAxleZ, 1)    -- Front Right
	createWheel("WheelRL", -wheelX, rearAxleZ, -1)   -- Rear Left
	createWheel("WheelRR", wheelX, rearAxleZ, 1)     -- Rear Right

	---------------------------------------------------------------------------
	-- PHASE 3: BODY PANELS (build one by one)
	---------------------------------------------------------------------------
	local C_GLASS = Color3.fromRGB(180, 210, 240)  -- light blue tinted glass

	-- Z positions
	local windshieldZ = SEAT_Z + 3.0      -- windshield base (2.5) — clearance for driver

	---------------------------------------------------------------------------
	-- WINDSHIELD (steep angle, glass with black frame)
	---------------------------------------------------------------------------
	local wsWidth = CHASSIS_WIDTH          -- full car width
	local wsHeight = 2.0
	local wsAngle = math.rad(55)          -- steep rake
	local wsBaseY = FLOOR_Y + 2.5         -- base of windshield

	-- Windshield glass
	local glass = VU.part(model, "WindshieldGlass",
		Vector3.new(wsWidth, wsHeight, 0.1),
		CFrame.new(0, wsBaseY + wsHeight/2 * math.cos(wsAngle), windshieldZ - wsHeight/2 * math.sin(wsAngle))
			* CFrame.Angles(-wsAngle, 0, 0),
		C_GLASS, Enum.Material.Glass)
	glass.Transparency = 0.5

	-- A-pillars (black frames on sides)
	for _, side in ipairs({-1, 1}) do
		VU.part(model, "APillar" .. (side == -1 and "L" or "R"),
			Vector3.new(0.25, wsHeight + 0.2, 0.25),
			CFrame.new(side * (wsWidth/2 + 0.1), wsBaseY + wsHeight/2 * math.cos(wsAngle), windshieldZ - wsHeight/2 * math.sin(wsAngle))
				* CFrame.Angles(-wsAngle, 0, 0),
			C_TRIM, Enum.Material.SmoothPlastic)
	end

	---------------------------------------------------------------------------
	-- HOOD + FRONT NOSE (sports car profile)
	---------------------------------------------------------------------------
	local hoodY = wsBaseY             -- same height as windshield base (4.0)
	local noseStartZ = frontZ - 1.5  -- nose begins 1.5 studs before front (Z=5.5)
	local hoodZ = windshieldZ         -- starts at windshield base (2.5)
	local hoodLen = noseStartZ - hoodZ  -- flat hood only to nose start (1.5)

	-- Flat hood (windshield to nose start)
	-- Hood (full width to meet fender inner faces)
	local hoodWidth = halfW * 2 + 0.3  -- edge-to-edge with fenders
	VU.part(model, "Hood",
		Vector3.new(hoodWidth, 0.3, hoodLen),
		CFrame.new(0, hoodY, hoodZ + hoodLen / 2),
		C_BODY, Enum.Material.SmoothPlastic)

	-- Hood center crease
	VU.part(model, "HoodCrease",
		Vector3.new(0.1, 0.05, hoodLen - 0.3),
		CFrame.new(0, hoodY + 0.25, hoodZ + hoodLen / 2),
		C_TRIM, Enum.Material.SmoothPlastic)

	-- Nose wedge (full width to meet fender nose wedges)
	local noseLipY = FLOOR_Y + 0.5           -- low front lip
	local noseRise = hoodY - noseLipY         -- slope height
	local noseLen = frontZ - noseStartZ + 0.5
	VU.wedge(model, "FrontNose",
		Vector3.new(hoodWidth, noseRise, noseLen),
		CFrame.new(0, noseLipY + noseRise / 2, noseStartZ + noseLen / 2)
			* CFrame.Angles(0, math.rad(180), 0),
		C_BODY, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- FRONT FASCIA (vertical face at front of car — mounting surface)
	-- The nose wedge slopes, so we need a flat vertical panel to mount
	-- headlights and grille on. Covers lower ~60% of the nose front.
	---------------------------------------------------------------------------
	local fasciaH = noseRise * 0.8         -- 1.6 studs tall
	local fasciaZ = noseLipY + fasciaH     -- top of fascia Y → surface Z on wedge
	-- Place fascia at the Z where the wedge surface is at fascia-top height
	-- Nose surface Z at height Y = 7.5 + (4.0 - Y)
	local fasciaTopY = noseLipY + fasciaH  -- 3.2
	local fasciaSurfaceZ = noseStartZ + (hoodY - fasciaTopY)  -- 7.5 + 0.8 = 8.3
	local fasciaFrontZ = fasciaSurfaceZ    -- flush with wedge slope at top edge

	VU.part(model, "FrontFascia",
		Vector3.new(hoodWidth, fasciaH, 0.3),
		CFrame.new(0, noseLipY + fasciaH / 2, fasciaFrontZ + 0.15),
		C_BODY, Enum.Material.SmoothPlastic)

	-- Front splitter (black lip at very bottom)
	VU.part(model, "FrontSplitter",
		Vector3.new(CHASSIS_WIDTH + 0.3, 0.25, 0.6),
		CFrame.new(0, noseLipY - 0.1, fasciaFrontZ + 0.3),
		C_TRIM, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- HEADLIGHTS (on front fascia, at outer corners)
	---------------------------------------------------------------------------
	local C_HEADLIGHT = Color3.fromRGB(200, 220, 255)
	local hlFaceZ = fasciaFrontZ + 0.32    -- flush on fascia front face

	for _, side in ipairs({-1, 1}) do
		-- Main headlight (neon, on fascia face at fender corner)
		VU.part(model, "Headlight" .. (side == -1 and "L" or "R"),
			Vector3.new(1.6, 1.0, 0.15),
			CFrame.new(side * 2.8, noseLipY + fasciaH / 2, hlFaceZ),
			C_HEADLIGHT, Enum.Material.Neon)

		-- DRL accent strip (thin line below main light)
		VU.part(model, "HeadlightDRL" .. (side == -1 and "L" or "R"),
			Vector3.new(1.8, 0.12, 0.12),
			CFrame.new(side * 2.8, noseLipY + 0.15, hlFaceZ),
			C_HEADLIGHT, Enum.Material.Neon)
	end

	---------------------------------------------------------------------------
	-- GRILLE (on front fascia, center, with slats for depth)
	---------------------------------------------------------------------------
	local grilleW = CHASSIS_WIDTH - 3.0   -- 5.0 wide (between headlights)
	local grilleH = fasciaH - 0.2         -- nearly full fascia height

	-- Dark backing (recessed intake look)
	VU.part(model, "GrilleBacking",
		Vector3.new(grilleW, grilleH, 0.15),
		CFrame.new(0, noseLipY + grilleH / 2 + 0.1, hlFaceZ - 0.15),
		Color3.fromRGB(15, 15, 18), Enum.Material.SmoothPlastic)

	-- Horizontal slats (forward of backing, 5 bars)
	for i = 0, 4 do
		VU.part(model, "GrilleSlat" .. i,
			Vector3.new(grilleW - 0.4, 0.07, 0.2),
			CFrame.new(0, noseLipY + 0.2 + i * 0.3, hlFaceZ + 0.1),
			C_TRIM, Enum.Material.SmoothPlastic)
	end

	-- Center vertical divider
	VU.part(model, "GrilleDivider",
		Vector3.new(0.1, grilleH - 0.1, 0.2),
		CFrame.new(0, noseLipY + grilleH / 2 + 0.1, hlFaceZ + 0.1),
		C_TRIM, Enum.Material.SmoothPlastic)

	-- Side mirrors (near A-pillars)
	for _, side in ipairs({-1, 1}) do
		VU.part(model, "Mirror" .. (side == -1 and "L" or "R"),
			Vector3.new(0.6, 0.3, 0.8),
			CFrame.new(side * (halfW + 0.4), hoodY - 0.3, windshieldZ - 0.3),
			C_TRIM, Enum.Material.SmoothPlastic)
	end

	---------------------------------------------------------------------------
	-- SIDE PANELS: 3 sections per side (rear fender, door, front fender)
	---------------------------------------------------------------------------
	local cockpitRearZ_side = SEAT_Z - 2.0  -- -2.5
	local panelGap = 0  -- no gap (prevents black line flicker between panels)

	for _, side in ipairs({-1, 1}) do
		local sx = side * halfW

		-- 1. REAR FENDER (rearZ to cockpit rear, tall enough to cover engine bay)
		local rearFenderLen = math.abs(cockpitRearZ_side - rearZ) - panelGap
		local rearFenderH = hoodY - sideBottomY  -- up to hood level (covers engine bay)
		VU.part(model, "RearFender" .. (side == -1 and "L" or "R"),
			Vector3.new(0.3, rearFenderH, rearFenderLen),
			CFrame.new(sx, sideBottomY + rearFenderH/2, (rearZ + cockpitRearZ_side) / 2),
			C_BODY, Enum.Material.SmoothPlastic)

		-- 2. DOOR (cockpit area, slightly lower than fenders — open top convertible)
		local doorLen = (windshieldZ - cockpitRearZ_side) - panelGap * 2
		local doorH = sideH + 0.2  -- raised a bit
		VU.part(model, "Door" .. (side == -1 and "L" or "R"),
			Vector3.new(0.3, doorH, doorLen),
			CFrame.new(sx, sideBottomY + doorH/2, (cockpitRearZ_side + windshieldZ) / 2),
			C_BODY, Enum.Material.SmoothPlastic)

		-- 3. FRONT FENDER (windshield to nose start, full height to hood)
		local frontFenderLen = noseStartZ - windshieldZ - panelGap
		local frontFenderH = hoodY - sideBottomY
		VU.part(model, "FrontFender" .. (side == -1 and "L" or "R"),
			Vector3.new(0.3, frontFenderH, frontFenderLen),
			CFrame.new(sx, sideBottomY + frontFenderH/2, windshieldZ + panelGap/2 + frontFenderLen/2),
			C_BODY, Enum.Material.SmoothPlastic)

		-- Front fender nose wedge (follows the nose slope on the side)
		local sideNoseRise = hoodY - noseLipY
		VU.wedge(model, "FenderNose" .. (side == -1 and "L" or "R"),
			Vector3.new(0.3, sideNoseRise, noseLen),
			CFrame.new(sx, noseLipY + sideNoseRise / 2, noseStartZ + noseLen / 2)
				* CFrame.Angles(0, math.rad(180), 0),
			C_BODY, Enum.Material.SmoothPlastic)
	end

	---------------------------------------------------------------------------
	-- REAR DECK (engine cover behind cockpit)
	---------------------------------------------------------------------------
	local cockpitRearZ = SEAT_Z - 2.0     -- where cockpit ends (-2.5)
	local rearDeckLength = math.abs(rearZ - cockpitRearZ)  -- 4.5
	local rearDeckY = FLOOR_Y + sideH     -- 3.0 = flush with side panel tops

	-- Engine bay dimensions (declared early, used by quarter panels + engine bay)
	local engineBayH = 1.2
	local engineBayW = CHASSIS_WIDTH - 2.0  -- narrower than deck, leaving white edges visible
	local engineBayLen = rearDeckLength - 1.0
	local engineBayY = rearDeckY + 0.2 + engineBayH / 2  -- sits on deck
	local engineBayZ = (cockpitRearZ + rearZ) / 2

	-- Rear deck surface (narrower than body so it doesn't Z-fight with side panels)
	-- Dark engine bay floor — neon engine blocks will sit on top later
	-- Shortened by 0.5 so it doesn't overlap with the RearEnd panel
	local deckLen = rearDeckLength - 0.8
	local deckZ = cockpitRearZ - deckLen / 2
	VU.part(model, "RearDeck",
		Vector3.new(CHASSIS_WIDTH - 0.4, 0.4, deckLen),
		CFrame.new(0, rearDeckY, deckZ),
		C_CHASSIS, Enum.Material.Metal)

	-- Engine: V-style neon fins (visible through glass cover)
	local C_ENGINE_NEON = Color3.fromRGB(255, 120, 30)  -- warm orange glow
	local engineTopY = rearDeckY + 0.3  -- sits on deck surface
	local finW = 2.0     -- each fin width
	local finH = 0.7     -- fin height
	local finDepth = 0.3 -- thin fins
	local vGap = 0.5     -- gap between left and right banks
	local vAngle = math.rad(8)  -- slight outward tilt (V-engine look)
	local finCount = 5
	local finSpacing = 0.55  -- center-to-center distance
	local bankLen = finCount * finSpacing

	for i = 0, finCount - 1 do
		if i % 2 == 1 then continue end -- skip every other fin for contrast
		local finZ = engineBayZ - bankLen/2 + finSpacing/2 + i * finSpacing

		-- Left bank fin
		VU.part(model, "EngineFinL" .. i,
			Vector3.new(finW, finH, finDepth),
			CFrame.new(-finW/2 - vGap/2, engineTopY + finH/2, finZ)
				* CFrame.Angles(0, 0, vAngle),
			C_ENGINE_NEON, Enum.Material.Neon)

		-- Right bank fin
		VU.part(model, "EngineFinR" .. i,
			Vector3.new(finW, finH, finDepth),
			CFrame.new(finW/2 + vGap/2, engineTopY + finH/2, finZ)
				* CFrame.Angles(0, 0, -vAngle),
			C_ENGINE_NEON, Enum.Material.Neon)
	end

	-- Center intake manifold (connecting rail)
	VU.part(model, "IntakeManifold",
		Vector3.new(vGap + 0.4, 0.25, bankLen),
		CFrame.new(0, engineTopY + finH + 0.15, engineBayZ),
		C_TRIM, Enum.Material.SmoothPlastic)

	-- Glass engine cover (engine bay only, not over seats)
	local glassY = engineTopY + finH + 0.5  -- well above the fins + manifold
	local glassFrontZ = cockpitRearZ - 1.2  -- pulled back from seat area
	local glassRearZ = rearZ + 0.4          -- to rear panel front face
	local glassLen = math.abs(glassFrontZ - glassRearZ)
	local glassZ = (glassFrontZ + glassRearZ) / 2
	local engineGlass = VU.part(model, "EngineGlass",
		Vector3.new(CHASSIS_WIDTH - 0.6, 0.15, glassLen),
		CFrame.new(0, glassY, glassZ),
		C_GLASS, Enum.Material.Glass)
	engineGlass.Transparency = 0.4

	---------------------------------------------------------------------------
	-- REAR END (back wall of car)
	---------------------------------------------------------------------------
	local rearWallBottom = FLOOR_Y + 0.22  -- slightly above chassis to avoid Z-fighting
	local rearWallTop = rearDeckY + 0.2 + engineBayH  -- up to engine bay top
	local rearWallH = rearWallTop - rearWallBottom
	VU.part(model, "RearEnd",
		Vector3.new(CHASSIS_WIDTH - 0.4, rearWallH, 0.4),
		CFrame.new(0, rearWallBottom + rearWallH/2, rearZ + 0.2),
		C_BODY, Enum.Material.SmoothPlastic)

	-- LED tail light strip (full-width row of small red neon segments)
	local C_TAILLIGHT = Color3.fromRGB(220, 15, 15)
	local tailY = rearDeckY + 0.3
	local tailZ = rearZ - 0.05  -- slightly behind rear panel
	local ledW = 0.5    -- each LED segment width
	local ledH = 0.2    -- thin strip
	local ledGap = 0.15 -- gap between segments
	local stripWidth = CHASSIS_WIDTH - 1.0  -- total strip span
	local ledCount = math.floor(stripWidth / (ledW + ledGap))
	local totalLedWidth = ledCount * ledW + (ledCount - 1) * ledGap
	local startX = -totalLedWidth / 2 + ledW / 2

	for i = 0, ledCount - 1 do
		VU.part(model, "TailLED" .. i,
			Vector3.new(ledW, ledH, 0.1),
			CFrame.new(startX + i * (ledW + ledGap), tailY, tailZ),
			C_TAILLIGHT, Enum.Material.Neon)
	end

	---------------------------------------------------------------------------
	-- EXHAUST PIPES (4 pipes with fire/smoke particles)
	---------------------------------------------------------------------------
	local C_EXHAUST = Color3.fromRGB(50, 50, 55)  -- dark chrome
	local exhaustY = FLOOR_Y + 0.4
	local exhaustZ = rearZ - 0.1  -- just behind rear panel
	local exhaustRadius = 0.45
	local exhaustLen = 0.4
	-- 4 pipes: 2 on each side
	local exhaustPositions = {
		{x = -2.2, name = "ExhaustL1"},
		{x = -1.4, name = "ExhaustL2"},
		{x =  1.4, name = "ExhaustR1"},
		{x =  2.2, name = "ExhaustR2"},
	}
	for _, ex in exhaustPositions do
		-- Pipe cylinder (oriented along Z axis)
		local pipe = VU.cylinder(model, ex.name,
			Vector3.new(exhaustLen, exhaustRadius * 2, exhaustRadius * 2),
			CFrame.new(ex.x, exhaustY, exhaustZ) * CFrame.Angles(0, math.rad(90), 0),
			C_EXHAUST, Enum.Material.Metal)

		-- Inner dark hole
		VU.cylinder(model, ex.name .. "Inner",
			Vector3.new(0.1, exhaustRadius * 1.2, exhaustRadius * 1.2),
			CFrame.new(ex.x, exhaustY, exhaustZ - exhaustLen/2 - 0.1) * CFrame.Angles(0, math.rad(90), 0),
			Color3.fromRGB(15, 15, 15), Enum.Material.SmoothPlastic)

		-- Fire/smoke particle emitter
		local emitter = Instance.new("ParticleEmitter")
		emitter.Name = "ExhaustSmoke"
		emitter.Rate = 25
		emitter.Lifetime = NumberRange.new(0.4, 1.0)
		emitter.Speed = NumberRange.new(5, 10)
		emitter.SpreadAngle = Vector2.new(10, 10)
		emitter.EmissionDirection = Enum.NormalId.Right -- cylinder rotated 90°, Right = -Z world
		emitter.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 160, 50)),  -- orange fire
			ColorSequenceKeypoint.new(0.3, Color3.fromRGB(220, 90, 25)), -- dark orange
			ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 90, 90)),    -- gray smoke
		})
		emitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(0.3, 0.6),
			NumberSequenceKeypoint.new(1, 1.2),
		})
		emitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.1),
			NumberSequenceKeypoint.new(0.5, 0.5),
			NumberSequenceKeypoint.new(1, 1),
		})
		emitter.LightEmission = 0.7
		emitter.Parent = pipe
	end

	---------------------------------------------------------------------------
	-- Set primary part for positioning
	---------------------------------------------------------------------------
	model.PrimaryPart = chassis

	return model
end

--------------------------------------------------------------------------------
-- DRIVABLE VERSION (player-controlled, VehicleSeat instead of NPC)
--------------------------------------------------------------------------------
function Convertible.buildDrivable()
	local model = Convertible.build()
	model.Name = "Convertible_Drivable"

	-- Add a VehicleSeat at the driver position
	-- Anchored: server moves the whole model via PivotTo, player is welded via Sit()
	local seat = Instance.new("VehicleSeat")
	seat.Name = "DrivingSeat"
	seat.Size = Vector3.new(2, 0.5, 2)
	seat.CFrame = CFrame.new(-DRIVER_X, SEAT_CUSHION_Y, SEAT_Z) * CFrame.Angles(0, math.rad(180), 0)
	seat.Anchored = true
	seat.CanCollide = false
	seat.Transparency = 1  -- invisible (cosmetic seat parts already there)
	seat.MaxSpeed = 0      -- we handle movement ourselves
	seat.HeadsUpDisplay = false -- hide default Roblox speed gauge
	seat.Parent = model

	-- SpotLight disabled (testing flickering)
	-- local hl = model:FindFirstChild("HeadlightL")
	-- if hl then
	-- 	local spot = Instance.new("SpotLight")
	-- 	spot.Face = Enum.NormalId.Back
	-- 	spot.Brightness = 2
	-- 	spot.Range = 70
	-- 	spot.Angle = 55
	-- 	spot.Shadows = false
	-- 	spot.Color = Color3.fromRGB(255, 250, 230)
	-- 	spot.Parent = hl
	-- end

	return model
end

return Convertible
