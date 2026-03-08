local VU = require(script.Parent:WaitForChild("VehicleUtils"))

local Speedboat = {}

--------------------------------------------------------------------------------
-- SPEEDBOAT  (faces +Z forward, hull bottom at Y=0)
-- Center-console offshore sport boat: deep-V hull, twin outboards,
-- helm console with windshield, bow seating. Sits on water surface.
--------------------------------------------------------------------------------

-- Colors
local C_HULL      = Color3.fromRGB(15, 25, 60)     -- navy below waterline
local C_TOPSIDE   = Color3.fromRGB(245, 245, 250)   -- white topsides
local C_DECK      = Color3.fromRGB(235, 235, 240)   -- off-white deck
local C_ACCENT    = Color3.fromRGB(220, 30, 30)     -- red rub rails / motor stripes
local C_CHROME    = Color3.fromRGB(185, 185, 190)
local C_DARK      = Color3.fromRGB(40, 40, 45)      -- motor cowlings, dashboard
local C_SEAT      = Color3.fromRGB(240, 240, 245)   -- white seats
local C_GLASS     = Color3.fromRGB(160, 200, 220)
local C_NAV_RED   = Color3.fromRGB(255, 20, 20)
local C_NAV_GREEN = Color3.fromRGB(20, 255, 40)
local C_NAV_WHITE = Color3.fromRGB(255, 250, 230)

-- Dimensions
local HULL_L = 18
local HULL_W = 7
local HULL_H = 2.4
local HULL_Y = HULL_H / 2          -- 1.2
local BOW_TAPER = 7                 -- wedge length at bow (sleek profile)
local DECK_Y = HULL_H + 0.1        -- 2.5
local HALF_L = HULL_L / 2          -- 9
local HALF_W = HULL_W / 2          -- 3.5

-- NPC seat positions (both on same bench, side-by-side)
local BENCH_Z       = 2.0
local SEAT_Y_LOCAL  = DECK_Y + 0.5      -- 3.0 (cushion top)
local DRIVER_X      = -1.5              -- left
local PASSENGER_X   = 1.5               -- right

-- Exports for NPC seating
Speedboat.SEAT_Y      = SEAT_Y_LOCAL + 2.5  -- 5.5 (HRP for R15)
Speedboat.DRIVER_X    = DRIVER_X
Speedboat.SEAT_Z      = BENCH_Z
Speedboat.PASSENGER_X = PASSENGER_X
Speedboat.PASSENGER_Z = BENCH_Z

