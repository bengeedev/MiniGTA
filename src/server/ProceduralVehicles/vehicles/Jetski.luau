local VU = require(script.Parent:WaitForChild("VehicleUtils"))

local Jetski = {}

--------------------------------------------------------------------------------
-- JETSKI  (faces +Z forward, hull bottom at Y=0)
-- Compact personal watercraft: sleek hull, handlebar steering,
-- jet nozzle at rear, seat for one rider. Sits on water surface.
--------------------------------------------------------------------------------

-- Colors
local C_HULL       = Color3.fromRGB(20, 60, 140)    -- deep blue hull
local C_DECK       = Color3.fromRGB(240, 240, 245)   -- white deck/top
local C_ACCENT     = Color3.fromRGB(255, 200, 0)     -- yellow racing stripe
local C_BLACK      = Color3.fromRGB(25, 25, 28)
local C_DARK_METAL = Color3.fromRGB(50, 50, 55)
local C_CHROME     = Color3.fromRGB(185, 185, 190)
local C_RUBBER     = Color3.fromRGB(35, 35, 38)
local C_RED_NEON   = Color3.fromRGB(255, 30, 20)
local C_HEADLIGHT  = Color3.fromRGB(255, 245, 210)
local C_GLASS      = Color3.fromRGB(160, 200, 220)

-- Dimensions
local HULL_LENGTH = 10
local HULL_WIDTH  = 3.6
local HULL_HEIGHT = 1.6
local HULL_Y      = HULL_HEIGHT / 2  -- center of hull at 0.8

-- Seat positions
local SEAT_Y    = HULL_HEIGHT + 0.8  -- 2.4 (top of hull + seat cushion)
local DRIVER_X  = 0
local SEAT_Z    = -0.5

-- Exports for NPC seating & WorldLoader
Jetski.SEAT_Y   = SEAT_Y + 2.5  -- HRP position for R15 on seat
Jetski.DRIVER_X = DRIVER_X
Jetski.SEAT_Z   = SEAT_Z

