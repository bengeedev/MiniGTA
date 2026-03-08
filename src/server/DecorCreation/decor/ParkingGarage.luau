local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))
local JunkCar = require(script.Parent:WaitForChild("JunkCar"))

local ParkingGarage = {}

function ParkingGarage.createParkingGarage(x, z, scale)
	local decorFolder = DecorUtils.decorFolder
	if not decorFolder then return nil end
	scale = scale or 1
	local TERRAIN_TOP = DecorUtils.TERRAIN_TOP
	local BUILDING_BASE = DecorUtils.BUILDING_BASE

	local model = Instance.new("Model")
	model.Name = "ParkingGarage"

	local sign_dir = x > 0 and 1 or -1
	local garageW = 40 * scale   -- width along X (away from road)
	local garageD = 34 * scale   -- depth along Z
	local floors = 3
	local floorH = 8 * scale
	local totalH = floors * floorH
	local baseY = TERRAIN_TOP + 2

	-- Garage center
	local cx = x + sign_dir * (garageW / 2)

	-- Concrete floor slabs for each level
	for f = 0, floors do
		local slabY = baseY + f * floorH
		local slab = Instance.new("Part")
		slab.Name = "GarageFloor_" .. f
		slab.Size = Vector3.new(garageW, 0.6, garageD)
		slab.Position = Vector3.new(cx, slabY, z)
		slab.Anchored = true
		slab.Material = Enum.Material.Concrete
		slab.Color = Color3.fromRGB(140, 135, 130)
		slab.Parent = model
	end

	-- Concrete columns (pillars)
	local colSpacingX = garageW / 3
	local colSpacingZ = garageD / 3
	for ix = 0, 3 do
		for iz = 0, 3 do
			local colX = cx - garageW / 2 + ix * colSpacingX
			local colZ = z - garageD / 2 + iz * colSpacingZ
			local col = Instance.new("Part")
			col.Name = "GarageColumn"
			col.Size = Vector3.new(1.2 * scale, totalH, 1.2 * scale)
			col.Position = Vector3.new(colX, baseY + totalH / 2, colZ)
			col.Anchored = true
			col.Material = Enum.Material.Concrete
			col.Color = Color3.fromRGB(160, 155, 150)
			col.Parent = model
		end
	end

	-- Half-walls along the edges (each floor, open structure feel)
	for f = 0, floors - 1 do
		local wallY = baseY + f * floorH + floorH * 0.3
		local wallH = floorH * 0.4

		-- Front wall (facing road) — low barrier
		local front = Instance.new("Part")
		front.Name = "GarageWall"
		front.Size = Vector3.new(0.5, wallH, garageD)
		front.Position = Vector3.new(cx - sign_dir * garageW / 2, wallY, z)
		front.Anchored = true
		front.Material = Enum.Material.Concrete
		front.Color = Color3.fromRGB(130, 125, 120)
		front.Parent = model

		-- Back wall
		local back = Instance.new("Part")
		back.Name = "GarageWall"
		back.Size = Vector3.new(0.5, floorH, garageD)
		back.Position = Vector3.new(cx + sign_dir * garageW / 2, baseY + f * floorH + floorH / 2, z)
		back.Anchored = true
		back.Material = Enum.Material.Concrete
		back.Color = Color3.fromRGB(120, 115, 110)
		back.Parent = model

		-- Side walls (partial)
		for _, sideSign in ipairs({ -1, 1 }) do
			local sideWall = Instance.new("Part")
			sideWall.Name = "GarageWall"
			sideWall.Size = Vector3.new(garageW, wallH, 0.5)
			sideWall.Position = Vector3.new(cx, wallY, z + sideSign * garageD / 2)
			sideWall.Anchored = true
			sideWall.Material = Enum.Material.Concrete
			sideWall.Color = Color3.fromRGB(130, 125, 120)
			sideWall.Parent = model
		end
	end

	-- Ramp between floors (along the back side)
	local rampW = 8 * scale
	local rampLen = garageD * 0.8
	for f = 0, floors - 2 do
		local rampStartY = baseY + f * floorH + 0.3
		local rampEndY = baseY + (f + 1) * floorH + 0.3
		local rampMidY = (rampStartY + rampEndY) / 2
		local rampAngle = math.atan2(floorH, rampLen)
		local rampHyp = math.sqrt(rampLen * rampLen + floorH * floorH)

		local ramp = Instance.new("Part")
		ramp.Name = "GarageRamp"
		ramp.Size = Vector3.new(rampW, 0.5, rampHyp)
		local rampX = cx + sign_dir * (garageW / 2 - rampW / 2 - 2)
		local rampSign = (f % 2 == 0) and 1 or -1
		ramp.CFrame = CFrame.new(rampX, rampMidY, z + rampSign * 2)
			* CFrame.Angles(rampSign * rampAngle, 0, 0)
		ramp.Anchored = true
		ramp.Material = Enum.Material.Concrete
		ramp.Color = Color3.fromRGB(150, 145, 140)
		ramp.Parent = model
	end

	-- "PARKING" sign on the front
	local signPart = Instance.new("Part")
	signPart.Name = "ParkingSign"
	signPart.Size = Vector3.new(0.5, 3 * scale, 12 * scale)
	signPart.Position = Vector3.new(cx - sign_dir * (garageW / 2 + 0.3), baseY + totalH - 2, z)
	signPart.Anchored = true
	signPart.Material = Enum.Material.Neon
	signPart.Color = Color3.fromRGB(50, 200, 255)
	signPart.Parent = model

	local gui = Instance.new("SurfaceGui")
	gui.Face = sign_dir > 0 and Enum.NormalId.Left or Enum.NormalId.Right
	gui.Parent = signPart
	local txt = Instance.new("TextLabel")
	txt.Size = UDim2.new(1, 0, 1, 0)
	txt.BackgroundTransparency = 1
	txt.Font = Enum.Font.GothamBold
	txt.Text = "PARKING"
	txt.TextColor3 = Color3.new(1, 1, 1)
	txt.TextScaled = true
	txt.Parent = gui

	-- === APOCALYPSE EFFECTS ===

	-- Burning junk car inside the garage (ground floor)
	local carGroundY = baseY + 0.5
	local carX = cx - sign_dir * (garageW * 0.15)  -- offset toward front inside
	local carZ = z + 4
	do
		local car = JunkCar.build(1, 200)
		car:PivotTo(CFrame.new(carX, carGroundY, carZ) * CFrame.Angles(0, math.rad(35), 0))
		car.Parent = model

		-- Big fire on the car
		local fireSource = Instance.new("Part")
		fireSource.Name = "CarFireSource"
		fireSource.Size = Vector3.new(5, 1, 5)
		fireSource.Position = Vector3.new(carX, carGroundY + 3, carZ)
		fireSource.Anchored = true
		fireSource.CanCollide = false
		fireSource.Transparency = 1
		fireSource.Parent = model

		local carFire = Instance.new("Fire")
		carFire.Size = 18
		carFire.Heat = 14
		carFire.Color = Color3.fromRGB(255, 120, 0)
		carFire.SecondaryColor = Color3.fromRGB(60, 20, 0)
		carFire.Parent = fireSource

		-- Thick black smoke rising from the car
		local carSmoke = Instance.new("Smoke")
		carSmoke.Size = 14
		carSmoke.Opacity = 0.7
		carSmoke.RiseVelocity = 10
		carSmoke.Color = Color3.fromRGB(30, 25, 20)
		carSmoke.Parent = fireSource
	end

	-- Smoke points at every garage level (front, sides)
	for f = 0, floors - 1 do
		local smokeY = baseY + f * floorH + floorH * 0.5
		local frontX = cx - sign_dir * (garageW / 2 - 1)

		-- Front edge: 3 smoke points spread along Z
		for _, zOff in ipairs({ -garageD * 0.3, 0, garageD * 0.3 }) do
			local src = Instance.new("Part")
			src.Name = "SmokePoint"
			src.Size = Vector3.new(1, 1, 1)
			src.Position = Vector3.new(frontX, smokeY, z + zOff)
			src.Anchored = true
			src.CanCollide = false
			src.Transparency = 1
			src.Parent = model

			local smoke = Instance.new("Smoke")
			smoke.Size = 5 + f * 3
			smoke.Opacity = 0.3 + f * 0.1
			smoke.RiseVelocity = 3 + f * 2
			smoke.Color = Color3.fromRGB(40, 35, 30)
			smoke.Parent = src
		end

		-- Side edges: 1 smoke point each side
		for _, sideOff in ipairs({ -1, 1 }) do
			local src = Instance.new("Part")
			src.Name = "SmokePoint"
			src.Size = Vector3.new(1, 1, 1)
			src.Position = Vector3.new(cx, smokeY, z + sideOff * (garageD / 2 - 1))
			src.Anchored = true
			src.CanCollide = false
			src.Transparency = 1
			src.Parent = model

			local smoke = Instance.new("Smoke")
			smoke.Size = 4 + f * 2
			smoke.Opacity = 0.25 + f * 0.08
			smoke.RiseVelocity = 3 + f * 1.5
			smoke.Color = Color3.fromRGB(45, 40, 35)
			smoke.Parent = src
		end
	end

	model.Parent = decorFolder
	return model
end

return ParkingGarage
