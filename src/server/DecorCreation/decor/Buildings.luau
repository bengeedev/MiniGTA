local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local Buildings = {}

local BUILDING_BASE = DecorUtils.BUILDING_BASE
local addWindowsToFace = DecorUtils.addWindowsToFace

--------------------------------------------------------------------------------
-- Deterministic building row definitions — each building hand-designed
-- LEFT side (x < 0): warm tones, brick-heavy
--------------------------------------------------------------------------------

local LEFT_ROW = {
	{ facade = 22, floors = 8,  color = Color3.fromRGB(200, 190, 170), mat = Enum.Material.Concrete,      winColor = Color3.fromRGB(255, 220, 140), litPct = 0.55, winW = 2.5, winH = 4.0, entrance = true },
	{ facade = 18, floors = 11, color = Color3.fromRGB(145, 100, 80),  mat = Enum.Material.Brick,          winColor = Color3.fromRGB(200, 230, 255), litPct = 0.40, winW = 2.0, winH = 3.5 },
	{ facade = 26, floors = 5,  color = Color3.fromRGB(210, 200, 185), mat = Enum.Material.SmoothPlastic,  winColor = Color3.fromRGB(255, 200, 100), litPct = 0.60, winW = 3.0, winH = 4.5 },
	{ facade = 16, floors = 9,  color = Color3.fromRGB(155, 145, 135), mat = Enum.Material.Slate,          winColor = Color3.fromRGB(180, 210, 255), litPct = 0.35, winW = 2.0, winH = 3.0 },
	{ facade = 22, floors = 12, color = Color3.fromRGB(190, 140, 100), mat = Enum.Material.Brick,          winColor = Color3.fromRGB(255, 220, 140), litPct = 0.50, winW = 2.5, winH = 4.0 },
	{ facade = 20, floors = 6,  color = Color3.fromRGB(220, 215, 205), mat = Enum.Material.Concrete,       winColor = Color3.fromRGB(255, 180, 120), litPct = 0.45, winW = 2.8, winH = 3.5 },
	{ facade = 24, floors = 10, color = Color3.fromRGB(165, 120, 90),  mat = Enum.Material.Brick,          winColor = Color3.fromRGB(200, 230, 255), litPct = 0.55, winW = 2.2, winH = 4.0 },
	{ facade = 18, floors = 7,  color = Color3.fromRGB(180, 170, 155), mat = Enum.Material.Slate,          winColor = Color3.fromRGB(255, 200, 100), litPct = 0.30, winW = 2.0, winH = 3.0 },
	{ facade = 28, floors = 11, color = Color3.fromRGB(200, 190, 170), mat = Enum.Material.Concrete,       winColor = Color3.fromRGB(180, 210, 255), litPct = 0.50, winW = 3.0, winH = 4.5 },
	{ facade = 16, floors = 8,  color = Color3.fromRGB(210, 200, 185), mat = Enum.Material.SmoothPlastic,  winColor = Color3.fromRGB(255, 220, 140), litPct = 0.40, winW = 2.0, winH = 3.5 },
}

