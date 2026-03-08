-- SkylineApproach.luau
-- Manhattan-style skyscrapers with two facade types:
--   "glass"    — full glass curtain wall with mullions (the main/elevator building)
--   "concrete" — solid walls with punched window openings (surrounding buildings)
-- Buildings are pre-built as templates at game start, then cloned for instant placement.
-- Only the central glass building gets NPCs (to make the elevator building stand out).

local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))
local RunService = game:GetService("RunService")

local SkylineApproach = {}

local BUILDING_BASE = DecorUtils.BUILDING_BASE

--------------------------------------------------------------------------------
-- SHARED DEFAULTS
--------------------------------------------------------------------------------

local LOBBY_H = 16 -- ground floor lobby = double height
local FLOOR_H = 8 -- regular office floors
local DEFAULT_FLOORS = 16 -- default floor count
local FACADE_W = 30 -- width along X
local DEPTH = 20 -- depth along Z
local FRONT_PANELS = 5 -- glass panels per floor on front/back
local SIDE_PANELS = 3 -- glass panels per floor on sides

local FLOOR_COLOR = Color3.fromRGB(210, 210, 215)
local LIGHT_COLOR = Color3.fromRGB(255, 240, 210)

--------------------------------------------------------------------------------
-- STYLE PRESETS
--------------------------------------------------------------------------------

local STYLES = {
	-- Glass tower — the main elevator building (only one that gets NPCs)
	glass_blue = {
		facade = "glass",
		floors = 16,
		hasNPCs = true,
		glassColor = Color3.fromRGB(180, 215, 245),
		frameColor = Color3.fromRGB(140, 145, 155),
		postColor = Color3.fromRGB(80, 85, 95),
		lightColor = Color3.fromRGB(220, 235, 255), -- cool white
	},

	-- Concrete towers — surrounding backdrop buildings (no NPCs)
	concrete_grey = {
		facade = "concrete",
		floors = 12,
		wallMaterial = Enum.Material.Concrete,
		wallColor = Color3.fromRGB(180, 175, 170),
		trimColor = Color3.fromRGB(140, 138, 135),
		postColor = Color3.fromRGB(100, 98, 95),
		windowColor = Color3.fromRGB(60, 80, 105),
		windowTransparency = 0.6,
		lightColor = Color3.fromRGB(255, 240, 210), -- warm yellow
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
		lightColor = Color3.fromRGB(255, 200, 150), -- warm orange
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
		lightColor = Color3.fromRGB(255, 250, 230), -- bright warm white
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
		lightColor = Color3.fromRGB(180, 210, 255), -- cool blue
	},
}

--------------------------------------------------------------------------------
-- TEMPLATE CACHE — pre-built models stored here at game start
--------------------------------------------------------------------------------

local templateCache = {} -- styleKey -> Model (positioned at origin)

-- Elevator data stored after createCityGrid so WorldLoader can query it
local lastElevatorData = nil

--------------------------------------------------------------------------------
-- HELPER: build glass facade for one wall of one floor
--------------------------------------------------------------------------------

local function buildGlassFacade(parent, axis, faceCoord, centerX, centerZ, wallWidth, panelCount, floorBaseY, floorH, scale, glassColor, frameColor)
	local mullionThick = 0.3 * scale
	local margin = 0.2 * scale
	local available = wallWidth - 2 * margin
	local pw = (available - (panelCount - 1) * mullionThick) / panelCount
	local bandThick = 0.4 * scale
	local glassH = floorH - bandThick
	local glassY = floorBaseY + bandThick / 2 + glassH / 2

	for p = 0, panelCount - 1 do
		local off = -available / 2 + pw / 2 + p * (pw + mullionThick)

		local panel = Instance.new("Part")
		panel.Name = "GlassPanel"
		if axis == "x" then
			panel.Size = Vector3.new(0.2, glassH, pw)
			panel.Position = Vector3.new(faceCoord, glassY, centerZ + off)
		else
			panel.Size = Vector3.new(pw, glassH, 0.2)
			panel.Position = Vector3.new(centerX + off, glassY, faceCoord)
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
				mullion.Position = Vector3.new(faceCoord, floorBaseY + floorH / 2, centerZ + mOff)
			else
				mullion.Size = Vector3.new(mullionThick, floorH, mullionThick)
				mullion.Position = Vector3.new(centerX + mOff, floorBaseY + floorH / 2, faceCoord)
			end
			mullion.Anchored = true
			mullion.CanCollide = false
			mullion.Material = Enum.Material.DiamondPlate
			mullion.Color = frameColor
			mullion.Parent = parent
		end
	end
end

--------------------------------------------------------------------------------
-- HELPER: build concrete facade for one wall of one floor
-- Concrete grid (spandrels + piers) with glass recessed behind the openings.
--------------------------------------------------------------------------------

local function buildConcreteFacade(parent, axis, faceCoord, centerX, centerZ, wallWidth, windowCount, floorBaseY, floorH, scale, wallMaterial, wallColor, windowColor, windowTransparency)
	local s = scale
	local wallThick = 0.5 * s
	local margin = 1.5 * s
	local available = wallWidth - 2 * margin
	local spacing = available / windowCount
	local pierW = spacing * 0.3
	local winW = spacing - pierW
	local winTransp = windowTransparency or 0.15

	-- Clean vertical split: bottom band, window zone, top band (no gaps)
	local bottomH = floorH * 0.2 -- bottom concrete band
	local topH = floorH * 0.12 -- top concrete band
	local winH = floorH - bottomH - topH -- window fills the rest exactly
	local winY = floorBaseY + bottomH + winH / 2 -- window center

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

	-- Bottom spandrel (full width)
	if axis == "x" then
		makeConcrete("Spandrel", Vector3.new(wallThick, bottomH, wallWidth), Vector3.new(faceCoord, floorBaseY + bottomH / 2, centerZ))
	else
		makeConcrete("Spandrel", Vector3.new(wallWidth, bottomH, wallThick), Vector3.new(centerX, floorBaseY + bottomH / 2, faceCoord))
	end

	-- Top spandrel (full width)
	if axis == "x" then
		makeConcrete("Spandrel", Vector3.new(wallThick, topH, wallWidth), Vector3.new(faceCoord, floorBaseY + floorH - topH / 2, centerZ))
	else
		makeConcrete("Spandrel", Vector3.new(wallWidth, topH, wallThick), Vector3.new(centerX, floorBaseY + floorH - topH / 2, faceCoord))
	end

	-- Edge piers (margin + half a pier width to bridge gap to first/last window)
	local edgePierW = margin + pierW / 2
	for side = -1, 1, 2 do
		local edgeOff = side * (wallWidth / 2 - edgePierW / 2)
		if axis == "x" then
			makeConcrete("EdgePier", Vector3.new(wallThick, winH, edgePierW), Vector3.new(faceCoord, winY, centerZ + edgeOff))
		else
			makeConcrete("EdgePier", Vector3.new(edgePierW, winH, wallThick), Vector3.new(centerX + edgeOff, winY, faceCoord))
		end
	end

	-- Windows + piers between them
	for w = 0, windowCount - 1 do
		local off = -available / 2 + spacing / 2 + w * spacing

		-- Glass panel (slightly oversized to eliminate hairline gaps)
		local win = Instance.new("Part")
		win.Name = "Window"
		if axis == "x" then
			win.Size = Vector3.new(0.15, winH + 0.2, winW + 0.2)
			win.Position = Vector3.new(faceCoord, winY, centerZ + off)
		else
			win.Size = Vector3.new(winW + 0.2, winH + 0.2, 0.15)
			win.Position = Vector3.new(centerX + off, winY, faceCoord)
		end
		win.Anchored = true
		win.CanCollide = false
		win.Material = Enum.Material.Glass
		win.Color = windowColor
		win.Transparency = winTransp
		win.Parent = parent

		-- Pier to the right (concrete covers the overlap from oversized glass)
		if w < windowCount - 1 then
			local pierOff = off + winW / 2 + pierW / 2
			if axis == "x" then
				makeConcrete("Pier", Vector3.new(wallThick, winH, pierW), Vector3.new(faceCoord, winY, centerZ + pierOff))
			else
				makeConcrete("Pier", Vector3.new(pierW, winH, wallThick), Vector3.new(centerX + pierOff, winY, faceCoord))
			end
		end
	end
end

--------------------------------------------------------------------------------
-- HELPER: build one floor section (internals + facade)
--------------------------------------------------------------------------------

