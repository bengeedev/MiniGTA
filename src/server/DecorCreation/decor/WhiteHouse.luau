local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local WhiteHouse = {}

local BUILDING_BASE = DecorUtils.BUILDING_BASE
local addWindowsToFace = DecorUtils.addWindowsToFace

--------------------------------------------------------------------------------
-- White House — South Portico (iconic curved colonnade) faces +Z toward player.
-- x is the near-edge offset; building extends away from lane center.
--------------------------------------------------------------------------------

function WhiteHouse.createWhiteHouse(x, z, scale)
	if not DecorUtils.decorFolder then return nil end
	scale = scale or 1

	local model = Instance.new("Model")
	model.Name = "WhiteHouse"

	local bodyColor = Color3.fromRGB(245, 245, 240)
	local trimColor = Color3.fromRGB(235, 235, 228)
	local roofColor = Color3.fromRGB(130, 130, 135)
	local winColor  = Color3.fromRGB(255, 220, 140)

	local xSign = x > 0 and 1 or -1

	---------------------------------------------------------------------------
	-- DIMENSIONS
	---------------------------------------------------------------------------
	local bodyW = 80 * scale   -- width along X
	local bodyD = 28 * scale   -- depth along Z
	local bodyH = 22 * scale
	-- For 2 rows of windows: floors=3, floorHeight=6 → rows at Y=13 and Y=19
	local winFloors = 3
	local winFloorH = 6 * scale

	-- Shift so near-X edge sits at original x
	x = x + xSign * bodyW / 2

	local frontZ = z + bodyD / 2   -- south face (+Z, toward player)
	local backZ  = z - bodyD / 2

	---------------------------------------------------------------------------
	-- 1. MAIN BODY
	---------------------------------------------------------------------------
	local main = Instance.new("Part")
	main.Name = "MainBody"
	main.Size = Vector3.new(bodyW, bodyH, bodyD)
	main.Position = Vector3.new(x, BUILDING_BASE + bodyH / 2, z)
	main.Anchored = true
	main.Material = Enum.Material.SmoothPlastic
	main.Color = bodyColor
	main.Parent = model

	-- Windows on all 4 faces (2 rows)
	addWindowsToFace(model, "z", frontZ + 0.15, x, bodyW, BUILDING_BASE, winFloors, winFloorH, 2.8 * scale, 4 * scale, 1.8, winColor, 0.7)
	addWindowsToFace(model, "z", backZ - 0.15, x, bodyW, BUILDING_BASE, winFloors, winFloorH, 2.8 * scale, 4 * scale, 1.8, winColor, 0.3)
	addWindowsToFace(model, "x", x - bodyW / 2 - 0.15, z, bodyD, BUILDING_BASE, winFloors, winFloorH, 2.8 * scale, 4 * scale, 1.8, winColor, 0.5)
	addWindowsToFace(model, "x", x + bodyW / 2 + 0.15, z, bodyD, BUILDING_BASE, winFloors, winFloorH, 2.8 * scale, 4 * scale, 1.8, winColor, 0.5)

	-- Floor band between stories
	local bandY = BUILDING_BASE + bodyH * 0.48
	local band = Instance.new("Part")
	band.Name = "FloorBand"
	band.Size = Vector3.new(bodyW + 0.3, 0.7 * scale, bodyD + 0.3)
	band.Position = Vector3.new(x, bandY, z)
	band.Anchored = true
	band.CanCollide = false
	band.Material = Enum.Material.SmoothPlastic
	band.Color = trimColor
	band.Parent = model

	-- Roof balustrade
	local balH = 2 * scale
	local balustrade = Instance.new("Part")
	balustrade.Name = "Balustrade"
	balustrade.Size = Vector3.new(bodyW + 0.5, balH, bodyD + 0.5)
	balustrade.Position = Vector3.new(x, BUILDING_BASE + bodyH + balH / 2, z)
	balustrade.Anchored = true
	balustrade.Material = Enum.Material.SmoothPlastic
	balustrade.Color = trimColor
	balustrade.Parent = model

	-- Flat roof
	local roofCap = Instance.new("Part")
	roofCap.Name = "RoofCap"
	roofCap.Size = Vector3.new(bodyW - 1 * scale, 0.4 * scale, bodyD - 1 * scale)
	roofCap.Position = Vector3.new(x, BUILDING_BASE + bodyH + balH + 0.2 * scale, z)
	roofCap.Anchored = true
	roofCap.Material = Enum.Material.Metal
	roofCap.Color = roofColor
	roofCap.Parent = model

	---------------------------------------------------------------------------
	-- 3. SOUTH PORTICO — Semicircular curved colonnade
	-- The iconic Truman Balcony side with columns in a half-circle.
	---------------------------------------------------------------------------
	local porticoRadius = 14 * scale  -- radius of the semicircle
	local NUM_COLUMNS = 8             -- columns around the semicircle
	local colRadius = 1 * scale
	local colHeight = bodyH - 3 * scale  -- nearly full height

	-- Columns arranged in a semicircle from -90° to +90° (centered on +Z)
	for i = 0, NUM_COLUMNS do
		local angle = math.rad(-90 + i * (180 / NUM_COLUMNS))
		local cx = x + porticoRadius * math.sin(angle)
		local cz = frontZ + porticoRadius * math.cos(angle)

		local col = Instance.new("Part")
		col.Name = "SouthColumn"
		col.Shape = Enum.PartType.Cylinder
		col.Size = Vector3.new(colHeight, colRadius * 2, colRadius * 2)
		col.CFrame = CFrame.new(cx, BUILDING_BASE + colHeight / 2, cz)
			* CFrame.Angles(0, 0, math.rad(90))
		col.Anchored = true
		col.Material = Enum.Material.SmoothPlastic
		col.Color = bodyColor
		col.Parent = model
	end

	-- Simple flat semicircular base under the portico columns
	local baseH = 2 * scale
	local basePart = Instance.new("Part")
	basePart.Name = "PorticoBase"
	basePart.Shape = Enum.PartType.Cylinder
	basePart.Size = Vector3.new(baseH, porticoRadius * 2 + 2 * scale, porticoRadius * 2 + 2 * scale)
	basePart.CFrame = CFrame.new(x, BUILDING_BASE + baseH / 2 + 0.5, frontZ)
		* CFrame.Angles(0, 0, math.rad(90))
	basePart.Anchored = true
	basePart.Material = Enum.Material.SmoothPlastic
	basePart.Color = trimColor
	basePart.Parent = model

	-- Same cylinder on top of columns (entablature cap)
	local capH = 2 * scale
	local capPart = Instance.new("Part")
	capPart.Name = "PorticoCap"
	capPart.Shape = Enum.PartType.Cylinder
	capPart.Size = Vector3.new(capH, porticoRadius * 2 + 2 * scale, porticoRadius * 2 + 2 * scale)
	capPart.CFrame = CFrame.new(x, BUILDING_BASE + colHeight + capH / 2, frontZ)
		* CFrame.Angles(0, 0, math.rad(90))
	capPart.Anchored = true
	capPart.Material = Enum.Material.SmoothPlastic
	capPart.Color = trimColor
	capPart.Parent = model

	---------------------------------------------------------------------------
	-- 4. AMERICAN FLAG
	---------------------------------------------------------------------------
	local poleH = 10 * scale
	local pole = Instance.new("Part")
	pole.Name = "FlagPole"
	pole.Shape = Enum.PartType.Cylinder
	pole.Size = Vector3.new(poleH, 0.3 * scale, 0.3 * scale)
	pole.CFrame = CFrame.new(x, BUILDING_BASE + bodyH + balH + poleH / 2, z)
		* CFrame.Angles(0, 0, math.rad(90))
	pole.Anchored = true
	pole.Material = Enum.Material.Metal
	pole.Color = Color3.fromRGB(180, 180, 180)
	pole.Parent = model

	local flagW = 5 * scale
	local flagH = 3.5 * scale
	local flagY = BUILDING_BASE + bodyH + balH + poleH - flagH / 2

	local stripes = Instance.new("Part")
	stripes.Name = "FlagStripes"
	stripes.Size = Vector3.new(flagW, flagH, 0.15 * scale)
	stripes.Position = Vector3.new(x + flagW / 2 + 0.2 * scale, flagY, z + 0.2 * scale)
	stripes.Anchored = true
	stripes.CanCollide = false
	stripes.Material = Enum.Material.SmoothPlastic
	stripes.Color = Color3.fromRGB(200, 40, 40)
	stripes.Parent = model

	local canton = Instance.new("Part")
	canton.Name = "FlagCanton"
	canton.Size = Vector3.new(flagW * 0.4, flagH * 0.55, 0.2 * scale)
	canton.Position = Vector3.new(x + flagW * 0.2 + 0.2 * scale, flagY + flagH * 0.22, z + 0.25 * scale)
	canton.Anchored = true
	canton.CanCollide = false
	canton.Material = Enum.Material.SmoothPlastic
	canton.Color = Color3.fromRGB(40, 50, 120)
	canton.Parent = model

	---------------------------------------------------------------------------
	-- 5. BLACK IRON FENCE — enclosing the White House zone
	---------------------------------------------------------------------------
	local fenceColor = Color3.fromRGB(20, 20, 25)
	local fenceH = 10 * scale
	local barSpacing = 3 * scale
	local barThick = 0.35 * scale
	local railH = 0.5 * scale
	local tipSize = 0.8 * scale

	-- Helper: build a fence segment between two points
	local function buildFence(x1, z1, x2, z2)
		local dx = x2 - x1
		local dz = z2 - z1
		local len = math.sqrt(dx * dx + dz * dz)
		local cx, cz = (x1 + x2) / 2, (z1 + z2) / 2
		local angle = math.atan2(dx, dz)

		-- Rails
		for _, ry in ipairs({ BUILDING_BASE + 1 * scale, BUILDING_BASE + fenceH - 1 * scale }) do
			local rail = Instance.new("Part")
			rail.Name = "FenceRail"
			rail.Size = Vector3.new(railH, railH, len)
			rail.CFrame = CFrame.new(cx, ry, cz) * CFrame.Angles(0, angle, 0)
			rail.Anchored = true
			rail.CanCollide = false
			rail.Material = Enum.Material.Metal
			rail.Color = fenceColor
			rail.Parent = model
		end

		-- Bars + tips
		local numBars = math.floor(len / barSpacing)
		for i = 0, numBars do
			local t = numBars > 0 and (i / numBars) or 0.5
			local bx = x1 + dx * t
			local bz = z1 + dz * t

			local bar = Instance.new("Part")
			bar.Name = "FenceBar"
			bar.Size = Vector3.new(barThick, fenceH, barThick)
			bar.Position = Vector3.new(bx, BUILDING_BASE + fenceH / 2, bz)
			bar.Anchored = true
			bar.CanCollide = false
			bar.Material = Enum.Material.Metal
			bar.Color = fenceColor
			bar.Parent = model

			local tip = Instance.new("Part")
			tip.Name = "SpearTip"
			tip.Size = Vector3.new(tipSize, tipSize, tipSize)
			tip.CFrame = CFrame.new(bx, BUILDING_BASE + fenceH + tipSize * 0.4, bz)
				* CFrame.Angles(0, 0, math.rad(45))
			tip.Anchored = true
			tip.CanCollide = false
			tip.Material = Enum.Material.Metal
			tip.Color = fenceColor
			tip.Parent = model
		end
	end

	-- Fence corners: enclose the property zone
	local margin = 30 * scale
	local fenceNearX = x - xSign * (bodyW / 2 + margin)  -- side closest to road
	local fenceFarX  = x + xSign * (bodyW / 2 + margin)  -- far side
	local fenceFrontZ = frontZ + porticoRadius + 25 * scale
	local fenceBackZ  = backZ - 10 * scale

	-- Front fence (along X)
	buildFence(fenceNearX, fenceFrontZ, fenceFarX, fenceFrontZ)
	-- Near-road side fence (along Z)
	buildFence(fenceNearX, fenceBackZ, fenceNearX, fenceFrontZ)
	-- Far side fence (along Z)
	buildFence(fenceFarX, fenceBackZ, fenceFarX, fenceFrontZ)
	-- Back fence (along X)
	buildFence(fenceNearX, fenceBackZ, fenceFarX, fenceBackZ)

	model.Parent = DecorUtils.decorFolder
	return model
end

return WhiteHouse