-- RIGHT side (x > 0): cooler tones, more concrete/slate
local RIGHT_ROW = {
	{ facade = 22, floors = 8,  color = Color3.fromRGB(145, 100, 80),  mat = Enum.Material.Brick,           winColor = Color3.fromRGB(200, 230, 255), litPct = 0.55, winW = 2.5, winH = 4.0, entrance = true },
	{ facade = 20, floors = 6,  color = Color3.fromRGB(165, 120, 90),  mat = Enum.Material.Brick,          winColor = Color3.fromRGB(255, 200, 100), litPct = 0.45, winW = 2.8, winH = 3.5 },
	{ facade = 16, floors = 12, color = Color3.fromRGB(220, 215, 205), mat = Enum.Material.SmoothPlastic,  winColor = Color3.fromRGB(255, 220, 140), litPct = 0.35, winW = 2.0, winH = 3.0 },
	{ facade = 24, floors = 7,  color = Color3.fromRGB(200, 190, 170), mat = Enum.Material.Concrete,       winColor = Color3.fromRGB(255, 180, 120), litPct = 0.50, winW = 3.0, winH = 4.0 },
	{ facade = 18, floors = 10, color = Color3.fromRGB(145, 100, 80),  mat = Enum.Material.Brick,          winColor = Color3.fromRGB(180, 210, 255), litPct = 0.40, winW = 2.2, winH = 3.5 },
	{ facade = 26, floors = 5,  color = Color3.fromRGB(190, 140, 100), mat = Enum.Material.Slate,          winColor = Color3.fromRGB(200, 230, 255), litPct = 0.55, winW = 2.5, winH = 4.5 },
	{ facade = 20, floors = 9,  color = Color3.fromRGB(210, 200, 185), mat = Enum.Material.Concrete,       winColor = Color3.fromRGB(255, 200, 100), litPct = 0.45, winW = 2.0, winH = 4.0 },
	{ facade = 22, floors = 11, color = Color3.fromRGB(155, 145, 135), mat = Enum.Material.Brick,          winColor = Color3.fromRGB(255, 220, 140), litPct = 0.50, winW = 2.5, winH = 3.5 },
	{ facade = 16, floors = 6,  color = Color3.fromRGB(180, 170, 155), mat = Enum.Material.SmoothPlastic,  winColor = Color3.fromRGB(255, 180, 120), litPct = 0.35, winW = 2.0, winH = 3.0 },
	{ facade = 24, floors = 8,  color = Color3.fromRGB(165, 120, 90),  mat = Enum.Material.Slate,          winColor = Color3.fromRGB(180, 210, 255), litPct = 0.60, winW = 3.0, winH = 4.5 },
}

--------------------------------------------------------------------------------
-- VARIATION 2: INDUSTRIAL — steel, concrete, metal tones
--------------------------------------------------------------------------------

local LEFT_ROW_2 = {
	{ facade = 24, floors = 9,  color = Color3.fromRGB(100, 105, 115), mat = Enum.Material.Metal,         winColor = Color3.fromRGB(200, 230, 255), litPct = 0.50, winW = 2.8, winH = 4.2, entrance = true },
	{ facade = 20, floors = 7,  color = Color3.fromRGB(140, 135, 125), mat = Enum.Material.Concrete,      winColor = Color3.fromRGB(255, 200, 100), litPct = 0.35, winW = 2.2, winH = 3.5 },
	{ facade = 16, floors = 13, color = Color3.fromRGB(130, 90, 70),   mat = Enum.Material.Brick,         winColor = Color3.fromRGB(180, 210, 255), litPct = 0.45, winW = 2.0, winH = 3.0 },
	{ facade = 28, floors = 6,  color = Color3.fromRGB(75, 75, 80),    mat = Enum.Material.SmoothPlastic, winColor = Color3.fromRGB(255, 220, 140), litPct = 0.55, winW = 3.2, winH = 4.5 },
	{ facade = 18, floors = 10, color = Color3.fromRGB(90, 95, 100),   mat = Enum.Material.Metal,         winColor = Color3.fromRGB(200, 230, 255), litPct = 0.40, winW = 2.0, winH = 3.5 },
	{ facade = 22, floors = 8,  color = Color3.fromRGB(120, 115, 110), mat = Enum.Material.Concrete,      winColor = Color3.fromRGB(255, 200, 100), litPct = 0.50, winW = 2.5, winH = 4.0 },
	{ facade = 26, floors = 11, color = Color3.fromRGB(85, 90, 95),    mat = Enum.Material.DiamondPlate,  winColor = Color3.fromRGB(180, 210, 255), litPct = 0.35, winW = 2.2, winH = 3.0 },
	{ facade = 16, floors = 7,  color = Color3.fromRGB(110, 80, 65),   mat = Enum.Material.Brick,         winColor = Color3.fromRGB(255, 220, 140), litPct = 0.45, winW = 2.0, winH = 3.5 },
	{ facade = 24, floors = 12, color = Color3.fromRGB(95, 100, 110),  mat = Enum.Material.Metal,         winColor = Color3.fromRGB(200, 230, 255), litPct = 0.55, winW = 3.0, winH = 4.5 },
	{ facade = 18, floors = 5,  color = Color3.fromRGB(135, 130, 120), mat = Enum.Material.Concrete,      winColor = Color3.fromRGB(255, 200, 100), litPct = 0.30, winW = 2.5, winH = 3.5 },
}

