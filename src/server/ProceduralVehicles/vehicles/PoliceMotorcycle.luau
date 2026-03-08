local VU = require(script.Parent:WaitForChild("VehicleUtils"))

local PoliceMotorcycle = {}

local CHROME = Color3.fromRGB(185, 185, 190)
local BLACK = Color3.fromRGB(25, 25, 28)
local DARK_BLUE = Color3.fromRGB(12, 22, 55)
local WHITE = Color3.fromRGB(185, 190, 195)
local RED_NEON = Color3.fromRGB(255, 30, 20)
local BLUE_NEON = Color3.fromRGB(30, 80, 255)
local DARK_METAL = Color3.fromRGB(50, 50, 55)
local RUBBER = Color3.fromRGB(35, 35, 38)

local POLICE_BLUE  = Color3.fromRGB(20, 35, 80)
local POLICE_BLACK = Color3.fromRGB(25, 25, 28)
local SKIN_TONE    = Color3.fromRGB(210, 170, 130)

local function addPartBasedMotorcycleRider(motoModel)
	local seatTopY = 4.0
	local seatZ    = -0.8

	VU.part(motoModel, "RiderLegs",
		Vector3.new(2.2, 0.8, 1.5),
		CFrame.new(0, seatTopY, seatZ),
		POLICE_BLACK, Enum.Material.SmoothPlastic)

	VU.part(motoModel, "RiderTorso",
		Vector3.new(1.8, 2.0, 1.0),
		CFrame.new(0, seatTopY + 1.3, seatZ + 0.3)
			* CFrame.Angles(math.rad(-10), 0, 0),
		POLICE_BLUE, Enum.Material.SmoothPlastic)

	for _, sx in ipairs({-1, 1}) do
		VU.part(motoModel, "RiderArm",
			Vector3.new(0.5, 0.5, 1.8),
			CFrame.new(sx * 0.9, seatTopY + 1.5, seatZ + 1.4)
				* CFrame.Angles(math.rad(-20), 0, 0),
			POLICE_BLUE, Enum.Material.SmoothPlastic)
	end

	VU.ball(motoModel, "RiderHead",
		Vector3.new(1.3, 1.3, 1.3),
		CFrame.new(0, seatTopY + 2.8, seatZ + 0.4),
		SKIN_TONE, Enum.Material.SmoothPlastic)

	VU.ball(motoModel, "RiderHelmet",
		Vector3.new(1.5, 1.2, 1.5),
		CFrame.new(0, seatTopY + 3.1, seatZ + 0.4),
		POLICE_BLACK, Enum.Material.SmoothPlastic)
end

