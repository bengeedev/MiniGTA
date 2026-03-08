local VU = require(script.Parent:WaitForChild("VehicleUtils"))

local HighSpeedTrain = {}

function HighSpeedTrain.build()
	local model = Instance.new("Model")
	model.Name = "Train_HighSpeed"

	-- === SHARED DIMENSIONS ===
	local W      = 10
	local H      = 10
	local floorY = 2.5
	local roofY  = floorY + H
	local winBot = floorY + 3
	local winTop = floorY + H - 1.5
	local winH   = winTop - winBot
	local botH   = winBot - floorY
	local topH   = roofY - winTop
	local bodyW  = W - 2

	-- === COLORS — TGV inOui livery ===
	local C_WHITE    = Color3.fromRGB(230, 232, 238)
	local C_CHARCOAL = Color3.fromRGB(55, 58, 65)
	local C_PINK     = Color3.fromRGB(200, 30, 120)
	local C_GLASS    = Color3.fromRGB(130, 175, 220)
	local C_CAB      = Color3.fromRGB(50, 60, 80)
	local C_UNDER    = Color3.fromRGB(40, 42, 48)
	local C_METAL    = Color3.fromRGB(150, 155, 165)
	local C_HEADL    = Color3.fromRGB(255, 245, 210)
	local C_TAILL    = Color3.fromRGB(220, 25, 15)
	local C_LIGHT    = Color3.fromRGB(255, 240, 210)
	local C_SEAT     = Color3.fromRGB(45, 55, 140)

	-------------------------------------------------------------------
	-- HELPER: build one wagon section at zCenter
	-- wallFront/wallRear: only add end walls at train extremities
	-------------------------------------------------------------------
	local function buildWagon(zCenter, wagonLen, hasCab, wallFront, wallRear)
		local z0 = zCenter - wagonLen / 2
		local z1 = zCenter + wagonLen / 2

		-- Floor (thin slab — interior hollow so seated NPCs are visible through windows)
		VU.part(model, "Floor",
			Vector3.new(bodyW, 0.3, wagonLen),
			CFrame.new(0, floorY + 0.15, zCenter),
			C_CHARCOAL, Enum.Material.SmoothPlastic)

		-- Body top (white)
		VU.part(model, "BodyTop",
			Vector3.new(bodyW, topH, wagonLen),
			CFrame.new(0, winTop + topH / 2, zCenter),
			C_WHITE, Enum.Material.SmoothPlastic)

		-- Side walls (opaque above/below window band)
		for _, s in ipairs({-1, 1}) do
			VU.part(model, "SideBot",
				Vector3.new(1, botH, wagonLen),
				CFrame.new(s * (W / 2 - 0.5), floorY + botH / 2, zCenter),
				C_CHARCOAL, Enum.Material.SmoothPlastic)
			VU.part(model, "SideTop",
				Vector3.new(1, topH, wagonLen),
				CFrame.new(s * (W / 2 - 0.5), winTop + topH / 2, zCenter),
				C_WHITE, Enum.Material.SmoothPlastic)
		end

		-- Glass
		for _, s in ipairs({-1, 1}) do
			local gw = VU.part(model, "Glass",
				Vector3.new(1, winH, wagonLen - 2),
				CFrame.new(s * (W / 2 - 0.5), winBot + winH / 2, zCenter),
				C_GLASS, Enum.Material.SmoothPlastic)
			gw.Transparency = 0.5
		end

		-- End walls (only at train extremities, not between wagons)
		for _, dir in ipairs({1, -1}) do
			local needWall = (dir == 1 and wallFront) or (dir == -1 and wallRear)
			if needWall then
				local endZ = (dir == 1) and z1 or z0
				VU.part(model, "EndWall",
					Vector3.new(W, H, 0.5),
					CFrame.new(0, floorY + H / 2, endZ + dir * 0.25),
					C_WHITE, Enum.Material.SmoothPlastic)
				VU.part(model, "EndLower",
					Vector3.new(W, botH, 0.6),
					CFrame.new(0, floorY + botH / 2, endZ + dir * 0.3),
					C_CHARCOAL, Enum.Material.SmoothPlastic)
			end
		end

		-- Cab features (windshield, lights, driver) only on cab wagons
		if hasCab then
			local cabLen = 5
			local wsH = 4
			for _, dir in ipairs({1, -1}) do
				local endZ = (dir == 1) and z1 or z0

				-- Windshield band
				local ws = VU.part(model, "Windshield",
					Vector3.new(W - 1.5, wsH, 0.15),
					CFrame.new(0, roofY - wsH / 2 - 0.8, endZ + dir * 0.55),
					C_CAB, Enum.Material.SmoothPlastic)
				ws.Transparency = 0.2

				-- Pink stripe
				VU.part(model, "EndStripe",
					Vector3.new(W - 2, 0.4, 0.2),
					CFrame.new(0, winBot + 0.2, endZ + dir * 0.6),
					C_PINK, Enum.Material.Neon)

				-- Headlights
				for _, sx in ipairs({-1, 1}) do
					VU.part(model, "Headlight",
						Vector3.new(1.5, 0.8, 0.3),
						CFrame.new(sx * 2.5, winBot - 0.5, endZ + dir * 0.7),
						C_HEADL, Enum.Material.Neon)
				end

				-- Tail lights
				for _, sx in ipairs({-1, 1}) do
					VU.part(model, "TailLight",
						Vector3.new(1.2, 0.4, 0.3),
						CFrame.new(sx * 3.5, roofY - 0.5, endZ + dir * 0.7),
						C_TAILL, Enum.Material.Neon)
				end

				-- Cab partition
				VU.part(model, "CabPartition",
					Vector3.new(W - 1, H - 2, 0.3),
					CFrame.new(0, floorY + H / 2, endZ - dir * cabLen),
					C_CHARCOAL, Enum.Material.SmoothPlastic)

				-- Dashboard
				local dashZ = endZ - dir * 1.5
				VU.part(model, "Dashboard",
					Vector3.new(W - 3, 1.5, 2),
					CFrame.new(0, floorY + 2.5, dashZ),
					C_CHARCOAL, Enum.Material.SmoothPlastic)
				VU.part(model, "DashScreen",
					Vector3.new(2, 1, 0.1),
					CFrame.new(0, floorY + 3.8, dashZ + dir * 0.5),
					C_LIGHT, Enum.Material.Neon)

			end
		end

		-- Ceiling light
		VU.part(model, "CeilingLight",
			Vector3.new(2, 0.2, wagonLen - 6),
			CFrame.new(0, roofY - 0.5, zCenter),
			C_LIGHT, Enum.Material.Neon)

		-- Seats
		local seatW   = 2
		local seatD   = 2
		local aisle   = 1.5
		local spacing = 4
		local margin  = hasCab and 8 or 3
		local sStart  = z0 + margin
		local sEnd    = z1 - margin
		local cushionY = floorY + 0.4

		local z = sStart
		while z + seatD <= sEnd do
			for _, s in ipairs({-1, 1}) do
				for seat = 0, 1 do
					local sx = s * (aisle / 2 + seatW / 2 + seat * seatW)
					VU.part(model, "Seat",
						Vector3.new(seatW - 0.2, 0.5, seatD - 0.2),
						CFrame.new(sx, cushionY + 0.65, z + seatD / 2),
						C_SEAT, Enum.Material.Fabric)
				end
			end
			z = z + spacing
		end

		-- Bogies (2 per wagon)
		for _, bOff in ipairs({wagonLen * 0.25, -wagonLen * 0.25}) do
			local bz = zCenter + bOff
			VU.part(model, "Bogie",
				Vector3.new(W - 2, 1, 5),
				CFrame.new(0, 1.2, bz),
				C_UNDER, Enum.Material.Metal)
			for _, ao in ipairs({-1.8, 1.8}) do
				for _, s in ipairs({-1, 1}) do
					VU.cylinder(model, "Wheel",
						Vector3.new(1, 1.8, 1.8),
						CFrame.new(s * (W / 2 - 1), 0.9, bz + ao),
						C_UNDER, Enum.Material.Metal)
				end
			end
		end

		-- Underbody skirt
		for _, s in ipairs({-1, 1}) do
			VU.part(model, "Skirt",
				Vector3.new(0.4, 1.5, wagonLen + 2),
				CFrame.new(s * (W / 2 - 0.1), floorY - 0.5, zCenter),
				C_METAL, Enum.Material.SmoothPlastic)
		end
	end

	-------------------------------------------------------------------
	-- BUILD: Head wagon (cab) + 8 passenger wagons
	-------------------------------------------------------------------
	local headL      = 50   -- head wagon length
	local wagonL     = 45   -- passenger wagon length
	local gap        = 3    -- gap between wagons (coupler space)
	local numWagons  = 3    -- passenger wagons behind head

	-- Head wagon: front wall yes, rear wall no (connects to wagon 1)
	local headZ = headL / 2
	buildWagon(headZ, headL, true, true, false)

	-- Passenger wagons, chained behind head
	local prevZ = headZ
	local prevL = headL
	local wagonCenters = {}
	for i = 1, numWagons do
		local wZ = prevZ - prevL / 2 - gap - wagonL / 2
		local isLast = (i == numWagons)
		-- no front wall (connected to previous), rear wall only on last
		buildWagon(wZ, wagonL, false, false, isLast)
		table.insert(wagonCenters, wZ)
		prevZ = wZ
		prevL = wagonL
	end

	-- Couplers between all wagons
	local couplerZs = { headZ - headL / 2 - gap / 2 }
	for i = 1, #wagonCenters - 1 do
		table.insert(couplerZs, wagonCenters[i] - wagonL / 2 - gap / 2)
	end
	for _, cz in ipairs(couplerZs) do
		VU.part(model, "Coupler",
			Vector3.new(W - 2, H - 2, gap),
			CFrame.new(0, floorY + H / 2, cz),
			C_CHARCOAL, Enum.Material.SmoothPlastic)
	end

	-- Pantographs — every other wagon + head
	-- Vehicle gets shifted +6 in world (wheels bottom → surfaceY=6)
	-- Contact wire world Y = 22.5, so local Y target = 22.5 - 6 = 16.5
	local pY = roofY + 0.5          -- base on roof = 13 local
	local pantoReach = 3.5           -- 16.5 - 13 = reaches contact wire

	-- Positions: head wagon + every other passenger wagon
	local pantoPositions = { headZ - 5 }
	for i = 1, #wagonCenters, 2 do
		table.insert(pantoPositions, wagonCenters[i])
	end

	for _, pz in ipairs(pantoPositions) do
		-- Base plate on roof
		VU.part(model, "PantoBase",
			Vector3.new(2.5, 0.3, 2.5),
			CFrame.new(0, pY, pz),
			C_UNDER, Enum.Material.Metal)

		-- Lower V-arms (angled outward)
		for _, s in ipairs({-1, 1}) do
			VU.part(model, "PantoLowerArm",
				Vector3.new(0.25, pantoReach * 0.6, 0.25),
				CFrame.new(s * 0.5, pY + pantoReach * 0.3, pz)
					* CFrame.Angles(0, 0, math.rad(s * -10)),
				C_METAL, Enum.Material.Metal)
		end

		-- Upper V-arms (angled inward)
		for _, s in ipairs({-1, 1}) do
			VU.part(model, "PantoUpperArm",
				Vector3.new(0.2, pantoReach * 0.5, 0.2),
				CFrame.new(s * 0.25, pY + pantoReach * 0.6 + pantoReach * 0.2, pz)
					* CFrame.Angles(0, 0, math.rad(s * 6)),
				C_METAL, Enum.Material.Metal)
		end

		-- Contact bar (touches the wire)
		VU.part(model, "PantoBar",
			Vector3.new(3.5, 0.15, 0.3),
			CFrame.new(0, pY + pantoReach, pz),
			Color3.fromRGB(50, 50, 55), Enum.Material.Metal)

		-- Contact strip (carbon strip on top of bar)
		VU.part(model, "PantoStrip",
			Vector3.new(2.5, 0.08, 0.15),
			CFrame.new(0, pY + pantoReach + 0.1, pz),
			Color3.fromRGB(35, 35, 40), Enum.Material.Metal)

	end

	-- PrimaryPart = first BodyTop created (inside buildWagon)
	local firstTop = model:FindFirstChild("BodyTop")
	if firstTop then
		model.PrimaryPart = firstTop
	end

	return model, wagonCenters
end

return HighSpeedTrain
