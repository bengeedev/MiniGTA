local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local StationPlatform = {}

--------------------------------------------------------------------------------
-- Station Platform — 5 tracks along X, filling the lane depth along Z.
-- Trains on middle 3 tracks, outer 2 empty. All cabs face -X (toward player).
-- Buffer stops at the near-X end. Platforms between tracks.
--------------------------------------------------------------------------------

function StationPlatform.createStationPlatform(x, z, scale)
	if not DecorUtils.decorFolder then return nil end
	scale = scale or 1

	local TERRAIN_TOP = DecorUtils.TERRAIN_TOP
	local terrainOff = 2
	local surfaceY = TERRAIN_TOP + terrainOff

	local model = Instance.new("Model")
	model.Name = "StationPlatform"

	local xSign = x > 0 and 1 or -1

	-- Colors
	local C_CONCRETE = Color3.fromRGB(170, 170, 175)
	local C_RAIL     = Color3.fromRGB(160, 155, 150)
	local C_SLEEPER  = Color3.fromRGB(155, 155, 160)
	local C_BED      = Color3.fromRGB(175, 175, 180)
	local C_YELLOW   = Color3.fromRGB(255, 200, 0)
	local C_RED      = Color3.fromRGB(200, 40, 30)
	local C_STEEL    = Color3.fromRGB(85, 90, 100)
	local C_METAL    = Color3.fromRGB(70, 75, 80)
	local C_WARM     = Color3.fromRGB(255, 220, 140)

	-- Layout
	local trackBedW  = 12 * scale
	local platformD  = 6 * scale
	local trackLen   = 250 * scale
	local platformH  = 2.5 * scale

	-- Rail dimensions
	local bedH      = 0.8 * scale
	local railH     = 0.8 * scale
	local railW     = 0.5 * scale
	local railGauge = 4 * scale
	local railY     = surfaceY + bedH + railH / 2

	-- Track center X
	local nearX = x
	local cx = nearX + xSign * trackLen / 2

	-- 5 tracks evenly spaced along Z, covering ~80 studs of the 90-depth lane
	local trackSpacing = 16 * scale
	local trackCZs = {}
	for i = -2, 2 do
		table.insert(trackCZs, z + i * trackSpacing)
	end

	-- Platforms between adjacent tracks (4 platforms)
	local platCZs = {}
	for i = 1, #trackCZs - 1 do
		table.insert(platCZs, (trackCZs[i] + trackCZs[i + 1]) / 2)
	end

	-- Tracks with trains: middle 3 (indices 2, 3, 4)
	local trainTrackIndices = {2, 3, 4}

	---------------------------------------------------------------------------
	-- 1. TRACK BEDS
	---------------------------------------------------------------------------
	for _, tcz in ipairs(trackCZs) do
		local bed = Instance.new("Part")
		bed.Name = "TrackBed"
		bed.Size = Vector3.new(trackLen, bedH, trackBedW)
		bed.Position = Vector3.new(cx, surfaceY + bedH / 2, tcz)
		bed.Anchored = true
		bed.CanCollide = false
		bed.Material = Enum.Material.Concrete
		bed.Color = C_BED
		bed.Parent = model
	end

	---------------------------------------------------------------------------
	-- 2. RAILS
	---------------------------------------------------------------------------
	for _, tcz in ipairs(trackCZs) do
		for _, side in ipairs({-1, 1}) do
			local rail = Instance.new("Part")
			rail.Name = "Rail"
			rail.Size = Vector3.new(trackLen, railH, railW)
			rail.Position = Vector3.new(cx, railY, tcz + side * railGauge / 2)
			rail.Anchored = true
			rail.CanCollide = false
			rail.Material = Enum.Material.Metal
			rail.Color = C_RAIL
			rail.Parent = model
		end
	end

	---------------------------------------------------------------------------
	-- 3. SLEEPERS
	---------------------------------------------------------------------------
	local sleeperH = 0.3 * scale
	local sleeperLen = 10 * scale
	local sleeperD = 1.5 * scale
	local sleeperY = surfaceY + bedH / 2 + 0.3
	local sleeperSpacing = 5

	for _, tcz in ipairs(trackCZs) do
		for sx = -trackLen / 2, trackLen / 2, sleeperSpacing do
			local sleeper = Instance.new("Part")
			sleeper.Name = "Sleeper"
			sleeper.Size = Vector3.new(sleeperD, sleeperH, sleeperLen)
			sleeper.Position = Vector3.new(cx + sx, sleeperY, tcz)
			sleeper.Anchored = true
			sleeper.CanCollide = false
			sleeper.Material = Enum.Material.Concrete
			sleeper.Color = C_SLEEPER
			sleeper.Parent = model
		end
	end

	---------------------------------------------------------------------------
	-- 4. BUFFER STOPS (only on tracks with trains)
	---------------------------------------------------------------------------
	local bufferX = nearX + xSign * 3
	local bufferW = 3 * scale
	local bufferH = 4 * scale

	for _, idx in ipairs(trainTrackIndices) do
		local tcz = trackCZs[idx]

		local block = Instance.new("Part")
		block.Name = "BufferStop"
		block.Size = Vector3.new(bufferW, bufferH, trackBedW * 0.6)
		block.Position = Vector3.new(bufferX, surfaceY + bufferH / 2, tcz)
		block.Anchored = true
		block.Material = Enum.Material.Concrete
		block.Color = C_CONCRETE
		block.Parent = model

		local face = Instance.new("Part")
		face.Name = "BufferFace"
		face.Size = Vector3.new(0.3, bufferH * 0.7, trackBedW * 0.5)
		face.Position = Vector3.new(bufferX - xSign * (bufferW / 2 + 0.15), surfaceY + bufferH * 0.45, tcz)
		face.Anchored = true
		face.CanCollide = false
		face.Material = Enum.Material.SmoothPlastic
		face.Color = C_RED
		face.Parent = model

		local stripe = Instance.new("Part")
		stripe.Name = "BufferStripe"
		stripe.Size = Vector3.new(0.05, 0.6 * scale, trackBedW * 0.5)
		stripe.Position = Vector3.new(bufferX - xSign * (bufferW / 2 + 0.3), surfaceY + bufferH * 0.6, tcz)
		stripe.Anchored = true
		stripe.CanCollide = false
		stripe.Material = Enum.Material.Neon
		stripe.Color = C_YELLOW
		stripe.Parent = model
	end

	---------------------------------------------------------------------------
	-- 5. PLATFORMS (between all adjacent tracks)
	---------------------------------------------------------------------------
	local platTop = TERRAIN_TOP + platformH

	for _, pcz in ipairs(platCZs) do
		local plat = Instance.new("Part")
		plat.Name = "Platform"
		plat.Size = Vector3.new(trackLen * 0.5, platformH, platformD)
		plat.Position = Vector3.new(cx + xSign * trackLen * 0.15, TERRAIN_TOP + platformH / 2, pcz)
		plat.Anchored = true
		plat.Material = Enum.Material.Concrete
		plat.Color = C_CONCRETE
		plat.Parent = model

		for _, side in ipairs({-1, 1}) do
			local lineZ = pcz + side * (platformD / 2 - 0.3 * scale)
			local line = Instance.new("Part")
			line.Name = "SafetyLine"
			line.Size = Vector3.new(trackLen * 0.5, 0.05, 0.7 * scale)
			line.Position = Vector3.new(cx + xSign * trackLen * 0.15, platTop + 0.03, lineZ)
			line.Anchored = true
			line.CanCollide = false
			line.Material = Enum.Material.Neon
			line.Color = C_YELLOW
			line.Parent = model
		end
	end

	---------------------------------------------------------------------------
	-- 6. CANOPIES (on the 2 platforms adjacent to train tracks)
	---------------------------------------------------------------------------
	local canopyH = 14 * scale
	local canopyY = platTop + canopyH
	local canopyLen = trackLen * 0.3

	for i = 1, #platCZs do
		local pcz = platCZs[i]
		local canopy = Instance.new("Part")
		canopy.Name = "PlatformCanopy"
		canopy.Size = Vector3.new(canopyLen, 0.5 * scale, platformD + 2 * scale)
		canopy.Position = Vector3.new(cx, canopyY, pcz)
		canopy.Anchored = true
		canopy.Material = Enum.Material.Metal
		canopy.Color = C_STEEL
		canopy.Parent = model

		local NUM_COLS = 4
		local colSpacing = canopyLen / (NUM_COLS - 1)
		for c = 0, NUM_COLS - 1 do
			local colX = cx - canopyLen / 2 + c * colSpacing
			for _, side in ipairs({-1, 1}) do
				local col = Instance.new("Part")
				col.Name = "CanopyCol"
				col.Size = Vector3.new(0.5 * scale, canopyH, 0.5 * scale)
				col.Position = Vector3.new(colX, platTop + canopyH / 2, pcz + side * (platformD / 2 - 0.3 * scale))
				col.Anchored = true
				col.Material = Enum.Material.Metal
				col.Color = C_STEEL
				col.Parent = model
			end
		end

		-- Lamps
		for c = 0, NUM_COLS - 2 do
			local lx = cx - canopyLen / 2 + (c + 0.5) * colSpacing
			local bulb = Instance.new("Part")
			bulb.Name = "PlatformLamp"
			bulb.Shape = Enum.PartType.Ball
			bulb.Size = Vector3.new(1.2 * scale, 1.2 * scale, 1.2 * scale)
			bulb.Position = Vector3.new(lx, canopyY - 0.8, pcz)
			bulb.Anchored = true
			bulb.CanCollide = false
			bulb.Material = Enum.Material.Neon
			bulb.Color = C_WARM
			bulb.Parent = model

			local pl = Instance.new("PointLight")
			pl.Brightness = 1
			pl.Range = 16
			pl.Color = C_WARM
			pl.Parent = bulb
		end
	end

	---------------------------------------------------------------------------
	-- 7. PARKED TGV TRAINS — cabs face -X (toward player)
	--    Train native: runs along Z, head at +Z.
	--    math.rad(-90): local +Z → world -X. Head faces toward player.
	--    Trim to head + 2 wagons (local Z > -100).
	--    PrimaryPart (BodyTop) at local (0, 11.75, 25).
	---------------------------------------------------------------------------
	local templates = ReplicatedStorage:FindFirstChild("VehicleTemplates")
	if templates then
		local trainTemplate = templates:FindFirstChild("Train_HighSpeed")
		if trainTemplate then
			local pivotYOffset = 11.75
			local Z_CUTOFF = -100

			-- After -90° rotation, head front is at pivotX - 25.
			-- We want heads near the playable edge (nearX).
			-- Head at nearX + 10 → pivotX = nearX + 35
			local trainBaseX = nearX + 35

			local function placeParkedTrain(name, trackCZ, xOffset)
				local train = trainTemplate:Clone()
				train.Name = name

				for _, p in ipairs(train:GetDescendants()) do
					if p:IsA("BasePart") then
						if p.Position.Z < Z_CUTOFF then
							p:Destroy()
						else
							p.Anchored = true
							p.CanCollide = false
						end
					end
				end

				-- math.rad(-90): local +Z → world -X (head faces player)
				train:PivotTo(
					CFrame.new(trainBaseX + xOffset, surfaceY + pivotYOffset, trackCZ)
					* CFrame.Angles(0, math.rad(-90), 0)
				)
				train.Parent = DecorUtils.decorFolder
			end

			-- Stagger trains in X for realism (offset pushes further back)
			placeParkedTrain("ParkedTrain1", trackCZs[2], 0)
			placeParkedTrain("ParkedTrain2", trackCZs[3], 25)
			placeParkedTrain("ParkedTrain3", trackCZs[4], 10)
		end
	end

	model.Parent = DecorUtils.decorFolder
	return model
end

return StationPlatform