function PoliceMotorcycle.build()
	local model = Instance.new("Model")
	model.Name = "Motorcycle_Police_1"

	local wheelR = 2.2
	local wheelW = 1.0
	local wheelBase = 10

	local frontZ = wheelBase / 2
	local rearZ = -wheelBase / 2

	-- WHEELS
	VU.cylinder(model, "FrontTire",
		Vector3.new(wheelW, wheelR * 2, wheelR * 2),
		CFrame.new(0, wheelR, frontZ),
		RUBBER, Enum.Material.SmoothPlastic)

	VU.cylinder(model, "FrontHub",
		Vector3.new(wheelW + 0.15, wheelR * 0.7, wheelR * 0.7),
		CFrame.new(0, wheelR, frontZ),
		CHROME, Enum.Material.Metal)

	VU.cylinder(model, "RearTire",
		Vector3.new(wheelW + 0.2, wheelR * 2.1, wheelR * 2.1),
		CFrame.new(0, wheelR, rearZ),
		RUBBER, Enum.Material.SmoothPlastic)

	VU.cylinder(model, "RearHub",
		Vector3.new(wheelW + 0.3, wheelR * 0.7, wheelR * 0.7),
		CFrame.new(0, wheelR, rearZ),
		CHROME, Enum.Material.Metal)

	-- FRAME
	VU.part(model, "MainFrame",
		Vector3.new(0.8, 0.8, wheelBase * 0.6),
		CFrame.new(0, wheelR + 1, 0),
		DARK_METAL, Enum.Material.Metal)

	VU.part(model, "Swingarm",
		Vector3.new(0.6, 0.5, 3.5),
		CFrame.new(0, wheelR, rearZ + 1.8),
		DARK_METAL, Enum.Material.Metal)

	-- ENGINE BLOCK
	VU.part(model, "EngineBlock",
		Vector3.new(2.8, 2, 3),
		CFrame.new(0, wheelR, 0),
		DARK_METAL, Enum.Material.DiamondPlate)

	-- FUEL TANK
	VU.part(model, "FuelTank",
		Vector3.new(2.5, 1.6, 3.5),
		CFrame.new(0, wheelR + 2.2, 1),
		DARK_BLUE, Enum.Material.SmoothPlastic)

	VU.part(model, "TankStripe",
		Vector3.new(2.52, 0.35, 2.2),
		CFrame.new(0, wheelR + 2.9, 1),
		WHITE, Enum.Material.SmoothPlastic)

	-- SEAT
	VU.part(model, "Seat",
		Vector3.new(2, 0.5, 3.5),
		CFrame.new(0, wheelR + 1.8, -1.8),
		BLACK, Enum.Material.Leather)

	-- FRONT FORKS
	local steerY = wheelR + 2.8
	local forkLen = 4.5
	for _, sx in ipairs({-0.4, 0.4}) do
		VU.part(model, "Fork",
			Vector3.new(0.3, forkLen, 0.3),
			CFrame.new(sx, wheelR + forkLen / 2 - 0.3, frontZ - 0.8)
				* CFrame.Angles(math.rad(20), 0, 0),
			CHROME, Enum.Material.Metal)
	end

	VU.part(model, "SteerHead",
		Vector3.new(1.2, 0.8, 0.6),
		CFrame.new(0, steerY + 1.2, frontZ - 1.5),
		DARK_METAL, Enum.Material.Metal)

	-- HANDLEBARS
	VU.cylinder(model, "Handlebar",
		Vector3.new(3.5, 0.25, 0.25),
		CFrame.new(0, steerY + 1.8, frontZ - 1.2),
		CHROME, Enum.Material.Metal)

	for _, sx in ipairs({-1, 1}) do
		VU.cylinder(model, "Grip",
			Vector3.new(0.6, 0.35, 0.35),
			CFrame.new(sx * 1.9, steerY + 1.8, frontZ - 1.2),
			RUBBER, Enum.Material.SmoothPlastic)
	end

	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Mirror",
			Vector3.new(0.5, 0.1, 0.7),
			CFrame.new(sx * 2.1, steerY + 2.0, frontZ - 0.9),
			CHROME, Enum.Material.Metal)
	end

	-- WINDSHIELD / FAIRING
	local wsBase = steerY + 0.5
	local ws = VU.part(model, "Windshield",
		Vector3.new(2.8, 3.5, 0.15),
		CFrame.new(0, wsBase + 1.75, frontZ - 0.5)
			* CFrame.Angles(math.rad(-10), 0, 0),
		Color3.fromRGB(200, 220, 240), Enum.Material.Glass)
	ws.Transparency = 0.6

	VU.part(model, "Fairing",
		Vector3.new(3.0, 1.8, 1.5),
		CFrame.new(0, steerY, frontZ - 1.8),
		WHITE, Enum.Material.SmoothPlastic)

	-- HEADLIGHT
	VU.part(model, "Headlight",
		Vector3.new(1.2, 0.8, 0.3),
		CFrame.new(0, steerY + 0.2, frontZ - 0.3),
		Color3.fromRGB(255, 245, 210), Enum.Material.Neon)

	-- FENDERS
	VU.part(model, "FrontFender",
		Vector3.new(1.4, 0.2, 2.5),
		CFrame.new(0, wheelR * 2 + 0.2, frontZ),
		WHITE, Enum.Material.SmoothPlastic)

	VU.part(model, "RearFender",
		Vector3.new(1.6, 0.2, 3.0),
		CFrame.new(0, wheelR * 1.5, rearZ - 0.3),
		WHITE, Enum.Material.SmoothPlastic)

	VU.part(model, "Taillight",
		Vector3.new(1.2, 0.4, 0.25),
		CFrame.new(0, wheelR * 1.5, rearZ - 1.7),
		Color3.fromRGB(200, 20, 15), Enum.Material.Neon)

	-- EXHAUST PIPES
	VU.cylinder(model, "ExhaustPipe",
		Vector3.new(5, 0.4, 0.4),
		CFrame.new(1.0, wheelR - 0.4, -1)
			* CFrame.Angles(0, math.rad(90), 0),
		CHROME, Enum.Material.Metal)

	VU.cylinder(model, "ExhaustTip",
		Vector3.new(0.6, 0.5, 0.5),
		CFrame.new(1.0, wheelR - 0.4, -3.8)
			* CFrame.Angles(0, math.rad(90), 0),
		CHROME, Enum.Material.Metal)

	-- SADDLEBAGS
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Saddlebag",
			Vector3.new(1.2, 1.8, 2.8),
			CFrame.new(sx * 1.6, wheelR + 0.8, -2.5),
			WHITE, Enum.Material.SmoothPlastic)
		VU.part(model, "BagStripe",
			Vector3.new(1.22, 0.2, 2.0),
			CFrame.new(sx * 1.6, wheelR + 1.2, -2.5),
			DARK_BLUE, Enum.Material.SmoothPlastic)
	end

	-- REAR TRUNK BOX
	VU.part(model, "TopCase",
		Vector3.new(2.4, 1.2, 1.8),
		CFrame.new(0, wheelR + 2.2, -3.5),
		BLACK, Enum.Material.SmoothPlastic)

	-- POLICE LIGHTS (light bar on top case)
	local lightBarY = wheelR + 3.2
	local lightBarZ = -3.5

	-- Light bar base
	VU.part(model, "LightBarBase",
		Vector3.new(2.6, 0.2, 1.0),
		CFrame.new(0, lightBarY - 0.1, lightBarZ),
		DARK_METAL, Enum.Material.SmoothPlastic)

	-- Red lights (left side) - PointLights disabled (testing flickering)
	VU.part(model, "LightRed1",
		Vector3.new(0.9, 0.5, 0.7),
		CFrame.new(-0.7, lightBarY + 0.2, lightBarZ),
		RED_NEON, Enum.Material.Neon)
	VU.part(model, "LightRed2",
		Vector3.new(0.5, 0.4, 0.5),
		CFrame.new(-0.15, lightBarY + 0.15, lightBarZ),
		RED_NEON, Enum.Material.Neon)

	-- Blue lights (right side) - PointLights disabled (testing flickering)
	VU.part(model, "LightBlue1",
		Vector3.new(0.9, 0.5, 0.7),
		CFrame.new(0.7, lightBarY + 0.2, lightBarZ),
		BLUE_NEON, Enum.Material.Neon)
	VU.part(model, "LightBlue2",
		Vector3.new(0.5, 0.4, 0.5),
		CFrame.new(0.15, lightBarY + 0.15, lightBarZ),
		BLUE_NEON, Enum.Material.Neon)

	model.PrimaryPart = model:FindFirstChild("EngineBlock")

	return model
