local VU = require(script.Parent:WaitForChild("VehicleUtils"))

local MonsterTruck = {}

--------------------------------------------------------------------------------
-- MONSTER TRUCK  (faces +Z forward, wheels on ground at Y=0)
-- Massive off-road wheels with pickup truck body sitting HIGH above.
-- Wheel diameter ~16 studs (3x player height).
-- Each wheel is a Model named "WheelXX" so the client spins them.
-- Wheel design based on Convertible pattern, scaled up.
--------------------------------------------------------------------------------

-- Colors
local C_TIRE       = Color3.fromRGB(25, 25, 25)      -- black tire rubber
local C_RIM        = Color3.fromRGB(200, 200, 205)    -- bright silver rim (chrome)
local C_RIM_DARK   = Color3.fromRGB(60, 60, 65)      -- dark rim accent
local C_HUB        = Color3.fromRGB(180, 180, 190)    -- hub center
local C_AXLE       = Color3.fromRGB(40, 40, 45)      -- axle/suspension metal
local C_CHASSIS    = Color3.fromRGB(35, 35, 40)      -- underside frame
local C_GLASS      = Color3.fromRGB(60, 80, 100)     -- windshield tint
local C_HEADLIGHT  = Color3.fromRGB(255, 240, 200)   -- warm headlights
local C_TAILLIGHT  = Color3.fromRGB(200, 20, 15)     -- red taillights
local C_BUMPER     = Color3.fromRGB(70, 70, 75)      -- chrome bumper
local C_GRILLE     = Color3.fromRGB(50, 50, 55)      -- dark grille
local C_BED_FLOOR  = Color3.fromRGB(60, 60, 65)      -- truck bed liner

--------------------------------------------------------------------------------
-- Wheel builder: REAL TORUS tire from individual blocks + chrome rim/spokes.
-- The tire is built from N blocks arranged in a ring = real donut with hole.
-- Tread blocks on the outside add relief texture.
-- side: 1 for right wheel, -1 for left wheel (determines spoke face)
--------------------------------------------------------------------------------
local TIRE_SEGMENTS = 16   -- how many blocks form the tire ring
local TREAD_PER_SEG = 1    -- tread blocks per tire segment

