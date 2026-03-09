-- MapUI.client.luau
-- Minimap (bottom-left, zoomed + scrolls with player) + Full Map (press M).
-- Lane-zone architecture: reads lane definitions from GTAConfig for all drawing.

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
-- COORDINATE HELPER — world (X,Z) → scale (0..1, 0..1)
--------------------------------------------------------------------------------

local function worldToScale(worldX, worldZ)
	local u = (worldX - ORIGIN_X) / CITY_W
	local v = (worldZ - ORIGIN_Z) / CITY_D
	return u, v
end

--------------------------------------------------------------------------------
-- SCREEN GUI
--------------------------------------------------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MapUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true

--------------------------------------------------------------------------------
-- DRAW FUNCTIONS
--------------------------------------------------------------------------------

local function drawDistricts(parent, isDetailed)
	for _, d in ipairs(GTAConfig.DISTRICTS) do
		local u1, v1 = worldToScale(ORIGIN_X + d.colMin * CELL, ORIGIN_Z + d.rowMin * CELL)
		local u2, v2 = worldToScale(ORIGIN_X + (d.colMax + 1) * CELL, ORIGIN_Z + (d.rowMax + 1) * CELL)

		local rect = Instance.new("Frame")
		rect.Name = "D_" .. d.name
		rect.Position = UDim2.new(u1, 0, v1, 0)
		rect.Size = UDim2.new(u2 - u1, 0, v2 - v1, 0)
		rect.BackgroundColor3 = d.color
		rect.BackgroundTransparency = 0.35
		rect.BorderSizePixel = 1
		rect.BorderColor3 = Color3.fromRGB(60, 60, 60)
		rect.ZIndex = 1
		rect.Parent = parent

		if isDetailed then
			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, 0, 1, 0)
			label.BackgroundTransparency = 1
			label.Text = string.upper(d.name)
			label.TextColor3 = Color3.fromRGB(255, 255, 255)
			label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
			label.TextStrokeTransparency = 0.2
			label.Font = Enum.Font.GothamBold
			label.TextSize = 12
			label.ZIndex = 5
			label.Parent = rect
		end
	end
end

-- Draw a lane line on the map (color + thickness from lane type)
local function drawLaneLine(parent, u1, v1, u2, v2, isVertical, color, thickness)
	local line = Instance.new("Frame")
	line.Name = "Lane"
	if isVertical then
		line.AnchorPoint = Vector2.new(0.5, 0)
		line.Position = UDim2.new(u1, 0, v1, 0)
		line.Size = UDim2.new(0, thickness, v2 - v1, 0)
	else
		line.AnchorPoint = Vector2.new(0, 0.5)
		line.Position = UDim2.new(u1, 0, v1, 0)
		line.Size = UDim2.new(u2 - u1, 0, 0, thickness)
	end
	line.BackgroundColor3 = color
	line.BackgroundTransparency = 0
	line.BorderSizePixel = 0
	line.ZIndex = 2
	line.Parent = parent
	return line
end

-- Draw all lanes from GTAConfig using lane type colors
local function drawAllLanes(parent, _isDetailed)
	-- H-lanes
	for _, lane in ipairs(GTAConfig.H_LANES) do
		local _, v = worldToScale(0, GTAConfig.getRowEdgeZ(lane.row))
		local def = GTAConfig.LANE_TYPES[lane.type]
		local color = def and def.mapColor or Color3.fromRGB(200, 200, 190)
		local thick = def and def.mapThickness or 3
		if thick == 0 then thick = 6 end
		drawLaneLine(parent, 0, v, 1, v, false, color, thick)
	end

	-- V-lanes
	for _, lane in ipairs(GTAConfig.V_LANES) do
		local u, _ = worldToScale(GTAConfig.getColEdgeX(lane.col), 0)
		local def = GTAConfig.LANE_TYPES[lane.type]
		local color = def and def.mapColor or Color3.fromRGB(200, 200, 190)
		local thick = def and def.mapThickness or 3
		if thick == 0 then thick = 6 end
		drawLaneLine(parent, u, 0, u, 1, true, color, thick)
	end
end