local RIGHT_ROW_2 = {
	{ facade = 22, floors = 10, color = Color3.fromRGB(120, 115, 110), mat = Enum.Material.Concrete,      winColor = Color3.fromRGB(180, 210, 255), litPct = 0.50, winW = 2.5, winH = 4.0, entrance = true },
	{ facade = 26, floors = 6,  color = Color3.fromRGB(75, 75, 80),    mat = Enum.Material.SmoothPlastic, winColor = Color3.fromRGB(255, 220, 140), litPct = 0.45, winW = 3.0, winH = 4.5 },
	{ facade = 18, floors = 12, color = Color3.fromRGB(90, 95, 100),   mat = Enum.Material.Metal,         winColor = Color3.fromRGB(200, 230, 255), litPct = 0.40, winW = 2.0, winH = 3.0 },
	{ facade = 20, floors = 8,  color = Color3.fromRGB(110, 80, 65),   mat = Enum.Material.Brick,         winColor = Color3.fromRGB(255, 200, 100), litPct = 0.55, winW = 2.5, winH = 4.0 },
	{ facade = 28, floors = 11, color = Color3.fromRGB(100, 105, 115), mat = Enum.Material.Metal,         winColor = Color3.fromRGB(180, 210, 255), litPct = 0.35, winW = 2.2, winH = 3.5 },
	{ facade = 16, floors = 7,  color = Color3.fromRGB(85, 90, 95),    mat = Enum.Material.DiamondPlate,  winColor = Color3.fromRGB(255, 220, 140), litPct = 0.50, winW = 2.8, winH = 4.2 },
	{ facade = 22, floors = 9,  color = Color3.fromRGB(140, 135, 125), mat = Enum.Material.Concrete,      winColor = Color3.fromRGB(200, 230, 255), litPct = 0.45, winW = 2.0, winH = 3.5 },
	{ facade = 24, floors = 13, color = Color3.fromRGB(95, 100, 110),  mat = Enum.Material.Metal,         winColor = Color3.fromRGB(255, 200, 100), litPct = 0.40, winW = 2.5, winH = 3.0 },
	{ facade = 18, floors = 6,  color = Color3.fromRGB(130, 125, 115), mat = Enum.Material.SmoothPlastic, winColor = Color3.fromRGB(180, 210, 255), litPct = 0.55, winW = 3.2, winH = 4.5 },
	{ facade = 20, floors = 8,  color = Color3.fromRGB(130, 90, 70),   mat = Enum.Material.Brick,         winColor = Color3.fromRGB(255, 220, 140), litPct = 0.35, winW = 2.0, winH = 3.5 },
}

--------------------------------------------------------------------------------
-- VARIATION 3: OLD TOWN — warm earth, terracotta, plaster
--------------------------------------------------------------------------------

