-- MapUI.client.luau
-- Minimap (bottom-left, always visible) + Full Map (press M).
-- Reads layout from GTAConfig — districts, roads, rail, metro, water channel.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared", 10)
local GTAConfig = require(Shared:WaitForChild("GTAConfig"))

local player = Players.LocalPlayer

-- Layout constants
local ORIGIN_X = GTAConfig.CITY_ORIGIN_X
local ORIGIN_Z = GTAConfig.CITY_ORIGIN_Z
local CITY_W   = GTAConfig.CITY_WIDTH
local CITY_D   = GTAConfig.CITY_DEPTH
local CELL     = GTAConfig.CELL_SIZE
local COLS     = GTAConfig.GRID_COLS
local ROWS     = GTAConfig.GRID_ROWS

--------------------------------------------------------------------------------
-- COORDINATE HELPERS
--------------------------------------------------------------------------------

-- World (X, Z) → map UDim2 offset (0..1, 0..1)
local function worldToMap(worldX, worldZ)
	local u = math.clamp((worldX - ORIGIN_X) / CITY_W, 0, 1)
	local v = math.clamp((worldZ - ORIGIN_Z) / CITY_D, 0, 1)
	return u, v
end

--------------------------------------------------------------------------------
-- UI CONSTRUCTION
--------------------------------------------------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MapUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true

-- ============ FULL MAP (toggle with M) ============

local fullMapVisible = false

local fullMapOverlay = Instance.new("Frame")
fullMapOverlay.Name = "FullMapOverlay"
fullMapOverlay.Size = UDim2.new(1, 0, 1, 0)
fullMapOverlay.Position = UDim2.new(0, 0, 0, 0)
fullMapOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
fullMapOverlay.BackgroundTransparency = 0.4
fullMapOverlay.Visible = false
fullMapOverlay.Parent = screenGui

-- Map frame (centered, maintains aspect ratio)
local mapAspect = CITY_W / CITY_D  -- ~1.11
local MAP_HEIGHT = 0.85
local MAP_WIDTH = MAP_HEIGHT * mapAspect

local fullMapFrame = Instance.new("Frame")
fullMapFrame.Name = "FullMap"
fullMapFrame.AnchorPoint = Vector2.new(0.5, 0.5)
fullMapFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
fullMapFrame.Size = UDim2.new(MAP_WIDTH, 0, MAP_HEIGHT, 0)
fullMapFrame.BackgroundColor3 = Color3.fromRGB(30, 60, 100) -- ocean blue
fullMapFrame.BorderSizePixel = 0
fullMapFrame.ClipsDescendants = true
fullMapFrame.Parent = fullMapOverlay

-- Corner radius
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = fullMapFrame

-- Stroke
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(200, 200, 200)
stroke.Thickness = 2
stroke.Parent = fullMapFrame

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(0.3, 0, 0, 30)
title.Position = UDim2.new(0.35, 0, 0, -35)
title.BackgroundTransparency = 1
title.Text = "ISLAND MAP  [M to close]"
title.TextColor3 = Color3.fromRGB(220, 220, 220)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = fullMapOverlay

-- ============ MINIMAP (bottom-left corner) ============

local MINI_SIZE = 180

local miniMapFrame = Instance.new("Frame")
miniMapFrame.Name = "Minimap"
miniMapFrame.AnchorPoint = Vector2.new(0, 1)
miniMapFrame.Position = UDim2.new(0, 15, 1, -15)
miniMapFrame.Size = UDim2.new(0, MINI_SIZE, 0, MINI_SIZE)
miniMapFrame.BackgroundColor3 = Color3.fromRGB(20, 40, 70)
miniMapFrame.BorderSizePixel = 0
miniMapFrame.ClipsDescendants = true
miniMapFrame.Parent = screenGui

local miniCorner = Instance.new("UICorner")
miniCorner.CornerRadius = UDim.new(0, 6)
miniCorner.Parent = miniMapFrame

local miniStroke = Instance.new("UIStroke")
miniStroke.Color = Color3.fromRGB(160, 160, 160)
miniStroke.Thickness = 2
miniStroke.Parent = miniMapFrame

