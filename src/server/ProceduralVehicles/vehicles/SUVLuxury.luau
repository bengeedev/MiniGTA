local VU = require(script.Parent:WaitForChild("VehicleUtils"))

local SUVLuxury = {}

--------------------------------------------------------------------------------
-- Default palette (black luxury SUV - Escalade/Range Rover style)
--------------------------------------------------------------------------------
local C_DEFAULT_BODY  = Color3.fromRGB(25, 25, 30)     -- black
local C_TRIM          = Color3.fromRGB(20, 20, 22)     -- darker trim
local C_CHROME        = Color3.fromRGB(200, 200, 205)  -- chrome accents
local C_GLASS         = Color3.fromRGB(40, 50, 60)     -- dark tinted glass (limo tint)
local C_INTERIOR      = Color3.fromRGB(60, 50, 45)     -- tan/leather interior
local C_RUBBER        = Color3.fromRGB(30, 30, 30)     -- tires
local C_HUB           = Color3.fromRGB(190, 190, 195)  -- chrome wheels
local C_HEADLIGHT     = Color3.fromRGB(255, 250, 245)  -- bright white LED
local C_DRL           = Color3.fromRGB(255, 255, 255)  -- daytime running lights
local C_TAILLIGHT     = Color3.fromRGB(180, 20, 20)    -- red taillight
local C_RUNNING_BOARD = Color3.fromRGB(45, 45, 48)     -- running board

--------------------------------------------------------------------------------
-- Shared Y constants (used by init.luau for NPC seating)
-- Luxury SUV sits high: floorY 2.4
--------------------------------------------------------------------------------
local FLOOR_Y = 2.4
SUVLuxury.FLOOR_Y = FLOOR_Y
SUVLuxury.SEAT_Y  = 4.9   -- adjusted for higher floor

