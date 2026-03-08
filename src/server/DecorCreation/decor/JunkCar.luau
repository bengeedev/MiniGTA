-- JunkCar: procedural junk car builder for junkyard/parking decor.
-- Builds 5 variants based on sedan/wagon/SUV silhouettes with rusted look,
-- missing wheels, broken windows, missing hood/trunk panels.
-- Replaces the imported Junkcar_1..5 DecorTemplates.

local JunkCar = {}

--------------------------------------------------------------------------------
-- Helpers (inline, no dependency on VehicleUtils which lives in ProceduralVehicles)
--------------------------------------------------------------------------------
local function makePart(parent, name, size, cf, color, material)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.CorrodedMetal
	p.Anchored = true
	p.CanCollide = false
	p.Parent = parent
	return p
end

local function makeCylinder(parent, name, size, cf, color, material)
	local p = makePart(parent, name, size, cf, color, material)
	p.Shape = Enum.PartType.Cylinder
	return p
end

local function makeWedge(parent, name, size, cf, color, material)
	local w = Instance.new("WedgePart")
	w.Name = name
	w.Size = size
	w.CFrame = cf
	w.Color = color
	w.Material = material or Enum.Material.CorrodedMetal
	w.Anchored = true
	w.CanCollide = false
	w.Parent = parent
	return w
end

--------------------------------------------------------------------------------
-- Rust palette: faded, dirty colors
--------------------------------------------------------------------------------
local RUST_BODIES = {
	Color3.fromRGB(120, 80, 50),   -- rusty brown
	Color3.fromRGB(90, 95, 80),    -- faded green
	Color3.fromRGB(140, 110, 70),  -- dirty tan
	Color3.fromRGB(100, 70, 60),   -- dark rust
	Color3.fromRGB(80, 80, 90),    -- faded blue-grey
	Color3.fromRGB(130, 90, 65),   -- copper rust
	Color3.fromRGB(110, 100, 80),  -- olive drab
	Color3.fromRGB(95, 60, 50),    -- deep rust
}
local C_RUST_DARK   = Color3.fromRGB(60, 45, 35)
local C_RUST_METAL  = Color3.fromRGB(80, 75, 70)
local C_BROKEN_GLASS = Color3.fromRGB(70, 80, 70)
local C_RUBBER      = Color3.fromRGB(30, 30, 30)
local C_GROUND      = Color3.fromRGB(50, 45, 40)
local C_HEADLIGHT   = Color3.fromRGB(100, 105, 95)   -- dead/dirty headlight glass
local C_TAILLIGHT   = Color3.fromRGB(90, 30, 25)     -- faded red taillight

--------------------------------------------------------------------------------
-- Car shape definitions: { halfW, frontEndZ, rearEndZ, cabFrontZ, cabRearZ,
--                          floorY, beltY, roofY, hasWagon, label }
-- All face +Z, wheels at ground Y=0.
--------------------------------------------------------------------------------
local SHAPES = {
	-- 1: sedan (compact, low)
	{
		halfW = 3.2, frontEndZ = 7.0, rearEndZ = -7.0,
		cabFrontZ = 2.0, cabRearZ = -3.5,
		floorY = 1.5, beltY = 3.3, roofY = 6.0,
		hasWagon = false, label = "Junkcar_1",
	},
	-- 2: station wagon (long, boxy rear)
	{
		halfW = 3.5, frontEndZ = 7.5, rearEndZ = -8.5,
		cabFrontZ = 2.5, cabRearZ = -7.0,
		floorY = 1.8, beltY = 3.8, roofY = 6.5,
		hasWagon = true, label = "Junkcar_2",
	},
	-- 3: SUV / crossover (tall, wide)
	{
		halfW = 3.8, frontEndZ = 7.5, rearEndZ = -7.5,
		cabFrontZ = 2.0, cabRearZ = -5.5,
		floorY = 2.2, beltY = 4.2, roofY = 7.2,
		hasWagon = true, label = "Junkcar_3",
	},
	-- 4: small hatchback (short, stubby)
	{
		halfW = 3.0, frontEndZ = 5.5, rearEndZ = -5.5,
		cabFrontZ = 1.5, cabRearZ = -4.0,
		floorY = 1.5, beltY = 3.2, roofY = 5.8,
		hasWagon = false, label = "Junkcar_4",
	},
	-- 5: van / minivan (tall, long, boxy)
	{
		halfW = 3.5, frontEndZ = 8.0, rearEndZ = -8.0,
		cabFrontZ = 3.5, cabRearZ = -7.0,
		floorY = 2.0, beltY = 4.0, roofY = 7.5,
		hasWagon = true, label = "Junkcar_5",
	},
}

