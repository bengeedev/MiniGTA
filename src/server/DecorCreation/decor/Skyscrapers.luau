local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local Skyscrapers = {}

local BUILDING_BASE = DecorUtils.BUILDING_BASE

--------------------------------------------------------------------------------
-- SKYSCRAPER SPECS: glass curtain wall, steel frame, crown features
-- Spec: facade, floors, bodyColor, frameColor, glassColor, litPct, crown, entrance
-- Crown types: "antenna", "spire", "glow", "helipad"
--------------------------------------------------------------------------------

local SKY_LEFT = {
	{ facade = 26, floors = 18, bodyColor = Color3.fromRGB(45, 55, 70),  frameColor = Color3.fromRGB(140, 145, 155), glassColor = Color3.fromRGB(150, 200, 255), litPct = 0.70, crown = "antenna",  entrance = true },
	{ facade = 22, floors = 14, bodyColor = Color3.fromRGB(40, 45, 55),  frameColor = Color3.fromRGB(120, 125, 135), glassColor = Color3.fromRGB(180, 220, 255), litPct = 0.60, crown = "glow" },
	{ facade = 18, floors = 22, bodyColor = Color3.fromRGB(35, 40, 50),  frameColor = Color3.fromRGB(140, 145, 155), glassColor = Color3.fromRGB(150, 200, 255), litPct = 0.75, crown = "spire" },
	{ facade = 28, floors = 12, bodyColor = Color3.fromRGB(55, 60, 70),  frameColor = Color3.fromRGB(120, 125, 135), glassColor = Color3.fromRGB(170, 210, 240), litPct = 0.55, crown = "helipad" },
	{ facade = 24, floors = 16, bodyColor = Color3.fromRGB(40, 50, 65),  frameColor = Color3.fromRGB(140, 145, 155), glassColor = Color3.fromRGB(180, 220, 255), litPct = 0.65, crown = "antenna" },
	{ facade = 20, floors = 20, bodyColor = Color3.fromRGB(35, 45, 60),  frameColor = Color3.fromRGB(120, 125, 135), glassColor = Color3.fromRGB(150, 200, 255), litPct = 0.70, crown = "glow" },
	{ facade = 26, floors = 13, bodyColor = Color3.fromRGB(50, 55, 65),  frameColor = Color3.fromRGB(140, 145, 155), glassColor = Color3.fromRGB(170, 210, 240), litPct = 0.60, crown = "helipad" },
	{ facade = 22, floors = 15, bodyColor = Color3.fromRGB(38, 43, 55),  frameColor = Color3.fromRGB(120, 125, 135), glassColor = Color3.fromRGB(180, 220, 255), litPct = 0.65, crown = "spire" },
}

local SKY_RIGHT = {
	{ facade = 24, floors = 16, bodyColor = Color3.fromRGB(40, 45, 55),  frameColor = Color3.fromRGB(130, 135, 145), glassColor = Color3.fromRGB(180, 220, 255), litPct = 0.65, crown = "spire",   entrance = true },
	{ facade = 28, floors = 20, bodyColor = Color3.fromRGB(35, 40, 50),  frameColor = Color3.fromRGB(110, 115, 125), glassColor = Color3.fromRGB(150, 200, 255), litPct = 0.75, crown = "antenna" },
	{ facade = 18, floors = 13, bodyColor = Color3.fromRGB(55, 60, 70),  frameColor = Color3.fromRGB(130, 135, 145), glassColor = Color3.fromRGB(170, 210, 240), litPct = 0.60, crown = "helipad" },
	{ facade = 22, floors = 22, bodyColor = Color3.fromRGB(38, 48, 62),  frameColor = Color3.fromRGB(110, 115, 125), glassColor = Color3.fromRGB(180, 220, 255), litPct = 0.70, crown = "glow" },
	{ facade = 26, floors = 11, bodyColor = Color3.fromRGB(42, 47, 58),  frameColor = Color3.fromRGB(130, 135, 145), glassColor = Color3.fromRGB(150, 200, 255), litPct = 0.55, crown = "antenna" },
	{ facade = 20, floors = 17, bodyColor = Color3.fromRGB(48, 53, 65),  frameColor = Color3.fromRGB(110, 115, 125), glassColor = Color3.fromRGB(170, 210, 240), litPct = 0.70, crown = "spire" },
	{ facade = 24, floors = 14, bodyColor = Color3.fromRGB(44, 50, 62),  frameColor = Color3.fromRGB(130, 135, 145), glassColor = Color3.fromRGB(180, 220, 255), litPct = 0.65, crown = "glow" },
	{ facade = 22, floors = 12, bodyColor = Color3.fromRGB(50, 55, 68),  frameColor = Color3.fromRGB(110, 115, 125), glassColor = Color3.fromRGB(150, 200, 255), litPct = 0.60, crown = "helipad" },
}

