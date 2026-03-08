local VU = require(script.Parent:WaitForChild("VehicleUtils"))

local Sedan = {}

--------------------------------------------------------------------------------
-- Default palette (classic red sedan, matches reference)
--------------------------------------------------------------------------------
local C_DEFAULT_BODY  = Color3.fromRGB(200, 30, 30)   -- red
local C_TRIM          = Color3.fromRGB(25, 25, 28)     -- black bumpers/trim
local C_CHROME        = Color3.fromRGB(180, 180, 185)  -- chrome grille/handles
local C_GLASS         = Color3.fromRGB(140, 185, 220)  -- blue tint glass
local C_INTERIOR      = Color3.fromRGB(45, 40, 40)     -- dark interior
local C_RUBBER        = Color3.fromRGB(30, 30, 30)     -- tires
local C_HUB           = Color3.fromRGB(160, 160, 165)  -- wheel hubs
local C_HEADLIGHT     = Color3.fromRGB(255, 245, 210)  -- warm white headlight
local C_AMBER         = Color3.fromRGB(255, 180, 30)   -- turn signal amber
local C_TAILLIGHT     = Color3.fromRGB(200, 20, 15)    -- red taillight

--------------------------------------------------------------------------------
-- Shared Y constants (used by init.luau for NPC seating)
-- R15 seated: ~2.1 studs from HRP to head top, ~1.5 studs HRP to feet
--------------------------------------------------------------------------------
local FLOOR_Y = 1.8
Sedan.FLOOR_Y = FLOOR_Y
Sedan.SEAT_Y  = 4.2   -- head top ~6.3, roof 6.8 → 0.5 clearance; feet ~2.7 hidden by chassis

