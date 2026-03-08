-- PrisonBuilding.luau
-- Brutalist concrete prison cell blocks: heavy walls, barred windows,
-- flat roof with parapet, floodlights, metal doors.
-- Signature: createPrisonBuilding(x, z, scale, offsetY)

local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local PrisonBuilding = {}

local TERRAIN_TOP = DecorUtils.TERRAIN_TOP

-- Colors
local CONCRETE_MAIN  = Color3.fromRGB(135, 130, 125)  -- main walls
local CONCRETE_DARK  = Color3.fromRGB(100, 95, 90)    -- parapet / trim
local CONCRETE_LIGHT = Color3.fromRGB(160, 155, 148)  -- foundation
local WINDOW_RECESS  = Color3.fromRGB(30, 30, 35)     -- dark window holes
local BAR_COLOR      = Color3.fromRGB(70, 70, 75)     -- window bars
local DOOR_COLOR     = Color3.fromRGB(60, 65, 70)     -- heavy metal doors
local FLOOD_COLOR    = Color3.fromRGB(255, 230, 180)  -- floodlight
local ROOF_COLOR     = Color3.fromRGB(90, 88, 85)     -- flat roof surface
local VENT_COLOR     = Color3.fromRGB(110, 108, 105)  -- roof vents/ducts

-- Building variation palettes (slightly different tones)
local WALL_PALETTES = {
	{ main = Color3.fromRGB(135, 130, 125), trim = Color3.fromRGB(100, 95, 90) },
	{ main = Color3.fromRGB(125, 125, 120), trim = Color3.fromRGB(90, 88, 85) },
	{ main = Color3.fromRGB(140, 135, 128), trim = Color3.fromRGB(105, 100, 95) },
}

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
-- BARRED WINDOW (recessed dark slot + vertical bars)
--------------------------------------------------------------------------------

local function buildWindow(parent, cx, cy, cz, winW, winH, faceAxis)
	-- faceAxis: "x" = window faces X direction, "z" = window faces Z direction
	local recess, barSize

	if faceAxis == "z" then
		-- Window on a wall that faces Z
		recess = makePart(parent, "WindowRecess",
			Vector3.new(winW, winH, 0.6),
			CFrame.new(cx, cy, cz),
			WINDOW_RECESS, Enum.Material.SmoothPlastic)

		-- Vertical bars
		local numBars = math.max(2, math.floor(winW / 0.6))
		local barSpacing = winW / (numBars + 1)
		for i = 1, numBars do
			local bx = cx - winW / 2 + i * barSpacing
			makePart(parent, "WindowBar",
				Vector3.new(0.12, winH - 0.2, 0.12),
				CFrame.new(bx, cy, cz + 0.25),
				BAR_COLOR, Enum.Material.Metal)
		end
	else
		-- Window on a wall that faces X
		recess = makePart(parent, "WindowRecess",
			Vector3.new(0.6, winH, winW),
			CFrame.new(cx, cy, cz),
			WINDOW_RECESS, Enum.Material.SmoothPlastic)

		local numBars = math.max(2, math.floor(winW / 0.6))
		local barSpacing = winW / (numBars + 1)
		for i = 1, numBars do
			local bz = cz - winW / 2 + i * barSpacing
			makePart(parent, "WindowBar",
				Vector3.new(0.12, winH - 0.2, 0.12),
				CFrame.new(cx + 0.25, cy, bz),
				BAR_COLOR, Enum.Material.Metal)
		end
	end

	return recess
end

--------------------------------------------------------------------------------
-- MAIN BUILDER
-- x, z = center position; scale adjusts overall size
--------------------------------------------------------------------------------

