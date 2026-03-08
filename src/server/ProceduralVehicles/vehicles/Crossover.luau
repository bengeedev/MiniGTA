local VU = require(script.Parent:WaitForChild("VehicleUtils"))

local Crossover = {}

--------------------------------------------------------------------------------
-- Default palette (white crossover like reference image)
--------------------------------------------------------------------------------
local C_DEFAULT_BODY  = Color3.fromRGB(235, 235, 240)  -- white
local C_TRIM          = Color3.fromRGB(25, 25, 28)      -- black bumpers/trim/cladding
local C_CHROME        = Color3.fromRGB(180, 180, 185)   -- chrome grille accents
local C_GLASS         = Color3.fromRGB(100, 120, 140)   -- darker tinted glass
local C_INTERIOR      = Color3.fromRGB(45, 40, 40)      -- dark interior
local C_RUBBER        = Color3.fromRGB(30, 30, 30)      -- tires
local C_HUB           = Color3.fromRGB(160, 160, 165)   -- wheel hubs
local C_HEADLIGHT     = Color3.fromRGB(255, 245, 210)   -- warm white headlight
local C_AMBER         = Color3.fromRGB(255, 180, 30)    -- turn signal amber
local C_TAILLIGHT     = Color3.fromRGB(200, 20, 15)     -- red taillight
local C_ROOF_RAIL     = Color3.fromRGB(35, 35, 38)      -- black roof rails

--------------------------------------------------------------------------------
-- Shared Y constants (used by init.luau for NPC seating)
-- Crossover sits higher than sedan: floorY 2.2 vs 1.8
--------------------------------------------------------------------------------
local FLOOR_Y = 2.2
Crossover.FLOOR_Y = FLOOR_Y
Crossover.SEAT_Y  = 4.6   -- adjusted for higher floor