local function drawLandmarks(parent)
	local landmarks = {
		{ icon = "✈",  col = 1.5,  row = 1,   tip = "Terminal" },
		{ icon = "⚡", col = 8,    row = 1,   tip = "Power Plant" },
		{ icon = "★",  col = 10.5, row = 1,   tip = "Military HQ" },
		{ icon = "☢",  col = 12.5, row = 1,   tip = "Nuclear" },
		{ icon = "🏛",  col = 8.5,  row = 4.5, tip = "White House" },
		{ icon = "🗼", col = 9,    row = 5,   tip = "Monument" },
		{ icon = "🔒", col = 10.5, row = 4.5, tip = "Prison" },
		{ icon = "🚂", col = 1,    row = 8,   tip = "Train Stn" },
		{ icon = "💧", col = 4,    row = 8,   tip = "Water Plant" },
		{ icon = "⛳", col = 10,   row = 8,   tip = "Golf" },
		{ icon = "🚀", col = 12.5, row = 8,   tip = "Launchpad" },
		{ icon = "👽", col = 13,   row = 8.5, tip = "UFO" },
	}

	for _, lm in ipairs(landmarks) do
		local lu, lv = worldToScale(ORIGIN_X + lm.col * CELL + CELL / 2, ORIGIN_Z + lm.row * CELL + CELL / 2)
		local m = Instance.new("TextLabel")
		m.Name = "LM"
		m.AnchorPoint = Vector2.new(0.5, 0.5)
		m.Position = UDim2.new(lu, 0, lv, 0)
		m.Size = UDim2.new(0, 20, 0, 20)
		m.BackgroundTransparency = 1
		m.Text = lm.icon
		m.TextSize = 14
		m.ZIndex = 6
		m.Parent = parent

		local t = Instance.new("TextLabel")
		t.Size = UDim2.new(0, 70, 0, 10)
		t.Position = UDim2.new(0.5, -35, 1, 1)
		t.BackgroundTransparency = 1
		t.Text = lm.tip
		t.TextColor3 = Color3.fromRGB(230, 230, 210)
		t.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		t.TextStrokeTransparency = 0.3
		t.Font = Enum.Font.Gotham
		t.TextSize = 8
		t.ZIndex = 6
		t.Parent = m
	end
end

local function createPlayerDot(parent, size)
	size = size or 10
	local dot = Instance.new("Frame")
	dot.Name = "PlayerDot"
	dot.AnchorPoint = Vector2.new(0.5, 0.5)
	dot.Size = UDim2.new(0, size, 0, size)
	dot.BackgroundColor3 = Color3.fromRGB(255, 255, 50)
	dot.BorderSizePixel = 0
	dot.ZIndex = 10
	dot.Parent = parent

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(1, 0)
	c.Parent = dot

	local g = Instance.new("UIStroke")
	g.Color = Color3.fromRGB(255, 255, 100)
	g.Thickness = 2
	g.Transparency = 0.4
	g.Parent = dot

	-- Direction arrow
	local arrow = Instance.new("Frame")
	arrow.Name = "Arrow"
	arrow.AnchorPoint = Vector2.new(0.5, 1)
	arrow.Position = UDim2.new(0.5, 0, 0, -2)
	arrow.Size = UDim2.new(0, 6, 0, 10)
	arrow.BackgroundColor3 = Color3.fromRGB(255, 255, 50)
	arrow.BorderSizePixel = 0
	arrow.ZIndex = 11
	arrow.Parent = dot

	return dot, arrow
end

--------------------------------------------------------------------------------
-- ============ FULL MAP (press M) ============
--------------------------------------------------------------------------------

local fullMapVisible = false

local fullMapOverlay = Instance.new("Frame")
fullMapOverlay.Name = "FullMapOverlay"
fullMapOverlay.Size = UDim2.new(1, 0, 1, 0)
fullMapOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
fullMapOverlay.BackgroundTransparency = 0.4
fullMapOverlay.Visible = false
fullMapOverlay.Parent = screenGui

local mapAspect = CITY_W / CITY_D

