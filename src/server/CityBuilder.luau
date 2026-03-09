-- CityBuilder.luau
-- Tiled grid: lanes + blocks, ZERO overlap (same as DashOrCrash).
-- Compound zones (airport, military, etc.) are big open blocks with no internal roads.

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared", 10)
local GTAConfig = require(Shared:WaitForChild("GTAConfig"))
local DecorCreation = require(script.Parent:WaitForChild("DecorCreation"))
local DecorUtils = require(script.Parent:WaitForChild("DecorCreation"):WaitForChild("decor"):WaitForChild("DecorUtils"))

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

-- Compound zones: no internal roads, one big open block
local COMPOUND = {
	airport = true,
	military = true,
	nuclear = true,
	power_plant = true,
	prison = true,
	space = true,
	water_plant = true,
	beach = true,
}

--------------------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------------------

local function getLaneWidth(laneType)
	if laneType == "highway" then return HIGHWAY_W end
	return ROAD_W
end

local function fillSurface(cx, cz, w, d, material)
	Terrain:FillBlock(CFrame.new(cx, SURFACE_CY, cz), Vector3.new(w, SURFACE_H, d), material)
end

local function getDistrictAt(worldX, worldZ)
	local col = math.clamp(math.floor((worldX - ORIGIN_X) / CELL), 0, GTAConfig.GRID_COLS - 1)
	local row = math.clamp(math.floor((worldZ - ORIGIN_Z) / CELL), 0, GTAConfig.GRID_ROWS - 1)
	return GTAConfig.getDistrict(col, row)
end

--------------------------------------------------------------------------------
-- COMPOUND RECTANGLES
-- Each compound district gets one big fill from boundary-lane inner edges.
-- Boundary lanes = the V-lanes/H-lanes at the district edges.
--------------------------------------------------------------------------------

local compoundRects = {}

local function computeCompoundRects()
	local hLanes = GTAConfig.H_LANES
	local vLanes = GTAConfig.V_LANES

	for _, d in ipairs(GTAConfig.DISTRICTS) do
		if not COMPOUND[d.name] then continue end

		-- Find boundary V-lanes (left: last V-lane at or before colMin, right: first V-lane at or after colMax+1)
		local leftVCol, leftVW, rightVCol, rightVW = nil, 0, nil, 0
		for _, v in ipairs(vLanes) do
			if v.col <= d.colMin then
				leftVCol = v.col
				leftVW = getLaneWidth(v.type)
			end
		end
		for _, v in ipairs(vLanes) do
			if v.col >= d.colMax + 1 and not rightVCol then
				rightVCol = v.col
				rightVW = getLaneWidth(v.type)
			end
		end

		-- Find boundary H-lanes (top: last H-lane at or before rowMin, bottom: first H-lane at or after rowMax+1)
		local topHRow, topHW, botHRow, botHW = nil, 0, nil, 0
		for _, h in ipairs(hLanes) do
			if h.row <= d.rowMin then
				topHRow = h.row
				topHW = getLaneWidth(h.type)
			end
		end
		for _, h in ipairs(hLanes) do
			if h.row >= d.rowMax + 1 and not botHRow then
				botHRow = h.row
				botHW = getLaneWidth(h.type)
			end
		end

		if not (leftVCol and rightVCol and topHRow and botHRow) then continue end

		local rect = {
			x1 = GTAConfig.getColEdgeX(leftVCol) + leftVW / 2,
			x2 = GTAConfig.getColEdgeX(rightVCol) - rightVW / 2,
			z1 = GTAConfig.getRowEdgeZ(topHRow) + topHW / 2,
			z2 = GTAConfig.getRowEdgeZ(botHRow) - botHW / 2,
			material = DISTRICT_TERRAIN[d.name] or Enum.Material.Grass,
		}

		if rect.x2 > rect.x1 and rect.z2 > rect.z1 then
			table.insert(compoundRects, rect)
		end
	end
end

local function isInsideCompound(cx, cz)
	for _, r in ipairs(compoundRects) do
		if cx > r.x1 and cx < r.x2 and cz > r.z1 and cz < r.z2 then
			return true
		end
	end
	return false
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

	--------------------------------------------------------------------
	-- A. COMPOUND ZONES (big open blocks, no roads inside)
	--------------------------------------------------------------------
	for _, r in ipairs(compoundRects) do
		fillSurface((r.x1 + r.x2) / 2, (r.z1 + r.z2) / 2, r.x2 - r.x1, r.z2 - r.z1, r.material)
		blockCount += 1
	end

	--------------------------------------------------------------------
	-- B. H-LANE STRIPS (segmented around compound zones)
	--------------------------------------------------------------------
	for _, h in ipairs(hLanes) do
		local z = GTAConfig.getRowEdgeZ(h.row)
		local w = getLaneWidth(h.type)

		-- Collect X ranges to skip (compound zones that this H-lane passes through)
		local skipRanges = {}
		for _, r in ipairs(compoundRects) do
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
				fillSurface((curX + skip[1]) / 2, z, segW, w, Enum.Material.Asphalt)
				laneCount += 1
			end
			curX = math.max(curX, skip[2])
		end
		if curX < cityRight then
			local segW = cityRight - curX
			fillSurface((curX + cityRight) / 2, z, segW, w, Enum.Material.Asphalt)
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
			if not isInsideCompound(x, bandCZ) then
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

			if not isInsideCompound(blockCX, bandCZ) then
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
-- PUBLIC API
--------------------------------------------------------------------------------

function CityBuilder.build(decorFolderRef, vehicleFolderRef, npcFolderRef)
	DecorUtils.decorFolder = decorFolderRef

	local worldFolder = Workspace:FindFirstChild("World") or Workspace
	roadFolder = Instance.new("Folder")
	roadFolder.Name = "Roads"
	roadFolder.Parent = worldFolder

	print("[CityBuilder] === Building city ===")

	computeCompoundRects()
	buildFoundation()
	buildSurface()

	print("[CityBuilder] === City complete! ===")
end

return CityBuilder
