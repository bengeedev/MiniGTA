local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local ConstructionSite = {}

local TERRAIN_TOP = DecorUtils.TERRAIN_TOP

--------------------------------------------------------------------------------
-- LEFT / RIGHT specs
--------------------------------------------------------------------------------

local LEFT_SPEC = {
	companyName  = "MEGA BUILD CO.",
	signColor    = Color3.fromRGB(255, 180, 40),   -- amber
	craneColor   = Color3.fromRGB(230, 120, 30),   -- orange crane
	concreteColor = Color3.fromRGB(170, 160, 145),  -- warm concrete
	steelColor   = Color3.fromRGB(80, 80, 90),      -- dark steel columns
	rebarColor   = Color3.fromRGB(220, 130, 50),    -- orange rebar
	scaffoldColor = Color3.fromRGB(160, 155, 140),   -- warm scaffold
	barrierColor = Color3.fromRGB(255, 140, 30),    -- orange barriers
}

local RIGHT_SPEC = {
	companyName  = "SKYLINE CONSTRUCTION",
	signColor    = Color3.fromRGB(60, 200, 230),    -- cyan
	craneColor   = Color3.fromRGB(220, 190, 40),    -- yellow crane
	concreteColor = Color3.fromRGB(155, 155, 160),   -- cool concrete
	steelColor   = Color3.fromRGB(75, 80, 95),       -- blue-tinted steel
	rebarColor   = Color3.fromRGB(200, 120, 40),     -- darker orange rebar
	scaffoldColor = Color3.fromRGB(150, 150, 155),    -- cool scaffold
	barrierColor = Color3.fromRGB(255, 160, 40),     -- yellow-orange barriers
}

--------------------------------------------------------------------------------
-- Helper: create partially built structure (3 floor slabs + columns + rebar)
--------------------------------------------------------------------------------

local function createStructure(model, cx, cz, scale, spec, baseY, sign_dir)
	local floorW = 16 * scale
	local floorD = 14 * scale
	local floorThick = 0.6 * scale
	local floorSpacing = 8 * scale

	-- Push structure to back of area (crane takes the front)
	local structX = cx + sign_dir * 8 * scale

	-- 3 floor slabs
	for i = 0, 2 do
		local floorY = baseY + i * floorSpacing
		local slab = Instance.new("Part")
		slab.Name = "FloorSlab"
		slab.Size = Vector3.new(floorW, floorThick, floorD)
		slab.Position = Vector3.new(structX, floorY + floorThick / 2, cz)
		slab.Anchored = true
		slab.Material = Enum.Material.Concrete
		slab.Color = spec.concreteColor
		slab.Parent = model
	end

	-- 6 steel columns connecting floors
	local colRadius = 0.5 * scale
	local colH = floorSpacing * 2 + floorThick
	local colPositions = {
		{ -floorW / 2 + 1.5 * scale, -floorD / 2 + 1.5 * scale },
		{  floorW / 2 - 1.5 * scale, -floorD / 2 + 1.5 * scale },
		{ -floorW / 2 + 1.5 * scale,  floorD / 2 - 1.5 * scale },
		{  floorW / 2 - 1.5 * scale,  floorD / 2 - 1.5 * scale },
		{  0, -floorD / 2 + 1.5 * scale },
		{  0,  floorD / 2 - 1.5 * scale },
	}
	for _, cp in ipairs(colPositions) do
		local col = Instance.new("Part")
		col.Name = "SteelColumn"
		col.Shape = Enum.PartType.Cylinder
		col.Size = Vector3.new(colH, colRadius * 2, colRadius * 2)
		col.CFrame = CFrame.new(structX + cp[1], baseY + colH / 2, cz + cp[2])
			* CFrame.Angles(0, 0, math.rad(90))
		col.Anchored = true
		col.Material = Enum.Material.Metal
		col.Color = spec.steelColor
		col.Parent = model
	end

	-- Rebar stubs poking from top floor
	local topFloorY = baseY + 2 * floorSpacing + floorThick
	local rebarH = 3 * scale
	for i = 1, 5 do
		local rebar = Instance.new("Part")
		rebar.Name = "Rebar"
		rebar.Shape = Enum.PartType.Cylinder
		rebar.Size = Vector3.new(rebarH, 0.2 * scale, 0.2 * scale)
		local rx = structX + (i - 3) * 3 * scale
		local rz = cz + (math.random() - 0.5) * floorD * 0.6
		rebar.CFrame = CFrame.new(rx, topFloorY + rebarH / 2, rz)
			* CFrame.Angles(0, 0, math.rad(90))
		rebar.Anchored = true
		rebar.Material = Enum.Material.Neon
		rebar.Color = spec.rebarColor
		rebar.Transparency = 0.2
		rebar.CanCollide = false
		rebar.Parent = model
	end

	return structX, topFloorY
end

--------------------------------------------------------------------------------
-- Helper: scaffolding wrapping road-facing side
--------------------------------------------------------------------------------

