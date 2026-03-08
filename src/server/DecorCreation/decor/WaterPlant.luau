local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local WaterPlant = {}

local TERRAIN_TOP = DecorUtils.TERRAIN_TOP

--------------------------------------------------------------------------------
-- LEFT / RIGHT specs
--------------------------------------------------------------------------------

local LEFT_SPEC = {
	waterColor   = Color3.fromRGB(40, 120, 200),   -- blue (processed/clean side)
	waterGlow    = Color3.fromRGB(60, 140, 220),
	boothColor   = Color3.fromRGB(200, 200, 210),
	signText     = "AQUA WORKS",
	signColor    = Color3.fromRGB(60, 180, 255),    -- blue
	chemLabels   = { "CHLORINE", "FLUORIDE" },
	chemColors   = { Color3.fromRGB(220, 220, 60), Color3.fromRGB(180, 80, 220) },
	tankRimColor = Color3.fromRGB(160, 170, 180),
}

local RIGHT_SPEC = {
	waterColor   = Color3.fromRGB(60, 150, 80),     -- green (intake/raw side)
	waterGlow    = Color3.fromRGB(50, 180, 70),
	boothColor   = Color3.fromRGB(180, 180, 185),
	signText     = "CITY WATER AUTHORITY",
	signColor    = Color3.fromRGB(80, 220, 120),     -- green
	chemLabels   = { "ALUM", "LIME" },
	chemColors   = { Color3.fromRGB(200, 200, 200), Color3.fromRGB(230, 220, 180) },
	tankRimColor = Color3.fromRGB(150, 155, 150),
}

--------------------------------------------------------------------------------
-- Helper: create a circular clarifier tank with rotating scraper arm
--------------------------------------------------------------------------------

