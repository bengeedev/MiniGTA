local VU = require(script.Parent:WaitForChild("VehicleUtils"))

local HazmatRunner = {}

--------------------------------------------------------------------------------
-- HAZMAT RUNNER  (faces +Z forward, wheels on ground at Y=0)
-- Nuclear recon vehicle: armored jeep base with glass dome cabin,
-- hazmat yellow/black paint, green neon radioactive accents.
--------------------------------------------------------------------------------

-- Colors
local C_HAZMAT_YELLOW = Color3.fromRGB(230, 200, 40)
local C_BLACK         = Color3.fromRGB(25, 25, 28)
local C_DARK_METAL    = Color3.fromRGB(50, 50, 55)
local C_METAL_FRAME   = Color3.fromRGB(70, 70, 75)
local C_GLASS         = Color3.fromRGB(160, 220, 180)   -- green-tinted glass
local C_NEON_GREEN    = Color3.fromRGB(80, 255, 80)     -- radioactive glow
local C_DARK_GREEN    = Color3.fromRGB(40, 80, 40)
local C_WARNING_BLACK = Color3.fromRGB(20, 20, 22)
local C_TIRE          = Color3.fromRGB(25, 25, 25)
local C_RIM           = Color3.fromRGB(90, 90, 95)      -- dark tactical rims
local C_HEADLIGHT     = Color3.fromRGB(80, 255, 120)    -- green headlights

-- Dimensions
local CHASSIS_LENGTH = 14
local CHASSIS_WIDTH  = 8
local WHEEL_R   = 2.0
local WHEEL_W   = 1.5
local FRONT_Z   = 5.5
local REAR_Z    = -5.5
local HALF_W    = 4.0
local FLOOR_Y   = WHEEL_R + 0.5  -- 2.5
local DOME_TOP  = FLOOR_Y + 7.0  -- 9.5 (tall glass dome)

-- Seat positions (left-hand drive)
local DRIVER_X    = -1.5
local PASSENGER_X = 1.5
local SEAT_Z      = 0.0
local SEAT_Y      = FLOOR_Y + 1.8  -- 4.3 (HRP position for R15)

-- Exports for NPC seating
HazmatRunner.FLOOR_Y = FLOOR_Y
HazmatRunner.SEAT_Y = SEAT_Y
HazmatRunner.DRIVER_X = DRIVER_X
HazmatRunner.PASSENGER_X = PASSENGER_X
HazmatRunner.SEAT_Z = SEAT_Z