local LEFT_ROW_3 = {
	{ facade = 20, floors = 5,  color = Color3.fromRGB(210, 175, 120), mat = Enum.Material.Brick,         winColor = Color3.fromRGB(255, 180, 120), litPct = 0.60, winW = 2.0, winH = 3.5, entrance = true },
	{ facade = 18, floors = 4,  color = Color3.fromRGB(185, 120, 85),  mat = Enum.Material.Brick,         winColor = Color3.fromRGB(255, 220, 140), litPct = 0.50, winW = 1.8, winH = 3.0 },
	{ facade = 24, floors = 6,  color = Color3.fromRGB(230, 220, 195), mat = Enum.Material.SmoothPlastic, winColor = Color3.fromRGB(255, 200, 100), litPct = 0.45, winW = 2.5, winH = 4.0 },
	{ facade = 16, floors = 5,  color = Color3.fromRGB(170, 155, 130), mat = Enum.Material.Slate,         winColor = Color3.fromRGB(255, 180, 120), litPct = 0.55, winW = 2.0, winH = 3.5 },
	{ facade = 22, floors = 4,  color = Color3.fromRGB(200, 185, 155), mat = Enum.Material.Concrete,      winColor = Color3.fromRGB(255, 220, 140), litPct = 0.40, winW = 2.2, winH = 3.0 },
	{ facade = 18, floors = 7,  color = Color3.fromRGB(175, 110, 80),  mat = Enum.Material.Brick,         winColor = Color3.fromRGB(255, 200, 100), litPct = 0.50, winW = 1.8, winH = 3.5 },
	{ facade = 26, floors = 5,  color = Color3.fromRGB(240, 235, 220), mat = Enum.Material.SmoothPlastic, winColor = Color3.fromRGB(255, 180, 120), litPct = 0.55, winW = 2.5, winH = 4.0 },
	{ facade = 16, floors = 4,  color = Color3.fromRGB(160, 150, 130), mat = Enum.Material.Slate,         winColor = Color3.fromRGB(255, 220, 140), litPct = 0.35, winW = 2.0, winH = 3.0 },
	{ facade = 20, floors = 6,  color = Color3.fromRGB(195, 145, 95),  mat = Enum.Material.Brick,         winColor = Color3.fromRGB(255, 200, 100), litPct = 0.60, winW = 2.2, winH = 3.5 },
	{ facade = 22, floors = 5,  color = Color3.fromRGB(215, 200, 170), mat = Enum.Material.Concrete,      winColor = Color3.fromRGB(255, 180, 120), litPct = 0.45, winW = 2.0, winH = 3.5 },
}

local RIGHT_ROW_3 = {
	{ facade = 22, floors = 5,  color = Color3.fromRGB(185, 120, 85),  mat = Enum.Material.Brick,         winColor = Color3.fromRGB(255, 220, 140), litPct = 0.55, winW = 2.2, winH = 3.5, entrance = true },
	{ facade = 16, floors = 6,  color = Color3.fromRGB(230, 220, 195), mat = Enum.Material.SmoothPlastic, winColor = Color3.fromRGB(255, 180, 120), litPct = 0.50, winW = 2.0, winH = 4.0 },
	{ facade = 24, floors = 4,  color = Color3.fromRGB(170, 155, 130), mat = Enum.Material.Slate,         winColor = Color3.fromRGB(255, 200, 100), litPct = 0.40, winW = 2.5, winH = 3.0 },
	{ facade = 20, floors = 7,  color = Color3.fromRGB(200, 185, 155), mat = Enum.Material.Concrete,      winColor = Color3.fromRGB(255, 220, 140), litPct = 0.55, winW = 2.0, winH = 3.5 },
	{ facade = 18, floors = 5,  color = Color3.fromRGB(175, 110, 80),  mat = Enum.Material.Brick,         winColor = Color3.fromRGB(255, 180, 120), litPct = 0.45, winW = 1.8, winH = 3.5 },
	{ facade = 26, floors = 4,  color = Color3.fromRGB(240, 235, 220), mat = Enum.Material.SmoothPlastic, winColor = Color3.fromRGB(255, 200, 100), litPct = 0.60, winW = 2.5, winH = 4.0 },
	{ facade = 16, floors = 6,  color = Color3.fromRGB(160, 150, 130), mat = Enum.Material.Slate,         winColor = Color3.fromRGB(255, 220, 140), litPct = 0.35, winW = 2.0, winH = 3.0 },
	{ facade = 22, floors = 5,  color = Color3.fromRGB(195, 145, 95),  mat = Enum.Material.Brick,         winColor = Color3.fromRGB(255, 180, 120), litPct = 0.50, winW = 2.2, winH = 3.5 },
	{ facade = 18, floors = 4,  color = Color3.fromRGB(215, 200, 170), mat = Enum.Material.Concrete,      winColor = Color3.fromRGB(255, 220, 140), litPct = 0.45, winW = 2.0, winH = 3.0 },
	{ facade = 24, floors = 6,  color = Color3.fromRGB(210, 175, 120), mat = Enum.Material.Brick,         winColor = Color3.fromRGB(255, 200, 100), litPct = 0.55, winW = 2.5, winH = 4.0 },
}

