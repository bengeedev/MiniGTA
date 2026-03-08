local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local Warehouse = {}

local TERRAIN_TOP = DecorUtils.TERRAIN_TOP
local addWindowsToFace = DecorUtils.addWindowsToFace

--------------------------------------------------------------------------------
-- LEFT / RIGHT specs for visual variety
--------------------------------------------------------------------------------

local LEFT_SPEC = {
	bodyMat   = Enum.Material.DiamondPlate,
	bodyColor = Color3.fromRGB(95, 90, 85),
	roofColor = Color3.fromRGB(70, 67, 63),
	signText  = "GLOBAL LOGISTICS",
	signColor = Color3.fromRGB(255, 180, 60),  -- warm amber
	bayCount  = 3,
	containers = {
		{ color = Color3.fromRGB(180, 40, 40) },   -- red
		{ color = Color3.fromRGB(40, 80, 160) },    -- blue
		{ color = Color3.fromRGB(50, 130, 60) },    -- green
	},
}

local RIGHT_SPEC = {
	bodyMat   = Enum.Material.Metal,
	bodyColor = Color3.fromRGB(90, 95, 100),
	roofColor = Color3.fromRGB(65, 70, 75),
	signText  = "FREIGHT DEPOT",
	signColor = Color3.fromRGB(60, 200, 255),  -- cool cyan
	bayCount  = 4,
	containers = {
		{ color = Color3.fromRGB(200, 170, 40) },   -- yellow
		{ color = Color3.fromRGB(210, 120, 40) },    -- orange
		{ color = Color3.fromRGB(130, 130, 135) },   -- gray
	},
}

--------------------------------------------------------------------------------
-- createWarehouse(x, z, scale)
--------------------------------------------------------------------------------

