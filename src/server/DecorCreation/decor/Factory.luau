local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local Factory = {}

local TERRAIN_TOP = DecorUtils.TERRAIN_TOP
local addWindowsToFace = DecorUtils.addWindowsToFace

--------------------------------------------------------------------------------
-- LEFT / RIGHT specs for visual variety
--------------------------------------------------------------------------------

local LEFT_SPEC = {
	bodyMat   = Enum.Material.DiamondPlate,
	bodyColor = Color3.fromRGB(85, 85, 90),
	roofColor = Color3.fromRGB(65, 65, 70),
	signText  = "INDUSTRIAL WORKS",
	signColor = Color3.fromRGB(255, 180, 60),  -- warm amber
	stacks    = 3,
	containers = {
		{ color = Color3.fromRGB(180, 40, 40),  w = 12 },  -- red
		{ color = Color3.fromRGB(40, 80, 160),  w = 10 },  -- blue
		{ color = Color3.fromRGB(50, 130, 60),  w = 11 },  -- green
	},
}

local RIGHT_SPEC = {
	bodyMat   = Enum.Material.Metal,
	bodyColor = Color3.fromRGB(95, 95, 100),
	roofColor = Color3.fromRGB(70, 70, 75),
	signText  = "FACTORY CO.",
	signColor = Color3.fromRGB(60, 200, 255),  -- cool cyan
	stacks    = 2,
	containers = {
		{ color = Color3.fromRGB(200, 170, 40),  w = 11 },  -- yellow
		{ color = Color3.fromRGB(210, 120, 40),  w = 10 },  -- orange
		{ color = Color3.fromRGB(130, 130, 135), w = 12 },  -- gray
	},
}

--------------------------------------------------------------------------------
-- createFactory(x, z, scale)
--------------------------------------------------------------------------------

