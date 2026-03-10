-- RoadNetwork.luau
-- Builds a waypoint graph from GTAConfig's road grid.
-- Intersections = nodes, road segments = edges.
-- Used by VehicleTraffic for NPC driving + pathfinding.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared", 10)
local GTAConfig = require(Shared:WaitForChild("GTAConfig"))

local RoadNetwork = {}
RoadNetwork.nodes = {}
RoadNetwork.nodeCount = 0
RoadNetwork.connectionCount = 0

-- Driveable lane types (vehicles can use these)
local DRIVEABLE = { road = true, highway = true }

local function getLaneWidth(laneType)
	local def = GTAConfig.LANE_TYPES[laneType]
	return def and def.width or GTAConfig.STREET_WIDTH
end

--------------------------------------------------------------------------------
-- BUILD GRAPH
--------------------------------------------------------------------------------

function RoadNetwork.build()
	local nodes = {}

	-- Collect driveable H-lanes and V-lanes
	local hLanes = {}
	for _, h in ipairs(GTAConfig.H_LANES) do
		if DRIVEABLE[h.type] then
			table.insert(hLanes, h)
		end
	end

	local vLanes = {}
	for _, v in ipairs(GTAConfig.V_LANES) do
		if DRIVEABLE[v.type] then
			table.insert(vLanes, v)
		end
	end

	-- Create intersection nodes (where driveable H-lane crosses driveable V-lane)
	for _, h in ipairs(hLanes) do
		local z = GTAConfig.getRowEdgeZ(h.row)
		for _, v in ipairs(vLanes) do
			local x = GTAConfig.getColEdgeX(v.col)
			if not GTAConfig.isInsideCompound(x, z) then
				local id = string.format("r%d_c%d", h.row, v.col)
				nodes[id] = {
					id = id,
					x = x, z = z,
					row = h.row, col = v.col,
					hType = h.type, vType = v.type,
					connections = {},
				}
			end
		end
	end

	-- Connect along H-lanes (east-west)
	for _, h in ipairs(hLanes) do
		-- Gather nodes on this row, sorted by X
		local rowNodes = {}
		for _, v in ipairs(vLanes) do
			local id = string.format("r%d_c%d", h.row, v.col)
			if nodes[id] then
				table.insert(rowNodes, nodes[id])
			end
		end
		table.sort(rowNodes, function(a, b) return a.x < b.x end)

		for i = 1, #rowNodes - 1 do
			local from = rowNodes[i]
			local to = rowNodes[i + 1]
			local length = to.x - from.x

			table.insert(from.connections, {
				node = to, dir = "east", length = length, laneType = h.type,
			})
			table.insert(to.connections, {
				node = from, dir = "west", length = length, laneType = h.type,
			})
		end
	end

	-- Connect along V-lanes (north-south)
	for _, v in ipairs(vLanes) do
		-- Gather nodes on this column, sorted by Z
		local colNodes = {}
		for _, h in ipairs(hLanes) do
			local id = string.format("r%d_c%d", h.row, v.col)
			if nodes[id] then
				table.insert(colNodes, nodes[id])
			end
		end
		table.sort(colNodes, function(a, b) return a.z < b.z end)

		for i = 1, #colNodes - 1 do
			local from = colNodes[i]
			local to = colNodes[i + 1]
			local length = to.z - from.z

			table.insert(from.connections, {
				node = to, dir = "south", length = length, laneType = v.type,
			})
			table.insert(to.connections, {
				node = from, dir = "north", length = length, laneType = v.type,
			})
		end
	end

	RoadNetwork.nodes = nodes

	-- Stats
	local nCount, cCount = 0, 0
	for _, n in pairs(nodes) do
		nCount += 1
		cCount += #n.connections
	end
	RoadNetwork.nodeCount = nCount
	RoadNetwork.connectionCount = cCount

	print(string.format("[RoadNetwork] %d intersections, %d connections", nCount, cCount))
	return nodes
end

--------------------------------------------------------------------------------
-- LANE HELPERS
--------------------------------------------------------------------------------

-- Lane offset from road center for right-hand driving.
-- Returns the perpendicular offset (Z for H-lanes, X for V-lanes).
-- East/West travel → offset in Z. North/South travel → offset in X.
function RoadNetwork.getLaneOffset(direction, laneType)
	local width = getLaneWidth(laneType)
	local offset = width / 4  -- center of one lane (half the road = one lane)

	-- Right-hand traffic:
	if direction == "east"  then return  offset end  -- south half (+Z)
	if direction == "west"  then return -offset end  -- north half (-Z)
	if direction == "south" then return -offset end  -- west half (-X)
	if direction == "north" then return  offset end  -- east half (+X)
	return 0
end

-- World position for a point along a segment.
-- progress: 0 = at fromNode, 1 = at toNode.
function RoadNetwork.getPosition(fromNode, toNode, progress, direction, laneType)
	local x = fromNode.x + (toNode.x - fromNode.x) * progress
	local z = fromNode.z + (toNode.z - fromNode.z) * progress
	local offset = RoadNetwork.getLaneOffset(direction, laneType)

	if direction == "east" or direction == "west" then
		z = z + offset
	else
		x = x + offset
	end

	return x, z
end

-- CFrame for a vehicle facing its travel direction.
function RoadNetwork.getVehicleCFrame(x, z, direction)
	local y = GTAConfig.GROUND_Y + 2
	if direction == "east"  then return CFrame.new(x, y, z) * CFrame.Angles(0,  math.pi / 2, 0) end
	if direction == "west"  then return CFrame.new(x, y, z) * CFrame.Angles(0, -math.pi / 2, 0) end
	if direction == "south" then return CFrame.new(x, y, z) end
	if direction == "north" then return CFrame.new(x, y, z) * CFrame.Angles(0,  math.pi, 0) end
	return CFrame.new(x, y, z)
end

-- Pick a random connection from a node (for NPC vehicles at intersections).
-- Optionally exclude a direction (to avoid U-turns).
function RoadNetwork.pickRandomConnection(node, excludeDir)
	local options = {}
	for _, conn in ipairs(node.connections) do
		if conn.dir ~= excludeDir then
			table.insert(options, conn)
		end
	end
	if #options == 0 then
		-- Dead end: allow U-turn
		return node.connections[math.random(#node.connections)]
	end
	return options[math.random(#options)]
end

-- Get the opposite direction (for U-turn exclusion).
function RoadNetwork.oppositeDir(dir)
	if dir == "east"  then return "west" end
	if dir == "west"  then return "east" end
	if dir == "north" then return "south" end
	if dir == "south" then return "north" end
	return nil
end

-- Get a random node to spawn a vehicle.
function RoadNetwork.getRandomNode()
	local keys = {}
	for id in pairs(RoadNetwork.nodes) do
		table.insert(keys, id)
	end
	if #keys == 0 then return nil end
	return RoadNetwork.nodes[keys[math.random(#keys)]]
end

return RoadNetwork