-- Times Square warm amber/gold palette
local SKY_LEFT_WARM = {
	{ facade = 26, floors = 18, bodyColor = Color3.fromRGB(90, 65, 35),  frameColor = Color3.fromRGB(170, 145, 90),  glassColor = Color3.fromRGB(255, 200, 80),  litPct = 0.88, crown = "antenna",  entrance = true },
	{ facade = 22, floors = 14, bodyColor = Color3.fromRGB(85, 58, 30),  frameColor = Color3.fromRGB(160, 135, 80),  glassColor = Color3.fromRGB(255, 180, 60),  litPct = 0.85, crown = "glow" },
	{ facade = 18, floors = 22, bodyColor = Color3.fromRGB(80, 55, 28),  frameColor = Color3.fromRGB(170, 145, 90),  glassColor = Color3.fromRGB(255, 210, 100), litPct = 0.92, crown = "spire" },
	{ facade = 28, floors = 12, bodyColor = Color3.fromRGB(95, 68, 38),  frameColor = Color3.fromRGB(160, 135, 80),  glassColor = Color3.fromRGB(255, 190, 70),  litPct = 0.85, crown = "helipad" },
	{ facade = 24, floors = 16, bodyColor = Color3.fromRGB(88, 62, 32),  frameColor = Color3.fromRGB(170, 145, 90),  glassColor = Color3.fromRGB(255, 200, 80),  litPct = 0.88, crown = "antenna" },
	{ facade = 20, floors = 20, bodyColor = Color3.fromRGB(82, 58, 30),  frameColor = Color3.fromRGB(160, 135, 80),  glassColor = Color3.fromRGB(255, 185, 65),  litPct = 0.86, crown = "glow" },
	{ facade = 26, floors = 13, bodyColor = Color3.fromRGB(92, 66, 35),  frameColor = Color3.fromRGB(170, 145, 90),  glassColor = Color3.fromRGB(255, 195, 75),  litPct = 0.85, crown = "helipad" },
	{ facade = 22, floors = 15, bodyColor = Color3.fromRGB(86, 60, 32),  frameColor = Color3.fromRGB(160, 135, 80),  glassColor = Color3.fromRGB(255, 205, 90),  litPct = 0.87, crown = "spire" },
}

local SKY_RIGHT_WARM = {
	{ facade = 24, floors = 16, bodyColor = Color3.fromRGB(85, 58, 30),  frameColor = Color3.fromRGB(165, 140, 85),  glassColor = Color3.fromRGB(255, 190, 70),  litPct = 0.88, crown = "spire",   entrance = true },
	{ facade = 28, floors = 20, bodyColor = Color3.fromRGB(80, 55, 28),  frameColor = Color3.fromRGB(155, 130, 75),  glassColor = Color3.fromRGB(255, 200, 80),  litPct = 0.90, crown = "antenna" },
	{ facade = 18, floors = 13, bodyColor = Color3.fromRGB(95, 68, 38),  frameColor = Color3.fromRGB(165, 140, 85),  glassColor = Color3.fromRGB(255, 185, 65),  litPct = 0.85, crown = "helipad" },
	{ facade = 22, floors = 22, bodyColor = Color3.fromRGB(83, 58, 30),  frameColor = Color3.fromRGB(155, 130, 75),  glassColor = Color3.fromRGB(255, 210, 100), litPct = 0.92, crown = "glow" },
	{ facade = 26, floors = 11, bodyColor = Color3.fromRGB(88, 63, 33),  frameColor = Color3.fromRGB(165, 140, 85),  glassColor = Color3.fromRGB(255, 195, 75),  litPct = 0.86, crown = "antenna" },
	{ facade = 20, floors = 17, bodyColor = Color3.fromRGB(92, 66, 35),  frameColor = Color3.fromRGB(155, 130, 75),  glassColor = Color3.fromRGB(255, 180, 60),  litPct = 0.87, crown = "spire" },
	{ facade = 24, floors = 14, bodyColor = Color3.fromRGB(86, 60, 32),  frameColor = Color3.fromRGB(165, 140, 85),  glassColor = Color3.fromRGB(255, 200, 85),  litPct = 0.86, crown = "glow" },
	{ facade = 22, floors = 12, bodyColor = Color3.fromRGB(90, 64, 34),  frameColor = Color3.fromRGB(155, 130, 75),  glassColor = Color3.fromRGB(255, 190, 70),  litPct = 0.85, crown = "helipad" },
}

