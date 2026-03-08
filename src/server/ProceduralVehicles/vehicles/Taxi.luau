local VU = require(script.Parent:WaitForChild("VehicleUtils"))

local Taxi = {}

--------------------------------------------------------------------------------
-- Taxi palette (classic yellow cab)
--------------------------------------------------------------------------------
local C_YELLOW        = Color3.fromRGB(255, 200, 40)   -- taxi yellow
local C_TRIM          = Color3.fromRGB(25, 25, 28)     -- dark trim
local C_CHROME        = Color3.fromRGB(180, 180, 185)  -- chrome details
local C_GLASS         = Color3.fromRGB(140, 160, 180)  -- window glass
local C_INTERIOR      = Color3.fromRGB(50, 45, 40)     -- tan interior
local C_RUBBER        = Color3.fromRGB(30, 30, 30)     -- tires
local C_HUB           = Color3.fromRGB(160, 160, 165)  -- silver hubcaps
local C_HEADLIGHT     = Color3.fromRGB(255, 245, 210)  -- warm white headlight
local C_TAILLIGHT     = Color3.fromRGB(200, 20, 15)    -- red taillight
local C_ROOF_LIGHT    = Color3.fromRGB(255, 240, 200)  -- taxi sign illuminated

--------------------------------------------------------------------------------
-- Shared Y constants (used by init.luau for NPC seating)
--------------------------------------------------------------------------------
local FLOOR_Y = 1.8
Taxi.FLOOR_Y = FLOOR_Y
Taxi.SEAT_Y  = 4.2

