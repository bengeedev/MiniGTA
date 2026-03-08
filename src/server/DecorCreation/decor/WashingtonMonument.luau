local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local WashingtonMonument = {}

local BUILDING_BASE = DecorUtils.BUILDING_BASE

function WashingtonMonument.createWashingtonMonument(x, z, scale)
	if not DecorUtils.decorFolder then return nil end
	scale = scale or 1

	local model = Instance.new("Model")
	model.Name = "WashingtonMonument"

	local marbleColor = Color3.fromRGB(230, 225, 215)
	local concreteColor = Color3.fromRGB(170, 170, 165)

	-- Base platform: 20x2x20
	local baseW = 20 * scale
	local baseH = 2 * scale
	local base = Instance.new("Part")
	base.Name = "BasePlatform"
	base.Size = Vector3.new(baseW, baseH, baseW)
	base.Position = Vector3.new(x, BUILDING_BASE + baseH / 2, z)
	base.Anchored = true
	base.Material = Enum.Material.Marble
	base.Color = marbleColor
	base.Parent = model

	-- Stepped base: slightly narrower
	local stepW = 16 * scale
	local stepH = 2 * scale
	local step = Instance.new("Part")
	step.Name = "SteppedBase"
	step.Size = Vector3.new(stepW, stepH, stepW)
	step.Position = Vector3.new(x, BUILDING_BASE + baseH + stepH / 2, z)
	step.Anchored = true
	step.Material = Enum.Material.Marble
	step.Color = marbleColor
	step.Parent = model

	-- Tower shaft: 3 stacked sections (12→10.5→9 wide, 80+40+20=140 tall)
	local shaftBase = BUILDING_BASE + baseH + stepH
	local sections = {
		{ width = 12, height = 50 },
		{ width = 10.5, height = 25 },
		{ width = 9, height = 15 },
	}

	local currentY = shaftBase
	for i, sec in ipairs(sections) do
		local w = sec.width * scale
		local h = sec.height * scale
		local shaft = Instance.new("Part")
		shaft.Name = "Shaft" .. i
		shaft.Size = Vector3.new(w, h, w)
		shaft.Position = Vector3.new(x, currentY + h / 2, z)
		shaft.Anchored = true
		shaft.Material = Enum.Material.Marble
		shaft.Color = marbleColor
		shaft.Parent = model
		currentY = currentY + h
	end

	-- Pyramidal cap: 4 WedgeParts
	local capBase = currentY
	local capW = 9 * scale
	local capH = 8 * scale

	-- Front wedge (facing -Z)
	local wedgeFront = Instance.new("WedgePart")
	wedgeFront.Name = "CapFront"
	wedgeFront.Size = Vector3.new(capW, capH, capW / 2)
	wedgeFront.CFrame = CFrame.new(x, capBase + capH / 2, z - capW / 4)
	wedgeFront.Anchored = true
	wedgeFront.Material = Enum.Material.Marble
	wedgeFront.Color = marbleColor
	wedgeFront.Parent = model

	-- Back wedge (facing +Z)
	local wedgeBack = Instance.new("WedgePart")
	wedgeBack.Name = "CapBack"
	wedgeBack.Size = Vector3.new(capW, capH, capW / 2)
	wedgeBack.CFrame = CFrame.new(x, capBase + capH / 2, z + capW / 4) * CFrame.Angles(0, math.pi, 0)
	wedgeBack.Anchored = true
	wedgeBack.Material = Enum.Material.Marble
	wedgeBack.Color = marbleColor
	wedgeBack.Parent = model

	-- Left wedge (facing -X)
	local wedgeLeft = Instance.new("WedgePart")
	wedgeLeft.Name = "CapLeft"
	wedgeLeft.Size = Vector3.new(capW, capH, capW / 2)
	wedgeLeft.CFrame = CFrame.new(x - capW / 4, capBase + capH / 2, z) * CFrame.Angles(0, math.rad(90), 0)
	wedgeLeft.Anchored = true
	wedgeLeft.Material = Enum.Material.Marble
	wedgeLeft.Color = marbleColor
	wedgeLeft.Parent = model

	-- Right wedge (facing +X)
	local wedgeRight = Instance.new("WedgePart")
	wedgeRight.Name = "CapRight"
	wedgeRight.Size = Vector3.new(capW, capH, capW / 2)
	wedgeRight.CFrame = CFrame.new(x + capW / 4, capBase + capH / 2, z) * CFrame.Angles(0, math.rad(-90), 0)
	wedgeRight.Anchored = true
	wedgeRight.Material = Enum.Material.Marble
	wedgeRight.Color = marbleColor
	wedgeRight.Parent = model

	-- Observation windows: 4 small Neon slits near the top (one per face)
	local obsY = capBase - 5 * scale
	local obsW = 3 * scale
	local obsH = 1.5 * scale
	local shaftTopW = 9 * scale

	-- Front/Back observation windows (on Z faces)
	for _, dir in ipairs({-1, 1}) do
		local obs = Instance.new("Part")
		obs.Name = "ObsWindow"
		obs.Size = Vector3.new(obsW, obsH, 0.3 * scale)
		obs.Position = Vector3.new(x, obsY, z + dir * (shaftTopW / 2 + 0.15))
		obs.Anchored = true
		obs.CanCollide = false
		obs.Material = Enum.Material.Neon
		obs.Color = Color3.fromRGB(255, 240, 200)
		obs.Parent = model
	end

	-- Left/Right observation windows (on X faces)
	for _, dir in ipairs({-1, 1}) do
		local obs = Instance.new("Part")
		obs.Name = "ObsWindow"
		obs.Size = Vector3.new(0.3 * scale, obsH, obsW)
		obs.Position = Vector3.new(x + dir * (shaftTopW / 2 + 0.15), obsY, z)
		obs.Anchored = true
		obs.CanCollide = false
		obs.Material = Enum.Material.Neon
		obs.Color = Color3.fromRGB(255, 240, 200)
		obs.Parent = model
	end

	-- Red aviation light at the very tip
	local tipY = capBase + capH + 0.5 * scale
	local tipLight = Instance.new("Part")
	tipLight.Name = "AviationLight"
	tipLight.Shape = Enum.PartType.Ball
	tipLight.Size = Vector3.new(1.5 * scale, 1.5 * scale, 1.5 * scale)
	tipLight.Position = Vector3.new(x, tipY, z)
	tipLight.Anchored = true
	tipLight.CanCollide = false
	tipLight.Material = Enum.Material.Neon
	tipLight.Color = Color3.fromRGB(255, 30, 30)
	tipLight.Parent = model

	local pointLight = Instance.new("PointLight")
	pointLight.Color = Color3.fromRGB(255, 30, 30)
	pointLight.Brightness = 2
	pointLight.Range = 20 * scale
	pointLight.Parent = tipLight

	-- Water pool surrounding the obelisk base
	local poolPad = 8 * scale
	local poolW = baseW + poolPad * 2
	local poolD = baseW + poolPad * 2
	local poolH = 0.6 * scale
	local surfaceY = BUILDING_BASE + 2

	local pool = Instance.new("Part")
	pool.Name = "ReflectingPool"
	pool.Size = Vector3.new(poolW, poolH, poolD)
	pool.Position = Vector3.new(x, surfaceY, z)
	pool.Anchored = true
	pool.CanCollide = false
	pool.Material = Enum.Material.Glass
	pool.Color = Color3.fromRGB(100, 170, 220)
	pool.Transparency = 0.45
	pool.Parent = model

	-- Grass border around the water pool
	local grassW = 4 * scale
	local grassH = 0.5 * scale
	local grassColor = Color3.fromRGB(60, 130, 50)
	local poolHalfW = poolW / 2
	local poolHalfD = poolD / 2

	-- Front and back strips (along X)
	for _, dir in ipairs({-1, 1}) do
		local strip = Instance.new("Part")
		strip.Name = "GrassBorder"
		strip.Size = Vector3.new(poolW + grassW * 2, grassH, grassW)
		strip.Position = Vector3.new(x, surfaceY, z + dir * (poolHalfD + grassW / 2))
		strip.Anchored = true
		strip.CanCollide = false
		strip.Material = Enum.Material.Concrete
		strip.Color = concreteColor
		strip.Parent = model
	end

	-- Left and right strips (along Z)
	for _, dir in ipairs({-1, 1}) do
		local strip = Instance.new("Part")
		strip.Name = "GrassBorder"
		strip.Size = Vector3.new(grassW, grassH, poolD)
		strip.Position = Vector3.new(x + dir * (poolHalfW + grassW / 2), surfaceY, z)
		strip.Anchored = true
		strip.CanCollide = false
		strip.Material = Enum.Material.Concrete
		strip.Color = concreteColor
		strip.Parent = model
	end

	model.Parent = DecorUtils.decorFolder
	return model
end

return WashingtonMonument
