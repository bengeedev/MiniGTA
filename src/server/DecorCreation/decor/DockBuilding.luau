-- DockBuilding.luau
-- Industrial dock warehouses for the Manhattan harbor theme.
-- Large corrugated metal / brick warehouses with loading bays and windows.

local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local DockBuilding = {}

--------------------------------------------------------------------------------
-- PALETTES (wall body + metal trim + accent light + wall material)
--------------------------------------------------------------------------------

local PALETTES = {
	{ body = Color3.fromRGB(140, 65, 55),  trim = Color3.fromRGB(70, 70, 75),  accent = Color3.fromRGB(255, 180, 80),  mat = Enum.Material.Brick },           -- red brick
	{ body = Color3.fromRGB(85, 85, 90),   trim = Color3.fromRGB(55, 55, 60),  accent = Color3.fromRGB(200, 220, 255), mat = Enum.Material.Concrete },         -- gray concrete
	{ body = Color3.fromRGB(120, 80, 50),  trim = Color3.fromRGB(80, 60, 45),  accent = Color3.fromRGB(255, 200, 100), mat = Enum.Material.CorrodedMetal },  -- rust brown
	{ body = Color3.fromRGB(50, 65, 95),   trim = Color3.fromRGB(40, 45, 55),  accent = Color3.fromRGB(140, 200, 255), mat = Enum.Material.CorrodedMetal },  -- dark blue steel
	{ body = Color3.fromRGB(75, 85, 60),   trim = Color3.fromRGB(50, 55, 45),  accent = Color3.fromRGB(180, 255, 140), mat = Enum.Material.CorrodedMetal },  -- olive green
	{ body = Color3.fromRGB(170, 155, 130),trim = Color3.fromRGB(90, 85, 75),  accent = Color3.fromRGB(255, 230, 170), mat = Enum.Material.Brick },            -- weathered tan
}

--------------------------------------------------------------------------------
-- BUILDER
--------------------------------------------------------------------------------

