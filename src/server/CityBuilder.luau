-- CityBuilder.luau
-- Phase 1: Infrastructure skeleton — terrain, major roads, railway, metro,
-- elevated highway, water channel, access ramps, dead-end buffers.

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared", 10)
local GTAConfig = require(Shared:WaitForChild("GTAConfig"))
local DecorCreation = require(script.Parent:WaitForChild("DecorCreation"))
local DecorUtils = require(script.Parent:WaitForChild("DecorCreation"):WaitForChild("decor"):WaitForChild("DecorUtils"))

local CityBuilder = {}

-- Shortcuts
local GROUND_Y     = GTAConfig.GROUND_Y
local CELL         = GTAConfig.CELL_SIZE
local COLS         = GTAConfig.GRID_COLS
local ROWS         = GTAConfig.GRID_ROWS
local ORIGIN_X     = GTAConfig.CITY_ORIGIN_X
local ORIGIN_Z     = GTAConfig.CITY_ORIGIN_Z
local CITY_W       = GTAConfig.CITY_WIDTH
local CITY_D       = GTAConfig.CITY_DEPTH
local STREET_W     = GTAConfig.STREET_WIDTH
local HIGHWAY_W    = GTAConfig.HIGHWAY_WIDTH

-- Track/vehicle constants (from vehicle builders)
local TRAIN_WIDTH  = 10   -- trains & subway cars
local RAIL_GAUGE   = 4    -- distance between rails
local TRACK_BED_W  = 14   -- concrete bed for high-speed/metro
local SLEEPER_W    = 12   -- wooden sleeper length
local METRO_Y      = GTAConfig.METRO_HEIGHT         -- 22
local ELEVATED_HW_Y = 14  -- elevated highway deck height
local MIN_CLEARANCE = 24  -- clearance under bridges/elevated (monster truck = 23.5)

local roadFolder = nil

--------------------------------------------------------------------------------
-- TERRAIN MATERIALS PER DISTRICT
--------------------------------------------------------------------------------

local DISTRICT_TERRAIN = {
	airport      = Enum.Material.Concrete,
	industrial   = Enum.Material.Slate,
	power_plant  = Enum.Material.Slate,
	military     = Enum.Material.Sand,
	nuclear      = Enum.Material.Ground,
	commercial   = Enum.Material.Ground,
	downtown     = Enum.Material.Concrete,
	government   = Enum.Material.Grass,
	prison       = Enum.Material.Slate,
	residential  = Enum.Material.Grass,
	harbor       = Enum.Material.Slate,
	water_plant  = Enum.Material.Mud,
	waterfront   = Enum.Material.Grass,
	beach        = Enum.Material.Sand,
	space        = Enum.Material.Basalt,
}

--------------------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------------------

local function fillTerrain(position, size, material)
	local region = Region3.new(position - size / 2, position + size / 2):ExpandToGrid(4)
	Workspace.Terrain:FillRegion(region, 4, material)
end

local function makePart(name, size, pos, material, color, parent, canCollide)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.CanCollide = (canCollide ~= false)
	p.Material = material
	p.Color = color
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Size = size
	p.Position = pos
	p.Parent = parent or roadFolder
	return p
end


--------------------------------------------------------------------------------
-- 1. ISLAND TERRAIN
--------------------------------------------------------------------------------

local function buildIslandTerrain()
	local margin = GTAConfig.OCEAN_MARGIN
	local totalW = CITY_W + margin * 2
	local totalD = CITY_D + margin * 2

	fillTerrain(Vector3.new(0, GTAConfig.WATER_LEVEL - 20, 0), Vector3.new(totalW, 40, totalD), Enum.Material.Water)
	fillTerrain(Vector3.new(0, GROUND_Y - 10, 0), Vector3.new(CITY_W + 100, 20, CITY_D + 100), Enum.Material.Grass)

	local coast = GTAConfig.COASTLINE_WIDTH
	local halfW = CITY_W / 2 + 50
	local halfD = CITY_D / 2 + 50
	fillTerrain(Vector3.new(0, GROUND_Y - 6, -halfD), Vector3.new(CITY_W + 100, 12, coast), Enum.Material.Sand)
	fillTerrain(Vector3.new(0, GROUND_Y - 6,  halfD), Vector3.new(CITY_W + 100, 12, coast), Enum.Material.Sand)
	fillTerrain(Vector3.new(-halfW, GROUND_Y - 6, 0), Vector3.new(coast, 12, CITY_D + 100), Enum.Material.Sand)
	fillTerrain(Vector3.new( halfW, GROUND_Y - 6, 0), Vector3.new(coast, 12, CITY_D + 100), Enum.Material.Sand)

	print("[CityBuilder] Island terrain built")