function Warehouse.createWarehouse(x, z, scale)
	local decorFolder = DecorUtils.decorFolder
	if not decorFolder then return nil end
	scale = scale or 1

	local spec = (x < 0) and LEFT_SPEC or RIGHT_SPEC
	local sign_dir = x > 0 and 1 or -1

	local model = Instance.new("Model")
	model.Name = "Warehouse"

	-- Dimensions (pre-scale)
	local bodyW = 38 * scale
	local bodyH = 16 * scale
	local bodyD = 30 * scale
	local baseY = TERRAIN_TOP

	-- Center of building (pushed away from road)
	local cx = x + sign_dir * (bodyW / 2)

	--------------------------------------------------------------------
	-- Main body
	--------------------------------------------------------------------
	local body = Instance.new("Part")
	body.Name = "WarehouseBody"
	body.Size = Vector3.new(bodyW, bodyH, bodyD)
	body.Position = Vector3.new(cx, baseY + bodyH / 2, z)
	body.Anchored = true
	body.Material = spec.bodyMat
	body.Color = spec.bodyColor
	body.Parent = model

	--------------------------------------------------------------------
	-- Roof (slight overhang, darker shade)
	--------------------------------------------------------------------
	local roof = Instance.new("Part")
	roof.Name = "WarehouseRoof"
	roof.Size = Vector3.new((40) * scale, 0.6 * scale, (32) * scale)
	roof.Position = Vector3.new(cx, baseY + bodyH + 0.3 * scale, z)
	roof.Anchored = true
	roof.Material = Enum.Material.DiamondPlate
	roof.Color = spec.roofColor
	roof.Parent = model

	--------------------------------------------------------------------
	-- 2 Roof vents (HVAC units)
	--------------------------------------------------------------------
	for i = 1, 2 do
		local ventZ = z + (i == 1 and -8 or 8) * scale
		local ventX = cx + sign_dir * 5 * scale

		local vent = Instance.new("Part")
		vent.Name = "RoofVent"
		vent.Size = Vector3.new(3 * scale, 2.5 * scale, 3 * scale)
		vent.Position = Vector3.new(ventX, baseY + bodyH + 0.6 * scale + 1.25 * scale, ventZ)
		vent.Anchored = true
		vent.Material = Enum.Material.Metal
		vent.Color = Color3.fromRGB(170, 170, 175)
		vent.Parent = model
	end

	--------------------------------------------------------------------
	-- Loading dock (raised platform, road-facing wall)
	--------------------------------------------------------------------
	local dockW = 5 * scale
	local dockH = 3.5 * scale
	local dockD = 26 * scale
	local dockX = x - sign_dir * (dockW / 2)  -- extends toward road from building edge

	local dock = Instance.new("Part")
	dock.Name = "LoadingDock"
	dock.Size = Vector3.new(dockW, dockH, dockD)
	dock.Position = Vector3.new(dockX, baseY + dockH / 2, z)
	dock.Anchored = true
	dock.Material = Enum.Material.Concrete
	dock.Color = Color3.fromRGB(140, 135, 130)
	dock.Parent = model

	--------------------------------------------------------------------
	-- Dock edge strip (yellow safety strip)
	--------------------------------------------------------------------
	local stripX = dockX - sign_dir * (dockW / 2 - 0.15)

	local strip = Instance.new("Part")
	strip.Name = "DockStrip"
	strip.Size = Vector3.new(0.3 * scale, 0.5 * scale, dockD)
	strip.Position = Vector3.new(stripX, baseY + dockH + 0.25 * scale, z)
	strip.Anchored = true
	strip.CanCollide = false
	strip.Material = Enum.Material.Neon
	strip.Color = Color3.fromRGB(220, 190, 0)
	strip.Parent = model

	--------------------------------------------------------------------
	-- Bay doors (on wall behind dock) + hazard strips above
	--------------------------------------------------------------------
	local bayFaceX = cx - sign_dir * (bodyW / 2 + 0.15)
	local bayW = 5 * scale
	local bayH = 7 * scale
	local baySpacing = dockD / (spec.bayCount + 1)

	for i = 1, spec.bayCount do
		local bayZ = z - dockD / 2 + i * baySpacing

		-- Door recess
		local door = Instance.new("Part")
		door.Name = "BayDoor"
		door.Size = Vector3.new(0.3 * scale, bayH, bayW)
		door.Position = Vector3.new(bayFaceX, baseY + dockH + bayH / 2, bayZ)
		door.Anchored = true
		door.Material = Enum.Material.CorrodedMetal
		door.Color = Color3.fromRGB(90, 65, 45)
		door.Parent = model

		-- Hazard strip above bay door
		local hazard = Instance.new("Part")
		hazard.Name = "HazardStrip"
		hazard.Size = Vector3.new(0.35 * scale, 0.5 * scale, 5.4 * scale)
		hazard.Position = Vector3.new(bayFaceX - sign_dir * 0.05, baseY + dockH + bayH + 0.25 * scale, bayZ)
		hazard.Anchored = true
		hazard.CanCollide = false
		hazard.Material = Enum.Material.Neon
		hazard.Color = Color3.fromRGB(220, 190, 0)
		hazard.Parent = model
	end

	--------------------------------------------------------------------
	-- 4 Safety bollards along dock edge
	--------------------------------------------------------------------
	local bollardDiam = 0.8 * scale
	local bollardH = 2.5 * scale
	local bollardSpacing = dockD / 5

	for i = 1, 4 do
		local bollardZ = z - dockD / 2 + i * bollardSpacing
		local bollardX = dockX - sign_dir * (dockW / 2 + 0.8 * scale)

		local bollard = Instance.new("Part")
		bollard.Name = "SafetyBollard"
		bollard.Shape = Enum.PartType.Cylinder
		bollard.Size = Vector3.new(bollardH, bollardDiam, bollardDiam)
		bollard.CFrame = CFrame.new(bollardX, baseY + bollardH / 2, bollardZ) * CFrame.Angles(0, 0, math.rad(90))
		bollard.Anchored = true
		bollard.Material = Enum.Material.SmoothPlastic
		bollard.Color = Color3.fromRGB(220, 190, 0)
		bollard.Parent = model
	end

	--------------------------------------------------------------------
	-- Warehouse sign (Neon + SurfaceGui)
	--------------------------------------------------------------------
	local signW = 14 * scale
	local signH = 2.5 * scale
	local signX = cx - sign_dir * (bodyW / 2 + 0.3)
	local signY = baseY + bodyH - 3.5 * scale

	local signPart = Instance.new("Part")
	signPart.Name = "WarehouseSign"
	signPart.Size = Vector3.new(0.4 * scale, signH, signW)
	signPart.Position = Vector3.new(signX, signY, z)
	signPart.Anchored = true
	signPart.Material = Enum.Material.Neon
	signPart.Color = spec.signColor
	signPart.Parent = model

	local gui = Instance.new("SurfaceGui")
	gui.Face = sign_dir > 0 and Enum.NormalId.Left or Enum.NormalId.Right
	gui.Parent = signPart

	local txt = Instance.new("TextLabel")
	txt.Size = UDim2.new(1, 0, 1, 0)
	txt.BackgroundTransparency = 1
	txt.Font = Enum.Font.GothamBold
	txt.Text = spec.signText
	txt.TextColor3 = Color3.new(1, 1, 1)
	txt.TextScaled = true
	txt.Parent = gui

	local signLight = Instance.new("PointLight")
	signLight.Brightness = 1.5
	signLight.Range = 16
	signLight.Color = spec.signColor
	signLight.Parent = signPart

	--------------------------------------------------------------------
	-- 3 Shipping containers (2 ground + 1 stacked)
	--------------------------------------------------------------------
	local containerBaseZ = z + bodyD / 2 + 2 * scale
	local containerH = 5 * scale
	local containerD = 5 * scale

	for i = 1, 3 do
		local cW = 11 * scale
		local cX = cx
		local cZ, cY

		if i <= 2 then
			-- Two on the ground, spaced along Z
			cZ = containerBaseZ + (i - 1) * (containerD + 1 * scale)
			cY = baseY + containerH / 2
		else
			-- Third stacked on top of first
			cZ = containerBaseZ
			cY = baseY + containerH + containerH / 2
		end

		local container = Instance.new("Part")
		container.Name = "ShippingContainer"
		container.Size = Vector3.new(cW, containerH, containerD)
		container.Position = Vector3.new(cX, cY, cZ)
		container.Anchored = true
		container.Material = Enum.Material.DiamondPlate
		container.Color = spec.containers[i].color
		container.Parent = model

		-- Container ridge (corrugation cap)
		local ridge = Instance.new("Part")
		ridge.Name = "ContainerRidge"
		ridge.Size = Vector3.new(cW + 0.2, 0.4 * scale, containerD + 0.2)
		ridge.Position = Vector3.new(cX, cY + containerH / 2 + 0.2 * scale, cZ)
		ridge.Anchored = true
		ridge.Material = Enum.Material.Metal
		ridge.Color = Color3.fromRGB(60, 60, 65)
		ridge.Parent = model
	end

	--------------------------------------------------------------------
	-- 3 Pallets + crates (other end of building along Z)
	--------------------------------------------------------------------
	local palletBaseZ = z - bodyD / 2 - 2 * scale

	for i = 1, 3 do
		local palletZ = palletBaseZ - (i - 1) * 4 * scale
		local palletX = cx + sign_dir * (5 + (i - 1) * 3) * scale

		-- Pallet
		local pallet = Instance.new("Part")
		pallet.Name = "Pallet"
		pallet.Size = Vector3.new(2.5 * scale, 0.3 * scale, 2.5 * scale)
		pallet.Position = Vector3.new(palletX, baseY + 0.15 * scale, palletZ)
		pallet.Anchored = true
		pallet.Material = Enum.Material.WoodPlanks
		pallet.Color = Color3.fromRGB(160, 120, 70)
		pallet.Parent = model

		-- Crate on pallet (varying heights)
		local crateH = (1.5 + i * 0.5) * scale
		local crate = Instance.new("Part")
		crate.Name = "Crate"
		crate.Size = Vector3.new(2.0 * scale, crateH, 2.0 * scale)
		crate.Position = Vector3.new(palletX, baseY + 0.3 * scale + crateH / 2, palletZ)
		crate.Anchored = true
		crate.Material = Enum.Material.WoodPlanks
		crate.Color = Color3.fromRGB(140, 100, 55)
		crate.Parent = model
	end

	--------------------------------------------------------------------
	-- Side wall windows (sparse, industrial feel)
	--------------------------------------------------------------------
	local sideZ1 = z - bodyD / 2
	local sideZ2 = z + bodyD / 2
	addWindowsToFace(
		model, "z", sideZ1, cx,
		bodyW, baseY, 2, bodyH / 2,
		2.0, 1.8, 3.0,
		Color3.fromRGB(200, 170, 80), 0.20
	)
	addWindowsToFace(
		model, "z", sideZ2, cx,
		bodyW, baseY, 2, bodyH / 2,
		2.0, 1.8, 3.0,
		Color3.fromRGB(200, 170, 80), 0.20
	)

	model.Parent = decorFolder
	return model
end

return Warehouse
