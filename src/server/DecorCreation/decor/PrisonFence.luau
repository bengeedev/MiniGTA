-- PrisonFence.luau
-- Maximum-security prison fencing: tall concrete posts, chain-link mesh panels,
-- razor wire coils on top. Plus a sliding gate entrance with animated panels.

local TweenService = game:GetService("TweenService")
local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local PrisonFence = {}

local TERRAIN_TOP = DecorUtils.TERRAIN_TOP

-- Colors
local CONCRETE_DARK  = Color3.fromRGB(120, 115, 110)  -- dark concrete posts
local CONCRETE_LIGHT = Color3.fromRGB(155, 150, 145)  -- lighter concrete base
local MESH_GRAY      = Color3.fromRGB(140, 140, 145)  -- chain-link mesh
local GATE_METAL     = Color3.fromRGB(80, 80, 85)     -- gate panels
local STRIPE_YELLOW  = Color3.fromRGB(200, 180, 30)   -- warning stripe
local STRIPE_RED     = Color3.fromRGB(180, 40, 30)    -- danger stripe
local LIGHT_WARM     = Color3.fromRGB(255, 200, 120)  -- security light

-- Dimensions
local FENCE_HEIGHT = 14         -- tall max-security fence
local POST_WIDTH = 1.2          -- thick concrete posts
local MESH_TRANSPARENCY = 0.4   -- see-through chain link
local SECTION_LENGTH = 20       -- studs between posts

--------------------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------------------

local function makePart(parent, name, size, cf, color, material)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.Concrete
	p.Anchored = true
	p.CanCollide = false
	p.Parent = parent
	return p
end

--------------------------------------------------------------------------------
-- SINGLE FENCE SECTION (one post + mesh panel to next post)
-- Builds along Z axis from z1 to z2 at fixed X
--------------------------------------------------------------------------------

local function buildFencePost(parent, x, z, height)
	local baseY = TERRAIN_TOP

	-- Concrete post
	makePart(parent, "FencePost",
		Vector3.new(POST_WIDTH, height, POST_WIDTH),
		CFrame.new(x, baseY + height / 2, z),
		CONCRETE_DARK, Enum.Material.Concrete)

	-- Post cap
	makePart(parent, "PostCap",
		Vector3.new(POST_WIDTH + 0.3, 0.3, POST_WIDTH + 0.3),
		CFrame.new(x, baseY + height + 0.15, z),
		CONCRETE_LIGHT, Enum.Material.Concrete)
end

local function buildMeshPanel(parent, x, z1, z2, height)
	local baseY = TERRAIN_TOP
	local panelLen = math.abs(z2 - z1)
	local midZ = (z1 + z2) / 2
	local meshH = height - 1.5  -- below razor wire zone

	-- Chain-link mesh (semi-transparent gray panel)
	local mesh = makePart(parent, "ChainLink",
		Vector3.new(0.15, meshH, panelLen - POST_WIDTH),
		CFrame.new(x, baseY + 0.5 + meshH / 2, midZ),
		MESH_GRAY, Enum.Material.DiamondPlate)
	mesh.Transparency = MESH_TRANSPARENCY

	-- Horizontal support bars (top and mid)
	for _, yFrac in ipairs({ 0.5, 1.0 }) do
		makePart(parent, "SupportBar",
			Vector3.new(0.2, 0.2, panelLen - POST_WIDTH),
			CFrame.new(x, baseY + meshH * yFrac + 0.5, midZ),
			MESH_GRAY, Enum.Material.Metal)
	end

	-- Bottom concrete base strip
	makePart(parent, "FenceBase",
		Vector3.new(1.0, 0.5, panelLen),
		CFrame.new(x, baseY + 0.25, midZ),
		CONCRETE_LIGHT, Enum.Material.Concrete)
end

--------------------------------------------------------------------------------
-- PUBLIC: createFenceRun(x, zStart, zEnd)
-- Builds a continuous fence run along one side of the road
-- x = fixed X position, zStart/zEnd = Z range (zStart > zEnd, going into lane)
--------------------------------------------------------------------------------

