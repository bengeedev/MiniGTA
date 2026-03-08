local VU = require(script.Parent:WaitForChild("VehicleUtils"))

local MilitaryJeep = {}

--------------------------------------------------------------------------------
-- MILITARY JEEP  (faces +Z forward, wheels on ground at Y=0)
-- Open-top army jeep with roll cage, push bar
--------------------------------------------------------------------------------

local BLACK      = Color3.fromRGB(25, 25, 28)
local WHITE      = Color3.fromRGB(240, 240, 245)
local DARK_METAL = Color3.fromRGB(50, 50, 55)
local YELLOW_NEON = Color3.fromRGB(255, 220, 60)

local OLIVE      = Color3.fromRGB(85, 107, 47)
local DARK_GREEN = Color3.fromRGB(50, 70, 35)

function MilitaryJeep.build()
	local model = Instance.new("Model")
	model.Name = "Jeep_Military_1"

	local wheelR = 2.0
	local wheelW = 1.4
	local frontZ = 5.2
	local rearZ  = -5.2
	local halfW  = 3.8
	local floorY = wheelR + 0.5
	local cabinTop = floorY + 5.5  -- tall enough for R15 NPCs

	-- Wheels (chunky off-road tires)
	for _, wz in ipairs({frontZ, rearZ}) do
		for _, sx in ipairs({-1, 1}) do
			VU.cylinder(model, "Tire",
				Vector3.new(wheelW, wheelR * 2, wheelR * 2),
				CFrame.new(sx * halfW, wheelR, wz),
				BLACK, Enum.Material.SmoothPlastic)
			VU.cylinder(model, "Hub",
				Vector3.new(wheelW + 0.15, wheelR * 0.6, wheelR * 0.6),
				CFrame.new(sx * halfW, wheelR, wz),
				DARK_METAL, Enum.Material.Metal)
		end
	end

	-- Chassis (wider, longer)
	local chassis = VU.part(model, "Chassis",
		Vector3.new(7.5, 1.4, 13),
		CFrame.new(0, floorY, 0),
		OLIVE, Enum.Material.SmoothPlastic)

	-- Hood (angled front)
	VU.wedge(model, "Hood",
		Vector3.new(7, 1.2, 3.5),
		CFrame.new(0, floorY + 1, 4.5) * CFrame.Angles(0, math.rad(180), 0),
		DARK_GREEN, Enum.Material.SmoothPlastic)

	-- Flat hood top
	VU.part(model, "HoodTop",
		Vector3.new(7, 0.2, 3),
		CFrame.new(0, floorY + 1.6, 3),
		DARK_GREEN, Enum.Material.SmoothPlastic)

	-- Star marking on hood
	VU.part(model, "StarDecal",
		Vector3.new(1.8, 0.05, 1.8),
		CFrame.new(0, floorY + 1.7, 3.5),
		WHITE, Enum.Material.SmoothPlastic)

	-- Side body panels (cabin walls)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "SidePanel",
			Vector3.new(0.4, 2.2, 6),
			CFrame.new(sx * 3.4, floorY + 1.8, -0.5),
			OLIVE, Enum.Material.SmoothPlastic)
	end

	-- Seat bench
	VU.part(model, "SeatBench",
		Vector3.new(6.4, 0.4, 2.5),
		CFrame.new(0, floorY + 0.9, 0),
		DARK_GREEN, Enum.Material.SmoothPlastic)

	-- Seat back
	VU.part(model, "SeatBack",
		Vector3.new(6.4, 2.5, 0.4),
		CFrame.new(0, floorY + 2.2, -1.2),
		DARK_GREEN, Enum.Material.SmoothPlastic)

	-- Windshield frame (taller, no glass -- open top)
	VU.part(model, "WindshieldFrame",
		Vector3.new(7, 0.3, 0.3),
		CFrame.new(0, cabinTop, 2.8),
		DARK_METAL, Enum.Material.Metal)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "WindshieldPost",
			Vector3.new(0.3, cabinTop - floorY - 0.5, 0.3),
			CFrame.new(sx * 3.2, floorY + (cabinTop - floorY) / 2 + 0.3, 2.8),
			DARK_METAL, Enum.Material.Metal)
	end

	-- Roll cage (tall enough for R15 NPCs)
	for _, sx in ipairs({-1, 1}) do
		-- Top side bars
		VU.part(model, "RollCageSide",
			Vector3.new(0.25, 0.25, 6),
			CFrame.new(sx * 3.2, cabinTop, -0.2),
			DARK_METAL, Enum.Material.Metal)
		-- Rear vertical bars
		VU.part(model, "RollCageVert",
			Vector3.new(0.25, cabinTop - floorY - 0.5, 0.25),
			CFrame.new(sx * 3.2, floorY + (cabinTop - floorY) / 2 + 0.3, -3.2),
			DARK_METAL, Enum.Material.Metal)
	end
	-- Rear top bar
	VU.part(model, "RollCageRear",
		Vector3.new(7, 0.25, 0.25),
		CFrame.new(0, cabinTop, -3.2),
		DARK_METAL, Enum.Material.Metal)

	-- Rear cargo bed with side rails
	VU.part(model, "RearBed",
		Vector3.new(6.5, 0.4, 3.5),
		CFrame.new(0, floorY + 0.2, -4.5),
		OLIVE, Enum.Material.SmoothPlastic)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "BedRail",
			Vector3.new(0.3, 1.5, 3.5),
			CFrame.new(sx * 3.2, floorY + 1.2, -4.5),
			DARK_METAL, Enum.Material.Metal)
	end
	-- Tailgate
	VU.part(model, "Tailgate",
		Vector3.new(6.5, 1.5, 0.3),
		CFrame.new(0, floorY + 1.2, -6.3),
		OLIVE, Enum.Material.SmoothPlastic)

	-- Push bar (front bumper -- heavy duty)
	VU.part(model, "PushBar",
		Vector3.new(6.5, 1.8, 0.6),
		CFrame.new(0, floorY + 0.6, 6.5),
		DARK_METAL, Enum.Material.Metal)

	-- Headlights
	for _, sx in ipairs({-2.2, 2.2}) do
		VU.cylinder(model, "Headlight",
			Vector3.new(0.3, 1.0, 1.0),
			CFrame.new(sx, floorY + 1.2, 6.3) * CFrame.Angles(0, math.rad(90), 0),
			YELLOW_NEON, Enum.Material.Neon)
	end

	-- Taillights (red)
	for _, sx in ipairs({-2.5, 2.5}) do
		VU.part(model, "Taillight",
			Vector3.new(0.6, 0.6, 0.15),
			CFrame.new(sx, floorY + 1.2, -6.4),
			Color3.fromRGB(200, 20, 20), Enum.Material.Neon)
	end

	-- Radio antenna (rear right)
	VU.part(model, "Antenna",
		Vector3.new(0.1, 4, 0.1),
		CFrame.new(2.8, cabinTop + 2, -3),
		DARK_METAL, Enum.Material.Metal)

	-- Side mirrors
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Mirror",
			Vector3.new(0.15, 0.5, 0.7),
			CFrame.new(sx * 3.8, floorY + 3, 2.5),
			DARK_METAL, Enum.Material.Metal)
	end

	model.PrimaryPart = chassis
	return model
end

return MilitaryJeep
