local VU = require(script.Parent:WaitForChild("VehicleUtils"))

local DoubleDecker = {}

--------------------------------------------------------------------------------
-- Classic British double-decker palette (London red)
--------------------------------------------------------------------------------
local C_BODY          = Color3.fromRGB(200, 30, 35)    -- London bus red
local C_TRIM          = Color3.fromRGB(35, 35, 40)     -- dark trim
local C_CREAM         = Color3.fromRGB(235, 230, 210)  -- cream accent band
local C_CHROME        = Color3.fromRGB(180, 180, 185)  -- chrome details
local C_GLASS         = Color3.fromRGB(130, 160, 180)  -- tinted glass
local C_INTERIOR      = Color3.fromRGB(70, 60, 55)     -- dark interior
local C_RUBBER        = Color3.fromRGB(30, 30, 30)     -- tires
local C_HUB           = Color3.fromRGB(160, 160, 165)  -- alloy wheels
local C_HEADLIGHT     = Color3.fromRGB(255, 250, 230)  -- warm white
local C_TAILLIGHT     = Color3.fromRGB(220, 30, 30)    -- red
local C_DEST_SIGN     = Color3.fromRGB(255, 220, 150)  -- warm white LED

--------------------------------------------------------------------------------
-- Shared Y constants (used by init.luau for NPC seating)
--------------------------------------------------------------------------------
local FLOOR_Y = 2.0
DoubleDecker.FLOOR_Y = FLOOR_Y
DoubleDecker.LOWER_SEAT_Y = 5.0      -- lower deck seating
DoubleDecker.UPPER_SEAT_Y = 10.5     -- upper deck seating

-- Lower deck: 6 rows of 4 (fills rear better)
DoubleDecker.LOWER_ROWS = 6
DoubleDecker.LOWER_FIRST_ROW_Z = 1.0  -- shifted back to fill rear

-- Upper deck: 7 rows of 4 (fills rear better)
DoubleDecker.UPPER_ROWS = 7
DoubleDecker.UPPER_FIRST_ROW_Z = 3.0  -- shifted back to fill rear

