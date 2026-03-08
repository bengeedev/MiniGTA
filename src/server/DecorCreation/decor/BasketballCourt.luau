local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))
local Fences = require(script.Parent:WaitForChild("Fences"))

local BasketballCourt = {}

function BasketballCourt.createBasketballCourt(x, z, scale)
	local decorFolder = DecorUtils.decorFolder
	if not decorFolder then return nil end
	scale = scale or 1
	local TERRAIN_TOP = DecorUtils.TERRAIN_TOP
	local NPCManager = DecorUtils.NPCManager

	local model = Instance.new("Model")
	model.Name = "BasketballCourt"

	local sign = x > 0 and 1 or -1
	local cx = x + sign * 12 * scale  -- center of court area, close to road
	local halfW = 24 * scale  -- court width (X direction)
	local halfD = 16 * scale  -- court depth (Z direction)

	-- Court surface (lighter concrete)
	local court = Instance.new("Part")
	court.Name = "CourtSurface"
	court.Size = Vector3.new(halfW * 2, 0.3, halfD * 2)
	court.Position = Vector3.new(cx, TERRAIN_TOP + 0.15, z)
	court.Anchored = true
	court.Material = Enum.Material.Concrete
	court.Color = Color3.fromRGB(170, 165, 155)
	court.Parent = model

	-- Court lines (thin white Neon parts)
	-- Center line
	local centerLine = Instance.new("Part")
	centerLine.Name = "CourtLine"
	centerLine.Size = Vector3.new(0.3, 0.05, halfD * 2 - 2)
	centerLine.Position = Vector3.new(cx, TERRAIN_TOP + 0.35, z)
	centerLine.Anchored = true
	centerLine.Material = Enum.Material.Neon
	centerLine.Color = Color3.fromRGB(255, 255, 255)
	centerLine.CanCollide = false
	centerLine.Parent = model

	-- Center circle
	local centerCircle = Instance.new("Part")
	centerCircle.Name = "CourtCircle"
	centerCircle.Shape = Enum.PartType.Cylinder
	centerCircle.Size = Vector3.new(0.05, 10 * scale, 10 * scale)
	centerCircle.CFrame = CFrame.new(cx, TERRAIN_TOP + 0.35, z) * CFrame.Angles(0, 0, math.rad(90))
	centerCircle.Anchored = true
	centerCircle.Material = Enum.Material.Neon
	centerCircle.Color = Color3.fromRGB(255, 255, 255)
	centerCircle.Transparency = 0.6
	centerCircle.CanCollide = false
	centerCircle.Parent = model

	-- Boundary lines
	local boundaryLines = {
		{ x = cx, z = z - halfD + 0.5, sx = halfW * 2 - 2, sz = 0.3 },  -- near
		{ x = cx, z = z + halfD - 0.5, sx = halfW * 2 - 2, sz = 0.3 },  -- far
		{ x = cx - halfW + 0.5, z = z, sx = 0.3, sz = halfD * 2 - 2 },  -- left
		{ x = cx + halfW - 0.5, z = z, sx = 0.3, sz = halfD * 2 - 2 },  -- right
	}
	for _, bl in ipairs(boundaryLines) do
		local line = Instance.new("Part")
		line.Name = "CourtLine"
		line.Size = Vector3.new(bl.sx, 0.05, bl.sz)
		line.Position = Vector3.new(bl.x, TERRAIN_TOP + 0.35, bl.z)
		line.Anchored = true
		line.Material = Enum.Material.Neon
		line.Color = Color3.fromRGB(255, 255, 255)
		line.CanCollide = false
		line.Parent = model
	end

	-- Basketball hoops (one at each end along X axis)
	for _, endSign in ipairs({ -1, 1 }) do
		local hoopX = cx + endSign * (halfW - 3) * 1
		local poleH = 12 * scale
		local groundY = TERRAIN_TOP + 2  -- terrain voxel offset

		-- Pole
		local pole = Instance.new("Part")
		pole.Name = "HoopPole"
		pole.Size = Vector3.new(0.6 * scale, poleH, 0.6 * scale)
		pole.Position = Vector3.new(hoopX, groundY + poleH / 2, z)
		pole.Anchored = true
		pole.Material = Enum.Material.Metal
		pole.Color = Color3.fromRGB(120, 120, 120)
		pole.Parent = model

		-- Backboard
		local board = Instance.new("Part")
		board.Name = "Backboard"
		board.Size = Vector3.new(0.4 * scale, 4 * scale, 5 * scale)
		board.Position = Vector3.new(hoopX - endSign * 0.5, groundY + poleH - 1, z)
		board.Anchored = true
		board.Material = Enum.Material.SmoothPlastic
		board.Color = Color3.fromRGB(240, 240, 240)
		board.Transparency = 0.3
		board.Parent = model

		-- Rim (orange cylinder)
		local rim = Instance.new("Part")
		rim.Name = "HoopRim"
		rim.Shape = Enum.PartType.Cylinder
		rim.Size = Vector3.new(0.3 * scale, 3 * scale, 3 * scale)
		rim.CFrame = CFrame.new(hoopX - endSign * 2, groundY + poleH - 2.5, z) * CFrame.Angles(0, 0, math.rad(90))
		rim.Anchored = true
		rim.Material = Enum.Material.Metal
		rim.Color = Color3.fromRGB(255, 100, 20)
		rim.Parent = model
	end

	-- Grid fence enclosure around the court
	Fences.createGridFence(model, {
		{ x = cx - halfW - 2, z = z - halfD - 2 },
		{ x = cx + halfW + 2, z = z - halfD - 2 },
		{ x = cx + halfW + 2, z = z + halfD + 2 },
		{ x = cx - halfW - 2, z = z + halfD + 2 },
	}, 16 * scale)

	-- Spawn baller NPCs on the court (pacing around like they're playing)
	if NPCManager then
		local npcPositions = {
			{ dx = -6, dz = -4, angle = 45,  paceRange = 8, paceAxis = "x" },
			{ dx = 8,  dz = 3,  angle = -30, paceRange = 6, paceAxis = "z" },
			{ dx = -2, dz = 8,  angle = 0,   paceRange = 7, paceAxis = "x" },
		}
		for _, np in ipairs(npcPositions) do
			task.spawn(function()
				NPCManager.spawnFromTemplate(
					NPCManager.randomCivilian(),
					Vector3.new(cx + np.dx * scale, TERRAIN_TOP + 5, z + np.dz * scale),
					np.angle,
					"pace",
					{ paceRange = np.paceRange, paceAxis = np.paceAxis, walkSpeed = 10 }
				)
			end)
		end
	end

	-- Hood-style floodlight poles (tall utility poles with harsh light)
	local groundY = TERRAIN_TOP + 2
	for _, lSign in ipairs({ -1, 1 }) do
		local lightX = cx
		local lightZ = z + lSign * (halfD + 3)
		local poleH = 18 * scale

		-- Utility pole (thin, tall, dark metal)
		local pole = Instance.new("Part")
		pole.Name = "FloodlightPole"
		pole.Size = Vector3.new(0.5 * scale, poleH, 0.5 * scale)
		pole.Position = Vector3.new(lightX, groundY + poleH / 2, lightZ)
		pole.Anchored = true
		pole.Material = Enum.Material.Metal
		pole.Color = Color3.fromRGB(55, 55, 60)
		pole.Parent = model

		-- Light housing (angled box at the top)
		local housing = Instance.new("Part")
		housing.Name = "FloodlightHousing"
		housing.Size = Vector3.new(3 * scale, 1 * scale, 2 * scale)
		housing.CFrame = CFrame.new(lightX, groundY + poleH - 0.5, lightZ - lSign * 1) * CFrame.Angles(math.rad(lSign * 20), 0, 0)
		housing.Anchored = true
		housing.Material = Enum.Material.Metal
		housing.Color = Color3.fromRGB(45, 45, 50)
		housing.Parent = model

		-- Glowing bulb face (neon underside)
		local bulb = Instance.new("Part")
		bulb.Name = "FloodlightBulb"
		bulb.Size = Vector3.new(2.5 * scale, 0.3, 1.5 * scale)
		bulb.CFrame = CFrame.new(lightX, groundY + poleH - 1.2, lightZ - lSign * 1)
		bulb.Anchored = true
		bulb.Material = Enum.Material.Neon
		bulb.Color = Color3.fromRGB(255, 220, 140)
		bulb.CanCollide = false
		bulb.Parent = model

		-- SpotLight for actual lighting
		local light = Instance.new("SpotLight")
		light.Color = Color3.fromRGB(255, 200, 120)
		light.Brightness = 3
		light.Range = 50
		light.Angle = 60
		light.Face = Enum.NormalId.Bottom
		light.Parent = bulb

	end

	model.Parent = decorFolder
	return model
end

return BasketballCourt
