local VU = require(script.Parent:WaitForChild("VehicleUtils"))

local NasaRover = {}

--------------------------------------------------------------------------------
-- NASA ROVER  (faces +Z forward, wheels on ground at Y=0)
-- Mars/Lunar exploration rover: wide 6-wheel chassis, pressurized glass
-- bubble cabin, solar panels, communication dish, robotic sensor arm.
--------------------------------------------------------------------------------

-- Colors
local C_WHITE       = Color3.fromRGB(235, 235, 240)    -- NASA white body
local C_SILVER      = Color3.fromRGB(180, 180, 185)    -- silver panels
local C_DARK_METAL  = Color3.fromRGB(55, 55, 60)       -- structural metal
local C_GOLD_FOIL   = Color3.fromRGB(200, 170, 60)     -- gold thermal foil
local C_GLASS       = Color3.fromRGB(190, 220, 255)    -- blue-tinted glass
local C_ORANGE      = Color3.fromRGB(255, 130, 30)     -- NASA orange accent
local C_BLUE        = Color3.fromRGB(30, 100, 200)     -- NASA blue accent
local C_NEON_ORANGE = Color3.fromRGB(255, 160, 50)     -- warm neon glow
local C_NEON_BLUE   = Color3.fromRGB(60, 150, 255)     -- instrument glow
local C_TIRE        = Color3.fromRGB(70, 70, 75)       -- rover wheel (metallic mesh)
local C_RIM         = Color3.fromRGB(200, 200, 205)    -- bright rim
local C_BLACK       = Color3.fromRGB(25, 25, 28)
local C_SOLAR       = Color3.fromRGB(25, 35, 80)       -- dark blue solar cell
local C_HEADLIGHT   = Color3.fromRGB(255, 200, 100)    -- warm orange beam

-- Dimensions (wider and longer than jeep — exploration rover proportions)
local CHASSIS_LENGTH = 16
local CHASSIS_WIDTH  = 9
local WHEEL_R   = 1.8
local WHEEL_W   = 1.6   -- wide mesh wheels
local HALF_W    = 4.8
local FLOOR_Y   = WHEEL_R + 0.8  -- 2.6 (higher ground clearance)

-- 6 wheels: 3 per side
local WHEEL_Z_FRONT = 6.0
local WHEEL_Z_MID   = 0.0
local WHEEL_Z_REAR  = -6.0

-- Cabin dimensions
local CABIN_BASE_Y = FLOOR_Y + 1.5   -- 4.1
local CABIN_TOP_Y  = CABIN_BASE_Y + 5.0  -- 9.1 (tall bubble)
local CABIN_W = 7.0
local CABIN_LEN = 6.0
local CABIN_Z = 0.5  -- slightly forward

-- Seat positions (center cockpit, side by side)
local DRIVER_X    = -1.5
local PASSENGER_X = 1.5
local SEAT_Z      = 0.5
local SEAT_Y      = FLOOR_Y + 2.0  -- 4.6 (HRP position for R15)

-- Exports for NPC seating
NasaRover.FLOOR_Y = FLOOR_Y
NasaRover.SEAT_Y = SEAT_Y
NasaRover.DRIVER_X = DRIVER_X
NasaRover.PASSENGER_X = PASSENGER_X
NasaRover.SEAT_Z = SEAT_Z

