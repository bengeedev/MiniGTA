-- MilitaryWarning decor builder
-- Area 51 high-security perimeter: chain-link fence with razor wire,
-- concrete base, steel posts, hazard markings + LCD warning panels.
-- Invisible TrussParts provide climbing mechanic.

local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local MilitaryWarning = {}

local TERRAIN_TOP = DecorUtils.TERRAIN_TOP

-- Area 51 palette
local STEEL_GRAY   = Color3.fromRGB(140, 145, 150)  -- clean chain-link
local POST_DARK    = Color3.fromRGB(60, 62, 65)      -- dark steel posts
local CONCRETE     = Color3.fromRGB(160, 155, 148)    -- base slab
local RAZOR_SILVER = Color3.fromRGB(170, 175, 180)    -- razor wire
local HAZARD_YELLOW = Color3.fromRGB(220, 180, 30)    -- warning stripes
local HAZARD_BLACK  = Color3.fromRGB(25, 25, 25)
local RED_NEON     = Color3.fromRGB(255, 40, 20)
local DARK_METAL   = Color3.fromRGB(50, 50, 55)

--------------------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------------------

local function makePart(parent, name, size, cf, color, material)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = false
	p.Parent = parent
	return p
end

local function makeCylinder(parent, name, size, cf, color, material)
	local p = makePart(parent, name, size, cf, color, material)
	p.Shape = Enum.PartType.Cylinder
	return p
end

local function makeBall(parent, name, size, cf, color, material)
	local p = makePart(parent, name, size, cf, color, material)
	p.Shape = Enum.PartType.Ball
	return p
end

--------------------------------------------------------------------------------
-- AREA 51 CHAIN-LINK FENCE
-- Invisible TrussParts (climbing) + visual chain-link + razor wire coils
--------------------------------------------------------------------------------

