local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local NuclearPlant = {}

local TERRAIN_TOP = DecorUtils.TERRAIN_TOP

--------------------------------------------------------------------------------
-- LEFT / RIGHT specs for visual variety
--------------------------------------------------------------------------------

local LEFT_SPEC = {
	domeColor = Color3.fromRGB(200, 200, 205),  -- warm
	signText  = "☢ NUCLEAR ENERGY",
	signColor = Color3.fromRGB(255, 180, 60),    -- amber
	towerSpread = 16,  -- cooling towers spread wide
}

local RIGHT_SPEC = {
	domeColor = Color3.fromRGB(190, 195, 205),  -- cool
	signText  = "☢ POWER STATION",
	signColor = Color3.fromRGB(60, 200, 255),    -- cyan
	towerSpread = 12,  -- cooling towers closer together
}

--------------------------------------------------------------------------------
-- createNuclearPlant(x, z, scale)
--------------------------------------------------------------------------------

function NuclearPlant.createNuclearPlant(x, z, scale)
	local decorFolder = DecorUtils.decorFolder
	if not decorFolder then return nil end
	scale = scale or 1

	local spec = (x < 0) and LEFT_SPEC or RIGHT_SPEC
	local sign_dir = x > 0 and 1 or -1  -- +1 = right side, -1 = left side

	local model = Instance.new("Model")
	model.Name = "NuclearPlant"

	-- Dimensions (pre-scale)
	local reactorW = 20 * scale
	local reactorH = 24 * scale
	local reactorD = 20 * scale
	local baseY = TERRAIN_TOP

	-- Center of reactor (pushed away from road)
	local cx = x + sign_dir * (reactorW / 2 + 2 * scale)

	--------------------------------------------------------------------
	-- Reactor building (main containment structure)
	--------------------------------------------------------------------
	local reactor = Instance.new("Part")
	reactor.Name = "ReactorBuilding"
	reactor.Size = Vector3.new(reactorW, reactorH, reactorD)
	reactor.Position = Vector3.new(cx, baseY + reactorH / 2, z)
	reactor.Anchored = true
	reactor.Material = Enum.Material.Concrete
	reactor.Color = Color3.fromRGB(195, 195, 200)
	reactor.Parent = model

	--------------------------------------------------------------------
	-- 4 corner columns on reactor
	--------------------------------------------------------------------
	local colW = 1.2 * scale
	local colH = 25 * scale
	local halfRW = reactorW / 2 - colW / 2
	local halfRD = reactorD / 2 - colW / 2
	for _, ox in ipairs({ -halfRW, halfRW }) do
		for _, oz in ipairs({ -halfRD, halfRD }) do
			local col = Instance.new("Part")
			col.Name = "ReactorColumn"
			col.Size = Vector3.new(colW, colH, colW)
			col.Position = Vector3.new(cx + ox, baseY + colH / 2, z + oz)
			col.Anchored = true
			col.Material = Enum.Material.Concrete
			col.Color = Color3.fromRGB(180, 180, 185)
			col.Parent = model
		end
	end

	--------------------------------------------------------------------
	-- Hazard stripes on front columns (yellow/black bands)
	--------------------------------------------------------------------
	local frontColOX = -sign_dir * halfRW
	for _, oz in ipairs({ -halfRD, halfRD }) do
		for band = 0, 3 do
			local stripe = Instance.new("Part")
			stripe.Name = "HazardStripe"
			stripe.Size = Vector3.new(colW + 0.1, 0.8 * scale, colW + 0.1)
			stripe.Position = Vector3.new(
				cx + frontColOX,
				baseY + 2 * scale + band * 2.5 * scale,
				z + oz
			)
			stripe.Anchored = true
			stripe.CanCollide = false
			stripe.Material = Enum.Material.SmoothPlastic
			stripe.Color = (band % 2 == 0)
				and Color3.fromRGB(220, 190, 0)
				or Color3.fromRGB(30, 30, 30)
			stripe.Parent = model
		end
	end

	--------------------------------------------------------------------
	-- Reactor dome (sphere sitting on top, bottom half hidden inside)
	--------------------------------------------------------------------
	local domeDiam = 20 * scale
	local dome = Instance.new("Part")
	dome.Name = "ReactorDome"
	dome.Shape = Enum.PartType.Ball
	dome.Size = Vector3.new(domeDiam, domeDiam, domeDiam)
	dome.Position = Vector3.new(cx, baseY + reactorH, z)
	dome.Anchored = true
	dome.Material = Enum.Material.SmoothPlastic
	dome.Color = spec.domeColor
	dome.Parent = model

	--------------------------------------------------------------------
	-- 2 Cooling towers (offset along Z from reactor)
	--------------------------------------------------------------------
	local towerDiam = 12 * scale
	local towerH = 30 * scale
	local towerTopY = baseY + towerH / 2
	local towerSpread = spec.towerSpread * scale

	for _, side in ipairs({ -1, 1 }) do
		local tz = z + side * towerSpread
		local tx = cx

		-- Main tower cylinder
		local tower = Instance.new("Part")
		tower.Name = "CoolingTower"
		tower.Shape = Enum.PartType.Cylinder
		tower.Size = Vector3.new(towerH, towerDiam, towerDiam)
		tower.CFrame = CFrame.new(tx, towerTopY, tz) * CFrame.Angles(0, 0, math.rad(90))
		tower.Anchored = true
		tower.Material = Enum.Material.Concrete
		tower.Color = Color3.fromRGB(210, 210, 215)
		tower.Parent = model

		-- Tower rim (slightly wider cap at top)
		local rimDiam = 13 * scale
		local rimH = 1.5 * scale
		local rim = Instance.new("Part")
		rim.Name = "TowerRim"
		rim.Shape = Enum.PartType.Cylinder
		rim.Size = Vector3.new(rimH, rimDiam, rimDiam)
		rim.CFrame = CFrame.new(tx, baseY + towerH - rimH / 2, tz) * CFrame.Angles(0, 0, math.rad(90))
		rim.Anchored = true
		rim.Material = Enum.Material.Concrete
		rim.Color = Color3.fromRGB(200, 200, 205)
		rim.Parent = model

		-- Green neon ring on tower
		local glowRingDiam = towerDiam + 1 * scale
		local glowRingH = 0.6 * scale
		local glowRing = Instance.new("Part")
		glowRing.Name = "TowerGlowRing"
		glowRing.Shape = Enum.PartType.Cylinder
		glowRing.Size = Vector3.new(glowRingH, glowRingDiam, glowRingDiam)
		glowRing.CFrame = CFrame.new(tx, baseY + towerH * 0.6, tz) * CFrame.Angles(0, 0, math.rad(90))
		glowRing.Anchored = true
		glowRing.CanCollide = false
		glowRing.Material = Enum.Material.Neon
		glowRing.Color = Color3.fromRGB(0, 255, 80)
		glowRing.Parent = model

		local ringLight = Instance.new("PointLight")
		ringLight.Brightness = 1.2
		ringLight.Range = 14
		ringLight.Color = Color3.fromRGB(0, 255, 80)
		ringLight.Parent = glowRing

		-- Green steam effect at top of tower
		local steamPoint = Instance.new("Part")
		steamPoint.Name = "SteamPoint"
		steamPoint.Size = Vector3.new(1, 1, 1)
		steamPoint.Position = Vector3.new(tx, baseY + towerH + 1, tz)
		steamPoint.Anchored = true
		steamPoint.CanCollide = false
		steamPoint.Transparency = 1
		steamPoint.Parent = model

		local smoke = Instance.new("Smoke")
		smoke.Size = 14
		smoke.Opacity = 0.3
		smoke.RiseVelocity = 8
		smoke.Color = Color3.fromRGB(100, 255, 120)
		smoke.Parent = steamPoint

		-- Glow light at steam source
		local steamGlow = Instance.new("PointLight")
		steamGlow.Brightness = 1.5
		steamGlow.Range = 18
		steamGlow.Color = Color3.fromRGB(80, 255, 100)
		steamGlow.Parent = steamPoint

		-- Horizontal pipe connecting reactor to cooling tower
		local pipeLen = math.abs(towerSpread) - towerDiam / 2 - reactorD / 2
		if pipeLen > 0 then
			local pipeDiam = 2.5 * scale
			local pipeY = baseY + 10 * scale
			local pipeZ = z + side * (reactorD / 2 + pipeLen / 2)

			local pipe = Instance.new("Part")
			pipe.Name = "ConnectingPipe"
			pipe.Shape = Enum.PartType.Cylinder
			pipe.Size = Vector3.new(pipeLen, pipeDiam, pipeDiam)
			pipe.CFrame = CFrame.new(cx, pipeY, pipeZ) * CFrame.Angles(math.rad(90), 0, 0)
			pipe.Anchored = true
			pipe.Material = Enum.Material.Metal
			pipe.Color = Color3.fromRGB(140, 140, 145)
			pipe.Parent = model
		end
	end

	--------------------------------------------------------------------
	-- Turbine hall (lower building beside reactor, pushed further from road)
	--------------------------------------------------------------------
	local turbW = 16 * scale
	local turbH = 12 * scale
	local turbD = 24 * scale
	local turbX = cx + sign_dir * (reactorW / 2 + turbW / 2)

	local turbine = Instance.new("Part")
	turbine.Name = "TurbineHall"
	turbine.Size = Vector3.new(turbW, turbH, turbD)
	turbine.Position = Vector3.new(turbX, baseY + turbH / 2, z)
	turbine.Anchored = true
	turbine.Material = Enum.Material.Concrete
	turbine.Color = Color3.fromRGB(160, 160, 165)
	turbine.Parent = model

	--------------------------------------------------------------------
	-- Radiation door (yellow, on road-facing side of reactor)
	--------------------------------------------------------------------
	local doorFaceX = cx - sign_dir * (reactorW / 2 + 0.15)
	local door = Instance.new("Part")
	door.Name = "RadiationDoor"
	door.Size = Vector3.new(0.3 * scale, 8 * scale, 10 * scale)
	door.Position = Vector3.new(doorFaceX, baseY + 4 * scale, z)
	door.Anchored = true
	door.Material = Enum.Material.SmoothPlastic
	door.Color = Color3.fromRGB(220, 190, 0)
	door.Parent = model

	-- Procedural radiation trefoil neon sign (above front door)
	local NEON_GREEN = Color3.fromRGB(0, 255, 80)
	local signR = 3.0 * scale
	local neonThick = 0.3 * scale
	local radCX = doorFaceX - sign_dir * 0.2
	local radCY = baseY + 12 * scale
	local radCZ = z

	-- Green neon border ring (behind backing, edge peeks out)
	local borderRing = Instance.new("Part")
	borderRing.Name = "RadBorderRing"
	borderRing.Shape = Enum.PartType.Cylinder
	borderRing.Size = Vector3.new(neonThick * 0.4, signR * 2.3, signR * 2.3)
	borderRing.CFrame = CFrame.new(radCX + sign_dir * 0.06, radCY, radCZ)
	borderRing.Anchored = true
	borderRing.CanCollide = false
	borderRing.Material = Enum.Material.Neon
	borderRing.Color = NEON_GREEN
	borderRing.Parent = model

	-- Dark backing disc (in front of border ring)
	local radBacking = Instance.new("Part")
	radBacking.Name = "RadSignBacking"
	radBacking.Shape = Enum.PartType.Cylinder
	radBacking.Size = Vector3.new(neonThick * 0.5, signR * 1.95, signR * 1.95)
	radBacking.CFrame = CFrame.new(radCX, radCY, radCZ)
	radBacking.Anchored = true
	radBacking.CanCollide = false
	radBacking.Material = Enum.Material.Metal
	radBacking.Color = Color3.fromRGB(25, 25, 30)
	radBacking.Parent = model

	-- 3 trefoil blades (neon green, 120 degrees apart in YZ plane)
	local bladeLen = 1.6 * scale
	local bladeWid = 2.0 * scale
	local bladeOff = 1.4 * scale
	local radBlades = {}

	for i = 0, 2 do
		local angle = i * math.rad(120)
		local blade = Instance.new("Part")
		blade.Name = "RadBlade"
		blade.Size = Vector3.new(neonThick, bladeLen, bladeWid)
		blade.CFrame = CFrame.new(radCX - sign_dir * 0.08, radCY, radCZ)
			* CFrame.Angles(angle, 0, 0)
			* CFrame.new(0, bladeOff, 0)
		blade.Anchored = true
		blade.CanCollide = false
		blade.Material = Enum.Material.Neon
		blade.Color = NEON_GREEN
		blade.Parent = model
		table.insert(radBlades, blade)
	end

	-- Yellow neon center dot
	local centerDot = Instance.new("Part")
	centerDot.Name = "RadCenter"
	centerDot.Shape = Enum.PartType.Ball
	centerDot.Size = Vector3.new(0.7 * scale, 0.7 * scale, 0.7 * scale)
	centerDot.Position = Vector3.new(radCX - sign_dir * 0.12, radCY, radCZ)
	centerDot.Anchored = true
	centerDot.CanCollide = false
	centerDot.Material = Enum.Material.Neon
	centerDot.Color = Color3.fromRGB(255, 255, 0)
	centerDot.Parent = model

	-- Glow light (pulses via animation)
	local radLight = Instance.new("PointLight")
	radLight.Brightness = 2
	radLight.Range = 14
	radLight.Color = NEON_GREEN
	radLight.Parent = centerDot

	-- Red neon "DANGER" text plate below trefoil
	local dangerW = 5 * scale
	local dangerH = 1.2 * scale
	local dangerPart = Instance.new("Part")
	dangerPart.Name = "DangerSign"
	dangerPart.Size = Vector3.new(neonThick, dangerH, dangerW)
	dangerPart.Position = Vector3.new(radCX, radCY - signR - 1.0 * scale, radCZ)
	dangerPart.Anchored = true
	dangerPart.CanCollide = false
	dangerPart.Material = Enum.Material.Neon
	dangerPart.Color = Color3.fromRGB(255, 60, 30)
	dangerPart.Parent = model

	local dangerGui = Instance.new("SurfaceGui")
	dangerGui.Face = sign_dir > 0 and Enum.NormalId.Left or Enum.NormalId.Right
	dangerGui.Parent = dangerPart

	local dangerTxt = Instance.new("TextLabel")
	dangerTxt.Size = UDim2.new(1, 0, 1, 0)
	dangerTxt.BackgroundTransparency = 1
	dangerTxt.Font = Enum.Font.GothamBold
	dangerTxt.Text = "DANGER"
	dangerTxt.TextColor3 = Color3.new(1, 1, 1)
	dangerTxt.TextScaled = true
	dangerTxt.Parent = dangerGui

	-- Register pulse animation
	DecorUtils.activePlatformAnimations[radBacking] = {
		type = "radiation_pulse",
		blades = radBlades,
		light = radLight,
		centerDot = centerDot,
		borderRing = borderRing,
	}

	-- 2 hazard strips above door
	for _, hOff in ipairs({ -3 * scale, 3 * scale }) do
		local strip = Instance.new("Part")
		strip.Name = "HazardStrip"
		strip.Size = Vector3.new(0.35 * scale, 0.6 * scale, 9 * scale)
		strip.Position = Vector3.new(doorFaceX - sign_dir * 0.05, baseY + 8.3 * scale, z + hOff)
		strip.Anchored = true
		strip.CanCollide = false
		strip.Material = Enum.Material.Neon
		strip.Color = Color3.fromRGB(220, 190, 0)
		strip.Parent = model
	end

	--------------------------------------------------------------------
	-- Warning sign (Neon + SurfaceGui)
	--------------------------------------------------------------------
	local signW = 12 * scale
	local signH = 3 * scale
	local signX = cx - sign_dir * (reactorW / 2 + 0.3)
	local signY = baseY + reactorH - 4 * scale

	local signPart = Instance.new("Part")
	signPart.Name = "NuclearSign"
	signPart.Size = Vector3.new(0.4 * scale, signH, signW)
	signPart.Position = Vector3.new(signX, signY, z)
	signPart.Anchored = true
	signPart.Material = Enum.Material.Neon
	signPart.Color = spec.signColor
	signPart.Parent = model

	local gui = Instance.new("SurfaceGui")
	gui.Face = sign_dir > 0 and Enum.NormalId.Left or Enum.NormalId.Right
	gui.Parent = signPart

	local txt = Instance.new("TextLabel")
	txt.Size = UDim2.new(1, 0, 1, 0)
	txt.BackgroundTransparency = 1
	txt.Font = Enum.Font.GothamBold
	txt.Text = spec.signText
	txt.TextColor3 = Color3.new(1, 1, 1)
	txt.TextScaled = true
	txt.Parent = gui

	local signLight = Instance.new("PointLight")
	signLight.Brightness = 1.5
	signLight.Range = 16
	signLight.Color = spec.signColor
	signLight.Parent = signPart

	--------------------------------------------------------------------
	-- Security barrier (low metal railing between plant and road)
	--------------------------------------------------------------------
	local barrierH = 3 * scale
	local barrierD = 40 * scale  -- spans most of the lane depth
	local barrierX = x - sign_dir * (0.5 * scale)

	local barrier = Instance.new("Part")
	barrier.Name = "SecurityBarrier"
	barrier.Size = Vector3.new(0.5 * scale, barrierH, barrierD)
	barrier.Position = Vector3.new(barrierX, baseY + barrierH / 2, z)
	barrier.Anchored = true
	barrier.Material = Enum.Material.Metal
	barrier.Color = Color3.fromRGB(100, 100, 105)
	barrier.Parent = model

	model.Parent = decorFolder
	return model
end

return NuclearPlant