function Jetski.build()
	local model = Instance.new("Model")
	model.Name = "Jetski_1"

	---------------------------------------------------------------------------
	-- HULL (main body — tapered wedge shape)
	---------------------------------------------------------------------------
	-- Main hull block
	local hull = VU.part(model, "Hull",
		Vector3.new(HULL_WIDTH, HULL_HEIGHT, HULL_LENGTH),
		CFrame.new(0, HULL_Y, 0),
		C_HULL, Enum.Material.SmoothPlastic)

	-- Bow (front taper — wedge narrowing forward)
	VU.wedge(model, "BowBottom",
		Vector3.new(HULL_WIDTH, HULL_HEIGHT, 3),
		CFrame.new(0, HULL_Y, HULL_LENGTH / 2 + 1.5),
		C_HULL, Enum.Material.SmoothPlastic)

	-- Stern (rear taper — slight wedge)
	VU.wedge(model, "Stern",
		Vector3.new(HULL_WIDTH - 0.4, HULL_HEIGHT * 0.6, 1.5),
		CFrame.new(0, HULL_Y * 0.6, -(HULL_LENGTH / 2 + 0.75))
			* CFrame.Angles(0, math.rad(180), 0),
		C_HULL, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- DECK (white top surface)
	---------------------------------------------------------------------------
	VU.part(model, "Deck",
		Vector3.new(HULL_WIDTH - 0.2, 0.3, HULL_LENGTH - 1),
		CFrame.new(0, HULL_HEIGHT + 0.15, 0.5),
		C_DECK, Enum.Material.SmoothPlastic)

	-- Bow deck (tapers with hull)
	VU.wedge(model, "BowDeck",
		Vector3.new(HULL_WIDTH - 0.2, 0.3, 2.5),
		CFrame.new(0, HULL_HEIGHT + 0.15, HULL_LENGTH / 2 + 1.25),
		C_DECK, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- RACING STRIPES (yellow accent along sides)
	---------------------------------------------------------------------------
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Stripe" .. (sx == -1 and "L" or "R"),
			Vector3.new(0.12, 0.4, HULL_LENGTH + 1),
			CFrame.new(sx * (HULL_WIDTH / 2 + 0.02), HULL_HEIGHT * 0.7, 0.5),
			C_ACCENT, Enum.Material.Neon)
	end

	---------------------------------------------------------------------------
	-- SEAT (rider saddle)
	---------------------------------------------------------------------------
	VU.part(model, "Seat",
		Vector3.new(1.8, 0.5, 3.5),
		CFrame.new(0, HULL_HEIGHT + 0.55, SEAT_Z),
		C_BLACK, Enum.Material.Leather)

	-- Seat back rest (small bump)
	VU.part(model, "SeatBack",
		Vector3.new(1.6, 0.8, 0.4),
		CFrame.new(0, HULL_HEIGHT + 0.9, SEAT_Z - 1.5),
		C_BLACK, Enum.Material.Leather)

	---------------------------------------------------------------------------
	-- HANDLEBAR COLUMN + HANDLEBARS
	---------------------------------------------------------------------------
	local steerZ = SEAT_Z + 2.5
	local steerY = HULL_HEIGHT + 1.5

	-- Steering column
	VU.part(model, "SteerColumn",
		Vector3.new(0.4, 1.8, 0.4),
		CFrame.new(0, steerY - 0.2, steerZ)
			* CFrame.Angles(math.rad(-15), 0, 0),
		C_DARK_METAL, Enum.Material.Metal)

	-- Handlebar crossbar
	VU.cylinder(model, "Handlebar",
		Vector3.new(2.8, 0.22, 0.22),
		CFrame.new(0, steerY + 0.7, steerZ + 0.3),
		C_CHROME, Enum.Material.Metal)

	-- Grips
	for _, sx in ipairs({-1, 1}) do
		VU.cylinder(model, "Grip" .. (sx == -1 and "L" or "R"),
			Vector3.new(0.5, 0.3, 0.3),
			CFrame.new(sx * 1.3, steerY + 0.7, steerZ + 0.3),
			C_RUBBER, Enum.Material.SmoothPlastic)
	end

	-- Small windshield / deflector
	local ws = VU.part(model, "Windshield",
		Vector3.new(2.2, 1.2, 0.1),
		CFrame.new(0, steerY + 0.3, steerZ + 0.6)
			* CFrame.Angles(math.rad(-20), 0, 0),
		C_GLASS, Enum.Material.Glass)
	ws.Transparency = 0.6

	-- Instrument cluster (small neon strip)
	VU.part(model, "InstrumentPanel",
		Vector3.new(1.2, 0.3, 0.1),
		CFrame.new(0, steerY + 0.0, steerZ + 0.5),
		C_ACCENT, Enum.Material.Neon)

	---------------------------------------------------------------------------
	-- HEADLIGHT
	---------------------------------------------------------------------------
	VU.part(model, "Headlight",
		Vector3.new(1.0, 0.5, 0.2),
		CFrame.new(0, HULL_HEIGHT + 0.4, HULL_LENGTH / 2 + 2.2),
		C_HEADLIGHT, Enum.Material.Neon)

	---------------------------------------------------------------------------
	-- JET NOZZLE (rear propulsion)
	---------------------------------------------------------------------------
	local nozzleZ = -(HULL_LENGTH / 2 + 1.5)

	-- Nozzle housing
	VU.cylinder(model, "NozzleHousing",
		Vector3.new(1.5, 1.4, 1.4),
		CFrame.new(0, HULL_Y, nozzleZ)
			* CFrame.Angles(0, math.rad(90), 0),
		C_DARK_METAL, Enum.Material.Metal)

	-- Inner nozzle (chrome)
	VU.cylinder(model, "NozzleInner",
		Vector3.new(0.8, 0.9, 0.9),
		CFrame.new(0, HULL_Y, nozzleZ - 0.5)
			* CFrame.Angles(0, math.rad(90), 0),
		C_CHROME, Enum.Material.Metal)

	-- Nozzle glow (blue)
	VU.cylinder(model, "NozzleGlow",
		Vector3.new(0.3, 0.7, 0.7),
		CFrame.new(0, HULL_Y, nozzleZ - 0.9)
			* CFrame.Angles(0, math.rad(90), 0),
		Color3.fromRGB(0, 160, 255), Enum.Material.Neon)

	---------------------------------------------------------------------------
	-- TAILLIGHT
	---------------------------------------------------------------------------
	VU.part(model, "Taillight",
		Vector3.new(1.4, 0.3, 0.15),
		CFrame.new(0, HULL_HEIGHT + 0.3, -(HULL_LENGTH / 2 + 0.1)),
		C_RED_NEON, Enum.Material.Neon)

	---------------------------------------------------------------------------
	-- INTAKE GRATES (side vents)
	---------------------------------------------------------------------------
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Intake" .. (sx == -1 and "L" or "R"),
			Vector3.new(0.15, 0.6, 2.0),
			CFrame.new(sx * (HULL_WIDTH / 2 - 0.1), HULL_HEIGHT * 0.5, -2.0),
			C_DARK_METAL, Enum.Material.DiamondPlate)
	end

	---------------------------------------------------------------------------
	-- WATER SPRAY (particle emitter from rear)
	---------------------------------------------------------------------------
	local sprayPart = Instance.new("Part")
	sprayPart.Name = "WaterSpray"
	sprayPart.Size = Vector3.new(0.5, 0.5, 0.5)
	sprayPart.Position = Vector3.new(0, HULL_Y * 0.5, nozzleZ - 1)
	sprayPart.Anchored = true
	sprayPart.CanCollide = false
	sprayPart.Transparency = 1
	sprayPart.Parent = model

	local spray = Instance.new("ParticleEmitter")
	spray.Name = "JetSpray"
	spray.Rate = 40
	spray.Speed = NumberRange.new(8, 18)
	spray.Lifetime = NumberRange.new(0.3, 0.8)
	spray.SpreadAngle = Vector2.new(15, 8)
	spray.EmissionDirection = Enum.NormalId.Back
	spray.LightEmission = 0.3
	spray.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.3, 0.8),
		NumberSequenceKeypoint.new(1, 1.5),
	})
	spray.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.5, 0.5),
		NumberSequenceKeypoint.new(1, 1),
	})
	spray.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 220, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 235, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(230, 245, 255)),
	})
	spray.Brightness = 1.5
	spray.Parent = sprayPart

	model.PrimaryPart = hull
	return model
end

--------------------------------------------------------------------------------
-- DRIVABLE VERSION (player-controlled, VehicleSeat + headlight beam)
--------------------------------------------------------------------------------
function Jetski.buildDrivable()
	local model = Jetski.build()
	model.Name = "Jetski_Drivable"

	-- VehicleSeat on the saddle
	local seat = Instance.new("VehicleSeat")
	seat.Name = "DrivingSeat"
	seat.Size = Vector3.new(2, 0.5, 2)
	seat.CFrame = CFrame.new(0, HULL_HEIGHT + 0.6, SEAT_Z) * CFrame.Angles(0, math.rad(180), 0)
	seat.Anchored = true
	seat.CanCollide = false
	seat.Transparency = 1
	seat.MaxSpeed = 0
	seat.HeadsUpDisplay = false
	seat.Parent = model

	return model
end

return Jetski