local function buildFloorSection(model, cx, cz, bw, bd, floorBaseY, floorH, frontZ, backZ, leftX, rightX, scale, style)
	local s = scale

	-- Floor slab
	local slab = Instance.new("Part")
	slab.Name = "FloorSlab"
	slab.Size = Vector3.new(bw - 0.4, 0.3 * s, bd - 0.4)
	slab.Position = Vector3.new(cx, floorBaseY + 0.15, cz)
	slab.Anchored = true
	slab.Material = Enum.Material.SmoothPlastic
	slab.Color = FLOOR_COLOR
	slab.Parent = model

	-- Facade
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

		buildGlassFacade(model, "z", frontZ, cx, cz, bw, FRONT_PANELS, floorBaseY, floorH, s, style.glassColor, style.frameColor)
		buildGlassFacade(model, "z", backZ, cx, cz, bw, FRONT_PANELS, floorBaseY, floorH, s, style.glassColor, style.frameColor)
		buildGlassFacade(model, "x", leftX, cx, cz, bd, SIDE_PANELS, floorBaseY, floorH, s, style.glassColor, style.frameColor)
		buildGlassFacade(model, "x", rightX, cx, cz, bd, SIDE_PANELS, floorBaseY, floorH, s, style.glassColor, style.frameColor)

	elseif style.facade == "concrete" then
		buildConcreteFacade(model, "z", frontZ, cx, cz, bw, FRONT_PANELS, floorBaseY, floorH, s, style.wallMaterial, style.wallColor, style.windowColor, style.windowTransparency)
		buildConcreteFacade(model, "z", backZ, cx, cz, bw, FRONT_PANELS, floorBaseY, floorH, s, style.wallMaterial, style.wallColor, style.windowColor, style.windowTransparency)
		buildConcreteFacade(model, "x", leftX, cx, cz, bd, SIDE_PANELS, floorBaseY, floorH, s, style.wallMaterial, style.wallColor, style.windowColor, style.windowTransparency)
		buildConcreteFacade(model, "x", rightX, cx, cz, bd, SIDE_PANELS, floorBaseY, floorH, s, style.wallMaterial, style.wallColor, style.windowColor, style.windowTransparency)
	end

	-- Warm ceiling light (color varies per building style)
	local floorLightColor = style.lightColor or LIGHT_COLOR
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

--------------------------------------------------------------------------------
-- BUILD A TEMPLATE MODEL (at origin, no NPCs, not parented to workspace)
--------------------------------------------------------------------------------

local function buildTemplate(styleKey)
	local style = STYLES[styleKey]
	if not style then return nil end

	local s = 1 -- templates always built at scale 1
	local bw = FACADE_W * s
	local bd = DEPTH * s
	local lobbyH = LOBBY_H * s
	local fh = FLOOR_H * s
	local floors = style.floors or DEFAULT_FLOORS
	local totalH = lobbyH + floors * fh
	local cx = 0
	local cz = -10 -- offset from origin like the original
	local frontZ = cz + bd / 2 + 0.15
	local backZ = cz - bd / 2 - 0.15
	local leftX = cx - bw / 2 - 0.15
	local rightX = cx + bw / 2 + 0.15

	local model = Instance.new("Model")
	model.Name = "SkylineTemplate_" .. styleKey

	-- Corner posts
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

	-- Lobby
	buildFloorSection(model, cx, cz, bw, bd, BUILDING_BASE, lobbyH, frontZ, backZ, leftX, rightX, s, style)

	-- Office floors
	for floor = 1, floors do
		local floorBaseY = BUILDING_BASE + lobbyH + (floor - 1) * fh
		buildFloorSection(model, cx, cz, bw, bd, floorBaseY, fh, frontZ, backZ, leftX, rightX, s, style)
	end

	-- Top band + roof
	local roofY = BUILDING_BASE + totalH
	local bandH = 0.4 * s

	local topBand = Instance.new("Part")
	topBand.Size = Vector3.new(bw, bandH, bandH)
	topBand.Position = Vector3.new(cx, roofY + bandH / 2, frontZ)
	topBand.Anchored = true
	topBand.CanCollide = false
	topBand.Material = Enum.Material.Metal
	topBand.Color = style.frameColor or style.trimColor
	topBand.Parent = model

	local roof = Instance.new("Part")
	roof.Name = "Roof"
	roof.Size = Vector3.new(bw + 0.5, 0.5, bd + 0.5)
	roof.Position = Vector3.new(cx, roofY + 0.25, cz)
	roof.Anchored = true
	roof.Material = Enum.Material.Metal
	roof.Color = style.frameColor or style.trimColor
	roof.Parent = model

	return model
end

--------------------------------------------------------------------------------
-- SPAWN: clone a cached template and reposition, then spawn NPCs if needed
--------------------------------------------------------------------------------

