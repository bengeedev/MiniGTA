-- MiamiBuilding.luau
-- Art Deco Miami-style buildings with pastel colors, windows, and neon accent strips.

local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local MiamiBuilding = {}

--------------------------------------------------------------------------------
-- PALETTES (pastel body + neon accent color)
--------------------------------------------------------------------------------

local PALETTES = {
	{ body = Color3.fromRGB(230, 180, 180), trim = Color3.fromRGB(255, 255, 255), neon = Color3.fromRGB(255, 180, 100) },  -- pink / warm gold
	{ body = Color3.fromRGB(170, 220, 200), trim = Color3.fromRGB(255, 255, 255), neon = Color3.fromRGB(100, 255, 200) },  -- mint / teal
	{ body = Color3.fromRGB(240, 230, 190), trim = Color3.fromRGB(255, 255, 255), neon = Color3.fromRGB(255, 220, 130) },  -- cream / gold
	{ body = Color3.fromRGB(220, 170, 160), trim = Color3.fromRGB(255, 255, 255), neon = Color3.fromRGB(255, 140, 100) },  -- coral / warm orange
	{ body = Color3.fromRGB(200, 190, 230), trim = Color3.fromRGB(255, 255, 255), neon = Color3.fromRGB(180, 140, 255) },  -- lavender / purple
	{ body = Color3.fromRGB(180, 210, 240), trim = Color3.fromRGB(255, 255, 255), neon = Color3.fromRGB(100, 200, 255) },  -- pale blue / cyan
}

--------------------------------------------------------------------------------
-- BUILDER
--------------------------------------------------------------------------------