function Speedboat.build()
	local model = Instance.new("Model")
	model.Name = "Speedboat_1"

	---------------------------------------------------------------------------
	-- HULL (deep-V, navy)
	---------------------------------------------------------------------------
	local hull = VU.part(model, "Hull",
		Vector3.new(HULL_W, HULL_H, HULL_L),
		CFrame.new(0, HULL_Y, 0),
		C_HULL, Enum.Material.SmoothPlastic)

	-- Bow (single wedge, full height — slopes from gunwale height to bow tip)
	local BOW_FULL_H = HULL_H + 1.0  -- 3.4 (matches hull + topside height)
	local bowSlopeAngle = math.atan2(BOW_FULL_H, BOW_TAPER) -- ~25.9°
	local bowSlopeLen = math.sqrt(BOW_FULL_H * BOW_FULL_H + BOW_TAPER * BOW_TAPER) -- ~7.78
	local bowCenterY = BOW_FULL_H / 2  -- 1.7
	local bowCenterZ = HALF_L + BOW_TAPER / 2  -- 12.5

	VU.wedge(model, "Bow",
		Vector3.new(HULL_W, BOW_FULL_H, BOW_TAPER),
		CFrame.new(0, bowCenterY, bowCenterZ) * CFrame.Angles(0, math.rad(180), 0),
		C_TOPSIDE, Enum.Material.SmoothPlastic)

	-- Chrome bow rails (along top side-edges of the wedge slope)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "BowRail" .. (sx == -1 and "L" or "R"),
			Vector3.new(0.12, 0.12, bowSlopeLen),
			CFrame.new(sx * (HALF_W - 0.1), bowCenterY, bowCenterZ)
				* CFrame.Angles(bowSlopeAngle, 0, 0),
			C_CHROME, Enum.Material.Metal)
	end

	-- Chrome keel line (center of slope)
	VU.part(model, "BowKeel",
		Vector3.new(0.12, 0.12, bowSlopeLen),
		CFrame.new(0, bowCenterY, bowCenterZ)
			* CFrame.Angles(bowSlopeAngle, 0, 0),
		C_CHROME, Enum.Material.Metal)

	-- Nav bow light (at the very tip, near ground)
	VU.part(model, "NavBow",
		Vector3.new(0.2, 0.2, 0.2),
		CFrame.new(0, 0.15, HALF_L + BOW_TAPER - 0.2),
		C_NAV_WHITE, Enum.Material.Neon)

	-- Transom (flat stern cap)
	VU.part(model, "Transom",
		Vector3.new(HULL_W, HULL_H + 0.6, 0.3),
		CFrame.new(0, HULL_Y + 0.3, -HALF_L - 0.15),
		C_HULL, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- TOPSIDES (white upper hull panels)
	---------------------------------------------------------------------------
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Topside" .. (sx == -1 and "L" or "R"),
			Vector3.new(0.3, 1.0, HULL_L),
			CFrame.new(sx * (HALF_W - 0.05), HULL_H + 0.5, 0),
			C_TOPSIDE, Enum.Material.SmoothPlastic)
	end

	---------------------------------------------------------------------------
	-- DECK (off-white DiamondPlate — stops at hull edge, bow is solid cap)
	---------------------------------------------------------------------------
	VU.part(model, "Deck",
		Vector3.new(HULL_W - 0.8, 0.2, HULL_L),
		CFrame.new(0, DECK_Y, 0),
		C_DECK, Enum.Material.DiamondPlate)

	---------------------------------------------------------------------------
	-- RUB RAILS (red neon accent strips along hull sides — hull only, not bow)
	---------------------------------------------------------------------------
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "RubRail" .. (sx == -1 and "L" or "R"),
			Vector3.new(0.12, 0.3, HULL_L),
			CFrame.new(sx * (HALF_W + 0.02), HULL_H + 0.05, 0),
			C_ACCENT, Enum.Material.Neon)
	end

	---------------------------------------------------------------------------
	-- GUNWALES (raised edges + chrome caps)
	---------------------------------------------------------------------------
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Gunwale" .. (sx == -1 and "L" or "R"),
			Vector3.new(0.25, 0.5, HULL_L + 1),
			CFrame.new(sx * (HALF_W - 0.25), HULL_H + 1.15, 0),
			C_TOPSIDE, Enum.Material.SmoothPlastic)

		VU.part(model, "GunwaleCap" .. (sx == -1 and "L" or "R"),
			Vector3.new(0.3, 0.1, HULL_L + 1),
			CFrame.new(sx * (HALF_W - 0.25), HULL_H + 1.45, 0),
			C_CHROME, Enum.Material.Metal)
	end

	---------------------------------------------------------------------------
	-- BENCH (single bench, both NPCs side-by-side)
	---------------------------------------------------------------------------
	local benchZ = 2.0
	local benchW = HULL_W - 1.6  -- 5.4

	-- Seat cushion
	VU.part(model, "BenchSeat",
		Vector3.new(benchW, 0.5, 2.0),
		CFrame.new(0, DECK_Y + 0.45, benchZ),
		C_SEAT, Enum.Material.Fabric)

	-- Backrest
	VU.part(model, "BenchBack",
		Vector3.new(benchW, 1.2, 0.35),
		CFrame.new(0, DECK_Y + 1.1, benchZ - 0.85),
		C_SEAT, Enum.Material.Fabric)

	---------------------------------------------------------------------------
	-- CONTROL CONSOLE (in front of bench, facing -Z toward NPCs)
	---------------------------------------------------------------------------
	local consZ = 5.0  -- ~1.5 studs clear of NPC legs
	local consW = 2.5
	local consH = 2.5
	local consD = 1.0

	-- Console body
	VU.part(model, "ConsoleBody",
		Vector3.new(consW, consH, consD),
		CFrame.new(0, DECK_Y + consH / 2, consZ),
		C_TOPSIDE, Enum.Material.SmoothPlastic)

	-- Dashboard (dark panel on -Z face, facing NPCs)
	VU.part(model, "Dashboard",
		Vector3.new(consW - 0.2, consH * 0.55, 0.12),
		CFrame.new(0, DECK_Y + consH * 0.45, consZ - consD / 2 - 0.05),
		C_DARK, Enum.Material.SmoothPlastic)

	-- Instrument glow (neon on -Z face)
	VU.part(model, "Instruments",
		Vector3.new(1.4, 0.4, 0.08),
		CFrame.new(0, DECK_Y + consH * 0.5, consZ - consD / 2 - 0.08),
		Color3.fromRGB(0, 180, 255), Enum.Material.Neon)

	-- Steering wheel (chrome disc on -Z face)
	VU.cylinder(model, "SteerWheel",
		Vector3.new(0.12, 1.0, 1.0),
		CFrame.new(0, DECK_Y + consH + 0.1, consZ - consD / 2 - 0.1),
		C_CHROME, Enum.Material.Metal)

	---------------------------------------------------------------------------
	-- WINDSHIELD (raked back from bow junction, matching bow slope angle)
	---------------------------------------------------------------------------
	local wsH = 3.5
	local wsTilt = -bowSlopeAngle  -- ~-26° = top leans back toward driver
	-- Bottom edge at bow junction (Z=HALF_L), top leans back over console
	local wsCenterY = DECK_Y + wsH / 2 * math.cos(wsTilt)
	local wsCenterZ = HALF_L + wsH / 2 * math.sin(wsTilt)

	local ws = VU.part(model, "Windshield",
		Vector3.new(HULL_W - 1.0, wsH, 0.12),
		CFrame.new(0, wsCenterY, wsCenterZ)
			* CFrame.Angles(wsTilt, 0, 0),
		C_GLASS, Enum.Material.Glass)
	ws.Transparency = 0.5

	-- Chrome windshield frame (top edge)
	VU.part(model, "WindshieldFrame",
		Vector3.new(HULL_W - 0.8, 0.12, 0.14),
		CFrame.new(0, DECK_Y + wsH * math.cos(wsTilt), HALF_L + wsH * math.sin(wsTilt))
			* CFrame.Angles(wsTilt, 0, 0),
		C_CHROME, Enum.Material.Metal)

	---------------------------------------------------------------------------
	-- TWIN OUTBOARD MOTORS (×2)
	---------------------------------------------------------------------------
	for _, sx in ipairs({-1, 1}) do
		local mx = sx * 1.6
		local mz = -HALF_L - 0.3
		local tag = sx == -1 and "L" or "R"

		-- Cowling (engine cover)
		VU.part(model, "Cowling" .. tag,
			Vector3.new(1.4, 2.0, 1.6),
			CFrame.new(mx, DECK_Y + 1.0, mz),
			C_DARK, Enum.Material.SmoothPlastic)

		-- Cowling cap (wedge top, taper toward boat)
		VU.wedge(model, "CowlCap" .. tag,
			Vector3.new(1.4, 0.6, 1.6),
			CFrame.new(mx, DECK_Y + 2.3, mz) * CFrame.Angles(0, math.rad(180), 0),
			C_DARK, Enum.Material.SmoothPlastic)

		-- Red accent stripe on cowling (outward-facing side)
		VU.part(model, "MotorStripe" .. tag,
			Vector3.new(1.42, 0.2, 0.12),
			CFrame.new(mx, DECK_Y + 1.2, mz - 0.8),
			C_ACCENT, Enum.Material.Neon)

		-- Lower unit (leg)
		VU.part(model, "LowerUnit" .. tag,
			Vector3.new(0.5, 2.2, 0.7),
			CFrame.new(mx, HULL_Y - 0.8, mz - 0.2),
			C_DARK, Enum.Material.Metal)

		-- Prop disc (chrome)
		VU.cylinder(model, "Prop" .. tag,
			Vector3.new(0.15, 1.4, 1.4),
			CFrame.new(mx, HULL_Y - 1.2, mz - 0.6)
				* CFrame.Angles(0, 0, math.rad(90)),
			C_CHROME, Enum.Material.Metal)
	end

	---------------------------------------------------------------------------
	-- NAV LIGHTS
	---------------------------------------------------------------------------
	-- Port (red — left gunwale)
	VU.part(model, "NavPort",
		Vector3.new(0.14, 0.25, 0.5),
		CFrame.new(-HALF_W + 0.15, HULL_H + 1.25, HALF_L - 1),
		C_NAV_RED, Enum.Material.Neon)

	-- Starboard (green — right gunwale)
	VU.part(model, "NavStarboard",
		Vector3.new(0.14, 0.25, 0.5),
		CFrame.new(HALF_W - 0.15, HULL_H + 1.25, HALF_L - 1),
		C_NAV_GREEN, Enum.Material.Neon)

	-- Stern (white)
	VU.part(model, "NavStern",
		Vector3.new(1.0, 0.3, 0.12),
		CFrame.new(0, HULL_H + 0.8, -HALF_L - 0.2),
		C_NAV_WHITE, Enum.Material.Neon)

	---------------------------------------------------------------------------
	-- CHROME CLEATS (4 corners)
	---------------------------------------------------------------------------
	local cleatPositions = {
		{  HALF_W - 0.4,  HALF_L - 2 },
		{ -HALF_W + 0.4,  HALF_L - 2 },
		{  HALF_W - 0.4, -HALF_L + 2 },
		{ -HALF_W + 0.4, -HALF_L + 2 },
	}
	local cleatY = HULL_H + 1.45 + 0.05 + 0.075  -- flush on gunwale cap top
	for i, pos in ipairs(cleatPositions) do
		VU.part(model, "Cleat" .. i,
			Vector3.new(0.4, 0.15, 0.8),
			CFrame.new(pos[1], cleatY, pos[2]),
			C_CHROME, Enum.Material.Metal)
	end

	---------------------------------------------------------------------------
	-- WAKE SPRAY (2× particle emitters behind motors)
	---------------------------------------------------------------------------
	for _, sx in ipairs({-1, 1}) do
		local sprayPart = Instance.new("Part")
		sprayPart.Name = "WakeSpray" .. (sx == -1 and "L" or "R")
		sprayPart.Size = Vector3.new(0.5, 0.5, 0.5)
		sprayPart.CFrame = CFrame.new(sx * 1.6, HULL_Y * 0.5, -HALF_L - 1.5)
			* CFrame.Angles(0, math.rad(180), 0)
		sprayPart.Anchored = true
		sprayPart.CanCollide = false
		sprayPart.Transparency = 1
		sprayPart.Parent = model

		local spray = Instance.new("ParticleEmitter")
		spray.Name = "WakeEmitter"
		spray.Rate = 50
		spray.Speed = NumberRange.new(10, 22)
		spray.Lifetime = NumberRange.new(0.3, 0.9)
		spray.SpreadAngle = Vector2.new(18, 10)
		spray.EmissionDirection = Enum.NormalId.Back
		spray.LightEmission = 0.3
		spray.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(0.3, 1.0),
			NumberSequenceKeypoint.new(1, 2.0),
		})
		spray.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.15),
			NumberSequenceKeypoint.new(0.5, 0.5),
			NumberSequenceKeypoint.new(1, 1),
		})
		spray.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 220, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 235, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(240, 248, 255)),
		})
		spray.Brightness = 1.5
		spray.Parent = sprayPart
	end

	model.PrimaryPart = hull
	return model
end

return Speedboat
