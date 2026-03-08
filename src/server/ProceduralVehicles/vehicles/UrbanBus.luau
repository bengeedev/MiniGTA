local VU = require(script.Parent:WaitForChild("VehicleUtils"))

local UrbanBus = {}

--------------------------------------------------------------------------------
-- Urban bus palette (white with blue accent)
--------------------------------------------------------------------------------
local C_BODY          = Color3.fromRGB(240, 240, 245)  -- white body
local C_ACCENT        = Color3.fromRGB(30, 100, 160)   -- blue accent stripe
local C_TRIM          = Color3.fromRGB(40, 40, 45)     -- dark trim/bumpers
local C_CHROME        = Color3.fromRGB(180, 180, 185)  -- chrome details
local C_GLASS         = Color3.fromRGB(130, 160, 180)  -- tinted glass
local C_INTERIOR      = Color3.fromRGB(80, 80, 85)     -- dark interior
local C_RUBBER        = Color3.fromRGB(30, 30, 30)     -- tires
local C_HUB           = Color3.fromRGB(160, 160, 165)  -- alloy wheels
local C_HEADLIGHT     = Color3.fromRGB(255, 250, 230)  -- warm white
local C_TAILLIGHT     = Color3.fromRGB(220, 30, 30)    -- red
local C_DEST_SIGN     = Color3.fromRGB(255, 180, 40)   -- amber LED display

--------------------------------------------------------------------------------
-- Shared Y constants (used by init.luau for NPC seating)
--------------------------------------------------------------------------------
local FLOOR_Y = 2.0  -- lower than school bus for accessibility
UrbanBus.FLOOR_Y = FLOOR_Y
UrbanBus.SEAT_Y  = 5.4

-- Seat layout: 4 per row (2 window + 2 aisle), 8 rows
UrbanBus.ROWS = 8
UrbanBus.SEAT_X_WINDOW = 2.8  -- inward to avoid hand clipping
UrbanBus.SEAT_X_AISLE  = 1.1
UrbanBus.ROW_SPACING   = 3.0
UrbanBus.FIRST_ROW_Z   = 4.0   -- first passenger row
UrbanBus.DRIVER_Z      = 9.0   -- driver at front