--------------------------------------------------------------------------------
-- TAXI BUILDER
-- Classic yellow cab based on Sedan with roof light sign.
-- Faces +Z forward, wheels on ground Y=0.
--------------------------------------------------------------------------------
function Taxi.build(modelName)
	modelName = modelName or "Taxi_1"

	local model = Instance.new("Model")
	model.Name = modelName

	---------------------------------------------------------------------------
	-- Dimensions (same as Sedan)
	---------------------------------------------------------------------------
	local wheelR     = 1.5
	local wheelW     = 1.0
	local halfW      = 3.5
	local bodyW      = halfW * 2

	local frontEndZ  =  7.5
	local rearEndZ   = -7.5
	local cabFrontZ  =  2.5
	local cabRearZ   = -4.0
	local trunkRearZ = -6.5

	local frontAxleZ =  5.0
	local rearAxleZ  = -5.0

	local floorY     = FLOOR_Y
	local beltY      = floorY + 2.0
	local winH       = 2.7
	local winTopY    = beltY + winH
	local roofY      = winTopY + 0.3
	local lowerH     = beltY - floorY

	local cabLen     = cabFrontZ - cabRearZ
	local cabMidZ    = (cabFrontZ + cabRearZ) / 2
	local bPillarZ   = -0.8

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
	-- 2. LOWER BODY (all yellow)
	---------------------------------------------------------------------------
	local doorThick = 0.5

	-- FRONT BODY (hood/engine area)
	local frontBodyLen = frontEndZ - cabFrontZ
	local chassis = VU.part(model, "Chassis",
		Vector3.new(bodyW, lowerH, frontBodyLen),
		CFrame.new(0, floorY + lowerH / 2, cabFrontZ + frontBodyLen / 2),
		C_YELLOW, Enum.Material.SmoothPlastic)

	-- REAR BODY (trunk area)
	local rearBodyLen = cabRearZ - rearEndZ
	VU.part(model, "RearBody",
		Vector3.new(bodyW, lowerH, rearBodyLen),
		CFrame.new(0, floorY + lowerH / 2, (cabRearZ + rearEndZ) / 2),
		C_YELLOW, Enum.Material.SmoothPlastic)

	-- DOOR PANELS (yellow)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "DoorPanel",
			Vector3.new(doorThick, lowerH, cabLen),
			CFrame.new(sx * (halfW - doorThick / 2), floorY + lowerH / 2, cabMidZ),
			C_YELLOW, Enum.Material.SmoothPlastic)
	end

	-- CABIN FLOOR
	VU.part(model, "CabinFloor",
		Vector3.new(bodyW - doorThick * 2, 0.15, cabLen),
		CFrame.new(0, floorY + 0.08, cabMidZ),
		C_INTERIOR, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- 3. HOOD
	---------------------------------------------------------------------------
	local hoodLen = frontEndZ - cabFrontZ - 0.5
	VU.part(model, "Hood",
		Vector3.new(bodyW - 0.4, 0.25, hoodLen),
		CFrame.new(0, beltY + 0.12, cabFrontZ + 0.25 + hoodLen / 2),
		C_YELLOW, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- 4. FRONT NOSE
	---------------------------------------------------------------------------
	local noseRise = beltY + 0.25 - (floorY + 0.6)
	VU.wedge(model, "FrontNose",
		Vector3.new(bodyW - 0.4, noseRise, 1.5),
		CFrame.new(0, floorY + 0.6 + noseRise / 2, frontEndZ + 0.25)
			* CFrame.Angles(0, math.rad(180), 0),
		C_YELLOW, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- 5. FRONT BUMPER + GRILLE + LIGHTS
	---------------------------------------------------------------------------
	VU.part(model, "FrontBumper",
		Vector3.new(bodyW + 0.2, 1.0, 0.5),
		CFrame.new(0, floorY + 0.3, frontEndZ + 0.3),
		C_CHROME, Enum.Material.SmoothPlastic)

	VU.part(model, "Grille",
		Vector3.new(4.0, 1.2, 0.2),
		CFrame.new(0, floorY + 1.0, frontEndZ + 0.5),
		C_TRIM, Enum.Material.SmoothPlastic)

	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Headlight",
			Vector3.new(1.2, 0.9, 0.2),
			CFrame.new(sx * 2.8, floorY + 1.2, frontEndZ + 0.5),
			C_HEADLIGHT, Enum.Material.Neon)
	end

	---------------------------------------------------------------------------
	-- 6. CABIN SHELL — roof, pillars, windows
	---------------------------------------------------------------------------
	-- ROOF (yellow)
	VU.part(model, "Roof",
		Vector3.new(bodyW, roofY - winTopY, cabLen + 0.6),
		CFrame.new(0, winTopY + (roofY - winTopY) / 2, cabMidZ),
		C_YELLOW, Enum.Material.SmoothPlastic)

	-- WINDSHIELD
	local wsg = VU.part(model, "Windshield",
		Vector3.new(bodyW - 0.6, winH, 0.15),
		CFrame.new(0, beltY + winH / 2, cabFrontZ + 0.1)
			* CFrame.Angles(math.rad(-12), 0, 0),
		C_GLASS, Enum.Material.Glass)
	wsg.Transparency = 0.4

	-- REAR WINDOW
	local rwg = VU.part(model, "RearWindow",
		Vector3.new(bodyW - 0.8, winH - 0.3, 0.15),
		CFrame.new(0, beltY + (winH - 0.3) / 2 + 0.15, cabRearZ)
			* CFrame.Angles(math.rad(10), 0, 0),
		C_GLASS, Enum.Material.Glass)
	rwg.Transparency = 0.4

	-- Rear window frame
	VU.part(model, "RearWinFrame",
		Vector3.new(bodyW, 0.3, 0.2),
		CFrame.new(0, beltY + 0.15, cabRearZ),
		C_YELLOW, Enum.Material.SmoothPlastic)

	-- A-PILLARS
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "APillar",
			Vector3.new(0.25, winH, 0.25),
			CFrame.new(sx * (halfW - 0.12), beltY + winH / 2, cabFrontZ),
			C_TRIM, Enum.Material.SmoothPlastic)
	end

	-- C-PILLARS
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "CPillar",
			Vector3.new(0.3, winH, 0.3),
			CFrame.new(sx * (halfW - 0.15), beltY + winH / 2, cabRearZ),
			C_YELLOW, Enum.Material.SmoothPlastic)
	end

	---------------------------------------------------------------------------
	-- 7. SIDE WINDOWS
	---------------------------------------------------------------------------
	local pillarW = 0.3

	for _, sx in ipairs({-1, 1}) do
		-- Front side window
		local fwFrontZ = cabFrontZ - 0.2
		local fwRearZ  = bPillarZ + pillarW/2
		local fwLen    = fwFrontZ - fwRearZ
		local fwCenterZ = (fwFrontZ + fwRearZ) / 2
		local fwg = VU.part(model, "SideWinFront",
			Vector3.new(0.15, winH, fwLen),
			CFrame.new(sx * halfW, beltY + winH / 2, fwCenterZ),
			C_GLASS, Enum.Material.Glass)
		fwg.Transparency = 0.4

		-- Rear side window
		local rwFrontZ = bPillarZ - pillarW/2
		local rwRearZ  = cabRearZ + 0.2
		local rwLen    = rwFrontZ - rwRearZ
		local rwCenterZ = (rwFrontZ + rwRearZ) / 2
		local rwsg2 = VU.part(model, "SideWinRear",
			Vector3.new(0.15, winH, rwLen),
			CFrame.new(sx * halfW, beltY + winH / 2, rwCenterZ),
			C_GLASS, Enum.Material.Glass)
		rwsg2.Transparency = 0.4

		-- B-PILLAR
		VU.part(model, "BPillar",
			Vector3.new(0.2, winH, pillarW),
			CFrame.new(sx * halfW, beltY + winH / 2, bPillarZ),
			C_TRIM, Enum.Material.SmoothPlastic)
	end

	---------------------------------------------------------------------------
	-- 8. TRUNK
	---------------------------------------------------------------------------
	local trunkLen = cabRearZ - trunkRearZ
	local trunkH = 0.6
	VU.part(model, "Trunk",
		Vector3.new(bodyW - 0.4, trunkH, trunkLen),
		CFrame.new(0, beltY + trunkH / 2, cabRearZ - trunkLen / 2),
		C_YELLOW, Enum.Material.SmoothPlastic)

	local rearSlopeRise = beltY + trunkH - (floorY + 0.8)
	VU.wedge(model, "RearSlope",
		Vector3.new(bodyW - 0.4, rearSlopeRise, rearEndZ - trunkRearZ + 1.0),
		CFrame.new(0, floorY + 0.8 + rearSlopeRise / 2, trunkRearZ - 0.5),
		C_YELLOW, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- 9. REAR BUMPER + TAILLIGHTS
	---------------------------------------------------------------------------
	VU.part(model, "RearBumper",
		Vector3.new(bodyW + 0.2, 0.8, 0.4),
		CFrame.new(0, floorY + 0.2, rearEndZ - 0.2),
		C_CHROME, Enum.Material.SmoothPlastic)

	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Taillight",
			Vector3.new(1.4, 0.7, 0.2),
			CFrame.new(sx * 2.2, floorY + 1.2, rearEndZ - 0.2),
			C_TAILLIGHT, Enum.Material.Neon)
	end

	---------------------------------------------------------------------------
	-- 10. TAXI ROOF SIGN
	---------------------------------------------------------------------------
	local signY = roofY + 0.4
	local signZ = cabMidZ + 0.5

	-- Sign base
	VU.part(model, "TaxiSignBase",
		Vector3.new(0.6, 0.2, 0.6),
		CFrame.new(0, roofY + 0.1, signZ),
		C_TRIM, Enum.Material.SmoothPlastic)

	-- Sign box (cream/off-white, not neon)
	VU.part(model, "TaxiSign",
		Vector3.new(2.4, 0.8, 1.0),
		CFrame.new(0, signY + 0.3, signZ),
		Color3.fromRGB(245, 235, 200), Enum.Material.SmoothPlastic)

	-- Black band across sign (like "TAXI" text area)
	VU.part(model, "TaxiSignBand",
		Vector3.new(2.0, 0.25, 1.02),
		CFrame.new(0, signY + 0.3, signZ),
		C_TRIM, Enum.Material.SmoothPlastic)

	-- Top and bottom trim lines
	VU.part(model, "TaxiSignTrimTop",
		Vector3.new(2.4, 0.08, 1.02),
		CFrame.new(0, signY + 0.65, signZ),
		C_TRIM, Enum.Material.SmoothPlastic)
	VU.part(model, "TaxiSignTrimBot",
		Vector3.new(2.4, 0.08, 1.02),
		CFrame.new(0, signY - 0.05, signZ),
		C_TRIM, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- 11. SIDE MIRRORS
	---------------------------------------------------------------------------
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Mirror",
			Vector3.new(0.5, 0.35, 0.7),
			CFrame.new(sx * (halfW + 0.35), beltY + 0.8, cabFrontZ - 0.3),
			C_TRIM, Enum.Material.Plastic)
	end

	---------------------------------------------------------------------------
	-- Finalize
	---------------------------------------------------------------------------
	model.PrimaryPart = chassis
	return model
end

return Taxi
