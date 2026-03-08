local VU = require(script.Parent:WaitForChild("VehicleUtils"))

local WaterRunner = {}

--------------------------------------------------------------------------------
-- WATER RUNNER  (faces +Z forward, wheels on ground at Y=0)
-- Water treatment utility pickup: armored cab with roll cage (open-top),
-- dark teal body, cyan neon accents, water cannon on roof rack, rear water tanks.
--------------------------------------------------------------------------------

-- Colors
local C_BODY          = Color3.fromRGB(40, 85, 120)    -- dark teal
local C_CYAN_NEON     = Color3.fromRGB(0, 200, 255)    -- signature cyan
local C_DARK_METAL    = Color3.fromRGB(50, 50, 55)
local C_METAL_FRAME   = Color3.fromRGB(70, 70, 75)
local C_GLASS         = Color3.fromRGB(140, 190, 220)  -- blue-tinted glass
local C_BLACK         = Color3.fromRGB(25, 25, 28)
local C_TIRE          = Color3.fromRGB(25, 25, 25)
local C_RIM           = Color3.fromRGB(90, 90, 95)
local C_BED           = Color3.fromRGB(35, 70, 100)    -- darker teal for bed
local C_TANK          = Color3.fromRGB(60, 100, 140)   -- tank body
local C_CONCRETE      = Color3.fromRGB(120, 125, 130)  -- accents

-- Dimensions (same as HazmatRunner)
local CHASSIS_LENGTH = 14
local CHASSIS_WIDTH  = 8
local WHEEL_R   = 2.0
local WHEEL_W   = 1.5
local FRONT_Z   = 5.5
local REAR_Z    = -5.5
local HALF_W    = 4.0
local FLOOR_Y   = WHEEL_R + 0.5  -- 2.5
local CAB_TOP   = FLOOR_Y + 6.5  -- 9.0 (roll cage top)

-- Seat positions (left-hand drive)
local DRIVER_X    = -1.5
local PASSENGER_X = 1.5
local SEAT_Z      = 0.0
local SEAT_Y      = FLOOR_Y + 1.8  -- 4.3

-- Exports for NPC seating
WaterRunner.FLOOR_Y = FLOOR_Y
WaterRunner.SEAT_Y = SEAT_Y
WaterRunner.DRIVER_X = DRIVER_X
WaterRunner.PASSENGER_X = PASSENGER_X
WaterRunner.SEAT_Z = SEAT_Z