local function buildWheel(parent, cx, cz, wheelR, wheelW, label, side)
	local wheelY = wheelR  -- center at radius so bottom touches Y=0

	-- Tire torus geometry
	local tireMinorR = 2.0                   -- tube cross-section radius (how fat the rubber is)
	local tireMajorR = wheelR - tireMinorR   -- center of tube ring (6.0 for wheelR=8)
	local rimOuterR  = tireMajorR - 0.2      -- rim sits just inside the tire ring

	local wheelModel = Instance.new("Model")
	wheelModel.Name = label

	-- Calculate segment arc length for block sizing
	local segAngle = (math.pi * 2) / TIRE_SEGMENTS
	local segArcLen = 2 * math.pi * tireMajorR / TIRE_SEGMENTS

	--------------------------------------------------------------------
	-- TIRE: ring of blocks forming a torus (real donut with hole!)
	--------------------------------------------------------------------
	local primaryPart = nil
	for i = 0, TIRE_SEGMENTS - 1 do
		local angle = (i / TIRE_SEGMENTS) * math.pi * 2
		local segCF = CFrame.new(cx, wheelY, cz)
			* CFrame.Angles(angle, 0, 0)         -- rotate around X-axis (wheel axis)
			* CFrame.new(0, tireMajorR, 0)        -- offset to ring position
		local seg = VU.part(wheelModel, "TireSeg",
			Vector3.new(wheelW, tireMinorR * 2, segArcLen + 0.3),  -- +0.3 overlap to seal gaps
			segCF,
			C_TIRE, Enum.Material.Rubber)

		-- Use first segment as PrimaryPart (for rotation center)
		if i == 0 then
			primaryPart = seg
		end

		-- TREAD BLOCKS: raised bumps on the outer surface for relief
		local treadCF = CFrame.new(cx, wheelY, cz)
			* CFrame.Angles(angle + segAngle * 0.5, 0, 0)  -- offset half-step
			* CFrame.new(0, tireMajorR + tireMinorR * 0.75, 0)
		VU.part(wheelModel, "Tread",
			Vector3.new(wheelW * 0.8, 0.6, segArcLen * 0.5),
			treadCF,
			Color3.fromRGB(35, 35, 38), Enum.Material.Rubber)
	end

	--------------------------------------------------------------------
	-- RIM: chrome disc + spokes (on outer face, NO overlapping = no flicker)
	--------------------------------------------------------------------
	local rimX = cx + (wheelW / 2 + 0.15) * side  -- slightly OUTSIDE the tire face

	-- Rim outer ring (thin chrome ring at the tire inner edge)
	-- Built from blocks to match the torus hole
	local rimRingSegs = 20
	local rimRingArc = 2 * math.pi * rimOuterR / rimRingSegs
	for i = 0, rimRingSegs - 1 do
		local angle = (i / rimRingSegs) * math.pi * 2
		local ringCF = CFrame.new(rimX, wheelY, cz)
			* CFrame.Angles(angle, 0, 0)           -- rotate around X-axis (wheel axis)
			* CFrame.new(0, rimOuterR, 0)
		VU.part(wheelModel, "RimRing",
			Vector3.new(0.3, 0.5, rimRingArc + 0.1),
			ringCF,
			C_RIM, Enum.Material.Metal)
	end

	-- 5 SPOKES: thick bars from center to rim ring (placed OUTSIDE tire = no Z-fight)
	local spokeCount = 5
	local spokeLen = rimOuterR - 1.2  -- from hub edge to near rim ring
	for i = 0, spokeCount - 1 do
		local angle = (i / spokeCount) * math.pi * 2
		local spokeCF = CFrame.new(rimX, wheelY, cz)
			* CFrame.Angles(angle, 0, 0)            -- rotate around X-axis (wheel axis)
			* CFrame.new(0, spokeLen / 2 + 0.8, 0)  -- offset from center
		VU.part(wheelModel, "Spoke" .. i,
			Vector3.new(0.5, spokeLen, 1.2),
			spokeCF,
			C_RIM, Enum.Material.Metal)
	end

	-- CENTER HUB (chrome disc at the very center)
	VU.cylinder(wheelModel, "Hub",
		Vector3.new(0.6, 2.5, 2.5),
		CFrame.new(rimX + side * 0.1, wheelY, cz),
		C_HUB, Enum.Material.Metal)

	--------------------------------------------------------------------
	-- Set PrimaryPart for spinning (needs to be at wheel center)
	-- Create an invisible anchor part at wheel center for clean rotation
	--------------------------------------------------------------------
	local anchor = Instance.new("Part")
	anchor.Name = "WheelCenter"
	anchor.Size = Vector3.new(0.1, 0.1, 0.1)
	anchor.CFrame = CFrame.new(cx, wheelY, cz)
	anchor.Transparency = 1
	anchor.CanCollide = false
	anchor.Anchored = true
	anchor.Parent = wheelModel
	wheelModel.PrimaryPart = anchor

	wheelModel.Parent = parent
	return wheelModel
end

