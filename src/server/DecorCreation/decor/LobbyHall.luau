-- LobbyHall.luau
-- Large glass-walled entrance lobby. Player spawns inside, contained by walls.
-- Back wall (-Z, toward zone 1) = sliding glass door, opens when game starts.
-- Front wall (+Z, behind player) = solid glass.
-- Side walls = solid glass. Pods on sides for UI stations.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local LobbyHall = {}

local TERRAIN_TOP = DecorUtils.TERRAIN_TOP
local PLAYABLE_WIDTH = DecorUtils.PLAYABLE_WIDTH

-- Dimensions — structure fills the lane (depth 120, centered on laneZ)
local HALL_WIDTH = PLAYABLE_WIDTH         -- 80 studs wide
local HALL_HALF_DEPTH = 55                -- half-depth from center (total 110, fits in 120 lane)
local HALL_HEIGHT = 22
local WALL_THICK = 0.4
local GLASS_TRANSPARENCY = 0.65
local GLASS_COLOR = Color3.fromRGB(200, 230, 255)

-- Frame/structure
local FRAME_COLOR = Color3.fromRGB(140, 140, 150)
local FRAME_MATERIAL = Enum.Material.DiamondPlate
local FLOOR_COLOR = Color3.fromRGB(200, 200, 205)
local CEILING_COLOR = Color3.fromRGB(180, 180, 185)

-- Pod/pedestal
local POD_COLOR = Color3.fromRGB(220, 220, 230)
local POD_ACCENT = Color3.fromRGB(100, 160, 255)
local POD_WIDTH = 8
local POD_DEPTH = 8
local POD_HEIGHT = 4

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

local function makeGlass(parent, name, size, cf)
	local p = makePart(parent, name, size, cf, GLASS_COLOR, Enum.Material.Glass)
	p.Transparency = GLASS_TRANSPARENCY
	p.CanCollide = true
	return p
end

--------------------------------------------------------------------------------
-- GLASS WALL: grid of panels with steel mullions
--------------------------------------------------------------------------------

local function buildGlassWall(parent, axis, coord, center, span, height, baseY)
	local MULLION_THICK = 0.4
	local PANEL_COLS = 6
	local PANEL_ROWS = 2

	local panelW = (span - MULLION_THICK * (PANEL_COLS + 1)) / PANEL_COLS
	local panelH = (height - MULLION_THICK * (PANEL_ROWS + 1)) / PANEL_ROWS

	for row = 0, PANEL_ROWS - 1 do
		local panelY = baseY + MULLION_THICK + panelH / 2 + row * (panelH + MULLION_THICK)
		for col = 0, PANEL_COLS - 1 do
			local offset = -span / 2 + MULLION_THICK + panelW / 2 + col * (panelW + MULLION_THICK)

			local size, cf
			if axis == "x" then
				size = Vector3.new(WALL_THICK, panelH, panelW)
				cf = CFrame.new(coord, panelY, center + offset)
			else
				size = Vector3.new(panelW, panelH, WALL_THICK)
				cf = CFrame.new(center + offset, panelY, coord)
			end
			makeGlass(parent, "GlassPanel", size, cf)
		end
	end

	-- Vertical mullions
	for col = 0, PANEL_COLS do
		local offset = -span / 2 + col * (panelW + MULLION_THICK) + MULLION_THICK / 2
		local size, cf
		if axis == "x" then
			size = Vector3.new(MULLION_THICK, height, MULLION_THICK)
			cf = CFrame.new(coord, baseY + height / 2, center + offset)
		else
			size = Vector3.new(MULLION_THICK, height, MULLION_THICK)
			cf = CFrame.new(center + offset, baseY + height / 2, coord)
		end
		makePart(parent, "Mullion", size, cf, FRAME_COLOR, FRAME_MATERIAL)
	end

	-- Horizontal mullions
	for row = 0, PANEL_ROWS do
		local mullionY = baseY + row * (panelH + MULLION_THICK) + MULLION_THICK / 2
		local size, cf
		if axis == "x" then
			size = Vector3.new(MULLION_THICK, MULLION_THICK, span)
			cf = CFrame.new(coord, mullionY, center)
		else
			size = Vector3.new(span, MULLION_THICK, MULLION_THICK)
			cf = CFrame.new(center, mullionY, coord)
		end
		makePart(parent, "HMullion", size, cf, FRAME_COLOR, FRAME_MATERIAL)
	end
end

--------------------------------------------------------------------------------
-- SLIDING GLASS DOOR: two panels that slide outward to open
--------------------------------------------------------------------------------

