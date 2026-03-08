local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local Fences = {}

local FENCE_RUST_COLORS = {
	Color3.fromRGB(140, 80, 45),
	Color3.fromRGB(120, 65, 35),
	Color3.fromRGB(105, 60, 40),
	Color3.fromRGB(130, 75, 50),
	Color3.fromRGB(95, 55, 35),
}
local FENCE_FRAME_COLOR = Color3.fromRGB(90, 55, 40)
local FENCE_BAR_SPACING = 2.5  -- studs between grid bars
local CROSS_SPACING = 4  -- spacing between each X cell along the panel

-- Build one grid panel between two points (a -> b)
-- atan2(dx,dz) aligns local +Z with the panel direction, so all lengths go on Z axis
local function buildGridPanel(parent, ax, az, bx, bz, height, baseY)
	local mx = (ax + bx) / 2
	local mz = (az + bz) / 2
	local dx = bx - ax
	local dz = bz - az
	local len = math.sqrt(dx * dx + dz * dz)
	local angle = math.atan2(dx, dz)
	local panelCF = CFrame.new(mx, 0, mz) * CFrame.Angles(0, angle, 0)

	-- Frame: top bar (length along local Z)
	local topBar = Instance.new("Part")
	topBar.Name = "FenceFrameTop"
	topBar.Size = Vector3.new(0.5, 0.5, len)
	topBar.CFrame = panelCF * CFrame.new(0, baseY + height, 0)
	topBar.Anchored = true
	topBar.Material = Enum.Material.CorrodedMetal
	topBar.Color = FENCE_FRAME_COLOR
	topBar.Parent = parent

	-- Frame: bottom bar
	local botBar = Instance.new("Part")
	botBar.Name = "FenceFrameBot"
	botBar.Size = Vector3.new(0.5, 0.5, len)
	botBar.CFrame = panelCF * CFrame.new(0, baseY + 0.5, 0)
	botBar.Anchored = true
	botBar.Material = Enum.Material.CorrodedMetal
	botBar.Color = FENCE_FRAME_COLOR
	botBar.Parent = parent

	-- Vertical grid bars (spaced along local Z)
	local gridH = height - 1
	local numV = math.floor(len / FENCE_BAR_SPACING)
	local startOffset = -len / 2 + FENCE_BAR_SPACING / 2
	for i = 0, numV - 1 do
		local bar = Instance.new("Part")
		bar.Name = "FenceBarV"
		bar.Size = Vector3.new(0.15, gridH, 0.15)
		bar.CFrame = panelCF * CFrame.new(0, baseY + height / 2 + 0.25, startOffset + i * FENCE_BAR_SPACING)
		bar.Anchored = true
		bar.Material = Enum.Material.CorrodedMetal
		bar.Color = FENCE_RUST_COLORS[math.random(#FENCE_RUST_COLORS)]
		bar.Parent = parent
	end

	-- Horizontal grid bars (length along local Z, stacked along Y)
	local numH = math.floor(gridH / FENCE_BAR_SPACING)
	local hStart = baseY + 1.2
	for i = 0, numH - 1 do
		local bar = Instance.new("Part")
		bar.Name = "FenceBarH"
		bar.Size = Vector3.new(0.15, 0.15, len - 0.4)
		bar.CFrame = panelCF * CFrame.new(0, hStart + i * FENCE_BAR_SPACING, 0)
		bar.Anchored = true
		bar.Material = Enum.Material.CorrodedMetal
		bar.Color = FENCE_RUST_COLORS[math.random(#FENCE_RUST_COLORS)]
		bar.Parent = parent
	end
end

-- Build one CROSS/diamond grid panel between two points (a -> b)
-- Diagonal bars in X pattern instead of horizontal+vertical
local function buildCrossGridPanel(parent, ax, az, bx, bz, height, baseY)
	local mx = (ax + bx) / 2
	local mz = (az + bz) / 2
	local dx = bx - ax
	local dz = bz - az
	local len = math.sqrt(dx * dx + dz * dz)
	local angle = math.atan2(dx, dz)
	local panelCF = CFrame.new(mx, 0, mz) * CFrame.Angles(0, angle, 0)

	-- Frame: top bar
	local topBar = Instance.new("Part")
	topBar.Name = "FenceFrameTop"
	topBar.Size = Vector3.new(0.5, 0.5, len)
	topBar.CFrame = panelCF * CFrame.new(0, baseY + height, 0)
	topBar.Anchored = true
	topBar.Material = Enum.Material.CorrodedMetal
	topBar.Color = FENCE_FRAME_COLOR
	topBar.Parent = parent

	-- Frame: bottom bar
	local botBar = Instance.new("Part")
	botBar.Name = "FenceFrameBot"
	botBar.Size = Vector3.new(0.5, 0.5, len)
	botBar.CFrame = panelCF * CFrame.new(0, baseY + 0.5, 0)
	botBar.Anchored = true
	botBar.Material = Enum.Material.CorrodedMetal
	botBar.Color = FENCE_FRAME_COLOR
	botBar.Parent = parent

	-- Diagonal cross bars: each cell is CROSS_SPACING wide, height tall
	-- Two bars per cell forming an X
	local gridH = height - 1
	local cellW = CROSS_SPACING
	local numCells = math.floor(len / cellW)
	local diagLen = math.sqrt(cellW * cellW + gridH * gridH)
	local diagAngle = math.atan2(gridH, cellW)  -- angle from horizontal
	local startZ = -len / 2 + cellW / 2

	for i = 0, numCells - 1 do
		local cellZ = startZ + i * cellW
		local cellY = baseY + height / 2 + 0.25
		local rustColor = FENCE_RUST_COLORS[math.random(#FENCE_RUST_COLORS)]

		-- Bar going bottom-left to top-right ( / )
		local bar1 = Instance.new("Part")
		bar1.Name = "FenceBarCross"
		bar1.Size = Vector3.new(0.15, 0.15, diagLen)
		bar1.CFrame = panelCF * CFrame.new(0, cellY, cellZ) * CFrame.Angles(diagAngle, 0, 0)
		bar1.Anchored = true
		bar1.Material = Enum.Material.CorrodedMetal
		bar1.Color = rustColor
		bar1.Parent = parent

		-- Bar going top-left to bottom-right ( \ )
		local bar2 = Instance.new("Part")
		bar2.Name = "FenceBarCross"
		bar2.Size = Vector3.new(0.15, 0.15, diagLen)
		bar2.CFrame = panelCF * CFrame.new(0, cellY, cellZ) * CFrame.Angles(-diagAngle, 0, 0)
		bar2.Anchored = true
		bar2.Material = Enum.Material.CorrodedMetal
		bar2.Color = rustColor
		bar2.Parent = parent
	end
end

-- Build a cross-grid enclosed fence from 4 corner positions
function Fences.createCrossGridFence(parent, corners, height)
	height = height or 10
	local baseY = DecorUtils.TERRAIN_TOP

	-- Corner posts
	for _, c in ipairs(corners) do
		local post = Instance.new("Part")
		post.Name = "FenceCornerPost"
		post.Size = Vector3.new(0.8, height + 0.5, 0.8)
		post.Position = Vector3.new(c.x, baseY + height / 2, c.z)
		post.Anchored = true
		post.Material = Enum.Material.CorrodedMetal
		post.Color = Color3.fromRGB(80, 50, 35)
		post.Parent = parent
	end

	-- Cross grid panels between each pair of corners (closed loop)
	for i = 1, #corners do
		local a = corners[i]
		local b = corners[i % #corners + 1]
		buildCrossGridPanel(parent, a.x, a.z, b.x, b.z, height, baseY)
	end
end

-- Build a full enclosed grid fence from 4 corner positions {x, z}
-- corners: { topLeft, topRight, bottomRight, bottomLeft } (closed rectangle)
function Fences.createGridFence(parent, corners, height)
	height = height or 10
	local baseY = DecorUtils.TERRAIN_TOP

	-- Corner posts (thick structural bars at each corner)
	for _, c in ipairs(corners) do
		local post = Instance.new("Part")
		post.Name = "FenceCornerPost"
		post.Size = Vector3.new(0.8, height + 0.5, 0.8)
		post.Position = Vector3.new(c.x, baseY + height / 2, c.z)
		post.Anchored = true
		post.Material = Enum.Material.CorrodedMetal
		post.Color = Color3.fromRGB(80, 50, 35)
		post.Parent = parent
	end

	-- Grid panels between each pair of corners (closed loop)
	for i = 1, #corners do
		local a = corners[i]
		local b = corners[i % #corners + 1]
		buildGridPanel(parent, a.x, a.z, b.x, b.z, height, baseY)
	end
end

-- Build a single straight fence line from point A to point B (no closed loop)
function Fences.createFenceLine(parent, x1, z1, x2, z2, height)
	height = height or 10
	local baseY = DecorUtils.TERRAIN_TOP

	-- Posts at each end
	for _, pos in ipairs({{x1, z1}, {x2, z2}}) do
		local post = Instance.new("Part")
		post.Name = "FenceCornerPost"
		post.Size = Vector3.new(0.8, height + 0.5, 0.8)
		post.Position = Vector3.new(pos[1], baseY + height / 2, pos[2])
		post.Anchored = true
		post.Material = Enum.Material.CorrodedMetal
		post.Color = Color3.fromRGB(80, 50, 35)
		post.Parent = parent
	end

	buildCrossGridPanel(parent, x1, z1, x2, z2, height, baseY)
end

return Fences