-- District name label under minimap
local miniDistrictLabel = Instance.new("TextLabel")
miniDistrictLabel.Name = "DistrictLabel"
miniDistrictLabel.AnchorPoint = Vector2.new(0, 1)
miniDistrictLabel.Position = UDim2.new(0, 15, 1, -MINI_SIZE - 20)
miniDistrictLabel.Size = UDim2.new(0, MINI_SIZE, 0, 18)
miniDistrictLabel.BackgroundTransparency = 1
miniDistrictLabel.Text = ""
miniDistrictLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
miniDistrictLabel.Font = Enum.Font.GothamBold
miniDistrictLabel.TextSize = 14
miniDistrictLabel.TextXAlignment = Enum.TextXAlignment.Center
miniDistrictLabel.Parent = screenGui

--------------------------------------------------------------------------------
-- DRAW MAP CONTENT (shared between minimap and fullmap)
--------------------------------------------------------------------------------

local function drawDistricts(parent)
	for _, d in ipairs(GTAConfig.DISTRICTS) do
		local u1, v1 = worldToMap(ORIGIN_X + d.colMin * CELL, ORIGIN_Z + d.rowMin * CELL)
		local u2, v2 = worldToMap(ORIGIN_X + (d.colMax + 1) * CELL, ORIGIN_Z + (d.rowMax + 1) * CELL)

		local rect = Instance.new("Frame")
		rect.Name = "District_" .. d.name
		rect.Position = UDim2.new(u1, 0, v1, 0)
		rect.Size = UDim2.new(u2 - u1, 0, v2 - v1, 0)
		rect.BackgroundColor3 = d.color
		rect.BackgroundTransparency = 0.3
		rect.BorderSizePixel = 1
		rect.BorderColor3 = Color3.fromRGB(80, 80, 80)
		rect.ZIndex = 1
		rect.Parent = parent

		-- District label (full map only, skip for minimap)
		if parent == fullMapFrame then
			local label = Instance.new("TextLabel")
			label.Name = "Label"
			label.Size = UDim2.new(1, 0, 1, 0)
			label.BackgroundTransparency = 1
			label.Text = string.upper(d.name)
			label.TextColor3 = Color3.fromRGB(255, 255, 255)
			label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
			label.TextStrokeTransparency = 0.3
			label.Font = Enum.Font.GothamBold
			label.TextSize = 11
			label.TextScaled = false
			label.ZIndex = 5
			label.Parent = rect
		end
	end
end

local function drawRoads(parent)
	local roadColor = Color3.fromRGB(60, 60, 65)

	-- Vertical roads
	for col = 0, COLS do
		local u, _ = worldToMap(ORIGIN_X + col * CELL, 0)
		local isHighway = (col == 0 or col == COLS)
		local thickness = isHighway and 3 or 1

		local line = Instance.new("Frame")
		line.Name = "VRoad_" .. col
		line.Position = UDim2.new(u, -math.floor(thickness / 2), 0, 0)
		line.Size = UDim2.new(0, thickness, 1, 0)
		line.BackgroundColor3 = isHighway and Color3.fromRGB(180, 160, 80) or roadColor
		line.BorderSizePixel = 0
		line.ZIndex = 2
		line.Parent = parent
	end

	-- Horizontal roads
	for row = 0, ROWS do
		local _, v = worldToMap(0, ORIGIN_Z + row * CELL)
		local isHighway = (row == 0 or row == ROWS)
		local thickness = isHighway and 3 or 1

		local line = Instance.new("Frame")
		line.Name = "HRoad_" .. row
		line.Position = UDim2.new(0, 0, v, -math.floor(thickness / 2))
		line.Size = UDim2.new(1, 0, 0, thickness)
		line.BackgroundColor3 = isHighway and Color3.fromRGB(180, 160, 80) or roadColor
		line.BorderSizePixel = 0
		line.ZIndex = 2
		line.Parent = parent
	end
end

local function drawRailway(parent)
	-- Railway at col 4 boundary
	local u, _ = worldToMap(ORIGIN_X + 4 * CELL, 0)

	local rail = Instance.new("Frame")
	rail.Name = "Railway"
	rail.Position = UDim2.new(u, -2, 0, 0)
	rail.Size = UDim2.new(0, 4, 1, 0)
	rail.BackgroundColor3 = Color3.fromRGB(140, 80, 40)
	rail.BackgroundTransparency = 0.2
	rail.BorderSizePixel = 0
	rail.ZIndex = 3
	rail.Parent = parent

	-- Dashed pattern overlay (rail ties feel)
	for i = 0, 30 do
		local tick = Instance.new("Frame")
		tick.Size = UDim2.new(0, 8, 0, 1)
		tick.Position = UDim2.new(0.5, -4, i / 31, 0)
		tick.BackgroundColor3 = Color3.fromRGB(100, 60, 30)
		tick.BorderSizePixel = 0
		tick.ZIndex = 3
		tick.Parent = rail
	end