--------------------------------------------------------------------------------
-- URBAN BUS BUILDER
-- Flat front (cab-over), hollow cabin, 4 seats per row, 8 rows.
-- Faces +Z forward, wheels on ground Y=0.
--------------------------------------------------------------------------------
function UrbanBus.build(modelName)
	modelName = modelName or "UrbanBus_1"

	local model = Instance.new("Model")
	model.Name = modelName

	---------------------------------------------------------------------------
	-- Dimensions
	---------------------------------------------------------------------------
	local wheelR     = 1.8
	local wheelW     = 0.9
	local halfW      = 5.0
	local bodyW      = halfW * 2  -- 10.0

	-- Flat front bus - no hood
	local frontEndZ  =  12.0
	local rearEndZ   = -18.0
	local cabLen     = frontEndZ - rearEndZ  -- 30.0

	local frontAxleZ =  9.0
	local rearAxleZ  = -15.0

	local floorY     = FLOOR_Y                          -- 2.0
	local beltY      = floorY + 3.0                     -- 5.0 (window sill)
	local winH       = 3.8                               -- window height
	local winTopY    = beltY + winH                      -- 8.8
	local roofY      = winTopY + 0.3                     -- 9.1
	local lowerH     = beltY - floorY                    -- 3.0

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
			CFrame.new(sx * (halfW - 0.7), wheelR, rearAxleZ),
			C_RUBBER, Enum.Material.SmoothPlastic)
		VU.cylinder(model, "RearHub",
			Vector3.new(wheelW + 0.1, wheelR * 0.6, wheelR * 0.6),
			CFrame.new(sx * (halfW + 0.2), wheelR, rearAxleZ),
			C_HUB, Enum.Material.Metal)
	end

	---------------------------------------------------------------------------
	-- 2. HOLLOW CABIN STRUCTURE
	---------------------------------------------------------------------------
	local doorThick = 0.4

	-- Lower body sides (below windows) - WHITE with BLUE stripe
	for _, sx in ipairs({-1, 1}) do
		-- Main white lower panel
		VU.part(model, "LowerSide",
			Vector3.new(doorThick, lowerH - 0.8, cabLen),
			CFrame.new(sx * (halfW - doorThick / 2), floorY + (lowerH - 0.8) / 2 + 0.4, (frontEndZ + rearEndZ) / 2),
			C_BODY, Enum.Material.SmoothPlastic)
		-- Blue accent stripe
		VU.part(model, "AccentStripe",
			Vector3.new(doorThick + 0.05, 0.6, cabLen),
			CFrame.new(sx * (halfW - doorThick / 2), beltY - 0.3, (frontEndZ + rearEndZ) / 2),
			C_ACCENT, Enum.Material.SmoothPlastic)
	end

	-- Rear wall (lower, solid)
	VU.part(model, "RearWallLower",
		Vector3.new(bodyW, lowerH, doorThick),
		CFrame.new(0, floorY + lowerH / 2, rearEndZ + doorThick / 2),
		C_BODY, Enum.Material.SmoothPlastic)

	-- Floor
	VU.part(model, "Floor",
		Vector3.new(bodyW - doorThick * 2, 0.2, cabLen),
		CFrame.new(0, floorY + 0.1, (frontEndZ + rearEndZ) / 2),
		C_INTERIOR, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- 3. UPPER CABIN (window area - hollow with pillars)
	---------------------------------------------------------------------------
	-- Window sill strip
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "WindowSill",
			Vector3.new(doorThick, 0.15, cabLen),
			CFrame.new(sx * (halfW - doorThick / 2), beltY, (frontEndZ + rearEndZ) / 2),
			C_BODY, Enum.Material.SmoothPlastic)
	end

	-- Window pillars and glass
	local windowCount = 10
	local windowStartZ = frontEndZ - 2.0
	local windowEndZ = rearEndZ + 2.0
	local totalWindowZ = windowStartZ - windowEndZ
	local pillarSpacing = totalWindowZ / windowCount
	local windowWidth = pillarSpacing - 0.4
	local pillarWidth = 0.4

	for _, sx in ipairs({-1, 1}) do
		for i = 0, windowCount do
			local pz = windowStartZ - i * pillarSpacing
			VU.part(model, "WindowPillar",
				Vector3.new(doorThick, winH, pillarWidth),
				CFrame.new(sx * (halfW - doorThick / 2), beltY + winH / 2, pz),
				C_BODY, Enum.Material.SmoothPlastic)
		end
		for i = 0, windowCount - 1 do
			local wz = windowStartZ - i * pillarSpacing - pillarSpacing / 2
			local wg = VU.part(model, "SideWindow",
				Vector3.new(0.15, winH - 0.3, windowWidth),
				CFrame.new(sx * halfW, beltY + winH / 2, wz),
				C_GLASS, Enum.Material.Glass)
			wg.Transparency = 0.5
		end
	end

	-- Rear upper wall with window frame
	local rearWinW = bodyW - 2.5
	local rearWinH = winH - 1.0
	local rearPillarW = (bodyW - rearWinW) / 2
	VU.part(model, "RearPillarL",
		Vector3.new(rearPillarW, winH, doorThick),
		CFrame.new(-halfW + rearPillarW / 2, beltY + winH / 2, rearEndZ + doorThick / 2),
		C_BODY, Enum.Material.SmoothPlastic)
	VU.part(model, "RearPillarR",
		Vector3.new(rearPillarW, winH, doorThick),
		CFrame.new(halfW - rearPillarW / 2, beltY + winH / 2, rearEndZ + doorThick / 2),
		C_BODY, Enum.Material.SmoothPlastic)
	VU.part(model, "RearTopBar",
		Vector3.new(rearWinW, winH - rearWinH, doorThick),
		CFrame.new(0, beltY + winH - (winH - rearWinH) / 2, rearEndZ + doorThick / 2),
		C_BODY, Enum.Material.SmoothPlastic)
	VU.part(model, "RearBottomBar",
		Vector3.new(rearWinW, 0.5, doorThick),
		CFrame.new(0, beltY + 0.25, rearEndZ + doorThick / 2),
		C_BODY, Enum.Material.SmoothPlastic)
	local rwg = VU.part(model, "RearWindow",
		Vector3.new(rearWinW, rearWinH - 0.5, 0.15),
		CFrame.new(0, beltY + 0.5 + (rearWinH - 0.5) / 2, rearEndZ),
		C_GLASS, Enum.Material.Glass)
	rwg.Transparency = 0.5

	---------------------------------------------------------------------------
	-- 4. ROOF
	---------------------------------------------------------------------------
	local chassis = VU.part(model, "Roof",
		Vector3.new(bodyW, roofY - winTopY, cabLen),
		CFrame.new(0, winTopY + (roofY - winTopY) / 2, (frontEndZ + rearEndZ) / 2),
		C_BODY, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- 5. FLAT FRONT FACE
	---------------------------------------------------------------------------
	-- Lower front panel (below windshield) - main white area
	VU.part(model, "FrontLower",
		Vector3.new(bodyW, lowerH - 1.2, 0.4),
		CFrame.new(0, floorY + (lowerH - 1.2) / 2 + 1.2, frontEndZ),
		C_BODY, Enum.Material.SmoothPlastic)

	-- Grille/vent area (dark, lower section)
	VU.part(model, "FrontGrille",
		Vector3.new(bodyW - 1, 1.0, 0.35),
		CFrame.new(0, floorY + 0.7, frontEndZ + 0.05),
		C_TRIM, Enum.Material.SmoothPlastic)

	-- Grille slats (horizontal lines)
	for i = 0, 2 do
		VU.part(model, "GrilleSlat",
			Vector3.new(bodyW - 1.5, 0.08, 0.1),
			CFrame.new(0, floorY + 0.4 + i * 0.3, frontEndZ + 0.15),
			C_CHROME, Enum.Material.Metal)
	end

	-- Blue accent on front
	VU.part(model, "FrontAccent",
		Vector3.new(bodyW, 0.6, 0.45),
		CFrame.new(0, beltY - 0.3, frontEndZ),
		C_ACCENT, Enum.Material.SmoothPlastic)

	-- Destination sign (amber LED, less bright)
	VU.part(model, "DestSign",
		Vector3.new(bodyW - 2, 0.7, 0.15),
		CFrame.new(0, winTopY - 0.4, frontEndZ + 0.05),
		C_DEST_SIGN, Enum.Material.SmoothPlastic)

	-- Windshield frame
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "APillar",
			Vector3.new(0.4, winH - 1.0, 0.4),
			CFrame.new(sx * (halfW - 0.3), beltY + (winH - 1.0) / 2 + 0.5, frontEndZ),
			C_TRIM, Enum.Material.SmoothPlastic)
	end

	-- Large windshield (two panes)
	for _, sx in ipairs({-1, 1}) do
		local ws = VU.part(model, "Windshield",
			Vector3.new((bodyW - 1.2) / 2, winH - 1.2, 0.15),
			CFrame.new(sx * (bodyW - 1.2) / 4, beltY + (winH - 1.2) / 2 + 0.6, frontEndZ + 0.05),
			C_GLASS, Enum.Material.Glass)
		ws.Transparency = 0.5
	end

	-- Windshield divider
	VU.part(model, "WindshieldDiv",
		Vector3.new(0.15, winH - 1.2, 0.2),
		CFrame.new(0, beltY + (winH - 1.2) / 2 + 0.6, frontEndZ),
		C_TRIM, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- 6. BUMPERS + LIGHTS
	---------------------------------------------------------------------------
	-- Front bumper (sturdy)
	VU.part(model, "FrontBumper",
		Vector3.new(bodyW + 0.4, 0.5, 0.6),
		CFrame.new(0, floorY + 0.05, frontEndZ + 0.3),
		C_TRIM, Enum.Material.SmoothPlastic)

	-- Rear bumper
	VU.part(model, "RearBumper",
		Vector3.new(bodyW + 0.3, 0.6, 0.4),
		CFrame.new(0, floorY - 0.1, rearEndZ - 0.2),
		C_TRIM, Enum.Material.SmoothPlastic)

	-- Headlights (larger, at corners)
	for _, sx in ipairs({-1, 1}) do
		-- Main headlight
		VU.part(model, "Headlight",
			Vector3.new(1.5, 1.0, 0.2),
			CFrame.new(sx * 4.0, floorY + 1.8, frontEndZ + 0.15),
			C_HEADLIGHT, Enum.Material.Neon)

		-- Headlight housing (dark frame)
		VU.part(model, "HeadlightHousing",
			Vector3.new(1.7, 1.2, 0.15),
			CFrame.new(sx * 4.0, floorY + 1.8, frontEndZ + 0.05),
			C_TRIM, Enum.Material.SmoothPlastic)

		-- Turn signal (amber, below headlight)
		VU.part(model, "TurnSignal",
			Vector3.new(1.0, 0.4, 0.2),
			CFrame.new(sx * 4.0, floorY + 0.5, frontEndZ + 0.15),
			Color3.fromRGB(255, 160, 30), Enum.Material.Neon)

		-- Fog light (small, lower corners)
		VU.part(model, "FogLight",
			Vector3.new(0.6, 0.4, 0.15),
			CFrame.new(sx * 3.0, floorY + 0.3, frontEndZ + 0.2),
			C_HEADLIGHT, Enum.Material.Neon)
	end

	-- Taillights
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Taillight",
			Vector3.new(0.8, 0.8, 0.2),
			CFrame.new(sx * 4.2, floorY + 1.0, rearEndZ - 0.05),
			C_TAILLIGHT, Enum.Material.Neon)
	end

	---------------------------------------------------------------------------
	-- 7. SIDE MIRRORS
	---------------------------------------------------------------------------
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "MirrorArm",
			Vector3.new(1.8, 0.1, 0.1),
			CFrame.new(sx * (halfW + 0.9), beltY + 1.5, frontEndZ - 1),
			C_CHROME, Enum.Material.Metal)
		VU.part(model, "Mirror",
			Vector3.new(0.4, 0.8, 0.4),
			CFrame.new(sx * (halfW + 1.7), beltY + 1.2, frontEndZ - 1),
			C_TRIM, Enum.Material.SmoothPlastic)
	end

	---------------------------------------------------------------------------
	-- 8. INTERIOR LIGHT (no PointLight for performance)
	---------------------------------------------------------------------------
	VU.part(model, "CeilingLight",
		Vector3.new(1.0, 0.08, cabLen * 0.5),
		CFrame.new(0, winTopY - 0.05, (frontEndZ + rearEndZ) / 2),
		Color3.fromRGB(240, 240, 235), Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- Finalize
	---------------------------------------------------------------------------
	model.PrimaryPart = chassis
	return model
end

return UrbanBus
