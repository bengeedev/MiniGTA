local VU = require(script.Parent:WaitForChild("VehicleUtils"))

local JumboJet = {}

--------------------------------------------------------------------------------
-- LIVERY DEFINITIONS
--------------------------------------------------------------------------------
JumboJet.LIVERIES = {
	{ name = "AF1",       fuselage = Color3.fromRGB(20, 40, 95),   wings = Color3.fromRGB(90, 145, 200),  accent = Color3.fromRGB(240, 242, 245) },
	{ name = "RedTail",   fuselage = Color3.fromRGB(245, 245, 250), wings = Color3.fromRGB(200, 35, 40),   accent = Color3.fromRGB(200, 35, 40) },
	{ name = "SkyGold",   fuselage = Color3.fromRGB(15, 30, 75),   wings = Color3.fromRGB(220, 190, 60),  accent = Color3.fromRGB(240, 240, 245) },
	{ name = "OceanBlue", fuselage = Color3.fromRGB(30, 120, 200), wings = Color3.fromRGB(240, 240, 245), accent = Color3.fromRGB(240, 240, 245) },
	{ name = "Emerald",   fuselage = Color3.fromRGB(0, 100, 65),   wings = Color3.fromRGB(200, 220, 210), accent = Color3.fromRGB(240, 242, 245) },
	{ name = "Sunset",    fuselage = Color3.fromRGB(240, 240, 245), wings = Color3.fromRGB(20, 25, 40),   accent = Color3.fromRGB(255, 120, 30) },
}

-- Lookup by name for quick access
local LIVERY_MAP = {}
for _, l in JumboJet.LIVERIES do
	LIVERY_MAP[l.name] = l
end

--------------------------------------------------------------------------------
-- FIXED PALETTE (shared across all liveries)
--------------------------------------------------------------------------------
local AF1_BELLY      = Color3.fromRGB(195, 200, 205)
local CHROME         = Color3.fromRGB(170, 170, 175)
local GLASS          = Color3.fromRGB(100, 130, 165)
local DARK_GRAY      = Color3.fromRGB(50, 55, 60)
local ENGINE_GRAY    = Color3.fromRGB(140, 142, 148)
local ENGINE_INNER   = Color3.fromRGB(60, 60, 65)
local RUBBER         = Color3.fromRGB(30, 30, 30)
local INTERIOR       = Color3.fromRGB(50, 55, 60)
local INTERIOR_CEIL  = Color3.fromRGB(200, 205, 210)
local RED_FLAG       = Color3.fromRGB(180, 40, 40)
local WHITE_FLAG     = Color3.fromRGB(240, 240, 245)
local NAV_RED        = Color3.fromRGB(255, 20, 20)
local NAV_GREEN      = Color3.fromRGB(20, 255, 20)
local NAV_WHITE      = Color3.fromRGB(255, 255, 255)

--------------------------------------------------------------------------------
-- DIMENSIONS (proportioned to R15 NPCs ~5.5 studs tall seated)
--------------------------------------------------------------------------------
local HALF_W       = 9       -- fuselage half-width (total 18)
local WALL_THICK   = 0.5
local BASE_Y       = 12      -- bottom of wall structure (gear clearance below)

-- Wall vertical layout
local LOWER_H      = 4       -- lower wall (below windows)
local WIN_H        = 3       -- window strip height
local UPPER_H      = 3       -- upper wall (above windows)
local WALL_H       = LOWER_H + WIN_H + UPPER_H  -- 10
local WALL_TOP_Y   = BASE_Y + WALL_H             -- 22

-- Rounding cylinders
local ROOF_DIAM    = 10
local BELLY_DIAM   = 10

-- Fuselage length
local BODY_LEN     = 130     -- main constant-width section
local NOSE_LEN     = 25      -- tapered nose
local TOTAL_LEN    = BODY_LEN + NOSE_LEN

-- Key Z positions (nose at +Z, tail at -Z)
local BODY_FRONT   =  BODY_LEN / 2    -- +65
local BODY_REAR    = -BODY_LEN / 2    -- -65
local NOSE_TIP     =  BODY_FRONT + NOSE_LEN  -- +90

-- Interior
local FLOOR_Y      = BASE_Y + 0.8
local SEAT_Y       = FLOOR_Y + 2.8   -- NPC HumanoidRootPart Y when seated