end

local function drawMetro(parent)
	local metroColor = Color3.fromRGB(0, 180, 255)

	-- E-W metro line at row 4 center
	local _, vEW = worldToMap(0, ORIGIN_Z + 4 * CELL + CELL / 2)
	local ewLine = Instance.new("Frame")
	ewLine.Name = "MetroEW"
	ewLine.Position = UDim2.new(0, 0, vEW, -1)
	ewLine.Size = UDim2.new(1, 0, 0, 3)
	ewLine.BackgroundColor3 = metroColor
	ewLine.BackgroundTransparency = 0.3
	ewLine.BorderSizePixel = 0
	ewLine.ZIndex = 3
	ewLine.Parent = parent

	-- N-S metro line at col 5 center
	local uNS, _ = worldToMap(ORIGIN_X + 5 * CELL + CELL / 2, 0)
	local nsLine = Instance.new("Frame")
	nsLine.Name = "MetroNS"
	nsLine.Position = UDim2.new(uNS, -1, 0, 0)
	nsLine.Size = UDim2.new(0, 3, 1, 0)
	nsLine.BackgroundColor3 = metroColor
	nsLine.BackgroundTransparency = 0.3
	nsLine.BorderSizePixel = 0
	nsLine.ZIndex = 3
	nsLine.Parent = parent

	-- Station dots (full map only)
	if parent == fullMapFrame then
		local stations = {
			{ col = 1,   row = 4, name = "Commercial" },
			{ col = 4,   row = 4, name = "Downtown" },
			{ col = 6.5, row = 4, name = "Government" },
			{ col = 5,   row = 1, name = "Industrial" },
			{ col = 5,   row = 4, name = "Hub" },
			{ col = 5,   row = 7, name = "Waterfront" },
		}
		for _, s in ipairs(stations) do
			local su, sv = worldToMap(ORIGIN_X + s.col * CELL + CELL / 2, ORIGIN_Z + s.row * CELL + CELL / 2)
			local dot = Instance.new("Frame")
			dot.Name = "Station_" .. s.name
			dot.AnchorPoint = Vector2.new(0.5, 0.5)
			dot.Position = UDim2.new(su, 0, sv, 0)
			dot.Size = UDim2.new(0, 8, 0, 8)
			dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			dot.BorderSizePixel = 0
			dot.ZIndex = 4
			dot.Parent = parent

			local dotCorner = Instance.new("UICorner")
			dotCorner.CornerRadius = UDim.new(1, 0)
			dotCorner.Parent = dot

			local stLabel = Instance.new("TextLabel")
			stLabel.Size = UDim2.new(0, 60, 0, 12)
			stLabel.Position = UDim2.new(1, 4, 0.5, -6)
			stLabel.BackgroundTransparency = 1
			stLabel.Text = s.name
			stLabel.TextColor3 = metroColor
			stLabel.Font = Enum.Font.GothamBold
			stLabel.TextSize = 9
			stLabel.TextXAlignment = Enum.TextXAlignment.Left
			stLabel.ZIndex = 5
			stLabel.Parent = dot
		end
	end
end

local function drawWaterChannel(parent)
	local chanZ = ORIGIN_Z + GTAConfig.WATER_CHANNEL_Z_ROW * CELL
	local chanW = GTAConfig.WATER_CHANNEL_WIDTH
	local _, v1 = worldToMap(0, chanZ - chanW / 2)
	local _, v2 = worldToMap(0, chanZ + chanW / 2)

	local water = Instance.new("Frame")
	water.Name = "WaterChannel"
	water.Position = UDim2.new(0, 0, v1, 0)
	water.Size = UDim2.new(0.8, 0, v2 - v1, 0)
	water.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
	water.BackgroundTransparency = 0.3
	water.BorderSizePixel = 0
	water.ZIndex = 2
	water.Parent = parent
end