local function createScaffolding(model, structX, cz, scale, spec, baseY, sign_dir)
	local scaffW = 16 * scale
	local scaffH = 18 * scale  -- covers ~2.5 levels
	local poleRadius = 0.25 * scale

	-- Road-facing side X
	local scaffX = structX - sign_dir * (8 * scale + 0.5 * scale)

	-- Vertical poles (4 across, 3 levels → 4 poles)
	local poleSpacing = scaffW / 3
	for i = 0, 3 do
		local pz = cz - scaffW / 2 + i * poleSpacing
		local pole = Instance.new("Part")
		pole.Name = "ScaffoldPole"
		pole.Shape = Enum.PartType.Cylinder
		pole.Size = Vector3.new(scaffH, poleRadius * 2, poleRadius * 2)
		pole.CFrame = CFrame.new(scaffX, baseY + scaffH / 2, pz)
			* CFrame.Angles(0, 0, math.rad(90))
		pole.Anchored = true
		pole.Material = Enum.Material.Metal
		pole.Color = spec.scaffoldColor
		pole.Parent = model
	end

	-- Horizontal bars at each level
	for level = 0, 2 do
		local barY = baseY + (level + 1) * 6 * scale
		local bar = Instance.new("Part")
		bar.Name = "ScaffoldBar"
		bar.Size = Vector3.new(0.3 * scale, 0.3 * scale, scaffW)
		bar.Position = Vector3.new(scaffX, barY, cz)
		bar.Anchored = true
		bar.Material = Enum.Material.Metal
		bar.Color = spec.scaffoldColor
		bar.Parent = model

		-- Plank floor at each level
		local plank = Instance.new("Part")
		plank.Name = "ScaffoldPlank"
		plank.Size = Vector3.new(2 * scale, 0.2 * scale, scaffW)
		plank.Position = Vector3.new(scaffX, barY + 0.1 * scale, cz)
		plank.Anchored = true
		plank.Material = Enum.Material.Wood
		plank.Color = Color3.fromRGB(160, 120, 70)
		plank.Parent = model
	end
end

--------------------------------------------------------------------------------
-- Helper: tower crane with animated boom
--------------------------------------------------------------------------------

