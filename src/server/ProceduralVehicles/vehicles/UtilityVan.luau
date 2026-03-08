local VU = require(script.Parent:WaitForChild("VehicleUtils"))

local UtilityVan = {}

--------------------------------------------------------------------------------
-- Default palette (white delivery van)
--------------------------------------------------------------------------------
local C_WHITE         = Color3.fromRGB(235, 235, 240)  -- body white
local C_TRIM          = Color3.fromRGB(30, 30, 35)     -- dark trim
local C_CHROME        = Color3.fromRGB(170, 170, 175)  -- chrome/silver
local C_GLASS         = Color3.fromRGB(130, 150, 170)  -- window glass
local C_INTERIOR      = Color3.fromRGB(45, 45, 50)     -- dark interior
local C_RUBBER        = Color3.fromRGB(30, 30, 30)     -- tires
local C_HUB           = Color3.fromRGB(100, 100, 105)  -- steel wheels
local C_HEADLIGHT     = Color3.fromRGB(255, 245, 210)  -- warm white
local C_TAILLIGHT     = Color3.fromRGB(200, 20, 15)    -- red
local C_TURN_SIGNAL   = Color3.fromRGB(255, 160, 30)   -- amber

--------------------------------------------------------------------------------
-- Shared Y constants (used by init.luau for NPC seating)
--------------------------------------------------------------------------------
local FLOOR_Y = 2.5
UtilityVan.FLOOR_Y = FLOOR_Y
UtilityVan.SEAT_Y  = 5.8
UtilityVan.DRIVER_Z = 4.5

