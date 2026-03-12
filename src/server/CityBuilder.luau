-- CityBuilder.luau
-- Tiled grid: lanes + blocks, ZERO overlap (same as DashOrCrash).
-- Compound zones (airport, military, etc.) are big open blocks with no internal roads.

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared", 10)
local GTAConfig = require(Shared:WaitForChild("GTAConfig"))
local DecorCreation = require(script.Parent:WaitForChild("DecorCreation"))
local DecorUtils = require(script.Parent:WaitForChild("DecorCreation"):WaitForChild("decor"):WaitForChild("DecorUtils"))
local HighSpeedTrack = require(script.Parent:WaitForChild("DecorCreation"):WaitForChild("decor"):WaitForChild("HighSpeedTrack"))
local RailwayCrossing = require(script.Parent:WaitForChild("DecorCreation"):WaitForChild("decor"):WaitForChild("RailwayCrossing"))
local WaterBridge = require(script.Parent:WaitForChild("DecorCreation"):WaitForChild("decor"):WaitForChild("WaterBridge"))
local TrafficLightBuilder = require(script.Parent:WaitForChild("DecorCreation"):WaitForChild("decor"):WaitForChild("TrafficLight"))
local RoadNetwork = require(script.Parent:WaitForChild("RoadNetwork"))
local AssetLibrary = require(script.Parent:WaitForChild("AssetLibrary"))

local CityBuilder = {}
local Terrain = Workspace.Terrain

local GROUND_Y  = GTAConfig.GROUND_Y
local CELL       = GTAConfig.CELL_SIZE
local ORIGIN_X   = GTAConfig.CITY_ORIGIN_X
local ORIGIN_Z   = GTAConfig.CITY_ORIGIN_Z
local CITY_W     = GTAConfig.CITY_WIDTH
local CITY_D     = GTAConfig.CITY_DEPTH
local ROAD_W     = GTAConfig.STREET_WIDTH
local HIGHWAY_W  = GTAConfig.HIGHWAY_WIDTH

local SURFACE_H  = 4
local SURFACE_CY = GROUND_Y - SURFACE_H / 2  -- Y=2

local roadFolder = nil

--------------------------------------------------------------------------------
-- DISTRICT CONFIG
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

local function getLaneWidth(laneType)
	local def = GTAConfig.LANE_TYPES[laneType]
	if def then return def.width end
	return ROAD_W
end

local function getLaneFillMaterial(laneType)
	if laneType == "railway" then
		return GTAConfig.LANE_TYPES.railway.material
	end
	return Enum.Material.Asphalt
end

local function fillSurface(cx, cz, w, d, material)
	Terrain:FillBlock(CFrame.new(cx, SURFACE_CY, cz), Vector3.new(w, SURFACE_H, d), material)
end

local function getDistrictAt(worldX, worldZ)
	local col = math.clamp(math.floor((worldX - ORIGIN_X) / CELL), 0, GTAConfig.GRID_COLS - 1)
	local row = math.clamp(math.floor((worldZ - ORIGIN_Z) / CELL), 0, GTAConfig.GRID_ROWS - 1)
	return GTAConfig.getDistrict(col, row)
end

-- Compound rects + material from district terrain config
local function getCompoundRectsWithMaterial()
	local rects = {}
	for _, r in ipairs(GTAConfig.getCompoundRects()) do
		table.insert(rects, {
			x1 = r.x1, x2 = r.x2, z1 = r.z1, z2 = r.z2,
			material = DISTRICT_TERRAIN[r.name] or Enum.Material.Grass,
		})
	end
	return rects
end

--------------------------------------------------------------------------------
-- 1. FOUNDATION (ocean + underground + coastline)
--------------------------------------------------------------------------------

local function buildFoundation()
	local margin = GTAConfig.OCEAN_MARGIN

	Terrain:FillBlock(
		CFrame.new(0, GTAConfig.WATER_LEVEL - 20, 0),
		Vector3.new(CITY_W + margin * 2, 40, CITY_D + margin * 2),
		Enum.Material.Water
	)

	Terrain:FillBlock(
		CFrame.new(0, -8, 0),
		Vector3.new(CITY_W + 100, 16, CITY_D + 100),
		Enum.Material.Rock
	)

	local coast = GTAConfig.COASTLINE_WIDTH
	local halfW = CITY_W / 2 + 50
	local halfD = CITY_D / 2 + 50
	Terrain:FillBlock(CFrame.new(0, SURFACE_CY, -halfD), Vector3.new(CITY_W + 100, SURFACE_H, coast), Enum.Material.Sand)
	Terrain:FillBlock(CFrame.new(0, SURFACE_CY,  halfD), Vector3.new(CITY_W + 100, SURFACE_H, coast), Enum.Material.Sand)
	Terrain:FillBlock(CFrame.new(-halfW, SURFACE_CY, 0), Vector3.new(coast, SURFACE_H, CITY_D + 100), Enum.Material.Sand)
	Terrain:FillBlock(CFrame.new( halfW, SURFACE_CY, 0), Vector3.new(coast, SURFACE_H, CITY_D + 100), Enum.Material.Sand)

	print("[CityBuilder] Foundation built")
end

--------------------------------------------------------------------------------
-- 2. SURFACE TILING (zero overlap)
--------------------------------------------------------------------------------

