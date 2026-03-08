local VU = require(script.Parent:WaitForChild("VehicleUtils"))

local SchoolBus = {}

--------------------------------------------------------------------------------
-- School bus palette (classic American yellow)
--------------------------------------------------------------------------------
local C_BODY          = Color3.fromRGB(255, 180, 0)    -- school bus yellow
local C_HOOD          = Color3.fromRGB(35, 35, 38)     -- black hood/cap
local C_TRIM          = Color3.fromRGB(25, 25, 28)     -- black bumpers/trim
local C_CHROME        = Color3.fromRGB(180, 180, 185)  -- chrome mirrors/details
local C_GLASS         = Color3.fromRGB(130, 160, 180)  -- light blue tinted glass
local C_INTERIOR      = Color3.fromRGB(90, 85, 75)     -- tan/beige interior
local C_SEATS         = Color3.fromRGB(60, 80, 50)     -- green vinyl seats
local C_RUBBER        = Color3.fromRGB(30, 30, 30)     -- tires
local C_HUB           = Color3.fromRGB(50, 50, 52)     -- black steel wheels
local C_HEADLIGHT     = Color3.fromRGB(255, 245, 210)  -- warm white headlight
local C_WARN_RED      = Color3.fromRGB(220, 30, 30)    -- red warning lights
local C_WARN_AMBER    = Color3.fromRGB(255, 180, 30)   -- amber warning lights

--------------------------------------------------------------------------------
-- Shared Y constants (used by init.luau for NPC seating)
-- Taller bus: floorY=2.4, beltY=5.8, seats at 6.0
--------------------------------------------------------------------------------
local FLOOR_Y = 2.4
SchoolBus.FLOOR_Y = FLOOR_Y
SchoolBus.SEAT_Y  = 6.0

-- Seat layout: 4 per row (2 window + 2 aisle), 8 rows
SchoolBus.ROWS = 8
SchoolBus.SEAT_X_WINDOW = 2.8   -- window seats (inward to avoid hand clipping)
SchoolBus.SEAT_X_AISLE  = 1.1   -- aisle seats
SchoolBus.ROW_SPACING   = 3.0   -- Z distance between rows
SchoolBus.FIRST_ROW_Z   = 2.0   -- Z of first passenger row (behind driver)
SchoolBus.DRIVER_Z      = 7.0   -- driver position (separate from passengers)