function WaterRunner.build()
	local model = Instance.new("Model")
	model.Name = "WaterRunner_1"

	---------------------------------------------------------------------------
	-- WHEELS (4 chunky off-road)
	---------------------------------------------------------------------------
	for _, wz in ipairs({FRONT_Z, REAR_Z}) do
		for _, sx in ipairs({-1, 1}) do
			VU.cylinder(model, "Tire",
				Vector3.new(WHEEL_W, WHEEL_R * 2, WHEEL_R * 2),
				CFrame.new(sx * HALF_W, WHEEL_R, wz),
				C_TIRE, Enum.Material.SmoothPlastic)
			VU.cylinder(model, "Hub",
				Vector3.new(WHEEL_W + 0.15, WHEEL_R * 0.6, WHEEL_R * 0.6),
				CFrame.new(sx * HALF_W, WHEEL_R, wz),
				C_RIM, Enum.Material.Metal)
		end
	end

	---------------------------------------------------------------------------
	-- CHASSIS (flat armored platform)
	---------------------------------------------------------------------------
	local chassis = VU.part(model, "Chassis",
		Vector3.new(CHASSIS_WIDTH, 1.4, CHASSIS_LENGTH),
		CFrame.new(0, FLOOR_Y, 0),
		C_BODY, Enum.Material.SmoothPlastic)

	-- Cyan neon underglow strips on chassis sides
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Underglow" .. (sx == -1 and "L" or "R"),
			Vector3.new(0.12, 0.2, CHASSIS_LENGTH - 2),
			CFrame.new(sx * (CHASSIS_WIDTH / 2 + 0.08), FLOOR_Y - 0.4, 0),
			C_CYAN_NEON, Enum.Material.Neon)
	end

	---------------------------------------------------------------------------
	-- FRONT: Hood + Push Bar
	---------------------------------------------------------------------------
	-- Angled hood wedge
	VU.wedge(model, "Hood",
		Vector3.new(CHASSIS_WIDTH - 0.5, 1.2, 3.5),
		CFrame.new(0, FLOOR_Y + 1, 4.5) * CFrame.Angles(0, math.rad(180), 0),
		C_BODY, Enum.Material.SmoothPlastic)

	-- Flat hood top
	VU.part(model, "HoodTop",
		Vector3.new(CHASSIS_WIDTH - 0.5, 0.2, 3),
		CFrame.new(0, FLOOR_Y + 1.6, 3),
		C_BODY, Enum.Material.SmoothPlastic)

	-- Push bar (heavy duty)
	VU.part(model, "PushBar",
		Vector3.new(CHASSIS_WIDTH - 0.5, 2.0, 0.6),
		CFrame.new(0, FLOOR_Y + 0.7, 6.8),
		C_DARK_METAL, Enum.Material.Metal)

	-- Cyan headlights
	for _, sx in ipairs({-2.5, 2.5}) do
		VU.cylinder(model, "Headlight" .. (sx < 0 and "L" or "R"),
			Vector3.new(0.3, 1.2, 1.2),
			CFrame.new(sx, FLOOR_Y + 1.3, 6.5) * CFrame.Angles(0, math.rad(90), 0),
			C_CYAN_NEON, Enum.Material.Neon)
	end

	---------------------------------------------------------------------------
	-- SIDE PANELS (armored lower body)
	---------------------------------------------------------------------------
	local sideH = 2.0
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "SidePanel" .. (sx == -1 and "L" or "R"),
			Vector3.new(0.4, sideH, 7),
			CFrame.new(sx * (CHASSIS_WIDTH / 2 - 0.1), FLOOR_Y + sideH / 2 + 0.2, -0.5),
			C_BODY, Enum.Material.SmoothPlastic)

		-- Cyan neon door line band
		VU.part(model, "DoorNeon" .. (sx == -1 and "L" or "R"),
			Vector3.new(0.12, 0.15, 5),
			CFrame.new(sx * (CHASSIS_WIDTH / 2), FLOOR_Y + sideH / 2 + 0.2, -0.5),
			C_CYAN_NEON, Enum.Material.Neon)
	end

	---------------------------------------------------------------------------
	-- SEAT BENCH + DASHBOARD
	---------------------------------------------------------------------------
	VU.part(model, "SeatBench",
		Vector3.new(6.4, 0.4, 2.5),
		CFrame.new(0, FLOOR_Y + 0.9, SEAT_Z),
		Color3.fromRGB(30, 60, 80), Enum.Material.Fabric)
	VU.part(model, "SeatBack",
		Vector3.new(6.4, 2.5, 0.4),
		CFrame.new(0, FLOOR_Y + 2.2, SEAT_Z - 1.2),
		Color3.fromRGB(30, 60, 80), Enum.Material.Fabric)

	-- Dashboard
	VU.part(model, "Dashboard",
		Vector3.new(CHASSIS_WIDTH - 1, 1.0, 0.5),
		CFrame.new(0, FLOOR_Y + 2.0, 2.5),
		C_BLACK, Enum.Material.SmoothPlastic)
	-- Instrument panel glow (cyan)
	VU.part(model, "InstrumentPanel",
		Vector3.new(3, 0.4, 0.12),
		CFrame.new(0, FLOOR_Y + 2.4, 2.72),
		C_CYAN_NEON, Enum.Material.Neon)

	---------------------------------------------------------------------------
	-- WINDSHIELD (blue-tinted glass, slightly angled)
	---------------------------------------------------------------------------
	local windshield = VU.part(model, "Windshield",
		Vector3.new(CHASSIS_WIDTH - 1.5, 3.0, 0.15),
		CFrame.new(0, FLOOR_Y + 3.5, 3.0) * CFrame.Angles(math.rad(-10), 0, 0),
		C_GLASS, Enum.Material.Glass)
	windshield.Transparency = 0.6

	---------------------------------------------------------------------------
	-- ROLL CAGE (open-top cab — no roof, just metal frame bars)
	---------------------------------------------------------------------------
	local cageBaseY = FLOOR_Y + sideH + 0.3
	local cageTopY = CAB_TOP
	local cageH = cageTopY - cageBaseY
	local cageW = CHASSIS_WIDTH - 0.8
	local cageLen = 7.5
	local cageZ = -0.5

	-- 4 vertical corner posts
	for _, sx in ipairs({-1, 1}) do
		for _, szOff in ipairs({cageLen / 2, -cageLen / 2}) do
			VU.part(model, "CagePost",
				Vector3.new(0.3, cageH, 0.3),
				CFrame.new(sx * (cageW / 2), cageBaseY + cageH / 2, cageZ + szOff),
				C_METAL_FRAME, Enum.Material.Metal)
		end
	end

	-- Top frame bars (front, rear, sides)
	VU.part(model, "CageTopFront",
		Vector3.new(cageW + 0.3, 0.3, 0.3),
		CFrame.new(0, cageTopY, cageZ + cageLen / 2),
		C_METAL_FRAME, Enum.Material.Metal)
	VU.part(model, "CageTopRear",
		Vector3.new(cageW + 0.3, 0.3, 0.3),
		CFrame.new(0, cageTopY, cageZ - cageLen / 2),
		C_METAL_FRAME, Enum.Material.Metal)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "CageTopSide" .. (sx == -1 and "L" or "R"),
			Vector3.new(0.3, 0.3, cageLen + 0.3),
			CFrame.new(sx * (cageW / 2), cageTopY, cageZ),
			C_METAL_FRAME, Enum.Material.Metal)
	end

	-- 2 cross-braces over the top (roof rack bars)
	for _, ofs in ipairs({-1.5, 1.5}) do
		VU.part(model, "RoofRack",
			Vector3.new(cageW + 0.3, 0.25, 0.25),
			CFrame.new(0, cageTopY + 0.15, cageZ + ofs),
			C_METAL_FRAME, Enum.Material.Metal)
	end

	---------------------------------------------------------------------------
	-- WATER CANNON on roof rack (the signature feature)
	---------------------------------------------------------------------------
	-- Cannon base (turret disc)
	VU.cylinder(model, "CannonBase",
		Vector3.new(0.4, 2.0, 2.0),
		CFrame.new(0, cageTopY + 0.5, cageZ) * CFrame.Angles(0, 0, math.rad(90)),
		C_DARK_METAL, Enum.Material.Metal)

	-- Cannon barrel (long cylinder pointing forward)
	local barrelLen = 4.0
	VU.cylinder(model, "CannonBarrel",
		Vector3.new(barrelLen, 0.8, 0.8),
		CFrame.new(0, cageTopY + 0.8, cageZ + barrelLen / 2 + 0.5)
			* CFrame.Angles(0, math.rad(90), 0),
		C_DARK_METAL, Enum.Material.Metal)

	-- Cyan neon nozzle tip
	VU.cylinder(model, "CannonNozzle",
		Vector3.new(0.3, 1.0, 1.0),
		CFrame.new(0, cageTopY + 0.8, cageZ + barrelLen + 0.8)
			* CFrame.Angles(0, math.rad(90), 0),
		C_CYAN_NEON, Enum.Material.Neon)

	-- Water spray ParticleEmitter from cannon nozzle
	local nozzlePart = Instance.new("Part")
	nozzlePart.Name = "CannonSpray"
	nozzlePart.Size = Vector3.new(0.5, 0.5, 0.5)
	nozzlePart.Position = Vector3.new(0, cageTopY + 0.8, cageZ + barrelLen + 1.2)
	nozzlePart.Anchored = true
	nozzlePart.CanCollide = false
	nozzlePart.Transparency = 1
	nozzlePart.Parent = model

	local spray = Instance.new("ParticleEmitter")
	spray.Name = "WaterSpray"
	spray.Rate = 30
	spray.Speed = NumberRange.new(6, 14)
	spray.Lifetime = NumberRange.new(0.4, 1.0)
	spray.SpreadAngle = Vector2.new(12, 12)
	spray.EmissionDirection = Enum.NormalId.Front
	spray.LightEmission = 0.4
	spray.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.4, 1.0),
		NumberSequenceKeypoint.new(1, 2.0),
	})
	spray.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(0.5, 0.4),
		NumberSequenceKeypoint.new(1, 1),
	})
	spray.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 200, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 220, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 240, 255)),
	})
	spray.Brightness = 2
	spray.Parent = nozzlePart

	---------------------------------------------------------------------------
	-- REAR UTILITY BED with water tanks
	---------------------------------------------------------------------------
	local bedZ = -3.5
	local bedLen = 5.5
	VU.part(model, "BedFloor",
		Vector3.new(CHASSIS_WIDTH - 0.5, 0.3, bedLen),
		CFrame.new(0, FLOOR_Y + 0.15, bedZ),
		C_BED, Enum.Material.DiamondPlate)

	-- Bed side rails
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "BedRail" .. (sx == -1 and "L" or "R"),
			Vector3.new(0.3, 1.5, bedLen),
			CFrame.new(sx * 3.55, FLOOR_Y + 0.95, bedZ),
			C_DARK_METAL, Enum.Material.Metal)
	end

	-- Rear gate
	VU.part(model, "RearGate",
		Vector3.new(CHASSIS_WIDTH - 0.5, 1.5, 0.3),
		CFrame.new(0, FLOOR_Y + 0.95, bedZ - bedLen / 2),
		C_DARK_METAL, Enum.Material.Metal)

	-- 2 horizontal water tanks in the bed
	local tankR = 0.9
	local tankLen = 4.0
	for _, sx in ipairs({-1.5, 1.5}) do
		VU.cylinder(model, "WaterTank",
			Vector3.new(tankLen, tankR * 2, tankR * 2),
			CFrame.new(sx, FLOOR_Y + 0.4 + tankR + 0.2, bedZ)
				* CFrame.Angles(0, math.rad(90), 0),
			C_TANK, Enum.Material.Metal)
		-- Cyan neon band on each tank
		VU.cylinder(model, "TankBand",
			Vector3.new(0.3, tankR * 2.05, tankR * 2.05),
			CFrame.new(sx, FLOOR_Y + 0.4 + tankR + 0.2, bedZ)
				* CFrame.Angles(0, math.rad(90), 0),
			C_CYAN_NEON, Enum.Material.Neon)
	end

	---------------------------------------------------------------------------
	-- REAR END
	---------------------------------------------------------------------------
	local rearWallH = sideH + 1.0
	VU.part(model, "RearEnd",
		Vector3.new(CHASSIS_WIDTH - 0.5, rearWallH, 0.4),
		CFrame.new(0, FLOOR_Y + rearWallH / 2 + 0.2, REAR_Z + 0.2),
		C_BODY, Enum.Material.SmoothPlastic)

	-- Taillights (cyan neon)
	for _, sx in ipairs({-2.5, 2.5}) do
		VU.part(model, "Taillight",
			Vector3.new(0.8, 0.5, 0.15),
			CFrame.new(sx, FLOOR_Y + 1.5, REAR_Z + 0.02),
			C_CYAN_NEON, Enum.Material.Neon)
	end

	---------------------------------------------------------------------------
	-- EXHAUST (water mist — blue particles)
	---------------------------------------------------------------------------
	local exhaustY = FLOOR_Y + 0.3
	local exhaustZ = REAR_Z - 0.1
	for _, sx in ipairs({-1.8, 1.8}) do
		local pipe = VU.cylinder(model, "Exhaust",
			Vector3.new(0.4, 0.7, 0.7),
			CFrame.new(sx, exhaustY, exhaustZ) * CFrame.Angles(0, math.rad(90), 0),
			C_DARK_METAL, Enum.Material.Metal)

		local emitter = Instance.new("ParticleEmitter")
		emitter.Name = "ExhaustMist"
		emitter.Rate = 12
		emitter.Lifetime = NumberRange.new(0.4, 1.0)
		emitter.Speed = NumberRange.new(2, 6)
		emitter.SpreadAngle = Vector2.new(15, 15)
		emitter.EmissionDirection = Enum.NormalId.Right
		emitter.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 200, 255)),
			ColorSequenceKeypoint.new(0.4, Color3.fromRGB(150, 220, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 240, 255)),
		})
		emitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(0.4, 0.7),
			NumberSequenceKeypoint.new(1, 1.2),
		})
		emitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(0.5, 0.6),
			NumberSequenceKeypoint.new(1, 1),
		})
		emitter.LightEmission = 0.3
		emitter.Parent = pipe
	end

	---------------------------------------------------------------------------
	-- SIDE MIRRORS
	---------------------------------------------------------------------------
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Mirror",
			Vector3.new(0.15, 0.5, 0.7),
			CFrame.new(sx * (HALF_W + 0.3), FLOOR_Y + 3.5, 2.5),
			C_DARK_METAL, Enum.Material.Metal)
	end

	---------------------------------------------------------------------------
	-- CYAN GLOW LIGHT (illuminates underside and surroundings)
	---------------------------------------------------------------------------
	local glowLight = Instance.new("PointLight")
	glowLight.Name = "CyanGlow"
	glowLight.Brightness = 1.5
	glowLight.Range = 16
	glowLight.Color = C_CYAN_NEON
	glowLight.Parent = chassis

	model.PrimaryPart = chassis
	return model