function PrisonFence.createFenceRun(x, zStart, zEnd)
	local folder = DecorUtils.decorFolder
	if not folder then return nil end

	local model = Instance.new("Model")
	model.Name = "PrisonFence"

	local z = zStart
	while z > zEnd do
		local nextZ = math.max(z - SECTION_LENGTH, zEnd)

		-- Post at this position
		buildFencePost(model, x, z, FENCE_HEIGHT)

		-- Mesh panel to next post
		if z ~= nextZ then
			buildMeshPanel(model, x, z, nextZ, FENCE_HEIGHT)
		end

		z = nextZ
	end

	-- Final post at the end
	buildFencePost(model, x, zEnd, FENCE_HEIGHT)

	model.Parent = folder
	return model
end

--------------------------------------------------------------------------------
-- PUBLIC: createGate(zPos, roadWidth)
-- Builds a sliding gate at the entrance of the prison zone.
-- Two panels slide outward to open. Returns the gate model + panels for animation.
-- roadWidth = width of the road opening
--------------------------------------------------------------------------------

function PrisonFence.createGate(zPos, roadWidth)
	local folder = DecorUtils.decorFolder
	if not folder then return nil end

	local model = Instance.new("Model")
	model.Name = "PrisonGate"

	local baseY = TERRAIN_TOP
	local halfRoad = roadWidth / 2
	local gateH = FENCE_HEIGHT + 2  -- gate is taller than fence
	local pillarW = 2.5
	local panelW = halfRoad  -- each panel covers half the road

	-- Heavy concrete gatehouse pillars (left and right)
	for _, sx in ipairs({ -1, 1 }) do
		local px = sx * (halfRoad + pillarW / 2)

		-- Main pillar
		makePart(model, "GatePillar",
			Vector3.new(pillarW, gateH, pillarW + 1),
			CFrame.new(px, baseY + gateH / 2, zPos),
			CONCRETE_DARK, Enum.Material.Concrete)

		-- Pillar cap
		makePart(model, "PillarCap",
			Vector3.new(pillarW + 0.6, 0.5, pillarW + 1.6),
			CFrame.new(px, baseY + gateH + 0.25, zPos),
			CONCRETE_LIGHT, Enum.Material.Concrete)

		-- Security light on top of pillar
		local lightPart = makePart(model, "SecurityLight",
			Vector3.new(0.6, 0.6, 0.6),
			CFrame.new(px, baseY + gateH + 0.8, zPos),
			LIGHT_WARM, Enum.Material.Neon)
		lightPart.Shape = Enum.PartType.Ball

		local pl = Instance.new("PointLight")
		pl.Color = LIGHT_WARM
		pl.Brightness = 2
		pl.Range = 18
		pl.Parent = lightPart

		-- Warning stripes on pillar face (facing road)
		local stripeH = 1.2
		for j = 0, 3 do
			local stripeY = baseY + 2 + j * (stripeH + 0.8)
			makePart(model, "WarningStripe",
				Vector3.new(pillarW + 0.05, stripeH, 0.15),
				CFrame.new(px, stripeY, zPos + (pillarW / 2 + 0.5) + 0.08),
				j % 2 == 0 and STRIPE_YELLOW or STRIPE_RED, Enum.Material.SmoothPlastic)
		end
	end

	-- Top crossbar connecting the two pillars (gate frame overhead)
	makePart(model, "GateCrossbar",
		Vector3.new(roadWidth + pillarW * 2 + 1, 1.2, 1.5),
		CFrame.new(0, baseY + gateH + 0.6, zPos),
		GATE_METAL, Enum.Material.Metal)

	-- "FEDERAL STATE PRISON" sign on crossbar
	local signPart = makePart(model, "GateSign",
		Vector3.new(roadWidth * 0.8, 2, 0.3),
		CFrame.new(0, baseY + gateH + 2.2, zPos + 1),
		GATE_METAL, Enum.Material.Metal)

	local signGui = Instance.new("SurfaceGui")
	signGui.Face = Enum.NormalId.Front
	signGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	signGui.PixelsPerStud = 40
	signGui.Parent = signPart

	local signLabel = Instance.new("TextLabel")
	signLabel.Size = UDim2.new(1, 0, 1, 0)
	signLabel.BackgroundTransparency = 1
	signLabel.Text = "FEDERAL STATE PRISON"
	signLabel.TextColor3 = Color3.fromRGB(255, 60, 40)
	signLabel.TextScaled = true
	signLabel.Font = Enum.Font.GothamBold
	signLabel.Parent = signGui

	-- Sliding gate panels (two halves that slide outward)
	local panelH = gateH - 2
	local leftPanel = makePart(model, "GatePanelLeft",
		Vector3.new(panelW, panelH, 0.5),
		CFrame.new(-panelW / 2, baseY + panelH / 2 + 0.5, zPos),
		GATE_METAL, Enum.Material.DiamondPlate)

	local rightPanel = makePart(model, "GatePanelRight",
		Vector3.new(panelW, panelH, 0.5),
		CFrame.new(panelW / 2, baseY + panelH / 2 + 0.5, zPos),
		GATE_METAL, Enum.Material.DiamondPlate)

	-- Horizontal bars on gate panels (tracked for animation)
	local leftBars = {}
	local rightBars = {}
	for _, info in ipairs({ { leftPanel, leftBars }, { rightPanel, rightBars } }) do
		local panel, barList = info[1], info[2]
		local px = panel.Position.X
		for j = 1, 4 do
			local barY = baseY + 1 + j * (panelH / 5)
			local bar = makePart(model, "GateBar",
				Vector3.new(panelW - 0.5, 0.3, 0.6),
				CFrame.new(px, barY, zPos),
				MESH_GRAY, Enum.Material.Metal)
			table.insert(barList, bar)
		end
	end

	-- Side fence walls at entrance (running along X from gate pillars outward)
	local WALL_EXTENT = 80  -- how far the wall extends on each side
	local pillarEdge = halfRoad + pillarW  -- outer edge of gate pillar
	local wallPostSpacing = SECTION_LENGTH

	for _, sx in ipairs({ -1, 1 }) do
		local startX = sx * pillarEdge
		local endX = sx * (pillarEdge + WALL_EXTENT)
		local stepX = sx * wallPostSpacing  -- step in correct direction

		local x = startX
		while (sx == -1 and x > endX) or (sx == 1 and x < endX) do
			local nextX
			if sx == -1 then
				nextX = math.max(x - wallPostSpacing, endX)
			else
				nextX = math.min(x + wallPostSpacing, endX)
			end

			-- Post
			buildFencePost(model, x, zPos, FENCE_HEIGHT)

			-- Mesh panel between this post and the next
			local panelLen = math.abs(nextX - x)
			local midX = (x + nextX) / 2
			local meshH = FENCE_HEIGHT - 1.5

			-- Chain-link mesh (rotated to run along X)
			local mesh = makePart(model, "ChainLink",
				Vector3.new(panelLen - POST_WIDTH, meshH, 0.15),
				CFrame.new(midX, baseY + 0.5 + meshH / 2, zPos),
				MESH_GRAY, Enum.Material.DiamondPlate)
			mesh.Transparency = MESH_TRANSPARENCY

			-- Support bars
			for _, yFrac in ipairs({ 0.5, 1.0 }) do
				makePart(model, "SupportBar",
					Vector3.new(panelLen - POST_WIDTH, 0.2, 0.2),
					CFrame.new(midX, baseY + meshH * yFrac + 0.5, zPos),
					MESH_GRAY, Enum.Material.Metal)
			end

			-- Concrete base
			makePart(model, "FenceBase",
				Vector3.new(panelLen, 0.5, 1.0),
				CFrame.new(midX, baseY + 0.25, zPos),
				CONCRETE_LIGHT, Enum.Material.Concrete)

			x = nextX
		end
		-- Final post at wall end
		buildFencePost(model, endX, zPos, FENCE_HEIGHT)
	end

	model.Parent = folder

	-- Animate gate open after a short delay (panels + bars slide into pillars)
	task.delay(1.5, function()
		local openDist = halfRoad + pillarW  -- slide panels behind pillars
		local tweenInfo = TweenInfo.new(2.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

		-- Panels
		TweenService:Create(leftPanel, tweenInfo, { CFrame = CFrame.new(
			-panelW / 2 - openDist, baseY + panelH / 2 + 0.5, zPos) }):Play()
		TweenService:Create(rightPanel, tweenInfo, { CFrame = CFrame.new(
			panelW / 2 + openDist, baseY + panelH / 2 + 0.5, zPos) }):Play()

		-- Bars follow their panel
		for _, bar in ipairs(leftBars) do
			local pos = bar.Position
			TweenService:Create(bar, tweenInfo, { CFrame = CFrame.new(
				pos.X - openDist, pos.Y, pos.Z) }):Play()
		end
		for _, bar in ipairs(rightBars) do
			local pos = bar.Position
			TweenService:Create(bar, tweenInfo, { CFrame = CFrame.new(
				pos.X + openDist, pos.Y, pos.Z) }):Play()
		end
	end)

	return model
end

return PrisonFence