local function createTowerCrane(model, cx, cz, scale, spec, baseY, sign_dir)
	-- Push crane to front of area (near road) so it's visible
	local craneX = cx - sign_dir * 10 * scale
	local craneZ = cz

	local blackStripe = Color3.fromRGB(30, 30, 30)

	--------------------------------------------------------------------
	-- Concrete base pedestal (wider, with bolts)
	--------------------------------------------------------------------
	local baseW = 5 * scale
	local baseH = 2 * scale
	local base = Instance.new("Part")
	base.Name = "CraneBase"
	base.Size = Vector3.new(baseW, baseH, baseW)
	base.Position = Vector3.new(craneX, baseY + baseH / 2, craneZ)
	base.Anchored = true
	base.Material = Enum.Material.Concrete
	base.Color = Color3.fromRGB(130, 130, 135)
	base.Parent = model

	-- 4 anchor bolts on base corners
	for _, bx in ipairs({ -1, 1 }) do
		for _, bz in ipairs({ -1, 1 }) do
			local bolt = Instance.new("Part")
			bolt.Name = "AnchorBolt"
			bolt.Shape = Enum.PartType.Cylinder
			bolt.Size = Vector3.new(0.5 * scale, 0.6 * scale, 0.6 * scale)
			bolt.CFrame = CFrame.new(
				craneX + bx * (baseW / 2 - 0.5 * scale),
				baseY + baseH + 0.25 * scale,
				craneZ + bz * (baseW / 2 - 0.5 * scale)
			) * CFrame.Angles(0, 0, math.rad(90))
			bolt.Anchored = true
			bolt.Material = Enum.Material.Metal
			bolt.Color = Color3.fromRGB(70, 70, 75)
			bolt.Parent = model
		end
	end

	--------------------------------------------------------------------
	-- Lattice mast (4 corner rails + diagonal cross-bracing)
	--------------------------------------------------------------------
	local mastW = 1.8 * scale  -- overall mast width
	local mastH = 35 * scale
	local railSize = 0.3 * scale
	local mastTopY = baseY + baseH + mastH

	-- 4 vertical corner rails
	local halfM = mastW / 2 - railSize / 2
	for _, mx in ipairs({ -halfM, halfM }) do
		for _, mz in ipairs({ -halfM, halfM }) do
			local rail = Instance.new("Part")
			rail.Name = "MastRail"
			rail.Size = Vector3.new(railSize, mastH, railSize)
			rail.Position = Vector3.new(craneX + mx, baseY + baseH + mastH / 2, craneZ + mz)
			rail.Anchored = true
			rail.Material = Enum.Material.Metal
			rail.Color = spec.craneColor
			rail.Parent = model
		end
	end

	-- Hazard stripes: alternating crane-color / black bands every 5 studs
	local stripeH = 1.2 * scale
	local stripeCount = math.floor(mastH / (5 * scale))
	for i = 0, stripeCount - 1 do
		local sy = baseY + baseH + i * 5 * scale + 2.5 * scale
		local sp = Instance.new("Part")
		sp.Name = "HazardStripe"
		sp.Size = Vector3.new(mastW, stripeH, mastW)
		sp.Position = Vector3.new(craneX, sy, craneZ)
		sp.Anchored = true
		sp.CanCollide = false
		sp.Material = Enum.Material.SmoothPlastic
		sp.Color = blackStripe
		sp.Parent = model
	end

	-- Diagonal X-braces on each face (every 7-stud section)
	local sectionH = 7 * scale
	local numSections = math.floor(mastH / sectionH)
	local braceThick = 0.15 * scale
	local braceLen = math.sqrt(sectionH * sectionH + mastW * mastW)

	for s = 0, numSections - 1 do
		local secBaseY = baseY + baseH + s * sectionH
		local secMidY = secBaseY + sectionH / 2

		-- Brace on X-facing sides (2 diagonals forming X, on +Z and -Z faces)
		for _, fz in ipairs({ -halfM, halfM }) do
			local brace = Instance.new("Part")
			brace.Name = "MastBrace"
			brace.Size = Vector3.new(braceThick, braceLen, braceThick)
			brace.CFrame = CFrame.new(craneX, secMidY, craneZ + fz)
				* CFrame.Angles(0, 0, math.atan2(mastW, sectionH))
			brace.Anchored = true
			brace.CanCollide = false
			brace.Material = Enum.Material.Metal
			brace.Color = spec.craneColor
			brace.Parent = model
		end

		-- Brace on Z-facing sides
		for _, fx in ipairs({ -halfM, halfM }) do
			local brace = Instance.new("Part")
			brace.Name = "MastBrace"
			brace.Size = Vector3.new(braceThick, braceLen, braceThick)
			brace.CFrame = CFrame.new(craneX + fx, secMidY, craneZ)
				* CFrame.Angles(math.atan2(mastW, sectionH), 0, 0)
			brace.Anchored = true
			brace.CanCollide = false
			brace.Material = Enum.Material.Metal
			brace.Color = spec.craneColor
			brace.Parent = model
		end

		-- Horizontal ring at each section boundary
		local ring = Instance.new("Part")
		ring.Name = "MastRing"
		ring.Size = Vector3.new(mastW, 0.2 * scale, mastW)
		ring.Position = Vector3.new(craneX, secBaseY, craneZ)
		ring.Anchored = true
		ring.CanCollide = false
		ring.Material = Enum.Material.Metal
		ring.Color = spec.craneColor
		ring.Parent = model
	end

	--------------------------------------------------------------------
	-- Slewing ring (visible turntable bearing at mast top)
	--------------------------------------------------------------------
	local slewDiam = 3 * scale
	local slew = Instance.new("Part")
	slew.Name = "SlewingRing"
	slew.Shape = Enum.PartType.Cylinder
	slew.Size = Vector3.new(0.6 * scale, slewDiam, slewDiam)
	slew.CFrame = CFrame.new(craneX, mastTopY + 0.3 * scale, craneZ)
		* CFrame.Angles(0, 0, math.rad(90))
	slew.Anchored = true
	slew.Material = Enum.Material.Metal
	slew.Color = Color3.fromRGB(60, 60, 65)
	slew.Parent = model

	--------------------------------------------------------------------
	-- Operator cab (sits on slewing ring)
	--------------------------------------------------------------------
	local cabW = 2.5 * scale
	local cabH = 2.5 * scale
	local cabY = mastTopY + 0.6 * scale
	local cab = Instance.new("Part")
	cab.Name = "CraneCab"
	cab.Size = Vector3.new(cabW, cabH, cabW)
	cab.Position = Vector3.new(craneX, cabY + cabH / 2, craneZ)
	cab.Anchored = true
	cab.Material = Enum.Material.Metal
	cab.Color = spec.craneColor
	cab.Parent = model

	-- Cab windows (wrap 3 sides for panoramic look)
	for _, face in ipairs({
		{ size = Vector3.new(cabW + 0.1, 1.2 * scale, 0.15 * scale), pos = Vector3.new(craneX, cabY + cabH * 0.6, craneZ - cabW / 2) },
		{ size = Vector3.new(cabW + 0.1, 1.2 * scale, 0.15 * scale), pos = Vector3.new(craneX, cabY + cabH * 0.6, craneZ + cabW / 2) },
		{ size = Vector3.new(0.15 * scale, 1.2 * scale, cabW + 0.1), pos = Vector3.new(craneX - cabW / 2, cabY + cabH * 0.6, craneZ) },
		{ size = Vector3.new(0.15 * scale, 1.2 * scale, cabW + 0.1), pos = Vector3.new(craneX + cabW / 2, cabY + cabH * 0.6, craneZ) },
	}) do
		local win = Instance.new("Part")
		win.Name = "CabWindow"
		win.Size = face.size
		win.Position = face.pos
		win.Anchored = true
		win.CanCollide = false
		win.Material = Enum.Material.Glass
		win.Color = Color3.fromRGB(170, 210, 240)
		win.Transparency = 0.3
		win.Parent = model
	end

	-- Cab roof
	local cabRoof = Instance.new("Part")
	cabRoof.Name = "CabRoof"
	cabRoof.Size = Vector3.new(cabW + 0.4 * scale, 0.2 * scale, cabW + 0.4 * scale)
	cabRoof.Position = Vector3.new(craneX, cabY + cabH + 0.1 * scale, craneZ)
	cabRoof.Anchored = true
	cabRoof.Material = Enum.Material.Metal
	cabRoof.Color = spec.craneColor
	cabRoof.Parent = model

	--------------------------------------------------------------------
	-- Cat head (short vertical peak above cab for pendant lines)
	--------------------------------------------------------------------
	local catHeadH = 5 * scale
	local catHeadW = 0.4 * scale
	local catHeadY = cabY + cabH
	local catHead = Instance.new("Part")
	catHead.Name = "CatHead"
	catHead.Size = Vector3.new(catHeadW, catHeadH, catHeadW)
	catHead.Position = Vector3.new(craneX, catHeadY + catHeadH / 2, craneZ)
	catHead.Anchored = true
	catHead.Material = Enum.Material.Metal
	catHead.Color = spec.craneColor
	catHead.Parent = model

	local catTopY = catHeadY + catHeadH

	--------------------------------------------------------------------
	-- Horizontal boom (the main rotating part)
	--------------------------------------------------------------------
	local boomLen = 30 * scale
	local boomH = 1.2 * scale
	local boomW = 1 * scale
	local boomY = cabY + cabH + boomH / 2

	local boom = Instance.new("Part")
	boom.Name = "CraneBoom"
	boom.Size = Vector3.new(boomLen, boomH, boomW)
	boom.CFrame = CFrame.new(craneX, boomY, craneZ) * CFrame.new(boomLen / 2 - 5 * scale, 0, 0)
	boom.Anchored = true
	boom.Material = Enum.Material.Metal
	boom.Color = spec.craneColor
	boom.Parent = model

	-- Red/white boom tip marker
	local tipLen = 2 * scale
	local tip = Instance.new("Part")
	tip.Name = "BoomTipRed"
	tip.Size = Vector3.new(tipLen, boomH + 0.1, boomW + 0.1)
	tip.CFrame = CFrame.new(craneX, boomY, craneZ)
		* CFrame.new(boomLen - 5 * scale - tipLen / 2, 0, 0)
	tip.Anchored = true
	tip.CanCollide = false
	tip.Material = Enum.Material.SmoothPlastic
	tip.Color = Color3.fromRGB(220, 30, 30)
	tip.Parent = model

	local tipWhite = Instance.new("Part")
	tipWhite.Name = "BoomTipWhite"
	tipWhite.Size = Vector3.new(tipLen, boomH + 0.1, boomW + 0.1)
	tipWhite.CFrame = CFrame.new(craneX, boomY, craneZ)
		* CFrame.new(boomLen - 5 * scale - tipLen * 1.5, 0, 0)
	tipWhite.Anchored = true
	tipWhite.CanCollide = false
	tipWhite.Material = Enum.Material.SmoothPlastic
	tipWhite.Color = Color3.fromRGB(240, 240, 240)
	tipWhite.Parent = model

	--------------------------------------------------------------------
	-- Counter-boom (short, opposite direction)
	--------------------------------------------------------------------
	local counterLen = 10 * scale
	local counter = Instance.new("Part")
	counter.Name = "CounterBoom"
	counter.Size = Vector3.new(counterLen, boomH, boomW)
	counter.CFrame = CFrame.new(craneX, boomY, craneZ) * CFrame.new(-counterLen / 2 - 1 * scale, 0, 0)
	counter.Anchored = true
	counter.Material = Enum.Material.Metal
	counter.Color = spec.craneColor
	counter.Parent = model

	-- Counterweight blocks (stacked pair for realism)
	local cwW = 3 * scale
	local cwH = 1.5 * scale
	local cwTop = Instance.new("Part")
	cwTop.Name = "Counterweight"
	cwTop.Size = Vector3.new(cwW, cwH, cwW)
	cwTop.CFrame = CFrame.new(craneX, boomY - boomH / 2 - cwH / 2, craneZ)
		* CFrame.new(-counterLen - 0.5 * scale, 0, 0)
	cwTop.Anchored = true
	cwTop.Material = Enum.Material.Concrete
	cwTop.Color = Color3.fromRGB(100, 100, 105)
	cwTop.Parent = model

	local cwBottom = Instance.new("Part")
	cwBottom.Name = "Counterweight2"
	cwBottom.Size = Vector3.new(cwW, cwH, cwW - 0.5 * scale)
	cwBottom.CFrame = CFrame.new(craneX, boomY - boomH / 2 - cwH / 2 - cwH, craneZ)
		* CFrame.new(-counterLen - 0.5 * scale, 0, 0)
	cwBottom.Anchored = true
	cwBottom.Material = Enum.Material.Concrete
	cwBottom.Color = Color3.fromRGB(85, 85, 90)
	cwBottom.Parent = model

	--------------------------------------------------------------------
	-- Pendant lines (cables from cat head to boom tip and counter-boom)
	--------------------------------------------------------------------
	-- Main pendant: cat head top → boom tip
	local pendantTipX = boomLen - 5 * scale
	local pendantLen = math.sqrt(pendantTipX * pendantTipX + (catTopY - boomY) * (catTopY - boomY))
	local pendantAngle = math.atan2(catTopY - boomY, pendantTipX)
	local pendant1 = Instance.new("Part")
	pendant1.Name = "PendantMain"
	pendant1.Size = Vector3.new(pendantLen, 0.12 * scale, 0.12 * scale)
	pendant1.CFrame = CFrame.new(craneX, (catTopY + boomY) / 2, craneZ)
		* CFrame.new(pendantTipX / 2, 0, 0)
		* CFrame.Angles(0, 0, -pendantAngle)
	pendant1.Anchored = true
	pendant1.CanCollide = false
	pendant1.Material = Enum.Material.Metal
	pendant1.Color = Color3.fromRGB(50, 50, 55)
	pendant1.Parent = model

	-- Counter pendant: cat head top → counter-boom tip
	local pendantCounterX = counterLen + 1 * scale
	local pendantCLen = math.sqrt(pendantCounterX * pendantCounterX + (catTopY - boomY) * (catTopY - boomY))
	local pendantCAngle = math.atan2(catTopY - boomY, pendantCounterX)
	local pendant2 = Instance.new("Part")
	pendant2.Name = "PendantCounter"
	pendant2.Size = Vector3.new(pendantCLen, 0.12 * scale, 0.12 * scale)
	pendant2.CFrame = CFrame.new(craneX, (catTopY + boomY) / 2, craneZ)
		* CFrame.new(-pendantCounterX / 2, 0, 0)
		* CFrame.Angles(0, 0, pendantCAngle)
	pendant2.Anchored = true
	pendant2.CanCollide = false
	pendant2.Material = Enum.Material.Metal
	pendant2.Color = Color3.fromRGB(50, 50, 55)
	pendant2.Parent = model

	--------------------------------------------------------------------
	-- Trolley, cable, hook
	--------------------------------------------------------------------
	local trolleyW = 1.5 * scale
	local trolley = Instance.new("Part")
	trolley.Name = "Trolley"
	trolley.Size = Vector3.new(trolleyW, 0.6 * scale, 1.2 * scale)
	trolley.CFrame = CFrame.new(craneX, boomY - boomH / 2 - 0.3 * scale, craneZ) * CFrame.new(boomLen / 2, 0, 0)
	trolley.Anchored = true
	trolley.Material = Enum.Material.Metal
	trolley.Color = Color3.fromRGB(80, 80, 85)
	trolley.Parent = model

	-- Hanging cable from trolley
	local cableH = 18 * scale
	local cable = Instance.new("Part")
	cable.Name = "HangingCable"
	cable.Size = Vector3.new(0.15 * scale, cableH, 0.15 * scale)
	cable.CFrame = CFrame.new(craneX, boomY - boomH / 2 - 0.6 * scale - cableH / 2, craneZ) * CFrame.new(boomLen / 2, 0, 0)
	cable.Anchored = true
	cable.Material = Enum.Material.Metal
	cable.Color = Color3.fromRGB(60, 60, 65)
	cable.Parent = model

	-- Hook block (more detailed than a simple ball)
	local hookBlockH = 1.2 * scale
	local hookBlock = Instance.new("Part")
	hookBlock.Name = "HookBlock"
	hookBlock.Size = Vector3.new(1.2 * scale, hookBlockH, 0.8 * scale)
	hookBlock.CFrame = CFrame.new(craneX, boomY - boomH / 2 - 0.6 * scale - cableH - hookBlockH / 2, craneZ) * CFrame.new(boomLen / 2, 0, 0)
	hookBlock.Anchored = true
	hookBlock.Material = Enum.Material.Metal
	hookBlock.Color = Color3.fromRGB(80, 80, 85)
	hookBlock.Parent = model

	-- Hook prong
	local hook = Instance.new("Part")
	hook.Name = "Hook"
	hook.Shape = Enum.PartType.Ball
	hook.Size = Vector3.new(0.7 * scale, 0.7 * scale, 0.7 * scale)
	hook.CFrame = CFrame.new(craneX, boomY - boomH / 2 - 0.6 * scale - cableH - hookBlockH - 0.35 * scale, craneZ) * CFrame.new(boomLen / 2, 0, 0)
	hook.Anchored = true
	hook.Material = Enum.Material.Metal
	hook.Color = Color3.fromRGB(200, 60, 30)  -- safety orange hook
	hook.Parent = model

	--------------------------------------------------------------------
	-- Register crane boom animation
	-- Boom + all linked parts rotate together around the mast top
	--------------------------------------------------------------------
	local hookTotalOffsetY = -boomH / 2 - 0.6 * scale - cableH - hookBlockH - 0.35 * scale
	DecorUtils.activePlatformAnimations[boom] = {
		type = "crane_boom",
		centerX = craneX,
		centerY = boomY,
		centerZ = craneZ,
		armOffset = boomLen / 2 - 5 * scale,
		angle = math.random() * math.pi * 2,
		speed = 0.15,
		linkedParts = {
			{ part = counter,       offsetX = -counterLen / 2 - 1 * scale,          offsetY = 0 },
			{ part = cwTop,         offsetX = -counterLen - 0.5 * scale,             offsetY = -boomH / 2 - cwH / 2 },
			{ part = cwBottom,      offsetX = -counterLen - 0.5 * scale,             offsetY = -boomH / 2 - cwH / 2 - cwH },
			{ part = trolley,       offsetX = boomLen / 2,                           offsetY = -boomH / 2 - 0.3 * scale },
			{ part = cable,         offsetX = boomLen / 2,                           offsetY = -boomH / 2 - 0.6 * scale - cableH / 2 },
			{ part = hookBlock,     offsetX = boomLen / 2,                           offsetY = -boomH / 2 - 0.6 * scale - cableH - hookBlockH / 2 },
			{ part = hook,          offsetX = boomLen / 2,                           offsetY = hookTotalOffsetY },
			{ part = pendant1,      offsetX = pendantTipX / 2,                       offsetY = (catTopY - boomY) / 2,   tiltAngle = -pendantAngle },
			{ part = pendant2,      offsetX = -pendantCounterX / 2,                  offsetY = (catTopY - boomY) / 2,   tiltAngle = pendantCAngle },
			{ part = tip,           offsetX = boomLen - 5 * scale - tipLen / 2,      offsetY = 0 },
			{ part = tipWhite,      offsetX = boomLen - 5 * scale - tipLen * 1.5,    offsetY = 0 },
			{ part = catHead,       offsetX = 0,                                     offsetY = (catTopY - boomY) - catHeadH / 2 },
		},
	}

	--------------------------------------------------------------------
	-- Warning light on cat head top
	--------------------------------------------------------------------
	local warnLight = Instance.new("Part")
	warnLight.Name = "CraneWarningLight"
	warnLight.Shape = Enum.PartType.Ball
	warnLight.Size = Vector3.new(0.8 * scale, 0.8 * scale, 0.8 * scale)
	warnLight.Position = Vector3.new(craneX, catTopY + 0.4 * scale, craneZ)
	warnLight.Anchored = true
	warnLight.Material = Enum.Material.Neon
	warnLight.Color = Color3.fromRGB(255, 40, 20)
	warnLight.Parent = model

	local wl = Instance.new("PointLight")
	wl.Brightness = 1.5
	wl.Range = 12
	wl.Color = Color3.fromRGB(255, 40, 20)
	wl.Parent = warnLight
