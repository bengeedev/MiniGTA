local VU = require(script.Parent:WaitForChild("VehicleUtils"))

local HazmatTruck = {}

-- Shared colors (defined locally)
local BLACK       = Color3.fromRGB(25, 25, 28)
local DARK_METAL  = Color3.fromRGB(50, 50, 55)
local YELLOW_NEON = Color3.fromRGB(255, 220, 60)

-- Hazmat-specific colors
local C_WARN_AMBER  = Color3.fromRGB(255, 160, 30)
local C_HAZMAT_BODY = Color3.fromRGB(50, 55, 50)
local C_HAZMAT_CAB  = Color3.fromRGB(55, 60, 55)
local C_HAZMAT_BED  = Color3.fromRGB(40, 45, 40)
local C_RAD_GREEN   = Color3.fromRGB(50, 255, 50)
local C_RAD_GLOW    = Color3.fromRGB(80, 255, 80)
local C_BARREL_METAL = Color3.fromRGB(90, 90, 95)
local C_RAD_YELLOW  = Color3.fromRGB(240, 200, 30)

function HazmatTruck.build()
	local model = Instance.new("Model")
	model.Name = "HazmatTruck_1"

	-- Layout
	local wheelR = 1.8
	local wheelW = 1.2
	local frontZ = 5.5
	local rearZ  = -7
	local halfW  = 3.5
	local floorY = wheelR + 0.4

	---------------------------------------------------------------------------
	-- WHEELS (heavy-duty)
	---------------------------------------------------------------------------
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
		C_HAZMAT_BODY, Enum.Material.SmoothPlastic)

	local cabH = 5
	local cabZ = frontZ - 2
	local cabW = 7
	local cabD = 5
	-- Back wall
	VU.part(model, "CabBack",
		Vector3.new(cabW, cabH, 0.3),
		CFrame.new(0, floorY + cabH / 2, cabZ - cabD / 2 + 0.15),
		C_HAZMAT_CAB, Enum.Material.SmoothPlastic)
	-- Side walls (door panels below window line)
	local doorH = 2.0
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "CabSide",
			Vector3.new(0.3, doorH, cabD),
			CFrame.new(sx * (cabW / 2 - 0.15), floorY + doorH / 2, cabZ),
			C_HAZMAT_CAB, Enum.Material.SmoothPlastic)
	end
	-- Floor
	VU.part(model, "CabFloor",
		Vector3.new(cabW, 0.3, cabD),
		CFrame.new(0, floorY + 0.15, cabZ),
		C_HAZMAT_CAB, Enum.Material.SmoothPlastic)

	-- Hood
	VU.wedge(model, "Hood",
		Vector3.new(6.8, 1.0, 2.5),
		CFrame.new(0, floorY + 0.8, frontZ + 0.5) * CFrame.Angles(0, math.rad(180), 0),
		C_HAZMAT_CAB, Enum.Material.SmoothPlastic)

	-- Windshield (on front face of cab)
	local windshield = VU.part(model, "Windshield",
		Vector3.new(6, 3, 0.2),
		CFrame.new(0, floorY + 3.5, cabZ + 2.6) * CFrame.Angles(math.rad(-10), 0, 0),
		Color3.fromRGB(100, 140, 160), Enum.Material.Glass)
	windshield.Transparency = 0.8

	-- Side windows
	for _, sx in ipairs({-1, 1}) do
		local win = VU.part(model, "SideWindow",
			Vector3.new(0.15, 2.5, 3),
			CFrame.new(sx * 3.55, floorY + 3.2, cabZ),
			Color3.fromRGB(100, 140, 160), Enum.Material.Glass)
		win.Transparency = 0.8
	end

	-- Cab roof
	VU.part(model, "CabRoof",
		Vector3.new(7.2, 0.3, 5.2),
		CFrame.new(0, floorY + cabH + 0.15, cabZ),
		C_HAZMAT_BODY, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- FLATBED
	---------------------------------------------------------------------------
	local bedZ = -3
	local bedLen = 8
	VU.part(model, "FlatbedFloor",
		Vector3.new(7, 0.4, bedLen),
		CFrame.new(0, floorY + 0.2, bedZ),
		C_HAZMAT_BED, Enum.Material.DiamondPlate)

	-- Bed side rails (taller for containment)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "BedRail",
			Vector3.new(0.3, 2.0, bedLen),
			CFrame.new(sx * 3.35, floorY + 1.2, bedZ),
			DARK_METAL, Enum.Material.Metal)
	end

	-- Rear gate
	VU.part(model, "RearGate",
		Vector3.new(7, 2.0, 0.3),
		CFrame.new(0, floorY + 1.2, bedZ - bedLen / 2),
		DARK_METAL, Enum.Material.Metal)

	---------------------------------------------------------------------------
	-- RADIOACTIVE BARRELS (cylinders on the flatbed, neon green glow)
	---------------------------------------------------------------------------
	local barrelR = 1.1
	local barrelH = 2.8
	local barrelY = floorY + 0.4 + barrelH / 2
	local barrelPositions = {
		{ x = -1.6, z = bedZ - 2 },
		{ x =  1.6, z = bedZ - 2 },
		{ x = -1.6, z = bedZ + 1 },
		{ x =  1.6, z = bedZ + 1 },
		{ x =  0,   z = bedZ - 0.5 },  -- center barrel
	}

	for i, bp in ipairs(barrelPositions) do
		-- Barrel body
		VU.cylinder(model, "Barrel" .. i,
			Vector3.new(barrelH, barrelR * 2, barrelR * 2),
			CFrame.new(bp.x, barrelY, bp.z) * CFrame.Angles(0, 0, math.rad(90)),
			C_BARREL_METAL, Enum.Material.Metal)
		-- Barrel lid (top)
		VU.cylinder(model, "BarrelLid" .. i,
			Vector3.new(0.15, barrelR * 1.8, barrelR * 1.8),
			CFrame.new(bp.x, barrelY + barrelH / 2, bp.z) * CFrame.Angles(0, 0, math.rad(90)),
			C_BARREL_METAL, Enum.Material.Metal)
		-- Radioactive glow ring (neon band around middle)
		VU.cylinder(model, "BarrelGlow" .. i,
			Vector3.new(0.5, barrelR * 2.05, barrelR * 2.05),
			CFrame.new(bp.x, barrelY, bp.z) * CFrame.Angles(0, 0, math.rad(90)),
			C_RAD_GREEN, Enum.Material.Neon)
		-- Radiation symbol stripe (yellow band)
		VU.cylinder(model, "BarrelStripe" .. i,
			Vector3.new(0.3, barrelR * 2.06, barrelR * 2.06),
			CFrame.new(bp.x, barrelY + 0.6, bp.z) * CFrame.Angles(0, 0, math.rad(90)),
			C_RAD_YELLOW, Enum.Material.SmoothPlastic)
	end

	-- Green glow light illuminating the barrels
	local barrelGlow = Instance.new("PointLight")
	barrelGlow.Name = "BarrelGlow"
	barrelGlow.Brightness = 2
	barrelGlow.Range = 18
	barrelGlow.Color = C_RAD_GREEN
	barrelGlow.Parent = model:FindFirstChild("Barrel3") -- center-ish barrel

	-- Radioactive particle leak from center barrel
	local leakPoint = Instance.new("Part")
	leakPoint.Name = "RadLeak"
	leakPoint.Size = Vector3.new(1, 1, 1)
	leakPoint.Position = Vector3.new(0, barrelY + barrelH / 2 + 0.5, bedZ - 0.5)
	leakPoint.Anchored = true
	leakPoint.CanCollide = false
	leakPoint.Transparency = 1
	leakPoint.Parent = model

	-- Main radioactive smoke plume
	local leak = Instance.new("ParticleEmitter")
	leak.Name = "RadSmoke"
	leak.Rate = 40
	leak.Speed = NumberRange.new(2, 6)
	leak.Lifetime = NumberRange.new(1, 2.5)
	leak.SpreadAngle = Vector2.new(45, 45)
	leak.EmissionDirection = Enum.NormalId.Top
	leak.LightEmission = 0.9
	leak.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.4),
		NumberSequenceKeypoint.new(0.5, 2),
		NumberSequenceKeypoint.new(1, 3.5),
	})
	leak.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.6, 0.5),
		NumberSequenceKeypoint.new(1, 1),
	})
	leak.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, C_RAD_GREEN),
		ColorSequenceKeypoint.new(1, C_RAD_GLOW),
	})
	leak.Brightness = 3
	leak.Parent = leakPoint

	-- Hot sparks flying off the barrels
	local sparks = Instance.new("ParticleEmitter")
	sparks.Name = "RadSparks"
	sparks.Rate = 25
	sparks.Speed = NumberRange.new(6, 14)
	sparks.Lifetime = NumberRange.new(0.15, 0.4)
	sparks.SpreadAngle = Vector2.new(70, 70)
	sparks.EmissionDirection = Enum.NormalId.Top
	sparks.LightEmission = 1
	sparks.Size = NumberSequence.new(0.4, 0)
	sparks.Color = ColorSequence.new(Color3.fromRGB(180, 255, 180))
	sparks.Brightness = 5
	sparks.Parent = leakPoint

	---------------------------------------------------------------------------
	-- WARNING LIGHTS + HAZARD SIGNS
	---------------------------------------------------------------------------
	-- Amber warning beacons on cab roof
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

	-- Radiation warning sign on rear gate
	VU.part(model, "RadSign",
		Vector3.new(2, 2, 0.1),
		CFrame.new(0, floorY + 2, rearZ - 0.3),
		C_RAD_YELLOW, Enum.Material.SmoothPlastic)
	-- Trefoil icon (simplified as dark circle + wedges)
	VU.ball(model, "TrefoilCenter",
		Vector3.new(0.5, 0.5, 0.1),
		CFrame.new(0, floorY + 2, rearZ - 0.4),
		BLACK, Enum.Material.SmoothPlastic)
	for i = 0, 2 do
		local angle = math.rad(i * 120)
		local bx = math.cos(angle) * 0.5
		local by = math.sin(angle) * 0.5
		VU.part(model, "TrefoilBlade" .. i,
			Vector3.new(0.4, 0.4, 0.05),
			CFrame.new(bx, floorY + 2 + by, rearZ - 0.4),
			BLACK, Enum.Material.SmoothPlastic)
	end

	model.PrimaryPart = chassis
	return model
end

return HazmatTruck