--------------------------------------------------------------------------------
-- SEDAN BUILDER
-- Blocky / voxel style 4-door sedan.  Faces +Z forward, wheels on ground Y=0.
--------------------------------------------------------------------------------
function Sedan.build(modelName, bodyColor)
	modelName = modelName or "Sedan_Red_1"
	bodyColor = bodyColor or C_DEFAULT_BODY

	local model = Instance.new("Model")
	model.Name = modelName

	---------------------------------------------------------------------------
	-- Dimensions
	---------------------------------------------------------------------------
	local wheelR     = 1.5
	local wheelW     = 1.0
	local halfW      = 3.5          -- half body width
	local bodyW      = halfW * 2    -- 7

	local frontEndZ  =  7.5         -- nose tip
	local rearEndZ   = -7.5         -- rear bumper
	local cabFrontZ  =  2.5         -- A-pillar (windshield base)
	local cabRearZ   = -4.0         -- C-pillar (rear window base)
	local trunkRearZ = -6.5         -- end of trunk lid

	local frontAxleZ =  5.0
	local rearAxleZ  = -5.0

	local floorY     = FLOOR_Y                          -- 1.8
	local beltY      = floorY + 2.0                     -- 3.8  (window sill / door top)
	local winH       = 2.7                               -- window height
	local winTopY    = beltY + winH                      -- 6.5
	local roofY      = winTopY + 0.3                     -- 6.8
	local lowerH     = beltY - floorY                    -- 2.0

	local cabLen     = cabFrontZ - cabRearZ              -- 6.5
	local cabMidZ    = (cabFrontZ + cabRearZ) / 2        -- -0.75
	local bPillarZ   = -0.8                              -- between front/rear windows

	---------------------------------------------------------------------------
	-- 1. WHEELS
	---------------------------------------------------------------------------
	for _, wp in ipairs({
		{ x = -halfW, z = frontAxleZ },
		{ x =  halfW, z = frontAxleZ },
		{ x = -halfW, z = rearAxleZ  },
		{ x =  halfW, z = rearAxleZ  },
	}) do
		VU.cylinder(model, "Tire",
			Vector3.new(wheelW, wheelR * 2, wheelR * 2),
			CFrame.new(wp.x, wheelR, wp.z),
			C_RUBBER, Enum.Material.SmoothPlastic)
		VU.cylinder(model, "Hub",
			Vector3.new(wheelW + 0.1, wheelR * 0.6, wheelR * 0.6),
			CFrame.new(wp.x, wheelR, wp.z),
			C_HUB, Enum.Material.Metal)
	end

	---------------------------------------------------------------------------
	-- 2. LOWER BODY — hollow cabin: front body, rear body, side door panels
	--    NPCs sit inside the empty cabin space without clipping.
	---------------------------------------------------------------------------
	local doorThick = 0.5   -- thickness of side door panels

	-- FRONT BODY (engine/hood area: solid from floorY to beltY)
	local frontBodyLen = frontEndZ - cabFrontZ
	local chassis = VU.part(model, "Chassis",
		Vector3.new(bodyW, lowerH, frontBodyLen),
		CFrame.new(0, floorY + lowerH / 2, cabFrontZ + frontBodyLen / 2),
		bodyColor, Enum.Material.SmoothPlastic)

	-- REAR BODY (trunk area: solid from floorY to beltY)
	local rearBodyLen = cabRearZ - rearEndZ    -- 3.5
	VU.part(model, "RearBody",
		Vector3.new(bodyW, lowerH, rearBodyLen),
		CFrame.new(0, floorY + lowerH / 2, (cabRearZ + rearEndZ) / 2),
		bodyColor, Enum.Material.SmoothPlastic)

	-- DOOR PANELS (left + right walls in cabin zone, from floorY to beltY)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "DoorPanel",
			Vector3.new(doorThick, lowerH, cabLen),
			CFrame.new(sx * (halfW - doorThick / 2), floorY + lowerH / 2, cabMidZ),
			bodyColor, Enum.Material.SmoothPlastic)
	end

	-- CABIN FLOOR (thin dark panel at very bottom of cabin)
	VU.part(model, "CabinFloor",
		Vector3.new(bodyW - doorThick * 2, 0.15, cabLen),
		CFrame.new(0, floorY + 0.08, cabMidZ),
		C_INTERIOR, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- 3. HOOD (flat panel from cabFront to frontEnd, sits on top of chassis)
	---------------------------------------------------------------------------
	local hoodLen = frontEndZ - cabFrontZ - 0.5
	VU.part(model, "Hood",
		Vector3.new(bodyW - 0.4, 0.25, hoodLen),
		CFrame.new(0, beltY + 0.12, cabFrontZ + 0.25 + hoodLen / 2),
		bodyColor, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- 4. FRONT NOSE (wedge from hood level down to bumper)
	---------------------------------------------------------------------------
	local noseRise = beltY + 0.25 - (floorY + 0.6)
	VU.wedge(model, "FrontNose",
		Vector3.new(bodyW - 0.4, noseRise, 1.5),
		CFrame.new(0, floorY + 0.6 + noseRise / 2, frontEndZ + 0.25)
			* CFrame.Angles(0, math.rad(180), 0),
		bodyColor, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- 5. FRONT BUMPER + GRILLE + LIGHTS
	---------------------------------------------------------------------------
	VU.part(model, "FrontBumper",
		Vector3.new(bodyW + 0.2, 1.0, 0.5),
		CFrame.new(0, floorY + 0.3, frontEndZ + 0.3),
		C_TRIM, Enum.Material.SmoothPlastic)

	VU.part(model, "Grille",
		Vector3.new(4.0, 1.2, 0.2),
		CFrame.new(0, floorY + 1.0, frontEndZ + 0.5),
		C_CHROME, Enum.Material.Metal)

	for i = 0, 3 do
		VU.part(model, "GrilleBar",
			Vector3.new(3.6, 0.05, 0.25),
			CFrame.new(0, floorY + 0.6 + i * 0.3, frontEndZ + 0.55),
			C_TRIM, Enum.Material.SmoothPlastic)
	end

	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Headlight",
			Vector3.new(1.2, 0.9, 0.2),
			CFrame.new(sx * 2.8, floorY + 1.2, frontEndZ + 0.5),
			C_HEADLIGHT, Enum.Material.Neon)
	end

	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "TurnSignal",
			Vector3.new(0.6, 0.4, 0.15),
			CFrame.new(sx * (halfW - 0.1), floorY + 0.8, frontEndZ + 0.5),
			C_AMBER, Enum.Material.Neon)
	end

	---------------------------------------------------------------------------
	-- 6. CABIN SHELL — roof, pillars, back wall, windshield, rear window
	--    (same approach as HazmatTruck cab: solid shell, empty interior)
	---------------------------------------------------------------------------

	-- ROOF
	VU.part(model, "Roof",
		Vector3.new(bodyW, roofY - winTopY, cabLen + 0.6),
		CFrame.new(0, winTopY + (roofY - winTopY) / 2, cabMidZ),
		bodyColor, Enum.Material.SmoothPlastic)

	-- WINDSHIELD (glass, tilted back, spans full width between A-pillars)
	local wsg = VU.part(model, "Windshield",
		Vector3.new(bodyW - 0.6, winH, 0.15),
		CFrame.new(0, beltY + winH / 2, cabFrontZ + 0.1)
			* CFrame.Angles(math.rad(-12), 0, 0),
		C_GLASS, Enum.Material.Glass)
	wsg.Transparency = 0.5

	-- REAR WINDOW (glass, tilted forward — visible from outside, no solid wall behind it)
	local rwg = VU.part(model, "RearWindow",
		Vector3.new(bodyW - 0.8, winH - 0.3, 0.15),
		CFrame.new(0, beltY + (winH - 0.3) / 2 + 0.15, cabRearZ)
			* CFrame.Angles(math.rad(10), 0, 0),
		C_GLASS, Enum.Material.Glass)
	rwg.Transparency = 0.5

	-- Rear window frame (thin body-color strip below the glass, fills gap above trunk)
	VU.part(model, "RearWinFrame",
		Vector3.new(bodyW, 0.3, 0.2),
		CFrame.new(0, beltY + 0.15, cabRearZ),
		bodyColor, Enum.Material.SmoothPlastic)

	-- A-PILLARS (at windshield corners)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "APillar",
			Vector3.new(0.25, winH, 0.25),
			CFrame.new(sx * (halfW - 0.12), beltY + winH / 2, cabFrontZ),
			C_TRIM, Enum.Material.SmoothPlastic)
	end

	-- C-PILLARS (at rear window corners)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "CPillar",
			Vector3.new(0.3, winH, 0.3),
			CFrame.new(sx * (halfW - 0.15), beltY + winH / 2, cabRearZ),
			bodyColor, Enum.Material.SmoothPlastic)
	end

	---------------------------------------------------------------------------
	-- 7. SIDE WINDOWS (glass panels flush at body edge, FULL height)
	---------------------------------------------------------------------------
	local pillarW = 0.3   -- B-pillar width in Z

	for _, sx in ipairs({-1, 1}) do
		-- Front side window (A-pillar to B-pillar)
		local fwFrontZ = cabFrontZ - 0.2       -- just behind A-pillar
		local fwRearZ  = bPillarZ + pillarW/2  -- up to B-pillar
		local fwLen    = fwFrontZ - fwRearZ
		local fwCenterZ = (fwFrontZ + fwRearZ) / 2
		local fwg = VU.part(model, "SideWinFront",
			Vector3.new(0.15, winH, fwLen),
			CFrame.new(sx * halfW, beltY + winH / 2, fwCenterZ),
			C_GLASS, Enum.Material.Glass)
		fwg.Transparency = 0.5

		-- Rear side window (B-pillar to C-pillar)
		local rwFrontZ = bPillarZ - pillarW/2  -- behind B-pillar
		local rwRearZ  = cabRearZ + 0.2        -- up to C-pillar
		local rwLen    = rwFrontZ - rwRearZ
		local rwCenterZ = (rwFrontZ + rwRearZ) / 2
		local rwsg2 = VU.part(model, "SideWinRear",
			Vector3.new(0.15, winH, rwLen),
			CFrame.new(sx * halfW, beltY + winH / 2, rwCenterZ),
			C_GLASS, Enum.Material.Glass)
		rwsg2.Transparency = 0.5

		-- B-PILLAR (between front and rear side windows)
		VU.part(model, "BPillar",
			Vector3.new(0.2, winH, pillarW),
			CFrame.new(sx * halfW, beltY + winH / 2, bPillarZ),
			bodyColor, Enum.Material.SmoothPlastic)
	end

	---------------------------------------------------------------------------
	-- 8. TRUNK (from cabRear to trunkRear)
	---------------------------------------------------------------------------
	local trunkLen = cabRearZ - trunkRearZ
	local trunkH = 0.6
	VU.part(model, "Trunk",
		Vector3.new(bodyW - 0.4, trunkH, trunkLen),
		CFrame.new(0, beltY + trunkH / 2, cabRearZ - trunkLen / 2),
		bodyColor, Enum.Material.SmoothPlastic)

	-- Trunk rear slope (drops down to bumper)
	local rearSlopeRise = beltY + trunkH - (floorY + 0.8)
	VU.wedge(model, "RearSlope",
		Vector3.new(bodyW - 0.4, rearSlopeRise, rearEndZ - trunkRearZ + 1.0),
		CFrame.new(0, floorY + 0.8 + rearSlopeRise / 2, trunkRearZ - 0.5),
		bodyColor, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- 9. REAR BUMPER + TAILLIGHTS
	---------------------------------------------------------------------------
	VU.part(model, "RearBumper",
		Vector3.new(bodyW + 0.2, 0.8, 0.4),
		CFrame.new(0, floorY + 0.2, rearEndZ - 0.2),
		C_TRIM, Enum.Material.SmoothPlastic)

	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Taillight",
			Vector3.new(1.4, 0.7, 0.2),
			CFrame.new(sx * 2.2, floorY + 1.2, rearEndZ - 0.2),
			C_TAILLIGHT, Enum.Material.Neon)
	end

	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "RearIndicator",
			Vector3.new(0.6, 0.35, 0.15),
			CFrame.new(sx * 2.8, floorY + 0.6, rearEndZ - 0.2),
			C_AMBER, Enum.Material.Neon)
	end

	---------------------------------------------------------------------------
	-- 10. SIDE TRIM + DETAILS
	---------------------------------------------------------------------------
	for _, sx in ipairs({-1, 1}) do
		-- Black side molding strip
		VU.part(model, "SideMolding",
			Vector3.new(0.08, 0.15, frontEndZ - rearEndZ - 2),
			CFrame.new(sx * (halfW + 0.02), beltY - 0.5, 0),
			C_TRIM, Enum.Material.SmoothPlastic)

		-- Door handles (2 per side)
		for _, dz in ipairs({1.0, -2.0}) do
			VU.part(model, "DoorHandle",
				Vector3.new(0.08, 0.12, 0.5),
				CFrame.new(sx * (halfW + 0.04), beltY - 0.3, dz),
				C_CHROME, Enum.Material.Metal)
		end

		-- Side mirror
		VU.part(model, "Mirror",
			Vector3.new(0.5, 0.35, 0.7),
			CFrame.new(sx * (halfW + 0.35), beltY + 0.8, cabFrontZ - 0.3),
			C_TRIM, Enum.Material.SmoothPlastic)
	end

	---------------------------------------------------------------------------
	-- 11. INTERIOR LIGHTING (Neon strip only, no PointLight for performance)
	---------------------------------------------------------------------------
	VU.part(model, "CeilingLight",
		Vector3.new(1.5, 0.08, cabLen * 0.6),
		CFrame.new(0, winTopY - 0.04, cabMidZ),
		Color3.fromRGB(255, 240, 210), Enum.Material.Neon)

	---------------------------------------------------------------------------
	-- 12. EXHAUST
	---------------------------------------------------------------------------
	for _, sx in ipairs({-1.2, 1.2}) do
		VU.cylinder(model, "ExhaustTip",
			Vector3.new(0.5, 0.4, 0.4),
			CFrame.new(sx, floorY + 0.3, rearEndZ - 0.3)
				* CFrame.Angles(math.rad(90), 0, 0),
			C_CHROME, Enum.Material.Metal)
	end

	---------------------------------------------------------------------------
	-- Finalize
	---------------------------------------------------------------------------
	model.PrimaryPart = chassis
	return model
end

return Sedan
