local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local Mansion = {}

local BUILDING_BASE = DecorUtils.BUILDING_BASE
local addWindowsToFace = DecorUtils.addWindowsToFace

--------------------------------------------------------------------------------
-- LEFT: Mediterranean / Spanish Colonial — warm stucco, terracotta pitched roof
--------------------------------------------------------------------------------

local LEFT_MANSIONS = {
	{
		facade = 40, floors = 2, floorH = 8,
		color = Color3.fromRGB(245, 235, 215), mat = Enum.Material.SmoothPlastic,
		roofColor = Color3.fromRGB(180, 90, 50), roofType = "pitched",
		winColor = Color3.fromRGB(255, 220, 140), litPct = 0.6, winW = 2.5, winH = 3.5,
		columns = 4, garageW = 12,
	},
	{
		facade = 34, floors = 2, floorH = 8,
		color = Color3.fromRGB(235, 220, 190), mat = Enum.Material.SmoothPlastic,
		roofColor = Color3.fromRGB(165, 80, 45), roofType = "pitched",
		winColor = Color3.fromRGB(255, 200, 100), litPct = 0.5, winW = 2.2, winH = 3.0,
		columns = 2, garageW = 10,
	},
	{
		facade = 44, floors = 2, floorH = 9,
		color = Color3.fromRGB(250, 245, 230), mat = Enum.Material.Concrete,
		roofColor = Color3.fromRGB(150, 75, 40), roofType = "pitched",
		winColor = Color3.fromRGB(255, 210, 130), litPct = 0.55, winW = 2.8, winH = 4.0,
		columns = 6, garageW = 14,
	},
	{
		facade = 36, floors = 2, floorH = 8,
		color = Color3.fromRGB(240, 225, 200), mat = Enum.Material.SmoothPlastic,
		roofColor = Color3.fromRGB(190, 100, 60), roofType = "pitched",
		winColor = Color3.fromRGB(255, 230, 150), litPct = 0.65, winW = 2.0, winH = 3.5,
		columns = 4, garageW = 10,
	},
	{
		facade = 42, floors = 3, floorH = 8,
		color = Color3.fromRGB(248, 240, 225), mat = Enum.Material.Concrete,
		roofColor = Color3.fromRGB(170, 85, 48), roofType = "pitched",
		winColor = Color3.fromRGB(255, 215, 135), litPct = 0.5, winW = 2.5, winH = 3.5,
		columns = 4, garageW = 12,
	},
}

--------------------------------------------------------------------------------
-- RIGHT: Modern / Contemporary — clean lines, flat roof, large glass panels
--------------------------------------------------------------------------------

local RIGHT_MANSIONS = {
	{
		facade = 42, floors = 2, floorH = 9,
		color = Color3.fromRGB(245, 245, 250), mat = Enum.Material.SmoothPlastic,
		roofColor = Color3.fromRGB(45, 45, 50), roofType = "flat",
		winColor = Color3.fromRGB(200, 230, 255), litPct = 0.7, winW = 5, winH = 6,
		columns = 0, garageW = 14,
	},
	{
		facade = 36, floors = 2, floorH = 9,
		color = Color3.fromRGB(230, 230, 235), mat = Enum.Material.SmoothPlastic,
		roofColor = Color3.fromRGB(55, 55, 60), roofType = "flat",
		winColor = Color3.fromRGB(180, 210, 255), litPct = 0.65, winW = 4.5, winH = 5.5,
		columns = 0, garageW = 12,
	},
	{
		facade = 46, floors = 2, floorH = 10,
		color = Color3.fromRGB(60, 60, 65), mat = Enum.Material.Metal,
		roofColor = Color3.fromRGB(40, 40, 45), roofType = "flat",
		winColor = Color3.fromRGB(200, 230, 255), litPct = 0.75, winW = 6, winH = 7,
		columns = 0, garageW = 14,
	},
	{
		facade = 38, floors = 2, floorH = 9,
		color = Color3.fromRGB(250, 250, 252), mat = Enum.Material.SmoothPlastic,
		roofColor = Color3.fromRGB(50, 50, 55), roofType = "flat",
		winColor = Color3.fromRGB(190, 220, 255), litPct = 0.6, winW = 4, winH = 5,
		columns = 0, garageW = 10,
	},
	{
		facade = 44, floors = 3, floorH = 9,
		color = Color3.fromRGB(235, 235, 240), mat = Enum.Material.SmoothPlastic,
		roofColor = Color3.fromRGB(35, 35, 40), roofType = "flat",
		winColor = Color3.fromRGB(200, 230, 255), litPct = 0.7, winW = 5, winH = 6,
		columns = 0, garageW = 12,
	},
}

