local VU = require(script.Parent:WaitForChild("VehicleUtils"))

local EscortSUV = {}

local SUV_BLACK  = Color3.fromRGB(15, 15, 18)
local SUV_CHROME = Color3.fromRGB(190, 190, 195)
local SUV_GLASS  = Color3.fromRGB(25, 28, 35)
local SUV_RUBBER = Color3.fromRGB(35, 35, 38)
local RED_NEON   = Color3.fromRGB(255, 30, 20)
local BLUE_NEON  = Color3.fromRGB(30, 80, 255)

function EscortSUV.build()
	local model = Instance.new("Model")
	model.Name = "SUV_Escort_1"

	local wheelR     = 2.0
	local wheelW     = 1.3
	local trackHW    = 3.6
	local frontAxleZ = 5.5
	local rearAxleZ  = -5.5
	local frontEndZ  = 9.0
	local rearEndZ   = -9.0

	local floorY     = wheelR + 0.5
	local beltY      = floorY + 2.8
	local winTopY    = beltY + 2.2
	local roofTopY   = winTopY + 0.4

	local bodyW      = 7.4
	local halfBW     = bodyW / 2

	local cabFrontZ  = 3.5
	local cabRearZ   = -7.5

	-- 1. WHEELS
	for _, wz in ipairs({frontAxleZ, rearAxleZ}) do
		for _, sx in ipairs({-1, 1}) do
			VU.cylinder(model, "Tire",
				Vector3.new(wheelW, wheelR * 2, wheelR * 2),
				CFrame.new(sx * trackHW, wheelR, wz),
				SUV_RUBBER, Enum.Material.SmoothPlastic)
			VU.cylinder(model, "Hub",
				Vector3.new(wheelW + 0.1, wheelR * 0.65, wheelR * 0.65),
				CFrame.new(sx * trackHW, wheelR, wz),
				SUV_CHROME, Enum.Material.Metal)
		end
	end

	-- 2. LOWER BODY
	local lowerH = beltY - floorY
	local chassis = VU.part(model, "Chassis",
		Vector3.new(bodyW, lowerH, frontEndZ - rearEndZ),
		CFrame.new(0, floorY + lowerH / 2, 0),
		SUV_BLACK, Enum.Material.SmoothPlastic)

	-- 3. HOOD
	local hoodLen = frontEndZ - cabFrontZ
	VU.part(model, "Hood",
		Vector3.new(bodyW - 0.2, 0.3, hoodLen),
		CFrame.new(0, beltY + 0.15, cabFrontZ + hoodLen / 2),
		SUV_BLACK, Enum.Material.SmoothPlastic)

	local wsRise = winTopY - beltY
	local wsRun  = 2.5
	VU.wedge(model, "WindshieldSlope",
		Vector3.new(bodyW - 1.0, wsRise, wsRun),
		CFrame.new(0, beltY + wsRise / 2, cabFrontZ + wsRun / 2)
			* CFrame.Angles(0, math.rad(180), 0),
		SUV_BLACK, Enum.Material.SmoothPlastic)

	-- 4. REAR
	local trunkLen = cabRearZ - rearEndZ
	local trunkTopY = beltY + 0.8
	local trunkH = trunkTopY - beltY
	VU.part(model, "Rear",
		Vector3.new(bodyW - 0.2, trunkH, trunkLen),
		CFrame.new(0, beltY + trunkH / 2, rearEndZ + trunkLen / 2),
		SUV_BLACK, Enum.Material.SmoothPlastic)

	local rsRise = winTopY - trunkTopY
	local rsRun  = 1.0
	VU.wedge(model, "RearSlope",
		Vector3.new(bodyW - 1.0, rsRise, rsRun),
		CFrame.new(0, trunkTopY + rsRise / 2, cabRearZ - rsRun / 2),
		SUV_BLACK, Enum.Material.SmoothPlastic)

	-- 5. CABIN SIDES
	local cabLen = cabFrontZ - cabRearZ
	local winH   = winTopY - beltY
	local panelThick = 0.4

	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "CabinSide",
			Vector3.new(panelThick, winH, cabLen),
			CFrame.new(sx * (halfBW - panelThick / 2), beltY + winH / 2, cabFrontZ - cabLen / 2),
			SUV_BLACK, Enum.Material.SmoothPlastic)
	end

	-- 6. ROOF
	VU.part(model, "Roof",
		Vector3.new(bodyW - 0.4, roofTopY - winTopY, cabLen + 0.4),
		CFrame.new(0, winTopY + (roofTopY - winTopY) / 2, cabFrontZ - cabLen / 2),
		SUV_BLACK, Enum.Material.SmoothPlastic)

	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "RoofRail",
			Vector3.new(0.15, 0.25, cabLen - 1),
			CFrame.new(sx * (halfBW - 0.6), roofTopY + 0.15, cabFrontZ - cabLen / 2),
			SUV_CHROME, Enum.Material.Metal)
	end

	local lightBarY = roofTopY + 0.35
	local lightBarZ = cabFrontZ - cabLen * 0.35

	VU.part(model, "LightBarBase",
		Vector3.new(4.0, 0.3, 1.2),
		CFrame.new(0, lightBarY, lightBarZ),
		SUV_BLACK, Enum.Material.SmoothPlastic)

	local suvRed1 = VU.part(model, "LightBarRed1",
		Vector3.new(0.8, 0.35, 0.8),
		CFrame.new(-1.2, lightBarY + 0.2, lightBarZ),
		RED_NEON, Enum.Material.Neon)
	local srl = Instance.new("PointLight")
	srl.Color = Color3.fromRGB(255, 30, 20)
	srl.Brightness = 4
	srl.Range = 16
	srl.Parent = suvRed1

	VU.part(model, "LightBarRed2",
		Vector3.new(0.6, 0.3, 0.6),
		CFrame.new(-0.3, lightBarY + 0.2, lightBarZ),
		RED_NEON, Enum.Material.Neon)

	local suvBlu1 = VU.part(model, "LightBarBlue1",
		Vector3.new(0.8, 0.35, 0.8),
		CFrame.new(1.2, lightBarY + 0.2, lightBarZ),
		BLUE_NEON, Enum.Material.Neon)
	local sbl = Instance.new("PointLight")
	sbl.Color = Color3.fromRGB(30, 80, 255)
	sbl.Brightness = 4
	sbl.Range = 16
	sbl.Parent = suvBlu1

	VU.part(model, "LightBarBlue2",
		Vector3.new(0.6, 0.3, 0.6),
		CFrame.new(0.3, lightBarY + 0.2, lightBarZ),
		BLUE_NEON, Enum.Material.Neon)

	-- 7. WINDSHIELD + REAR WINDOW
	local wsg = VU.part(model, "Windshield",
		Vector3.new(bodyW - 1.8, winH - 0.2, 0.15),
		CFrame.new(0, beltY + winH / 2, cabFrontZ) * CFrame.Angles(math.rad(-15), 0, 0),
		SUV_GLASS, Enum.Material.Glass)
	wsg.Transparency = 0.3

	local rwg = VU.part(model, "RearWindow",
		Vector3.new(bodyW - 1.8, winH - 0.4, 0.15),
		CFrame.new(0, beltY + winH / 2, cabRearZ) * CFrame.Angles(math.rad(5), 0, 0),
		SUV_GLASS, Enum.Material.Glass)
	rwg.Transparency = 0.3

	-- 8. SIDE WINDOWS
	local bPilZ = 0.0
	local cPilZ = -4.5

	for _, sx in ipairs({-1, 1}) do
		local fwLen = cabFrontZ - bPilZ - 0.6
		local fwg = VU.part(model, "SideWinFront",
			Vector3.new(0.12, winH - 0.5, fwLen),
			CFrame.new(sx * halfBW, beltY + winH / 2, bPilZ + fwLen / 2 + 0.3),
			SUV_GLASS, Enum.Material.Glass)
		fwg.Transparency = 0.3

		local rwLen = bPilZ - cPilZ - 0.6
		local rwsg = VU.part(model, "SideWinRear",
			Vector3.new(0.12, winH - 0.5, rwLen),
			CFrame.new(sx * halfBW, beltY + winH / 2, cPilZ + rwLen / 2 + 0.3),
			SUV_GLASS, Enum.Material.Glass)
		rwsg.Transparency = 0.3

		local qwLen = cPilZ - cabRearZ - 0.8
		local qwg = VU.part(model, "SideWinQuarter",
			Vector3.new(0.12, winH - 0.8, qwLen),
			CFrame.new(sx * halfBW, beltY + winH / 2, cabRearZ + qwLen / 2 + 0.4),
			SUV_GLASS, Enum.Material.Glass)
		qwg.Transparency = 0.3
	end

	-- 9. FRONT END
	VU.part(model, "Grille",
		Vector3.new(4.5, 2.0, 0.3),
		CFrame.new(0, floorY + lowerH / 2 + 0.3, frontEndZ + 0.15),
		SUV_CHROME, Enum.Material.Metal)

	for i = 0, 4 do
		VU.part(model, "GrilleBar",
			Vector3.new(4.1, 0.06, 0.35),
			CFrame.new(0, floorY + 0.8 + i * 0.4, frontEndZ + 0.2),
			SUV_BLACK, Enum.Material.SmoothPlastic)
	end

	VU.part(model, "FrontBumper",
		Vector3.new(bodyW + 0.2, 1.0, 0.6),
		CFrame.new(0, floorY + 0.2, frontEndZ + 0.3),
		SUV_BLACK, Enum.Material.SmoothPlastic)

	VU.part(model, "BumperChrome",
		Vector3.new(bodyW - 2, 0.15, 0.65),
		CFrame.new(0, floorY + 0.1, frontEndZ + 0.35),
		SUV_CHROME, Enum.Material.Metal)

	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Headlight",
			Vector3.new(1.4, 1.2, 0.25),
			CFrame.new(sx * 2.8, floorY + lowerH / 2 + 0.4, frontEndZ + 0.2),
			Color3.fromRGB(255, 245, 210), Enum.Material.Neon)
	end

	for _, sx in ipairs({-1, 1}) do
		VU.ball(model, "FogLight",
			Vector3.new(0.6, 0.6, 0.3),
			CFrame.new(sx * 2.2, floorY + 0.5, frontEndZ + 0.4),
			Color3.fromRGB(255, 245, 210), Enum.Material.Neon)
	end

	-- 10. REAR END
	VU.part(model, "RearBumper",
		Vector3.new(bodyW + 0.2, 0.8, 0.5),
		CFrame.new(0, floorY + 0.2, rearEndZ - 0.3),
		SUV_BLACK, Enum.Material.SmoothPlastic)

	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Taillight",
			Vector3.new(0.6, 1.8, 0.25),
			CFrame.new(sx * (halfBW - 0.2), floorY + lowerH / 2 + 0.5, rearEndZ - 0.2),
			Color3.fromRGB(200, 20, 15), Enum.Material.Neon)
	end

	-- 11. CHROME BELT TRIM + RUNNING BOARDS
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "BeltTrim",
			Vector3.new(0.08, 0.12, frontEndZ - rearEndZ - 1),
			CFrame.new(sx * halfBW, beltY, 0),
			SUV_CHROME, Enum.Material.Metal)

		VU.part(model, "RunningBoard",
			Vector3.new(0.8, 0.2, 8),
			CFrame.new(sx * (halfBW + 0.2), floorY - 0.3, -1),
			SUV_BLACK, Enum.Material.DiamondPlate)
	end

	-- 12. SIDE MIRRORS
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Mirror",
			Vector3.new(0.15, 0.5, 0.8),
			CFrame.new(sx * (halfBW + 0.3), beltY + 1.0, cabFrontZ - 0.5),
			SUV_BLACK, Enum.Material.SmoothPlastic)
	end

	model.PrimaryPart = chassis
	return model
end

return EscortSUV