local function buildSurface()
	Terrain:SetMaterialColor(Enum.Material.Asphalt, Color3.fromRGB(50, 50, 55))

	local hLanes = GTAConfig.H_LANES
	local vLanes = GTAConfig.V_LANES
	local laneCount = 0
	local blockCount = 0

	local cityLeft  = ORIGIN_X - 30
	local cityRight = ORIGIN_X + CITY_W + 30

	local cRects = getCompoundRectsWithMaterial()
	local sharedRects = GTAConfig.getCompoundRects()

	--------------------------------------------------------------------
	-- A. COMPOUND ZONES (big open blocks, no roads inside)
	--------------------------------------------------------------------
	for _, r in ipairs(cRects) do
		fillSurface((r.x1 + r.x2) / 2, (r.z1 + r.z2) / 2, r.x2 - r.x1, r.z2 - r.z1, r.material)
		blockCount += 1
	end

	--------------------------------------------------------------------
	-- B. H-LANE STRIPS (segmented around compound zones)
	--------------------------------------------------------------------
	for _, h in ipairs(hLanes) do
		if h.type == "water" then continue end -- handled by buildWaterChannel
		local z = GTAConfig.getRowEdgeZ(h.row)
		local w = getLaneWidth(h.type)
		local laneMat = getLaneFillMaterial(h.type)

		-- Collect X ranges to skip (compound zones that this H-lane passes through)
		local skipRanges = {}
		for _, r in ipairs(sharedRects) do
			if z > r.z1 and z < r.z2 then
				table.insert(skipRanges, { r.x1, r.x2 })
			end
		end
		table.sort(skipRanges, function(a, b) return a[1] < b[1] end)

		-- Fill non-skipped portions
		local curX = cityLeft
		for _, skip in ipairs(skipRanges) do
			if curX < skip[1] then
				local segW = skip[1] - curX
				fillSurface((curX + skip[1]) / 2, z, segW, w, laneMat)
				laneCount += 1
			end
			curX = math.max(curX, skip[2])
		end
		if curX < cityRight then
			local segW = cityRight - curX
			fillSurface((curX + cityRight) / 2, z, segW, w, laneMat)
			laneCount += 1
		end
	end

	--------------------------------------------------------------------
	-- C. ROW BANDS (V-lane segments + district blocks, skip compounds)
	--------------------------------------------------------------------
	for i = 1, #hLanes - 1 do
		local topH = hLanes[i]
		local botH = hLanes[i + 1]
		local topZ = GTAConfig.getRowEdgeZ(topH.row) + getLaneWidth(topH.type) / 2
		local botZ = GTAConfig.getRowEdgeZ(botH.row) - getLaneWidth(botH.type) / 2
		local bandD = botZ - topZ
		if bandD <= 0 then continue end
		local bandCZ = (topZ + botZ) / 2

		-- V-lane segments (skip if inside compound)
		for _, v in ipairs(vLanes) do
			local x = GTAConfig.getColEdgeX(v.col)
			if not GTAConfig.isInsideCompound(x, bandCZ) then
				fillSurface(x, bandCZ, getLaneWidth(v.type), bandD, Enum.Material.Asphalt)
				laneCount += 1
			end
		end

		-- Blocks between V-lanes (skip if inside compound)
		for j = 1, #vLanes - 1 do
			local leftV = vLanes[j]
			local rightV = vLanes[j + 1]
			local leftX  = GTAConfig.getColEdgeX(leftV.col) + getLaneWidth(leftV.type) / 2
			local rightX = GTAConfig.getColEdgeX(rightV.col) - getLaneWidth(rightV.type) / 2
			local blockW = rightX - leftX
			if blockW <= 0 then continue end
			local blockCX = (leftX + rightX) / 2

			if not GTAConfig.isInsideCompound(blockCX, bandCZ) then
				local dist = getDistrictAt(blockCX, bandCZ)
				local mat = DISTRICT_TERRAIN[dist] or Enum.Material.Grass
				fillSurface(blockCX, bandCZ, blockW, bandD, mat)
				blockCount += 1
			end
		end
	end

	print("[CityBuilder] Surface tiled:", laneCount, "lane segments,", blockCount, "blocks")
end

--------------------------------------------------------------------------------
-- 3. RAILWAY TRACKS (highspeed rail parts on "railway" H-lanes)
--------------------------------------------------------------------------------