end

--------------------------------------------------------------------------------
-- Helper: ground props (mixer, beams, sand, barriers, cones)
--------------------------------------------------------------------------------

local function createGroundProps(model, x, cz, scale, spec, baseY, sign_dir)
	local cx = x

	-- Concrete mixer (angled cylinder on a small platform)
	local mixerX = cx + sign_dir * 6 * scale
	local mixerZ = cz - 6 * scale

	-- Mixer platform
	local platform = Instance.new("Part")
	platform.Name = "MixerPlatform"
	platform.Size = Vector3.new(4 * scale, 1 * scale, 4 * scale)
	platform.Position = Vector3.new(mixerX, baseY + 0.5 * scale, mixerZ)
	platform.Anchored = true
	platform.Material = Enum.Material.Metal
	platform.Color = Color3.fromRGB(100, 100, 105)
	platform.Parent = model

	-- Mixer drum (angled cylinder)
	local drumDiam = 3 * scale
	local drumLen = 5 * scale
	local drum = Instance.new("Part")
	drum.Name = "MixerDrum"
	drum.Shape = Enum.PartType.Cylinder
	drum.Size = Vector3.new(drumLen, drumDiam, drumDiam)
	drum.CFrame = CFrame.new(mixerX, baseY + 1 * scale + drumDiam / 2 + 0.5 * scale, mixerZ)
		* CFrame.Angles(0, 0, math.rad(25))
	drum.Anchored = true
	drum.Material = Enum.Material.Metal
	drum.Color = Color3.fromRGB(190, 190, 195)
	drum.Parent = model

	-- Drum stripe
	local stripe = Instance.new("Part")
	stripe.Name = "DrumStripe"
	stripe.Shape = Enum.PartType.Cylinder
	stripe.Size = Vector3.new(drumLen * 0.3, drumDiam + 0.1, drumDiam + 0.1)
	stripe.CFrame = drum.CFrame
	stripe.Anchored = true
	stripe.CanCollide = false
	stripe.Material = Enum.Material.SmoothPlastic
	stripe.Color = spec.barrierColor
	stripe.Parent = model

	-- Sand/gravel pile
	local sandX = cx + sign_dir * 10 * scale
	local sandZ = cz - 4 * scale
	local sand = Instance.new("Part")
	sand.Name = "SandPile"
	sand.Shape = Enum.PartType.Ball
	sand.Size = Vector3.new(5 * scale, 3 * scale, 5 * scale)
	sand.Position = Vector3.new(sandX, baseY + 1.5 * scale, sandZ)
	sand.Anchored = true
	sand.Material = Enum.Material.Sand
	sand.Color = Color3.fromRGB(200, 185, 140)
	sand.Parent = model

	-- Steel I-beams stacked flat (3-4 beams)
	local beamX = cx + sign_dir * 8 * scale
	local beamZ = cz + 8 * scale
	for i = 1, 4 do
		local beam = Instance.new("Part")
		beam.Name = "SteelBeam"
		beam.Size = Vector3.new(8 * scale, 0.4 * scale, 0.6 * scale)
		beam.Position = Vector3.new(
			beamX + (math.random() - 0.5) * 1 * scale,
			baseY + (i - 1) * 0.45 * scale + 0.2 * scale,
			beamZ + (i - 2) * 0.8 * scale
		)
		beam.Anchored = true
		beam.Material = Enum.Material.Metal
		beam.Color = Color3.fromRGB(130, 90, 60)  -- rusty steel
		beam.Parent = model
	end

	-- Safety barriers along road edge (3-4 orange/white barriers)
	for i = 1, 4 do
		local barrierZ = cz + (i - 2.5) * 6 * scale
		local barrierX = x - sign_dir * 1 * scale

		-- Barrier body
		local barrier = Instance.new("Part")
		barrier.Name = "SafetyBarrier"
		barrier.Size = Vector3.new(1.2 * scale, 2 * scale, 0.4 * scale)
		barrier.Position = Vector3.new(barrierX, baseY + 1 * scale, barrierZ)
		barrier.Anchored = true
		barrier.Material = Enum.Material.SmoothPlastic
		barrier.Color = spec.barrierColor
		barrier.Parent = model

		-- White stripe on barrier
		local bstripe = Instance.new("Part")
		bstripe.Name = "BarrierStripe"
		bstripe.Size = Vector3.new(1.22 * scale, 0.5 * scale, 0.42 * scale)
		bstripe.Position = Vector3.new(barrierX, baseY + 1.3 * scale, barrierZ)
		bstripe.Anchored = true
		bstripe.CanCollide = false
		bstripe.Material = Enum.Material.SmoothPlastic
		bstripe.Color = Color3.fromRGB(240, 240, 240)
		bstripe.Parent = model
	end

	-- Traffic cones (5 scattered near road)
	for i = 1, 5 do
		local coneZ = cz + (i - 3) * 5 * scale + (math.random() - 0.5) * 2 * scale
		local coneX = x + sign_dir * (1 + math.random() * 3) * scale

		-- Cone body (small cylinder, tapered via scale)
		local cone = Instance.new("Part")
		cone.Name = "TrafficCone"
		cone.Shape = Enum.PartType.Cylinder
		cone.Size = Vector3.new(1.5 * scale, 0.8 * scale, 0.8 * scale)
		cone.CFrame = CFrame.new(coneX, baseY + 0.75 * scale, coneZ)
			* CFrame.Angles(0, 0, math.rad(90))
		cone.Anchored = true
		cone.Material = Enum.Material.SmoothPlastic
		cone.Color = Color3.fromRGB(255, 100, 20)
		cone.Parent = model

		-- White stripe on cone
		local cs = Instance.new("Part")
		cs.Name = "ConeStripe"
		cs.Shape = Enum.PartType.Cylinder
		cs.Size = Vector3.new(0.3 * scale, 0.82 * scale, 0.82 * scale)
		cs.CFrame = CFrame.new(coneX, baseY + 1.1 * scale, coneZ)
			* CFrame.Angles(0, 0, math.rad(90))
		cs.Anchored = true
		cs.CanCollide = false
		cs.Material = Enum.Material.SmoothPlastic
		cs.Color = Color3.fromRGB(240, 240, 240)
		cs.Parent = model
	end