end

PoliceMotorcycle.addPartBasedRider = addPartBasedMotorcycleRider

-- Seat constants for NPC seating / drivable
local WHEEL_RADIUS = 2.2
PoliceMotorcycle.SEAT_Y = WHEEL_RADIUS + 1.8 + 2.5  -- 6.5 (HRP position for R15 on seat)
PoliceMotorcycle.DRIVER_X = 0
PoliceMotorcycle.SEAT_Z = -0.8

--------------------------------------------------------------------------------
-- DRIVABLE VERSION (player-controlled, VehicleSeat + headlight beam)
--------------------------------------------------------------------------------
function PoliceMotorcycle.buildDrivable()
	local model = PoliceMotorcycle.build()
	model.Name = "PoliceMotorcycle_Drivable"

	-- VehicleSeat on the motorcycle seat
	local seat = Instance.new("VehicleSeat")
	seat.Name = "DrivingSeat"
	seat.Size = Vector3.new(2, 0.5, 2)
	seat.CFrame = CFrame.new(0, WHEEL_RADIUS + 1.8 + 0.3, -0.8) * CFrame.Angles(0, math.rad(180), 0)
	seat.Anchored = true
	seat.CanCollide = false
	seat.Transparency = 1
	seat.MaxSpeed = 0
	seat.HeadsUpDisplay = false
	seat.Parent = model

	-- Headlight beam disabled (testing flickering)
	-- local hl = model:FindFirstChild("Headlight")
	-- if hl then
	-- 	local spot = Instance.new("SpotLight")
	-- 	spot.Face = Enum.NormalId.Front
	-- 	spot.Brightness = 2.5
	-- 	spot.Range = 70
	-- 	spot.Angle = 55
	-- 	spot.Shadows = false
	-- 	spot.Color = Color3.fromRGB(255, 245, 210)
	-- 	spot.Parent = hl
	-- end

	return model
