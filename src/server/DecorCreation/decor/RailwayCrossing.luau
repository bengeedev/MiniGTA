-- RailwayCrossing.luau
-- Level crossing block: where a road/highway crosses a railway track.
-- Self-contained prefab with road surface, rails, gates, signs.

local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local RailwayCrossing = {}

function RailwayCrossing.create(x, z, roadWidth, scale)
	if not DecorUtils.decorFolder then return nil end
	scale = scale or 1

	local TERRAIN_TOP = DecorUtils.TERRAIN_TOP
	local terrainOffset = 2
	local surfaceY = TERRAIN_TOP + terrainOffset

	local railGauge = 4 * scale
	local railHeight = 1 * scale
	local railWidth = 0.6 * scale
	local sleeperHeight = 0.4 * scale
	local railY = surfaceY + sleeperHeight + railHeight / 2

	-- Colors
	local C_RAIL    = Color3.fromRGB(160, 155, 150)
	local C_ASPHALT = Color3.fromRGB(50, 50, 55)
	local C_RED     = Color3.fromRGB(200, 40, 40)
	local C_WHITE   = Color3.fromRGB(240, 240, 240)
	local C_YELLOW  = Color3.fromRGB(255, 220, 40)
	local C_POLE    = Color3.fromRGB(80, 80, 85)

	local model = Instance.new("Model")
	model.Name = "RailwayCrossing"

	---------------------------------------------------------------------------
	-- 1. ROAD SURFACE (asphalt strip crossing the tracks)
	---------------------------------------------------------------------------
	local road = Instance.new("Part")
	road.Name = "CrossingRoad"
	road.Size = Vector3.new(roadWidth, 0.3, railGauge * 2 + 6)
	road.Position = Vector3.new(x, surfaceY + 0.15, z)
	road.Anchored = true
	road.CanCollide = false
	road.Material = Enum.Material.Asphalt
	road.Color = C_ASPHALT
	road.Parent = model

	---------------------------------------------------------------------------
	-- 2. RAILS continuing through the crossing (no sleepers here)
	---------------------------------------------------------------------------
	for _, side in ipairs({-1, 1}) do
		local rail = Instance.new("Part")
		rail.Name = "CrossingRail"
		rail.Size = Vector3.new(roadWidth, railHeight, railWidth)
		rail.Position = Vector3.new(x, railY, z + side * railGauge)
		rail.Anchored = true
		rail.CanCollide = false
		rail.Material = Enum.Material.Metal
		rail.Color = C_RAIL
		rail.Parent = model
	end

	---------------------------------------------------------------------------
	-- 3. YELLOW WARNING LINES on road (before and after the rails)
	---------------------------------------------------------------------------
	for _, side in ipairs({-1, 1}) do
		local line = Instance.new("Part")
		line.Name = "WarningLine"
		line.Size = Vector3.new(roadWidth * 0.9, 0.05, 0.5 * scale)
		line.Position = Vector3.new(x, surfaceY + 0.35, z + side * (railGauge + 3))
		line.Anchored = true
		line.CanCollide = false
		line.Material = Enum.Material.SmoothPlastic
		line.Color = C_YELLOW
		line.Parent = model
	end

	---------------------------------------------------------------------------
	-- 4. CROSSING GATES (barrier arm + pole, north & south of track)
	---------------------------------------------------------------------------
	for _, sideZ in ipairs({-1, 1}) do
		local gateZ = z + sideZ * (railGauge + 8) * scale

		-- Gate pole
		local poleH = 8 * scale
		local pole = Instance.new("Part")
		pole.Name = "GatePole"
		pole.Size = Vector3.new(0.6 * scale, poleH, 0.6 * scale)
		pole.Position = Vector3.new(x + roadWidth / 2 + 1, surfaceY + poleH / 2, gateZ)
		pole.Anchored = true
		pole.CanCollide = false
		pole.Material = Enum.Material.Metal
		pole.Color = C_POLE
		pole.Parent = model

		-- Barrier arm (red with white stripes — spans full road)
		local armLen = roadWidth
		local arm = Instance.new("Part")
		arm.Name = "GateArm"
		arm.Size = Vector3.new(armLen, 0.4 * scale, 0.3 * scale)
		arm.Position = Vector3.new(x + roadWidth / 2 + 1 - armLen / 2, surfaceY + poleH - 0.5, gateZ)
		arm.Anchored = true
		arm.CanCollide = false
		arm.Material = Enum.Material.SmoothPlastic
		arm.Color = C_RED
		arm.Parent = model

		-- White stripes on the arm
		for s = 0, 2 do
			local stripe = Instance.new("Part")
			stripe.Name = "ArmStripe"
			stripe.Size = Vector3.new(armLen / 6, 0.42 * scale, 0.32 * scale)
			stripe.Position = Vector3.new(
				x + roadWidth / 2 + 1 - armLen / 4 - s * armLen / 3,
				surfaceY + poleH - 0.5,
				gateZ
			)
			stripe.Anchored = true
			stripe.CanCollide = false
			stripe.Material = Enum.Material.SmoothPlastic
			stripe.Color = C_WHITE
			stripe.Parent = model
		end

		-- Red warning light on top of pole
		local light = Instance.new("Part")
		light.Name = "WarningLight"
		light.Size = Vector3.new(0.8 * scale, 0.8 * scale, 0.8 * scale)
		light.Position = Vector3.new(x + roadWidth / 2 + 1, surfaceY + poleH + 0.5, gateZ)
		light.Anchored = true
		light.CanCollide = false
		light.Shape = Enum.PartType.Ball
		light.Material = Enum.Material.Neon
		light.Color = C_RED
		light.Parent = model
	end

	---------------------------------------------------------------------------
	-- 5. RAILROAD CROSSING SIGNS (X-shaped crossbuck, both sides of road)
	---------------------------------------------------------------------------
	for _, sideZ in ipairs({-1, 1}) do
		local signX = x + roadWidth / 2 + 3
		local signZ = z + sideZ * (railGauge + 10) * scale
		local signY = surfaceY + 6 * scale

		-- Sign pole
		local sPole = Instance.new("Part")
		sPole.Name = "SignPole"
		sPole.Size = Vector3.new(0.4 * scale, 6 * scale, 0.4 * scale)
		sPole.Position = Vector3.new(signX, surfaceY + 3 * scale, signZ)
		sPole.Anchored = true
		sPole.CanCollide = false
		sPole.Material = Enum.Material.Metal
		sPole.Color = C_POLE
		sPole.Parent = model

		-- X crossbuck (two diagonal boards)
		for _, angle in ipairs({45, -45}) do
			local board = Instance.new("Part")
			board.Name = "Crossbuck"
			board.Size = Vector3.new(4 * scale, 0.4 * scale, 0.3 * scale)
			board.CFrame = CFrame.new(signX, signY, signZ) * CFrame.Angles(0, 0, math.rad(angle))
			board.Anchored = true
			board.CanCollide = false
			board.Material = Enum.Material.SmoothPlastic
			board.Color = C_WHITE
			board.Parent = model
		end
	end

	model.Parent = DecorUtils.decorFolder
	return model
end

return RailwayCrossing