local function createClarifier(model, px, pz, scale, spec, baseY)
	local tankDiam = 14 * scale
	local tankH = 3 * scale

	-- Dark floor disc (bottom of pool)
	local floor = Instance.new("Part")
	floor.Name = "ClarifierFloor"
	floor.Shape = Enum.PartType.Cylinder
	floor.Size = Vector3.new(0.3 * scale, tankDiam, tankDiam)
	floor.CFrame = CFrame.new(px, baseY + 0.15 * scale, pz) * CFrame.Angles(0, 0, math.rad(90))
	floor.Anchored = true
	floor.Material = Enum.Material.Concrete
	floor.Color = Color3.fromRGB(70, 80, 85)
	floor.Parent = model

	-- Water fill (the visible pool body — neon cylinder)
	local waterDiam = tankDiam - 0.4 * scale
	local waterH = tankH - 0.3 * scale
	local water = Instance.new("Part")
	water.Name = "ClarifierWater"
	water.Shape = Enum.PartType.Cylinder
	water.Size = Vector3.new(waterH, waterDiam, waterDiam)
	water.CFrame = CFrame.new(px, baseY + 0.3 * scale + waterH / 2, pz) * CFrame.Angles(0, 0, math.rad(90))
	water.Anchored = true
	water.CanCollide = false
	water.Material = Enum.Material.Neon
	water.Color = spec.waterColor
	water.Transparency = 0.35
	water.Parent = model

	-- Water glow
	local waterLight = Instance.new("PointLight")
	waterLight.Brightness = 0.8
	waterLight.Range = 10
	waterLight.Color = spec.waterGlow
	waterLight.Parent = water

	-- Bubble particles rising from water
	local bubblePart = Instance.new("Part")
	bubblePart.Name = "BubblePoint"
	bubblePart.Size = Vector3.new(waterDiam * 0.6, 1, waterDiam * 0.6)
	bubblePart.Position = Vector3.new(px, baseY + tankH + 0.2 * scale, pz)
	bubblePart.Anchored = true
	bubblePart.CanCollide = false
	bubblePart.Transparency = 1
	bubblePart.Parent = model

	local bubbles = Instance.new("ParticleEmitter")
	bubbles.Name = "Bubbles"
	bubbles.Rate = 25
	bubbles.Speed = NumberRange.new(1, 4)
	bubbles.Lifetime = NumberRange.new(1.0, 2.0)
	bubbles.SpreadAngle = Vector2.new(25, 25)
	bubbles.LightEmission = 0.4
	bubbles.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.4, 0.7),
		NumberSequenceKeypoint.new(0.8, 0.5),
		NumberSequenceKeypoint.new(1, 0.1),
	})
	bubbles.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(0.5, 0.3),
		NumberSequenceKeypoint.new(1, 1),
	})
	bubbles.Color = ColorSequence.new(spec.waterGlow, Color3.fromRGB(220, 240, 255))
	bubbles.Brightness = 1
	bubbles.Parent = bubblePart

	-- Center column (the pivot for the scraper arm)
	local centerCol = Instance.new("Part")
	centerCol.Name = "ClarifierCenter"
	centerCol.Shape = Enum.PartType.Cylinder
	centerCol.Size = Vector3.new(tankH + 2 * scale, 1.2 * scale, 1.2 * scale)
	centerCol.CFrame = CFrame.new(px, baseY + (tankH + 2 * scale) / 2, pz) * CFrame.Angles(0, 0, math.rad(90))
	centerCol.Anchored = true
	centerCol.Material = Enum.Material.Metal
	centerCol.Color = Color3.fromRGB(120, 120, 125)
	centerCol.Parent = model

	-- Rotating scraper arm (registered for animation)
	local armLen = tankDiam / 2 - 0.5 * scale
	local armH = 0.4 * scale
	local armW = 0.6 * scale
	local armY = baseY + tankH + 0.8 * scale

	local arm = Instance.new("Part")
	arm.Name = "ScraperArm"
	arm.Size = Vector3.new(armLen, armH, armW)
	arm.CFrame = CFrame.new(px, armY, pz) * CFrame.new(armLen / 2, 0, 0)
	arm.Anchored = true
	arm.Material = Enum.Material.Metal
	arm.Color = Color3.fromRGB(140, 140, 145)
	arm.Parent = model

	-- Register clarifier arm animation
	DecorUtils.activePlatformAnimations[arm] = {
		type = "clarifier_arm",
		centerX = px,
		centerY = armY,
		centerZ = pz,
		armOffset = armLen / 2,
		angle = math.random() * math.pi * 2,
		speed = 0.3,
	}

	return wall
end

--------------------------------------------------------------------------------
-- createWaterPlant(x, z, scale)
--------------------------------------------------------------------------------

