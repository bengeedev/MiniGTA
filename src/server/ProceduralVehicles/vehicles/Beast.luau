local VU = require(script.Parent:WaitForChild("VehicleUtils"))

local Beast = {}

local BEAST_BLACK  = Color3.fromRGB(15, 15, 18)
local BEAST_CHROME = Color3.fromRGB(185, 185, 190)
local BEAST_GLASS  = Color3.fromRGB(20, 20, 25)
local RUBBER       = Color3.fromRGB(35, 35, 38)

function Beast.build()
	local model = Instance.new("Model")
	model.Name = "Limo_Beast_1"

	local wheelR     = 1.8
	local wheelW     = 1.3
	local trackHW    = 3.8
	local frontAxleZ = 11.0
	local rearAxleZ  = -11.0
	local frontEndZ  = 16.0
	local rearEndZ   = -16.0

	local floorY     = wheelR + 0.2
	local beltY      = floorY + 2.8
	local winTopY    = beltY + 2.0
	local roofTopY   = winTopY + 0.4

	local bodyW      = 8.0
	local halfBW     = bodyW / 2

	local trunkTopY  = beltY + 0.5

	local cabFrontZ  = 6.0
	local cabRearZ   = -11.0

	-- 1. WHEELS
	for _, wz in ipairs({frontAxleZ, rearAxleZ}) do
		for _, sx in ipairs({-1, 1}) do
			VU.cylinder(model, "Tire",
				Vector3.new(wheelW, wheelR * 2, wheelR * 2),
				CFrame.new(sx * trackHW, wheelR, wz),
				RUBBER, Enum.Material.SmoothPlastic)
			VU.cylinder(model, "Hub",
				Vector3.new(wheelW + 0.1, wheelR * 0.6, wheelR * 0.6),
				CFrame.new(sx * trackHW, wheelR, wz),
				BEAST_CHROME, Enum.Material.Metal)
		end
	end

	-- 2. LOWER BODY
	local lowerH = beltY - floorY
	local chassis = VU.part(model, "Chassis",
		Vector3.new(bodyW, lowerH, frontEndZ - rearEndZ),
		CFrame.new(0, floorY + lowerH / 2, 0),
		BEAST_BLACK, Enum.Material.DiamondPlate)

	-- 3. HOOD
	local hoodLen = frontEndZ - cabFrontZ
	VU.part(model, "Hood",
		Vector3.new(bodyW - 0.2, 0.3, hoodLen),
		CFrame.new(0, beltY + 0.15, cabFrontZ + hoodLen / 2),
		BEAST_BLACK, Enum.Material.SmoothPlastic)

	local wsRise = winTopY - beltY
	local wsRun  = 2.5
	VU.wedge(model, "WindshieldSlope",
		Vector3.new(bodyW - 1.2, wsRise, wsRun),
		CFrame.new(0, beltY + wsRise / 2, cabFrontZ + wsRun / 2)
			* CFrame.Angles(0, math.rad(180), 0),
		BEAST_BLACK, Enum.Material.SmoothPlastic)

	-- 4. TRUNK
	local trunkLen = cabRearZ - rearEndZ
	local trunkH   = trunkTopY - beltY
	VU.part(model, "Trunk",
		Vector3.new(bodyW - 0.2, trunkH, trunkLen),
		CFrame.new(0, beltY + trunkH / 2, rearEndZ + trunkLen / 2),
		BEAST_BLACK, Enum.Material.SmoothPlastic)

	local rsRise = winTopY - trunkTopY
	local rsRun  = 1.5
	VU.wedge(model, "RearSlope",
		Vector3.new(bodyW - 1.2, rsRise, rsRun),
		CFrame.new(0, trunkTopY + rsRise / 2, cabRearZ - rsRun / 2),
		BEAST_BLACK, Enum.Material.SmoothPlastic)

	-- 5. CABIN SIDES
	local cabLen = cabFrontZ - cabRearZ
	local winH   = winTopY - beltY
	local panelThick = 0.4

	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "CabinSide",
			Vector3.new(panelThick, winH, cabLen),
			CFrame.new(sx * (halfBW - panelThick / 2), beltY + winH / 2, cabFrontZ - cabLen / 2),
			BEAST_BLACK, Enum.Material.SmoothPlastic)
	end

	-- 6. ROOF
	VU.part(model, "Roof",
		Vector3.new(bodyW - 0.4, roofTopY - winTopY, cabLen + 0.4),
		CFrame.new(0, winTopY + (roofTopY - winTopY) / 2, cabFrontZ - cabLen / 2),
		BEAST_BLACK, Enum.Material.SmoothPlastic)

	-- 7. WINDSHIELD + REAR WINDOW
	local wsg = VU.part(model, "Windshield",
		Vector3.new(bodyW - 1.8, winH - 0.2, 0.15),
		CFrame.new(0, beltY + winH / 2, cabFrontZ) * CFrame.Angles(math.rad(-15), 0, 0),
		BEAST_GLASS, Enum.Material.Glass)
	wsg.Transparency = 0.3

	local rwg = VU.part(model, "RearWindow",
		Vector3.new(bodyW - 1.8, winH - 0.4, 0.15),
		CFrame.new(0, beltY + winH / 2, cabRearZ) * CFrame.Angles(math.rad(10), 0, 0),
		BEAST_GLASS, Enum.Material.Glass)
	rwg.Transparency = 0.3

	-- 8. SIDE WINDOWS
	local bPillarFrontZ = 0.5
	local bPillarRearZ  = -0.5

	for _, sx in ipairs({-1, 1}) do
		local fwLen = cabFrontZ - bPillarFrontZ - 0.4
		local fwg = VU.part(model, "SideWinFront",
			Vector3.new(0.12, winH - 0.5, fwLen),
			CFrame.new(sx * halfBW, beltY + winH / 2, bPillarFrontZ + fwLen / 2 + 0.2),
			BEAST_GLASS, Enum.Material.Glass)
		fwg.Transparency = 0.3

		local rwLen = bPillarRearZ - cabRearZ - 0.8
		local rwsg = VU.part(model, "SideWinRear",
			Vector3.new(0.12, winH - 0.5, rwLen),
			CFrame.new(sx * halfBW, beltY + winH / 2, cabRearZ + 0.4 + rwLen / 2),
			BEAST_GLASS, Enum.Material.Glass)
		rwsg.Transparency = 0.3
	end

	-- 9. FRONT END
	VU.part(model, "Grille",
		Vector3.new(3.6, 1.6, 0.25),
		CFrame.new(0, floorY + lowerH / 2 + 0.2, frontEndZ + 0.15),
		BEAST_CHROME, Enum.Material.Metal)

	for i = 0, 3 do
		VU.part(model, "GrilleBar",
			Vector3.new(3.2, 0.08, 0.3),
			CFrame.new(0, floorY + 0.5 + i * 0.4, frontEndZ + 0.2),
			BEAST_BLACK, Enum.Material.SmoothPlastic)
	end

	VU.part(model, "FrontBumper",
		Vector3.new(bodyW + 0.2, 0.8, 0.5),
		CFrame.new(0, floorY + 0.2, frontEndZ + 0.3),
		BEAST_BLACK, Enum.Material.DiamondPlate)

	VU.part(model, "FrontBumperChrome",
		Vector3.new(bodyW - 1, 0.15, 0.55),
		CFrame.new(0, floorY + 0.1, frontEndZ + 0.35),
		BEAST_CHROME, Enum.Material.Metal)

	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Headlight",
			Vector3.new(1.2, 0.6, 0.2),
			CFrame.new(sx * 2.5, floorY + lowerH / 2 + 0.5, frontEndZ + 0.2),
			Color3.fromRGB(255, 245, 210), Enum.Material.Neon)
	end

	-- 10. REAR END
	VU.part(model, "RearBumper",
		Vector3.new(bodyW + 0.2, 0.8, 0.5),
		CFrame.new(0, floorY + 0.2, rearEndZ - 0.3),
		BEAST_BLACK, Enum.Material.DiamondPlate)

	VU.part(model, "RearBumperChrome",
		Vector3.new(bodyW - 1.5, 0.15, 0.55),
		CFrame.new(0, floorY + 0.1, rearEndZ - 0.35),
		BEAST_CHROME, Enum.Material.Metal)

	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Taillight",
			Vector3.new(0.8, 1.6, 0.3),
			CFrame.new(sx * (halfBW - 0.3), floorY + lowerH / 2 + 0.5, rearEndZ - 0.2),
			Color3.fromRGB(200, 20, 15), Enum.Material.Neon)
	end

	-- 11. CHROME BELT TRIM
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "BeltTrim",
			Vector3.new(0.08, 0.12, frontEndZ - rearEndZ - 1),
			CFrame.new(sx * halfBW, beltY, 0),
			BEAST_CHROME, Enum.Material.Metal)
	end

	model.PrimaryPart = chassis
	return model
end

return Beast
