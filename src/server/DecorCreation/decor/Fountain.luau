-- Fountain: modern rectangular glass basin with water
local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local Fountain = {}

function Fountain.createFountain(x, z, scale)
	local decorFolder = DecorUtils.decorFolder
	if not decorFolder then return nil end
	scale = scale or 1

	local BUILDING_BASE = DecorUtils.BUILDING_BASE

	local model = Instance.new("Model")
	model.Name = "Fountain"

	local baseY = BUILDING_BASE

	-- Basin dimensions: wide rectangle
	local basinW = 30 * scale -- along X (across the lane)
	local basinD = 18 * scale -- along Z (along the lane)
	local wallH = 5 * scale
	local wallThick = 0.5 * scale
	local glassColor = Color3.fromRGB(180, 220, 250)
	local frameColor = Color3.fromRGB(170, 170, 175)

	-- Concrete base slab (slightly larger than basin)
	local slab = Instance.new("Part")
	slab.Name = "BaseSlab"
	slab.Size = Vector3.new(basinW + 2, 0.4, basinD + 2)
	slab.Position = Vector3.new(x, baseY + 0.2, z)
	slab.Anchored = true
	slab.Material = Enum.Material.SmoothPlastic
	slab.Color = Color3.fromRGB(210, 205, 200)
	slab.Parent = model

	local floorY = baseY + 0.4

	-- Glass walls: 4 sides
	for dz = -1, 1, 2 do
		local wall = Instance.new("Part")
		wall.Name = "BasinWall"
		wall.Size = Vector3.new(basinW, wallH, wallThick)
		wall.Position = Vector3.new(x, floorY + wallH / 2, z + dz * (basinD / 2))
		wall.Anchored = true
		wall.Material = Enum.Material.Glass
		wall.Color = glassColor
		wall.Transparency = 0.35
		wall:SetAttribute("ThemeRole", "shop_glass")
		wall:SetAttribute("BaseColor", glassColor)
		wall.Parent = model
	end
	for dx = -1, 1, 2 do
		local wall = Instance.new("Part")
		wall.Name = "BasinWall"
		wall.Size = Vector3.new(wallThick, wallH, basinD)
		wall.Position = Vector3.new(x + dx * (basinW / 2), floorY + wallH / 2, z)
		wall.Anchored = true
		wall.Material = Enum.Material.Glass
		wall.Color = glassColor
		wall.Transparency = 0.35
		wall:SetAttribute("ThemeRole", "shop_glass")
		wall:SetAttribute("BaseColor", glassColor)
		wall.Parent = model
	end

	-- Steel corner posts
	local postThick = 0.4 * scale
	for dx = -1, 1, 2 do
		for dz = -1, 1, 2 do
			local post = Instance.new("Part")
			post.Name = "CornerPost"
			post.Size = Vector3.new(postThick, wallH + 0.3, postThick)
			post.Position = Vector3.new(
				x + dx * (basinW / 2),
				floorY + wallH / 2,
				z + dz * (basinD / 2)
			)
			post.Anchored = true
			post.Material = Enum.Material.DiamondPlate
			post.Color = frameColor
			post:SetAttribute("ThemeRole", "shop_mullion")
			post:SetAttribute("BaseColor", frameColor)
			post.Parent = model
		end
	end

	-- Top rim rails
	local rimY = floorY + wallH
	for dz = -1, 1, 2 do
		local rail = Instance.new("Part")
		rail.Name = "TopRail"
		rail.Size = Vector3.new(basinW + postThick, postThick * 0.8, postThick * 0.8)
		rail.Position = Vector3.new(x, rimY, z + dz * (basinD / 2))
		rail.Anchored = true
		rail.Material = Enum.Material.DiamondPlate
		rail.Color = frameColor
		rail:SetAttribute("ThemeRole", "shop_mullion")
		rail:SetAttribute("BaseColor", frameColor)
		rail.Parent = model
	end
	for dx = -1, 1, 2 do
		local rail = Instance.new("Part")
		rail.Name = "TopRail"
		rail.Size = Vector3.new(postThick * 0.8, postThick * 0.8, basinD + postThick)
		rail.Position = Vector3.new(x + dx * (basinW / 2), rimY, z)
		rail.Anchored = true
		rail.Material = Enum.Material.DiamondPlate
		rail.Color = frameColor
		rail:SetAttribute("ThemeRole", "shop_mullion")
		rail:SetAttribute("BaseColor", frameColor)
		rail.Parent = model
	end

	-- Neon accent strips along the base of each wall
	local neonH = 0.4 * scale
	local neonColor = Color3.fromRGB(140, 200, 255)
	for dz = -1, 1, 2 do
		local strip = Instance.new("Part")
		strip.Name = "NeonStrip"
		strip.Size = Vector3.new(basinW - postThick * 2, neonH, 0.15)
		strip.Position = Vector3.new(x, floorY + neonH / 2, z + dz * (basinD / 2 - wallThick / 2))
		strip.Anchored = true
		strip.CanCollide = false
		strip.Material = Enum.Material.Neon
		strip.Color = neonColor
		strip:SetAttribute("ThemeRole", "shop_sign")
		strip:SetAttribute("BaseColor", neonColor)
		strip.Parent = model
	end
	for dx = -1, 1, 2 do
		local strip = Instance.new("Part")
		strip.Name = "NeonStrip"
		strip.Size = Vector3.new(0.15, neonH, basinD - postThick * 2)
		strip.Position = Vector3.new(x + dx * (basinW / 2 - wallThick / 2), floorY + neonH / 2, z)
		strip.Anchored = true
		strip.CanCollide = false
		strip.Material = Enum.Material.Neon
		strip.Color = neonColor
		strip:SetAttribute("ThemeRole", "shop_sign")
		strip:SetAttribute("BaseColor", neonColor)
		strip.Parent = model
	end

	-- Neon accent strips along the top rim
	for dz = -1, 1, 2 do
		local strip = Instance.new("Part")
		strip.Name = "NeonStripTop"
		strip.Size = Vector3.new(basinW - postThick * 2, neonH, 0.15)
		strip.Position = Vector3.new(x, rimY - neonH / 2, z + dz * (basinD / 2 - wallThick / 2))
		strip.Anchored = true
		strip.CanCollide = false
		strip.Material = Enum.Material.Neon
		strip.Color = neonColor
		strip:SetAttribute("ThemeRole", "shop_sign")
		strip:SetAttribute("BaseColor", neonColor)
		strip.Parent = model
	end
	for dx = -1, 1, 2 do
		local strip = Instance.new("Part")
		strip.Name = "NeonStripTop"
		strip.Size = Vector3.new(0.15, neonH, basinD - postThick * 2)
		strip.Position = Vector3.new(x + dx * (basinW / 2 - wallThick / 2), rimY - neonH / 2, z)
		strip.Anchored = true
		strip.CanCollide = false
		strip.Material = Enum.Material.Neon
		strip.Color = neonColor
		strip:SetAttribute("ThemeRole", "shop_sign")
		strip:SetAttribute("BaseColor", neonColor)
		strip.Parent = model
	end

	-- Basin floor (light tiled look)
	local basinFloor = Instance.new("Part")
	basinFloor.Name = "BasinFloor"
	basinFloor.Size = Vector3.new(basinW - wallThick * 2, 0.3, basinD - wallThick * 2)
	basinFloor.Position = Vector3.new(x, floorY + 0.15, z)
	basinFloor.Anchored = true
	basinFloor.Material = Enum.Material.SmoothPlastic
	basinFloor.Color = Color3.fromRGB(190, 210, 220)
	basinFloor:SetAttribute("ThemeRole", "shop_floor")
	basinFloor:SetAttribute("BaseColor", basinFloor.Color)
	basinFloor.Parent = model

	-- Water surface (glass part — reliable at any size)
	local waterH = wallH * 0.65
	local water = Instance.new("Part")
	water.Name = "Water"
	water.Size = Vector3.new(basinW - wallThick * 2 - 0.2, waterH, basinD - wallThick * 2 - 0.2)
	water.Position = Vector3.new(x, floorY + 0.3 + waterH / 2, z)
	water.Anchored = true
	water.CanCollide = false
	water.Material = Enum.Material.Glass
	water.Color = Color3.fromRGB(100, 170, 220)
	water.Transparency = 0.45
	water.Parent = model

	-- Underwater light
	local lightPart = Instance.new("Part")
	lightPart.Name = "UnderwaterLight"
	lightPart.Size = Vector3.new(1, 0.2, 1)
	lightPart.Position = Vector3.new(x, floorY + 0.5, z)
	lightPart.Anchored = true
	lightPart.CanCollide = false
	lightPart.Transparency = 1
	lightPart.Parent = model

	local underwaterLight = Instance.new("PointLight")
	underwaterLight.Color = Color3.fromRGB(120, 190, 255)
	underwaterLight.Brightness = 1.2
	underwaterLight.Range = 18
	underwaterLight.Parent = lightPart

	-- Water jet (ParticleEmitter from center of basin)
	local jetBase = Instance.new("Part")
	jetBase.Name = "JetEmitter"
	jetBase.Size = Vector3.new(1, 0.2, 1)
	jetBase.Position = Vector3.new(x, floorY + wallH * 0.65 + 0.5, z)
	jetBase.Anchored = true
	jetBase.CanCollide = false
	jetBase.Transparency = 1
	jetBase.Parent = model

	local jet = Instance.new("ParticleEmitter")
	jet.Name = "WaterJet"
	jet.Rate = 80
	jet.Lifetime = NumberRange.new(1.2, 1.8)
	jet.Speed = NumberRange.new(22, 28)
	jet.SpreadAngle = Vector2.new(4, 4)
	jet.EmissionDirection = Enum.NormalId.Top
	jet.Acceleration = Vector3.new(0, -35, 0)
	jet.Drag = 1
	jet.LightEmission = 0.5
	jet.LightInfluence = 0.6
	jet.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3 * scale),
		NumberSequenceKeypoint.new(0.3, 0.8 * scale),
		NumberSequenceKeypoint.new(1, 0.2 * scale),
	})
	jet.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(0.5, 0.3),
		NumberSequenceKeypoint.new(1, 1),
	})
	jet.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 230, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 210, 250)),
	})
	jet.RotSpeed = NumberRange.new(-30, 30)
	jet.Orientation = Enum.ParticleOrientation.FacingCamera
	jet.Parent = jetBase

	-- Water pool surrounding the fountain (shallow water square)
	local waterPadding = 3 * scale
	local poolW = basinW + 2 + waterPadding * 2
	local poolD = basinD + 2 + waterPadding * 2
	local poolH = 0.6
	local surfaceY = baseY + 2 -- above terrain voxels

	local pool = Instance.new("Part")
	pool.Name = "SurroundingWater"
	pool.Size = Vector3.new(poolW, poolH, poolD)
	pool.Position = Vector3.new(x, surfaceY, z)
	pool.Anchored = true
	pool.CanCollide = false
	pool.Material = Enum.Material.Glass
	pool.Color = Color3.fromRGB(100, 170, 220)
	pool.Transparency = 0.45
	pool.Parent = model

	-- Grass border around the water pool
	local grassW = 2.5 * scale
	local grassH = 0.6
	local grassY = surfaceY
	local grassColor = Color3.fromRGB(70, 140, 60)
	local poolHalfW = poolW / 2
	local poolHalfD = poolD / 2

	-- Front and back strips (along X)
	for dz = -1, 1, 2 do
		local strip = Instance.new("Part")
		strip.Name = "GrassBorder"
		strip.Size = Vector3.new(poolW + grassW * 2, grassH, grassW)
		strip.Position = Vector3.new(x, grassY, z + dz * (poolHalfD + grassW / 2))
		strip.Anchored = true
		strip.CanCollide = false
		strip.Material = Enum.Material.LeafyGrass
		strip.Color = grassColor
		strip.Parent = model
	end

	-- Left and right strips (along Z)
	for dx = -1, 1, 2 do
		local strip = Instance.new("Part")
		strip.Name = "GrassBorder"
		strip.Size = Vector3.new(grassW, grassH, poolD)
		strip.Position = Vector3.new(x + dx * (poolHalfW + grassW / 2), grassY, z)
		strip.Anchored = true
		strip.CanCollide = false
		strip.Material = Enum.Material.LeafyGrass
		strip.Color = grassColor
		strip.Parent = model
	end

	model.Parent = decorFolder
	return model
end

return Fountain
