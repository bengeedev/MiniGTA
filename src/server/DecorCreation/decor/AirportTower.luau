local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local AirportTower = {}

function AirportTower.createAirportTower(x, z, scale)
	local decorFolder = DecorUtils.decorFolder
	if not decorFolder then return nil end
	scale = scale or 1
	local BUILDING_BASE = DecorUtils.BUILDING_BASE

	local building = Instance.new("Model")
	building.Name = "AirportTower"

	local s = scale
	local DARK_METAL = Color3.fromRGB(45, 48, 52)
	local LIGHT_METAL = Color3.fromRGB(140, 145, 150)

	-- == METAL LATTICE TOWER (open steel structure) ==
	local SHAFT_H = 45 * s
	local SHAFT_R = 6 * s        -- radius (distance from center to leg)
	local shaftBaseY = BUILDING_BASE
	local STEEL = Color3.fromRGB(90, 95, 100)
	local STEEL_DARK = Color3.fromRGB(60, 63, 68)
	local LEG_THICK = 0.8 * s
	local BRACE_THICK = 0.4 * s

	-- 4 main vertical legs at corners
	local legPositions = {
		{x + SHAFT_R, z + SHAFT_R},
		{x + SHAFT_R, z - SHAFT_R},
		{x - SHAFT_R, z + SHAFT_R},
		{x - SHAFT_R, z - SHAFT_R},
	}

	for _, pos in ipairs(legPositions) do
		local leg = Instance.new("Part")
		leg.Size = Vector3.new(LEG_THICK, SHAFT_H, LEG_THICK)
		leg.Position = Vector3.new(pos[1], shaftBaseY + SHAFT_H / 2, pos[2])
		leg.Anchored = true
		leg.Material = Enum.Material.DiamondPlate
		leg.Color = STEEL
		leg.Parent = building
	end

	-- Horizontal rings at intervals
	local NUM_RINGS = 4
	for ring = 0, NUM_RINGS do
		local ringY = shaftBaseY + ring * (SHAFT_H / NUM_RINGS)
		-- 4 horizontal beams forming a square frame
		for _, beam in ipairs({
			{Vector3.new(SHAFT_R * 2 + LEG_THICK, BRACE_THICK, BRACE_THICK), CFrame.new(x, ringY, z + SHAFT_R)},
			{Vector3.new(SHAFT_R * 2 + LEG_THICK, BRACE_THICK, BRACE_THICK), CFrame.new(x, ringY, z - SHAFT_R)},
			{Vector3.new(BRACE_THICK, BRACE_THICK, SHAFT_R * 2 + LEG_THICK), CFrame.new(x + SHAFT_R, ringY, z)},
			{Vector3.new(BRACE_THICK, BRACE_THICK, SHAFT_R * 2 + LEG_THICK), CFrame.new(x - SHAFT_R, ringY, z)},
		}) do
			local h = Instance.new("Part")
			h.Size = beam[1]
			h.CFrame = beam[2]
			h.Anchored = true
			h.Material = Enum.Material.Metal
			h.Color = STEEL_DARK
			h.Parent = building
		end
	end

	-- Diagonal cross-braces on each face (X pattern between rings)
	local sectionH = SHAFT_H / NUM_RINGS
	for section = 0, NUM_RINGS - 1 do
		local baseY = shaftBaseY + section * sectionH
		local midY = baseY + sectionH / 2
		local braceLen = math.sqrt(sectionH * sectionH + (SHAFT_R * 2) * (SHAFT_R * 2))
		local braceAngle = math.atan2(sectionH, SHAFT_R * 2)

		-- Braces on X-facing sides (along Z)
		for _, sx in ipairs({SHAFT_R, -SHAFT_R}) do
			-- Brace going /
			local b1 = Instance.new("Part")
			b1.Size = Vector3.new(BRACE_THICK * 0.7, braceLen, BRACE_THICK * 0.7)
			b1.CFrame = CFrame.new(x + sx, midY, z) * CFrame.Angles(0, 0, braceAngle)
			b1.Anchored = true
			b1.CanCollide = false
			b1.Material = Enum.Material.Metal
			b1.Color = STEEL
			b1.Parent = building

			-- Brace going \
			local b2 = Instance.new("Part")
			b2.Size = Vector3.new(BRACE_THICK * 0.7, braceLen, BRACE_THICK * 0.7)
			b2.CFrame = CFrame.new(x + sx, midY, z) * CFrame.Angles(0, 0, -braceAngle)
			b2.Anchored = true
			b2.CanCollide = false
			b2.Material = Enum.Material.Metal
			b2.Color = STEEL
			b2.Parent = building
		end

		-- Braces on Z-facing sides (along X)
		for _, sz in ipairs({SHAFT_R, -SHAFT_R}) do
			local b1 = Instance.new("Part")
			b1.Size = Vector3.new(BRACE_THICK * 0.7, braceLen, BRACE_THICK * 0.7)
			b1.CFrame = CFrame.new(x, midY, z + sz) * CFrame.Angles(braceAngle, 0, 0)
			b1.Anchored = true
			b1.CanCollide = false
			b1.Material = Enum.Material.Metal
			b1.Color = STEEL
			b1.Parent = building

			local b2 = Instance.new("Part")
			b2.Size = Vector3.new(BRACE_THICK * 0.7, braceLen, BRACE_THICK * 0.7)
			b2.CFrame = CFrame.new(x, midY, z + sz) * CFrame.Angles(-braceAngle, 0, 0)
			b2.Anchored = true
			b2.CanCollide = false
			b2.Material = Enum.Material.Metal
			b2.Color = STEEL
			b2.Parent = building
		end
	end

	-- Light blocks on alternating faces (LAX style, mounted on the structure)
	local PANEL_COLOR = Color3.fromRGB(200, 225, 255)
	local panelDist = SHAFT_R + 0.3 * s
	local lightY = shaftBaseY + SHAFT_H * 0.6
	for face = 0, 3 do
		local angle = math.rad(face * 90 + 45)
		local px = x + math.cos(angle) * panelDist
		local pz = z + math.sin(angle) * panelDist

		local panel = Instance.new("Part")
		panel.Size = Vector3.new(3 * s, 4 * s, 0.3 * s)
		panel.CFrame = CFrame.new(px, lightY, pz) * CFrame.Angles(0, -angle + math.rad(90), 0)
		panel.Anchored = true
		panel.CanCollide = false
		panel.Material = Enum.Material.Neon
		panel.Color = PANEL_COLOR
		panel.Parent = building

		local glow = Instance.new("PointLight")
		glow.Color = PANEL_COLOR
		glow.Brightness = 0.6
		glow.Range = 15
		glow.Parent = panel
	end

	-- Transition platform (wider slab where structure meets cab)
	local ringY = shaftBaseY + SHAFT_H
	local ringSize = SHAFT_R * 2.5
	local ring1 = Instance.new("Part")
	ring1.Size = Vector3.new(ringSize, 1.2 * s, ringSize)
	ring1.CFrame = CFrame.new(x, ringY + 0.6 * s, z)
	ring1.Anchored = true
	ring1.Material = Enum.Material.DiamondPlate
	ring1.Color = STEEL_DARK
	ring1.Parent = building

	local ring2 = Instance.new("Part")
	ring2.Size = Vector3.new(ringSize, 1.2 * s, ringSize)
	ring2.CFrame = CFrame.new(x, ringY + 0.6 * s, z) * CFrame.Angles(0, math.rad(45), 0)
	ring2.Anchored = true
	ring2.Material = Enum.Material.DiamondPlate
	ring2.Color = STEEL_DARK
	ring2.Parent = building

	local cabBaseY = ringY + 1.2 * s

	-- == CONTROL CENTER CAB ==
	local CAB_W = 16 * s     -- width (Z axis)
	local CAB_D = 16 * s     -- depth (X axis)
	local CAB_H = 10 * s     -- glass wall height (tall enough for characters)
	local FRAME = 0.4 * s    -- metal frame thickness
	local GLASS_COLOR = Color3.fromRGB(60, 85, 110)
	local GLASS_TINT = Color3.fromRGB(40, 55, 70) -- darker lower band

	-- Floor slab (wider than cab, visible overhang)
	local FLOOR_OVERHANG = 2.5 * s
	local floorW = CAB_W + FLOOR_OVERHANG * 2
	local floorD = CAB_D + FLOOR_OVERHANG * 2
	local floorSlab = Instance.new("Part")
	floorSlab.Size = Vector3.new(floorD, 0.6 * s, floorW)
	floorSlab.Position = Vector3.new(x, cabBaseY + 0.3 * s, z)
	floorSlab.Anchored = true
	floorSlab.Material = Enum.Material.DiamondPlate
	floorSlab.Color = DARK_METAL
	floorSlab.Parent = building

	-- Catwalk railing posts around the overhang
	local RAIL_H = 3.5 * s
	local railY = cabBaseY + 0.6 * s + RAIL_H / 2
	local postSize = Vector3.new(0.3 * s, RAIL_H, 0.3 * s)
	local railColor = Color3.fromRGB(80, 82, 86)
	local postPositions = {}
	local halfD = floorD / 2 - 0.15 * s
	local halfW = floorW / 2 - 0.15 * s
	-- Posts along each edge
	for i = -1, 1 do
		table.insert(postPositions, {x + halfD, z + i * (halfW * 0.7)})
		table.insert(postPositions, {x - halfD, z + i * (halfW * 0.7)})
		table.insert(postPositions, {x + i * (halfD * 0.7), z + halfW})
		table.insert(postPositions, {x + i * (halfD * 0.7), z - halfW})
	end
	-- Corner posts
	table.insert(postPositions, {x + halfD, z + halfW})
	table.insert(postPositions, {x + halfD, z - halfW})
	table.insert(postPositions, {x - halfD, z + halfW})
	table.insert(postPositions, {x - halfD, z - halfW})

	for _, pos in ipairs(postPositions) do
		local post = Instance.new("Part")
		post.Size = postSize
		post.Position = Vector3.new(pos[1], railY, pos[2])
		post.Anchored = true
		post.CanCollide = false
		post.Material = Enum.Material.Metal
		post.Color = railColor
		post.Parent = building
	end

	-- Horizontal railing bars (top rail around each side)
	local barH = 0.2 * s
	local barTopY = cabBaseY + 0.6 * s + RAIL_H
	local barMidY = cabBaseY + 0.6 * s + RAIL_H * 0.5
	for _, barY in ipairs({barTopY, barMidY}) do
		-- X-facing bars (along Z)
		for _, dx in ipairs({halfD, -halfD}) do
			local bar = Instance.new("Part")
			bar.Size = Vector3.new(0.15 * s, barH, floorW)
			bar.Position = Vector3.new(x + dx, barY, z)
			bar.Anchored = true
			bar.CanCollide = false
			bar.Material = Enum.Material.Metal
			bar.Color = railColor
			bar.Parent = building
		end
		-- Z-facing bars (along X)
		for _, dz in ipairs({halfW, -halfW}) do
			local bar = Instance.new("Part")
			bar.Size = Vector3.new(floorD, barH, 0.15 * s)
			bar.Position = Vector3.new(x, barY, z + dz)
			bar.Anchored = true
			bar.CanCollide = false
			bar.Material = Enum.Material.Metal
			bar.Color = railColor
			bar.Parent = building
		end
	end

	-- Corner pillars (structural metal beams at cab corners)
	local pillarH = CAB_H + 1.0 * s
	local pillarSize = Vector3.new(FRAME, pillarH, FRAME)
	local chD = CAB_D / 2
	local chW = CAB_W / 2
	local pillarY = cabBaseY + 0.6 * s + pillarH / 2
	for _, cx in ipairs({x + chD, x - chD}) do
		for _, cz in ipairs({z + chW, z - chW}) do
			local pillar = Instance.new("Part")
			pillar.Size = pillarSize
			pillar.Position = Vector3.new(cx, pillarY, cz)
			pillar.Anchored = true
			pillar.Material = Enum.Material.Metal
			pillar.Color = DARK_METAL
			pillar.Parent = building
		end
	end

	-- Glass walls (4 sides, split into upper and lower band with a metal divider)
	local glassBaseY = cabBaseY + 0.6 * s
	local lowerH = CAB_H * 0.35
	local upperH = CAB_H * 0.65 - FRAME
	local dividerY = glassBaseY + lowerH + FRAME / 2

	-- Build each wall: two glass panes + horizontal metal divider
	local walls = {
		{size_upper = Vector3.new(0.25 * s, upperH, CAB_W - FRAME), size_lower = Vector3.new(0.25 * s, lowerH, CAB_W - FRAME), px = x + chD, pz = z}, -- +X face
		{size_upper = Vector3.new(0.25 * s, upperH, CAB_W - FRAME), size_lower = Vector3.new(0.25 * s, lowerH, CAB_W - FRAME), px = x - chD, pz = z}, -- -X face
		{size_upper = Vector3.new(CAB_D - FRAME, upperH, 0.25 * s), size_lower = Vector3.new(CAB_D - FRAME, lowerH, 0.25 * s), px = x, pz = z + chW}, -- +Z face
		{size_upper = Vector3.new(CAB_D - FRAME, upperH, 0.25 * s), size_lower = Vector3.new(CAB_D - FRAME, lowerH, 0.25 * s), px = x, pz = z - chW}, -- -Z face
	}

	for _, w in ipairs(walls) do
		-- Lower glass band (darker tint)
		local lower = Instance.new("Part")
		lower.Size = w.size_lower
		lower.Position = Vector3.new(w.px, glassBaseY + lowerH / 2, w.pz)
		lower.Anchored = true
		lower.CanCollide = false
		lower.Material = Enum.Material.Glass
		lower.Color = GLASS_TINT
		lower.Transparency = 0.35
		lower.Parent = building

		-- Metal divider strip
		local divSize = w.size_upper
		local divider = Instance.new("Part")
		divider.Size = Vector3.new(divSize.X + 0.05, FRAME, divSize.Z + 0.05)
		divider.Position = Vector3.new(w.px, dividerY, w.pz)
		divider.Anchored = true
		divider.CanCollide = false
		divider.Material = Enum.Material.Metal
		divider.Color = DARK_METAL
		divider.Parent = building

		-- Upper glass band (main windows, lighter)
		local upper = Instance.new("Part")
		upper.Size = w.size_upper
		upper.Position = Vector3.new(w.px, dividerY + FRAME / 2 + upperH / 2, w.pz)
		upper.Anchored = true
		upper.CanCollide = false
		upper.Material = Enum.Material.Glass
		upper.Color = GLASS_COLOR
		upper.Transparency = 0.3
		upper.Parent = building
	end

	-- Ceiling slab
	local ceilY = glassBaseY + CAB_H
	local ceilSlab = Instance.new("Part")
	ceilSlab.Size = Vector3.new(CAB_D + 1.5 * s, 0.5 * s, CAB_W + 1.5 * s)
	ceilSlab.Position = Vector3.new(x, ceilY + 0.25 * s, z)
	ceilSlab.Anchored = true
	ceilSlab.Material = Enum.Material.Metal
	ceilSlab.Color = DARK_METAL
	ceilSlab.Parent = building

	-- Roof equipment platform (slightly raised)
	local roofTopY = ceilY + 0.5 * s
	local roofPlat = Instance.new("Part")
	roofPlat.Size = Vector3.new(CAB_D * 0.5, 0.3 * s, CAB_W * 0.5)
	roofPlat.Position = Vector3.new(x, roofTopY + 0.15 * s, z)
	roofPlat.Anchored = true
	roofPlat.Material = Enum.Material.DiamondPlate
	roofPlat.Color = LIGHT_METAL
	roofPlat.Parent = building

	-- Radar dome (sphere on roof)
	local dome = Instance.new("Part")
	dome.Shape = Enum.PartType.Ball
	dome.Size = Vector3.new(3.5 * s, 3.5 * s, 3.5 * s)
	dome.Position = Vector3.new(x + 2 * s, roofTopY + 0.3 * s + 1.75 * s, z)
	dome.Anchored = true
	dome.CanCollide = false
	dome.Material = Enum.Material.SmoothPlastic
	dome.Color = Color3.fromRGB(220, 225, 230)
	dome.Parent = building

	-- Antenna mast + beacon
	local antennaH = 8 * s
	local antenna = Instance.new("Part")
	antenna.Size = Vector3.new(0.4 * s, antennaH, 0.4 * s)
	antenna.Position = Vector3.new(x - 2 * s, roofTopY + 0.3 * s + antennaH / 2, z)
	antenna.Anchored = true
	antenna.Material = Enum.Material.Metal
	antenna.Color = railColor
	antenna.Parent = building

	local beacon = Instance.new("Part")
	beacon.Shape = Enum.PartType.Ball
	beacon.Size = Vector3.new(1.0 * s, 1.0 * s, 1.0 * s)
	beacon.Position = Vector3.new(x - 2 * s, roofTopY + 0.3 * s + antennaH + 0.5 * s, z)
	beacon.Anchored = true
	beacon.CanCollide = false
	beacon.Material = Enum.Material.Neon
	beacon.Color = Color3.fromRGB(255, 40, 40)
	beacon.Parent = building

	-- Interior ceiling light strips (two rows, warm white)
	for _, offZ in ipairs({-3 * s, 3 * s}) do
		local ceilLight = Instance.new("Part")
		ceilLight.Size = Vector3.new(CAB_D * 0.6, 0.15 * s, 1.5 * s)
		ceilLight.Position = Vector3.new(x, ceilY - 0.15 * s, z + offZ)
		ceilLight.Anchored = true
		ceilLight.CanCollide = false
		ceilLight.Material = Enum.Material.Neon
		ceilLight.Color = Color3.fromRGB(255, 235, 200)
		ceilLight.Parent = building

		local ptLight = Instance.new("PointLight")
		ptLight.Color = Color3.fromRGB(255, 235, 200)
		ptLight.Brightness = 0.8
		ptLight.Range = 18
		ptLight.Parent = ceilLight
	end

	-- Main overhead SpotLight (warm downward light, visible through glass)
	local spotMount = Instance.new("Part")
	spotMount.Size = Vector3.new(0.5 * s, 0.5 * s, 0.5 * s)
	spotMount.Position = Vector3.new(x, ceilY - 0.3 * s, z)
	spotMount.Anchored = true
	spotMount.CanCollide = false
	spotMount.Transparency = 1
	spotMount.Parent = building

	local spotLight = Instance.new("SpotLight")
	spotLight.Face = Enum.NormalId.Bottom
	spotLight.Color = Color3.fromRGB(255, 240, 210)
	spotLight.Brightness = 1.2
	spotLight.Range = 20
	spotLight.Angle = 80
	spotLight.Parent = spotMount

	-- Floor mat (dark carpet inside cab)
	local floorMat = Instance.new("Part")
	floorMat.Size = Vector3.new(CAB_D - 1 * s, 0.15 * s, CAB_W - 1 * s)
	floorMat.Position = Vector3.new(x, glassBaseY + 0.08 * s, z)
	floorMat.Anchored = true
	floorMat.CanCollide = false
	floorMat.Material = Enum.Material.Fabric
	floorMat.Color = Color3.fromRGB(30, 32, 38)
	floorMat.Parent = building

	-- U-shaped console desk (wraps around the road-facing side)
	local deskH = 3 * s
	local deskThick = 1.5 * s
	local deskColor = Color3.fromRGB(35, 35, 40)
	local sign_dir = x > 0 and 1 or -1

	-- Front desk (facing road, along Z)
	local frontDesk = Instance.new("Part")
	frontDesk.Size = Vector3.new(deskThick, deskH, CAB_W * 0.7)
	frontDesk.Position = Vector3.new(x - sign_dir * (CAB_D / 2 - deskThick - 1 * s), glassBaseY + deskH / 2, z)
	frontDesk.Anchored = true
	frontDesk.CanCollide = false
	frontDesk.Material = Enum.Material.SmoothPlastic
	frontDesk.Color = deskColor
	frontDesk.Parent = building

	-- Side wings of the desk
	local wingLen = 4 * s
	for _, side in ipairs({-1, 1}) do
		local wing = Instance.new("Part")
		wing.Size = Vector3.new(wingLen, deskH, deskThick)
		wing.Position = Vector3.new(
			x - sign_dir * (CAB_D / 2 - deskThick - 1 * s) + sign_dir * (wingLen / 2),
			glassBaseY + deskH / 2,
			z + side * (CAB_W * 0.35)
		)
		wing.Anchored = true
		wing.CanCollide = false
		wing.Material = Enum.Material.SmoothPlastic
		wing.Color = deskColor
		wing.Parent = building
	end

	-- Monitor screens on the front desk (green radar + blue data)
	local screenH = 1.8 * s
	local screenW = 2.0 * s
	local screenColors = {
		Color3.fromRGB(40, 170, 70),  -- radar green
		Color3.fromRGB(50, 140, 220), -- data blue
		Color3.fromRGB(40, 170, 70),  -- radar green
		Color3.fromRGB(50, 140, 220), -- data blue
		Color3.fromRGB(40, 170, 70),  -- radar green
	}
	for i = -2, 2 do
		local screen = Instance.new("Part")
		screen.Size = Vector3.new(0.15 * s, screenH, screenW)
		screen.Position = Vector3.new(
			x - sign_dir * (CAB_D / 2 - deskThick - 0.9 * s),
			glassBaseY + deskH + screenH / 2 + 0.2 * s,
			z + i * 2.5 * s
		)
		screen.Anchored = true
		screen.CanCollide = false
		screen.Material = Enum.Material.Neon
		screen.Color = screenColors[i + 3]
		screen.Parent = building
	end

	building.Parent = decorFolder
	return building
end

return AirportTower