-- Shibuya neon pink/purple palette
local SKY_LEFT_NEON = {
	{ facade = 26, floors = 18, bodyColor = Color3.fromRGB(65, 35, 85),  frameColor = Color3.fromRGB(140, 110, 160), glassColor = Color3.fromRGB(255, 100, 200), litPct = 0.90, crown = "antenna",  entrance = true },
	{ facade = 22, floors = 14, bodyColor = Color3.fromRGB(58, 30, 78),  frameColor = Color3.fromRGB(130, 100, 150), glassColor = Color3.fromRGB(200, 80, 255),  litPct = 0.88, crown = "glow" },
	{ facade = 18, floors = 22, bodyColor = Color3.fromRGB(55, 28, 75),  frameColor = Color3.fromRGB(140, 110, 160), glassColor = Color3.fromRGB(255, 120, 220), litPct = 0.92, crown = "spire" },
	{ facade = 28, floors = 12, bodyColor = Color3.fromRGB(70, 38, 90),  frameColor = Color3.fromRGB(130, 100, 150), glassColor = Color3.fromRGB(220, 90, 255),  litPct = 0.88, crown = "helipad" },
	{ facade = 24, floors = 16, bodyColor = Color3.fromRGB(62, 32, 82),  frameColor = Color3.fromRGB(140, 110, 160), glassColor = Color3.fromRGB(255, 110, 210), litPct = 0.90, crown = "antenna" },
	{ facade = 20, floors = 20, bodyColor = Color3.fromRGB(56, 30, 76),  frameColor = Color3.fromRGB(130, 100, 150), glassColor = Color3.fromRGB(210, 85, 255),  litPct = 0.88, crown = "glow" },
	{ facade = 26, floors = 13, bodyColor = Color3.fromRGB(68, 36, 88),  frameColor = Color3.fromRGB(140, 110, 160), glassColor = Color3.fromRGB(255, 105, 205), litPct = 0.87, crown = "helipad" },
	{ facade = 22, floors = 15, bodyColor = Color3.fromRGB(60, 32, 80),  frameColor = Color3.fromRGB(130, 100, 150), glassColor = Color3.fromRGB(215, 88, 255),  litPct = 0.89, crown = "spire" },
}

local SKY_RIGHT_NEON = {
	{ facade = 24, floors = 16, bodyColor = Color3.fromRGB(58, 30, 78),  frameColor = Color3.fromRGB(135, 105, 155), glassColor = Color3.fromRGB(255, 110, 210), litPct = 0.90, crown = "spire",   entrance = true },
	{ facade = 28, floors = 20, bodyColor = Color3.fromRGB(55, 28, 75),  frameColor = Color3.fromRGB(125, 95, 145),  glassColor = Color3.fromRGB(200, 80, 255),  litPct = 0.92, crown = "antenna" },
	{ facade = 18, floors = 13, bodyColor = Color3.fromRGB(70, 38, 90),  frameColor = Color3.fromRGB(135, 105, 155), glassColor = Color3.fromRGB(220, 90, 255),  litPct = 0.87, crown = "helipad" },
	{ facade = 22, floors = 22, bodyColor = Color3.fromRGB(62, 32, 82),  frameColor = Color3.fromRGB(125, 95, 145),  glassColor = Color3.fromRGB(255, 120, 220), litPct = 0.92, crown = "glow" },
	{ facade = 26, floors = 11, bodyColor = Color3.fromRGB(64, 34, 84),  frameColor = Color3.fromRGB(135, 105, 155), glassColor = Color3.fromRGB(210, 85, 255),  litPct = 0.88, crown = "antenna" },
	{ facade = 20, floors = 17, bodyColor = Color3.fromRGB(68, 36, 88),  frameColor = Color3.fromRGB(125, 95, 145),  glassColor = Color3.fromRGB(255, 100, 200), litPct = 0.90, crown = "spire" },
	{ facade = 24, floors = 14, bodyColor = Color3.fromRGB(60, 32, 80),  frameColor = Color3.fromRGB(135, 105, 155), glassColor = Color3.fromRGB(215, 88, 255),  litPct = 0.88, crown = "glow" },
	{ facade = 22, floors = 12, bodyColor = Color3.fromRGB(66, 35, 86),  frameColor = Color3.fromRGB(125, 95, 145),  glassColor = Color3.fromRGB(255, 105, 205), litPct = 0.87, crown = "helipad" },
}

--------------------------------------------------------------------------------
-- SKYSCRAPER BUILDER — glass curtain wall + steel frame + crown
--------------------------------------------------------------------------------

