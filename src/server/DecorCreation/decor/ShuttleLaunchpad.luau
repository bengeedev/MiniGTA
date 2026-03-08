local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local ShuttleLaunchpad = {}

function ShuttleLaunchpad.createShuttleLaunchpad(x, z, scale)
	local decorFolder = DecorUtils.decorFolder
	if not decorFolder then return nil end
	scale = scale or 1
	local TERRAIN_TOP = DecorUtils.TERRAIN_TOP
	local baseY = TERRAIN_TOP + 2 * scale  -- top of launch pad

	local model = Instance.new("Model")
	model.Name = "ShuttleLaunchpad"

	local S = scale  -- shorthand

	----------------------------------------------------------------------------
	-- LAUNCH PAD (flat concrete platform)
	----------------------------------------------------------------------------
	local pad = Instance.new("Part")
	pad.Name = "LaunchPad"
	pad.Size = Vector3.new(50 * S, 4 * S, 50 * S)
	pad.CFrame = CFrame.new(x, TERRAIN_TOP + 2 * S, z)
	pad.Color = Color3.fromRGB(130, 130, 135)
	pad.Material = Enum.Material.Concrete
	pad.Anchored = true
	pad.Parent = model

	----------------------------------------------------------------------------
	-- ARIANE-STYLE ROCKET (all white, massive)
	-- From bottom to top: nozzle cluster, engine section, core, upper, fairing
	-- All rocket parts go into a sub-model for launch animation
	----------------------------------------------------------------------------
	local rocketModel = Instance.new("Model")
	rocketModel.Name = "Rocket"
	rocketModel.Parent = model

	local rocketX = x
	local rocketBottomY = baseY + 2 * S  -- sitting on pad

	-- NOZZLE CLUSTER (visible from player on ground)
	-- Main Vulcain nozzle bell (wide flared cone)
	local nozzleBellOuter = Instance.new("Part")
	nozzleBellOuter.Name = "NozzleBellOuter"
	nozzleBellOuter.Shape = Enum.PartType.Cylinder
	nozzleBellOuter.Size = Vector3.new(4 * S, 9 * S, 9 * S)
	nozzleBellOuter.CFrame = CFrame.new(rocketX, rocketBottomY - 1 * S, z)
		* CFrame.Angles(0, 0, math.rad(90))
	nozzleBellOuter.Color = Color3.fromRGB(55, 50, 45)
	nozzleBellOuter.Material = Enum.Material.Metal
	nozzleBellOuter.Anchored = true
	nozzleBellOuter.Parent = rocketModel

	-- Inner nozzle throat (smaller, darker, recessed)
	local nozzleThroat = Instance.new("Part")
	nozzleThroat.Name = "NozzleThroat"
	nozzleThroat.Shape = Enum.PartType.Cylinder
	nozzleThroat.Size = Vector3.new(5 * S, 6 * S, 6 * S)
	nozzleThroat.CFrame = CFrame.new(rocketX, rocketBottomY, z)
		* CFrame.Angles(0, 0, math.rad(90))
	nozzleThroat.Color = Color3.fromRGB(25, 25, 30)
	nozzleThroat.Material = Enum.Material.Metal
	nozzleThroat.Anchored = true
	nozzleThroat.Parent = rocketModel

	-- Nozzle rim ring (bright ring at the bell exit)
	local nozzleRim = Instance.new("Part")
	nozzleRim.Name = "NozzleRim"
	nozzleRim.Shape = Enum.PartType.Cylinder
	nozzleRim.Size = Vector3.new(0.5 * S, 9.5 * S, 9.5 * S)
	nozzleRim.CFrame = CFrame.new(rocketX, rocketBottomY - 2.8 * S, z)
		* CFrame.Angles(0, 0, math.rad(90))
	nozzleRim.Color = Color3.fromRGB(90, 85, 75)
	nozzleRim.Material = Enum.Material.Metal
	nozzleRim.Anchored = true
	nozzleRim.Parent = rocketModel

	-- Heat shield plate (flat disc above nozzle, visible from below)
	local heatShield = Instance.new("Part")
	heatShield.Name = "HeatShield"
	heatShield.Shape = Enum.PartType.Cylinder
	heatShield.Size = Vector3.new(1 * S, 14 * S, 14 * S)
	heatShield.CFrame = CFrame.new(rocketX, rocketBottomY + 1.5 * S, z)
		* CFrame.Angles(0, 0, math.rad(90))
	heatShield.Color = Color3.fromRGB(60, 55, 50)
	heatShield.Material = Enum.Material.DiamondPlate
	heatShield.Anchored = true
	heatShield.Parent = rocketModel

	-- ENGINE SECTION (transition ring between nozzle and core)
	local engineBase = Instance.new("Part")
	engineBase.Name = "EngineBase"
	engineBase.Shape = Enum.PartType.Cylinder
	engineBase.Size = Vector3.new(6 * S, 15 * S, 15 * S)
	engineBase.CFrame = CFrame.new(rocketX, rocketBottomY + 5.5 * S, z)
		* CFrame.Angles(0, 0, math.rad(90))
	engineBase.Color = Color3.fromRGB(50, 50, 55)
	engineBase.Material = Enum.Material.Metal
	engineBase.Anchored = true
	engineBase.Parent = rocketModel

	-- Pipe details around engine base (4 small cylinders)
	for i = 0, 3 do
		local angle = math.rad(i * 90 + 45)
		local pipeR = 7.5 * S
		local pipe = Instance.new("Part")
		pipe.Name = "EnginePipe"
		pipe.Shape = Enum.PartType.Cylinder
		pipe.Size = Vector3.new(6 * S, 1.2 * S, 1.2 * S)
		pipe.CFrame = CFrame.new(
			rocketX + math.cos(angle) * pipeR,
			rocketBottomY + 6 * S,
			z + math.sin(angle) * pipeR
		) * CFrame.Angles(0, 0, math.rad(90))
		pipe.Color = Color3.fromRGB(80, 75, 70)
		pipe.Material = Enum.Material.Metal
		pipe.Anchored = true
		pipe.Parent = rocketModel
	end

	-- CORE STAGE (main white cylinder — bigger diameter)
	local coreH = 55 * S
	local coreD = 15 * S
	local core = Instance.new("Part")
	core.Name = "CoreStage"
	core.Shape = Enum.PartType.Cylinder
	core.Size = Vector3.new(coreH, coreD, coreD)
	core.CFrame = CFrame.new(rocketX, rocketBottomY + 10 * S + coreH / 2, z)
		* CFrame.Angles(0, 0, math.rad(90))
	core.Color = Color3.fromRGB(240, 240, 245)
	core.Material = Enum.Material.SmoothPlastic
	core.Anchored = true
	core.Parent = rocketModel

	-- ESA blue stripe band (decorative ring on core)
	local stripe = Instance.new("Part")
	stripe.Name = "BlueStripe"
	stripe.Shape = Enum.PartType.Cylinder
	stripe.Size = Vector3.new(3 * S, coreD + 1, coreD + 1)
	stripe.CFrame = CFrame.new(rocketX, rocketBottomY + 10 * S + coreH * 0.75, z)
		* CFrame.Angles(0, 0, math.rad(90))
	stripe.Color = Color3.fromRGB(0, 50, 140) -- ESA blue
	stripe.Material = Enum.Material.SmoothPlastic
	stripe.Anchored = true
	stripe.Parent = rocketModel

	-- UPPER STAGE (smaller white cylinder on top of core)
	local upperH = 12 * S
	local upperD = 8 * S
	local upperY = rocketBottomY + 10 * S + coreH + 0.5 * S  -- small gap avoids Z-fighting with core top
	local upper = Instance.new("Part")
	upper.Name = "UpperStage"
	upper.Shape = Enum.PartType.Cylinder
	upper.Size = Vector3.new(upperH, upperD, upperD)
	upper.CFrame = CFrame.new(rocketX, upperY + upperH / 2, z)
		* CFrame.Angles(0, 0, math.rad(90))
	upper.Color = Color3.fromRGB(235, 235, 240)
	upper.Material = Enum.Material.SmoothPlastic
	upper.Anchored = true
	upper.Parent = rocketModel

	-- PAYLOAD FAIRING (nose cone — tapered top)
	local fairingH = 14 * S
	local fairingD = 10 * S
	local fairingY = upperY + upperH

	-- Fairing body (cylinder, slightly wider than upper stage)
	local fairingBody = Instance.new("Part")
	fairingBody.Name = "FairingBody"
	fairingBody.Shape = Enum.PartType.Cylinder
	fairingBody.Size = Vector3.new(fairingH * 0.6, fairingD, fairingD)
	fairingBody.CFrame = CFrame.new(rocketX, fairingY + fairingH * 0.3, z)
		* CFrame.Angles(0, 0, math.rad(90))
	fairingBody.Color = Color3.fromRGB(240, 240, 245)
	fairingBody.Material = Enum.Material.SmoothPlastic
	fairingBody.Anchored = true
	fairingBody.Parent = rocketModel

	-- Fairing nose tip (ball on top)
	local fairingNose = Instance.new("Part")
	fairingNose.Name = "FairingNose"
	fairingNose.Shape = Enum.PartType.Ball
	fairingNose.Size = Vector3.new(fairingD, fairingD, fairingD)
	fairingNose.CFrame = CFrame.new(rocketX, fairingY + fairingH * 0.6 + fairingD * 0.3, z)
	fairingNose.Color = Color3.fromRGB(240, 240, 245)
	fairingNose.Material = Enum.Material.SmoothPlastic
	fairingNose.Anchored = true
	fairingNose.Parent = rocketModel

	-- SOLID ROCKET BOOSTERS (2 cylinders flanking the core)
	local boosterH = 40 * S
	local boosterD = 6 * S
	local boosterSpacing = 9 * S

	for _, side in { -1, 1 } do
		-- Booster body
		local booster = Instance.new("Part")
		booster.Name = "SolidBooster"
		booster.Shape = Enum.PartType.Cylinder
		booster.Size = Vector3.new(boosterH, boosterD, boosterD)
		booster.CFrame = CFrame.new(rocketX, rocketBottomY + 3 * S + boosterH / 2, z + side * boosterSpacing)
			* CFrame.Angles(0, 0, math.rad(90))
		booster.Color = Color3.fromRGB(230, 230, 235)
		booster.Material = Enum.Material.SmoothPlastic
		booster.Anchored = true
		booster.Parent = rocketModel

		-- Booster nose cone (ball on top)
		local boosterNose = Instance.new("Part")
		boosterNose.Name = "BoosterNose"
		boosterNose.Shape = Enum.PartType.Ball
		boosterNose.Size = Vector3.new(boosterD, boosterD, boosterD)
		boosterNose.CFrame = CFrame.new(rocketX, rocketBottomY + 3 * S + boosterH + boosterD * 0.3, z + side * boosterSpacing)
		boosterNose.Color = Color3.fromRGB(230, 230, 235)
		boosterNose.Material = Enum.Material.SmoothPlastic
		boosterNose.Anchored = true
		boosterNose.Parent = rocketModel

		-- Booster nozzle bell (visible from ground)
		local boosterBell = Instance.new("Part")
		boosterBell.Name = "BoosterBell"
		boosterBell.Shape = Enum.PartType.Cylinder
		boosterBell.Size = Vector3.new(2 * S, boosterD * 1.1, boosterD * 1.1)
		boosterBell.CFrame = CFrame.new(rocketX, rocketBottomY, z + side * boosterSpacing)
			* CFrame.Angles(0, 0, math.rad(90))
		boosterBell.Color = Color3.fromRGB(55, 50, 45)
		boosterBell.Material = Enum.Material.Metal
		boosterBell.Anchored = true
		boosterBell.Parent = rocketModel

		-- Booster nozzle inner (dark hole)
		local boosterNozzle = Instance.new("Part")
		boosterNozzle.Name = "BoosterNozzle"
		boosterNozzle.Shape = Enum.PartType.Cylinder
		boosterNozzle.Size = Vector3.new(2.5 * S, boosterD * 0.6, boosterD * 0.6)
		boosterNozzle.CFrame = CFrame.new(rocketX, rocketBottomY - 0.5 * S, z + side * boosterSpacing)
			* CFrame.Angles(0, 0, math.rad(90))
		boosterNozzle.Color = Color3.fromRGB(25, 25, 30)
		boosterNozzle.Material = Enum.Material.Metal
		boosterNozzle.Anchored = true
		boosterNozzle.Parent = rocketModel

		-- Struts connecting booster to core (2 per booster, top and bottom)
		for _, strutH in { 0.2, 0.65 } do
			local strut = Instance.new("Part")
			strut.Name = "BoosterStrut"
			strut.Size = Vector3.new(1.5 * S, 1.5 * S, (boosterSpacing - coreD / 2 - boosterD / 2) * 1.1)
			strut.CFrame = CFrame.new(
				rocketX,
				rocketBottomY + 3 * S + boosterH * strutH,
				z + side * (coreD / 2 + boosterSpacing - coreD / 2) / 2 + side * coreD / 4
			)
			strut.Color = Color3.fromRGB(180, 180, 185)
			strut.Material = Enum.Material.Metal
			strut.Anchored = true
			strut.Parent = rocketModel
		end
	end

	-- Set PrimaryPart for PivotTo animation
	rocketModel.PrimaryPart = core

	----------------------------------------------------------------------------
	-- EXHAUST & SMOKE PARTICLE EMITTERS
	----------------------------------------------------------------------------

	-- Exhaust plume (moves with rocket — parented to rocketModel)
	local exhaustPart = Instance.new("Part")
	exhaustPart.Name = "ExhaustEmitter"
	exhaustPart.Size = Vector3.new(8 * S, 1 * S, 8 * S)
	exhaustPart.CFrame = CFrame.new(rocketX, rocketBottomY - 3 * S, z)
	exhaustPart.Transparency = 1
	exhaustPart.CanCollide = false
	exhaustPart.Anchored = true
	exhaustPart.Parent = rocketModel

	local exhaust = Instance.new("ParticleEmitter")
	exhaust.Name = "Exhaust"
	exhaust.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 80)),
		ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255, 130, 20)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 60, 10)),
	})
	exhaust.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 4 * S),
		NumberSequenceKeypoint.new(0.4, 10 * S),
		NumberSequenceKeypoint.new(1, 16 * S),
	})
	exhaust.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.6, 0.4),
		NumberSequenceKeypoint.new(1, 1),
	})
	exhaust.Lifetime = NumberRange.new(0.5, 1.5)
	exhaust.Speed = NumberRange.new(50, 100)
	exhaust.Rate = 300
	exhaust.SpreadAngle = Vector2.new(12, 12)
	exhaust.EmissionDirection = Enum.NormalId.Bottom
	exhaust.LightEmission = 1
	exhaust.LightInfluence = 0
	exhaust.Enabled = false
	exhaust.Parent = exhaustPart

	-- Ground smoke cloud (stays on pad — parented to model)
	local smokePart = Instance.new("Part")
	smokePart.Name = "GroundSmoke"
	smokePart.Size = Vector3.new(35 * S, 1 * S, 35 * S)
	smokePart.CFrame = CFrame.new(x, baseY + 2 * S, z)
	smokePart.Transparency = 1
	smokePart.CanCollide = false
	smokePart.Anchored = true
	smokePart.Parent = model

	local smoke = Instance.new("ParticleEmitter")
	smoke.Name = "Smoke"
	smoke.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 220, 220)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(160, 160, 160)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 100, 100)),
	})
	smoke.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 3 * S),
		NumberSequenceKeypoint.new(0.4, 18 * S),
		NumberSequenceKeypoint.new(1, 30 * S),
	})
	smoke.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.4, 0.5),
		NumberSequenceKeypoint.new(1, 1),
	})
	smoke.Lifetime = NumberRange.new(4, 8)
	smoke.Speed = NumberRange.new(8, 25)
	smoke.Rate = 150
	smoke.SpreadAngle = Vector2.new(180, 180)
	smoke.EmissionDirection = Enum.NormalId.Top
	smoke.LightEmission = 0
	smoke.LightInfluence = 1
	smoke.Enabled = false
	smoke.Parent = smokePart

	-- Pre-launch steam (white vapor venting, stays on pad)
	local steam = Instance.new("ParticleEmitter")
	steam.Name = "Steam"
	steam.Color = ColorSequence.new(Color3.fromRGB(240, 240, 245))
	steam.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 2 * S),
		NumberSequenceKeypoint.new(0.5, 8 * S),
		NumberSequenceKeypoint.new(1, 14 * S),
	})
	steam.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.4),
		NumberSequenceKeypoint.new(0.5, 0.7),
		NumberSequenceKeypoint.new(1, 1),
	})
	steam.Lifetime = NumberRange.new(2, 5)
	steam.Speed = NumberRange.new(3, 10)
	steam.Rate = 40
	steam.SpreadAngle = Vector2.new(180, 180)
	steam.EmissionDirection = Enum.NormalId.Top
	steam.LightEmission = 0.2
	steam.LightInfluence = 1
	steam.Enabled = false
	steam.Parent = smokePart

	----------------------------------------------------------------------------
	-- LAUNCH TOWER (gantry)
	----------------------------------------------------------------------------
	local towerX = x - 18 * S
	local towerH = 95 * S

	local tower = Instance.new("Part")
	tower.Name = "Tower"
	tower.Size = Vector3.new(5 * S, towerH, 5 * S)
	tower.CFrame = CFrame.new(towerX, baseY + 2 * S + towerH / 2, z)
	tower.Color = Color3.fromRGB(200, 60, 30)
	tower.Material = Enum.Material.DiamondPlate
	tower.Anchored = true
	tower.Parent = model

	-- Tower arms at different heights
	for _, h in { 0.3, 0.55, 0.75 } do
		local arm = Instance.new("Part")
		arm.Name = "TowerArm"
		arm.Size = Vector3.new(18 * S, 1.5 * S, 3 * S)
		arm.CFrame = CFrame.new(towerX + 9 * S, baseY + 2 * S + towerH * h, z)
		arm.Color = Color3.fromRGB(200, 60, 30)
		arm.Material = Enum.Material.DiamondPlate
		arm.Anchored = true
		arm.Parent = model
	end

	----------------------------------------------------------------------------
	-- TERRAIN VARIATION: perimeter apron, utility bunkers
	----------------------------------------------------------------------------

	-- Perimeter apron (raised concrete ring around the pad area)
	local apronH = 0.6 * S
	-- Front and back apron strips
	for _, dz in { -1, 1 } do
		local apron = Instance.new("Part")
		apron.Name = "ApronStrip"
		apron.Size = Vector3.new(60 * S, apronH, 4 * S)
		apron.Position = Vector3.new(x, TERRAIN_TOP + apronH / 2, z + dz * 28 * S)
		apron.Anchored = true
		apron.Material = Enum.Material.Concrete
		apron.Color = Color3.fromRGB(150, 150, 155)
		apron.Parent = model
	end
	-- Side apron strips
	for _, dx in { -1, 1 } do
		local apron = Instance.new("Part")
		apron.Name = "ApronStrip"
		apron.Size = Vector3.new(4 * S, apronH, 60 * S)
		apron.Position = Vector3.new(x + dx * 28 * S, TERRAIN_TOP + apronH / 2, z)
		apron.Anchored = true
		apron.Material = Enum.Material.Concrete
		apron.Color = Color3.fromRGB(150, 150, 155)
		apron.Parent = model
	end


	-- Small utility bunker (concrete block with antenna)
	local bunkerX = x + 22 * S
	local bunkerZ = z - 20 * S
	local bunker = Instance.new("Part")
	bunker.Name = "UtilityBunker"
	bunker.Size = Vector3.new(6 * S, 4 * S, 8 * S)
	bunker.Position = Vector3.new(bunkerX, TERRAIN_TOP + 2 * S, bunkerZ)
	bunker.Anchored = true
	bunker.Material = Enum.Material.Concrete
	bunker.Color = Color3.fromRGB(110, 110, 115)
	bunker.Parent = model

	-- Antenna on bunker
	local antenna = Instance.new("Part")
	antenna.Name = "Antenna"
	antenna.Size = Vector3.new(0.3 * S, 10 * S, 0.3 * S)
	antenna.Position = Vector3.new(bunkerX, TERRAIN_TOP + 4 * S + 5 * S, bunkerZ)
	antenna.Anchored = true
	antenna.Material = Enum.Material.Metal
	antenna.Color = Color3.fromRGB(180, 180, 185)
	antenna.Parent = model

	-- Antenna dish
	local dish = Instance.new("Part")
	dish.Name = "Dish"
	dish.Shape = Enum.PartType.Ball
	dish.Size = Vector3.new(3 * S, 3 * S, 3 * S)
	dish.Position = Vector3.new(bunkerX, TERRAIN_TOP + 14 * S, bunkerZ)
	dish.Anchored = true
	dish.Material = Enum.Material.Metal
	dish.Color = Color3.fromRGB(220, 220, 225)
	dish.Parent = model

	----------------------------------------------------------------------------
	-- RED PULSING WARNING LIGHTS (evenly spaced around the pad perimeter)
	----------------------------------------------------------------------------
	local poleH = 6 * S
	local poleR = 0.3 * S
	local lightR = 0.8 * S
	local diodes = {}
	local padRadius = 27 * S -- just outside the pad

	-- Place poles along front, back, and sides of the pad
	local polePositions = {}
	-- Front and back rows (along X)
	for i = -3, 3 do
		table.insert(polePositions, { x + i * 8 * S, z - padRadius })
		table.insert(polePositions, { x + i * 8 * S, z + padRadius })
	end
	-- Side rows (along Z, skip corners already covered)
	for i = -2, 2 do
		table.insert(polePositions, { x - padRadius, z + i * 8 * S })
		table.insert(polePositions, { x + padRadius, z + i * 8 * S })
	end

	for _, pos in ipairs(polePositions) do
		local px, pz = pos[1], pos[2]

		local pole = Instance.new("Part")
		pole.Name = "WarningPole"
		pole.Size = Vector3.new(poleR, poleH, poleR)
		pole.Position = Vector3.new(px, baseY + poleH / 2, pz)
		pole.Anchored = true
		pole.Material = Enum.Material.Metal
		pole.Color = Color3.fromRGB(200, 200, 205)
		pole.Parent = model

		local diode = Instance.new("Part")
		diode.Name = "WarningDiode"
		diode.Shape = Enum.PartType.Ball
		diode.Size = Vector3.new(lightR, lightR, lightR)
		diode.Position = Vector3.new(px, baseY + poleH + lightR / 2, pz)
		diode.Anchored = true
		diode.CanCollide = false
		diode.Material = Enum.Material.Neon
		diode.Color = Color3.fromRGB(255, 40, 20)
		diode.Parent = model

		local glow = Instance.new("PointLight")
		glow.Color = Color3.fromRGB(255, 50, 20)
		glow.Brightness = 1.5
		glow.Range = 10
		glow.Parent = diode

		table.insert(diodes, diode)
	end

	----------------------------------------------------------------------------
	-- BLAST GATE (exit barrier — forces player to watch the launch)
	----------------------------------------------------------------------------
	local gateZ = z + 45 * S  -- in front of shuttle, behind countdown panel (z+60)
	local gateW = 84 * S      -- slightly wider than playable width
	local gateH = 10 * S
	local gateClosedY = TERRAIN_TOP + 2 + gateH / 2

	-- Gate panel (heavy blast door, slides up to open)
	local gateDoor = Instance.new("Part")
	gateDoor.Name = "BlastGate"
	gateDoor.Size = Vector3.new(gateW, gateH, 2 * S)
	gateDoor.CFrame = CFrame.new(0, gateClosedY, gateZ)
	gateDoor.Color = Color3.fromRGB(55, 55, 60)
	gateDoor.Material = Enum.Material.DiamondPlate
	gateDoor.Anchored = true
	gateDoor.Parent = model

	-- Gate pillars (fixed, don't move)
	for _, dx in { -1, 1 } do
		local pillar = Instance.new("Part")
		pillar.Name = "GatePillar"
		pillar.Size = Vector3.new(4 * S, gateH + 6 * S, 4 * S)
		pillar.Position = Vector3.new(dx * (gateW / 2 + 2 * S), TERRAIN_TOP + 2 + (gateH + 6 * S) / 2, gateZ)
		pillar.Color = Color3.fromRGB(35, 35, 40)
		pillar.Material = Enum.Material.Metal
		pillar.Anchored = true
		pillar.Parent = model

		-- Red warning light on each pillar
		local pillarLight = Instance.new("Part")
		pillarLight.Name = "GateLight"
		pillarLight.Shape = Enum.PartType.Ball
		pillarLight.Size = Vector3.new(1.5 * S, 1.5 * S, 1.5 * S)
		pillarLight.Position = Vector3.new(dx * (gateW / 2 + 2 * S), TERRAIN_TOP + 2 + gateH + 6 * S + 0.8 * S, gateZ)
		pillarLight.Color = Color3.fromRGB(255, 40, 20)
		pillarLight.Material = Enum.Material.Neon
		pillarLight.Anchored = true
		pillarLight.CanCollide = false
		pillarLight.Parent = model

		local pGlow = Instance.new("PointLight")
		pGlow.Color = Color3.fromRGB(255, 50, 20)
		pGlow.Brightness = 2
		pGlow.Range = 15
		pGlow.Parent = pillarLight

		table.insert(diodes, pillarLight)  -- pulse with other warning lights
	end

	-- SurfaceGui on the gate (facing approaching player — Front = -Z)
	local gateGui = Instance.new("SurfaceGui")
	gateGui.Name = "GateGUI"
	gateGui.Face = Enum.NormalId.Back  -- faces +Z towards approaching player
	gateGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gateGui.PixelsPerStud = 30
	gateGui.LightInfluence = 0
	gateGui.Brightness = 2
	gateGui.Parent = gateDoor

	-- Warning chevron stripes (alternating orange/black UI bands)
	for i = 0, 9 do
		local band = Instance.new("Frame")
		band.Name = "ChevronBand"
		band.Size = UDim2.new(1, 0, 0.1, 0)
		band.Position = UDim2.new(0, 0, i * 0.1, 0)
		band.BackgroundColor3 = (i % 2 == 0) and Color3.fromRGB(255, 160, 0) or Color3.fromRGB(30, 30, 30)
		band.BorderSizePixel = 0
		band.Parent = gateGui
	end

	-- Central text overlay
	local gateText = Instance.new("TextLabel")
	gateText.Name = "GateLabel"
	gateText.Size = UDim2.new(0.8, 0, 0.35, 0)
	gateText.Position = UDim2.new(0.1, 0, 0.1, 0)
	gateText.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	gateText.BackgroundTransparency = 0.2
	gateText.Text = "BLAST ZONE"
	gateText.TextColor3 = Color3.fromRGB(255, 200, 0)
	gateText.TextScaled = true
	gateText.Font = Enum.Font.RobotoMono
	gateText.ZIndex = 2
	gateText.Parent = gateGui

	local gateSubText = Instance.new("TextLabel")
	gateSubText.Name = "GateSub"
	gateSubText.Size = UDim2.new(0.8, 0, 0.25, 0)
	gateSubText.Position = UDim2.new(0.1, 0, 0.55, 0)
	gateSubText.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	gateSubText.BackgroundTransparency = 0.2
	gateSubText.Text = "GATE OPENS AFTER LAUNCH"
	gateSubText.TextColor3 = Color3.fromRGB(200, 200, 200)
	gateSubText.TextScaled = true
	gateSubText.Font = Enum.Font.RobotoMono
	gateSubText.ZIndex = 2
	gateSubText.Parent = gateGui

	----------------------------------------------------------------------------
	-- COUNTDOWN DISPLAY PANEL (LED archway at entrance of player path)
	----------------------------------------------------------------------------
	local cdX = 0  -- center of player path
	local cdZ = z + 60 * S  -- near lane entrance of wider lane
	local cdBaseY = TERRAIN_TOP + 2

	-- Two support posts
	for _, dx in { -1, 1 } do
		local post = Instance.new("Part")
		post.Name = "CountdownPost"
		post.Size = Vector3.new(0.8 * S, 14 * S, 0.8 * S)
		post.Position = Vector3.new(cdX + dx * 6 * S, cdBaseY + 7 * S, cdZ)
		post.Color = Color3.fromRGB(25, 25, 30)
		post.Material = Enum.Material.Metal
		post.Anchored = true
		post.CanCollide = false
		post.Parent = model
	end

	-- Dark LED screen
	local cdScreen = Instance.new("Part")
	cdScreen.Name = "CountdownScreen"
	cdScreen.Size = Vector3.new(12 * S, 7 * S, 0.5 * S)
	cdScreen.CFrame = CFrame.new(cdX, cdBaseY + 11.5 * S, cdZ)
	cdScreen.Color = Color3.fromRGB(8, 8, 12)
	cdScreen.Material = Enum.Material.SmoothPlastic
	cdScreen.Anchored = true
	cdScreen.CanCollide = false
	cdScreen.Parent = model

	-- Neon accent frame (cyan glow border)
	local cdFrame = Instance.new("Part")
	cdFrame.Name = "CountdownFrame"
	cdFrame.Size = Vector3.new(12.8 * S, 7.8 * S, 0.2 * S)
	cdFrame.CFrame = CFrame.new(cdX, cdBaseY + 11.5 * S, cdZ - 0.3 * S)
	cdFrame.Color = Color3.fromRGB(0, 140, 255)
	cdFrame.Material = Enum.Material.Neon
	cdFrame.Transparency = 0.3
	cdFrame.Anchored = true
	cdFrame.CanCollide = false
	cdFrame.Parent = model

	-- SurfaceGui on back face (faces +Z towards approaching player)
	local cdGui = Instance.new("SurfaceGui")
	cdGui.Name = "CountdownGUI"
	cdGui.Face = Enum.NormalId.Back
	cdGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	cdGui.PixelsPerStud = 50
	cdGui.LightInfluence = 0
	cdGui.Brightness = 2
	cdGui.Parent = cdScreen

	-- Header: "LAUNCH SEQUENCE"
	local cdHeader = Instance.new("TextLabel")
	cdHeader.Name = "Header"
	cdHeader.Size = UDim2.new(1, 0, 0.2, 0)
	cdHeader.Position = UDim2.new(0, 0, 0.03, 0)
	cdHeader.BackgroundTransparency = 1
	cdHeader.Text = "LAUNCH SEQUENCE"
	cdHeader.TextColor3 = Color3.fromRGB(0, 180, 255)
	cdHeader.TextScaled = true
	cdHeader.Font = Enum.Font.RobotoMono
	cdHeader.Parent = cdGui

	-- Big countdown number
	local cdNumber = Instance.new("TextLabel")
	cdNumber.Name = "Countdown"
	cdNumber.Size = UDim2.new(1, 0, 0.7, 0)
	cdNumber.Position = UDim2.new(0, 0, 0.25, 0)
	cdNumber.BackgroundTransparency = 1
	cdNumber.Text = "STANDBY"
	cdNumber.TextColor3 = Color3.fromRGB(0, 255, 100)
	cdNumber.TextScaled = true
	cdNumber.Font = Enum.Font.RobotoMono
	cdNumber.Parent = cdGui

	-- Register animations
	local activePlatformAnimations = DecorUtils.activePlatformAnimations
	if activePlatformAnimations then
		-- Warning light pulsing
		if #diodes > 0 then
			activePlatformAnimations[pad] = {
				type = "launch_warning",
				diodes = diodes,
				warningLabels = {},
				subLabels = {},
				lastTick = 0,
				phase = 0,
			}
		end

		-- Rocket launch cycle
		activePlatformAnimations[rocketModel] = {
			type = "rocket_launch",
			rocketModel = rocketModel,
			initialPivot = rocketModel:GetPivot(),
			startTime = tick(),
			state = "idle",
			exhaustEmitter = exhaust,
			smokeEmitter = smoke,
			steamEmitter = steam,
			countdownLabel = cdNumber,
			gatePart = gateDoor,
			gateClosedY = gateClosedY,
			gateOpenY = gateClosedY + gateH + 4 * S,
		}
	end

	model.Parent = decorFolder
	return model
end

return ShuttleLaunchpad
