local VU = require(script.Parent:WaitForChild("VehicleUtils"))

local WaterTanker = {}

-- Shared colors
local BLACK       = Color3.fromRGB(25, 25, 28)
local DARK_METAL  = Color3.fromRGB(50, 50, 55)
local YELLOW_NEON = Color3.fromRGB(255, 220, 60)
local C_WARN_AMBER = Color3.fromRGB(255, 160, 30)

-- Water tanker-specific colors
local C_WATER_BODY  = Color3.fromRGB(45, 70, 95)
local C_WATER_CAB   = Color3.fromRGB(50, 80, 110)
local C_WATER_TANK  = Color3.fromRGB(60, 130, 190)
local C_WATER_NEON  = Color3.fromRGB(50, 180, 255)
local C_WATER_GLOW  = Color3.fromRGB(80, 200, 255)
local C_WATER_SPLASH = Color3.fromRGB(150, 210, 255)
local C_WATER_WHITE = Color3.fromRGB(220, 235, 245)
local C_WATER_GREEN = Color3.fromRGB(30, 255, 80)
local C_WATER_GREEN_GLOW = Color3.fromRGB(60, 255, 120)

function WaterTanker.build()
	local model = Instance.new("Model")
	model.Name = "WaterTanker_1"

	-- Layout
	local wheelR = 1.9
	local wheelW = 1.2
	local frontZ = 5.5
	local rearZ  = -8
	local halfW  = 3.6
	local floorY = wheelR + 0.4

	---------------------------------------------------------------------------
	-- WHEELS (heavy-duty, dual rear)
	---------------------------------------------------------------------------
	-- Front axle
	for _, sx in ipairs({-1, 1}) do
		VU.cylinder(model, "FrontTire",
			Vector3.new(wheelW, wheelR * 2, wheelR * 2),
			CFrame.new(sx * halfW, wheelR, frontZ - 1),
			BLACK, Enum.Material.SmoothPlastic)
		VU.cylinder(model, "FrontHub",
			Vector3.new(wheelW + 0.1, wheelR * 0.5, wheelR * 0.5),
			CFrame.new(sx * halfW, wheelR, frontZ - 1),
			DARK_METAL, Enum.Material.Metal)
	end
	-- Rear dual wheels
	for _, sx in ipairs({-1, 1}) do
		for _, offset in ipairs({0, 1.3}) do
			VU.cylinder(model, "RearTire",
				Vector3.new(wheelW * 0.9, wheelR * 2, wheelR * 2),
				CFrame.new(sx * (halfW + offset * sx * 0.3), wheelR, rearZ + 1.5),
				BLACK, Enum.Material.SmoothPlastic)
		end
		VU.cylinder(model, "RearHub",
			Vector3.new(wheelW * 2.2, wheelR * 0.5, wheelR * 0.5),
			CFrame.new(sx * halfW, wheelR, rearZ + 1.5),
			DARK_METAL, Enum.Material.Metal)
	end

	---------------------------------------------------------------------------
	-- CHASSIS + CAB
	---------------------------------------------------------------------------
	local chassis = VU.part(model, "Chassis",
		Vector3.new(7.2, 1.0, 15),
		CFrame.new(0, floorY, -1),
		C_WATER_BODY, Enum.Material.SmoothPlastic)

	local cabH = 5
	local cabZ = frontZ - 2

	local cabW = 7.2
	local cabD = 5
	-- Back wall
	VU.part(model, "CabBack",
		Vector3.new(cabW, cabH, 0.3),
		CFrame.new(0, floorY + cabH / 2, cabZ - cabD / 2 + 0.15),
		C_WATER_CAB, Enum.Material.SmoothPlastic)
	-- Side walls (door panels below window line)
	local doorH = 2.0
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "CabSide",
			Vector3.new(0.3, doorH, cabD),
			CFrame.new(sx * (cabW / 2 - 0.15), floorY + doorH / 2, cabZ),
			C_WATER_CAB, Enum.Material.SmoothPlastic)
	end
	-- Floor
	VU.part(model, "CabFloor",
		Vector3.new(cabW, 0.3, cabD),
		CFrame.new(0, floorY + 0.15, cabZ),
		C_WATER_CAB, Enum.Material.SmoothPlastic)

	-- Hood
	VU.wedge(model, "Hood",
		Vector3.new(7, 1.0, 2.5),
		CFrame.new(0, floorY + 0.8, frontZ + 0.5) * CFrame.Angles(0, math.rad(180), 0),
		C_WATER_CAB, Enum.Material.SmoothPlastic)

	-- Windshield (on front face of cab)
	local windshield = VU.part(model, "Windshield",
		Vector3.new(6, 3, 0.2),
		CFrame.new(0, floorY + 3.5, cabZ + 2.6) * CFrame.Angles(math.rad(-10), 0, 0),
		Color3.fromRGB(100, 150, 180), Enum.Material.Glass)
	windshield.Transparency = 0.8

	-- Side windows
	for _, sx in ipairs({-1, 1}) do
		local win = VU.part(model, "SideWindow",
			Vector3.new(0.15, 2.5, 3),
			CFrame.new(sx * 3.65, floorY + 3.2, cabZ),
			Color3.fromRGB(100, 150, 180), Enum.Material.Glass)
		win.Transparency = 0.8
	end

	-- Cab roof
	VU.part(model, "CabRoof",
		Vector3.new(7.4, 0.3, 5.2),
		CFrame.new(0, floorY + cabH + 0.15, cabZ),
		C_WATER_BODY, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- WATER TANK (large horizontal cylinder, blue)
	---------------------------------------------------------------------------
	local tankR = 3.0
	local tankLen = 10
	local tankZ = -2.5
	local tankY = floorY + 0.5 + tankR

	-- Main tank body
	VU.cylinder(model, "WaterTank",
		Vector3.new(tankLen, tankR * 2, tankR * 2),
		CFrame.new(0, tankY, tankZ) * CFrame.Angles(0, math.rad(90), 0),
		C_WATER_TANK, Enum.Material.SmoothPlastic)

	-- Front cap (small dome, kept clear of cab)
	VU.ball(model, "TankCapFront",
		Vector3.new(tankR * 2, tankR * 2, tankR * 0.5),
		CFrame.new(0, tankY, tankZ + tankLen / 2 - 0.3),
		C_WATER_CAB, Enum.Material.Metal)

	-- Rear cap
	VU.ball(model, "TankCapRear",
		Vector3.new(tankR * 2, tankR * 2, tankR * 1.2),
		CFrame.new(0, tankY, tankZ - tankLen / 2),
		C_WATER_CAB, Enum.Material.Metal)

	-- Neon blue band at tank center
	VU.cylinder(model, "NeonBandCenter",
		Vector3.new(0.5, tankR * 2.06, tankR * 2.06),
		CFrame.new(0, tankY, tankZ) * CFrame.Angles(0, math.rad(90), 0),
		C_WATER_NEON, Enum.Material.Neon)

	-- Neon blue bands near each end
	for _, lz in ipairs({tankZ - 3, tankZ + 3}) do
		VU.cylinder(model, "NeonBand",
			Vector3.new(0.3, tankR * 2.05, tankR * 2.05),
			CFrame.new(0, tankY, lz) * CFrame.Angles(0, math.rad(90), 0),
			C_WATER_NEON, Enum.Material.Neon)
	end

	-- Neon stripe along the top of the tank
	VU.part(model, "NeonTopStripe",
		Vector3.new(0.3, 0.2, tankLen - 1),
		CFrame.new(0, tankY + tankR + 0.05, tankZ),
		C_WATER_NEON, Enum.Material.Neon)

	-- Neon stripes along the sides
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "NeonSideStripe",
			Vector3.new(0.2, 0.3, tankLen - 1),
			CFrame.new(sx * (tankR + 0.05), tankY, tankZ),
			C_WATER_NEON, Enum.Material.Neon)
	end

	-- Tank support cradles
	for _, cz in ipairs({tankZ - 3, tankZ + 3}) do
		VU.part(model, "TankCradle",
			Vector3.new(7, 0.4, 0.5),
			CFrame.new(0, floorY + 0.5, cz),
			DARK_METAL, Enum.Material.Metal)
		for _, sx in ipairs({-1, 1}) do
			VU.part(model, "CradleArm",
				Vector3.new(0.4, tankR + 0.3, 0.5),
				CFrame.new(sx * 2.8, floorY + 0.5 + (tankR + 0.3) / 2, cz),
				DARK_METAL, Enum.Material.Metal)
		end
	end

	-- Fill hatch on top
	VU.cylinder(model, "FillHatch",
		Vector3.new(0.4, 1.8, 1.8),
		CFrame.new(0, tankY + tankR + 0.2, tankZ + 1.5) * CFrame.Angles(0, 0, math.rad(90)),
		DARK_METAL, Enum.Material.Metal)

	-- Rear discharge pipe + nozzle
	VU.cylinder(model, "DischargePipe",
		Vector3.new(2, 0.6, 0.6),
		CFrame.new(0, tankY - tankR + 0.5, tankZ - tankLen / 2 - 1) * CFrame.Angles(0, 0, math.rad(90)),
		DARK_METAL, Enum.Material.Metal)
	VU.cylinder(model, "Nozzle",
		Vector3.new(0.5, 0.9, 0.9),
		CFrame.new(0, tankY - tankR + 0.5, tankZ - tankLen / 2 - 2) * CFrame.Angles(0, 0, math.rad(90)),
		C_WATER_GREEN, Enum.Material.Neon)

	-- Green bubble glow sphere around nozzle
	VU.ball(model, "NozzleBubble",
		Vector3.new(2.5, 2.5, 2.5),
		CFrame.new(0, tankY - tankR + 0.5, tankZ - tankLen / 2 - 2),
		C_WATER_GREEN, Enum.Material.ForceField)

	-- Pulsating green PointLight on bubble
	local bubbleGlow = Instance.new("PointLight")
	bubbleGlow.Name = "BubbleGlow"
	bubbleGlow.Brightness = 4
	bubbleGlow.Range = 18
	bubbleGlow.Color = C_WATER_GREEN_GLOW
	bubbleGlow.Parent = model:FindFirstChild("NozzleBubble")

	-- Water glow on the tank
	local waterGlow = Instance.new("PointLight")
	waterGlow.Name = "WaterGlow"
	waterGlow.Brightness = 2.5
	waterGlow.Range = 20
	waterGlow.Color = C_WATER_GLOW
	waterGlow.Parent = model:FindFirstChild("WaterTank")

	---------------------------------------------------------------------------
	-- WATER SPLASH / DRIP EFFECTS
	---------------------------------------------------------------------------
	-- Water dripping from rear nozzle
	local dripPoint = Instance.new("Part")
	dripPoint.Name = "DripPoint"
	dripPoint.Size = Vector3.new(1, 1, 1)
	dripPoint.Position = Vector3.new(0, tankY - tankR, tankZ - tankLen / 2 - 2)
	dripPoint.Anchored = true
	dripPoint.CanCollide = false
	dripPoint.Transparency = 1
	dripPoint.Parent = model

	local drip = Instance.new("ParticleEmitter")
	drip.Name = "WaterDrip"
	drip.Rate = 35
	drip.Speed = NumberRange.new(2, 5)
	drip.Lifetime = NumberRange.new(0.5, 1.5)
	drip.SpreadAngle = Vector2.new(20, 20)
	drip.EmissionDirection = Enum.NormalId.Bottom
	drip.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.5, 0.6),
		NumberSequenceKeypoint.new(1, 0.1),
	})
	drip.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.7, 0.4),
		NumberSequenceKeypoint.new(1, 1),
	})
	drip.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, C_WATER_GREEN),
		ColorSequenceKeypoint.new(1, C_WATER_GREEN_GLOW),
	})
	drip.LightEmission = 0.8
	drip.Brightness = 3
	drip.Parent = dripPoint

	-- Splash mist from top hatch (pressure overflow)
	local splashPoint = Instance.new("Part")
	splashPoint.Name = "SplashPoint"
	splashPoint.Size = Vector3.new(1, 1, 1)
	splashPoint.Position = Vector3.new(0, tankY + tankR + 1, tankZ + 1.5)
	splashPoint.Anchored = true
	splashPoint.CanCollide = false
	splashPoint.Transparency = 1
	splashPoint.Parent = model

	local splash = Instance.new("ParticleEmitter")
	splash.Name = "WaterMist"
	splash.Rate = 25
	splash.Speed = NumberRange.new(3, 7)
	splash.Lifetime = NumberRange.new(0.6, 1.8)
	splash.SpreadAngle = Vector2.new(50, 50)
	splash.EmissionDirection = Enum.NormalId.Top
	splash.LightEmission = 0.5
	splash.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.5, 1.2),
		NumberSequenceKeypoint.new(1, 2.5),
	})
	splash.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.5, 0.5),
		NumberSequenceKeypoint.new(1, 1),
	})
	splash.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, C_WATER_GLOW),
		ColorSequenceKeypoint.new(1, C_WATER_WHITE),
	})
	splash.Brightness = 2
	splash.Parent = splashPoint

	---------------------------------------------------------------------------
	-- LIGHTS
	---------------------------------------------------------------------------
	-- Blue neon warning beacons on cab roof
	for _, sx in ipairs({-2.5, 2.5}) do
		VU.part(model, "WarningLight",
			Vector3.new(0.8, 0.5, 0.8),
			CFrame.new(sx, floorY + cabH + 0.6, cabZ + 1),
			C_WATER_NEON, Enum.Material.Neon)
	end

	-- Center amber beacon
	VU.part(model, "AmberBeacon",
		Vector3.new(0.8, 0.5, 0.8),
		CFrame.new(0, floorY + cabH + 0.6, cabZ + 1),
		C_WARN_AMBER, Enum.Material.Neon)

	-- Headlights
	for _, sx in ipairs({-2.2, 2.2}) do
		VU.cylinder(model, "Headlight",
			Vector3.new(0.3, 1.2, 1.2),
			CFrame.new(sx, floorY + 1.2, frontZ + 1) * CFrame.Angles(0, math.rad(90), 0),
			YELLOW_NEON, Enum.Material.Neon)
	end

	-- Taillights (red)
	for _, sx in ipairs({-2.5, 2.5}) do
		VU.part(model, "Taillight",
			Vector3.new(0.8, 0.6, 0.15),
			CFrame.new(sx, floorY + 0.8, rearZ),
			Color3.fromRGB(200, 20, 20), Enum.Material.Neon)
	end

	-- Neon underglow on the chassis (blue)
	for _, sx in ipairs({-3, 3}) do
		VU.part(model, "Underglow",
			Vector3.new(0.3, 0.2, 10),
			CFrame.new(sx, floorY - 0.3, -1),
			C_WATER_NEON, Enum.Material.Neon)
	end

	-- Side markers (blue neon dots along the tank)
	for _, sx in ipairs({-1, 1}) do
		for i = -2, 2 do
			VU.ball(model, "SideMarker",
				Vector3.new(0.5, 0.5, 0.5),
				CFrame.new(sx * (tankR + 0.1), tankY, tankZ + i * 2),
				C_WATER_NEON, Enum.Material.Neon)
		end
	end

	-- Water droplet sign on rear
	VU.part(model, "WaterSign",
		Vector3.new(2.5, 2.5, 0.1),
		CFrame.new(0, floorY + 2, rearZ - 0.1),
		C_WATER_CAB, Enum.Material.SmoothPlastic)
	VU.ball(model, "DropletIcon",
		Vector3.new(1.2, 1.5, 0.3),
		CFrame.new(0, floorY + 2.2, rearZ - 0.2),
		C_WATER_GREEN, Enum.Material.Neon)

	model.PrimaryPart = chassis
	return model
end

return WaterTanker