local function buildRailwayTracks()
	local hLanes = GTAConfig.H_LANES
	local vLanes = GTAConfig.V_LANES
	local cityLeft  = ORIGIN_X - 30
	local cityRight = ORIGIN_X + CITY_W + 30
	local trackCount = 0
	local crossingCount = 0

	for _, h in ipairs(hLanes) do
		if h.type ~= "railway" then continue end
		local z = GTAConfig.getRowEdgeZ(h.row)

		-- Collect all zones to skip: compound zones + road crossings
		local skipRanges = {}

		for _, r in ipairs(GTAConfig.getCompoundRects()) do
			if z > r.z1 and z < r.z2 then
				table.insert(skipRanges, { x1 = r.x1, x2 = r.x2, crossing = false })
			end
		end

		-- Each V-lane that crosses this railway = a crossing block
		local crossings = {}
		for _, v in ipairs(vLanes) do
			local vx = GTAConfig.getColEdgeX(v.col)
			local vw = getLaneWidth(v.type)
			if not GTAConfig.isInsideCompound(vx, z) then
				table.insert(crossings, { x = vx, width = vw })
				table.insert(skipRanges, { x1 = vx - vw / 2, x2 = vx + vw / 2, crossing = true })
			end
		end

		table.sort(skipRanges, function(a, b) return a.x1 < b.x1 end)

		-- Build track segments between all skip zones
		local segments = {}
		local curX = cityLeft
		for _, skip in ipairs(skipRanges) do
			if curX < skip.x1 then
				table.insert(segments, { curX, skip.x1 })
			end
			curX = math.max(curX, skip.x2)
		end
		if curX < cityRight then
			table.insert(segments, { curX, cityRight })
		end

		-- Place track segments (buffer stops only at very first/last)
		for i, seg in ipairs(segments) do
			local leftBuf = (i == 1)
			local rightBuf = (i == #segments)
			HighSpeedTrack.createSegment(seg[1], seg[2], z, 1, leftBuf, rightBuf)
			trackCount += 1
		end

		-- Place crossing blocks at each road intersection
		for _, c in ipairs(crossings) do
			RailwayCrossing.create(c.x, z, c.width, 1)
			crossingCount += 1
		end
	end

	print("[CityBuilder] Railway:", trackCount, "track segments,", crossingCount, "crossings")
end

--------------------------------------------------------------------------------
-- 4. WATER CHANNEL (river at water H-lanes + bridge crossings)
--------------------------------------------------------------------------------

local function buildWaterChannel()
	local hLanes = GTAConfig.H_LANES
	local vLanes = GTAConfig.V_LANES
	local cityLeft  = ORIGIN_X - 30
	local cityRight = ORIGIN_X + CITY_W + 30
	local channelCount = 0
	local bridgeCount = 0

	-- Water fill: Y=-4 to Y=2 → surface at Y=2, 6 studs deep, no flicker
	local WATER_Y = -1   -- center of fill
	local WATER_H = 6    -- height of fill
	local BANK_H  = 5    -- riverbank wall height
	local BANK_W  = 2    -- riverbank wall thickness

	local C_BANK = Color3.fromRGB(100, 95, 90)

	for _, h in ipairs(hLanes) do
		if h.type ~= "water" then continue end
		local z = GTAConfig.getRowEdgeZ(h.row)
		local w = getLaneWidth(h.type)

		-- Compute segments (skip compound zones)
		local skipRanges = {}
		for _, r in ipairs(GTAConfig.getCompoundRects()) do
			if z > r.z1 and z < r.z2 then
				table.insert(skipRanges, { r.x1, r.x2 })
			end
		end
		table.sort(skipRanges, function(a, b) return a[1] < b[1] end)

		local curX = cityLeft
		for _, skip in ipairs(skipRanges) do
			if curX < skip[1] then
				local segW = skip[1] - curX
				local cx = (curX + skip[1]) / 2

				-- Water fill (lower than ground, surface at Y=2)
				Terrain:FillBlock(CFrame.new(cx, WATER_Y, z), Vector3.new(segW, WATER_H, w), Enum.Material.Water)

				-- Riverbank walls (north + south edges)
				for _, sideZ in ipairs({-1, 1}) do
					local bankZ = z + sideZ * (w / 2 - BANK_W / 2)
					local bank = Instance.new("Part")
					bank.Name = "Riverbank"
					bank.Size = Vector3.new(segW, BANK_H, BANK_W)
					bank.Position = Vector3.new(cx, GROUND_Y - BANK_H / 2 + 1, bankZ)
					bank.Anchored = true
					bank.CanCollide = true
					bank.Material = Enum.Material.Slate
					bank.Color = C_BANK
					bank.Parent = DecorUtils.decorFolder
				end

				channelCount += 1
			end
			curX = math.max(curX, skip[2])
		end
		if curX < cityRight then
			local segW = cityRight - curX
			local cx = (curX + cityRight) / 2

			Terrain:FillBlock(CFrame.new(cx, WATER_Y, z), Vector3.new(segW, WATER_H, w), Enum.Material.Water)

			for _, sideZ in ipairs({-1, 1}) do
				local bankZ = z + sideZ * (w / 2 - BANK_W / 2)
				local bank = Instance.new("Part")
				bank.Name = "Riverbank"
				bank.Size = Vector3.new(segW, BANK_H, BANK_W)
				bank.Position = Vector3.new(cx, GROUND_Y - BANK_H / 2 + 1, bankZ)
				bank.Anchored = true
				bank.CanCollide = true
				bank.Material = Enum.Material.Slate
				bank.Color = C_BANK
				bank.Parent = DecorUtils.decorFolder
			end

			channelCount += 1
		end

		-- Place bridge blocks at V-lane crossings
		for _, v in ipairs(vLanes) do
			local vx = GTAConfig.getColEdgeX(v.col)
			local vw = getLaneWidth(v.type)
			if not GTAConfig.isInsideCompound(vx, z) then
				WaterBridge.create(vx, z, vw, w, 1)
				bridgeCount += 1
			end
		end
	end

	print("[CityBuilder] Water channel:", channelCount, "segments,", bridgeCount, "bridges")
end

--------------------------------------------------------------------------------
-- 5. ROAD MARKINGS (center lines + dashes on road surfaces)
--------------------------------------------------------------------------------

local DRIVEABLE_LANES = { road = true, highway = true }

local function buildRoadMarkings()
	local MARK_Y   = GROUND_Y + 1
	local C_YELLOW  = Color3.fromRGB(255, 200, 40)
	local C_WHITE   = Color3.fromRGB(240, 240, 240)
	local LINE_W    = 1
	local DASH_LEN  = 4
	local DASH_GAP  = 6
	local markCount = 0

	local compoundRects = GTAConfig.getCompoundRects()

	-- Non-driveable H-lane Z zones to skip for V-lane markings (railway, water)
	local nonDriveableZones = {}
	for _, h in ipairs(GTAConfig.H_LANES) do
		if not DRIVEABLE_LANES[h.type] then
			local z = GTAConfig.getRowEdgeZ(h.row)
			local w = getLaneWidth(h.type)
			table.insert(nonDriveableZones, { z - w / 2, z + w / 2 })
		end
	end

	--------------------------------------------------------------------
	-- A. H-LANE CENTER LINES (yellow, along X)
	--------------------------------------------------------------------
	for _, h in ipairs(GTAConfig.H_LANES) do
		if not DRIVEABLE_LANES[h.type] then continue end
		local z = GTAConfig.getRowEdgeZ(h.row)
		local cityLeft  = GTAConfig.CITY_ORIGIN_X
		local cityRight = GTAConfig.CITY_ORIGIN_X + CITY_W

		-- Skip compound zones
		local skipRanges = {}
		for _, r in ipairs(compoundRects) do
			if z > r.z1 and z < r.z2 then
				table.insert(skipRanges, { r.x1, r.x2 })
			end
		end
		table.sort(skipRanges, function(a, b) return a[1] < b[1] end)

		local curX = cityLeft
		for _, skip in ipairs(skipRanges) do
			if curX < skip[1] then
				local segLen = skip[1] - curX
				local cx = (curX + skip[1]) / 2
				local line = Instance.new("Part")
				line.Name = "CenterLine"
				line.Size = Vector3.new(segLen, 0.15, LINE_W)
				line.Position = Vector3.new(cx, MARK_Y, z)
				line.Anchored = true
				line.CanCollide = false
				line.Material = Enum.Material.Neon
				line.Color = C_YELLOW
				line.Parent = DecorUtils.decorFolder
				markCount += 1
			end
			curX = math.max(curX, skip[2])
		end
		if curX < cityRight then
			local segLen = cityRight - curX
			local cx = (curX + cityRight) / 2
			local line = Instance.new("Part")
			line.Name = "CenterLine"
			line.Size = Vector3.new(segLen, 0.15, LINE_W)
			line.Position = Vector3.new(cx, MARK_Y, z)
			line.Anchored = true
			line.CanCollide = false
			line.Material = Enum.Material.Neon
			line.Color = C_YELLOW
			line.Parent = DecorUtils.decorFolder
			markCount += 1
		end
	end

	--------------------------------------------------------------------
	-- B. V-LANE CENTER LINES (yellow, along Z)
	--------------------------------------------------------------------
	for _, v in ipairs(GTAConfig.V_LANES) do
		if not DRIVEABLE_LANES[v.type] then continue end
		local x = GTAConfig.getColEdgeX(v.col)
		local cityTop    = GTAConfig.CITY_ORIGIN_Z
		local cityBottom = GTAConfig.CITY_ORIGIN_Z + CITY_D

		-- Skip compound zones + non-driveable H-lane zones (railway, water)
		local skipRanges = {}
		for _, r in ipairs(compoundRects) do
			if x > r.x1 and x < r.x2 then
				table.insert(skipRanges, { r.z1, r.z2 })
			end
		end
		for _, zone in ipairs(nonDriveableZones) do
			table.insert(skipRanges, zone)
		end
		table.sort(skipRanges, function(a, b) return a[1] < b[1] end)

		local curZ = cityTop
		for _, skip in ipairs(skipRanges) do
			if curZ < skip[1] then
				local segLen = skip[1] - curZ
				local cz = (curZ + skip[1]) / 2
				local line = Instance.new("Part")
				line.Name = "CenterLine"
				line.Size = Vector3.new(LINE_W, 0.15, segLen)
				line.Position = Vector3.new(x, MARK_Y, cz)
				line.Anchored = true
				line.CanCollide = false
				line.Material = Enum.Material.Neon
				line.Color = C_YELLOW
				line.Parent = DecorUtils.decorFolder
				markCount += 1
			end
			curZ = math.max(curZ, skip[2])
		end
		if curZ < cityBottom then
			local segLen = cityBottom - curZ
			local cz = (curZ + cityBottom) / 2
			local line = Instance.new("Part")
			line.Name = "CenterLine"
			line.Size = Vector3.new(LINE_W, 0.15, segLen)
			line.Position = Vector3.new(x, MARK_Y, cz)
			line.Anchored = true
			line.CanCollide = false
			line.Material = Enum.Material.Neon
			line.Color = C_YELLOW
			line.Parent = DecorUtils.decorFolder
			markCount += 1
		end
	end

	--------------------------------------------------------------------
	-- C. HIGHWAY LANE DASHES (white, between lanes on same side)
	--------------------------------------------------------------------
	for _, h in ipairs(GTAConfig.H_LANES) do
		if h.type ~= "highway" then continue end
		local z = GTAConfig.getRowEdgeZ(h.row)
		local w = getLaneWidth(h.type)
		local quarterW = w / 4  -- offset for lane dividers
		local cityLeft  = GTAConfig.CITY_ORIGIN_X
		local cityRight = GTAConfig.CITY_ORIGIN_X + CITY_W

		for _, sideZ in ipairs({-1, 1}) do
			local dashZ = z + sideZ * quarterW
			for dx = cityLeft, cityRight, DASH_LEN + DASH_GAP do
				local dash = Instance.new("Part")
				dash.Name = "LaneDash"
				dash.Size = Vector3.new(DASH_LEN, 0.15, 0.4)
				dash.Position = Vector3.new(dx + DASH_LEN / 2, MARK_Y, dashZ)
				dash.Anchored = true
				dash.CanCollide = false
				dash.Material = Enum.Material.Neon
				dash.Color = C_WHITE
				dash.Parent = DecorUtils.decorFolder
			end
			markCount += 1
		end
	end

	for _, v in ipairs(GTAConfig.V_LANES) do
		if v.type ~= "highway" then continue end
		local x = GTAConfig.getColEdgeX(v.col)
		local w = getLaneWidth(v.type)
		local quarterW = w / 4
		local cityTop    = GTAConfig.CITY_ORIGIN_Z
		local cityBottom = GTAConfig.CITY_ORIGIN_Z + CITY_D

		for _, sideX in ipairs({-1, 1}) do
			local dashX = x + sideX * quarterW
			for dz = cityTop, cityBottom, DASH_LEN + DASH_GAP do
				local dash = Instance.new("Part")
				dash.Name = "LaneDash"
				dash.Size = Vector3.new(0.4, 0.15, DASH_LEN)
				dash.Position = Vector3.new(dashX, MARK_Y, dz + DASH_LEN / 2)
				dash.Anchored = true
				dash.CanCollide = false
				dash.Material = Enum.Material.Neon
				dash.Color = C_WHITE
				dash.Parent = DecorUtils.decorFolder
			end
			markCount += 1
		end
	end

	-- Debug: print first few marking positions
	local debugCount = 0
	for _, child in ipairs(DecorUtils.decorFolder:GetChildren()) do
		if child.Name == "CenterLine" and debugCount < 3 then
			print("[RoadMarkings] Line at", child.Position, "size", child.Size)
			debugCount += 1
		end
	end

	print("[CityBuilder] Road markings:", markCount)
end

--------------------------------------------------------------------------------
-- TRAFFIC LIGHTS AT INTERSECTIONS
--------------------------------------------------------------------------------

local function placeTrafficLights()
	local nodes = RoadNetwork.nodes
	local count = 0

	for _, node in pairs(nodes) do
		-- Only place lights at road×road intersections (skip highway perimeter)
		if node.hType == "highway" or node.vType == "highway" then continue end

		local ix, iz = node.x, node.z
		local hWidth = GTAConfig.LANE_TYPES[node.hType] and GTAConfig.LANE_TYPES[node.hType].width or 40
		local vWidth = GTAConfig.LANE_TYPES[node.vType] and GTAConfig.LANE_TYPES[node.vType].width or 40
		local cornerOff = 2  -- extra offset from road edge

		-- Four corners of the intersection, each with a pole light facing approaching traffic.
		-- NE corner: serves south-bound (faces north) and west-bound (faces east) traffic
		-- SE corner: serves north-bound (faces south) and east-bound (faces west) traffic
		-- SW corner: serves north-bound and west-bound — etc.
		-- Simplified: one pole per approach direction (4 lights total)

		local halfH = hWidth / 2 + cornerOff
		local halfV = vWidth / 2 + cornerOff

		-- Yaw convention: the light faces TOWARD approaching traffic.
		-- East-bound traffic approaches from west → light faces west (yaw = -π/2)
		-- etc. But CFrame rotation makes -Z the "look" direction, so:
		-- Serving east traffic → yaw = math.pi/2 (east in our convention, -Z face points west toward traffic)

		local approaches = {
			-- { pole X offset, pole Z offset, yaw (traffic direction served), trafficDir }
			{ halfV,  halfH, math.pi / 2, "H" },   -- NE corner, serves east-bound (H)
			{ halfV, -halfH, 0,            "V" },   -- SE corner, serves south-bound (V)
			{-halfV, -halfH, -math.pi / 2, "H" },   -- SW corner, serves west-bound (H)
			{-halfV,  halfH, math.pi,       "V" },   -- NW corner, serves north-bound (V)
		}

		for _, a in ipairs(approaches) do
			local model = TrafficLightBuilder.createPoleLight(ix + a[1], iz + a[2], a[3])
			if model then
				model:SetAttribute("TrafficDir", a[4])  -- "H" or "V" for phase toggling
				count += 1
			end
		end
	end

	print(string.format("[CityBuilder] Placed %d traffic lights at %d intersections",
		count, RoadNetwork.nodeCount))
end

--------------------------------------------------------------------------------
-- 6. POPULATE BLOCKS (place buildings from AssetLibrary)
--------------------------------------------------------------------------------

local function populateBlocks()
	local hLanes = GTAConfig.H_LANES
	local vLanes = GTAConfig.V_LANES
	local buildingCount = 0
	local MARGIN = 10 -- inset from block edge for building placement

	for i = 1, #hLanes - 1 do
		local topH = hLanes[i]
		local botH = hLanes[i + 1]
		local topZ = GTAConfig.getRowEdgeZ(topH.row) + getLaneWidth(topH.type) / 2
		local botZ = GTAConfig.getRowEdgeZ(botH.row) - getLaneWidth(botH.type) / 2
		local bandD = botZ - topZ
		if bandD <= 0 then continue end
		local bandCZ = (topZ + botZ) / 2

		for j = 1, #vLanes - 1 do
			local leftV = vLanes[j]
			local rightV = vLanes[j + 1]
			local leftX  = GTAConfig.getColEdgeX(leftV.col) + getLaneWidth(leftV.type) / 2
			local rightX = GTAConfig.getColEdgeX(rightV.col) - getLaneWidth(rightV.type) / 2
			local blockW = rightX - leftX
			if blockW <= 0 then continue end
			local blockCX = (leftX + rightX) / 2

			if GTAConfig.isInsideCompound(blockCX, bandCZ) then continue end

			local dist = getDistrictAt(blockCX, bandCZ)

			-- Available space for building placement
			local usableW = blockW - MARGIN * 2
			local usableD = bandD - MARGIN * 2
			if usableW < 20 or usableD < 20 then continue end

			----------------------------------------------------------------
			-- DOWNTOWN: skyscrapers
			----------------------------------------------------------------
			if dist == "downtown" then
				local styles = { "glass", "glass", "warm", "neon" } -- weighted toward glass
				local bDepth = 20  -- base depth per skyscraper

				-- How many skyscrapers fit along X?
				local gap = 2
				local numX = math.max(1, math.floor((usableW + gap) / (bDepth + gap)))
				local totalW = numX * bDepth + (numX - 1) * gap
				local startX = blockCX - totalW / 2 + bDepth / 2

				for bx = 1, numX do
					local cx = startX + (bx - 1) * (bDepth + gap)
					local style = styles[math.random(1, #styles)]
					local specIdx = math.random(1, AssetLibrary.getSkyscraperCount(style))

					AssetLibrary.createSkyscraper(cx, bandCZ, {
						style = style,
						specIndex = specIdx,
						scale = 1,
						depth = bDepth,
						parent = DecorUtils.decorFolder,
					})
					buildingCount += 1
				end
			end

			-- (other districts will be added as we extract more assets)
		end
	end

	print("[CityBuilder] Buildings placed:", buildingCount)
end

--------------------------------------------------------------------------------
-- POPULATE COMPOUNDS — landmark buildings in big open zones
--------------------------------------------------------------------------------

local function populateCompounds()
	local compoundRects = GTAConfig.getCompoundRects()
	local folder = DecorUtils.decorFolder
	local count = 0

	for _, rect in ipairs(compoundRects) do
		local cx = (rect.x1 + rect.x2) / 2
		local cz = (rect.z1 + rect.z2) / 2
		local w = rect.x2 - rect.x1
		local d = rect.z2 - rect.z1

		--------------------------------------------------------------------
		-- NUCLEAR
		--------------------------------------------------------------------
		------------------------------------------------------------
		-- Shared compound helpers
		------------------------------------------------------------

		-- Concrete pad to cover bumpy terrain
		local function makeCompoundPad(padColor, padMat)
			local padH = 1.5
			local padY = GROUND_Y + 3
			local pad = Instance.new("Part")
			pad.Name = "CompoundPad"
			pad.Size = Vector3.new(w - 4, padH, d - 4)
			pad.Position = Vector3.new(cx, padY + padH / 2, cz)
			pad.Anchored = true
			pad.Material = padMat or Enum.Material.Concrete
			pad.Color = padColor or Color3.fromRGB(80, 85, 80)
			pad.Parent = folder
			return padY + padH  -- top of pad = baseY
		end

		-- Perimeter fence with posts
		local function makePerimeterFence(baseY, opts)
			opts = opts or {}
			local fenceH = opts.height or 5
			local fenceColor = opts.color or Color3.fromRGB(130, 130, 135)
			local postColor = opts.postColor or Color3.fromRGB(110, 110, 115)
			local margin = opts.margin or 5
			local transp = opts.transparency or 0.3
			local postSpacing = opts.postSpacing or 20

			local fx1 = rect.x1 + margin
			local fx2 = rect.x2 - margin
			local fz1 = rect.z1 + margin
			local fz2 = rect.z2 - margin

			local segments = {
				{ size = Vector3.new(fx2 - fx1, fenceH, 0.3), pos = Vector3.new(cx, baseY + fenceH / 2, fz1) },
				{ size = Vector3.new(fx2 - fx1, fenceH, 0.3), pos = Vector3.new(cx, baseY + fenceH / 2, fz2) },
				{ size = Vector3.new(0.3, fenceH, fz2 - fz1), pos = Vector3.new(fx1, baseY + fenceH / 2, cz) },
				{ size = Vector3.new(0.3, fenceH, fz2 - fz1), pos = Vector3.new(fx2, baseY + fenceH / 2, cz) },
			}
			for _, seg in ipairs(segments) do
				local fence = Instance.new("Part")
				fence.Name = "CompoundFence"
				fence.Size = seg.size
				fence.Position = seg.pos
				fence.Anchored = true
				fence.Material = Enum.Material.Metal
				fence.Color = fenceColor
				fence.Transparency = transp
				fence.Parent = folder
			end

			local function addPosts(x1, z1, x2, z2)
				local dx = x2 - x1
				local dz = z2 - z1
				local len = math.sqrt(dx * dx + dz * dz)
				local numPosts = math.max(2, math.floor(len / postSpacing))
				for i = 0, numPosts do
					local t = i / numPosts
					local post = Instance.new("Part")
					post.Name = "FencePost"
					post.Size = Vector3.new(0.5, fenceH + 1, 0.5)
					post.Position = Vector3.new(x1 + dx * t, baseY + (fenceH + 1) / 2, z1 + dz * t)
					post.Anchored = true
					post.Material = Enum.Material.Metal
					post.Color = postColor
					post.Parent = folder
				end
			end
			addPosts(fx1, fz1, fx2, fz1)
			addPosts(fx1, fz2, fx2, fz2)
			addPosts(fx1, fz1, fx1, fz2)
			addPosts(fx2, fz1, fx2, fz2)

			return fx1, fz1, fx2, fz2, fenceH
		end

		-- Warning/info signs on fence
		local function makeFenceSigns(baseY, fenceH, fx1, fz1, fx2, fz2, text, signColor)
			local signW = 8
			local signH = 2
			signColor = signColor or Color3.fromRGB(255, 200, 0)
			local signDefs = {
				{ pos = Vector3.new(cx, baseY + fenceH + signH / 2 + 0.5, fz1), face = "Front" },
				{ pos = Vector3.new(cx, baseY + fenceH + signH / 2 + 0.5, fz2), face = "Back" },
				{ pos = Vector3.new(fx1, baseY + fenceH + signH / 2 + 0.5, cz), face = "Right" },
				{ pos = Vector3.new(fx2, baseY + fenceH + signH / 2 + 0.5, cz), face = "Left" },
			}
			for _, sd in ipairs(signDefs) do
				local isZFace = (sd.face == "Front" or sd.face == "Back")
				local signPart = Instance.new("Part")
				signPart.Name = "WarningSign"
				signPart.Size = isZFace and Vector3.new(signW, signH, 0.3) or Vector3.new(0.3, signH, signW)
				signPart.Position = sd.pos
				signPart.Anchored = true
				signPart.Material = Enum.Material.Neon
				signPart.Color = signColor
				signPart.Parent = folder

				local gui = Instance.new("SurfaceGui")
				gui.Face = Enum.NormalId[sd.face]
				gui.Parent = signPart

				local lbl = Instance.new("TextLabel")
				lbl.Size = UDim2.new(1, 0, 1, 0)
				lbl.BackgroundTransparency = 1
				lbl.Text = text
				lbl.TextColor3 = Color3.fromRGB(30, 30, 30)
				lbl.TextScaled = true
				lbl.Font = Enum.Font.GothamBold
				lbl.Parent = gui
			end
		end

		------------------------------------------------------------
		-- NUCLEAR
		------------------------------------------------------------
		if rect.name == "nuclear" then
			local baseY = makeCompoundPad(Color3.fromRGB(80, 85, 80))

			AssetLibrary.createNuclearPlant(cx, cz, {
				parent = folder,
				scale = 1,
				baseY = baseY,
			})

			local fx1, fz1, fx2, fz2, fenceH = makePerimeterFence(baseY)
			makeFenceSigns(baseY, fenceH, fx1, fz1, fx2, fz2, "RESTRICTED AREA")

			count += 1

		------------------------------------------------------------
		-- PRISON
		------------------------------------------------------------
		elseif rect.name == "prison" then
			local baseY = makeCompoundPad(Color3.fromRGB(95, 90, 85))

			-- Tall perimeter fence (14 studs like DashOrCrash)
			local fx1, fz1, fx2, fz2, fenceH = makePerimeterFence(baseY, {
				height = 14,
				color = Color3.fromRGB(140, 140, 145),
				postColor = Color3.fromRGB(120, 115, 110),
				margin = 8,
				transparency = 0.4,
				postSpacing = 15,
			})
			makeFenceSigns(baseY, fenceH, fx1, fz1, fx2, fz2,
				"FEDERAL STATE PRISON", Color3.fromRGB(255, 60, 30))

			-- Guard towers at 4 corners
			local towerW = 6
			local towerH = 20
			local cabinH = 5
			local corners = {
				{ x = fx1, z = fz1 },
				{ x = fx2, z = fz1 },
				{ x = fx1, z = fz2 },
				{ x = fx2, z = fz2 },
			}
			for _, c in ipairs(corners) do
				-- Tower shaft
				local shaft = Instance.new("Part")
				shaft.Name = "GuardTowerShaft"
				shaft.Size = Vector3.new(towerW * 0.4, towerH, towerW * 0.4)
				shaft.Position = Vector3.new(c.x, baseY + towerH / 2, c.z)
				shaft.Anchored = true
				shaft.Material = Enum.Material.Concrete
				shaft.Color = Color3.fromRGB(130, 125, 120)
				shaft.Parent = folder

				-- Cabin
				local cabin = Instance.new("Part")
				cabin.Name = "GuardTowerCabin"
				cabin.Size = Vector3.new(towerW, cabinH, towerW)
				cabin.Position = Vector3.new(c.x, baseY + towerH + cabinH / 2, c.z)
				cabin.Anchored = true
				cabin.Material = Enum.Material.Concrete
				cabin.Color = Color3.fromRGB(120, 115, 110)
				cabin.Parent = folder

				-- Cabin windows (glass)
				for _, face in ipairs({
					{ size = Vector3.new(towerW + 0.1, cabinH * 0.6, 0.15), pos = Vector3.new(c.x, baseY + towerH + cabinH * 0.6, c.z + towerW / 2) },
					{ size = Vector3.new(towerW + 0.1, cabinH * 0.6, 0.15), pos = Vector3.new(c.x, baseY + towerH + cabinH * 0.6, c.z - towerW / 2) },
					{ size = Vector3.new(0.15, cabinH * 0.6, towerW + 0.1), pos = Vector3.new(c.x + towerW / 2, baseY + towerH + cabinH * 0.6, c.z) },
					{ size = Vector3.new(0.15, cabinH * 0.6, towerW + 0.1), pos = Vector3.new(c.x - towerW / 2, baseY + towerH + cabinH * 0.6, c.z) },
				}) do
					local glass = Instance.new("Part")
					glass.Name = "TowerWindow"
					glass.Size = face.size
					glass.Position = face.pos
					glass.Anchored = true
					glass.Material = Enum.Material.Glass
					glass.Color = Color3.fromRGB(180, 200, 210)
					glass.Transparency = 0.4
					glass.Parent = folder
				end

				-- Roof
				local roof = Instance.new("Part")
				roof.Name = "GuardTowerRoof"
				roof.Size = Vector3.new(towerW + 2, 0.5, towerW + 2)
				roof.Position = Vector3.new(c.x, baseY + towerH + cabinH + 0.25, c.z)
				roof.Anchored = true
				roof.Material = Enum.Material.Metal
				roof.Color = Color3.fromRGB(70, 70, 75)
				roof.Parent = folder

				-- Searchlight
				local lightPart = Instance.new("Part")
				lightPart.Name = "Searchlight"
				lightPart.Size = Vector3.new(1.5, 1, 1.5)
				lightPart.Position = Vector3.new(c.x, baseY + towerH + cabinH + 1, c.z)
				lightPart.Anchored = true
				lightPart.Material = Enum.Material.Metal
				lightPart.Color = Color3.fromRGB(60, 60, 65)
				lightPart.Parent = folder

				local spot = Instance.new("SpotLight")
				spot.Face = Enum.NormalId.Bottom
				spot.Angle = 60
				spot.Range = 50
				spot.Brightness = 3
				spot.Color = Color3.fromRGB(255, 230, 180)
				spot.Parent = lightPart
			end

			-- Prison gate on south side (+Z face, closest to central city)
			local gateW = 16
			local gateH = fenceH + 2
			local gatePillarW = 2.5
			local gateZ = fz2

			for _, side in ipairs({ -1, 1 }) do
				local pillarX = cx + side * (gateW / 2 + gatePillarW / 2)

				-- Gate pillar
				local pillar = Instance.new("Part")
				pillar.Name = "GatePillar"
				pillar.Size = Vector3.new(gatePillarW, gateH, gatePillarW)
				pillar.Position = Vector3.new(pillarX, baseY + gateH / 2, gateZ)
				pillar.Anchored = true
				pillar.Material = Enum.Material.Concrete
				pillar.Color = Color3.fromRGB(110, 105, 100)
				pillar.Parent = folder

				-- Warning stripes on pillar
				for stripe = 0, 3 do
					local stripeColor = (stripe % 2 == 0) and Color3.fromRGB(200, 180, 30) or Color3.fromRGB(180, 40, 30)
					local sp = Instance.new("Part")
					sp.Name = "PillarStripe"
					sp.Size = Vector3.new(gatePillarW + 0.1, 1.2, gatePillarW + 0.1)
					sp.Position = Vector3.new(pillarX, baseY + 2 + stripe * 2.5, gateZ)
					sp.Anchored = true
					sp.CanCollide = false
					sp.Material = Enum.Material.SmoothPlastic
					sp.Color = stripeColor
					sp.Parent = folder
				end

				-- Security light on cap
				local capLight = Instance.new("Part")
				capLight.Name = "GateLight"
				capLight.Shape = Enum.PartType.Ball
				capLight.Size = Vector3.new(1.5, 1.5, 1.5)
				capLight.Position = Vector3.new(pillarX, baseY + gateH + 1, gateZ)
				capLight.Anchored = true
				capLight.Material = Enum.Material.Neon
				capLight.Color = Color3.fromRGB(255, 200, 120)
				capLight.Parent = folder

				local pl = Instance.new("PointLight")
				pl.Brightness = 2
				pl.Range = 16
				pl.Color = Color3.fromRGB(255, 200, 120)
				pl.Parent = capLight
			end

			-- Gate crossbar with sign
			local crossbar = Instance.new("Part")
			crossbar.Name = "GateCrossbar"
			crossbar.Size = Vector3.new(gateW + gatePillarW * 2, 2, 1.5)
			crossbar.Position = Vector3.new(cx, baseY + gateH + 0.5, gateZ)
			crossbar.Anchored = true
			crossbar.Material = Enum.Material.Metal
			crossbar.Color = Color3.fromRGB(80, 80, 85)
			crossbar.Parent = folder

			local gateGui = Instance.new("SurfaceGui")
			gateGui.Face = Enum.NormalId.Front
			gateGui.Parent = crossbar

			local gateTxt = Instance.new("TextLabel")
			gateTxt.Size = UDim2.new(1, 0, 1, 0)
			gateTxt.BackgroundTransparency = 1
			gateTxt.Font = Enum.Font.GothamBold
			gateTxt.Text = "FEDERAL STATE PRISON"
			gateTxt.TextColor3 = Color3.fromRGB(255, 60, 30)
			gateTxt.TextScaled = true
			gateTxt.Parent = gateGui

			-- Back face too
			local gateGui2 = Instance.new("SurfaceGui")
			gateGui2.Face = Enum.NormalId.Back
			gateGui2.Parent = crossbar
			local gateTxt2 = gateTxt:Clone()
			gateTxt2.Parent = gateGui2

			-- Cell blocks — 4 buildings arranged in the compound
			-- Prison rect is ~320W × 680D, so we have room for a grid
			local buildingSpots = {
				{ x = cx - 50, z = cz - 120 },
				{ x = cx + 50, z = cz - 120 },
				{ x = cx - 50, z = cz + 40 },
				{ x = cx + 50, z = cz + 40 },
				{ x = cx,      z = cz - 40 },   -- center block
				{ x = cx,      z = cz + 160 },   -- near gate
			}
			for _, spot in ipairs(buildingSpots) do
				AssetLibrary.createPrisonBuilding(spot.x, spot.z, {
					parent = folder,
					scale = 1,
					baseY = baseY,
				})
			end

			-- Exercise yard (flat concrete area between buildings)
			local yard = Instance.new("Part")
			yard.Name = "ExerciseYard"
			yard.Size = Vector3.new(80, 0.2, 60)
			yard.Position = Vector3.new(cx, baseY + 0.1, cz - 40)
			yard.Anchored = true
			yard.Material = Enum.Material.Concrete
			yard.Color = Color3.fromRGB(140, 135, 130)
			yard.Parent = folder

			-- Yard court markings
			local marking = Instance.new("Part")
			marking.Name = "CourtMarking"
			marking.Size = Vector3.new(40, 0.05, 30)
			marking.Position = Vector3.new(cx, baseY + 0.25, cz - 40)
			marking.Anchored = true
			marking.CanCollide = false
			marking.Material = Enum.Material.SmoothPlastic
			marking.Color = Color3.fromRGB(200, 200, 200)
			marking.Transparency = 0.7
			marking.Parent = folder

			-- Floodlight poles inside compound (between buildings)
			local floodPositions = {
				{ x = cx - 70, z = cz - 60 },
				{ x = cx + 70, z = cz - 60 },
				{ x = cx - 70, z = cz + 100 },
				{ x = cx + 70, z = cz + 100 },
				{ x = cx,      z = cz + 80 },
			}
			local poleH = 16
			for _, fp in ipairs(floodPositions) do
				local pole = Instance.new("Part")
				pole.Name = "FloodlightPole"
				pole.Size = Vector3.new(0.8, poleH, 0.8)
				pole.Position = Vector3.new(fp.x, baseY + poleH / 2, fp.z)
				pole.Anchored = true
				pole.Material = Enum.Material.Metal
				pole.Color = Color3.fromRGB(90, 90, 95)
				pole.Parent = folder

				local fixture = Instance.new("Part")
				fixture.Name = "FloodlightFixture"
				fixture.Size = Vector3.new(2, 1, 2)
				fixture.Position = Vector3.new(fp.x, baseY + poleH + 0.5, fp.z)
				fixture.Anchored = true
				fixture.Material = Enum.Material.Metal
				fixture.Color = Color3.fromRGB(60, 60, 65)
				fixture.Parent = folder

				local spot = Instance.new("SpotLight")
				spot.Face = Enum.NormalId.Bottom
				spot.Angle = 70
				spot.Range = 40
				spot.Brightness = 2.5
				spot.Color = Color3.fromRGB(255, 230, 180)
				spot.Parent = fixture
			end

			count += 1
		end
	end

	print("[CityBuilder] Compounds populated:", count)
end

--------------------------------------------------------------------------------
-- TELEPORT PADS — one per district, at a safe sidewalk corner
--------------------------------------------------------------------------------

-- District neon colors (match district identity)
local PAD_COLORS = {
	downtown     = Color3.fromRGB(0, 140, 255),
	commercial   = Color3.fromRGB(255, 200, 50),
	government   = Color3.fromRGB(220, 220, 240),
	prison       = Color3.fromRGB(255, 80, 40),
	residential  = Color3.fromRGB(80, 220, 100),
	airport      = Color3.fromRGB(150, 150, 170),
	industrial   = Color3.fromRGB(200, 140, 60),
	power_plant  = Color3.fromRGB(255, 180, 40),
	military     = Color3.fromRGB(60, 140, 50),
	nuclear      = Color3.fromRGB(0, 255, 80),
	harbor       = Color3.fromRGB(140, 120, 80),
	water_plant  = Color3.fromRGB(40, 180, 220),
	waterfront   = Color3.fromRGB(80, 200, 240),
	beach        = Color3.fromRGB(255, 220, 100),
	space        = Color3.fromRGB(140, 100, 255),
}

-- Display names for signs
local PAD_NAMES = {
	downtown     = "DOWNTOWN",
	commercial   = "COMMERCIAL",
	government   = "GOVERNMENT",
	prison       = "PRISON",
	residential  = "RESIDENTIAL",
	airport      = "AIRPORT",
	industrial   = "INDUSTRIAL",
	power_plant  = "POWER PLANT",
	military     = "MILITARY",
	nuclear      = "NUCLEAR",
	harbor       = "HARBOR",
	water_plant  = "WATER PLANT",
	waterfront   = "WATERFRONT",
	beach        = "BEACH",
	space        = "SPACE CENTER",
}

-- Store pad positions so DebugMenu can teleport to exact spot
CityBuilder.teleportPads = {} -- { [districtName] = Vector3 }

local function placeTeleportPads()
	local folder = DecorUtils.decorFolder
	local count = 0

	for _, dist in ipairs(GTAConfig.DISTRICTS) do
		-- Find the nearest road intersection corner inside this district
		-- Place pad at colMin edge + offset, rowMin edge + offset (top-left corner)
		local edgeCol = dist.colMin
		local edgeRow = dist.rowMin

		-- World position of the intersection center
		local intX = GTAConfig.getColEdgeX(edgeCol)
		local intZ = GTAConfig.getRowEdgeZ(edgeRow)

		-- Offset into the block (away from road center), on the sidewalk
		-- +X and +Z to be inside the district, not outside it
		local SIDEWALK_OFFSET = 28  -- road half-width(20) + 8 studs onto sidewalk
		local padX = intX + SIDEWALK_OFFSET
		local padZ = intZ + SIDEWALK_OFFSET

		-- For compound zones, use a higher baseY (above concrete pad)
		local padBaseY = GROUND_Y
		if GTAConfig.COMPOUND_DISTRICTS[dist.name] then
			padBaseY = GROUND_Y + 3 + 1.5  -- match compound pad top
		end

		local padModel, animData = AssetLibrary.createTeleportPad(padX, padZ, {
			parent = folder,
			scale = 1,
			districtName = PAD_NAMES[dist.name] or dist.name:upper(),
			color = PAD_COLORS[dist.name] or Color3.fromRGB(0, 180, 255),
			baseY = padBaseY,
		})

		-- Store landing position (top of platform + 3 studs clearance)
		CityBuilder.teleportPads[dist.name] = Vector3.new(padX, padBaseY + 3, padZ)
		count += 1
	end

	print("[CityBuilder] Teleport pads placed:", count)
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

	print("[CityBuilder] === Building city ===")

	buildFoundation()
	buildSurface()
	buildRailwayTracks()
	buildWaterChannel()
	RoadNetwork.build()
	placeTrafficLights()
	populateBlocks()
	populateCompounds()
	placeTeleportPads()

	print("[CityBuilder] === City complete! ===")
end

return CityBuilder