end

--------------------------------------------------------------------------------
-- 2. PER-DISTRICT TERRAIN
--------------------------------------------------------------------------------

local function buildDistrictTerrain()
	for _, d in ipairs(GTAConfig.DISTRICTS) do
		local mat = DISTRICT_TERRAIN[d.name]
		if not mat then continue end
		local x1 = ORIGIN_X + d.colMin * CELL
		local z1 = ORIGIN_Z + d.rowMin * CELL
		local x2 = ORIGIN_X + (d.colMax + 1) * CELL
		local z2 = ORIGIN_Z + (d.rowMax + 1) * CELL
		fillTerrain(Vector3.new((x1+x2)/2, GROUND_Y-4, (z1+z2)/2), Vector3.new(x2-x1, 8, z2-z1), mat)
	end
	print("[CityBuilder] District terrain painted")
end

--------------------------------------------------------------------------------
-- 3. MAJOR ROADS (zone-boundary avenues + perimeter highway)
--------------------------------------------------------------------------------

local function buildRoadSegment(x, z, sizeX, sizeZ, isHighway)
	local w = isHighway and HIGHWAY_W or STREET_W
	local col = isHighway and Color3.fromRGB(55, 55, 60) or Color3.fromRGB(45, 45, 50)
	makePart("Road", Vector3.new(sizeX, 0.3, sizeZ), Vector3.new(x, GROUND_Y + 0.15, z), Enum.Material.Asphalt, col)

	-- Lane markings
	local isVertical = sizeZ > sizeX
	local length = isVertical and sizeZ or sizeX
	local dir = isVertical and "z" or "x"
	local DASH, GAP = 4, 6
	local count = math.floor(length / (DASH + GAP))
	for i = 0, count - 1 do
		local offset = -length / 2 + i * (DASH + GAP) + DASH / 2
		local mSize, mPos
		if dir == "z" then
			mSize = Vector3.new(0.3, 0.05, DASH)
			mPos = Vector3.new(x, GROUND_Y + 0.32, z + offset)
		else
			mSize = Vector3.new(DASH, 0.05, 0.3)
			mPos = Vector3.new(x + offset, GROUND_Y + 0.32, z)
		end
		makePart("LaneMark", mSize, mPos, Enum.Material.SmoothPlastic, Color3.fromRGB(220, 210, 160), nil, false)
	end

	-- Sidewalks
	local SW = 5
	if isVertical then
		makePart("Sidewalk", Vector3.new(SW, 0.5, sizeZ), Vector3.new(x - sizeX/2 - SW/2, GROUND_Y + 0.05, z), Enum.Material.Concrete, Color3.fromRGB(170, 165, 155))
		makePart("Sidewalk", Vector3.new(SW, 0.5, sizeZ), Vector3.new(x + sizeX/2 + SW/2, GROUND_Y + 0.05, z), Enum.Material.Concrete, Color3.fromRGB(170, 165, 155))
	else
		makePart("Sidewalk", Vector3.new(sizeX, 0.5, SW), Vector3.new(x, GROUND_Y + 0.05, z - sizeZ/2 - SW/2), Enum.Material.Concrete, Color3.fromRGB(170, 165, 155))
		makePart("Sidewalk", Vector3.new(sizeX, 0.5, SW), Vector3.new(x, GROUND_Y + 0.05, z + sizeZ/2 + SW/2), Enum.Material.Concrete, Color3.fromRGB(170, 165, 155))
	end
end