end

--------------------------------------------------------------------------------
-- Helper: sign + lighting + dust effects
--------------------------------------------------------------------------------

local function createSignAndEffects(model, x, cz, scale, spec, baseY, sign_dir)
	-- Neon sign
	local signW = 12 * scale
	local signH = 2.5 * scale
	local signX = x + sign_dir * 1.5 * scale
	local signY = baseY + 7 * scale

	local signPart = Instance.new("Part")
	signPart.Name = "ConstructionSign"
	signPart.Size = Vector3.new(0.4 * scale, signH, signW)
	signPart.Position = Vector3.new(signX, signY, cz + 12 * scale)
	signPart.Anchored = true
	signPart.Material = Enum.Material.Neon
	signPart.Color = spec.signColor
	signPart.Parent = model

	local gui = Instance.new("SurfaceGui")
	gui.Face = sign_dir > 0 and Enum.NormalId.Left or Enum.NormalId.Right
	gui.Parent = signPart

	local txt = Instance.new("TextLabel")
	txt.Size = UDim2.new(1, 0, 1, 0)
	txt.BackgroundTransparency = 1
	txt.Font = Enum.Font.GothamBold
	txt.Text = spec.companyName
	txt.TextColor3 = Color3.new(1, 1, 1)
	txt.TextScaled = true
	txt.Parent = gui

	local signLight = Instance.new("PointLight")
	signLight.Brightness = 1.2
	signLight.Range = 12
	signLight.Color = spec.signColor
	signLight.Parent = signPart

	-- Work light poles (2, warm yellow)
	local lightPositions = {
		{ x = x + sign_dir * 4 * scale, z = cz - 14 * scale },
		{ x = x + sign_dir * 4 * scale, z = cz + 14 * scale },
	}
	for _, lp in ipairs(lightPositions) do
		local poleH = 10 * scale
		local pole = Instance.new("Part")
		pole.Name = "WorkLightPole"
		pole.Size = Vector3.new(0.4 * scale, poleH, 0.4 * scale)
		pole.Position = Vector3.new(lp.x, baseY + poleH / 2, lp.z)
		pole.Anchored = true
		pole.Material = Enum.Material.Metal
		pole.Color = Color3.fromRGB(110, 110, 115)
		pole.Parent = model

		local fixture = Instance.new("Part")
		fixture.Name = "WorkLight"
		fixture.Size = Vector3.new(1.5 * scale, 0.6 * scale, 1.5 * scale)
		fixture.Position = Vector3.new(lp.x, baseY + poleH + 0.3 * scale, lp.z)
		fixture.Anchored = true
		fixture.Material = Enum.Material.Neon
		fixture.Color = Color3.fromRGB(255, 230, 160)
		fixture.Parent = model

		local light = Instance.new("PointLight")
		light.Brightness = 0.8
		light.Range = 14
		light.Color = Color3.fromRGB(255, 230, 160)
		light.Parent = fixture
	end

	-- Dust particle emitter near structure base
	local dustX = x + sign_dir * 8 * scale
	local dustPart = Instance.new("Part")
	dustPart.Name = "DustPoint"
	dustPart.Size = Vector3.new(14 * scale, 1, 12 * scale)
	dustPart.Position = Vector3.new(dustX, baseY + 1, cz)
	dustPart.Anchored = true
	dustPart.CanCollide = false
	dustPart.Transparency = 1
	dustPart.Parent = model

	local dust = Instance.new("ParticleEmitter")
	dust.Name = "ConstructionDust"
	dust.Rate = 12
	dust.Speed = NumberRange.new(0.5, 2)
	dust.Lifetime = NumberRange.new(2, 5)
	dust.SpreadAngle = Vector2.new(40, 40)
	dust.LightEmission = 0.1
	dust.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.3, 2.5),
		NumberSequenceKeypoint.new(0.7, 4),
		NumberSequenceKeypoint.new(1, 2),
	})
	dust.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.3, 0.6),
		NumberSequenceKeypoint.new(0.7, 0.8),
		NumberSequenceKeypoint.new(1, 1),
	})
	dust.Color = ColorSequence.new(Color3.fromRGB(180, 170, 150), Color3.fromRGB(200, 190, 170))
	dust.Acceleration = Vector3.new(0, 0.5, 0)
	dust.Parent = dustPart
