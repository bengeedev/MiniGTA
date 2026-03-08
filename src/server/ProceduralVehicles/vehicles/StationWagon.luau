local VU = require(script.Parent:WaitForChild("VehicleUtils"))

local StationWagon = {}

--------------------------------------------------------------------------------
-- Default palette (white wagon like the reference image)
--------------------------------------------------------------------------------
local C_DEFAULT_BODY  = Color3.fromRGB(235, 235, 240)  -- white
local C_TRIM          = Color3.fromRGB(25, 25, 28)      -- black bumpers/trim
local C_CHROME        = Color3.fromRGB(180, 180, 185)   -- chrome grille/handles
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
--------------------------------------------------------------------------------
local FLOOR_Y = 1.8
StationWagon.FLOOR_Y = FLOOR_Y
StationWagon.SEAT_Y  = 4.2

--------------------------------------------------------------------------------
-- STATION WAGON BUILDER
-- Blocky 80s/90s style estate car. Faces +Z forward, wheels on ground Y=0.
-- Key difference from sedan: extended rear with full-height cargo area + roof rails
--------------------------------------------------------------------------------
function StationWagon.build(modelName, bodyColor)
	modelName = modelName or "Wagon_White_1"
	bodyColor = bodyColor or C_DEFAULT_BODY

	local model = Instance.new("Model")
	model.Name = modelName

	---------------------------------------------------------------------------
	-- Dimensions (longer than sedan, squared-off rear)
	---------------------------------------------------------------------------
	local wheelR     = 1.5
	local wheelW     = 1.0
	local halfW      = 3.5          -- half body width
	local bodyW      = halfW * 2    -- 7

	local frontEndZ  =  8.0         -- nose tip (slightly longer hood)
	local rearEndZ   = -9.0         -- rear bumper (longer overall)
	local cabFrontZ  =  2.5         -- A-pillar (windshield base)
	local cabRearZ   = -7.5         -- D-pillar (rear of wagon)
	local bPillarZ   = -0.5         -- between front/rear doors
	local cPillarZ   = -4.0         -- between rear door and cargo windows

	local frontAxleZ =  5.5
	local rearAxleZ  = -6.5

	local floorY     = FLOOR_Y                          -- 1.8
	local beltY      = floorY + 2.0                     -- 3.8  (window sill)
	local winH       = 2.7                               -- window height
	local winTopY    = beltY + winH                      -- 6.5
	local roofY      = winTopY + 0.3                     -- 6.8
	local lowerH     = beltY - floorY                    -- 2.0

	local cabLen     = cabFrontZ - cabRearZ              -- 10.0 (longer cabin area)
	local cabMidZ    = (cabFrontZ + cabRearZ) / 2        -- -2.5

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
	-- 2. LOWER BODY — hollow cabin with extended rear cargo area
	---------------------------------------------------------------------------
	local doorThick = 0.5

	-- FRONT BODY (engine/hood area)
	local frontBodyLen = frontEndZ - cabFrontZ
	local chassis = VU.part(model, "Chassis",
		Vector3.new(bodyW, lowerH, frontBodyLen),
		CFrame.new(0, floorY + lowerH / 2, cabFrontZ + frontBodyLen / 2),
		bodyColor, Enum.Material.SmoothPlastic)

	-- REAR BODY (below cargo area, from cabin to rear bumper)
	local rearBodyLen = cabRearZ - rearEndZ
	VU.part(model, "RearBody",
		Vector3.new(bodyW, lowerH, rearBodyLen),
		CFrame.new(0, floorY + lowerH / 2, (cabRearZ + rearEndZ) / 2),
		bodyColor, Enum.Material.SmoothPlastic)

	-- DOOR PANELS (left + right walls in passenger area, from floor to belt)
	local passengerLen = cabFrontZ - cPillarZ
	local passengerMidZ = (cabFrontZ + cPillarZ) / 2
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "DoorPanel",
			Vector3.new(doorThick, lowerH, passengerLen),
			CFrame.new(sx * (halfW - doorThick / 2), floorY + lowerH / 2, passengerMidZ),
			bodyColor, Enum.Material.SmoothPlastic)
	end

	-- CARGO SIDE PANELS (left + right walls in cargo area, below windows)
	local cargoLen = cPillarZ - cabRearZ
	local cargoMidZ = (cPillarZ + cabRearZ) / 2
	for _, sx in ipairs({-1, 1}) do
		-- Lower cargo side (floor to belt line)
		VU.part(model, "CargoSideLower",
			Vector3.new(doorThick, lowerH, cargoLen),
			CFrame.new(sx * (halfW - doorThick / 2), floorY + lowerH / 2, cargoMidZ),
			bodyColor, Enum.Material.SmoothPlastic)
		-- Upper cargo side (belt line to roof, solid panel below windows)
		local upperH = winH * 0.15  -- small strip below cargo windows
		VU.part(model, "CargoSideUpper",
			Vector3.new(doorThick, upperH, cargoLen),
			CFrame.new(sx * (halfW - doorThick / 2), beltY + upperH / 2, cargoMidZ),
			bodyColor, Enum.Material.SmoothPlastic)
	end

	-- CABIN FLOOR
	VU.part(model, "CabinFloor",
		Vector3.new(bodyW - doorThick * 2, 0.15, passengerLen),
		CFrame.new(0, floorY + 0.08, passengerMidZ),
		C_INTERIOR, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- 3. HOOD (stepped design like the reference - two levels)
	---------------------------------------------------------------------------
	local hoodLen = frontEndZ - cabFrontZ - 0.5
	-- Lower hood section
	VU.part(model, "HoodLower",
		Vector3.new(bodyW - 0.4, 0.2, hoodLen * 0.6),
		CFrame.new(0, beltY - 0.3, frontEndZ - hoodLen * 0.3),
		bodyColor, Enum.Material.SmoothPlastic)
	-- Upper hood section (raised near windshield)
	VU.part(model, "HoodUpper",
		Vector3.new(bodyW - 0.4, 0.25, hoodLen * 0.4),
		CFrame.new(0, beltY + 0.12, cabFrontZ + hoodLen * 0.2 + 0.25),
		bodyColor, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- 4. FRONT NOSE
	---------------------------------------------------------------------------
	local noseRise = beltY - 0.3 - (floorY + 0.6)
	VU.wedge(model, "FrontNose",
		Vector3.new(bodyW - 0.4, noseRise, 1.2),
		CFrame.new(0, floorY + 0.6 + noseRise / 2, frontEndZ + 0.1)
			* CFrame.Angles(0, math.rad(180), 0),
		bodyColor, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- 5. FRONT BUMPER + GRILLE + LIGHTS
	---------------------------------------------------------------------------
	VU.part(model, "FrontBumper",
		Vector3.new(bodyW + 0.2, 1.0, 0.5),
		CFrame.new(0, floorY + 0.3, frontEndZ + 0.3),
		C_TRIM, Enum.Material.SmoothPlastic)

	-- Chrome grille (horizontal bars like reference)
	VU.part(model, "Grille",
		Vector3.new(4.0, 1.2, 0.15),
		CFrame.new(0, floorY + 1.0, frontEndZ + 0.45),
		C_CHROME, Enum.Material.Metal)

	for i = 0, 4 do
		VU.part(model, "GrilleBar",
			Vector3.new(3.6, 0.04, 0.2),
			CFrame.new(0, floorY + 0.5 + i * 0.25, frontEndZ + 0.5),
			C_TRIM, Enum.Material.SmoothPlastic)
	end

	-- Headlights (rectangular, like 80s style)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Headlight",
			Vector3.new(1.0, 0.8, 0.15),
			CFrame.new(sx * 2.8, floorY + 1.1, frontEndZ + 0.45),
			C_HEADLIGHT, Enum.Material.Neon)
	end

	-- Turn signals (amber, beside headlights)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "TurnSignal",
			Vector3.new(0.5, 0.4, 0.15),
			CFrame.new(sx * (halfW - 0.1), floorY + 0.75, frontEndZ + 0.45),
			C_AMBER, Enum.Material.Neon)
	end

	---------------------------------------------------------------------------
	-- 6. ROOF (extends all the way to rear - wagon style)
	---------------------------------------------------------------------------
	local roofLen = cabFrontZ - rearEndZ + 0.3  -- extend to actual rear
	VU.part(model, "Roof",
		Vector3.new(bodyW, roofY - winTopY, roofLen),
		CFrame.new(0, winTopY + (roofY - winTopY) / 2, (cabFrontZ + rearEndZ) / 2),
		bodyColor, Enum.Material.SmoothPlastic)

	-- ROOF RAILS (black, running along the sides)
	for _, sx in ipairs({-1, 1}) do
		-- Main rail
		VU.part(model, "RoofRail",
			Vector3.new(0.15, 0.2, roofLen - 1),
			CFrame.new(sx * (halfW - 0.3), roofY + 0.1, (cabFrontZ + rearEndZ) / 2),
			C_ROOF_RAIL, Enum.Material.SmoothPlastic)
		-- Rail supports (front and back)
		for _, rz in ipairs({cabFrontZ - 0.8, rearEndZ + 0.8}) do
			VU.part(model, "RailSupport",
				Vector3.new(0.12, 0.15, 0.3),
				CFrame.new(sx * (halfW - 0.3), roofY + 0.02, rz),
				C_ROOF_RAIL, Enum.Material.SmoothPlastic)
		end
	end

	---------------------------------------------------------------------------
	-- 7. WINDSHIELD
	---------------------------------------------------------------------------
	local wsg = VU.part(model, "Windshield",
		Vector3.new(bodyW - 0.6, winH, 0.15),
		CFrame.new(0, beltY + winH / 2, cabFrontZ + 0.1)
			* CFrame.Angles(math.rad(-15), 0, 0),
		C_GLASS, Enum.Material.Glass)
	wsg.Transparency = 0.5

	---------------------------------------------------------------------------
	-- 8. REAR WINDOW (on the tailgate at actual rear of car)
	---------------------------------------------------------------------------
	local rwg = VU.part(model, "RearWindow",
		Vector3.new(bodyW - 1.2, winH - 0.3, 0.15),
		CFrame.new(0, beltY + (winH - 0.3) / 2 + 0.15, rearEndZ + 0.08),
		C_GLASS, Enum.Material.Glass)
	rwg.Transparency = 0.5

	---------------------------------------------------------------------------
	-- 9. PILLARS (A, B, C, D for wagon)
	---------------------------------------------------------------------------
	-- A-PILLARS (windshield)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "APillar",
			Vector3.new(0.25, winH, 0.25),
			CFrame.new(sx * (halfW - 0.12), beltY + winH / 2, cabFrontZ),
			C_TRIM, Enum.Material.SmoothPlastic)
	end

	-- B-PILLARS (between front/rear doors)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "BPillar",
			Vector3.new(0.2, winH, 0.3),
			CFrame.new(sx * halfW, beltY + winH / 2, bPillarZ),
			C_TRIM, Enum.Material.SmoothPlastic)
	end

	-- C-PILLARS (between rear door and cargo)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "CPillar",
			Vector3.new(0.2, winH, 0.3),
			CFrame.new(sx * halfW, beltY + winH / 2, cPillarZ),
			C_TRIM, Enum.Material.SmoothPlastic)
	end

	-- D-PILLARS (at rear window corners)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "DPillar",
			Vector3.new(0.25, winH, 0.25),
			CFrame.new(sx * (halfW - 0.12), beltY + winH / 2, cabRearZ),
			C_TRIM, Enum.Material.SmoothPlastic)
	end

	---------------------------------------------------------------------------
	-- 10. SIDE WINDOWS (4 per side: front door, rear door, cargo small, cargo large)
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
		fwg.Transparency = 0.5

		-- Rear door window (B to C pillar)
		local rdFrontZ = bPillarZ - pillarW/2
		local rdRearZ  = cPillarZ + pillarW/2
		local rdLen    = rdFrontZ - rdRearZ
		local rdg = VU.part(model, "SideWinRearDoor",
			Vector3.new(0.15, winH, rdLen),
			CFrame.new(sx * halfW, beltY + winH / 2, (rdFrontZ + rdRearZ) / 2),
			C_GLASS, Enum.Material.Glass)
		rdg.Transparency = 0.5

		-- Cargo window (C to D pillar) - the distinctive wagon rear side window
		local cwFrontZ = cPillarZ - pillarW/2
		local cwRearZ  = cabRearZ + pillarW/2
		local cwLen    = cwFrontZ - cwRearZ
		local cwg = VU.part(model, "SideWinCargo",
			Vector3.new(0.15, winH, cwLen),
			CFrame.new(sx * halfW, beltY + winH / 2, (cwFrontZ + cwRearZ) / 2),
			C_GLASS, Enum.Material.Glass)
		cwg.Transparency = 0.5
	end

	---------------------------------------------------------------------------
	-- 11. REAR SECTION (squared-off wagon back)
	---------------------------------------------------------------------------
	-- Rear body panel (below rear window, from belt down to bumper)
	VU.part(model, "RearPanel",
		Vector3.new(bodyW, beltY - floorY, 0.3),
		CFrame.new(0, floorY + (beltY - floorY) / 2, rearEndZ + 0.05),
		bodyColor, Enum.Material.SmoothPlastic)

	-- Back wall (fills gap between roof and rear window)
	VU.part(model, "BackWall",
		Vector3.new(bodyW, roofY - beltY, 0.25),
		CFrame.new(0, beltY + (roofY - beltY) / 2, rearEndZ + 0.12),
		bodyColor, Enum.Material.SmoothPlastic)

	-- Cargo floor (connects cabin to rear)
	local cargoFloorLen = cabRearZ - rearEndZ
	VU.part(model, "CargoFloor",
		Vector3.new(bodyW - doorThick * 2, 0.15, cargoFloorLen),
		CFrame.new(0, floorY + 0.08, (cabRearZ + rearEndZ) / 2),
		C_INTERIOR, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- 12. REAR BUMPER + TAILLIGHTS
	---------------------------------------------------------------------------
	VU.part(model, "RearBumper",
		Vector3.new(bodyW + 0.2, 0.8, 0.4),
		CFrame.new(0, floorY + 0.2, rearEndZ - 0.2),
		C_TRIM, Enum.Material.SmoothPlastic)

	-- Taillights (vertical, wagon-style)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Taillight",
			Vector3.new(0.8, 1.8, 0.15),
			CFrame.new(sx * (halfW - 0.5), floorY + 1.8, rearEndZ - 0.15),
			C_TAILLIGHT, Enum.Material.Neon)
	end

	---------------------------------------------------------------------------
	-- 13. SIDE TRIM + DETAILS
	---------------------------------------------------------------------------
	for _, sx in ipairs({-1, 1}) do
		-- Black side molding strip
		VU.part(model, "SideMolding",
			Vector3.new(0.08, 0.15, frontEndZ - rearEndZ - 2),
			CFrame.new(sx * (halfW + 0.02), beltY - 0.5, (frontEndZ + rearEndZ) / 2),
			C_TRIM, Enum.Material.SmoothPlastic)

		-- Door handles (front and rear doors)
		for _, dz in ipairs({1.5, -2.0}) do
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

		-- Wheel well trim (front and rear)
		for _, wz in ipairs({frontAxleZ, rearAxleZ}) do
			VU.part(model, "WheelWellTrim",
				Vector3.new(0.1, 0.3, 2.2),
				CFrame.new(sx * (halfW + 0.02), floorY + 0.5, wz),
				C_TRIM, Enum.Material.SmoothPlastic)
		end
	end

	---------------------------------------------------------------------------
	-- 14. INTERIOR LIGHTING (Neon strip only, no PointLight for performance)
	---------------------------------------------------------------------------
	VU.part(model, "CeilingLight",
		Vector3.new(1.5, 0.08, passengerLen * 0.5),
		CFrame.new(0, winTopY - 0.04, passengerMidZ),
		Color3.fromRGB(255, 240, 210), Enum.Material.Neon)

	---------------------------------------------------------------------------
	-- 15. EXHAUST
	---------------------------------------------------------------------------
	VU.cylinder(model, "ExhaustTip",
		Vector3.new(0.5, 0.4, 0.4),
		CFrame.new(-1.5, floorY + 0.3, rearEndZ - 0.3)
			* CFrame.Angles(math.rad(90), 0, 0),
		C_CHROME, Enum.Material.Metal)

	---------------------------------------------------------------------------
	-- Finalize
	---------------------------------------------------------------------------
	model.PrimaryPart = chassis
	return model
end

return StationWagon