local function buildMajorRoads()
	-- Collect all unique district boundary edges
	local hRows = {}  -- set of row indices that are horizontal boundaries
	local vEdges = {} -- vEdges[col] = { {z1,z2}, ... } partial vertical spans

	for _, d in ipairs(GTAConfig.DISTRICTS) do
		hRows[d.rowMin] = true
		hRows[d.rowMax + 1] = true

		-- Left edge
		local lk = d.colMin .. "_" .. d.rowMin .. "_" .. (d.rowMax + 1)
		if not vEdges[lk] then
			vEdges[lk] = { col = d.colMin, z1 = ORIGIN_Z + d.rowMin * CELL, z2 = ORIGIN_Z + (d.rowMax + 1) * CELL }
		end
		-- Right edge
		local rk = (d.colMax + 1) .. "_" .. d.rowMin .. "_" .. (d.rowMax + 1)
		if not vEdges[rk] then
			vEdges[rk] = { col = d.colMax + 1, z1 = ORIGIN_Z + d.rowMin * CELL, z2 = ORIGIN_Z + (d.rowMax + 1) * CELL }
		end
	end

	local count = 0

	-- Horizontal roads (full width, at each boundary row)
	for row, _ in pairs(hRows) do
		local z = ORIGIN_Z + row * CELL
		local isHW = (row == 0 or row == ROWS)
		local w = isHW and HIGHWAY_W or STREET_W
		buildRoadSegment(0, z, CITY_W + 60, w, isHW)
		count += 1
	end

	-- Vertical roads (partial spans per district edge)
	for _, edge in pairs(vEdges) do
		local x = ORIGIN_X + edge.col * CELL
		local isHW = (edge.col == 0 or edge.col == COLS)
		local w = isHW and HIGHWAY_W or STREET_W
		local cz = (edge.z1 + edge.z2) / 2
		local length = edge.z2 - edge.z1
		buildRoadSegment(x, cz, w, length, isHW)
		count += 1
	end

	print("[CityBuilder] Major roads built:", count, "segments")
end

--------------------------------------------------------------------------------
-- 4. RAILWAY (ground-level N-S, offset from col-4 road)
-- Uses proper rail gauge (4 studs), 12-stud sleepers, 1-stud high rails.
-- Offset 20 studs east of col-4 boundary to not overlap the road.
--------------------------------------------------------------------------------

local function buildRailway()
	local railX = ORIGIN_X + 4 * CELL + 20  -- 20 studs east of col-4 road
	local railLen = CITY_D + 40
	local railY = GROUND_Y

	-- Gravel bed
	makePart("RailBed", Vector3.new(SLEEPER_W + 4, 0.3, railLen),
		Vector3.new(railX, railY + 0.15, 0),
		Enum.Material.Pebble, Color3.fromRGB(120, 110, 95))

	-- Two steel rails (4-stud gauge, 1 stud high, matching real builders)
	for _, offset in ipairs({-RAIL_GAUGE/2, RAIL_GAUGE/2}) do
		makePart("Rail", Vector3.new(0.8, 1, railLen),
			Vector3.new(railX + offset, railY + 0.8, 0),
			Enum.Material.Metal, Color3.fromRGB(140, 140, 150))
	end

	-- Wooden sleepers every 6 studs
	local tieCount = math.floor(railLen / 6)
	for i = 0, tieCount do
		local z = -railLen/2 + i * 6
		makePart("Tie", Vector3.new(SLEEPER_W, 0.6, 2),
			Vector3.new(railX, railY + 0.3, z),
			Enum.Material.Wood, Color3.fromRGB(90, 60, 30), nil, false)
	end

	-- Buffer stops at both ends (dead ends)
	for _, zEnd in ipairs({-railLen/2, railLen/2}) do
		local dir = (zEnd < 0) and 1 or -1
		-- Buffer bumper
		makePart("BufferStop", Vector3.new(SLEEPER_W, 4, 3),
			Vector3.new(railX, railY + 2, zEnd + dir * 2),
			Enum.Material.Metal, Color3.fromRGB(180, 40, 40))
		-- Buffer beam
		makePart("BufferBeam", Vector3.new(8, 2, 1),
			Vector3.new(railX, railY + 3, zEnd + dir * 3.5),
			Enum.Material.Metal, Color3.fromRGB(220, 60, 40))
	end

	print("[CityBuilder] Railway built (N-S, col 4 + 20 offset, with buffer stops)")