--------------------------------------------------------------------------------
-- Main build function
--------------------------------------------------------------------------------
function MonsterTruck.build(modelName, bodyColor)
	bodyColor = bodyColor or Color3.fromRGB(230, 200, 40)  -- default yellow

	local model = Instance.new("Model")
	model.Name = modelName or "Monstertruck_1"

	-- Wheel dimensions (massive — 3x player height)
	local wheelR  = 8.0     -- radius = 8 studs → diameter 16
	local wheelW  = 5.0     -- tire width

	-- Track width — wheels just past the body edges (slight overhang)
	local trackHW = 9.0     -- half-track width (center to wheel center)

	-- Axle positions — spread apart so wheels don't touch (24 stud gap, 8 between edges)
	local frontAxleZ = 12.0
	local rearAxleZ  = -12.0

	-- Body sits high — floor near wheel top, tall body panels
	local floorY   = wheelR * 2 - 2   -- 14 studs — near top of wheels
	local beltY    = floorY + 5.0     -- 19 — window sill (5 studs of body side)
	local roofY    = beltY + 4.5      -- 23.5 — roof top
	local bodyW    = 12.0             -- body width (fills between wheels)
	local halfBW   = bodyW / 2

	-- Body Z extents — longer to match wider wheelbase
	local frontEndZ = 14.0
	local rearEndZ  = -15.0
	local cabFrontZ = 6.0
	local cabRearZ  = -2.0

	------------------------------------------------------------------------
	-- 1. WHEELS (4 massive wheels with chrome spoked rims)
	------------------------------------------------------------------------
	buildWheel(model, -trackHW, frontAxleZ, wheelR, wheelW, "WheelFL", -1)
	buildWheel(model,  trackHW, frontAxleZ, wheelR, wheelW, "WheelFR",  1)
	buildWheel(model, -trackHW, rearAxleZ,  wheelR, wheelW, "WheelRL", -1)
	buildWheel(model,  trackHW, rearAxleZ,  wheelR, wheelW, "WheelRR",  1)

	------------------------------------------------------------------------
	-- 2. SUSPENSION / FRAME
	------------------------------------------------------------------------
	-- Front and rear axle beams (spanning the wide track)
	for _, az in ipairs({frontAxleZ, rearAxleZ}) do
		VU.part(model, "Axle",
			Vector3.new(trackHW * 2 + 2, 1.2, 1.2),
			CFrame.new(0, wheelR, az),
			C_AXLE, Enum.Material.DiamondPlate)
	end

	-- Suspension arms (angled from axle up to body, visible through gap)
	local frameY = floorY - 0.6
	for _, az in ipairs({frontAxleZ, rearAxleZ}) do
		for _, sx in ipairs({-1, 1}) do
			-- Outer arm (from wheel area up to body edge)
			local armBottomX = sx * (trackHW * 0.6)
			local armTopX = sx * (halfBW - 1)
			local armLen = math.sqrt((floorY - wheelR)^2 + (armTopX - armBottomX)^2)
			local armAngle = math.atan2(armTopX - armBottomX, floorY - wheelR)
			VU.part(model, "SuspArm",
				Vector3.new(0.8, armLen, 0.8),
				CFrame.new((armBottomX + armTopX) / 2, (wheelR + floorY) / 2, az)
					* CFrame.Angles(0, 0, -armAngle),
				C_AXLE, Enum.Material.Metal)
		end
	end

	-- Chassis frame rails (under body)
	local frameLen = frontEndZ - rearEndZ
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "FrameRail",
			Vector3.new(1.8, 1.0, frameLen),
			CFrame.new(sx * 3.5, frameY, (frontEndZ + rearEndZ) / 2),
			C_CHASSIS, Enum.Material.DiamondPlate)
	end

	-- Cross members
	for _, cz in ipairs({frontAxleZ, 0, rearAxleZ}) do
		VU.part(model, "CrossMember",
			Vector3.new(bodyW - 2, 0.8, 1.2),
			CFrame.new(0, frameY, cz),
			C_CHASSIS, Enum.Material.DiamondPlate)
	end

	------------------------------------------------------------------------
	-- 3. LOWER BODY (pickup truck shape — sits above the wheels)
	------------------------------------------------------------------------
	local lowerH = beltY - floorY

	-- Engine bay / front body
	local frontBodyLen = frontEndZ - cabFrontZ
	local chassis = VU.part(model, "Chassis",
		Vector3.new(bodyW, lowerH, frontBodyLen),
		CFrame.new(0, floorY + lowerH / 2, cabFrontZ + frontBodyLen / 2),
		bodyColor, Enum.Material.SmoothPlastic)

	-- Cab sides (door panels)
	local cabLen = cabFrontZ - cabRearZ
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "DoorPanel",
			Vector3.new(0.5, lowerH, cabLen),
			CFrame.new(sx * (halfBW - 0.25), floorY + lowerH / 2, (cabFrontZ + cabRearZ) / 2),
			bodyColor, Enum.Material.SmoothPlastic)
	end

	-- Cab floor
	VU.part(model, "CabFloor",
		Vector3.new(bodyW - 1, 0.4, cabLen),
		CFrame.new(0, floorY, (cabFrontZ + cabRearZ) / 2),
		C_CHASSIS, Enum.Material.SmoothPlastic)

	------------------------------------------------------------------------
	-- 4. HOOD
	------------------------------------------------------------------------
	local hoodLen = frontEndZ - cabFrontZ - 0.3
	VU.part(model, "Hood",
		Vector3.new(bodyW - 0.4, 0.3, hoodLen),
		CFrame.new(0, beltY + 0.15, cabFrontZ + 0.15 + hoodLen / 2),
		bodyColor, Enum.Material.SmoothPlastic)

	-- Hood scoop
	VU.part(model, "HoodScoop",
		Vector3.new(2.5, 0.8, 2.5),
		CFrame.new(0, beltY + 0.6, cabFrontZ + hoodLen * 0.4),
		bodyColor, Enum.Material.SmoothPlastic)

	------------------------------------------------------------------------
	-- 5. CABIN (roof, pillars, windshield)
	------------------------------------------------------------------------
	local winH = roofY - beltY - 0.5

	-- Roof
	VU.part(model, "Roof",
		Vector3.new(bodyW - 0.6, 0.5, cabLen + 0.4),
		CFrame.new(0, roofY - 0.25, (cabFrontZ + cabRearZ) / 2),
		bodyColor, Enum.Material.SmoothPlastic)

	-- A-pillars
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "APillar",
			Vector3.new(0.5, winH, 0.5),
			CFrame.new(sx * (halfBW - 0.5), beltY + winH / 2, cabFrontZ),
			bodyColor, Enum.Material.SmoothPlastic)
	end

	-- C-pillars
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "CPillar",
			Vector3.new(0.5, winH, 0.5),
			CFrame.new(sx * (halfBW - 0.5), beltY + winH / 2, cabRearZ),
			bodyColor, Enum.Material.SmoothPlastic)
	end

	-- Rear cab wall
	VU.part(model, "RearCabWall",
		Vector3.new(bodyW - 1.0, winH, 0.4),
		CFrame.new(0, beltY + winH / 2, cabRearZ),
		bodyColor, Enum.Material.SmoothPlastic)

	-- Windshield (angled)
	local ws = VU.part(model, "Windshield",
		Vector3.new(bodyW - 2.0, winH - 0.3, 0.2),
		CFrame.new(0, beltY + winH / 2, cabFrontZ + 0.1)
			* CFrame.Angles(math.rad(-12), 0, 0),
		C_GLASS, Enum.Material.Glass)
	ws.Transparency = 0.3

	-- Rear window
	local rw = VU.part(model, "RearWindow",
		Vector3.new(bodyW - 2.5, winH - 0.8, 0.2),
		CFrame.new(0, beltY + winH / 2, cabRearZ - 0.1)
			* CFrame.Angles(math.rad(5), 0, 0),
		C_GLASS, Enum.Material.Glass)
	rw.Transparency = 0.3

	-- Side windows (on outer face of door panels)
	for _, sx in ipairs({-1, 1}) do
		local sw = VU.part(model, "SideWindow",
			Vector3.new(0.15, winH - 0.5, cabLen * 0.65),
			CFrame.new(sx * (halfBW + 0.08), beltY + winH / 2, (cabFrontZ + cabRearZ) / 2),
			C_GLASS, Enum.Material.Glass)
		sw.Transparency = 0.3
	end

	------------------------------------------------------------------------
	-- 6. TRUCK BED (behind cab)
	------------------------------------------------------------------------
	local bedLen = cabRearZ - rearEndZ
	local bedH = lowerH * 0.7

	-- Bed floor
	VU.part(model, "BedFloor",
		Vector3.new(bodyW - 0.6, 0.4, bedLen),
		CFrame.new(0, floorY, cabRearZ - bedLen / 2),
		C_BED_FLOOR, Enum.Material.DiamondPlate)

	-- Bed side walls
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "BedSide",
			Vector3.new(0.5, bedH, bedLen),
			CFrame.new(sx * (halfBW - 0.25), floorY + bedH / 2, cabRearZ - bedLen / 2),
			bodyColor, Enum.Material.SmoothPlastic)
	end

	-- Tailgate
	VU.part(model, "Tailgate",
		Vector3.new(bodyW - 0.6, bedH, 0.4),
		CFrame.new(0, floorY + bedH / 2, rearEndZ + 0.2),
		bodyColor, Enum.Material.SmoothPlastic)

	-- Bed rail caps
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "BedRailCap",
			Vector3.new(0.6, 0.2, bedLen),
			CFrame.new(sx * (halfBW - 0.25), floorY + bedH + 0.1, cabRearZ - bedLen / 2),
			C_BUMPER, Enum.Material.Metal)
	end

	------------------------------------------------------------------------
	-- 7. FRONT END (grille, bumper, headlights)
	------------------------------------------------------------------------
	VU.part(model, "FrontBumper",
		Vector3.new(bodyW + 0.5, 1.5, 0.8),
		CFrame.new(0, floorY + 0.3, frontEndZ + 0.4),
		C_BUMPER, Enum.Material.Metal)

	VU.part(model, "Grille",
		Vector3.new(bodyW - 2.0, lowerH - 0.5, 0.3),
		CFrame.new(0, floorY + lowerH / 2, frontEndZ + 0.15),
		C_GRILLE, Enum.Material.Metal)

	for i = 0, 3 do
		VU.part(model, "GrilleBar",
			Vector3.new(bodyW - 2.5, 0.15, 0.35),
			CFrame.new(0, floorY + 0.8 + i * 0.6, frontEndZ + 0.2),
			C_BUMPER, Enum.Material.Metal)
	end

	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Headlight",
			Vector3.new(1.8, 1.2, 0.3),
			CFrame.new(sx * (halfBW - 1.5), floorY + lowerH / 2, frontEndZ + 0.2),
			C_HEADLIGHT, Enum.Material.Neon)
	end

	------------------------------------------------------------------------
	-- 8. REAR END
	------------------------------------------------------------------------
	VU.part(model, "RearBumper",
		Vector3.new(bodyW + 0.3, 1.2, 0.6),
		CFrame.new(0, floorY + 0.3, rearEndZ - 0.3),
		C_BUMPER, Enum.Material.Metal)

	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Taillight",
			Vector3.new(1.0, 0.8, 0.3),
			CFrame.new(sx * (halfBW - 1.0), floorY + bedH / 2, rearEndZ - 0.15),
			C_TAILLIGHT, Enum.Material.Neon)
	end

	------------------------------------------------------------------------
	-- 9. EXHAUST PIPES (vertical stacks behind cab)
	------------------------------------------------------------------------
	for _, sx in ipairs({-1, 1}) do
		local pipeBottom = floorY - 2
		local pipeTop = roofY + 1
		local pipeH = pipeTop - pipeBottom
		VU.cylinder(model, "ExhaustPipe",
			Vector3.new(pipeH, 1.0, 1.0),
			CFrame.new(sx * (halfBW - 0.3), pipeBottom + pipeH / 2, cabRearZ - 0.8)
				* CFrame.Angles(0, 0, math.rad(90)),
			Color3.fromRGB(55, 55, 60), Enum.Material.Metal)
		VU.cylinder(model, "ExhaustTip",
			Vector3.new(0.5, 1.3, 1.3),
			CFrame.new(sx * (halfBW - 0.3), pipeTop + 0.25, cabRearZ - 0.8)
				* CFrame.Angles(0, 0, math.rad(90)),
			C_BUMPER, Enum.Material.Metal)
	end

	------------------------------------------------------------------------
	-- 10. ROOF LIGHTS (5 marker lights)
	------------------------------------------------------------------------
	local lightBarY = roofY + 0.3
	VU.part(model, "LightBarBase",
		Vector3.new(7, 0.3, 1.2),
		CFrame.new(0, lightBarY, cabFrontZ - 0.3),
		C_CHASSIS, Enum.Material.SmoothPlastic)

	for i = -2, 2 do
		VU.cylinder(model, "RoofLight",
			Vector3.new(0.3, 1.0, 1.0),
			CFrame.new(i * 1.6, lightBarY + 0.4, cabFrontZ - 0.3)
				* CFrame.Angles(0, 0, math.rad(90)),
			C_HEADLIGHT, Enum.Material.Neon)
	end

	------------------------------------------------------------------------
	-- 11. SIDE MIRRORS
	------------------------------------------------------------------------
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Mirror",
			Vector3.new(0.2, 0.7, 1.0),
			CFrame.new(sx * (halfBW + 0.5), beltY + 1.5, cabFrontZ - 0.3),
			C_CHASSIS, Enum.Material.SmoothPlastic)
	end

	------------------------------------------------------------------------
	-- Finalize
	------------------------------------------------------------------------
	model.PrimaryPart = chassis
	return model
end

-- Export seat position constants for NPC seating
-- floorY = 14, seated HRP offset ~2.5, cab center Z = (6 + -2)/2 = 2
MonsterTruck.SEAT_Y = 16.5
MonsterTruck.DRIVER_X = 2.0
MonsterTruck.SEAT_Z = 2.0

return MonsterTruck