function DockBuilding.create(x, z, scale, offsetY, paletteIndex)
	local palette = PALETTES[paletteIndex or math.random(1, #PALETTES)]
	scale = scale or 1
	offsetY = offsetY or 0
	local baseY = DecorUtils.TERRAIN_TOP + offsetY

	-- Dimensions (large industrial warehouse)
	local bodyW = 30 * scale
	local bodyD = 20 * scale
	local floorH = 5 * scale
	local floors = 3
	local bodyH = floors * floorH

	local model = Instance.new("Model")
	model.Name = "DockBuilding"

	-- Concrete foundation (fills gap between terrain and raised building)
	if offsetY > 0 then
		local foundation = Instance.new("Part")
		foundation.Name = "Foundation"
		foundation.Size = Vector3.new(bodyW + 1 * scale, offsetY, bodyD + 1 * scale)
		foundation.Position = Vector3.new(x, DecorUtils.TERRAIN_TOP + offsetY / 2, z)
		foundation.Anchored = true
		foundation.CanCollide = true
		foundation.Material = Enum.Material.Concrete
		foundation.Color = Color3.fromRGB(100, 100, 105)
		foundation.Parent = model
	end

	-- Main body
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(bodyW, bodyH, bodyD)
	body.Position = Vector3.new(x, baseY + bodyH / 2, z)
	body.Anchored = true
	body.CanCollide = true
	body.Material = palette.mat
	body.Color = palette.body
	body.Parent = model

	-- Metal base strip (wainscoting along bottom)
	local baseStrip = Instance.new("Part")
	baseStrip.Name = "BaseStrip"
	baseStrip.Size = Vector3.new(bodyW + 0.4 * scale, 1.5 * scale, bodyD + 0.4 * scale)
	baseStrip.Position = Vector3.new(x, baseY + 0.75 * scale, z)
	baseStrip.Anchored = true
	baseStrip.CanCollide = false
	baseStrip.Material = Enum.Material.Metal
	baseStrip.Color = palette.trim
	baseStrip.Parent = model

	-- Metal roof (flat with overhang)
	local roof = Instance.new("Part")
	roof.Name = "Roof"
	roof.Size = Vector3.new(bodyW + 2 * scale, 0.6 * scale, bodyD + 2 * scale)
	roof.Position = Vector3.new(x, baseY + bodyH + 0.3 * scale, z)
	roof.Anchored = true
	roof.CanCollide = false
	roof.Material = Enum.Material.Metal
	roof.Color = palette.trim
	roof.Parent = model

	-- Roof ventilation units (3 box units on top)
	for i = -1, 1 do
		local vent = Instance.new("Part")
		vent.Name = "RoofVent"
		vent.Size = Vector3.new(3.5 * scale, 2 * scale, 2.5 * scale)
		vent.Position = Vector3.new(x + i * 8 * scale, baseY + bodyH + 1.3 * scale, z)
		vent.Anchored = true
		vent.CanCollide = false
		vent.Material = Enum.Material.Metal
		vent.Color = palette.trim
		vent.Parent = model
	end

	-- Loading bay doors on front face (ground floor, 3 rolling doors)
	local frontFace = z + bodyD / 2 + 0.05
	local doorH = floorH * 0.8
	local doorW = 6 * scale
	for _, dx in ipairs({-8 * scale, 0, 8 * scale}) do
		local door = Instance.new("Part")
		door.Name = "LoadingDoor"
		door.Size = Vector3.new(doorW, doorH, 0.3)
		door.Position = Vector3.new(x + dx, baseY + doorH / 2, frontFace)
		door.Anchored = true
		door.CanCollide = false
		door.Material = Enum.Material.DiamondPlate
		door.Color = palette.trim
		door.Parent = model

		-- Accent strip above each door
		local frame = Instance.new("Part")
		frame.Name = "DoorFrame"
		frame.Size = Vector3.new(doorW + 0.8 * scale, 0.4 * scale, 0.15)
		frame.Position = Vector3.new(x + dx, baseY + doorH + 0.2 * scale, frontFace + 0.1)
		frame.Anchored = true
		frame.CanCollide = false
		frame.Material = Enum.Material.Neon
		frame.Color = palette.accent
		frame.Parent = model
	end

	-- Windows on upper floors (front face)
	local litColor = Color3.fromRGB(220, 230, 245)
	DecorUtils.addWindowsToFace(
		model, "z", frontFace,
		x, bodyW,
		baseY + floorH, floors - 1, floorH,
		3.0 * scale, 2.0 * scale, 2.0 * scale,
		litColor, 0.5
	)

	-- Windows on side faces (all floors)
	for _, side in ipairs({-1, 1}) do
		local sideFace = x + side * bodyW / 2 + side * 0.05
		DecorUtils.addWindowsToFace(
			model, "x", sideFace,
			z, bodyD,
			baseY, floors, floorH,
			3.0 * scale, 2.0 * scale, 2.0 * scale,
			litColor, 0.4
		)
	end

	-- Horizontal accent strip at roofline (front + back faces)
	for _, fz in ipairs({frontFace, z - bodyD / 2 - 0.05}) do
		local strip = Instance.new("Part")
		strip.Name = "RoofStrip"
		strip.Size = Vector3.new(bodyW + 0.4 * scale, 0.35 * scale, 0.15)
		strip.Position = Vector3.new(x, baseY + bodyH, fz)
		strip.Anchored = true
		strip.CanCollide = false
		strip.Material = Enum.Material.Neon
		strip.Color = palette.accent
		strip.Parent = model
	end

	-- Floor division strips on front face (between floors 1-2 and 2-3)
	for floor = 1, floors - 1 do
		local divStrip = Instance.new("Part")
		divStrip.Name = "FloorDiv"
		divStrip.Size = Vector3.new(bodyW + 0.2 * scale, 0.25 * scale, 0.15)
		divStrip.Position = Vector3.new(x, baseY + floor * floorH, frontFace)
		divStrip.Anchored = true
		divStrip.CanCollide = false
		divStrip.Material = Enum.Material.Metal
		divStrip.Color = palette.trim
		divStrip.Parent = model
	end

	model.PrimaryPart = body
	model.Parent = DecorUtils.decorFolder
	return model
end

-- Convenience wrappers for each palette
function DockBuilding.createBrick(x, z, scale, offsetY)
	return DockBuilding.create(x, z, scale, offsetY, 1)
end

function DockBuilding.createConcrete(x, z, scale, offsetY)
	return DockBuilding.create(x, z, scale, offsetY, 2)
end

function DockBuilding.createRust(x, z, scale, offsetY)
	return DockBuilding.create(x, z, scale, offsetY, 3)
end

function DockBuilding.createBlueSteel(x, z, scale, offsetY)
	return DockBuilding.create(x, z, scale, offsetY, 4)
end

function DockBuilding.createOlive(x, z, scale, offsetY)
	return DockBuilding.create(x, z, scale, offsetY, 5)
end

function DockBuilding.createTan(x, z, scale, offsetY)
	return DockBuilding.create(x, z, scale, offsetY, 6)
end

function DockBuilding.createRandom(x, z, scale, offsetY)
	return DockBuilding.create(x, z, scale, offsetY)
end

return DockBuilding