end

--------------------------------------------------------------------------------
-- 5. ELEVATED METRO (E-W + N-S, sized for 10-stud-wide subway trains)
-- 14-stud concrete bed, proper pillars, station platforms with stairs.
--------------------------------------------------------------------------------

local function buildMetroTrack(startX, startZ, endX, endZ, name)
	local dx = endX - startX
	local dz = endZ - startZ
	local length = math.sqrt(dx*dx + dz*dz)
	local cx = (startX + endX) / 2
	local cz = (startZ + endZ) / 2
	local isVertical = math.abs(dz) > math.abs(dx)

	-- Concrete track bed (14 studs wide for 10-stud trains)
	local bedSize = isVertical and Vector3.new(TRACK_BED_W, 1, length) or Vector3.new(length, 1, TRACK_BED_W)
	makePart(name .. "Bed", bedSize, Vector3.new(cx, METRO_Y, cz), Enum.Material.Concrete, Color3.fromRGB(160, 155, 145))

	-- Safety rails on edges
	for _, side in ipairs({-1, 1}) do
		local railOff = (TRACK_BED_W / 2 + 0.3) * side
		local rSize, rPos
		if isVertical then
			rSize = Vector3.new(0.6, 1.5, length)
			rPos = Vector3.new(cx + railOff, METRO_Y + 1, cz)
		else
			rSize = Vector3.new(length, 1.5, 0.6)
			rPos = Vector3.new(cx, METRO_Y + 1, cz + railOff)
		end
		makePart(name .. "Rail", rSize, rPos, Enum.Material.Metal, Color3.fromRGB(80, 80, 90))
	end

	-- Steel rails on bed (4-stud gauge)
	for _, offset in ipairs({-RAIL_GAUGE/2, RAIL_GAUGE/2}) do
		local rSize, rPos
		if isVertical then
			rSize = Vector3.new(0.6, 0.5, length)
			rPos = Vector3.new(cx + offset, METRO_Y + 0.75, cz)
		else
			rSize = Vector3.new(length, 0.5, 0.6)
			rPos = Vector3.new(cx, METRO_Y + 0.75, cz + offset)
		end
		makePart(name .. "Track", rSize, rPos, Enum.Material.Metal, Color3.fromRGB(140, 140, 150))
	end

	-- Support pillars every 2 cells
	local pillarSpacing = CELL * 2
	local numPillars = math.floor(length / pillarSpacing)
	local pillarH = METRO_Y - GROUND_Y
	for i = 0, numPillars do
		local t = i / math.max(numPillars, 1)
		local px = startX + dx * t
		local pz = startZ + dz * t
		makePart(name .. "Pillar", Vector3.new(3, pillarH, 3),
			Vector3.new(px, GROUND_Y + pillarH / 2, pz),
			Enum.Material.Concrete, Color3.fromRGB(80, 80, 90))
	end

	-- Buffer stops at both ends
	for _, endPos in ipairs({{startX, startZ, 1}, {endX, endZ, -1}}) do
		local bx, bz, dir = endPos[1], endPos[2], endPos[3]
		local bSize, bPos
		if isVertical then
			bSize = Vector3.new(TRACK_BED_W, 4, 2)
			bPos = Vector3.new(bx, METRO_Y + 2.5, bz + dir * 2)
		else
			bSize = Vector3.new(2, 4, TRACK_BED_W)
			bPos = Vector3.new(bx + dir * 2, METRO_Y + 2.5, bz)
		end
		makePart(name .. "Buffer", bSize, bPos, Enum.Material.Metal, Color3.fromRGB(180, 40, 40))
	end
end

