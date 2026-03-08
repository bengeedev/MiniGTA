local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local PowerPlant = {}

local TERRAIN_TOP = DecorUtils.TERRAIN_TOP
local addWindowsToFace = DecorUtils.addWindowsToFace

--------------------------------------------------------------------------------
-- LEFT / RIGHT specs for visual variety
--------------------------------------------------------------------------------

local LEFT_SPEC = {
	bodyMat   = Enum.Material.DiamondPlate,
	bodyColor = Color3.fromRGB(80, 80, 90),
	roofColor = Color3.fromRGB(55, 55, 65),
	signText  = "⚡ VOLT ENERGY",
	signColor = Color3.fromRGB(255, 180, 60),   -- warm amber
	arcColor  = Color3.fromRGB(120, 180, 255),   -- cool blue arc
	sparkColor = Color3.fromRGB(200, 220, 255),
	coilColor = Color3.fromRGB(170, 170, 180),
	transformerCount = 2,
}

local RIGHT_SPEC = {
	bodyMat   = Enum.Material.Metal,
	bodyColor = Color3.fromRGB(75, 80, 90),
	roofColor = Color3.fromRGB(50, 55, 65),
	signText  = "⚡ POWER GRID CO.",
	signColor = Color3.fromRGB(60, 200, 255),    -- cool cyan
	arcColor  = Color3.fromRGB(180, 140, 255),    -- purple arc
	sparkColor = Color3.fromRGB(220, 180, 255),
	coilColor = Color3.fromRGB(180, 175, 170),
	transformerCount = 3,
}

--------------------------------------------------------------------------------
-- Helper: create a Tesla coil at position, returns tip attachment part
--------------------------------------------------------------------------------