end

--------------------------------------------------------------------------------
-- DRIVABLE VERSION (player-controlled, VehicleSeat + cyan headlight beam)
--------------------------------------------------------------------------------
function WaterRunner.buildDrivable()
	local model = WaterRunner.build()
	model.Name = "WaterRunner_Drivable"

	-- VehicleSeat at driver position
	local seat = Instance.new("VehicleSeat")
	seat.Name = "DrivingSeat"
	seat.Size = Vector3.new(2, 0.5, 2)
	seat.CFrame = CFrame.new(-DRIVER_X, FLOOR_Y + 0.9, SEAT_Z) * CFrame.Angles(0, math.rad(180), 0)
	seat.Anchored = true
	seat.CanCollide = false
	seat.Transparency = 1
	seat.MaxSpeed = 0
	seat.HeadsUpDisplay = false
	seat.Parent = model

	-- Cyan headlight beam
	local hl = model:FindFirstChild("HeadlightL")
	if hl then
		local spot = Instance.new("SpotLight")
		spot.Face = Enum.NormalId.Back
		spot.Brightness = 2.5
		spot.Range = 70
		spot.Angle = 55
		spot.Shadows = false
		spot.Color = Color3.fromRGB(0, 200, 255)
		spot.Parent = hl
	end

	return model
end

return WaterRunner