function WaterPlant.createWaterPlant(x, z, scale)
	local decorFolder = DecorUtils.decorFolder
	if not decorFolder then return nil end
	scale = scale or 1

	local spec = (x < 0) and LEFT_SPEC or RIGHT_SPEC
	local sign_dir = x > 0 and 1 or -1

	local model = Instance.new("Model")
	model.Name = "WaterPlant"

	local baseY = TERRAIN_TOP

	-- Building area center (pushed away from road)
	local areaW = 36 * scale
	local cx = x + sign_dir * (areaW / 2)

	--------------------------------------------------------------------
	-- 2 Clarifier tanks (circular, side by side along Z)
	--------------------------------------------------------------------
	local tankSpacing = 16 * scale
	local tankX = cx - sign_dir * 5 * scale  -- closer to road side of area
	createClarifier(model, tankX, z - tankSpacing / 2, scale, spec, baseY)
	createClarifier(model, tankX, z + tankSpacing / 2, scale, spec, baseY)

	--------------------------------------------------------------------
	-- Settling basin (open-top: 4 walls + floor + water fill)
	--------------------------------------------------------------------
	local basinW = 16 * scale
	local basinH = 3 * scale
	local basinD = 28 * scale
	local basinX = cx + sign_dir * 4 * scale
	local wallT = 0.6 * scale   -- wall thickness
	local basinColor = Color3.fromRGB(140, 145, 150)

	-- Floor
	local basinFloor = Instance.new("Part")
	basinFloor.Name = "BasinFloor"
	basinFloor.Size = Vector3.new(basinW, wallT, basinD)
	basinFloor.Position = Vector3.new(basinX, baseY + wallT / 2, z)
	basinFloor.Anchored = true
	basinFloor.Material = Enum.Material.Concrete
	basinFloor.Color = Color3.fromRGB(70, 80, 85)
	basinFloor.Parent = model

	-- 4 walls (left, right along X; front, back along Z)
	local wallDefs = {
		{ s = Vector3.new(wallT, basinH, basinD), p = Vector3.new(basinX - basinW / 2 + wallT / 2, baseY + basinH / 2, z) },
		{ s = Vector3.new(wallT, basinH, basinD), p = Vector3.new(basinX + basinW / 2 - wallT / 2, baseY + basinH / 2, z) },
		{ s = Vector3.new(basinW, basinH, wallT), p = Vector3.new(basinX, baseY + basinH / 2, z - basinD / 2 + wallT / 2) },
		{ s = Vector3.new(basinW, basinH, wallT), p = Vector3.new(basinX, baseY + basinH / 2, z + basinD / 2 - wallT / 2) },
	}
	for _, def in ipairs(wallDefs) do
		local w = Instance.new("Part")
		w.Name = "BasinWall"
		w.Size = def.s
		w.Position = def.p
		w.Anchored = true
		w.Material = Enum.Material.Concrete
		w.Color = basinColor
		w.Parent = model
	end

	-- Water fill (thick neon slab sitting inside basin)
	local innerW = basinW - wallT * 2
	local innerD = basinD - wallT * 2
	local waterH = basinH - wallT - 0.3 * scale  -- fill up to near top
	local basinWater = Instance.new("Part")
	basinWater.Name = "BasinWater"
	basinWater.Size = Vector3.new(innerW, waterH, innerD)
	basinWater.Position = Vector3.new(basinX, baseY + wallT + waterH / 2, z)
	basinWater.Anchored = true
	basinWater.CanCollide = false
	basinWater.Material = Enum.Material.Neon
	basinWater.Color = spec.waterColor
	basinWater.Transparency = 0.4
	basinWater.Parent = model

	-- Basin water glow
	local basinGlow = Instance.new("PointLight")
	basinGlow.Brightness = 0.6
	basinGlow.Range = 10
	basinGlow.Color = spec.waterGlow
	basinGlow.Parent = basinWater

	-- Basin bubble aeration (enhanced)
	local basinBubblePart = Instance.new("Part")
	basinBubblePart.Name = "BasinBubblePoint"
	basinBubblePart.Size = Vector3.new(innerW * 0.5, 1, innerD * 0.4)
	basinBubblePart.Position = Vector3.new(basinX, baseY + basinH + 0.1 * scale, z)
	basinBubblePart.Anchored = true
	basinBubblePart.CanCollide = false
	basinBubblePart.Transparency = 1
	basinBubblePart.Parent = model

	local basinBubbles = Instance.new("ParticleEmitter")
	basinBubbles.Name = "BasinBubbles"
	basinBubbles.Rate = 20
	basinBubbles.Speed = NumberRange.new(1, 3)
	basinBubbles.Lifetime = NumberRange.new(0.8, 1.8)
	basinBubbles.SpreadAngle = Vector2.new(15, 15)
	basinBubbles.LightEmission = 0.4
	basinBubbles.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.4, 0.6),
		NumberSequenceKeypoint.new(1, 0.1),
	})
	basinBubbles.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(0.6, 0.4),
		NumberSequenceKeypoint.new(1, 1),
	})
	basinBubbles.Color = ColorSequence.new(spec.waterGlow, Color3.fromRGB(220, 240, 255))
	basinBubbles.Brightness = 1
	basinBubbles.Parent = basinBubblePart

	-- Waterfall overflow at basin road-side edge
	local fallX = basinX - sign_dir * (basinW / 2)
	local fallPart = Instance.new("Part")
	fallPart.Name = "WaterfallPoint"
	fallPart.Size = Vector3.new(1, 1, basinD * 0.5)
	fallPart.Position = Vector3.new(fallX, baseY + basinH, z)
	fallPart.Anchored = true
	fallPart.CanCollide = false
	fallPart.Transparency = 1
	fallPart.Parent = model

	local waterfall = Instance.new("ParticleEmitter")
	waterfall.Name = "Waterfall"
	waterfall.Rate = 40
	waterfall.Speed = NumberRange.new(0.5, 2)
	waterfall.Lifetime = NumberRange.new(0.6, 1.4)
	waterfall.SpreadAngle = Vector2.new(10, 5)
	waterfall.LightEmission = 0.2
	waterfall.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.5, 1.0),
		NumberSequenceKeypoint.new(1, 0.3),
	})
	waterfall.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(0.5, 0.3),
		NumberSequenceKeypoint.new(1, 1),
	})
	waterfall.Color = ColorSequence.new(spec.waterColor)
	waterfall.Brightness = 1
	waterfall.Acceleration = Vector3.new(0, -8, 0)
	waterfall.Parent = fallPart

	-- Catwalk railing over basin (2 thin rails along the length)
	local railH = 3.5 * scale
	local railY = baseY + basinH + railH / 2
	for _, rOff in ipairs({ -basinW / 2 + 0.5 * scale, basinW / 2 - 0.5 * scale }) do
		local rail = Instance.new("Part")
		rail.Name = "CatwalkRail"
		rail.Size = Vector3.new(0.2 * scale, railH, basinD)
		rail.Position = Vector3.new(basinX + rOff, railY, z)
		rail.Anchored = true
		rail.Material = Enum.Material.Metal
		rail.Color = Color3.fromRGB(180, 180, 60)  -- safety yellow
		rail.Transparency = 0.1
		rail.Parent = model
	end

	-- Catwalk floor (grated metal walkway)
	local walkway = Instance.new("Part")
	walkway.Name = "CatwalkFloor"
	walkway.Size = Vector3.new(basinW - 1 * scale, 0.2 * scale, basinD)
	walkway.Position = Vector3.new(basinX, baseY + basinH + 0.1 * scale, z)
	walkway.Anchored = true
	walkway.Material = Enum.Material.DiamondPlate
	walkway.Color = Color3.fromRGB(110, 110, 115)
	walkway.Transparency = 0.4  -- grated look
	walkway.Parent = model

	--------------------------------------------------------------------
	-- Pipe network (connecting clarifiers to basin)
	--------------------------------------------------------------------
	local pipeDiam = 1.8 * scale
	local pipeColor = Color3.fromRGB(60, 130, 180)

	-- Horizontal pipe from each clarifier to basin
	for _, side in ipairs({ -1, 1 }) do
		local pipeZ = z + side * tankSpacing / 2
		local pipeStartX = tankX + sign_dir * 7 * scale
		local pipeEndX = basinX - sign_dir * (basinW / 2)
		local pipeLen = math.abs(pipeEndX - pipeStartX)
		local pipeMidX = (pipeStartX + pipeEndX) / 2

		local pipe = Instance.new("Part")
		pipe.Name = "ConnectPipe"
		pipe.Shape = Enum.PartType.Cylinder
		pipe.Size = Vector3.new(pipeLen, pipeDiam, pipeDiam)
		pipe.CFrame = CFrame.new(pipeMidX, baseY + 2.5 * scale, pipeZ)
			* CFrame.Angles(0, math.rad(90), 0)
			* CFrame.Angles(0, 0, math.rad(90))
		pipe.Anchored = true
		pipe.Material = Enum.Material.Metal
		pipe.Color = pipeColor
		pipe.Parent = model

		-- Valve wheel on pipe
		local valveDiam = 1.5 * scale
		local valve = Instance.new("Part")
		valve.Name = "PipeValve"
		valve.Shape = Enum.PartType.Cylinder
		valve.Size = Vector3.new(0.3 * scale, valveDiam, valveDiam)
		valve.CFrame = CFrame.new(pipeMidX, baseY + 2.5 * scale + pipeDiam / 2 + 0.5 * scale, pipeZ)
			* CFrame.Angles(0, 0, math.rad(90))
		valve.Anchored = true
		valve.Material = Enum.Material.Metal
		valve.Color = Color3.fromRGB(180, 40, 40)  -- red valve wheel
		valve.Parent = model
	end

	--------------------------------------------------------------------
	-- Water tower (elevated sphere on stilts, behind building)
	--------------------------------------------------------------------
	local towerX = cx + sign_dir * (areaW / 2 - 5 * scale)
	local towerZ = z - 8 * scale
	local stiltsH = 16 * scale
	local sphereDiam = 8 * scale

	-- 4 stilts
	local stiltW = 0.8 * scale
	local stiltSpread = 3 * scale
	for _, sx in ipairs({ -stiltSpread, stiltSpread }) do
		for _, sz in ipairs({ -stiltSpread, stiltSpread }) do
			local stilt = Instance.new("Part")
			stilt.Name = "TowerStilt"
			stilt.Size = Vector3.new(stiltW, stiltsH, stiltW)
			stilt.Position = Vector3.new(towerX + sx, baseY + stiltsH / 2, towerZ + sz)
			stilt.Anchored = true
			stilt.Material = Enum.Material.Metal
			stilt.Color = Color3.fromRGB(120, 120, 125)
			stilt.Parent = model
		end
	end

	-- Cross braces on stilts
	for _, bz in ipairs({ -stiltSpread, stiltSpread }) do
		local brace = Instance.new("Part")
		brace.Name = "TowerBrace"
		brace.Size = Vector3.new(stiltSpread * 2, 0.5 * scale, 0.5 * scale)
		brace.CFrame = CFrame.new(towerX, baseY + stiltsH * 0.5, towerZ + bz)
			* CFrame.Angles(0, 0, math.rad(25))
		brace.Anchored = true
		brace.Material = Enum.Material.Metal
		brace.Color = Color3.fromRGB(115, 115, 120)
		brace.Parent = model
	end

	-- Water sphere
	local sphere = Instance.new("Part")
	sphere.Name = "WaterTowerSphere"
	sphere.Shape = Enum.PartType.Ball
	sphere.Size = Vector3.new(sphereDiam, sphereDiam, sphereDiam)
	sphere.Position = Vector3.new(towerX, baseY + stiltsH + sphereDiam / 2, towerZ)
	sphere.Anchored = true
	sphere.Material = Enum.Material.SmoothPlastic
	sphere.Color = Color3.fromRGB(180, 200, 220)
	sphere.Parent = model

	-- Water tower label
	local towerGui = Instance.new("SurfaceGui")
	towerGui.Face = sign_dir > 0 and Enum.NormalId.Left or Enum.NormalId.Right
	towerGui.Parent = sphere

	local towerTxt = Instance.new("TextLabel")
	towerTxt.Size = UDim2.new(0.8, 0, 0.3, 0)
	towerTxt.Position = UDim2.new(0.1, 0, 0.35, 0)
	towerTxt.BackgroundTransparency = 1
	towerTxt.Font = Enum.Font.GothamBold
	towerTxt.Text = "H₂O"
	towerTxt.TextColor3 = Color3.fromRGB(60, 100, 160)
	towerTxt.TextScaled = true
	towerTxt.Parent = towerGui

	--------------------------------------------------------------------
	-- 2 Chemical tanks (tall cylinders, near water tower)
	--------------------------------------------------------------------
	for i = 1, 2 do
		local chemZ = towerZ + (10 + (i - 1) * 6) * scale
		local chemX = towerX
		local chemDiam = 3 * scale
		local chemH = 10 * scale

		local chem = Instance.new("Part")
		chem.Name = "ChemicalTank"
		chem.Shape = Enum.PartType.Cylinder
		chem.Size = Vector3.new(chemH, chemDiam, chemDiam)
		chem.CFrame = CFrame.new(chemX, baseY + chemH / 2, chemZ) * CFrame.Angles(0, 0, math.rad(90))
		chem.Anchored = true
		chem.Material = Enum.Material.SmoothPlastic
		chem.Color = spec.chemColors[i]
		chem.Parent = model

		-- Tank cap
		local cap = Instance.new("Part")
		cap.Name = "TankCap"
		cap.Shape = Enum.PartType.Cylinder
		cap.Size = Vector3.new(0.5 * scale, chemDiam + 0.3, chemDiam + 0.3)
		cap.CFrame = CFrame.new(chemX, baseY + chemH + 0.25 * scale, chemZ) * CFrame.Angles(0, 0, math.rad(90))
		cap.Anchored = true
		cap.Material = Enum.Material.Metal
		cap.Color = Color3.fromRGB(80, 80, 85)
		cap.Parent = model

		-- Chemical label
		local labelPart = Instance.new("Part")
		labelPart.Name = "ChemLabel"
		labelPart.Size = Vector3.new(0.1, 1.5 * scale, 2.5 * scale)
		labelPart.Position = Vector3.new(chemX - chemDiam / 2 - 0.05, baseY + chemH * 0.6, chemZ)
		labelPart.Anchored = true
		labelPart.CanCollide = false
		labelPart.Material = Enum.Material.SmoothPlastic
		labelPart.Color = Color3.fromRGB(240, 240, 240)
		labelPart.Parent = model

		local labelGui = Instance.new("SurfaceGui")
		labelGui.Face = Enum.NormalId.Back
		labelGui.Parent = labelPart

		local labelTxt = Instance.new("TextLabel")
		labelTxt.Size = UDim2.new(1, 0, 1, 0)
		labelTxt.BackgroundTransparency = 1
		labelTxt.Font = Enum.Font.GothamBold
		labelTxt.Text = spec.chemLabels[i]
		labelTxt.TextColor3 = Color3.fromRGB(30, 30, 30)
		labelTxt.TextScaled = true
		labelTxt.Parent = labelGui
	end

	--------------------------------------------------------------------
	-- Control booth (small building near road)
	--------------------------------------------------------------------
	local boothW = 8 * scale
	local boothH = 6 * scale
	local boothD = 6 * scale
	local boothX = x + sign_dir * (boothW / 2 + 1 * scale)
	local boothZ = z - 12 * scale

	local booth = Instance.new("Part")
	booth.Name = "ControlBooth"
	booth.Size = Vector3.new(boothW, boothH, boothD)
	booth.Position = Vector3.new(boothX, baseY + boothH / 2, boothZ)
	booth.Anchored = true
	booth.Material = Enum.Material.Concrete
	booth.Color = spec.boothColor
	booth.Parent = model

	-- Booth roof
	local boothRoof = Instance.new("Part")
	boothRoof.Name = "BoothRoof"
	boothRoof.Size = Vector3.new(boothW + 1 * scale, 0.4 * scale, boothD + 1 * scale)
	boothRoof.Position = Vector3.new(boothX, baseY + boothH + 0.2 * scale, boothZ)
	boothRoof.Anchored = true
	boothRoof.Material = Enum.Material.Metal
	boothRoof.Color = Color3.fromRGB(70, 70, 75)
	boothRoof.Parent = model

	-- Booth window (road-facing)
	local boothWinX = boothX - sign_dir * (boothW / 2 + 0.1)
	local boothWin = Instance.new("Part")
	boothWin.Name = "BoothWindow"
	boothWin.Size = Vector3.new(0.2 * scale, 2.5 * scale, 4 * scale)
	boothWin.Position = Vector3.new(boothWinX, baseY + boothH * 0.65, boothZ)
	boothWin.Anchored = true
	boothWin.CanCollide = false
	boothWin.Material = Enum.Material.Glass
	boothWin.Color = Color3.fromRGB(180, 210, 240)
	boothWin.Transparency = 0.3
	boothWin.Parent = model

	-- Interior light glow from booth
	local boothLight = Instance.new("PointLight")
	boothLight.Brightness = 1.0
	boothLight.Range = 8
	boothLight.Color = Color3.fromRGB(255, 240, 200)
	boothLight.Parent = boothWin

	--------------------------------------------------------------------
	-- Main sign (Neon + SurfaceGui)
	--------------------------------------------------------------------
	local signW = 14 * scale
	local signH = 2.5 * scale
	local signX = x + sign_dir * 1 * scale
	local signY = baseY + 8 * scale

	local signPart = Instance.new("Part")
	signPart.Name = "WaterPlantSign"
	signPart.Size = Vector3.new(0.4 * scale, signH, signW)
	signPart.Position = Vector3.new(signX, signY, z + 10 * scale)
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
	txt.Text = spec.signText
	txt.TextColor3 = Color3.new(1, 1, 1)
	txt.TextScaled = true
	txt.Parent = gui

	local signLight = Instance.new("PointLight")
	signLight.Brightness = 1.2
	signLight.Range = 12
	signLight.Color = spec.signColor
	signLight.Parent = signPart

	--------------------------------------------------------------------
	-- Flood lights (tall poles with bright lights for night scene)
	--------------------------------------------------------------------
	local floodH = 12 * scale
	local floodPositions = {
		{ x = tankX, z = z - tankSpacing / 2 - 9 * scale },   -- near first clarifier
		{ x = tankX, z = z + tankSpacing / 2 + 9 * scale },   -- near second clarifier
		{ x = basinX, z = z - basinD / 2 - 2 * scale },        -- basin end
		{ x = basinX, z = z + basinD / 2 + 2 * scale },        -- basin other end
	}
	for _, fp in ipairs(floodPositions) do
		-- Pole
		local pole = Instance.new("Part")
		pole.Name = "FloodPole"
		pole.Size = Vector3.new(0.4 * scale, floodH, 0.4 * scale)
		pole.Position = Vector3.new(fp.x, baseY + floodH / 2, fp.z)
		pole.Anchored = true
		pole.Material = Enum.Material.Metal
		pole.Color = Color3.fromRGB(110, 110, 115)
		pole.Parent = model

		-- Light fixture (small neon box at top)
		local fixture = Instance.new("Part")
		fixture.Name = "FloodLight"
		fixture.Size = Vector3.new(1.5 * scale, 0.6 * scale, 1.5 * scale)
		fixture.Position = Vector3.new(fp.x, baseY + floodH + 0.3 * scale, fp.z)
		fixture.Anchored = true
		fixture.Material = Enum.Material.Neon
		fixture.Color = Color3.fromRGB(255, 240, 210)
		fixture.Parent = model

		local flood = Instance.new("PointLight")
		flood.Brightness = 1.0
		flood.Range = 16
		flood.Color = Color3.fromRGB(255, 245, 220)
		flood.Parent = fixture
	end

	--------------------------------------------------------------------
	-- Security fence (perimeter)
	--------------------------------------------------------------------
	local fenceH = 3.5 * scale
	local fenceD = 38 * scale
	local fenceX = x - sign_dir * 0.3

	local fence = Instance.new("Part")
	fence.Name = "SecurityFence"
	fence.Size = Vector3.new(0.3 * scale, fenceH, fenceD)
	fence.Position = Vector3.new(fenceX, baseY + fenceH / 2, z)
	fence.Anchored = true
	fence.Material = Enum.Material.Metal
	fence.Color = Color3.fromRGB(130, 130, 135)
	fence.Transparency = 0.3
	fence.Parent = model

	-- Fence posts
	local postSpacing = fenceD / 7
	for i = 1, 6 do
		local postZ = z - fenceD / 2 + i * postSpacing
		local post = Instance.new("Part")
		post.Name = "FencePost"
		post.Size = Vector3.new(0.4 * scale, fenceH + 0.5 * scale, 0.4 * scale)
		post.Position = Vector3.new(fenceX, baseY + (fenceH + 0.5 * scale) / 2, postZ)
		post.Anchored = true
		post.Material = Enum.Material.Metal
		post.Color = Color3.fromRGB(110, 110, 115)
		post.Parent = model
	end

	model.Parent = decorFolder
	return model
end

return WaterPlant