local function buildMetroStation(x, z, stationName, isVertical)
	-- Platform (wider than track, passengers stand here)
	local platW = 20
	local platD = 30
	local pSize = isVertical and Vector3.new(platW, 0.5, platD) or Vector3.new(platD, 0.5, platW)
	makePart("Platform_" .. stationName, pSize,
		Vector3.new(x, METRO_Y + 0.5, z),
		Enum.Material.Concrete, Color3.fromRGB(180, 175, 165))

	-- Roof shelter
	local roofSize = isVertical and Vector3.new(platW + 2, 0.3, platD - 4) or Vector3.new(platD - 4, 0.3, platW + 2)
	makePart("Roof_" .. stationName, roofSize,
		Vector3.new(x, METRO_Y + 6, z),
		Enum.Material.Metal, Color3.fromRGB(60, 65, 75))

	-- Roof support columns (4 corners)
	for _, sx in ipairs({-1, 1}) do
		for _, sz in ipairs({-1, 1}) do
			local cx = x + sx * (platW / 2 - 2)
			local cz = z + sz * (platD / 2 - 4)
			if not isVertical then
				cx = x + sx * (platD / 2 - 4)
				cz = z + sz * (platW / 2 - 2)
			end
			makePart("RoofCol", Vector3.new(1, 5, 1),
				Vector3.new(cx, METRO_Y + 3, cz),
				Enum.Material.Metal, Color3.fromRGB(80, 80, 90))
		end
	end

	-- Station sign
	local signSize = Vector3.new(12, 3, 0.5)
	local signPos = isVertical
		and Vector3.new(x, METRO_Y + 5, z - platD / 2 - 1)
		or Vector3.new(x - platD / 2 - 1, METRO_Y + 5, z)
	local sign = makePart("Sign_" .. stationName, signSize, signPos, Enum.Material.SmoothPlastic, Color3.fromRGB(0, 150, 220))
	local sg = Instance.new("SurfaceGui")
	sg.Face = Enum.NormalId.Front
	sg.Parent = sign
	local tl = Instance.new("TextLabel")
	tl.Size = UDim2.new(1, 0, 1, 0)
	tl.BackgroundTransparency = 1
	tl.Text = stationName
	tl.TextColor3 = Color3.fromRGB(255, 255, 255)
	tl.Font = Enum.Font.GothamBold
	tl.TextScaled = true
	tl.Parent = sg

	-- ACCESS STAIRS (ground → platform, individual steps on both sides)
	local stairH = METRO_Y - GROUND_Y  -- 18 studs to climb
	local NUM_STEPS = 12
	local STEP_H = stairH / NUM_STEPS       -- 1.5 studs per step
	local STEP_D = 3                         -- depth per step
	local STAIR_W = 6

	for _, side in ipairs({-1, 1}) do
		-- Stairs start at the edge of the platform and go down to ground
		local platEdge = isVertical and (platW / 2) or (platD / 2)

		for i = 0, NUM_STEPS - 1 do
			local stepY = GROUND_Y + (NUM_STEPS - i) * STEP_H - STEP_H / 2
			local stepOffset = platEdge + 2 + i * STEP_D + STEP_D / 2

			local stepX, stepZ
			if isVertical then
				stepX = x + side * stepOffset
				stepZ = z
			else
				stepX = x
				stepZ = z + side * stepOffset
			end

			-- Each step is a concrete block
			makePart("Step", Vector3.new(
				isVertical and STEP_D or STAIR_W,
				STEP_H,
				isVertical and STAIR_W or STEP_D
			), Vector3.new(stepX, stepY, stepZ),
				Enum.Material.Concrete, Color3.fromRGB(170, 165, 155))
		end

		-- Railings along the staircase
		local totalStairLen = NUM_STEPS * STEP_D
		local railCenterOffset = platEdge + 2 + totalStairLen / 2
		local railMidY = GROUND_Y + stairH / 2 + 1

		for _, rSide in ipairs({-1, 1}) do
			local railX, railZ, railSize
			if isVertical then
				local rOff = rSide * (STAIR_W / 2 + 0.3)
				railX = x + side * railCenterOffset
				railZ = z + rOff
				railSize = Vector3.new(totalStairLen, 2, 0.5)
			else
				local rOff = rSide * (STAIR_W / 2 + 0.3)
				railX = x + rOff
				railZ = z + side * railCenterOffset
				railSize = Vector3.new(0.5, 2, totalStairLen)
			end
			makePart("StairRail", railSize,
				Vector3.new(railX, railMidY, railZ),
				Enum.Material.Metal, Color3.fromRGB(100, 100, 110))
		end
	end