local function buildSkyscraperFromSpec(spec, x, z, scale, bDepthBase, options)
	bDepthBase = bDepthBase or 20
	options = options or {}
	local showFront = options.showFront ~= false
	local showSides = options.showSides or false

	local building = Instance.new("Model")
	building.Name = spec.entrance and "Skyscraper_Main" or "Skyscraper_Side"

	local bDepth = bDepthBase * scale
	local facadeLen = spec.facade * scale
	local floorHeight = 6 * scale
	local height = spec.floors * floorHeight
	local sign = x > 0 and 1 or -1
	local frontX = x - sign * (bDepth / 2 + 0.15)

	-- Glass core body
	local core = Instance.new("Part")
	core.Size = Vector3.new(bDepth, height, facadeLen)
	core.Position = Vector3.new(x, BUILDING_BASE + height / 2, z)
	core.Anchored = true
	core.Material = Enum.Material.Glass
	core.Color = spec.bodyColor
	core.Transparency = 0.08
	core:SetAttribute("ThemeRole", "building_body")
	core:SetAttribute("BaseColor", spec.bodyColor)
	core:SetAttribute("BaseMaterial", "Glass")
	core.Parent = building

	-- Roof cap
	local roof = Instance.new("Part")
	roof.Size = Vector3.new(bDepth + 0.5, 0.5, facadeLen + 0.5)
	roof.Position = Vector3.new(x, BUILDING_BASE + height + 0.25, z)
	roof.Anchored = true
	roof.Material = Enum.Material.Metal
	roof.Color = spec.frameColor
	roof:SetAttribute("ThemeRole", "building_roof")
	roof:SetAttribute("BaseColor", spec.frameColor)
	roof:SetAttribute("BaseMaterial", "Metal")
	roof.Parent = building

	-- Shared panel constants
	local panelGap = 0.6
	local panelH = floorHeight - 0.8
	-- Unlit glass tinted toward the spec's glass color for variant identity
	local gc = spec.glassColor
	local darkGlass = Color3.fromRGB(
		math.floor(gc.R * 255 * 0.18 + 30),
		math.floor(gc.G * 255 * 0.18 + 35),
		math.floor(gc.B * 255 * 0.18 + 45)
	)

	-- FRONT FACE (inward X face): bands + columns + glass panels
	if showFront then
		for floor = 1, spec.floors do
			local bandY = BUILDING_BASE + floor * floorHeight
			local band = Instance.new("Part")
			band.Size = Vector3.new(0.4, 0.4, facadeLen)
			band.Position = Vector3.new(frontX, bandY, z)
			band.Anchored = true
			band.CanCollide = false
			band.Material = Enum.Material.Metal
			band.Color = spec.frameColor
			band.Parent = building
		end

		for _, zOff in ipairs({ -facadeLen / 2 + 0.3, facadeLen / 2 - 0.3 }) do
			local col = Instance.new("Part")
			col.Size = Vector3.new(0.5, height, 0.6)
			col.Position = Vector3.new(frontX, BUILDING_BASE + height / 2, z + zOff)
			col.Anchored = true
			col.CanCollide = false
			col.Material = Enum.Material.Metal
			col.Color = spec.frameColor
			col.Parent = building
		end

		local panelW = 3.5 * scale
		local margin = 1.5
		local available = facadeLen - 2 * margin
		local numPanels = math.max(1, math.floor((available + panelGap) / (panelW + panelGap)))
		local totalPW = numPanels * panelW + (numPanels - 1) * panelGap
		local startOff = -totalPW / 2 + panelW / 2

		for floor = 2, spec.floors do
			local panelY = BUILDING_BASE + (floor - 0.5) * floorHeight
			for p = 1, numPanels do
				local off = startOff + (p - 1) * (panelW + panelGap)
				local panel = Instance.new("Part")
				panel.Size = Vector3.new(0.3, panelH, panelW)
				panel.Position = Vector3.new(frontX - sign * 0.1, panelY, z + off)
				panel.Anchored = true
				panel.CanCollide = false
				if math.random() < spec.litPct then
					panel.Material = Enum.Material.Neon
					panel.Color = spec.glassColor
					panel:SetAttribute("ThemeRole", "building_window_lit")
					panel:SetAttribute("BaseColor", spec.glassColor)
					panel:SetAttribute("BaseMaterial", "Neon")
				else
					panel.Material = Enum.Material.Glass
					panel.Color = darkGlass
					panel.Transparency = 0.15
					panel:SetAttribute("ThemeRole", "building_window")
					panel:SetAttribute("BaseColor", darkGlass)
					panel:SetAttribute("BaseMaterial", "Glass")
				end
				panel.Parent = building
			end
		end
	end

	-- SIDE FACES (Z faces): bands + columns + glass panels
	if showSides then
		local sideZ1 = z - facadeLen / 2 - 0.15
		local sideZ2 = z + facadeLen / 2 + 0.15

		for _, sideZ in ipairs({ sideZ1, sideZ2 }) do
			-- Horizontal bands along X
			for floor = 1, spec.floors do
				local bandY = BUILDING_BASE + floor * floorHeight
				local band = Instance.new("Part")
				band.Size = Vector3.new(bDepth, 0.4, 0.4)
				band.Position = Vector3.new(x, bandY, sideZ)
				band.Anchored = true
				band.CanCollide = false
				band.Material = Enum.Material.Metal
				band.Color = spec.frameColor
				band.Parent = building
			end

			-- Vertical columns on side face edges
			for _, xOff in ipairs({ -bDepth / 2 + 0.3, bDepth / 2 - 0.3 }) do
				local col = Instance.new("Part")
				col.Size = Vector3.new(0.6, height, 0.5)
				col.Position = Vector3.new(x + xOff, BUILDING_BASE + height / 2, sideZ)
				col.Anchored = true
				col.CanCollide = false
				col.Material = Enum.Material.Metal
				col.Color = spec.frameColor
				col.Parent = building
			end

			-- Glass panels spanning X
			local sidePanelW = 3.0 * scale
			local sideMargin = 1.5
			local sideAvail = bDepth - 2 * sideMargin
			local sideNum = math.max(1, math.floor((sideAvail + panelGap) / (sidePanelW + panelGap)))
			local sideTotalW = sideNum * sidePanelW + (sideNum - 1) * panelGap
			local sideStart = -sideTotalW / 2 + sidePanelW / 2
			local sideLit = spec.litPct * 0.6

			for floor = 2, spec.floors do
				local panelY = BUILDING_BASE + (floor - 0.5) * floorHeight
				for p = 1, sideNum do
					local off = sideStart + (p - 1) * (sidePanelW + panelGap)
					local panel = Instance.new("Part")
					panel.Size = Vector3.new(sidePanelW, panelH, 0.3)
					panel.Position = Vector3.new(x + off, panelY, sideZ)
					panel.Anchored = true
					panel.CanCollide = false
					if math.random() < sideLit then
						panel.Material = Enum.Material.Neon
						panel.Color = spec.glassColor
						panel:SetAttribute("ThemeRole", "building_window_lit")
						panel:SetAttribute("BaseColor", spec.glassColor)
						panel:SetAttribute("BaseMaterial", "Neon")
					else
						panel.Material = Enum.Material.Glass
						panel.Color = darkGlass
						panel.Transparency = 0.15
						panel:SetAttribute("ThemeRole", "building_window")
						panel:SetAttribute("BaseColor", darkGlass)
						panel:SetAttribute("BaseMaterial", "Glass")
					end
					panel.Parent = building
				end
			end
		end
	end

	-- Crown features
	if spec.crown == "antenna" then
		local antenna = Instance.new("Part")
		antenna.Size = Vector3.new(0.5, 10 * scale, 0.5)
		antenna.Position = Vector3.new(x, BUILDING_BASE + height + 5 * scale, z)
		antenna.Anchored = true
		antenna.Material = Enum.Material.Metal
		antenna.Color = Color3.fromRGB(80, 80, 85)
		antenna.Parent = building

		local tip = Instance.new("Part")
		tip.Size = Vector3.new(1, 1, 1)
		tip.Position = Vector3.new(x, BUILDING_BASE + height + 10 * scale + 0.5, z)
		tip.Anchored = true
		tip.CanCollide = false
		tip.Shape = Enum.PartType.Ball
		tip.Material = Enum.Material.Neon
		tip.Color = Color3.fromRGB(255, 50, 50)
		tip.Parent = building

	elseif spec.crown == "spire" then
		local spire = Instance.new("Part")
		spire.Size = Vector3.new(2 * scale, 14 * scale, 2 * scale)
		spire.Position = Vector3.new(x, BUILDING_BASE + height + 7 * scale, z)
		spire.Anchored = true
		spire.Material = Enum.Material.Metal
		spire.Color = Color3.fromRGB(180, 185, 195)
		spire.Parent = building

	elseif spec.crown == "glow" then
		local crownPart = Instance.new("Part")
		crownPart.Size = Vector3.new(bDepth + 1, 2, facadeLen + 1)
		crownPart.Position = Vector3.new(x, BUILDING_BASE + height + 1, z)
		crownPart.Anchored = true
		crownPart.CanCollide = false
		crownPart.Material = Enum.Material.Neon
		crownPart.Color = spec.glassColor
		crownPart:SetAttribute("ThemeRole", "building_window_lit")
		crownPart:SetAttribute("BaseColor", spec.glassColor)
		crownPart:SetAttribute("BaseMaterial", "Neon")
		crownPart.Parent = building

	elseif spec.crown == "helipad" then
		local pad = Instance.new("Part")
		pad.Size = Vector3.new(bDepth - 4, 0.5, facadeLen - 4)
		pad.Position = Vector3.new(x, BUILDING_BASE + height + 0.5, z)
		pad.Anchored = true
		pad.Material = Enum.Material.Concrete
		pad.Color = Color3.fromRGB(85, 85, 90)
		pad.Parent = building

		local markH = Instance.new("Part")
		markH.Size = Vector3.new(3, 0.1, 3)
		markH.Position = Vector3.new(x, BUILDING_BASE + height + 0.8, z)
		markH.Anchored = true
		markH.CanCollide = false
		markH.Material = Enum.Material.Neon
		markH.Color = Color3.fromRGB(255, 255, 100)
		markH.Parent = building
	end

	-- Glass elevators on front face (one each side of entrance, ride up and down)
	if showFront and spec.elevator ~= false and spec.floors >= 10 then
		local activePlatformAnimations = DecorUtils.activePlatformAnimations
		local NPCManager = DecorUtils.NPCManager
		local elevW = 3.5 * scale
		local elevH = 8 * scale  -- tall enough for R15 character (~6 studs)
		local elevD = 3 * scale
		local elevX = frontX - sign * (elevD / 2 + 0.1)
		local elevZoff = facadeLen * 0.3  -- offset from center along facade
		local faceAngle = sign > 0 and 90 or -90  -- face toward road (center)

		for _, zSide in ipairs({ z + elevZoff, z - elevZoff }) do
			local elevMinY = BUILDING_BASE + elevH / 2 + 3  -- cab bottom stays above ground
			local elevMaxY = BUILDING_BASE + height - elevH / 2 - 1
			local elevSpeed = 6 + math.random() * 4

			-- Elevator cab (glass box)
			local cab = Instance.new("Part")
			cab.Name = "ElevatorCab"
			cab.Size = Vector3.new(elevD, elevH, elevW)
			cab.Position = Vector3.new(elevX, elevMinY + math.random() * (elevMaxY - elevMinY), zSide)
			cab.Anchored = true
			cab.CanCollide = false
			cab.Material = Enum.Material.Glass
			cab.Color = Color3.fromRGB(80, 120, 170)
			cab.Transparency = 0.4
			cab.Parent = building

			-- Elevator floor (visible metal floor inside cab)
			local cabFloor = Instance.new("Part")
			cabFloor.Name = "ElevatorFloor"
			cabFloor.Size = Vector3.new(elevD - 0.2, 0.2 * scale, elevW - 0.2)
			cabFloor.Position = Vector3.new(elevX, cab.Position.Y - elevH / 2 + 0.1, zSide)
			cabFloor.Anchored = true
			cabFloor.CanCollide = false
			cabFloor.Material = Enum.Material.DiamondPlate
			cabFloor.Color = Color3.fromRGB(60, 62, 66)
			cabFloor.Parent = building

			-- Interior light in cab
			local cabLight = Instance.new("Part")
			cabLight.Name = "ElevatorLight"
			cabLight.Size = Vector3.new(elevD * 0.5, 0.15 * scale, elevW * 0.5)
			cabLight.Position = Vector3.new(elevX, cab.Position.Y + elevH / 2 - 0.2, zSide)
			cabLight.Anchored = true
			cabLight.CanCollide = false
			cabLight.Material = Enum.Material.Neon
			cabLight.Color = Color3.fromRGB(255, 240, 210)
			cabLight.Transparency = 0
			cabLight.Parent = building

			-- Register elevator animation (cab + floor + light move together)
			local phaseOffset = math.random() * 20
			activePlatformAnimations[cab] = {
				type = "elevator",
				minY = elevMinY,
				maxY = elevMaxY,
				speed = elevSpeed,
				phaseOffset = phaseOffset,
				baseX = elevX,
				baseZ = zSide,
				elevH = elevH,
				linkedParts = { cabFloor, cabLight },
				npcModel = nil,
			}

			-- Spawn a real NPC inside the elevator
			if NPCManager then
				local npcY = cab.Position.Y - elevH / 2 + 3
				local capturedCab = cab
				task.spawn(function()
					local npc = NPCManager.spawnFromTemplate(
						NPCManager.randomCivilian(),
						Vector3.new(elevX, npcY, zSide),
						faceAngle, -- face toward road
						"idle"
					)
					if npc then
						for _, part in npc:GetDescendants() do
							if part:IsA("BasePart") then
								part.Anchored = true
							end
						end
						local animData = activePlatformAnimations[capturedCab]
						if animData then
							animData.npcModel = npc
							animData.npcFaceCFrame = CFrame.Angles(0, math.rad(faceAngle), 0)
						end
					end
				end)
			end
		end
	end

	-- Glass lobby entrance (main building only)
	if spec.entrance then
		local doorWidth = 5 * scale
		local doorHeight = 8 * scale
		local doorY = BUILDING_BASE + doorHeight / 2

		local lobby = Instance.new("Part")
		lobby.Name = "Lobby"
		lobby.Size = Vector3.new(3 * scale, doorHeight, doorWidth + 2)
		lobby.Position = Vector3.new(frontX - sign * 1.5 * scale, doorY, z)
		lobby.Anchored = true
		lobby.Material = Enum.Material.Glass
		lobby.Color = Color3.fromRGB(50, 70, 90)
		lobby.Transparency = 0.3
		lobby.Parent = building

		local lobbyLight = Instance.new("Part")
		lobbyLight.Size = Vector3.new(2, 0.3, doorWidth)
		lobbyLight.Position = Vector3.new(frontX - sign * 1.5 * scale, BUILDING_BASE + doorHeight + 0.5, z)
		lobbyLight.Anchored = true
		lobbyLight.CanCollide = false
		lobbyLight.Material = Enum.Material.Neon
		lobbyLight.Color = Color3.fromRGB(255, 240, 200)
		lobbyLight.Parent = building
	end

	building.Parent = DecorUtils.decorFolder
	return building