local function drawLandmarks(parent)
	local landmarks = {
		{ name = "Terminal",    icon = "✈",  col = 2.5, row = 1 },
		{ name = "Power Plant", icon = "⚡", col = 4.5, row = 0.5 },
		{ name = "Nuclear",    icon = "☢",  col = 6,   row = 0 },
		{ name = "Military HQ",icon = "★",  col = 7.5, row = 1 },
		{ name = "Prison",     icon = "🔒", col = 9,   row = 1 },
		{ name = "White House", icon = "🏛",  col = 6.5, row = 4 },
		{ name = "Monument",   icon = "🗼", col = 7.2, row = 4 },
		{ name = "Train Stn",  icon = "🚂", col = 1,   row = 7 },
		{ name = "Golf",       icon = "⛳", col = 6.5, row = 7 },
		{ name = "Launchpad",  icon = "🚀", col = 8.5, row = 7 },
		{ name = "UFO",        icon = "👽", col = 9,   row = 7.5 },
	}

	for _, lm in ipairs(landmarks) do
		local lu, lv = worldToMap(ORIGIN_X + lm.col * CELL + CELL / 2, ORIGIN_Z + lm.row * CELL + CELL / 2)

		local marker = Instance.new("TextLabel")
		marker.Name = "LM_" .. lm.name
		marker.AnchorPoint = Vector2.new(0.5, 0.5)
		marker.Position = UDim2.new(lu, 0, lv, 0)
		marker.Size = UDim2.new(0, 20, 0, 20)
		marker.BackgroundTransparency = 1
		marker.Text = lm.icon
		marker.TextSize = 14
		marker.ZIndex = 6
		marker.Parent = parent

		-- Tooltip label
		if parent == fullMapFrame then
			local tip = Instance.new("TextLabel")
			tip.Size = UDim2.new(0, 70, 0, 10)
			tip.Position = UDim2.new(0.5, -35, 1, 1)
			tip.BackgroundTransparency = 1
			tip.Text = lm.name
			tip.TextColor3 = Color3.fromRGB(220, 220, 200)
			tip.TextStrokeTransparency = 0.4
			tip.Font = Enum.Font.Gotham
			tip.TextSize = 8
			tip.ZIndex = 6
			tip.Parent = marker
		end
	end
end

-- Player dot
local function createPlayerDot(parent)
	local dot = Instance.new("Frame")
	dot.Name = "PlayerDot"
	dot.AnchorPoint = Vector2.new(0.5, 0.5)
	dot.Size = UDim2.new(0, 10, 0, 10)
	dot.BackgroundColor3 = Color3.fromRGB(255, 255, 50)
	dot.BorderSizePixel = 0
	dot.ZIndex = 10
	dot.Parent = parent

	local dotCorner = Instance.new("UICorner")
	dotCorner.CornerRadius = UDim.new(1, 0)
	dotCorner.Parent = dot

	-- Pulsing glow
	local glow = Instance.new("UIStroke")
	glow.Color = Color3.fromRGB(255, 255, 100)
	glow.Thickness = 2
	glow.Transparency = 0.5
	glow.Parent = dot

	return dot
end

-- Direction arrow on player dot
local function createDirectionArrow(parent)
	local arrow = Instance.new("ImageLabel")
	arrow.Name = "Arrow"
	arrow.AnchorPoint = Vector2.new(0.5, 0.5)
	arrow.Position = UDim2.new(0.5, 0, 0.5, 0)
	arrow.Size = UDim2.new(0, 20, 0, 20)
	arrow.BackgroundTransparency = 1
	arrow.Image = "" -- We'll use a triangle Frame instead
	arrow.ZIndex = 11
	arrow.Parent = parent

	-- Simple triangle using rotated frame
	local tri = Instance.new("Frame")
	tri.Name = "DirIndicator"
	tri.AnchorPoint = Vector2.new(0.5, 1)
	tri.Position = UDim2.new(0.5, 0, 0, -2)
	tri.Size = UDim2.new(0, 6, 0, 8)
	tri.BackgroundColor3 = Color3.fromRGB(255, 255, 50)
	tri.BorderSizePixel = 0
	tri.Rotation = 0
	tri.ZIndex = 11
	tri.Parent = parent

	return tri
end

--------------------------------------------------------------------------------
-- BUILD BOTH MAPS
--------------------------------------------------------------------------------