--------------------------------------------------------------------------------
-- UTILITY VAN BUILDER
-- Boxy cargo van with cab + enclosed cargo area.
-- Parameterized for different liveries (delivery, ambulance, etc.)
-- Faces +Z forward, wheels on ground Y=0.
--
-- Options table (all optional):
--   cargoWindows = true       -- add windows to cargo sides
--   emergencyLights = Color3  -- add roof light bar with this color
--   sideDecal = "rbxassetid://..." -- decal for cargo sides
--   stripeColor = Color3      -- horizontal stripe on cargo
--------------------------------------------------------------------------------
function UtilityVan.build(modelName, bodyColor, accentColor, options)
	modelName = modelName or "UtilityVan_1"
	bodyColor = bodyColor or C_WHITE
	accentColor = accentColor or C_TRIM
	options = options or {}

	local model = Instance.new("Model")
	model.Name = modelName

	---------------------------------------------------------------------------
	-- Dimensions
	---------------------------------------------------------------------------
	local wheelR     = 1.8
	local wheelW     = 1.2
	local halfW      = 4.0
	local bodyW      = halfW * 2

	local frontEndZ  =  8.0
	local rearEndZ   = -10.0
	local cabRearZ   =  1.0      -- where cab meets cargo
	local totalLen   = frontEndZ - rearEndZ

	local frontAxleZ =  5.5
	local rearAxleZ  = -7.5

	local floorY     = FLOOR_Y
	local cabRoofY   = 9.5       -- cab height
	local cargoRoofY = 10.5      -- cargo box slightly taller
	local beltY      = floorY + 2.2
	local winH       = cabRoofY - beltY - 0.3

	local cabLen     = frontEndZ - cabRearZ
	local cargoLen   = cabRearZ - rearEndZ

	---------------------------------------------------------------------------
	-- 1. WHEELS (dual rear optional - single for now)
	---------------------------------------------------------------------------
	for _, wp in ipairs({
		{ x = -halfW, z = frontAxleZ },
		{ x =  halfW, z = frontAxleZ },
		{ x = -halfW, z = rearAxleZ  },
		{ x =  halfW, z = rearAxleZ  },
	}) do
		VU.cylinder(model, "Tire",
			Vector3.new(wheelW, wheelR * 2, wheelR * 2),
			CFrame.new(wp.x, wheelR, wp.z),
			C_RUBBER, Enum.Material.SmoothPlastic)
		VU.cylinder(model, "Hub",
			Vector3.new(wheelW + 0.1, wheelR * 0.55, wheelR * 0.55),
			CFrame.new(wp.x, wheelR, wp.z),
			C_HUB, Enum.Material.Metal)
	end

	---------------------------------------------------------------------------
	-- 2. CAB - Lower body
	---------------------------------------------------------------------------
	local cabLowerH = beltY - floorY

	-- Cab floor
	local chassis = VU.part(model, "CabFloor",
		Vector3.new(bodyW, 0.3, cabLen),
		CFrame.new(0, floorY, (frontEndZ + cabRearZ) / 2),
		C_INTERIOR, Enum.Material.SmoothPlastic)

	-- Cab side panels (below windows)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "CabSide",
			Vector3.new(0.4, cabLowerH, cabLen),
			CFrame.new(sx * (halfW - 0.2), floorY + cabLowerH / 2, (frontEndZ + cabRearZ) / 2),
			bodyColor, Enum.Material.SmoothPlastic)
	end

	-- Hood/engine cover
	local hoodLen = 2.5
	VU.part(model, "Hood",
		Vector3.new(bodyW - 0.6, 0.3, hoodLen),
		CFrame.new(0, beltY, frontEndZ - hoodLen / 2),
		bodyColor, Enum.Material.SmoothPlastic)

	-- Front nose (angled) - connects hood to bumper
	local noseH = beltY - (floorY + 0.8)
	local noseLen = 1.5
	VU.wedge(model, "FrontNose",
		Vector3.new(bodyW - 0.6, noseH, noseLen),
		CFrame.new(0, floorY + 0.8 + noseH / 2, frontEndZ - hoodLen + noseLen / 2)
			* CFrame.Angles(0, math.rad(180), 0),
		bodyColor, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- 3. CAB - Upper / Windows
	---------------------------------------------------------------------------
	-- Cab roof
	VU.part(model, "CabRoof",
		Vector3.new(bodyW, 0.35, cabLen - 1.0),
		CFrame.new(0, cabRoofY, (frontEndZ + cabRearZ) / 2 - 0.5),
		bodyColor, Enum.Material.SmoothPlastic)

	-- Windshield
	local wsH = winH + 0.5
	local wsg = VU.part(model, "Windshield",
		Vector3.new(bodyW - 1.0, wsH, 0.15),
		CFrame.new(0, beltY + wsH / 2, frontEndZ - 2.0)
			* CFrame.Angles(math.rad(-15), 0, 0),
		C_GLASS, Enum.Material.Glass)
	wsg.Transparency = 0.35

	-- A-pillars
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "APillar",
			Vector3.new(0.3, wsH + 0.5, 0.3),
			CFrame.new(sx * (halfW - 0.5), beltY + wsH / 2, frontEndZ - 2.2),
			accentColor, Enum.Material.SmoothPlastic)
	end

	-- Side windows (cab)
	for _, sx in ipairs({-1, 1}) do
		-- Door window (full side glass)
		local dwg = VU.part(model, "CabDoorWindow",
			Vector3.new(0.15, winH, cabLen - 3.0),
			CFrame.new(sx * halfW, beltY + winH / 2 + 0.15, (frontEndZ + cabRearZ) / 2 - 0.5),
			C_GLASS, Enum.Material.Glass)
		dwg.Transparency = 0.4
	end

	-- Rear cab wall (separates cab from cargo)
	VU.part(model, "CabRearWall",
		Vector3.new(bodyW - 0.8, cabRoofY - floorY, 0.3),
		CFrame.new(0, floorY + (cabRoofY - floorY) / 2, cabRearZ),
		C_INTERIOR, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- 4. CARGO BOX
	---------------------------------------------------------------------------
	local cargoH = cargoRoofY - floorY
	local cargoMidZ = (cabRearZ + rearEndZ) / 2

	-- Cargo floor
	VU.part(model, "CargoFloor",
		Vector3.new(bodyW - 0.4, 0.3, cargoLen),
		CFrame.new(0, floorY, cargoMidZ),
		C_INTERIOR, Enum.Material.SmoothPlastic)

	-- Cargo walls (sides) - hollow if windows enabled
	if options.cargoWindows then
		-- Window dimensions
		local cargoWinH = 2.5
		local cargoWinY = floorY + cargoH - cargoWinH - 1.0
		local cargoWinLen = cargoLen - 2.0

		-- Lower wall (below window)
		local lowerH = cargoWinY - floorY
		for _, sx in ipairs({-1, 1}) do
			local lowerWall = VU.part(model, "CargoSideLower",
				Vector3.new(0.35, lowerH, cargoLen),
				CFrame.new(sx * (halfW - 0.17), floorY + lowerH / 2, cargoMidZ),
				bodyColor, Enum.Material.SmoothPlastic)

			-- Add decal/logo if provided
			if options.sideDecal then
				local decal = Instance.new("Decal")
				decal.Texture = "rbxassetid://" .. tostring(options.sideDecal)
				decal.Face = sx > 0 and Enum.NormalId.Right or Enum.NormalId.Left
				decal.Parent = lowerWall
			end
		end

		-- Upper wall (above window)
		local upperY = cargoWinY + cargoWinH
		local upperH = cargoRoofY - upperY
		for _, sx in ipairs({-1, 1}) do
			VU.part(model, "CargoSideUpper",
				Vector3.new(0.35, upperH, cargoLen),
				CFrame.new(sx * (halfW - 0.17), upperY + upperH / 2, cargoMidZ),
				bodyColor, Enum.Material.SmoothPlastic)
		end

		-- Front/rear pillars (window frame)
		local pillarLen = (cargoLen - cargoWinLen) / 2
		for _, sx in ipairs({-1, 1}) do
			-- Front pillar
			VU.part(model, "CargoSideFrontPillar",
				Vector3.new(0.35, cargoWinH, pillarLen),
				CFrame.new(sx * (halfW - 0.17), cargoWinY + cargoWinH / 2, cabRearZ - pillarLen / 2),
				bodyColor, Enum.Material.SmoothPlastic)
			-- Rear pillar
			VU.part(model, "CargoSideRearPillar",
				Vector3.new(0.35, cargoWinH, pillarLen),
				CFrame.new(sx * (halfW - 0.17), cargoWinY + cargoWinH / 2, rearEndZ + pillarLen / 2),
				bodyColor, Enum.Material.SmoothPlastic)
		end

		-- Glass windows
		for _, sx in ipairs({-1, 1}) do
			local cwg = VU.part(model, "CargoWindow",
				Vector3.new(0.15, cargoWinH, cargoWinLen),
				CFrame.new(sx * halfW, cargoWinY + cargoWinH / 2, cargoMidZ),
				C_GLASS, Enum.Material.Glass)
			cwg.Transparency = 0.5
		end

		-- Interior light
		VU.part(model, "CargoInteriorLight",
			Vector3.new(1.5, 0.2, 3.0),
			CFrame.new(0, cargoRoofY - 0.5, cargoMidZ),
			Color3.fromRGB(255, 250, 230), Enum.Material.Neon)
	else
		-- Solid cargo walls (no windows)
		for _, sx in ipairs({-1, 1}) do
			VU.part(model, "CargoSide",
				Vector3.new(0.35, cargoH, cargoLen),
				CFrame.new(sx * (halfW - 0.17), floorY + cargoH / 2, cargoMidZ),
				bodyColor, Enum.Material.SmoothPlastic)
		end
	end

	-- Cargo roof
	VU.part(model, "CargoRoof",
		Vector3.new(bodyW, 0.35, cargoLen),
		CFrame.new(0, cargoRoofY, cargoMidZ),
		bodyColor, Enum.Material.SmoothPlastic)

	-- Cargo rear door
	VU.part(model, "CargoRearDoor",
		Vector3.new(bodyW - 0.4, cargoH - 0.5, 0.3),
		CFrame.new(0, floorY + (cargoH - 0.5) / 2 + 0.25, rearEndZ + 0.15),
		bodyColor, Enum.Material.SmoothPlastic)

	-- Rear door details (handle, seam)
	VU.part(model, "RearDoorSeam",
		Vector3.new(0.1, cargoH - 1.0, 0.32),
		CFrame.new(0, floorY + cargoH / 2, rearEndZ + 0.15),
		accentColor, Enum.Material.SmoothPlastic)
	VU.part(model, "RearDoorHandle",
		Vector3.new(0.8, 0.25, 0.15),
		CFrame.new(0.8, floorY + cargoH / 2, rearEndZ),
		C_CHROME, Enum.Material.Metal)

	-- OPTIONAL: Side stripe (colored band)
	if options.stripeColor then
		local stripeH = 0.8
		local stripeY = floorY + cargoH / 2
		for _, sx in ipairs({-1, 1}) do
			VU.part(model, "CargoStripe",
				Vector3.new(0.37, stripeH, cargoLen - 0.5),
				CFrame.new(sx * (halfW - 0.17), stripeY, cargoMidZ),
				options.stripeColor, Enum.Material.SmoothPlastic)
		end
	end

	-- OPTIONAL: Emergency lights on roof (same style as police car)
	if options.emergencyLights then
		local lightBarY = cargoRoofY + 0.3
		local lightBarZ = cabRearZ - 1.5
		local C_RED = Color3.fromRGB(255, 30, 20)

		-- Light bar base
		VU.part(model, "LightBarBase",
			Vector3.new(5.0, 0.25, 1.5),
			CFrame.new(0, lightBarY, lightBarZ),
			accentColor, Enum.Material.SmoothPlastic)

		-- Red lights (left side)
		local redLight1 = VU.part(model, "LightRed1",
			Vector3.new(1.0, 0.4, 1.0),
			CFrame.new(-1.5, lightBarY + 0.25, lightBarZ),
			C_RED, Enum.Material.Neon)
		local rl1 = Instance.new("PointLight")
		rl1.Color = C_RED
		rl1.Brightness = 2
		rl1.Range = 12
		rl1.Parent = redLight1

		VU.part(model, "LightRed2",
			Vector3.new(0.7, 0.35, 0.8),
			CFrame.new(-0.4, lightBarY + 0.22, lightBarZ),
			C_RED, Enum.Material.Neon)

		-- Red lights (right side)
		local redLight3 = VU.part(model, "LightRed3",
			Vector3.new(1.0, 0.4, 1.0),
			CFrame.new(1.5, lightBarY + 0.25, lightBarZ),
			C_RED, Enum.Material.Neon)
		local rl3 = Instance.new("PointLight")
		rl3.Color = C_RED
		rl3.Brightness = 2
		rl3.Range = 12
		rl3.Parent = redLight3

		VU.part(model, "LightRed4",
			Vector3.new(0.7, 0.35, 0.8),
			CFrame.new(0.4, lightBarY + 0.22, lightBarZ),
			C_RED, Enum.Material.Neon)
	end

	---------------------------------------------------------------------------
	-- 5. FRONT BUMPER + GRILLE + LIGHTS
	---------------------------------------------------------------------------
	VU.part(model, "FrontBumper",
		Vector3.new(bodyW + 0.4, 1.2, 0.6),
		CFrame.new(0, floorY - 0.4, frontEndZ + 0.3),
		accentColor, Enum.Material.SmoothPlastic)

	-- Grille
	VU.part(model, "Grille",
		Vector3.new(3.5, 1.5, 0.25),
		CFrame.new(0, floorY + 0.8, frontEndZ + 0.4),
		accentColor, Enum.Material.SmoothPlastic)

	-- Headlights
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Headlight",
			Vector3.new(1.4, 1.0, 0.25),
			CFrame.new(sx * 2.8, floorY + 1.0, frontEndZ + 0.4),
			C_HEADLIGHT, Enum.Material.Neon)

		-- Turn signals
		VU.part(model, "TurnSignal",
			Vector3.new(0.6, 0.5, 0.25),
			CFrame.new(sx * 3.5, floorY + 0.3, frontEndZ + 0.4),
			C_TURN_SIGNAL, Enum.Material.SmoothPlastic)
	end

	---------------------------------------------------------------------------
	-- 6. REAR BUMPER + LIGHTS
	---------------------------------------------------------------------------
	VU.part(model, "RearBumper",
		Vector3.new(bodyW + 0.4, 0.8, 0.5),
		CFrame.new(0, floorY - 0.3, rearEndZ - 0.25),
		accentColor, Enum.Material.SmoothPlastic)

	-- Taillights
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Taillight",
			Vector3.new(1.0, 1.5, 0.25),
			CFrame.new(sx * 3.2, floorY + 1.5, rearEndZ),
			C_TAILLIGHT, Enum.Material.Neon)

		-- Reverse lights
		VU.part(model, "ReverseLight",
			Vector3.new(0.6, 0.5, 0.25),
			CFrame.new(sx * 2.5, floorY + 0.5, rearEndZ),
			Color3.fromRGB(240, 240, 245), Enum.Material.SmoothPlastic)
	end

	---------------------------------------------------------------------------
	-- 7. SIDE MIRRORS
	---------------------------------------------------------------------------
	for _, sx in ipairs({-1, 1}) do
		-- Mirror arm
		VU.part(model, "MirrorArm",
			Vector3.new(0.8, 0.15, 0.15),
			CFrame.new(sx * (halfW + 0.4), beltY + 1.5, frontEndZ - 3.0),
			accentColor, Enum.Material.SmoothPlastic)
		-- Mirror head
		VU.part(model, "MirrorHead",
			Vector3.new(0.6, 0.8, 0.4),
			CFrame.new(sx * (halfW + 0.7), beltY + 1.5, frontEndZ - 3.0),
			accentColor, Enum.Material.Plastic)
	end

	---------------------------------------------------------------------------
	-- 8. WHEEL ARCHES (fenders)
	---------------------------------------------------------------------------
	-- Front wheel arches
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "FrontFender",
			Vector3.new(0.5, 0.8, 3.0),
			CFrame.new(sx * (halfW + 0.1), floorY - 0.5, frontAxleZ),
			bodyColor, Enum.Material.SmoothPlastic)
	end

	-- Rear wheel arches
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "RearFender",
			Vector3.new(0.5, 0.8, 3.5),
			CFrame.new(sx * (halfW + 0.1), floorY - 0.5, rearAxleZ),
			bodyColor, Enum.Material.SmoothPlastic)
	end

	---------------------------------------------------------------------------
	-- Finalize
	---------------------------------------------------------------------------
	model.PrimaryPart = chassis
	return model
end

return UtilityVan