function NasaRover.build()
	local model = Instance.new("Model")
	model.Name = "NasaRover_1"

	---------------------------------------------------------------------------
	-- WHEELS (6 wheels — 3 per side, wide mesh-style rover wheels)
	-- Each wrapped in a Model so WorldLoader can spin them.
	---------------------------------------------------------------------------
	local wheelPositions = {WHEEL_Z_FRONT, WHEEL_Z_MID, WHEEL_Z_REAR}
	local wheelLabels = {"Front", "Mid", "Rear"}
	for wi, wz in ipairs(wheelPositions) do
		for _, sx in ipairs({-1, 1}) do
			local sideName = sx == -1 and "L" or "R"
			local wheelModel = Instance.new("Model")
			wheelModel.Name = "Wheel_" .. wheelLabels[wi] .. sideName
			wheelModel.Parent = model

			-- Main wheel (metallic mesh look)
			local tire = VU.cylinder(wheelModel, "Tire",
				Vector3.new(WHEEL_W, WHEEL_R * 2, WHEEL_R * 2),
				CFrame.new(sx * HALF_W, WHEEL_R, wz),
				C_TIRE, Enum.Material.DiamondPlate)
			-- Hub (bright center)
			VU.cylinder(wheelModel, "Hub",
				Vector3.new(WHEEL_W + 0.15, WHEEL_R * 0.5, WHEEL_R * 0.5),
				CFrame.new(sx * HALF_W, WHEEL_R, wz),
				C_RIM, Enum.Material.Foil)

			wheelModel.PrimaryPart = tire

			-- Suspension arm connecting wheel to chassis (on main model, not wheel)
			local armY = FLOOR_Y - 0.3
			VU.part(model, "SuspArm",
				Vector3.new(0.3, 0.3, 1.2),
				CFrame.new(sx * (HALF_W - 0.8), armY, wz),
				C_DARK_METAL, Enum.Material.Metal)
			-- Vertical strut
			VU.part(model, "SuspStrut",
				Vector3.new(0.3, FLOOR_Y - WHEEL_R, 0.3),
				CFrame.new(sx * HALF_W, (FLOOR_Y + WHEEL_R) / 2, wz),
				C_DARK_METAL, Enum.Material.Metal)
		end
	end

	---------------------------------------------------------------------------
	-- CHASSIS (flat platform with gold thermal foil underside)
	---------------------------------------------------------------------------
	local chassis = VU.part(model, "Chassis",
		Vector3.new(CHASSIS_WIDTH, 1.0, CHASSIS_LENGTH),
		CFrame.new(0, FLOOR_Y, 0),
		C_WHITE, Enum.Material.SmoothPlastic)

	-- Gold foil underside (thermal protection, visible from sides)
	VU.part(model, "ThermalFoil",
		Vector3.new(CHASSIS_WIDTH - 0.5, 0.15, CHASSIS_LENGTH - 1),
		CFrame.new(0, FLOOR_Y - 0.55, 0),
		C_GOLD_FOIL, Enum.Material.Foil)

	---------------------------------------------------------------------------
	-- FRONT: Instrument deck + headlights
	---------------------------------------------------------------------------
	-- Front instrument deck (lower profile than cabin)
	local frontDeckLen = 3.5
	local frontDeckH = 1.2
	VU.part(model, "FrontDeck",
		Vector3.new(CHASSIS_WIDTH - 1, frontDeckH, frontDeckLen),
		CFrame.new(0, FLOOR_Y + frontDeckH / 2 + 0.5, CHASSIS_LENGTH / 2 - frontDeckLen / 2),
		C_SILVER, Enum.Material.SmoothPlastic)

	-- Nose wedge
	VU.wedge(model, "FrontNose",
		Vector3.new(CHASSIS_WIDTH - 1.5, frontDeckH, 2),
		CFrame.new(0, FLOOR_Y + frontDeckH / 2 + 0.5, CHASSIS_LENGTH / 2 + 0.8)
			* CFrame.Angles(0, math.rad(180), 0),
		C_WHITE, Enum.Material.SmoothPlastic)

	-- Headlights (warm orange — like space suit visor)
	for _, sx in ipairs({-3.0, 3.0}) do
		VU.cylinder(model, "Headlight" .. (sx < 0 and "L" or "R"),
			Vector3.new(0.3, 1.0, 1.0),
			CFrame.new(sx, FLOOR_Y + 1.5, CHASSIS_LENGTH / 2 + 0.3) * CFrame.Angles(0, math.rad(90), 0),
			C_HEADLIGHT, Enum.Material.Neon)
	end

	-- Front cameras/sensors (small boxes on instrument deck)
	for _, sx in ipairs({-1.5, 0, 1.5}) do
		VU.part(model, "FrontSensor",
			Vector3.new(0.5, 0.5, 0.5),
			CFrame.new(sx, FLOOR_Y + frontDeckH + 1.0, CHASSIS_LENGTH / 2 - 0.5),
			C_BLACK, Enum.Material.SmoothPlastic)
		-- Lens glow
		VU.part(model, "SensorLens",
			Vector3.new(0.15, 0.3, 0.3),
			CFrame.new(sx, FLOOR_Y + frontDeckH + 1.0, CHASSIS_LENGTH / 2 - 0.24),
			C_NEON_BLUE, Enum.Material.Neon)
	end

	---------------------------------------------------------------------------
	-- GLASS BUBBLE CABIN (pressurized dome — the signature feature)
	---------------------------------------------------------------------------
	-- The cabin is a rounded glass enclosure with white frame ribs

	-- Side glass panels (slightly curved via angling)
	for _, sx in ipairs({-1, 1}) do
		local sideGlass = VU.part(model, "CabinSideGlass" .. (sx == -1 and "L" or "R"),
			Vector3.new(0.15, CABIN_TOP_Y - CABIN_BASE_Y - 0.5, CABIN_LEN),
			CFrame.new(sx * CABIN_W / 2, (CABIN_BASE_Y + CABIN_TOP_Y) / 2, CABIN_Z),
			C_GLASS, Enum.Material.Glass)
		sideGlass.Transparency = 0.45
	end

	-- Front glass (angled forward)
	local frontGlass = VU.part(model, "CabinFrontGlass",
		Vector3.new(CABIN_W, (CABIN_TOP_Y - CABIN_BASE_Y) * 0.85, 0.15),
		CFrame.new(0, (CABIN_BASE_Y + CABIN_TOP_Y) / 2, CABIN_Z + CABIN_LEN / 2)
			* CFrame.Angles(math.rad(-10), 0, 0),
		C_GLASS, Enum.Material.Glass)
	frontGlass.Transparency = 0.45

	-- Rear glass
	local rearGlass = VU.part(model, "CabinRearGlass",
		Vector3.new(CABIN_W, (CABIN_TOP_Y - CABIN_BASE_Y) * 0.85, 0.15),
		CFrame.new(0, (CABIN_BASE_Y + CABIN_TOP_Y) / 2, CABIN_Z - CABIN_LEN / 2)
			* CFrame.Angles(math.rad(10), 0, 0),
		C_GLASS, Enum.Material.Glass)
	rearGlass.Transparency = 0.45

	-- Roof glass (top of bubble)
	local roofGlass = VU.part(model, "CabinRoofGlass",
		Vector3.new(CABIN_W - 1.5, 0.15, CABIN_LEN - 0.5),
		CFrame.new(0, CABIN_TOP_Y - 0.3, CABIN_Z),
		C_GLASS, Enum.Material.Glass)
	roofGlass.Transparency = 0.4

	-- White frame ribs (3 arches over the cabin)
	local ribCount = 3
	local ribSpacing = CABIN_LEN / (ribCount + 1)
	for i = 1, ribCount do
		local ribZ = CABIN_Z - CABIN_LEN / 2 + i * ribSpacing
		-- Top arch bar
		VU.part(model, "CabinRib" .. i,
			Vector3.new(CABIN_W + 0.4, 0.25, 0.25),
			CFrame.new(0, CABIN_TOP_Y - 0.2, ribZ),
			C_WHITE, Enum.Material.SmoothPlastic)
		-- Side posts
		for _, sx in ipairs({-1, 1}) do
			VU.part(model, "CabinPost",
				Vector3.new(0.25, CABIN_TOP_Y - CABIN_BASE_Y, 0.25),
				CFrame.new(sx * (CABIN_W / 2 + 0.05), (CABIN_BASE_Y + CABIN_TOP_Y) / 2, ribZ),
				C_WHITE, Enum.Material.SmoothPlastic)
		end
	end

	-- Front and rear frame bars
	VU.part(model, "CabinFrameFront",
		Vector3.new(CABIN_W + 0.4, 0.25, 0.25),
		CFrame.new(0, CABIN_TOP_Y * 0.92, CABIN_Z + CABIN_LEN / 2),
		C_WHITE, Enum.Material.SmoothPlastic)
	VU.part(model, "CabinFrameRear",
		Vector3.new(CABIN_W + 0.4, 0.25, 0.25),
		CFrame.new(0, CABIN_TOP_Y * 0.92, CABIN_Z - CABIN_LEN / 2),
		C_WHITE, Enum.Material.SmoothPlastic)

	-- Side frame rails
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "CabinRail" .. (sx == -1 and "L" or "R"),
			Vector3.new(0.25, 0.25, CABIN_LEN + 0.3),
			CFrame.new(sx * (CABIN_W / 2 + 0.05), CABIN_TOP_Y - 0.2, CABIN_Z),
			C_WHITE, Enum.Material.SmoothPlastic)
	end

	-- Orange accent band at cabin base (where cabin meets chassis)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "CabinAccent" .. (sx == -1 and "L" or "R"),
			Vector3.new(0.12, 0.3, CABIN_LEN),
			CFrame.new(sx * (CABIN_W / 2 + 0.12), CABIN_BASE_Y, CABIN_Z),
			C_NEON_ORANGE, Enum.Material.Neon)
	end
	VU.part(model, "CabinAccentFront",
		Vector3.new(CABIN_W, 0.3, 0.12),
		CFrame.new(0, CABIN_BASE_Y, CABIN_Z + CABIN_LEN / 2 + 0.06),
		C_NEON_ORANGE, Enum.Material.Neon)
	VU.part(model, "CabinAccentRear",
		Vector3.new(CABIN_W, 0.3, 0.12),
		CFrame.new(0, CABIN_BASE_Y, CABIN_Z - CABIN_LEN / 2 - 0.06),
		C_NEON_ORANGE, Enum.Material.Neon)

	---------------------------------------------------------------------------
	-- INTERIOR: Seats + Dashboard
	---------------------------------------------------------------------------
	VU.part(model, "SeatBench",
		Vector3.new(6, 0.4, 2.5),
		CFrame.new(0, FLOOR_Y + 1.2, SEAT_Z),
		C_SILVER, Enum.Material.Fabric)
	VU.part(model, "SeatBack",
		Vector3.new(6, 2.5, 0.4),
		CFrame.new(0, FLOOR_Y + 2.5, SEAT_Z - 1.2),
		C_SILVER, Enum.Material.Fabric)

	-- Dashboard (multi-screen instrument panel)
	VU.part(model, "Dashboard",
		Vector3.new(CABIN_W - 1.5, 1.2, 0.5),
		CFrame.new(0, FLOOR_Y + 2.2, CABIN_Z + CABIN_LEN / 2 - 0.8),
		C_BLACK, Enum.Material.SmoothPlastic)
	-- Screen glow (3 monitors)
	for i = -1, 1 do
		VU.part(model, "Screen" .. (i + 2),
			Vector3.new(1.4, 0.7, 0.1),
			CFrame.new(i * 1.8, FLOOR_Y + 2.6, CABIN_Z + CABIN_LEN / 2 - 0.52),
			C_NEON_BLUE, Enum.Material.Neon)
	end

	---------------------------------------------------------------------------
	-- SOLAR PANELS (fold-out wings on cabin roof)
	---------------------------------------------------------------------------
	local solarY = CABIN_TOP_Y + 0.1
	local solarLen = 4.0
	local solarW = 3.5
	local solarAngle = math.rad(5)  -- slight tilt outward

	for _, sx in ipairs({-1, 1}) do
		-- Panel frame
		VU.part(model, "SolarFrame" .. (sx == -1 and "L" or "R"),
			Vector3.new(solarW, 0.1, solarLen),
			CFrame.new(sx * (CABIN_W / 2 + solarW / 2 - 0.3), solarY, CABIN_Z)
				* CFrame.Angles(0, 0, sx * solarAngle),
			C_SILVER, Enum.Material.Metal)

		-- Solar cells (dark blue, on top of frame)
		VU.part(model, "SolarCell" .. (sx == -1 and "L" or "R"),
			Vector3.new(solarW - 0.4, 0.06, solarLen - 0.4),
			CFrame.new(sx * (CABIN_W / 2 + solarW / 2 - 0.3), solarY + 0.08, CABIN_Z)
				* CFrame.Angles(0, 0, sx * solarAngle),
			C_SOLAR, Enum.Material.SmoothPlastic)

		-- Grid lines on solar panel (visual detail)
		for j = 0, 3 do
			VU.part(model, "SolarGrid",
				Vector3.new(solarW - 0.5, 0.03, 0.05),
				CFrame.new(sx * (CABIN_W / 2 + solarW / 2 - 0.3), solarY + 0.12, CABIN_Z - solarLen / 2 + 0.5 + j * 1.0)
					* CFrame.Angles(0, 0, sx * solarAngle),
				C_SILVER, Enum.Material.Metal)
		end

		-- Support arm connecting panel to cabin
		VU.part(model, "SolarArm" .. (sx == -1 and "L" or "R"),
			Vector3.new(1.5, 0.2, 0.2),
			CFrame.new(sx * (CABIN_W / 2 + 0.5), solarY - 0.15, CABIN_Z),
			C_DARK_METAL, Enum.Material.Metal)
	end

	---------------------------------------------------------------------------
	-- COMMUNICATION DISH (rear, mounted on a mast)
	---------------------------------------------------------------------------
	local dishMastY = CABIN_TOP_Y + 2.0
	-- Mast
	VU.part(model, "DishMast",
		Vector3.new(0.2, 3.0, 0.2),
		CFrame.new(0, CABIN_TOP_Y + 1.5, -4.0),
		C_DARK_METAL, Enum.Material.Metal)
	-- Dish (cylinder tilted forward)
	VU.cylinder(model, "Dish",
		Vector3.new(0.3, 2.5, 2.5),
		CFrame.new(0, dishMastY + 1.0, -4.0)
			* CFrame.Angles(math.rad(35), 0, 0),
		C_WHITE, Enum.Material.SmoothPlastic)
	-- Dish feed (center nub)
	VU.part(model, "DishFeed",
		Vector3.new(0.15, 0.15, 1.2),
		CFrame.new(0, dishMastY + 1.0, -3.5)
			* CFrame.Angles(math.rad(35), 0, 0),
		C_DARK_METAL, Enum.Material.Metal)
	-- Dish tip light
	VU.ball(model, "DishLight",
		Vector3.new(0.25, 0.25, 0.25),
		CFrame.new(0, dishMastY + 1.4, -3.2),
		C_NEON_ORANGE, Enum.Material.Neon)

	---------------------------------------------------------------------------
	-- ROBOTIC ARM (rear-right, folded with instrument head)
	---------------------------------------------------------------------------
	local armBaseZ = -3.0
	local armBaseY = FLOOR_Y + 1.2
	local armBaseX = 3.0

	-- Base joint
	VU.cylinder(model, "ArmJoint1",
		Vector3.new(0.5, 0.8, 0.8),
		CFrame.new(armBaseX, armBaseY, armBaseZ) * CFrame.Angles(0, 0, math.rad(90)),
		C_DARK_METAL, Enum.Material.Metal)
	-- Upper arm (angled up)
	VU.part(model, "ArmUpper",
		Vector3.new(0.3, 2.5, 0.3),
		CFrame.new(armBaseX, armBaseY + 1.5, armBaseZ)
			* CFrame.Angles(0, 0, math.rad(-10)),
		C_SILVER, Enum.Material.Metal)
	-- Elbow joint
	VU.cylinder(model, "ArmJoint2",
		Vector3.new(0.4, 0.6, 0.6),
		CFrame.new(armBaseX - 0.4, armBaseY + 2.8, armBaseZ) * CFrame.Angles(0, 0, math.rad(90)),
		C_DARK_METAL, Enum.Material.Metal)
	-- Forearm (angled forward)
	VU.part(model, "ArmFore",
		Vector3.new(0.25, 0.25, 2.0),
		CFrame.new(armBaseX - 0.4, armBaseY + 3.0, armBaseZ + 1.2)
			* CFrame.Angles(math.rad(-15), 0, 0),
		C_SILVER, Enum.Material.Metal)
	-- Instrument head (camera/drill)
	VU.part(model, "ArmHead",
		Vector3.new(0.6, 0.6, 0.6),
		CFrame.new(armBaseX - 0.4, armBaseY + 2.8, armBaseZ + 2.3),
		C_BLACK, Enum.Material.SmoothPlastic)
	VU.part(model, "ArmLens",
		Vector3.new(0.4, 0.4, 0.1),
		CFrame.new(armBaseX - 0.4, armBaseY + 2.8, armBaseZ + 2.62),
		C_NEON_BLUE, Enum.Material.Neon)

	---------------------------------------------------------------------------
	-- REAR: Equipment bay, sample rack, battery, O2 tanks, rear camera
	---------------------------------------------------------------------------
	local rearZ = -CHASSIS_LENGTH / 2

	-- Equipment bay frame (open rack structure behind cabin)
	VU.part(model, "EquipBay",
		Vector3.new(CHASSIS_WIDTH - 2, 2.0, 4.5),
		CFrame.new(0, FLOOR_Y + 1.5, rearZ + 2.8),
		C_WHITE, Enum.Material.SmoothPlastic)

	-- Gold foil accents on equipment bay sides
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "EquipFoil",
			Vector3.new(0.08, 1.5, 4.0),
			CFrame.new(sx * (CHASSIS_WIDTH / 2 - 1.1), FLOOR_Y + 1.5, rearZ + 2.8),
			C_GOLD_FOIL, Enum.Material.Foil)
	end

	-- Sample collection containers (3 colored boxes on top of equipment bay)
	local sampleColors = {
		Color3.fromRGB(200, 80, 40),   -- red/orange
		Color3.fromRGB(60, 140, 200),  -- blue
		Color3.fromRGB(80, 180, 80),   -- green
	}
	for i, col in ipairs(sampleColors) do
		local sx = (i - 2) * 2.0  -- -2, 0, 2
		VU.part(model, "SampleBox" .. i,
			Vector3.new(1.4, 0.8, 1.4),
			CFrame.new(sx, FLOOR_Y + 2.9, rearZ + 1.5),
			col, Enum.Material.SmoothPlastic)
		-- Lid line
		VU.part(model, "SampleLid" .. i,
			Vector3.new(1.3, 0.06, 1.3),
			CFrame.new(sx, FLOOR_Y + 3.35, rearZ + 1.5),
			C_SILVER, Enum.Material.Metal)
	end

	-- Battery / power unit (left side of bay)
	VU.part(model, "Battery",
		Vector3.new(2.5, 1.2, 2.0),
		CFrame.new(-2.0, FLOOR_Y + 1.2, rearZ + 4.0),
		C_BLACK, Enum.Material.SmoothPlastic)
	-- Blue status indicator
	VU.part(model, "BatteryLED",
		Vector3.new(0.6, 0.2, 0.08),
		CFrame.new(-2.0, FLOOR_Y + 1.9, rearZ + 3.0),
		C_NEON_BLUE, Enum.Material.Neon)

	-- Gas/O2 tanks (right side — 2 small horizontal cylinders)
	for i = 0, 1 do
		VU.cylinder(model, "O2Tank" .. (i + 1),
			Vector3.new(2.0, 0.7, 0.7),
			CFrame.new(2.0, FLOOR_Y + 1.0 + i * 0.9, rearZ + 4.0)
				* CFrame.Angles(0, 0, math.rad(90)),
			C_WHITE, Enum.Material.SmoothPlastic)
		-- Valve cap
		VU.cylinder(model, "TankCap" .. (i + 1),
			Vector3.new(0.15, 0.5, 0.5),
			CFrame.new(3.05, FLOOR_Y + 1.0 + i * 0.9, rearZ + 4.0)
				* CFrame.Angles(0, 0, math.rad(90)),
			C_ORANGE, Enum.Material.Metal)
	end

	-- Orange hazard stripe across rear bumper
	VU.part(model, "RearHazard",
		Vector3.new(CHASSIS_WIDTH - 1, 0.5, 0.12),
		CFrame.new(0, FLOOR_Y + 0.8, rearZ + 0.55),
		C_ORANGE, Enum.Material.SmoothPlastic)

	-- Rear-facing camera (small unit on top edge of bay)
	VU.part(model, "RearCam",
		Vector3.new(0.5, 0.5, 0.5),
		CFrame.new(0, FLOOR_Y + 2.8, rearZ + 0.7),
		C_BLACK, Enum.Material.SmoothPlastic)
	VU.part(model, "RearCamLens",
		Vector3.new(0.3, 0.3, 0.1),
		CFrame.new(0, FLOOR_Y + 2.8, rearZ + 0.44),
		C_NEON_BLUE, Enum.Material.Neon)

	-- Taillights (orange neon)
	for _, sx in ipairs({-3.0, 3.0}) do
		VU.part(model, "Taillight",
			Vector3.new(0.8, 0.4, 0.15),
			CFrame.new(sx, FLOOR_Y + 1.5, rearZ + 0.5),
			C_NEON_ORANGE, Enum.Material.Neon)
	end

	-- NASA "worm" logo stripe (blue accent band on sides)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "NasaStripe" .. (sx == -1 and "L" or "R"),
			Vector3.new(0.08, 0.4, CHASSIS_LENGTH - 3),
			CFrame.new(sx * (CHASSIS_WIDTH / 2 + 0.02), FLOOR_Y + 0.2, 0),
			C_BLUE, Enum.Material.SmoothPlastic)
	end

	-- Orange neon underglow (subtle, like instrument lighting)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Underglow" .. (sx == -1 and "L" or "R"),
			Vector3.new(0.1, 0.15, CHASSIS_LENGTH - 4),
			CFrame.new(sx * (CHASSIS_WIDTH / 2 - 0.5), FLOOR_Y - 0.5, 0),
			C_NEON_ORANGE, Enum.Material.Neon)
	end

	-- (Antenna removed — dish provides comms)

	---------------------------------------------------------------------------
	-- Side mirrors (small, on cabin frame)
	---------------------------------------------------------------------------
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Mirror",
			Vector3.new(0.12, 0.4, 0.6),
			CFrame.new(sx * (CABIN_W / 2 + 0.4), CABIN_BASE_Y + 2.0, CABIN_Z + CABIN_LEN / 2 - 0.5),
			C_DARK_METAL, Enum.Material.Metal)
	end

	model.PrimaryPart = chassis
	return model
