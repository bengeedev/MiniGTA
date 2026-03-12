-- AssetLibrary.luau
-- Unified asset library for MiniGTA. Each asset is a standalone function
-- extracted from legacy DashOrCrash builders with a consistent interface:
--   create(centerX, centerZ, options) → Model
-- No lane/road assumptions. All faces rendered. Ready for 2D grid placement.

local AssetLibrary = {}

local BUILDING_BASE = 4 -- ground surface Y (matches DecorUtils.BUILDING_BASE)

--------------------------------------------------------------------------------
-- SKYSCRAPER SPECS
-- 3 styles × 16 specs each (merged from legacy LEFT/RIGHT tables)
-- Spec: facade, floors, bodyColor, frameColor, glassColor, litPct, crown, entrance
-- Crown types: "antenna", "spire", "glow", "helipad"
--------------------------------------------------------------------------------

local SKYSCRAPER_SPECS = {
	glass = {
		-- Cool blue glass palette (from SKY_LEFT + SKY_RIGHT)
		{ facade = 26, floors = 18, bodyColor = Color3.fromRGB(45, 55, 70),  frameColor = Color3.fromRGB(140, 145, 155), glassColor = Color3.fromRGB(150, 200, 255), litPct = 0.70, crown = "antenna",  entrance = true },
		{ facade = 22, floors = 14, bodyColor = Color3.fromRGB(40, 45, 55),  frameColor = Color3.fromRGB(120, 125, 135), glassColor = Color3.fromRGB(180, 220, 255), litPct = 0.60, crown = "glow" },
		{ facade = 18, floors = 22, bodyColor = Color3.fromRGB(35, 40, 50),  frameColor = Color3.fromRGB(140, 145, 155), glassColor = Color3.fromRGB(150, 200, 255), litPct = 0.75, crown = "spire" },
		{ facade = 28, floors = 12, bodyColor = Color3.fromRGB(55, 60, 70),  frameColor = Color3.fromRGB(120, 125, 135), glassColor = Color3.fromRGB(170, 210, 240), litPct = 0.55, crown = "helipad" },
		{ facade = 24, floors = 16, bodyColor = Color3.fromRGB(40, 50, 65),  frameColor = Color3.fromRGB(140, 145, 155), glassColor = Color3.fromRGB(180, 220, 255), litPct = 0.65, crown = "antenna" },
		{ facade = 20, floors = 20, bodyColor = Color3.fromRGB(35, 45, 60),  frameColor = Color3.fromRGB(120, 125, 135), glassColor = Color3.fromRGB(150, 200, 255), litPct = 0.70, crown = "glow" },
		{ facade = 26, floors = 13, bodyColor = Color3.fromRGB(50, 55, 65),  frameColor = Color3.fromRGB(140, 145, 155), glassColor = Color3.fromRGB(170, 210, 240), litPct = 0.60, crown = "helipad" },
		{ facade = 22, floors = 15, bodyColor = Color3.fromRGB(38, 43, 55),  frameColor = Color3.fromRGB(120, 125, 135), glassColor = Color3.fromRGB(180, 220, 255), litPct = 0.65, crown = "spire" },
		{ facade = 24, floors = 16, bodyColor = Color3.fromRGB(40, 45, 55),  frameColor = Color3.fromRGB(130, 135, 145), glassColor = Color3.fromRGB(180, 220, 255), litPct = 0.65, crown = "spire",   entrance = true },
		{ facade = 28, floors = 20, bodyColor = Color3.fromRGB(35, 40, 50),  frameColor = Color3.fromRGB(110, 115, 125), glassColor = Color3.fromRGB(150, 200, 255), litPct = 0.75, crown = "antenna" },
		{ facade = 18, floors = 13, bodyColor = Color3.fromRGB(55, 60, 70),  frameColor = Color3.fromRGB(130, 135, 145), glassColor = Color3.fromRGB(170, 210, 240), litPct = 0.60, crown = "helipad" },
		{ facade = 22, floors = 22, bodyColor = Color3.fromRGB(38, 48, 62),  frameColor = Color3.fromRGB(110, 115, 125), glassColor = Color3.fromRGB(180, 220, 255), litPct = 0.70, crown = "glow" },
		{ facade = 26, floors = 11, bodyColor = Color3.fromRGB(42, 47, 58),  frameColor = Color3.fromRGB(130, 135, 145), glassColor = Color3.fromRGB(150, 200, 255), litPct = 0.55, crown = "antenna" },
		{ facade = 20, floors = 17, bodyColor = Color3.fromRGB(48, 53, 65),  frameColor = Color3.fromRGB(110, 115, 125), glassColor = Color3.fromRGB(170, 210, 240), litPct = 0.70, crown = "spire" },
		{ facade = 24, floors = 14, bodyColor = Color3.fromRGB(44, 50, 62),  frameColor = Color3.fromRGB(130, 135, 145), glassColor = Color3.fromRGB(180, 220, 255), litPct = 0.65, crown = "glow" },
		{ facade = 22, floors = 12, bodyColor = Color3.fromRGB(50, 55, 68),  frameColor = Color3.fromRGB(110, 115, 125), glassColor = Color3.fromRGB(150, 200, 255), litPct = 0.60, crown = "helipad" },
	},

	warm = {
		-- Times Square amber/gold palette (from SKY_LEFT_WARM + SKY_RIGHT_WARM)
		{ facade = 26, floors = 18, bodyColor = Color3.fromRGB(90, 65, 35),  frameColor = Color3.fromRGB(170, 145, 90),  glassColor = Color3.fromRGB(255, 200, 80),  litPct = 0.88, crown = "antenna",  entrance = true },
		{ facade = 22, floors = 14, bodyColor = Color3.fromRGB(85, 58, 30),  frameColor = Color3.fromRGB(160, 135, 80),  glassColor = Color3.fromRGB(255, 180, 60),  litPct = 0.85, crown = "glow" },
		{ facade = 18, floors = 22, bodyColor = Color3.fromRGB(80, 55, 28),  frameColor = Color3.fromRGB(170, 145, 90),  glassColor = Color3.fromRGB(255, 210, 100), litPct = 0.92, crown = "spire" },
		{ facade = 28, floors = 12, bodyColor = Color3.fromRGB(95, 68, 38),  frameColor = Color3.fromRGB(160, 135, 80),  glassColor = Color3.fromRGB(255, 190, 70),  litPct = 0.85, crown = "helipad" },
		{ facade = 24, floors = 16, bodyColor = Color3.fromRGB(88, 62, 32),  frameColor = Color3.fromRGB(170, 145, 90),  glassColor = Color3.fromRGB(255, 200, 80),  litPct = 0.88, crown = "antenna" },
		{ facade = 20, floors = 20, bodyColor = Color3.fromRGB(82, 58, 30),  frameColor = Color3.fromRGB(160, 135, 80),  glassColor = Color3.fromRGB(255, 185, 65),  litPct = 0.86, crown = "glow" },
		{ facade = 26, floors = 13, bodyColor = Color3.fromRGB(92, 66, 35),  frameColor = Color3.fromRGB(170, 145, 90),  glassColor = Color3.fromRGB(255, 195, 75),  litPct = 0.85, crown = "helipad" },
		{ facade = 22, floors = 15, bodyColor = Color3.fromRGB(86, 60, 32),  frameColor = Color3.fromRGB(160, 135, 80),  glassColor = Color3.fromRGB(255, 205, 90),  litPct = 0.87, crown = "spire" },
		{ facade = 24, floors = 16, bodyColor = Color3.fromRGB(85, 58, 30),  frameColor = Color3.fromRGB(165, 140, 85),  glassColor = Color3.fromRGB(255, 190, 70),  litPct = 0.88, crown = "spire",   entrance = true },
		{ facade = 28, floors = 20, bodyColor = Color3.fromRGB(80, 55, 28),  frameColor = Color3.fromRGB(155, 130, 75),  glassColor = Color3.fromRGB(255, 200, 80),  litPct = 0.90, crown = "antenna" },
		{ facade = 18, floors = 13, bodyColor = Color3.fromRGB(95, 68, 38),  frameColor = Color3.fromRGB(165, 140, 85),  glassColor = Color3.fromRGB(255, 185, 65),  litPct = 0.85, crown = "helipad" },
		{ facade = 22, floors = 22, bodyColor = Color3.fromRGB(83, 58, 30),  frameColor = Color3.fromRGB(155, 130, 75),  glassColor = Color3.fromRGB(255, 210, 100), litPct = 0.92, crown = "glow" },
		{ facade = 26, floors = 11, bodyColor = Color3.fromRGB(88, 63, 33),  frameColor = Color3.fromRGB(165, 140, 85),  glassColor = Color3.fromRGB(255, 195, 75),  litPct = 0.86, crown = "antenna" },
		{ facade = 20, floors = 17, bodyColor = Color3.fromRGB(92, 66, 35),  frameColor = Color3.fromRGB(155, 130, 75),  glassColor = Color3.fromRGB(255, 180, 60),  litPct = 0.87, crown = "spire" },
		{ facade = 24, floors = 14, bodyColor = Color3.fromRGB(86, 60, 32),  frameColor = Color3.fromRGB(165, 140, 85),  glassColor = Color3.fromRGB(255, 200, 85),  litPct = 0.86, crown = "glow" },
		{ facade = 22, floors = 12, bodyColor = Color3.fromRGB(90, 64, 34),  frameColor = Color3.fromRGB(155, 130, 75),  glassColor = Color3.fromRGB(255, 190, 70),  litPct = 0.85, crown = "helipad" },
	},

	neon = {
		-- Shibuya neon pink/purple palette (from SKY_LEFT_NEON + SKY_RIGHT_NEON)
		{ facade = 26, floors = 18, bodyColor = Color3.fromRGB(65, 35, 85),  frameColor = Color3.fromRGB(140, 110, 160), glassColor = Color3.fromRGB(255, 100, 200), litPct = 0.90, crown = "antenna",  entrance = true },
		{ facade = 22, floors = 14, bodyColor = Color3.fromRGB(58, 30, 78),  frameColor = Color3.fromRGB(130, 100, 150), glassColor = Color3.fromRGB(200, 80, 255),  litPct = 0.88, crown = "glow" },
		{ facade = 18, floors = 22, bodyColor = Color3.fromRGB(55, 28, 75),  frameColor = Color3.fromRGB(140, 110, 160), glassColor = Color3.fromRGB(255, 120, 220), litPct = 0.92, crown = "spire" },
		{ facade = 28, floors = 12, bodyColor = Color3.fromRGB(70, 38, 90),  frameColor = Color3.fromRGB(130, 100, 150), glassColor = Color3.fromRGB(220, 90, 255),  litPct = 0.88, crown = "helipad" },
		{ facade = 24, floors = 16, bodyColor = Color3.fromRGB(62, 32, 82),  frameColor = Color3.fromRGB(140, 110, 160), glassColor = Color3.fromRGB(255, 110, 210), litPct = 0.90, crown = "antenna" },
		{ facade = 20, floors = 20, bodyColor = Color3.fromRGB(56, 30, 76),  frameColor = Color3.fromRGB(130, 100, 150), glassColor = Color3.fromRGB(210, 85, 255),  litPct = 0.88, crown = "glow" },
		{ facade = 26, floors = 13, bodyColor = Color3.fromRGB(68, 36, 88),  frameColor = Color3.fromRGB(140, 110, 160), glassColor = Color3.fromRGB(255, 105, 205), litPct = 0.87, crown = "helipad" },
		{ facade = 22, floors = 15, bodyColor = Color3.fromRGB(60, 32, 80),  frameColor = Color3.fromRGB(130, 100, 150), glassColor = Color3.fromRGB(215, 88, 255),  litPct = 0.89, crown = "spire" },
		{ facade = 24, floors = 16, bodyColor = Color3.fromRGB(58, 30, 78),  frameColor = Color3.fromRGB(135, 105, 155), glassColor = Color3.fromRGB(255, 110, 210), litPct = 0.90, crown = "spire",   entrance = true },
		{ facade = 28, floors = 20, bodyColor = Color3.fromRGB(55, 28, 75),  frameColor = Color3.fromRGB(125, 95, 145),  glassColor = Color3.fromRGB(200, 80, 255),  litPct = 0.92, crown = "antenna" },
		{ facade = 18, floors = 13, bodyColor = Color3.fromRGB(70, 38, 90),  frameColor = Color3.fromRGB(135, 105, 155), glassColor = Color3.fromRGB(220, 90, 255),  litPct = 0.87, crown = "helipad" },
		{ facade = 22, floors = 22, bodyColor = Color3.fromRGB(62, 32, 82),  frameColor = Color3.fromRGB(125, 95, 145),  glassColor = Color3.fromRGB(255, 120, 220), litPct = 0.92, crown = "glow" },
		{ facade = 26, floors = 11, bodyColor = Color3.fromRGB(64, 34, 84),  frameColor = Color3.fromRGB(135, 105, 155), glassColor = Color3.fromRGB(210, 85, 255),  litPct = 0.88, crown = "antenna" },
		{ facade = 20, floors = 17, bodyColor = Color3.fromRGB(68, 36, 88),  frameColor = Color3.fromRGB(125, 95, 145),  glassColor = Color3.fromRGB(255, 100, 200), litPct = 0.90, crown = "spire" },
		{ facade = 24, floors = 14, bodyColor = Color3.fromRGB(60, 32, 80),  frameColor = Color3.fromRGB(135, 105, 155), glassColor = Color3.fromRGB(215, 88, 255),  litPct = 0.88, crown = "glow" },
		{ facade = 22, floors = 12, bodyColor = Color3.fromRGB(66, 35, 86),  frameColor = Color3.fromRGB(125, 95, 145),  glassColor = Color3.fromRGB(255, 105, 205), litPct = 0.87, crown = "helipad" },
	},
}

--------------------------------------------------------------------------------
-- SKYSCRAPER BUILDER
-- Builds ONE standalone glass skyscraper at (centerX, centerZ).
-- All 4 faces rendered (no lane/road assumptions).
--
-- options:
--   style     = "glass" | "warm" | "neon"  (default: "glass")
--   specIndex = 1..16                       (default: random)
--   scale     = number                      (default: 1)
--   depth     = number                      (default: 20, base depth before scale)
--   parent    = Instance                    (default: nil, caller parents it)
--------------------------------------------------------------------------------

local function buildGlassPanelFace(building, spec, faceAxis, faceCoord, faceLen, centerOther, floorHeight, scale, darkGlass, isDetailed)
	local panelGap = 0.6
	local panelH = floorHeight - 0.8
	local panelW = (isDetailed and 3.5 or 3.0) * scale
	local margin = 1.5
	local available = faceLen - 2 * margin
	local numPanels = math.max(1, math.floor((available + panelGap) / (panelW + panelGap)))
	local totalPW = numPanels * panelW + (numPanels - 1) * panelGap
	local startOff = -totalPW / 2 + panelW / 2
	local litPct = isDetailed and spec.litPct or (spec.litPct * 0.6)

	-- Horizontal bands
	for floor = 1, spec.floors do
		local bandY = BUILDING_BASE + floor * floorHeight
		local band = Instance.new("Part")
		if faceAxis == "x" then
			band.Size = Vector3.new(0.4, 0.4, faceLen)
			band.Position = Vector3.new(faceCoord, bandY, centerOther)
		else
			band.Size = Vector3.new(faceLen, 0.4, 0.4)
			band.Position = Vector3.new(centerOther, bandY, faceCoord)
		end
		band.Anchored = true
		band.CanCollide = false
		band.Material = Enum.Material.Metal
		band.Color = spec.frameColor
		band.Parent = building
	end

	-- Vertical edge columns
	local height = spec.floors * floorHeight
	local offsets = { -faceLen / 2 + 0.3, faceLen / 2 - 0.3 }
	for _, off in ipairs(offsets) do
		local col = Instance.new("Part")
		if faceAxis == "x" then
			col.Size = Vector3.new(0.5, height, 0.6)
			col.Position = Vector3.new(faceCoord, BUILDING_BASE + height / 2, centerOther + off)
		else
			col.Size = Vector3.new(0.6, height, 0.5)
			col.Position = Vector3.new(centerOther + off, BUILDING_BASE + height / 2, faceCoord)
		end
		col.Anchored = true
		col.CanCollide = false
		col.Material = Enum.Material.Metal
		col.Color = spec.frameColor
		col.Parent = building
	end

	-- Glass panels
	for floor = 2, spec.floors do
		local panelY = BUILDING_BASE + (floor - 0.5) * floorHeight
		for p = 1, numPanels do
			local off = startOff + (p - 1) * (panelW + panelGap)
			local panel = Instance.new("Part")
			if faceAxis == "x" then
				panel.Size = Vector3.new(0.3, panelH, panelW)
				panel.Position = Vector3.new(faceCoord, panelY, centerOther + off)
			else
				panel.Size = Vector3.new(panelW, panelH, 0.3)
				panel.Position = Vector3.new(centerOther + off, panelY, faceCoord)
			end
			panel.Anchored = true
			panel.CanCollide = false
			if math.random() < litPct then
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

function AssetLibrary.createSkyscraper(centerX, centerZ, options)
	options = options or {}
	local style = options.style or "glass"
	local scale = options.scale or 1
	local bDepthBase = options.depth or 20

	local specs = SKYSCRAPER_SPECS[style] or SKYSCRAPER_SPECS.glass
	local specIndex = options.specIndex or math.random(1, #specs)
	local spec = specs[math.clamp(specIndex, 1, #specs)]

	local building = Instance.new("Model")
	building.Name = "Skyscraper_" .. style .. "_" .. specIndex

	local bDepth = bDepthBase * scale
	local facadeLen = spec.facade * scale
	local floorHeight = 6 * scale
	local height = spec.floors * floorHeight

	-- Compute darkGlass tint from spec glassColor
	local gc = spec.glassColor
	local darkGlass = Color3.fromRGB(
		math.floor(gc.R * 255 * 0.18 + 30),
		math.floor(gc.G * 255 * 0.18 + 35),
		math.floor(gc.B * 255 * 0.18 + 45)
	)

	-- Glass core body
	local core = Instance.new("Part")
	core.Size = Vector3.new(bDepth, height, facadeLen)
	core.Position = Vector3.new(centerX, BUILDING_BASE + height / 2, centerZ)
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
	roof.Position = Vector3.new(centerX, BUILDING_BASE + height + 0.25, centerZ)
	roof.Anchored = true
	roof.Material = Enum.Material.Metal
	roof.Color = spec.frameColor
	roof:SetAttribute("ThemeRole", "building_roof")
	roof:SetAttribute("BaseColor", spec.frameColor)
	roof:SetAttribute("BaseMaterial", "Metal")
	roof.Parent = building

	-- All 4 faces: front(-X), back(+X), left(-Z), right(+Z)
	-- Front and back are X-axis faces (detailed), sides are Z-axis faces
	local frontX = centerX - bDepth / 2 - 0.15
	local backX  = centerX + bDepth / 2 + 0.15
	local leftZ  = centerZ - facadeLen / 2 - 0.15
	local rightZ = centerZ + facadeLen / 2 + 0.15

	-- Front face (-X): detailed panels
	buildGlassPanelFace(building, spec, "x", frontX, facadeLen, centerZ, floorHeight, scale, darkGlass, true)
	-- Back face (+X): detailed panels
	buildGlassPanelFace(building, spec, "x", backX, facadeLen, centerZ, floorHeight, scale, darkGlass, true)
	-- Left face (-Z): side panels
	buildGlassPanelFace(building, spec, "z", leftZ, bDepth, centerX, floorHeight, scale, darkGlass, false)
	-- Right face (+Z): side panels
	buildGlassPanelFace(building, spec, "z", rightZ, bDepth, centerX, floorHeight, scale, darkGlass, false)

	-- Crown features
	if spec.crown == "antenna" then
		local antenna = Instance.new("Part")
		antenna.Size = Vector3.new(0.5, 10 * scale, 0.5)
		antenna.Position = Vector3.new(centerX, BUILDING_BASE + height + 5 * scale, centerZ)
		antenna.Anchored = true
		antenna.Material = Enum.Material.Metal
		antenna.Color = Color3.fromRGB(80, 80, 85)
		antenna.Parent = building

		local tip = Instance.new("Part")
		tip.Size = Vector3.new(1, 1, 1)
		tip.Position = Vector3.new(centerX, BUILDING_BASE + height + 10 * scale + 0.5, centerZ)
		tip.Anchored = true
		tip.CanCollide = false
		tip.Shape = Enum.PartType.Ball
		tip.Material = Enum.Material.Neon
		tip.Color = Color3.fromRGB(255, 50, 50)
		tip.Parent = building

	elseif spec.crown == "spire" then
		local spire = Instance.new("Part")
		spire.Size = Vector3.new(2 * scale, 14 * scale, 2 * scale)
		spire.Position = Vector3.new(centerX, BUILDING_BASE + height + 7 * scale, centerZ)
		spire.Anchored = true
		spire.Material = Enum.Material.Metal
		spire.Color = Color3.fromRGB(180, 185, 195)
		spire.Parent = building

	elseif spec.crown == "glow" then
		local crownPart = Instance.new("Part")
		crownPart.Size = Vector3.new(bDepth + 1, 2, facadeLen + 1)
		crownPart.Position = Vector3.new(centerX, BUILDING_BASE + height + 1, centerZ)
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
		pad.Position = Vector3.new(centerX, BUILDING_BASE + height + 0.5, centerZ)
		pad.Anchored = true
		pad.Material = Enum.Material.Concrete
		pad.Color = Color3.fromRGB(85, 85, 90)
		pad.Parent = building

		local markH = Instance.new("Part")
		markH.Size = Vector3.new(3, 0.1, 3)
		markH.Position = Vector3.new(centerX, BUILDING_BASE + height + 0.8, centerZ)
		markH.Anchored = true
		markH.CanCollide = false
		markH.Material = Enum.Material.Neon
		markH.Color = Color3.fromRGB(255, 255, 100)
		markH.Parent = building
	end

	-- Glass lobby entrance (front face, specs with entrance = true)
	if spec.entrance then
		local doorWidth = 5 * scale
		local doorHeight = 8 * scale
		local doorY = BUILDING_BASE + doorHeight / 2
		local lobbyX = frontX - 1.5 * scale

		local lobby = Instance.new("Part")
		lobby.Name = "Lobby"
		lobby.Size = Vector3.new(3 * scale, doorHeight, doorWidth + 2)
		lobby.Position = Vector3.new(lobbyX, doorY, centerZ)
		lobby.Anchored = true
		lobby.Material = Enum.Material.Glass
		lobby.Color = Color3.fromRGB(50, 70, 90)
		lobby.Transparency = 0.3
		lobby.Parent = building

		local lobbyLight = Instance.new("Part")
		lobbyLight.Size = Vector3.new(2, 0.3, doorWidth)
		lobbyLight.Position = Vector3.new(lobbyX, BUILDING_BASE + doorHeight + 0.5, centerZ)
		lobbyLight.Anchored = true
		lobbyLight.CanCollide = false
		lobbyLight.Material = Enum.Material.Neon
		lobbyLight.Color = Color3.fromRGB(255, 240, 200)
		lobbyLight.Parent = building

		-- Also add a lobby on back face (+X)
		local backLobbyX = backX + 1.5 * scale
		local lobby2 = lobby:Clone()
		lobby2.Position = Vector3.new(backLobbyX, doorY, centerZ)
		lobby2.Parent = building

		local lobbyLight2 = lobbyLight:Clone()
		lobbyLight2.Position = Vector3.new(backLobbyX, BUILDING_BASE + doorHeight + 0.5, centerZ)
		lobbyLight2.Parent = building
	end

	-- Parent to caller's folder if provided
	if options.parent then
		building.Parent = options.parent
	end

	return building
end

-- Convenience: get spec count for a style
function AssetLibrary.getSkyscraperCount(style)
	local specs = SKYSCRAPER_SPECS[style or "glass"]
	return specs and #specs or 0
end

-- List all available styles
function AssetLibrary.getSkyscraperStyles()
	return { "glass", "warm", "neon" }
end

--------------------------------------------------------------------------------
-- TICKER SCREEN
-- Scrolling stock ticker panel (Times Square style).
-- Attaches to a building face. Returns the screen Part + label for animation.
--
-- options:
--   width      = number  (screen width, default: 20)
--   height     = number  (screen height, default: 6)
--   y          = number  (center Y position, default: BUILDING_BASE + 15)
--   face       = "x" | "z"  (which axis the screen faces, default: "x")
--   textColor  = Color3  (ticker text color, default: amber)
--   tickerText = string  (custom text, default: stock ticker)
--   parent     = Instance
--------------------------------------------------------------------------------

local TICKER_TEXT_DEFAULT = "DOC +2.3%  RBXL -0.8%  BREAKING: DASH OR CRASH REACHES 1M PLAYERS  LHMN +1.1%  WEATHER: SUNNY WITH CHANCE OF TRAFFIC  DASH +5.0%  CRSH -3.2%  NEWS: LOCAL CHICKEN CROSSES ROAD, CAUSES 12-CAR PILEUP  BLOX +4.7%  "

function AssetLibrary.createTickerScreen(centerX, centerZ, options)
	options = options or {}
	local screenW = options.width or 20
	local screenH = options.height or 6
	local screenY = options.y or (BUILDING_BASE + 15)
	local faceAxis = options.face or "x"
	local textColor = options.textColor or Color3.fromRGB(255, 200, 80)
	local tickerText = options.tickerText or TICKER_TEXT_DEFAULT

	local screen = Instance.new("Part")
	screen.Name = "TickerScreen"
	if faceAxis == "x" then
		screen.Size = Vector3.new(0.5, screenH, screenW)
	else
		screen.Size = Vector3.new(screenW, screenH, 0.5)
	end
	screen.Position = Vector3.new(centerX, screenY, centerZ)
	screen.Anchored = true
	screen.CanCollide = false
	screen.Material = Enum.Material.Neon
	screen.Color = Color3.fromRGB(20, 20, 25)

	local gui = Instance.new("SurfaceGui")
	gui.Name = "TickerGui"
	gui.Face = faceAxis == "x" and Enum.NormalId.Right or Enum.NormalId.Front
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
	label.Text = tickerText .. tickerText
	label.TextColor3 = textColor
	label.TextSize = 80
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextScaled = false
	label.Parent = bg

	if options.parent then
		screen.Parent = options.parent
	end

	-- Returns screen + label so caller can register ticker animation
	return screen, label
end

--------------------------------------------------------------------------------
-- LCD PANEL
-- Large video/ad display panel for building facades.
-- Returns the panel Part (contains SurfaceGui with VideoFrame).
--
-- options:
--   width   = number  (panel width, default: 18)
--   height  = number  (panel height, default: 14)
--   y       = number  (center Y, default: BUILDING_BASE + 21)
--   face    = "x" | "z"  (default: "x")
--   videoId = string  (rbxassetid, default: "rbxassetid://5608403837")
--   parent  = Instance
--------------------------------------------------------------------------------

function AssetLibrary.createLCDPanel(centerX, centerZ, options)
	options = options or {}
	local panelW = options.width or 18
	local panelH = options.height or 14
	local panelY = options.y or (BUILDING_BASE + 21)
	local faceAxis = options.face or "x"
	local videoId = options.videoId or "rbxassetid://5608403837"

	local panel = Instance.new("Part")
	panel.Name = "LCDPanel"
	if faceAxis == "x" then
		panel.Size = Vector3.new(0.5, panelH, panelW)
	else
		panel.Size = Vector3.new(panelW, panelH, 0.5)
	end
	panel.Position = Vector3.new(centerX, panelY, centerZ)
	panel.Anchored = true
	panel.CanCollide = false
	panel.Material = Enum.Material.Neon
	panel.Color = Color3.fromRGB(15, 15, 20)

	local gui = Instance.new("SurfaceGui")
	gui.Name = "LCDGui"
	gui.Face = faceAxis == "x" and Enum.NormalId.Right or Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 50
	gui.Parent = panel

	local video = Instance.new("VideoFrame")
	video.Name = "AdVideo"
	video.Size = UDim2.new(1, 0, 1, 0)
	video.Video = videoId
	video.Looped = true
	video.Playing = true
	video.Parent = gui

	if options.parent then
		panel.Parent = options.parent
	end

	return panel
end

--------------------------------------------------------------------------------
-- HELIPAD
-- Rooftop helipad with platform, support struts, safety railings, H marking,
-- and neon circle. Standalone — place on any flat surface.
--
-- options:
--   width   = number  (pad width along X, default: 26)
--   depth   = number  (pad depth along Z, default: 22)
--   roofY   = number  (Y of the surface to place on, default: BUILDING_BASE)
--   parent  = Instance
--------------------------------------------------------------------------------

function AssetLibrary.createHelipad(centerX, centerZ, options)
	options = options or {}
	local padW = options.width or 26
	local padD = options.depth or 22
	local padY = options.roofY or BUILDING_BASE
	local padThick = 0.5

	local model = Instance.new("Model")
	model.Name = "Helipad"

	-- Main platform
	local padFloor = Instance.new("Part")
	padFloor.Name = "HelipadFloor"
	padFloor.Size = Vector3.new(padW, padThick, padD)
	padFloor.Position = Vector3.new(centerX, padY, centerZ)
	padFloor.Anchored = true
	padFloor.CanCollide = true
	padFloor.Material = Enum.Material.DiamondPlate
	padFloor.Color = Color3.fromRGB(130, 135, 140)
	padFloor.Parent = model

	-- Support struts underneath
	for _, sz in ipairs({ -1, 1 }) do
		local strut = Instance.new("Part")
		strut.Name = "HelipadStrut"
		strut.Size = Vector3.new(1.5, 12, 1.5)
		strut.Position = Vector3.new(centerX + padW / 2 - 3, padY - 6, centerZ + sz * (padD / 2 - 3))
		strut.Anchored = true
		strut.CanCollide = false
		strut.Material = Enum.Material.DiamondPlate
		strut.Color = Color3.fromRGB(80, 85, 90)
		strut.Parent = model

		local brace = Instance.new("Part")
		brace.Name = "HelipadBrace"
		brace.Size = Vector3.new(1, 1, 14)
		brace.CFrame = CFrame.new(centerX + padW / 4, padY - 8, centerZ + sz * (padD / 2 - 3))
			* CFrame.Angles(math.rad(35), 0, 0)
		brace.Anchored = true
		brace.CanCollide = false
		brace.Material = Enum.Material.DiamondPlate
		brace.Color = Color3.fromRGB(80, 85, 90)
		brace.Parent = model
	end

	-- Safety railings (3 sides)
	local railH = 3
	local railThick = 0.2
	local railY = padY + railH / 2 + padThick / 2
	local railColor = Color3.fromRGB(180, 185, 190)

	for _, rail in ipairs({
		{ Vector3.new(padW, railH, railThick), Vector3.new(centerX, railY, centerZ + padD / 2) },  -- front +Z
		{ Vector3.new(padW, railH, railThick), Vector3.new(centerX, railY, centerZ - padD / 2) },  -- back -Z
		{ Vector3.new(railThick, railH, padD), Vector3.new(centerX + padW / 2, railY, centerZ) },  -- outer +X
	}) do
		local r = Instance.new("Part")
		r.Name = "HelipadRail"
		r.Size = rail[1]
		r.Position = rail[2]
		r.Anchored = true
		r.CanCollide = true
		r.Material = Enum.Material.Metal
		r.Color = railColor
		r.Transparency = 0.3
		r.Parent = model
	end

	-- "H" marking (neon on pad surface)
	local hMarkY = padY + padThick / 2 + 0.05
	local hColor = Color3.fromRGB(255, 255, 255)
	local hBarW = 1.2
	local hBarH = 10
	local hGap = 5

	for _, bar in ipairs({
		{ Vector3.new(hBarW, 0.1, hBarH), Vector3.new(centerX - hGap / 2, hMarkY, centerZ) },
		{ Vector3.new(hBarW, 0.1, hBarH), Vector3.new(centerX + hGap / 2, hMarkY, centerZ) },
		{ Vector3.new(hGap + hBarW, 0.1, hBarW), Vector3.new(centerX, hMarkY, centerZ) },
	}) do
		local b = Instance.new("Part")
		b.Name = "HelipadH"
		b.Size = bar[1]
		b.Position = bar[2]
		b.Anchored = true
		b.CanCollide = false
		b.Material = Enum.Material.Neon
		b.Color = hColor
		b.Parent = model
	end

	-- Neon circle around the H
	local circleR = 8
	local segments = 24
	for i = 1, segments do
		local a1 = math.rad((i - 1) * 360 / segments)
		local a2 = math.rad(i * 360 / segments)
		local mx = centerX + circleR * math.cos((a1 + a2) / 2)
		local mz = centerZ + circleR * math.sin((a1 + a2) / 2)
		local segLen = 2 * circleR * math.sin(math.rad(360 / segments / 2))

		local seg = Instance.new("Part")
		seg.Name = "HelipadCircle"
		seg.Size = Vector3.new(segLen, 0.1, 0.6)
		seg.CFrame = CFrame.new(mx, hMarkY, mz) * CFrame.Angles(0, -(a1 + a2) / 2 + math.rad(90), 0)
		seg.Anchored = true
		seg.CanCollide = false
		seg.Material = Enum.Material.Neon
		seg.Color = hColor
		seg.Parent = model
	end

	if options.parent then
		model.Parent = options.parent
	end

	return model
end

--------------------------------------------------------------------------------
-- ELEVATOR SHAFT
-- Glass elevator with steel shaft rails, rideable platform, glass cabin with
-- neon accent strips. Returns model + parts table for animation.
--
-- options:
--   height    = number  (shaft height, default: 144)
--   shaftW    = number  (shaft width, default: 6)
--   shaftD    = number  (shaft depth, default: 5)
--   neonColor = Color3  (accent color, default: cyan)
--   parent    = Instance
--------------------------------------------------------------------------------

function AssetLibrary.createElevatorShaft(centerX, centerZ, options)
	options = options or {}
	local shaftHeight = options.height or 144
	local shaftW = options.shaftW or 6
	local shaftD = options.shaftD or 5
	local neonColor = options.neonColor or Color3.fromRGB(0, 180, 255)

	local model = Instance.new("Model")
	model.Name = "ElevatorShaft"

	-- Steel frame rails at 4 corners
	for dx = -1, 1, 2 do
		for dz = -1, 1, 2 do
			local rail = Instance.new("Part")
			rail.Name = "ShaftRail"
			rail.Size = Vector3.new(0.3, shaftHeight, 0.3)
			rail.Position = Vector3.new(
				centerX + dx * (shaftW / 2 - 0.15),
				BUILDING_BASE + shaftHeight / 2,
				centerZ + dz * (shaftD / 2 - 0.15)
			)
			rail.Anchored = true
			rail.CanCollide = false
			rail.Material = Enum.Material.DiamondPlate
			rail.Color = Color3.fromRGB(80, 85, 95)
			rail.Parent = model
		end
	end

	-- Elevator platform (rideable)
	local elevBaseY = BUILDING_BASE + 2
	local platformH = 0.4
	local platform = Instance.new("Part")
	platform.Name = "ElevatorPlatform"
	platform.Size = Vector3.new(shaftW - 0.6, platformH, shaftD - 0.6)
	platform.Position = Vector3.new(centerX, elevBaseY + platformH / 2, centerZ)
	platform.Anchored = true
	platform.CanCollide = true
	platform.Material = Enum.Material.DiamondPlate
	platform.Color = Color3.fromRGB(160, 165, 170)
	platform.Parent = model

	-- Cabin dimensions
	local cabinH = 8.0
	local cabinWallThick = 0.15
	local cabinW = shaftW - 0.6
	local cabinD = shaftD - 0.6
	local cabinBaseY = elevBaseY + platformH
	local cabinCenterY = cabinBaseY + cabinH / 2
	local neonThick = 0.12

	local cabinParts = {}
	local function addCabinPart(part)
		part.Anchored = true
		part.Parent = model
		table.insert(cabinParts, part)
		return part
	end

	-- Left wall (glass)
	local leftWall = Instance.new("Part")
	leftWall.Name = "ElevatorCabinLeft"
	leftWall.Size = Vector3.new(cabinWallThick, cabinH, cabinD)
	leftWall.Position = Vector3.new(centerX - cabinW / 2, cabinCenterY, centerZ)
	leftWall.CanCollide = true
	leftWall.Material = Enum.Material.Glass
	leftWall.Color = Color3.fromRGB(180, 215, 245)
	leftWall.Transparency = 0.5
	addCabinPart(leftWall)

	-- Right wall (glass)
	local rightWall = Instance.new("Part")
	rightWall.Name = "ElevatorCabinRight"
	rightWall.Size = Vector3.new(cabinWallThick, cabinH, cabinD)
	rightWall.Position = Vector3.new(centerX + cabinW / 2, cabinCenterY, centerZ)
	rightWall.CanCollide = true
	rightWall.Material = Enum.Material.Glass
	rightWall.Color = Color3.fromRGB(180, 215, 245)
	rightWall.Transparency = 0.5
	addCabinPart(rightWall)

	-- Ceiling (glass)
	local ceiling = Instance.new("Part")
	ceiling.Name = "ElevatorCabinCeiling"
	ceiling.Size = Vector3.new(cabinW, 0.3, cabinD)
	ceiling.Position = Vector3.new(centerX, cabinBaseY + cabinH, centerZ)
	ceiling.CanCollide = false
	ceiling.Material = Enum.Material.Glass
	ceiling.Color = Color3.fromRGB(180, 215, 245)
	ceiling.Transparency = 0.5
	addCabinPart(ceiling)

	-- Handrail on back wall
	local handrail = Instance.new("Part")
	handrail.Name = "ElevatorHandrail"
	handrail.Size = Vector3.new(cabinW - 0.6, 0.12, 0.12)
	handrail.Position = Vector3.new(centerX, cabinBaseY + 2.5, centerZ - cabinD / 2 + 0.2)
	handrail.CanCollide = false
	handrail.Material = Enum.Material.DiamondPlate
	handrail.Color = Color3.fromRGB(100, 105, 110)
	addCabinPart(handrail)

	-- Ceiling light (neon)
	local elevLight = Instance.new("Part")
	elevLight.Name = "ElevatorCeilingLight"
	elevLight.Size = Vector3.new(cabinW - 1.0, 0.1, cabinD - 1.0)
	elevLight.Position = Vector3.new(centerX, cabinBaseY + cabinH - 0.25, centerZ)
	elevLight.CanCollide = false
	elevLight.Material = Enum.Material.Neon
	elevLight.Color = Color3.fromRGB(200, 230, 255)
	elevLight.Transparency = 0.3
	addCabinPart(elevLight)

	-- Neon accent strips — vertical edges (4 corners)
	for _, edge in ipairs({
		{ Vector3.new(neonThick, cabinH, neonThick), Vector3.new(centerX - cabinW / 2 + neonThick, cabinCenterY, centerZ - cabinD / 2 + neonThick) },
		{ Vector3.new(neonThick, cabinH, neonThick), Vector3.new(centerX + cabinW / 2 - neonThick, cabinCenterY, centerZ - cabinD / 2 + neonThick) },
		{ Vector3.new(neonThick, cabinH, neonThick), Vector3.new(centerX - cabinW / 2 + neonThick, cabinCenterY, centerZ + cabinD / 2 - neonThick) },
		{ Vector3.new(neonThick, cabinH, neonThick), Vector3.new(centerX + cabinW / 2 - neonThick, cabinCenterY, centerZ + cabinD / 2 - neonThick) },
	}) do
		local strip = Instance.new("Part")
		strip.Name = "ElevatorNeonEdge"
		strip.Size = edge[1]
		strip.Position = edge[2]
		strip.CanCollide = false
		strip.Material = Enum.Material.Neon
		strip.Color = neonColor
		strip.Transparency = 0.1
		addCabinPart(strip)
	end

	-- Neon floor trim strips (bottom edge: back + sides)
	for _, trim in ipairs({
		{ Vector3.new(cabinW, neonThick, neonThick), Vector3.new(centerX, cabinBaseY + neonThick / 2, centerZ - cabinD / 2 + neonThick) },
		{ Vector3.new(neonThick, neonThick, cabinD), Vector3.new(centerX - cabinW / 2 + neonThick, cabinBaseY + neonThick / 2, centerZ) },
		{ Vector3.new(neonThick, neonThick, cabinD), Vector3.new(centerX + cabinW / 2 - neonThick, cabinBaseY + neonThick / 2, centerZ) },
	}) do
		local strip = Instance.new("Part")
		strip.Name = "ElevatorNeonTrim"
		strip.Size = trim[1]
		strip.Position = trim[2]
		strip.CanCollide = false
		strip.Material = Enum.Material.Neon
		strip.Color = neonColor
		strip.Transparency = 0.1
		addCabinPart(strip)
	end

	-- Neon ceiling trim strips (top edge: back + sides)
	for _, trim in ipairs({
		{ Vector3.new(cabinW, neonThick, neonThick), Vector3.new(centerX, cabinBaseY + cabinH - neonThick / 2, centerZ - cabinD / 2 + neonThick) },
		{ Vector3.new(neonThick, neonThick, cabinD), Vector3.new(centerX - cabinW / 2 + neonThick, cabinBaseY + cabinH - neonThick / 2, centerZ) },
		{ Vector3.new(neonThick, neonThick, cabinD), Vector3.new(centerX + cabinW / 2 - neonThick, cabinBaseY + cabinH - neonThick / 2, centerZ) },
	}) do
		local strip = Instance.new("Part")
		strip.Name = "ElevatorNeonTrim"
		strip.Size = trim[1]
		strip.Position = trim[2]
		strip.CanCollide = false
		strip.Material = Enum.Material.Neon
		strip.Color = neonColor
		strip.Transparency = 0.1
		addCabinPart(strip)
	end

	if options.parent then
		model.Parent = options.parent
	end

	-- Return model + animation data for caller to register
	return model, {
		platform = platform,
		elevLight = elevLight,
		cabinParts = cabinParts,
		cabinH = cabinH,
		shaftX = centerX,
		shaftZ = centerZ,
		shaftW = shaftW,
		shaftD = shaftD,
		startY = elevBaseY + platformH / 2,
		endY = BUILDING_BASE + shaftHeight + 0.5 + platformH / 2,
	}
end

--------------------------------------------------------------------------------
-- ROOFTOP ANTENNA
-- Thin pole + pulsing red beacon + optional cross-arms.
-- 4 variants: simple pole (1-2), lattice with cross-arms (3-4).
-- Returns the model + beacon parts (for pulse animation).
--
-- options:
--   roofY    = number  (top surface Y, default: BUILDING_BASE)
--   roofW    = number  (building width, for random edge placement)
--   roofD    = number  (building depth, for random edge placement)
--   variant  = 1..4    (default: random)
--   parent   = Instance
--------------------------------------------------------------------------------

function AssetLibrary.createRooftopAntenna(centerX, centerZ, options)
	options = options or {}
	local roofY = options.roofY or BUILDING_BASE
	local roofW = options.roofW or 20
	local roofD = options.roofD or 20
	local variant = options.variant or math.random(1, 4)

	local model = Instance.new("Model")
	model.Name = "RooftopAntenna"

	-- Place near a random edge/corner
	local edgeX = centerX + (math.random() - 0.5) * (roofW - 3)
	local edgeZ = centerZ + (math.random() - 0.5) * (roofD - 3)

	local poleH
	if variant <= 2 then
		poleH = math.random(6, 12)
	else
		poleH = math.random(10, 18)
	end

	local poleColor = Color3.fromRGB(70, 70, 65)
	local beaconColor = Color3.fromRGB(255, 30, 20)

	-- Main pole
	local pole = Instance.new("Part")
	pole.Name = "AntennaPole"
	pole.Size = Vector3.new(0.3, poleH, 0.3)
	pole.Position = Vector3.new(edgeX, roofY + poleH / 2, edgeZ)
	pole.Anchored = true
	pole.CanCollide = false
	pole.Material = Enum.Material.Metal
	pole.Color = poleColor
	pole.Parent = model

	-- Red beacon on top
	local beacon = Instance.new("Part")
	beacon.Name = "AntennaBeacon"
	beacon.Shape = Enum.PartType.Ball
	beacon.Size = Vector3.new(0.8, 0.8, 0.8)
	beacon.Position = Vector3.new(edgeX, roofY + poleH + 0.4, edgeZ)
	beacon.Anchored = true
	beacon.CanCollide = false
	beacon.Material = Enum.Material.Neon
	beacon.Color = beaconColor
	beacon.Parent = model

	local beaconGlow = Instance.new("PointLight")
	beaconGlow.Color = Color3.fromRGB(255, 40, 30)
	beaconGlow.Brightness = 2
	beaconGlow.Range = 14
	beaconGlow.Parent = beacon

	local beacons = { { part = beacon, light = beaconGlow, phase = math.random() * math.pi * 2 } }

	-- Cross-arms (variants 3-4)
	if variant == 3 or variant == 4 then
		local armY = roofY + poleH * 0.6
		for _, dir in ipairs({ -1, 1 }) do
			local arm = Instance.new("Part")
			arm.Name = "AntennaCrossArm"
			arm.Size = Vector3.new(2.5, 0.2, 0.2)
			arm.Position = Vector3.new(edgeX + dir * 1.25, armY, edgeZ)
			arm.Anchored = true
			arm.CanCollide = false
			arm.Material = Enum.Material.Metal
			arm.Color = Color3.fromRGB(55, 55, 50)
			arm.Parent = model
		end
	end

	-- Second mid-height beacon (variant 4 only)
	if variant == 4 then
		local midY = roofY + poleH * 0.45
		local midBeacon = Instance.new("Part")
		midBeacon.Name = "AntennaBeaconMid"
		midBeacon.Shape = Enum.PartType.Ball
		midBeacon.Size = Vector3.new(0.5, 0.5, 0.5)
		midBeacon.Position = Vector3.new(edgeX, midY, edgeZ)
		midBeacon.Anchored = true
		midBeacon.CanCollide = false
		midBeacon.Material = Enum.Material.Neon
		midBeacon.Color = beaconColor
		midBeacon.Parent = model

		table.insert(beacons, { part = midBeacon, light = nil, phase = math.random() * math.pi * 2 + math.pi })
	end

	if options.parent then
		model.Parent = options.parent
	end

	-- Return model + beacon data for pulse animation
	return model, beacons
end

--------------------------------------------------------------------------------
-- SKYLINE TOWER
-- Manhattan-style tower with per-floor construction (floor slabs, ceiling
-- lights, detailed facades). Two facade types: glass curtain wall or concrete
-- with punched windows. 5 styles from SkylineApproach.
--
-- options:
--   style   = "glass_blue" | "concrete_grey" | "concrete_brick" |
--             "concrete_sandstone" | "concrete_dark"  (default: random)
--   width   = number  (facade width, default: 30)
--   depth   = number  (building depth, default: 20)
--   scale   = number  (default: 1)
--   parent  = Instance
--------------------------------------------------------------------------------

local SKYLINE_STYLES = {
	glass_blue = {
		facade = "glass",
		floors = 16,
		glassColor = Color3.fromRGB(180, 215, 245),
		frameColor = Color3.fromRGB(140, 145, 155),
		postColor = Color3.fromRGB(80, 85, 95),
		lightColor = Color3.fromRGB(220, 235, 255),
	},
	concrete_grey = {
		facade = "concrete",
		floors = 12,
		wallMaterial = Enum.Material.Concrete,
		wallColor = Color3.fromRGB(180, 175, 170),
		trimColor = Color3.fromRGB(140, 138, 135),
		postColor = Color3.fromRGB(100, 98, 95),
		windowColor = Color3.fromRGB(60, 80, 105),
		windowTransparency = 0.6,
		lightColor = Color3.fromRGB(255, 240, 210),
	},
	concrete_brick = {
		facade = "concrete",
		floors = 10,
		wallMaterial = Enum.Material.Brick,
		wallColor = Color3.fromRGB(160, 110, 90),
		trimColor = Color3.fromRGB(130, 90, 75),
		postColor = Color3.fromRGB(90, 65, 55),
		windowColor = Color3.fromRGB(55, 75, 100),
		windowTransparency = 0.6,
		lightColor = Color3.fromRGB(255, 200, 150),
	},
	concrete_sandstone = {
		facade = "concrete",
		floors = 14,
		wallMaterial = Enum.Material.Limestone,
		wallColor = Color3.fromRGB(210, 200, 180),
		trimColor = Color3.fromRGB(170, 162, 148),
		postColor = Color3.fromRGB(120, 115, 105),
		windowColor = Color3.fromRGB(55, 75, 100),
		windowTransparency = 0.6,
		lightColor = Color3.fromRGB(255, 250, 230),
	},
	concrete_dark = {
		facade = "concrete",
		floors = 16,
		wallMaterial = Enum.Material.Concrete,
		wallColor = Color3.fromRGB(90, 88, 85),
		trimColor = Color3.fromRGB(70, 68, 65),
		postColor = Color3.fromRGB(50, 48, 45),
		windowColor = Color3.fromRGB(40, 55, 75),
		windowTransparency = 0.55,
		lightColor = Color3.fromRGB(180, 210, 255),
	},
}

local SKYLINE_STYLE_KEYS = { "glass_blue", "concrete_grey", "concrete_brick", "concrete_sandstone", "concrete_dark" }

local SKYLINE_LOBBY_H = 16
local SKYLINE_FLOOR_H = 8
local SKYLINE_FRONT_PANELS = 5
local SKYLINE_SIDE_PANELS = 3
local SKYLINE_FLOOR_COLOR = Color3.fromRGB(210, 210, 215)

-- Glass facade helper: one wall, one floor
local function buildSkylineGlassFacade(parent, axis, faceCoord, cx, cz, wallWidth, panelCount, floorBaseY, floorH, s, glassColor, frameColor)
	local mullionThick = 0.3 * s
	local margin = 0.2 * s
	local available = wallWidth - 2 * margin
	local pw = (available - (panelCount - 1) * mullionThick) / panelCount
	local bandThick = 0.4 * s
	local glassH = floorH - bandThick
	local glassY = floorBaseY + bandThick / 2 + glassH / 2

	for p = 0, panelCount - 1 do
		local off = -available / 2 + pw / 2 + p * (pw + mullionThick)
		local panel = Instance.new("Part")
		panel.Name = "GlassPanel"
		if axis == "x" then
			panel.Size = Vector3.new(0.2, glassH, pw)
			panel.Position = Vector3.new(faceCoord, glassY, cz + off)
		else
			panel.Size = Vector3.new(pw, glassH, 0.2)
			panel.Position = Vector3.new(cx + off, glassY, faceCoord)
		end
		panel.Anchored = true
		panel.CanCollide = false
		panel.Material = Enum.Material.Glass
		panel.Color = glassColor
		panel.Transparency = 0.65
		panel.Parent = parent

		if p < panelCount - 1 then
			local mOff = off + pw / 2 + mullionThick / 2
			local mullion = Instance.new("Part")
			mullion.Name = "VMullion"
			if axis == "x" then
				mullion.Size = Vector3.new(mullionThick, floorH, mullionThick)
				mullion.Position = Vector3.new(faceCoord, floorBaseY + floorH / 2, cz + mOff)
			else
				mullion.Size = Vector3.new(mullionThick, floorH, mullionThick)
				mullion.Position = Vector3.new(cx + mOff, floorBaseY + floorH / 2, faceCoord)
			end
			mullion.Anchored = true
			mullion.CanCollide = false
			mullion.Material = Enum.Material.DiamondPlate
			mullion.Color = frameColor
			mullion.Parent = parent
		end
	end
end

-- Concrete facade helper: one wall, one floor
local function buildSkylineConcreteFacade(parent, axis, faceCoord, cx, cz, wallWidth, windowCount, floorBaseY, floorH, s, wallMaterial, wallColor, windowColor, windowTransparency)
	local wallThick = 0.5 * s
	local margin = 1.5 * s
	local available = wallWidth - 2 * margin
	local spacing = available / windowCount
	local pierW = spacing * 0.3
	local winW = spacing - pierW
	local winTransp = windowTransparency or 0.15

	local bottomH = floorH * 0.2
	local topH = floorH * 0.12
	local winH = floorH - bottomH - topH
	local winY = floorBaseY + bottomH + winH / 2

	local function makeConcrete(name, size, position)
		local part = Instance.new("Part")
		part.Name = name
		part.Size = size
		part.Position = position
		part.Anchored = true
		part.CanCollide = false
		part.Material = wallMaterial
		part.Color = wallColor
		part.Parent = parent
	end

	-- Bottom spandrel
	if axis == "x" then
		makeConcrete("Spandrel", Vector3.new(wallThick, bottomH, wallWidth), Vector3.new(faceCoord, floorBaseY + bottomH / 2, cz))
	else
		makeConcrete("Spandrel", Vector3.new(wallWidth, bottomH, wallThick), Vector3.new(cx, floorBaseY + bottomH / 2, faceCoord))
	end

	-- Top spandrel
	if axis == "x" then
		makeConcrete("Spandrel", Vector3.new(wallThick, topH, wallWidth), Vector3.new(faceCoord, floorBaseY + floorH - topH / 2, cz))
	else
		makeConcrete("Spandrel", Vector3.new(wallWidth, topH, wallThick), Vector3.new(cx, floorBaseY + floorH - topH / 2, faceCoord))
	end

	-- Edge piers
	local edgePierW = margin + pierW / 2
	for side = -1, 1, 2 do
		local edgeOff = side * (wallWidth / 2 - edgePierW / 2)
		if axis == "x" then
			makeConcrete("EdgePier", Vector3.new(wallThick, winH, edgePierW), Vector3.new(faceCoord, winY, cz + edgeOff))
		else
			makeConcrete("EdgePier", Vector3.new(edgePierW, winH, wallThick), Vector3.new(cx + edgeOff, winY, faceCoord))
		end
	end

	-- Windows + piers
	for w = 0, windowCount - 1 do
		local off = -available / 2 + spacing / 2 + w * spacing
		local win = Instance.new("Part")
		win.Name = "Window"
		if axis == "x" then
			win.Size = Vector3.new(0.15, winH + 0.2, winW + 0.2)
			win.Position = Vector3.new(faceCoord, winY, cz + off)
		else
			win.Size = Vector3.new(winW + 0.2, winH + 0.2, 0.15)
			win.Position = Vector3.new(cx + off, winY, faceCoord)
		end
		win.Anchored = true
		win.CanCollide = false
		win.Material = Enum.Material.Glass
		win.Color = windowColor
		win.Transparency = winTransp
		win.Parent = parent

		if w < windowCount - 1 then
			local pierOff = off + winW / 2 + pierW / 2
			if axis == "x" then
				makeConcrete("Pier", Vector3.new(wallThick, winH, pierW), Vector3.new(faceCoord, winY, cz + pierOff))
			else
				makeConcrete("Pier", Vector3.new(pierW, winH, wallThick), Vector3.new(cx + pierOff, winY, faceCoord))
			end
		end
	end
end

-- Build one floor section (slab + facade + ceiling light)
local function buildSkylineFloor(model, cx, cz, bw, bd, floorBaseY, floorH, frontZ, backZ, leftX, rightX, s, style)
	-- Floor slab
	local slab = Instance.new("Part")
	slab.Name = "FloorSlab"
	slab.Size = Vector3.new(bw - 0.4, 0.3 * s, bd - 0.4)
	slab.Position = Vector3.new(cx, floorBaseY + 0.15, cz)
	slab.Anchored = true
	slab.Material = Enum.Material.SmoothPlastic
	slab.Color = SKYLINE_FLOOR_COLOR
	slab.Parent = model

	-- Facade per face
	if style.facade == "glass" then
		local bandH = 0.4 * s
		for _, face in ipairs({
			{ Vector3.new(bw, bandH, bandH), Vector3.new(cx, floorBaseY + bandH / 2, frontZ) },
			{ Vector3.new(bw, bandH, bandH), Vector3.new(cx, floorBaseY + bandH / 2, backZ) },
			{ Vector3.new(bandH, bandH, bd), Vector3.new(leftX, floorBaseY + bandH / 2, cz) },
			{ Vector3.new(bandH, bandH, bd), Vector3.new(rightX, floorBaseY + bandH / 2, cz) },
		}) do
			local band = Instance.new("Part")
			band.Name = "Band"
			band.Size = face[1]
			band.Position = face[2]
			band.Anchored = true
			band.CanCollide = false
			band.Material = Enum.Material.Metal
			band.Color = style.frameColor
			band.Parent = model
		end
		buildSkylineGlassFacade(model, "z", frontZ, cx, cz, bw, SKYLINE_FRONT_PANELS, floorBaseY, floorH, s, style.glassColor, style.frameColor)
		buildSkylineGlassFacade(model, "z", backZ, cx, cz, bw, SKYLINE_FRONT_PANELS, floorBaseY, floorH, s, style.glassColor, style.frameColor)
		buildSkylineGlassFacade(model, "x", leftX, cx, cz, bd, SKYLINE_SIDE_PANELS, floorBaseY, floorH, s, style.glassColor, style.frameColor)
		buildSkylineGlassFacade(model, "x", rightX, cx, cz, bd, SKYLINE_SIDE_PANELS, floorBaseY, floorH, s, style.glassColor, style.frameColor)
	elseif style.facade == "concrete" then
		buildSkylineConcreteFacade(model, "z", frontZ, cx, cz, bw, SKYLINE_FRONT_PANELS, floorBaseY, floorH, s, style.wallMaterial, style.wallColor, style.windowColor, style.windowTransparency)
		buildSkylineConcreteFacade(model, "z", backZ, cx, cz, bw, SKYLINE_FRONT_PANELS, floorBaseY, floorH, s, style.wallMaterial, style.wallColor, style.windowColor, style.windowTransparency)
		buildSkylineConcreteFacade(model, "x", leftX, cx, cz, bd, SKYLINE_SIDE_PANELS, floorBaseY, floorH, s, style.wallMaterial, style.wallColor, style.windowColor, style.windowTransparency)
		buildSkylineConcreteFacade(model, "x", rightX, cx, cz, bd, SKYLINE_SIDE_PANELS, floorBaseY, floorH, s, style.wallMaterial, style.wallColor, style.windowColor, style.windowTransparency)
	end

	-- Ceiling light
	local floorLightColor = style.lightColor or Color3.fromRGB(255, 240, 210)
	local lightPart = Instance.new("Part")
	lightPart.Name = "CeilingLight"
	lightPart.Size = Vector3.new(bw * 0.5, 0.15 * s, bd * 0.5)
	lightPart.Position = Vector3.new(cx, floorBaseY + floorH - 0.2, cz)
	lightPart.Anchored = true
	lightPart.CanCollide = false
	lightPart.Material = Enum.Material.Neon
	lightPart.Color = floorLightColor
	lightPart.Transparency = 0.3
	lightPart.Parent = model

	local ptLight = Instance.new("PointLight")
	ptLight.Color = floorLightColor
	ptLight.Brightness = 1.2
	ptLight.Range = 14
	ptLight.Parent = lightPart
end

function AssetLibrary.createSkylineTower(centerX, centerZ, options)
	options = options or {}
	local styleKey = options.style or SKYLINE_STYLE_KEYS[math.random(1, #SKYLINE_STYLE_KEYS)]
	local style = SKYLINE_STYLES[styleKey]
	if not style then style = SKYLINE_STYLES.glass_blue; styleKey = "glass_blue" end

	local s = options.scale or 1
	local bw = (options.width or 30) * s
	local bd = (options.depth or 20) * s
	local lobbyH = SKYLINE_LOBBY_H * s
	local fh = SKYLINE_FLOOR_H * s
	local floors = style.floors
	local totalH = lobbyH + floors * fh

	local cx = centerX
	local cz = centerZ
	local frontZ = cz + bd / 2 + 0.15
	local backZ  = cz - bd / 2 - 0.15
	local leftX  = cx - bw / 2 - 0.15
	local rightX = cx + bw / 2 + 0.15

	local model = Instance.new("Model")
	model.Name = "SkylineTower_" .. styleKey

	-- Corner posts (full height)
	local postThick = 0.6 * s
	for dx = -1, 1, 2 do
		for dz = -1, 1, 2 do
			local post = Instance.new("Part")
			post.Name = "CornerPost"
			post.Size = Vector3.new(postThick, totalH, postThick)
			post.Position = Vector3.new(
				cx + dx * (bw / 2 - postThick / 2),
				BUILDING_BASE + totalH / 2,
				cz + dz * (bd / 2 - postThick / 2)
			)
			post.Anchored = true
			post.Material = Enum.Material.DiamondPlate
			post.Color = style.postColor
			post.Parent = model
		end
	end

	-- Lobby (double height)
	buildSkylineFloor(model, cx, cz, bw, bd, BUILDING_BASE, lobbyH, frontZ, backZ, leftX, rightX, s, style)

	-- Office floors
	for floor = 1, floors do
		local floorBaseY = BUILDING_BASE + lobbyH + (floor - 1) * fh
		buildSkylineFloor(model, cx, cz, bw, bd, floorBaseY, fh, frontZ, backZ, leftX, rightX, s, style)
	end

	-- Roof
	local roofY = BUILDING_BASE + totalH
	local roof = Instance.new("Part")
	roof.Name = "Roof"
	roof.Size = Vector3.new(bw + 0.5, 0.5, bd + 0.5)
	roof.Position = Vector3.new(cx, roofY + 0.25, cz)
	roof.Anchored = true
	roof.Material = Enum.Material.Metal
	roof.Color = style.frameColor or style.trimColor
	roof.Parent = model

	if options.parent then
		model.Parent = options.parent
	end

	return model, { totalHeight = totalH, roofY = roofY + 0.5 }
end

-- List skyline tower styles
function AssetLibrary.getSkylineTowerStyles()
	return SKYLINE_STYLE_KEYS
end

--------------------------------------------------------------------------------
-- SIMPLE BLOCK
-- Lightweight building: just a body + roof (2 parts). Good for background
-- fill or distant views. 6 presets from SkylineApproach.
--
-- options:
--   preset  = 1..6     (default: random)
--   width   = number   (default: 30)
--   depth   = number   (default: 20)
--   parent  = Instance
--------------------------------------------------------------------------------

local BLOCK_PRESETS = {
	{ wallColor = Color3.fromRGB(180, 175, 170), material = Enum.Material.Concrete, roofColor = Color3.fromRGB(120, 118, 115), floors = 12 },
	{ wallColor = Color3.fromRGB(160, 110, 90),  material = Enum.Material.Brick,    roofColor = Color3.fromRGB(100, 75, 65),   floors = 10 },
	{ wallColor = Color3.fromRGB(210, 200, 180), material = Enum.Material.Limestone, roofColor = Color3.fromRGB(150, 142, 130), floors = 14 },
	{ wallColor = Color3.fromRGB(90, 88, 85),    material = Enum.Material.Concrete, roofColor = Color3.fromRGB(60, 58, 55),    floors = 16 },
	{ wallColor = Color3.fromRGB(150, 145, 140), material = Enum.Material.Concrete, roofColor = Color3.fromRGB(110, 108, 105), floors = 11 },
	{ wallColor = Color3.fromRGB(130, 95, 80),   material = Enum.Material.Brick,    roofColor = Color3.fromRGB(90, 68, 58),    floors = 13 },
}

function AssetLibrary.createSimpleBlock(centerX, centerZ, options)
	options = options or {}
	local presetIdx = options.preset or math.random(1, #BLOCK_PRESETS)
	local preset = BLOCK_PRESETS[math.clamp(presetIdx, 1, #BLOCK_PRESETS)]
	local bw = options.width or 30
	local bd = options.depth or 20
	local totalH = SKYLINE_LOBBY_H + preset.floors * SKYLINE_FLOOR_H

	local model = Instance.new("Model")
	model.Name = "SimpleBlock_" .. presetIdx

	-- Body
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(bw, totalH, bd)
	body.Position = Vector3.new(centerX, BUILDING_BASE + totalH / 2, centerZ)
	body.Anchored = true
	body.CanCollide = true
	body.Material = preset.material
	body.Color = preset.wallColor
	body.Parent = model

	-- Roof
	local roof = Instance.new("Part")
	roof.Name = "Roof"
	roof.Size = Vector3.new(bw + 0.5, 0.5, bd + 0.5)
	roof.Position = Vector3.new(centerX, BUILDING_BASE + totalH + 0.25, centerZ)
	roof.Anchored = true
	roof.Material = Enum.Material.Metal
	roof.Color = preset.roofColor
	roof.Parent = model

	if options.parent then
		model.Parent = options.parent
	end

	return model, { totalHeight = totalH, roofY = BUILDING_BASE + totalH + 0.5 }
end

function AssetLibrary.getSimpleBlockCount()
	return #BLOCK_PRESETS
end

--------------------------------------------------------------------------------
-- APARTMENT BUILDING
-- Mid-rise building with windows on all 4 faces. 3 variants:
--   "city"       — warm tones, brick/concrete (20 specs)
--   "industrial" — steel/metal, rooftop water tanks + vents (20 specs)
--   "oldtown"    — earth tones, fabric awnings, lower floors (20 specs)
--
-- options:
--   variant   = "city" | "industrial" | "oldtown"  (default: "city")
--   specIndex = 1..20                               (default: random)
--   scale     = number                              (default: 1)
--   depth     = number                              (base depth, default: 16)
--   parent    = Instance
--------------------------------------------------------------------------------

local APARTMENT_SPECS = {
	city = {
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
		{ facade = 22, floors = 8,  color = Color3.fromRGB(145, 100, 80),  mat = Enum.Material.Brick,          winColor = Color3.fromRGB(200, 230, 255), litPct = 0.55, winW = 2.5, winH = 4.0, entrance = true },
		{ facade = 20, floors = 6,  color = Color3.fromRGB(165, 120, 90),  mat = Enum.Material.Brick,          winColor = Color3.fromRGB(255, 200, 100), litPct = 0.45, winW = 2.8, winH = 3.5 },
		{ facade = 16, floors = 12, color = Color3.fromRGB(220, 215, 205), mat = Enum.Material.SmoothPlastic,  winColor = Color3.fromRGB(255, 220, 140), litPct = 0.35, winW = 2.0, winH = 3.0 },
		{ facade = 24, floors = 7,  color = Color3.fromRGB(200, 190, 170), mat = Enum.Material.Concrete,       winColor = Color3.fromRGB(255, 180, 120), litPct = 0.50, winW = 3.0, winH = 4.0 },
		{ facade = 18, floors = 10, color = Color3.fromRGB(145, 100, 80),  mat = Enum.Material.Brick,          winColor = Color3.fromRGB(180, 210, 255), litPct = 0.40, winW = 2.2, winH = 3.5 },
		{ facade = 26, floors = 5,  color = Color3.fromRGB(190, 140, 100), mat = Enum.Material.Slate,          winColor = Color3.fromRGB(200, 230, 255), litPct = 0.55, winW = 2.5, winH = 4.5 },
		{ facade = 20, floors = 9,  color = Color3.fromRGB(210, 200, 185), mat = Enum.Material.Concrete,       winColor = Color3.fromRGB(255, 200, 100), litPct = 0.45, winW = 2.0, winH = 4.0 },
		{ facade = 22, floors = 11, color = Color3.fromRGB(155, 145, 135), mat = Enum.Material.Brick,          winColor = Color3.fromRGB(255, 220, 140), litPct = 0.50, winW = 2.5, winH = 3.5 },
		{ facade = 16, floors = 6,  color = Color3.fromRGB(180, 170, 155), mat = Enum.Material.SmoothPlastic,  winColor = Color3.fromRGB(255, 180, 120), litPct = 0.35, winW = 2.0, winH = 3.0 },
		{ facade = 24, floors = 8,  color = Color3.fromRGB(165, 120, 90),  mat = Enum.Material.Slate,          winColor = Color3.fromRGB(180, 210, 255), litPct = 0.60, winW = 3.0, winH = 4.5 },
	},

	industrial = {
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
	},

	oldtown = {
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
	},
}

-- Window helper (self-contained, same logic as DecorUtils.addWindowsToFace)
local function addWindowsToFace(building, axis, faceCoord, center, faceWidth, baseY, floors, floorHeight, winW, winH, winGap, litColor, litChance)
	local margin = 1.5
	local available = faceWidth - 2 * margin
	local numWindows = math.floor((available + winGap) / (winW + winGap))
	if numWindows < 1 then return end

	local totalW = numWindows * winW + (numWindows - 1) * winGap
	local startOffset = -totalW / 2 + winW / 2
	local darkColor = Color3.fromRGB(80, 120, 160)

	for floor = 2, floors do
		local floorY = baseY + (floor - 0.5) * floorHeight
		for w = 1, numWindows do
			local offset = startOffset + (w - 1) * (winW + winGap)
			local window = Instance.new("Part")
			window.Name = "Window"
			if axis == "x" then
				window.Size = Vector3.new(0.3, winH, winW)
				window.Position = Vector3.new(faceCoord, floorY, center + offset)
			else
				window.Size = Vector3.new(winW, winH, 0.3)
				window.Position = Vector3.new(center + offset, floorY, faceCoord)
			end
			window.Anchored = true
			window.CanCollide = false
			if math.random() < litChance then
				window.Material = Enum.Material.Neon
				window.Color = litColor
				window:SetAttribute("ThemeRole", "building_window_lit")
				window:SetAttribute("BaseColor", litColor)
				window:SetAttribute("BaseMaterial", "Neon")
			else
				window.Material = Enum.Material.Glass
				window.Color = darkColor
				window:SetAttribute("ThemeRole", "building_window")
				window:SetAttribute("BaseColor", darkColor)
				window:SetAttribute("BaseMaterial", "Glass")
			end
			window.Parent = building
		end
	end
end

function AssetLibrary.createApartment(centerX, centerZ, options)
	options = options or {}
	local variant = options.variant or "city"
	local scale = options.scale or 1
	local bDepthBase = options.depth or 16

	local specs = APARTMENT_SPECS[variant] or APARTMENT_SPECS.city
	local specIndex = options.specIndex or math.random(1, #specs)
	local spec = specs[math.clamp(specIndex, 1, #specs)]

	local building = Instance.new("Model")
	building.Name = "Apartment_" .. variant .. "_" .. specIndex

	local bDepth = bDepthBase * scale
	local facadeLen = spec.facade * scale
	local floorHeight = 7 * scale
	local height = spec.floors * floorHeight

	-- Main body
	local main = Instance.new("Part")
	main.Size = Vector3.new(bDepth, height, facadeLen)
	main.Position = Vector3.new(centerX, BUILDING_BASE + height / 2, centerZ)
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
	roof.Position = Vector3.new(centerX, BUILDING_BASE + height + 0.5, centerZ)
	roof.Anchored = true
	roof.Material = Enum.Material.Metal
	roof.Color = roofColor
	roof:SetAttribute("ThemeRole", "building_roof")
	roof:SetAttribute("BaseColor", roofColor)
	roof:SetAttribute("BaseMaterial", "Metal")
	roof.Parent = building

	-- Windows on all 4 faces (no sign-based front/back — equal detail)
	local frontX = centerX - bDepth / 2 - 0.15
	local backX  = centerX + bDepth / 2 + 0.15
	local sideZ1 = centerZ - facadeLen / 2 - 0.15
	local sideZ2 = centerZ + facadeLen / 2 + 0.15
	local winGap = 1.2

	addWindowsToFace(building, "x", frontX, centerZ, facadeLen, BUILDING_BASE, spec.floors, floorHeight, spec.winW, spec.winH, winGap, spec.winColor, spec.litPct)
	addWindowsToFace(building, "x", backX,  centerZ, facadeLen, BUILDING_BASE, spec.floors, floorHeight, spec.winW, spec.winH, winGap, spec.winColor, spec.litPct)
	addWindowsToFace(building, "z", sideZ1, centerX, bDepth,    BUILDING_BASE, spec.floors, floorHeight, spec.winW, spec.winH, winGap, spec.winColor, spec.litPct * 0.7)
	addWindowsToFace(building, "z", sideZ2, centerX, bDepth,    BUILDING_BASE, spec.floors, floorHeight, spec.winW, spec.winH, winGap, spec.winColor, spec.litPct * 0.7)

	-- Entrance (specs with entrance = true)
	if spec.entrance then
		local doorWidth = (variant == "oldtown" and 3.5 or 4) * scale
		local doorHeight = (variant == "oldtown" and 6 or 7) * scale
		local doorY = BUILDING_BASE + doorHeight / 2 + 0.2
		local entranceX = frontX - 0.15

		if variant == "oldtown" then
			-- Wooden door + fabric awning
			local door = Instance.new("Part")
			door.Name = "Door"
			door.Size = Vector3.new(0.3, doorHeight, doorWidth)
			door.Position = Vector3.new(entranceX, doorY, centerZ)
			door.Anchored = true
			door.CanCollide = false
			door.Material = Enum.Material.WoodPlanks
			door.Color = Color3.fromRGB(90, 60, 35)
			door.Parent = building

			local awning = Instance.new("Part")
			awning.Name = "Awning"
			awning.Size = Vector3.new(2.5 * scale, 0.15 * scale, doorWidth + 2 * scale)
			awning.Position = Vector3.new(entranceX - 1.2 * scale, BUILDING_BASE + doorHeight + 0.5, centerZ)
			awning.Anchored = true
			awning.CanCollide = false
			awning.Material = Enum.Material.Fabric
			awning.Color = spec.floors % 2 == 0 and Color3.fromRGB(160, 60, 40) or Color3.fromRGB(40, 100, 60)
			awning.Parent = building
		else
			-- Modern glass entrance: frame + double doors + canopy + light
			local frame = Instance.new("Part")
			frame.Name = "DoorFrame"
			frame.Size = Vector3.new(0.5, doorHeight + 0.5, doorWidth + 0.6)
			frame.Position = Vector3.new(entranceX, doorY, centerZ)
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
				door.Position = Vector3.new(entranceX - 0.1, doorY, centerZ + i * (panelWidth / 2 + 0.1))
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
			canopy.Position = Vector3.new(entranceX - 1 * scale, BUILDING_BASE + doorHeight + 1, centerZ)
			canopy.Anchored = true
			canopy.Material = Enum.Material.Metal
			canopy.Color = Color3.fromRGB(40, 40, 45)
			canopy.Parent = building

			local entranceLight = Instance.new("Part")
			entranceLight.Name = "EntranceLight"
			entranceLight.Size = Vector3.new(0.3, 0.3, 1.5)
			entranceLight.Position = Vector3.new(entranceX - 0.15, BUILDING_BASE + doorHeight + 0.5, centerZ)
			entranceLight.Anchored = true
			entranceLight.CanCollide = false
			entranceLight.Material = Enum.Material.Neon
			entranceLight.Color = Color3.fromRGB(255, 230, 180)
			entranceLight.Parent = building
		end
	end

	-- Industrial variant: rooftop details
	if variant == "industrial" then
		local roofY = BUILDING_BASE + height + 1
		-- Water tank on taller buildings
		if spec.floors >= 8 then
			local tankH = 3.5 * scale
			local tankW = 3 * scale
			local tank = Instance.new("Part")
			tank.Name = "WaterTank"
			tank.Shape = Enum.PartType.Cylinder
			tank.Size = Vector3.new(tankH, tankW, tankW)
			tank.CFrame = CFrame.new(centerX, roofY + tankH / 2 + 1.5 * scale, centerZ + facadeLen * 0.15) * CFrame.Angles(0, 0, math.rad(90))
			tank.Anchored = true
			tank.Material = Enum.Material.Metal
			tank.Color = Color3.fromRGB(55, 60, 65)
			tank.Parent = building

			for _, off in ipairs({{-1,-1},{-1,1},{1,-1},{1,1}}) do
				local leg = Instance.new("Part")
				leg.Name = "TankLeg"
				leg.Size = Vector3.new(0.4 * scale, 1.5 * scale, 0.4 * scale)
				leg.Position = Vector3.new(centerX + off[1] * 0.8 * scale, roofY + 0.75 * scale, centerZ + facadeLen * 0.15 + off[2] * 0.8 * scale)
				leg.Anchored = true
				leg.Material = Enum.Material.Metal
				leg.Color = Color3.fromRGB(45, 50, 55)
				leg.Parent = building
			end
		end
		-- Vent boxes
		if spec.facade >= 18 then
			local ventCount = spec.floors >= 10 and 3 or 2
			for i = 1, ventCount do
				local vent = Instance.new("Part")
				vent.Name = "Vent"
				vent.Size = Vector3.new(1.8 * scale, 1.2 * scale, 1.8 * scale)
				vent.Position = Vector3.new(centerX + (i - ventCount / 2 - 0.5) * 3 * scale, roofY + 0.6 * scale, centerZ - facadeLen * 0.2)
				vent.Anchored = true
				vent.Material = Enum.Material.DiamondPlate
				vent.Color = Color3.fromRGB(65, 70, 75)
				vent.Parent = building
			end
		end
		-- Antenna on tallest
		if spec.floors >= 11 then
			local antenna = Instance.new("Part")
			antenna.Name = "Antenna"
			antenna.Size = Vector3.new(0.3 * scale, 6 * scale, 0.3 * scale)
			antenna.Position = Vector3.new(centerX, roofY + 3 * scale, centerZ)
			antenna.Anchored = true
			antenna.Material = Enum.Material.Metal
			antenna.Color = Color3.fromRGB(50, 55, 60)
			antenna.Parent = building
		end
	end

	if options.parent then
		building.Parent = options.parent
	end

	return building
end

function AssetLibrary.getApartmentCount(variant)
	local specs = APARTMENT_SPECS[variant or "city"]
	return specs and #specs or 0
end

function AssetLibrary.getApartmentVariants()
	return { "city", "industrial", "oldtown" }
end

--------------------------------------------------------------------------------
-- MANSION SPECS
-- 2 variants: "mediterranean" (warm stucco, pitched terracotta roof, columns)
--             "modern" (clean lines, flat dark roof, glass canopy)
-- 5 specs each = 10 total
-- Spec: facade, floors, floorH, color, mat, roofColor, roofType,
--        winColor, litPct, winW, winH, columns, garageW
--------------------------------------------------------------------------------

local MANSION_SPECS = {
	mediterranean = {
		{ facade = 40, floors = 2, floorH = 8,  color = Color3.fromRGB(245, 235, 215), mat = Enum.Material.SmoothPlastic, roofColor = Color3.fromRGB(180, 90, 50),  roofType = "pitched", winColor = Color3.fromRGB(255, 220, 140), litPct = 0.6,  winW = 2.5, winH = 3.5, columns = 4, garageW = 12 },
		{ facade = 34, floors = 2, floorH = 8,  color = Color3.fromRGB(235, 220, 190), mat = Enum.Material.SmoothPlastic, roofColor = Color3.fromRGB(165, 80, 45),  roofType = "pitched", winColor = Color3.fromRGB(255, 200, 100), litPct = 0.5,  winW = 2.2, winH = 3.0, columns = 2, garageW = 10 },
		{ facade = 44, floors = 2, floorH = 9,  color = Color3.fromRGB(250, 245, 230), mat = Enum.Material.Concrete,      roofColor = Color3.fromRGB(150, 75, 40),  roofType = "pitched", winColor = Color3.fromRGB(255, 210, 130), litPct = 0.55, winW = 2.8, winH = 4.0, columns = 6, garageW = 14 },
		{ facade = 36, floors = 2, floorH = 8,  color = Color3.fromRGB(240, 225, 200), mat = Enum.Material.SmoothPlastic, roofColor = Color3.fromRGB(190, 100, 60), roofType = "pitched", winColor = Color3.fromRGB(255, 230, 150), litPct = 0.65, winW = 2.0, winH = 3.5, columns = 4, garageW = 10 },
		{ facade = 42, floors = 3, floorH = 8,  color = Color3.fromRGB(248, 240, 225), mat = Enum.Material.Concrete,      roofColor = Color3.fromRGB(170, 85, 48),  roofType = "pitched", winColor = Color3.fromRGB(255, 215, 135), litPct = 0.5,  winW = 2.5, winH = 3.5, columns = 4, garageW = 12 },
	},
	modern = {
		{ facade = 42, floors = 2, floorH = 9,  color = Color3.fromRGB(245, 245, 250), mat = Enum.Material.SmoothPlastic, roofColor = Color3.fromRGB(45, 45, 50),   roofType = "flat", winColor = Color3.fromRGB(200, 230, 255), litPct = 0.7,  winW = 5.0, winH = 6.0, columns = 0, garageW = 14 },
		{ facade = 36, floors = 2, floorH = 9,  color = Color3.fromRGB(230, 230, 235), mat = Enum.Material.SmoothPlastic, roofColor = Color3.fromRGB(55, 55, 60),   roofType = "flat", winColor = Color3.fromRGB(180, 210, 255), litPct = 0.65, winW = 4.5, winH = 5.5, columns = 0, garageW = 12 },
		{ facade = 46, floors = 2, floorH = 10, color = Color3.fromRGB(60, 60, 65),    mat = Enum.Material.Metal,         roofColor = Color3.fromRGB(40, 40, 45),   roofType = "flat", winColor = Color3.fromRGB(200, 230, 255), litPct = 0.75, winW = 6.0, winH = 7.0, columns = 0, garageW = 14 },
		{ facade = 38, floors = 2, floorH = 9,  color = Color3.fromRGB(250, 250, 252), mat = Enum.Material.SmoothPlastic, roofColor = Color3.fromRGB(50, 50, 55),   roofType = "flat", winColor = Color3.fromRGB(190, 220, 255), litPct = 0.6,  winW = 4.0, winH = 5.0, columns = 0, garageW = 10 },
		{ facade = 44, floors = 3, floorH = 9,  color = Color3.fromRGB(235, 235, 240), mat = Enum.Material.SmoothPlastic, roofColor = Color3.fromRGB(35, 35, 40),   roofType = "flat", winColor = Color3.fromRGB(200, 230, 255), litPct = 0.7,  winW = 5.0, winH = 6.0, columns = 0, garageW = 12 },
	},
}

local MANSION_LOT_DEPTH = 28
local MANSION_DRIVEWAY_W = 6

--------------------------------------------------------------------------------
-- createMansion(centerX, centerZ, options)
-- options.variant: "mediterranean" or "modern" (default "mediterranean")
-- options.specIndex: 1-5 (default random)
-- options.scale: number (default 1)
-- options.parent: Instance to parent to
-- options.pool: boolean (default random 50%)
-- Returns: Model
--------------------------------------------------------------------------------

function AssetLibrary.createMansion(centerX, centerZ, options)
	options = options or {}
	local variant = options.variant or "mediterranean"
	local specs = MANSION_SPECS[variant] or MANSION_SPECS.mediterranean
	local specIndex = options.specIndex or math.random(1, #specs)
	local spec = specs[math.clamp(specIndex, 1, #specs)]
	local scale = options.scale or 1

	local model = Instance.new("Model")
	model.Name = "Mansion"

	local facadeLen = spec.facade * scale
	local floorH = spec.floorH * scale
	local height = spec.floors * floorH
	local lotD = MANSION_LOT_DEPTH * scale
	local roofOH = 1.5 * scale

	-- Body: facade along X, depth along Z
	local bodyX = facadeLen
	local bodyZ = lotD

	-- ── BODY ──────────────────────────────────────────────────────────────
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(bodyX, height, bodyZ)
	body.Position = Vector3.new(centerX, BUILDING_BASE + height / 2, centerZ)
	body.Anchored = true
	body.Material = spec.mat
	body.Color = spec.color
	body:SetAttribute("ThemeRole", "building_body")
	body:SetAttribute("BaseColor", spec.color)
	body:SetAttribute("BaseMaterial", spec.mat.Name)
	body.Parent = model

	-- ── ROOF ──────────────────────────────────────────────────────────────
	if spec.roofType == "pitched" then
		local roofRise = 5 * scale
		-- Ridge along X, slopes along Z
		local roofHalfD = bodyZ / 2 + roofOH
		local panelLen = math.sqrt(roofHalfD * roofHalfD + roofRise * roofRise)
		local roofAngle = math.atan2(roofRise, roofHalfD)

		for _, s in ipairs({ -1, 1 }) do
			local panel = Instance.new("Part")
			panel.Name = "RoofPanel"
			panel.Size = Vector3.new(bodyX + roofOH * 2, 0.5 * scale, panelLen)
			panel.CFrame = CFrame.new(
				centerX, BUILDING_BASE + height + roofRise / 2,
				centerZ + s * roofHalfD / 2
			) * CFrame.Angles(s * roofAngle, 0, 0)
			panel.Anchored = true
			panel.Material = Enum.Material.Slate
			panel.Color = spec.roofColor
			panel:SetAttribute("ThemeRole", "building_roof")
			panel:SetAttribute("BaseColor", spec.roofColor)
			panel:SetAttribute("BaseMaterial", "Slate")
			panel.Parent = model
		end

		local ridge = Instance.new("Part")
		ridge.Name = "Ridge"
		ridge.Size = Vector3.new(bodyX + roofOH * 2, 0.6 * scale, 1.5 * scale)
		ridge.Position = Vector3.new(centerX, BUILDING_BASE + height + roofRise, centerZ)
		ridge.Anchored = true
		ridge.Material = Enum.Material.Slate
		ridge.Color = spec.roofColor
		ridge:SetAttribute("ThemeRole", "building_roof")
		ridge:SetAttribute("BaseColor", spec.roofColor)
		ridge:SetAttribute("BaseMaterial", "Slate")
		ridge.Parent = model
	else
		-- Flat roof with overhang
		local roof = Instance.new("Part")
		roof.Name = "Roof"
		roof.Size = Vector3.new(bodyX + roofOH * 2, 0.8 * scale, bodyZ + roofOH * 2)
		roof.Position = Vector3.new(centerX, BUILDING_BASE + height + 0.4 * scale, centerZ)
		roof.Anchored = true
		roof.Material = Enum.Material.SmoothPlastic
		roof.Color = spec.roofColor
		roof:SetAttribute("ThemeRole", "building_roof")
		roof:SetAttribute("BaseColor", spec.roofColor)
		roof:SetAttribute("BaseMaterial", "SmoothPlastic")
		roof.Parent = model

		local trim = Instance.new("Part")
		trim.Name = "RoofTrim"
		trim.Size = Vector3.new(bodyX + roofOH * 2 + 0.5, 1.2 * scale, bodyZ + roofOH * 2 + 0.5)
		trim.Position = Vector3.new(centerX, BUILDING_BASE + height + 1 * scale, centerZ)
		trim.Anchored = true
		trim.Material = Enum.Material.Metal
		trim.Color = spec.roofColor
		trim:SetAttribute("ThemeRole", "building_roof")
		trim:SetAttribute("BaseColor", spec.roofColor)
		trim:SetAttribute("BaseMaterial", "Metal")
		trim.Parent = model
	end

	-- ── WINDOWS — all 4 faces ─────────────────────────────────────────────
	local winW = spec.winW * scale
	local winH = spec.winH * scale
	local winGap = 1.5 * scale

	-- Front (+Z)
	addWindowsToFace(model, "z", centerZ + bodyZ / 2 + 0.2, centerX, bodyX, BUILDING_BASE,
		spec.floors, floorH, winW, winH, winGap, spec.winColor, spec.litPct)
	-- Back (-Z)
	addWindowsToFace(model, "z", centerZ - bodyZ / 2 - 0.2, centerX, bodyX, BUILDING_BASE,
		spec.floors, floorH, winW, winH, winGap, spec.winColor, spec.litPct * 0.5)
	-- Left (-X)
	addWindowsToFace(model, "x", centerX - bodyX / 2 - 0.2, centerZ, bodyZ, BUILDING_BASE,
		spec.floors, floorH, winW, winH, winGap, spec.winColor, spec.litPct * 0.4)
	-- Right (+X)
	addWindowsToFace(model, "x", centerX + bodyX / 2 + 0.2, centerZ, bodyZ, BUILDING_BASE,
		spec.floors, floorH, winW, winH, winGap, spec.winColor, spec.litPct * 0.4)

	-- ── ENTRANCE (front face +Z) ─────────────────────────────────────────
	local doorW = 3.5 * scale
	local doorH = 6 * scale

	if spec.columns > 0 then
		-- Columned portico
		local colSpacing = doorW + 2 * scale
		local colRadius = 0.6 * scale
		local colH = doorH + 2 * scale

		for i = 1, spec.columns do
			local colOff = (i - (spec.columns + 1) / 2) * colSpacing / 2
			local col = Instance.new("Part")
			col.Name = "Column"
			col.Shape = Enum.PartType.Cylinder
			col.Size = Vector3.new(colH, colRadius * 2, colRadius * 2)
			col.CFrame = CFrame.new(
				centerX + colOff,
				BUILDING_BASE + colH / 2,
				centerZ + bodyZ / 2 + 1 * scale
			) * CFrame.Angles(0, 0, math.rad(90))
			col.Anchored = true
			col.Material = Enum.Material.Marble
			col.Color = Color3.fromRGB(240, 235, 225)
			col.Parent = model
		end

		local porticoW = (spec.columns - 1) * colSpacing / 2 + 3 * scale
		local portico = Instance.new("Part")
		portico.Name = "Portico"
		portico.Size = Vector3.new(porticoW, 0.6 * scale, 3 * scale)
		portico.Position = Vector3.new(centerX, BUILDING_BASE + colH + 0.3 * scale, centerZ + bodyZ / 2 + 1 * scale)
		portico.Anchored = true
		portico.Material = Enum.Material.Marble
		portico.Color = Color3.fromRGB(235, 230, 220)
		portico.Parent = model
	else
		-- Modern canopy
		local canopy = Instance.new("Part")
		canopy.Name = "Canopy"
		canopy.Size = Vector3.new(8 * scale, 0.3 * scale, 4 * scale)
		canopy.Position = Vector3.new(centerX, BUILDING_BASE + doorH + 1.5 * scale, centerZ + bodyZ / 2 + 2 * scale)
		canopy.Anchored = true
		canopy.Material = Enum.Material.SmoothPlastic
		canopy.Color = spec.roofColor
		canopy.Parent = model
	end

	-- Door
	local door = Instance.new("Part")
	door.Name = "Door"
	door.Size = Vector3.new(doorW, doorH, 0.3)
	door.Position = Vector3.new(centerX, BUILDING_BASE + doorH / 2, centerZ + bodyZ / 2 + 0.2)
	door.Anchored = true
	door.CanCollide = false
	door.Material = spec.columns > 0 and Enum.Material.Wood or Enum.Material.Glass
	door.Color = spec.columns > 0 and Color3.fromRGB(90, 55, 30) or Color3.fromRGB(180, 210, 240)
	door.Transparency = spec.columns > 0 and 0 or 0.3
	door.Parent = model

	-- ── GARAGE (attached on +X side, flush with front) ───────────────────
	local garageW = spec.garageW * scale
	local garageH = floorH * 0.9
	local garageD = lotD * 0.6

	local gx = centerX + bodyX / 2 + garageW / 2 + 0.5 * scale
	local gzC = centerZ + bodyZ / 2 - garageD / 2  -- flush with front face

	local garage = Instance.new("Part")
	garage.Name = "Garage"
	garage.Size = Vector3.new(garageW, garageH, garageD)
	garage.Position = Vector3.new(gx, BUILDING_BASE + garageH / 2, gzC)
	garage.Anchored = true
	garage.Material = spec.mat
	garage.Color = spec.color
	garage:SetAttribute("ThemeRole", "building_body")
	garage:SetAttribute("BaseColor", spec.color)
	garage:SetAttribute("BaseMaterial", spec.mat.Name)
	garage.Parent = model

	local gDoorH = garageH * 0.7
	local gd = Instance.new("Part")
	gd.Name = "GarageDoor"
	gd.Size = Vector3.new(garageW * 0.75, gDoorH, 0.3)
	gd.Position = Vector3.new(gx, BUILDING_BASE + gDoorH / 2 + 0.3, gzC + garageD / 2 + 0.15)
	gd.Anchored = true
	gd.CanCollide = false
	gd.Material = Enum.Material.Metal
	gd.Color = Color3.fromRGB(160, 155, 150)
	gd.Parent = model

	local gr = Instance.new("Part")
	gr.Name = "GarageRoof"
	gr.Size = Vector3.new(garageW + 1 * scale, 0.5 * scale, garageD + 1 * scale)
	gr.Position = Vector3.new(gx, BUILDING_BASE + garageH + 0.25 * scale, gzC)
	gr.Anchored = true
	gr.Material = spec.roofType == "pitched" and Enum.Material.Slate or Enum.Material.SmoothPlastic
	gr.Color = spec.roofColor
	gr:SetAttribute("ThemeRole", "building_roof")
	gr:SetAttribute("BaseColor", spec.roofColor)
	gr:SetAttribute("BaseMaterial", gr.Material.Name)
	gr.Parent = model

	-- ── LAWN + DRIVEWAY (front, +Z side) ─────────────────────────────────
	local lawnD = 3 * scale
	local lawnZ = centerZ + bodyZ / 2 + lawnD / 2 + 0.5

	local lawn = Instance.new("Part")
	lawn.Name = "Lawn"
	lawn.Size = Vector3.new(bodyX + garageW + 2 * scale, 0.3, lawnD)
	lawn.Position = Vector3.new(centerX + garageW / 4, BUILDING_BASE + 0.15, lawnZ)
	lawn.Anchored = true
	lawn.Material = Enum.Material.LeafyGrass
	lawn.Color = Color3.fromRGB(70, 145, 55)
	lawn.Parent = model

	local drive = Instance.new("Part")
	drive.Name = "Driveway"
	drive.Size = Vector3.new(MANSION_DRIVEWAY_W * scale, 0.35, lawnD + 2 * scale)
	drive.Position = Vector3.new(centerX, BUILDING_BASE + 0.2, lawnZ)
	drive.Anchored = true
	drive.Material = Enum.Material.Concrete
	drive.Color = Color3.fromRGB(170, 165, 160)
	drive.Parent = model

	-- ── POOL (behind house, -Z side) ─────────────────────────────────────
	local wantPool = options.pool
	if wantPool == nil then wantPool = spec.floors <= 2 and math.random() < 0.5 end
	if wantPool then
		local poolW = 8 * scale
		local poolL = 14 * scale

		local poolX = centerX
		local poolZ = centerZ - bodyZ / 2 - poolL / 2 - 2 * scale

		local pool = Instance.new("Part")
		pool.Name = "Pool"
		pool.Size = Vector3.new(poolL, 0.5, poolW)
		pool.Position = Vector3.new(poolX, BUILDING_BASE + 0.3, poolZ)
		pool.Anchored = true
		pool.Material = Enum.Material.Glass
		pool.Color = Color3.fromRGB(80, 185, 225)
		pool.Transparency = 0.3
		pool.Parent = model

		local edge = Instance.new("Part")
		edge.Name = "PoolEdge"
		edge.Size = Vector3.new(poolL + 2 * scale, 0.4, poolW + 2 * scale)
		edge.Position = Vector3.new(poolX, BUILDING_BASE + 0.2, poolZ)
		edge.Anchored = true
		edge.Material = Enum.Material.Marble
		edge.Color = Color3.fromRGB(230, 225, 215)
		edge.Parent = model
	end

	if options.parent then
		model.Parent = options.parent
	end

	return model
end

function AssetLibrary.getMansionCount(variant)
	local specs = MANSION_SPECS[variant or "mediterranean"]
	return specs and #specs or 0
end

function AssetLibrary.getMansionVariants()
	return { "mediterranean", "modern" }
end

--------------------------------------------------------------------------------
-- SHOP CONSTANTS
-- Standalone color/material/name pools (inlined from DecorUtils)
--------------------------------------------------------------------------------

local SHOP_DEPTH = 16

local SHOP_WALL_COLORS = {
	Color3.fromRGB(200, 190, 170), Color3.fromRGB(180, 170, 155),
	Color3.fromRGB(165, 120, 90),  Color3.fromRGB(210, 200, 185),
	Color3.fromRGB(155, 145, 135), Color3.fromRGB(190, 140, 100),
	Color3.fromRGB(220, 215, 205), Color3.fromRGB(145, 100, 80),
}

local SHOP_WINDOW_COLORS = {
	Color3.fromRGB(255, 220, 140), Color3.fromRGB(200, 230, 255),
	Color3.fromRGB(255, 200, 100), Color3.fromRGB(180, 210, 255),
	Color3.fromRGB(255, 180, 120),
}

local SHOP_SIGN_COLORS = {
	Color3.fromRGB(255, 50, 80),  Color3.fromRGB(50, 200, 255),
	Color3.fromRGB(255, 100, 200), Color3.fromRGB(50, 180, 50),
	Color3.fromRGB(255, 200, 50),
}

local SHOP_SIGN_FONTS = {
	Enum.Font.GothamBold, Enum.Font.FredokaOne, Enum.Font.Bangers,
	Enum.Font.LuckiestGuy, Enum.Font.PermanentMarker,
	Enum.Font.PatrickHand, Enum.Font.Oswald,
}

local SHOP_NAMES = {
	"PIZZA", "COFFEE", "DINER", "NOODLES", "BURGERS",
	"BOOKS", "SHOES", "VINYL", "TOYS", "ARCADE",
	"NAILS", "BARBER", "SUSHI", "TACOS", "BAKERY",
	"FLOWERS", "CANDY", "JAZZ", "RECORDS", "COMICS",
	"ICE CREAM", "LAUNDRY", "DELI", "BAGELS", "DONUTS",
}

local LUXURY_SHOP_NAMES = {
	"MAISON", "ATELIER", "NOIR", "LUXE", "BIJOUX",
	"HAUTE", "GALLERIA", "BONSOIR", "OPALE", "RIVIERA",
	"LUMIERE", "VELOUR", "PRESTIGE", "PALAZZO", "EDEN",
}

local LUXURY_WALL_COLORS = {
	Color3.fromRGB(245, 240, 230), Color3.fromRGB(235, 230, 220),
	Color3.fromRGB(225, 220, 215), Color3.fromRGB(210, 205, 200),
	Color3.fromRGB(240, 235, 225),
}

local LUXURY_SIGN_COLORS = {
	Color3.fromRGB(180, 155, 80), Color3.fromRGB(30, 30, 30),
	Color3.fromRGB(25, 25, 50),   Color3.fromRGB(140, 120, 65),
}

local LUXURY_SIGN_FONTS = { Enum.Font.GothamBold, Enum.Font.Oswald }

local LUXURY_WINDOW_COLORS = {
	Color3.fromRGB(255, 240, 200), Color3.fromRGB(255, 230, 180),
	Color3.fromRGB(240, 235, 220),
}

local function pickRandom(t)
	return t[math.random(1, #t)]
end

--------------------------------------------------------------------------------
-- createShop(centerX, centerZ, options)
-- A single 2-floor shop unit: glass storefront, interior, awning, neon sign, roof.
-- All 4 faces rendered (glass front on +Z, back wall, two side walls).
-- options.variant: "standard" or "luxury" (default "standard")
-- options.facadeWidth: facade length in studs (default random 16-26)
-- options.scale: number (default 1)
-- options.shopName: string (default random from pool)
-- options.parent: Instance to parent to
-- Returns: Model
--------------------------------------------------------------------------------

function AssetLibrary.createShop(centerX, centerZ, options)
	options = options or {}
	local variant = options.variant or "standard"
	local scale = options.scale or 1
	local isLuxury = variant == "luxury"

	local wallColors = isLuxury and LUXURY_WALL_COLORS or SHOP_WALL_COLORS
	local signColors = isLuxury and LUXURY_SIGN_COLORS or SHOP_SIGN_COLORS
	local signFonts = isLuxury and LUXURY_SIGN_FONTS or SHOP_SIGN_FONTS
	local windowColors = isLuxury and LUXURY_WINDOW_COLORS or SHOP_WINDOW_COLORS
	local nameList = isLuxury and LUXURY_SHOP_NAMES or SHOP_NAMES
	local wallMaterial = isLuxury and Enum.Material.SmoothPlastic or Enum.Material.Brick
	local awningMaterial = isLuxury and Enum.Material.SmoothPlastic or Enum.Material.Fabric
	local floorColor = isLuxury and Color3.fromRGB(240, 235, 225) or Color3.fromRGB(180, 160, 130)
	local ceilingColor = isLuxury and Color3.fromRGB(255, 245, 225) or Color3.fromRGB(255, 240, 210)
	local roofColor = isLuxury and Color3.fromRGB(30, 30, 35) or Color3.fromRGB(40, 40, 45)

	local facadeLen = options.facadeWidth and (options.facadeWidth * scale) or (math.random(16, 26) * scale)
	local bDepth = SHOP_DEPTH * scale
	local floorHeight = 10 * scale
	local floors = 2
	local height = floors * floorHeight

	local wallColor = pickRandom(wallColors)
	local signColor = pickRandom(signColors)

	-- Body dimensions: facade along X, depth along Z
	local W = facadeLen   -- width along X
	local D = bDepth      -- depth along Z

	local building = Instance.new("Model")
	building.Name = "Building_Shop"

	-- ── BACK WALL (-Z) ───────────────────────────────────────────────────
	local back = Instance.new("Part")
	back.Name = "BackWall"
	back.Size = Vector3.new(W, height, 0.5)
	back.Position = Vector3.new(centerX, BUILDING_BASE + height / 2, centerZ - D / 2)
	back.Anchored = true
	back.Material = wallMaterial
	back.Color = wallColor
	back:SetAttribute("ThemeRole", "shop_wall")
	back:SetAttribute("BaseColor", wallColor)
	back:SetAttribute("BaseMaterial", wallMaterial.Name)
	back.Parent = building

	-- ── SIDE WALLS ────────────────────────────────────────────────────────
	for _, s in ipairs({ -1, 1 }) do
		local side = Instance.new("Part")
		side.Name = "SideWall"
		side.Size = Vector3.new(0.5, height, D)
		side.Position = Vector3.new(centerX + s * W / 2, BUILDING_BASE + height / 2, centerZ)
		side.Anchored = true
		side.Material = wallMaterial
		side.Color = wallColor
		side:SetAttribute("ThemeRole", "shop_wall")
		side:SetAttribute("BaseColor", wallColor)
		side:SetAttribute("BaseMaterial", wallMaterial.Name)
		side.Parent = building
	end

	-- ── UPPER FRONT WALL (+Z, 2nd floor above glass) ─────────────────────
	local upperFrontH = height - floorHeight
	local frontZ = centerZ + D / 2 + 0.2
	local upperFront = Instance.new("Part")
	upperFront.Name = "UpperFrontWall"
	upperFront.Size = Vector3.new(W, upperFrontH, 0.5)
	upperFront.Position = Vector3.new(centerX, BUILDING_BASE + floorHeight + upperFrontH / 2, frontZ)
	upperFront.Anchored = true
	upperFront.Material = wallMaterial
	upperFront.Color = wallColor
	upperFront:SetAttribute("ThemeRole", "shop_wall")
	upperFront:SetAttribute("BaseColor", wallColor)
	upperFront:SetAttribute("BaseMaterial", wallMaterial.Name)
	upperFront.Parent = building

	-- ── GLASS STOREFRONT (+Z face, ground floor) ──────────────────────────
	local glassHeight = floorHeight * 0.92
	local glassY = BUILDING_BASE + glassHeight / 2 + 0.2
	local glass = Instance.new("Part")
	glass.Name = "StorefrontGlass"
	glass.Size = Vector3.new(W * 0.95, glassHeight, 0.3)
	glass.Position = Vector3.new(centerX, glassY, frontZ)
	glass.Anchored = true
	glass.CanCollide = true
	glass.Material = Enum.Material.Glass
	glass.Color = isLuxury and Color3.fromRGB(220, 235, 255) or Color3.fromRGB(200, 230, 255)
	glass.Transparency = 0.65
	glass:SetAttribute("ThemeRole", "shop_glass")
	glass:SetAttribute("BaseColor", glass.Color)
	glass.Parent = building

	-- Mullions
	local numMullions = 4
	local mullionSpacing = (W * 0.95) / (numMullions + 1)
	for m = 1, numMullions do
		local mullion = Instance.new("Part")
		mullion.Name = "Mullion"
		mullion.Size = Vector3.new(0.15, glassHeight, 0.15)
		mullion.Position = Vector3.new(centerX - (W * 0.95) / 2 + m * mullionSpacing, glassY, frontZ + 0.1)
		mullion.Anchored = true
		mullion.CanCollide = false
		mullion.Material = Enum.Material.Metal
		mullion.Color = Color3.fromRGB(120, 120, 125)
		mullion:SetAttribute("ThemeRole", "shop_mullion")
		mullion:SetAttribute("BaseColor", mullion.Color)
		mullion.Parent = building
	end

	-- ── INTERIOR ──────────────────────────────────────────────────────────
	local interiorFloor = Instance.new("Part")
	interiorFloor.Name = "InteriorFloor"
	interiorFloor.Size = Vector3.new(W * 0.9, 0.3, D * 0.8)
	interiorFloor.Position = Vector3.new(centerX, BUILDING_BASE + 0.15, centerZ)
	interiorFloor.Anchored = true
	interiorFloor.CanCollide = false
	interiorFloor.Material = Enum.Material.SmoothPlastic
	interiorFloor.Color = floorColor
	interiorFloor:SetAttribute("ThemeRole", "shop_floor")
	interiorFloor:SetAttribute("BaseColor", floorColor)
	interiorFloor.Parent = building

	local ceilingLight = Instance.new("Part")
	ceilingLight.Name = "CeilingLight"
	ceilingLight.Size = Vector3.new(W * 0.6, 0.3, D * 0.4)
	ceilingLight.Position = Vector3.new(centerX, BUILDING_BASE + floorHeight - 0.3, centerZ)
	ceilingLight.Anchored = true
	ceilingLight.CanCollide = false
	ceilingLight.Material = Enum.Material.Neon
	ceilingLight.Color = ceilingColor
	ceilingLight:SetAttribute("ThemeRole", "shop_ceiling")
	ceilingLight:SetAttribute("BaseColor", ceilingColor)
	ceilingLight.Parent = building

	local shopLight = Instance.new("PointLight")
	shopLight.Color = isLuxury and Color3.fromRGB(255, 245, 220) or Color3.fromRGB(255, 230, 180)
	shopLight.Brightness = 0.5
	shopLight.Range = 12
	shopLight:SetAttribute("ThemeRole", "shop_shoplight")
	shopLight:SetAttribute("BaseColor", shopLight.Color)
	shopLight.Parent = ceilingLight

	local interiorBack = Instance.new("Part")
	interiorBack.Name = "InteriorBackWall"
	interiorBack.Size = Vector3.new(W * 0.7, floorHeight * 0.7, 0.3)
	interiorBack.Position = Vector3.new(centerX, BUILDING_BASE + floorHeight * 0.4, centerZ - D * 0.35)
	interiorBack.Anchored = true
	interiorBack.CanCollide = false
	interiorBack.Material = Enum.Material.SmoothPlastic
	interiorBack.Color = pickRandom(wallColors)
	interiorBack:SetAttribute("ThemeRole", "shop_wall")
	interiorBack:SetAttribute("BaseColor", interiorBack.Color)
	interiorBack:SetAttribute("BaseMaterial", Enum.Material.SmoothPlastic.Name)
	interiorBack.Parent = building

	-- ── AWNING (+Z face) ──────────────────────────────────────────────────
	local awning = Instance.new("Part")
	awning.Name = "Awning"
	awning.Size = Vector3.new(W * 0.9, 0.4, 3 * scale)
	awning.Position = Vector3.new(centerX, BUILDING_BASE + floorHeight - 0.5, frontZ + 1.5 * scale)
	awning.Anchored = true
	awning.Material = awningMaterial
	awning.Color = signColor
	awning:SetAttribute("ThemeRole", "shop_awning")
	awning:SetAttribute("BaseColor", signColor)
	awning:SetAttribute("BaseMaterial", awningMaterial.Name)
	awning.Parent = building

	-- ── SECOND FLOOR WINDOWS (front +Z) ───────────────────────────────────
	local upWinW = 2.5 * scale
	local upWinH = 3 * scale
	local upWinY = BUILDING_BASE + floorHeight + floorHeight * 0.45
	local numUpWin = math.floor(W / (upWinW + 2))
	local totalUpW = numUpWin * upWinW + (numUpWin - 1) * 2
	local startOff = -totalUpW / 2 + upWinW / 2

	for w = 1, numUpWin do
		local off = startOff + (w - 1) * (upWinW + 2)
		local win = Instance.new("Part")
		win.Name = "UpperWindow"
		win.Size = Vector3.new(upWinW, upWinH, 0.3)
		win.Position = Vector3.new(centerX + off, upWinY, frontZ)
		win.Anchored = true
		win.CanCollide = false
		if math.random() < 0.5 then
			win.Material = Enum.Material.Neon
			win.Color = pickRandom(windowColors)
			win:SetAttribute("ThemeRole", "shop_window")
			win:SetAttribute("BaseColor", win.Color)
		else
			win.Material = Enum.Material.Glass
			win.Color = Color3.fromRGB(80, 120, 160)
			win:SetAttribute("ThemeRole", "shop_darkwindow")
			win:SetAttribute("BaseColor", win.Color)
		end
		win.Parent = building
	end

	-- ── BACK FACE WINDOWS (-Z, dimmer) ────────────────────────────────────
	for w = 1, math.max(1, numUpWin - 1) do
		local off = startOff + (w - 1) * (upWinW + 2)
		local win = Instance.new("Part")
		win.Name = "BackWindow"
		win.Size = Vector3.new(upWinW, upWinH, 0.3)
		win.Position = Vector3.new(centerX + off, upWinY, centerZ - D / 2 - 0.2)
		win.Anchored = true
		win.CanCollide = false
		win.Material = Enum.Material.Glass
		win.Color = Color3.fromRGB(60, 80, 100)
		win:SetAttribute("ThemeRole", "shop_darkwindow")
		win:SetAttribute("BaseColor", win.Color)
		win.Parent = building
	end

	-- ── NEON SIGN (front +Z, above storefront) ───────────────────────────
	local shopName = options.shopName or pickRandom(nameList)
	local signH = 2.5 * scale
	local signW = W * 0.6
	local neonSign = Instance.new("Part")
	neonSign.Name = "NeonSign"
	neonSign.Size = Vector3.new(signW, signH, 0.4)
	neonSign.Position = Vector3.new(centerX, BUILDING_BASE + floorHeight + signH / 2 + 0.5, frontZ + 0.3)
	neonSign.Anchored = true
	neonSign.CanCollide = false
	neonSign.Material = Enum.Material.Neon
	neonSign.Color = signColor
	neonSign:SetAttribute("ThemeRole", "shop_sign")
	neonSign:SetAttribute("BaseColor", signColor)
	neonSign.Parent = building

	local gui = Instance.new("SurfaceGui")
	gui.Name = "SignGui"
	gui.Face = Enum.NormalId.Back
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 50
	gui.Parent = neonSign

	local label = Instance.new("TextLabel")
	label.Name = "ShopName"
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = shopName
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	label.Font = pickRandom(signFonts)
	label:SetAttribute("ThemeRole", "shop_signtext")
	label.Parent = gui

	-- ── ROOF ──────────────────────────────────────────────────────────────
	local roof = Instance.new("Part")
	roof.Name = "Roof"
	roof.Size = Vector3.new(W + 0.5, 0.5, D + 0.5)
	roof.Position = Vector3.new(centerX, BUILDING_BASE + height + 0.25, centerZ)
	roof.Anchored = true
	roof.Material = Enum.Material.Metal
	roof.Color = roofColor
	roof:SetAttribute("ThemeRole", "shop_roof")
	roof:SetAttribute("BaseColor", roofColor)
	roof.Parent = building

	if options.parent then
		building.Parent = options.parent
	end

	return building
end

function AssetLibrary.getShopVariants()
	return { "standard", "luxury" }
end

--------------------------------------------------------------------------------
-- HOOD BUILDING CONSTANTS
--------------------------------------------------------------------------------

local HOOD_WALL_COLORS = {
	Color3.fromRGB(140, 120, 100),  -- dirty beige
	Color3.fromRGB(120, 110, 100),  -- grimy grey
	Color3.fromRGB(130, 100, 80),   -- faded brown
	Color3.fromRGB(110, 105, 95),   -- dark concrete
	Color3.fromRGB(100, 90, 80),    -- smoky
}

local HOOD_SHOP_NAMES = {
	"LAUNDRY", "BARBER", "BODEGA", "TIRES", "99c STORE",
	"AUTO PARTS", "NAILS", "CHICKEN", "TACOS", "PHONE FIX",
	"SNEAKERS", "MUSIC", "PET SHOP", "CANDY", "JUICE BAR",
}

--------------------------------------------------------------------------------
-- createHoodBuilding(centerX, centerZ, options)
-- Ground-floor shop + 2-4 upper brick apartment floors stacked on top.
-- options.facadeWidth: facade width in studs (default random 16-26)
-- options.extraFloors: 2-4 upper apartment floors (default random)
-- options.scale: number (default 1)
-- options.shopName: string (default random from hood names)
-- options.parent: Instance to parent to
-- Returns: Model
--------------------------------------------------------------------------------

function AssetLibrary.createHoodBuilding(centerX, centerZ, options)
	options = options or {}
	local scale = options.scale or 1
	local facadeWidth = options.facadeWidth or math.random(16, 26)

	-- Build the shop base using createShop
	local shopModel = AssetLibrary.createShop(centerX, centerZ, {
		variant = "standard",
		facadeWidth = facadeWidth,
		scale = scale,
		shopName = options.shopName or pickRandom(HOOD_SHOP_NAMES),
	})

	-- Rename to hood building
	shopModel.Name = "HoodBuilding"

	-- Stack hood apartment floors on top
	local extraFloors = options.extraFloors or math.random(2, 4)
	local floorH = 8 * scale
	local shopH = 2 * 10 * scale  -- 2 shop floors × 10 studs
	local extraH = extraFloors * floorH
	local wallColor = pickRandom(HOOD_WALL_COLORS)

	local bDepth = SHOP_DEPTH * scale
	local facadeLen = facadeWidth * scale

	-- Upper brick body
	local body = Instance.new("Part")
	body.Name = "UpperBody"
	body.Size = Vector3.new(facadeLen, extraH, bDepth)
	body.Position = Vector3.new(centerX, BUILDING_BASE + shopH + extraH / 2, centerZ)
	body.Anchored = true
	body.Material = Enum.Material.Brick
	body.Color = wallColor
	body:SetAttribute("ThemeRole", "building_body")
	body:SetAttribute("BaseColor", wallColor)
	body:SetAttribute("BaseMaterial", "Brick")
	body.Parent = shopModel

	-- Windows on all 4 faces
	local winW = 2 * scale
	local winH = 3 * scale
	local winGap = 2 * scale

	-- Front (+Z) and Back (-Z) windows
	for _, faceData in ipairs({
		{ axis = "z", coord = centerZ + bDepth / 2 + 0.2, width = facadeLen, litChance = 0.4 },
		{ axis = "z", coord = centerZ - bDepth / 2 - 0.2, width = facadeLen, litChance = 0.2 },
		{ axis = "x", coord = centerX - facadeLen / 2 - 0.2, width = bDepth, litChance = 0.15 },
		{ axis = "x", coord = centerX + facadeLen / 2 + 0.2, width = bDepth, litChance = 0.15 },
	}) do
		local center = faceData.axis == "z" and centerX or centerZ
		local available = faceData.width - 3
		local numWin = math.floor((available + winGap) / (winW + winGap))
		if numWin > 0 then
			local totalWinW = numWin * winW + (numWin - 1) * winGap
			local winStart = -totalWinW / 2 + winW / 2

			for floor = 1, extraFloors do
				local floorY = BUILDING_BASE + shopH + (floor - 0.5) * floorH
				for w = 1, numWin do
					local offset = winStart + (w - 1) * (winW + winGap)
					local win = Instance.new("Part")
					win.Name = "Window"
					win.Anchored = true
					win.CanCollide = false

					if faceData.axis == "z" then
						win.Size = Vector3.new(winW, winH, 0.3)
						win.Position = Vector3.new(center + offset, floorY, faceData.coord)
					else
						win.Size = Vector3.new(0.3, winH, winW)
						win.Position = Vector3.new(faceData.coord, floorY, center + offset)
					end

					if math.random() < faceData.litChance then
						win.Material = Enum.Material.Neon
						win.Color = Color3.fromRGB(255, 200, 100)
						win:SetAttribute("ThemeRole", "building_window_lit")
						win:SetAttribute("BaseColor", Color3.fromRGB(255, 200, 100))
						win:SetAttribute("BaseMaterial", "Neon")
					else
						win.Material = Enum.Material.Glass
						win.Color = Color3.fromRGB(50, 60, 70)
						win:SetAttribute("ThemeRole", "building_window")
						win:SetAttribute("BaseColor", Color3.fromRGB(50, 60, 70))
						win:SetAttribute("BaseMaterial", "Glass")
					end
					win.Parent = shopModel
				end
			end
		end
	end

	-- Flat roof edge (replaces the shop roof)
	local roofEdge = Instance.new("Part")
	roofEdge.Name = "RoofEdge"
	roofEdge.Size = Vector3.new(facadeLen + 0.5, 0.8, bDepth + 0.5)
	roofEdge.Position = Vector3.new(centerX, BUILDING_BASE + shopH + extraH + 0.4, centerZ)
	roofEdge.Anchored = true
	roofEdge.Material = Enum.Material.Concrete
	roofEdge.Color = Color3.fromRGB(80, 75, 70)
	roofEdge:SetAttribute("ThemeRole", "building_roof")
	roofEdge:SetAttribute("BaseColor", Color3.fromRGB(80, 75, 70))
	roofEdge:SetAttribute("BaseMaterial", "Concrete")
	roofEdge.Parent = shopModel

	if options.parent then
		shopModel.Parent = options.parent
	end

	return shopModel
end

--------------------------------------------------------------------------------
-- MIAMI BUILDING SPECS
-- Art Deco pastel buildings: 6 palette variants
-- Each: 4-floor main body + 2-floor central tower + neon accent strips
--------------------------------------------------------------------------------

local MIAMI_PALETTES = {
	{ name = "pink",     body = Color3.fromRGB(230, 180, 180), trim = Color3.fromRGB(255, 255, 255), neon = Color3.fromRGB(255, 180, 100) },
	{ name = "mint",     body = Color3.fromRGB(170, 220, 200), trim = Color3.fromRGB(255, 255, 255), neon = Color3.fromRGB(100, 255, 200) },
	{ name = "cream",    body = Color3.fromRGB(240, 230, 190), trim = Color3.fromRGB(255, 255, 255), neon = Color3.fromRGB(255, 220, 130) },
	{ name = "coral",    body = Color3.fromRGB(220, 170, 160), trim = Color3.fromRGB(255, 255, 255), neon = Color3.fromRGB(255, 140, 100) },
	{ name = "lavender", body = Color3.fromRGB(200, 190, 230), trim = Color3.fromRGB(255, 255, 255), neon = Color3.fromRGB(180, 140, 255) },
	{ name = "blue",     body = Color3.fromRGB(180, 210, 240), trim = Color3.fromRGB(255, 255, 255), neon = Color3.fromRGB(100, 200, 255) },
}

--------------------------------------------------------------------------------
-- createMiamiBuilding(centerX, centerZ, options)
-- options.palette: 1-6 or palette name string (default random)
-- options.scale: number (default 1)
-- options.parent: Instance to parent to
-- Returns: Model
--------------------------------------------------------------------------------

function AssetLibrary.createMiamiBuilding(centerX, centerZ, options)
	options = options or {}
	local scale = options.scale or 1

	-- Resolve palette
	local paletteIndex
	if type(options.palette) == "number" then
		paletteIndex = math.clamp(options.palette, 1, #MIAMI_PALETTES)
	elseif type(options.palette) == "string" then
		for i, p in ipairs(MIAMI_PALETTES) do
			if p.name == options.palette then paletteIndex = i; break end
		end
		paletteIndex = paletteIndex or math.random(1, #MIAMI_PALETTES)
	else
		paletteIndex = math.random(1, #MIAMI_PALETTES)
	end
	local palette = MIAMI_PALETTES[paletteIndex]

	-- Dimensions
	local bodyW = 18 * scale
	local bodyD = 12 * scale
	local floorH = 4 * scale
	local mainFloors = 4
	local towerFloors = 2
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
	body.Position = Vector3.new(centerX, BUILDING_BASE + mainH / 2, centerZ)
	body.Anchored = true
	body.CanCollide = true
	body.Material = Enum.Material.Concrete
	body.Color = palette.body
	body:SetAttribute("ThemeRole", "building_body")
	body:SetAttribute("BaseColor", palette.body)
	body:SetAttribute("BaseMaterial", "Concrete")
	body.Parent = model

	-- Central tower
	local tower = Instance.new("Part")
	tower.Name = "Tower"
	tower.Size = Vector3.new(towerW, towerH, bodyD * 0.7)
	tower.Position = Vector3.new(centerX, BUILDING_BASE + mainH + towerH / 2, centerZ)
	tower.Anchored = true
	tower.CanCollide = true
	tower.Material = Enum.Material.Concrete
	tower.Color = palette.body
	tower:SetAttribute("ThemeRole", "building_body")
	tower:SetAttribute("BaseColor", palette.body)
	tower:SetAttribute("BaseMaterial", "Concrete")
	tower.Parent = model

	-- Tower cap
	local cap = Instance.new("Part")
	cap.Name = "TowerCap"
	cap.Size = Vector3.new(towerW + 1 * scale, 0.6 * scale, bodyD * 0.7 + 1 * scale)
	cap.Position = Vector3.new(centerX, BUILDING_BASE + totalH + 0.3 * scale, centerZ)
	cap.Anchored = true
	cap.CanCollide = false
	cap.Material = Enum.Material.Concrete
	cap.Color = palette.trim
	cap.Parent = model

	-- Roof parapets (left and right wings)
	for _, side in ipairs({ -1, 1 }) do
		local wingW = (bodyW - towerW) / 2
		local wingX = centerX + side * (towerW / 2 + wingW / 2)
		local parapet = Instance.new("Part")
		parapet.Name = "Parapet"
		parapet.Size = Vector3.new(wingW, 0.8 * scale, bodyD)
		parapet.Position = Vector3.new(wingX, BUILDING_BASE + mainH + 0.4 * scale, centerZ)
		parapet.Anchored = true
		parapet.CanCollide = false
		parapet.Material = Enum.Material.Concrete
		parapet.Color = palette.trim
		parapet.Parent = model
	end

	-- Neon accent strips — all 4 faces of main body
	for _, faceData in ipairs({
		{ axis = "z", coord = centerZ + bodyD / 2 + 0.05, width = bodyW },
		{ axis = "z", coord = centerZ - bodyD / 2 - 0.05, width = bodyW },
		{ axis = "x", coord = centerX + bodyW / 2 + 0.05, width = bodyD },
		{ axis = "x", coord = centerX - bodyW / 2 - 0.05, width = bodyD },
	}) do
		for floor = 1, mainFloors do
			local stripY = BUILDING_BASE + floor * floorH
			local strip = Instance.new("Part")
			strip.Name = "NeonStrip"
			if faceData.axis == "z" then
				strip.Size = Vector3.new(faceData.width + 0.4 * scale, 0.25 * scale, 0.15)
				strip.Position = Vector3.new(centerX, stripY, faceData.coord)
			else
				strip.Size = Vector3.new(0.15, 0.25 * scale, faceData.width + 0.4 * scale)
				strip.Position = Vector3.new(faceData.coord, stripY, centerZ)
			end
			strip.Anchored = true
			strip.CanCollide = false
			strip.Material = Enum.Material.Neon
			strip.Color = palette.neon
			strip:SetAttribute("ThemeRole", "building_neon")
			strip:SetAttribute("BaseColor", palette.neon)
			strip:SetAttribute("BaseMaterial", "Neon")
			strip.Parent = model
		end
	end

	-- Tower neon strips (front + back only)
	for _, faceData in ipairs({
		{ axis = "z", coord = centerZ + bodyD / 2 + 0.05, width = towerW },
		{ axis = "z", coord = centerZ - bodyD / 2 - 0.05, width = towerW },
	}) do
		for floor = 1, towerFloors do
			local stripY = BUILDING_BASE + mainH + floor * floorH
			local strip = Instance.new("Part")
			strip.Name = "NeonStrip"
			strip.Size = Vector3.new(faceData.width + 0.4 * scale, 0.25 * scale, 0.15)
			strip.Position = Vector3.new(centerX, stripY, faceData.coord)
			strip.Anchored = true
			strip.CanCollide = false
			strip.Material = Enum.Material.Neon
			strip.Color = palette.neon
			strip:SetAttribute("ThemeRole", "building_neon")
			strip:SetAttribute("BaseColor", palette.neon)
			strip:SetAttribute("BaseMaterial", "Neon")
			strip.Parent = model
		end
	end

	-- Vertical neon pillars on tower edges (front + back)
	for _, faceZ in ipairs({ centerZ + bodyD / 2 + 0.05, centerZ - bodyD / 2 - 0.05 }) do
		for _, side in ipairs({ -1, 1 }) do
			local pillar = Instance.new("Part")
			pillar.Name = "NeonPillar"
			pillar.Size = Vector3.new(0.3 * scale, totalH, 0.3 * scale)
			pillar.Position = Vector3.new(centerX + side * towerW / 2, BUILDING_BASE + totalH / 2, faceZ)
			pillar.Anchored = true
			pillar.CanCollide = false
			pillar.Material = Enum.Material.Neon
			pillar.Color = palette.neon
			pillar:SetAttribute("ThemeRole", "building_neon")
			pillar:SetAttribute("BaseColor", palette.neon)
			pillar:SetAttribute("BaseMaterial", "Neon")
			pillar.Parent = model

			local cornerPillar = Instance.new("Part")
			cornerPillar.Name = "NeonCorner"
			cornerPillar.Size = Vector3.new(0.3 * scale, mainH, 0.3 * scale)
			cornerPillar.Position = Vector3.new(centerX + side * bodyW / 2, BUILDING_BASE + mainH / 2, faceZ)
			cornerPillar.Anchored = true
			cornerPillar.CanCollide = false
			cornerPillar.Material = Enum.Material.Neon
			cornerPillar.Color = palette.neon
			cornerPillar:SetAttribute("ThemeRole", "building_neon")
			cornerPillar:SetAttribute("BaseColor", palette.neon)
			cornerPillar:SetAttribute("BaseMaterial", "Neon")
			cornerPillar.Parent = model
		end
	end

	-- Entrance (front +Z)
	local entranceW = 4 * scale
	local entranceH = floorH * 0.85
	local entrance = Instance.new("Part")
	entrance.Name = "Entrance"
	entrance.Size = Vector3.new(entranceW, entranceH, 0.4)
	entrance.Position = Vector3.new(centerX, BUILDING_BASE + entranceH / 2, centerZ + bodyD / 2 + 0.15)
	entrance.Anchored = true
	entrance.CanCollide = false
	entrance.Material = Enum.Material.Glass
	entrance.Color = Color3.fromRGB(40, 60, 80)
	entrance.Transparency = 0.3
	entrance.Parent = model

	-- Windows on all 4 faces (main body)
	local litColor = Color3.fromRGB(255, 240, 200)
	local winW = 2.0 * scale
	local winH = 2.5 * scale
	local winGap = 1.5 * scale

	-- Front (+Z)
	addWindowsToFace(model, "z", centerZ + bodyD / 2 + 0.05, centerX, bodyW, BUILDING_BASE,
		mainFloors, floorH, winW, winH, winGap, litColor, 0.6)
	-- Back (-Z)
	addWindowsToFace(model, "z", centerZ - bodyD / 2 - 0.05, centerX, bodyW, BUILDING_BASE,
		mainFloors, floorH, winW, winH, winGap, litColor, 0.35)
	-- Left (-X)
	addWindowsToFace(model, "x", centerX - bodyW / 2 - 0.05, centerZ, bodyD, BUILDING_BASE,
		mainFloors, floorH, winW, winH, winGap, litColor, 0.45)
	-- Right (+X)
	addWindowsToFace(model, "x", centerX + bodyW / 2 + 0.05, centerZ, bodyD, BUILDING_BASE,
		mainFloors, floorH, winW, winH, winGap, litColor, 0.45)

	-- Tower windows (front + back)
	addWindowsToFace(model, "z", centerZ + bodyD / 2 + 0.05, centerX, towerW, BUILDING_BASE + mainH,
		towerFloors, floorH, winW, winH, winGap, litColor, 0.7)
	addWindowsToFace(model, "z", centerZ - bodyD / 2 - 0.05, centerX, towerW, BUILDING_BASE + mainH,
		towerFloors, floorH, winW, winH, winGap, litColor, 0.4)

	model.PrimaryPart = body

	if options.parent then
		model.Parent = options.parent
	end

	return model
end

function AssetLibrary.getMiamiPalettes()
	local names = {}
	for _, p in ipairs(MIAMI_PALETTES) do table.insert(names, p.name) end
	return names
end

function AssetLibrary.getMiamiPaletteCount()
	return #MIAMI_PALETTES
end

--------------------------------------------------------------------------------
-- DOCK BUILDING SPECS
-- Industrial dock warehouses: 6 palette variants (material + color combos)
-- 3 floors, 30W × 20D studs, loading bay doors, roof vents
--------------------------------------------------------------------------------

local DOCK_PALETTES = {
	{ name = "brick",      body = Color3.fromRGB(140, 65, 55),   trim = Color3.fromRGB(70, 70, 75),  accent = Color3.fromRGB(255, 180, 80),  mat = Enum.Material.Brick },
	{ name = "concrete",   body = Color3.fromRGB(85, 85, 90),    trim = Color3.fromRGB(55, 55, 60),  accent = Color3.fromRGB(200, 220, 255), mat = Enum.Material.Concrete },
	{ name = "rust",       body = Color3.fromRGB(120, 80, 50),   trim = Color3.fromRGB(80, 60, 45),  accent = Color3.fromRGB(255, 200, 100), mat = Enum.Material.CorrodedMetal },
	{ name = "blue_steel", body = Color3.fromRGB(50, 65, 95),    trim = Color3.fromRGB(40, 45, 55),  accent = Color3.fromRGB(140, 200, 255), mat = Enum.Material.CorrodedMetal },
	{ name = "olive",      body = Color3.fromRGB(75, 85, 60),    trim = Color3.fromRGB(50, 55, 45),  accent = Color3.fromRGB(180, 255, 140), mat = Enum.Material.CorrodedMetal },
	{ name = "tan",        body = Color3.fromRGB(170, 155, 130), trim = Color3.fromRGB(90, 85, 75),  accent = Color3.fromRGB(255, 230, 170), mat = Enum.Material.Brick },
}

--------------------------------------------------------------------------------
-- createDockBuilding(centerX, centerZ, options)
-- options.palette: 1-6 or palette name string (default random)
-- options.scale: number (default 1)
-- options.parent: Instance to parent to
-- Returns: Model
--------------------------------------------------------------------------------

function AssetLibrary.createDockBuilding(centerX, centerZ, options)
	options = options or {}
	local scale = options.scale or 1

	-- Resolve palette
	local paletteIndex
	if type(options.palette) == "number" then
		paletteIndex = math.clamp(options.palette, 1, #DOCK_PALETTES)
	elseif type(options.palette) == "string" then
		for i, p in ipairs(DOCK_PALETTES) do
			if p.name == options.palette then paletteIndex = i; break end
		end
		paletteIndex = paletteIndex or math.random(1, #DOCK_PALETTES)
	else
		paletteIndex = math.random(1, #DOCK_PALETTES)
	end
	local palette = DOCK_PALETTES[paletteIndex]

	-- Dimensions
	local bodyW = 30 * scale
	local bodyD = 20 * scale
	local floorH = 5 * scale
	local floors = 3
	local bodyH = floors * floorH

	local model = Instance.new("Model")
	model.Name = "DockBuilding"

	-- Main body
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(bodyW, bodyH, bodyD)
	body.Position = Vector3.new(centerX, BUILDING_BASE + bodyH / 2, centerZ)
	body.Anchored = true
	body.CanCollide = true
	body.Material = palette.mat
	body.Color = palette.body
	body:SetAttribute("ThemeRole", "building_body")
	body:SetAttribute("BaseColor", palette.body)
	body:SetAttribute("BaseMaterial", palette.mat.Name)
	body.Parent = model

	-- Metal base strip
	local baseStrip = Instance.new("Part")
	baseStrip.Name = "BaseStrip"
	baseStrip.Size = Vector3.new(bodyW + 0.4 * scale, 1.5 * scale, bodyD + 0.4 * scale)
	baseStrip.Position = Vector3.new(centerX, BUILDING_BASE + 0.75 * scale, centerZ)
	baseStrip.Anchored = true
	baseStrip.CanCollide = false
	baseStrip.Material = Enum.Material.Metal
	baseStrip.Color = palette.trim
	baseStrip.Parent = model

	-- Metal roof
	local roof = Instance.new("Part")
	roof.Name = "Roof"
	roof.Size = Vector3.new(bodyW + 2 * scale, 0.6 * scale, bodyD + 2 * scale)
	roof.Position = Vector3.new(centerX, BUILDING_BASE + bodyH + 0.3 * scale, centerZ)
	roof.Anchored = true
	roof.CanCollide = false
	roof.Material = Enum.Material.Metal
	roof.Color = palette.trim
	roof:SetAttribute("ThemeRole", "building_roof")
	roof:SetAttribute("BaseColor", palette.trim)
	roof:SetAttribute("BaseMaterial", "Metal")
	roof.Parent = model

	-- Roof vents
	for i = -1, 1 do
		local vent = Instance.new("Part")
		vent.Name = "RoofVent"
		vent.Size = Vector3.new(3.5 * scale, 2 * scale, 2.5 * scale)
		vent.Position = Vector3.new(centerX + i * 8 * scale, BUILDING_BASE + bodyH + 1.3 * scale, centerZ)
		vent.Anchored = true
		vent.CanCollide = false
		vent.Material = Enum.Material.Metal
		vent.Color = palette.trim
		vent.Parent = model
	end

	-- Loading bay doors on front (+Z) and back (-Z)
	local doorH = floorH * 0.8
	local doorW = 6 * scale
	for _, faceData in ipairs({
		{ z = centerZ + bodyD / 2 + 0.05 },
		{ z = centerZ - bodyD / 2 - 0.05 },
	}) do
		for _, dx in ipairs({ -8 * scale, 0, 8 * scale }) do
			local door = Instance.new("Part")
			door.Name = "LoadingDoor"
			door.Size = Vector3.new(doorW, doorH, 0.3)
			door.Position = Vector3.new(centerX + dx, BUILDING_BASE + doorH / 2, faceData.z)
			door.Anchored = true
			door.CanCollide = false
			door.Material = Enum.Material.DiamondPlate
			door.Color = palette.trim
			door.Parent = model

			local frame = Instance.new("Part")
			frame.Name = "DoorFrame"
			frame.Size = Vector3.new(doorW + 0.8 * scale, 0.4 * scale, 0.15)
			frame.Position = Vector3.new(centerX + dx, BUILDING_BASE + doorH + 0.2 * scale, faceData.z)
			frame.Anchored = true
			frame.CanCollide = false
			frame.Material = Enum.Material.Neon
			frame.Color = palette.accent
			frame:SetAttribute("ThemeRole", "building_neon")
			frame:SetAttribute("BaseColor", palette.accent)
			frame:SetAttribute("BaseMaterial", "Neon")
			frame.Parent = model
		end
	end

	-- Windows on all 4 faces (upper floors on front/back, all floors on sides)
	local litColor = Color3.fromRGB(220, 230, 245)
	local winW = 3.0 * scale
	local winH = 2.0 * scale
	local winGap = 2.0 * scale

	-- Front/back upper floors (skip ground floor — has loading doors)
	addWindowsToFace(model, "z", centerZ + bodyD / 2 + 0.05, centerX, bodyW, BUILDING_BASE + floorH,
		floors - 1, floorH, winW, winH, winGap, litColor, 0.5)
	addWindowsToFace(model, "z", centerZ - bodyD / 2 - 0.05, centerX, bodyW, BUILDING_BASE + floorH,
		floors - 1, floorH, winW, winH, winGap, litColor, 0.3)
	-- Side faces (all floors)
	addWindowsToFace(model, "x", centerX - bodyW / 2 - 0.05, centerZ, bodyD, BUILDING_BASE,
		floors, floorH, winW, winH, winGap, litColor, 0.4)
	addWindowsToFace(model, "x", centerX + bodyW / 2 + 0.05, centerZ, bodyD, BUILDING_BASE,
		floors, floorH, winW, winH, winGap, litColor, 0.4)

	-- Accent strips at roofline (all 4 faces)
	for _, stripData in ipairs({
		{ axis = "z", coord = centerZ + bodyD / 2 + 0.05, width = bodyW },
		{ axis = "z", coord = centerZ - bodyD / 2 - 0.05, width = bodyW },
		{ axis = "x", coord = centerX + bodyW / 2 + 0.05, width = bodyD },
		{ axis = "x", coord = centerX - bodyW / 2 - 0.05, width = bodyD },
	}) do
		local strip = Instance.new("Part")
		strip.Name = "RoofStrip"
		if stripData.axis == "z" then
			strip.Size = Vector3.new(stripData.width + 0.4 * scale, 0.35 * scale, 0.15)
			strip.Position = Vector3.new(centerX, BUILDING_BASE + bodyH, stripData.coord)
		else
			strip.Size = Vector3.new(0.15, 0.35 * scale, stripData.width + 0.4 * scale)
			strip.Position = Vector3.new(stripData.coord, BUILDING_BASE + bodyH, centerZ)
		end
		strip.Anchored = true
		strip.CanCollide = false
		strip.Material = Enum.Material.Neon
		strip.Color = palette.accent
		strip:SetAttribute("ThemeRole", "building_neon")
		strip:SetAttribute("BaseColor", palette.accent)
		strip:SetAttribute("BaseMaterial", "Neon")
		strip.Parent = model
	end

	-- Floor division strips on front face
	for floor = 1, floors - 1 do
		local divStrip = Instance.new("Part")
		divStrip.Name = "FloorDiv"
		divStrip.Size = Vector3.new(bodyW + 0.2 * scale, 0.25 * scale, 0.15)
		divStrip.Position = Vector3.new(centerX, BUILDING_BASE + floor * floorH, centerZ + bodyD / 2 + 0.05)
		divStrip.Anchored = true
		divStrip.CanCollide = false
		divStrip.Material = Enum.Material.Metal
		divStrip.Color = palette.trim
		divStrip.Parent = model
	end

	model.PrimaryPart = body

	if options.parent then
		model.Parent = options.parent
	end

	return model
end

function AssetLibrary.getDockPalettes()
	local names = {}
	for _, p in ipairs(DOCK_PALETTES) do table.insert(names, p.name) end
	return names
end

function AssetLibrary.getDockPaletteCount()
	return #DOCK_PALETTES
end

--------------------------------------------------------------------------------
-- createGlassCubeStore(centerX, centerZ, options)
-- Iconic transparent glass cube retail showpiece (Apple Store parody).
-- 36×36×28 studs, 4 glass walls with steel mullions, interior display tables.
-- options.scale: number (default 1)
-- options.parent: Instance to parent to
-- Returns: Model
--------------------------------------------------------------------------------

function AssetLibrary.createGlassCubeStore(centerX, centerZ, options)
	options = options or {}
	local scale = options.scale or 1

	local model = Instance.new("Model")
	model.Name = "GlassCubeStore"

	-- Dimensions
	local cubeW = 36 * scale
	local cubeH = 28 * scale
	local cubeD = 36 * scale
	local slabW = 40 * scale
	local slabD = 40 * scale

	-- Concrete base slab
	local slab = Instance.new("Part")
	slab.Name = "BaseSlab"
	slab.Size = Vector3.new(slabD, 0.5 * scale, slabW)
	slab.Position = Vector3.new(centerX, BUILDING_BASE + 0.25 * scale, centerZ)
	slab.Anchored = true
	slab.Material = Enum.Material.Concrete
	slab.Color = Color3.fromRGB(190, 190, 195)
	slab.Parent = model

	local floorY = BUILDING_BASE + 0.5 * scale

	-- Interior white floor
	local floor = Instance.new("Part")
	floor.Name = "InteriorFloor"
	floor.Size = Vector3.new(cubeD - 1, 0.2, cubeW - 1)
	floor.Position = Vector3.new(centerX, floorY + 0.1, centerZ)
	floor.Anchored = true
	floor.CanCollide = false
	floor.Material = Enum.Material.SmoothPlastic
	floor.Color = Color3.fromRGB(245, 245, 250)
	floor:SetAttribute("ThemeRole", "shop_floor")
	floor:SetAttribute("BaseColor", floor.Color)
	floor.Parent = model

	-- 4 corner posts
	local postThick = 0.5 * scale
	local postH = cubeH
	for dx = -1, 1, 2 do
		for dz = -1, 1, 2 do
			local post = Instance.new("Part")
			post.Name = "CornerPost"
			post.Size = Vector3.new(postThick, postH, postThick)
			post.Position = Vector3.new(
				centerX + dx * (cubeD / 2 - postThick / 2),
				floorY + postH / 2,
				centerZ + dz * (cubeW / 2 - postThick / 2)
			)
			post.Anchored = true
			post.Material = Enum.Material.DiamondPlate
			post.Color = Color3.fromRGB(160, 160, 165)
			post:SetAttribute("ThemeRole", "shop_mullion")
			post:SetAttribute("BaseColor", post.Color)
			post.Parent = model
		end
	end

	-- Glass walls helper
	local mullionThick = 0.3 * scale
	local midY = floorY + cubeH / 2
	local glassColor = Color3.fromRGB(200, 230, 255)

	local function buildWall(axis, faceCoord, wallWidth, panelCount)
		local pw = (wallWidth - postThick * 2 - mullionThick * (panelCount - 1)) / panelCount
		local startOffset = -wallWidth / 2 + postThick + pw / 2

		for row = 0, 1 do
			local rowY = floorY + mullionThick / 2 + (cubeH - mullionThick) / 4 + row * ((cubeH - mullionThick) / 2 + mullionThick)
			local panelH = (cubeH - mullionThick) / 2

			for col = 0, panelCount - 1 do
				local offset = startOffset + col * (pw + mullionThick)
				local panel = Instance.new("Part")
				panel.Name = "GlassPanel"
				if axis == "x" then
					panel.Size = Vector3.new(0.2, panelH, pw)
					panel.Position = Vector3.new(faceCoord, rowY, centerZ + offset)
				else
					panel.Size = Vector3.new(pw, panelH, 0.2)
					panel.Position = Vector3.new(centerX + offset, rowY, faceCoord)
				end
				panel.Anchored = true
				panel.CanCollide = false
				panel.Material = Enum.Material.Glass
				panel.Color = glassColor
				panel.Transparency = 0.6
				panel:SetAttribute("ThemeRole", "shop_glass")
				panel:SetAttribute("BaseColor", glassColor)
				panel.Parent = model
			end

			if row == 0 then
				local hMullion = Instance.new("Part")
				hMullion.Name = "HMullion"
				if axis == "x" then
					hMullion.Size = Vector3.new(mullionThick, mullionThick, wallWidth - postThick * 2)
					hMullion.Position = Vector3.new(faceCoord, midY, centerZ)
				else
					hMullion.Size = Vector3.new(wallWidth - postThick * 2, mullionThick, mullionThick)
					hMullion.Position = Vector3.new(centerX, midY, faceCoord)
				end
				hMullion.Anchored = true
				hMullion.CanCollide = false
				hMullion.Material = Enum.Material.DiamondPlate
				hMullion.Color = Color3.fromRGB(160, 160, 165)
				hMullion:SetAttribute("ThemeRole", "shop_mullion")
				hMullion:SetAttribute("BaseColor", hMullion.Color)
				hMullion.Parent = model
			end
		end

		for col = 1, panelCount - 1 do
			local pw2 = (wallWidth - postThick * 2 - mullionThick * (panelCount - 1)) / panelCount
			local offset = -wallWidth / 2 + postThick + (col - 1) * (pw2 + mullionThick) + pw2 + mullionThick / 2
			local vMullion = Instance.new("Part")
			vMullion.Name = "VMullion"
			if axis == "x" then
				vMullion.Size = Vector3.new(mullionThick, cubeH, mullionThick)
				vMullion.Position = Vector3.new(faceCoord, floorY + cubeH / 2, centerZ + offset)
			else
				vMullion.Size = Vector3.new(mullionThick, cubeH, mullionThick)
				vMullion.Position = Vector3.new(centerX + offset, floorY + cubeH / 2, faceCoord)
			end
			vMullion.Anchored = true
			vMullion.CanCollide = false
			vMullion.Material = Enum.Material.DiamondPlate
			vMullion.Color = Color3.fromRGB(160, 160, 165)
			vMullion:SetAttribute("ThemeRole", "shop_mullion")
			vMullion:SetAttribute("BaseColor", vMullion.Color)
			vMullion.Parent = model
		end
	end

	-- All 4 glass walls
	buildWall("x", centerX - cubeD / 2, cubeW, 4)
	buildWall("x", centerX + cubeD / 2, cubeW, 4)
	buildWall("z", centerZ - cubeW / 2, cubeD, 4)
	buildWall("z", centerZ + cubeW / 2, cubeD, 4)

	-- Flat roof
	local roof = Instance.new("Part")
	roof.Name = "Roof"
	roof.Size = Vector3.new(cubeD + 0.4, 0.4 * scale, cubeW + 0.4)
	roof.Position = Vector3.new(centerX, floorY + cubeH + 0.2 * scale, centerZ)
	roof.Anchored = true
	roof.Material = Enum.Material.DiamondPlate
	roof.Color = Color3.fromRGB(170, 170, 175)
	roof:SetAttribute("ThemeRole", "shop_roof")
	roof:SetAttribute("BaseColor", roof.Color)
	roof.Parent = model

	-- Interior display tables (2×2 grid)
	local tableH = 3 * scale
	local tableW = 10 * scale
	local tableD = 2.5 * scale
	for row = -1, 1, 2 do
		for col = -1, 1, 2 do
			local tbl = Instance.new("Part")
			tbl.Name = "DisplayTable"
			tbl.Size = Vector3.new(tableD, tableH, tableW)
			tbl.Position = Vector3.new(centerX + row * 8 * scale, floorY + tableH / 2, centerZ + col * 8 * scale)
			tbl.Anchored = true
			tbl.Material = Enum.Material.SmoothPlastic
			tbl.Color = Color3.fromRGB(240, 240, 245)
			tbl:SetAttribute("ThemeRole", "shop_floor")
			tbl:SetAttribute("BaseColor", tbl.Color)
			tbl.Parent = model

			for d = -1.5, 1.5, 1 do
				local device = Instance.new("Part")
				device.Name = "Device"
				device.Size = Vector3.new(1.2 * scale, 0.15 * scale, 0.8 * scale)
				device.Position = Vector3.new(
					centerX + row * 8 * scale,
					floorY + tableH + 0.075 * scale,
					centerZ + col * 8 * scale + d * 2.2 * scale
				)
				device.Anchored = true
				device.CanCollide = false
				device.Material = Enum.Material.Neon
				device.Color = Color3.fromRGB(255, 255, 255)
				device.Parent = model
			end
		end
	end

	-- Ceiling light
	local ceilingLight = Instance.new("Part")
	ceilingLight.Name = "CeilingLight"
	ceilingLight.Size = Vector3.new(cubeD * 0.6, 0.3, cubeW * 0.6)
	ceilingLight.Position = Vector3.new(centerX, floorY + cubeH - 0.3, centerZ)
	ceilingLight.Anchored = true
	ceilingLight.CanCollide = false
	ceilingLight.Material = Enum.Material.Neon
	ceilingLight.Color = Color3.fromRGB(255, 255, 255)
	ceilingLight:SetAttribute("ThemeRole", "shop_ceiling")
	ceilingLight:SetAttribute("BaseColor", ceilingLight.Color)
	ceilingLight.Parent = model

	local pointLight = Instance.new("PointLight")
	pointLight.Color = Color3.fromRGB(255, 255, 255)
	pointLight.Brightness = 0.8
	pointLight.Range = 28
	pointLight.Parent = ceilingLight

	-- Logo on front face (+Z)
	local logoSize = 14 * scale
	local logoPart = Instance.new("Part")
	logoPart.Name = "LogoGlow"
	logoPart.Size = Vector3.new(logoSize, logoSize, 0.4)
	logoPart.Position = Vector3.new(centerX, floorY + cubeH * 0.62, centerZ + cubeW / 2 + 0.25)
	logoPart.Anchored = true
	logoPart.CanCollide = false
	logoPart.Material = Enum.Material.SmoothPlastic
	logoPart.Color = Color3.fromRGB(255, 255, 255)
	logoPart.Transparency = 1
	logoPart.Parent = model

	local logoGlow = Instance.new("PointLight")
	logoGlow.Color = Color3.fromRGB(255, 255, 255)
	logoGlow.Brightness = 1.2
	logoGlow.Range = 16
	logoGlow.Parent = logoPart

	local logoGui = Instance.new("SurfaceGui")
	logoGui.Name = "LogoGui"
	logoGui.Face = Enum.NormalId.Back
	logoGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	logoGui.PixelsPerStud = 50
	logoGui.LightInfluence = 0
	logoGui.Parent = logoPart

	local logoImage = Instance.new("ImageLabel")
	logoImage.Name = "Logo"
	logoImage.Size = UDim2.new(1, 0, 1, 0)
	logoImage.BackgroundTransparency = 1
	logoImage.Image = "rbxassetid://73932591058200"
	logoImage.ImageColor3 = Color3.fromRGB(255, 255, 255)
	logoImage.ScaleType = Enum.ScaleType.Fit
	logoImage.Parent = logoGui

	if options.parent then
		model.Parent = options.parent
	end

	return model
end

--------------------------------------------------------------------------------
-- createParkingGarage(centerX, centerZ, options)
-- Multi-level concrete parking structure: 3 floors, open-air with columns,
-- half-walls, ramps between floors, PARKING sign on front (+Z).
-- 40W × 34D studs.
-- options.scale: number (default 1)
-- options.parent: Instance to parent to
-- Returns: Model
--------------------------------------------------------------------------------

function AssetLibrary.createParkingGarage(centerX, centerZ, options)
	options = options or {}
	local scale = options.scale or 1

	local model = Instance.new("Model")
	model.Name = "ParkingGarage"

	local garageW = 40 * scale
	local garageD = 34 * scale
	local floors = 3
	local floorH = 8 * scale
	local totalH = floors * floorH

	-- Floor slabs (ground + each level + roof)
	for f = 0, floors do
		local slabY = BUILDING_BASE + f * floorH
		local slab = Instance.new("Part")
		slab.Name = "GarageFloor_" .. f
		slab.Size = Vector3.new(garageW, 0.6, garageD)
		slab.Position = Vector3.new(centerX, slabY, centerZ)
		slab.Anchored = true
		slab.Material = Enum.Material.Concrete
		slab.Color = Color3.fromRGB(140, 135, 130)
		slab:SetAttribute("ThemeRole", "building_body")
		slab:SetAttribute("BaseColor", slab.Color)
		slab:SetAttribute("BaseMaterial", "Concrete")
		slab.Parent = model
	end

	-- Columns (4×4 grid)
	local colSpacingX = garageW / 3
	local colSpacingZ = garageD / 3
	for ix = 0, 3 do
		for iz = 0, 3 do
			local colX = centerX - garageW / 2 + ix * colSpacingX
			local colZ = centerZ - garageD / 2 + iz * colSpacingZ
			local col = Instance.new("Part")
			col.Name = "GarageColumn"
			col.Size = Vector3.new(1.2 * scale, totalH, 1.2 * scale)
			col.Position = Vector3.new(colX, BUILDING_BASE + totalH / 2, colZ)
			col.Anchored = true
			col.Material = Enum.Material.Concrete
			col.Color = Color3.fromRGB(160, 155, 150)
			col.Parent = model
		end
	end

	-- Half-walls on all 4 edges per floor
	for f = 0, floors - 1 do
		local wallY = BUILDING_BASE + f * floorH + floorH * 0.3
		local wallH = floorH * 0.4

		-- Front (+Z) — low barrier
		local front = Instance.new("Part")
		front.Name = "GarageWall"
		front.Size = Vector3.new(garageW, wallH, 0.5)
		front.Position = Vector3.new(centerX, wallY, centerZ + garageD / 2)
		front.Anchored = true
		front.Material = Enum.Material.Concrete
		front.Color = Color3.fromRGB(130, 125, 120)
		front.Parent = model

		-- Back (-Z) — full height
		local back = Instance.new("Part")
		back.Name = "GarageWall"
		back.Size = Vector3.new(garageW, floorH, 0.5)
		back.Position = Vector3.new(centerX, BUILDING_BASE + f * floorH + floorH / 2, centerZ - garageD / 2)
		back.Anchored = true
		back.Material = Enum.Material.Concrete
		back.Color = Color3.fromRGB(120, 115, 110)
		back.Parent = model

		-- Side walls
		for _, s in ipairs({ -1, 1 }) do
			local sideWall = Instance.new("Part")
			sideWall.Name = "GarageWall"
			sideWall.Size = Vector3.new(0.5, wallH, garageD)
			sideWall.Position = Vector3.new(centerX + s * garageW / 2, wallY, centerZ)
			sideWall.Anchored = true
			sideWall.Material = Enum.Material.Concrete
			sideWall.Color = Color3.fromRGB(130, 125, 120)
			sideWall.Parent = model
		end
	end

	-- Ramps between floors (along back -Z side)
	local rampW = 8 * scale
	local rampLen = garageD * 0.8
	for f = 0, floors - 2 do
		local rampStartY = BUILDING_BASE + f * floorH + 0.3
		local rampEndY = BUILDING_BASE + (f + 1) * floorH + 0.3
		local rampMidY = (rampStartY + rampEndY) / 2
		local rampAngle = math.atan2(floorH, rampLen)
		local rampHyp = math.sqrt(rampLen * rampLen + floorH * floorH)

		local ramp = Instance.new("Part")
		ramp.Name = "GarageRamp"
		ramp.Size = Vector3.new(rampW, 0.5, rampHyp)
		local rampX = centerX - garageW / 2 + rampW / 2 + 2
		local rampSign = (f % 2 == 0) and 1 or -1
		ramp.CFrame = CFrame.new(rampX, rampMidY, centerZ + rampSign * 2)
			* CFrame.Angles(rampSign * rampAngle, 0, 0)
		ramp.Anchored = true
		ramp.Material = Enum.Material.Concrete
		ramp.Color = Color3.fromRGB(150, 145, 140)
		ramp.Parent = model
	end

	-- PARKING sign on front (+Z face)
	local signPart = Instance.new("Part")
	signPart.Name = "ParkingSign"
	signPart.Size = Vector3.new(12 * scale, 3 * scale, 0.5)
	signPart.Position = Vector3.new(centerX, BUILDING_BASE + totalH - 2, centerZ + garageD / 2 + 0.3)
	signPart.Anchored = true
	signPart.Material = Enum.Material.Neon
	signPart.Color = Color3.fromRGB(50, 200, 255)
	signPart:SetAttribute("ThemeRole", "building_neon")
	signPart:SetAttribute("BaseColor", signPart.Color)
	signPart:SetAttribute("BaseMaterial", "Neon")
	signPart.Parent = model

	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Back
	gui.Parent = signPart
	local txt = Instance.new("TextLabel")
	txt.Size = UDim2.new(1, 0, 1, 0)
	txt.BackgroundTransparency = 1
	txt.Font = Enum.Font.GothamBold
	txt.Text = "PARKING"
	txt.TextColor3 = Color3.new(1, 1, 1)
	txt.TextScaled = true
	txt.Parent = gui

	if options.parent then
		model.Parent = options.parent
	end

	return model
end

--------------------------------------------------------------------------------
-- WAREHOUSE SPECS
-- 2 variants: "logistics" (warm amber) and "freight" (cool cyan)
-- 38W × 30D × 16H studs, loading dock, shipping containers, pallets
--------------------------------------------------------------------------------

local WAREHOUSE_SPECS = {
	{
		name = "logistics",
		bodyMat = Enum.Material.DiamondPlate, bodyColor = Color3.fromRGB(95, 90, 85),
		roofColor = Color3.fromRGB(70, 67, 63),
		signText = "GLOBAL LOGISTICS", signColor = Color3.fromRGB(255, 180, 60),
		bayCount = 3,
		containers = {
			{ color = Color3.fromRGB(180, 40, 40) },
			{ color = Color3.fromRGB(40, 80, 160) },
			{ color = Color3.fromRGB(50, 130, 60) },
		},
	},
	{
		name = "freight",
		bodyMat = Enum.Material.Metal, bodyColor = Color3.fromRGB(90, 95, 100),
		roofColor = Color3.fromRGB(65, 70, 75),
		signText = "FREIGHT DEPOT", signColor = Color3.fromRGB(60, 200, 255),
		bayCount = 4,
		containers = {
			{ color = Color3.fromRGB(200, 170, 40) },
			{ color = Color3.fromRGB(210, 120, 40) },
			{ color = Color3.fromRGB(130, 130, 135) },
		},
	},
}

--------------------------------------------------------------------------------
-- createWarehouse(centerX, centerZ, options)
-- options.variant: "logistics" or "freight" or 1-2 (default random)
-- options.scale: number (default 1)
-- options.parent: Instance to parent to
-- Returns: Model
--------------------------------------------------------------------------------

function AssetLibrary.createWarehouse(centerX, centerZ, options)
	options = options or {}
	local scale = options.scale or 1

	-- Resolve spec
	local spec
	if type(options.variant) == "number" then
		spec = WAREHOUSE_SPECS[math.clamp(options.variant, 1, #WAREHOUSE_SPECS)]
	elseif type(options.variant) == "string" then
		for _, s in ipairs(WAREHOUSE_SPECS) do
			if s.name == options.variant then spec = s; break end
		end
		spec = spec or WAREHOUSE_SPECS[math.random(1, #WAREHOUSE_SPECS)]
	else
		spec = WAREHOUSE_SPECS[math.random(1, #WAREHOUSE_SPECS)]
	end

	local model = Instance.new("Model")
	model.Name = "Warehouse"

	local bodyW = 38 * scale
	local bodyH = 16 * scale
	local bodyD = 30 * scale

	-- Main body
	local body = Instance.new("Part")
	body.Name = "WarehouseBody"
	body.Size = Vector3.new(bodyW, bodyH, bodyD)
	body.Position = Vector3.new(centerX, BUILDING_BASE + bodyH / 2, centerZ)
	body.Anchored = true
	body.Material = spec.bodyMat
	body.Color = spec.bodyColor
	body:SetAttribute("ThemeRole", "building_body")
	body:SetAttribute("BaseColor", spec.bodyColor)
	body:SetAttribute("BaseMaterial", spec.bodyMat.Name)
	body.Parent = model

	-- Roof
	local roof = Instance.new("Part")
	roof.Name = "WarehouseRoof"
	roof.Size = Vector3.new(40 * scale, 0.6 * scale, 32 * scale)
	roof.Position = Vector3.new(centerX, BUILDING_BASE + bodyH + 0.3 * scale, centerZ)
	roof.Anchored = true
	roof.Material = Enum.Material.DiamondPlate
	roof.Color = spec.roofColor
	roof:SetAttribute("ThemeRole", "building_roof")
	roof:SetAttribute("BaseColor", spec.roofColor)
	roof:SetAttribute("BaseMaterial", "DiamondPlate")
	roof.Parent = model

	-- Roof vents
	for i = 1, 2 do
		local ventZ = centerZ + (i == 1 and -8 or 8) * scale
		local vent = Instance.new("Part")
		vent.Name = "RoofVent"
		vent.Size = Vector3.new(3 * scale, 2.5 * scale, 3 * scale)
		vent.Position = Vector3.new(centerX + 5 * scale, BUILDING_BASE + bodyH + 0.6 * scale + 1.25 * scale, ventZ)
		vent.Anchored = true
		vent.Material = Enum.Material.Metal
		vent.Color = Color3.fromRGB(170, 170, 175)
		vent.Parent = model
	end

	-- Loading dock on front (+Z)
	local dockW = 5 * scale
	local dockH = 3.5 * scale
	local dockD = 26 * scale
	local dockZ = centerZ + bodyD / 2 + dockW / 2

	local dock = Instance.new("Part")
	dock.Name = "LoadingDock"
	dock.Size = Vector3.new(dockD, dockH, dockW)
	dock.Position = Vector3.new(centerX, BUILDING_BASE + dockH / 2, dockZ)
	dock.Anchored = true
	dock.Material = Enum.Material.Concrete
	dock.Color = Color3.fromRGB(140, 135, 130)
	dock.Parent = model

	-- Yellow safety strip
	local strip = Instance.new("Part")
	strip.Name = "DockStrip"
	strip.Size = Vector3.new(dockD, 0.5 * scale, 0.3 * scale)
	strip.Position = Vector3.new(centerX, BUILDING_BASE + dockH + 0.25 * scale, dockZ + dockW / 2 - 0.15)
	strip.Anchored = true
	strip.CanCollide = false
	strip.Material = Enum.Material.Neon
	strip.Color = Color3.fromRGB(220, 190, 0)
	strip.Parent = model

	-- Bay doors on front wall (+Z face)
	local bayFaceZ = centerZ + bodyD / 2 + 0.15
	local bayW = 5 * scale
	local bayH = 7 * scale
	local baySpacing = dockD / (spec.bayCount + 1)

	for i = 1, spec.bayCount do
		local bayX = centerX - dockD / 2 + i * baySpacing

		local door = Instance.new("Part")
		door.Name = "BayDoor"
		door.Size = Vector3.new(bayW, bayH, 0.3 * scale)
		door.Position = Vector3.new(bayX, BUILDING_BASE + dockH + bayH / 2, bayFaceZ)
		door.Anchored = true
		door.Material = Enum.Material.CorrodedMetal
		door.Color = Color3.fromRGB(90, 65, 45)
		door.Parent = model

		local hazard = Instance.new("Part")
		hazard.Name = "HazardStrip"
		hazard.Size = Vector3.new(5.4 * scale, 0.5 * scale, 0.35 * scale)
		hazard.Position = Vector3.new(bayX, BUILDING_BASE + dockH + bayH + 0.25 * scale, bayFaceZ + 0.05)
		hazard.Anchored = true
		hazard.CanCollide = false
		hazard.Material = Enum.Material.Neon
		hazard.Color = Color3.fromRGB(220, 190, 0)
		hazard.Parent = model
	end

	-- Safety bollards
	local bollardDiam = 0.8 * scale
	local bollardH = 2.5 * scale
	local bollardSpacing = dockD / 5
	for i = 1, 4 do
		local bollardX = centerX - dockD / 2 + i * bollardSpacing
		local bollardZ = dockZ + dockW / 2 + 0.8 * scale

		local bollard = Instance.new("Part")
		bollard.Name = "SafetyBollard"
		bollard.Shape = Enum.PartType.Cylinder
		bollard.Size = Vector3.new(bollardH, bollardDiam, bollardDiam)
		bollard.CFrame = CFrame.new(bollardX, BUILDING_BASE + bollardH / 2, bollardZ) * CFrame.Angles(0, 0, math.rad(90))
		bollard.Anchored = true
		bollard.Material = Enum.Material.SmoothPlastic
		bollard.Color = Color3.fromRGB(220, 190, 0)
		bollard.Parent = model
	end

	-- Neon sign on front (+Z face, upper)
	local signW = 14 * scale
	local signH = 2.5 * scale
	local signPart = Instance.new("Part")
	signPart.Name = "WarehouseSign"
	signPart.Size = Vector3.new(signW, signH, 0.4 * scale)
	signPart.Position = Vector3.new(centerX, BUILDING_BASE + bodyH - 3.5 * scale, centerZ + bodyD / 2 + 0.3)
	signPart.Anchored = true
	signPart.Material = Enum.Material.Neon
	signPart.Color = spec.signColor
	signPart:SetAttribute("ThemeRole", "building_neon")
	signPart:SetAttribute("BaseColor", spec.signColor)
	signPart:SetAttribute("BaseMaterial", "Neon")
	signPart.Parent = model

	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Back
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

	-- Shipping containers (behind building, -Z side)
	local containerBaseZ = centerZ - bodyD / 2 - 2 * scale
	local containerH = 5 * scale
	local containerD = 5 * scale

	for i = 1, 3 do
		local cW = 11 * scale
		local cZ, cY
		if i <= 2 then
			cZ = containerBaseZ - (i - 1) * (containerD + 1 * scale)
			cY = BUILDING_BASE + containerH / 2
		else
			cZ = containerBaseZ
			cY = BUILDING_BASE + containerH + containerH / 2
		end

		local container = Instance.new("Part")
		container.Name = "ShippingContainer"
		container.Size = Vector3.new(cW, containerH, containerD)
		container.Position = Vector3.new(centerX, cY, cZ)
		container.Anchored = true
		container.Material = Enum.Material.DiamondPlate
		container.Color = spec.containers[i].color
		container.Parent = model

		local ridge = Instance.new("Part")
		ridge.Name = "ContainerRidge"
		ridge.Size = Vector3.new(cW + 0.2, 0.4 * scale, containerD + 0.2)
		ridge.Position = Vector3.new(centerX, cY + containerH / 2 + 0.2 * scale, cZ)
		ridge.Anchored = true
		ridge.Material = Enum.Material.Metal
		ridge.Color = Color3.fromRGB(60, 60, 65)
		ridge.Parent = model
	end

	-- Pallets + crates (+X side)
	local palletBaseX = centerX + bodyW / 2 + 2 * scale
	for i = 1, 3 do
		local palletX = palletBaseX + (i - 1) * 4 * scale

		local pallet = Instance.new("Part")
		pallet.Name = "Pallet"
		pallet.Size = Vector3.new(2.5 * scale, 0.3 * scale, 2.5 * scale)
		pallet.Position = Vector3.new(palletX, BUILDING_BASE + 0.15 * scale, centerZ)
		pallet.Anchored = true
		pallet.Material = Enum.Material.WoodPlanks
		pallet.Color = Color3.fromRGB(160, 120, 70)
		pallet.Parent = model

		local crateH = (1.5 + i * 0.5) * scale
		local crate = Instance.new("Part")
		crate.Name = "Crate"
		crate.Size = Vector3.new(2.0 * scale, crateH, 2.0 * scale)
		crate.Position = Vector3.new(palletX, BUILDING_BASE + 0.3 * scale + crateH / 2, centerZ)
		crate.Anchored = true
		crate.Material = Enum.Material.WoodPlanks
		crate.Color = Color3.fromRGB(140, 100, 55)
		crate.Parent = model
	end

	-- Windows on all 4 faces (sparse, industrial)
	local litColor = Color3.fromRGB(200, 170, 80)
	addWindowsToFace(model, "z", centerZ + bodyD / 2 + 0.05, centerX, bodyW, BUILDING_BASE, 2, bodyH / 2, 2.0, 1.8, 3.0, litColor, 0.20)
	addWindowsToFace(model, "z", centerZ - bodyD / 2 - 0.05, centerX, bodyW, BUILDING_BASE, 2, bodyH / 2, 2.0, 1.8, 3.0, litColor, 0.15)
	addWindowsToFace(model, "x", centerX + bodyW / 2 + 0.05, centerZ, bodyD, BUILDING_BASE, 2, bodyH / 2, 2.0, 1.8, 3.0, litColor, 0.15)
	addWindowsToFace(model, "x", centerX - bodyW / 2 - 0.05, centerZ, bodyD, BUILDING_BASE, 2, bodyH / 2, 2.0, 1.8, 3.0, litColor, 0.15)

	if options.parent then
		model.Parent = options.parent
	end

	return model
end

function AssetLibrary.getWarehouseVariants()
	return { "logistics", "freight" }
end

--------------------------------------------------------------------------------
-- FACTORY SPECS
-- 2 variants: "industrial" (warm amber, 3 stacks) and "factory" (cool cyan, 2 stacks)
-- 36W × 30D × 22H studs, smokestacks, loading bays, hazard stripes
--------------------------------------------------------------------------------

local FACTORY_SPECS = {
	{
		name = "industrial",
		bodyMat = Enum.Material.DiamondPlate, bodyColor = Color3.fromRGB(85, 85, 90),
		roofColor = Color3.fromRGB(65, 65, 70),
		signText = "INDUSTRIAL WORKS", signColor = Color3.fromRGB(255, 180, 60),
		stacks = 3,
		containers = {
			{ color = Color3.fromRGB(180, 40, 40), w = 12 },
			{ color = Color3.fromRGB(40, 80, 160), w = 10 },
			{ color = Color3.fromRGB(50, 130, 60), w = 11 },
		},
	},
	{
		name = "factory",
		bodyMat = Enum.Material.Metal, bodyColor = Color3.fromRGB(95, 95, 100),
		roofColor = Color3.fromRGB(70, 70, 75),
		signText = "FACTORY CO.", signColor = Color3.fromRGB(60, 200, 255),
		stacks = 2,
		containers = {
			{ color = Color3.fromRGB(200, 170, 40), w = 11 },
			{ color = Color3.fromRGB(210, 120, 40), w = 10 },
			{ color = Color3.fromRGB(130, 130, 135), w = 12 },
		},
	},
}

--------------------------------------------------------------------------------
-- createFactory(centerX, centerZ, options)
-- options.variant: "industrial" or "factory" or 1-2 (default random)
-- options.scale: number (default 1)
-- options.parent: Instance to parent to
-- Returns: Model
--------------------------------------------------------------------------------

function AssetLibrary.createFactory(centerX, centerZ, options)
	options = options or {}
	local scale = options.scale or 1

	local spec
	if type(options.variant) == "number" then
		spec = FACTORY_SPECS[math.clamp(options.variant, 1, #FACTORY_SPECS)]
	elseif type(options.variant) == "string" then
		for _, s in ipairs(FACTORY_SPECS) do
			if s.name == options.variant then spec = s; break end
		end
		spec = spec or FACTORY_SPECS[math.random(1, #FACTORY_SPECS)]
	else
		spec = FACTORY_SPECS[math.random(1, #FACTORY_SPECS)]
	end

	local model = Instance.new("Model")
	model.Name = "Factory"

	local bodyW = 36 * scale
	local bodyH = 22 * scale
	local bodyD = 30 * scale

	-- Main body
	local body = Instance.new("Part")
	body.Name = "FactoryBody"
	body.Size = Vector3.new(bodyW, bodyH, bodyD)
	body.Position = Vector3.new(centerX, BUILDING_BASE + bodyH / 2, centerZ)
	body.Anchored = true
	body.Material = spec.bodyMat
	body.Color = spec.bodyColor
	body:SetAttribute("ThemeRole", "building_body")
	body:SetAttribute("BaseColor", spec.bodyColor)
	body:SetAttribute("BaseMaterial", spec.bodyMat.Name)
	body.Parent = model

	-- Roof
	local roof = Instance.new("Part")
	roof.Name = "FactoryRoof"
	roof.Size = Vector3.new(bodyW + 1 * scale, 0.8 * scale, bodyD + 1 * scale)
	roof.Position = Vector3.new(centerX, BUILDING_BASE + bodyH + 0.4 * scale, centerZ)
	roof.Anchored = true
	roof.Material = Enum.Material.DiamondPlate
	roof.Color = spec.roofColor
	roof:SetAttribute("ThemeRole", "building_roof")
	roof:SetAttribute("BaseColor", spec.roofColor)
	roof:SetAttribute("BaseMaterial", "DiamondPlate")
	roof.Parent = model

	-- Corner columns with hazard stripes on front pair
	local colSize = 1.5 * scale
	local colH = bodyH + 1 * scale
	local halfW = bodyW / 2 - colSize / 2
	local halfD = bodyD / 2 - colSize / 2
	for _, ox in ipairs({ -halfW, halfW }) do
		for _, oz in ipairs({ -halfD, halfD }) do
			local col = Instance.new("Part")
			col.Name = "FactoryColumn"
			col.Size = Vector3.new(colSize, colH, colSize)
			col.Position = Vector3.new(centerX + ox, BUILDING_BASE + colH / 2, centerZ + oz)
			col.Anchored = true
			col.Material = Enum.Material.Concrete
			col.Color = Color3.fromRGB(120, 120, 125)
			col.Parent = model
		end
	end

	-- Hazard stripes on front (+Z) columns
	for _, ox in ipairs({ -halfW, halfW }) do
		for band = 0, 3 do
			local stripe = Instance.new("Part")
			stripe.Name = "HazardStripe"
			stripe.Size = Vector3.new(colSize + 0.1, 0.8 * scale, colSize + 0.1)
			stripe.Position = Vector3.new(centerX + ox, BUILDING_BASE + 2 * scale + band * 2.5 * scale, centerZ + halfD)
			stripe.Anchored = true
			stripe.CanCollide = false
			stripe.Material = Enum.Material.SmoothPlastic
			stripe.Color = (band % 2 == 0) and Color3.fromRGB(220, 190, 0) or Color3.fromRGB(30, 30, 30)
			stripe.Parent = model
		end
	end

	-- Smokestacks on roof (toward -Z back)
	local stackDiam = 3 * scale
	local stackH = 14 * scale
	local stackTopY = BUILDING_BASE + bodyH + 0.8 * scale + stackH / 2
	local stackSpacing = bodyD / (spec.stacks + 1)
	local smokeData = {}

	for i = 1, spec.stacks do
		local stackZ = centerZ - bodyD / 2 + i * stackSpacing
		local stackX = centerX - bodyW / 2 + 5 * scale

		local stack = Instance.new("Part")
		stack.Name = "Smokestack"
		stack.Shape = Enum.PartType.Cylinder
		stack.Size = Vector3.new(stackH, stackDiam, stackDiam)
		stack.CFrame = CFrame.new(stackX, stackTopY, stackZ) * CFrame.Angles(0, 0, math.rad(90))
		stack.Anchored = true
		stack.Material = Enum.Material.Metal
		stack.Color = Color3.fromRGB(80, 80, 85)
		stack.Parent = model

		-- Smoke effect
		local smokePoint = Instance.new("Part")
		smokePoint.Name = "SmokePoint"
		smokePoint.Size = Vector3.new(1, 1, 1)
		smokePoint.Position = Vector3.new(stackX, BUILDING_BASE + bodyH + 0.8 * scale + stackH, stackZ)
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

		table.insert(smokeData, smokePoint)
	end

	-- Loading bay doors on front (+Z face)
	local bayFaceZ = centerZ + bodyD / 2 + 0.15
	for _, bayOff in ipairs({ -5 * scale, 5 * scale }) do
		local door = Instance.new("Part")
		door.Name = "LoadingBayDoor"
		door.Size = Vector3.new(6 * scale, 8 * scale, 0.3 * scale)
		door.Position = Vector3.new(centerX + bayOff, BUILDING_BASE + 4 * scale, bayFaceZ)
		door.Anchored = true
		door.Material = Enum.Material.SmoothPlastic
		door.Color = Color3.fromRGB(50, 50, 55)
		door.Parent = model

		local hazardStrip = Instance.new("Part")
		hazardStrip.Name = "HazardStrip"
		hazardStrip.Size = Vector3.new(7 * scale, 0.6 * scale, 0.35 * scale)
		hazardStrip.Position = Vector3.new(centerX + bayOff, BUILDING_BASE + 8.3 * scale, bayFaceZ + 0.05)
		hazardStrip.Anchored = true
		hazardStrip.CanCollide = false
		hazardStrip.Material = Enum.Material.Neon
		hazardStrip.Color = Color3.fromRGB(220, 190, 0)
		hazardStrip.Parent = model
	end

	-- Neon sign on front (+Z)
	local signW = 14 * scale
	local signH = 3 * scale
	local signPart = Instance.new("Part")
	signPart.Name = "FactorySign"
	signPart.Size = Vector3.new(signW, signH, 0.4 * scale)
	signPart.Position = Vector3.new(centerX, BUILDING_BASE + bodyH - 4 * scale, centerZ + bodyD / 2 + 0.3)
	signPart.Anchored = true
	signPart.Material = Enum.Material.Neon
	signPart.Color = spec.signColor
	signPart:SetAttribute("ThemeRole", "building_neon")
	signPart:SetAttribute("BaseColor", spec.signColor)
	signPart:SetAttribute("BaseMaterial", "Neon")
	signPart.Parent = model

	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Back
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

	-- Cargo containers (+X side)
	local containerBaseX = centerX + bodyW / 2 + 3 * scale
	for i, cSpec in ipairs(spec.containers) do
		local cW = cSpec.w * scale
		local cH = 5 * scale
		local cD = 5 * scale
		local cX = containerBaseX
		local cZ = centerZ + bodyD / 2 - 6 * scale - (i - 1) * 6 * scale
		local cY = BUILDING_BASE + cH / 2
		if i == 3 then
			cZ = centerZ + bodyD / 2 - 6 * scale
			cY = BUILDING_BASE + cH + cH / 2
		end

		local container = Instance.new("Part")
		container.Name = "CargoContainer"
		container.Size = Vector3.new(cW, cH, cD)
		container.Position = Vector3.new(cX, cY, cZ)
		container.Anchored = true
		container.Material = Enum.Material.DiamondPlate
		container.Color = cSpec.color
		container.Parent = model

		local ridge = Instance.new("Part")
		ridge.Name = "ContainerRidge"
		ridge.Size = Vector3.new(cW + 0.2, 0.4 * scale, cD + 0.2)
		ridge.Position = Vector3.new(cX, cY + cH / 2 + 0.2 * scale, cZ)
		ridge.Anchored = true
		ridge.Material = Enum.Material.Metal
		ridge.Color = Color3.fromRGB(60, 60, 65)
		ridge.Parent = model
	end

	-- Windows on all 4 faces (small, sparse, industrial)
	local litColor = Color3.fromRGB(200, 170, 80)
	addWindowsToFace(model, "z", centerZ + bodyD / 2 + 0.05, centerX, bodyW, BUILDING_BASE, 3, bodyH / 3, 2.0, 1.8, 3.0, litColor, 0.25)
	addWindowsToFace(model, "z", centerZ - bodyD / 2 - 0.05, centerX, bodyW, BUILDING_BASE, 3, bodyH / 3, 2.0, 1.8, 3.0, litColor, 0.15)
	addWindowsToFace(model, "x", centerX + bodyW / 2 + 0.05, centerZ, bodyD, BUILDING_BASE, 3, bodyH / 3, 2.0, 1.8, 3.0, litColor, 0.20)
	addWindowsToFace(model, "x", centerX - bodyW / 2 - 0.05, centerZ, bodyD, BUILDING_BASE, 3, bodyH / 3, 2.0, 1.8, 3.0, litColor, 0.20)

	if options.parent then
		model.Parent = options.parent
	end

	return model, { smokePoints = smokeData }
end

function AssetLibrary.getFactoryVariants()
	return { "industrial", "factory" }
end

--------------------------------------------------------------------------------
-- OFFICE BUILDING WALL COLORS (inlined from DecorUtils)
--------------------------------------------------------------------------------

local OFFICE_WALL_COLORS = {
	Color3.fromRGB(200, 190, 170), Color3.fromRGB(180, 170, 155),
	Color3.fromRGB(165, 120, 90),  Color3.fromRGB(210, 200, 185),
	Color3.fromRGB(155, 145, 135), Color3.fromRGB(190, 140, 100),
	Color3.fromRGB(220, 215, 205), Color3.fromRGB(145, 100, 80),
}

local OFFICE_WINDOW_COLORS = {
	Color3.fromRGB(255, 220, 140), Color3.fromRGB(200, 230, 255),
	Color3.fromRGB(255, 200, 100), Color3.fromRGB(180, 210, 255),
	Color3.fromRGB(255, 180, 120),
}

--------------------------------------------------------------------------------
-- createOffice(centerX, centerZ, options)
-- Mid-rise office (4-8 floors) with glass floor strips on all faces.
-- options.variant: "office" or "tower" (default "office")
--   office: 4-8 floors, 5.5 stud floor height, SmoothPlastic, glass strips
--   tower: 10-18 floors, 4.5 stud floor height, Metal, full windows + antenna
-- options.facadeWidth: studs (default random 18-26 office, 10-16 tower)
-- options.depth: studs (default random 14-20 office, 10-16 tower)
-- options.floors: number (default random per variant)
-- options.scale: number (default 1)
-- options.parent: Instance to parent to
-- Returns: Model
--------------------------------------------------------------------------------

function AssetLibrary.createOffice(centerX, centerZ, options)
	options = options or {}
	local scale = options.scale or 1
	local variant = options.variant or "office"
	local isTower = variant == "tower"

	local wallColor = pickRandom(OFFICE_WALL_COLORS)
	local windowColor = pickRandom(OFFICE_WINDOW_COLORS)

	local facadeLen, bDepth, floors, floorHeight, bodyMat

	if isTower then
		facadeLen = (options.facadeWidth or math.random(10, 16)) * scale
		bDepth = (options.depth or math.random(10, 16)) * scale
		floors = options.floors or math.random(10, 18)
		floorHeight = 4.5 * scale
		bodyMat = Enum.Material.Metal
	else
		facadeLen = (options.facadeWidth or math.random(18, 26)) * scale
		bDepth = (options.depth or math.random(14, 20)) * scale
		floors = options.floors or math.random(4, 8)
		floorHeight = 5.5 * scale
		bodyMat = Enum.Material.SmoothPlastic
	end

	local height = floors * floorHeight

	local building = Instance.new("Model")
	building.Name = isTower and "Building_Tower" or "Building_Office"

	-- Main body: facade along X, depth along Z
	local main = Instance.new("Part")
	main.Name = "Body"
	main.Size = Vector3.new(facadeLen, height, bDepth)
	main.Position = Vector3.new(centerX, BUILDING_BASE + height / 2, centerZ)
	main.Anchored = true
	main.Material = bodyMat
	main.Color = wallColor
	main:SetAttribute("ThemeRole", "building_body")
	main:SetAttribute("BaseColor", wallColor)
	main:SetAttribute("BaseMaterial", bodyMat.Name)
	main.Parent = building

	if isTower then
		-- Full windows on all 4 faces
		local winW = 2 * scale
		local winH = 2 * scale
		local winGap = 2 * scale
		local litChance = 0.7

		addWindowsToFace(building, "z", centerZ + bDepth / 2 + 0.2, centerX, facadeLen, BUILDING_BASE, floors, floorHeight, winW, winH, winGap, windowColor, litChance)
		addWindowsToFace(building, "z", centerZ - bDepth / 2 - 0.2, centerX, facadeLen, BUILDING_BASE, floors, floorHeight, winW, winH, winGap, windowColor, litChance)
		addWindowsToFace(building, "x", centerX + facadeLen / 2 + 0.2, centerZ, bDepth, BUILDING_BASE, floors, floorHeight, winW, winH, winGap, windowColor, litChance)
		addWindowsToFace(building, "x", centerX - facadeLen / 2 - 0.2, centerZ, bDepth, BUILDING_BASE, floors, floorHeight, winW, winH, winGap, windowColor, litChance)

		-- Antenna
		local antenna = Instance.new("Part")
		antenna.Name = "Antenna"
		antenna.Size = Vector3.new(0.5, 8 * scale, 0.5)
		antenna.Position = Vector3.new(centerX, BUILDING_BASE + height + 4 * scale, centerZ)
		antenna.Anchored = true
		antenna.Material = Enum.Material.Metal
		antenna.Color = Color3.fromRGB(80, 80, 85)
		antenna.Parent = building

		-- Blinking red light
		local light = Instance.new("Part")
		light.Name = "BeaconLight"
		light.Size = Vector3.new(1, 1, 1)
		light.Position = Vector3.new(centerX, BUILDING_BASE + height + 8 * scale + 0.5, centerZ)
		light.Anchored = true
		light.CanCollide = false
		light.Shape = Enum.PartType.Ball
		light.Material = Enum.Material.Neon
		light.Color = Color3.fromRGB(255, 0, 0)
		light.Parent = building
	else
		-- Glass strips on all 4 faces per floor
		for floor = 1, floors do
			local floorY = BUILDING_BASE + (floor - 0.5) * floorHeight
			local isLit = math.random() >= 0.2

			-- Front (+Z)
			local stripF = Instance.new("Part")
			stripF.Name = "GlassStrip"
			stripF.Size = Vector3.new(facadeLen * 0.9, floorHeight * 0.5, 0.5)
			stripF.Position = Vector3.new(centerX, floorY, centerZ + bDepth / 2 + 0.2)
			stripF.Anchored = true
			stripF.CanCollide = false
			stripF.Material = isLit and Enum.Material.Neon or Enum.Material.Glass
			stripF.Color = isLit and windowColor or Color3.fromRGB(30, 35, 45)
			stripF:SetAttribute("ThemeRole", isLit and "building_window_lit" or "building_window")
			stripF:SetAttribute("BaseColor", stripF.Color)
			stripF.Parent = building

			-- Back (-Z)
			local stripB = Instance.new("Part")
			stripB.Name = "GlassStrip"
			stripB.Size = Vector3.new(facadeLen * 0.9, floorHeight * 0.5, 0.5)
			stripB.Position = Vector3.new(centerX, floorY, centerZ - bDepth / 2 - 0.2)
			stripB.Anchored = true
			stripB.CanCollide = false
			stripB.Material = math.random() < 0.3 and Enum.Material.Glass or Enum.Material.Neon
			stripB.Color = stripB.Material == Enum.Material.Neon and windowColor or Color3.fromRGB(30, 35, 45)
			stripB:SetAttribute("ThemeRole", "building_window")
			stripB:SetAttribute("BaseColor", stripB.Color)
			stripB.Parent = building

			-- Left (-X)
			local stripL = Instance.new("Part")
			stripL.Name = "GlassStrip"
			stripL.Size = Vector3.new(0.5, floorHeight * 0.5, bDepth * 0.9)
			stripL.Position = Vector3.new(centerX - facadeLen / 2 - 0.2, floorY, centerZ)
			stripL.Anchored = true
			stripL.CanCollide = false
			stripL.Material = math.random() < 0.4 and Enum.Material.Glass or Enum.Material.Neon
			stripL.Color = stripL.Material == Enum.Material.Neon and windowColor or Color3.fromRGB(30, 35, 45)
			stripL:SetAttribute("ThemeRole", "building_window")
			stripL:SetAttribute("BaseColor", stripL.Color)
			stripL.Parent = building

			-- Right (+X)
			local stripR = Instance.new("Part")
			stripR.Name = "GlassStrip"
			stripR.Size = Vector3.new(0.5, floorHeight * 0.5, bDepth * 0.9)
			stripR.Position = Vector3.new(centerX + facadeLen / 2 + 0.2, floorY, centerZ)
			stripR.Anchored = true
			stripR.CanCollide = false
			stripR.Material = math.random() < 0.4 and Enum.Material.Glass or Enum.Material.Neon
			stripR.Color = stripR.Material == Enum.Material.Neon and windowColor or Color3.fromRGB(30, 35, 45)
			stripR:SetAttribute("ThemeRole", "building_window")
			stripR:SetAttribute("BaseColor", stripR.Color)
			stripR.Parent = building
		end
	end

	if options.parent then
		building.Parent = options.parent
	end

	return building
end

function AssetLibrary.getOfficeVariants()
	return { "office", "tower" }
end

--------------------------------------------------------------------------------
-- CONSTRUCTION SITE SPECS
-- 2 variants: "mega" (warm amber/orange) and "skyline" (cool cyan/yellow)
-- Partial structure + tower crane + scaffolding + ground props
--------------------------------------------------------------------------------

local CONSTRUCTION_SPECS = {
	{
		name = "mega",
		companyName = "MEGA BUILD CO.",
		signColor = Color3.fromRGB(255, 180, 40),
		craneColor = Color3.fromRGB(230, 120, 30),
		concreteColor = Color3.fromRGB(170, 160, 145),
		steelColor = Color3.fromRGB(80, 80, 90),
		rebarColor = Color3.fromRGB(220, 130, 50),
		scaffoldColor = Color3.fromRGB(160, 155, 140),
		barrierColor = Color3.fromRGB(255, 140, 30),
	},
	{
		name = "skyline",
		companyName = "SKYLINE CONSTRUCTION",
		signColor = Color3.fromRGB(60, 200, 230),
		craneColor = Color3.fromRGB(220, 190, 40),
		concreteColor = Color3.fromRGB(155, 155, 160),
		steelColor = Color3.fromRGB(75, 80, 95),
		rebarColor = Color3.fromRGB(200, 120, 40),
		scaffoldColor = Color3.fromRGB(150, 150, 155),
		barrierColor = Color3.fromRGB(255, 160, 40),
	},
}

--------------------------------------------------------------------------------
-- createConstructionSite(centerX, centerZ, options)
-- options.variant: "mega" or "skyline" or 1-2 (default random)
-- options.scale: number (default 1)
-- options.parent: Instance to parent to
-- Returns: Model, { craneBoom = Part, craneAnimData = table }
--------------------------------------------------------------------------------

function AssetLibrary.createConstructionSite(centerX, centerZ, options)
	options = options or {}
	local scale = options.scale or 1

	local spec
	if type(options.variant) == "number" then
		spec = CONSTRUCTION_SPECS[math.clamp(options.variant, 1, #CONSTRUCTION_SPECS)]
	elseif type(options.variant) == "string" then
		for _, s in ipairs(CONSTRUCTION_SPECS) do
			if s.name == options.variant then spec = s; break end
		end
		spec = spec or CONSTRUCTION_SPECS[math.random(1, #CONSTRUCTION_SPECS)]
	else
		spec = CONSTRUCTION_SPECS[math.random(1, #CONSTRUCTION_SPECS)]
	end

	local model = Instance.new("Model")
	model.Name = "ConstructionSite"

	-- ── PARTIALLY BUILT STRUCTURE (+X side) ──────────────────────────────
	local floorW = 16 * scale
	local floorD = 14 * scale
	local floorThick = 0.6 * scale
	local floorSpacing = 8 * scale
	local structX = centerX + 8 * scale

	-- 3 floor slabs
	for i = 0, 2 do
		local floorY = BUILDING_BASE + i * floorSpacing
		local slab = Instance.new("Part")
		slab.Name = "FloorSlab"
		slab.Size = Vector3.new(floorW, floorThick, floorD)
		slab.Position = Vector3.new(structX, floorY + floorThick / 2, centerZ)
		slab.Anchored = true
		slab.Material = Enum.Material.Concrete
		slab.Color = spec.concreteColor
		slab.Parent = model
	end

	-- 6 steel columns
	local colRadius = 0.5 * scale
	local colH = floorSpacing * 2 + floorThick
	local colPositions = {
		{ -floorW / 2 + 1.5 * scale, -floorD / 2 + 1.5 * scale },
		{  floorW / 2 - 1.5 * scale, -floorD / 2 + 1.5 * scale },
		{ -floorW / 2 + 1.5 * scale,  floorD / 2 - 1.5 * scale },
		{  floorW / 2 - 1.5 * scale,  floorD / 2 - 1.5 * scale },
		{  0, -floorD / 2 + 1.5 * scale },
		{  0,  floorD / 2 - 1.5 * scale },
	}
	for _, cp in ipairs(colPositions) do
		local col = Instance.new("Part")
		col.Name = "SteelColumn"
		col.Shape = Enum.PartType.Cylinder
		col.Size = Vector3.new(colH, colRadius * 2, colRadius * 2)
		col.CFrame = CFrame.new(structX + cp[1], BUILDING_BASE + colH / 2, centerZ + cp[2])
			* CFrame.Angles(0, 0, math.rad(90))
		col.Anchored = true
		col.Material = Enum.Material.Metal
		col.Color = spec.steelColor
		col.Parent = model
	end

	-- Rebar stubs on top floor
	local topFloorY = BUILDING_BASE + 2 * floorSpacing + floorThick
	local rebarH = 3 * scale
	for i = 1, 5 do
		local rebar = Instance.new("Part")
		rebar.Name = "Rebar"
		rebar.Shape = Enum.PartType.Cylinder
		rebar.Size = Vector3.new(rebarH, 0.2 * scale, 0.2 * scale)
		rebar.CFrame = CFrame.new(structX + (i - 3) * 3 * scale, topFloorY + rebarH / 2,
			centerZ + (math.random() - 0.5) * floorD * 0.6)
			* CFrame.Angles(0, 0, math.rad(90))
		rebar.Anchored = true
		rebar.Material = Enum.Material.Neon
		rebar.Color = spec.rebarColor
		rebar.Transparency = 0.2
		rebar.CanCollide = false
		rebar.Parent = model
	end

	-- ── SCAFFOLDING (-X side of structure) ───────────────────────────────
	local scaffW = 16 * scale
	local scaffH = 18 * scale
	local poleRadius = 0.25 * scale
	local scaffX = structX - 8 * scale - 0.5 * scale

	for i = 0, 3 do
		local pz = centerZ - scaffW / 2 + i * scaffW / 3
		local pole = Instance.new("Part")
		pole.Name = "ScaffoldPole"
		pole.Shape = Enum.PartType.Cylinder
		pole.Size = Vector3.new(scaffH, poleRadius * 2, poleRadius * 2)
		pole.CFrame = CFrame.new(scaffX, BUILDING_BASE + scaffH / 2, pz)
			* CFrame.Angles(0, 0, math.rad(90))
		pole.Anchored = true
		pole.Material = Enum.Material.Metal
		pole.Color = spec.scaffoldColor
		pole.Parent = model
	end

	for level = 0, 2 do
		local barY = BUILDING_BASE + (level + 1) * 6 * scale
		local bar = Instance.new("Part")
		bar.Name = "ScaffoldBar"
		bar.Size = Vector3.new(0.3 * scale, 0.3 * scale, scaffW)
		bar.Position = Vector3.new(scaffX, barY, centerZ)
		bar.Anchored = true
		bar.Material = Enum.Material.Metal
		bar.Color = spec.scaffoldColor
		bar.Parent = model

		local plank = Instance.new("Part")
		plank.Name = "ScaffoldPlank"
		plank.Size = Vector3.new(2 * scale, 0.2 * scale, scaffW)
		plank.Position = Vector3.new(scaffX, barY + 0.1 * scale, centerZ)
		plank.Anchored = true
		plank.Material = Enum.Material.Wood
		plank.Color = Color3.fromRGB(160, 120, 70)
		plank.Parent = model
	end

	-- ── TOWER CRANE (-X side, near front) ─────────────────────────────────
	local craneX = centerX - 10 * scale
	local craneZ = centerZ

	-- Concrete base pedestal
	local craneBaseW = 5 * scale
	local craneBaseH = 2 * scale
	local craneBase = Instance.new("Part")
	craneBase.Name = "CraneBase"
	craneBase.Size = Vector3.new(craneBaseW, craneBaseH, craneBaseW)
	craneBase.Position = Vector3.new(craneX, BUILDING_BASE + craneBaseH / 2, craneZ)
	craneBase.Anchored = true
	craneBase.Material = Enum.Material.Concrete
	craneBase.Color = Color3.fromRGB(130, 130, 135)
	craneBase.Parent = model

	-- Anchor bolts
	for _, bx in ipairs({ -1, 1 }) do
		for _, bz in ipairs({ -1, 1 }) do
			local bolt = Instance.new("Part")
			bolt.Name = "AnchorBolt"
			bolt.Shape = Enum.PartType.Cylinder
			bolt.Size = Vector3.new(0.5 * scale, 0.6 * scale, 0.6 * scale)
			bolt.CFrame = CFrame.new(
				craneX + bx * (craneBaseW / 2 - 0.5 * scale),
				BUILDING_BASE + craneBaseH + 0.25 * scale,
				craneZ + bz * (craneBaseW / 2 - 0.5 * scale)
			) * CFrame.Angles(0, 0, math.rad(90))
			bolt.Anchored = true
			bolt.Material = Enum.Material.Metal
			bolt.Color = Color3.fromRGB(70, 70, 75)
			bolt.Parent = model
		end
	end

	-- Lattice mast
	local mastW = 1.8 * scale
	local mastH = 35 * scale
	local railSize = 0.3 * scale
	local mastTopY = BUILDING_BASE + craneBaseH + mastH

	local halfM = mastW / 2 - railSize / 2
	for _, mx in ipairs({ -halfM, halfM }) do
		for _, mz in ipairs({ -halfM, halfM }) do
			local rail = Instance.new("Part")
			rail.Name = "MastRail"
			rail.Size = Vector3.new(railSize, mastH, railSize)
			rail.Position = Vector3.new(craneX + mx, BUILDING_BASE + craneBaseH + mastH / 2, craneZ + mz)
			rail.Anchored = true
			rail.Material = Enum.Material.Metal
			rail.Color = spec.craneColor
			rail.Parent = model
		end
	end

	-- Hazard stripes on mast
	local stripeH = 1.2 * scale
	local stripeCount = math.floor(mastH / (5 * scale))
	for i = 0, stripeCount - 1 do
		local sy = BUILDING_BASE + craneBaseH + i * 5 * scale + 2.5 * scale
		local sp = Instance.new("Part")
		sp.Name = "HazardStripe"
		sp.Size = Vector3.new(mastW, stripeH, mastW)
		sp.Position = Vector3.new(craneX, sy, craneZ)
		sp.Anchored = true
		sp.CanCollide = false
		sp.Material = Enum.Material.SmoothPlastic
		sp.Color = Color3.fromRGB(30, 30, 30)
		sp.Parent = model
	end

	-- Mast cross-bracing
	local sectionH = 7 * scale
	local numSections = math.floor(mastH / sectionH)
	local braceThick = 0.15 * scale
	local braceLen = math.sqrt(sectionH * sectionH + mastW * mastW)

	for s = 0, numSections - 1 do
		local secMidY = BUILDING_BASE + craneBaseH + s * sectionH + sectionH / 2

		for _, fz in ipairs({ -halfM, halfM }) do
			local brace = Instance.new("Part")
			brace.Name = "MastBrace"
			brace.Size = Vector3.new(braceThick, braceLen, braceThick)
			brace.CFrame = CFrame.new(craneX, secMidY, craneZ + fz)
				* CFrame.Angles(0, 0, math.atan2(mastW, sectionH))
			brace.Anchored = true
			brace.CanCollide = false
			brace.Material = Enum.Material.Metal
			brace.Color = spec.craneColor
			brace.Parent = model
		end

		for _, fx in ipairs({ -halfM, halfM }) do
			local brace = Instance.new("Part")
			brace.Name = "MastBrace"
			brace.Size = Vector3.new(braceThick, braceLen, braceThick)
			brace.CFrame = CFrame.new(craneX + fx, secMidY, craneZ)
				* CFrame.Angles(math.atan2(mastW, sectionH), 0, 0)
			brace.Anchored = true
			brace.CanCollide = false
			brace.Material = Enum.Material.Metal
			brace.Color = spec.craneColor
			brace.Parent = model
		end

		local ring = Instance.new("Part")
		ring.Name = "MastRing"
		ring.Size = Vector3.new(mastW, 0.2 * scale, mastW)
		ring.Position = Vector3.new(craneX, BUILDING_BASE + craneBaseH + s * sectionH, craneZ)
		ring.Anchored = true
		ring.CanCollide = false
		ring.Material = Enum.Material.Metal
		ring.Color = spec.craneColor
		ring.Parent = model
	end

	-- Slewing ring
	local slewDiam = 3 * scale
	local slew = Instance.new("Part")
	slew.Name = "SlewingRing"
	slew.Shape = Enum.PartType.Cylinder
	slew.Size = Vector3.new(0.6 * scale, slewDiam, slewDiam)
	slew.CFrame = CFrame.new(craneX, mastTopY + 0.3 * scale, craneZ)
		* CFrame.Angles(0, 0, math.rad(90))
	slew.Anchored = true
	slew.Material = Enum.Material.Metal
	slew.Color = Color3.fromRGB(60, 60, 65)
	slew.Parent = model

	-- Operator cab
	local cabW = 2.5 * scale
	local cabH = 2.5 * scale
	local cabY = mastTopY + 0.6 * scale
	local cab = Instance.new("Part")
	cab.Name = "CraneCab"
	cab.Size = Vector3.new(cabW, cabH, cabW)
	cab.Position = Vector3.new(craneX, cabY + cabH / 2, craneZ)
	cab.Anchored = true
	cab.Material = Enum.Material.Metal
	cab.Color = spec.craneColor
	cab.Parent = model

	-- Cab windows
	for _, face in ipairs({
		{ size = Vector3.new(cabW + 0.1, 1.2 * scale, 0.15 * scale), pos = Vector3.new(craneX, cabY + cabH * 0.6, craneZ - cabW / 2) },
		{ size = Vector3.new(cabW + 0.1, 1.2 * scale, 0.15 * scale), pos = Vector3.new(craneX, cabY + cabH * 0.6, craneZ + cabW / 2) },
		{ size = Vector3.new(0.15 * scale, 1.2 * scale, cabW + 0.1), pos = Vector3.new(craneX - cabW / 2, cabY + cabH * 0.6, craneZ) },
		{ size = Vector3.new(0.15 * scale, 1.2 * scale, cabW + 0.1), pos = Vector3.new(craneX + cabW / 2, cabY + cabH * 0.6, craneZ) },
	}) do
		local win = Instance.new("Part")
		win.Name = "CabWindow"
		win.Size = face.size
		win.Position = face.pos
		win.Anchored = true
		win.CanCollide = false
		win.Material = Enum.Material.Glass
		win.Color = Color3.fromRGB(170, 210, 240)
		win.Transparency = 0.3
		win.Parent = model
	end

	local cabRoof = Instance.new("Part")
	cabRoof.Name = "CabRoof"
	cabRoof.Size = Vector3.new(cabW + 0.4 * scale, 0.2 * scale, cabW + 0.4 * scale)
	cabRoof.Position = Vector3.new(craneX, cabY + cabH + 0.1 * scale, craneZ)
	cabRoof.Anchored = true
	cabRoof.Material = Enum.Material.Metal
	cabRoof.Color = spec.craneColor
	cabRoof.Parent = model

	-- Cat head
	local catHeadH = 5 * scale
	local catHeadW = 0.4 * scale
	local catHeadY = cabY + cabH
	local catHead = Instance.new("Part")
	catHead.Name = "CatHead"
	catHead.Size = Vector3.new(catHeadW, catHeadH, catHeadW)
	catHead.Position = Vector3.new(craneX, catHeadY + catHeadH / 2, craneZ)
	catHead.Anchored = true
	catHead.Material = Enum.Material.Metal
	catHead.Color = spec.craneColor
	catHead.Parent = model

	local catTopY = catHeadY + catHeadH

	-- Horizontal boom
	local boomLen = 30 * scale
	local boomH = 1.2 * scale
	local boomW = 1 * scale
	local boomY = cabY + cabH + boomH / 2

	local boom = Instance.new("Part")
	boom.Name = "CraneBoom"
	boom.Size = Vector3.new(boomLen, boomH, boomW)
	boom.CFrame = CFrame.new(craneX, boomY, craneZ) * CFrame.new(boomLen / 2 - 5 * scale, 0, 0)
	boom.Anchored = true
	boom.Material = Enum.Material.Metal
	boom.Color = spec.craneColor
	boom.Parent = model

	-- Boom tip markers
	local tipLen = 2 * scale
	local tip = Instance.new("Part")
	tip.Name = "BoomTipRed"
	tip.Size = Vector3.new(tipLen, boomH + 0.1, boomW + 0.1)
	tip.CFrame = CFrame.new(craneX, boomY, craneZ) * CFrame.new(boomLen - 5 * scale - tipLen / 2, 0, 0)
	tip.Anchored = true
	tip.CanCollide = false
	tip.Material = Enum.Material.SmoothPlastic
	tip.Color = Color3.fromRGB(220, 30, 30)
	tip.Parent = model

	local tipWhite = Instance.new("Part")
	tipWhite.Name = "BoomTipWhite"
	tipWhite.Size = Vector3.new(tipLen, boomH + 0.1, boomW + 0.1)
	tipWhite.CFrame = CFrame.new(craneX, boomY, craneZ) * CFrame.new(boomLen - 5 * scale - tipLen * 1.5, 0, 0)
	tipWhite.Anchored = true
	tipWhite.CanCollide = false
	tipWhite.Material = Enum.Material.SmoothPlastic
	tipWhite.Color = Color3.fromRGB(240, 240, 240)
	tipWhite.Parent = model

	-- Counter-boom
	local counterLen = 10 * scale
	local counter = Instance.new("Part")
	counter.Name = "CounterBoom"
	counter.Size = Vector3.new(counterLen, boomH, boomW)
	counter.CFrame = CFrame.new(craneX, boomY, craneZ) * CFrame.new(-counterLen / 2 - 1 * scale, 0, 0)
	counter.Anchored = true
	counter.Material = Enum.Material.Metal
	counter.Color = spec.craneColor
	counter.Parent = model

	-- Counterweight blocks
	local cwW = 3 * scale
	local cwH = 1.5 * scale
	local cwTop = Instance.new("Part")
	cwTop.Name = "Counterweight"
	cwTop.Size = Vector3.new(cwW, cwH, cwW)
	cwTop.CFrame = CFrame.new(craneX, boomY - boomH / 2 - cwH / 2, craneZ)
		* CFrame.new(-counterLen - 0.5 * scale, 0, 0)
	cwTop.Anchored = true
	cwTop.Material = Enum.Material.Concrete
	cwTop.Color = Color3.fromRGB(100, 100, 105)
	cwTop.Parent = model

	local cwBottom = Instance.new("Part")
	cwBottom.Name = "Counterweight2"
	cwBottom.Size = Vector3.new(cwW, cwH, cwW - 0.5 * scale)
	cwBottom.CFrame = CFrame.new(craneX, boomY - boomH / 2 - cwH / 2 - cwH, craneZ)
		* CFrame.new(-counterLen - 0.5 * scale, 0, 0)
	cwBottom.Anchored = true
	cwBottom.Material = Enum.Material.Concrete
	cwBottom.Color = Color3.fromRGB(85, 85, 90)
	cwBottom.Parent = model

	-- Pendant lines
	local pendantTipX = boomLen - 5 * scale
	local pendantLen2 = math.sqrt(pendantTipX * pendantTipX + (catTopY - boomY) * (catTopY - boomY))
	local pendantAngle = math.atan2(catTopY - boomY, pendantTipX)
	local pendant1 = Instance.new("Part")
	pendant1.Name = "PendantMain"
	pendant1.Size = Vector3.new(pendantLen2, 0.12 * scale, 0.12 * scale)
	pendant1.CFrame = CFrame.new(craneX, (catTopY + boomY) / 2, craneZ)
		* CFrame.new(pendantTipX / 2, 0, 0) * CFrame.Angles(0, 0, -pendantAngle)
	pendant1.Anchored = true
	pendant1.CanCollide = false
	pendant1.Material = Enum.Material.Metal
	pendant1.Color = Color3.fromRGB(50, 50, 55)
	pendant1.Parent = model

	local pendantCounterX = counterLen + 1 * scale
	local pendantCLen = math.sqrt(pendantCounterX * pendantCounterX + (catTopY - boomY) * (catTopY - boomY))
	local pendantCAngle = math.atan2(catTopY - boomY, pendantCounterX)
	local pendant2 = Instance.new("Part")
	pendant2.Name = "PendantCounter"
	pendant2.Size = Vector3.new(pendantCLen, 0.12 * scale, 0.12 * scale)
	pendant2.CFrame = CFrame.new(craneX, (catTopY + boomY) / 2, craneZ)
		* CFrame.new(-pendantCounterX / 2, 0, 0) * CFrame.Angles(0, 0, pendantCAngle)
	pendant2.Anchored = true
	pendant2.CanCollide = false
	pendant2.Material = Enum.Material.Metal
	pendant2.Color = Color3.fromRGB(50, 50, 55)
	pendant2.Parent = model

	-- Trolley, cable, hook
	local trolley = Instance.new("Part")
	trolley.Name = "Trolley"
	trolley.Size = Vector3.new(1.5 * scale, 0.6 * scale, 1.2 * scale)
	trolley.CFrame = CFrame.new(craneX, boomY - boomH / 2 - 0.3 * scale, craneZ) * CFrame.new(boomLen / 2, 0, 0)
	trolley.Anchored = true
	trolley.Material = Enum.Material.Metal
	trolley.Color = Color3.fromRGB(80, 80, 85)
	trolley.Parent = model

	local cableH = 18 * scale
	local cable = Instance.new("Part")
	cable.Name = "HangingCable"
	cable.Size = Vector3.new(0.15 * scale, cableH, 0.15 * scale)
	cable.CFrame = CFrame.new(craneX, boomY - boomH / 2 - 0.6 * scale - cableH / 2, craneZ) * CFrame.new(boomLen / 2, 0, 0)
	cable.Anchored = true
	cable.Material = Enum.Material.Metal
	cable.Color = Color3.fromRGB(60, 60, 65)
	cable.Parent = model

	local hookBlockH = 1.2 * scale
	local hookBlock = Instance.new("Part")
	hookBlock.Name = "HookBlock"
	hookBlock.Size = Vector3.new(1.2 * scale, hookBlockH, 0.8 * scale)
	hookBlock.CFrame = CFrame.new(craneX, boomY - boomH / 2 - 0.6 * scale - cableH - hookBlockH / 2, craneZ) * CFrame.new(boomLen / 2, 0, 0)
	hookBlock.Anchored = true
	hookBlock.Material = Enum.Material.Metal
	hookBlock.Color = Color3.fromRGB(80, 80, 85)
	hookBlock.Parent = model

	local hook = Instance.new("Part")
	hook.Name = "Hook"
	hook.Shape = Enum.PartType.Ball
	hook.Size = Vector3.new(0.7 * scale, 0.7 * scale, 0.7 * scale)
	hook.CFrame = CFrame.new(craneX, boomY - boomH / 2 - 0.6 * scale - cableH - hookBlockH - 0.35 * scale, craneZ) * CFrame.new(boomLen / 2, 0, 0)
	hook.Anchored = true
	hook.Material = Enum.Material.Metal
	hook.Color = Color3.fromRGB(200, 60, 30)
	hook.Parent = model

	-- Warning light on cat head
	local warnLight = Instance.new("Part")
	warnLight.Name = "CraneWarningLight"
	warnLight.Shape = Enum.PartType.Ball
	warnLight.Size = Vector3.new(0.8 * scale, 0.8 * scale, 0.8 * scale)
	warnLight.Position = Vector3.new(craneX, catTopY + 0.4 * scale, craneZ)
	warnLight.Anchored = true
	warnLight.Material = Enum.Material.Neon
	warnLight.Color = Color3.fromRGB(255, 40, 20)
	warnLight.Parent = model

	local wl = Instance.new("PointLight")
	wl.Brightness = 1.5
	wl.Range = 12
	wl.Color = Color3.fromRGB(255, 40, 20)
	wl.Parent = warnLight

	-- ── GROUND PROPS ──────────────────────────────────────────────────────

	-- Concrete mixer
	local mixerX = centerX + 6 * scale
	local mixerZ = centerZ - 6 * scale

	local mixerPlatform = Instance.new("Part")
	mixerPlatform.Name = "MixerPlatform"
	mixerPlatform.Size = Vector3.new(4 * scale, 1 * scale, 4 * scale)
	mixerPlatform.Position = Vector3.new(mixerX, BUILDING_BASE + 0.5 * scale, mixerZ)
	mixerPlatform.Anchored = true
	mixerPlatform.Material = Enum.Material.Metal
	mixerPlatform.Color = Color3.fromRGB(100, 100, 105)
	mixerPlatform.Parent = model

	local drumDiam = 3 * scale
	local drumLen = 5 * scale
	local drum = Instance.new("Part")
	drum.Name = "MixerDrum"
	drum.Shape = Enum.PartType.Cylinder
	drum.Size = Vector3.new(drumLen, drumDiam, drumDiam)
	drum.CFrame = CFrame.new(mixerX, BUILDING_BASE + 1 * scale + drumDiam / 2 + 0.5 * scale, mixerZ)
		* CFrame.Angles(0, 0, math.rad(25))
	drum.Anchored = true
	drum.Material = Enum.Material.Metal
	drum.Color = Color3.fromRGB(190, 190, 195)
	drum.Parent = model

	-- Sand pile
	local sand = Instance.new("Part")
	sand.Name = "SandPile"
	sand.Shape = Enum.PartType.Ball
	sand.Size = Vector3.new(5 * scale, 3 * scale, 5 * scale)
	sand.Position = Vector3.new(centerX + 10 * scale, BUILDING_BASE + 1.5 * scale, centerZ - 4 * scale)
	sand.Anchored = true
	sand.Material = Enum.Material.Sand
	sand.Color = Color3.fromRGB(200, 185, 140)
	sand.Parent = model

	-- Steel beams
	for i = 1, 4 do
		local beam = Instance.new("Part")
		beam.Name = "SteelBeam"
		beam.Size = Vector3.new(8 * scale, 0.4 * scale, 0.6 * scale)
		beam.Position = Vector3.new(
			centerX + 8 * scale + (math.random() - 0.5) * 1 * scale,
			BUILDING_BASE + (i - 1) * 0.45 * scale + 0.2 * scale,
			centerZ + 8 * scale + (i - 2) * 0.8 * scale
		)
		beam.Anchored = true
		beam.Material = Enum.Material.Metal
		beam.Color = Color3.fromRGB(130, 90, 60)
		beam.Parent = model
	end

	-- Safety barriers (+Z edge)
	for i = 1, 4 do
		local barrierZ = centerZ + (i - 2.5) * 6 * scale
		local barrier = Instance.new("Part")
		barrier.Name = "SafetyBarrier"
		barrier.Size = Vector3.new(0.4 * scale, 2 * scale, 1.2 * scale)
		barrier.Position = Vector3.new(centerX - 1 * scale, BUILDING_BASE + 1 * scale, barrierZ)
		barrier.Anchored = true
		barrier.Material = Enum.Material.SmoothPlastic
		barrier.Color = spec.barrierColor
		barrier.Parent = model

		local bstripe = Instance.new("Part")
		bstripe.Name = "BarrierStripe"
		bstripe.Size = Vector3.new(0.42 * scale, 0.5 * scale, 1.22 * scale)
		bstripe.Position = Vector3.new(centerX - 1 * scale, BUILDING_BASE + 1.3 * scale, barrierZ)
		bstripe.Anchored = true
		bstripe.CanCollide = false
		bstripe.Material = Enum.Material.SmoothPlastic
		bstripe.Color = Color3.fromRGB(240, 240, 240)
		bstripe.Parent = model
	end

	-- Traffic cones
	for i = 1, 5 do
		local coneZ = centerZ + (i - 3) * 5 * scale + (math.random() - 0.5) * 2 * scale
		local coneX = centerX + (1 + math.random() * 3) * scale

		local cone = Instance.new("Part")
		cone.Name = "TrafficCone"
		cone.Shape = Enum.PartType.Cylinder
		cone.Size = Vector3.new(1.5 * scale, 0.8 * scale, 0.8 * scale)
		cone.CFrame = CFrame.new(coneX, BUILDING_BASE + 0.75 * scale, coneZ)
			* CFrame.Angles(0, 0, math.rad(90))
		cone.Anchored = true
		cone.Material = Enum.Material.SmoothPlastic
		cone.Color = Color3.fromRGB(255, 100, 20)
		cone.Parent = model

		local cs = Instance.new("Part")
		cs.Name = "ConeStripe"
		cs.Shape = Enum.PartType.Cylinder
		cs.Size = Vector3.new(0.3 * scale, 0.82 * scale, 0.82 * scale)
		cs.CFrame = CFrame.new(coneX, BUILDING_BASE + 1.1 * scale, coneZ)
			* CFrame.Angles(0, 0, math.rad(90))
		cs.Anchored = true
		cs.CanCollide = false
		cs.Material = Enum.Material.SmoothPlastic
		cs.Color = Color3.fromRGB(240, 240, 240)
		cs.Parent = model
	end

	-- ── SIGN + WORK LIGHTS + DUST ─────────────────────────────────────────

	-- Neon company sign
	local signPart = Instance.new("Part")
	signPart.Name = "ConstructionSign"
	signPart.Size = Vector3.new(12 * scale, 2.5 * scale, 0.4 * scale)
	signPart.Position = Vector3.new(centerX, BUILDING_BASE + 7 * scale, centerZ + 12 * scale)
	signPart.Anchored = true
	signPart.Material = Enum.Material.Neon
	signPart.Color = spec.signColor
	signPart:SetAttribute("ThemeRole", "building_neon")
	signPart:SetAttribute("BaseColor", spec.signColor)
	signPart:SetAttribute("BaseMaterial", "Neon")
	signPart.Parent = model

	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Back
	gui.Parent = signPart
	local txt = Instance.new("TextLabel")
	txt.Size = UDim2.new(1, 0, 1, 0)
	txt.BackgroundTransparency = 1
	txt.Font = Enum.Font.GothamBold
	txt.Text = spec.companyName
	txt.TextColor3 = Color3.new(1, 1, 1)
	txt.TextScaled = true
	txt.Parent = gui

	local signLight = Instance.new("PointLight")
	signLight.Brightness = 1.2
	signLight.Range = 12
	signLight.Color = spec.signColor
	signLight.Parent = signPart

	-- Work light poles
	for _, lp in ipairs({
		{ x = centerX + 4 * scale, z = centerZ - 14 * scale },
		{ x = centerX + 4 * scale, z = centerZ + 14 * scale },
	}) do
		local poleH = 10 * scale
		local pole = Instance.new("Part")
		pole.Name = "WorkLightPole"
		pole.Size = Vector3.new(0.4 * scale, poleH, 0.4 * scale)
		pole.Position = Vector3.new(lp.x, BUILDING_BASE + poleH / 2, lp.z)
		pole.Anchored = true
		pole.Material = Enum.Material.Metal
		pole.Color = Color3.fromRGB(110, 110, 115)
		pole.Parent = model

		local fixture = Instance.new("Part")
		fixture.Name = "WorkLight"
		fixture.Size = Vector3.new(1.5 * scale, 0.6 * scale, 1.5 * scale)
		fixture.Position = Vector3.new(lp.x, BUILDING_BASE + poleH + 0.3 * scale, lp.z)
		fixture.Anchored = true
		fixture.Material = Enum.Material.Neon
		fixture.Color = Color3.fromRGB(255, 230, 160)
		fixture.Parent = model

		local light = Instance.new("PointLight")
		light.Brightness = 0.8
		light.Range = 14
		light.Color = Color3.fromRGB(255, 230, 160)
		light.Parent = fixture
	end

	-- Dust particle emitter
	local dustPart = Instance.new("Part")
	dustPart.Name = "DustPoint"
	dustPart.Size = Vector3.new(14 * scale, 1, 12 * scale)
	dustPart.Position = Vector3.new(centerX + 8 * scale, BUILDING_BASE + 1, centerZ)
	dustPart.Anchored = true
	dustPart.CanCollide = false
	dustPart.Transparency = 1
	dustPart.Parent = model

	local dust = Instance.new("ParticleEmitter")
	dust.Name = "ConstructionDust"
	dust.Rate = 12
	dust.Speed = NumberRange.new(0.5, 2)
	dust.Lifetime = NumberRange.new(2, 5)
	dust.SpreadAngle = Vector2.new(40, 40)
	dust.LightEmission = 0.1
	dust.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.3, 2.5),
		NumberSequenceKeypoint.new(0.7, 4),
		NumberSequenceKeypoint.new(1, 2),
	})
	dust.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.3, 0.6),
		NumberSequenceKeypoint.new(0.7, 0.8),
		NumberSequenceKeypoint.new(1, 1),
	})
	dust.Color = ColorSequence.new(Color3.fromRGB(180, 170, 150), Color3.fromRGB(200, 190, 170))
	dust.Acceleration = Vector3.new(0, 0.5, 0)
	dust.Parent = dustPart

	-- ── CRANE BOOM ANIMATION DATA ─────────────────────────────────────────
	local hookTotalOffsetY = -boomH / 2 - 0.6 * scale - cableH - hookBlockH - 0.35 * scale
	local craneAnimData = {
		type = "crane_boom",
		centerX = craneX,
		centerY = boomY,
		centerZ = craneZ,
		armOffset = boomLen / 2 - 5 * scale,
		angle = math.random() * math.pi * 2,
		speed = 0.15,
		linkedParts = {
			{ part = counter,   offsetX = -counterLen / 2 - 1 * scale,      offsetY = 0 },
			{ part = cwTop,     offsetX = -counterLen - 0.5 * scale,         offsetY = -boomH / 2 - cwH / 2 },
			{ part = cwBottom,  offsetX = -counterLen - 0.5 * scale,         offsetY = -boomH / 2 - cwH / 2 - cwH },
			{ part = trolley,   offsetX = boomLen / 2,                       offsetY = -boomH / 2 - 0.3 * scale },
			{ part = cable,     offsetX = boomLen / 2,                       offsetY = -boomH / 2 - 0.6 * scale - cableH / 2 },
			{ part = hookBlock, offsetX = boomLen / 2,                       offsetY = -boomH / 2 - 0.6 * scale - cableH - hookBlockH / 2 },
			{ part = hook,      offsetX = boomLen / 2,                       offsetY = hookTotalOffsetY },
			{ part = pendant1,  offsetX = pendantTipX / 2,                   offsetY = (catTopY - boomY) / 2,  tiltAngle = -pendantAngle },
			{ part = pendant2,  offsetX = -pendantCounterX / 2,              offsetY = (catTopY - boomY) / 2,  tiltAngle = pendantCAngle },
			{ part = tip,       offsetX = boomLen - 5 * scale - tipLen / 2,  offsetY = 0 },
			{ part = tipWhite,  offsetX = boomLen - 5 * scale - tipLen * 1.5, offsetY = 0 },
			{ part = catHead,   offsetX = 0,                                 offsetY = (catTopY - boomY) - catHeadH / 2 },
		},
	}

	if options.parent then
		model.Parent = options.parent
	end

	return model, { craneBoom = boom, craneAnimData = craneAnimData }
end

function AssetLibrary.getConstructionSiteVariants()
	return { "mega", "skyline" }
end

--------------------------------------------------------------------------------
-- createPrisonBuilding(centerX, centerZ, options)
-- Brutalist concrete cell block: barred windows, metal doors, floodlights, parapet.
-- Random 3-4 stories, 35-55W × 18-26D studs.
-- options.scale: number (default 1)
-- options.parent: Instance to parent to
-- Returns: Model
--------------------------------------------------------------------------------

function AssetLibrary.createPrisonBuilding(centerX, centerZ, options)
	options = options or {}
	local scale = options.scale or 1
	local baseY = options.baseY or BUILDING_BASE

	local model = Instance.new("Model")
	model.Name = "PrisonBuilding"

	-- Palette
	local palettes = {
		{ main = Color3.fromRGB(135, 130, 125), trim = Color3.fromRGB(100, 95, 90) },
		{ main = Color3.fromRGB(125, 125, 120), trim = Color3.fromRGB(90, 88, 85) },
		{ main = Color3.fromRGB(140, 135, 128), trim = Color3.fromRGB(105, 100, 95) },
	}
	local palette = palettes[math.random(#palettes)]

	local stories = math.random(3, 4)
	local storyH = 6 * scale
	local buildW = (35 + math.random() * 20) * scale
	local buildD = (18 + math.random() * 8) * scale
	local totalH = stories * storyH
	local halfW = buildW / 2
	local halfD = buildD / 2

	local function makePart(name, size, cf, color, material)
		local p = Instance.new("Part")
		p.Name = name
		p.Size = size
		p.CFrame = cf
		p.Color = color
		p.Material = material or Enum.Material.Concrete
		p.Anchored = true
		p.CanCollide = false
		p.Parent = model
		return p
	end

	-- Foundation
	makePart("Foundation",
		Vector3.new(buildD + 2 * scale, 1 * scale, buildW + 2 * scale),
		CFrame.new(centerX, baseY + 0.5 * scale, centerZ),
		Color3.fromRGB(160, 155, 148))

	-- Main block
	makePart("MainBlock",
		Vector3.new(buildD, totalH, buildW),
		CFrame.new(centerX, baseY + 1 * scale + totalH / 2, centerZ),
		palette.main)

	-- Parapet
	local roofY = baseY + 1 * scale + totalH
	local parapetH = 1.5 * scale

	for _, sx in ipairs({ -1, 1 }) do
		makePart("Parapet",
			Vector3.new(0.8 * scale, parapetH, buildW + 0.4 * scale),
			CFrame.new(centerX + sx * (halfD + 0.2 * scale), roofY + parapetH / 2, centerZ),
			palette.trim)
	end
	for _, sz in ipairs({ -1, 1 }) do
		makePart("Parapet",
			Vector3.new(buildD + 1.2 * scale, parapetH, 0.8 * scale),
			CFrame.new(centerX, roofY + parapetH / 2, centerZ + sz * (halfW + 0.2 * scale)),
			palette.trim)
	end

	-- Flat roof
	makePart("Roof",
		Vector3.new(buildD - 0.5 * scale, 0.3 * scale, buildW - 0.5 * scale),
		CFrame.new(centerX, roofY + 0.15 * scale, centerZ),
		Color3.fromRGB(90, 88, 85))

	-- Roof vents
	for _ = 1, math.random(2, 4) do
		local vx = centerX + (math.random() - 0.5) * (buildD - 4 * scale)
		local vz = centerZ + (math.random() - 0.5) * (buildW - 4 * scale)
		local vSize = (1.5 + math.random() * 1.5) * scale
		makePart("RoofVent",
			Vector3.new(vSize, vSize * 0.8, vSize),
			CFrame.new(vx, roofY + vSize * 0.4, vz),
			Color3.fromRGB(110, 108, 105), Enum.Material.DiamondPlate)
	end

	-- Barred windows helper
	local function buildWindow(cx, cy, cz, winW, winH, faceAxis)
		if faceAxis == "z" then
			makePart("WindowRecess", Vector3.new(winW, winH, 0.6), CFrame.new(cx, cy, cz),
				Color3.fromRGB(30, 30, 35), Enum.Material.SmoothPlastic)
			local numBars = math.max(2, math.floor(winW / 0.6))
			local barSpacing = winW / (numBars + 1)
			for i = 1, numBars do
				makePart("WindowBar", Vector3.new(0.12, winH - 0.2, 0.12),
					CFrame.new(cx - winW / 2 + i * barSpacing, cy, cz + 0.25),
					Color3.fromRGB(70, 70, 75), Enum.Material.Metal)
			end
		else
			makePart("WindowRecess", Vector3.new(0.6, winH, winW), CFrame.new(cx, cy, cz),
				Color3.fromRGB(30, 30, 35), Enum.Material.SmoothPlastic)
			local numBars = math.max(2, math.floor(winW / 0.6))
			local barSpacing = winW / (numBars + 1)
			for i = 1, numBars do
				makePart("WindowBar", Vector3.new(0.12, winH - 0.2, 0.12),
					CFrame.new(cx + 0.25, cy, cz - winW / 2 + i * barSpacing),
					Color3.fromRGB(70, 70, 75), Enum.Material.Metal)
			end
		end
	end

	-- Windows on all 4 faces
	local winW = 1.8 * scale
	local winH = 1.4 * scale
	local winSpacing = 4.5 * scale
	local numWins = math.floor(buildW / winSpacing)
	local winStartZ = centerZ - (numWins - 1) * winSpacing / 2

	for story = 1, stories do
		local winY = baseY + 1 * scale + (story - 0.4) * storyH
		for i = 0, numWins - 1 do
			local wz = winStartZ + i * winSpacing
			buildWindow(centerX + halfD + 0.01, winY, wz, winW, winH, "x")
			buildWindow(centerX - halfD - 0.01, winY, wz, winW, winH, "x")
		end
	end

	local sideWins = math.max(1, math.floor(buildD / winSpacing) - 1)
	local sideStartX = centerX - (sideWins - 1) * winSpacing / 2
	for story = 1, stories do
		local winY = baseY + 1 * scale + (story - 0.4) * storyH
		for i = 0, sideWins - 1 do
			local wx = sideStartX + i * winSpacing
			buildWindow(wx, winY, centerZ - halfW - 0.01, winW, winH, "z")
			buildWindow(wx, winY, centerZ + halfW + 0.01, winW, winH, "z")
		end
	end

	-- Heavy metal doors (one on each long face)
	local doorW = 3 * scale
	local doorH = 4 * scale
	for _, sx in ipairs({ -1, 1 }) do
		local doorX = centerX + sx * (halfD + 0.05)
		makePart("DoorFrame",
			Vector3.new(0.8 * scale, doorH + 0.5 * scale, doorW + 1 * scale),
			CFrame.new(doorX, baseY + 1 * scale + (doorH + 0.5 * scale) / 2, centerZ),
			palette.trim)
		makePart("Door",
			Vector3.new(0.4 * scale, doorH, doorW),
			CFrame.new(doorX + sx * 0.2, baseY + 1 * scale + doorH / 2, centerZ),
			Color3.fromRGB(60, 65, 70), Enum.Material.DiamondPlate)
	end

	-- Floodlights
	local floodY = roofY - 1 * scale
	for _, fl in ipairs({
		{ x = centerX + halfD + 0.3, z = centerZ - halfW * 0.5 },
		{ x = centerX + halfD + 0.3, z = centerZ + halfW * 0.5 },
		{ x = centerX - halfD - 0.3, z = centerZ - halfW * 0.5 },
		{ x = centerX - halfD - 0.3, z = centerZ + halfW * 0.5 },
	}) do
		local light = makePart("Floodlight",
			Vector3.new(0.8 * scale, 0.5 * scale, 1.2 * scale),
			CFrame.new(fl.x, floodY, fl.z) * CFrame.Angles(math.rad(30), 0, 0),
			Color3.fromRGB(60, 60, 65), Enum.Material.Metal)

		local spot = Instance.new("SpotLight")
		spot.Face = Enum.NormalId.Bottom
		spot.Angle = 50
		spot.Range = 25
		spot.Brightness = 2
		spot.Color = Color3.fromRGB(255, 230, 180)
		spot.Parent = light
	end

	-- Story trim lines
	for story = 1, stories - 1 do
		local trimY = baseY + 1 * scale + story * storyH
		for _, sx in ipairs({ -1, 1 }) do
			makePart("StoryTrim",
				Vector3.new(0.15 * scale, 0.4 * scale, buildW + 0.1 * scale),
				CFrame.new(centerX + sx * (halfD + 0.05), trimY, centerZ),
				palette.trim)
		end
	end

	if options.parent then
		model.Parent = options.parent
	end

	return model
end

--------------------------------------------------------------------------------
-- WHITE HOUSE
-- Iconic government building: main body with windows, south portico with
-- semicircular colonnade, American flag, iron fence perimeter.
-- Options: parent, scale
--------------------------------------------------------------------------------

function AssetLibrary.createWhiteHouse(centerX, centerZ, options)
	options = options or {}
	local scale = options.scale or 1

	local model = Instance.new("Model")
	model.Name = "WhiteHouse"

	local bodyColor = Color3.fromRGB(245, 245, 240)
	local trimColor = Color3.fromRGB(235, 235, 228)
	local roofColor = Color3.fromRGB(130, 130, 135)
	local winColor  = Color3.fromRGB(255, 220, 140)

	---------------------------------------------------------------------------
	-- DIMENSIONS
	---------------------------------------------------------------------------
	local bodyW = 80 * scale   -- width along X
	local bodyD = 28 * scale   -- depth along Z
	local bodyH = 22 * scale
	local winFloors = 3
	local winFloorH = 6 * scale

	local halfW = bodyW / 2
	local halfD = bodyD / 2
	local frontZ = centerZ + halfD   -- south face (+Z)
	local backZ  = centerZ - halfD

	---------------------------------------------------------------------------
	-- 1. MAIN BODY
	---------------------------------------------------------------------------
	local main = Instance.new("Part")
	main.Name = "MainBody"
	main.Size = Vector3.new(bodyW, bodyH, bodyD)
	main.Position = Vector3.new(centerX, BUILDING_BASE + bodyH / 2, centerZ)
	main.Anchored = true
	main.Material = Enum.Material.SmoothPlastic
	main.Color = bodyColor
	main.Parent = model

	-- Windows on all 4 faces (2 rows)
	addWindowsToFace(model, "z", frontZ + 0.15, centerX, bodyW, BUILDING_BASE, winFloors, winFloorH, 2.8 * scale, 4 * scale, 1.8, winColor, 0.7)
	addWindowsToFace(model, "z", backZ - 0.15, centerX, bodyW, BUILDING_BASE, winFloors, winFloorH, 2.8 * scale, 4 * scale, 1.8, winColor, 0.3)
	addWindowsToFace(model, "x", centerX - halfW - 0.15, centerZ, bodyD, BUILDING_BASE, winFloors, winFloorH, 2.8 * scale, 4 * scale, 1.8, winColor, 0.5)
	addWindowsToFace(model, "x", centerX + halfW + 0.15, centerZ, bodyD, BUILDING_BASE, winFloors, winFloorH, 2.8 * scale, 4 * scale, 1.8, winColor, 0.5)

	-- Floor band between stories
	local bandY = BUILDING_BASE + bodyH * 0.48
	local band = Instance.new("Part")
	band.Name = "FloorBand"
	band.Size = Vector3.new(bodyW + 0.3, 0.7 * scale, bodyD + 0.3)
	band.Position = Vector3.new(centerX, bandY, centerZ)
	band.Anchored = true
	band.CanCollide = false
	band.Material = Enum.Material.SmoothPlastic
	band.Color = trimColor
	band.Parent = model

	-- Roof balustrade
	local balH = 2 * scale
	local balustrade = Instance.new("Part")
	balustrade.Name = "Balustrade"
	balustrade.Size = Vector3.new(bodyW + 0.5, balH, bodyD + 0.5)
	balustrade.Position = Vector3.new(centerX, BUILDING_BASE + bodyH + balH / 2, centerZ)
	balustrade.Anchored = true
	balustrade.Material = Enum.Material.SmoothPlastic
	balustrade.Color = trimColor
	balustrade.Parent = model

	-- Flat roof
	local roofCap = Instance.new("Part")
	roofCap.Name = "RoofCap"
	roofCap.Size = Vector3.new(bodyW - 1 * scale, 0.4 * scale, bodyD - 1 * scale)
	roofCap.Position = Vector3.new(centerX, BUILDING_BASE + bodyH + balH + 0.2 * scale, centerZ)
	roofCap.Anchored = true
	roofCap.Material = Enum.Material.Metal
	roofCap.Color = roofColor
	roofCap.Parent = model

	---------------------------------------------------------------------------
	-- 2. SOUTH PORTICO — Semicircular curved colonnade
	---------------------------------------------------------------------------
	local porticoRadius = 14 * scale
	local NUM_COLUMNS = 8
	local colRadius = 1 * scale
	local colHeight = bodyH - 3 * scale

	for i = 0, NUM_COLUMNS do
		local angle = math.rad(-90 + i * (180 / NUM_COLUMNS))
		local cx = centerX + porticoRadius * math.sin(angle)
		local cz = frontZ + porticoRadius * math.cos(angle)

		local col = Instance.new("Part")
		col.Name = "SouthColumn"
		col.Shape = Enum.PartType.Cylinder
		col.Size = Vector3.new(colHeight, colRadius * 2, colRadius * 2)
		col.CFrame = CFrame.new(cx, BUILDING_BASE + colHeight / 2, cz)
			* CFrame.Angles(0, 0, math.rad(90))
		col.Anchored = true
		col.Material = Enum.Material.SmoothPlastic
		col.Color = bodyColor
		col.Parent = model
	end

	-- Semicircular base under portico columns
	local baseH = 2 * scale
	local basePart = Instance.new("Part")
	basePart.Name = "PorticoBase"
	basePart.Shape = Enum.PartType.Cylinder
	basePart.Size = Vector3.new(baseH, porticoRadius * 2 + 2 * scale, porticoRadius * 2 + 2 * scale)
	basePart.CFrame = CFrame.new(centerX, BUILDING_BASE + baseH / 2 + 0.5, frontZ)
		* CFrame.Angles(0, 0, math.rad(90))
	basePart.Anchored = true
	basePart.Material = Enum.Material.SmoothPlastic
	basePart.Color = trimColor
	basePart.Parent = model

	-- Entablature cap on top of columns
	local capH = 2 * scale
	local capPart = Instance.new("Part")
	capPart.Name = "PorticoCap"
	capPart.Shape = Enum.PartType.Cylinder
	capPart.Size = Vector3.new(capH, porticoRadius * 2 + 2 * scale, porticoRadius * 2 + 2 * scale)
	capPart.CFrame = CFrame.new(centerX, BUILDING_BASE + colHeight + capH / 2, frontZ)
		* CFrame.Angles(0, 0, math.rad(90))
	capPart.Anchored = true
	capPart.Material = Enum.Material.SmoothPlastic
	capPart.Color = trimColor
	capPart.Parent = model

	---------------------------------------------------------------------------
	-- 3. AMERICAN FLAG
	---------------------------------------------------------------------------
	local poleH = 10 * scale
	local pole = Instance.new("Part")
	pole.Name = "FlagPole"
	pole.Shape = Enum.PartType.Cylinder
	pole.Size = Vector3.new(poleH, 0.3 * scale, 0.3 * scale)
	pole.CFrame = CFrame.new(centerX, BUILDING_BASE + bodyH + balH + poleH / 2, centerZ)
		* CFrame.Angles(0, 0, math.rad(90))
	pole.Anchored = true
	pole.Material = Enum.Material.Metal
	pole.Color = Color3.fromRGB(180, 180, 180)
	pole.Parent = model

	local flagW = 5 * scale
	local flagH = 3.5 * scale
	local flagY = BUILDING_BASE + bodyH + balH + poleH - flagH / 2

	local stripes = Instance.new("Part")
	stripes.Name = "FlagStripes"
	stripes.Size = Vector3.new(flagW, flagH, 0.15 * scale)
	stripes.Position = Vector3.new(centerX + flagW / 2 + 0.2 * scale, flagY, centerZ + 0.2 * scale)
	stripes.Anchored = true
	stripes.CanCollide = false
	stripes.Material = Enum.Material.SmoothPlastic
	stripes.Color = Color3.fromRGB(200, 40, 40)
	stripes.Parent = model

	local canton = Instance.new("Part")
	canton.Name = "FlagCanton"
	canton.Size = Vector3.new(flagW * 0.4, flagH * 0.55, 0.2 * scale)
	canton.Position = Vector3.new(centerX + flagW * 0.2 + 0.2 * scale, flagY + flagH * 0.22, centerZ + 0.25 * scale)
	canton.Anchored = true
	canton.CanCollide = false
	canton.Material = Enum.Material.SmoothPlastic
	canton.Color = Color3.fromRGB(40, 50, 120)
	canton.Parent = model

	---------------------------------------------------------------------------
	-- 4. BLACK IRON FENCE — enclosing the property
	---------------------------------------------------------------------------
	local fenceColor = Color3.fromRGB(20, 20, 25)
	local fenceH = 10 * scale
	local barSpacing = 3 * scale
	local barThick = 0.35 * scale
	local railH = 0.5 * scale
	local tipSize = 0.8 * scale

	local function buildFence(x1, z1, x2, z2)
		local dx = x2 - x1
		local dz = z2 - z1
		local len = math.sqrt(dx * dx + dz * dz)
		local fcx, fcz = (x1 + x2) / 2, (z1 + z2) / 2
		local angle = math.atan2(dx, dz)

		-- Rails (top and bottom)
		for _, ry in ipairs({ BUILDING_BASE + 1 * scale, BUILDING_BASE + fenceH - 1 * scale }) do
			local rail = Instance.new("Part")
			rail.Name = "FenceRail"
			rail.Size = Vector3.new(railH, railH, len)
			rail.CFrame = CFrame.new(fcx, ry, fcz) * CFrame.Angles(0, angle, 0)
			rail.Anchored = true
			rail.CanCollide = false
			rail.Material = Enum.Material.Metal
			rail.Color = fenceColor
			rail.Parent = model
		end

		-- Bars + spear tips
		local numBars = math.floor(len / barSpacing)
		for i = 0, numBars do
			local t = numBars > 0 and (i / numBars) or 0.5
			local bx = x1 + dx * t
			local bz = z1 + dz * t

			local bar = Instance.new("Part")
			bar.Name = "FenceBar"
			bar.Size = Vector3.new(barThick, fenceH, barThick)
			bar.Position = Vector3.new(bx, BUILDING_BASE + fenceH / 2, bz)
			bar.Anchored = true
			bar.CanCollide = false
			bar.Material = Enum.Material.Metal
			bar.Color = fenceColor
			bar.Parent = model

			local tip = Instance.new("Part")
			tip.Name = "SpearTip"
			tip.Size = Vector3.new(tipSize, tipSize, tipSize)
			tip.CFrame = CFrame.new(bx, BUILDING_BASE + fenceH + tipSize * 0.4, bz)
				* CFrame.Angles(0, 0, math.rad(45))
			tip.Anchored = true
			tip.CanCollide = false
			tip.Material = Enum.Material.Metal
			tip.Color = fenceColor
			tip.Parent = model
		end
	end

	-- Fence corners: symmetric around center
	local margin = 30 * scale
	local fenceLeft  = centerX - halfW - margin
	local fenceRight = centerX + halfW + margin
	local fenceFront = frontZ + porticoRadius + 25 * scale
	local fenceBack  = backZ - 10 * scale

	buildFence(fenceLeft, fenceFront, fenceRight, fenceFront)  -- front
	buildFence(fenceLeft, fenceBack, fenceLeft, fenceFront)    -- left side
	buildFence(fenceRight, fenceBack, fenceRight, fenceFront)  -- right side
	buildFence(fenceLeft, fenceBack, fenceRight, fenceBack)    -- back

	if options.parent then
		model.Parent = options.parent
	end

	return model
end

--------------------------------------------------------------------------------
-- AIRPORT TERMINAL
-- Modern 160-stud glass-front terminal: 2 floors, glass storefront with
-- mullions, canopy, "TERMINAL" neon letters, check-in desks, interior lights.
-- Options: parent, scale
--------------------------------------------------------------------------------

function AssetLibrary.createAirportTerminal(centerX, centerZ, options)
	options = options or {}
	local scale = options.scale or 1

	local building = Instance.new("Model")
	building.Name = "AirportTerminal"

	local FACADE = 160 * scale
	local B_DEPTH = 28 * scale
	local FLOOR_H = 12 * scale
	local HEIGHT = 2 * FLOOR_H
	local wallColor = Color3.fromRGB(215, 220, 230)
	local glassColor = Color3.fromRGB(150, 200, 255)

	local frontZ = centerZ + B_DEPTH / 2 + 0.2
	local backZ = centerZ - B_DEPTH / 2

	-- Back wall
	local back = Instance.new("Part")
	back.Name = "BackWall"
	back.Size = Vector3.new(FACADE, HEIGHT, 0.5)
	back.Position = Vector3.new(centerX, BUILDING_BASE + HEIGHT / 2, backZ)
	back.Anchored = true
	back.Material = Enum.Material.SmoothPlastic
	back.Color = wallColor
	back.Parent = building

	-- Side walls
	for i = -1, 1, 2 do
		local side = Instance.new("Part")
		side.Name = "SideWall"
		side.Size = Vector3.new(0.5, HEIGHT, B_DEPTH)
		side.Position = Vector3.new(centerX + i * FACADE / 2, BUILDING_BASE + HEIGHT / 2, centerZ)
		side.Anchored = true
		side.Material = Enum.Material.SmoothPlastic
		side.Color = wallColor
		side.Parent = building
	end

	-- Upper front wall (floor 2)
	local upperH = HEIGHT - FLOOR_H
	local upperFront = Instance.new("Part")
	upperFront.Name = "UpperFrontWall"
	upperFront.Size = Vector3.new(FACADE, upperH, 0.5)
	upperFront.Position = Vector3.new(centerX, BUILDING_BASE + FLOOR_H + upperH / 2, frontZ)
	upperFront.Anchored = true
	upperFront.Material = Enum.Material.SmoothPlastic
	upperFront.Color = wallColor
	upperFront.Parent = building

	-- Upper windows (front Z face)
	local upWinW = 3.5 * scale
	local upWinH = 5 * scale
	local upWinY = BUILDING_BASE + FLOOR_H + FLOOR_H * 0.45
	local numUpWin = math.floor(FACADE / (upWinW + 2.5))
	local totalUpW = numUpWin * upWinW + (numUpWin - 1) * 2.5
	local startOff = -totalUpW / 2 + upWinW / 2
	for w = 1, numUpWin do
		local off = startOff + (w - 1) * (upWinW + 2.5)
		local win = Instance.new("Part")
		win.Size = Vector3.new(upWinW, upWinH, 0.3)
		win.Position = Vector3.new(centerX + off, upWinY, frontZ)
		win.Anchored = true
		win.CanCollide = false
		win.Material = math.random() < 0.6 and Enum.Material.Neon or Enum.Material.Glass
		win.Color = math.random() < 0.6 and glassColor or Color3.fromRGB(80, 120, 160)
		win.Parent = building
	end

	-- Glass storefront (floor 1)
	local glassH = FLOOR_H * 0.88
	local glassY = BUILDING_BASE + glassH / 2 + 0.2
	local glass = Instance.new("Part")
	glass.Size = Vector3.new(FACADE * 0.95, glassH, 0.3)
	glass.Position = Vector3.new(centerX, glassY, frontZ)
	glass.Anchored = true
	glass.CanCollide = false
	glass.Material = Enum.Material.Glass
	glass.Color = Color3.fromRGB(200, 230, 255)
	glass.Transparency = 0.55
	glass.Parent = building

	-- Mullions
	local numMullions = 28
	local mullionSpacing = (FACADE * 0.95) / (numMullions + 1)
	for m = 1, numMullions do
		local mullion = Instance.new("Part")
		mullion.Size = Vector3.new(0.15, glassH, 0.15)
		mullion.Position = Vector3.new(centerX - (FACADE * 0.95) / 2 + m * mullionSpacing, glassY, frontZ + 0.1)
		mullion.Anchored = true
		mullion.CanCollide = false
		mullion.Material = Enum.Material.Metal
		mullion.Color = Color3.fromRGB(120, 120, 130)
		mullion.Parent = building
	end

	-- Canopy
	local awning = Instance.new("Part")
	awning.Size = Vector3.new(FACADE * 0.92, 0.5, 5 * scale)
	awning.Position = Vector3.new(centerX, BUILDING_BASE + FLOOR_H - 0.5, frontZ + 2.5 * scale)
	awning.Anchored = true
	awning.Material = Enum.Material.Metal
	awning.Color = Color3.fromRGB(60, 65, 75)
	awning.Parent = building

	-- "T E R M I N A L" neon letter signs
	local letters = { "T", "E", "R", "M", "I", "N", "A", "L" }
	local letterH = 4 * scale
	local letterW = 4 * scale
	local letterGap = 3 * scale
	local totalLettersW = #letters * letterW + (#letters - 1) * letterGap
	local letterStartX = centerX - totalLettersW / 2 + letterW / 2
	local letterY = BUILDING_BASE + FLOOR_H + letterH / 2 + 1

	for i, letter in ipairs(letters) do
		local lX = letterStartX + (i - 1) * (letterW + letterGap)
		local sign = Instance.new("Part")
		sign.Name = "Letter_" .. letter
		sign.Size = Vector3.new(letterW, letterH, 0.4)
		sign.Position = Vector3.new(lX, letterY, frontZ + 0.3)
		sign.Anchored = true
		sign.CanCollide = false
		sign.Material = Enum.Material.Neon
		sign.Color = Color3.fromRGB(50, 180, 255)
		sign.Parent = building

		local gui = Instance.new("SurfaceGui")
		gui.Face = Enum.NormalId.Back
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud = 50
		gui.Parent = sign

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, 0, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = letter
		lbl.TextColor3 = Color3.new(1, 1, 1)
		lbl.TextScaled = true
		lbl.Font = Enum.Font.GothamBold
		lbl.Parent = gui
	end

	-- Interior floor
	local iFloor = Instance.new("Part")
	iFloor.Size = Vector3.new(FACADE * 0.9, 0.3, B_DEPTH * 0.85)
	iFloor.Position = Vector3.new(centerX, BUILDING_BASE + 0.15, centerZ)
	iFloor.Anchored = true
	iFloor.CanCollide = false
	iFloor.Material = Enum.Material.SmoothPlastic
	iFloor.Color = Color3.fromRGB(200, 195, 185)
	iFloor.Parent = building

	-- Interior ceiling light
	local cLight = Instance.new("Part")
	cLight.Size = Vector3.new(FACADE * 0.7, 0.3, B_DEPTH * 0.5)
	cLight.Position = Vector3.new(centerX, BUILDING_BASE + FLOOR_H - 0.3, centerZ)
	cLight.Anchored = true
	cLight.CanCollide = false
	cLight.Material = Enum.Material.Neon
	cLight.Color = Color3.fromRGB(255, 245, 220)
	cLight.Parent = building

	local ptLight = Instance.new("PointLight")
	ptLight.Color = Color3.fromRGB(255, 240, 200)
	ptLight.Brightness = 0.6
	ptLight.Range = 30
	ptLight.Parent = cLight

	-- Check-in desks (9 along X)
	local DESK_COUNT = 9
	local deskW = 8 * scale
	local deskH = 3.5 * scale
	local deskD = 2.5 * scale
	local deskGap = 5 * scale
	local totalDesksW = DESK_COUNT * deskW + (DESK_COUNT - 1) * deskGap
	local deskStartX = centerX - totalDesksW / 2 + deskW / 2

	for d = 0, DESK_COUNT - 1 do
		local dX = deskStartX + d * (deskW + deskGap)
		local front = Instance.new("Part")
		front.Size = Vector3.new(deskW, deskH, 0.4)
		front.Position = Vector3.new(dX, BUILDING_BASE + deskH / 2, centerZ + deskD / 2)
		front.Anchored = true
		front.CanCollide = false
		front.Material = Enum.Material.SmoothPlastic
		front.Color = Color3.fromRGB(60, 65, 75)
		front.Parent = building

		local top = Instance.new("Part")
		top.Size = Vector3.new(deskW, 0.3, deskD)
		top.Position = Vector3.new(dX, BUILDING_BASE + deskH, centerZ)
		top.Anchored = true
		top.CanCollide = false
		top.Material = Enum.Material.SmoothPlastic
		top.Color = Color3.fromRGB(180, 180, 190)
		top.Parent = building
	end

	-- Roof
	local roof = Instance.new("Part")
	roof.Size = Vector3.new(FACADE + 0.5, 0.5, B_DEPTH + 0.5)
	roof.Position = Vector3.new(centerX, BUILDING_BASE + HEIGHT + 0.25, centerZ)
	roof.Anchored = true
	roof.Material = Enum.Material.Metal
	roof.Color = Color3.fromRGB(50, 50, 55)
	roof.Parent = building

	if options.parent then
		building.Parent = options.parent
	end

	return building
end

--------------------------------------------------------------------------------
-- COMMAND CENTER
-- Glass cube mission control (Houston-style): dark-tinted glass walls,
-- giant telemetry screen with SurfaceGui, console desks with monitors,
-- side status screens, "MISSION CONTROL" sign. Returns animation data
-- for countdown/telemetry ticking.
-- Options: parent, scale
--------------------------------------------------------------------------------

function AssetLibrary.createCommandCenter(centerX, centerZ, options)
	options = options or {}
	local scale = options.scale or 1

	local model = Instance.new("Model")
	model.Name = "CommandCenter"

	-- Cube dimensions
	local cubeW = 40 * scale  -- width along Z
	local cubeH = 24 * scale  -- height
	local cubeD = 36 * scale  -- depth along X
	local slabW = 44 * scale
	local slabD = 40 * scale

	local floorY = BUILDING_BASE + 0.5 * scale

	---------------------------------------------------------------------------
	-- BASE SLAB (dark concrete)
	---------------------------------------------------------------------------
	local slab = Instance.new("Part")
	slab.Name = "BaseSlab"
	slab.Size = Vector3.new(slabD, 0.5 * scale, slabW)
	slab.Position = Vector3.new(centerX, BUILDING_BASE + 0.25 * scale, centerZ)
	slab.Anchored = true
	slab.Material = Enum.Material.Concrete
	slab.Color = Color3.fromRGB(60, 60, 65)
	slab.Parent = model

	-- Interior dark floor
	local floor = Instance.new("Part")
	floor.Name = "InteriorFloor"
	floor.Size = Vector3.new(cubeD - 1, 0.2, cubeW - 1)
	floor.Position = Vector3.new(centerX, floorY + 0.1, centerZ)
	floor.Anchored = true
	floor.CanCollide = false
	floor.Material = Enum.Material.SmoothPlastic
	floor.Color = Color3.fromRGB(30, 35, 45)
	floor.Parent = model

	---------------------------------------------------------------------------
	-- STEEL FRAME (4 corner posts)
	---------------------------------------------------------------------------
	local postThick = 0.6 * scale
	local postH = cubeH
	for dx = -1, 1, 2 do
		for dz = -1, 1, 2 do
			local post = Instance.new("Part")
			post.Name = "CornerPost"
			post.Size = Vector3.new(postThick, postH, postThick)
			post.Position = Vector3.new(
				centerX + dx * (cubeD / 2 - postThick / 2),
				floorY + postH / 2,
				centerZ + dz * (cubeW / 2 - postThick / 2)
			)
			post.Anchored = true
			post.Material = Enum.Material.DiamondPlate
			post.Color = Color3.fromRGB(80, 85, 95)
			post.Parent = model
		end
	end

	---------------------------------------------------------------------------
	-- GLASS PANELS (dark blue-tinted, all 4 walls)
	---------------------------------------------------------------------------
	local mullionThick = 0.3 * scale
	local midY = floorY + cubeH / 2
	local glassColor = Color3.fromRGB(100, 140, 200)

	local function buildWall(axis, faceCoord, wallWidth, panelCount)
		local pw = (wallWidth - postThick * 2 - mullionThick * (panelCount - 1)) / panelCount
		local startOffset = -wallWidth / 2 + postThick + pw / 2
		local panelH = (cubeH - mullionThick) / 2

		for row = 0, 1 do
			local rowY = floorY + mullionThick / 2 + panelH / 2 + row * (panelH + mullionThick)

			for col = 0, panelCount - 1 do
				local offset = startOffset + col * (pw + mullionThick)

				local panel = Instance.new("Part")
				panel.Name = "GlassPanel"
				if axis == "x" then
					panel.Size = Vector3.new(0.2, panelH, pw)
					panel.Position = Vector3.new(faceCoord, rowY, centerZ + offset)
				else
					panel.Size = Vector3.new(pw, panelH, 0.2)
					panel.Position = Vector3.new(centerX + offset, rowY, faceCoord)
				end
				panel.Anchored = true
				panel.CanCollide = false
				panel.Material = Enum.Material.SmoothPlastic
				panel.Color = glassColor
				panel.Transparency = 0.8
				panel.Parent = model
			end

			if row == 0 then
				local hMullion = Instance.new("Part")
				hMullion.Name = "HMullion"
				if axis == "x" then
					hMullion.Size = Vector3.new(mullionThick, mullionThick, wallWidth - postThick * 2)
					hMullion.Position = Vector3.new(faceCoord, midY, centerZ)
				else
					hMullion.Size = Vector3.new(wallWidth - postThick * 2, mullionThick, mullionThick)
					hMullion.Position = Vector3.new(centerX, midY, faceCoord)
				end
				hMullion.Anchored = true
				hMullion.CanCollide = false
				hMullion.Material = Enum.Material.DiamondPlate
				hMullion.Color = Color3.fromRGB(80, 85, 95)
				hMullion.Parent = model
			end
		end

		for col = 1, panelCount - 1 do
			local offset = startOffset + (col - 1) * (pw + mullionThick) + pw + mullionThick / 2
			local vMullion = Instance.new("Part")
			vMullion.Name = "VMullion"
			if axis == "x" then
				vMullion.Size = Vector3.new(mullionThick, cubeH, mullionThick)
				vMullion.Position = Vector3.new(faceCoord, floorY + cubeH / 2, centerZ + offset)
			else
				vMullion.Size = Vector3.new(mullionThick, cubeH, mullionThick)
				vMullion.Position = Vector3.new(centerX + offset, floorY + cubeH / 2, faceCoord)
			end
			vMullion.Anchored = true
			vMullion.CanCollide = false
			vMullion.Material = Enum.Material.DiamondPlate
			vMullion.Color = Color3.fromRGB(80, 85, 95)
			vMullion.Parent = model
		end
	end

	buildWall("x", centerX - cubeD / 2, cubeW, 4)
	buildWall("x", centerX + cubeD / 2, cubeW, 4)
	buildWall("z", centerZ - cubeW / 2, cubeD, 4)
	buildWall("z", centerZ + cubeW / 2, cubeD, 4)

	-- Flat roof
	local roof = Instance.new("Part")
	roof.Name = "Roof"
	roof.Size = Vector3.new(cubeD + 0.4, 0.4 * scale, cubeW + 0.4)
	roof.Position = Vector3.new(centerX, floorY + cubeH + 0.2 * scale, centerZ)
	roof.Anchored = true
	roof.Material = Enum.Material.DiamondPlate
	roof.Color = Color3.fromRGB(60, 65, 75)
	roof.Parent = model

	---------------------------------------------------------------------------
	-- GIANT SCREEN (back wall, -Z side — consoles face toward it)
	---------------------------------------------------------------------------
	local screenW = cubeW * 0.85
	local screenH = cubeH * 0.65
	local screenThick = 0.4
	local screenX = centerX
	local screenZ = centerZ - (cubeW / 2 - 1.5 * scale)
	local screenY = floorY + cubeH * 0.55

	local screen = Instance.new("Part")
	screen.Name = "MainScreen"
	screen.Size = Vector3.new(screenW, screenH, screenThick)
	screen.Position = Vector3.new(screenX, screenY, screenZ)
	screen.Anchored = true
	screen.CanCollide = false
	screen.Material = Enum.Material.Neon
	screen.Color = Color3.fromRGB(10, 20, 40)
	screen.Parent = model

	-- SurfaceGui on the screen face (facing +Z toward consoles)
	local screenGui = Instance.new("SurfaceGui")
	screenGui.Name = "MissionGui"
	screenGui.Face = Enum.NormalId.Front
	screenGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	screenGui.PixelsPerStud = 24
	screenGui.LightInfluence = 0
	screenGui.Brightness = 1.5
	screenGui.Parent = screen

	-- Background frame
	local bg = Instance.new("Frame")
	bg.Name = "BG"
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.fromRGB(5, 12, 30)
	bg.BorderSizePixel = 0
	bg.Parent = screenGui

	-- "MISSION CONTROL" header
	local header = Instance.new("TextLabel")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0.12, 0)
	header.Position = UDim2.new(0, 0, 0.01, 0)
	header.BackgroundTransparency = 1
	header.Text = "MISSION CONTROL"
	header.TextColor3 = Color3.fromRGB(0, 200, 255)
	header.TextScaled = true
	header.Font = Enum.Font.Code
	header.Parent = bg

	-- Thin cyan line under header
	local headerLine = Instance.new("Frame")
	headerLine.Name = "HeaderLine"
	headerLine.Size = UDim2.new(0.9, 0, 0.004, 0)
	headerLine.Position = UDim2.new(0.05, 0, 0.13, 0)
	headerLine.BackgroundColor3 = Color3.fromRGB(0, 180, 220)
	headerLine.BorderSizePixel = 0
	headerLine.Parent = bg

	-- COUNTDOWN display
	local countdown = Instance.new("TextLabel")
	countdown.Name = "Countdown"
	countdown.Size = UDim2.new(0.4, 0, 0.18, 0)
	countdown.Position = UDim2.new(0.3, 0, 0.16, 0)
	countdown.BackgroundTransparency = 1
	countdown.Text = "T- 00:03:42"
	countdown.TextColor3 = Color3.fromRGB(255, 80, 60)
	countdown.TextScaled = true
	countdown.Font = Enum.Font.Code
	countdown.Parent = bg

	-- Telemetry data columns (left and right)
	local telemetryData = {
		{ col = 0, row = 0, label = "ALT", value = "0.000 km", color = Color3.fromRGB(0, 255, 120) },
		{ col = 0, row = 1, label = "VEL", value = "0.000 km/s", color = Color3.fromRGB(0, 255, 120) },
		{ col = 0, row = 2, label = "ACC", value = "0.00 g", color = Color3.fromRGB(0, 255, 120) },
		{ col = 0, row = 3, label = "FUEL", value = "100.0%", color = Color3.fromRGB(0, 255, 120) },
		{ col = 0, row = 4, label = "TEMP", value = "22.4 C", color = Color3.fromRGB(0, 255, 120) },
		{ col = 1, row = 0, label = "STAGE", value = "1 / GROUND", color = Color3.fromRGB(255, 200, 0) },
		{ col = 1, row = 1, label = "PITCH", value = "90.00 deg", color = Color3.fromRGB(0, 200, 255) },
		{ col = 1, row = 2, label = "YAW", value = "0.00 deg", color = Color3.fromRGB(0, 200, 255) },
		{ col = 1, row = 3, label = "ROLL", value = "0.00 deg", color = Color3.fromRGB(0, 200, 255) },
		{ col = 1, row = 4, label = "COMM", value = "NOMINAL", color = Color3.fromRGB(0, 255, 120) },
	}

	local rowH = 0.09
	local startY = 0.38

	for _, d in ipairs(telemetryData) do
		local colX = d.col == 0 and 0.03 or 0.52
		local rowY2 = startY + d.row * (rowH + 0.02)

		local lbl = Instance.new("TextLabel")
		lbl.Name = d.label .. "Label"
		lbl.Size = UDim2.new(0.15, 0, rowH, 0)
		lbl.Position = UDim2.new(colX, 0, rowY2, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = d.label
		lbl.TextColor3 = Color3.fromRGB(120, 140, 160)
		lbl.TextScaled = true
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Font = Enum.Font.Code
		lbl.Parent = bg

		local val = Instance.new("TextLabel")
		val.Name = d.label .. "Value"
		val.Size = UDim2.new(0.28, 0, rowH, 0)
		val.Position = UDim2.new(colX + 0.16, 0, rowY2, 0)
		val.BackgroundTransparency = 1
		val.Text = d.value
		val.TextColor3 = d.color
		val.TextScaled = true
		val.TextXAlignment = Enum.TextXAlignment.Left
		val.Font = Enum.Font.Code
		val.Parent = bg
	end

	-- Status bar at bottom
	local statusBar = Instance.new("Frame")
	statusBar.Name = "StatusBar"
	statusBar.Size = UDim2.new(0.96, 0, 0.004, 0)
	statusBar.Position = UDim2.new(0.02, 0, 0.92, 0)
	statusBar.BackgroundColor3 = Color3.fromRGB(0, 100, 140)
	statusBar.BorderSizePixel = 0
	statusBar.Parent = bg

	local statusText = Instance.new("TextLabel")
	statusText.Name = "StatusText"
	statusText.Size = UDim2.new(0.96, 0, 0.06, 0)
	statusText.Position = UDim2.new(0.02, 0, 0.93, 0)
	statusText.BackgroundTransparency = 1
	statusText.Text = "ALL SYSTEMS GO  |  WEATHER: CLEAR  |  WIND: 3.2 KTS NE  |  RANGE SAFETY: GREEN"
	statusText.TextColor3 = Color3.fromRGB(0, 180, 80)
	statusText.TextScaled = true
	statusText.Font = Enum.Font.Code
	statusText.Parent = bg

	-- Screen glow light
	local screenLight = Instance.new("PointLight")
	screenLight.Color = Color3.fromRGB(0, 140, 255)
	screenLight.Brightness = 0.6
	screenLight.Range = 20
	screenLight.Parent = screen

	---------------------------------------------------------------------------
	-- SIDE SCREENS (both Z walls, status displays)
	---------------------------------------------------------------------------
	local sideScreenW = cubeD * 0.5
	local sideScreenH = cubeH * 0.4
	local sideLabels = {
		{ sz = -1, title = "TRAJECTORY", statuses = { "GUIDANCE: OK", "TRACKING: OK", "FTS: ARMED", "RANGE: CLR" } },
		{ sz = 1,  title = "SYSTEMS",    statuses = { "LOX: FULL", "LH2: FULL", "HYDRAUL: OK", "POWER: NOM" } },
	}

	for _, side in ipairs(sideLabels) do
		local sideScreen = Instance.new("Part")
		sideScreen.Name = "SideScreen"
		sideScreen.Size = Vector3.new(sideScreenW, sideScreenH, screenThick)
		sideScreen.Position = Vector3.new(
			centerX,
			floorY + cubeH * 0.6,
			centerZ + side.sz * (cubeW / 2 - 1.5 * scale)
		)
		sideScreen.Anchored = true
		sideScreen.CanCollide = false
		sideScreen.Material = Enum.Material.Neon
		sideScreen.Color = Color3.fromRGB(10, 20, 40)
		sideScreen.Parent = model

		local sideGui = Instance.new("SurfaceGui")
		sideGui.Name = "SideGui"
		sideGui.Face = side.sz > 0 and Enum.NormalId.Front or Enum.NormalId.Back
		sideGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		sideGui.PixelsPerStud = 20
		sideGui.LightInfluence = 0
		sideGui.Brightness = 1.5
		sideGui.Parent = sideScreen

		local sideBg = Instance.new("Frame")
		sideBg.Size = UDim2.new(1, 0, 1, 0)
		sideBg.BackgroundColor3 = Color3.fromRGB(5, 15, 35)
		sideBg.BorderSizePixel = 0
		sideBg.Parent = sideGui

		local sideTitle = Instance.new("TextLabel")
		sideTitle.Size = UDim2.new(1, 0, 0.15, 0)
		sideTitle.BackgroundTransparency = 1
		sideTitle.Text = side.title
		sideTitle.TextColor3 = Color3.fromRGB(0, 180, 255)
		sideTitle.TextScaled = true
		sideTitle.Font = Enum.Font.Code
		sideTitle.Parent = sideBg

		for si, st in ipairs(side.statuses) do
			local stLbl = Instance.new("TextLabel")
			stLbl.Size = UDim2.new(0.9, 0, 0.16, 0)
			stLbl.Position = UDim2.new(0.05, 0, 0.18 + (si - 1) * 0.2, 0)
			stLbl.BackgroundTransparency = 1
			stLbl.Text = st
			stLbl.TextColor3 = st:find("ARM") and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(0, 255, 120)
			stLbl.TextScaled = true
			stLbl.TextXAlignment = Enum.TextXAlignment.Left
			stLbl.Font = Enum.Font.Code
			stLbl.Parent = sideBg
		end

		local sideLight = Instance.new("PointLight")
		sideLight.Color = Color3.fromRGB(0, 100, 200)
		sideLight.Brightness = 0.3
		sideLight.Range = 12
		sideLight.Parent = sideScreen
	end

	---------------------------------------------------------------------------
	-- CONSOLE DESKS (3 rows facing the main screen, toward -Z)
	---------------------------------------------------------------------------
	local deskW2 = cubeW * 0.7
	local deskD2 = 3 * scale
	local deskH2 = 3.5 * scale
	local deskOffsets = { -8 * scale, 0, 8 * scale }

	for _, dx in ipairs(deskOffsets) do
		-- Desk surface
		local desk = Instance.new("Part")
		desk.Name = "ConsoleDesk"
		desk.Size = Vector3.new(deskW2 / 3 - 1 * scale, deskH2, deskD2)
		desk.Position = Vector3.new(
			centerX + dx,
			floorY + deskH2 / 2,
			centerZ + 6 * scale
		)
		desk.Anchored = true
		desk.Material = Enum.Material.SmoothPlastic
		desk.Color = Color3.fromRGB(40, 45, 55)
		desk.Parent = model

		-- Monitor on each desk
		local monitor = Instance.new("Part")
		monitor.Name = "Monitor"
		monitor.Size = Vector3.new(3.5 * scale, 2.5 * scale, 0.2)
		monitor.Position = Vector3.new(
			centerX + dx,
			floorY + deskH2 + 1.5 * scale,
			centerZ + 5 * scale
		)
		monitor.Anchored = true
		monitor.CanCollide = false
		monitor.Material = Enum.Material.Neon
		monitor.Color = Color3.fromRGB(20, 60, 100)
		monitor.Parent = model
	end

	-- Chairs at each desk
	for _, dx in ipairs(deskOffsets) do
		local chair = Instance.new("Part")
		chair.Name = "Chair"
		chair.Size = Vector3.new(2 * scale, 3 * scale, 2 * scale)
		chair.Position = Vector3.new(
			centerX + dx,
			floorY + 1.5 * scale,
			centerZ + 10 * scale
		)
		chair.Anchored = true
		chair.Material = Enum.Material.SmoothPlastic
		chair.Color = Color3.fromRGB(25, 25, 35)
		chair.Parent = model

		local chairBack = Instance.new("Part")
		chairBack.Name = "ChairBack"
		chairBack.Size = Vector3.new(2 * scale, 4 * scale, 0.5 * scale)
		chairBack.Position = Vector3.new(
			centerX + dx,
			floorY + 2 * scale,
			centerZ + 11.2 * scale
		)
		chairBack.Anchored = true
		chairBack.Material = Enum.Material.SmoothPlastic
		chairBack.Color = Color3.fromRGB(25, 25, 35)
		chairBack.Parent = model
	end

	---------------------------------------------------------------------------
	-- CEILING BLUE LIGHT
	---------------------------------------------------------------------------
	local ceilingLight = Instance.new("Part")
	ceilingLight.Name = "CeilingLight"
	ceilingLight.Size = Vector3.new(cubeD * 0.5, 0.3, cubeW * 0.5)
	ceilingLight.Position = Vector3.new(centerX, floorY + cubeH - 0.3, centerZ)
	ceilingLight.Anchored = true
	ceilingLight.CanCollide = false
	ceilingLight.Material = Enum.Material.Neon
	ceilingLight.Color = Color3.fromRGB(20, 60, 140)
	ceilingLight.Parent = model

	local pointLight = Instance.new("PointLight")
	pointLight.Color = Color3.fromRGB(40, 100, 200)
	pointLight.Brightness = 0.5
	pointLight.Range = 24
	pointLight.Parent = ceilingLight

	---------------------------------------------------------------------------
	-- "MISSION CONTROL" SIGN (on front +Z face)
	---------------------------------------------------------------------------
	local signPart = Instance.new("Part")
	signPart.Name = "SignPart"
	signPart.Size = Vector3.new(18 * scale, 3 * scale, 0.4)
	signPart.Position = Vector3.new(centerX, floorY + cubeH * 0.85, centerZ + cubeW / 2 + 0.25)
	signPart.Anchored = true
	signPart.CanCollide = false
	signPart.Material = Enum.Material.SmoothPlastic
	signPart.Color = Color3.fromRGB(20, 30, 50)
	signPart.Transparency = 1
	signPart.Parent = model

	local signGui = Instance.new("SurfaceGui")
	signGui.Name = "SignGui"
	signGui.Face = Enum.NormalId.Front
	signGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	signGui.PixelsPerStud = 32
	signGui.LightInfluence = 0
	signGui.Brightness = 2
	signGui.Parent = signPart

	local signLabel = Instance.new("TextLabel")
	signLabel.Size = UDim2.new(1, 0, 1, 0)
	signLabel.BackgroundTransparency = 1
	signLabel.Text = "MISSION CONTROL"
	signLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
	signLabel.TextScaled = true
	signLabel.Font = Enum.Font.Code
	signLabel.Parent = signGui

	local signGlow = Instance.new("PointLight")
	signGlow.Color = Color3.fromRGB(0, 160, 255)
	signGlow.Brightness = 0.8
	signGlow.Range = 14
	signGlow.Parent = signPart

	if options.parent then
		model.Parent = options.parent
	end

	-- Collect telemetry value labels for animation
	local valueLabels = {}
	for _, child in bg:GetChildren() do
		if child.Name:match("Value$") then
			table.insert(valueLabels, child)
		end
	end

	return model, {
		type = "mission_control",
		mainScreen = screen,
		countdownLabel = countdown,
		valueLabels = valueLabels,
	}
end

--------------------------------------------------------------------------------
-- NUCLEAR PLANT
-- Reactor containment building with dome, 2 cooling towers with green steam,
-- turbine hall, radiation trefoil sign, "DANGER" neon, hazard stripes,
-- security barrier. Returns animation data for radiation pulse.
-- Options: parent, scale, variant (1 or 2)
--------------------------------------------------------------------------------

function AssetLibrary.createNuclearPlant(centerX, centerZ, options)
	options = options or {}
	local scale = options.scale or 1
	local baseY = options.baseY or BUILDING_BASE

	local SPECS = {
		{ domeColor = Color3.fromRGB(200, 200, 205), signText = "NUCLEAR ENERGY",  signColor = Color3.fromRGB(255, 180, 60), towerSpread = 16 },
		{ domeColor = Color3.fromRGB(190, 195, 205), signText = "POWER STATION",   signColor = Color3.fromRGB(60, 200, 255), towerSpread = 12 },
	}
	local spec = SPECS[options.variant or math.random(1, 2)]

	local model = Instance.new("Model")
	model.Name = "NuclearPlant"

	local reactorW = 20 * scale
	local reactorH = 24 * scale
	local reactorD = 20 * scale

	---------------------------------------------------------------------------
	-- REACTOR BUILDING (main containment structure)
	---------------------------------------------------------------------------
	local reactor = Instance.new("Part")
	reactor.Name = "ReactorBuilding"
	reactor.Size = Vector3.new(reactorW, reactorH, reactorD)
	reactor.Position = Vector3.new(centerX, baseY + reactorH / 2, centerZ)
	reactor.Anchored = true
	reactor.Material = Enum.Material.Concrete
	reactor.Color = Color3.fromRGB(195, 195, 200)
	reactor.Parent = model

	-- 4 corner columns
	local colW = 1.2 * scale
	local colH = 25 * scale
	local halfRW = reactorW / 2 - colW / 2
	local halfRD = reactorD / 2 - colW / 2
	for _, ox in ipairs({ -halfRW, halfRW }) do
		for _, oz in ipairs({ -halfRD, halfRD }) do
			local col = Instance.new("Part")
			col.Name = "ReactorColumn"
			col.Size = Vector3.new(colW, colH, colW)
			col.Position = Vector3.new(centerX + ox, baseY + colH / 2, centerZ + oz)
			col.Anchored = true
			col.Material = Enum.Material.Concrete
			col.Color = Color3.fromRGB(180, 180, 185)
			col.Parent = model
		end
	end

	-- Hazard stripes on front (+Z) columns
	for _, oz in ipairs({ -halfRD, halfRD }) do
		for band = 0, 3 do
			local stripe = Instance.new("Part")
			stripe.Name = "HazardStripe"
			stripe.Size = Vector3.new(colW + 0.1, 0.8 * scale, colW + 0.1)
			stripe.Position = Vector3.new(
				centerX + halfRW,
				baseY + 2 * scale + band * 2.5 * scale,
				centerZ + oz
			)
			stripe.Anchored = true
			stripe.CanCollide = false
			stripe.Material = Enum.Material.SmoothPlastic
			stripe.Color = (band % 2 == 0) and Color3.fromRGB(220, 190, 0) or Color3.fromRGB(30, 30, 30)
			stripe.Parent = model
		end
	end

	-- Reactor dome
	local domeDiam = 20 * scale
	local dome = Instance.new("Part")
	dome.Name = "ReactorDome"
	dome.Shape = Enum.PartType.Ball
	dome.Size = Vector3.new(domeDiam, domeDiam, domeDiam)
	dome.Position = Vector3.new(centerX, baseY + reactorH, centerZ)
	dome.Anchored = true
	dome.Material = Enum.Material.SmoothPlastic
	dome.Color = spec.domeColor
	dome.Parent = model

	---------------------------------------------------------------------------
	-- 2 COOLING TOWERS (offset along Z)
	---------------------------------------------------------------------------
	local towerDiam = 12 * scale
	local towerH = 30 * scale
	local towerTopY = baseY + towerH / 2
	local towerSpread = spec.towerSpread * scale

	for _, side in ipairs({ -1, 1 }) do
		local tz = centerZ + side * towerSpread
		local tx = centerX

		local tower = Instance.new("Part")
		tower.Name = "CoolingTower"
		tower.Shape = Enum.PartType.Cylinder
		tower.Size = Vector3.new(towerH, towerDiam, towerDiam)
		tower.CFrame = CFrame.new(tx, towerTopY, tz) * CFrame.Angles(0, 0, math.rad(90))
		tower.Anchored = true
		tower.Material = Enum.Material.Concrete
		tower.Color = Color3.fromRGB(210, 210, 215)
		tower.Parent = model

		-- Tower rim
		local rimDiam = 13 * scale
		local rimH = 1.5 * scale
		local rim = Instance.new("Part")
		rim.Name = "TowerRim"
		rim.Shape = Enum.PartType.Cylinder
		rim.Size = Vector3.new(rimH, rimDiam, rimDiam)
		rim.CFrame = CFrame.new(tx, baseY + towerH - rimH / 2, tz) * CFrame.Angles(0, 0, math.rad(90))
		rim.Anchored = true
		rim.Material = Enum.Material.Concrete
		rim.Color = Color3.fromRGB(200, 200, 205)
		rim.Parent = model

		-- Green neon ring
		local glowRingDiam = towerDiam + 1 * scale
		local glowRingH = 0.6 * scale
		local glowRing = Instance.new("Part")
		glowRing.Name = "TowerGlowRing"
		glowRing.Shape = Enum.PartType.Cylinder
		glowRing.Size = Vector3.new(glowRingH, glowRingDiam, glowRingDiam)
		glowRing.CFrame = CFrame.new(tx, baseY + towerH * 0.6, tz) * CFrame.Angles(0, 0, math.rad(90))
		glowRing.Anchored = true
		glowRing.CanCollide = false
		glowRing.Material = Enum.Material.Neon
		glowRing.Color = Color3.fromRGB(0, 255, 80)
		glowRing.Parent = model

		local ringLight = Instance.new("PointLight")
		ringLight.Brightness = 1.2
		ringLight.Range = 14
		ringLight.Color = Color3.fromRGB(0, 255, 80)
		ringLight.Parent = glowRing

		-- Green steam at top
		local steamPoint = Instance.new("Part")
		steamPoint.Name = "SteamPoint"
		steamPoint.Size = Vector3.new(1, 1, 1)
		steamPoint.Position = Vector3.new(tx, baseY + towerH + 1, tz)
		steamPoint.Anchored = true
		steamPoint.CanCollide = false
		steamPoint.Transparency = 1
		steamPoint.Parent = model

		local smoke = Instance.new("Smoke")
		smoke.Size = 14
		smoke.Opacity = 0.3
		smoke.RiseVelocity = 8
		smoke.Color = Color3.fromRGB(100, 255, 120)
		smoke.Parent = steamPoint

		local steamGlow = Instance.new("PointLight")
		steamGlow.Brightness = 1.5
		steamGlow.Range = 18
		steamGlow.Color = Color3.fromRGB(80, 255, 100)
		steamGlow.Parent = steamPoint

		-- Pipe connecting reactor to cooling tower
		local pipeLen = math.abs(towerSpread) - towerDiam / 2 - reactorD / 2
		if pipeLen > 0 then
			local pipeDiam = 2.5 * scale
			local pipeY = baseY + 10 * scale
			local pipeZ = centerZ + side * (reactorD / 2 + pipeLen / 2)

			local pipe = Instance.new("Part")
			pipe.Name = "ConnectingPipe"
			pipe.Shape = Enum.PartType.Cylinder
			pipe.Size = Vector3.new(pipeLen, pipeDiam, pipeDiam)
			pipe.CFrame = CFrame.new(centerX, pipeY, pipeZ) * CFrame.Angles(math.rad(90), 0, 0)
			pipe.Anchored = true
			pipe.Material = Enum.Material.Metal
			pipe.Color = Color3.fromRGB(140, 140, 145)
			pipe.Parent = model
		end
	end

	---------------------------------------------------------------------------
	-- TURBINE HALL (beside reactor, +X side)
	---------------------------------------------------------------------------
	local turbW = 16 * scale
	local turbH = 12 * scale
	local turbD = 24 * scale
	local turbX = centerX + reactorW / 2 + turbW / 2

	local turbine = Instance.new("Part")
	turbine.Name = "TurbineHall"
	turbine.Size = Vector3.new(turbW, turbH, turbD)
	turbine.Position = Vector3.new(turbX, baseY + turbH / 2, centerZ)
	turbine.Anchored = true
	turbine.Material = Enum.Material.Concrete
	turbine.Color = Color3.fromRGB(160, 160, 165)
	turbine.Parent = model

	---------------------------------------------------------------------------
	-- RADIATION DOOR (front +Z face of reactor)
	---------------------------------------------------------------------------
	local doorFaceZ = centerZ + reactorD / 2 + 0.15
	local door = Instance.new("Part")
	door.Name = "RadiationDoor"
	door.Size = Vector3.new(10 * scale, 8 * scale, 0.3 * scale)
	door.Position = Vector3.new(centerX, baseY + 4 * scale, doorFaceZ)
	door.Anchored = true
	door.Material = Enum.Material.SmoothPlastic
	door.Color = Color3.fromRGB(220, 190, 0)
	door.Parent = model

	-- Radiation trefoil sign (above front door)
	local NEON_GREEN = Color3.fromRGB(0, 255, 80)
	local signR = 3.0 * scale
	local neonThick = 0.3 * scale
	local radCZ2 = doorFaceZ + 0.2
	local radCY = baseY + 12 * scale

	-- Green neon border ring
	local borderRing = Instance.new("Part")
	borderRing.Name = "RadBorderRing"
	borderRing.Shape = Enum.PartType.Cylinder
	borderRing.Size = Vector3.new(signR * 2.3, signR * 2.3, neonThick * 0.4)
	borderRing.CFrame = CFrame.new(centerX, radCY, radCZ2 + 0.06)
	borderRing.Anchored = true
	borderRing.CanCollide = false
	borderRing.Material = Enum.Material.Neon
	borderRing.Color = NEON_GREEN
	borderRing.Parent = model

	-- Dark backing disc
	local radBacking = Instance.new("Part")
	radBacking.Name = "RadSignBacking"
	radBacking.Shape = Enum.PartType.Cylinder
	radBacking.Size = Vector3.new(signR * 1.95, signR * 1.95, neonThick * 0.5)
	radBacking.CFrame = CFrame.new(centerX, radCY, radCZ2)
	radBacking.Anchored = true
	radBacking.CanCollide = false
	radBacking.Material = Enum.Material.Metal
	radBacking.Color = Color3.fromRGB(25, 25, 30)
	radBacking.Parent = model

	-- 3 trefoil blades (120 degrees apart in XY plane)
	local bladeLen = 1.6 * scale
	local bladeWid = 2.0 * scale
	local bladeOff = 1.4 * scale
	local radBlades = {}

	for i = 0, 2 do
		local angle = i * math.rad(120)
		local blade = Instance.new("Part")
		blade.Name = "RadBlade"
		blade.Size = Vector3.new(bladeWid, bladeLen, neonThick)
		blade.CFrame = CFrame.new(centerX, radCY, radCZ2 + 0.08)
			* CFrame.Angles(0, 0, angle)
			* CFrame.new(0, bladeOff, 0)
		blade.Anchored = true
		blade.CanCollide = false
		blade.Material = Enum.Material.Neon
		blade.Color = NEON_GREEN
		blade.Parent = model
		table.insert(radBlades, blade)
	end

	-- Yellow neon center dot
	local centerDot = Instance.new("Part")
	centerDot.Name = "RadCenter"
	centerDot.Shape = Enum.PartType.Ball
	centerDot.Size = Vector3.new(0.7 * scale, 0.7 * scale, 0.7 * scale)
	centerDot.Position = Vector3.new(centerX, radCY, radCZ2 + 0.12)
	centerDot.Anchored = true
	centerDot.CanCollide = false
	centerDot.Material = Enum.Material.Neon
	centerDot.Color = Color3.fromRGB(255, 255, 0)
	centerDot.Parent = model

	local radLight = Instance.new("PointLight")
	radLight.Brightness = 2
	radLight.Range = 14
	radLight.Color = NEON_GREEN
	radLight.Parent = centerDot

	-- "DANGER" neon text below trefoil
	local dangerW = 5 * scale
	local dangerH = 1.2 * scale
	local dangerPart = Instance.new("Part")
	dangerPart.Name = "DangerSign"
	dangerPart.Size = Vector3.new(dangerW, dangerH, neonThick)
	dangerPart.Position = Vector3.new(centerX, radCY - signR - 1.0 * scale, radCZ2)
	dangerPart.Anchored = true
	dangerPart.CanCollide = false
	dangerPart.Material = Enum.Material.Neon
	dangerPart.Color = Color3.fromRGB(255, 60, 30)
	dangerPart.Parent = model

	local dangerGui = Instance.new("SurfaceGui")
	dangerGui.Face = Enum.NormalId.Front
	dangerGui.Parent = dangerPart

	local dangerTxt = Instance.new("TextLabel")
	dangerTxt.Size = UDim2.new(1, 0, 1, 0)
	dangerTxt.BackgroundTransparency = 1
	dangerTxt.Font = Enum.Font.GothamBold
	dangerTxt.Text = "DANGER"
	dangerTxt.TextColor3 = Color3.new(1, 1, 1)
	dangerTxt.TextScaled = true
	dangerTxt.Parent = dangerGui

	-- Hazard strips above door
	for _, hOff in ipairs({ -3 * scale, 3 * scale }) do
		local strip = Instance.new("Part")
		strip.Name = "HazardStrip"
		strip.Size = Vector3.new(9 * scale, 0.6 * scale, 0.35 * scale)
		strip.Position = Vector3.new(centerX + hOff, baseY + 8.3 * scale, doorFaceZ + 0.05)
		strip.Anchored = true
		strip.CanCollide = false
		strip.Material = Enum.Material.Neon
		strip.Color = Color3.fromRGB(220, 190, 0)
		strip.Parent = model
	end

	---------------------------------------------------------------------------
	-- WARNING SIGN (neon text on front face)
	---------------------------------------------------------------------------
	local signW2 = 12 * scale
	local signH2 = 3 * scale
	local signZ2 = centerZ + reactorD / 2 + 0.3
	local signY2 = baseY + reactorH - 4 * scale

	local signPart = Instance.new("Part")
	signPart.Name = "NuclearSign"
	signPart.Size = Vector3.new(signW2, signH2, 0.4 * scale)
	signPart.Position = Vector3.new(centerX, signY2, signZ2)
	signPart.Anchored = true
	signPart.Material = Enum.Material.Neon
	signPart.Color = spec.signColor
	signPart.Parent = model

	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
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

	---------------------------------------------------------------------------
	-- SECURITY BARRIER (low metal railing, +Z side)
	---------------------------------------------------------------------------
	local barrierH = 3 * scale
	local barrierD = 40 * scale

	local barrier = Instance.new("Part")
	barrier.Name = "SecurityBarrier"
	barrier.Size = Vector3.new(barrierD, barrierH, 0.5 * scale)
	barrier.Position = Vector3.new(centerX, baseY + barrierH / 2, centerZ + reactorD / 2 + 4 * scale)
	barrier.Anchored = true
	barrier.Material = Enum.Material.Metal
	barrier.Color = Color3.fromRGB(100, 100, 105)
	barrier.Parent = model

	if options.parent then
		model.Parent = options.parent
	end

	-- Return animation data for radiation pulse
	return model, {
		type = "radiation_pulse",
		blades = radBlades,
		light = radLight,
		centerDot = centerDot,
		borderRing = borderRing,
	}
end

--------------------------------------------------------------------------------
-- POWER PLANT
-- Industrial power facility: turbine hall, 2 Tesla coils with electrical arc
-- beams + spark emitters, transformer boxes, high-voltage pylon with power
-- lines, warning signs, security fence. Returns arc animation data.
-- Options: parent, scale, variant (1 or 2)
--------------------------------------------------------------------------------

function AssetLibrary.createPowerPlant(centerX, centerZ, options)
	options = options or {}
	local scale = options.scale or 1

	local SPECS = {
		{
			bodyMat = Enum.Material.DiamondPlate, bodyColor = Color3.fromRGB(80, 80, 90),
			roofColor = Color3.fromRGB(55, 55, 65), signText = "VOLT ENERGY",
			signColor = Color3.fromRGB(255, 180, 60), arcColor = Color3.fromRGB(120, 180, 255),
			sparkColor = Color3.fromRGB(200, 220, 255), coilColor = Color3.fromRGB(170, 170, 180),
			transformerCount = 2,
		},
		{
			bodyMat = Enum.Material.Metal, bodyColor = Color3.fromRGB(75, 80, 90),
			roofColor = Color3.fromRGB(50, 55, 65), signText = "POWER GRID CO.",
			signColor = Color3.fromRGB(60, 200, 255), arcColor = Color3.fromRGB(180, 140, 255),
			sparkColor = Color3.fromRGB(220, 180, 255), coilColor = Color3.fromRGB(180, 175, 170),
			transformerCount = 3,
		},
	}
	local spec = SPECS[options.variant or math.random(1, 2)]

	local model = Instance.new("Model")
	model.Name = "PowerPlant"

	-- Dimensions
	local bodyW = 30 * scale
	local bodyH = 14 * scale
	local bodyD = 26 * scale

	---------------------------------------------------------------------------
	-- Helper: create a Tesla coil, returns sphere + glow
	---------------------------------------------------------------------------
	local function createTeslaCoil(px, pz)
		local pedW = 4 * scale
		local pedH = 2 * scale
		local pedestal = Instance.new("Part")
		pedestal.Name = "CoilPedestal"
		pedestal.Size = Vector3.new(pedW, pedH, pedW)
		pedestal.Position = Vector3.new(px, BUILDING_BASE + pedH / 2, pz)
		pedestal.Anchored = true
		pedestal.Material = Enum.Material.Concrete
		pedestal.Color = Color3.fromRGB(130, 130, 135)
		pedestal.Parent = model

		-- 3 insulator discs
		local insulatorDiam = 3.0 * scale
		local insulatorH = 0.6 * scale
		local insulatorBaseY = BUILDING_BASE + pedH
		for i = 0, 2 do
			local ins = Instance.new("Part")
			ins.Name = "Insulator"
			ins.Shape = Enum.PartType.Cylinder
			ins.Size = Vector3.new(insulatorH, insulatorDiam - i * 0.3 * scale, insulatorDiam - i * 0.3 * scale)
			ins.CFrame = CFrame.new(px, insulatorBaseY + i * (insulatorH + 0.3 * scale) + insulatorH / 2, pz) * CFrame.Angles(0, 0, math.rad(90))
			ins.Anchored = true
			ins.Material = Enum.Material.SmoothPlastic
			ins.Color = Color3.fromRGB(220, 200, 160)
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

		-- Copper wire wraps
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
			wrap.Color = Color3.fromRGB(200, 140, 50)
			wrap.Parent = model
		end

		-- Top sphere
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

		-- Spark emitter
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

		local glow = Instance.new("PointLight")
		glow.Name = "CoilGlow"
		glow.Brightness = 2
		glow.Range = 18
		glow.Color = spec.arcColor
		glow.Parent = sphere

		return sphere, glow
	end

	---------------------------------------------------------------------------
	-- Helper: create a transformer box
	---------------------------------------------------------------------------
	local function createTransformer(px, pz)
		local boxW = 4 * scale
		local boxH = 3.5 * scale
		local boxD = 3 * scale

		local box = Instance.new("Part")
		box.Name = "TransformerBox"
		box.Size = Vector3.new(boxW, boxH, boxD)
		box.Position = Vector3.new(px, BUILDING_BASE + boxH / 2, pz)
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
			bushing.CFrame = CFrame.new(px + i * 1.2 * scale, BUILDING_BASE + boxH + 1.25 * scale, pz) * CFrame.Angles(0, 0, math.rad(90))
			bushing.Anchored = true
			bushing.Material = Enum.Material.SmoothPlastic
			bushing.Color = Color3.fromRGB(200, 180, 140)
			bushing.Parent = model
		end

		-- Warning sticker
		local sticker = Instance.new("Part")
		sticker.Name = "WarningSticker"
		sticker.Size = Vector3.new(1.5 * scale, 1.5 * scale, 0.1)
		sticker.Position = Vector3.new(px, BUILDING_BASE + boxH * 0.6, pz + boxD / 2 + 0.05)
		sticker.Anchored = true
		sticker.CanCollide = false
		sticker.Material = Enum.Material.Neon
		sticker.Color = Color3.fromRGB(220, 190, 0)
		sticker.Parent = model

		-- Spark emitter
		local sparkPoint = Instance.new("Part")
		sparkPoint.Name = "TransformerSpark"
		sparkPoint.Size = Vector3.new(1, 1, 1)
		sparkPoint.Position = Vector3.new(px, BUILDING_BASE + boxH + 2 * scale, pz)
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
	end

	---------------------------------------------------------------------------
	-- MAIN TURBINE HALL
	---------------------------------------------------------------------------
	local body = Instance.new("Part")
	body.Name = "TurbineHall"
	body.Size = Vector3.new(bodyW, bodyH, bodyD)
	body.Position = Vector3.new(centerX, BUILDING_BASE + bodyH / 2, centerZ)
	body.Anchored = true
	body.Material = spec.bodyMat
	body.Color = spec.bodyColor
	body.Parent = model

	local roof = Instance.new("Part")
	roof.Name = "TurbineRoof"
	roof.Size = Vector3.new(bodyW + 1 * scale, 0.6 * scale, bodyD + 1 * scale)
	roof.Position = Vector3.new(centerX, BUILDING_BASE + bodyH + 0.3 * scale, centerZ)
	roof.Anchored = true
	roof.Material = Enum.Material.DiamondPlate
	roof.Color = spec.roofColor
	roof.Parent = model

	-- Windows on all 4 faces
	addWindowsToFace(model, "z", centerZ + bodyD / 2 + 0.05, centerX, bodyW, BUILDING_BASE, 2, bodyH / 2, 2.0, 1.8, 3.0, Color3.fromRGB(200, 220, 255), 0.30)
	addWindowsToFace(model, "z", centerZ - bodyD / 2 - 0.05, centerX, bodyW, BUILDING_BASE, 2, bodyH / 2, 2.0, 1.8, 3.0, Color3.fromRGB(200, 220, 255), 0.15)
	addWindowsToFace(model, "x", centerX + bodyW / 2 + 0.05, centerZ, bodyD, BUILDING_BASE, 2, bodyH / 2, 2.0, 1.8, 3.0, Color3.fromRGB(200, 220, 255), 0.20)
	addWindowsToFace(model, "x", centerX - bodyW / 2 - 0.05, centerZ, bodyD, BUILDING_BASE, 2, bodyH / 2, 2.0, 1.8, 3.0, Color3.fromRGB(200, 220, 255), 0.20)

	---------------------------------------------------------------------------
	-- 2 TESLA COILS (in front of building, +Z side)
	---------------------------------------------------------------------------
	local coilSpacing = 12 * scale
	local coilZ = centerZ + bodyD / 2 + 6 * scale
	local coil1X = centerX - coilSpacing / 2
	local coil2X = centerX + coilSpacing / 2

	local sphere1, glow1 = createTeslaCoil(coil1X, coilZ)
	local sphere2, glow2 = createTeslaCoil(coil2X, coilZ)

	---------------------------------------------------------------------------
	-- ELECTRICAL ARC BEAMS between the two Tesla coils
	---------------------------------------------------------------------------
	local att1 = Instance.new("Attachment")
	att1.Name = "ArcAttach1"
	att1.Parent = sphere1

	local att2 = Instance.new("Attachment")
	att2.Name = "ArcAttach2"
	att2.Parent = sphere2

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
	beam2.Color = ColorSequence.new(Color3.fromRGB(240, 240, 255))
	beam2.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.5, 0.05),
		NumberSequenceKeypoint.new(1, 0.2),
	})
	beam2.Brightness = 4
	beam2.Parent = sphere1

	---------------------------------------------------------------------------
	-- TRANSFORMER BOXES (between coils and building, -Z side)
	---------------------------------------------------------------------------
	local tfBaseZ = centerZ - bodyD / 2 + 4 * scale
	local tfSpacing = bodyW / (spec.transformerCount + 1)
	for i = 1, spec.transformerCount do
		local tfX = centerX - bodyW / 2 + i * tfSpacing
		createTransformer(tfX, tfBaseZ)
	end

	---------------------------------------------------------------------------
	-- HIGH-VOLTAGE PYLON (behind building, -Z side)
	---------------------------------------------------------------------------
	local pylonZ = centerZ - bodyD / 2 - 6 * scale
	local pylonH = 28 * scale
	local pylonW = 1.5 * scale

	local pole = Instance.new("Part")
	pole.Name = "PylonPole"
	pole.Size = Vector3.new(pylonW, pylonH, pylonW)
	pole.Position = Vector3.new(centerX, BUILDING_BASE + pylonH / 2, pylonZ)
	pole.Anchored = true
	pole.Material = Enum.Material.Metal
	pole.Color = Color3.fromRGB(120, 120, 125)
	pole.Parent = model

	-- Cross arms (3 levels)
	for i = 1, 3 do
		local armY = BUILDING_BASE + pylonH * (0.5 + i * 0.15)
		local armLen = (14 - i * 2) * scale
		local arm = Instance.new("Part")
		arm.Name = "PylonArm"
		arm.Size = Vector3.new(armLen, pylonW * 0.8, pylonW * 0.8)
		arm.Position = Vector3.new(centerX, armY, pylonZ)
		arm.Anchored = true
		arm.Material = Enum.Material.Metal
		arm.Color = Color3.fromRGB(110, 110, 115)
		arm.Parent = model

		for _, endDir in ipairs({ -1, 1 }) do
			local insX = centerX + endDir * (armLen / 2)
			local ins = Instance.new("Part")
			ins.Name = "PylonInsulator"
			ins.Shape = Enum.PartType.Cylinder
			ins.Size = Vector3.new(2 * scale, 1 * scale, 1 * scale)
			ins.CFrame = CFrame.new(insX, armY - 1 * scale, pylonZ) * CFrame.Angles(0, 0, math.rad(90))
			ins.Anchored = true
			ins.Material = Enum.Material.SmoothPlastic
			ins.Color = Color3.fromRGB(210, 190, 150)
			ins.Parent = model
		end
	end

	-- Diagonal braces
	for _, bDir in ipairs({ -1, 1 }) do
		local brace = Instance.new("Part")
		brace.Name = "PylonBrace"
		brace.Size = Vector3.new(0.6 * scale, 18 * scale, 0.6 * scale)
		brace.CFrame = CFrame.new(centerX + bDir * 2 * scale, BUILDING_BASE + pylonH * 0.5, pylonZ) * CFrame.Angles(0, 0, math.rad(bDir * 15))
		brace.Anchored = true
		brace.Material = Enum.Material.Metal
		brace.Color = Color3.fromRGB(115, 115, 120)
		brace.Parent = model
	end

	-- Power line from pylon to building roof
	local lineAtt1 = Instance.new("Attachment")
	lineAtt1.Position = Vector3.new(0, pylonH * 0.35, 0)
	lineAtt1.Parent = pole

	local lineAtt2 = Instance.new("Attachment")
	lineAtt2.Position = Vector3.new(0, 0, -bodyD / 2)
	lineAtt2.Parent = roof

	local powerLine = Instance.new("Beam")
	powerLine.Name = "PowerLine"
	powerLine.Attachment0 = lineAtt1
	powerLine.Attachment1 = lineAtt2
	powerLine.Segments = 12
	powerLine.Width0 = 0.15 * scale
	powerLine.Width1 = 0.15 * scale
	powerLine.CurveSize0 = -3 * scale
	powerLine.CurveSize1 = -3 * scale
	powerLine.FaceCamera = true
	powerLine.Color = ColorSequence.new(Color3.fromRGB(40, 40, 45))
	powerLine.Transparency = NumberSequence.new(0)
	powerLine.Parent = pole

	---------------------------------------------------------------------------
	-- WARNING SIGN (DANGER HIGH VOLTAGE, front +Z)
	---------------------------------------------------------------------------
	local warnSignW = 10 * scale
	local warnSignH = 2 * scale
	local warnZ = centerZ + bodyD / 2 + 2 * scale

	local warnPart = Instance.new("Part")
	warnPart.Name = "HighVoltageSign"
	warnPart.Size = Vector3.new(warnSignW, warnSignH, 0.3 * scale)
	warnPart.Position = Vector3.new(centerX, BUILDING_BASE + 5 * scale, warnZ)
	warnPart.Anchored = true
	warnPart.Material = Enum.Material.Neon
	warnPart.Color = Color3.fromRGB(255, 60, 20)
	warnPart.Parent = model

	local warnGui = Instance.new("SurfaceGui")
	warnGui.Face = Enum.NormalId.Front
	warnGui.Parent = warnPart

	local warnTxt = Instance.new("TextLabel")
	warnTxt.Size = UDim2.new(1, 0, 1, 0)
	warnTxt.BackgroundTransparency = 1
	warnTxt.Font = Enum.Font.GothamBold
	warnTxt.Text = "DANGER HIGH VOLTAGE"
	warnTxt.TextColor3 = Color3.new(1, 1, 1)
	warnTxt.TextScaled = true
	warnTxt.Parent = warnGui

	local warnLight = Instance.new("PointLight")
	warnLight.Brightness = 1.2
	warnLight.Range = 10
	warnLight.Color = Color3.fromRGB(255, 60, 20)
	warnLight.Parent = warnPart

	---------------------------------------------------------------------------
	-- MAIN SIGN (neon text on front face)
	---------------------------------------------------------------------------
	local signW3 = 14 * scale
	local signH3 = 2.5 * scale

	local signPart2 = Instance.new("Part")
	signPart2.Name = "PowerPlantSign"
	signPart2.Size = Vector3.new(signW3, signH3, 0.4 * scale)
	signPart2.Position = Vector3.new(centerX, BUILDING_BASE + bodyH - 3 * scale, centerZ + bodyD / 2 + 0.3)
	signPart2.Anchored = true
	signPart2.Material = Enum.Material.Neon
	signPart2.Color = spec.signColor
	signPart2.Parent = model

	local gui2 = Instance.new("SurfaceGui")
	gui2.Face = Enum.NormalId.Front
	gui2.Parent = signPart2

	local txt2 = Instance.new("TextLabel")
	txt2.Size = UDim2.new(1, 0, 1, 0)
	txt2.BackgroundTransparency = 1
	txt2.Font = Enum.Font.GothamBold
	txt2.Text = spec.signText
	txt2.TextColor3 = Color3.new(1, 1, 1)
	txt2.TextScaled = true
	txt2.Parent = gui2

	local signLight2 = Instance.new("PointLight")
	signLight2.Brightness = 1.5
	signLight2.Range = 16
	signLight2.Color = spec.signColor
	signLight2.Parent = signPart2

	---------------------------------------------------------------------------
	-- SECURITY FENCE (+Z side, chain-link style)
	---------------------------------------------------------------------------
	local fenceH = 4 * scale
	local fenceW = 34 * scale
	local fenceZ2 = centerZ + bodyD / 2 + 10 * scale

	local fence = Instance.new("Part")
	fence.Name = "SecurityFence"
	fence.Size = Vector3.new(fenceW, fenceH, 0.3 * scale)
	fence.Position = Vector3.new(centerX, BUILDING_BASE + fenceH / 2, fenceZ2)
	fence.Anchored = true
	fence.Material = Enum.Material.Metal
	fence.Color = Color3.fromRGB(130, 130, 135)
	fence.Transparency = 0.3
	fence.Parent = model

	local postCount = 6
	local postSpacing = fenceW / (postCount + 1)
	for i = 1, postCount do
		local postX = centerX - fenceW / 2 + i * postSpacing
		local post = Instance.new("Part")
		post.Name = "FencePost"
		post.Size = Vector3.new(0.4 * scale, fenceH + 0.5 * scale, 0.4 * scale)
		post.Position = Vector3.new(postX, BUILDING_BASE + (fenceH + 0.5 * scale) / 2, fenceZ2)
		post.Anchored = true
		post.Material = Enum.Material.Metal
		post.Color = Color3.fromRGB(110, 110, 115)
		post.Parent = model
	end

	if options.parent then
		model.Parent = options.parent
	end

	-- Return animation data for electrical arc
	return model, {
		type = "electrical_arc",
		beam1 = beam,
		beam2 = beam2,
		glow1 = glow1,
		glow2 = glow2,
		baseScale = scale,
	}
end

--------------------------------------------------------------------------------
-- WATER PLANT
-- Water treatment facility: 2 circular clarifier tanks with bubble particles
-- and scraper arms, settling basin with water fill + catwalk + waterfall,
-- pipe network with valves, water tower on stilts, 2 chemical tanks,
-- control booth, flood lights, security fence. Returns animation data for
-- clarifier arms.
-- Options: parent, scale, variant (1 or 2)
--------------------------------------------------------------------------------

function AssetLibrary.createWaterPlant(centerX, centerZ, options)
	options = options or {}
	local scale = options.scale or 1

	local SPECS = {
		{
			waterColor = Color3.fromRGB(40, 120, 200), waterGlow = Color3.fromRGB(60, 140, 220),
			boothColor = Color3.fromRGB(200, 200, 210), signText = "AQUA WORKS",
			signColor = Color3.fromRGB(60, 180, 255), chemLabels = { "CHLORINE", "FLUORIDE" },
			chemColors = { Color3.fromRGB(220, 220, 60), Color3.fromRGB(180, 80, 220) },
		},
		{
			waterColor = Color3.fromRGB(60, 150, 80), waterGlow = Color3.fromRGB(50, 180, 70),
			boothColor = Color3.fromRGB(180, 180, 185), signText = "CITY WATER AUTHORITY",
			signColor = Color3.fromRGB(80, 220, 120), chemLabels = { "ALUM", "LIME" },
			chemColors = { Color3.fromRGB(200, 200, 200), Color3.fromRGB(230, 220, 180) },
		},
	}
	local spec = SPECS[options.variant or math.random(1, 2)]

	local model = Instance.new("Model")
	model.Name = "WaterPlant"

	local clarifierAnims = {}

	---------------------------------------------------------------------------
	-- Helper: create a circular clarifier tank
	---------------------------------------------------------------------------
	local function createClarifier(px, pz)
		local tankDiam = 14 * scale
		local tankH = 3 * scale

		-- Dark floor disc
		local floor = Instance.new("Part")
		floor.Name = "ClarifierFloor"
		floor.Shape = Enum.PartType.Cylinder
		floor.Size = Vector3.new(0.3 * scale, tankDiam, tankDiam)
		floor.CFrame = CFrame.new(px, BUILDING_BASE + 0.15 * scale, pz) * CFrame.Angles(0, 0, math.rad(90))
		floor.Anchored = true
		floor.Material = Enum.Material.Concrete
		floor.Color = Color3.fromRGB(70, 80, 85)
		floor.Parent = model

		-- Water fill (neon cylinder)
		local waterDiam = tankDiam - 0.4 * scale
		local waterH = tankH - 0.3 * scale
		local water = Instance.new("Part")
		water.Name = "ClarifierWater"
		water.Shape = Enum.PartType.Cylinder
		water.Size = Vector3.new(waterH, waterDiam, waterDiam)
		water.CFrame = CFrame.new(px, BUILDING_BASE + 0.3 * scale + waterH / 2, pz) * CFrame.Angles(0, 0, math.rad(90))
		water.Anchored = true
		water.CanCollide = false
		water.Material = Enum.Material.Neon
		water.Color = spec.waterColor
		water.Transparency = 0.35
		water.Parent = model

		local waterLight = Instance.new("PointLight")
		waterLight.Brightness = 0.8
		waterLight.Range = 10
		waterLight.Color = spec.waterGlow
		waterLight.Parent = water

		-- Bubble particles
		local bubblePart = Instance.new("Part")
		bubblePart.Name = "BubblePoint"
		bubblePart.Size = Vector3.new(waterDiam * 0.6, 1, waterDiam * 0.6)
		bubblePart.Position = Vector3.new(px, BUILDING_BASE + tankH + 0.2 * scale, pz)
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

		-- Center column
		local centerCol = Instance.new("Part")
		centerCol.Name = "ClarifierCenter"
		centerCol.Shape = Enum.PartType.Cylinder
		centerCol.Size = Vector3.new(tankH + 2 * scale, 1.2 * scale, 1.2 * scale)
		centerCol.CFrame = CFrame.new(px, BUILDING_BASE + (tankH + 2 * scale) / 2, pz) * CFrame.Angles(0, 0, math.rad(90))
		centerCol.Anchored = true
		centerCol.Material = Enum.Material.Metal
		centerCol.Color = Color3.fromRGB(120, 120, 125)
		centerCol.Parent = model

		-- Rotating scraper arm
		local armLen = tankDiam / 2 - 0.5 * scale
		local armH = 0.4 * scale
		local armW = 0.6 * scale
		local armY = BUILDING_BASE + tankH + 0.8 * scale

		local arm = Instance.new("Part")
		arm.Name = "ScraperArm"
		arm.Size = Vector3.new(armLen, armH, armW)
		arm.CFrame = CFrame.new(px, armY, pz) * CFrame.new(armLen / 2, 0, 0)
		arm.Anchored = true
		arm.Material = Enum.Material.Metal
		arm.Color = Color3.fromRGB(140, 140, 145)
		arm.Parent = model

		-- Track animation data for caller
		table.insert(clarifierAnims, {
			type = "clarifier_arm",
			arm = arm,
			centerX = px,
			centerY = armY,
			centerZ = pz,
			armOffset = armLen / 2,
			angle = math.random() * math.pi * 2,
			speed = 0.3,
		})
	end

	---------------------------------------------------------------------------
	-- 2 CLARIFIER TANKS (along Z, -X side of area)
	---------------------------------------------------------------------------
	local tankSpacing = 16 * scale
	local tankX = centerX - 5 * scale
	createClarifier(tankX, centerZ - tankSpacing / 2)
	createClarifier(tankX, centerZ + tankSpacing / 2)

	---------------------------------------------------------------------------
	-- SETTLING BASIN (open-top: 4 walls + floor + water fill)
	---------------------------------------------------------------------------
	local basinW = 16 * scale
	local basinH = 3 * scale
	local basinD = 28 * scale
	local basinX = centerX + 4 * scale
	local wallT = 0.6 * scale
	local basinColor = Color3.fromRGB(140, 145, 150)

	-- Floor
	local basinFloor = Instance.new("Part")
	basinFloor.Name = "BasinFloor"
	basinFloor.Size = Vector3.new(basinW, wallT, basinD)
	basinFloor.Position = Vector3.new(basinX, BUILDING_BASE + wallT / 2, centerZ)
	basinFloor.Anchored = true
	basinFloor.Material = Enum.Material.Concrete
	basinFloor.Color = Color3.fromRGB(70, 80, 85)
	basinFloor.Parent = model

	-- 4 walls
	local wallDefs = {
		{ s = Vector3.new(wallT, basinH, basinD), p = Vector3.new(basinX - basinW / 2 + wallT / 2, BUILDING_BASE + basinH / 2, centerZ) },
		{ s = Vector3.new(wallT, basinH, basinD), p = Vector3.new(basinX + basinW / 2 - wallT / 2, BUILDING_BASE + basinH / 2, centerZ) },
		{ s = Vector3.new(basinW, basinH, wallT), p = Vector3.new(basinX, BUILDING_BASE + basinH / 2, centerZ - basinD / 2 + wallT / 2) },
		{ s = Vector3.new(basinW, basinH, wallT), p = Vector3.new(basinX, BUILDING_BASE + basinH / 2, centerZ + basinD / 2 - wallT / 2) },
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

	-- Water fill
	local innerW = basinW - wallT * 2
	local innerD = basinD - wallT * 2
	local waterH2 = basinH - wallT - 0.3 * scale
	local basinWater = Instance.new("Part")
	basinWater.Name = "BasinWater"
	basinWater.Size = Vector3.new(innerW, waterH2, innerD)
	basinWater.Position = Vector3.new(basinX, BUILDING_BASE + wallT + waterH2 / 2, centerZ)
	basinWater.Anchored = true
	basinWater.CanCollide = false
	basinWater.Material = Enum.Material.Neon
	basinWater.Color = spec.waterColor
	basinWater.Transparency = 0.4
	basinWater.Parent = model

	local basinGlow = Instance.new("PointLight")
	basinGlow.Brightness = 0.6
	basinGlow.Range = 10
	basinGlow.Color = spec.waterGlow
	basinGlow.Parent = basinWater

	-- Basin bubble aeration
	local basinBubblePart = Instance.new("Part")
	basinBubblePart.Name = "BasinBubblePoint"
	basinBubblePart.Size = Vector3.new(innerW * 0.5, 1, innerD * 0.4)
	basinBubblePart.Position = Vector3.new(basinX, BUILDING_BASE + basinH + 0.1 * scale, centerZ)
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

	-- Waterfall overflow at +Z edge
	local fallPart = Instance.new("Part")
	fallPart.Name = "WaterfallPoint"
	fallPart.Size = Vector3.new(basinW * 0.5, 1, 1)
	fallPart.Position = Vector3.new(basinX, BUILDING_BASE + basinH, centerZ + basinD / 2)
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

	-- Catwalk railings over basin
	local railH = 3.5 * scale
	local railY = BUILDING_BASE + basinH + railH / 2
	for _, rOff in ipairs({ -basinW / 2 + 0.5 * scale, basinW / 2 - 0.5 * scale }) do
		local rail = Instance.new("Part")
		rail.Name = "CatwalkRail"
		rail.Size = Vector3.new(0.2 * scale, railH, basinD)
		rail.Position = Vector3.new(basinX + rOff, railY, centerZ)
		rail.Anchored = true
		rail.Material = Enum.Material.Metal
		rail.Color = Color3.fromRGB(180, 180, 60)
		rail.Transparency = 0.1
		rail.Parent = model
	end

	-- Catwalk floor
	local walkway = Instance.new("Part")
	walkway.Name = "CatwalkFloor"
	walkway.Size = Vector3.new(basinW - 1 * scale, 0.2 * scale, basinD)
	walkway.Position = Vector3.new(basinX, BUILDING_BASE + basinH + 0.1 * scale, centerZ)
	walkway.Anchored = true
	walkway.Material = Enum.Material.DiamondPlate
	walkway.Color = Color3.fromRGB(110, 110, 115)
	walkway.Transparency = 0.4
	walkway.Parent = model

	---------------------------------------------------------------------------
	-- PIPE NETWORK (connecting clarifiers to basin)
	---------------------------------------------------------------------------
	local pipeDiam = 1.8 * scale
	local pipeColor = Color3.fromRGB(60, 130, 180)

	for _, side in ipairs({ -1, 1 }) do
		local pipeZ = centerZ + side * tankSpacing / 2
		local pipeStartX = tankX + 7 * scale
		local pipeEndX = basinX - basinW / 2
		local pipeLen = math.abs(pipeEndX - pipeStartX)
		local pipeMidX = (pipeStartX + pipeEndX) / 2

		local pipe = Instance.new("Part")
		pipe.Name = "ConnectPipe"
		pipe.Shape = Enum.PartType.Cylinder
		pipe.Size = Vector3.new(pipeLen, pipeDiam, pipeDiam)
		pipe.CFrame = CFrame.new(pipeMidX, BUILDING_BASE + 2.5 * scale, pipeZ)
			* CFrame.Angles(0, math.rad(90), 0)
			* CFrame.Angles(0, 0, math.rad(90))
		pipe.Anchored = true
		pipe.Material = Enum.Material.Metal
		pipe.Color = pipeColor
		pipe.Parent = model

		-- Valve wheel
		local valveDiam = 1.5 * scale
		local valve = Instance.new("Part")
		valve.Name = "PipeValve"
		valve.Shape = Enum.PartType.Cylinder
		valve.Size = Vector3.new(0.3 * scale, valveDiam, valveDiam)
		valve.CFrame = CFrame.new(pipeMidX, BUILDING_BASE + 2.5 * scale + pipeDiam / 2 + 0.5 * scale, pipeZ)
			* CFrame.Angles(0, 0, math.rad(90))
		valve.Anchored = true
		valve.Material = Enum.Material.Metal
		valve.Color = Color3.fromRGB(180, 40, 40)
		valve.Parent = model
	end

	---------------------------------------------------------------------------
	-- WATER TOWER (elevated sphere on stilts, -Z side)
	---------------------------------------------------------------------------
	local towerX = centerX + 13 * scale
	local towerZ = centerZ - 8 * scale
	local stiltsH = 16 * scale
	local sphereDiam = 8 * scale

	local stiltW = 0.8 * scale
	local stiltSpread = 3 * scale
	for _, sx in ipairs({ -stiltSpread, stiltSpread }) do
		for _, sz in ipairs({ -stiltSpread, stiltSpread }) do
			local stilt = Instance.new("Part")
			stilt.Name = "TowerStilt"
			stilt.Size = Vector3.new(stiltW, stiltsH, stiltW)
			stilt.Position = Vector3.new(towerX + sx, BUILDING_BASE + stiltsH / 2, towerZ + sz)
			stilt.Anchored = true
			stilt.Material = Enum.Material.Metal
			stilt.Color = Color3.fromRGB(120, 120, 125)
			stilt.Parent = model
		end
	end

	-- Cross braces
	for _, bz in ipairs({ -stiltSpread, stiltSpread }) do
		local brace = Instance.new("Part")
		brace.Name = "TowerBrace"
		brace.Size = Vector3.new(stiltSpread * 2, 0.5 * scale, 0.5 * scale)
		brace.CFrame = CFrame.new(towerX, BUILDING_BASE + stiltsH * 0.5, towerZ + bz)
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
	sphere.Position = Vector3.new(towerX, BUILDING_BASE + stiltsH + sphereDiam / 2, towerZ)
	sphere.Anchored = true
	sphere.Material = Enum.Material.SmoothPlastic
	sphere.Color = Color3.fromRGB(180, 200, 220)
	sphere.Parent = model

	-- Water tower label (on +Z face)
	local towerGui = Instance.new("SurfaceGui")
	towerGui.Face = Enum.NormalId.Front
	towerGui.Parent = sphere

	local towerTxt = Instance.new("TextLabel")
	towerTxt.Size = UDim2.new(0.8, 0, 0.3, 0)
	towerTxt.Position = UDim2.new(0.1, 0, 0.35, 0)
	towerTxt.BackgroundTransparency = 1
	towerTxt.Font = Enum.Font.GothamBold
	towerTxt.Text = "H2O"
	towerTxt.TextColor3 = Color3.fromRGB(60, 100, 160)
	towerTxt.TextScaled = true
	towerTxt.Parent = towerGui

	---------------------------------------------------------------------------
	-- 2 CHEMICAL TANKS (near water tower)
	---------------------------------------------------------------------------
	for i = 1, 2 do
		local chemZ = towerZ + (10 + (i - 1) * 6) * scale
		local chemX = towerX
		local chemDiam = 3 * scale
		local chemH = 10 * scale

		local chem = Instance.new("Part")
		chem.Name = "ChemicalTank"
		chem.Shape = Enum.PartType.Cylinder
		chem.Size = Vector3.new(chemH, chemDiam, chemDiam)
		chem.CFrame = CFrame.new(chemX, BUILDING_BASE + chemH / 2, chemZ) * CFrame.Angles(0, 0, math.rad(90))
		chem.Anchored = true
		chem.Material = Enum.Material.SmoothPlastic
		chem.Color = spec.chemColors[i]
		chem.Parent = model

		local cap = Instance.new("Part")
		cap.Name = "TankCap"
		cap.Shape = Enum.PartType.Cylinder
		cap.Size = Vector3.new(0.5 * scale, chemDiam + 0.3, chemDiam + 0.3)
		cap.CFrame = CFrame.new(chemX, BUILDING_BASE + chemH + 0.25 * scale, chemZ) * CFrame.Angles(0, 0, math.rad(90))
		cap.Anchored = true
		cap.Material = Enum.Material.Metal
		cap.Color = Color3.fromRGB(80, 80, 85)
		cap.Parent = model

		-- Chemical label (on +Z face)
		local labelPart = Instance.new("Part")
		labelPart.Name = "ChemLabel"
		labelPart.Size = Vector3.new(2.5 * scale, 1.5 * scale, 0.1)
		labelPart.Position = Vector3.new(chemX, BUILDING_BASE + chemH * 0.6, chemZ + chemDiam / 2 + 0.05)
		labelPart.Anchored = true
		labelPart.CanCollide = false
		labelPart.Material = Enum.Material.SmoothPlastic
		labelPart.Color = Color3.fromRGB(240, 240, 240)
		labelPart.Parent = model

		local labelGui = Instance.new("SurfaceGui")
		labelGui.Face = Enum.NormalId.Front
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

	---------------------------------------------------------------------------
	-- CONTROL BOOTH (small building, +Z side)
	---------------------------------------------------------------------------
	local boothW = 8 * scale
	local boothH2 = 6 * scale
	local boothD = 6 * scale
	local boothX = centerX - 10 * scale
	local boothZ = centerZ + 12 * scale

	local booth = Instance.new("Part")
	booth.Name = "ControlBooth"
	booth.Size = Vector3.new(boothW, boothH2, boothD)
	booth.Position = Vector3.new(boothX, BUILDING_BASE + boothH2 / 2, boothZ)
	booth.Anchored = true
	booth.Material = Enum.Material.Concrete
	booth.Color = spec.boothColor
	booth.Parent = model

	local boothRoof = Instance.new("Part")
	boothRoof.Name = "BoothRoof"
	boothRoof.Size = Vector3.new(boothW + 1 * scale, 0.4 * scale, boothD + 1 * scale)
	boothRoof.Position = Vector3.new(boothX, BUILDING_BASE + boothH2 + 0.2 * scale, boothZ)
	boothRoof.Anchored = true
	boothRoof.Material = Enum.Material.Metal
	boothRoof.Color = Color3.fromRGB(70, 70, 75)
	boothRoof.Parent = model

	-- Booth window (+Z face)
	local boothWin = Instance.new("Part")
	boothWin.Name = "BoothWindow"
	boothWin.Size = Vector3.new(4 * scale, 2.5 * scale, 0.2 * scale)
	boothWin.Position = Vector3.new(boothX, BUILDING_BASE + boothH2 * 0.65, boothZ + boothD / 2 + 0.1)
	boothWin.Anchored = true
	boothWin.CanCollide = false
	boothWin.Material = Enum.Material.Glass
	boothWin.Color = Color3.fromRGB(180, 210, 240)
	boothWin.Transparency = 0.3
	boothWin.Parent = model

	local boothLight = Instance.new("PointLight")
	boothLight.Brightness = 1.0
	boothLight.Range = 8
	boothLight.Color = Color3.fromRGB(255, 240, 200)
	boothLight.Parent = boothWin

	---------------------------------------------------------------------------
	-- MAIN SIGN (neon text, +Z face)
	---------------------------------------------------------------------------
	local signW4 = 14 * scale
	local signH4 = 2.5 * scale

	local signPart3 = Instance.new("Part")
	signPart3.Name = "WaterPlantSign"
	signPart3.Size = Vector3.new(signW4, signH4, 0.4 * scale)
	signPart3.Position = Vector3.new(centerX, BUILDING_BASE + 8 * scale, centerZ + 16 * scale)
	signPart3.Anchored = true
	signPart3.Material = Enum.Material.Neon
	signPart3.Color = spec.signColor
	signPart3.Parent = model

	local gui3 = Instance.new("SurfaceGui")
	gui3.Face = Enum.NormalId.Front
	gui3.Parent = signPart3

	local txt3 = Instance.new("TextLabel")
	txt3.Size = UDim2.new(1, 0, 1, 0)
	txt3.BackgroundTransparency = 1
	txt3.Font = Enum.Font.GothamBold
	txt3.Text = spec.signText
	txt3.TextColor3 = Color3.new(1, 1, 1)
	txt3.TextScaled = true
	txt3.Parent = gui3

	local signLight3 = Instance.new("PointLight")
	signLight3.Brightness = 1.2
	signLight3.Range = 12
	signLight3.Color = spec.signColor
	signLight3.Parent = signPart3

	---------------------------------------------------------------------------
	-- FLOOD LIGHTS (4 poles around the facility)
	---------------------------------------------------------------------------
	local floodH = 12 * scale
	local floodPositions = {
		{ x = tankX, z = centerZ - tankSpacing / 2 - 9 * scale },
		{ x = tankX, z = centerZ + tankSpacing / 2 + 9 * scale },
		{ x = basinX, z = centerZ - basinD / 2 - 2 * scale },
		{ x = basinX, z = centerZ + basinD / 2 + 2 * scale },
	}
	for _, fp in ipairs(floodPositions) do
		local pole = Instance.new("Part")
		pole.Name = "FloodPole"
		pole.Size = Vector3.new(0.4 * scale, floodH, 0.4 * scale)
		pole.Position = Vector3.new(fp.x, BUILDING_BASE + floodH / 2, fp.z)
		pole.Anchored = true
		pole.Material = Enum.Material.Metal
		pole.Color = Color3.fromRGB(110, 110, 115)
		pole.Parent = model

		local fixture = Instance.new("Part")
		fixture.Name = "FloodLight"
		fixture.Size = Vector3.new(1.5 * scale, 0.6 * scale, 1.5 * scale)
		fixture.Position = Vector3.new(fp.x, BUILDING_BASE + floodH + 0.3 * scale, fp.z)
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

	---------------------------------------------------------------------------
	-- SECURITY FENCE (+Z perimeter)
	---------------------------------------------------------------------------
	local fenceH2 = 3.5 * scale
	local fenceW2 = 38 * scale
	local fenceZ3 = centerZ + 20 * scale

	local fence = Instance.new("Part")
	fence.Name = "SecurityFence"
	fence.Size = Vector3.new(fenceW2, fenceH2, 0.3 * scale)
	fence.Position = Vector3.new(centerX, BUILDING_BASE + fenceH2 / 2, fenceZ3)
	fence.Anchored = true
	fence.Material = Enum.Material.Metal
	fence.Color = Color3.fromRGB(130, 130, 135)
	fence.Transparency = 0.3
	fence.Parent = model

	local postSpacing = fenceW2 / 7
	for i = 1, 6 do
		local postX = centerX - fenceW2 / 2 + i * postSpacing
		local post = Instance.new("Part")
		post.Name = "FencePost"
		post.Size = Vector3.new(0.4 * scale, fenceH2 + 0.5 * scale, 0.4 * scale)
		post.Position = Vector3.new(postX, BUILDING_BASE + (fenceH2 + 0.5 * scale) / 2, fenceZ3)
		post.Anchored = true
		post.Material = Enum.Material.Metal
		post.Color = Color3.fromRGB(110, 110, 115)
		post.Parent = model
	end

	if options.parent then
		model.Parent = options.parent
	end

	-- Return animation data for clarifier arms
	return model, clarifierAnims
end

--------------------------------------------------------------------------------
-- MILITARY BASE (stub — props will be added later)
-- Options: parent, scale
--------------------------------------------------------------------------------

function AssetLibrary.createMilitaryBase(centerX, centerZ, options)
	options = options or {}

	local model = Instance.new("Model")
	model.Name = "MilitaryBase"

	if options.parent then
		model.Parent = options.parent
	end

	return model
end

--------------------------------------------------------------------------------
-- TELEPORT PAD
-- Neon landing platform with holographic rings and district name sign.
-- Safe spawn point — placed at road-edge corners away from buildings/traffic.
-- Options: parent, scale, districtName, color (Color3), baseY
--------------------------------------------------------------------------------

function AssetLibrary.createTeleportPad(centerX, centerZ, options)
	options = options or {}
	local scale = options.scale or 1
	local baseY = options.baseY or BUILDING_BASE
	local padColor = options.color or Color3.fromRGB(0, 180, 255)
	local districtName = options.districtName or "ZONE"

	local model = Instance.new("Model")
	model.Name = "TeleportPad_" .. districtName

	-- Main platform (octagonal look via cylinder)
	local platDiam = 12 * scale
	local platH = 0.6 * scale
	local platform = Instance.new("Part")
	platform.Name = "Platform"
	platform.Shape = Enum.PartType.Cylinder
	platform.Size = Vector3.new(platH, platDiam, platDiam)
	platform.CFrame = CFrame.new(centerX, baseY + platH / 2, centerZ) * CFrame.Angles(0, 0, math.rad(90))
	platform.Anchored = true
	platform.Material = Enum.Material.Neon
	platform.Color = padColor
	platform.Parent = model

	-- Dark inner disc (contrast ring)
	local innerDiam = 9 * scale
	local innerH = 0.15 * scale
	local innerDisc = Instance.new("Part")
	innerDisc.Name = "InnerDisc"
	innerDisc.Shape = Enum.PartType.Cylinder
	innerDisc.Size = Vector3.new(innerH, innerDiam, innerDiam)
	innerDisc.CFrame = CFrame.new(centerX, baseY + platH + innerH / 2, centerZ) * CFrame.Angles(0, 0, math.rad(90))
	innerDisc.Anchored = true
	innerDisc.CanCollide = false
	innerDisc.Material = Enum.Material.SmoothPlastic
	innerDisc.Color = Color3.fromRGB(20, 20, 25)
	innerDisc.Parent = model

	-- Neon center dot
	local dotDiam = 2 * scale
	local dot = Instance.new("Part")
	dot.Name = "CenterDot"
	dot.Shape = Enum.PartType.Cylinder
	dot.Size = Vector3.new(0.2 * scale, dotDiam, dotDiam)
	dot.CFrame = CFrame.new(centerX, baseY + platH + 0.2 * scale, centerZ) * CFrame.Angles(0, 0, math.rad(90))
	dot.Anchored = true
	dot.CanCollide = false
	dot.Material = Enum.Material.Neon
	dot.Color = padColor
	dot.Parent = model

	-- Holographic ring (floating, slow spin via animation data)
	local ringDiam = 10 * scale
	local ringThick = 0.25 * scale
	local ring = Instance.new("Part")
	ring.Name = "HoloRing"
	ring.Shape = Enum.PartType.Cylinder
	ring.Size = Vector3.new(ringThick, ringDiam, ringDiam)
	ring.CFrame = CFrame.new(centerX, baseY + 3 * scale, centerZ) * CFrame.Angles(0, 0, math.rad(90))
	ring.Anchored = true
	ring.CanCollide = false
	ring.Material = Enum.Material.Neon
	ring.Color = padColor
	ring.Transparency = 0.4
	ring.Parent = model

	-- Second ring (smaller, higher)
	local ring2Diam = 6 * scale
	local ring2 = Instance.new("Part")
	ring2.Name = "HoloRing2"
	ring2.Shape = Enum.PartType.Cylinder
	ring2.Size = Vector3.new(ringThick, ring2Diam, ring2Diam)
	ring2.CFrame = CFrame.new(centerX, baseY + 5 * scale, centerZ) * CFrame.Angles(0, 0, math.rad(90))
	ring2.Anchored = true
	ring2.CanCollide = false
	ring2.Material = Enum.Material.Neon
	ring2.Color = padColor
	ring2.Transparency = 0.55
	ring2.Parent = model

	-- Glow light under rings
	local glow = Instance.new("PointLight")
	glow.Brightness = 2
	glow.Range = 20
	glow.Color = padColor
	glow.Parent = dot

	-- 4 corner pillars with neon strips
	local pillarH = 4 * scale
	local pillarW = 0.4 * scale
	local pillarOff = 5 * scale
	for _, ox in ipairs({ -pillarOff, pillarOff }) do
		for _, oz in ipairs({ -pillarOff, pillarOff }) do
			local pillar = Instance.new("Part")
			pillar.Name = "PadPillar"
			pillar.Size = Vector3.new(pillarW, pillarH, pillarW)
			pillar.Position = Vector3.new(centerX + ox, baseY + pillarH / 2, centerZ + oz)
			pillar.Anchored = true
			pillar.Material = Enum.Material.Neon
			pillar.Color = padColor
			pillar.Transparency = 0.2
			pillar.Parent = model
		end
	end

	-- District name sign (floating above)
	local signW = 10 * scale
	local signH = 2 * scale
	local signPart = Instance.new("Part")
	signPart.Name = "DistrictSign"
	signPart.Size = Vector3.new(signW, signH, 0.2 * scale)
	signPart.Position = Vector3.new(centerX, baseY + 7 * scale, centerZ)
	signPart.Anchored = true
	signPart.CanCollide = false
	signPart.Material = Enum.Material.Neon
	signPart.Color = padColor
	signPart.Transparency = 0.3
	signPart.Parent = model

	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.Parent = signPart

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamBold
	lbl.Text = districtName
	lbl.TextColor3 = Color3.new(1, 1, 1)
	lbl.TextScaled = true
	lbl.Parent = gui

	-- Back face too
	local gui2 = Instance.new("SurfaceGui")
	gui2.Face = Enum.NormalId.Back
	gui2.Parent = signPart

	local lbl2 = Instance.new("TextLabel")
	lbl2.Size = UDim2.new(1, 0, 1, 0)
	lbl2.BackgroundTransparency = 1
	lbl2.Font = Enum.Font.GothamBold
	lbl2.Text = districtName
	lbl2.TextColor3 = Color3.new(1, 1, 1)
	lbl2.TextScaled = true
	lbl2.Parent = gui2

	-- Beam particles (vertical light column)
	local beamTop = Instance.new("Part")
	beamTop.Name = "BeamTop"
	beamTop.Size = Vector3.new(1, 1, 1)
	beamTop.Position = Vector3.new(centerX, baseY + 15 * scale, centerZ)
	beamTop.Anchored = true
	beamTop.CanCollide = false
	beamTop.Transparency = 1
	beamTop.Parent = model

	local beamBottom = Instance.new("Part")
	beamBottom.Name = "BeamBottom"
	beamBottom.Size = Vector3.new(1, 1, 1)
	beamBottom.Position = Vector3.new(centerX, baseY + platH, centerZ)
	beamBottom.Anchored = true
	beamBottom.CanCollide = false
	beamBottom.Transparency = 1
	beamBottom.Parent = model

	local att0 = Instance.new("Attachment")
	att0.Parent = beamBottom
	local att1 = Instance.new("Attachment")
	att1.Parent = beamTop

	local beam = Instance.new("Beam")
	beam.Attachment0 = att0
	beam.Attachment1 = att1
	beam.Width0 = 4 * scale
	beam.Width1 = 0.5 * scale
	beam.Color = ColorSequence.new(padColor)
	beam.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0.95) })
	beam.LightEmission = 1
	beam.FaceCamera = true
	beam.Parent = beamBottom

	if options.parent then
		model.Parent = options.parent
	end

	return model, {
		type = "teleport_pad",
		ring = ring,
		ring2 = ring2,
		platform = platform,
	}
end

return AssetLibrary
