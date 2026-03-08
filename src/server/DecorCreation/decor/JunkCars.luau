local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))
local JunkCar = require(script.Parent:WaitForChild("JunkCar"))

local JunkCars = {}

-- Attach effects using built-in Fire/Smoke instances (same style as Junkyard barrels)
local function addEffects(car, fx)
	-- Find a random BasePart to attach to
	local parts = {}
	if car:IsA("BasePart") then
		table.insert(parts, car)
	else
		for _, p in car:GetDescendants() do
			if p:IsA("BasePart") then
				table.insert(parts, p)
			end
		end
	end
	if #parts == 0 then return end
	local target = parts[math.random(#parts)]

	if fx == "smoke" or fx == "both" then
		local smoke = Instance.new("Smoke")
		smoke.Size = 6
		smoke.Opacity = 0.3
		smoke.RiseVelocity = 4
		smoke.Color = Color3.fromRGB(50, 50, 50)
		smoke.Parent = target
	end

	if fx == "fire" or fx == "both" then
		local fire = Instance.new("Fire")
		fire.Size = 8
		fire.Heat = 6
		fire.Color = Color3.fromRGB(255, 140, 30)
		fire.SecondaryColor = Color3.fromRGB(255, 60, 0)
		fire.Parent = target
	end
end

function JunkCars.createJunkCars(x, z, scale)
	local decorFolder = DecorUtils.decorFolder
	if not decorFolder then return nil end
	scale = scale or 1
	local TERRAIN_TOP = DecorUtils.TERRAIN_TOP

	local model = Instance.new("Model")
	model.Name = "JunkCars"

	local groundY = TERRAIN_TOP + 5

	-- Dense scatter of wrecked cars — no gaps across the full playable width
	-- fx: "smoke", "fire", "both", or nil (no effects)
	local placements = {
		-- Row 1 (front, dz negative)
		{ variant = 1, dx = -35, dz = -8,  rot = 15,  fx = "smoke" },
		{ variant = 3, dx = -20, dz = -10, rot = -45 },
		{ variant = 5, dx = -5,  dz = -7,  rot = 30,  fx = "fire" },
		{ variant = 2, dx = 10,  dz = -9,  rot = -60 },
		{ variant = 4, dx = 25,  dz = -8,  rot = 20,  fx = "smoke" },
		{ variant = 1, dx = 37,  dz = -10, rot = -35 },
		-- Row 2 (center)
		{ variant = 4, dx = -32, dz = 0,   rot = -25, fx = "both" },
		{ variant = 2, dx = -15, dz = 2,   rot = 55 },
		{ variant = 1, dx = 0,   dz = -1,  rot = -10, fx = "smoke" },
		{ variant = 5, dx = 15,  dz = 1,   rot = 40,  fx = "fire" },
		{ variant = 3, dx = 30,  dz = 0,   rot = -50 },
		-- Row 3 (back, dz positive)
		{ variant = 2, dx = -37, dz = 8,   rot = 70 },
		{ variant = 5, dx = -22, dz = 10,  rot = -15, fx = "both" },
		{ variant = 3, dx = -8,  dz = 7,   rot = 45,  fx = "smoke" },
		{ variant = 1, dx = 8,   dz = 9,   rot = -70 },
		{ variant = 4, dx = 22,  dz = 8,   rot = 25,  fx = "fire" },
		{ variant = 2, dx = 35,  dz = 10,  rot = -40 },
	}

	for i, cp in ipairs(placements) do
		local car = JunkCar.build(cp.variant, i)
		local carX = x + cp.dx * scale
		local carZ = z + cp.dz * scale
		car:PivotTo(CFrame.new(carX, groundY, carZ) * CFrame.Angles(0, math.rad(cp.rot), 0))
		car:ScaleTo(1.2)

		-- Attach smoke/fire effects
		if cp.fx then
			addEffects(car, cp.fx)
		end

		car.Parent = model
	end

	model.Parent = decorFolder
	return model
end

return JunkCars