function Factory.createFactory(x, z, scale)
	local decorFolder = DecorUtils.decorFolder
	if not decorFolder then return nil end
	scale = scale or 1

	local spec = (x < 0) and LEFT_SPEC or RIGHT_SPEC
	local sign_dir = x > 0 and 1 or -1  -- +1 = right side, -1 = left side

	local model = Instance.new("Model")
	model.Name = "Factory"

	-- Dimensions (pre-scale)
	local bodyW = 36 * scale
	local bodyH = 22 * scale
	local bodyD = 30 * scale
	local baseY = TERRAIN_TOP

	-- Center of building (pushed away from road)
	local cx = x + sign_dir * (bodyW / 2)

	--------------------------------------------------------------------
	-- Main body
	--------------------------------------------------------------------
	local body = Instance.new("Part")
	body.Name = "FactoryBody"
	body.Size = Vector3.new(bodyW, bodyH, bodyD)
	body.Position = Vector3.new(cx, baseY + bodyH / 2, z)
	body.Anchored = true
	body.Material = spec.bodyMat
	body.Color = spec.bodyColor
	body.Parent = model

	--------------------------------------------------------------------
	-- Roof (slight overhang)
	--------------------------------------------------------------------
	local roof = Instance.new("Part")
	roof.Name = "FactoryRoof"
	roof.Size = Vector3.new(bodyW + 1 * scale, 0.8 * scale, bodyD + 1 * scale)
	roof.Position = Vector3.new(cx, baseY + bodyH + 0.4 * scale, z)
	roof.Anchored = true
	roof.Material = Enum.Material.DiamondPlate
	roof.Color = spec.roofColor
	roof.Parent = model

	--------------------------------------------------------------------
	-- 4 corner columns
	--------------------------------------------------------------------
	local colSize = 1.5 * scale
	local colH = (bodyH + 1) * scale / scale  -- same height as body + slight extra
	colH = bodyH + 1 * scale
	local halfW = bodyW / 2 - colSize / 2
	local halfD = bodyD / 2 - colSize / 2
	for _, ox in ipairs({ -halfW, halfW }) do
		for _, oz in ipairs({ -halfD, halfD }) do
			local col = Instance.new("Part")
			col.Name = "FactoryColumn"
			col.Size = Vector3.new(colSize, colH, colSize)
			col.Position = Vector3.new(cx + ox, baseY + colH / 2, z + oz)
			col.Anchored = true
			col.Material = Enum.Material.Concrete
			col.Color = Color3.fromRGB(120, 120, 125)
			col.Parent = model
		end
	end

	--------------------------------------------------------------------
	-- Hazard stripes on front columns (yellow/black bands)
	--------------------------------------------------------------------
	local frontColOX = -sign_dir * halfW
	for _, oz in ipairs({ -halfD, halfD }) do
		for band = 0, 3 do
			local stripe = Instance.new("Part")
			stripe.Name = "HazardStripe"
			stripe.Size = Vector3.new(colSize + 0.1, 0.8 * scale, colSize + 0.1)
			stripe.Position = Vector3.new(
				cx + frontColOX,
				baseY + 2 * scale + band * 2.5 * scale,
				z + oz
			)
			stripe.Anchored = true
			stripe.CanCollide = false
			stripe.Material = Enum.Material.SmoothPlastic
			stripe.Color = (band % 2 == 0)
				and Color3.fromRGB(220, 190, 0)
				or Color3.fromRGB(30, 30, 30)
			stripe.Parent = model
		end
	end

	--------------------------------------------------------------------
	-- Smokestacks on roof
	--------------------------------------------------------------------
	local stackDiam = 3 * scale
	local stackH = 14 * scale
	local stackTopY = baseY + bodyH + 0.8 * scale + stackH / 2
	local stackSpacing = bodyD / (spec.stacks + 1)
	for i = 1, spec.stacks do
		local stackZ = z - bodyD / 2 + i * stackSpacing
		-- Place stacks toward the back edge of the roof
		local stackX = cx - sign_dir * (bodyW / 2 - 5 * scale)

		local stack = Instance.new("Part")
		stack.Name = "Smokestack"
		stack.Shape = Enum.PartType.Cylinder
		stack.Size = Vector3.new(stackH, stackDiam, stackDiam)
		stack.CFrame = CFrame.new(stackX, stackTopY, stackZ) * CFrame.Angles(0, 0, math.rad(90))
		stack.Anchored = true
		stack.Material = Enum.Material.Metal
		stack.Color = Color3.fromRGB(80, 80, 85)
		stack.Parent = model

		-- Smoke effect at top of stack
		local smokePoint = Instance.new("Part")
		smokePoint.Name = "SmokePoint"
		smokePoint.Size = Vector3.new(1, 1, 1)
		smokePoint.Position = Vector3.new(stackX, baseY + bodyH + 0.8 * scale + stackH, stackZ)
		smokePoint.Anchored = true
		smokePoint.CanCollide = false
		smokePoint.Transparency = 1
		smokePoint.Parent = model

		local smoke = Instance.new("Smoke")
		smoke.Size = 8 + i * 2
		smoke.Opacity = 0.35
		smoke.RiseVelocity = 6
		smoke.Color = Color3.fromRGB(160, 155, 150)
		smoke.Parent = smokePoint
	end

	--------------------------------------------------------------------
	-- Loading bay doors (on road-facing wall)
	--------------------------------------------------------------------
	local bayFaceX = cx - sign_dir * (bodyW / 2 + 0.15)
	for _, bayOff in ipairs({ -5 * scale, 5 * scale }) do
		-- Door recess
		local door = Instance.new("Part")
		door.Name = "LoadingBayDoor"
		door.Size = Vector3.new(0.3 * scale, 8 * scale, 6 * scale)
		door.Position = Vector3.new(bayFaceX, baseY + 4 * scale, z + bayOff)
		door.Anchored = true
		door.Material = Enum.Material.SmoothPlastic
		door.Color = Color3.fromRGB(50, 50, 55)
		door.Parent = model

		-- Hazard warning strip above door
		local strip = Instance.new("Part")
		strip.Name = "HazardStrip"
		strip.Size = Vector3.new(0.35 * scale, 0.6 * scale, 7 * scale)
		strip.Position = Vector3.new(bayFaceX - sign_dir * 0.05, baseY + 8.3 * scale, z + bayOff)
		strip.Anchored = true
		strip.CanCollide = false
		strip.Material = Enum.Material.Neon
		strip.Color = Color3.fromRGB(220, 190, 0)
		strip.Parent = model
	end

	--------------------------------------------------------------------
	-- Windows (small, high, mostly dark — industrial feel)
	--------------------------------------------------------------------
	-- Road-facing wall
	local roadFaceCoord = cx - sign_dir * (bodyW / 2)
	addWindowsToFace(
		model, "x", roadFaceCoord, z,
		bodyD, baseY, 3, bodyH / 3,
		2.0, 1.8, 3.0,
		Color3.fromRGB(200, 170, 80), 0.25
	)
	-- Back wall
	local backFaceCoord = cx + sign_dir * (bodyW / 2)
	addWindowsToFace(
		model, "x", backFaceCoord, z,
		bodyD, baseY, 3, bodyH / 3,
		2.0, 1.8, 3.0,
		Color3.fromRGB(200, 170, 80), 0.25
	)

	--------------------------------------------------------------------
	-- Cargo containers (stacked near building, road-side)
	--------------------------------------------------------------------
	local containerBaseX = cx - sign_dir * (bodyW / 2 + 3 * scale)
	local containerBaseZ = z + bodyD / 2 - 6 * scale
	for i, cSpec in ipairs(spec.containers) do
		local cW = cSpec.w * scale
		local cH = 5 * scale
		local cD = 5 * scale
		-- Stack: first two on ground, third on top of first
		local cX = containerBaseX
		local cZ = containerBaseZ - (i - 1) * 6 * scale
		local cY = baseY + cH / 2
		if i == 3 then
			cZ = containerBaseZ
			cY = baseY + cH + cH / 2
		end

		local container = Instance.new("Part")
		container.Name = "CargoContainer"
		container.Size = Vector3.new(cW, cH, cD)
		container.Position = Vector3.new(cX, cY, cZ)
		container.Anchored = true
		container.Material = Enum.Material.DiamondPlate
		container.Color = cSpec.color
		container.Parent = model

		-- Container ridge (corrugation cap)
		local ridge = Instance.new("Part")
		ridge.Name = "ContainerRidge"
		ridge.Size = Vector3.new(cW + 0.2, 0.4 * scale, cD + 0.2)
		ridge.Position = Vector3.new(cX, cY + cH / 2 + 0.2 * scale, cZ)
		ridge.Anchored = true
		ridge.Material = Enum.Material.Metal
		ridge.Color = Color3.fromRGB(60, 60, 65)
		ridge.Parent = model
	end

	--------------------------------------------------------------------
	-- Factory sign (Neon + SurfaceGui)
	--------------------------------------------------------------------
	local signW = 14 * scale
	local signH = 3 * scale
	local signX = cx - sign_dir * (bodyW / 2 + 0.3)
	local signY = baseY + bodyH - 4 * scale

	local signPart = Instance.new("Part")
	signPart.Name = "FactorySign"
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

	-- PointLight for sign glow
	local signLight = Instance.new("PointLight")
	signLight.Brightness = 1.5
	signLight.Range = 16
	signLight.Color = spec.signColor
	signLight.Parent = signPart

	model.Parent = decorFolder
	return model
end

return Factory