function MiamiBuilding.create(x, z, scale, offsetY, paletteIndex)
	local palette = PALETTES[paletteIndex or math.random(1, #PALETTES)]
	scale = scale or 1
	offsetY = offsetY or 0
	local baseY = DecorUtils.TERRAIN_TOP + offsetY

	-- Dimensions
	local bodyW = 18 * scale
	local bodyD = 12 * scale
	local floorH = 4 * scale
	local mainFloors = 4
	local towerFloors = 2   -- extra floors for central tower
	local mainH = mainFloors * floorH
	local towerW = 8 * scale
	local towerH = towerFloors * floorH
	local totalH = mainH + towerH

	local model = Instance.new("Model")
	model.Name = "MiamiBuilding"

	-- Main body
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(bodyW, mainH, bodyD)
	body.Position = Vector3.new(x, baseY + mainH / 2, z)
	body.Anchored = true
	body.CanCollide = true
	body.Material = Enum.Material.Concrete
	body.Color = palette.body
	body.Parent = model

	-- Central tower (extends above main body)
	local tower = Instance.new("Part")
	tower.Name = "Tower"
	tower.Size = Vector3.new(towerW, towerH, bodyD * 0.7)
	tower.Position = Vector3.new(x, baseY + mainH + towerH / 2, z)
	tower.Anchored = true
	tower.CanCollide = true
	tower.Material = Enum.Material.Concrete
	tower.Color = palette.body
	tower.Parent = model

	-- Tower cap (small decorative element on top)
	local cap = Instance.new("Part")
	cap.Name = "TowerCap"
	cap.Size = Vector3.new(towerW + 1 * scale, 0.6 * scale, bodyD * 0.7 + 1 * scale)
	cap.Position = Vector3.new(x, baseY + totalH + 0.3 * scale, z)
	cap.Anchored = true
	cap.CanCollide = false
	cap.Material = Enum.Material.Concrete
	cap.Color = palette.trim
	cap.Parent = model

	-- Roof parapet on main body (left and right wings)
	for _, side in ipairs({-1, 1}) do
		local wingW = (bodyW - towerW) / 2
		local wingX = x + side * (towerW / 2 + wingW / 2)
		local parapet = Instance.new("Part")
		parapet.Name = "Parapet" .. (side == -1 and "L" or "R")
		parapet.Size = Vector3.new(wingW, 0.8 * scale, bodyD)
		parapet.Position = Vector3.new(wingX, baseY + mainH + 0.4 * scale, z)
		parapet.Anchored = true
		parapet.CanCollide = false
		parapet.Material = Enum.Material.Concrete
		parapet.Color = palette.trim
		parapet.Parent = model
	end

	-- Horizontal neon accent strips (Art Deco signature)
	-- One strip per floor on the front face + one at roof line
	local frontFace = z + bodyD / 2 + 0.05
	for floor = 1, mainFloors do
		local stripY = baseY + floor * floorH
		local strip = Instance.new("Part")
		strip.Name = "NeonStrip"
		strip.Size = Vector3.new(bodyW + 0.4 * scale, 0.25 * scale, 0.15)
		strip.Position = Vector3.new(x, stripY, frontFace)
		strip.Anchored = true
		strip.CanCollide = false
		strip.Material = Enum.Material.Neon
		strip.Color = palette.neon
		strip.Parent = model
	end

	-- Tower neon strips
	for floor = 1, towerFloors do
		local stripY = baseY + mainH + floor * floorH
		local strip = Instance.new("Part")
		strip.Name = "NeonStrip"
		strip.Size = Vector3.new(towerW + 0.4 * scale, 0.25 * scale, 0.15)
		strip.Position = Vector3.new(x, stripY, frontFace)
		strip.Anchored = true
		strip.CanCollide = false
		strip.Material = Enum.Material.Neon
		strip.Color = palette.neon
		strip.Parent = model
	end

	-- Vertical neon accents on tower edges (Art Deco pillars)
	for _, side in ipairs({-1, 1}) do
		local pillar = Instance.new("Part")
		pillar.Name = "NeonPillar"
		pillar.Size = Vector3.new(0.3 * scale, totalH, 0.3 * scale)
		pillar.Position = Vector3.new(x + side * towerW / 2, baseY + totalH / 2, frontFace)
		pillar.Anchored = true
		pillar.CanCollide = false
		pillar.Material = Enum.Material.Neon
		pillar.Color = palette.neon
		pillar.Parent = model

		-- Also on main body corners
		local cornerPillar = Instance.new("Part")
		cornerPillar.Name = "NeonCorner"
		cornerPillar.Size = Vector3.new(0.3 * scale, mainH, 0.3 * scale)
		cornerPillar.Position = Vector3.new(x + side * bodyW / 2, baseY + mainH / 2, frontFace)
		cornerPillar.Anchored = true
		cornerPillar.CanCollide = false
		cornerPillar.Material = Enum.Material.Neon
		cornerPillar.Color = palette.neon
		cornerPillar.Parent = model
	end

	-- Ground floor entrance (darker recessed area)
	local entranceW = 4 * scale
	local entranceH = floorH * 0.85
	local entrance = Instance.new("Part")
	entrance.Name = "Entrance"
	entrance.Size = Vector3.new(entranceW, entranceH, 0.4)
	entrance.Position = Vector3.new(x, baseY + entranceH / 2, frontFace + 0.1)
	entrance.Anchored = true
	entrance.CanCollide = false
	entrance.Material = Enum.Material.Glass
	entrance.Color = Color3.fromRGB(40, 60, 80)
	entrance.Transparency = 0.3
	entrance.Parent = model

	-- Windows on front face (main body, starting floor 2)
	local litColor = Color3.fromRGB(255, 240, 200)  -- warm light
	DecorUtils.addWindowsToFace(
		model, "z", frontFace,
		x, bodyW,
		baseY, mainFloors, floorH,
		2.0 * scale, 2.5 * scale, 1.5 * scale,
		litColor, 0.6
	)

	-- Windows on tower front face
	DecorUtils.addWindowsToFace(
		model, "z", frontFace,
		x, towerW,
		baseY + mainH, towerFloors, floorH,
		2.0 * scale, 2.5 * scale, 1.5 * scale,
		litColor, 0.7
	)

	-- Windows on side faces
	for _, side in ipairs({-1, 1}) do
		local sideFace = x + side * bodyW / 2 + side * 0.05
		DecorUtils.addWindowsToFace(
			model, "x", sideFace,
			z, bodyD,
			baseY, mainFloors, floorH,
			2.0 * scale, 2.5 * scale, 1.5 * scale,
			litColor, 0.45
		)
	end

	model.PrimaryPart = body
	model.Parent = DecorUtils.decorFolder
	return model
end

-- Convenience wrappers for each palette (for PROCEDURAL_BUILDERS)
function MiamiBuilding.createPink(x, z, scale, offsetY)
	return MiamiBuilding.create(x, z, scale, offsetY, 1)
end

function MiamiBuilding.createMint(x, z, scale, offsetY)
	return MiamiBuilding.create(x, z, scale, offsetY, 2)
end

function MiamiBuilding.createCream(x, z, scale, offsetY)
	return MiamiBuilding.create(x, z, scale, offsetY, 3)
end

function MiamiBuilding.createCoral(x, z, scale, offsetY)
	return MiamiBuilding.create(x, z, scale, offsetY, 4)
end

function MiamiBuilding.createLavender(x, z, scale, offsetY)
	return MiamiBuilding.create(x, z, scale, offsetY, 5)
end

function MiamiBuilding.createBlue(x, z, scale, offsetY)
	return MiamiBuilding.create(x, z, scale, offsetY, 6)
end

-- Random palette
function MiamiBuilding.createRandom(x, z, scale, offsetY)
	return MiamiBuilding.create(x, z, scale, offsetY)
end

return MiamiBuilding
