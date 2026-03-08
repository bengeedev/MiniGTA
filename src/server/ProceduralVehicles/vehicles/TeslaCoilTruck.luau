local VU = require(script.Parent:WaitForChild("VehicleUtils"))

local TeslaCoilTruck = {}

-- Shared colors
local BLACK       = Color3.fromRGB(25, 25, 28)
local DARK_METAL  = Color3.fromRGB(50, 50, 55)
local YELLOW_NEON = Color3.fromRGB(255, 220, 60)
local C_WARN_AMBER = Color3.fromRGB(255, 160, 30)

-- Tesla coil truck-specific colors
local C_TRUCK_BODY  = Color3.fromRGB(60, 65, 75)
local C_TRUCK_CAB   = Color3.fromRGB(70, 75, 85)
local C_TRUCK_BED   = Color3.fromRGB(50, 55, 60)
local C_HAZARD      = Color3.fromRGB(240, 190, 30)
local C_COIL_METAL  = Color3.fromRGB(170, 170, 180)
local C_COIL_SPHERE = Color3.fromRGB(180, 190, 200)
local C_ARC_BLUE    = Color3.fromRGB(120, 180, 255)
local C_SPARK       = Color3.fromRGB(200, 220, 255)

function TeslaCoilTruck.build()
	local model = Instance.new("Model")
	model.Name = "TeslaCoilTruck_1"

	-- Layout
	local wheelR = 1.8
	local wheelW = 1.2
	local frontZ = 5.5
	local rearZ  = -7
	local halfW  = 3.5
	local floorY = wheelR + 0.4

	---------------------------------------------------------------------------
	-- WHEELS (heavy-duty industrial)
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
	-- Rear axle (dual rear wheels)
	for _, sx in ipairs({-1, 1}) do
		for _, offset in ipairs({0, 1.3}) do
			VU.cylinder(model, "RearTire",
				Vector3.new(wheelW * 0.9, wheelR * 2, wheelR * 2),
				CFrame.new(sx * (halfW + offset * sx * 0.3), wheelR, rearZ + 1),
				BLACK, Enum.Material.SmoothPlastic)
		end
		VU.cylinder(model, "RearHub",
			Vector3.new(wheelW * 2.2, wheelR * 0.5, wheelR * 0.5),
			CFrame.new(sx * halfW, wheelR, rearZ + 1),
			DARK_METAL, Enum.Material.Metal)
	end

	---------------------------------------------------------------------------
	-- CHASSIS + CAB
	---------------------------------------------------------------------------
	local chassis = VU.part(model, "Chassis",
		Vector3.new(7, 1.0, 14),
		CFrame.new(0, floorY, -0.5),
		C_TRUCK_BODY, Enum.Material.SmoothPlastic)

	-- Cab (front box with slight height)
	local cabH = 5
	local cabZ = frontZ - 2
	local cabW = 7
	local cabD = 5
	-- Back wall
	VU.part(model, "CabBack",
		Vector3.new(cabW, cabH, 0.3),
		CFrame.new(0, floorY + cabH / 2, cabZ - cabD / 2 + 0.15),
		C_TRUCK_CAB, Enum.Material.SmoothPlastic)
	-- Side walls (door panels below window line)
	local doorH = 2.0
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "CabSide",
			Vector3.new(0.3, doorH, cabD),
			CFrame.new(sx * (cabW / 2 - 0.15), floorY + doorH / 2, cabZ),
			C_TRUCK_CAB, Enum.Material.SmoothPlastic)
	end
	-- Floor
	VU.part(model, "CabFloor",
		Vector3.new(cabW, 0.3, cabD),
		CFrame.new(0, floorY + 0.15, cabZ),
		C_TRUCK_CAB, Enum.Material.SmoothPlastic)

	-- Hood (angled front)
	VU.wedge(model, "Hood",
		Vector3.new(6.8, 1.0, 2.5),
		CFrame.new(0, floorY + 0.8, frontZ + 0.5) * CFrame.Angles(0, math.rad(180), 0),
		C_TRUCK_CAB, Enum.Material.SmoothPlastic)

	-- Windshield
	local windshield = VU.part(model, "Windshield",
		Vector3.new(6, 3, 0.2),
		CFrame.new(0, floorY + 3.5, cabZ + 2.3) * CFrame.Angles(math.rad(-10), 0, 0),
		Color3.fromRGB(100, 140, 170), Enum.Material.Glass)
	windshield.Transparency = 0.8

	-- Side windows
	for _, sx in ipairs({-1, 1}) do
		local win = VU.part(model, "SideWindow",
			Vector3.new(0.15, 2.5, 3),
			CFrame.new(sx * 3.45, floorY + 3.2, cabZ),
			Color3.fromRGB(100, 140, 170), Enum.Material.Glass)
		win.Transparency = 0.8
	end

	-- Cab roof
	VU.part(model, "CabRoof",
		Vector3.new(7.2, 0.3, 5.2),
		CFrame.new(0, floorY + cabH + 0.15, cabZ),
		C_TRUCK_BODY, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- FLATBED (behind cab)
	---------------------------------------------------------------------------
	local bedZ = -3
	local bedLen = 8
	VU.part(model, "FlatbedFloor",
		Vector3.new(7, 0.4, bedLen),
		CFrame.new(0, floorY + 0.2, bedZ),
		C_TRUCK_BED, Enum.Material.DiamondPlate)

	-- Bed side rails
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "BedRail",
			Vector3.new(0.3, 1.2, bedLen),
			CFrame.new(sx * 3.35, floorY + 0.8, bedZ),
			DARK_METAL, Enum.Material.Metal)
	end

	-- Hazard stripes on rear
	VU.part(model, "HazardStripe",
		Vector3.new(7, 0.8, 0.15),
		CFrame.new(0, floorY + 0.8, bedZ - bedLen / 2),
		C_HAZARD, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- TESLA COIL (on flatbed)
	---------------------------------------------------------------------------
	local coilBaseZ = bedZ
	local coilBaseY = floorY + 0.6

	-- Pedestal base (heavy metal box)
	local pedW = 3.5
	local pedH = 1.5
	VU.part(model, "CoilPedestal",
		Vector3.new(pedW, pedH, pedW),
		CFrame.new(0, coilBaseY + pedH / 2, coilBaseZ),
		DARK_METAL, Enum.Material.DiamondPlate)

	-- Insulator rings on pedestal
	for i = 0, 2 do
		VU.cylinder(model, "Insulator" .. i,
			Vector3.new(0.3, pedW + 0.5, pedW + 0.5),
			CFrame.new(0, coilBaseY + pedH + 0.3 + i * 0.5, coilBaseZ) * CFrame.Angles(0, 0, math.rad(90)),
			Color3.fromRGB(200, 180, 140), Enum.Material.SmoothPlastic)
	end

	-- Main coil column (thinner, neon glow)
	local coilH = 6
	local coilR = 0.7
	local coilY = coilBaseY + pedH + 1.5 + coilH / 2
	VU.cylinder(model, "CoilWinding",
		Vector3.new(coilH, coilR * 2, coilR * 2),
		CFrame.new(0, coilY, coilBaseZ) * CFrame.Angles(0, 0, math.rad(90)),
		Color3.fromRGB(255, 30, 20), Enum.Material.Neon)

	-- Plasma ball (glass outer shell + neon core)
	local sphereDiam = 3
	local sphereY = coilY + coilH / 2 + sphereDiam / 2 - 0.3
	local sphere = VU.ball(model, "CoilSphere",
		Vector3.new(sphereDiam, sphereDiam, sphereDiam),
		CFrame.new(0, sphereY, coilBaseZ),
		Color3.fromRGB(60, 80, 100), Enum.Material.Glass)
	sphere.Transparency = 0.35
	-- Glowing plasma core inside
	VU.ball(model, "PlasmaCore",
		Vector3.new(sphereDiam * 0.55, sphereDiam * 0.55, sphereDiam * 0.55),
		CFrame.new(0, sphereY, coilBaseZ),
		C_ARC_BLUE, Enum.Material.Neon)

	-- Spark particles at sphere tip
	local sparkPoint = Instance.new("Part")
	sparkPoint.Name = "SparkPoint"
	sparkPoint.Size = Vector3.new(1, 1, 1)
	sparkPoint.Position = Vector3.new(0, sphereY + sphereDiam / 2, coilBaseZ)
	sparkPoint.Anchored = true
	sparkPoint.CanCollide = false
	sparkPoint.Transparency = 1
	sparkPoint.Parent = model

	local sparks = Instance.new("ParticleEmitter")
	sparks.Name = "Sparks"
	sparks.Rate = 20
	sparks.Speed = NumberRange.new(5, 12)
	sparks.Lifetime = NumberRange.new(0.1, 0.3)
	sparks.SpreadAngle = Vector2.new(60, 60)
	sparks.LightEmission = 1
	sparks.Size = NumberSequence.new(0.4, 0)
	sparks.Color = ColorSequence.new(C_SPARK)
	sparks.Brightness = 4
	sparks.Parent = sparkPoint

	-- Glow light on sphere
	local glow = Instance.new("PointLight")
	glow.Name = "CoilGlow"
	glow.Brightness = 3
	glow.Range = 24
	glow.Color = C_ARC_BLUE
	glow.Parent = sphere

	-- Grounding rod (small metal post on bed, arc target)
	local rodZ = coilBaseZ + 2.5
	local rodH = 3
	local rodY = coilBaseY + rodH / 2
	VU.part(model, "GroundRod",
		Vector3.new(0.3, rodH, 0.3),
		CFrame.new(2, rodY, rodZ),
		DARK_METAL, Enum.Material.Metal)
	local rodTip = VU.ball(model, "GroundRodTip",
		Vector3.new(0.8, 0.8, 0.8),
		CFrame.new(2, coilBaseY + rodH + 0.2, rodZ),
		C_COIL_METAL, Enum.Material.Metal)

	-- Arc beam from sphere to grounding rod
	local att1 = Instance.new("Attachment")
	att1.Name = "ArcStart"
	att1.Parent = sphere

	local att2 = Instance.new("Attachment")
	att2.Name = "ArcEnd"
	att2.Parent = rodTip

	local arc = Instance.new("Beam")
	arc.Name = "ElectricalArc"
	arc.Attachment0 = att1
	arc.Attachment1 = att2
	arc.Segments = 20
	arc.CurveSize0 = 1.5
	arc.CurveSize1 = -1.5
	arc.Width0 = 0.3
	arc.Width1 = 0.2
	arc.TextureLength = 1
	arc.LightEmission = 1
	arc.LightInfluence = 0
	arc.FaceCamera = true
	arc.Color = ColorSequence.new(C_ARC_BLUE)
	arc.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(0.5, 0),
		NumberSequenceKeypoint.new(1, 0.1),
	})
	arc.Brightness = 3
	arc.Parent = sphere

	-- Second thinner arc (chaotic offset)
	local arc2 = Instance.new("Beam")
	arc2.Name = "ElectricalArc2"
	arc2.Attachment0 = att1
	arc2.Attachment1 = att2
	arc2.Segments = 16
	arc2.CurveSize0 = -1
	arc2.CurveSize1 = 1.2
	arc2.Width0 = 0.15
	arc2.Width1 = 0.1
	arc2.TextureLength = 0.8
	arc2.LightEmission = 1
	arc2.LightInfluence = 0
	arc2.FaceCamera = true
	arc2.Color = ColorSequence.new(Color3.fromRGB(180, 220, 255))
	arc2.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.5, 0.05),
		NumberSequenceKeypoint.new(1, 0.2),
	})
	arc2.Brightness = 4
	arc2.Parent = sphere

	---------------------------------------------------------------------------
	-- WARNING LIGHTS (amber beacons on cab roof)
	---------------------------------------------------------------------------
	for _, sx in ipairs({-2.5, 2.5}) do
		VU.part(model, "WarningLight",
			Vector3.new(0.8, 0.5, 0.8),
			CFrame.new(sx, floorY + cabH + 0.6, cabZ + 1),
			C_WARN_AMBER, Enum.Material.Neon)
	end

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

	-- Hazard sign on back (high voltage warning)
	VU.part(model, "HazardSign",
		Vector3.new(2, 2, 0.1),
		CFrame.new(0, floorY + 2, rearZ - 0.1),
		C_HAZARD, Enum.Material.SmoothPlastic)
	-- Lightning bolt on sign (small dark triangle)
	VU.part(model, "BoltIcon",
		Vector3.new(0.6, 1.2, 0.05),
		CFrame.new(0, floorY + 2, rearZ - 0.2),
		C_TRUCK_BODY, Enum.Material.SmoothPlastic)

	model.PrimaryPart = chassis
	return model
end

return TeslaCoilTruck
