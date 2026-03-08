-- Watchtower decor builder
-- Military zone watchtowers with rotating searchlight beams.
-- Concrete/metal scaffold towers placed on both sides of the lane.

local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local Watchtower = {}

local TERRAIN_TOP = DecorUtils.TERRAIN_TOP
local PLAYABLE_WIDTH = DecorUtils.PLAYABLE_WIDTH

-- Color palette (matching MilitaryWarning)
local POST_DARK    = Color3.fromRGB(60, 62, 65)
local CONCRETE     = Color3.fromRGB(160, 155, 148)
local CABIN_DARK   = Color3.fromRGB(50, 50, 55)
local RAILING_GRAY = Color3.fromRGB(90, 92, 95)
local LIGHT_WHITE  = Color3.fromRGB(255, 250, 230)

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

--------------------------------------------------------------------------------
-- SINGLE TOWER
-- Returns the searchlight head part + beam target for animation registration
--------------------------------------------------------------------------------

local function buildTower(parent, cx, cz, towerHeight, registerAnimation)
	local baseY = TERRAIN_TOP

	-- Concrete foundation slab
	makePart(parent, "Foundation",
		Vector3.new(10, 1, 10),
		CFrame.new(cx, baseY + 0.5, cz),
		CONCRETE, Enum.Material.Concrete)

	-- 4 angled metal legs (scaffolding style)
	local legRadius = 3.5  -- distance from center at base
	local legTopRadius = 1.5  -- distance from center at top
	local legHeight = towerHeight - 2  -- leave room for platform

	for i = 0, 3 do
		local angle = math.rad(45 + i * 90)
		local bx = cx + math.cos(angle) * legRadius
		local bz = cz + math.sin(angle) * legRadius
		local tx = cx + math.cos(angle) * legTopRadius
		local tz = cz + math.sin(angle) * legTopRadius

		local midX = (bx + tx) / 2
		local midZ = (bz + tz) / 2
		local midY = baseY + 1 + legHeight / 2

		local dx = tx - bx
		local dz = tz - bz
		local dy = legHeight
		local length = math.sqrt(dx * dx + dy * dy + dz * dz)

		-- Leg cylinder pointing upward with slight inward lean
		local bottom = Vector3.new(bx, baseY + 1, bz)
		local top = Vector3.new(tx, baseY + 1 + legHeight, tz)
		local mid = (bottom + top) / 2
		local dir = (top - bottom).Unit

		makeCylinder(parent, "Leg",
			Vector3.new(length, 0.6, 0.6),
			CFrame.lookAt(mid, mid + dir)
				* CFrame.Angles(0, math.rad(90), 0),
			POST_DARK, Enum.Material.DiamondPlate)
	end

	-- Cross braces between legs (X pattern on each face)
	local braceYLevels = { 0.3, 0.6 }
	for _, yFrac in ipairs(braceYLevels) do
		local y = baseY + 1 + legHeight * yFrac
		local rAtY = legRadius + (legTopRadius - legRadius) * yFrac

		for i = 0, 3 do
			local a1 = math.rad(45 + i * 90)
			local a2 = math.rad(45 + ((i + 1) % 4) * 90)
			local x1 = cx + math.cos(a1) * rAtY
			local z1 = cz + math.sin(a1) * rAtY
			local x2 = cx + math.cos(a2) * rAtY
			local z2 = cz + math.sin(a2) * rAtY

			local mx = (x1 + x2) / 2
			local mz = (z1 + z2) / 2
			local braceLen = math.sqrt((x2 - x1) ^ 2 + (z2 - z1) ^ 2)
			local braceAngle = math.atan2(z2 - z1, x2 - x1)

			makePart(parent, "Brace",
				Vector3.new(braceLen, 0.3, 0.3),
				CFrame.new(mx, y, mz)
					* CFrame.Angles(0, -braceAngle, 0),
				POST_DARK, Enum.Material.DiamondPlate)
		end
	end

	-- Platform slab at top
	local platY = baseY + 1 + legHeight
	makePart(parent, "Platform",
		Vector3.new(8, 0.6, 8),
		CFrame.new(cx, platY + 0.3, cz),
		CONCRETE, Enum.Material.Concrete)

	-- Railing around platform edge
	local railH = 1.2
	local railY = platY + 0.6 + railH / 2
	local platHalf = 4
	for _, offset in ipairs({
		{ platHalf, 0, 0.15, railH, platHalf * 2 },   -- +X side
		{ -platHalf, 0, 0.15, railH, platHalf * 2 },   -- -X side
		{ 0, platHalf, platHalf * 2, railH, 0.15 },     -- +Z side
		{ 0, -platHalf, platHalf * 2, railH, 0.15 },    -- -Z side
	}) do
		makePart(parent, "Railing",
			Vector3.new(offset[3], offset[4], offset[5]),
			CFrame.new(cx + offset[1], railY, cz + offset[2]),
			RAILING_GRAY, Enum.Material.Metal).Transparency = 0.3
	end

	-- Guard cabin (small box)
	local cabinW, cabinH, cabinD = 5, 4, 5
	local cabinY = platY + 0.6 + cabinH / 2
	makePart(parent, "CabinWall",
		Vector3.new(cabinW, cabinH, cabinD),
		CFrame.new(cx, cabinY, cz),
		CABIN_DARK, Enum.Material.Metal)

	-- Glass windows (slightly inset on two faces)
	for _, face in ipairs({
		{ 0, 0, -(cabinD / 2 - 0.05), cabinW - 1, cabinH - 1, 0.1 },  -- front
		{ 0, 0,  (cabinD / 2 - 0.05), cabinW - 1, cabinH - 1, 0.1 },  -- back
		{ -(cabinW / 2 - 0.05), 0, 0, 0.1, cabinH - 1, cabinD - 1 },  -- left
		{  (cabinW / 2 - 0.05), 0, 0, 0.1, cabinH - 1, cabinD - 1 },  -- right
	}) do
		local win = makePart(parent, "CabinWindow",
			Vector3.new(face[4], face[5], face[6]),
			CFrame.new(cx + face[1], cabinY + 0.3, cz + face[3]),
			Color3.fromRGB(140, 180, 200), Enum.Material.Glass)
		win.Transparency = 0.5
	end

	-- Roof slab (slightly wider)
	local roofY = platY + 0.6 + cabinH
	makePart(parent, "Roof",
		Vector3.new(cabinW + 1.5, 0.4, cabinD + 1.5),
		CFrame.new(cx, roofY + 0.2, cz),
		CABIN_DARK, Enum.Material.Metal)

	-- Searchlight mount (short cylinder on roof)
	local mountY = roofY + 0.4
	makeCylinder(parent, "SearchlightMount",
		Vector3.new(0.8, 1.2, 1.2),
		CFrame.new(cx, mountY + 0.4, cz)
			* CFrame.Angles(0, 0, math.rad(90)),
		POST_DARK, Enum.Material.Metal)

	-- Searchlight head (the part that rotates)
	local headY = mountY + 0.8
	local head = makeCylinder(parent, "SearchlightHead",
		Vector3.new(2.5, 1.0, 1.0),
		CFrame.new(cx, headY, cz)
			* CFrame.Angles(0, 0, math.rad(90)),
		RAILING_GRAY, Enum.Material.Metal)

	-- SpotLight on searchlight head
	local spot = Instance.new("SpotLight")
	spot.Brightness = 4
	spot.Range = 60
	spot.Angle = 35
	spot.Color = LIGHT_WHITE
	spot.Face = Enum.NormalId.Bottom
	spot.Parent = head

	-- PointLight for local glow
	local glow = Instance.new("PointLight")
	glow.Brightness = 2
	glow.Range = 12
	glow.Color = LIGHT_WHITE
	glow.Parent = head

	-- Beam target (invisible part on the ground that the beam points to)
	local beamRange = 30
	local target = Instance.new("Part")
	target.Name = "BeamTarget"
	target.Size = Vector3.new(0.5, 0.5, 0.5)
	target.Position = Vector3.new(cx + beamRange, baseY, cz)
	target.Anchored = true
	target.CanCollide = false
	target.Transparency = 1
	target.Parent = parent

	-- Beam attachments
	local att0 = Instance.new("Attachment")
	att0.Name = "BeamStart"
	att0.Parent = head

	local att1 = Instance.new("Attachment")
	att1.Name = "BeamEnd"
	att1.Parent = target

	-- Visible beam
	local beam = Instance.new("Beam")
	beam.Attachment0 = att0
	beam.Attachment1 = att1
	beam.Color = ColorSequence.new(LIGHT_WHITE)
	beam.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(1, 0.7),
	})
	beam.LightEmission = 1
	beam.LightInfluence = 0
	beam.Width0 = 1.5
	beam.Width1 = 6
	beam.FaceCamera = true
	beam.Parent = head

	-- Register searchlight animation
	if registerAnimation then
		registerAnimation(head, {
			type = "searchlight",
			centerX = cx,
			centerY = headY,
			centerZ = cz,
			angle = math.random() * math.pi * 2,  -- random start angle
			speed = 0.4 + math.random() * 0.2,     -- slight speed variation
			tiltDeg = 30,
			beamTarget = target,
			beamRange = beamRange,
			groundY = baseY,
		})
	end