end

local function buildElevatedMetro()
	-- E-W line through central band (row 4.5)
	local ewZ = ORIGIN_Z + 4.5 * CELL + CELL / 2
	buildMetroTrack(ORIGIN_X - 20, ewZ, ORIGIN_X + CITY_W + 20, ewZ, "MetroEW")

	-- N-S line through downtown (col 6)
	local nsX = ORIGIN_X + 6 * CELL
	buildMetroTrack(nsX, ORIGIN_Z - 20, nsX, ORIGIN_Z + CITY_D + 20, "MetroNS")

	-- Stations
	buildMetroStation(ORIGIN_X + 2 * CELL,  ewZ, "Airport",      false)
	buildMetroStation(ORIGIN_X + 5 * CELL,  ewZ, "Downtown West", false)
	buildMetroStation(ORIGIN_X + 8 * CELL,  ewZ, "Government",   false)
	buildMetroStation(ORIGIN_X + 11 * CELL, ewZ, "Residential",  false)
	buildMetroStation(nsX, ORIGIN_Z + 1.5 * CELL, "Industrial",  true)
	buildMetroStation(nsX, ewZ,                    "Metro Hub",   true)
	buildMetroStation(nsX, ORIGIN_Z + 8 * CELL,   "Waterfront",  true)

	print("[CityBuilder] Elevated metro built (E-W + N-S, 14-stud bed, 7 stations with stairs)")
end

--------------------------------------------------------------------------------
-- 6. ELEVATED HIGHWAY (ring around central band with on/off ramps)
--------------------------------------------------------------------------------

local function buildElevatedHighwaySegment(startX, startZ, endX, endZ)
	local dx = endX - startX
	local dz = endZ - startZ
	local length = math.sqrt(dx*dx + dz*dz)
	local cx = (startX + endX) / 2
	local cz = (startZ + endZ) / 2
	local isVertical = math.abs(dz) > math.abs(dx)

	-- Highway deck
	local deckW = HIGHWAY_W
	local deckSize = isVertical and Vector3.new(deckW, 1, length) or Vector3.new(length, 1, deckW)
	makePart("ElevatedHW", deckSize,
		Vector3.new(cx, ELEVATED_HW_Y, cz),
		Enum.Material.Concrete, Color3.fromRGB(150, 145, 135))

	-- Road surface on deck
	local surfSize = isVertical and Vector3.new(deckW - 2, 0.2, length) or Vector3.new(length, 0.2, deckW - 2)
	makePart("HWSurface", surfSize,
		Vector3.new(cx, ELEVATED_HW_Y + 0.6, cz),
		Enum.Material.Asphalt, Color3.fromRGB(50, 50, 55))

	-- Jersey barriers on edges
	for _, side in ipairs({-1, 1}) do
		local bOff = (deckW / 2 - 1) * side
		local bSize, bPos
		if isVertical then
			bSize = Vector3.new(2, 2.5, length)
			bPos = Vector3.new(cx + bOff, ELEVATED_HW_Y + 1.75, cz)
		else
			bSize = Vector3.new(length, 2.5, 2)
			bPos = Vector3.new(cx, ELEVATED_HW_Y + 1.75, cz + bOff)
		end
		makePart("Barrier", bSize, bPos, Enum.Material.Concrete, Color3.fromRGB(180, 175, 165))
	end

	-- Support pillars
	local pillarSpacing = CELL * 1.5
	local numPillars = math.max(1, math.floor(length / pillarSpacing))
	local pillarH = ELEVATED_HW_Y - GROUND_Y
	for i = 0, numPillars do
		local t = i / math.max(numPillars, 1)
		local px = startX + dx * t
		local pz = startZ + dz * t
		-- Twin pillars (one each side)
		for _, side in ipairs({-1, 1}) do
			local pOff = (deckW / 2 - 4) * side
			local ppx = isVertical and (px + pOff) or px
			local ppz = isVertical and pz or (pz + pOff)
			makePart("HWPillar", Vector3.new(2.5, pillarH, 2.5),
				Vector3.new(ppx, GROUND_Y + pillarH / 2, ppz),
				Enum.Material.Concrete, Color3.fromRGB(100, 95, 90))
		end
	end
