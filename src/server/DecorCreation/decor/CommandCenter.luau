-- CommandCenter: glass cube mission control (Houston-style) for space_launch lane
-- Based on GlassCubeStore structure with dark-tinted glass and giant telemetry screens
local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local CommandCenter = {}

function CommandCenter.createCommandCenter(x, z, scale)
	local decorFolder = DecorUtils.decorFolder
	if not decorFolder then return nil end
	scale = scale or 1

	local BUILDING_BASE = DecorUtils.BUILDING_BASE
	local getFrontX = DecorUtils.getFrontX

	local model = Instance.new("Model")
	model.Name = "CommandCenter"

	local sign_dir = x > 0 and 1 or -1

	-- Cube dimensions (slightly wider than GlassCubeStore)
	local cubeW = 40 * scale -- width (along Z)
	local cubeH = 24 * scale -- height (lower, more bunker-like)
	local cubeD = 36 * scale -- depth (along X)
	local slabW = 44 * scale
	local slabD = 40 * scale

	local frontX = getFrontX(x, cubeD)
	local centerX = frontX + sign_dir * (cubeD / 2)
	local centerZ = z
	local baseY = BUILDING_BASE

	----------------------------------------------------------------------------
	-- BASE SLAB (dark concrete)
	----------------------------------------------------------------------------
	local slab = Instance.new("Part")
	slab.Name = "BaseSlab"
	slab.Size = Vector3.new(slabD, 0.5 * scale, slabW)
	slab.Position = Vector3.new(centerX, baseY + 0.25 * scale, centerZ)
	slab.Anchored = true
	slab.Material = Enum.Material.Concrete
	slab.Color = Color3.fromRGB(60, 60, 65)
	slab.Parent = model

	local floorY = baseY + 0.5 * scale

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

	----------------------------------------------------------------------------
	-- STEEL FRAME (4 corner posts)
	----------------------------------------------------------------------------
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

	----------------------------------------------------------------------------
	-- GLASS PANELS (dark blue-tinted, 4 walls)
	----------------------------------------------------------------------------
	local mullionThick = 0.3 * scale
	local midY = floorY + cubeH / 2
	local glassColor = Color3.fromRGB(100, 140, 200) -- lighter blue tint, see-through

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

	-- Flat roof (dark)
	local roof = Instance.new("Part")
	roof.Name = "Roof"
	roof.Size = Vector3.new(cubeD + 0.4, 0.4 * scale, cubeW + 0.4)
	roof.Position = Vector3.new(centerX, floorY + cubeH + 0.2 * scale, centerZ)
	roof.Anchored = true
	roof.Material = Enum.Material.DiamondPlate
	roof.Color = Color3.fromRGB(60, 65, 75)
	roof.Parent = model

	----------------------------------------------------------------------------
	-- GIANT SCREEN (back wall — the wall furthest from road x=0)
	----------------------------------------------------------------------------
	local screenW = cubeW * 0.85
	local screenH = cubeH * 0.65
	local screenThick = 0.4
	-- Back wall is the one away from the road
	local screenX = centerX + sign_dir * (cubeD / 2 - 1.5 * scale)
	local screenY = floorY + cubeH * 0.55

	local screen = Instance.new("Part")
	screen.Name = "MainScreen"
	screen.Size = Vector3.new(screenThick, screenH, screenW)
	screen.Position = Vector3.new(screenX, screenY, centerZ)
	screen.Anchored = true
	screen.CanCollide = false
	screen.Material = Enum.Material.Neon
	screen.Color = Color3.fromRGB(10, 20, 40)
	screen.Parent = model

	-- SurfaceGui on the screen face (facing inward toward road)
	local screenGui = Instance.new("SurfaceGui")
	screenGui.Name = "MissionGui"
	screenGui.Face = sign_dir > 0 and Enum.NormalId.Left or Enum.NormalId.Right
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
		-- Left column
		{ col = 0, row = 0, label = "ALT", value = "0.000 km", color = Color3.fromRGB(0, 255, 120) },
		{ col = 0, row = 1, label = "VEL", value = "0.000 km/s", color = Color3.fromRGB(0, 255, 120) },
		{ col = 0, row = 2, label = "ACC", value = "0.00 g", color = Color3.fromRGB(0, 255, 120) },
		{ col = 0, row = 3, label = "FUEL", value = "100.0%", color = Color3.fromRGB(0, 255, 120) },
		{ col = 0, row = 4, label = "TEMP", value = "22.4 C", color = Color3.fromRGB(0, 255, 120) },
		-- Right column
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
		local rowY = startY + d.row * (rowH + 0.02)

		-- Label
		local lbl = Instance.new("TextLabel")
		lbl.Name = d.label .. "Label"
		lbl.Size = UDim2.new(0.15, 0, rowH, 0)
		lbl.Position = UDim2.new(colX, 0, rowY, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = d.label
		lbl.TextColor3 = Color3.fromRGB(120, 140, 160)
		lbl.TextScaled = true
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Font = Enum.Font.Code
		lbl.Parent = bg

		-- Value
		local val = Instance.new("TextLabel")
		val.Name = d.label .. "Value"
		val.Size = UDim2.new(0.28, 0, rowH, 0)
		val.Position = UDim2.new(colX + 0.16, 0, rowY, 0)
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

	----------------------------------------------------------------------------
	-- SIDE SCREEN (far wall only — the one the player sees after passing)
	----------------------------------------------------------------------------
	local sideScreenW = cubeD * 0.5
	local sideScreenH = cubeH * 0.4
	for _, sz in { -1 } do
		local sideScreen = Instance.new("Part")
		sideScreen.Name = "SideScreen"
		sideScreen.Size = Vector3.new(sideScreenW, sideScreenH, screenThick)
		sideScreen.Position = Vector3.new(
			centerX + sign_dir * 4 * scale,
			floorY + cubeH * 0.6,
			centerZ + sz * (cubeW / 2 - 1.5 * scale)
		)
		sideScreen.Anchored = true
		sideScreen.CanCollide = false
		sideScreen.Material = Enum.Material.Neon
		sideScreen.Color = Color3.fromRGB(10, 20, 40)
		sideScreen.Parent = model

		local sideGui = Instance.new("SurfaceGui")
		sideGui.Name = "SideGui"
		sideGui.Face = sz > 0 and Enum.NormalId.Front or Enum.NormalId.Back
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
		sideTitle.Text = sz < 0 and "TRAJECTORY" or "SYSTEMS"
		sideTitle.TextColor3 = Color3.fromRGB(0, 180, 255)
		sideTitle.TextScaled = true
		sideTitle.Font = Enum.Font.Code
		sideTitle.Parent = sideBg

		-- Grid of status indicators
		local statuses = sz < 0
			and { "GUIDANCE: OK", "TRACKING: OK", "FTS: ARMED", "RANGE: CLR" }
			or  { "LOX: FULL", "LH2: FULL", "HYDRAUL: OK", "POWER: NOM" }
		for si, st in ipairs(statuses) do
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

	----------------------------------------------------------------------------
	-- CONSOLE DESKS (3 rows facing the main screen)
	----------------------------------------------------------------------------
	local deskW = cubeW * 0.7
	local deskD = 3 * scale
	local deskH = 3.5 * scale
	local deskRows = { -8 * scale, 0, 8 * scale }

	for _, dz in ipairs(deskRows) do
		-- Desk surface
		local desk = Instance.new("Part")
		desk.Name = "ConsolDesk"
		desk.Size = Vector3.new(deskD, deskH, deskW / 3 - 1 * scale)
		desk.Position = Vector3.new(
			centerX - sign_dir * 6 * scale,
			floorY + deskH / 2,
			centerZ + dz
		)
		desk.Anchored = true
		desk.Material = Enum.Material.SmoothPlastic
		desk.Color = Color3.fromRGB(40, 45, 55)
		desk.Parent = model

		-- Monitor on each desk (small neon screen)
		local monitor = Instance.new("Part")
		monitor.Name = "Monitor"
		monitor.Size = Vector3.new(0.2, 2.5 * scale, 3.5 * scale)
		monitor.Position = Vector3.new(
			centerX - sign_dir * 5 * scale,
			floorY + deskH + 1.5 * scale,
			centerZ + dz
		)
		monitor.Anchored = true
		monitor.CanCollide = false
		monitor.Material = Enum.Material.Neon
		monitor.Color = Color3.fromRGB(20, 60, 100)
		monitor.Parent = model
	end

	-- Chair-like blocks at each desk
	for _, dz in ipairs(deskRows) do
		local chair = Instance.new("Part")
		chair.Name = "Chair"
		chair.Size = Vector3.new(2 * scale, 3 * scale, 2 * scale)
		chair.Position = Vector3.new(
			centerX - sign_dir * 10 * scale,
			floorY + 1.5 * scale,
			centerZ + dz
		)
		chair.Anchored = true
		chair.Material = Enum.Material.SmoothPlastic
		chair.Color = Color3.fromRGB(25, 25, 35)
		chair.Parent = model

		-- Chair back
		local chairBack = Instance.new("Part")
		chairBack.Name = "ChairBack"
		chairBack.Size = Vector3.new(0.5 * scale, 4 * scale, 2 * scale)
		chairBack.Position = Vector3.new(
			centerX - sign_dir * 11.2 * scale,
			floorY + 2 * scale,
			centerZ + dz
		)
		chairBack.Anchored = true
		chairBack.Material = Enum.Material.SmoothPlastic
		chairBack.Color = Color3.fromRGB(25, 25, 35)
		chairBack.Parent = model
	end

	----------------------------------------------------------------------------
	-- CEILING BLUE LIGHT
	----------------------------------------------------------------------------
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

	----------------------------------------------------------------------------
	-- "MISSION CONTROL" SIGN (on front face, facing road)
	----------------------------------------------------------------------------
	local signPart = Instance.new("Part")
	signPart.Name = "SignPart"
	signPart.Size = Vector3.new(0.4, 3 * scale, 18 * scale)
	local signFaceX = centerX - sign_dir * (cubeD / 2 + 0.25)
	signPart.Position = Vector3.new(signFaceX, floorY + cubeH * 0.85, centerZ)
	signPart.Anchored = true
	signPart.CanCollide = false
	signPart.Material = Enum.Material.SmoothPlastic
	signPart.Color = Color3.fromRGB(20, 30, 50)
	signPart.Transparency = 1
	signPart.Parent = model

	local signGui = Instance.new("SurfaceGui")
	signGui.Name = "SignGui"
	signGui.Face = sign_dir > 0 and Enum.NormalId.Left or Enum.NormalId.Right
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

	----------------------------------------------------------------------------
	-- REGISTER SCREEN ANIMATION (countdown + telemetry ticking)
	----------------------------------------------------------------------------
	local activePlatformAnimations = DecorUtils.activePlatformAnimations
	if activePlatformAnimations then
		-- Collect references to the telemetry value labels we created
		local valueLabels = {}
		for _, child in bg:GetChildren() do
			if child.Name:match("Value$") then
				table.insert(valueLabels, child)
			end
		end

		activePlatformAnimations[screen] = {
			type = "mission_control",
			countdownLabel = countdown,
			valueLabels = valueLabels,
			startTime = tick(),
			lastTick = 0,
		}
	end

	----------------------------------------------------------------------------
	-- SPAWN NPCs (space controllers seated at desks)
	----------------------------------------------------------------------------
	local NPCManager = DecorUtils.NPCManager
	if NPCManager then
		for _, dz in ipairs(deskRows) do
			local npcX = centerX - sign_dir * 9 * scale
			local npcZ = centerZ + dz
			task.spawn(function()
				NPCManager.spawnFromTemplate(
					NPCManager.randomCivilian(),
					Vector3.new(npcX, floorY + 3.5, npcZ),
					sign_dir > 0 and 90 or -90, -- face toward the screen
					"idle"
				)
			end)
		end
	end

	model.Parent = decorFolder
	return model
end

return CommandCenter
