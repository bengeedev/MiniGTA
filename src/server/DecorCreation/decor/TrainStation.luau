local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local TrainStation = {}

local BUILDING_BASE = DecorUtils.BUILDING_BASE

--------------------------------------------------------------------------------
-- Helper: build one arch (semicircle in Y-X plane) out of N segments.
--------------------------------------------------------------------------------
local function buildArch(parent, centerX, centerZ, halfSpan, springY, peakY, numSegs, sizeZ, thick, mat, col, transp)
	local archRise = peakY - springY

	for i = 0, numSegs - 1 do
		local theta0 = i * math.pi / numSegs
		local theta1 = (i + 1) * math.pi / numSegs

		local px0 = halfSpan * math.cos(theta0)
		local py0 = springY + archRise * math.sin(theta0)
		local px1 = halfSpan * math.cos(theta1)
		local py1 = springY + archRise * math.sin(theta1)

		local mx = (px0 + px1) / 2
		local my = (py0 + py1) / 2

		local segLen = math.sqrt((px1 - px0)^2 + (py1 - py0)^2)
		local midTheta = (theta0 + theta1) / 2
		local tiltAngle = midTheta - math.pi / 2

		local panel = Instance.new("Part")
		panel.Name = "ArchSeg"
		panel.Size = Vector3.new(segLen, thick, sizeZ)
		panel.CFrame = CFrame.new(centerX + mx, my, centerZ)
			* CFrame.Angles(0, 0, tiltAngle)
		panel.Anchored = true
		panel.CanCollide = false
		panel.Material = mat
		panel.Color = col
		panel.Transparency = transp or 0
		panel.Parent = parent
	end
end

--------------------------------------------------------------------------------
-- Grand Train Station — Modern / Minimal
-- Building centered at z (laneZ). Facade faces +Z (toward approaching player).
-- Near X edge sits at x; building extends away from lane center.
--------------------------------------------------------------------------------