local fullMap = Instance.new("Frame")
fullMap.Name = "FullMap"
fullMap.AnchorPoint = Vector2.new(0.5, 0.5)
fullMap.Position = UDim2.new(0.5, 0, 0.5, 0)
fullMap.Size = UDim2.new(0.92, 0, 0.88, 0)
fullMap.BackgroundColor3 = Color3.fromRGB(25, 50, 90)
fullMap.BorderSizePixel = 0
fullMap.ClipsDescendants = true
fullMap.Parent = fullMapOverlay

local aspectConstraint = Instance.new("UIAspectRatioConstraint")
aspectConstraint.AspectRatio = mapAspect
aspectConstraint.AspectType = Enum.AspectType.FitWithinMaxSize
aspectConstraint.Parent = fullMap

Instance.new("UICorner", fullMap).CornerRadius = UDim.new(0, 8)
local fStroke = Instance.new("UIStroke", fullMap)
fStroke.Color = Color3.fromRGB(200, 200, 200)
fStroke.Thickness = 2

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.4, 0, 0, 28)
title.AnchorPoint = Vector2.new(0.5, 0)
title.Position = UDim2.new(0.5, 0, 0, -34)
title.BackgroundTransparency = 1
title.Text = "ISLAND MAP  [M to close]"
title.TextColor3 = Color3.fromRGB(220, 220, 220)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = fullMapOverlay

-- Draw full map content
drawDistricts(fullMap, true)
drawAllLanes(fullMap, true)
drawLandmarks(fullMap)
local fullDot, fullArrow = createPlayerDot(fullMap, 10)

-- Legend — auto-generated from LANE_TYPES
local legend = Instance.new("Frame")
legend.AnchorPoint = Vector2.new(1, 1)
legend.Position = UDim2.new(1, -8, 1, -8)
legend.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
legend.BackgroundTransparency = 0.4
legend.BorderSizePixel = 0
legend.ZIndex = 8
legend.Parent = fullMap
Instance.new("UICorner", legend).CornerRadius = UDim.new(0, 4)

-- Build legend entries
local legendEntries = {
	{ Color3.fromRGB(240, 210, 80), "Highway" },
	{ Color3.fromRGB(200, 200, 190), "Road" },
	{ Color3.fromRGB(139, 69, 19), "Railway" },
	{ Color3.fromRGB(255, 255, 50), "You" },
}

legend.Size = UDim2.new(0, 110, 0, 4 + #legendEntries * 14)

for i, item in ipairs(legendEntries) do
	local sw = Instance.new("Frame")
	sw.Size = UDim2.new(0, 10, 0, 10)
	sw.Position = UDim2.new(0, 8, 0, 4 + (i - 1) * 14)
	sw.BackgroundColor3 = item[1]
	sw.BorderSizePixel = 0
	sw.ZIndex = 9
	sw.Parent = legend

	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, -24, 0, 12)
	l.Position = UDim2.new(0, 22, 0, 3 + (i - 1) * 14)
	l.BackgroundTransparency = 1
	l.Text = item[2]
	l.TextColor3 = Color3.fromRGB(220, 220, 220)
	l.Font = Enum.Font.Gotham
	l.TextSize = 10
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.ZIndex = 9
	l.Parent = legend
end

--------------------------------------------------------------------------------
-- ============ MINIMAP (bottom-left, ZOOMED, scrolls with player) ============
--------------------------------------------------------------------------------

local MINI_SIZE = 200
local MINI_ZOOM = 3.5

local miniFrame = Instance.new("Frame")
miniFrame.Name = "Minimap"
miniFrame.AnchorPoint = Vector2.new(0, 1)
miniFrame.Position = UDim2.new(0, 12, 1, -12)
miniFrame.Size = UDim2.new(0, MINI_SIZE, 0, MINI_SIZE)
miniFrame.BackgroundColor3 = Color3.fromRGB(25, 50, 90)
miniFrame.BorderSizePixel = 0
miniFrame.ClipsDescendants = true
miniFrame.Parent = screenGui

Instance.new("UICorner", miniFrame).CornerRadius = UDim.new(0, 6)
local mStroke = Instance.new("UIStroke", miniFrame)
mStroke.Color = Color3.fromRGB(180, 180, 180)
mStroke.Thickness = 2