local function buildFence(parent, cx, cz, width, height, registerAnimation)
	local baseY = TERRAIN_TOP

	-- CLIMBING LAYER: invisible TrussParts
	local trussSize = 2
	local numTrussX = math.ceil(width / trussSize)
	local numTrussY = math.ceil(height / trussSize)
	local startTX = cx - (numTrussX * trussSize) / 2

	for ix = 0, numTrussX - 1 do
		local px = startTX + ix * trussSize + trussSize / 2
		for iy = 0, numTrussY - 1 do
			local py = baseY + iy * trussSize + trussSize / 2
			local truss = Instance.new("TrussPart")
			truss.Name = "FenceTruss"
			truss.Size = Vector3.new(trussSize, trussSize, trussSize)
			truss.CFrame = CFrame.new(px, py, cz)
			truss.Transparency = 1
			truss.Anchored = true
			truss.Parent = parent
		end
	end

	-- VISUAL LAYER
	local postSpacing = 10
	local numPosts = math.floor(width / postSpacing) + 1
	local startX = cx - width / 2
	local hazardLights = {}

	-- Concrete foundation slab
	makePart(parent, "ConcreteBase",
		Vector3.new(width, 1.2, 3),
		CFrame.new(cx, baseY + 0.6, cz),
		CONCRETE, Enum.Material.Concrete)

	-- Steel posts (round tubes)
	for i = 0, numPosts - 1 do
		local px = startX + i * postSpacing
		-- Main post (cylinder rotated to stand vertical)
		makeCylinder(parent, "SteelPost",
			Vector3.new(height + 2, 0.8, 0.8),
			CFrame.new(px, baseY + (height + 2) / 2, cz)
				* CFrame.Angles(0, 0, math.rad(90)),
			POST_DARK, Enum.Material.Metal)

		-- Post cap (small ball on top)
		makeBall(parent, "PostCap",
			Vector3.new(1.0, 1.0, 1.0),
			CFrame.new(px, baseY + height + 2, cz),
			POST_DARK, Enum.Material.Metal)

		-- Pulsing hazard light (yellow Neon cube)
		local hazard = makePart(parent, "HazardLight",
			Vector3.new(0.9, 0.9, 0.9),
			CFrame.new(px, baseY + 5, cz),
			HAZARD_YELLOW, Enum.Material.Neon)
		local glow = Instance.new("PointLight")
		glow.Color = HAZARD_YELLOW
		glow.Brightness = 1.5
		glow.Range = 8
		glow.Parent = hazard
		table.insert(hazardLights, hazard)

		-- Black stripe accent below
		makePart(parent, "HazardStripe",
			Vector3.new(0.92, 0.3, 0.92),
			CFrame.new(px, baseY + 5.6, cz),
			HAZARD_BLACK, Enum.Material.SmoothPlastic)
	end

	-- Register hazard pulse animation
	if registerAnimation and #hazardLights > 0 then
		registerAnimation(hazardLights[1], {
			type = "hazard_pulse",
			lights = hazardLights,
		})
	end

	-- Horizontal tension wires (3 lines across)
	for _, yFrac in ipairs({0.25, 0.5, 0.75}) do
		makePart(parent, "TensionWire",
			Vector3.new(width, 0.12, 0.12),
			CFrame.new(cx, baseY + height * yFrac + 1, cz),
			STEEL_GRAY, Enum.Material.Metal)
	end

	-- Top rail (thick horizontal bar)
	makePart(parent, "TopRail",
		Vector3.new(width, 0.6, 0.6),
		CFrame.new(cx, baseY + height + 0.5, cz),
		POST_DARK, Enum.Material.Metal)

	-- Bottom rail
	makePart(parent, "BottomRail",
		Vector3.new(width, 0.4, 0.4),
		CFrame.new(cx, baseY + 1.4, cz),
		POST_DARK, Enum.Material.Metal)

	-- Chain-link mesh panels (DiamondPlate, semi-transparent)
	local meshH = height - 1
	for i = 0, numPosts - 2 do
		local px = startX + i * postSpacing + postSpacing / 2
		local panel = makePart(parent, "ChainLink",
			Vector3.new(postSpacing - 1, meshH, 0.15),
			CFrame.new(px, baseY + 1.5 + meshH / 2, cz),
			STEEL_GRAY, Enum.Material.DiamondPlate)
		panel.Transparency = 0.4
	end

	-- RAZOR WIRE COILS on top (cylinder coils along the length)
	local wireY = baseY + height + 1.5
	local coilSpacing = 3
	local numCoils = math.floor(width / coilSpacing)
	for i = 0, numCoils do
		local coilX = cx - width / 2 + i * coilSpacing
		-- Main coil ring (cylinder tilted)
		makeCylinder(parent, "RazorCoil",
			Vector3.new(0.3, 1.8, 1.8),
			CFrame.new(coilX, wireY, cz)
				* CFrame.Angles(0, math.rad(i * 15), math.rad(90)),
			RAZOR_SILVER, Enum.Material.Metal)
	end

	-- Two long razor wire strands threading through coils
	makePart(parent, "RazorStrand",
		Vector3.new(width, 0.1, 0.1),
		CFrame.new(cx, wireY + 0.5, cz),
		RAZOR_SILVER, Enum.Material.Metal)
	makePart(parent, "RazorStrand2",
		Vector3.new(width, 0.1, 0.1),
		CFrame.new(cx, wireY - 0.5, cz),
		RAZOR_SILVER, Enum.Material.Metal)

	-- Angled support arms holding razor wire outward (every 3rd post)
	for i = 0, numPosts - 1, 3 do
		local px = startX + i * postSpacing
		local armY = baseY + height + 1
		-- Angled arm toward player side
		makePart(parent, "WireArm",
			Vector3.new(0.3, 0.3, 3),
			CFrame.new(px, armY + 0.8, cz - 1)
				* CFrame.Angles(math.rad(-30), 0, 0),
			POST_DARK, Enum.Material.Metal)
		-- Angled arm toward compound side
		makePart(parent, "WireArm",
			Vector3.new(0.3, 0.3, 3),
			CFrame.new(px, armY + 0.8, cz + 1)
				* CFrame.Angles(math.rad(30), 0, 0),
			POST_DARK, Enum.Material.Metal)
	end
end

--------------------------------------------------------------------------------
-- LCD WARNING PANEL (pulsing red diodes + cycling military messages)
--------------------------------------------------------------------------------