-- Full map content
drawDistricts(fullMapFrame)
drawRoads(fullMapFrame)
drawRailway(fullMapFrame)
drawMetro(fullMapFrame)
drawWaterChannel(fullMapFrame)
drawLandmarks(fullMapFrame)
local fullPlayerDot = createPlayerDot(fullMapFrame)
local fullDirArrow = createDirectionArrow(fullPlayerDot)

-- Minimap content
drawDistricts(miniMapFrame)
drawRoads(miniMapFrame)
drawRailway(miniMapFrame)
drawMetro(miniMapFrame)
drawWaterChannel(miniMapFrame)
local miniPlayerDot = createPlayerDot(miniMapFrame)
local miniDirArrow = createDirectionArrow(miniPlayerDot)

-- Legend (full map, bottom-right)
local legend = Instance.new("Frame")
legend.Name = "Legend"
legend.AnchorPoint = Vector2.new(1, 1)
legend.Position = UDim2.new(1, -10, 1, -10)
legend.Size = UDim2.new(0, 120, 0, 100)
legend.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
legend.BackgroundTransparency = 0.5
legend.BorderSizePixel = 0
legend.ZIndex = 8
legend.Parent = fullMapFrame

local legendCorner = Instance.new("UICorner")
legendCorner.CornerRadius = UDim.new(0, 4)
legendCorner.Parent = legend

local legendItems = {
	{ color = Color3.fromRGB(180, 160, 80),  text = "Highway" },
	{ color = Color3.fromRGB(60, 60, 65),    text = "Road" },
	{ color = Color3.fromRGB(140, 80, 40),   text = "Railway" },
	{ color = Color3.fromRGB(0, 180, 255),   text = "Metro" },
	{ color = Color3.fromRGB(40, 120, 200),  text = "Water" },
	{ color = Color3.fromRGB(255, 255, 50),  text = "You" },
}

for i, item in ipairs(legendItems) do
	local swatch = Instance.new("Frame")
	swatch.Size = UDim2.new(0, 10, 0, 10)
	swatch.Position = UDim2.new(0, 8, 0, 6 + (i - 1) * 15)
	swatch.BackgroundColor3 = item.color
	swatch.BorderSizePixel = 0
	swatch.ZIndex = 9
	swatch.Parent = legend

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -25, 0, 12)
	lbl.Position = UDim2.new(0, 22, 0, 5 + (i - 1) * 15)
	lbl.BackgroundTransparency = 1
	lbl.Text = item.text
	lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 10
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 9
	lbl.Parent = legend
end

--------------------------------------------------------------------------------
-- TOGGLE FULL MAP
--------------------------------------------------------------------------------

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.M then
		fullMapVisible = not fullMapVisible
		fullMapOverlay.Visible = fullMapVisible
	end
end)

--------------------------------------------------------------------------------
-- UPDATE LOOP — move player dot
--------------------------------------------------------------------------------

local function getPlayerPosition()
	local char = player.Character
	if not char then return nil, nil end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil, nil end
	return hrp.Position, hrp.CFrame.LookVector
end

local function updatePlayerDot(dot, dirArrow, worldPos, lookDir)
	local u, v = worldToMap(worldPos.X, worldPos.Z)
	dot.Position = UDim2.new(u, 0, v, 0)

	-- Rotation from look direction (Y axis = north = -Z in Roblox)
	if lookDir then
		local angle = math.deg(math.atan2(lookDir.X, -lookDir.Z))
		dirArrow.Rotation = angle
	end
end

RunService.Heartbeat:Connect(function()
	local pos, look = getPlayerPosition()
	if not pos then return end

	-- Update full map dot
	updatePlayerDot(fullPlayerDot, fullDirArrow, pos, look)

	-- Update minimap dot
	updatePlayerDot(miniPlayerDot, miniDirArrow, pos, look)

	-- Update district name label
	local col = math.floor((pos.X - ORIGIN_X) / CELL)
	local row = math.floor((pos.Z - ORIGIN_Z) / CELL)
	col = math.clamp(col, 0, COLS - 1)
	row = math.clamp(row, 0, ROWS - 1)
	local district = GTAConfig.getDistrict(col, row)
	miniDistrictLabel.Text = string.upper(district)
end)

--------------------------------------------------------------------------------
-- PARENT GUI
--------------------------------------------------------------------------------

screenGui.Parent = player:WaitForChild("PlayerGui")
print("[MapUI] Map ready — press M for full map")