-- Wings
local WING_ROOT_Z  = 10             -- wing leading edge Z (forward of center)
local WING_CHORD   = 22             -- wing depth front-to-back
local WING_SPAN    = 68             -- each wing half-span (total 136 + 18 body = 154)
local WING_THICK   = 2.0
local WING_Y       = BASE_Y + 1     -- wing attaches at lower fuselage
local WING_SWEEP   = 12             -- trailing edge is 12 studs further back

-- Engines (4 total, 2 per wing)
local ENG_DIAM     = 6
local ENG_LEN      = 14
local ENG_Y        = WING_Y - 4     -- hang below wing

-- Tail
local VSTAB_H      = 12             -- vertical stabilizer height
local VSTAB_CHORD  = 16             -- vertical stab root chord
local HSTAB_SPAN   = 22             -- each horizontal stab half-span
local HSTAB_CHORD  = 10
local TAIL_LEN     = 40             -- visible tail taper length

--------------------------------------------------------------------------------
-- BUILD
--------------------------------------------------------------------------------
function JumboJet.build(liveryName)
	local livery = LIVERY_MAP[liveryName or "AF1"] or LIVERY_MAP["AF1"]
	local COL_FUSELAGE = livery.fuselage
	local COL_WINGS    = livery.wings
	local COL_ACCENT   = livery.accent

	local model = Instance.new("Model")
	model.Name = "JumboJet_" .. livery.name

	local seatPositions = {} -- Z positions for NPC passengers

	---------------------------------------------------------------------------
	-- 1. FUSELAGE BODY (hollow tube with window strips)
	---------------------------------------------------------------------------

	-- Lower walls (below windows) — both sides — deep blue
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "FuselageLower",
			Vector3.new(WALL_THICK, LOWER_H, BODY_LEN),
			CFrame.new(sx * HALF_W, BASE_Y + LOWER_H / 2, 0),
			COL_FUSELAGE, Enum.Material.SmoothPlastic)
	end

	-- Window strips (transparent glass) — both sides
	local winBottomY = BASE_Y + LOWER_H
	for _, sx in ipairs({-1, 1}) do
		local glass = VU.part(model, "WindowStrip",
			Vector3.new(WALL_THICK + 0.05, WIN_H, BODY_LEN - 4),
			CFrame.new(sx * HALF_W, winBottomY + WIN_H / 2, 0),
			COL_WINGS, Enum.Material.Glass)
		glass.Transparency = 0.35
	end

	-- Upper walls (above windows) — both sides — deep blue
	local upperBottomY = winBottomY + WIN_H
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "FuselageUpper",
			Vector3.new(WALL_THICK, UPPER_H, BODY_LEN),
			CFrame.new(sx * HALF_W, upperBottomY + UPPER_H / 2, 0),
			COL_FUSELAGE, Enum.Material.SmoothPlastic)
	end

	-- Roof cylinder (top half visible, bottom hidden inside)
	VU.cylinder(model, "RoofCurve",
		Vector3.new(BODY_LEN, ROOF_DIAM, ROOF_DIAM),
		CFrame.new(0, WALL_TOP_Y, 0) * CFrame.Angles(0, math.rad(90), 0),
		COL_FUSELAGE, Enum.Material.SmoothPlastic)

	-- Belly cylinder (bottom half visible, top hidden inside)
	VU.cylinder(model, "BellyCurve",
		Vector3.new(BODY_LEN, BELLY_DIAM, BELLY_DIAM),
		CFrame.new(0, BASE_Y, 0) * CFrame.Angles(0, math.rad(90), 0),
		COL_FUSELAGE, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- 2. INTERIOR (floor + ceiling strip for visibility)
	---------------------------------------------------------------------------
	VU.part(model, "InteriorFloor",
		Vector3.new(HALF_W * 2 - 2, 0.3, BODY_LEN - 6),
		CFrame.new(0, FLOOR_Y, 0),
		INTERIOR, Enum.Material.SmoothPlastic)

	VU.part(model, "InteriorCeiling",
		Vector3.new(HALF_W * 2 - 2, 0.2, BODY_LEN - 6),
		CFrame.new(0, upperBottomY - 0.1, 0),
		INTERIOR_CEIL, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- 3. WINDOW DETAILS (individual window rectangles for visual pop)
	---------------------------------------------------------------------------
	local winCenterY = winBottomY + WIN_H / 2
	local windowSpacing = 3.5
	local windowW = 1.2
	local windowH = 1.8

	for _, sx in ipairs({-1, 1}) do
		local wZ = BODY_FRONT - 8
		while wZ > BODY_REAR + 8 do
			VU.part(model, "Window",
				Vector3.new(0.1, windowH, windowW),
				CFrame.new(sx * (HALF_W + 0.08), winCenterY, wZ),
				Color3.fromRGB(220, 235, 255), Enum.Material.Neon)
			wZ = wZ - windowSpacing
		end
	end

	---------------------------------------------------------------------------
	-- 4. NPC SEAT POSITIONS (window seats both sides)
	---------------------------------------------------------------------------
	local seatSpacing = 7
	local seatXLeft  = -(HALF_W - 2.5)
	local seatXRight =  (HALF_W - 2.5)

	local z = BODY_FRONT - 15
	while z > BODY_REAR + 15 do
		table.insert(seatPositions, { x = seatXLeft, z = z })
		table.insert(seatPositions, { x = seatXRight, z = z })
		z = z - seatSpacing
	end

	---------------------------------------------------------------------------
	-- 5. NOSE (elongated ovoid dome)
	---------------------------------------------------------------------------
	local NOSE_DIAM = HALF_W * 2 + 2  -- 20, same cross-section as fuselage

	-- Ovoid nose cone (back half hidden in fuselage, front half = pointy nose)
	VU.ball(model, "NoseDome",
		Vector3.new(NOSE_DIAM, NOSE_DIAM, 56),
		CFrame.new(0, BASE_Y + WALL_H / 2, BODY_FRONT),
		COL_FUSELAGE, Enum.Material.SmoothPlastic)

	-- Cockpit windshield (half-disc embedded in dome — dome hides inner half)
	VU.cylinder(model, "CockpitDisc",
		Vector3.new(2, 14, 14),
		CFrame.new(0, BASE_Y + WALL_H / 2 + 3, BODY_FRONT + 4)
			* CFrame.Angles(0, math.rad(90), math.rad(90)),
		Color3.fromRGB(255, 255, 0), Enum.Material.Neon)

	---------------------------------------------------------------------------
	-- 6. TAIL (dome cap + stabilizers)
	---------------------------------------------------------------------------

	-- Dome cap: hemisphere closing the fuselage rear (front half hidden in tube)
	local DOME_DIAM = HALF_W * 2 + 2  -- 20, matches full visual cross-section
	VU.ball(model, "TailDome",
		Vector3.new(DOME_DIAM, DOME_DIAM, DOME_DIAM),
		CFrame.new(0, BASE_Y + WALL_H / 2, BODY_REAR),
		COL_FUSELAGE, Enum.Material.SmoothPlastic)

	-- Vertical stabilizer (tall fin rising from the tail)
	local vStabZ = BODY_REAR - 2
	VU.part(model, "VerticalStab",
		Vector3.new(1.0, VSTAB_H, VSTAB_CHORD),
		CFrame.new(0, WALL_TOP_Y + VSTAB_H / 2, vStabZ),
		COL_WINGS, Enum.Material.SmoothPlastic)

	-- Swept fin tip (wedge on top of vertical stab, rotated to sweep backward)
	VU.wedge(model, "VStabTip",
		Vector3.new(1.0, 5, VSTAB_CHORD),
		CFrame.new(0, WALL_TOP_Y + VSTAB_H + 2.5, vStabZ)
			* CFrame.Angles(0, math.rad(180), 0),
		COL_WINGS, Enum.Material.SmoothPlastic)

	-- Horizontal stabilizers (both sides)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "HorizontalStab",
			Vector3.new(HSTAB_SPAN, 0.6, HSTAB_CHORD),
			CFrame.new(sx * (HSTAB_SPAN / 2 + 0.5), WALL_TOP_Y + 2, BODY_REAR),
			COL_WINGS, Enum.Material.SmoothPlastic)

		-- Stab tip nav light (red = left/port, green = right/starboard)
		local stabNavColor = if sx == -1 then NAV_RED else NAV_GREEN
		VU.part(model, "StabNavLight",
			Vector3.new(0.4, 0.3, 0.6),
			CFrame.new(sx * (HSTAB_SPAN + 0.5), WALL_TOP_Y + 2, BODY_REAR - HSTAB_CHORD / 2 + 1),
			stabNavColor, Enum.Material.Neon)
	end

	-- White tail nav light (rear-facing, on vertical stab trailing edge)
	VU.part(model, "TailNavLight",
		Vector3.new(0.5, 0.5, 0.6),
		CFrame.new(0, WALL_TOP_Y + VSTAB_H * 0.6, vStabZ - VSTAB_CHORD / 2),
		NAV_WHITE, Enum.Material.Neon)

	---------------------------------------------------------------------------
	-- 7. WINGS (swept back, thick at root, thinner at tip)
	---------------------------------------------------------------------------
	for _, sx in ipairs({-1, 1}) do
		local wingCenterZ = WING_ROOT_Z - WING_CHORD / 2 - WING_SWEEP / 2

		-- Main wing (single flat panel, like stabilizer but big)
		VU.part(model, "Wing",
			Vector3.new(WING_SPAN, WING_THICK, WING_CHORD),
			CFrame.new(sx * (HALF_W + WING_SPAN / 2), WING_Y, wingCenterZ),
			COL_WINGS, Enum.Material.SmoothPlastic)

		-- Wing root fairing (blends wing into fuselage)
		VU.part(model, "WingRoot",
			Vector3.new(6, WING_THICK + 1.5, WING_CHORD + 4),
			CFrame.new(sx * (HALF_W + 2), WING_Y, wingCenterZ),
			COL_ACCENT, Enum.Material.SmoothPlastic)

		-- Wing tip bevel (tapered edge, like VStabTip on vertical stab)
		local BEVEL_SPAN = 10
		VU.wedge(model, "WingBevel",
			Vector3.new(WING_CHORD, WING_THICK, BEVEL_SPAN),
			CFrame.new(sx * (HALF_W + WING_SPAN + BEVEL_SPAN / 2), WING_Y, wingCenterZ)
				* CFrame.Angles(0, sx * math.rad(90), 0),
			COL_WINGS, Enum.Material.SmoothPlastic)

		-- Winglet (upward tip)
		local tipX = sx * (HALF_W + WING_SPAN + BEVEL_SPAN)
		VU.part(model, "Winglet",
			Vector3.new(0.5, 5, 4),
			CFrame.new(tipX, WING_Y + 2.5, wingCenterZ + WING_CHORD / 2 - 3),
			COL_ACCENT, Enum.Material.SmoothPlastic)

		-- Nav light on wingtip trailing edge (red = left/port, green = right/starboard)
		local navColor = if sx == -1 then NAV_RED else NAV_GREEN
		VU.part(model, "WingNavLight",
			Vector3.new(0.6, 0.4, 0.8),
			CFrame.new(tipX, WING_Y, wingCenterZ - WING_CHORD / 2 + 2),
			navColor, Enum.Material.Neon)
	end

	---------------------------------------------------------------------------
	-- 8. ENGINES (4 total: 2 per wing)
	---------------------------------------------------------------------------
	local enginePositions = {
		{ side = -1, dist = 20 },  -- left inner
		{ side = -1, dist = 42 },  -- left outer
		{ side =  1, dist = 20 },  -- right inner
		{ side =  1, dist = 42 },  -- right outer
	}

	for _, ep in ipairs(enginePositions) do
		local engX = ep.side * (HALF_W + ep.dist)
		local engZ = WING_ROOT_Z - WING_CHORD / 2

		-- Pylon (connects engine to wing)
		VU.part(model, "Pylon",
			Vector3.new(1.5, 3.5, ENG_LEN * 0.5),
			CFrame.new(engX, WING_Y - 1.5, engZ),
			AF1_BELLY, Enum.Material.SmoothPlastic)

		-- Engine nacelle (main body cylinder)
		VU.cylinder(model, "EngineNacelle",
			Vector3.new(ENG_LEN, ENG_DIAM, ENG_DIAM),
			CFrame.new(engX, ENG_Y, engZ)
				* CFrame.Angles(0, math.rad(90), 0),
			ENGINE_GRAY, Enum.Material.Metal)

		-- Engine cowling lip (thick intake ring at front)
		VU.cylinder(model, "EngineCowling",
			Vector3.new(1.5, ENG_DIAM + 1, ENG_DIAM + 1),
			CFrame.new(engX, ENG_Y, engZ + ENG_LEN / 2)
				* CFrame.Angles(0, math.rad(90), 0),
			CHROME, Enum.Material.Metal)

		-- Engine fan (visible spinner disc inside intake)
		VU.cylinder(model, "EngineFan",
			Vector3.new(0.3, ENG_DIAM - 1, ENG_DIAM - 1),
			CFrame.new(engX, ENG_Y, engZ + ENG_LEN / 2 + 0.2)
				* CFrame.Angles(0, math.rad(90), 0),
			CHROME, Enum.Material.Metal)

		-- Engine inner cone (center spinner)
		VU.ball(model, "EngineCone",
			Vector3.new(2, 2, 3),
			CFrame.new(engX, ENG_Y, engZ + ENG_LEN / 2 + 0.5),
			COL_ACCENT, Enum.Material.SmoothPlastic)

		-- Engine exhaust nozzle (rear, darker + narrower)
		VU.cylinder(model, "EngineExhaust",
			Vector3.new(2, ENG_DIAM - 1, ENG_DIAM - 1),
			CFrame.new(engX, ENG_Y, engZ - ENG_LEN / 2 - 0.8)
				* CFrame.Angles(0, math.rad(90), 0),
			ENGINE_INNER, Enum.Material.Metal)

		-- Exhaust smoke anchor (unrotated box so EmissionDirection is reliable)
		local smokeAnchor = VU.part(model, "ExhaustAnchor",
			Vector3.new(1, 1, 1),
			CFrame.new(engX, ENG_Y, engZ - ENG_LEN / 2 - 1.5),
			ENGINE_INNER, Enum.Material.Metal)
		smokeAnchor.Transparency = 1

		local smoke = Instance.new("ParticleEmitter")
		smoke.Parent = smokeAnchor
		smoke.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 160, 50)),
			ColorSequenceKeypoint.new(0.3, Color3.fromRGB(200, 200, 200)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(240, 240, 245)),
		})
		smoke.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.3, 3),
			NumberSequenceKeypoint.new(1, 5),
		})
		smoke.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2),
			NumberSequenceKeypoint.new(0.5, 0.6),
			NumberSequenceKeypoint.new(1, 1),
		})
		smoke.Lifetime = NumberRange.new(1, 2)
		smoke.Rate = 25
		smoke.Speed = NumberRange.new(8, 14)
		smoke.SpreadAngle = Vector2.new(6, 6)
		smoke.EmissionDirection = Enum.NormalId.Back
		smoke.RotSpeed = NumberRange.new(-30, 30)
		smoke.Rotation = NumberRange.new(0, 360)
	end

	---------------------------------------------------------------------------
	-- 9. LANDING GEAR
	---------------------------------------------------------------------------

	-- Nose gear
	local noseGearZ = BODY_FRONT - 10
	VU.part(model, "NoseGearStrut",
		Vector3.new(0.8, BASE_Y - BELLY_DIAM / 2, 0.8),
		CFrame.new(0, (BASE_Y - BELLY_DIAM / 2) / 2, noseGearZ),
		DARK_GRAY, Enum.Material.Metal)
	for _, sx in ipairs({-1, 1}) do
		VU.cylinder(model, "NoseWheel",
			Vector3.new(1.6, 4.0, 4.0),
			CFrame.new(sx * 1.5, 2.0, noseGearZ),
			RUBBER, Enum.Material.SmoothPlastic)
	end

	-- Main gear (2 bogies, 4 wheels each)
	for _, sx in ipairs({-1, 1}) do
		local gearX = sx * 5
		local gearZ = -5
		VU.part(model, "MainGearStrut",
			Vector3.new(1.0, BASE_Y - BELLY_DIAM / 2, 1.0),
			CFrame.new(gearX, (BASE_Y - BELLY_DIAM / 2) / 2, gearZ),
			DARK_GRAY, Enum.Material.Metal)

		-- 4 wheels per bogie (2×2 grid)
		for _, dz in ipairs({-2.0, 2.0}) do
			for _, dx in ipairs({-1.5, 1.5}) do
				VU.cylinder(model, "MainWheel",
					Vector3.new(1.8, 4.5, 4.5),
					CFrame.new(gearX + dx, 2.25, gearZ + dz),
					RUBBER, Enum.Material.SmoothPlastic)
			end
		end
	end

	---------------------------------------------------------------------------
	-- 10. AIR FORCE 1 LIVERY (white divider stripe between blue halves)
	---------------------------------------------------------------------------

	-- Thin white accent line at the color split (window level border)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "DividerStripe",
			Vector3.new(0.15, 0.4, BODY_LEN),
			CFrame.new(sx * (HALF_W + 0.15), winBottomY - 0.2, 0),
			COL_ACCENT, Enum.Material.SmoothPlastic)
	end

	---------------------------------------------------------------------------
	-- FINALIZE
	---------------------------------------------------------------------------
	local primary = model:FindFirstChild("InteriorFloor") or model:FindFirstChild("BellyCurve")
	model.PrimaryPart = primary

	return model, seatPositions
end

return JumboJet
