-- DecorUtils: shared state, constants, and helpers for all decor builders.
local DecorUtils = {}

-- State (set by DecorCreation.init, accessed by all builders)
DecorUtils.decorFolder = nil
DecorUtils.decorTemplates = nil
DecorUtils.activePlatformAnimations = {}

-- Lazy-loaded NPCManager reference
DecorUtils.NPCManager = nil

-- Constants
DecorUtils.PLAYABLE_WIDTH = 80
DecorUtils.TERRAIN_TOP = 4
DecorUtils.BUILDING_BASE = 4
DecorUtils.WINDOW_MARGIN = 1.5

-- Color/material tables
DecorUtils.WALL_COLORS = {
	Color3.fromRGB(200, 190, 170),  -- sandstone
	Color3.fromRGB(180, 170, 155),  -- warm grey
	Color3.fromRGB(165, 120, 90),   -- brown brick
	Color3.fromRGB(210, 200, 185),  -- cream
	Color3.fromRGB(155, 145, 135),  -- cool grey
	Color3.fromRGB(190, 140, 100),  -- tan
	Color3.fromRGB(220, 215, 205),  -- off-white
	Color3.fromRGB(145, 100, 80),   -- red brick
}

DecorUtils.WINDOW_COLORS = {
	Color3.fromRGB(255, 220, 140),  -- warm yellow
	Color3.fromRGB(200, 230, 255),  -- cool white
	Color3.fromRGB(255, 200, 100),  -- amber
	Color3.fromRGB(180, 210, 255),  -- pale blue
	Color3.fromRGB(255, 180, 120),  -- soft orange
}

DecorUtils.SIGN_COLORS = {
	Color3.fromRGB(255, 50, 80),    -- red
	Color3.fromRGB(50, 200, 255),   -- cyan
	Color3.fromRGB(255, 100, 200),  -- pink
	Color3.fromRGB(50, 180, 50),    -- green (darker to read text)
	Color3.fromRGB(255, 200, 50),   -- gold
}

DecorUtils.SIGN_FONTS = {
	Enum.Font.GothamBold,
	Enum.Font.FredokaOne,
	Enum.Font.Bangers,
	Enum.Font.LuckiestGuy,
	Enum.Font.PermanentMarker,
	Enum.Font.PatrickHand,
	Enum.Font.Oswald,
}

DecorUtils.WALL_MATERIALS = {
	Enum.Material.Concrete,
	Enum.Material.Brick,
	Enum.Material.SmoothPlastic,
	Enum.Material.Slate,
}

-- Helper functions
function DecorUtils.pickRandom(t)
	return t[math.random(1, #t)]
end

function DecorUtils.getFrontX(x, bDepth)
	local sign = x > 0 and 1 or -1
	return x - sign * (bDepth / 2 + 0.2)
end

function DecorUtils.addWindowsToFace(building, axis, faceCoord, center, faceWidth, baseY, floors, floorHeight, winW, winH, winGap, litColor, litChance)
	local available = faceWidth - 2 * DecorUtils.WINDOW_MARGIN
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

-- Lazy-load NPCManager
function DecorUtils.ensureNPCManager(scriptParent)
	if not DecorUtils.NPCManager then
		local ok, mod = pcall(function()
			return require(scriptParent:WaitForChild("NPCManager"))
		end)
		if ok and mod then
			DecorUtils.NPCManager = mod
		end
	end
	return DecorUtils.NPCManager
end

return DecorUtils