local function buildLCDWarningPanel(parent, cx, cz, registerAnimation)
	local baseY = TERRAIN_TOP
	local screenW = 10
	local screenH = 5
	local poleH = 10

	-- Two support posts
	for _, dx in ipairs({-1, 1}) do
		makePart(parent, "WarningPost",
			Vector3.new(0.8, poleH, 0.8),
			CFrame.new(cx + dx * (screenW / 2 + 0.5), baseY + poleH / 2, cz),
			DARK_METAL, Enum.Material.Metal)
	end

	-- Dark LED screen
	local screen = makePart(parent, "WarningScreen",
		Vector3.new(screenW, screenH, 0.5),
		CFrame.new(cx, baseY + poleH + screenH / 2 - 1, cz),
		Color3.fromRGB(8, 8, 12), Enum.Material.SmoothPlastic)

	-- Neon accent frame
	makePart(parent, "WarningFrame",
		Vector3.new(screenW + 0.8, screenH + 0.8, 0.2),
		CFrame.new(cx, baseY + poleH + screenH / 2 - 1, cz - 0.3),
		RED_NEON, Enum.Material.Neon).Transparency = 0.3

	local diodes = {}
	local warningLabels = {}
	local subLabels = {}

	for _, face in ipairs({Enum.NormalId.Front, Enum.NormalId.Back}) do
		local gui = Instance.new("SurfaceGui")
		gui.Name = "WarningGUI"
		gui.Face = face
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud = 50
		gui.LightInfluence = 0
		gui.Brightness = 2
		gui.Parent = screen

		for i = 0, 9 do
			local band = Instance.new("Frame")
			band.Name = "ChevronBand"
			band.Size = UDim2.new(1, 0, 0.1, 0)
			band.Position = UDim2.new(0, 0, i * 0.1, 0)
			band.BackgroundColor3 = (i % 2 == 0) and Color3.fromRGB(180, 20, 10) or Color3.fromRGB(15, 15, 20)
			band.BorderSizePixel = 0
			band.Parent = gui
		end

		local mainLabel = Instance.new("TextLabel")
		mainLabel.Name = "WarningMain"
		mainLabel.Size = UDim2.new(0.9, 0, 0.35, 0)
		mainLabel.Position = UDim2.new(0.05, 0, 0.08, 0)
		mainLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
		mainLabel.BackgroundTransparency = 0.2
		mainLabel.Text = "RESTRICTED AREA"
		mainLabel.TextColor3 = Color3.fromRGB(255, 60, 30)
		mainLabel.TextScaled = true
		mainLabel.Font = Enum.Font.RobotoMono
		mainLabel.ZIndex = 2
		mainLabel.Parent = gui
		table.insert(warningLabels, mainLabel)

		local subLabel = Instance.new("TextLabel")
		subLabel.Name = "WarningSub"
		subLabel.Size = UDim2.new(0.9, 0, 0.25, 0)
		subLabel.Position = UDim2.new(0.05, 0, 0.55, 0)
		subLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
		subLabel.BackgroundTransparency = 0.2
		subLabel.Text = "AUTHORIZED ONLY"
		subLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		subLabel.TextScaled = true
		subLabel.Font = Enum.Font.RobotoMono
		subLabel.ZIndex = 2
		subLabel.Parent = gui
		table.insert(subLabels, subLabel)
	end

	for _, dx in ipairs({-1, 1}) do
		local diode = makeBall(parent, "WarningDiode",
			Vector3.new(1.2, 1.2, 1.2),
			CFrame.new(cx + dx * (screenW / 2 + 0.5), baseY + poleH + 0.8, cz),
			RED_NEON, Enum.Material.Neon)

		local glow = Instance.new("PointLight")
		glow.Color = Color3.fromRGB(255, 50, 20)
		glow.Brightness = 1.5
		glow.Range = 10
		glow.Parent = diode

		table.insert(diodes, diode)
	end

	if registerAnimation and #diodes > 0 then
		registerAnimation(screen, {
			type = "launch_warning",
			diodes = diodes,
			warningLabels = warningLabels,
			subLabels = subLabels,
			lastTick = 0,
			phase = 0,
			messages = {
				{ main = "RESTRICTED AREA", sub = "AUTHORIZED ONLY", mainColor = Color3.fromRGB(255, 40, 20), subColor = Color3.fromRGB(200, 200, 200) },
				{ main = "AREA 51", sub = "NO TRESPASSING", mainColor = Color3.fromRGB(255, 200, 0), subColor = Color3.fromRGB(255, 80, 40) },
				{ main = "KEEP OUT", sub = "MILITARY ZONE", mainColor = Color3.fromRGB(255, 60, 30), subColor = Color3.fromRGB(0, 200, 255) },
				{ main = "DANGER", sub = "USE OF DEADLY FORCE", mainColor = Color3.fromRGB(255, 40, 20), subColor = Color3.fromRGB(255, 60, 30) },
				{ main = "CLASSIFIED", sub = "TOP SECRET FACILITY", mainColor = Color3.fromRGB(0, 200, 255), subColor = Color3.fromRGB(255, 200, 0) },
				{ main = "WARNING", sub = "SURVEILLANCE ACTIVE", mainColor = Color3.fromRGB(255, 200, 0), subColor = Color3.fromRGB(0, 255, 120) },
			},
		})
	end
end

--------------------------------------------------------------------------------
-- MAIN BUILDER
--------------------------------------------------------------------------------

function MilitaryWarning.createMilitaryWarning(x, z, scale)
	local folder = DecorUtils.decorFolder
	if not folder then return nil end

	local model = Instance.new("Model")
	model.Name = "MilitaryWarning"

	local registerAnimation = function(part, data)
		if DecorUtils.activePlatformAnimations then
			DecorUtils.activePlatformAnimations[part] = data
		end
	end

	local width = 500  -- full lane width so player CANNOT go around
	local fenceH = 18

	-- Area 51 perimeter fence (climbable)
	buildFence(model, x, z, width, fenceH, registerAnimation)

	-- LCD warning panels in front of the fence
	buildLCDWarningPanel(model, x - 20, z - 8, registerAnimation)
	buildLCDWarningPanel(model, x,      z - 8, registerAnimation)
	buildLCDWarningPanel(model, x + 20, z - 8, registerAnimation)

	model.Parent = folder
	return model
end

return MilitaryWarning