--------------------------------------------------------------------------------
-- CROSSOVER BUILDER
-- Chunky SUV/crossover style. Faces +Z forward, wheels on ground Y=0.
-- Key features: higher ride, black cladding, roof rack, wheel arch flares
--------------------------------------------------------------------------------
function Crossover.build(modelName, bodyColor)
	modelName = modelName or "Crossover_White_1"
	bodyColor = bodyColor or C_DEFAULT_BODY

	local model = Instance.new("Model")
	model.Name = modelName

	---------------------------------------------------------------------------
	-- Dimensions (taller/chunkier than sedan)
	---------------------------------------------------------------------------
	local wheelR     = 1.8           -- bigger wheels than sedan (1.5)
	local wheelW     = 1.1
	local halfW      = 3.6           -- slightly wider
	local bodyW      = halfW * 2     -- 7.2

	local frontEndZ  =  7.5          -- nose tip
	local rearEndZ   = -7.5          -- rear bumper
	local cabFrontZ  =  2.0          -- A-pillar (windshield base)
	local cabRearZ   = -5.5          -- D-pillar (rear of cabin)
	local bPillarZ   = -1.0          -- between front/rear doors

	local frontAxleZ =  5.0
	local rearAxleZ  = -5.0

	local floorY     = FLOOR_Y                          -- 2.2
	local beltY      = floorY + 2.2                     -- 4.4 (window sill)
	local winH       = 2.5                               -- window height
	local winTopY    = beltY + winH                      -- 6.9
	local roofY      = winTopY + 0.4                     -- 7.3
	local lowerH     = beltY - floorY                    -- 2.2

	local cabLen     = cabFrontZ - cabRearZ              -- 7.5
	local cabMidZ    = (cabFrontZ + cabRearZ) / 2        -- -1.75

	---------------------------------------------------------------------------
	-- 1. WHEELS (bigger, chunkier)
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
			Vector3.new(wheelW + 0.1, wheelR * 0.55, wheelR * 0.55),
			CFrame.new(wp.x, wheelR, wp.z),
			C_HUB, Enum.Material.Metal)
	end

	---------------------------------------------------------------------------
	-- 2. LOWER BODY — hollow cabin with black cladding
	---------------------------------------------------------------------------
	local doorThick = 0.5
	local claddingH = 0.8  -- black plastic cladding height

	-- FRONT BODY (engine/hood area)
	local frontBodyLen = frontEndZ - cabFrontZ
	local chassis = VU.part(model, "Chassis",
		Vector3.new(bodyW, lowerH - claddingH, frontBodyLen),
		CFrame.new(0, floorY + claddingH + (lowerH - claddingH) / 2, cabFrontZ + frontBodyLen / 2),
		bodyColor, Enum.Material.SmoothPlastic)

	-- Front lower cladding (black plastic)
	VU.part(model, "FrontCladding",
		Vector3.new(bodyW, claddingH, frontBodyLen),
		CFrame.new(0, floorY + claddingH / 2, cabFrontZ + frontBodyLen / 2),
		C_TRIM, Enum.Material.SmoothPlastic)

	-- REAR BODY (cargo area below windows)
	local rearBodyLen = cabRearZ - rearEndZ
	VU.part(model, "RearBody",
		Vector3.new(bodyW, lowerH - claddingH, rearBodyLen),
		CFrame.new(0, floorY + claddingH + (lowerH - claddingH) / 2, (cabRearZ + rearEndZ) / 2),
		bodyColor, Enum.Material.SmoothPlastic)

	-- Rear lower cladding (black plastic)
	VU.part(model, "RearCladding",
		Vector3.new(bodyW, claddingH, rearBodyLen),
		CFrame.new(0, floorY + claddingH / 2, (cabRearZ + rearEndZ) / 2),
		C_TRIM, Enum.Material.SmoothPlastic)

	-- DOOR PANELS (left + right walls in cabin zone)
	for _, sx in ipairs({-1, 1}) do
		-- Upper door panel (body color)
		VU.part(model, "DoorPanel",
			Vector3.new(doorThick, lowerH - claddingH, cabLen),
			CFrame.new(sx * (halfW - doorThick / 2), floorY + claddingH + (lowerH - claddingH) / 2, cabMidZ),
			bodyColor, Enum.Material.SmoothPlastic)
		-- Lower door cladding (black plastic)
		VU.part(model, "DoorCladding",
			Vector3.new(doorThick, claddingH, cabLen),
			CFrame.new(sx * (halfW - doorThick / 2), floorY + claddingH / 2, cabMidZ),
			C_TRIM, Enum.Material.SmoothPlastic)
	end

	-- CABIN FLOOR
	VU.part(model, "CabinFloor",
		Vector3.new(bodyW - doorThick * 2, 0.15, cabLen),
		CFrame.new(0, floorY + 0.08, cabMidZ),
		C_INTERIOR, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- 3. HOOD (flat, boxy SUV style)
	---------------------------------------------------------------------------
	local hoodLen = frontEndZ - cabFrontZ - 0.5
	VU.part(model, "Hood",
		Vector3.new(bodyW - 0.4, 0.3, hoodLen),
		CFrame.new(0, beltY + 0.15, cabFrontZ + 0.25 + hoodLen / 2),
		bodyColor, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- 5. FRONT NOSE (less sloped, more upright SUV style)
	---------------------------------------------------------------------------
	local noseRise = beltY + 0.3 - (floorY + claddingH + 0.3)
	VU.wedge(model, "FrontNose",
		Vector3.new(bodyW - 0.4, noseRise, 1.0),
		CFrame.new(0, floorY + claddingH + 0.3 + noseRise / 2, frontEndZ + 0.1)
			* CFrame.Angles(0, math.rad(180), 0),
		bodyColor, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- 6. FRONT BUMPER + GRILLE + LIGHTS (boxy, aggressive)
	---------------------------------------------------------------------------
	-- Lower bumper (black plastic)
	VU.part(model, "FrontBumper",
		Vector3.new(bodyW + 0.4, 1.2, 0.6),
		CFrame.new(0, floorY + 0.4, frontEndZ + 0.35),
		C_TRIM, Enum.Material.SmoothPlastic)

	-- Main grille (large, boxy)
	VU.part(model, "Grille",
		Vector3.new(4.5, 1.5, 0.2),
		CFrame.new(0, floorY + claddingH + 0.9, frontEndZ + 0.5),
		C_TRIM, Enum.Material.SmoothPlastic)

	-- Chrome grille accent bars
	for i = 0, 4 do
		VU.part(model, "GrilleBar",
			Vector3.new(4.0, 0.06, 0.25),
			CFrame.new(0, floorY + claddingH + 0.4 + i * 0.28, frontEndZ + 0.55),
			C_CHROME, Enum.Material.Metal)
	end

	-- Headlights (rectangular, beside grille)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Headlight",
			Vector3.new(1.2, 1.0, 0.2),
			CFrame.new(sx * 2.9, floorY + claddingH + 0.9, frontEndZ + 0.5),
			C_HEADLIGHT, Enum.Material.Neon)
	end

	-- Turn signals (amber, corners)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "TurnSignal",
			Vector3.new(0.5, 0.5, 0.15),
			CFrame.new(sx * (halfW + 0.05), floorY + claddingH + 0.5, frontEndZ + 0.5),
			C_AMBER, Enum.Material.Neon)
	end

	-- Fog lights (below bumper, like reference)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "FogLight",
			Vector3.new(0.8, 0.5, 0.15),
			CFrame.new(sx * 2.2, floorY + 0.5, frontEndZ + 0.5),
			C_HEADLIGHT, Enum.Material.Neon)
	end

	---------------------------------------------------------------------------
	-- 7. ROOF + ROOF RACK (black rails like reference)
	---------------------------------------------------------------------------
	VU.part(model, "Roof",
		Vector3.new(bodyW, roofY - winTopY, cabLen + 0.6),
		CFrame.new(0, winTopY + (roofY - winTopY) / 2, cabMidZ),
		bodyColor, Enum.Material.SmoothPlastic)

	-- Roof rack base (black panel on top)
	local rackLen = cabLen - 1.5
	VU.part(model, "RoofRackBase",
		Vector3.new(bodyW - 1.0, 0.15, rackLen),
		CFrame.new(0, roofY + 0.08, cabMidZ),
		C_ROOF_RAIL, Enum.Material.SmoothPlastic)

	-- Roof rack side rails
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "RoofRail",
			Vector3.new(0.2, 0.25, rackLen),
			CFrame.new(sx * (halfW - 0.5), roofY + 0.2, cabMidZ),
			C_ROOF_RAIL, Enum.Material.SmoothPlastic)
	end

	-- Roof rack cross bars
	for _, rz in ipairs({cabFrontZ - 1.0, cabMidZ, cabRearZ + 1.0}) do
		VU.part(model, "RoofCrossBar",
			Vector3.new(bodyW - 1.2, 0.15, 0.25),
			CFrame.new(0, roofY + 0.25, rz),
			C_ROOF_RAIL, Enum.Material.SmoothPlastic)
	end

	---------------------------------------------------------------------------
	-- 8. WINDSHIELD
	---------------------------------------------------------------------------
	local wsg = VU.part(model, "Windshield",
		Vector3.new(bodyW - 0.6, winH, 0.15),
		CFrame.new(0, beltY + winH / 2, cabFrontZ + 0.1)
			* CFrame.Angles(math.rad(-18), 0, 0),
		C_GLASS, Enum.Material.Glass)
	wsg.Transparency = 0.5

	---------------------------------------------------------------------------
	-- 9. REAR WINDOW + HATCH
	---------------------------------------------------------------------------
	local rwg = VU.part(model, "RearWindow",
		Vector3.new(bodyW - 1.0, winH - 0.4, 0.15),
		CFrame.new(0, beltY + (winH - 0.4) / 2 + 0.2, cabRearZ - 0.1)
			* CFrame.Angles(math.rad(12), 0, 0),
		C_GLASS, Enum.Material.Glass)
	rwg.Transparency = 0.5

	-- Rear hatch panel (below window)
	VU.part(model, "RearHatch",
		Vector3.new(bodyW, beltY - floorY - claddingH, 0.3),
		CFrame.new(0, floorY + claddingH + (beltY - floorY - claddingH) / 2, rearEndZ + 0.05),
		bodyColor, Enum.Material.SmoothPlastic)

	-- Rear hatch lower (black cladding)
	VU.part(model, "RearHatchCladding",
		Vector3.new(bodyW, claddingH, 0.3),
		CFrame.new(0, floorY + claddingH / 2, rearEndZ + 0.05),
		C_TRIM, Enum.Material.SmoothPlastic)

	-- Back wall (fills gap between roof and rear)
	VU.part(model, "BackWall",
		Vector3.new(bodyW, roofY - beltY, 0.25),
		CFrame.new(0, beltY + (roofY - beltY) / 2, cabRearZ + 0.1),
		bodyColor, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- 10. PILLARS (A, B, C)
	---------------------------------------------------------------------------
	-- A-PILLARS (windshield)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "APillar",
			Vector3.new(0.3, winH, 0.3),
			CFrame.new(sx * (halfW - 0.15), beltY + winH / 2, cabFrontZ),
			C_TRIM, Enum.Material.SmoothPlastic)
	end

	-- B-PILLARS (between front/rear doors)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "BPillar",
			Vector3.new(0.25, winH, 0.35),
			CFrame.new(sx * halfW, beltY + winH / 2, bPillarZ),
			C_TRIM, Enum.Material.SmoothPlastic)
	end

	-- C-PILLARS (rear corners, thicker for SUV look)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "CPillar",
			Vector3.new(0.35, winH, 0.4),
			CFrame.new(sx * (halfW - 0.15), beltY + winH / 2, cabRearZ),
			bodyColor, Enum.Material.SmoothPlastic)
	end

	---------------------------------------------------------------------------
	-- 11. SIDE WINDOWS
	---------------------------------------------------------------------------
	local pillarW = 0.35

	for _, sx in ipairs({-1, 1}) do
		-- Front door window (A to B pillar)
		local fwFrontZ = cabFrontZ - 0.2
		local fwRearZ  = bPillarZ + pillarW/2
		local fwLen    = fwFrontZ - fwRearZ
		local fwg = VU.part(model, "SideWinFront",
			Vector3.new(0.15, winH, fwLen),
			CFrame.new(sx * halfW, beltY + winH / 2, (fwFrontZ + fwRearZ) / 2),
			C_GLASS, Enum.Material.Glass)
		fwg.Transparency = 0.5

		-- Rear door window (B to C pillar)
		local rwFrontZ = bPillarZ - pillarW/2
		local rwRearZ  = cabRearZ + 0.3
		local rwLen    = rwFrontZ - rwRearZ
		local rwg2 = VU.part(model, "SideWinRear",
			Vector3.new(0.15, winH, rwLen),
			CFrame.new(sx * halfW, beltY + winH / 2, (rwFrontZ + rwRearZ) / 2),
			C_GLASS, Enum.Material.Glass)
		rwg2.Transparency = 0.5
	end

	---------------------------------------------------------------------------
	-- 12. REAR BUMPER + TAILLIGHTS
	---------------------------------------------------------------------------
	VU.part(model, "RearBumper",
		Vector3.new(bodyW + 0.4, 1.0, 0.5),
		CFrame.new(0, floorY + 0.3, rearEndZ - 0.25),
		C_TRIM, Enum.Material.SmoothPlastic)

	-- Taillights (vertical, flush with rear face)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Taillight",
			Vector3.new(1.0, 1.4, 0.2),
			CFrame.new(sx * 2.5, floorY + claddingH + 0.9, rearEndZ + 0.05),
			C_TAILLIGHT, Enum.Material.Neon)
	end

	---------------------------------------------------------------------------
	-- 13. SIDE TRIM + DETAILS
	---------------------------------------------------------------------------
	for _, sx in ipairs({-1, 1}) do
		-- Door handles (front and rear doors)
		for _, dz in ipairs({0.8, -3.0}) do
			VU.part(model, "DoorHandle",
				Vector3.new(0.08, 0.12, 0.5),
				CFrame.new(sx * (halfW + 0.04), beltY - 0.3, dz),
				C_CHROME, Enum.Material.Metal)
		end

		-- Side mirror (chunky)
		VU.part(model, "Mirror",
			Vector3.new(0.6, 0.4, 0.8),
			CFrame.new(sx * (halfW + 0.4), beltY + 0.6, cabFrontZ - 0.3),
			C_TRIM, Enum.Material.SmoothPlastic)
	end

	---------------------------------------------------------------------------
	-- 14. INTERIOR LIGHTING (Neon strip only, no PointLight for performance)
	---------------------------------------------------------------------------
	VU.part(model, "CeilingLight",
		Vector3.new(1.5, 0.08, cabLen * 0.5),
		CFrame.new(0, winTopY - 0.04, cabMidZ),
		Color3.fromRGB(255, 240, 210), Enum.Material.Neon)

	---------------------------------------------------------------------------
	-- 15. EXHAUST (dual, chrome tips)
	---------------------------------------------------------------------------
	for _, sx in ipairs({-1.5, 1.5}) do
		VU.cylinder(model, "ExhaustTip",
			Vector3.new(0.5, 0.45, 0.45),
			CFrame.new(sx, floorY + 0.4, rearEndZ - 0.35)
				* CFrame.Angles(math.rad(90), 0, 0),
			C_CHROME, Enum.Material.Metal)
	end

	---------------------------------------------------------------------------
	-- Finalize
	---------------------------------------------------------------------------
	model.PrimaryPart = chassis
	return model
end

return Crossover