function TrainStation.createStationHall(x, z, scale)
	local decorFolder = DecorUtils.decorFolder
	if not decorFolder then return nil end
	scale = scale or 1

	local model = Instance.new("Model")
	model.Name = "StationHall"

	---------------------------------------------------------------------------
	-- DIMENSIONS
	---------------------------------------------------------------------------
	local facadeW   = 70 * scale   -- width along X
	local shedDepth = 60 * scale   -- depth along Z
	local wallH     = 30 * scale   -- side wall height
	local archPeak  = 60 * scale   -- top of barrel vault above BUILDING_BASE
	local halfSpan  = facadeW / 2

	-- Shift X so near edge (closest to lane center) sits at x,
	-- building extends away from center — matching other builders.
	local xSign = x > 0 and 1 or -1
	x = x + xSign * halfSpan

	local roofY0    = BUILDING_BASE + wallH
	local roofYPeak = BUILDING_BASE + archPeak

	local C_STEEL    = Color3.fromRGB(85, 90, 100)
	local C_GLASS    = Color3.fromRGB(200, 230, 255)
	local C_METAL    = Color3.fromRGB(70, 75, 80)
	local C_BRICK    = Color3.fromRGB(175, 140, 105)
	local C_CONCRETE = Color3.fromRGB(160, 160, 165)

	-- Z layout: centered at z, facade faces +Z (toward player)
	local frontZ      = z + shedDepth / 2
	local backZ       = z - shedDepth / 2
	local shedCenterZ = z

	---------------------------------------------------------------------------
	-- 1. FACADE (at frontZ, facing +Z)
	---------------------------------------------------------------------------
	local groundH     = wallH
	local facadeThick = 1.5 * scale
	local baseH       = 3 * scale

	-- a) Concrete base slab
	local baseSlab = Instance.new("Part")
	baseSlab.Name = "FacadeBase"
	baseSlab.Size = Vector3.new(facadeW + 2 * scale, baseH, facadeThick + 1 * scale)
	baseSlab.Position = Vector3.new(x, BUILDING_BASE + baseH / 2, frontZ)
	baseSlab.Anchored = true
	baseSlab.Material = Enum.Material.Concrete
	baseSlab.Color = C_CONCRETE
	baseSlab.Parent = model

	-- b) Steel columns from base to wall top
	local NUM_COLS = 8
	local colSpacing = facadeW / (NUM_COLS - 1)
	local colH = groundH - baseH
	local colW = 1 * scale

	for c = 0, NUM_COLS - 1 do
		local cx = x - halfSpan + c * colSpacing
		local col = Instance.new("Part")
		col.Name = "SteelColumn"
		col.Size = Vector3.new(colW, colH, colW)
		col.Position = Vector3.new(cx, BUILDING_BASE + baseH + colH / 2, frontZ)
		col.Anchored = true
		col.Material = Enum.Material.Metal
		col.Color = C_STEEL
		col.Parent = model
	end

	-- c) Glass entrance panels between columns
	local panelH = colH - 1 * scale
	for c = 0, NUM_COLS - 2 do
		local leftX = x - halfSpan + c * colSpacing + colW / 2
		local rightX = x - halfSpan + (c + 1) * colSpacing - colW / 2
		local panelW = rightX - leftX
		local panelCX = (leftX + rightX) / 2

		local panel = Instance.new("Part")
		panel.Name = "GlassPanel"
		panel.Size = Vector3.new(panelW, panelH, 0.3)
		panel.Position = Vector3.new(panelCX, BUILDING_BASE + baseH + panelH / 2, frontZ)
		panel.Anchored = true
		panel.CanCollide = false
		panel.Material = Enum.Material.SmoothPlastic
		panel.Color = C_GLASS
		panel.Transparency = 0.8
		panel.Parent = model

		-- Horizontal mullion
		local mullion = Instance.new("Part")
		mullion.Name = "Mullion"
		mullion.Size = Vector3.new(panelW, 0.25 * scale, 0.35)
		mullion.Position = Vector3.new(panelCX, BUILDING_BASE + baseH + panelH * 0.5, frontZ + 0.1)
		mullion.Anchored = true
		mullion.CanCollide = false
		mullion.Material = Enum.Material.Metal
		mullion.Color = C_STEEL
		mullion.Parent = model
	end

	-- d) Horizontal steel band at top of ground floor
	local band = Instance.new("Part")
	band.Name = "SteelBand"
	band.Size = Vector3.new(facadeW + 2 * scale, 1 * scale, facadeThick + 0.5 * scale)
	band.Position = Vector3.new(x, BUILDING_BASE + groundH + 0.5 * scale, frontZ)
	band.Anchored = true
	band.Material = Enum.Material.Metal
	band.Color = C_STEEL
	band.Parent = model

	-- e) Glass panels filling the semicircular arch above steel band
	local NUM_MULLIONS = 7
	local mullionXs = {}
	for m = 0, NUM_MULLIONS + 1 do
		mullionXs[m] = x - halfSpan + m * (facadeW / (NUM_MULLIONS + 1))
	end

	for m = 0, NUM_MULLIONS do
		local leftMX = mullionXs[m]
		local rightMX = mullionXs[m + 1]
		local panelCX = (leftMX + rightMX) / 2
		local panelW = rightMX - leftMX

		local relX = (panelCX - x) / halfSpan
		local archYatX = roofY0 + (roofYPeak - roofY0) * math.sqrt(math.max(0, 1 - relX * relX))
		local pH = archYatX - roofY0

		if pH > 1 then
			local glassPanel = Instance.new("Part")
			glassPanel.Name = "FacadeGlass"
			glassPanel.Size = Vector3.new(panelW - 0.4 * scale, pH, 0.3)
			glassPanel.Position = Vector3.new(panelCX, roofY0 + pH / 2, frontZ)
			glassPanel.Anchored = true
			glassPanel.CanCollide = false
			glassPanel.Material = Enum.Material.SmoothPlastic
			glassPanel.Color = C_GLASS
			glassPanel.Transparency = 0.8
			glassPanel.Parent = model
		end
	end

	-- f) Steel arch frame (outer rim)
	buildArch(model, x, frontZ + 0.2, halfSpan + 0.5 * scale, roofY0, roofYPeak + 0.5,
		16, 0.3 * scale, 0.6 * scale,
		Enum.Material.Metal, C_STEEL, 0)

	-- g) Vertical steel mullions in the glass arch
	for m = 1, NUM_MULLIONS do
		local mx = mullionXs[m]
		local relX = (mx - x) / halfSpan
		local archYatX = roofY0 + (roofYPeak - roofY0) * math.sqrt(math.max(0, 1 - relX * relX))
		local mullH = archYatX - roofY0
		if mullH > 1 then
			local mullion = Instance.new("Part")
			mullion.Name = "ArchMullion"
			mullion.Size = Vector3.new(0.35 * scale, mullH, 0.35 * scale)
			mullion.Position = Vector3.new(mx, roofY0 + mullH / 2, frontZ)
			mullion.Anchored = true
			mullion.CanCollide = false
			mullion.Material = Enum.Material.Metal
			mullion.Color = C_STEEL
			mullion.Parent = model
		end
	end

	---------------------------------------------------------------------------
	-- 2. SIDE WALLS (glass + steel columns) + BACK WALL
	---------------------------------------------------------------------------
	local SIDE_COLS = 7
	local sideColSpacing = shedDepth / (SIDE_COLS - 1)
	local sideColH = wallH - baseH
	local sideBaseH = baseH

	for _, side in ipairs({-1, 1}) do
		local wallX = x + side * halfSpan

		-- Concrete base along the side
		local sideBase = Instance.new("Part")
		sideBase.Name = "SideBase"
		sideBase.Size = Vector3.new(facadeThick + 1 * scale, sideBaseH, shedDepth)
		sideBase.Position = Vector3.new(wallX, BUILDING_BASE + sideBaseH / 2, shedCenterZ)
		sideBase.Anchored = true
		sideBase.Material = Enum.Material.Concrete
		sideBase.Color = C_CONCRETE
		sideBase.Parent = model

		-- Steel columns along the side (from front to back)
		for c = 0, SIDE_COLS - 1 do
			local cz = frontZ - c * sideColSpacing
			local col = Instance.new("Part")
			col.Name = "SideColumn"
			col.Size = Vector3.new(colW, sideColH, colW)
			col.Position = Vector3.new(wallX, BUILDING_BASE + sideBaseH + sideColH / 2, cz)
			col.Anchored = true
			col.Material = Enum.Material.Metal
			col.Color = C_STEEL
			col.Parent = model
		end

		-- Glass panels between side columns
		local sidePanelH = sideColH - 1 * scale
		for c = 0, SIDE_COLS - 2 do
			local z0 = frontZ - c * sideColSpacing
			local z1 = frontZ - (c + 1) * sideColSpacing
			local pCZ = (z0 + z1) / 2
			local pLen = math.abs(z1 - z0) - colW

			local sidePanel = Instance.new("Part")
			sidePanel.Name = "SideGlass"
			sidePanel.Size = Vector3.new(0.3, sidePanelH, pLen)
			sidePanel.Position = Vector3.new(wallX, BUILDING_BASE + sideBaseH + sidePanelH / 2, pCZ)
			sidePanel.Anchored = true
			sidePanel.CanCollide = false
			sidePanel.Material = Enum.Material.SmoothPlastic
			sidePanel.Color = C_GLASS
			sidePanel.Transparency = 0.8
			sidePanel.Parent = model

			-- Horizontal mullion at mid-height
			local sideMullion = Instance.new("Part")
			sideMullion.Name = "SideMullion"
			sideMullion.Size = Vector3.new(0.35, 0.25 * scale, pLen)
			sideMullion.Position = Vector3.new(wallX, BUILDING_BASE + sideBaseH + sidePanelH * 0.5, pCZ)
			sideMullion.Anchored = true
			sideMullion.CanCollide = false
			sideMullion.Material = Enum.Material.Metal
			sideMullion.Color = C_STEEL
			sideMullion.Parent = model
		end

		-- Steel band at top of side wall
		local sideBand = Instance.new("Part")
		sideBand.Name = "SideBand"
		sideBand.Size = Vector3.new(facadeThick + 0.5 * scale, 1 * scale, shedDepth + 1 * scale)
		sideBand.Position = Vector3.new(wallX, BUILDING_BASE + wallH + 0.5 * scale, shedCenterZ)
		sideBand.Anchored = true
		sideBand.Material = Enum.Material.Metal
		sideBand.Color = C_STEEL
		sideBand.Parent = model
	end

	-- Back wall
	local backWall = Instance.new("Part")
	backWall.Name = "BackWall"
	backWall.Size = Vector3.new(facadeW, wallH, 1.5 * scale)
	backWall.Position = Vector3.new(x, BUILDING_BASE + wallH / 2, backZ)
	backWall.Anchored = true
	backWall.Material = Enum.Material.Brick
	backWall.Color = C_BRICK
	backWall.Parent = model

	---------------------------------------------------------------------------
	-- 3. BARREL VAULT ROOF (glass dome)
	---------------------------------------------------------------------------
	buildArch(model, x, shedCenterZ, halfSpan, roofY0, roofYPeak,
		14, shedDepth - 1 * scale, 0.4 * scale,
		Enum.Material.SmoothPlastic, C_GLASS, 0.6)

	-- Ridge beam
	local ridge = Instance.new("Part")
	ridge.Name = "RidgeBeam"
	ridge.Size = Vector3.new(1 * scale, 1 * scale, shedDepth)
	ridge.Position = Vector3.new(x, roofYPeak + 0.3, shedCenterZ)
	ridge.Anchored = true
	ridge.Material = Enum.Material.Metal
	ridge.Color = C_METAL
	ridge.Parent = model

	---------------------------------------------------------------------------
	-- 4. METAL RIB ARCHES (structural ribs)
	---------------------------------------------------------------------------
	local NUM_RIBS = 5
	for r = 1, NUM_RIBS do
		local ribZ = frontZ - r * shedDepth / (NUM_RIBS + 1)
		buildArch(model, x, ribZ, halfSpan, roofY0, roofYPeak,
			12, 0.6 * scale, 0.6 * scale,
			Enum.Material.Metal, C_METAL, 0)
	end

	---------------------------------------------------------------------------
	-- 5. PLATFORM CANOPY (steel awning extending toward player, +Z)
	---------------------------------------------------------------------------
	local canopyD = 8 * scale
	local canopyY = BUILDING_BASE + 12 * scale
	local canopy = Instance.new("Part")
	canopy.Name = "Canopy"
	canopy.Size = Vector3.new(facadeW * 0.85, 0.4 * scale, canopyD)
	canopy.Position = Vector3.new(x, canopyY, frontZ + canopyD / 2)
	canopy.Anchored = true
	canopy.Material = Enum.Material.Metal
	canopy.Color = C_STEEL
	canopy.Parent = model

	-- Canopy support poles
	for _, side in ipairs({-1, 0, 1}) do
		local pole = Instance.new("Part")
		pole.Name = "CanopyPole"
		pole.Size = Vector3.new(0.4 * scale, canopyY - BUILDING_BASE, 0.4 * scale)
		pole.Position = Vector3.new(x + side * facadeW * 0.35, BUILDING_BASE + (canopyY - BUILDING_BASE) / 2, frontZ + canopyD)
		pole.Anchored = true
		pole.Material = Enum.Material.Metal
		pole.Color = C_STEEL
		pole.Parent = model
	end

	---------------------------------------------------------------------------
	-- 6. PLATFORM LAMPS
	---------------------------------------------------------------------------
	for i = -3, 3 do
		local lx = x + i * 10 * scale
		local poleH = 8 * scale
		local lz = frontZ + 4 * scale

		local pole = Instance.new("Part")
		pole.Name = "LampPole"
		pole.Size = Vector3.new(0.35 * scale, poleH, 0.35 * scale)
		pole.Position = Vector3.new(lx, BUILDING_BASE + poleH / 2, lz)
		pole.Anchored = true
		pole.Material = Enum.Material.Metal
		pole.Color = Color3.fromRGB(80, 80, 80)
		pole.Parent = model

		local bulb = Instance.new("Part")
		bulb.Name = "LampBulb"
		bulb.Shape = Enum.PartType.Ball
		bulb.Size = Vector3.new(1.2 * scale, 1.2 * scale, 1.2 * scale)
		bulb.Position = Vector3.new(lx, BUILDING_BASE + poleH + 0.3, lz)
		bulb.Anchored = true
		bulb.CanCollide = false
		bulb.Material = Enum.Material.Neon
		bulb.Color = Color3.fromRGB(255, 220, 140)
		bulb.Parent = model

		local light = Instance.new("PointLight")
		light.Brightness = 1
		light.Range = 14
		light.Color = Color3.fromRGB(255, 220, 140)
		light.Parent = bulb
	end

	---------------------------------------------------------------------------
	-- 7. SIDE WING — lower terminal extension, attached to the far wall
	--    Same glass/steel style, extends further from lane center.
	---------------------------------------------------------------------------
	local wingW     = 55 * scale    -- width along X (extends away from center)
	local wingDepth = shedDepth     -- same Z extent as main hall
	local wingH     = wallH          -- match main hall wall height (below dome)
	local wingRoofH = 1 * scale

	-- Far wall of main hall (away from lane center)
	local farWallX  = x + xSign * halfSpan
	-- Wing center X extends further from lane center
	local wingCX    = farWallX + xSign * wingW / 2
	local wingCZ    = shedCenterZ

	-- a) Concrete base
	local wingBaseH = baseH
	local wingBase = Instance.new("Part")
	wingBase.Name = "WingBase"
	wingBase.Size = Vector3.new(wingW, wingBaseH, wingDepth)
	wingBase.Position = Vector3.new(wingCX, BUILDING_BASE + wingBaseH / 2, wingCZ)
	wingBase.Anchored = true
	wingBase.Material = Enum.Material.Concrete
	wingBase.Color = C_CONCRETE
	wingBase.Parent = model

	-- b) Glass walls (front and back faces, along Z ends)
	for _, fz in ipairs({frontZ, backZ}) do
		local wingGlass = Instance.new("Part")
		wingGlass.Name = "WingFaceGlass"
		wingGlass.Size = Vector3.new(wingW, wingH - wingBaseH, 0.3)
		wingGlass.Position = Vector3.new(wingCX, BUILDING_BASE + wingBaseH + (wingH - wingBaseH) / 2, fz)
		wingGlass.Anchored = true
		wingGlass.CanCollide = false
		wingGlass.Material = Enum.Material.SmoothPlastic
		wingGlass.Color = C_GLASS
		wingGlass.Transparency = 0.8
		wingGlass.Parent = model

		-- Horizontal mullion
		local wMull = Instance.new("Part")
		wMull.Name = "WingFaceMullion"
		wMull.Size = Vector3.new(wingW, 0.3 * scale, 0.35)
		wMull.Position = Vector3.new(wingCX, BUILDING_BASE + wingBaseH + (wingH - wingBaseH) * 0.5, fz)
		wMull.Anchored = true
		wMull.CanCollide = false
		wMull.Material = Enum.Material.Metal
		wMull.Color = C_STEEL
		wMull.Parent = model
	end

	-- c) Glass side wall (outer face, away from main hall)
	local outerWallX = wingCX + xSign * wingW / 2
	local wingSideGlass = Instance.new("Part")
	wingSideGlass.Name = "WingSideGlass"
	wingSideGlass.Size = Vector3.new(0.3, wingH - wingBaseH, wingDepth)
	wingSideGlass.Position = Vector3.new(outerWallX, BUILDING_BASE + wingBaseH + (wingH - wingBaseH) / 2, wingCZ)
	wingSideGlass.Anchored = true
	wingSideGlass.CanCollide = false
	wingSideGlass.Material = Enum.Material.SmoothPlastic
	wingSideGlass.Color = C_GLASS
	wingSideGlass.Transparency = 0.8
	wingSideGlass.Parent = model

	-- d) Horizontal mullion on outer side wall
	local wingSideMull = Instance.new("Part")
	wingSideMull.Name = "WingSideMullion"
	wingSideMull.Size = Vector3.new(0.35, 0.3 * scale, wingDepth)
	wingSideMull.Position = Vector3.new(outerWallX, BUILDING_BASE + wingBaseH + (wingH - wingBaseH) * 0.5, wingCZ)
	wingSideMull.Anchored = true
	wingSideMull.CanCollide = false
	wingSideMull.Material = Enum.Material.Metal
	wingSideMull.Color = C_STEEL
	wingSideMull.Parent = model

	-- e) Steel columns at corners and mid-points
	local wingColH = wingH - wingBaseH
	local wingCorners = {
		{wingCX - wingW / 2, frontZ},
		{wingCX + wingW / 2, frontZ},
		{wingCX - wingW / 2, backZ},
		{wingCX + wingW / 2, backZ},
		{wingCX, frontZ},
		{wingCX, backZ},
	}
	for _, corner in ipairs(wingCorners) do
		local wCol = Instance.new("Part")
		wCol.Name = "WingColumn"
		wCol.Size = Vector3.new(colW, wingColH, colW)
		wCol.Position = Vector3.new(corner[1], BUILDING_BASE + wingBaseH + wingColH / 2, corner[2])
		wCol.Anchored = true
		wCol.Material = Enum.Material.Metal
		wCol.Color = C_STEEL
		wCol.Parent = model
	end

	-- f) Steel band at top of wing walls
	local wingBandSides = {
		-- Front/back bands
		{Vector3.new(wingW + 1 * scale, wingRoofH, 1.5 * scale), Vector3.new(wingCX, BUILDING_BASE + wingH, frontZ)},
		{Vector3.new(wingW + 1 * scale, wingRoofH, 1.5 * scale), Vector3.new(wingCX, BUILDING_BASE + wingH, backZ)},
		-- Outer side band
		{Vector3.new(1.5 * scale, wingRoofH, wingDepth + 1 * scale), Vector3.new(outerWallX, BUILDING_BASE + wingH, wingCZ)},
	}
	for _, b in ipairs(wingBandSides) do
		local wb = Instance.new("Part")
		wb.Name = "WingBand"
		wb.Size = b[1]
		wb.Position = b[2]
		wb.Anchored = true
		wb.Material = Enum.Material.Metal
		wb.Color = C_STEEL
		wb.Parent = model
	end

	-- g) Flat steel roof
	local wingRoof = Instance.new("Part")
	wingRoof.Name = "WingRoof"
	wingRoof.Size = Vector3.new(wingW + 1 * scale, 0.5 * scale, wingDepth + 1 * scale)
	wingRoof.Position = Vector3.new(wingCX, BUILDING_BASE + wingH + 0.25 * scale, wingCZ)
	wingRoof.Anchored = true
	wingRoof.Material = Enum.Material.Metal
	wingRoof.Color = C_METAL
	wingRoof.Parent = model

	-- h) Vertical steel mullions dividing the glass side wall
	local WING_SIDE_MULLIONS = 5
	for m = 1, WING_SIDE_MULLIONS do
		local mz = frontZ - m * wingDepth / (WING_SIDE_MULLIONS + 1)
		local wm = Instance.new("Part")
		wm.Name = "WingSideDivider"
		wm.Size = Vector3.new(0.35 * scale, wingColH, 0.35 * scale)
		wm.Position = Vector3.new(outerWallX, BUILDING_BASE + wingBaseH + wingColH / 2, mz)
		wm.Anchored = true
		wm.CanCollide = false
		wm.Material = Enum.Material.Metal
		wm.Color = C_STEEL
		wm.Parent = model
	end

	---------------------------------------------------------------------------
	-- 8. INTERIOR LIGHTING — Main Hall
	--    Hanging pendant lights along the center of the barrel vault.
	---------------------------------------------------------------------------
	local HALL_LIGHTS = 5
	local hangY = BUILDING_BASE + wallH - 2 * scale  -- just below where vault starts
	local C_WARM = Color3.fromRGB(255, 220, 140)

	for i = 1, HALL_LIGHTS do
		local lz = frontZ - i * shedDepth / (HALL_LIGHTS + 1)

		-- Thin rod hanging from vault
		local rod = Instance.new("Part")
		rod.Name = "LightRod"
		rod.Size = Vector3.new(0.2 * scale, 4 * scale, 0.2 * scale)
		rod.Position = Vector3.new(x, hangY + 2 * scale, lz)
		rod.Anchored = true
		rod.CanCollide = false
		rod.Material = Enum.Material.Metal
		rod.Color = C_METAL
		rod.Parent = model

		-- Glowing bulb
		local bulb = Instance.new("Part")
		bulb.Name = "HallLight"
		bulb.Shape = Enum.PartType.Ball
		bulb.Size = Vector3.new(2 * scale, 2 * scale, 2 * scale)
		bulb.Position = Vector3.new(x, hangY, lz)
		bulb.Anchored = true
		bulb.CanCollide = false
		bulb.Material = Enum.Material.Neon
		bulb.Color = C_WARM
		bulb.Parent = model

		local pl = Instance.new("PointLight")
		pl.Brightness = 1.5
		pl.Range = 25
		pl.Color = C_WARM
		pl.Parent = bulb
	end

	---------------------------------------------------------------------------
	-- 9. INTERIOR LIGHTING — Wing
	--    Ceiling-flush lights along the wing center.
	---------------------------------------------------------------------------
	local WING_LIGHTS = 4
	local wingLightY = BUILDING_BASE + wingH - 1 * scale

	for i = 1, WING_LIGHTS do
		local lz = frontZ - i * wingDepth / (WING_LIGHTS + 1)

		local wBulb = Instance.new("Part")
		wBulb.Name = "WingLight"
		wBulb.Shape = Enum.PartType.Ball
		wBulb.Size = Vector3.new(1.5 * scale, 1.5 * scale, 1.5 * scale)
		wBulb.Position = Vector3.new(wingCX, wingLightY, lz)
		wBulb.Anchored = true
		wBulb.CanCollide = false
		wBulb.Material = Enum.Material.Neon
		wBulb.Color = C_WARM
		wBulb.Parent = model

		local wpl = Instance.new("PointLight")
		wpl.Brightness = 1.2
		wpl.Range = 18
		wpl.Color = C_WARM
		wpl.Parent = wBulb
	end

	---------------------------------------------------------------------------
	-- 10. FACADE CLOCK — Big round analog clock above the entrance
	--     Pure 3D parts: cylinder face + black part hands, animated via CFrame
	---------------------------------------------------------------------------
	local clockDiam = 14 * scale
	local clockThick = 0.8 * scale
	local clockY = roofY0 + 10 * scale
	local clockZ = frontZ + 2

	-- Dark rim ring
	local rim = Instance.new("Part")
	rim.Name = "ClockRim"
	rim.Shape = Enum.PartType.Cylinder
	rim.Size = Vector3.new(clockThick + 0.3, clockDiam + 2 * scale, clockDiam + 2 * scale)
	rim.CFrame = CFrame.new(x, clockY, clockZ)
		* CFrame.Angles(0, math.rad(90), 0)
	rim.Anchored = true
	rim.CanCollide = false
	rim.Material = Enum.Material.Metal
	rim.Color = C_METAL
	rim.Parent = model

	-- White clock face (cylinder)
	local clockFace = Instance.new("Part")
	clockFace.Name = "ClockFace"
	clockFace.Shape = Enum.PartType.Cylinder
	clockFace.Size = Vector3.new(clockThick, clockDiam, clockDiam)
	clockFace.CFrame = CFrame.new(x, clockY, clockZ + 0.3)
		* CFrame.Angles(0, math.rad(90), 0)
	clockFace.Anchored = true
	clockFace.CanCollide = false
	clockFace.Material = Enum.Material.SmoothPlastic
	clockFace.Color = Color3.fromRGB(245, 240, 230)
	clockFace.Parent = model

	-- Center hub (small black cylinder)
	local hub = Instance.new("Part")
	hub.Name = "ClockHub"
	hub.Shape = Enum.PartType.Cylinder
	hub.Size = Vector3.new(0.4, 1 * scale, 1 * scale)
	hub.CFrame = CFrame.new(x, clockY, clockZ + 0.7)
		* CFrame.Angles(0, math.rad(90), 0)
	hub.Anchored = true
	hub.CanCollide = false
	hub.Material = Enum.Material.Metal
	hub.Color = Color3.fromRGB(30, 30, 35)
	hub.Parent = model

	-- 12 hour markers (small black parts around the edge)
	local markerRadius = clockDiam / 2 * 0.82
	for h = 1, 12 do
		local angle = math.rad(h * 30)  -- 0=12 o'clock, clockwise
		local mx = x + markerRadius * math.sin(angle)
		local my = clockY + markerRadius * math.cos(angle)
		local isMain = (h % 3 == 0)
		local mLen = isMain and (1.2 * scale) or (0.7 * scale)
		local mW = isMain and (0.5 * scale) or (0.3 * scale)

		local mark = Instance.new("Part")
		mark.Name = "Mark_" .. h
		mark.Size = Vector3.new(mW, mLen, 0.3)
		mark.CFrame = CFrame.new(mx, my, clockZ + 0.6)
			* CFrame.Angles(0, 0, -angle)
		mark.Anchored = true
		mark.CanCollide = false
		mark.Material = Enum.Material.Metal
		mark.Color = Color3.fromRGB(30, 30, 35)
		mark.Parent = model
	end

	-- Hour hand (short, thick black part)
	local hourLen = clockDiam / 2 * 0.5
	local hourHand = Instance.new("Part")
	hourHand.Name = "HourHand"
	hourHand.Size = Vector3.new(0.6 * scale, hourLen, 0.3)
	hourHand.CFrame = CFrame.new(x, clockY, clockZ + 0.8)
	hourHand.Anchored = true
	hourHand.CanCollide = false
	hourHand.Material = Enum.Material.Metal
	hourHand.Color = Color3.fromRGB(20, 20, 25)
	hourHand.Parent = model

	-- Minute hand (longer, thinner black part)
	local minuteLen = clockDiam / 2 * 0.75
	local minuteHand = Instance.new("Part")
	minuteHand.Name = "MinuteHand"
	minuteHand.Size = Vector3.new(0.4 * scale, minuteLen, 0.25)
	minuteHand.CFrame = CFrame.new(x, clockY, clockZ + 0.9)
	minuteHand.Anchored = true
	minuteHand.CanCollide = false
	minuteHand.Material = Enum.Material.Metal
	minuteHand.Color = Color3.fromRGB(20, 20, 25)
	minuteHand.Parent = model

	-- Register clock animation (3D hands rotated via CFrame)
	local activePlatformAnimations = DecorUtils.activePlatformAnimations
	if activePlatformAnimations then
		activePlatformAnimations[clockFace] = {
			type = "station_clock",
			centerX = x,
			centerY = clockY,
			centerZ = clockZ,
			hourHand = hourHand,
			hourLen = hourLen,
			minuteHand = minuteHand,
			minuteLen = minuteLen,
		}
	end

	---------------------------------------------------------------------------
	-- 11. DEPARTURE BOARD — Large screen on the back wall
	---------------------------------------------------------------------------
	local scrW = facadeW * 0.75
	local scrH = wallH * 0.55
	local scrThick = 0.4
	local scrY = BUILDING_BASE + wallH * 0.6

	local screen = Instance.new("Part")
	screen.Name = "DepartureScreen"
	screen.Size = Vector3.new(scrW, scrH, scrThick)
	screen.Position = Vector3.new(x, scrY, backZ + 1)
	screen.Anchored = true
	screen.CanCollide = false
	screen.Material = Enum.Material.Neon
	screen.Color = Color3.fromRGB(8, 15, 35)
	screen.Parent = model

	-- SurfaceGui facing +Z (toward the interior / player)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "DepartureGui"
	gui.Face = Enum.NormalId.Back
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 24
	gui.LightInfluence = 0
	gui.Brightness = 1.5
	gui.Parent = screen

	-- Background
	local bg = Instance.new("Frame")
	bg.Name = "BG"
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.fromRGB(5, 12, 30)
	bg.BorderSizePixel = 0
	bg.Parent = gui

	-- Header: "DEPARTURES"
	local header = Instance.new("TextLabel")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0.12, 0)
	header.Position = UDim2.new(0, 0, 0.01, 0)
	header.BackgroundTransparency = 1
	header.Text = "DEPARTURES"
	header.TextColor3 = Color3.fromRGB(255, 200, 0)
	header.TextScaled = true
	header.Font = Enum.Font.Code
	header.Parent = bg

	-- Cyan line under header
	local headerLine = Instance.new("Frame")
	headerLine.Size = UDim2.new(0.94, 0, 0.004, 0)
	headerLine.Position = UDim2.new(0.03, 0, 0.13, 0)
	headerLine.BackgroundColor3 = Color3.fromRGB(0, 180, 220)
	headerLine.BorderSizePixel = 0
	headerLine.Parent = bg

	-- Column headers
	local colHeaders = {
		{ text = "TIME",     x = 0.03, w = 0.14 },
		{ text = "TRAIN",    x = 0.18, w = 0.12 },
		{ text = "DESTINATION", x = 0.31, w = 0.30 },
		{ text = "PLATFORM", x = 0.62, w = 0.14 },
		{ text = "STATUS",   x = 0.77, w = 0.20 },
	}
	for _, ch in ipairs(colHeaders) do
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(ch.w, 0, 0.07, 0)
		lbl.Position = UDim2.new(ch.x, 0, 0.15, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = ch.text
		lbl.TextColor3 = Color3.fromRGB(120, 140, 160)
		lbl.TextScaled = true
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Font = Enum.Font.Code
		lbl.Parent = bg
	end

	-- Thin line under column headers
	local colLine = Instance.new("Frame")
	colLine.Size = UDim2.new(0.94, 0, 0.003, 0)
	colLine.Position = UDim2.new(0.03, 0, 0.225, 0)
	colLine.BackgroundColor3 = Color3.fromRGB(40, 60, 80)
	colLine.BorderSizePixel = 0
	colLine.Parent = bg

	-- Train departure rows
	local departures = {
		{ time = "08:15", train = "TGV 6201",  dest = "PARIS GARE DU NORD",   plat = "1A" },
		{ time = "08:32", train = "IC 482",    dest = "AMSTERDAM CENTRAAL",    plat = "3B" },
		{ time = "08:45", train = "RE 1140",   dest = "BERLIN HAUPTBAHNHOF",   plat = "2A" },
		{ time = "09:00", train = "EC 87",     dest = "ZURICH HB",             plat = "4C" },
		{ time = "09:12", train = "TGV 9580",  dest = "LONDON ST PANCRAS",     plat = "1B" },
		{ time = "09:30", train = "ICE 621",   dest = "FRANKFURT AM MAIN",     plat = "5A" },
		{ time = "09:48", train = "THA 9320",  dest = "BRUXELLES MIDI",        plat = "2B" },
		{ time = "10:05", train = "IC 2044",   dest = "VIENNA WESTBAHNHOF",    plat = "3A" },
	}

	local rowH = 0.08
	local startY = 0.24
	local statusLabels = {}

	for i, dep in ipairs(departures) do
		local ry = startY + (i - 1) * (rowH + 0.015)
		if ry + rowH > 0.95 then break end

		local rowColor = Color3.fromRGB(220, 230, 240)

		-- Time
		local tLbl = Instance.new("TextLabel")
		tLbl.Size = UDim2.new(0.14, 0, rowH, 0)
		tLbl.Position = UDim2.new(0.03, 0, ry, 0)
		tLbl.BackgroundTransparency = 1
		tLbl.Text = dep.time
		tLbl.TextColor3 = rowColor
		tLbl.TextScaled = true
		tLbl.TextXAlignment = Enum.TextXAlignment.Left
		tLbl.Font = Enum.Font.Code
		tLbl.Parent = bg

		-- Train
		local trLbl = Instance.new("TextLabel")
		trLbl.Size = UDim2.new(0.12, 0, rowH, 0)
		trLbl.Position = UDim2.new(0.18, 0, ry, 0)
		trLbl.BackgroundTransparency = 1
		trLbl.Text = dep.train
		trLbl.TextColor3 = rowColor
		trLbl.TextScaled = true
		trLbl.TextXAlignment = Enum.TextXAlignment.Left
		trLbl.Font = Enum.Font.Code
		trLbl.Parent = bg

		-- Destination
		local dLbl = Instance.new("TextLabel")
		dLbl.Size = UDim2.new(0.30, 0, rowH, 0)
		dLbl.Position = UDim2.new(0.31, 0, ry, 0)
		dLbl.BackgroundTransparency = 1
		dLbl.Text = dep.dest
		dLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
		dLbl.TextScaled = true
		dLbl.TextXAlignment = Enum.TextXAlignment.Left
		dLbl.Font = Enum.Font.Code
		dLbl.Parent = bg

		-- Platform
		local pLbl = Instance.new("TextLabel")
		pLbl.Size = UDim2.new(0.14, 0, rowH, 0)
		pLbl.Position = UDim2.new(0.62, 0, ry, 0)
		pLbl.BackgroundTransparency = 1
		pLbl.Text = dep.plat
		pLbl.TextColor3 = Color3.fromRGB(0, 200, 255)
		pLbl.TextScaled = true
		pLbl.TextXAlignment = Enum.TextXAlignment.Left
		pLbl.Font = Enum.Font.Code
		pLbl.Parent = bg

		-- Status (will be animated)
		local sLbl = Instance.new("TextLabel")
		sLbl.Name = "Status_" .. i
		sLbl.Size = UDim2.new(0.20, 0, rowH, 0)
		sLbl.Position = UDim2.new(0.77, 0, ry, 0)
		sLbl.BackgroundTransparency = 1
		sLbl.Text = "ON TIME"
		sLbl.TextColor3 = Color3.fromRGB(0, 255, 120)
		sLbl.TextScaled = true
		sLbl.TextXAlignment = Enum.TextXAlignment.Left
		sLbl.Font = Enum.Font.Code
		sLbl.Parent = bg
		table.insert(statusLabels, sLbl)
	end

	-- Status bar at bottom
	local statusBar = Instance.new("Frame")
	statusBar.Size = UDim2.new(0.94, 0, 0.003, 0)
	statusBar.Position = UDim2.new(0.03, 0, 0.93, 0)
	statusBar.BackgroundColor3 = Color3.fromRGB(0, 100, 140)
	statusBar.BorderSizePixel = 0
	statusBar.Parent = bg

	local clockLabel = Instance.new("TextLabel")
	clockLabel.Name = "Clock"
	clockLabel.Size = UDim2.new(0.94, 0, 0.05, 0)
	clockLabel.Position = UDim2.new(0.03, 0, 0.94, 0)
	clockLabel.BackgroundTransparency = 1
	clockLabel.Text = "08:14  |  WELCOME  |  ALL SERVICES RUNNING"
	clockLabel.TextColor3 = Color3.fromRGB(0, 180, 80)
	clockLabel.TextScaled = true
	clockLabel.Font = Enum.Font.Code
	clockLabel.Parent = bg

	-- Screen glow
	local screenGlow = Instance.new("PointLight")
	screenGlow.Color = Color3.fromRGB(80, 160, 255)
	screenGlow.Brightness = 0.8
	screenGlow.Range = 22
	screenGlow.Parent = screen

	-- Register animation
	local activePlatformAnimations = DecorUtils.activePlatformAnimations
	if activePlatformAnimations then
		activePlatformAnimations[screen] = {
			type = "departure_board",
			statusLabels = statusLabels,
			clockLabel = clockLabel,
			lastTick = 0,
			startTime = tick(),
		}
	end

	model.Parent = decorFolder
	return model
end

return TrainStation