--------------------------------------------------------------------------------
-- CONSTANTS
--------------------------------------------------------------------------------

local LOT_DEPTH = 28    -- house depth (the narrow dimension)
local LOT_GAP = 4       -- spacing between lots along X
local DRIVEWAY_W = 6

--------------------------------------------------------------------------------
-- BUILD ONE MANSION
-- facing "x": front toward road center. Body: lotD along X, facade along Z
-- facing "z": front toward player (+Z). Body: facade along X, lotD along Z
-- The body is PHYSICALLY ROTATED so the wide facade always faces the front.
--------------------------------------------------------------------------------

local function buildMansion(spec, x, z, scale, facing)
	facing = facing or "x"
	local model = Instance.new("Model")
	model.Name = "Mansion"

	local sign = x > 0 and 1 or -1
	local facadeLen = spec.facade * scale
	local floorH = spec.floorH * scale
	local height = spec.floors * floorH
	local lotD = LOT_DEPTH * scale
	local roofOH = 1.5 * scale

	-- Key: body dimensions swap based on facing
	local bodyX, bodyZ  -- the actual Part size along X and Z
	if facing == "x" then
		bodyX = lotD        -- narrow depth perpendicular to road
		bodyZ = facadeLen   -- wide facade along road
	else
		bodyX = facadeLen   -- wide facade facing player
		bodyZ = lotD        -- shallow depth going away from player
	end

	-- ── BODY ──────────────────────────────────────────────────────────────
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(bodyX, height, bodyZ)
	body.Position = Vector3.new(x, BUILDING_BASE + height / 2, z)
	body.Anchored = true
	body.Material = spec.mat
	body.Color = spec.color
	body:SetAttribute("ThemeRole", "building_body")
	body:SetAttribute("BaseColor", spec.color)
	body:SetAttribute("BaseMaterial", spec.mat.Name)
	body.Parent = model

	-- ── ROOF ──────────────────────────────────────────────────────────────
	if spec.roofType == "pitched" then
		local roofRise = 5 * scale

		if facing == "x" then
			-- Ridge along Z, slopes along X
			local roofHalfW = bodyX / 2 + roofOH
			local panelLen = math.sqrt(roofHalfW * roofHalfW + roofRise * roofRise)
			local roofAngle = math.atan2(roofRise, roofHalfW)

			for _, s in ipairs({-1, 1}) do
				local panel = Instance.new("Part")
				panel.Name = "RoofPanel"
				panel.Size = Vector3.new(panelLen, 0.5 * scale, bodyZ + roofOH * 2)
				panel.CFrame = CFrame.new(
					x + s * roofHalfW / 2,
					BUILDING_BASE + height + roofRise / 2, z
				) * CFrame.Angles(0, 0, -s * roofAngle)
				panel.Anchored = true
				panel.Material = Enum.Material.Slate
				panel.Color = spec.roofColor
				panel:SetAttribute("ThemeRole", "building_roof")
				panel:SetAttribute("BaseColor", spec.roofColor)
				panel:SetAttribute("BaseMaterial", "Slate")
				panel.Parent = model
			end

			local ridge = Instance.new("Part")
			ridge.Name = "Ridge"
			ridge.Size = Vector3.new(1.5 * scale, 0.6 * scale, bodyZ + roofOH * 2)
			ridge.Position = Vector3.new(x, BUILDING_BASE + height + roofRise, z)
			ridge.Anchored = true
			ridge.Material = Enum.Material.Slate
			ridge.Color = spec.roofColor
			ridge:SetAttribute("ThemeRole", "building_roof")
			ridge:SetAttribute("BaseColor", spec.roofColor)
			ridge:SetAttribute("BaseMaterial", "Slate")
			ridge.Parent = model
		else
			-- Ridge along X, slopes along Z → gable faces the player
			local roofHalfD = bodyZ / 2 + roofOH
			local panelLen = math.sqrt(roofHalfD * roofHalfD + roofRise * roofRise)
			local roofAngle = math.atan2(roofRise, roofHalfD)

			for _, s in ipairs({-1, 1}) do
				local panel = Instance.new("Part")
				panel.Name = "RoofPanel"
				panel.Size = Vector3.new(bodyX + roofOH * 2, 0.5 * scale, panelLen)
				panel.CFrame = CFrame.new(
					x, BUILDING_BASE + height + roofRise / 2,
					z + s * roofHalfD / 2
				) * CFrame.Angles(s * roofAngle, 0, 0)
				panel.Anchored = true
				panel.Material = Enum.Material.Slate
				panel.Color = spec.roofColor
				panel:SetAttribute("ThemeRole", "building_roof")
				panel:SetAttribute("BaseColor", spec.roofColor)
				panel:SetAttribute("BaseMaterial", "Slate")
				panel.Parent = model
			end

			local ridge = Instance.new("Part")
			ridge.Name = "Ridge"
			ridge.Size = Vector3.new(bodyX + roofOH * 2, 0.6 * scale, 1.5 * scale)
			ridge.Position = Vector3.new(x, BUILDING_BASE + height + roofRise, z)
			ridge.Anchored = true
			ridge.Material = Enum.Material.Slate
			ridge.Color = spec.roofColor
			ridge:SetAttribute("ThemeRole", "building_roof")
			ridge:SetAttribute("BaseColor", spec.roofColor)
			ridge:SetAttribute("BaseMaterial", "Slate")
			ridge.Parent = model
		end
	else
		-- Flat roof with overhang
		local roof = Instance.new("Part")
		roof.Name = "Roof"
		roof.Size = Vector3.new(bodyX + roofOH * 2, 0.8 * scale, bodyZ + roofOH * 2)
		roof.Position = Vector3.new(x, BUILDING_BASE + height + 0.4 * scale, z)
		roof.Anchored = true
		roof.Material = Enum.Material.SmoothPlastic
		roof.Color = spec.roofColor
		roof:SetAttribute("ThemeRole", "building_roof")
		roof:SetAttribute("BaseColor", spec.roofColor)
		roof:SetAttribute("BaseMaterial", "SmoothPlastic")
		roof.Parent = model

		local trim = Instance.new("Part")
		trim.Name = "RoofTrim"
		trim.Size = Vector3.new(bodyX + roofOH * 2 + 0.5, 1.2 * scale, bodyZ + roofOH * 2 + 0.5)
		trim.Position = Vector3.new(x, BUILDING_BASE + height + 1 * scale, z)
		trim.Anchored = true
		trim.Material = Enum.Material.Metal
		trim.Color = spec.roofColor
		trim:SetAttribute("ThemeRole", "building_roof")
		trim:SetAttribute("BaseColor", spec.roofColor)
		trim:SetAttribute("BaseMaterial", "Metal")
		trim.Parent = model
	end

	-- ── WINDOWS ───────────────────────────────────────────────────────────
	if facing == "x" then
		-- Front on X face (toward road center), facade width = bodyZ
		local frontX = x - sign * (bodyX / 2 + 0.2)
		addWindowsToFace(model, "x", frontX, z, bodyZ, BUILDING_BASE,
			spec.floors, floorH, spec.winW * scale, spec.winH * scale,
			1.5 * scale, spec.winColor, spec.litPct)
	else
		-- Front on +Z face (toward player), facade width = bodyX
		local frontZ = z + bodyZ / 2 + 0.2
		addWindowsToFace(model, "z", frontZ, x, bodyX, BUILDING_BASE,
			spec.floors, floorH, spec.winW * scale, spec.winH * scale,
			1.5 * scale, spec.winColor, spec.litPct)
	end

	-- ── ENTRANCE ──────────────────────────────────────────────────────────
	local doorW = 3.5 * scale
	local doorH = 6 * scale

	if spec.columns > 0 then
		local colSpacing = doorW + 2 * scale
		local colRadius = 0.6 * scale
		local colH = doorH + 2 * scale
		local numCols = spec.columns

		for i = 1, numCols do
			local colOff = (i - (numCols + 1) / 2) * colSpacing / 2
			local col = Instance.new("Part")
			col.Name = "Column"
			col.Shape = Enum.PartType.Cylinder
			col.Size = Vector3.new(colH, colRadius * 2, colRadius * 2)

			if facing == "x" then
				col.CFrame = CFrame.new(
					x - sign * (bodyX / 2 + 1 * scale),
					BUILDING_BASE + colH / 2,
					z + colOff
				) * CFrame.Angles(0, 0, math.rad(90))
			else
				col.CFrame = CFrame.new(
					x + colOff,
					BUILDING_BASE + colH / 2,
					z + bodyZ / 2 + 1 * scale
				) * CFrame.Angles(0, 0, math.rad(90))
			end

			col.Anchored = true
			col.Material = Enum.Material.Marble
			col.Color = Color3.fromRGB(240, 235, 225)
			col.Parent = model
		end

		local porticoW = (numCols - 1) * colSpacing / 2 + 3 * scale
		local portico = Instance.new("Part")
		portico.Name = "Portico"

		if facing == "x" then
			portico.Size = Vector3.new(3 * scale, 0.6 * scale, porticoW)
			portico.Position = Vector3.new(x - sign * (bodyX / 2 + 1 * scale), BUILDING_BASE + colH + 0.3 * scale, z)
		else
			portico.Size = Vector3.new(porticoW, 0.6 * scale, 3 * scale)
			portico.Position = Vector3.new(x, BUILDING_BASE + colH + 0.3 * scale, z + bodyZ / 2 + 1 * scale)
		end

		portico.Anchored = true
		portico.Material = Enum.Material.Marble
		portico.Color = Color3.fromRGB(235, 230, 220)
		portico.Parent = model
	else
		local canopy = Instance.new("Part")
		canopy.Name = "Canopy"

		if facing == "x" then
			canopy.Size = Vector3.new(4 * scale, 0.3 * scale, 8 * scale)
			canopy.Position = Vector3.new(x - sign * (bodyX / 2 + 2 * scale), BUILDING_BASE + doorH + 1.5 * scale, z)
		else
			canopy.Size = Vector3.new(8 * scale, 0.3 * scale, 4 * scale)
			canopy.Position = Vector3.new(x, BUILDING_BASE + doorH + 1.5 * scale, z + bodyZ / 2 + 2 * scale)
		end

		canopy.Anchored = true
		canopy.Material = Enum.Material.SmoothPlastic
		canopy.Color = spec.roofColor
		canopy.Parent = model
	end

	-- Door
	local door = Instance.new("Part")
	door.Name = "Door"

	if facing == "x" then
		door.Size = Vector3.new(0.3, doorH, doorW)
		door.Position = Vector3.new(x - sign * (bodyX / 2 + 0.2), BUILDING_BASE + doorH / 2, z)
	else
		door.Size = Vector3.new(doorW, doorH, 0.3)
		door.Position = Vector3.new(x, BUILDING_BASE + doorH / 2, z + bodyZ / 2 + 0.2)
	end

	door.Anchored = true
	door.CanCollide = false
	door.Material = spec.columns > 0 and Enum.Material.Wood or Enum.Material.Glass
	door.Color = spec.columns > 0 and Color3.fromRGB(90, 55, 30) or Color3.fromRGB(180, 210, 240)
	door.Transparency = spec.columns > 0 and 0 or 0.3
	door.Parent = model

	-- ── GARAGE ────────────────────────────────────────────────────────────
	local garageW = spec.garageW * scale
	local garageH = floorH * 0.9
	local garageD = lotD * 0.6

	if facing == "x" then
		-- Garage attached along +Z side of house
		local gz = z + bodyZ / 2 + garageW / 2 + 0.5 * scale

		local garage = Instance.new("Part")
		garage.Name = "Garage"
		garage.Size = Vector3.new(garageD, garageH, garageW)
		garage.Position = Vector3.new(x, BUILDING_BASE + garageH / 2, gz)
		garage.Anchored = true
		garage.Material = spec.mat
		garage.Color = spec.color
		garage:SetAttribute("ThemeRole", "building_body")
		garage:SetAttribute("BaseColor", spec.color)
		garage:SetAttribute("BaseMaterial", spec.mat.Name)
		garage.Parent = model

		local gDoorH = garageH * 0.7
		local gd = Instance.new("Part")
		gd.Name = "GarageDoor"
		gd.Size = Vector3.new(0.3, gDoorH, garageW * 0.75)
		gd.Position = Vector3.new(x - sign * (garageD / 2 + 0.15), BUILDING_BASE + gDoorH / 2 + 0.3, gz)
		gd.Anchored = true
		gd.CanCollide = false
		gd.Material = Enum.Material.Metal
		gd.Color = Color3.fromRGB(160, 155, 150)
		gd.Parent = model

		local gr = Instance.new("Part")
		gr.Name = "GarageRoof"
		gr.Size = Vector3.new(garageD + 1 * scale, 0.5 * scale, garageW + 1 * scale)
		gr.Position = Vector3.new(x, BUILDING_BASE + garageH + 0.25 * scale, gz)
		gr.Anchored = true
		gr.Material = spec.roofType == "pitched" and Enum.Material.Slate or Enum.Material.SmoothPlastic
		gr.Color = spec.roofColor
		gr:SetAttribute("ThemeRole", "building_roof")
		gr:SetAttribute("BaseColor", spec.roofColor)
		gr:SetAttribute("BaseMaterial", gr.Material.Name)
		gr.Parent = model
	else
		-- Garage attached along +X side (outward from road), flush with front
		local gx = x + sign * (bodyX / 2 + garageW / 2 + 0.5 * scale)
		local gzC = z + bodyZ / 2 - garageD / 2  -- flush with front face

		local garage = Instance.new("Part")
		garage.Name = "Garage"
		garage.Size = Vector3.new(garageW, garageH, garageD)
		garage.Position = Vector3.new(gx, BUILDING_BASE + garageH / 2, gzC)
		garage.Anchored = true
		garage.Material = spec.mat
		garage.Color = spec.color
		garage:SetAttribute("ThemeRole", "building_body")
		garage:SetAttribute("BaseColor", spec.color)
		garage:SetAttribute("BaseMaterial", spec.mat.Name)
		garage.Parent = model

		local gDoorH = garageH * 0.7
		local gd = Instance.new("Part")
		gd.Name = "GarageDoor"
		gd.Size = Vector3.new(garageW * 0.75, gDoorH, 0.3)
		gd.Position = Vector3.new(gx, BUILDING_BASE + gDoorH / 2 + 0.3, gzC + garageD / 2 + 0.15)
		gd.Anchored = true
		gd.CanCollide = false
		gd.Material = Enum.Material.Metal
		gd.Color = Color3.fromRGB(160, 155, 150)
		gd.Parent = model

		local gr = Instance.new("Part")
		gr.Name = "GarageRoof"
		gr.Size = Vector3.new(garageW + 1 * scale, 0.5 * scale, garageD + 1 * scale)
		gr.Position = Vector3.new(gx, BUILDING_BASE + garageH + 0.25 * scale, gzC)
		gr.Anchored = true
		gr.Material = spec.roofType == "pitched" and Enum.Material.Slate or Enum.Material.SmoothPlastic
		gr.Color = spec.roofColor
		gr:SetAttribute("ThemeRole", "building_roof")
		gr:SetAttribute("BaseColor", spec.roofColor)
		gr:SetAttribute("BaseMaterial", gr.Material.Name)
		gr.Parent = model
	end

	-- ── LAWN + DRIVEWAY ──────────────────────────────────────────────────
	local lawnD = 3 * scale

	if facing == "x" then
		local lawnX = x - sign * (bodyX / 2 + lawnD / 2 + 0.5)
		local lawn = Instance.new("Part")
		lawn.Name = "Lawn"
		lawn.Size = Vector3.new(lawnD, 0.3, bodyZ + garageW + 2 * scale)
		lawn.Position = Vector3.new(lawnX, BUILDING_BASE + 0.15, z + garageW / 4)
		lawn.Anchored = true
		lawn.Material = Enum.Material.LeafyGrass
		lawn.Color = Color3.fromRGB(70, 145, 55)
		lawn.Parent = model

		local drive = Instance.new("Part")
		drive.Name = "Driveway"
		drive.Size = Vector3.new(lawnD + 2 * scale, 0.35, DRIVEWAY_W * scale)
		drive.Position = Vector3.new(lawnX, BUILDING_BASE + 0.2, z)
		drive.Anchored = true
		drive.Material = Enum.Material.Concrete
		drive.Color = Color3.fromRGB(170, 165, 160)
		drive.Parent = model
	else
		local lawnZ = z + bodyZ / 2 + lawnD / 2 + 0.5
		local lawn = Instance.new("Part")
		lawn.Name = "Lawn"
		lawn.Size = Vector3.new(bodyX + garageW + 2 * scale, 0.3, lawnD)
		lawn.Position = Vector3.new(x + sign * garageW / 4, BUILDING_BASE + 0.15, lawnZ)
		lawn.Anchored = true
		lawn.Material = Enum.Material.LeafyGrass
		lawn.Color = Color3.fromRGB(70, 145, 55)
		lawn.Parent = model

		local drive = Instance.new("Part")
		drive.Name = "Driveway"
		drive.Size = Vector3.new(DRIVEWAY_W * scale, 0.35, lawnD + 2 * scale)
		drive.Position = Vector3.new(x, BUILDING_BASE + 0.2, lawnZ)
		drive.Anchored = true
		drive.Material = Enum.Material.Concrete
		drive.Color = Color3.fromRGB(170, 165, 160)
		drive.Parent = model
	end

	-- ── POOL (behind house) ──────────────────────────────────────────────
	if spec.floors <= 2 and math.random() < 0.5 then
		local poolW = 8 * scale
		local poolL = 14 * scale
		local poolX, poolZ, poolSizeX, poolSizeZ

		if facing == "x" then
			poolX = x + sign * (bodyX / 2 + poolW / 2 + 2 * scale)
			poolZ = z
			poolSizeX = poolW
			poolSizeZ = poolL
		else
			poolX = x
			poolZ = z - bodyZ / 2 - poolL / 2 - 2 * scale
			poolSizeX = poolL
			poolSizeZ = poolW
		end

		local pool = Instance.new("Part")
		pool.Name = "Pool"
		pool.Size = Vector3.new(poolSizeX, 0.5, poolSizeZ)
		pool.Position = Vector3.new(poolX, BUILDING_BASE + 0.3, poolZ)
		pool.Anchored = true
		pool.Material = Enum.Material.Glass
		pool.Color = Color3.fromRGB(80, 185, 225)
		pool.Transparency = 0.3
		pool.Parent = model

		local edge = Instance.new("Part")
		edge.Name = "PoolEdge"
		edge.Size = Vector3.new(poolSizeX + 2 * scale, 0.4, poolSizeZ + 2 * scale)
		edge.Position = Vector3.new(poolX, BUILDING_BASE + 0.2, poolZ)
		edge.Anchored = true
		edge.Material = Enum.Material.Marble
		edge.Color = Color3.fromRGB(230, 225, 215)
		edge.Parent = model
	end

	model.Parent = DecorUtils.decorFolder
	return model
end

--------------------------------------------------------------------------------
-- ROW BUILDER
-- First mansion faces road (X-facing, narrow along X).
-- Rest face the player (Z-facing, WIDE along X — facade turned toward player).
-- Step adapts: X-facing step = lotD, Z-facing step = spec.facade (wider).
--------------------------------------------------------------------------------

function Mansion.createMansion(x, z, scale)
	if not DecorUtils.decorFolder then return nil end
	scale = scale or 1

	local row = x > 0 and RIGHT_MANSIONS or LEFT_MANSIONS
	local dir = x > 0 and 1 or -1

	-- First mansion: X-facing (narrow along X, facade along Z)
	buildMansion(row[1], x, z, scale, "x")
	local curX = x + dir * (LOT_DEPTH + LOT_GAP) * scale

	-- Rest: Z-facing (wide facade along X, facing player)
	for i = 2, #row do
		buildMansion(row[i], curX, z, scale, "z")
		curX = curX + dir * (row[i].facade + LOT_GAP) * scale
	end
end

return Mansion