end

--------------------------------------------------------------------------------
-- DRIVABLE VERSION (player-controlled, VehicleSeat + headlight beam)
--------------------------------------------------------------------------------
function NasaRover.buildDrivable()
	local model = NasaRover.build()
	model.Name = "NasaRover_Drivable"

	-- VehicleSeat at driver position
	local seat = Instance.new("VehicleSeat")
	seat.Name = "DrivingSeat"
	seat.Size = Vector3.new(2, 0.5, 2)
	seat.CFrame = CFrame.new(-DRIVER_X, FLOOR_Y + 1.2, SEAT_Z) * CFrame.Angles(0, math.rad(180), 0)
	seat.Anchored = true
	seat.CanCollide = false
	seat.Transparency = 1
	seat.MaxSpeed = 0
	seat.HeadsUpDisplay = false
	seat.Parent = model

	-- Orange-tinted headlight beam
	local hl = model:FindFirstChild("HeadlightL")
	if hl then
		local spot = Instance.new("SpotLight")
		spot.Face = Enum.NormalId.Back
		spot.Brightness = 2
		spot.Range = 70
		spot.Angle = 55
		spot.Shadows = false
		spot.Color = Color3.fromRGB(255, 210, 140)  -- warm orange beam
		spot.Parent = hl
	end

	return model
end

return NasaRover