function HazmatRunner.build()
	local model = Instance.new("Model")
	model.Name = "HazmatRunner_1"

	---------------------------------------------------------------------------
	-- WHEELS (chunky off-road, dark tactical look)
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
	-- CHASSIS (armored flat platform)
	---------------------------------------------------------------------------
	local chassis = VU.part(model, "Chassis",
		Vector3.new(CHASSIS_WIDTH, 1.4, CHASSIS_LENGTH),
		CFrame.new(0, FLOOR_Y, 0),
		C_HAZMAT_YELLOW, Enum.Material.SmoothPlastic)

	-- Hazmat warning stripes on chassis sides (black diagonal feel via alternating blocks)
	for _, sx in ipairs({-1, 1}) do
		for i = 0, 4 do
			local stripeZ = -4 + i * 2.2
			VU.part(model, "WarningStripe",
				Vector3.new(0.15, 0.8, 1.0),
				CFrame.new(sx * (CHASSIS_WIDTH / 2 + 0.05), FLOOR_Y + 0.3, stripeZ),
				C_WARNING_BLACK, Enum.Material.SmoothPlastic)
		end
	end

	---------------------------------------------------------------------------
	-- FRONT: Hood + Push Bar
	---------------------------------------------------------------------------
	-- Angled hood
	VU.wedge(model, "Hood",
		Vector3.new(CHASSIS_WIDTH - 0.5, 1.2, 3.5),
		CFrame.new(0, FLOOR_Y + 1, 4.5) * CFrame.Angles(0, math.rad(180), 0),
		C_HAZMAT_YELLOW, Enum.Material.SmoothPlastic)

	-- Flat hood top
	VU.part(model, "HoodTop",
		Vector3.new(CHASSIS_WIDTH - 0.5, 0.2, 3),
		CFrame.new(0, FLOOR_Y + 1.6, 3),
		C_HAZMAT_YELLOW, Enum.Material.SmoothPlastic)

	-- Radiation symbol on hood (simplified: 3 black wedges around a green center)
	VU.cylinder(model, "RadSymbolCenter",
		Vector3.new(0.06, 0.8, 0.8),
		CFrame.new(0, FLOOR_Y + 1.72, 3.5) * CFrame.Angles(0, 0, math.rad(90)),
		C_NEON_GREEN, Enum.Material.Neon)
	for i = 0, 2 do
		local angle = math.rad(i * 120)
		VU.part(model, "RadSymbolBlade" .. i,
			Vector3.new(0.5, 0.06, 1.2),
			CFrame.new(math.sin(angle) * 0.5, FLOOR_Y + 1.72, 3.5 + math.cos(angle) * 0.5)
				* CFrame.Angles(0, -angle, 0),
			C_WARNING_BLACK, Enum.Material.SmoothPlastic)
	end

	-- Push bar (heavy duty, dark metal)
	VU.part(model, "PushBar",
		Vector3.new(CHASSIS_WIDTH - 0.5, 2.0, 0.6),
		CFrame.new(0, FLOOR_Y + 0.7, 6.8),
		C_DARK_METAL, Enum.Material.Metal)

	-- Headlights (green neon — radioactive)
	for _, sx in ipairs({-2.5, 2.5}) do
		VU.cylinder(model, "Headlight" .. (sx < 0 and "L" or "R"),
			Vector3.new(0.3, 1.2, 1.2),
			CFrame.new(sx, FLOOR_Y + 1.3, 6.5) * CFrame.Angles(0, math.rad(90), 0),
			C_HEADLIGHT, Enum.Material.Neon)
	end

	---------------------------------------------------------------------------
	-- SIDE PANELS (armored lower body)
	---------------------------------------------------------------------------
	local sideH = 2.0  -- armored door height
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "SidePanel" .. (sx == -1 and "L" or "R"),
			Vector3.new(0.4, sideH, 7),
			CFrame.new(sx * (CHASSIS_WIDTH / 2 - 0.1), FLOOR_Y + sideH / 2 + 0.2, -0.5),
			C_HAZMAT_YELLOW, Enum.Material.SmoothPlastic)

		-- Armored vent slits (dark)
		for i = 0, 2 do
			VU.part(model, "Vent",
				Vector3.new(0.12, 0.15, 1.5),
				CFrame.new(sx * (CHASSIS_WIDTH / 2), FLOOR_Y + 1.0 + i * 0.4, -0.5),
				C_DARK_METAL, Enum.Material.Metal)
		end
	end

	---------------------------------------------------------------------------
	-- SEAT BENCH + DASHBOARD
	---------------------------------------------------------------------------
	VU.part(model, "SeatBench",
		Vector3.new(6.4, 0.4, 2.5),
		CFrame.new(0, FLOOR_Y + 0.9, SEAT_Z),
		C_DARK_GREEN, Enum.Material.Fabric)
	VU.part(model, "SeatBack",
		Vector3.new(6.4, 2.5, 0.4),
		CFrame.new(0, FLOOR_Y + 2.2, SEAT_Z - 1.2),
		C_DARK_GREEN, Enum.Material.Fabric)

	-- Dashboard with instruments
	VU.part(model, "Dashboard",
		Vector3.new(CHASSIS_WIDTH - 1, 1.0, 0.5),
		CFrame.new(0, FLOOR_Y + 2.0, 2.5),
		C_BLACK, Enum.Material.SmoothPlastic)
	-- Instrument panel glow (green readouts)
	VU.part(model, "InstrumentPanel",
		Vector3.new(3, 0.4, 0.12),
		CFrame.new(0, FLOOR_Y + 2.4, 2.72),
		C_NEON_GREEN, Enum.Material.Neon)

	---------------------------------------------------------------------------
	-- GLASS DOME CABIN (the signature feature)
	-- Metal frame arcs + transparent glass panels
	---------------------------------------------------------------------------
	local domeBaseY = FLOOR_Y + sideH + 0.3   -- 4.8
	local domeH = DOME_TOP - domeBaseY          -- 4.7
	local domeW = CHASSIS_WIDTH - 0.8           -- 7.2
	local domeLen = 7.5                          -- length of dome section
	local domeZ = -0.5                           -- centered on cabin

	-- Main glass panels (front, back, sides)
	-- Front glass (windshield area, slightly angled)
	local frontGlass = VU.part(model, "DomeFrontGlass",
		Vector3.new(domeW, domeH * 0.8, 0.15),
		CFrame.new(0, domeBaseY + domeH * 0.4, domeZ + domeLen / 2)
			* CFrame.Angles(math.rad(-8), 0, 0),
		C_GLASS, Enum.Material.Glass)
	frontGlass.Transparency = 0.5

	-- Rear glass
	local rearGlass = VU.part(model, "DomeRearGlass",
		Vector3.new(domeW, domeH * 0.8, 0.15),
		CFrame.new(0, domeBaseY + domeH * 0.4, domeZ - domeLen / 2)
			* CFrame.Angles(math.rad(8), 0, 0),
		C_GLASS, Enum.Material.Glass)
	rearGlass.Transparency = 0.5

	-- Side glass panels
	for _, sx in ipairs({-1, 1}) do
		local sideGlass = VU.part(model, "DomeSideGlass" .. (sx == -1 and "L" or "R"),
			Vector3.new(0.15, domeH * 0.8, domeLen),
			CFrame.new(sx * domeW / 2, domeBaseY + domeH * 0.4, domeZ),
			C_GLASS, Enum.Material.Glass)
		sideGlass.Transparency = 0.5
	end

	-- Roof glass panel (top of dome)
	local roofGlass = VU.part(model, "DomeRoofGlass",
		Vector3.new(domeW - 1, 0.15, domeLen - 0.5),
		CFrame.new(0, DOME_TOP - 0.2, domeZ),
		C_GLASS, Enum.Material.Glass)
	roofGlass.Transparency = 0.4

	-- Metal frame arcs (4 cross-ribs over the dome)
	local arcCount = 4
	local arcSpacing = domeLen / (arcCount + 1)
	for i = 1, arcCount do
		local arcZ = domeZ - domeLen / 2 + i * arcSpacing
		-- Top bar
		VU.part(model, "DomeArc" .. i,
			Vector3.new(domeW + 0.3, 0.3, 0.3),
			CFrame.new(0, DOME_TOP - 0.1, arcZ),
			C_METAL_FRAME, Enum.Material.Metal)
		-- Vertical posts connecting to side panels
		for _, sx in ipairs({-1, 1}) do
			local postH = domeH
			VU.part(model, "DomePost",
				Vector3.new(0.3, postH, 0.3),
				CFrame.new(sx * (domeW / 2 + 0.05), domeBaseY + postH / 2, arcZ),
				C_METAL_FRAME, Enum.Material.Metal)
		end
	end

	-- Front and rear frame bars
	VU.part(model, "DomeFrameFront",
		Vector3.new(domeW + 0.3, 0.3, 0.3),
		CFrame.new(0, domeBaseY + domeH * 0.8, domeZ + domeLen / 2),
		C_METAL_FRAME, Enum.Material.Metal)
	VU.part(model, "DomeFrameRear",
		Vector3.new(domeW + 0.3, 0.3, 0.3),
		CFrame.new(0, domeBaseY + domeH * 0.8, domeZ - domeLen / 2),
		C_METAL_FRAME, Enum.Material.Metal)

	-- Side frame rails (top edge)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "DomeRail" .. (sx == -1 and "L" or "R"),
			Vector3.new(0.3, 0.3, domeLen + 0.3),
			CFrame.new(sx * (domeW / 2 + 0.05), DOME_TOP - 0.1, domeZ),
			C_METAL_FRAME, Enum.Material.Metal)
	end

	---------------------------------------------------------------------------
	-- GREEN NEON ACCENT STRIPS (radioactive glow along the body)
	---------------------------------------------------------------------------
	-- Base neon strip along chassis sides
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "NeonStrip" .. (sx == -1 and "L" or "R"),
			Vector3.new(0.12, 0.2, CHASSIS_LENGTH - 2),
			CFrame.new(sx * (CHASSIS_WIDTH / 2 + 0.08), FLOOR_Y - 0.4, 0),
			C_NEON_GREEN, Enum.Material.Neon)
	end

	-- Dome base neon ring (where dome meets body)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "DomeNeon" .. (sx == -1 and "L" or "R"),
			Vector3.new(0.1, 0.15, domeLen),
			CFrame.new(sx * (domeW / 2 + 0.15), domeBaseY - 0.1, domeZ),
			C_NEON_GREEN, Enum.Material.Neon)
	end
	VU.part(model, "DomeNeonFront",
		Vector3.new(domeW, 0.15, 0.1),
		CFrame.new(0, domeBaseY - 0.1, domeZ + domeLen / 2 + 0.05),
		C_NEON_GREEN, Enum.Material.Neon)
	VU.part(model, "DomeNeonRear",
		Vector3.new(domeW, 0.15, 0.1),
		CFrame.new(0, domeBaseY - 0.1, domeZ - domeLen / 2 - 0.05),
		C_NEON_GREEN, Enum.Material.Neon)

	---------------------------------------------------------------------------
	-- ROOF SCANNER (rotating antenna/sensor on top of dome)
	---------------------------------------------------------------------------
	-- Scanner base
	VU.cylinder(model, "ScannerBase",
		Vector3.new(0.4, 1.5, 1.5),
		CFrame.new(0, DOME_TOP + 0.2, domeZ) * CFrame.Angles(0, 0, math.rad(90)),
		C_DARK_METAL, Enum.Material.Metal)
	-- Scanner arm (animated by WorldLoader)
	VU.part(model, "ScannerArm",
		Vector3.new(3.5, 0.2, 0.3),
		CFrame.new(0, DOME_TOP + 0.5, domeZ),
		C_DARK_METAL, Enum.Material.Metal)
	-- Scanner tip (glowing green)
	VU.part(model, "ScannerTip",
		Vector3.new(0.4, 0.4, 0.4),
		CFrame.new(1.75, DOME_TOP + 0.5, domeZ),
		C_NEON_GREEN, Enum.Material.Neon)

	---------------------------------------------------------------------------
	-- REAR: Tailgate + Taillights + Equipment
	---------------------------------------------------------------------------
	local rearWallH = sideH + 1.5
	VU.part(model, "RearEnd",
		Vector3.new(CHASSIS_WIDTH - 0.5, rearWallH, 0.4),
		CFrame.new(0, FLOOR_Y + rearWallH / 2 + 0.2, REAR_Z + 0.2),
		C_HAZMAT_YELLOW, Enum.Material.SmoothPlastic)

	-- Taillights (green neon for hazmat theme)
	for _, sx in ipairs({-2.5, 2.5}) do
		VU.part(model, "Taillight",
			Vector3.new(0.8, 0.5, 0.15),
			CFrame.new(sx, FLOOR_Y + 1.5, REAR_Z + 0.02),
			C_NEON_GREEN, Enum.Material.Neon)
	end

	-- Spare tire mount on rear
	VU.cylinder(model, "SpareTire",
		Vector3.new(1.0, 2.5, 2.5),
		CFrame.new(0, FLOOR_Y + 2.5, REAR_Z - 0.3),
		C_TIRE, Enum.Material.SmoothPlastic)
	VU.cylinder(model, "SpareHub",
		Vector3.new(0.3, 0.8, 0.8),
		CFrame.new(0, FLOOR_Y + 2.5, REAR_Z - 0.8),
		C_RIM, Enum.Material.Metal)

	---------------------------------------------------------------------------
	-- EXHAUST (green radioactive fumes)
	---------------------------------------------------------------------------
	local exhaustY = FLOOR_Y + 0.3
	local exhaustZ = REAR_Z - 0.1
	for _, sx in ipairs({-1.8, 1.8}) do
		local pipe = VU.cylinder(model, "Exhaust",
			Vector3.new(0.4, 0.7, 0.7),
			CFrame.new(sx, exhaustY, exhaustZ) * CFrame.Angles(0, math.rad(90), 0),
			C_DARK_METAL, Enum.Material.Metal)

		local emitter = Instance.new("ParticleEmitter")
		emitter.Name = "ExhaustFumes"
		emitter.Rate = 15
		emitter.Lifetime = NumberRange.new(0.5, 1.2)
		emitter.Speed = NumberRange.new(3, 8)
		emitter.SpreadAngle = Vector2.new(12, 12)
		emitter.EmissionDirection = Enum.NormalId.Right
		emitter.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 255, 100)),
			ColorSequenceKeypoint.new(0.4, Color3.fromRGB(60, 180, 60)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 60, 40)),
		})
		emitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(0.4, 0.8),
			NumberSequenceKeypoint.new(1, 1.5),
		})
		emitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2),
			NumberSequenceKeypoint.new(0.5, 0.6),
			NumberSequenceKeypoint.new(1, 1),
		})
		emitter.LightEmission = 0.5
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
	-- ANTENNA (rear right, tall radio mast)
	---------------------------------------------------------------------------
	VU.part(model, "Antenna",
		Vector3.new(0.08, 5, 0.08),
		CFrame.new(3.0, DOME_TOP + 2.5, -3),
		C_DARK_METAL, Enum.Material.Metal)
	-- Antenna tip glow
	VU.ball(model, "AntennaTip",
		Vector3.new(0.3, 0.3, 0.3),
		CFrame.new(3.0, DOME_TOP + 5.1, -3),
		C_NEON_GREEN, Enum.Material.Neon)

	model.PrimaryPart = chassis
	return model
end

--------------------------------------------------------------------------------
-- DRIVABLE VERSION (player-controlled, VehicleSeat + green headlight beam)
--------------------------------------------------------------------------------
function HazmatRunner.buildDrivable()
	local model = HazmatRunner.build()
	model.Name = "HazmatRunner_Drivable"

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

	-- Green headlight beam (radioactive feel)
	local hl = model:FindFirstChild("HeadlightL")
	if hl then
		local spot = Instance.new("SpotLight")
		spot.Face = Enum.NormalId.Back
		spot.Brightness = 2.5
		spot.Range = 70
		spot.Angle = 55
		spot.Shadows = false
		spot.Color = Color3.fromRGB(120, 255, 140)  -- green-tinted beam
		spot.Parent = hl
	end

	return model
end

return HazmatRunner