--------------------------------------------------------------------------------
-- LUXURY SUV BUILDER
-- Large, elegant SUV with 3 rows. Faces +Z forward, wheels on ground Y=0.
-- Key features: chrome accents, running boards, premium look, long body
--------------------------------------------------------------------------------
function SUVLuxury.build(modelName, bodyColor)
	modelName = modelName or "SUV_Black_1"
	bodyColor = bodyColor or C_DEFAULT_BODY

	local model = Instance.new("Model")
	model.Name = modelName

	---------------------------------------------------------------------------
	-- Dimensions (longer than crossover for 3 rows)
	---------------------------------------------------------------------------
	local wheelR     = 2.0           -- big luxury wheels
	local wheelW     = 1.2
	local halfW      = 4.0           -- wider body
	local bodyW      = halfW * 2     -- 8.0

	local frontEndZ  =  9.5          -- nose tip
	local rearEndZ   = -9.5          -- rear bumper (short overhang behind wheels)
	local cabFrontZ  =  3.0          -- A-pillar (windshield base)
	local cabRearZ   = -8.0          -- D-pillar (at rear axle)
	local bPillarZ   =  0.0          -- between front/middle rows
	local cPillarZ   = -4.0          -- between middle/rear rows

	local frontAxleZ =  6.5
	local rearAxleZ  = -7.0

	local floorY     = FLOOR_Y                          -- 2.4
	local beltY      = floorY + 2.4                     -- 4.8 (window sill)
	local winH       = 2.6                               -- window height
	local winTopY    = beltY + winH                      -- 7.4
	local roofY      = winTopY + 0.4                     -- 7.8
	local lowerH     = beltY - floorY                    -- 2.4

	local cabLen     = cabFrontZ - cabRearZ              -- 12.0
	local cabMidZ    = (cabFrontZ + cabRearZ) / 2        -- -3.0

	---------------------------------------------------------------------------
	-- 1. WHEELS (large chrome alloys)
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
		-- Chrome alloy wheels
		VU.cylinder(model, "Hub",
			Vector3.new(wheelW + 0.15, wheelR * 0.7, wheelR * 0.7),
			CFrame.new(wp.x, wheelR, wp.z),
			C_HUB, Enum.Material.Metal)
	end

	---------------------------------------------------------------------------
	-- 2. LOWER BODY — clean luxury lines (minimal black cladding)
	---------------------------------------------------------------------------
	local doorThick = 0.5

	-- FRONT BODY (engine/hood area)
	local frontBodyLen = frontEndZ - cabFrontZ
	local chassis = VU.part(model, "Chassis",
		Vector3.new(bodyW, lowerH, frontBodyLen),
		CFrame.new(0, floorY + lowerH / 2, cabFrontZ + frontBodyLen / 2),
		bodyColor, Enum.Material.SmoothPlastic)

	-- REAR BODY (cargo area)
	local rearBodyLen = cabRearZ - rearEndZ
	VU.part(model, "RearBody",
		Vector3.new(bodyW, lowerH, rearBodyLen),
		CFrame.new(0, floorY + lowerH / 2, (cabRearZ + rearEndZ) / 2),
		bodyColor, Enum.Material.SmoothPlastic)

	-- DOOR PANELS (left + right walls in cabin zone)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "DoorPanel",
			Vector3.new(doorThick, lowerH, cabLen),
			CFrame.new(sx * (halfW - doorThick / 2), floorY + lowerH / 2, cabMidZ),
			bodyColor, Enum.Material.SmoothPlastic)
	end

	-- CABIN FLOOR (leather-look)
	VU.part(model, "CabinFloor",
		Vector3.new(bodyW - doorThick * 2, 0.15, cabLen),
		CFrame.new(0, floorY + 0.08, cabMidZ),
		C_INTERIOR, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- 3. RUNNING BOARDS (luxury side steps, between wheel wells)
	---------------------------------------------------------------------------
	local runningBoardFrontZ = frontAxleZ - 2.5  -- start behind front wheel
	local runningBoardRearZ  = rearAxleZ + 2.5   -- end before rear wheel
	local runningBoardLen = runningBoardFrontZ - runningBoardRearZ
	local runningBoardMidZ = (runningBoardFrontZ + runningBoardRearZ) / 2
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "RunningBoard",
			Vector3.new(0.8, 0.15, runningBoardLen),
			CFrame.new(sx * (halfW + 0.3), floorY - 0.3, runningBoardMidZ),
			C_RUNNING_BOARD, Enum.Material.SmoothPlastic)
		-- Chrome trim on running board
		VU.part(model, "RunningBoardTrim",
			Vector3.new(0.1, 0.08, runningBoardLen - 0.5),
			CFrame.new(sx * (halfW + 0.35), floorY - 0.2, runningBoardMidZ),
			C_CHROME, Enum.Material.Metal)
	end

	---------------------------------------------------------------------------
	-- 4. HOOD (long, elegant, slight slope)
	---------------------------------------------------------------------------
	local hoodLen = frontEndZ - cabFrontZ - 0.5
	VU.part(model, "Hood",
		Vector3.new(bodyW - 0.4, 0.25, hoodLen),
		CFrame.new(0, beltY + 0.12, cabFrontZ + 0.25 + hoodLen / 2),
		bodyColor, Enum.Material.SmoothPlastic)

	-- Hood character lines (subtle chrome strips)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "HoodLine",
			Vector3.new(0.05, 0.02, hoodLen - 1),
			CFrame.new(sx * 1.5, beltY + 0.26, cabFrontZ + 0.5 + (hoodLen - 1) / 2),
			C_CHROME, Enum.Material.Metal)
	end

	---------------------------------------------------------------------------
	-- 5. FRONT NOSE (gentle slope, luxury profile)
	---------------------------------------------------------------------------
	local noseRise = beltY + 0.25 - (floorY + 0.8)
	VU.wedge(model, "FrontNose",
		Vector3.new(bodyW - 0.4, noseRise, 1.2),
		CFrame.new(0, floorY + 0.8 + noseRise / 2, frontEndZ + 0.15)
			* CFrame.Angles(0, math.rad(180), 0),
		bodyColor, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- 6. FRONT BUMPER + GRILLE + LIGHTS (luxury chrome grille)
	---------------------------------------------------------------------------
	-- Lower bumper (body color, integrated)
	VU.part(model, "FrontBumper",
		Vector3.new(bodyW + 0.3, 1.0, 0.5),
		CFrame.new(0, floorY + 0.3, frontEndZ + 0.3),
		bodyColor, Enum.Material.SmoothPlastic)

	-- Chrome bumper accent
	VU.part(model, "BumperChrome",
		Vector3.new(bodyW - 1, 0.15, 0.2),
		CFrame.new(0, floorY + 0.15, frontEndZ + 0.5),
		C_CHROME, Enum.Material.Metal)

	-- Large chrome grille (signature luxury look)
	VU.part(model, "GrilleFrame",
		Vector3.new(4.0, 2.0, 0.15),
		CFrame.new(0, floorY + 1.5, frontEndZ + 0.55),
		C_CHROME, Enum.Material.Metal)

	-- Grille mesh (dark center)
	VU.part(model, "GrilleMesh",
		Vector3.new(3.6, 1.6, 0.1),
		CFrame.new(0, floorY + 1.5, frontEndZ + 0.5),
		C_TRIM, Enum.Material.SmoothPlastic)

	-- Horizontal chrome bars in grille
	for i = 0, 5 do
		VU.part(model, "GrilleBar",
			Vector3.new(3.4, 0.08, 0.15),
			CFrame.new(0, floorY + 0.8 + i * 0.28, frontEndZ + 0.55),
			C_CHROME, Enum.Material.Metal)
	end

	-- LED Headlights (slim, modern)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Headlight",
			Vector3.new(1.5, 0.6, 0.2),
			CFrame.new(sx * 3.0, floorY + 2.0, frontEndZ + 0.5),
			C_HEADLIGHT, Enum.Material.Neon)
	end

	-- DRL strips (below headlights)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "DRL",
			Vector3.new(1.2, 0.15, 0.15),
			CFrame.new(sx * 3.0, floorY + 1.5, frontEndZ + 0.55),
			C_DRL, Enum.Material.Neon)
	end

	-- Fog lights (in bumper)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "FogLight",
			Vector3.new(0.6, 0.4, 0.15),
			CFrame.new(sx * 2.5, floorY + 0.5, frontEndZ + 0.5),
			C_HEADLIGHT, Enum.Material.Neon)
	end

	---------------------------------------------------------------------------
	-- 7. ROOF (flat, luxury profile)
	---------------------------------------------------------------------------
	VU.part(model, "Roof",
		Vector3.new(bodyW, roofY - winTopY, cabLen + 0.6),
		CFrame.new(0, winTopY + (roofY - winTopY) / 2, cabMidZ),
		bodyColor, Enum.Material.SmoothPlastic)

	-- Chrome roof rails (subtle)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "RoofRail",
			Vector3.new(0.12, 0.15, cabLen - 2),
			CFrame.new(sx * (halfW - 0.4), roofY + 0.08, cabMidZ),
			C_CHROME, Enum.Material.Metal)
	end

	---------------------------------------------------------------------------
	-- 8. WINDSHIELD (large, slightly raked)
	---------------------------------------------------------------------------
	local wsg = VU.part(model, "Windshield",
		Vector3.new(bodyW - 0.6, winH, 0.15),
		CFrame.new(0, beltY + winH / 2, cabFrontZ + 0.1)
			* CFrame.Angles(math.rad(-15), 0, 0),
		C_GLASS, Enum.Material.Glass)
	wsg.Transparency = 0.4

	---------------------------------------------------------------------------
	-- 9. REAR WINDOW + TAILGATE
	---------------------------------------------------------------------------
	local rwg = VU.part(model, "RearWindow",
		Vector3.new(bodyW - 1.0, winH - 0.5, 0.15),
		CFrame.new(0, beltY + (winH - 0.5) / 2 + 0.25, cabRearZ - 0.1)
			* CFrame.Angles(math.rad(10), 0, 0),
		C_GLASS, Enum.Material.Glass)
	rwg.Transparency = 0.4

	-- Tailgate panel
	VU.part(model, "Tailgate",
		Vector3.new(bodyW, beltY - floorY, 0.3),
		CFrame.new(0, floorY + (beltY - floorY) / 2, rearEndZ + 0.05),
		bodyColor, Enum.Material.SmoothPlastic)

	-- Back wall
	VU.part(model, "BackWall",
		Vector3.new(bodyW, roofY - beltY, 0.25),
		CFrame.new(0, beltY + (roofY - beltY) / 2, cabRearZ + 0.1),
		bodyColor, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- 10. PILLARS (A, B, C, D - chrome trim accents)
	---------------------------------------------------------------------------
	-- A-PILLARS
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "APillar",
			Vector3.new(0.3, winH, 0.3),
			CFrame.new(sx * (halfW - 0.15), beltY + winH / 2, cabFrontZ),
			C_TRIM, Enum.Material.SmoothPlastic)
	end

	-- B-PILLARS (between front/middle)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "BPillar",
			Vector3.new(0.25, winH, 0.3),
			CFrame.new(sx * halfW, beltY + winH / 2, bPillarZ),
			C_TRIM, Enum.Material.SmoothPlastic)
		-- Chrome trim on B-pillar
		VU.part(model, "BPillarChrome",
			Vector3.new(0.05, winH - 0.5, 0.1),
			CFrame.new(sx * (halfW + 0.02), beltY + winH / 2, bPillarZ),
			C_CHROME, Enum.Material.Metal)
	end

	-- C-PILLARS (between middle/rear)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "CPillar",
			Vector3.new(0.25, winH, 0.3),
			CFrame.new(sx * halfW, beltY + winH / 2, cPillarZ),
			C_TRIM, Enum.Material.SmoothPlastic)
	end

	-- D-PILLARS (rear corners)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "DPillar",
			Vector3.new(0.35, winH, 0.35),
			CFrame.new(sx * (halfW - 0.15), beltY + winH / 2, cabRearZ),
			bodyColor, Enum.Material.SmoothPlastic)
	end

	---------------------------------------------------------------------------
	-- 11. SIDE WINDOWS (3 per side: front, middle, rear - dark tint)
	---------------------------------------------------------------------------
	local pillarW = 0.3

	for _, sx in ipairs({-1, 1}) do
		-- Front door window (A to B pillar)
		local fwFrontZ = cabFrontZ - 0.2
		local fwRearZ  = bPillarZ + pillarW/2
		local fwLen    = fwFrontZ - fwRearZ
		local fwg = VU.part(model, "SideWinFront",
			Vector3.new(0.15, winH, fwLen),
			CFrame.new(sx * halfW, beltY + winH / 2, (fwFrontZ + fwRearZ) / 2),
			C_GLASS, Enum.Material.Glass)
		fwg.Transparency = 0.4

		-- Middle door window (B to C pillar)
		local mwFrontZ = bPillarZ - pillarW/2
		local mwRearZ  = cPillarZ + pillarW/2
		local mwLen    = mwFrontZ - mwRearZ
		local mwg = VU.part(model, "SideWinMiddle",
			Vector3.new(0.15, winH, mwLen),
			CFrame.new(sx * halfW, beltY + winH / 2, (mwFrontZ + mwRearZ) / 2),
			C_GLASS, Enum.Material.Glass)
		mwg.Transparency = 0.4

		-- Rear window (C to D pillar)
		local rwFrontZ = cPillarZ - pillarW/2
		local rwRearZ  = cabRearZ + 0.3
		local rwLen    = rwFrontZ - rwRearZ
		local rwg2 = VU.part(model, "SideWinRear",
			Vector3.new(0.15, winH, rwLen),
			CFrame.new(sx * halfW, beltY + winH / 2, (rwFrontZ + rwRearZ) / 2),
			C_GLASS, Enum.Material.Glass)
		rwg2.Transparency = 0.4
	end

	---------------------------------------------------------------------------
	-- 12. REAR BUMPER + TAILLIGHTS (full-width LED bar style)
	---------------------------------------------------------------------------
	VU.part(model, "RearBumper",
		Vector3.new(bodyW + 0.3, 0.8, 0.4),
		CFrame.new(0, floorY + 0.25, rearEndZ - 0.2),
		bodyColor, Enum.Material.SmoothPlastic)

	-- Chrome bumper accent
	VU.part(model, "RearBumperChrome",
		Vector3.new(bodyW - 1.5, 0.1, 0.15),
		CFrame.new(0, floorY + 0.1, rearEndZ - 0.15),
		C_CHROME, Enum.Material.Metal)

	-- Large taillights (vertical, luxury style)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Taillight",
			Vector3.new(1.2, 2.0, 0.2),
			CFrame.new(sx * 3.0, floorY + lowerH / 2 + 0.8, rearEndZ + 0.05),
			C_TAILLIGHT, Enum.Material.Neon)
	end

	-- Center light bar (connects taillights)
	VU.part(model, "TaillightBar",
		Vector3.new(4.5, 0.25, 0.15),
		CFrame.new(0, floorY + lowerH + 0.5, rearEndZ + 0.05),
		C_TAILLIGHT, Enum.Material.Neon)

	---------------------------------------------------------------------------
	-- 13. CHROME SIDE TRIM + DETAILS
	---------------------------------------------------------------------------
	for _, sx in ipairs({-1, 1}) do
		-- Chrome window surround (beltline)
		VU.part(model, "WindowChrome",
			Vector3.new(0.06, 0.1, cabLen - 1),
			CFrame.new(sx * (halfW + 0.02), beltY + 0.05, cabMidZ),
			C_CHROME, Enum.Material.Metal)

		-- Door handles (chrome)
		for _, dz in ipairs({1.5, -2.0, -6.0}) do
			VU.part(model, "DoorHandle",
				Vector3.new(0.1, 0.15, 0.6),
				CFrame.new(sx * (halfW + 0.05), beltY - 0.4, dz),
				C_CHROME, Enum.Material.Metal)
		end

		-- Side mirror (large, luxury)
		VU.part(model, "Mirror",
			Vector3.new(0.7, 0.45, 0.9),
			CFrame.new(sx * (halfW + 0.45), beltY + 0.5, cabFrontZ - 0.3),
			bodyColor, Enum.Material.SmoothPlastic)
		-- Mirror chrome accent
		VU.part(model, "MirrorChrome",
			Vector3.new(0.08, 0.35, 0.7),
			CFrame.new(sx * (halfW + 0.75), beltY + 0.5, cabFrontZ - 0.3),
			C_CHROME, Enum.Material.Metal)
	end

	---------------------------------------------------------------------------
	-- 14. INTERIOR LIGHTING (Neon strip only, no PointLight for performance)
	---------------------------------------------------------------------------
	VU.part(model, "CeilingLight",
		Vector3.new(2.0, 0.08, cabLen * 0.6),
		CFrame.new(0, winTopY - 0.04, cabMidZ),
		Color3.fromRGB(255, 245, 230), Enum.Material.Neon)

	---------------------------------------------------------------------------
	-- 15. EXHAUST (dual chrome tips, larger)
	---------------------------------------------------------------------------
	for _, sx in ipairs({-2.0, 2.0}) do
		VU.cylinder(model, "ExhaustTip",
			Vector3.new(0.6, 0.5, 0.5),
			CFrame.new(sx, floorY + 0.4, rearEndZ - 0.4)
				* CFrame.Angles(math.rad(90), 0, 0),
			C_CHROME, Enum.Material.Metal)
	end

	---------------------------------------------------------------------------
	-- Finalize
	---------------------------------------------------------------------------
	model.PrimaryPart = chassis
	return model
end

return SUVLuxury
