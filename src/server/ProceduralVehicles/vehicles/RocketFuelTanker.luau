local VU = require(script.Parent:WaitForChild("VehicleUtils"))

local RocketFuelTanker = {}

-- Shared colors
local BLACK       = Color3.fromRGB(25, 25, 28)
local DARK_METAL  = Color3.fromRGB(50, 50, 55)
local YELLOW_NEON = Color3.fromRGB(255, 220, 60)
local C_WARN_AMBER = Color3.fromRGB(255, 160, 30)

-- Rocket fuel tanker-specific colors
local C_NASA_WHITE  = Color3.fromRGB(230, 230, 235)
local C_NASA_GREY   = Color3.fromRGB(160, 165, 170)
local C_NASA_DARK   = Color3.fromRGB(60, 65, 70)
local C_FUEL_ORANGE = Color3.fromRGB(255, 120, 20)
local C_FUEL_RED    = Color3.fromRGB(220, 40, 30)
local C_CRYO_BLUE   = Color3.fromRGB(160, 210, 255)
local C_VAPOR       = Color3.fromRGB(220, 240, 255)

function RocketFuelTanker.build()
	local model = Instance.new("Model")
	model.Name = "RocketFuelTanker_1"

	-- Layout (longer than other trucks — it's a tanker)
	local wheelR = 2.0
	local wheelW = 1.3
	local frontZ = 6
	local rearZ  = -10
	local halfW  = 3.8
	local floorY = wheelR + 0.4

	---------------------------------------------------------------------------
	-- WHEELS (heavy-duty, 3 axles)
	---------------------------------------------------------------------------
	-- Front axle
	for _, sx in ipairs({-1, 1}) do
		VU.cylinder(model, "FrontTire",
			Vector3.new(wheelW, wheelR * 2, wheelR * 2),
			CFrame.new(sx * halfW, wheelR, frontZ - 1),
			BLACK, Enum.Material.SmoothPlastic)
		VU.cylinder(model, "FrontHub",
			Vector3.new(wheelW + 0.1, wheelR * 0.6, wheelR * 0.6),
			CFrame.new(sx * halfW, wheelR, frontZ - 1),
			DARK_METAL, Enum.Material.Metal)
	end
	-- Mid rear axle (dual)
	for _, sx in ipairs({-1, 1}) do
		for _, offset in ipairs({0, 1.3}) do
			VU.cylinder(model, "MidRearTire",
				Vector3.new(wheelW * 0.9, wheelR * 2, wheelR * 2),
				CFrame.new(sx * (halfW + offset * sx * 0.3), wheelR, rearZ + 4),
				BLACK, Enum.Material.SmoothPlastic)
		end
		VU.cylinder(model, "MidRearHub",
			Vector3.new(wheelW * 2.2, wheelR * 0.6, wheelR * 0.6),
			CFrame.new(sx * halfW, wheelR, rearZ + 4),
			DARK_METAL, Enum.Material.Metal)
	end
	-- Rear axle (dual)
	for _, sx in ipairs({-1, 1}) do
		for _, offset in ipairs({0, 1.3}) do
			VU.cylinder(model, "RearTire",
				Vector3.new(wheelW * 0.9, wheelR * 2, wheelR * 2),
				CFrame.new(sx * (halfW + offset * sx * 0.3), wheelR, rearZ + 1.5),
				BLACK, Enum.Material.SmoothPlastic)
		end
		VU.cylinder(model, "RearHub",
			Vector3.new(wheelW * 2.2, wheelR * 0.6, wheelR * 0.6),
			CFrame.new(sx * halfW, wheelR, rearZ + 1.5),
			DARK_METAL, Enum.Material.Metal)
	end

	---------------------------------------------------------------------------
	-- CHASSIS
	---------------------------------------------------------------------------
	local chassis = VU.part(model, "Chassis",
		Vector3.new(7.5, 1.0, 18),
		CFrame.new(0, floorY, -2),
		C_NASA_DARK, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- CAB (NASA white, compact)
	---------------------------------------------------------------------------
	local cabH = 5.5
	local cabZ = frontZ - 2

	local cabW = 7.5
	local cabD = 5
	-- Back wall
	VU.part(model, "CabBack",
		Vector3.new(cabW, cabH, 0.3),
		CFrame.new(0, floorY + cabH / 2, cabZ - cabD / 2 + 0.15),
		C_NASA_WHITE, Enum.Material.SmoothPlastic)
	-- Side walls (door panels below window line)
	local doorH = 2.0
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "CabSide",
			Vector3.new(0.3, doorH, cabD),
			CFrame.new(sx * (cabW / 2 - 0.15), floorY + doorH / 2, cabZ),
			C_NASA_WHITE, Enum.Material.SmoothPlastic)
	end
	-- Floor
	VU.part(model, "CabFloor",
		Vector3.new(cabW, 0.3, cabD),
		CFrame.new(0, floorY + 0.15, cabZ),
		C_NASA_WHITE, Enum.Material.SmoothPlastic)

	-- Hood
	VU.wedge(model, "Hood",
		Vector3.new(7.2, 1.2, 3),
		CFrame.new(0, floorY + 0.9, frontZ + 0.8) * CFrame.Angles(0, math.rad(180), 0),
		C_NASA_WHITE, Enum.Material.SmoothPlastic)

	VU.part(model, "HoodTop",
		Vector3.new(7.2, 0.2, 2),
		CFrame.new(0, floorY + 1.5, frontZ - 0.5),
		C_NASA_GREY, Enum.Material.SmoothPlastic)

	-- Windshield (proud of cab face)
	local windshield = VU.part(model, "Windshield",
		Vector3.new(6.2, 3.2, 0.2),
		CFrame.new(0, floorY + 3.8, cabZ + 2.6) * CFrame.Angles(math.rad(-8), 0, 0),
		Color3.fromRGB(100, 140, 170), Enum.Material.Glass)
	windshield.Transparency = 0.8

	-- Side windows
	for _, sx in ipairs({-1, 1}) do
		local win = VU.part(model, "SideWindow",
			Vector3.new(0.15, 2.5, 3),
			CFrame.new(sx * 3.8, floorY + 3.5, cabZ),
			Color3.fromRGB(100, 140, 170), Enum.Material.Glass)
		win.Transparency = 0.8
	end

	-- Cab roof
	VU.part(model, "CabRoof",
		Vector3.new(7.7, 0.3, 5.2),
		CFrame.new(0, floorY + cabH + 0.15, cabZ),
		C_NASA_GREY, Enum.Material.SmoothPlastic)

	-- NASA blue stripe on cab sides
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "NasaStripe",
			Vector3.new(0.05, 0.8, 4.5),
			CFrame.new(sx * 3.78, floorY + 2, cabZ),
			Color3.fromRGB(30, 60, 150), Enum.Material.SmoothPlastic)
	end

	---------------------------------------------------------------------------
	-- FUEL TANK (large horizontal cylinder)
	---------------------------------------------------------------------------
	local tankR = 3.2
	local tankLen = 12
	local tankZ = -3.5
	local tankY = floorY + 0.5 + tankR

	-- Main tank
	VU.cylinder(model, "FuelTank",
		Vector3.new(tankLen, tankR * 2, tankR * 2),
		CFrame.new(0, tankY, tankZ) * CFrame.Angles(0, math.rad(90), 0),
		C_NASA_WHITE, Enum.Material.SmoothPlastic)

	-- Front dome cap
	VU.ball(model, "TankCapFront",
		Vector3.new(tankR * 2, tankR * 2, tankR * 1.2),
		CFrame.new(0, tankY, tankZ + tankLen / 2),
		C_NASA_GREY, Enum.Material.Metal)

	-- Rear dome cap
	VU.ball(model, "TankCapRear",
		Vector3.new(tankR * 2, tankR * 2, tankR * 1.2),
		CFrame.new(0, tankY, tankZ - tankLen / 2),
		C_NASA_GREY, Enum.Material.Metal)

	-- Support cradles
	for _, cz in ipairs({tankZ - 3, tankZ + 3}) do
		VU.part(model, "TankCradle",
			Vector3.new(7, 0.4, 0.6),
			CFrame.new(0, floorY + 0.5, cz),
			DARK_METAL, Enum.Material.Metal)
		for _, sx in ipairs({-1, 1}) do
			VU.part(model, "CradleArm",
				Vector3.new(0.4, tankR + 0.5, 0.6),
				CFrame.new(sx * 3, floorY + 0.5 + (tankR + 0.5) / 2, cz),
				DARK_METAL, Enum.Material.Metal)
		end
	end

	-- Orange hazard band at tank center
	VU.cylinder(model, "HazardBand",
		Vector3.new(0.6, tankR * 2.05, tankR * 2.05),
		CFrame.new(0, tankY, tankZ) * CFrame.Angles(0, math.rad(90), 0),
		C_FUEL_ORANGE, Enum.Material.SmoothPlastic)

	-- Red label bands near each end
	for _, lz in ipairs({tankZ - 3.5, tankZ + 3.5}) do
		VU.cylinder(model, "FuelLabel",
			Vector3.new(0.4, tankR * 2.04, tankR * 2.04),
			CFrame.new(0, tankY, lz) * CFrame.Angles(0, math.rad(90), 0),
			C_FUEL_RED, Enum.Material.SmoothPlastic)
	end

	-- Piping on top of tank
	VU.cylinder(model, "TopPipe",
		Vector3.new(0.4, 0.4, tankLen - 2),
		CFrame.new(0, tankY + tankR + 0.2, tankZ),
		DARK_METAL, Enum.Material.Metal)

	-- Pressure valves
	for _, vz in ipairs({tankZ - 2, tankZ, tankZ + 2}) do
		VU.cylinder(model, "Valve",
			Vector3.new(1.2, 0.6, 0.6),
			CFrame.new(0, tankY + tankR + 0.6, vz) * CFrame.Angles(0, 0, math.rad(90)),
			DARK_METAL, Enum.Material.Metal)
	end

	---------------------------------------------------------------------------
	-- CRYO VAPOR EFFECTS
	---------------------------------------------------------------------------
	-- Steam from valves (top)
	local vaporTop = Instance.new("Part")
	vaporTop.Name = "VaporTop"
	vaporTop.Size = Vector3.new(1, 1, 1)
	vaporTop.Position = Vector3.new(0, tankY + tankR + 1.5, tankZ)
	vaporTop.Anchored = true
	vaporTop.CanCollide = false
	vaporTop.Transparency = 1
	vaporTop.Parent = model

	local steamTop = Instance.new("ParticleEmitter")
	steamTop.Name = "CryoSteam"
	steamTop.Rate = 30
	steamTop.Speed = NumberRange.new(2, 5)
	steamTop.Lifetime = NumberRange.new(0.8, 2)
	steamTop.SpreadAngle = Vector2.new(40, 40)
	steamTop.EmissionDirection = Enum.NormalId.Top
	steamTop.LightEmission = 0.3
	steamTop.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.5, 1.5),
		NumberSequenceKeypoint.new(1, 3),
	})
	steamTop.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.4),
		NumberSequenceKeypoint.new(0.5, 0.6),
		NumberSequenceKeypoint.new(1, 1),
	})
	steamTop.Color = ColorSequence.new(C_VAPOR)
	steamTop.Brightness = 1.5
	steamTop.Parent = vaporTop

	-- Condensation dripping from rear cap
	local vaporRear = Instance.new("Part")
	vaporRear.Name = "VaporRear"
	vaporRear.Size = Vector3.new(1, 1, 1)
	vaporRear.Position = Vector3.new(0, tankY - tankR, tankZ - tankLen / 2)
	vaporRear.Anchored = true
	vaporRear.CanCollide = false
	vaporRear.Transparency = 1
	vaporRear.Parent = model

	local steamRear = Instance.new("ParticleEmitter")
	steamRear.Name = "CryoDrip"
	steamRear.Rate = 20
	steamRear.Speed = NumberRange.new(1, 3)
	steamRear.Lifetime = NumberRange.new(0.5, 1.5)
	steamRear.SpreadAngle = Vector2.new(25, 25)
	steamRear.EmissionDirection = Enum.NormalId.Bottom
	steamRear.LightEmission = 0.2
	steamRear.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(1, 1.5),
	})
	steamRear.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(1, 1),
	})
	steamRear.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, C_CRYO_BLUE),
		ColorSequenceKeypoint.new(1, C_VAPOR),
	})
	steamRear.Brightness = 1.5
	steamRear.Parent = vaporRear

	-- Frost glow
	local frostGlow = Instance.new("PointLight")
	frostGlow.Name = "FrostGlow"
	frostGlow.Brightness = 1.5
	frostGlow.Range = 16
	frostGlow.Color = C_CRYO_BLUE
	frostGlow.Parent = model:FindFirstChild("FuelTank")

	---------------------------------------------------------------------------
	-- LIGHTS + SIGNS
	---------------------------------------------------------------------------
	for _, sx in ipairs({-2.8, 2.8}) do
		VU.part(model, "WarningLight",
			Vector3.new(0.8, 0.5, 0.8),
			CFrame.new(sx, floorY + cabH + 0.6, cabZ + 1),
			C_WARN_AMBER, Enum.Material.Neon)
	end

	for _, sx in ipairs({-2.5, 2.5}) do
		VU.cylinder(model, "Headlight",
			Vector3.new(0.3, 1.2, 1.2),
			CFrame.new(sx, floorY + 1.2, frontZ + 1.5) * CFrame.Angles(0, math.rad(90), 0),
			YELLOW_NEON, Enum.Material.Neon)
	end

	for _, sx in ipairs({-2.8, 2.8}) do
		VU.part(model, "Taillight",
			Vector3.new(0.8, 0.6, 0.15),
			CFrame.new(sx, floorY + 0.8, rearZ),
			Color3.fromRGB(200, 20, 20), Enum.Material.Neon)
	end

	-- Hazard sign on rear
	VU.part(model, "HazardSign",
		Vector3.new(3, 1.5, 0.1),
		CFrame.new(0, floorY + 2.5, rearZ - 0.1),
		C_FUEL_ORANGE, Enum.Material.SmoothPlastic)
	VU.part(model, "HazardIcon",
		Vector3.new(1, 1, 0.05),
		CFrame.new(0, floorY + 2.5, rearZ - 0.2),
		C_FUEL_RED, Enum.Material.SmoothPlastic)

	-- Side mirrors
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Mirror",
			Vector3.new(0.15, 0.5, 0.7),
			CFrame.new(sx * 4.2, floorY + 3.5, cabZ + 2),
			DARK_METAL, Enum.Material.Metal)
	end

	model.PrimaryPart = chassis
	return model
end

return RocketFuelTanker