--------------------------------------------------------------------------------
-- Build one segment from a spec table
--------------------------------------------------------------------------------

function Buildings.buildFromSpec(spec, x, z, scale, bDepthBase, variant)
	bDepthBase = bDepthBase or 16
	local building = Instance.new("Model")
	building.Name = spec.entrance and "Building_Main" or "Building_Side"

	local bDepth = bDepthBase * scale
	local facadeLen = spec.facade * scale
	local floorHeight = 7 * scale
	local height = spec.floors * floorHeight

	-- Main body
	local main = Instance.new("Part")
	main.Size = Vector3.new(bDepth, height, facadeLen)
	main.Position = Vector3.new(x, BUILDING_BASE + height / 2, z)
	main.Anchored = true
	main.Material = spec.mat
	main.Color = spec.color
	main:SetAttribute("ThemeRole", "building_body")
	main:SetAttribute("BaseColor", spec.color)
	main:SetAttribute("BaseMaterial", spec.mat.Name)
	main.Parent = building

	-- Roof cap
	local roofColor = Color3.fromRGB(35, 35, 40)
	local roof = Instance.new("Part")
	roof.Size = Vector3.new(bDepth + 1, 1 * scale, facadeLen + 1)
	roof.Position = Vector3.new(x, BUILDING_BASE + height + 0.5, z)
	roof.Anchored = true
	roof.Material = Enum.Material.Metal
	roof.Color = roofColor
	roof:SetAttribute("ThemeRole", "building_roof")
	roof:SetAttribute("BaseColor", roofColor)
	roof:SetAttribute("BaseMaterial", "Metal")
	roof.Parent = building

	-- Windows on all 4 faces
	local sign = x > 0 and 1 or -1
	local frontX = x - sign * (bDepth / 2 + 0.15)
	local backX = x + sign * (bDepth / 2 + 0.15)
	local sideZ1 = z - facadeLen / 2 - 0.15
	local sideZ2 = z + facadeLen / 2 + 0.15
	local winGap = 1.2

	addWindowsToFace(building, "x", frontX, z, facadeLen, BUILDING_BASE, spec.floors, floorHeight, spec.winW, spec.winH, winGap, spec.winColor, spec.litPct)
	addWindowsToFace(building, "x", backX, z, facadeLen, BUILDING_BASE, spec.floors, floorHeight, spec.winW, spec.winH, winGap, spec.winColor, spec.litPct * 0.4)
	addWindowsToFace(building, "z", sideZ1, x, bDepth, BUILDING_BASE, spec.floors, floorHeight, spec.winW, spec.winH, winGap, spec.winColor, spec.litPct * 0.5)
	addWindowsToFace(building, "z", sideZ2, x, bDepth, BUILDING_BASE, spec.floors, floorHeight, spec.winW, spec.winH, winGap, spec.winColor, spec.litPct * 0.5)

	-- Entrance (first building only) — old town gets its own simpler door
	if spec.entrance and variant ~= "oldtown" then
		local doorWidth = 4 * scale
		local doorHeight = 7 * scale
		local doorY = BUILDING_BASE + doorHeight / 2 + 0.2

		local frame = Instance.new("Part")
		frame.Name = "DoorFrame"
		frame.Size = Vector3.new(0.5, doorHeight + 0.5, doorWidth + 0.6)
		frame.Position = Vector3.new(frontX - sign * 0.15, doorY, z)
		frame.Anchored = true
		frame.CanCollide = false
		frame.Material = Enum.Material.Metal
		frame.Color = Color3.fromRGB(35, 35, 40)
		frame.Parent = building

		local panelWidth = (doorWidth - 0.3) / 2
		for i = -1, 1, 2 do
			local door = Instance.new("Part")
			door.Name = "Door"
			door.Size = Vector3.new(0.2, doorHeight, panelWidth)
			door.Position = Vector3.new(frontX - sign * 0.25, doorY, z + i * (panelWidth / 2 + 0.1))
			door.Anchored = true
			door.CanCollide = false
			door.Material = Enum.Material.Glass
			door.Color = Color3.fromRGB(60, 70, 90)
			door.Transparency = 0.3
			door.Parent = building
		end

		local canopy = Instance.new("Part")
		canopy.Name = "Canopy"
		canopy.Size = Vector3.new(2 * scale, 0.3, doorWidth + 2)
		canopy.Position = Vector3.new(frontX - sign * 1 * scale, BUILDING_BASE + doorHeight + 1, z)
		canopy.Anchored = true
		canopy.Material = Enum.Material.Metal
		canopy.Color = Color3.fromRGB(40, 40, 45)
		canopy.Parent = building

		local entranceLight = Instance.new("Part")
		entranceLight.Name = "EntranceLight"
		entranceLight.Size = Vector3.new(0.3, 0.3, 1.5)
		entranceLight.Position = Vector3.new(frontX - sign * 0.3, BUILDING_BASE + doorHeight + 0.5, z)
		entranceLight.Anchored = true
		entranceLight.CanCollide = false
		entranceLight.Material = Enum.Material.Neon
		entranceLight.Color = Color3.fromRGB(255, 230, 180)
		entranceLight.Parent = building
	end

	-- Variant-specific architectural details
	if variant == "industrial" then
		Buildings._addIndustrialRoof(building, x, z, scale, height, spec, bDepth, facadeLen)
	elseif variant == "oldtown" then
		Buildings._addOldTownDetails(building, x, z, scale, height, spec, bDepth, facadeLen, floorHeight)
	end

	building.Parent = DecorUtils.decorFolder
	return building