end

--------------------------------------------------------------------------------
-- ENEMY VARIANT (dark red/black aggressive recolor with rider)
--------------------------------------------------------------------------------
function PoliceMotorcycle.buildEnemy()
	local model = Instance.new("Model")
	model.Name = "EnemyMotorcycle_1"

	-- Aggressive palette
	local E_BODY    = Color3.fromRGB(120, 20, 20)   -- dark crimson
	local E_ACCENT  = Color3.fromRGB(30, 30, 35)    -- near-black trim
	local E_METAL   = Color3.fromRGB(40, 40, 45)
	local E_CHROME  = Color3.fromRGB(80, 80, 85)    -- tarnished chrome
	local E_RED     = Color3.fromRGB(255, 40, 30)

	local wheelR = 2.2
	local wheelW = 1.0
	local wheelBase = 10
	local frontZ = wheelBase / 2
	local rearZ = -wheelBase / 2

	-- Wheels
	VU.cylinder(model, "FrontTire",
		Vector3.new(wheelW, wheelR * 2, wheelR * 2),
		CFrame.new(0, wheelR, frontZ),
		RUBBER, Enum.Material.SmoothPlastic)
	VU.cylinder(model, "FrontHub",
		Vector3.new(wheelW + 0.15, wheelR * 0.7, wheelR * 0.7),
		CFrame.new(0, wheelR, frontZ),
		E_CHROME, Enum.Material.Metal)
	VU.cylinder(model, "RearTire",
		Vector3.new(wheelW + 0.2, wheelR * 2.1, wheelR * 2.1),
		CFrame.new(0, wheelR, rearZ),
		RUBBER, Enum.Material.SmoothPlastic)
	VU.cylinder(model, "RearHub",
		Vector3.new(wheelW + 0.3, wheelR * 0.7, wheelR * 0.7),
		CFrame.new(0, wheelR, rearZ),
		E_CHROME, Enum.Material.Metal)

	-- Frame + engine
	VU.part(model, "MainFrame",
		Vector3.new(0.8, 0.8, wheelBase * 0.6),
		CFrame.new(0, wheelR + 1, 0),
		E_METAL, Enum.Material.Metal)
	VU.part(model, "Swingarm",
		Vector3.new(0.6, 0.5, 3.5),
		CFrame.new(0, wheelR, rearZ + 1.8),
		E_METAL, Enum.Material.Metal)
	VU.part(model, "EngineBlock",
		Vector3.new(2.8, 2, 3),
		CFrame.new(0, wheelR, 0),
		E_METAL, Enum.Material.DiamondPlate)

	-- Fuel tank (crimson)
	VU.part(model, "FuelTank",
		Vector3.new(2.5, 1.6, 3.5),
		CFrame.new(0, wheelR + 2.2, 1),
		E_BODY, Enum.Material.SmoothPlastic)
	VU.part(model, "TankStripe",
		Vector3.new(2.52, 0.35, 2.2),
		CFrame.new(0, wheelR + 2.9, 1),
		E_ACCENT, Enum.Material.SmoothPlastic)

	-- Seat
	VU.part(model, "Seat",
		Vector3.new(2, 0.5, 3.5),
		CFrame.new(0, wheelR + 1.8, -1.8),
		E_ACCENT, Enum.Material.Leather)

	-- Front forks
	local steerY = wheelR + 2.8
	for _, sx in ipairs({-0.4, 0.4}) do
		VU.part(model, "Fork",
			Vector3.new(0.3, 4.5, 0.3),
			CFrame.new(sx, wheelR + 4.5 / 2 - 0.3, frontZ - 0.8)
				* CFrame.Angles(math.rad(20), 0, 0),
			E_CHROME, Enum.Material.Metal)
	end
	VU.part(model, "SteerHead",
		Vector3.new(1.2, 0.8, 0.6),
		CFrame.new(0, steerY + 1.2, frontZ - 1.5),
		E_METAL, Enum.Material.Metal)

	-- Handlebars
	VU.cylinder(model, "Handlebar",
		Vector3.new(3.5, 0.25, 0.25),
		CFrame.new(0, steerY + 1.8, frontZ - 1.2),
		E_CHROME, Enum.Material.Metal)

	-- Fairing (dark)
	VU.part(model, "Fairing",
		Vector3.new(3.0, 1.8, 1.5),
		CFrame.new(0, steerY, frontZ - 1.8),
		E_ACCENT, Enum.Material.SmoothPlastic)

	-- Headlight (red-tinted)
	VU.part(model, "Headlight",
		Vector3.new(1.2, 0.8, 0.3),
		CFrame.new(0, steerY + 0.2, frontZ - 0.3),
		E_RED, Enum.Material.Neon)

	-- Fenders
	VU.part(model, "FrontFender",
		Vector3.new(1.4, 0.2, 2.5),
		CFrame.new(0, wheelR * 2 + 0.2, frontZ),
		E_ACCENT, Enum.Material.SmoothPlastic)
	VU.part(model, "RearFender",
		Vector3.new(1.6, 0.2, 3.0),
		CFrame.new(0, wheelR * 1.5, rearZ - 0.3),
		E_ACCENT, Enum.Material.SmoothPlastic)

	-- Taillight
	VU.part(model, "Taillight",
		Vector3.new(1.2, 0.4, 0.25),
		CFrame.new(0, wheelR * 1.5, rearZ - 1.7),
		E_RED, Enum.Material.Neon)

	-- Exhaust
	VU.cylinder(model, "ExhaustPipe",
		Vector3.new(5, 0.4, 0.4),
		CFrame.new(1.0, wheelR - 0.4, -1)
			* CFrame.Angles(0, math.rad(90), 0),
		E_CHROME, Enum.Material.Metal)

	-- Red-only lights (both sides)
	local lightBarY = wheelR + 3.2
	local lightBarZ = -3.5
	VU.part(model, "LightBarBase",
		Vector3.new(2.6, 0.2, 1.0),
		CFrame.new(0, lightBarY - 0.1, lightBarZ),
		E_METAL, Enum.Material.SmoothPlastic)
	VU.part(model, "LightRed1",
		Vector3.new(0.9, 0.5, 0.7),
		CFrame.new(-0.7, lightBarY + 0.2, lightBarZ),
		E_RED, Enum.Material.Neon)
	-- PointLight disabled (testing flickering)
	VU.part(model, "LightRed2",
		Vector3.new(0.5, 0.4, 0.5),
		CFrame.new(-0.15, lightBarY + 0.15, lightBarZ),
		E_RED, Enum.Material.Neon)
	VU.part(model, "LightRed3",
		Vector3.new(0.9, 0.5, 0.7),
		CFrame.new(0.7, lightBarY + 0.2, lightBarZ),
		E_RED, Enum.Material.Neon)
	-- PointLight disabled (testing flickering)
	VU.part(model, "LightRed4",
		Vector3.new(0.5, 0.4, 0.5),
		CFrame.new(0.15, lightBarY + 0.15, lightBarZ),
		E_RED, Enum.Material.Neon)

	model.PrimaryPart = model:FindFirstChild("EngineBlock")
	return model
end

return PoliceMotorcycle