end

--------------------------------------------------------------------------------
-- MAIN BUILDER
--------------------------------------------------------------------------------

function Watchtower.createWatchtower(x, z, scale)
	local folder = DecorUtils.decorFolder
	if not folder then return nil end

	local model = Instance.new("Model")
	model.Name = "Watchtower"

	local registerAnimation = function(part, data)
		if DecorUtils.activePlatformAnimations then
			DecorUtils.activePlatformAnimations[part] = data
		end
	end

	local half = PLAYABLE_WIDTH / 2
	local towerOffsetX = half + 15  -- outside playable area

	-- 3 towers per side, spaced across lane depth (80 studs)
	local zPositions = { z - 25, z, z + 25 }

	for i, tz in ipairs(zPositions) do
		local height = 18 + math.random() * 4  -- 18-22 studs

		-- Left side tower
		buildTower(model, x - towerOffsetX, tz, height, registerAnimation)

		-- Right side tower
		buildTower(model, x + towerOffsetX, tz, height, registerAnimation)
	end

	model.Parent = folder
	return model
end

-- Single tower at exact (x, z) — for use with sideDecor system
function Watchtower.createSingleTower(x, z, scale)
	local folder = DecorUtils.decorFolder
	if not folder then return nil end

	local model = Instance.new("Model")
	model.Name = "Watchtower"

	local registerAnimation = function(part, data)
		if DecorUtils.activePlatformAnimations then
			DecorUtils.activePlatformAnimations[part] = data
		end
	end

	local height = 18 + math.random() * 4
	buildTower(model, x, z, height, registerAnimation)

	model.Parent = folder
	return model
end

return Watchtower