local function spawnBuilding(x, z, scale, styleKey)
	local folder = DecorUtils.decorFolder
	if not folder then return nil end
	scale = scale or 1

	local style = STYLES[styleKey]
	if not style then return nil end

	-- Clone from cache (fast) or build on the fly (fallback)
	local model
	local template = templateCache[styleKey]
	if template then
		model = template:Clone()
		model.Name = "SkylineBuilding_" .. styleKey
	else
		warn("[Skyline] Template not cached for " .. styleKey .. ", building on the fly")
		model = buildTemplate(styleKey)
		if not model then return nil end
		model.Name = "SkylineBuilding_" .. styleKey
	end

	-- Reposition: template was built at (0, -10), move to (x, z - 10)
	local offsetCF = CFrame.new(x, 0, z)
	model:PivotTo(offsetCF * model:GetPivot())

	model.Parent = folder

	-- NPCs only for buildings that want them (the main glass building)
	if style.hasNPCs then
		local NPCManager = DecorUtils.NPCManager
		if NPCManager then
			local s = scale
			local bw = FACADE_W * s
			local lobbyH = LOBBY_H * s
			local fh = FLOOR_H * s
			local floors = style.floors or DEFAULT_FLOORS
			local halfW = bw / 2 - 2 * s
			local halfD = DEPTH * s / 2 - 1 * s
			local cx = x
			local cz = z - 10
			local faceAngles = { 0, 45, 90, 135, 180, 225, 270, 315 }

			-- Lobby: 3 NPCs
			local lobbySlabTop = BUILDING_BASE + 0.3
			for _ = 1, 3 do
				local npcX = cx + (math.random() - 0.5) * halfW * 1.4
				local npcZ = cz + (math.random() - 0.3) * halfD
				local angle = faceAngles[math.random(#faceAngles)]
				task.spawn(function()
					NPCManager.spawnFromTemplate(
						NPCManager.randomCivilian(),
						Vector3.new(npcX, lobbySlabTop + 3.5, npcZ),
						angle, "idle"
					)
				end)
			end

			-- Office floors: 3-4 NPCs each
			for floor = 1, floors do
				local floorBaseY = BUILDING_BASE + lobbyH + (floor - 1) * fh
				local slabTop = floorBaseY + 0.3
				local count = 3 + math.random(0, 1)

				for _ = 1, count do
					local npcX = cx + (math.random() - 0.5) * halfW * 1.4
					local npcZ = cz + (math.random() - 0.3) * halfD
					local angle = faceAngles[math.random(#faceAngles)]
					task.spawn(function()
						NPCManager.spawnFromTemplate(
							NPCManager.randomCivilian(),
							Vector3.new(npcX, slabTop + 3.5, npcZ),
							angle, "idle"
						)
					end)
				end
			end
		end
	end

	return model
end

--------------------------------------------------------------------------------
-- SIMPLE BLOCK — lightweight building for back rows (only rooftop visible
-- from helicopter). Just a body + roof, 2 parts total. Preloaded as templates.
--------------------------------------------------------------------------------

local BLOCK_PRESETS = {
	{ wallColor = Color3.fromRGB(180, 175, 170), material = Enum.Material.Concrete, roofColor = Color3.fromRGB(120, 118, 115), floors = 12 },
	{ wallColor = Color3.fromRGB(160, 110, 90),  material = Enum.Material.Brick,    roofColor = Color3.fromRGB(100, 75, 65),   floors = 10 },
	{ wallColor = Color3.fromRGB(210, 200, 180), material = Enum.Material.Limestone, roofColor = Color3.fromRGB(150, 142, 130), floors = 14 },
	{ wallColor = Color3.fromRGB(90, 88, 85),    material = Enum.Material.Concrete, roofColor = Color3.fromRGB(60, 58, 55),    floors = 16 },
	{ wallColor = Color3.fromRGB(150, 145, 140), material = Enum.Material.Concrete, roofColor = Color3.fromRGB(110, 108, 105), floors = 11 },
	{ wallColor = Color3.fromRGB(130, 95, 80),   material = Enum.Material.Brick,    roofColor = Color3.fromRGB(90, 68, 58),    floors = 13 },
}

local blockTemplateCache = {} -- index -> Model

local function buildBlockTemplate(presetIdx)
	local preset = BLOCK_PRESETS[presetIdx]
	local bw = FACADE_W
	local bd = DEPTH
	local totalH = LOBBY_H + preset.floors * FLOOR_H

	local model = Instance.new("Model")
	model.Name = "SkylineBlock_" .. presetIdx

	-- Body
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(bw, totalH, bd)
	body.Position = Vector3.new(0, BUILDING_BASE + totalH / 2, -10)
	body.Anchored = true
	body.CanCollide = false
	body.Material = preset.material
	body.Color = preset.wallColor
	body.Parent = model

	-- Roof
	local roof = Instance.new("Part")
	roof.Name = "Roof"
	roof.Size = Vector3.new(bw + 0.5, 0.5, bd + 0.5)
	roof.Position = Vector3.new(0, BUILDING_BASE + totalH + 0.25, -10)
	roof.Anchored = true
	roof.Material = Enum.Material.Metal
	roof.Color = preset.roofColor
	roof.Parent = model

	return model
end

local function spawnBlock(x, z, presetIdx)
	local folder = DecorUtils.decorFolder
	if not folder then return nil end

	local model
	local template = blockTemplateCache[presetIdx]
	if template then
		model = template:Clone()
	else
		model = buildBlockTemplate(presetIdx)
	end

	local offsetCF = CFrame.new(x, 0, z)
	model:PivotTo(offsetCF * model:GetPivot())
	model.Parent = folder
	return model
end

--------------------------------------------------------------------------------
-- CITY GRID HELPERS
--------------------------------------------------------------------------------

local BUILDING_SPACING = 33 -- center-to-center
local CONCRETE_STYLES = { "concrete_grey", "concrete_brick", "concrete_sandstone", "concrete_dark" }
local ROW_SPACING = 28 -- Z distance between rows

-- Pick a style/index that differs from the previous one
local function pickStyle(avoid)
	local choices = {}
	for _, s in ipairs(CONCRETE_STYLES) do
		if s ~= avoid then
			table.insert(choices, s)
		end
	end
	return choices[math.random(#choices)]
end

local function pickBlock(avoid)
	local idx
	repeat
		idx = math.random(1, #BLOCK_PRESETS)
	until idx ~= avoid
	return idx
end

--------------------------------------------------------------------------------
-- ROOFTOP ANTENNAS — thin poles + pulsing red neon lights on building edges
--------------------------------------------------------------------------------

local antennaLights = {} -- all neon beacon parts for pulse animation
local antennaPulseConn = nil

local ANTENNA_COLORS = {
	pole = Color3.fromRGB(70, 70, 65),
	beacon = Color3.fromRGB(255, 30, 20),
	crossArm = Color3.fromRGB(55, 55, 50),
}

-- Add a rooftop antenna to a building at the given world position
-- roofY = top surface of the roof, bw/bd = building width/depth
local function addRooftopAntenna(folder, bx, bz, roofY, bw, bd)
	local variant = math.random(1, 4)

	-- Place antenna near a random edge/corner of the roof
	local edgeX = bx + (math.random() - 0.5) * (bw - 3)
	local edgeZ = bz + (math.random() - 0.5) * (bd - 3)

	local poleH
	if variant <= 2 then
		-- Variant 1-2: Simple pole + beacon
		poleH = math.random(6, 12)
	else
		-- Variant 3-4: Taller lattice with cross-arms
		poleH = math.random(10, 18)
	end

	-- Main pole
	local pole = Instance.new("Part")
	pole.Name = "AntennaPole"
	pole.Size = Vector3.new(0.3, poleH, 0.3)
	pole.Position = Vector3.new(edgeX, roofY + poleH / 2, edgeZ)
	pole.Anchored = true
	pole.CanCollide = false
	pole.Material = Enum.Material.Metal
	pole.Color = ANTENNA_COLORS.pole
	pole.Parent = folder

	-- Red beacon on top
	local beacon = Instance.new("Part")
	beacon.Name = "AntennaBeacon"
	beacon.Shape = Enum.PartType.Ball
	beacon.Size = Vector3.new(0.8, 0.8, 0.8)
	beacon.Position = Vector3.new(edgeX, roofY + poleH + 0.4, edgeZ)
	beacon.Anchored = true
	beacon.CanCollide = false
	beacon.Material = Enum.Material.Neon
	beacon.Color = ANTENNA_COLORS.beacon
	beacon.Parent = folder

	local beaconGlow = Instance.new("PointLight")
	beaconGlow.Color = Color3.fromRGB(255, 40, 30)
	beaconGlow.Brightness = 2
	beaconGlow.Range = 14
	beaconGlow.Parent = beacon

	-- Random phase offset so they don't all blink in sync
	table.insert(antennaLights, {
		part = beacon,
		light = beaconGlow,
		phase = math.random() * math.pi * 2,
	})

	if variant == 3 or variant == 4 then
		-- Cross-arms at ~60% height
		local armY = roofY + poleH * 0.6
		for _, dir in ipairs({-1, 1}) do
			local arm = Instance.new("Part")
			arm.Name = "AntennaCrossArm"
			arm.Size = Vector3.new(2.5, 0.2, 0.2)
			arm.Position = Vector3.new(edgeX + dir * 1.25, armY, edgeZ)
			arm.Anchored = true
			arm.CanCollide = false
			arm.Material = Enum.Material.Metal
			arm.Color = ANTENNA_COLORS.crossArm
			arm.Parent = folder
		end
	end

	if variant == 4 then
		-- Second smaller beacon at mid-height
		local midY = roofY + poleH * 0.45
		local midBeacon = Instance.new("Part")
		midBeacon.Name = "AntennaBeaconMid"
		midBeacon.Shape = Enum.PartType.Ball
		midBeacon.Size = Vector3.new(0.5, 0.5, 0.5)
		midBeacon.Position = Vector3.new(edgeX, midY, edgeZ)
		midBeacon.Anchored = true
		midBeacon.CanCollide = false
		midBeacon.Material = Enum.Material.Neon
		midBeacon.Color = ANTENNA_COLORS.beacon
		midBeacon.Parent = folder

		table.insert(antennaLights, {
			part = midBeacon,
			light = nil,
			phase = math.random() * math.pi * 2 + math.pi, -- offset from top beacon
		})
	end
end

-- Start the pulse animation for all antenna beacons
local function startAntennaPulse()
	if antennaPulseConn then return end
	local elapsed = 0
	antennaPulseConn = RunService.Heartbeat:Connect(function(dt)
		elapsed = elapsed + dt
		for i = #antennaLights, 1, -1 do
			local a = antennaLights[i]
			if not a.part or not a.part.Parent then
				table.remove(antennaLights, i)
			else
				-- Slow blink: sharp on/off pulse (on for ~0.3s, off for ~1.5s)
				local t = (elapsed * 0.55 + a.phase) % (math.pi * 2)
				local pulse = t < 0.6 and 1 or 0
				a.part.Transparency = pulse == 1 and 0 or 0.85
				if a.light then
					a.light.Brightness = pulse == 1 and 2.5 or 0
				end
			end
		end
		if #antennaLights == 0 then
			antennaPulseConn:Disconnect()
			antennaPulseConn = nil
		end
	end)
end

--------------------------------------------------------------------------------
-- CITY GRID BUILDER — one call places the entire skyline
-- Row 0: glass center + concrete flanking (detailed, ground level view)
-- Row 1: concrete buildings (detailed, second row)
-- Rows 2+: simple blocks (only rooftops matter for helicopter)
--------------------------------------------------------------------------------

local GRID_ROWS = 25 -- total rows of buildings (row 0 = main, rows 1-3 = detailed, rows 4+ = blocks)
local BUILDINGS_PER_ROW = 7 -- buildings across X

function SkylineApproach.createCityGrid(x, z, scale)
	local folder = DecorUtils.decorFolder
	if not folder then return nil end

	-- Reset antenna state on rebuild
	if antennaPulseConn then antennaPulseConn:Disconnect(); antennaPulseConn = nil end
	antennaLights = {}

	-- Shift grid forward so row 0 is near the front of the lane (player enters from front)
	-- Lane depth=800, so front edge is at z+400. Place row 0 about 30 studs from front.
	local baseZ = z + 370

	-- Row 0: main row — glass center + concrete flanking
	spawnBuilding(x, baseZ, scale, "glass_blue")
	local prevLeft, prevRight = "glass_blue", "glass_blue"
	for i = 1, 3 do
		local offset = i * BUILDING_SPACING
		local leftStyle = pickStyle(prevLeft)
		spawnBuilding(x - offset, baseZ, scale, leftStyle)
		prevLeft = leftStyle
		local rightStyle = pickStyle(prevRight)
		spawnBuilding(x + offset, baseZ, scale, rightStyle)
		prevRight = rightStyle
	end

	----------------------------------------------------------------------------
	-- ELEVATOR at front entrance of glass building
	----------------------------------------------------------------------------
	local glassStyle = STYLES.glass_blue
	local totalBuildingH = LOBBY_H + (glassStyle.floors or DEFAULT_FLOORS) * FLOOR_H
	local buildingCZ = baseZ - 10 -- building template offset
	local buildingFrontZ = buildingCZ + DEPTH / 2 + 0.15

	-- Shaft dimensions
	local shaftW = 6
	local shaftD = 5
	local shaftX = x -- centered on building
	local shaftZ = buildingFrontZ + shaftD / 2 + 0.5 -- protrudes in front of lobby

	-- Steel frame rails along shaft edges (no glass panels — keeps neon cabin visible)
	for dx = -1, 1, 2 do
		for dz = -1, 1, 2 do
			local rail = Instance.new("Part")
			rail.Name = "ShaftRail"
			rail.Size = Vector3.new(0.3, totalBuildingH, 0.3)
			rail.Position = Vector3.new(
				shaftX + dx * (shaftW / 2 - 0.15),
				BUILDING_BASE + totalBuildingH / 2,
				shaftZ + dz * (shaftD / 2 - 0.15)
			)
			rail.Anchored = true
			rail.CanCollide = false
			rail.Material = Enum.Material.DiamondPlate
			rail.Color = Color3.fromRGB(80, 85, 95)
			rail.Parent = folder
		end
	end

	-- Elevator platform (rideable, collides) — raised 2 studs above terrain
	local elevBaseY = BUILDING_BASE + 2
	local platformH = 0.4
	local platform = Instance.new("Part")
	platform.Name = "ElevatorPlatform"
	platform.Size = Vector3.new(shaftW - 0.6, platformH, shaftD - 0.6)
	platform.Position = Vector3.new(shaftX, elevBaseY + platformH / 2, shaftZ)
	platform.Anchored = true
	platform.CanCollide = true
	platform.Material = Enum.Material.DiamondPlate
	platform.Color = Color3.fromRGB(160, 165, 170)
	platform.Parent = folder

	-- Cabin dimensions (sits on top of platform, open front)
	local cabinH = 8.0 -- tall enough for Roblox characters
	local cabinWallThick = 0.15
	local cabinW = shaftW - 0.6 -- same as platform width
	local cabinD = shaftD - 0.6 -- same as platform depth
	local cabinBaseY = elevBaseY + platformH -- top of platform
	local cabinCenterY = cabinBaseY + cabinH / 2
	local neonColor = Color3.fromRGB(0, 180, 255) -- cyan accent
	local neonThick = 0.12

	-- Cabin parts table (moved together during ride)
	local cabinParts = {}

	local function addCabinPart(part)
		part.Anchored = true
		part.Parent = folder
		table.insert(cabinParts, part)
		return part
	end

	-- Left wall — glass (back wall omitted so player can exit onto roof)
	local leftWall = Instance.new("Part")
	leftWall.Name = "ElevatorCabinLeft"
	leftWall.Size = Vector3.new(cabinWallThick, cabinH, cabinD)
	leftWall.Position = Vector3.new(shaftX - cabinW / 2, cabinCenterY, shaftZ)
	leftWall.CanCollide = true
	leftWall.Material = Enum.Material.Glass
	leftWall.Color = Color3.fromRGB(180, 215, 245)
	leftWall.Transparency = 0.5
	addCabinPart(leftWall)

	-- Right wall — glass
	local rightWall = Instance.new("Part")
	rightWall.Name = "ElevatorCabinRight"
	rightWall.Size = Vector3.new(cabinWallThick, cabinH, cabinD)
	rightWall.Position = Vector3.new(shaftX + cabinW / 2, cabinCenterY, shaftZ)
	rightWall.CanCollide = true
	rightWall.Material = Enum.Material.Glass
	rightWall.Color = Color3.fromRGB(180, 215, 245)
	rightWall.Transparency = 0.5
	addCabinPart(rightWall)

	-- Cabin ceiling — glass
	local ceiling = Instance.new("Part")
	ceiling.Name = "ElevatorCabinCeiling"
	ceiling.Size = Vector3.new(cabinW, 0.3, cabinD)
	ceiling.Position = Vector3.new(shaftX, cabinBaseY + cabinH, shaftZ)
	ceiling.CanCollide = false
	ceiling.Material = Enum.Material.Glass
	ceiling.Color = Color3.fromRGB(180, 215, 245)
	ceiling.Transparency = 0.5
	addCabinPart(ceiling)

	-- Handrail on back wall
	local handrail = Instance.new("Part")
	handrail.Name = "ElevatorHandrail"
	handrail.Size = Vector3.new(cabinW - 0.6, 0.12, 0.12)
	handrail.Position = Vector3.new(shaftX, cabinBaseY + 2.5, shaftZ - cabinD / 2 + 0.2)
	handrail.CanCollide = false
	handrail.Material = Enum.Material.DiamondPlate
	handrail.Color = Color3.fromRGB(100, 105, 110)
	addCabinPart(handrail)

	-- Ceiling light — neon panel
	local elevLight = Instance.new("Part")
	elevLight.Name = "ElevatorCeilingLight"
	elevLight.Size = Vector3.new(cabinW - 1.0, 0.1, cabinD - 1.0)
	elevLight.Position = Vector3.new(shaftX, cabinBaseY + cabinH - 0.25, shaftZ)
	elevLight.CanCollide = false
	elevLight.Material = Enum.Material.Neon
	elevLight.Color = Color3.fromRGB(200, 230, 255)
	elevLight.Transparency = 0.3
	addCabinPart(elevLight)

	-- Neon accent strips along vertical edges (4 corners, 3 sides — skip front 2)
	for _, edge in ipairs({
		-- back-left
		{ Vector3.new(neonThick, cabinH, neonThick), Vector3.new(shaftX - cabinW / 2 + neonThick, cabinCenterY, shaftZ - cabinD / 2 + neonThick) },
		-- back-right
		{ Vector3.new(neonThick, cabinH, neonThick), Vector3.new(shaftX + cabinW / 2 - neonThick, cabinCenterY, shaftZ - cabinD / 2 + neonThick) },
		-- front-left (entry edge)
		{ Vector3.new(neonThick, cabinH, neonThick), Vector3.new(shaftX - cabinW / 2 + neonThick, cabinCenterY, shaftZ + cabinD / 2 - neonThick) },
		-- front-right (entry edge)
		{ Vector3.new(neonThick, cabinH, neonThick), Vector3.new(shaftX + cabinW / 2 - neonThick, cabinCenterY, shaftZ + cabinD / 2 - neonThick) },
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

	-- Neon floor trim strips (bottom edge of back + sides)
	for _, trim in ipairs({
		-- back floor trim
		{ Vector3.new(cabinW, neonThick, neonThick), Vector3.new(shaftX, cabinBaseY + neonThick / 2, shaftZ - cabinD / 2 + neonThick) },
		-- left floor trim
		{ Vector3.new(neonThick, neonThick, cabinD), Vector3.new(shaftX - cabinW / 2 + neonThick, cabinBaseY + neonThick / 2, shaftZ) },
		-- right floor trim
		{ Vector3.new(neonThick, neonThick, cabinD), Vector3.new(shaftX + cabinW / 2 - neonThick, cabinBaseY + neonThick / 2, shaftZ) },
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

	-- Neon ceiling trim strips (top edge of back + sides)
	for _, trim in ipairs({
		{ Vector3.new(cabinW, neonThick, neonThick), Vector3.new(shaftX, cabinBaseY + cabinH - neonThick / 2, shaftZ - cabinD / 2 + neonThick) },
		{ Vector3.new(neonThick, neonThick, cabinD), Vector3.new(shaftX - cabinW / 2 + neonThick, cabinBaseY + cabinH - neonThick / 2, shaftZ) },
		{ Vector3.new(neonThick, neonThick, cabinD), Vector3.new(shaftX + cabinW / 2 - neonThick, cabinBaseY + cabinH - neonThick / 2, shaftZ) },
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

	----------------------------------------------------------------------------
	-- NEON CHEVRONS on ground leading to elevator
	----------------------------------------------------------------------------
	local chevrons = {}
	local chevronCount = 6
	local chevronArmLen = 3.0
	local chevronAngle = math.rad(35)
	local chevronColor = Color3.fromRGB(0, 180, 255)
	local chevronStartZ = shaftZ + shaftD / 2 + 20 -- furthest from building
	local chevronEndZ = shaftZ + shaftD / 2 + 3    -- closest to building
	local chevronSpacing = (chevronStartZ - chevronEndZ) / (chevronCount + 1)

	local Workspace = game:GetService("Workspace")
	for i = 1, chevronCount do
		local t = i / (chevronCount + 1)
		local cZ = chevronStartZ - t * (chevronStartZ - chevronEndZ)
		local cY = BUILDING_BASE + 2

		for _, side in ipairs({ -1, 1 }) do
			local arm = Instance.new("Part")
			arm.Name = "ElevatorChevron_" .. i
			arm.Size = Vector3.new(chevronArmLen, 0.4, 0.4)
			arm.CFrame = CFrame.new(x + side * 1.5, cY, cZ)
				* CFrame.Angles(0, -side * chevronAngle, 0)
			arm.Anchored = true
			arm.CanCollide = false
			arm.Material = Enum.Material.Neon
			arm.Color = chevronColor
			arm.Transparency = 0.15
			arm.Parent = Workspace
			table.insert(chevrons, arm)
		end
	end

	print("[Skyline] Created " .. #chevrons .. " chevrons at Y=" .. (BUILDING_BASE + 2) .. " Z range " .. chevronEndZ .. " to " .. chevronStartZ)

	-- Store elevator metadata for WorldLoader
	lastElevatorData = {
		platform = platform,
		elevLight = elevLight,
		cabinParts = cabinParts,
		cabinH = cabinH,
		chevrons = chevrons,
		shaftX = shaftX,
		shaftZ = shaftZ,
		shaftW = shaftW,
		shaftD = shaftD,
		startY = elevBaseY + platformH / 2,
		endY = BUILDING_BASE + totalBuildingH + 0.5 + platformH / 2,
		roofY = BUILDING_BASE + totalBuildingH,
		roofChevrons = {}, -- populated after helipad creation
		helicopter = nil, -- populated after helicopter placement
	}

	----------------------------------------------------------------------------
	-- HELIPAD extending from the right side of the glass building
	----------------------------------------------------------------------------
	local roofTopY = BUILDING_BASE + totalBuildingH + 0.5
	local padW = 26 -- helipad width (along X, extending outward)
	local padD = 22 -- helipad depth (along Z)
	local padThick = 0.5
	local buildingRightX = x + FACADE_W / 2
	local padCenterX = buildingRightX + padW / 2 - 2 -- overlap 2 studs with building
	local padCenterZ = buildingCZ -- aligned with building center
	local padY = roofTopY

	-- Main platform
	local padFloor = Instance.new("Part")
	padFloor.Name = "HelipadFloor"
	padFloor.Size = Vector3.new(padW, padThick, padD)
	padFloor.Position = Vector3.new(padCenterX, padY, padCenterZ)
	padFloor.Anchored = true
	padFloor.CanCollide = true
	padFloor.Material = Enum.Material.DiamondPlate
	padFloor.Color = Color3.fromRGB(130, 135, 140)
	padFloor.Parent = folder

	-- Support struts underneath
	for _, sz in ipairs({ -1, 1 }) do
		local strut = Instance.new("Part")
		strut.Name = "HelipadStrut"
		strut.Size = Vector3.new(1.5, 12, 1.5)
		strut.Position = Vector3.new(padCenterX + padW / 2 - 3, padY - 6, padCenterZ + sz * (padD / 2 - 3))
		strut.Anchored = true
		strut.CanCollide = false
		strut.Material = Enum.Material.DiamondPlate
		strut.Color = Color3.fromRGB(80, 85, 90)
		strut.Parent = folder

		-- Diagonal brace
		local brace = Instance.new("Part")
		brace.Name = "HelipadBrace"
		brace.Size = Vector3.new(1, 1, 14)
		brace.CFrame = CFrame.new(padCenterX + padW / 4, padY - 8, padCenterZ + sz * (padD / 2 - 3))
			* CFrame.Angles(math.rad(35), 0, 0)
		brace.Anchored = true
		brace.CanCollide = false
		brace.Material = Enum.Material.DiamondPlate
		brace.Color = Color3.fromRGB(80, 85, 90)
		brace.Parent = folder
	end

	-- Safety railing (3 sides — inner side connects to building)
	local railH = 3
	local railThick = 0.2
	local railY = padY + railH / 2 + padThick / 2
	local railColor = Color3.fromRGB(180, 185, 190)

	-- Front rail (+Z)
	local frontRail = Instance.new("Part")
	frontRail.Name = "HelipadRail"
	frontRail.Size = Vector3.new(padW, railH, railThick)
	frontRail.Position = Vector3.new(padCenterX, railY, padCenterZ + padD / 2)
	frontRail.Anchored = true
	frontRail.CanCollide = true
	frontRail.Material = Enum.Material.Metal
	frontRail.Color = railColor
	frontRail.Transparency = 0.3
	frontRail.Parent = folder

	-- Back rail (-Z)
	local backRail = Instance.new("Part")
	backRail.Name = "HelipadRail"
	backRail.Size = Vector3.new(padW, railH, railThick)
	backRail.Position = Vector3.new(padCenterX, railY, padCenterZ - padD / 2)
	backRail.Anchored = true
	backRail.CanCollide = true
	backRail.Material = Enum.Material.Metal
	backRail.Color = railColor
	backRail.Transparency = 0.3
	backRail.Parent = folder

	-- Outer rail (+X)
	local outerRail = Instance.new("Part")
	outerRail.Name = "HelipadRail"
	outerRail.Size = Vector3.new(railThick, railH, padD)
	outerRail.Position = Vector3.new(padCenterX + padW / 2, railY, padCenterZ)
	outerRail.Anchored = true
	outerRail.CanCollide = true
	outerRail.Material = Enum.Material.Metal
	outerRail.Color = railColor
	outerRail.Transparency = 0.3
	outerRail.Parent = folder

	-- "H" marking — two vertical bars + one horizontal bar (neon on the pad surface)
	local hMarkY = padY + padThick / 2 + 0.05
	local hColor = Color3.fromRGB(255, 255, 255)
	local hBarW = 1.2 -- bar width
	local hBarH = 10 -- vertical bar length (along Z)
	local hGap = 5 -- gap between vertical bars (along X)

	-- Left vertical bar of H
	local hLeft = Instance.new("Part")
	hLeft.Name = "HelipadH"
	hLeft.Size = Vector3.new(hBarW, 0.1, hBarH)
	hLeft.Position = Vector3.new(padCenterX - hGap / 2, hMarkY, padCenterZ)
	hLeft.Anchored = true
	hLeft.CanCollide = false
	hLeft.Material = Enum.Material.Neon
	hLeft.Color = hColor
	hLeft.Parent = folder

	-- Right vertical bar of H
	local hRight = Instance.new("Part")
	hRight.Name = "HelipadH"
	hRight.Size = Vector3.new(hBarW, 0.1, hBarH)
	hRight.Position = Vector3.new(padCenterX + hGap / 2, hMarkY, padCenterZ)
	hRight.Anchored = true
	hRight.CanCollide = false
	hRight.Material = Enum.Material.Neon
	hRight.Color = hColor
	hRight.Parent = folder

	-- Horizontal crossbar of H
	local hCross = Instance.new("Part")
	hCross.Name = "HelipadH"
	hCross.Size = Vector3.new(hGap + hBarW, 0.1, hBarW)
	hCross.Position = Vector3.new(padCenterX, hMarkY, padCenterZ)
	hCross.Anchored = true
	hCross.CanCollide = false
	hCross.Material = Enum.Material.Neon
	hCross.Color = hColor
	hCross.Parent = folder

	-- Circle around the H (neon ring using wedges approximated by 12 segments)
	local circleR = 8
	local segments = 24
	for i = 1, segments do
		local a1 = math.rad((i - 1) * 360 / segments)
		local a2 = math.rad(i * 360 / segments)
		local mx = padCenterX + circleR * math.cos((a1 + a2) / 2)
		local mz = padCenterZ + circleR * math.sin((a1 + a2) / 2)
		local segLen = 2 * circleR * math.sin(math.rad(360 / segments / 2))

		local seg = Instance.new("Part")
		seg.Name = "HelipadCircle"
		seg.Size = Vector3.new(segLen, 0.1, 0.6)
		seg.CFrame = CFrame.new(mx, hMarkY, mz) * CFrame.Angles(0, -(a1 + a2) / 2 + math.rad(90), 0)
		seg.Anchored = true
		seg.CanCollide = false
		seg.Material = Enum.Material.Neon
		seg.Color = hColor
		seg.Parent = folder
	end

	-- Helicopter on the pad (with server-side rotor spinning)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local vehicleTemplates = ReplicatedStorage:FindFirstChild("VehicleTemplates")
	if vehicleTemplates then
		local heliTemplate = vehicleTemplates:FindFirstChild("Helicopter_Police_1")
		if heliTemplate then
			local heli = heliTemplate:Clone()
			heli.Name = "RooftopHelicopter"
			-- Remove NPC passengers from the clone
			for _, desc in heli:GetDescendants() do
				if desc:IsA("Model") and desc:FindFirstChildOfClass("Humanoid") then
					desc:Destroy()
				end
			end

			-- Customize: civilian variant (red + blue, no police equipment)
			local HELI_RED = Color3.fromRGB(180, 30, 30)
			local HELI_BLUE = Color3.fromRGB(30, 80, 200)
			local policePartsToRemove = {}

			for _, desc in heli:GetDescendants() do
				local name = desc.Name
				-- Collect police-specific parts for removal
				if name == "LightRed" or name == "LightBlue"
					or name == "PoliceStripe"
					or name == "SearchlightHousing" or name == "BeamTip" or name == "LaserImpact" then
					table.insert(policePartsToRemove, desc)
				end
				-- Recolor body parts
				if desc:IsA("BasePart") then
					if name == "Floor" or name == "TailFin" or name == "HorizStab"
						or name == "APillar" or name == "CPillar" or name == "BPillar"
						or name == "RoofRailSide" or name == "RoofRailFront" or name == "RotorHub" then
						desc.Color = HELI_RED
					elseif name == "EngineCowl" or name == "TailBoom" then
						desc.Color = HELI_BLUE
					elseif name == "Roof" then
						-- Glass roof so player is visible from above
						desc.Material = Enum.Material.Glass
						desc.Color = Color3.fromRGB(120, 160, 200)
						desc.Transparency = 0.55
					end
				end
			end
			for _, p in policePartsToRemove do
				p:Destroy()
			end
			heli:SetAttribute("_hasPoliceLight", nil)

			-- Add invisible VehicleSeat for pilot (left seat position)
			local seat = Instance.new("VehicleSeat")
			seat.Name = "DrivingSeat"
			seat.Size = Vector3.new(2, 0.5, 2)
			seat.CFrame = CFrame.new(-1.5, -1.5, 1.5) * CFrame.Angles(0, math.rad(180), 0)
			seat.Anchored = true
			seat.CanCollide = false
			seat.Transparency = 1
			seat.MaxSpeed = 0
			seat.HeadsUpDisplay = false
			seat.Parent = heli

			heli:PivotTo(CFrame.new(padCenterX, padY + 4, padCenterZ) * CFrame.Angles(0, math.rad(45), 0))
			heli.Parent = folder

			-- Spin rotors server-side (static prop, not managed by VehicleSystem)
			local mainRotor = heli:FindFirstChild("MainRotor")
			local tailRotor = heli:FindFirstChild("TailRotor")
			RunService.Heartbeat:Connect(function(dt)
				if not heli or not heli.Parent then return end
				if mainRotor and mainRotor.PrimaryPart then
					local cf = mainRotor:GetPivot()
					mainRotor:PivotTo(cf * CFrame.Angles(0, dt * 12, 0))
				end
				if tailRotor and tailRotor.PrimaryPart then
					local cf = tailRotor:GetPivot()
					tailRotor:PivotTo(cf * CFrame.Angles(dt * 20, 0, 0))
				end
			end)

			-- Store helicopter + helipad position for WorldLoader / resetInteractables
			if lastElevatorData then
				lastElevatorData.helicopter = heli
				lastElevatorData.helipadCenterX = padCenterX
				lastElevatorData.helipadY = padY
				lastElevatorData.helipadCenterZ = padCenterZ
			end

			print("[Skyline] Placed helicopter on helipad")

			----------------------------------------------------------------
			-- ENEMY HELICOPTER (army green, missile launcher pods)
			----------------------------------------------------------------
			local enemyHeli = heliTemplate:Clone()
			enemyHeli.Name = "EnemyHelicopter"

			-- Remove NPC passengers from clone
			for _, desc in enemyHeli:GetDescendants() do
				if desc:IsA("Model") and desc:FindFirstChildOfClass("Humanoid") then
					desc:Destroy()
				end
			end

			-- Army green color scheme
			local ARMY_GREEN = Color3.fromRGB(60, 80, 45)
			local ARMY_DARK = Color3.fromRGB(40, 55, 30)
			local ARMY_ACCENT = Color3.fromRGB(50, 65, 35)
			local enemyPoliceRemove = {}

			for _, desc in enemyHeli:GetDescendants() do
				local eName = desc.Name
				-- Collect police parts for removal
				if eName == "LightRed" or eName == "LightBlue"
					or eName == "PoliceStripe"
					or eName == "SearchlightHousing" or eName == "BeamTip" or eName == "LaserImpact" then
					table.insert(enemyPoliceRemove, desc)
				end
				-- Recolor to army green
				if desc:IsA("BasePart") then
					if eName == "Floor" or eName == "TailFin" or eName == "HorizStab"
						or eName == "APillar" or eName == "CPillar" or eName == "BPillar"
						or eName == "RoofRailSide" or eName == "RoofRailFront" or eName == "RotorHub"
						or eName == "RotorMast" or eName == "SkidStrut" then
						desc.Color = ARMY_GREEN
					elseif eName == "EngineCowl" or eName == "TailBoom" then
						desc.Color = ARMY_DARK
					elseif eName == "Roof" then
						desc.Color = ARMY_DARK
						desc.Material = Enum.Material.Metal
						desc.Transparency = 0
					elseif eName == "Dashboard" or eName == "Console" then
						desc.Color = ARMY_ACCENT
					elseif eName == "Windshield" or eName == "SideGlassFront"
						or eName == "SideGlassRear" or eName == "RearGlass" then
						desc.Color = Color3.fromRGB(80, 100, 80)
						desc.Transparency = 0.45
					elseif eName == "Skid" then
						desc.Color = ARMY_ACCENT
					end
				end
			end
			for _, p in enemyPoliceRemove do
				p:Destroy()
			end
			enemyHeli:SetAttribute("_hasPoliceLight", nil)

			-- Missile launcher pods (one per side)
			local POD_COLOR = Color3.fromRGB(55, 55, 50)
			local TUBE_COLOR = Color3.fromRGB(40, 40, 38)

			for _, side in ipairs({-1, 1}) do
				local podX = side * 3.5
				local podY = -2.0
				local podZ = 1.0

				-- Pylon connecting pod to fuselage underside
				local pylon = Instance.new("Part")
				pylon.Name = "MissilePylon"
				pylon.Size = Vector3.new(1.0, 0.3, 1.5)
				pylon.CFrame = CFrame.new(side * 3.25, podY + 0.8, podZ)
				pylon.Anchored = true
				pylon.CanCollide = false
				pylon.Material = Enum.Material.Metal
				pylon.Color = ARMY_DARK
				pylon.Parent = enemyHeli

				-- Pod housing (cylinder, axis rotated to Z)
				local housing = Instance.new("Part")
				housing.Name = "MissilePodHousing"
				housing.Shape = Enum.PartType.Cylinder
				housing.Size = Vector3.new(3.5, 2.0, 2.0)
				housing.CFrame = CFrame.new(podX, podY, podZ)
					* CFrame.Angles(0, math.rad(90), 0)
				housing.Anchored = true
				housing.CanCollide = false
				housing.Material = Enum.Material.Metal
				housing.Color = POD_COLOR
				housing.Parent = enemyHeli

				-- Front cap (dark ring at muzzle end)
				local cap = Instance.new("Part")
				cap.Name = "MissilePodCap"
				cap.Shape = Enum.PartType.Cylinder
				cap.Size = Vector3.new(0.2, 2.05, 2.05)
				cap.CFrame = CFrame.new(podX, podY, podZ + 1.8)
					* CFrame.Angles(0, math.rad(90), 0)
				cap.Anchored = true
				cap.CanCollide = false
				cap.Material = Enum.Material.DiamondPlate
				cap.Color = Color3.fromRGB(35, 35, 32)
				cap.Parent = enemyHeli

				-- Tube barrels (2x2 grid, protruding from front)
				local tubeSpacing = 0.55
				for tx = -1, 1, 2 do
					for ty = -1, 1, 2 do
						local tube = Instance.new("Part")
						tube.Name = "MissileTube"
						tube.Shape = Enum.PartType.Cylinder
						tube.Size = Vector3.new(4.0, 0.45, 0.45)
						tube.CFrame = CFrame.new(
							podX + tx * tubeSpacing / 2,
							podY + ty * tubeSpacing / 2,
							podZ + 0.3
						) * CFrame.Angles(0, math.rad(90), 0)
						tube.Anchored = true
						tube.CanCollide = false
						tube.Material = Enum.Material.DiamondPlate
						tube.Color = TUBE_COLOR
						tube.Parent = enemyHeli
					end
				end
			end

			-- Hide enemy heli off-screen until WorldLoader spawns it during flight
			enemyHeli:PivotTo(CFrame.new(0, -500, 0))
			enemyHeli.Parent = folder

			-- Spin enemy rotors server-side
			local enemyMainRotor = enemyHeli:FindFirstChild("MainRotor")
			local enemyTailRotor = enemyHeli:FindFirstChild("TailRotor")
			RunService.Heartbeat:Connect(function(dt)
				if not enemyHeli or not enemyHeli.Parent then return end
				if enemyMainRotor and enemyMainRotor.PrimaryPart then
					local ecf = enemyMainRotor:GetPivot()
					enemyMainRotor:PivotTo(ecf * CFrame.Angles(0, dt * 12, 0))
				end
				if enemyTailRotor and enemyTailRotor.PrimaryPart then
					local ecf = enemyTailRotor:GetPivot()
					enemyTailRotor:PivotTo(ecf * CFrame.Angles(dt * 20, 0, 0))
				end
			end)

			-- Spawn 2 seated civilian NPCs in enemy helicopter
			local NPCMgr = DecorUtils.NPCManager
			if NPCMgr then
				local enemyPivot = enemyHeli:GetPivot()
				for _, seatXPos in ipairs({-1.5, 1.5}) do
					task.spawn(function()
						local worldSeatCF = enemyPivot
							* CFrame.new(seatXPos, 0, 1.5)
							* CFrame.Angles(0, math.rad(180), 0)
						NPCMgr.spawnSeatedInVehicle(
							NPCMgr.randomCivilian(), enemyHeli, worldSeatCF
						)
					end)
				end
			end

			-- Store enemy helicopter for WorldLoader
			if lastElevatorData then
				lastElevatorData.enemyHelicopter = enemyHeli
			end

			print("[Skyline] Enemy helicopter ready (hidden until flight)")
		end
	end

	----------------------------------------------------------------------------
	-- ROOFTOP CHEVRONS pointing from elevator toward helipad (→ +X direction)
	----------------------------------------------------------------------------
	local roofChevronCount = 3
	local roofChevronColor = Color3.fromRGB(0, 180, 255)
	local roofChevronY = roofTopY + padThick / 2 + 0.05
	local chevStartX = shaftX + shaftW / 2 + 2 -- start just past the elevator shaft
	local chevEndX = buildingRightX -- end at the building edge
	local roofChevrons = {}

	for i = 1, roofChevronCount do
		local t = i / (roofChevronCount + 1)
		local cX = chevStartX + t * (chevEndX - chevStartX)

		-- Same V as entrance chevrons, rotated 90° to point right (+X)
		for _, side in ipairs({ -1, 1 }) do
			local arm = Instance.new("Part")
			arm.Name = "RoofChevron_" .. i
			arm.Size = Vector3.new(chevronArmLen, 0.4, 0.4)
			arm.CFrame = CFrame.new(cX, roofChevronY, buildingCZ + side * 1.5)
				* CFrame.Angles(0, -side * chevronAngle + math.rad(90), 0)
			arm.Anchored = true
			arm.CanCollide = false
			arm.Material = Enum.Material.Neon
			arm.Color = roofChevronColor
			arm.Transparency = 0.15
			arm.Parent = folder
			table.insert(roofChevrons, arm)
		end
	end

	-- Store roof chevrons in elevator data for animation
	if lastElevatorData then
		lastElevatorData.roofChevrons = roofChevrons
	end

	-- Row 1: concrete detailed row (staggered X by half spacing)
	local row1Z = baseZ - ROW_SPACING
	local halfShift = BUILDING_SPACING / 2
	local prev = nil
	for i = -2, 2 do
		local px = i * BUILDING_SPACING + halfShift
		local style = pickStyle(prev)
		spawnBuilding(x + px, row1Z, scale, style)
		prev = style
		-- ~30% chance of antenna on detailed buildings
		if math.random() < 0.30 then
			local sData = STYLES[style]
			local bRoofY = BUILDING_BASE + (LOBBY_H + (sData.floors or DEFAULT_FLOORS) * FLOOR_H) * scale + 0.5
			addRooftopAntenna(folder, x + px, row1Z - 10, bRoofY, FACADE_W * scale, DEPTH * scale)
		end
	end

	-- Rows 2-3: detailed concrete buildings (visible from rooftop before flight)
	for row = 2, 3 do
		local rowZ = baseZ - row * ROW_SPACING
		local xShift = (row % 2 == 0) and 0 or halfShift
		local prevStyle = nil
		for i = -3, 3 do
			local px = i * BUILDING_SPACING + xShift
			local jitter = (math.random() - 0.5) * 4
			local style = pickStyle(prevStyle)
			spawnBuilding(x + px + jitter, rowZ, scale, style)
			prevStyle = style
			if math.random() < 0.35 then
				local sData = STYLES[style]
				local bRoofY = BUILDING_BASE + (LOBBY_H + (sData.floors or DEFAULT_FLOORS) * FLOOR_H) * scale + 0.5
				addRooftopAntenna(folder, x + px + jitter, rowZ - 10, bRoofY, FACADE_W * scale, DEPTH * scale)
			end
		end
	end

	-- Rows 4+: simple blocks (only rooftops visible from helicopter altitude)
	for row = 4, GRID_ROWS - 1 do
		local rowZ = baseZ - row * ROW_SPACING
		local xShift = (row % 2 == 0) and 0 or halfShift
		local prevBlock = nil
		for i = -3, 3 do
			local px = i * BUILDING_SPACING + xShift
			local jitter = (math.random() - 0.5) * 4
			local idx = pickBlock(prevBlock)
			spawnBlock(x + px + jitter, rowZ, idx)
			prevBlock = idx
			if math.random() < 0.35 then
				local preset = BLOCK_PRESETS[idx]
				local bRoofY = BUILDING_BASE + LOBBY_H + preset.floors * FLOOR_H + 0.5
				addRooftopAntenna(folder, x + px + jitter, rowZ - 10, bRoofY, FACADE_W, DEPTH)
			end
		end
	end

	-- Start antenna beacon pulse animation
	startAntennaPulse()

	----------------------------------------------------------------------------
	-- LANDING HELIPAD at the far end of the grid
	----------------------------------------------------------------------------
	local lastRowZ = baseZ - (GRID_ROWS - 1) * ROW_SPACING
	local landPadW = 26
	local landPadD = 22
	local landPadThick = 0.5
	local landPadX = x -- centered on lane
	local landPadZ = lastRowZ - ROW_SPACING -- one row past the last buildings
	local landPadY = roofTopY -- same height as takeoff helipad

	-- Main platform
	local landFloor = Instance.new("Part")
	landFloor.Name = "LandingPadFloor"
	landFloor.Size = Vector3.new(landPadW, landPadThick, landPadD)
	landFloor.Position = Vector3.new(landPadX, landPadY, landPadZ)
	landFloor.Anchored = true
	landFloor.CanCollide = true
	landFloor.Material = Enum.Material.DiamondPlate
	landFloor.Color = Color3.fromRGB(130, 135, 140)
	landFloor.Parent = folder

	-- Safety railings (all 4 sides)
	local lrailH = 3
	local lrailThick = 0.2
	local lrailY = landPadY + lrailH / 2 + landPadThick / 2
	local lrailColor = Color3.fromRGB(180, 185, 190)

	for _, data in ipairs({
		{ Vector3.new(landPadW, lrailH, lrailThick), Vector3.new(landPadX, lrailY, landPadZ + landPadD / 2) },
		{ Vector3.new(landPadW, lrailH, lrailThick), Vector3.new(landPadX, lrailY, landPadZ - landPadD / 2) },
		{ Vector3.new(lrailThick, lrailH, landPadD), Vector3.new(landPadX + landPadW / 2, lrailY, landPadZ) },
		{ Vector3.new(lrailThick, lrailH, landPadD), Vector3.new(landPadX - landPadW / 2, lrailY, landPadZ) },
	}) do
		local rail = Instance.new("Part")
		rail.Name = "LandingPadRail"
		rail.Size = data[1]
		rail.Position = data[2]
		rail.Anchored = true
		rail.CanCollide = true
		rail.Material = Enum.Material.Metal
		rail.Color = lrailColor
		rail.Transparency = 0.3
		rail.Parent = folder
	end

	-- "H" marking (neon)
	local lhMarkY = landPadY + landPadThick / 2 + 0.05
	local lhColor = Color3.fromRGB(255, 255, 255)
	local lhBarW = 1.2
	local lhBarH = 10
	local lhGap = 5

	for _, hData in ipairs({
		{ Vector3.new(lhBarW, 0.1, lhBarH), Vector3.new(landPadX - lhGap / 2, lhMarkY, landPadZ) },
		{ Vector3.new(lhBarW, 0.1, lhBarH), Vector3.new(landPadX + lhGap / 2, lhMarkY, landPadZ) },
		{ Vector3.new(lhGap + lhBarW, 0.1, lhBarW), Vector3.new(landPadX, lhMarkY, landPadZ) },
	}) do
		local h = Instance.new("Part")
		h.Name = "LandingPadH"
		h.Size = hData[1]
		h.Position = hData[2]
		h.Anchored = true
		h.CanCollide = false
		h.Material = Enum.Material.Neon
		h.Color = lhColor
		h.Parent = folder
	end

	-- Neon circle around H
	local lcircleR = 8
	local lsegments = 24
	for i = 1, lsegments do
		local a1 = math.rad((i - 1) * 360 / lsegments)
		local a2 = math.rad(i * 360 / lsegments)
		local mx = landPadX + lcircleR * math.cos((a1 + a2) / 2)
		local mz = landPadZ + lcircleR * math.sin((a1 + a2) / 2)
		local segLen = 2 * lcircleR * math.sin(math.rad(360 / lsegments / 2))

		local seg = Instance.new("Part")
		seg.Name = "LandingPadCircle"
		seg.Size = Vector3.new(segLen, 0.1, 0.6)
		seg.CFrame = CFrame.new(mx, lhMarkY, mz) * CFrame.Angles(0, -(a1 + a2) / 2 + math.rad(90), 0)
		seg.Anchored = true
		seg.CanCollide = false
		seg.Material = Enum.Material.Neon
		seg.Color = lhColor
		seg.Parent = folder
	end

	-- Store landing pad data for WorldLoader
	if lastElevatorData then
		lastElevatorData.landingPadX = landPadX
		lastElevatorData.landingPadZ = landPadZ
		lastElevatorData.landingPadY = landPadY
	end

	print("[Skyline] Landing helipad placed at Z=" .. landPadZ)
end

--------------------------------------------------------------------------------
-- PRELOAD: build all templates at game start
--------------------------------------------------------------------------------

function SkylineApproach.preloadTemplates()
	-- Detailed building templates
	for styleKey, _ in pairs(STYLES) do
		local t = buildTemplate(styleKey)
		if t then
			templateCache[styleKey] = t
			print("[Skyline] Preloaded template: " .. styleKey)
		end
	end
	-- Simple block templates
	for i = 1, #BLOCK_PRESETS do
		local t = buildBlockTemplate(i)
		if t then
			blockTemplateCache[i] = t
			print("[Skyline] Preloaded block: " .. i)
		end
	end
end

--------------------------------------------------------------------------------
-- EXPORTED BUILDERS
--------------------------------------------------------------------------------

-- Single building builders (kept for flexibility)
function SkylineApproach.createGlassBlue(x, z, scale) return spawnBuilding(x, z, scale, "glass_blue") end
function SkylineApproach.createSkylineWall(x, z, scale) return spawnBuilding(x, z, scale, "glass_blue") end

-- Elevator data getter (called by WorldLoader after city grid is placed)
function SkylineApproach.getElevatorData()
	return lastElevatorData
end

-- Reset interactive parts (elevator + helicopters) for retry after death.
-- Destroys old helis, clones fresh ones, resets elevator to ground.
function SkylineApproach.resetInteractables()
	local d = lastElevatorData
	if not d then return end
	local folder = DecorUtils.decorFolder

	-- 1. Reset elevator platform to start
	if d.platform and d.platform.Parent then
		d.platform.Position = Vector3.new(d.shaftX, d.startY, d.shaftZ)
	end

	-- 2. Reset cabin parts to initial Y
	for _, cp in d.cabinParts or {} do
		if cp and cp.Parent then
			local initY = cp:GetAttribute("initY")
			if initY then
				cp.Position = Vector3.new(cp.Position.X, initY, cp.Position.Z)
			end
		end
	end

	-- 3. Reset chevron transparency
	for _, chev in d.chevrons or {} do
		if chev and chev.Parent then chev.Transparency = 0.15 end
	end
	for _, chev in d.roofChevrons or {} do
		if chev and chev.Parent then chev.Transparency = 0.15 end
	end

	-- 4. Destroy old helicopters
	if d.helicopter and d.helicopter.Parent then d.helicopter:Destroy() end
	if d.enemyHelicopter and d.enemyHelicopter.Parent then d.enemyHelicopter:Destroy() end
	d.helicopter = nil
	d.enemyHelicopter = nil

	-- 5. Clone fresh helicopters from template
	local vehicleTemplates = game:GetService("ReplicatedStorage"):FindFirstChild("VehicleTemplates")
	if not vehicleTemplates then return end
	local heliTemplate = vehicleTemplates:FindFirstChild("Helicopter_Police_1")
	if not heliTemplate then return end

	-- Helipad position (stored during createCityGrid)
	local padCenterX = d.helipadCenterX
	local padY = d.helipadY
	local padCenterZ = d.helipadCenterZ
	if not padCenterX then return end

	-- Player helicopter (red/blue civilian)
	local heli = heliTemplate:Clone()
	heli.Name = "RooftopHelicopter"
	for _, desc in heli:GetDescendants() do
		if desc:IsA("Model") and desc:FindFirstChildOfClass("Humanoid") then desc:Destroy() end
	end
	local HELI_RED = Color3.fromRGB(180, 30, 30)
	local HELI_BLUE = Color3.fromRGB(30, 80, 200)
	local policeRemove = {}
	for _, desc in heli:GetDescendants() do
		local n = desc.Name
		if n == "LightRed" or n == "LightBlue" or n == "PoliceStripe"
			or n == "SearchlightHousing" or n == "BeamTip" or n == "LaserImpact" then
			table.insert(policeRemove, desc)
		end
		if desc:IsA("BasePart") then
			if n == "Floor" or n == "TailFin" or n == "HorizStab"
				or n == "APillar" or n == "CPillar" or n == "BPillar"
				or n == "RoofRailSide" or n == "RoofRailFront" or n == "RotorHub" then
				desc.Color = HELI_RED
			elseif n == "EngineCowl" or n == "TailBoom" then
				desc.Color = HELI_BLUE
			elseif n == "Roof" then
				desc.Material = Enum.Material.Glass
				desc.Color = Color3.fromRGB(120, 160, 200)
				desc.Transparency = 0.55
			end
		end
	end
	for _, p in policeRemove do p:Destroy() end
	heli:SetAttribute("_hasPoliceLight", nil)

	local seat = Instance.new("VehicleSeat")
	seat.Name = "DrivingSeat"
	seat.Size = Vector3.new(2, 0.5, 2)
	seat.CFrame = CFrame.new(-1.5, -1.5, 1.5) * CFrame.Angles(0, math.rad(180), 0)
	seat.Anchored = true
	seat.CanCollide = false
	seat.Transparency = 1
	seat.MaxSpeed = 0
	seat.HeadsUpDisplay = false
	seat.Parent = heli

	heli:PivotTo(CFrame.new(padCenterX, padY + 4, padCenterZ) * CFrame.Angles(0, math.rad(45), 0))
	heli.Parent = folder

	-- Spin rotors
	local mainRotor = heli:FindFirstChild("MainRotor")
	local tailRotor = heli:FindFirstChild("TailRotor")
	RunService.Heartbeat:Connect(function(dt)
		if not heli or not heli.Parent then return end
		if mainRotor and mainRotor.PrimaryPart then
			mainRotor:PivotTo(mainRotor:GetPivot() * CFrame.Angles(0, dt * 12, 0))
		end
		if tailRotor and tailRotor.PrimaryPart then
			tailRotor:PivotTo(tailRotor:GetPivot() * CFrame.Angles(dt * 20, 0, 0))
		end
	end)

	d.helicopter = heli

	-- Enemy helicopter (army green)
	local enemyHeli = heliTemplate:Clone()
	enemyHeli.Name = "EnemyHelicopter"
	for _, desc in enemyHeli:GetDescendants() do
		if desc:IsA("Model") and desc:FindFirstChildOfClass("Humanoid") then desc:Destroy() end
	end
	local ARMY_GREEN = Color3.fromRGB(60, 80, 45)
	local ARMY_DARK = Color3.fromRGB(40, 55, 30)
	local ARMY_ACCENT = Color3.fromRGB(50, 65, 35)
	local enemyRemove = {}
	for _, desc in enemyHeli:GetDescendants() do
		local n = desc.Name
		if n == "LightRed" or n == "LightBlue" or n == "PoliceStripe"
			or n == "SearchlightHousing" or n == "BeamTip" or n == "LaserImpact" then
			table.insert(enemyRemove, desc)
		end
		if desc:IsA("BasePart") then
			if n == "Floor" or n == "TailFin" or n == "HorizStab"
				or n == "APillar" or n == "CPillar" or n == "BPillar"
				or n == "RoofRailSide" or n == "RoofRailFront" or n == "RotorHub"
				or n == "RotorMast" or n == "SkidStrut" then
				desc.Color = ARMY_GREEN
			elseif n == "EngineCowl" or n == "TailBoom" then
				desc.Color = ARMY_DARK
			elseif n == "Roof" then
				desc.Color = ARMY_DARK
				desc.Material = Enum.Material.Metal
				desc.Transparency = 0
			elseif n == "Dashboard" or n == "Console" then
				desc.Color = ARMY_ACCENT
			elseif n == "Windshield" or n == "SideGlassFront"
				or n == "SideGlassRear" or n == "RearGlass" then
				desc.Color = Color3.fromRGB(80, 100, 80)
				desc.Transparency = 0.45
			elseif n == "Skid" then
				desc.Color = ARMY_ACCENT
			end
		end
	end
	for _, p in enemyRemove do p:Destroy() end
	enemyHeli:SetAttribute("_hasPoliceLight", nil)

	-- Missile pods (same as original)
	local POD_COLOR = Color3.fromRGB(55, 55, 50)
	local TUBE_COLOR = Color3.fromRGB(40, 40, 38)
	for _, side in ipairs({-1, 1}) do
		local podX = side * 3.5
		local podY = -2.0
		local podZ = 1.0
		local pylon = Instance.new("Part")
		pylon.Name = "MissilePylon"
		pylon.Size = Vector3.new(1.0, 0.3, 1.5)
		pylon.CFrame = CFrame.new(side * 3.25, podY + 0.8, podZ)
		pylon.Anchored = true
		pylon.CanCollide = false
		pylon.Material = Enum.Material.Metal
		pylon.Color = ARMY_DARK
		pylon.Parent = enemyHeli

		local housing = Instance.new("Part")
		housing.Name = "MissilePodHousing"
		housing.Shape = Enum.PartType.Cylinder
		housing.Size = Vector3.new(3.5, 2.0, 2.0)
		housing.CFrame = CFrame.new(podX, podY, podZ) * CFrame.Angles(0, math.rad(90), 0)
		housing.Anchored = true
		housing.CanCollide = false
		housing.Material = Enum.Material.Metal
		housing.Color = POD_COLOR
		housing.Parent = enemyHeli

		local cap = Instance.new("Part")
		cap.Name = "MissilePodCap"
		cap.Shape = Enum.PartType.Cylinder
		cap.Size = Vector3.new(0.2, 2.05, 2.05)
		cap.CFrame = CFrame.new(podX, podY, podZ + 1.8) * CFrame.Angles(0, math.rad(90), 0)
		cap.Anchored = true
		cap.CanCollide = false
		cap.Material = Enum.Material.DiamondPlate
		cap.Color = Color3.fromRGB(35, 35, 32)
		cap.Parent = enemyHeli

		for tx = -1, 1, 2 do
			for ty = -1, 1, 2 do
				local tube = Instance.new("Part")
				tube.Name = "MissileTube"
				tube.Shape = Enum.PartType.Cylinder
				tube.Size = Vector3.new(4.0, 0.45, 0.45)
				tube.CFrame = CFrame.new(podX + tx * 0.275, podY + ty * 0.275, podZ + 0.3) * CFrame.Angles(0, math.rad(90), 0)
				tube.Anchored = true
				tube.CanCollide = false
				tube.Material = Enum.Material.DiamondPlate
				tube.Color = TUBE_COLOR
				tube.Parent = enemyHeli
			end
		end
	end

	enemyHeli:PivotTo(CFrame.new(0, -500, 0))
	enemyHeli.Parent = folder

	-- Spin enemy rotors
	local eMainRotor = enemyHeli:FindFirstChild("MainRotor")
	local eTailRotor = enemyHeli:FindFirstChild("TailRotor")
	RunService.Heartbeat:Connect(function(dt)
		if not enemyHeli or not enemyHeli.Parent then return end
		if eMainRotor and eMainRotor.PrimaryPart then
			eMainRotor:PivotTo(eMainRotor:GetPivot() * CFrame.Angles(0, dt * 12, 0))
		end
		if eTailRotor and eTailRotor.PrimaryPart then
			eTailRotor:PivotTo(eTailRotor:GetPivot() * CFrame.Angles(dt * 20, 0, 0))
		end
	end)

	d.enemyHelicopter = enemyHeli

	print("[Skyline] Interactables reset — fresh helicopters + elevator at ground")
end

return SkylineApproach