--------------------------------------------------------------------------------
-- Build a single junk car variant (1-5).
-- Returns a Model with PrimaryPart set, positioned at origin facing +Z.
--------------------------------------------------------------------------------
function JunkCar.build(variant, placementSeed)
	variant = math.clamp(variant or 1, 1, #SHAPES)
	local S = SHAPES[variant]

	-- Unique random per placement (different seed = different rust color, damage, etc.)
	local seed = (placementSeed or 0) * 997 + variant * 137
	local rng = Random.new(seed)

	local bodyColor = RUST_BODIES[rng:NextInteger(1, #RUST_BODIES)]

	local model = Instance.new("Model")
	model.Name = S.label

	local halfW     = S.halfW
	local bodyW     = halfW * 2
	local frontEndZ = S.frontEndZ
	local rearEndZ  = S.rearEndZ
	local cabFrontZ = S.cabFrontZ
	local cabRearZ  = S.cabRearZ
	local floorY    = S.floorY
	local beltY     = S.beltY
	local roofY     = S.roofY
	local lowerH    = beltY - floorY
	local winH      = roofY - beltY - 0.3
	local winTopY   = beltY + winH

	------------------------------------------------------------------------
	-- 1. FLAT TIRES or MISSING WHEELS (cinder blocks)
	-- Some wheels are flat tires, others are missing (just a cinder block)
	------------------------------------------------------------------------
	local frontAxleZ = frontEndZ - 2.5
	local rearAxleZ  = rearEndZ + 2.5
	local wheelPositions = {
		{ x = -halfW, z = frontAxleZ },
		{ x =  halfW, z = frontAxleZ },
		{ x = -halfW, z = rearAxleZ  },
		{ x =  halfW, z = rearAxleZ  },
	}

	for _, wp in ipairs(wheelPositions) do
		local roll = rng:NextInteger(0, 2)  -- 0=flat tire, 1=missing (block), 2=missing (nothing)
		if roll == 0 then
			-- Flat tire: squished, sagging
			makeCylinder(model, "FlatTire",
				Vector3.new(1.0, 2.8, 2.8),
				CFrame.new(wp.x, 0.8, wp.z),
				C_RUBBER, Enum.Material.SmoothPlastic)
		elseif roll == 1 then
			-- Cinder block where wheel was
			makePart(model, "CinderBlock",
				Vector3.new(1.2, 0.8, 1.8),
				CFrame.new(wp.x, 0.4, wp.z),
				Color3.fromRGB(120, 115, 110), Enum.Material.Concrete)
		end
		-- roll == 2: nothing, just missing
	end

	------------------------------------------------------------------------
	-- 2. LOWER BODY (always present — this is the main car shape)
	------------------------------------------------------------------------
	-- Front body (engine bay)
	local frontBodyLen = frontEndZ - cabFrontZ
	local chassis = makePart(model, "Chassis",
		Vector3.new(bodyW, lowerH, frontBodyLen),
		CFrame.new(0, floorY + lowerH / 2, cabFrontZ + frontBodyLen / 2),
		bodyColor)

	-- Rear body
	local rearBodyLen = cabRearZ - rearEndZ
	makePart(model, "RearBody",
		Vector3.new(bodyW, lowerH, rearBodyLen),
		CFrame.new(0, floorY + lowerH / 2, (cabRearZ + rearEndZ) / 2),
		bodyColor)

	-- Side panels (doors) — slight dent/bow outward on random side
	local cabLen = cabFrontZ - cabRearZ
	local cabMidZ = (cabFrontZ + cabRearZ) / 2
	for _, sx in ipairs({-1, 1}) do
		local dentAngle = rng:NextNumber(-0.03, 0.03)  -- subtle bow
		local dentOffset = rng:NextNumber(-0.15, 0.15)  -- slight push in/out
		makePart(model, "DoorPanel",
			Vector3.new(0.5, lowerH, cabLen),
			CFrame.new(sx * (halfW - 0.25 + dentOffset), floorY + lowerH / 2, cabMidZ)
				* CFrame.Angles(0, 0, dentAngle),
			bodyColor)
	end

	------------------------------------------------------------------------
	-- 3. HOOD (randomly missing or ajar)
	------------------------------------------------------------------------
	local hoodLen = frontEndZ - cabFrontZ - 0.5
	local hoodState = rng:NextInteger(0, 2)  -- 0=present, 1=ajar (tilted), 2=missing
	if hoodState == 0 then
		makePart(model, "Hood",
			Vector3.new(bodyW - 0.6, 0.2, hoodLen),
			CFrame.new(0, beltY + 0.1, cabFrontZ + 0.25 + hoodLen / 2),
			bodyColor)
	elseif hoodState == 1 then
		-- Hood popped open (tilted up at front)
		makePart(model, "Hood",
			Vector3.new(bodyW - 0.6, 0.2, hoodLen),
			CFrame.new(0, beltY + 0.5, cabFrontZ + 0.25 + hoodLen / 2)
				* CFrame.Angles(math.rad(-20), 0, 0),
			bodyColor)
	end
	-- hoodState == 2: missing, show dark engine bay
	if hoodState ~= 0 then
		-- Exposed engine bay (dark interior visible)
		makePart(model, "EngineBay",
			Vector3.new(bodyW - 1.0, 0.3, hoodLen - 0.5),
			CFrame.new(0, beltY - 0.2, cabFrontZ + 0.5 + (hoodLen - 0.5) / 2),
			C_RUST_DARK, Enum.Material.Metal)
	end

	------------------------------------------------------------------------
	-- 4. FRONT BUMPER (dented / hanging)
	------------------------------------------------------------------------
	local bumperTilt = math.rad(rng:NextNumber(-5, 10))
	makePart(model, "FrontBumper",
		Vector3.new(bodyW + 0.2, 0.8, 0.4),
		CFrame.new(0, floorY + 0.2, frontEndZ + 0.2)
			* CFrame.Angles(bumperTilt, 0, 0),
		C_RUST_METAL)

	------------------------------------------------------------------------
	-- 5. CABIN SHELL — roof, pillars, broken windows
	------------------------------------------------------------------------
	-- Roof (always present, maybe dented — slight sag + tilt)
	local roofSag = rng:NextNumber(0, 0.5)
	local roofTiltX = rng:NextNumber(-0.02, 0.02)
	local roofTiltZ = rng:NextNumber(-0.015, 0.015)
	local roofLen = S.hasWagon and (cabFrontZ - rearEndZ + 0.3) or (cabLen + 0.6)
	local roofMidZ = S.hasWagon and ((cabFrontZ + rearEndZ) / 2) or cabMidZ
	makePart(model, "Roof",
		Vector3.new(bodyW, roofY - winTopY - roofSag, roofLen),
		CFrame.new(0, winTopY + (roofY - winTopY - roofSag) / 2, roofMidZ)
			* CFrame.Angles(roofTiltX, 0, roofTiltZ),
		bodyColor)

	-- A-pillars
	for _, sx in ipairs({-1, 1}) do
		makePart(model, "APillar",
			Vector3.new(0.25, winH, 0.25),
			CFrame.new(sx * (halfW - 0.12), beltY + winH / 2, cabFrontZ),
			C_RUST_DARK)
	end

	-- C-pillars / rear pillars
	local rearPillarZ = S.hasWagon and (rearEndZ + 0.3) or cabRearZ
	for _, sx in ipairs({-1, 1}) do
		makePart(model, "CPillar",
			Vector3.new(0.25, winH, 0.25),
			CFrame.new(sx * (halfW - 0.12), beltY + winH / 2, rearPillarZ),
			C_RUST_DARK)
	end

	------------------------------------------------------------------------
	-- 6. WINDOWS — broken jagged remnants, cracked panes, or missing
	------------------------------------------------------------------------
	-- Windshield: 0=full cracked, 1=missing, 2=bottom-half remnant, 3=diagonal shard
	local wsState = rng:NextInteger(0, 3)
	if wsState == 0 then
		-- Full cracked pane (dirty, low transparency)
		local ws = makePart(model, "Windshield",
			Vector3.new(bodyW - 0.6, winH, 0.15),
			CFrame.new(0, beltY + winH / 2, cabFrontZ + 0.1)
				* CFrame.Angles(math.rad(-12), 0, 0),
			C_BROKEN_GLASS, Enum.Material.Glass)
		ws.Transparency = 0.2
	elseif wsState == 2 then
		-- Bottom half remnant
		local remnantH = winH * 0.45
		local ws = makePart(model, "Windshield",
			Vector3.new(bodyW - 0.6, remnantH, 0.15),
			CFrame.new(0, beltY + remnantH / 2, cabFrontZ + 0.1)
				* CFrame.Angles(math.rad(-12), 0, 0),
			C_BROKEN_GLASS, Enum.Material.Glass)
		ws.Transparency = 0.2
	elseif wsState == 3 then
		-- Diagonal shard (wedge) remaining on one side
		local shardSide = rng:NextInteger(0, 1) == 0 and -1 or 1
		local shardW = (bodyW - 0.6) * 0.55
		makeWedge(model, "WindshieldShard",
			Vector3.new(shardW, winH * 0.7, 0.15),
			CFrame.new(shardSide * shardW * 0.3, beltY + winH * 0.35, cabFrontZ + 0.1)
				* CFrame.Angles(math.rad(-12), shardSide > 0 and 0 or math.rad(180), 0),
			C_BROKEN_GLASS, Enum.Material.Glass)
	end
	-- wsState == 1: fully missing

	-- Rear window: same variety
	local rwState = rng:NextInteger(0, 3)
	local rearWinZ = S.hasWagon and (rearEndZ + 0.08) or cabRearZ
	if rwState == 0 then
		local rw = makePart(model, "RearWindow",
			Vector3.new(bodyW - 1.0, winH - 0.3, 0.15),
			CFrame.new(0, beltY + (winH - 0.3) / 2 + 0.15, rearWinZ)
				* CFrame.Angles(math.rad(8), 0, 0),
			C_BROKEN_GLASS, Enum.Material.Glass)
		rw.Transparency = 0.25
	elseif rwState == 2 then
		local remnantH = (winH - 0.3) * 0.4
		local rw = makePart(model, "RearWindow",
			Vector3.new(bodyW - 1.0, remnantH, 0.15),
			CFrame.new(0, beltY + remnantH / 2 + 0.15, rearWinZ)
				* CFrame.Angles(math.rad(8), 0, 0),
			C_BROKEN_GLASS, Enum.Material.Glass)
		rw.Transparency = 0.25
	elseif rwState == 3 then
		local shardSide = rng:NextInteger(0, 1) == 0 and -1 or 1
		local shardW = (bodyW - 1.0) * 0.5
		makeWedge(model, "RearWindowShard",
			Vector3.new(shardW, (winH - 0.3) * 0.6, 0.15),
			CFrame.new(shardSide * shardW * 0.25, beltY + (winH - 0.3) * 0.3 + 0.15, rearWinZ)
				* CFrame.Angles(math.rad(8), shardSide > 0 and 0 or math.rad(180), 0),
			C_BROKEN_GLASS, Enum.Material.Glass)
	end

	-- Side windows: per-side, 0=full cracked, 1=bottom strip, 2=missing, 3=corner shard
	for _, sx in ipairs({-1, 1}) do
		local sideState = rng:NextInteger(0, 3)
		local sideWinW = cabLen * 0.7
		if sideState == 0 then
			local sw = makePart(model, "SideWindow",
				Vector3.new(0.15, winH - 0.3, sideWinW),
				CFrame.new(sx * halfW, beltY + winH / 2, cabMidZ),
				C_BROKEN_GLASS, Enum.Material.Glass)
			sw.Transparency = 0.25
		elseif sideState == 1 then
			-- Bottom strip only
			local stripH = (winH - 0.3) * 0.35
			local sw = makePart(model, "SideWindow",
				Vector3.new(0.15, stripH, sideWinW),
				CFrame.new(sx * halfW, beltY + stripH / 2, cabMidZ),
				C_BROKEN_GLASS, Enum.Material.Glass)
			sw.Transparency = 0.2
		elseif sideState == 3 then
			-- Corner triangle shard
			makeWedge(model, "SideWindowShard",
				Vector3.new(0.15, (winH - 0.3) * 0.5, sideWinW * 0.5),
				CFrame.new(sx * halfW, beltY + (winH - 0.3) * 0.25, cabMidZ - sideWinW * 0.15)
					* CFrame.Angles(0, sx > 0 and 0 or math.rad(180), 0),
				C_BROKEN_GLASS, Enum.Material.Glass)
		end
		-- sideState == 2: fully missing
	end

	------------------------------------------------------------------------
	-- 7. HEADLIGHTS (dead glass blocks, some broken/missing)
	------------------------------------------------------------------------
	local hlY = floorY + lowerH * 0.55
	local hlW = 1.2
	local hlH = 0.8
	local hlD = 0.3
	for _, sx in ipairs({-1, 1}) do
		local hlState = rng:NextInteger(0, 3)  -- 0=intact dead, 1=cracked, 2=missing, 3=half-broken
		local hlX = sx * (halfW - hlW * 0.6)
		local hlZ = frontEndZ + hlD / 2 + 0.05
		if hlState == 0 then
			-- Intact but dead (dirty glass block)
			local hl = makePart(model, "Headlight",
				Vector3.new(hlW, hlH, hlD),
				CFrame.new(hlX, hlY, hlZ),
				C_HEADLIGHT, Enum.Material.Glass)
			hl.Transparency = 0.15
		elseif hlState == 1 then
			-- Cracked (opaque, darker)
			makePart(model, "Headlight",
				Vector3.new(hlW, hlH, hlD),
				CFrame.new(hlX, hlY, hlZ),
				Color3.fromRGB(70, 75, 65), Enum.Material.Glass)
		elseif hlState == 3 then
			-- Half-broken: bottom shard remains
			local shardH = hlH * 0.5
			local hl = makePart(model, "Headlight",
				Vector3.new(hlW, shardH, hlD),
				CFrame.new(hlX, hlY - (hlH - shardH) / 2, hlZ),
				C_HEADLIGHT, Enum.Material.Glass)
			hl.Transparency = 0.1
		end
		-- hlState == 2: missing (empty socket visible)
	end

	------------------------------------------------------------------------
	-- 8. TAILLIGHTS (faded red glass blocks)
	------------------------------------------------------------------------
	local tlY = floorY + lowerH * 0.5
	local tlW = 0.9
	local tlH = 0.6
	local tlD = 0.25
	for _, sx in ipairs({-1, 1}) do
		local tlState = rng:NextInteger(0, 2)  -- 0=intact, 1=cracked, 2=missing
		local tlX = sx * (halfW - tlW * 0.55)
		local tlZ = rearEndZ - tlD / 2 - 0.05
		if tlState == 0 then
			local tl = makePart(model, "Taillight",
				Vector3.new(tlW, tlH, tlD),
				CFrame.new(tlX, tlY, tlZ),
				C_TAILLIGHT, Enum.Material.Glass)
			tl.Transparency = 0.15
		elseif tlState == 1 then
			makePart(model, "Taillight",
				Vector3.new(tlW, tlH, tlD),
				CFrame.new(tlX, tlY, tlZ),
				Color3.fromRGB(60, 20, 18), Enum.Material.Glass)
		end
		-- tlState == 2: missing
	end

	------------------------------------------------------------------------
	-- 9. TRUNK / REAR (sometimes missing on non-wagons)
	------------------------------------------------------------------------
	if not S.hasWagon then
		local trunkState = rng:NextInteger(0, 2)
		if trunkState ~= 2 then
			local trunkLen = cabRearZ - rearEndZ - 1
			local trunkH = 0.5
			makePart(model, "Trunk",
				Vector3.new(bodyW - 0.6, trunkH, trunkLen),
				CFrame.new(0, beltY + trunkH / 2, cabRearZ - trunkLen / 2 - 0.5),
				bodyColor)
		end
	end

	-- Rear bumper (always, but rusty)
	makePart(model, "RearBumper",
		Vector3.new(bodyW + 0.2, 0.6, 0.3),
		CFrame.new(0, floorY + 0.15, rearEndZ - 0.15),
		C_RUST_METAL)

	-- Rear panel (wagon / back wall)
	if S.hasWagon then
		makePart(model, "RearPanel",
			Vector3.new(bodyW, roofY - floorY, 0.25),
			CFrame.new(0, floorY + (roofY - floorY) / 2, rearEndZ + 0.12),
			bodyColor)
	end

	------------------------------------------------------------------------
	-- 10. RUST PATCHES (random darker spots on body)
	------------------------------------------------------------------------
	for _ = 1, rng:NextInteger(2, 5) do
		local patchX = rng:NextNumber(-halfW + 1, halfW - 1)
		local patchZ = rng:NextNumber(rearEndZ + 1, frontEndZ - 1)
		local patchY = floorY + rng:NextNumber(0.5, lowerH)
		makePart(model, "RustPatch",
			Vector3.new(rng:NextNumber(1.5, 3.0), rng:NextNumber(0.8, 1.5), rng:NextNumber(1.5, 3.0)),
			CFrame.new(patchX, patchY, patchZ),
			C_RUST_DARK, Enum.Material.CorrodedMetal)
	end

	------------------------------------------------------------------------
	-- Invisible collision box (monoblock) — prevents player getting stuck
	-- inside detail gaps. All detail parts stay CanCollide = false.
	------------------------------------------------------------------------
	local boxH = roofY - floorY + 0.5
	local boxZ = frontEndZ - rearEndZ + 0.5
	local collisionBox = Instance.new("Part")
	collisionBox.Name = "CollisionBox"
	collisionBox.Size = Vector3.new(bodyW + 0.5, boxH, boxZ)
	collisionBox.CFrame = CFrame.new(0, floorY + boxH / 2, (frontEndZ + rearEndZ) / 2)
	collisionBox.Transparency = 1
	collisionBox.CanCollide = true
	collisionBox.CanQuery = false
	collisionBox.CanTouch = false
	collisionBox.Anchored = true
	collisionBox.Parent = model

	model.PrimaryPart = chassis
	return model
end

return JunkCar
