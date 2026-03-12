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

return AssetLibrary