end

local function buildHighwayRamp(baseX, baseZ, topX, topZ, approachDir)
	-- Vehicle ramp from ground to elevated highway
	local rampLen = 80  -- long gentle slope for vehicles
	local rampH = ELEVATED_HW_Y - GROUND_Y
	local rampW = HIGHWAY_W - 4

	local cx = (baseX + topX) / 2
	local cz = (baseZ + topZ) / 2

	-- Ramp deck (angled)
	local rampSize = Vector3.new(rampW, 1, rampLen)
	local angle = math.atan2(rampH, rampLen)

	local rampCF
	if approachDir == "north" then
		rampCF = CFrame.new(cx, GROUND_Y + rampH / 2, cz) * CFrame.Angles(angle, 0, 0)
	elseif approachDir == "south" then
		rampCF = CFrame.new(cx, GROUND_Y + rampH / 2, cz) * CFrame.Angles(-angle, 0, 0)
	elseif approachDir == "east" then
		rampCF = CFrame.new(cx, GROUND_Y + rampH / 2, cz) * CFrame.Angles(0, math.pi / 2, angle)
	elseif approachDir == "west" then
		rampCF = CFrame.new(cx, GROUND_Y + rampH / 2, cz) * CFrame.Angles(0, -math.pi / 2, angle)
	end

	local ramp = Instance.new("Part")
	ramp.Name = "HWRamp"
	ramp.Anchored = true
	ramp.Material = Enum.Material.Concrete
	ramp.Color = Color3.fromRGB(150, 145, 135)
	ramp.Size = rampSize
	ramp.CFrame = rampCF
	ramp.Parent = roadFolder

	-- Ramp surface
	local surf = Instance.new("Part")
	surf.Name = "RampSurface"
	surf.Anchored = true
	surf.Material = Enum.Material.Asphalt
	surf.Color = Color3.fromRGB(50, 50, 55)
	surf.Size = Vector3.new(rampW - 2, 0.2, rampLen)
	surf.CFrame = rampCF * CFrame.new(0, 0.6, 0)
	surf.Parent = roadFolder

	-- Ramp barriers
	for _, side in ipairs({-1, 1}) do
		local barrier = Instance.new("Part")
		barrier.Name = "RampBarrier"
		barrier.Anchored = true
		barrier.Material = Enum.Material.Concrete
		barrier.Color = Color3.fromRGB(180, 175, 165)
		barrier.Size = Vector3.new(2, 2.5, rampLen)
		barrier.CFrame = rampCF * CFrame.new(side * (rampW / 2 - 1), 1.75, 0)
		barrier.Parent = roadFolder
	end
end

local function buildElevatedHighway()
	-- Elevated highway ring around the central band (rows 3-6)
	-- Runs along row 3 boundary (north side) and row 7 boundary (south side)
	-- Connected by N-S segments on west (col 0) and east (col COLS)

	local northZ = ORIGIN_Z + 3 * CELL - HIGHWAY_W  -- just north of central band
	local southZ = ORIGIN_Z + 7 * CELL + HIGHWAY_W  -- just south of central band
	local westX  = ORIGIN_X + HIGHWAY_W
	local eastX  = ORIGIN_X + CITY_W - HIGHWAY_W

	-- E-W elevated segments (north & south)
	buildElevatedHighwaySegment(westX, northZ, eastX, northZ)
	buildElevatedHighwaySegment(westX, southZ, eastX, southZ)

	-- N-S elevated segments (west & east connectors)
	buildElevatedHighwaySegment(westX, northZ, westX, southZ)
	buildElevatedHighwaySegment(eastX, northZ, eastX, southZ)

	-- On/off ramps at key points
	-- North side ramps (2 ramps)
	local rampOffset = 40
	buildHighwayRamp(ORIGIN_X + 3 * CELL, northZ - rampOffset, ORIGIN_X + 3 * CELL, northZ, "south")
	buildHighwayRamp(ORIGIN_X + 10 * CELL, northZ - rampOffset, ORIGIN_X + 10 * CELL, northZ, "south")

	-- South side ramps (2 ramps)
	buildHighwayRamp(ORIGIN_X + 5 * CELL, southZ + rampOffset, ORIGIN_X + 5 * CELL, southZ, "north")
	buildHighwayRamp(ORIGIN_X + 9 * CELL, southZ + rampOffset, ORIGIN_X + 9 * CELL, southZ, "north")

	print("[CityBuilder] Elevated highway ring built with 4 ramps")