local function buildDoorHalf(parent, name, zPos, xCenter, halfWidth, height, baseY)
	-- Build a glass panel grid (like the side walls) for one door half
	local MULLION_THICK = 0.4
	local PANEL_COLS = 3
	local PANEL_ROWS = 2
	local span = halfWidth * 2 -- total width of this half

	local panelW = (span - MULLION_THICK * (PANEL_COLS + 1)) / PANEL_COLS
	local panelH = (height - MULLION_THICK * (PANEL_ROWS + 1)) / PANEL_ROWS

	local doorModel = Instance.new("Model")
	doorModel.Name = name

	-- Glass panels
	for row = 0, PANEL_ROWS - 1 do
		local panelY = baseY + MULLION_THICK + panelH / 2 + row * (panelH + MULLION_THICK)
		for col = 0, PANEL_COLS - 1 do
			local offset = -span / 2 + MULLION_THICK + panelW / 2 + col * (panelW + MULLION_THICK)
			local size = Vector3.new(panelW, panelH, WALL_THICK)
			local cf = CFrame.new(xCenter + offset, panelY, zPos)
			makeGlass(doorModel, "GlassPanel", size, cf)
		end
	end

	-- Vertical mullions
	for col = 0, PANEL_COLS do
		local offset = -span / 2 + col * (panelW + MULLION_THICK) + MULLION_THICK / 2
		makePart(doorModel, "Mullion",
			Vector3.new(MULLION_THICK, height, MULLION_THICK),
			CFrame.new(xCenter + offset, baseY + height / 2, zPos),
			FRAME_COLOR, FRAME_MATERIAL)
	end

	-- Horizontal mullions
	for row = 0, PANEL_ROWS do
		local mullionY = baseY + row * (panelH + MULLION_THICK) + MULLION_THICK / 2
		makePart(doorModel, "HMullion",
			Vector3.new(span, MULLION_THICK, MULLION_THICK),
			CFrame.new(xCenter, mullionY, zPos),
			FRAME_COLOR, FRAME_MATERIAL)
	end

	doorModel.Parent = parent
	return doorModel
end

local function buildSlidingDoor(parent, zPos, width, height, baseY)
	local PILLAR_W = 2
	local halfW = width / 2

	-- Corner pillars only (no center divider — both halves slide cleanly apart)
	for _, sx in ipairs({ -1, 1 }) do
		makePart(parent, "DoorPillar",
			Vector3.new(PILLAR_W, height, PILLAR_W),
			CFrame.new(sx * halfW, baseY + height / 2, zPos),
			FRAME_COLOR, FRAME_MATERIAL)
	end

	-- Top crossbar
	makePart(parent, "DoorCrossbar",
		Vector3.new(width + PILLAR_W, 1, PILLAR_W),
		CFrame.new(0, baseY + height + 0.5, zPos),
		FRAME_COLOR, FRAME_MATERIAL)

	-- Each door half spans from center to its corner pillar
	local doorHalfW = halfW - PILLAR_W / 2
	local leftPanel = buildDoorHalf(parent, "DoorPanelLeft", zPos,
		-doorHalfW / 2, doorHalfW / 2, height, baseY)

	local rightPanel = buildDoorHalf(parent, "DoorPanelRight", zPos,
		doorHalfW / 2, doorHalfW / 2, height, baseY)

	return leftPanel, rightPanel
end

--------------------------------------------------------------------------------
-- POD: pedestal with label
--------------------------------------------------------------------------------

local function buildPod(parent, x, z, baseY, label, accentColor)
	accentColor = accentColor or POD_ACCENT
	local base = makePart(parent, "PodBase",
		Vector3.new(POD_WIDTH, POD_HEIGHT, POD_DEPTH),
		CFrame.new(x, baseY + POD_HEIGHT / 2, z),
		POD_COLOR, Enum.Material.SmoothPlastic)
	base.CanCollide = true

	makePart(parent, "PodAccent",
		Vector3.new(POD_WIDTH + 0.2, 0.3, POD_DEPTH + 0.2),
		CFrame.new(x, baseY + POD_HEIGHT + 0.15, z),
		accentColor, Enum.Material.Neon)

	local signPart = makePart(parent, "PodSign",
		Vector3.new(POD_WIDTH - 1, 3, 0.1),
		CFrame.new(x, baseY + POD_HEIGHT + 2.5, z),
		accentColor, Enum.Material.SmoothPlastic)
	signPart.Transparency = 1

	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.LightInfluence = 0
	gui.Parent = signPart

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = label
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Parent = gui

	local gui2 = gui:Clone()
	gui2.Face = Enum.NormalId.Back
	gui2.Parent = signPart

	local glow = Instance.new("PointLight")
	glow.Color = accentColor
	glow.Brightness = 1
	glow.Range = 12
	glow.Parent = signPart

	-- ProximityPrompt for pod interaction
	local prompt = Instance.new("ProximityPrompt")
	prompt.ObjectText = label
	prompt.ActionText = "Open"
	prompt.MaxActivationDistance = 10
	prompt.HoldDuration = 0
	prompt.RequiresLineOfSight = false
	prompt.Parent = base
