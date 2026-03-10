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
local RoadNetwork = require(script.Parent:WaitForChild("RoadNetwork"))

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

	print("[CityBuilder] === City complete! ===")
end

return CityBuilder