function PrisonBuilding.createPrisonBuilding(x, z, scale, offsetY)
	local folder = DecorUtils.decorFolder
	if not folder then return nil end

	scale = scale or 1
	offsetY = offsetY or 0
	local baseY = TERRAIN_TOP + offsetY

	local model = Instance.new("Model")
	model.Name = "PrisonBuilding"

	-- Pick a random palette and variation
	local palette = WALL_PALETTES[math.random(#WALL_PALETTES)]
	local wallColor = palette.main
	local trimColor = palette.trim

	-- Random variation: 3 or 4 stories, larger footprint
	local stories = math.random(3, 4)
	local storyH = 6 * scale
	local buildW = (35 + math.random() * 20) * scale   -- 35-55 studs wide (along Z)
	local buildD = (18 + math.random() * 8) * scale    -- 18-26 studs deep (along X)
	local totalH = stories * storyH
	local halfW = buildW / 2
	local halfD = buildD / 2

	---------------------------------------------------------------------------
	-- FOUNDATION (slightly wider concrete slab)
	---------------------------------------------------------------------------
	makePart(model, "Foundation",
		Vector3.new(buildD + 2 * scale, 1 * scale, buildW + 2 * scale),
		CFrame.new(x, baseY + 0.5 * scale, z),
		CONCRETE_LIGHT, Enum.Material.Concrete)

	---------------------------------------------------------------------------
	-- MAIN WALLS
	---------------------------------------------------------------------------
	makePart(model, "MainBlock",
		Vector3.new(buildD, totalH, buildW),
		CFrame.new(x, baseY + 1 * scale + totalH / 2, z),
		wallColor, Enum.Material.Concrete)

	---------------------------------------------------------------------------
	-- PARAPET (raised edge around roof)
	---------------------------------------------------------------------------
	local roofY = baseY + 1 * scale + totalH
	local parapetH = 1.5 * scale

	-- Front and back parapets (along Z)
	for _, sx in ipairs({ -1, 1 }) do
		makePart(model, "Parapet",
			Vector3.new(0.8 * scale, parapetH, buildW + 0.4 * scale),
			CFrame.new(x + sx * (halfD + 0.2 * scale), roofY + parapetH / 2, z),
			trimColor, Enum.Material.Concrete)
	end
	-- Left and right parapets (along X)
	for _, sz in ipairs({ -1, 1 }) do
		makePart(model, "Parapet",
			Vector3.new(buildD + 1.2 * scale, parapetH, 0.8 * scale),
			CFrame.new(x, roofY + parapetH / 2, z + sz * (halfW + 0.2 * scale)),
			trimColor, Enum.Material.Concrete)
	end

	-- Flat roof surface
	makePart(model, "Roof",
		Vector3.new(buildD - 0.5 * scale, 0.3 * scale, buildW - 0.5 * scale),
		CFrame.new(x, roofY + 0.15 * scale, z),
		ROOF_COLOR, Enum.Material.Concrete)

	---------------------------------------------------------------------------
	-- ROOF DETAILS (vents, AC units)
	---------------------------------------------------------------------------
	local numVents = math.random(2, 4)
	for i = 1, numVents do
		local vx = x + (math.random() - 0.5) * (buildD - 4 * scale)
		local vz = z + (math.random() - 0.5) * (buildW - 4 * scale)
		local vSize = (1.5 + math.random() * 1.5) * scale
		makePart(model, "RoofVent",
			Vector3.new(vSize, vSize * 0.8, vSize),
			CFrame.new(vx, roofY + vSize * 0.4, vz),
			VENT_COLOR, Enum.Material.DiamondPlate)
	end

	---------------------------------------------------------------------------
	-- WINDOWS (barred, on both long faces — Z-facing walls)
	---------------------------------------------------------------------------
	local winW = 1.8 * scale
	local winH = 1.4 * scale
	local winSpacing = 4.5 * scale
	local numWins = math.floor(buildW / winSpacing)
	local winStartZ = z - (numWins - 1) * winSpacing / 2

	for story = 1, stories do
		local winY = baseY + 1 * scale + (story - 0.4) * storyH
		for i = 0, numWins - 1 do
			local wz = winStartZ + i * winSpacing
			-- Front face (positive X)
			buildWindow(model, x + halfD + 0.01, winY, wz, winW, winH, "x")
			-- Back face (negative X)
			buildWindow(model, x - halfD - 0.01, winY, wz, winW, winH, "x")
		end
	end

	---------------------------------------------------------------------------
	-- WINDOWS (short faces — X-facing walls, fewer)
	---------------------------------------------------------------------------
	local sideWins = math.max(1, math.floor(buildD / winSpacing) - 1)
	local sideStartX = x - (sideWins - 1) * winSpacing / 2

	for story = 1, stories do
		local winY = baseY + 1 * scale + (story - 0.4) * storyH
		for i = 0, sideWins - 1 do
			local wx = sideStartX + i * winSpacing
			-- Left face (negative Z)
			buildWindow(model, wx, winY, z - halfW - 0.01, winW, winH, "z")
			-- Right face (positive Z)
			buildWindow(model, wx, winY, z + halfW + 0.01, winW, winH, "z")
		end
	end

	---------------------------------------------------------------------------
	-- HEAVY METAL DOORS (one on each long face)
	---------------------------------------------------------------------------
	local doorW = 3 * scale
	local doorH = 4 * scale

	for _, sx in ipairs({ -1, 1 }) do
		local doorX = x + sx * (halfD + 0.05)

		-- Door recess
		makePart(model, "DoorFrame",
			Vector3.new(0.8 * scale, doorH + 0.5 * scale, doorW + 1 * scale),
			CFrame.new(doorX, baseY + 1 * scale + (doorH + 0.5 * scale) / 2, z),
			trimColor, Enum.Material.Concrete)

		-- Door panel
		makePart(model, "Door",
			Vector3.new(0.4 * scale, doorH, doorW),
			CFrame.new(doorX + sx * 0.2, baseY + 1 * scale + doorH / 2, z),
			DOOR_COLOR, Enum.Material.DiamondPlate)
	end

	---------------------------------------------------------------------------
	-- FLOODLIGHTS (on walls, angled down)
	---------------------------------------------------------------------------
	local floodY = roofY - 1 * scale
	local floodPositions = {
		{ x = x + halfD + 0.3, z = z - halfW * 0.5, face = 1 },
		{ x = x + halfD + 0.3, z = z + halfW * 0.5, face = 1 },
		{ x = x - halfD - 0.3, z = z - halfW * 0.5, face = -1 },
		{ x = x - halfD - 0.3, z = z + halfW * 0.5, face = -1 },
	}

	for _, fl in ipairs(floodPositions) do
		local light = makePart(model, "Floodlight",
			Vector3.new(0.8 * scale, 0.5 * scale, 1.2 * scale),
			CFrame.new(fl.x, floodY, fl.z)
				* CFrame.Angles(math.rad(30), 0, 0),
			Color3.fromRGB(60, 60, 65), Enum.Material.Metal)

		local spot = Instance.new("SpotLight")
		spot.Face = Enum.NormalId.Bottom
		spot.Angle = 50
		spot.Range = 25
		spot.Brightness = 2
		spot.Color = FLOOD_COLOR
		spot.Parent = light
	end

	---------------------------------------------------------------------------
	-- HORIZONTAL TRIM LINES (story separators on long faces)
	---------------------------------------------------------------------------
	for story = 1, stories - 1 do
		local trimY = baseY + 1 * scale + story * storyH
		for _, sx in ipairs({ -1, 1 }) do
			makePart(model, "StoryTrim",
				Vector3.new(0.15 * scale, 0.4 * scale, buildW + 0.1 * scale),
				CFrame.new(x + sx * (halfD + 0.05), trimY, z),
				trimColor, Enum.Material.Concrete)
		end
	end

	model.Parent = folder
	return model
end

return PrisonBuilding