-- Shared seat positions (moved inward so arms don't stick out)
DoubleDecker.SEAT_X_WINDOW = 2.3      -- was 3.0, moved inward
DoubleDecker.SEAT_X_AISLE  = 0.8
DoubleDecker.ROW_SPACING   = 2.5      -- slightly tighter spacing

DoubleDecker.DRIVER_Z = 8.0

--------------------------------------------------------------------------------
-- DOUBLE DECKER BUILDER
-- Two-level bus, hollow cabins on both decks.
-- Faces +Z forward, wheels on ground Y=0.
--------------------------------------------------------------------------------
function DoubleDecker.build(modelName)
	modelName = modelName or "DoubleDecker_1"

	local model = Instance.new("Model")
	model.Name = modelName

	---------------------------------------------------------------------------
	-- Dimensions
	---------------------------------------------------------------------------
	local wheelR     = 1.8
	local wheelW     = 0.9
	local halfW      = 4.5          -- slightly narrower than urban bus
	local bodyW      = halfW * 2    -- 9.0

	local frontEndZ  =  10.0
	local rearEndZ   = -14.0
	local cabLen     = frontEndZ - rearEndZ  -- 24.0

	local frontAxleZ =  7.5
	local rearAxleZ  = -11.5

	-- Lower deck
	local floorY     = FLOOR_Y                          -- 2.0
	local lowerBeltY = floorY + 2.8                     -- 4.8 (lower window sill)
	local lowerWinH  = 2.8                               -- lower window height
	local lowerTopY  = lowerBeltY + lowerWinH           -- 7.6

	-- Upper deck (taller for NPC heads)
	local upperFloorY = lowerTopY + 0.3                 -- 7.9 (upper deck floor)
	local upperBeltY  = upperFloorY + 1.8               -- 9.7 (upper window sill)
	local upperWinH   = 3.5                              -- taller windows for heads
	local upperTopY   = upperBeltY + upperWinH          -- 13.2
	local roofY       = upperTopY + 0.3                 -- 13.5

	local lowerH     = lowerBeltY - floorY              -- 2.8
	local doorThick  = 0.4

	---------------------------------------------------------------------------
	-- 1. WHEELS (dual rear)
	---------------------------------------------------------------------------
	for _, sx in ipairs({-1, 1}) do
		VU.cylinder(model, "FrontTire",
			Vector3.new(wheelW, wheelR * 2, wheelR * 2),
			CFrame.new(sx * halfW, wheelR, frontAxleZ),
			C_RUBBER, Enum.Material.SmoothPlastic)
		VU.cylinder(model, "FrontHub",
			Vector3.new(wheelW + 0.1, wheelR * 0.6, wheelR * 0.6),
			CFrame.new(sx * halfW, wheelR, frontAxleZ),
			C_HUB, Enum.Material.Metal)
	end

	for _, sx in ipairs({-1, 1}) do
		VU.cylinder(model, "RearTireOuter",
			Vector3.new(wheelW, wheelR * 2, wheelR * 2),
			CFrame.new(sx * (halfW + 0.2), wheelR, rearAxleZ),
			C_RUBBER, Enum.Material.SmoothPlastic)
		VU.cylinder(model, "RearTireInner",
			Vector3.new(wheelW, wheelR * 2, wheelR * 2),
			CFrame.new(sx * (halfW - 0.6), wheelR, rearAxleZ),
			C_RUBBER, Enum.Material.SmoothPlastic)
		VU.cylinder(model, "RearHub",
			Vector3.new(wheelW + 0.1, wheelR * 0.6, wheelR * 0.6),
			CFrame.new(sx * (halfW + 0.2), wheelR, rearAxleZ),
			C_HUB, Enum.Material.Metal)
	end

	---------------------------------------------------------------------------
	-- 2. LOWER DECK (hollow cabin)
	---------------------------------------------------------------------------
	-- Lower body sides (below windows)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "LowerSide",
			Vector3.new(doorThick, lowerH, cabLen),
			CFrame.new(sx * (halfW - doorThick / 2), floorY + lowerH / 2, (frontEndZ + rearEndZ) / 2),
			C_BODY, Enum.Material.SmoothPlastic)
	end

	-- Lower deck floor
	VU.part(model, "LowerFloor",
		Vector3.new(bodyW - doorThick * 2, 0.2, cabLen),
		CFrame.new(0, floorY + 0.1, (frontEndZ + rearEndZ) / 2),
		C_INTERIOR, Enum.Material.SmoothPlastic)

	-- Lower rear wall
	VU.part(model, "LowerRearWall",
		Vector3.new(bodyW, lowerH, doorThick),
		CFrame.new(0, floorY + lowerH / 2, rearEndZ + doorThick / 2),
		C_BODY, Enum.Material.SmoothPlastic)

	-- Lower window sill
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "LowerSill",
			Vector3.new(doorThick, 0.12, cabLen),
			CFrame.new(sx * (halfW - doorThick / 2), lowerBeltY, (frontEndZ + rearEndZ) / 2),
			C_BODY, Enum.Material.SmoothPlastic)
	end

	-- Lower window pillars and glass
	local windowCount = 7
	local windowStartZ = frontEndZ - 1.5
	local windowEndZ = rearEndZ + 1.5
	local totalWindowZ = windowStartZ - windowEndZ
	local pillarSpacing = totalWindowZ / windowCount
	local windowWidth = pillarSpacing - 0.35
	local pillarWidth = 0.35

	for _, sx in ipairs({-1, 1}) do
		for i = 0, windowCount do
			local pz = windowStartZ - i * pillarSpacing
			VU.part(model, "LowerPillar",
				Vector3.new(doorThick, lowerWinH, pillarWidth),
				CFrame.new(sx * (halfW - doorThick / 2), lowerBeltY + lowerWinH / 2, pz),
				C_BODY, Enum.Material.SmoothPlastic)
		end
		for i = 0, windowCount - 1 do
			local wz = windowStartZ - i * pillarSpacing - pillarSpacing / 2
			local wg = VU.part(model, "LowerWindow",
				Vector3.new(0.12, lowerWinH - 0.2, windowWidth),
				CFrame.new(sx * halfW, lowerBeltY + lowerWinH / 2, wz),
				C_GLASS, Enum.Material.Glass)
			wg.Transparency = 0.5
		end
	end

	-- Lower rear window
	VU.part(model, "LowerRearUpper",
		Vector3.new(bodyW, lowerWinH, doorThick),
		CFrame.new(0, lowerBeltY + lowerWinH / 2, rearEndZ + doorThick / 2),
		C_BODY, Enum.Material.SmoothPlastic)
	local lrw = VU.part(model, "LowerRearWindow",
		Vector3.new(bodyW - 2, lowerWinH - 0.5, 0.12),
		CFrame.new(0, lowerBeltY + lowerWinH / 2, rearEndZ),
		C_GLASS, Enum.Material.Glass)
	lrw.Transparency = 0.5

	---------------------------------------------------------------------------
	-- 3. CREAM BAND (between decks)
	---------------------------------------------------------------------------
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "CreamBand",
			Vector3.new(doorThick + 0.05, 0.5, cabLen),
			CFrame.new(sx * (halfW - doorThick / 2), lowerTopY + 0.15, (frontEndZ + rearEndZ) / 2),
			C_CREAM, Enum.Material.SmoothPlastic)
	end

	---------------------------------------------------------------------------
	-- 4. UPPER DECK (hollow cabin)
	---------------------------------------------------------------------------
	-- Upper deck floor
	local chassis = VU.part(model, "UpperFloor",
		Vector3.new(bodyW - doorThick * 2, 0.25, cabLen),
		CFrame.new(0, upperFloorY + 0.125, (frontEndZ + rearEndZ) / 2),
		C_INTERIOR, Enum.Material.SmoothPlastic)

	-- Upper body sides (below windows)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "UpperSideLower",
			Vector3.new(doorThick, upperBeltY - upperFloorY, cabLen),
			CFrame.new(sx * (halfW - doorThick / 2), upperFloorY + (upperBeltY - upperFloorY) / 2, (frontEndZ + rearEndZ) / 2),
			C_BODY, Enum.Material.SmoothPlastic)
	end

	-- Upper rear wall (lower part)
	VU.part(model, "UpperRearLower",
		Vector3.new(bodyW, upperBeltY - upperFloorY, doorThick),
		CFrame.new(0, upperFloorY + (upperBeltY - upperFloorY) / 2, rearEndZ + doorThick / 2),
		C_BODY, Enum.Material.SmoothPlastic)

	-- Upper window sill
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "UpperSill",
			Vector3.new(doorThick, 0.12, cabLen),
			CFrame.new(sx * (halfW - doorThick / 2), upperBeltY, (frontEndZ + rearEndZ) / 2),
			C_BODY, Enum.Material.SmoothPlastic)
	end

	-- Upper window pillars and glass
	for _, sx in ipairs({-1, 1}) do
		for i = 0, windowCount do
			local pz = windowStartZ - i * pillarSpacing
			VU.part(model, "UpperPillar",
				Vector3.new(doorThick, upperWinH, pillarWidth),
				CFrame.new(sx * (halfW - doorThick / 2), upperBeltY + upperWinH / 2, pz),
				C_BODY, Enum.Material.SmoothPlastic)
		end
		for i = 0, windowCount - 1 do
			local wz = windowStartZ - i * pillarSpacing - pillarSpacing / 2
			local wg = VU.part(model, "UpperWindow",
				Vector3.new(0.12, upperWinH - 0.2, windowWidth),
				CFrame.new(sx * halfW, upperBeltY + upperWinH / 2, wz),
				C_GLASS, Enum.Material.Glass)
			wg.Transparency = 0.5
		end
	end

	-- Upper rear wall with window
	VU.part(model, "UpperRearUpper",
		Vector3.new(bodyW, upperWinH, doorThick),
		CFrame.new(0, upperBeltY + upperWinH / 2, rearEndZ + doorThick / 2),
		C_BODY, Enum.Material.SmoothPlastic)
	local urw = VU.part(model, "UpperRearWindow",
		Vector3.new(bodyW - 2, upperWinH - 0.4, 0.12),
		CFrame.new(0, upperBeltY + upperWinH / 2, rearEndZ),
		C_GLASS, Enum.Material.Glass)
	urw.Transparency = 0.5

	---------------------------------------------------------------------------
	-- 5. ROOF
	---------------------------------------------------------------------------
	VU.part(model, "Roof",
		Vector3.new(bodyW, roofY - upperTopY, cabLen),
		CFrame.new(0, upperTopY + (roofY - upperTopY) / 2, (frontEndZ + rearEndZ) / 2),
		C_BODY, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- 6. FRONT FACE (both decks) - Classic British style
	---------------------------------------------------------------------------
	-- Lower front panel (main red area)
	VU.part(model, "FrontLower",
		Vector3.new(bodyW, lowerH - 1.2, 0.4),
		CFrame.new(0, floorY + (lowerH - 1.2) / 2 + 1.2, frontEndZ),
		C_BODY, Enum.Material.SmoothPlastic)

	-- Radiator/grille area (larger, darker)
	VU.part(model, "RadiatorSurround",
		Vector3.new(5.0, 1.4, 0.3),
		CFrame.new(0, floorY + 0.9, frontEndZ + 0.08),
		C_TRIM, Enum.Material.SmoothPlastic)

	-- Chrome radiator grille
	VU.part(model, "RadiatorGrille",
		Vector3.new(4.5, 1.1, 0.15),
		CFrame.new(0, floorY + 0.9, frontEndZ + 0.18),
		C_CHROME, Enum.Material.Metal)

	-- Grille slats (horizontal)
	for i = 0, 3 do
		VU.part(model, "GrilleSlat",
			Vector3.new(4.2, 0.06, 0.08),
			CFrame.new(0, floorY + 0.5 + i * 0.28, frontEndZ + 0.22),
			C_TRIM, Enum.Material.SmoothPlastic)
	end

	-- Corner trim pieces (classic look)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "CornerTrim",
			Vector3.new(0.3, lowerH, 0.5),
			CFrame.new(sx * (halfW - 0.15), floorY + lowerH / 2, frontEndZ + 0.1),
			C_TRIM, Enum.Material.SmoothPlastic)
	end

	-- Lower windshield frame
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "LowerAPillar",
			Vector3.new(0.4, lowerWinH, 0.4),
			CFrame.new(sx * (halfW - 0.3), lowerBeltY + lowerWinH / 2, frontEndZ),
			C_TRIM, Enum.Material.SmoothPlastic)
	end

	-- Lower windshield glass (two panes)
	for _, sx in ipairs({-1, 1}) do
		local ws = VU.part(model, "LowerWindshield",
			Vector3.new((bodyW - 1.2) / 2, lowerWinH - 0.4, 0.12),
			CFrame.new(sx * (bodyW - 1.2) / 4, lowerBeltY + lowerWinH / 2, frontEndZ + 0.05),
			C_GLASS, Enum.Material.Glass)
		ws.Transparency = 0.5
	end

	-- Lower windshield center divider
	VU.part(model, "LowerWsDiv",
		Vector3.new(0.15, lowerWinH - 0.4, 0.18),
		CFrame.new(0, lowerBeltY + lowerWinH / 2, frontEndZ),
		C_TRIM, Enum.Material.SmoothPlastic)

	-- Cream band front
	VU.part(model, "CreamBandFront",
		Vector3.new(bodyW, 0.5, 0.45),
		CFrame.new(0, lowerTopY + 0.15, frontEndZ),
		C_CREAM, Enum.Material.SmoothPlastic)

	-- Route number box (on cream band, with frame)
	VU.part(model, "RouteBoxFrame",
		Vector3.new(2.4, 0.45, 0.12),
		CFrame.new(0, lowerTopY + 0.15, frontEndZ + 0.18),
		C_TRIM, Enum.Material.SmoothPlastic)
	VU.part(model, "RouteDisplay",
		Vector3.new(2.1, 0.35, 0.1),
		CFrame.new(0, lowerTopY + 0.15, frontEndZ + 0.22),
		C_DEST_SIGN, Enum.Material.SmoothPlastic)

	-- Upper front panel (red area below upper windows)
	VU.part(model, "UpperFrontLower",
		Vector3.new(bodyW, upperBeltY - upperFloorY, 0.4),
		CFrame.new(0, upperFloorY + (upperBeltY - upperFloorY) / 2, frontEndZ),
		C_BODY, Enum.Material.SmoothPlastic)

	-- Upper corner trim
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "UpperCornerTrim",
			Vector3.new(0.3, upperBeltY - upperFloorY + upperWinH, 0.5),
			CFrame.new(sx * (halfW - 0.15), upperFloorY + (upperBeltY - upperFloorY + upperWinH) / 2, frontEndZ + 0.1),
			C_TRIM, Enum.Material.SmoothPlastic)
	end

	-- Upper windshield frame
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "UpperAPillar",
			Vector3.new(0.4, upperWinH, 0.4),
			CFrame.new(sx * (halfW - 0.3), upperBeltY + upperWinH / 2, frontEndZ),
			C_TRIM, Enum.Material.SmoothPlastic)
	end

	-- Upper windshield glass (two panes)
	for _, sx in ipairs({-1, 1}) do
		local ws = VU.part(model, "UpperWindshield",
			Vector3.new((bodyW - 1.2) / 2, upperWinH - 0.4, 0.12),
			CFrame.new(sx * (bodyW - 1.2) / 4, upperBeltY + upperWinH / 2, frontEndZ + 0.05),
			C_GLASS, Enum.Material.Glass)
		ws.Transparency = 0.5
	end

	-- Upper windshield center divider
	VU.part(model, "UpperWsDiv",
		Vector3.new(0.15, upperWinH - 0.4, 0.18),
		CFrame.new(0, upperBeltY + upperWinH / 2, frontEndZ),
		C_TRIM, Enum.Material.SmoothPlastic)

	-- Destination sign (top front, larger)
	VU.part(model, "DestSignBox",
		Vector3.new(bodyW - 0.8, 0.9, 0.18),
		CFrame.new(0, upperTopY - 0.15, frontEndZ + 0.08),
		C_TRIM, Enum.Material.SmoothPlastic)
	VU.part(model, "DestSign",
		Vector3.new(bodyW - 1.2, 0.7, 0.1),
		CFrame.new(0, upperTopY - 0.15, frontEndZ + 0.15),
		C_DEST_SIGN, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- 7. BUMPERS + LIGHTS
	---------------------------------------------------------------------------
	VU.part(model, "FrontBumper",
		Vector3.new(bodyW + 0.3, 0.45, 0.5),
		CFrame.new(0, floorY + 0.05, frontEndZ + 0.25),
		C_TRIM, Enum.Material.SmoothPlastic)

	VU.part(model, "RearBumper",
		Vector3.new(bodyW + 0.3, 0.5, 0.4),
		CFrame.new(0, floorY, rearEndZ - 0.2),
		C_TRIM, Enum.Material.SmoothPlastic)

	-- Headlights
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Headlight",
			Vector3.new(1.2, 0.8, 0.15),
			CFrame.new(sx * 3.5, floorY + 1.6, frontEndZ + 0.12),
			C_HEADLIGHT, Enum.Material.Neon)
		VU.part(model, "HeadlightHousing",
			Vector3.new(1.4, 1.0, 0.1),
			CFrame.new(sx * 3.5, floorY + 1.6, frontEndZ + 0.02),
			C_TRIM, Enum.Material.SmoothPlastic)

		-- Turn signals
		VU.part(model, "TurnSignal",
			Vector3.new(0.8, 0.35, 0.15),
			CFrame.new(sx * 3.5, floorY + 0.5, frontEndZ + 0.12),
			Color3.fromRGB(255, 160, 30), Enum.Material.Neon)
	end

	-- Taillights
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Taillight",
			Vector3.new(0.7, 1.2, 0.15),
			CFrame.new(sx * 3.8, floorY + 1.2, rearEndZ - 0.05),
			C_TAILLIGHT, Enum.Material.Neon)
	end

	---------------------------------------------------------------------------
	-- 8. SIDE MIRRORS
	---------------------------------------------------------------------------
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "MirrorArm",
			Vector3.new(1.5, 0.1, 0.1),
			CFrame.new(sx * (halfW + 0.75), lowerBeltY + 1.2, frontEndZ - 0.8),
			C_CHROME, Enum.Material.Metal)
		VU.part(model, "Mirror",
			Vector3.new(0.35, 0.6, 0.35),
			CFrame.new(sx * (halfW + 1.4), lowerBeltY + 0.9, frontEndZ - 0.8),
			C_TRIM, Enum.Material.SmoothPlastic)
	end

	---------------------------------------------------------------------------
	-- Finalize
	---------------------------------------------------------------------------
	model.PrimaryPart = chassis
	return model
end

return DoubleDecker