-- Inner content frame (larger than viewport — scrolls to follow player)
local contentW = math.floor(MINI_SIZE * MINI_ZOOM * mapAspect)
local contentH = math.floor(MINI_SIZE * MINI_ZOOM)

local miniContent = Instance.new("Frame")
miniContent.Name = "Content"
miniContent.Size = UDim2.new(0, contentW, 0, contentH)
miniContent.BackgroundColor3 = Color3.fromRGB(25, 50, 90)
miniContent.BorderSizePixel = 0
miniContent.Parent = miniFrame

-- Draw mini map content (no labels — too small)
drawDistricts(miniContent, false)
drawAllLanes(miniContent, false)

-- Player dot stays fixed at center of minimap viewport
local miniDot, miniArrow = createPlayerDot(miniFrame, 12)
miniDot.Position = UDim2.new(0.5, 0, 0.5, 0)

-- Crosshair lines on minimap (subtle)
local function miniCross(sizeU, sizeV, posU, posV)
	local c = Instance.new("Frame")
	c.AnchorPoint = Vector2.new(0.5, 0.5)
	c.Position = UDim2.new(posU, 0, posV, 0)
	c.Size = UDim2.new(sizeU, 0, sizeV, 0)
	c.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	c.BackgroundTransparency = 0.85
	c.BorderSizePixel = 0
	c.ZIndex = 9
	c.Parent = miniFrame
end
miniCross(0, 1, 0.5, 0.5)
miniCross(1, 0, 0.5, 0.5)

-- District name label above minimap
local miniLabel = Instance.new("TextLabel")
miniLabel.Name = "DistrictLabel"
miniLabel.AnchorPoint = Vector2.new(0, 1)
miniLabel.Position = UDim2.new(0, 12, 1, -MINI_SIZE - 18)
miniLabel.Size = UDim2.new(0, MINI_SIZE, 0, 20)
miniLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
miniLabel.BackgroundTransparency = 0.5
miniLabel.Text = ""
miniLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
miniLabel.Font = Enum.Font.GothamBold
miniLabel.TextSize = 13
miniLabel.TextXAlignment = Enum.TextXAlignment.Center
miniLabel.Parent = screenGui
Instance.new("UICorner", miniLabel).CornerRadius = UDim.new(0, 4)

--------------------------------------------------------------------------------
-- TOGGLE FULL MAP
--------------------------------------------------------------------------------

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.M then
		fullMapVisible = not fullMapVisible
		fullMapOverlay.Visible = fullMapVisible
	end
end)

--------------------------------------------------------------------------------
-- UPDATE LOOP
--------------------------------------------------------------------------------

local function getPlayerPosition()
	local char = player.Character
	if not char then return nil, nil end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil, nil end
	return hrp.Position, hrp.CFrame.LookVector
end

RunService.Heartbeat:Connect(function()
	local pos, look = getPlayerPosition()
	if not pos then return end

	local u, v = worldToScale(pos.X, pos.Z)
	local angle = look and math.deg(math.atan2(look.X, -look.Z)) or 0

	-- Full map: move dot
	fullDot.Position = UDim2.new(math.clamp(u, 0, 1), 0, math.clamp(v, 0, 1), 0)
	fullArrow.Rotation = angle

	-- Minimap: scroll content so player is centered in viewport
	local px = u * contentW
	local pz = v * contentH
	miniContent.Position = UDim2.new(0, math.floor(MINI_SIZE / 2 - px), 0, math.floor(MINI_SIZE / 2 - pz))
	miniArrow.Rotation = angle

	-- District name
	local col = math.clamp(math.floor((pos.X - ORIGIN_X) / CELL), 0, COLS - 1)
	local row = math.clamp(math.floor((pos.Z - ORIGIN_Z) / CELL), 0, ROWS - 1)
	miniLabel.Text = string.upper(GTAConfig.getDistrict(col, row))
end)

--------------------------------------------------------------------------------
-- PARENT
--------------------------------------------------------------------------------

screenGui.Parent = player:WaitForChild("PlayerGui")
print("[MapUI] Map ready — press M for full map")