end

-- Standard skyscraper row
local function createSkyscraper(x, z, scale)
	local bDepthBase = 20
	local bDepth = bDepthBase * scale
	local row = x > 0 and SKY_RIGHT or SKY_LEFT

	-- Main building: front + sides
	buildSkyscraperFromSpec(row[1], x, z, scale, bDepthBase, { showFront = true, showSides = true })

	local dir = x > 0 and 1 or -1
	local curX = x + dir * bDepth
	for i = 2, #row do
		if i <= 2 then
			buildSkyscraperFromSpec(row[i], curX, z, scale, bDepthBase, { showFront = true, showSides = true })
		else
			buildSkyscraperFromSpec(row[i], curX, z, scale, bDepthBase, { showFront = false, showSides = true })
		end
		curX = curX + dir * bDepth
	end
end

--------------------------------------------------------------------------------
-- AD SCREEN HELPERS — ticker and LCD panels for skyscraper variants
--------------------------------------------------------------------------------

local TICKER_TEXT = "DOC +2.3%  RBXL -0.8%  BREAKING: DASH OR CRASH REACHES 1M PLAYERS  LHMN +1.1%  WEATHER: SUNNY WITH CHANCE OF TRAFFIC  DASH +5.0%  CRSH -3.2%  NEWS: LOCAL CHICKEN CROSSES ROAD, CAUSES 12-CAR PILEUP  BLOX +4.7%  "