end

--------------------------------------------------------------------------------
-- 7. WATER CHANNEL + BRIDGES
--------------------------------------------------------------------------------

local function buildWaterChannel()
	local chanZ = ORIGIN_Z + GTAConfig.WATER_CHANNEL_Z_ROW * CELL
	local chanW = GTAConfig.WATER_CHANNEL_WIDTH

	fillTerrain(Vector3.new(0, GROUND_Y - 8, chanZ), Vector3.new(CITY_W - CELL * 2, 16, chanW), Enum.Material.Air)
	fillTerrain(Vector3.new(0, GTAConfig.WATER_LEVEL - 4, chanZ), Vector3.new(CITY_W - CELL * 2, 8, chanW), Enum.Material.Water)

	-- Stone walls on both banks
	for _, side in ipairs({-1, 1}) do
		local wallZ = chanZ + side * (chanW / 2 + 1)
		makePart("CanalWall", Vector3.new(CITY_W - CELL * 2, 6, 2),
			Vector3.new(0, GROUND_Y - 2, wallZ),
			Enum.Material.Slate, Color3.fromRGB(80, 75, 70))
	end

	print("[CityBuilder] Water channel built")
end

local function buildBridges()
	local chanZ = ORIGIN_Z + GTAConfig.WATER_CHANNEL_Z_ROW * CELL
	local chanW = GTAConfig.WATER_CHANNEL_WIDTH

	-- Bridges where vertical roads cross the channel
	local bridgeCols = {}
	for _, d in ipairs(GTAConfig.DISTRICTS) do
		if d.colMin > 0 then bridgeCols[d.colMin] = true end
		if d.colMax + 1 < COLS then bridgeCols[d.colMax + 1] = true end
	end

	for col, _ in pairs(bridgeCols) do
		local x = ORIGIN_X + col * CELL

		-- Bridge deck
		makePart("BridgeDeck", Vector3.new(STREET_W + 10, 1, chanW + 30),
			Vector3.new(x, GROUND_Y + 0.5, chanZ),
			Enum.Material.Concrete, Color3.fromRGB(160, 155, 145))

		-- Railings
		for _, side in ipairs({-1, 1}) do
			makePart("BridgeRail", Vector3.new(1, 3, chanW + 30),
				Vector3.new(x + side * (STREET_W / 2 + 5), GROUND_Y + 2, chanZ),
				Enum.Material.Metal, Color3.fromRGB(100, 100, 110))
		end
	end

	print("[CityBuilder] Bridges built")
end

--------------------------------------------------------------------------------
-- PUBLIC API
--------------------------------------------------------------------------------

function CityBuilder.build(decorFolderRef, vehicleFolderRef, npcFolderRef)
	DecorUtils.decorFolder = decorFolderRef

	local worldFolder = Workspace:FindFirstChild("World") or Workspace
	roadFolder = Instance.new("Folder")
	roadFolder.Name = "Roads"
	roadFolder.Parent = worldFolder

	print("[CityBuilder] === Building infrastructure skeleton ===")
	print("[CityBuilder] Island:", CITY_W, "x", CITY_D, "studs |", COLS, "x", ROWS, "grid @", CELL, "studs")

	buildIslandTerrain()
	buildDistrictTerrain()
	buildMajorRoads()
	buildRailway()
	buildElevatedMetro()
	buildElevatedHighway()
	buildWaterChannel()
	buildBridges()

	print("[CityBuilder] === Infrastructure complete! ===")
end

return CityBuilder