local function createTeslaCoil(model, px, pz, scale, spec, baseY)
	-- Base pedestal
	local pedW = 4 * scale
	local pedH = 2 * scale
	local pedestal = Instance.new("Part")
	pedestal.Name = "CoilPedestal"
	pedestal.Size = Vector3.new(pedW, pedH, pedW)
	pedestal.Position = Vector3.new(px, baseY + pedH / 2, pz)
	pedestal.Anchored = true
	pedestal.Material = Enum.Material.Concrete
	pedestal.Color = Color3.fromRGB(130, 130, 135)
	pedestal.Parent = model

	-- 3 insulator discs (ceramic look, stacked)
	local insulatorDiam = 3.0 * scale
	local insulatorH = 0.6 * scale
	local insulatorBaseY = baseY + pedH
	for i = 0, 2 do
		local ins = Instance.new("Part")
		ins.Name = "Insulator"
		ins.Shape = Enum.PartType.Cylinder
		ins.Size = Vector3.new(insulatorH, insulatorDiam - i * 0.3 * scale, insulatorDiam - i * 0.3 * scale)
		ins.CFrame = CFrame.new(px, insulatorBaseY + i * (insulatorH + 0.3 * scale) + insulatorH / 2, pz) * CFrame.Angles(0, 0, math.rad(90))
		ins.Anchored = true
		ins.Material = Enum.Material.SmoothPlastic
		ins.Color = Color3.fromRGB(220, 200, 160)  -- ceramic tan
		ins.Parent = model
	end

	-- Main coil column
	local coilDiam = 1.8 * scale
	local coilH = 14 * scale
	local coilBaseY = insulatorBaseY + 3 * (insulatorH + 0.3 * scale)
	local coil = Instance.new("Part")
	coil.Name = "CoilColumn"
	coil.Shape = Enum.PartType.Cylinder
	coil.Size = Vector3.new(coilH, coilDiam, coilDiam)
	coil.CFrame = CFrame.new(px, coilBaseY + coilH / 2, pz) * CFrame.Angles(0, 0, math.rad(90))
	coil.Anchored = true
	coil.Material = Enum.Material.Metal
	coil.Color = spec.coilColor
	coil.Parent = model

	-- Copper wire wraps (neon rings around column)
	local wrapCount = 5
	for i = 1, wrapCount do
		local wy = coilBaseY + (i / (wrapCount + 1)) * coilH
		local wrap = Instance.new("Part")
		wrap.Name = "CoilWrap"
		wrap.Shape = Enum.PartType.Cylinder
		wrap.Size = Vector3.new(0.4 * scale, coilDiam + 0.8 * scale, coilDiam + 0.8 * scale)
		wrap.CFrame = CFrame.new(px, wy, pz) * CFrame.Angles(0, 0, math.rad(90))
		wrap.Anchored = true
		wrap.CanCollide = false
		wrap.Material = Enum.Material.Neon
		wrap.Color = Color3.fromRGB(200, 140, 50)  -- copper glow
		wrap.Parent = model
	end

	-- Top sphere (discharge point)
	local sphereDiam = 3.5 * scale
	local sphereY = coilBaseY + coilH + sphereDiam / 2
	local sphere = Instance.new("Part")
	sphere.Name = "CoilSphere"
	sphere.Shape = Enum.PartType.Ball
	sphere.Size = Vector3.new(sphereDiam, sphereDiam, sphereDiam)
	sphere.Position = Vector3.new(px, sphereY, pz)
	sphere.Anchored = true
	sphere.Material = Enum.Material.Metal
	sphere.Color = spec.coilColor
	sphere.Parent = model

	-- Spark emitter at sphere tip
	local sparkPart = Instance.new("Part")
	sparkPart.Name = "SparkPoint"
	sparkPart.Size = Vector3.new(1, 1, 1)
	sparkPart.Position = Vector3.new(px, sphereY + sphereDiam / 2, pz)
	sparkPart.Anchored = true
	sparkPart.CanCollide = false
	sparkPart.Transparency = 1
	sparkPart.Parent = model

	local sparks = Instance.new("ParticleEmitter")
	sparks.Name = "Sparks"
	sparks.Rate = 15
	sparks.Speed = NumberRange.new(4, 10)
	sparks.Lifetime = NumberRange.new(0.1, 0.3)
	sparks.SpreadAngle = Vector2.new(60, 60)
	sparks.LightEmission = 1
	sparks.Size = NumberSequence.new(0.3, 0)
	sparks.Color = ColorSequence.new(spec.sparkColor)
	sparks.Brightness = 3
	sparks.Parent = sparkPart

	-- Glow light on sphere
	local glow = Instance.new("PointLight")
	glow.Name = "CoilGlow"
	glow.Brightness = 2
	glow.Range = 18
	glow.Color = spec.arcColor
	glow.Parent = sphere

	-- Return the sphere (we'll attach beams to it)
	return sphere, glow
end

--------------------------------------------------------------------------------
-- Helper: create a transformer box
--------------------------------------------------------------------------------

local function createTransformer(model, px, pz, scale, baseY)
	local boxW = 4 * scale
	local boxH = 3.5 * scale
	local boxD = 3 * scale

	-- Main box
	local box = Instance.new("Part")
	box.Name = "TransformerBox"
	box.Size = Vector3.new(boxW, boxH, boxD)
	box.Position = Vector3.new(px, baseY + boxH / 2, pz)
	box.Anchored = true
	box.Material = Enum.Material.Metal
	box.Color = Color3.fromRGB(100, 105, 110)
	box.Parent = model

	-- 3 insulator bushings on top
	for i = -1, 1 do
		local bushing = Instance.new("Part")
		bushing.Name = "Bushing"
		bushing.Shape = Enum.PartType.Cylinder
		bushing.Size = Vector3.new(2.5 * scale, 0.8 * scale, 0.8 * scale)
		bushing.CFrame = CFrame.new(px + i * 1.2 * scale, baseY + boxH + 1.25 * scale, pz) * CFrame.Angles(0, 0, math.rad(90))
		bushing.Anchored = true
		bushing.Material = Enum.Material.SmoothPlastic
		bushing.Color = Color3.fromRGB(200, 180, 140)  -- ceramic
		bushing.Parent = model
	end

	-- Warning sticker (yellow face)
	local sticker = Instance.new("Part")
	sticker.Name = "WarningSticker"
	sticker.Size = Vector3.new(0.1, 1.5 * scale, 1.5 * scale)
	sticker.Position = Vector3.new(px - boxW / 2 - 0.05, baseY + boxH * 0.6, pz)
	sticker.Anchored = true
	sticker.CanCollide = false
	sticker.Material = Enum.Material.Neon
	sticker.Color = Color3.fromRGB(220, 190, 0)
	sticker.Parent = model

	-- Spark emitter (small crackles near bushings)
	local sparkPoint = Instance.new("Part")
	sparkPoint.Name = "TransformerSpark"
	sparkPoint.Size = Vector3.new(1, 1, 1)
	sparkPoint.Position = Vector3.new(px, baseY + boxH + 2 * scale, pz)
	sparkPoint.Anchored = true
	sparkPoint.CanCollide = false
	sparkPoint.Transparency = 1
	sparkPoint.Parent = model

	local sparks = Instance.new("ParticleEmitter")
	sparks.Rate = 5
	sparks.Speed = NumberRange.new(2, 6)
	sparks.Lifetime = NumberRange.new(0.05, 0.15)
	sparks.SpreadAngle = Vector2.new(90, 90)
	sparks.LightEmission = 1
	sparks.Size = NumberSequence.new(0.2, 0)
	sparks.Color = ColorSequence.new(Color3.fromRGB(200, 220, 255))
	sparks.Brightness = 2
	sparks.Parent = sparkPoint

	return box
end

--------------------------------------------------------------------------------
-- createPowerPlant(x, z, scale)
--------------------------------------------------------------------------------

function PowerPlant.createPowerPlant(x, z, scale)
	local decorFolder = DecorUtils.decorFolder
	if not decorFolder then return nil end
	scale = scale or 1

	local spec = (x < 0) and LEFT_SPEC or RIGHT_SPEC
	local sign_dir = x > 0 and 1 or -1

	local model = Instance.new("Model")
	model.Name = "PowerPlant"

	-- Dimensions
	local bodyW = 30 * scale
	local bodyH = 14 * scale
	local bodyD = 26 * scale
	local baseY = TERRAIN_TOP

	-- Center of building (pushed away from road)
	local cx = x + sign_dir * (bodyW / 2)

	--------------------------------------------------------------------
	-- Main turbine hall
	--------------------------------------------------------------------
	local body = Instance.new("Part")
	body.Name = "TurbineHall"
	body.Size = Vector3.new(bodyW, bodyH, bodyD)
	body.Position = Vector3.new(cx, baseY + bodyH / 2, z)
	body.Anchored = true
	body.Material = spec.bodyMat
	body.Color = spec.bodyColor
	body.Parent = model

	-- Roof
	local roof = Instance.new("Part")
	roof.Name = "TurbineRoof"
	roof.Size = Vector3.new(bodyW + 1 * scale, 0.6 * scale, bodyD + 1 * scale)
	roof.Position = Vector3.new(cx, baseY + bodyH + 0.3 * scale, z)
	roof.Anchored = true
	roof.Material = Enum.Material.DiamondPlate
	roof.Color = spec.roofColor
	roof.Parent = model

	--------------------------------------------------------------------
	-- Windows (sparse, industrial)
	--------------------------------------------------------------------
	local roadFace = cx - sign_dir * (bodyW / 2)
	addWindowsToFace(
		model, "x", roadFace, z,
		bodyD, baseY, 2, bodyH / 2,
		2.0, 1.8, 3.0,
		Color3.fromRGB(200, 220, 255), 0.30
	)
	local backFace = cx + sign_dir * (bodyW / 2)
	addWindowsToFace(
		model, "x", backFace, z,
		bodyD, baseY, 2, bodyH / 2,
		2.0, 1.8, 3.0,
		Color3.fromRGB(200, 220, 255), 0.15
	)

	--------------------------------------------------------------------
	-- 2 Tesla coils (in front of building, between road and hall)
	--------------------------------------------------------------------
	local coilSpacing = 12 * scale
	local coilX = x + sign_dir * 2 * scale  -- near road edge
	local coil1Z = z - coilSpacing / 2
	local coil2Z = z + coilSpacing / 2

	local sphere1, glow1 = createTeslaCoil(model, coilX, coil1Z, scale, spec, baseY)
	local sphere2, glow2 = createTeslaCoil(model, coilX, coil2Z, scale, spec, baseY)

	--------------------------------------------------------------------
	-- Electrical arc beam between the two Tesla coil spheres
	--------------------------------------------------------------------
	local att1 = Instance.new("Attachment")
	att1.Name = "ArcAttach1"
	att1.Parent = sphere1

	local att2 = Instance.new("Attachment")
	att2.Name = "ArcAttach2"
	att2.Parent = sphere2

	-- Main arc beam
	local beam = Instance.new("Beam")
	beam.Name = "ElectricalArc"
	beam.Attachment0 = att1
	beam.Attachment1 = att2
	beam.Segments = 24
	beam.Width0 = 0.6 * scale
	beam.Width1 = 0.6 * scale
	beam.CurveSize0 = 4 * scale
	beam.CurveSize1 = -3 * scale
	beam.LightEmission = 1
	beam.LightInfluence = 0
	beam.FaceCamera = true
	beam.Color = ColorSequence.new(spec.arcColor)
	beam.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(0.5, 0),
		NumberSequenceKeypoint.new(1, 0.1),
	})
	beam.Brightness = 3
	beam.Parent = sphere1

	-- Secondary thinner arc (offset curves for chaotic feel)
	local beam2 = Instance.new("Beam")
	beam2.Name = "ElectricalArc2"
	beam2.Attachment0 = att1
	beam2.Attachment1 = att2
	beam2.Segments = 20
	beam2.Width0 = 0.3 * scale
	beam2.Width1 = 0.3 * scale
	beam2.CurveSize0 = -2 * scale
	beam2.CurveSize1 = 5 * scale
	beam2.LightEmission = 1
	beam2.LightInfluence = 0
	beam2.FaceCamera = true
	beam2.Color = ColorSequence.new(Color3.fromRGB(240, 240, 255))  -- whiter core
	beam2.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.5, 0.05),
		NumberSequenceKeypoint.new(1, 0.2),
	})
	beam2.Brightness = 4
	beam2.Parent = sphere1

	-- Register electrical arc animation
	DecorUtils.activePlatformAnimations[sphere1] = {
		type = "electrical_arc",
		beam1 = beam,
		beam2 = beam2,
		glow1 = glow1,
		glow2 = glow2,
		baseScale = scale,
	}

	--------------------------------------------------------------------
	-- Transformer boxes (between coils and building)
	--------------------------------------------------------------------
	local tfBaseX = cx - sign_dir * (bodyW / 2 - 4 * scale)
	local tfSpacing = bodyD / (spec.transformerCount + 1)
	for i = 1, spec.transformerCount do
		local tfZ = z - bodyD / 2 + i * tfSpacing
		createTransformer(model, tfBaseX, tfZ, scale, baseY)
	end

	--------------------------------------------------------------------
	-- High-voltage pylon (behind building, further from road)
	--------------------------------------------------------------------
	local pylonX = cx + sign_dir * (bodyW / 2 + 6 * scale)
	local pylonH = 28 * scale
	local pylonW = 1.5 * scale

	-- Main vertical pole
	local pole = Instance.new("Part")
	pole.Name = "PylonPole"
	pole.Size = Vector3.new(pylonW, pylonH, pylonW)
	pole.Position = Vector3.new(pylonX, baseY + pylonH / 2, z)
	pole.Anchored = true
	pole.Material = Enum.Material.Metal
	pole.Color = Color3.fromRGB(120, 120, 125)
	pole.Parent = model

	-- Cross arms (3 levels)
	for i = 1, 3 do
		local armY = baseY + pylonH * (0.5 + i * 0.15)
		local armLen = (14 - i * 2) * scale
		local arm = Instance.new("Part")
		arm.Name = "PylonArm"
		arm.Size = Vector3.new(pylonW * 0.8, pylonW * 0.8, armLen)
		arm.Position = Vector3.new(pylonX, armY, z)
		arm.Anchored = true
		arm.Material = Enum.Material.Metal
		arm.Color = Color3.fromRGB(110, 110, 115)
		arm.Parent = model

		-- Insulator at each end of arm
		for _, endDir in ipairs({ -1, 1 }) do
			local insZ = z + endDir * (armLen / 2)
			local ins = Instance.new("Part")
			ins.Name = "PylonInsulator"
			ins.Shape = Enum.PartType.Cylinder
			ins.Size = Vector3.new(2 * scale, 1 * scale, 1 * scale)
			ins.CFrame = CFrame.new(pylonX, armY - 1 * scale, insZ) * CFrame.Angles(0, 0, math.rad(90))
			ins.Anchored = true
			ins.Material = Enum.Material.SmoothPlastic
			ins.Color = Color3.fromRGB(210, 190, 150)
			ins.Parent = model
		end
	end

	-- Diagonal braces on pylon
	local braceW = 0.6 * scale
	local braceLen = 18 * scale
	for _, bDir in ipairs({ -1, 1 }) do
		local brace = Instance.new("Part")
		brace.Name = "PylonBrace"
		brace.Size = Vector3.new(braceW, braceLen, braceW)
		brace.CFrame = CFrame.new(pylonX, baseY + pylonH * 0.5, z + bDir * 2 * scale) * CFrame.Angles(0, 0, math.rad(bDir * 15))
		brace.Anchored = true
		brace.Material = Enum.Material.Metal
		brace.Color = Color3.fromRGB(115, 115, 120)
		brace.Parent = model
	end

	--------------------------------------------------------------------
	-- Power lines from pylon to building (decorative beams)
	--------------------------------------------------------------------
	local lineAtt1 = Instance.new("Attachment")
	lineAtt1.Position = Vector3.new(0, pylonH * 0.35, 0)
	lineAtt1.Parent = pole

	-- Attachment on roof edge
	local lineAtt2 = Instance.new("Attachment")
	lineAtt2.Position = Vector3.new(sign_dir * bodyW / 2, 0, 0)
	lineAtt2.Parent = roof

	local powerLine = Instance.new("Beam")
	powerLine.Name = "PowerLine"
	powerLine.Attachment0 = lineAtt1
	powerLine.Attachment1 = lineAtt2
	powerLine.Segments = 12
	powerLine.Width0 = 0.15 * scale
	powerLine.Width1 = 0.15 * scale
	powerLine.CurveSize0 = -3 * scale  -- droop/sag
	powerLine.CurveSize1 = -3 * scale
	powerLine.FaceCamera = true
	powerLine.Color = ColorSequence.new(Color3.fromRGB(40, 40, 45))
	powerLine.Transparency = NumberSequence.new(0)
	powerLine.Parent = pole

	--------------------------------------------------------------------
	-- Warning sign (DANGER HIGH VOLTAGE)
	--------------------------------------------------------------------
	local warnSignW = 10 * scale
	local warnSignH = 2 * scale
	local warnX = x - sign_dir * 1 * scale
	local warnY = baseY + 5 * scale

	local warnPart = Instance.new("Part")
	warnPart.Name = "HighVoltageSign"
	warnPart.Size = Vector3.new(0.3 * scale, warnSignH, warnSignW)
	warnPart.Position = Vector3.new(warnX, warnY, z)
	warnPart.Anchored = true
	warnPart.Material = Enum.Material.Neon
	warnPart.Color = Color3.fromRGB(255, 60, 20)
	warnPart.Parent = model

	local warnGui = Instance.new("SurfaceGui")
	warnGui.Face = sign_dir > 0 and Enum.NormalId.Left or Enum.NormalId.Right
	warnGui.Parent = warnPart

	local warnTxt = Instance.new("TextLabel")
	warnTxt.Size = UDim2.new(1, 0, 1, 0)
	warnTxt.BackgroundTransparency = 1
	warnTxt.Font = Enum.Font.GothamBold
	warnTxt.Text = "⚡ DANGER HIGH VOLTAGE ⚡"
	warnTxt.TextColor3 = Color3.new(1, 1, 1)
	warnTxt.TextScaled = true
	warnTxt.Parent = warnGui

	local warnLight = Instance.new("PointLight")
	warnLight.Brightness = 1.2
	warnLight.Range = 10
	warnLight.Color = Color3.fromRGB(255, 60, 20)
	warnLight.Parent = warnPart

	--------------------------------------------------------------------
	-- Main sign (Neon + SurfaceGui)
	--------------------------------------------------------------------
	local signW = 14 * scale
	local signH = 2.5 * scale
	local signX = cx - sign_dir * (bodyW / 2 + 0.3)
	local signY = baseY + bodyH - 3 * scale

	local signPart = Instance.new("Part")
	signPart.Name = "PowerPlantSign"
	signPart.Size = Vector3.new(0.4 * scale, signH, signW)
	signPart.Position = Vector3.new(signX, signY, z)
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
	signLight.Brightness = 1.5
	signLight.Range = 16
	signLight.Color = spec.signColor
	signLight.Parent = signPart

	--------------------------------------------------------------------
	-- Security fence (chain-link style, between plant and road)
	--------------------------------------------------------------------
	local fenceH = 4 * scale
	local fenceD = 34 * scale
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
	local postCount = 6
	local postSpacing = fenceD / (postCount + 1)
	for i = 1, postCount do
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

return PowerPlant
