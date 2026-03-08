local VU = require(script.Parent:WaitForChild("VehicleUtils"))

local SubwayTrain = {}

function SubwayTrain.build()
	local model = Instance.new("Model")
	model.Name = "Subway_1"

	-- === SHARED DIMENSIONS (same as high-speed) ===
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

	-- === COLORS — NYC Subway stainless steel ===
	local C_SILVER   = Color3.fromRGB(190, 195, 205)
	local C_DARK     = Color3.fromRGB(60, 62, 68)
	local C_BLUE     = Color3.fromRGB(0, 57, 166)
	local C_GLASS    = Color3.fromRGB(140, 180, 210)
	local C_CAB      = Color3.fromRGB(45, 50, 65)
	local C_UNDER    = Color3.fromRGB(40, 42, 48)
	local C_METAL    = Color3.fromRGB(150, 155, 165)
	local C_HEADL    = Color3.fromRGB(255, 245, 210)
	local C_TAILL    = Color3.fromRGB(220, 25, 15)
	local C_LIGHT    = Color3.fromRGB(255, 240, 210)
	local C_SEAT     = Color3.fromRGB(230, 120, 30)

	-------------------------------------------------------------------
	-- HELPER: build one subway car at zCenter
	-------------------------------------------------------------------
	local function buildCar(zCenter, carLen, hasCab, wallFront, wallRear)
		local z0 = zCenter - carLen / 2
		local z1 = zCenter + carLen / 2

		-- Floor (thin slab — interior hollow so seated NPCs are visible through windows)
		VU.part(model, "Floor",
			Vector3.new(bodyW, 0.3, carLen),
			CFrame.new(0, floorY + 0.15, zCenter),
			C_DARK, Enum.Material.SmoothPlastic)

		-- Body top (silver)
		VU.part(model, "BodyTop",
			Vector3.new(bodyW, topH, carLen),
			CFrame.new(0, winTop + topH / 2, zCenter),
			C_SILVER, Enum.Material.Metal)

		-- Blue stripe along sides (MTA style)
		for _, s in ipairs({-1, 1}) do
			VU.part(model, "BlueStripe",
				Vector3.new(0.15, 1.2, carLen - 2),
				CFrame.new(s * (W / 2 - 0.35), winBot + 0.6, zCenter),
				C_BLUE, Enum.Material.SmoothPlastic)
		end

		-- Side walls (opaque above/below window band)
		for _, s in ipairs({-1, 1}) do
			VU.part(model, "SideBot",
				Vector3.new(1, botH, carLen),
				CFrame.new(s * (W / 2 - 0.5), floorY + botH / 2, zCenter),
				C_DARK, Enum.Material.SmoothPlastic)
			VU.part(model, "SideTop",
				Vector3.new(1, topH, carLen),
				CFrame.new(s * (W / 2 - 0.5), winTop + topH / 2, zCenter),
				C_SILVER, Enum.Material.Metal)
		end

		-- Glass windows
		for _, s in ipairs({-1, 1}) do
			local gw = VU.part(model, "Glass",
				Vector3.new(1, winH, carLen - 2),
				CFrame.new(s * (W / 2 - 0.5), winBot + winH / 2, zCenter),
				C_GLASS, Enum.Material.SmoothPlastic)
			gw.Transparency = 0.5
		end

		-- End walls
		for _, dir in ipairs({1, -1}) do
			local needWall = (dir == 1 and wallFront) or (dir == -1 and wallRear)
			if needWall then
				local endZ = (dir == 1) and z1 or z0
				VU.part(model, "EndWall",
					Vector3.new(W, H, 0.5),
					CFrame.new(0, floorY + H / 2, endZ + dir * 0.25),
					C_SILVER, Enum.Material.Metal)
				VU.part(model, "EndLower",
					Vector3.new(W, botH, 0.6),
					CFrame.new(0, floorY + botH / 2, endZ + dir * 0.3),
					C_DARK, Enum.Material.SmoothPlastic)
			end
		end

		-- Cab features (front/rear of head car)
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

				-- Blue stripe on end
				VU.part(model, "EndStripe",
					Vector3.new(W - 2, 0.6, 0.2),
					CFrame.new(0, winBot + 0.3, endZ + dir * 0.6),
					C_BLUE, Enum.Material.Neon)

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
					C_DARK, Enum.Material.SmoothPlastic)

				-- Dashboard
				local dashZ = endZ - dir * 1.5
				VU.part(model, "Dashboard",
					Vector3.new(W - 3, 1.5, 2),
					CFrame.new(0, floorY + 2.5, dashZ),
					C_DARK, Enum.Material.SmoothPlastic)
				VU.part(model, "DashScreen",
					Vector3.new(2, 1, 0.1),
					CFrame.new(0, floorY + 3.8, dashZ + dir * 0.5),
					C_LIGHT, Enum.Material.Neon)

			end
		end

		-- Ceiling light
		VU.part(model, "CeilingLight",
			Vector3.new(2, 0.2, carLen - 6),
			CFrame.new(0, roofY - 0.5, zCenter),
			C_LIGHT, Enum.Material.Neon)

		-- Grab poles (vertical poles near doors — subway style)
		for _, poleZ in ipairs({z0 + 5, z1 - 5}) do
			for _, s in ipairs({-1, 1}) do
				VU.cylinder(model, "GrabPole",
					Vector3.new(0.3, H - 1, 0.3),
					CFrame.new(s * (W / 2 - 2), floorY + H / 2, poleZ),
					C_METAL, Enum.Material.Metal)
			end
		end

		-- Seats (bench-style along sides, subway layout)
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

		-- Bogies (2 per car)
		for _, bOff in ipairs({carLen * 0.25, -carLen * 0.25}) do
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
				Vector3.new(0.4, 1.5, carLen + 2),
				CFrame.new(s * (W / 2 - 0.1), floorY - 0.5, zCenter),
				C_METAL, Enum.Material.SmoothPlastic)
		end
	end

	-------------------------------------------------------------------
	-- BUILD: Head car (cab) + 5 passenger cars (shorter than TGV)
	-------------------------------------------------------------------
	local headL     = 50
	local carL      = 45
	local gap       = 3
	local numCars   = 5

	-- Head car: front wall yes, rear wall no
	local headZ = headL / 2
	buildCar(headZ, headL, true, true, false)

	-- Passenger cars
	local prevZ = headZ
	local prevL = headL
	local carCenters = {}
	for i = 1, numCars do
		local cZ = prevZ - prevL / 2 - gap - carL / 2
		local isLast = (i == numCars)
		buildCar(cZ, carL, false, false, isLast)
		table.insert(carCenters, cZ)
		prevZ = cZ
		prevL = carL
	end

	-- Couplers between all cars
	local couplerZ = headZ - headL / 2 - gap / 2
	VU.part(model, "Coupler",
		Vector3.new(W - 2, H - 2, gap),
		CFrame.new(0, floorY + H / 2, couplerZ),
		C_DARK, Enum.Material.SmoothPlastic)
	local prevCZ = headZ
	local prevCL = headL
	for i = 1, numCars - 1 do
		local cZ = prevCZ - prevCL / 2 - gap - carL / 2
		local coupler = cZ - carL / 2 - gap / 2
		VU.part(model, "Coupler",
			Vector3.new(W - 2, H - 2, gap),
			CFrame.new(0, floorY + H / 2, coupler),
			C_DARK, Enum.Material.SmoothPlastic)
		prevCZ = cZ
		prevCL = carL
	end

	-- No pantographs — subway uses third rail

	-- Roof-mounted AC units (subway style)
	local allCenters = { headZ }
	local pZ = headZ
	local pL = headL
	for i = 1, numCars do
		local cZ = pZ - pL / 2 - gap - carL / 2
		table.insert(allCenters, cZ)
		pZ = cZ
		pL = carL
	end
	for _, cz in ipairs(allCenters) do
		VU.part(model, "ACUnit",
			Vector3.new(4, 0.8, 8),
			CFrame.new(0, roofY + 0.4, cz),
			C_DARK, Enum.Material.Metal)
	end

	local firstTop = model:FindFirstChild("BodyTop")
	if firstTop then
		model.PrimaryPart = firstTop
	end

	return model, carCenters
end

return SubwayTrain