end

--------------------------------------------------------------------------------
-- VARIANT: Industrial — rooftop water tanks, vent boxes, antennas
--------------------------------------------------------------------------------

function Buildings._addIndustrialRoof(building, x, z, scale, height, spec, bDepth, facadeLen)
	local roofY = BUILDING_BASE + height + 1

	-- Water tank on taller buildings
	if spec.floors >= 8 then
		local tankH = 3.5 * scale
		local tankW = 3 * scale

		local tank = Instance.new("Part")
		tank.Name = "WaterTank"
		tank.Shape = Enum.PartType.Cylinder
		tank.Size = Vector3.new(tankH, tankW, tankW)
		tank.CFrame = CFrame.new(x, roofY + tankH / 2 + 1.5 * scale, z + facadeLen * 0.15)
			* CFrame.Angles(0, 0, math.rad(90))
		tank.Anchored = true
		tank.Material = Enum.Material.Metal
		tank.Color = Color3.fromRGB(55, 60, 65)
		tank.Parent = building

		-- Tank legs (4 supports)
		for _, off in ipairs({{-1,-1},{-1,1},{1,-1},{1,1}}) do
			local leg = Instance.new("Part")
			leg.Name = "TankLeg"
			leg.Size = Vector3.new(0.4 * scale, 1.5 * scale, 0.4 * scale)
			leg.Position = Vector3.new(
				x + off[1] * 0.8 * scale,
				roofY + 0.75 * scale,
				z + facadeLen * 0.15 + off[2] * 0.8 * scale
			)
			leg.Anchored = true
			leg.Material = Enum.Material.Metal
			leg.Color = Color3.fromRGB(45, 50, 55)
			leg.Parent = building
		end
	end

	-- Vent boxes on wider buildings
	if spec.facade >= 18 then
		local ventCount = spec.floors >= 10 and 3 or 2
		for i = 1, ventCount do
			local vent = Instance.new("Part")
			vent.Name = "Vent"
			vent.Size = Vector3.new(1.8 * scale, 1.2 * scale, 1.8 * scale)
			vent.Position = Vector3.new(
				x + (i - ventCount / 2 - 0.5) * 3 * scale,
				roofY + 0.6 * scale,
				z - facadeLen * 0.2
			)
			vent.Anchored = true
			vent.Material = Enum.Material.DiamondPlate
			vent.Color = Color3.fromRGB(65, 70, 75)
			vent.Parent = building
		end
	end

	-- Antenna on tallest buildings
	if spec.floors >= 11 then
		local antenna = Instance.new("Part")
		antenna.Name = "Antenna"
		antenna.Size = Vector3.new(0.3 * scale, 6 * scale, 0.3 * scale)
		antenna.Position = Vector3.new(x, roofY + 3 * scale, z)
		antenna.Anchored = true
		antenna.Material = Enum.Material.Metal
		antenna.Color = Color3.fromRGB(50, 55, 60)
		antenna.Parent = building
	end