end

--------------------------------------------------------------------------------
-- PUBLIC: createLobbyHall(x, z, scale)
-- z = lane CENTER (laneZ from LaneCreation)
--------------------------------------------------------------------------------

function LobbyHall.createLobbyHall(x, z, scale)
	local decorFolder = DecorUtils.decorFolder
	if not decorFolder then return nil end

	local model = Instance.new("Model")
	model.Name = "LobbyHall"

	local baseY = TERRAIN_TOP
	local halfW = HALL_WIDTH / 2
	-- z is the lane CENTER; build from center outward
	local nearZ = z + HALL_HALF_DEPTH    -- +Z edge (behind player, entrance side)
	local farZ = z - HALL_HALF_DEPTH     -- -Z edge (toward zone 1, exit side)

	--------------------------------------------------------------------
	-- FLOOR
	--------------------------------------------------------------------
	local floor = makePart(model, "Floor",
		Vector3.new(HALL_WIDTH, 0.3, HALL_HALF_DEPTH * 2),
		CFrame.new(0, baseY + 0.15, z),
		FLOOR_COLOR, Enum.Material.Marble)
	floor.CanCollide = true

	--------------------------------------------------------------------
	-- SIDE WALLS (left + right)
	--------------------------------------------------------------------
	buildGlassWall(model, "x", -halfW, z, HALL_HALF_DEPTH * 2, HALL_HEIGHT, baseY)
	buildGlassWall(model, "x", halfW, z, HALL_HALF_DEPTH * 2, HALL_HEIGHT, baseY)

	--------------------------------------------------------------------
	-- BACK WALL (+Z, behind player) — invisible collision barrier
	-- Fully transparent so the camera never clips into it
	--------------------------------------------------------------------
	local backWall = Instance.new("Part")
	backWall.Name = "BackWallBarrier"
	backWall.Size = Vector3.new(HALL_WIDTH, HALL_HEIGHT, WALL_THICK)
	backWall.CFrame = CFrame.new(0, baseY + HALL_HEIGHT / 2, nearZ)
	backWall.Anchored = true
	backWall.CanCollide = true
	backWall.Transparency = 1
	backWall.Parent = model

	--------------------------------------------------------------------
	-- BACK WALL (-Z, toward zone 1) — sliding glass door
	--------------------------------------------------------------------
	local leftDoor, rightDoor = buildSlidingDoor(model, farZ, HALL_WIDTH, HALL_HEIGHT, baseY)

	--------------------------------------------------------------------
	-- CEILING + light
	--------------------------------------------------------------------
	local roofY = baseY + HALL_HEIGHT
	makePart(model, "Ceiling",
		Vector3.new(HALL_WIDTH + 0.5, 0.4, HALL_HALF_DEPTH * 2 + 0.5),
		CFrame.new(0, roofY + 0.2, z),
		CEILING_COLOR, Enum.Material.DiamondPlate)

	local lightStrip = makePart(model, "LightStrip",
		Vector3.new(HALL_WIDTH * 0.4, 0.3, HALL_HALF_DEPTH * 2 * 0.8),
		CFrame.new(0, roofY - 0.2, z),
		Color3.fromRGB(255, 255, 255), Enum.Material.Neon)
	lightStrip.CanCollide = false

	local ceilingLight = Instance.new("PointLight")
	ceilingLight.Color = Color3.fromRGB(255, 255, 255)
	ceilingLight.Brightness = 0.8
	ceilingLight.Range = 50
	ceilingLight.Parent = lightStrip

	--------------------------------------------------------------------
	-- PODS: 4 pedestals along the sides
	--------------------------------------------------------------------
	local totalDepth = HALL_HALF_DEPTH * 2
	local podSpacing = totalDepth / 5
	local podX = halfW - POD_WIDTH / 2 - 4

	-- Player spawns at z+15, faces -Z. All pods placed well ahead of player.
	buildPod(model, -podX, z - 8, baseY, "CHARACTERS", Color3.fromRGB(80, 140, 255))    -- blue
	buildPod(model, podX, z - 8, baseY, "SHOP", Color3.fromRGB(80, 220, 100))           -- green
	buildPod(model, -podX, z - 24, baseY, "LEADERBOARD", Color3.fromRGB(255, 200, 40))   -- gold
	buildPod(model, podX, z - 24, baseY, "BADGES", Color3.fromRGB(180, 80, 255))          -- purple
	buildPod(model, podX, z - 40, baseY, "PROFILE", Color3.fromRGB(140, 140, 160))       -- grey
	buildPod(model, -podX, z - 40, baseY, "THEMES", Color3.fromRGB(200, 80, 255))        -- magenta

	--------------------------------------------------------------------
	-- FLOOR CHEVRONS: V-arrows pointing toward the sliding door (-Z)
	-- (parented to Workspace like skyline/driving chevrons)
	--------------------------------------------------------------------
	local RunService = game:GetService("RunService")
	local Workspace = game:GetService("Workspace")
	local chevronCount = 8
	local chevronArmLen = 3.0
	local chevronAngle = math.rad(35)
	local chevronColor = Color3.fromRGB(0, 180, 255) -- cyan neon
	local chevronY = baseY + 2
	local chevronStartZ = nearZ - podSpacing * 0.5
	local chevronEndZ = farZ + 4

	local chevronParts = {}
	for i = 1, chevronCount do
		local t = i / (chevronCount + 1)
		local cZ = chevronStartZ - t * (chevronStartZ - chevronEndZ)

		for _, side in ipairs({-1, 1}) do
			local arm = Instance.new("Part")
			arm.Name = "LobbyChevron_" .. i
			arm.Size = Vector3.new(chevronArmLen, 0.4, 0.4)
			arm.CFrame = CFrame.new(side * 1.5, chevronY, cZ)
				* CFrame.Angles(0, -side * chevronAngle, 0)
			arm.Anchored = true
			arm.CanCollide = false
			arm.Material = Enum.Material.Neon
			arm.Color = chevronColor
			arm.Transparency = 0.15
			arm.Parent = Workspace
			table.insert(chevronParts, { part = arm, idx = i })
		end
	end

	-- Staggered pulse animation (flowing toward exit door, same as driving lanes)
	RunService.Heartbeat:Connect(function()
		for _, chev in chevronParts do
			if chev.part and chev.part.Parent then
				local wave = math.sin(tick() * 4 - chev.idx * 1.0)
				chev.part.Transparency = 0.1 + 0.7 * math.clamp((1 - wave) / 2, 0, 1)
			end
		end
	end)

	--------------------------------------------------------------------
	-- PROXIMITY TRIGGER: invisible zone in front of the door
	-- Opens the sliding door when a player walks into it
	--------------------------------------------------------------------
	local TRIGGER_DEPTH = 20  -- how far from door the trigger extends
	local triggerPart = Instance.new("Part")
	triggerPart.Name = "DoorTrigger"
	triggerPart.Size = Vector3.new(HALL_WIDTH * 0.6, 8, TRIGGER_DEPTH)
	triggerPart.CFrame = CFrame.new(0, baseY + 4, farZ + TRIGGER_DEPTH / 2 + 2)
	triggerPart.Anchored = true
	triggerPart.CanCollide = false
	triggerPart.Transparency = 1
	triggerPart.Parent = model

	local doorOpened = false
	triggerPart.Touched:Connect(function(hit)
		if doorOpened then return end
		local character = hit.Parent
		if not character then return end
		local player = Players:GetPlayerFromCharacter(character)
		if not player then return end
		doorOpened = true
		LobbyHall.openDoor(model)
	end)

	--------------------------------------------------------------------
	-- DONE
	--------------------------------------------------------------------
	model.Parent = decorFolder

	return model
end

--- Open the sliding door (each half is a Model of parts)
function LobbyHall.openDoor(lobbyModel)
	if not lobbyModel then return end

	local leftPanel = lobbyModel:FindFirstChild("DoorPanelLeft")
	local rightPanel = lobbyModel:FindFirstChild("DoorPanelRight")
	if not leftPanel or not rightPanel then return end

	local slideDistance = HALL_WIDTH / 2
	local slideVec = Vector3.new(slideDistance, 0, 0)
	local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

	-- Slide every part in each door half
	for _, part in leftPanel:GetChildren() do
		if part:IsA("BasePart") then
			TweenService:Create(part, tweenInfo, {
				CFrame = part.CFrame + Vector3.new(-slideDistance, 0, 0)
			}):Play()
		end
	end
	for _, part in rightPanel:GetChildren() do
		if part:IsA("BasePart") then
			TweenService:Create(part, tweenInfo, {
				CFrame = part.CFrame + Vector3.new(slideDistance, 0, 0)
			}):Play()
		end
	end

	-- Disable collision after panels start moving
	task.delay(0.5, function()
		for _, part in leftPanel:GetChildren() do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
		for _, part in rightPanel:GetChildren() do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
	end)
end

return LobbyHall