end

--------------------------------------------------------------------------------
-- createConstructionSite(x, z, scale)
--------------------------------------------------------------------------------

function ConstructionSite.createConstructionSite(x, z, scale)
	local decorFolder = DecorUtils.decorFolder
	if not decorFolder then return nil end
	scale = scale or 1

	local spec = (x < 0) and LEFT_SPEC or RIGHT_SPEC
	local sign_dir = x > 0 and 1 or -1

	local model = Instance.new("Model")
	model.Name = "ConstructionSite"

	local baseY = TERRAIN_TOP

	-- Building area center (pushed away from road)
	local areaW = 36 * scale
	local cx = x + sign_dir * (areaW / 2)

	-- Partially built structure
	local structX = createStructure(model, cx, z, scale, spec, baseY, sign_dir)

	-- Scaffolding on road-facing side
	createScaffolding(model, structX, z, scale, spec, baseY, sign_dir)

	-- Tower crane
	createTowerCrane(model, cx, z, scale, spec, baseY, sign_dir)

	-- Ground props (mixer, beams, sand, barriers, cones)
	createGroundProps(model, x, z, scale, spec, baseY, sign_dir)

	-- Sign + work lights + dust
	createSignAndEffects(model, x, z, scale, spec, baseY, sign_dir)

	model.Parent = decorFolder
	return model
end

return ConstructionSite