end

--------------------------------------------------------------------------------
-- VARIANT: Old Town — balconies with railings, flower boxes, colored awnings
--------------------------------------------------------------------------------

function Buildings._addOldTownDetails(building, x, z, scale, height, spec, bDepth, facadeLen, floorHeight)
	local sign = x > 0 and 1 or -1
	local frontX = x - sign * (bDepth / 2 + 0.15)

	-- Simple wooden door + fabric awning (replaces modern glass entrance)
	if spec.entrance then
		local doorWidth = 3.5 * scale
		local doorHeight = 6 * scale
		local doorY = BUILDING_BASE + doorHeight / 2 + 0.1

		-- Wooden door
		local door = Instance.new("Part")
		door.Name = "Door"
		door.Size = Vector3.new(0.3, doorHeight, doorWidth)
		door.Position = Vector3.new(frontX - sign * 0.15, doorY, z)
		door.Anchored = true
		door.CanCollide = false
		door.Material = Enum.Material.WoodPlanks
		door.Color = Color3.fromRGB(90, 60, 35)
		door.Parent = building

		-- Fabric awning above door
		local awning = Instance.new("Part")
		awning.Name = "Awning"
		awning.Size = Vector3.new(2.5 * scale, 0.15 * scale, doorWidth + 2 * scale)
		awning.Position = Vector3.new(
			frontX - sign * 1.2 * scale,
			BUILDING_BASE + doorHeight + 0.5,
			z
		)
		awning.Anchored = true
		awning.CanCollide = false
		awning.Material = Enum.Material.Fabric
		-- Alternate terracotta red / forest green
		awning.Color = spec.floors % 2 == 0
			and Color3.fromRGB(160, 60, 40)
			or Color3.fromRGB(40, 100, 60)
		awning.Parent = building
	end
end

-- Generic building row: places first building at center, rest extending outward along X
local function createBuildingRow(x, z, scale, leftRow, rightRow, bDepthBase, variant)
	bDepthBase = bDepthBase or 16
	local bDepth = bDepthBase * scale
	local row = x > 0 and rightRow or leftRow

	Buildings.buildFromSpec(row[1], x, z, scale, bDepthBase, variant)

	local dir = x > 0 and 1 or -1
	local curX = x + dir * bDepth
	for i = 2, #row do
		Buildings.buildFromSpec(row[i], curX, z, scale, bDepthBase, variant)
		curX = curX + dir * bDepth
	end
end

-- Variation 1: original city apartments
local function createApartment(x, z, scale)
	createBuildingRow(x, z, scale, LEFT_ROW, RIGHT_ROW)
end

-- Variation 2: industrial
local function createApartment2(x, z, scale)
	createBuildingRow(x, z, scale, LEFT_ROW_2, RIGHT_ROW_2, 16, "industrial")
end

-- Variation 3: old town
local function createApartment3(x, z, scale)
	createBuildingRow(x, z, scale, LEFT_ROW_3, RIGHT_ROW_3, 16, "oldtown")
end

-- Building dispatchers (public API)
function Buildings.createBuilding(x, z, scale)
	if not DecorUtils.decorFolder then return nil end
	scale = scale or 1
	return createApartment(x, z, scale)
end

function Buildings.createBuilding2(x, z, scale)
	if not DecorUtils.decorFolder then return nil end
	scale = scale or 1
	return createApartment2(x, z, scale)
end

function Buildings.createBuilding3(x, z, scale)
	if not DecorUtils.decorFolder then return nil end
	scale = scale or 1
	return createApartment3(x, z, scale)
end

return Buildings