local function addTickerScreen(building, frontX, z, facadeLen, scale, spec, sign)
	local screenW = facadeLen * 0.8
	local screenH = 6 * scale
	local floorHeight = 6 * scale
	local screenY = BUILDING_BASE + 2.5 * floorHeight

	local screen = Instance.new("Part")
	screen.Name = "TickerScreen"
	screen.Size = Vector3.new(0.5, screenH, screenW)
	screen.Position = Vector3.new(frontX - sign * 0.3, screenY, z)
	screen.Anchored = true
	screen.CanCollide = false
	screen.Material = Enum.Material.Neon
	screen.Color = Color3.fromRGB(20, 20, 25)
	screen.Parent = building

	local gui = Instance.new("SurfaceGui")
	gui.Name = "TickerGui"
	gui.Face = sign > 0 and Enum.NormalId.Left or Enum.NormalId.Right
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 50
	gui.Parent = screen

	local bg = Instance.new("Frame")
	bg.Name = "Background"
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
	bg.BorderSizePixel = 0
	bg.ClipsDescendants = true
	bg.Parent = gui

	local label = Instance.new("TextLabel")
	label.Name = "TickerLabel"
	label.Size = UDim2.new(4, 0, 1, 0)
	label.Position = UDim2.new(0, 0, 0, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.RobotoMono
	label.Text = TICKER_TEXT .. TICKER_TEXT
	label.TextColor3 = spec.glassColor
	label.TextSize = 80
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextScaled = false
	label.Parent = bg

	DecorUtils.activePlatformAnimations[label] = {
		type = "ticker",
		speed = 0.08,
		offset = 0,
	}
end

local function addLCDPanel(building, frontX, z, facadeLen, scale, spec, sign)
	local panelW = facadeLen * 0.7
	local panelH = 14 * scale
	local floorHeight = 6 * scale
	local panelY = BUILDING_BASE + 3.5 * floorHeight

	local panel = Instance.new("Part")
	panel.Name = "LCDPanel"
	panel.Size = Vector3.new(0.5, panelH, panelW)
	panel.Position = Vector3.new(frontX - sign * 0.3, panelY, z)
	panel.Anchored = true
	panel.CanCollide = false
	panel.Material = Enum.Material.Neon
	panel.Color = Color3.fromRGB(15, 15, 20)
	panel.Parent = building

	local gui = Instance.new("SurfaceGui")
	gui.Name = "LCDGui"
	gui.Face = sign > 0 and Enum.NormalId.Left or Enum.NormalId.Right
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 50
	gui.Parent = panel

	local video = Instance.new("VideoFrame")
	video.Name = "AdVideo"
	video.Size = UDim2.new(1, 0, 1, 0)
	video.Video = "rbxassetid://5608403837"
	video.Looped = true
	video.Playing = true
	video.Parent = gui
end

-- Times Square skyscraper
local function createSkyscraperTimesSquare(x, z, scale)
	local bDepthBase = 20
	local bDepth = bDepthBase * scale
	local row = x > 0 and SKY_RIGHT_WARM or SKY_LEFT_WARM

	local sign = x > 0 and 1 or -1
	local spec = row[1]
	local facadeLen = spec.facade * scale
	local frontX = x - sign * (bDepth / 2 + 0.15)

	local building = buildSkyscraperFromSpec(spec, x, z, scale, bDepthBase, { showFront = true, showSides = true })

	local tickerZ = z - facadeLen * 0.3
	local lcdZ = z + facadeLen * 0.3
	addTickerScreen(building, frontX, tickerZ, facadeLen * 0.5, scale, spec, sign)
	addLCDPanel(building, frontX, lcdZ, facadeLen * 0.5, scale, spec, sign)

	local curX = x + sign * bDepth
	for i = 2, #row do
		if i <= 2 then
			local b = buildSkyscraperFromSpec(row[i], curX, z, scale, bDepthBase, { showFront = true, showSides = true })
			local spec2 = row[i]
			local frontX2 = curX - sign * (bDepth / 2 + 0.15)
			addLCDPanel(b, frontX2, z, spec2.facade * scale, scale, spec2, sign)
		else
			buildSkyscraperFromSpec(row[i], curX, z, scale, bDepthBase, { showFront = false, showSides = true })
		end
		curX = curX + sign * bDepth
	end
end

-- Shibuya skyscraper
local function createSkyscraperShibuya(x, z, scale)
	local bDepthBase = 20
	local bDepth = bDepthBase * scale
	local row = x > 0 and SKY_RIGHT_NEON or SKY_LEFT_NEON

	local sign = x > 0 and 1 or -1
	local spec = row[1]
	local facadeLen = spec.facade * scale
	local frontX = x - sign * (bDepth / 2 + 0.15)

	local building = buildSkyscraperFromSpec(spec, x, z, scale, bDepthBase, { showFront = true, showSides = true })

	local lcdZ1 = z - facadeLen * 0.3
	local lcdZ2 = z + facadeLen * 0.3
	addLCDPanel(building, frontX, lcdZ1, facadeLen * 0.5, scale, spec, sign)
	addLCDPanel(building, frontX, lcdZ2, facadeLen * 0.5, scale, spec, sign)

	local curX = x + sign * bDepth
	for i = 2, #row do
		if i <= 2 then
			local b = buildSkyscraperFromSpec(row[i], curX, z, scale, bDepthBase, { showFront = true, showSides = true })
			local spec2 = row[i]
			local frontX2 = curX - sign * (bDepth / 2 + 0.15)
			addLCDPanel(b, frontX2, z, spec2.facade * scale, scale, spec2, sign)
		else
			buildSkyscraperFromSpec(row[i], curX, z, scale, bDepthBase, { showFront = false, showSides = true })
		end
		curX = curX + sign * bDepth
	end
end

--------------------------------------------------------------------------------
-- Public dispatchers
--------------------------------------------------------------------------------

function Skyscrapers.createBuildingSkyscraper(x, z, scale)
	if not DecorUtils.decorFolder then return nil end
	scale = scale or 1
	return createSkyscraper(x, z, scale)
end

function Skyscrapers.createBuildingSkyscraperTimesSquare(x, z, scale)
	if not DecorUtils.decorFolder then return nil end
	scale = scale or 1
	return createSkyscraperTimesSquare(x, z, scale)
end

function Skyscrapers.createBuildingSkyscraperShibuya(x, z, scale)
	if not DecorUtils.decorFolder then return nil end
	scale = scale or 1
	return createSkyscraperShibuya(x, z, scale)
end

return Skyscrapers