--------------------------------------------------------------------------------
-- SCHOOL BUS BUILDER
-- Hollow cabin like sedan/SUV, 4 seats per row, 8 rows.
-- Faces +Z forward, wheels on ground Y=0.
--------------------------------------------------------------------------------
function SchoolBus.build(modelName)
	modelName = modelName or "SchoolBus_1"

	local model = Instance.new("Model")
	model.Name = modelName

	---------------------------------------------------------------------------
	-- Dimensions (scaled from SUV proportions)
	---------------------------------------------------------------------------
	local wheelR     = 2.0
	local wheelW     = 1.0
	local halfW      = 5.0           -- wider for 4-across seating
	local bodyW      = halfW * 2     -- 10.0

	-- Length: hood + driver + 8 passenger rows + rear
	local frontEndZ  =  12.0         -- nose tip
	local rearEndZ   = -20.0         -- rear bumper
	local hoodEndZ   =  8.0          -- where hood meets cabin
	local cabFrontZ  =  7.5          -- windshield base

	local frontAxleZ =  9.0
	local rearAxleZ  = -17.0

	local floorY     = FLOOR_Y                          -- 2.4
	local beltY      = floorY + 3.4                     -- 5.8 (window sill, taller lower body)
	local winH       = 4.0                               -- window height (taller, no gap to roof)
	local winTopY    = beltY + winH                      -- 9.8
	local roofY      = winTopY + 0.2                     -- 10.0
	local lowerH     = beltY - floorY                    -- 3.4

	local cabLen     = cabFrontZ - rearEndZ              -- 27.5

	---------------------------------------------------------------------------
	-- 1. WHEELS (dual rear)
	---------------------------------------------------------------------------
	-- Front wheels
	for _, sx in ipairs({-1, 1}) do
		VU.cylinder(model, "FrontTire",
			Vector3.new(wheelW, wheelR * 2, wheelR * 2),
			CFrame.new(sx * halfW, wheelR, frontAxleZ),
			C_RUBBER, Enum.Material.SmoothPlastic)
		VU.cylinder(model, "FrontHub",
			Vector3.new(wheelW + 0.1, wheelR * 0.5, wheelR * 0.5),
			CFrame.new(sx * halfW, wheelR, frontAxleZ),
			C_HUB, Enum.Material.Metal)
	end

	-- Rear dual wheels
	for _, sx in ipairs({-1, 1}) do
		VU.cylinder(model, "RearTireOuter",
			Vector3.new(wheelW, wheelR * 2, wheelR * 2),
			CFrame.new(sx * (halfW + 0.3), wheelR, rearAxleZ),
			C_RUBBER, Enum.Material.SmoothPlastic)
		VU.cylinder(model, "RearTireInner",
			Vector3.new(wheelW, wheelR * 2, wheelR * 2),
			CFrame.new(sx * (halfW - 0.8), wheelR, rearAxleZ),
			C_RUBBER, Enum.Material.SmoothPlastic)
		VU.cylinder(model, "RearHub",
			Vector3.new(wheelW + 0.1, wheelR * 0.5, wheelR * 0.5),
			CFrame.new(sx * (halfW + 0.3), wheelR, rearAxleZ),
			C_HUB, Enum.Material.Metal)
	end

	---------------------------------------------------------------------------
	-- 2. HOLLOW CABIN STRUCTURE (like sedan/SUV - see-through)
	---------------------------------------------------------------------------
	local doorThick = 0.5

	-- DRIVER CABIN (hollow, like other cars)
	local driverCabLen = cabFrontZ - hoodEndZ  -- driver area length

	-- Driver cabin side walls (thin, below windows) - BLACK for bus front
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "DriverCabinSide",
			Vector3.new(doorThick, lowerH, driverCabLen + 2),
			CFrame.new(sx * (halfW - doorThick / 2), floorY + lowerH / 2, hoodEndZ + driverCabLen / 2 + 1),
			C_HOOD, Enum.Material.SmoothPlastic)
	end

	-- Hood (engine cover in front of driver) - solid black, shorter
	local hoodLen = frontEndZ - cabFrontZ - 1
	local chassis = VU.part(model, "Hood",
		Vector3.new(bodyW - 0.4, 0.3, hoodLen),
		CFrame.new(0, beltY - 0.8, cabFrontZ + 1 + hoodLen / 2),
		C_HOOD, Enum.Material.SmoothPlastic)

	-- Hood lower (engine block area)
	VU.part(model, "HoodLower",
		Vector3.new(bodyW - 1, lowerH - 0.8, hoodLen),
		CFrame.new(0, floorY + (lowerH - 0.8) / 2 + 0.4, cabFrontZ + 1 + hoodLen / 2),
		C_HOOD, Enum.Material.SmoothPlastic)

	-- PASSENGER CABIN SIDE WALLS (thin door panels, below windows - YELLOW)
	local passengerCabLen = cabFrontZ - rearEndZ - driverCabLen
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "CabinSide",
			Vector3.new(doorThick, lowerH, passengerCabLen),
			CFrame.new(sx * (halfW - doorThick / 2), floorY + lowerH / 2, (hoodEndZ + rearEndZ) / 2),
			C_BODY, Enum.Material.SmoothPlastic)
	end

	-- REAR WALL (solid below windows)
	VU.part(model, "RearWallLower",
		Vector3.new(bodyW, lowerH, doorThick),
		CFrame.new(0, floorY + lowerH / 2, rearEndZ + doorThick / 2),
		C_BODY, Enum.Material.SmoothPlastic)

	-- CABIN FLOOR (entire length)
	VU.part(model, "CabinFloor",
		Vector3.new(bodyW - doorThick * 2, 0.2, cabFrontZ - rearEndZ + 2),
		CFrame.new(0, floorY + 0.1, (cabFrontZ + rearEndZ) / 2),
		C_INTERIOR, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- 2b. DRIVER CABIN WINDOWS (like other cars - hollow, see-through)
	---------------------------------------------------------------------------
	-- Driver side windows (on the black front section)
	for _, sx in ipairs({-1, 1}) do
		-- Window pillar at front
		VU.part(model, "DriverPillarFront",
			Vector3.new(doorThick, winH, 0.4),
			CFrame.new(sx * (halfW - doorThick / 2), beltY + winH / 2, cabFrontZ + 0.5),
			C_HOOD, Enum.Material.SmoothPlastic)
		-- Window pillar at back (where yellow starts)
		VU.part(model, "DriverPillarRear",
			Vector3.new(doorThick, winH, 0.4),
			CFrame.new(sx * (halfW - doorThick / 2), beltY + winH / 2, hoodEndZ),
			C_BODY, Enum.Material.SmoothPlastic)
		-- Driver side window glass
		local dswg = VU.part(model, "DriverSideWindow",
			Vector3.new(0.15, winH - 0.4, driverCabLen - 0.5),
			CFrame.new(sx * halfW, beltY + winH / 2, (cabFrontZ + hoodEndZ) / 2 + 0.3),
			C_GLASS, Enum.Material.Glass)
		dswg.Transparency = 0.5
	end

	---------------------------------------------------------------------------
	-- 3. UPPER CABIN (window area - hollow with pillars)
	---------------------------------------------------------------------------
	-- Window sill (horizontal strip at beltY)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "WindowSill",
			Vector3.new(doorThick, 0.15, cabLen),
			CFrame.new(sx * (halfW - doorThick / 2), beltY, (cabFrontZ + rearEndZ) / 2),
			C_BODY, Enum.Material.SmoothPlastic)
	end

	-- Window pillars and glass
	local windowCount = 9
	local windowStartZ = cabFrontZ - 1.0
	local windowEndZ = rearEndZ + 2.0
	local totalWindowZ = windowStartZ - windowEndZ
	local pillarSpacing = totalWindowZ / windowCount
	local windowWidth = pillarSpacing - 0.5
	local pillarWidth = 0.5

	for _, sx in ipairs({-1, 1}) do
		for i = 0, windowCount do
			local pz = windowStartZ - i * pillarSpacing
			-- Pillar
			VU.part(model, "WindowPillar",
				Vector3.new(doorThick, winH, pillarWidth),
				CFrame.new(sx * (halfW - doorThick / 2), beltY + winH / 2, pz),
				C_BODY, Enum.Material.SmoothPlastic)
		end
		-- Windows (between pillars)
		for i = 0, windowCount - 1 do
			local wz = windowStartZ - i * pillarSpacing - pillarSpacing / 2
			local wg = VU.part(model, "SideWindow",
				Vector3.new(0.15, winH - 0.3, windowWidth),
				CFrame.new(sx * halfW, beltY + winH / 2, wz),
				C_GLASS, Enum.Material.Glass)
			wg.Transparency = 0.5
		end
	end

	-- Rear upper wall (frame around window, not solid)
	local rearWinW = bodyW - 2.5  -- window width
	local rearWinH = winH - 1.0   -- window height
	local rearPillarW = (bodyW - rearWinW) / 2  -- side pillars
	-- Left pillar
	VU.part(model, "RearPillarL",
		Vector3.new(rearPillarW, winH, doorThick),
		CFrame.new(-halfW + rearPillarW / 2, beltY + winH / 2, rearEndZ + doorThick / 2),
		C_BODY, Enum.Material.SmoothPlastic)
	-- Right pillar
	VU.part(model, "RearPillarR",
		Vector3.new(rearPillarW, winH, doorThick),
		CFrame.new(halfW - rearPillarW / 2, beltY + winH / 2, rearEndZ + doorThick / 2),
		C_BODY, Enum.Material.SmoothPlastic)
	-- Top bar (above window)
	VU.part(model, "RearTopBar",
		Vector3.new(rearWinW, winH - rearWinH, doorThick),
		CFrame.new(0, beltY + winH - (winH - rearWinH) / 2, rearEndZ + doorThick / 2),
		C_BODY, Enum.Material.SmoothPlastic)
	-- Bottom bar (below window, above lower wall)
	VU.part(model, "RearBottomBar",
		Vector3.new(rearWinW, 0.5, doorThick),
		CFrame.new(0, beltY + 0.25, rearEndZ + doorThick / 2),
		C_BODY, Enum.Material.SmoothPlastic)
	-- Rear window glass
	local rwg = VU.part(model, "RearWindow",
		Vector3.new(rearWinW, rearWinH - 0.5, 0.15),
		CFrame.new(0, beltY + 0.5 + (rearWinH - 0.5) / 2, rearEndZ),
		C_GLASS, Enum.Material.Glass)
	rwg.Transparency = 0.5

	---------------------------------------------------------------------------
	-- 4. ROOF
	---------------------------------------------------------------------------
	VU.part(model, "Roof",
		Vector3.new(bodyW, roofY - winTopY, cabLen + hoodLen),
		CFrame.new(0, winTopY + (roofY - winTopY) / 2, (frontEndZ + rearEndZ) / 2),
		C_BODY, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- 5. FRONT FACE + WINDSHIELD (like sedan/SUV - see-through)
	---------------------------------------------------------------------------
	-- Front grille/bumper area (black, below windshield)
	VU.part(model, "FrontFace",
		Vector3.new(bodyW, lowerH, 0.4),
		CFrame.new(0, floorY + lowerH / 2, frontEndZ),
		C_HOOD, Enum.Material.SmoothPlastic)

	-- A-pillars (frame the windshield)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "APillar",
			Vector3.new(0.4, winH, 0.5),
			CFrame.new(sx * (halfW - 0.4), beltY + winH / 2, cabFrontZ + 0.8),
			C_TRIM, Enum.Material.SmoothPlastic)
	end

	-- Windshield (large, split - placed at angle)
	local wsg = VU.part(model, "Windshield",
		Vector3.new(bodyW - 1.2, winH - 0.5, 0.15),
		CFrame.new(0, beltY + winH / 2, cabFrontZ + 1.5)
			* CFrame.Angles(math.rad(-15), 0, 0),
		C_GLASS, Enum.Material.Glass)
	wsg.Transparency = 0.5

	-- Windshield divider (center bar)
	VU.part(model, "WindshieldDivider",
		Vector3.new(0.15, winH - 0.5, 0.2),
		CFrame.new(0, beltY + winH / 2, cabFrontZ + 1.4),
		C_TRIM, Enum.Material.SmoothPlastic)

	-- Upper front face (above windshield, connects to roof)
	VU.part(model, "FrontRoofEdge",
		Vector3.new(bodyW, 0.4, 1.5),
		CFrame.new(0, winTopY, cabFrontZ + 1),
		C_BODY, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- 6. FRONT BUMPER + LIGHTS
	---------------------------------------------------------------------------
	VU.part(model, "FrontBumper",
		Vector3.new(bodyW + 0.4, 0.8, 0.5),
		CFrame.new(0, floorY - 0.2, frontEndZ + 0.3),
		C_TRIM, Enum.Material.SmoothPlastic)

	-- Headlights
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Headlight",
			Vector3.new(1.0, 0.8, 0.2),
			CFrame.new(sx * 3.5, floorY + 0.8, frontEndZ + 0.15),
			C_HEADLIGHT, Enum.Material.Neon)
	end

	-- Warning lights (red top, amber below)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "WarnRed",
			Vector3.new(0.7, 0.4, 0.2),
			CFrame.new(sx * 3.5, beltY + 0.2, frontEndZ + 0.15),
			C_WARN_RED, Enum.Material.Neon)
		VU.part(model, "WarnAmber",
			Vector3.new(0.5, 0.35, 0.2),
			CFrame.new(sx * 2.5, beltY + 0.15, frontEndZ + 0.15),
			C_WARN_AMBER, Enum.Material.Neon)
	end

	---------------------------------------------------------------------------
	-- 7. REAR BUMPER + LIGHTS
	---------------------------------------------------------------------------
	VU.part(model, "RearBumper",
		Vector3.new(bodyW + 0.4, 0.8, 0.5),
		CFrame.new(0, floorY - 0.2, rearEndZ - 0.3),
		C_TRIM, Enum.Material.SmoothPlastic)

	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Taillight",
			Vector3.new(0.9, 1.0, 0.2),
			CFrame.new(sx * 4.0, floorY + 1.0, rearEndZ + 0.05),
			C_WARN_RED, Enum.Material.Neon)
	end


	---------------------------------------------------------------------------
	-- 9. SIDE MIRRORS
	---------------------------------------------------------------------------
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "MirrorArm",
			Vector3.new(1.5, 0.1, 0.1),
			CFrame.new(sx * (halfW + 0.75), beltY + 1.0, cabFrontZ),
			C_CHROME, Enum.Material.Metal)
		VU.part(model, "Mirror",
			Vector3.new(0.4, 0.7, 0.3),
			CFrame.new(sx * (halfW + 1.4), beltY + 0.6, cabFrontZ),
			C_TRIM, Enum.Material.SmoothPlastic)
	end

	---------------------------------------------------------------------------
	-- 10. INTERIOR LIGHTING (no PointLight for performance)
	---------------------------------------------------------------------------
	VU.part(model, "CeilingLight",
		Vector3.new(1.0, 0.08, cabLen * 0.5),
		CFrame.new(0, winTopY - 0.05, (cabFrontZ + rearEndZ) / 2),
		Color3.fromRGB(240, 235, 220), Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- Finalize
	---------------------------------------------------------------------------
	model.PrimaryPart = chassis
	return model
end

return SchoolBus
