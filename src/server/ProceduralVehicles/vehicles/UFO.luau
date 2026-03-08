local VU = require(script.Parent:WaitForChild("VehicleUtils"))

local UFO = {}

local UFO_BODY = Color3.fromRGB(55, 55, 65)
local UFO_GREEN = Color3.fromRGB(0, 255, 80)
local UFO_BLUE = Color3.fromRGB(30, 120, 255)
local UFO_RED = Color3.fromRGB(255, 30, 20)
local UFO_DOME = Color3.fromRGB(40, 60, 70)
local UFO_CANNON = Color3.fromRGB(30, 30, 35)

-- Exported for parameterized calls in init.luau
UFO.GREEN = UFO_GREEN
UFO.BLUE = UFO_BLUE

function UFO.build(modelName, laserColor, laserCoreColor)
	local model = Instance.new("Model")
	model.Name = modelName

	-- Invisible root part so PivotTo doesn't overwrite saucer rotation
	local root = VU.part(model, "Root",
		Vector3.new(1, 1, 1),
		CFrame.new(0, 0, 0),
		UFO_BODY, Enum.Material.SmoothPlastic)
	root.Transparency = 1

	-- Main saucer disc (18 stud diameter, flat horizontal)
	VU.cylinder(model, "Saucer",
		Vector3.new(1.8, 18, 18),
		CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, math.rad(90)),
		UFO_BODY, Enum.Material.Metal)

	-- Upper hull ridge
	VU.cylinder(model, "UpperRidge",
		Vector3.new(0.6, 12, 12),
		CFrame.new(0, 0.7, 0) * CFrame.Angles(0, 0, math.rad(90)),
		UFO_BODY, Enum.Material.Metal)

	-- Dome on top (darker, menacing tint)
	local dome = VU.ball(model, "Dome",
		Vector3.new(7, 4.5, 7),
		CFrame.new(0, 1.8, 0),
		UFO_DOME, Enum.Material.Glass)
	dome.Transparency = 0.3

	-- Red accent lights on dome base (4 evenly spaced)
	for i = 0, 3 do
		local angle = math.rad(i * 90)
		local rx = math.cos(angle) * 3
		local rz = math.sin(angle) * 3
		VU.ball(model, "DomeLight",
			Vector3.new(0.5, 0.5, 0.5),
			CFrame.new(rx, 1.2, rz),
			UFO_RED, Enum.Material.Neon)
	end

	-- Rim lights (8 around edge, bright green)
	for i = 0, 7 do
		local angle = math.rad(i * 45)
		local rx = math.cos(angle) * 8
		local rz = math.sin(angle) * 8
		VU.ball(model, "RimLight",
			Vector3.new(0.9, 0.9, 0.9),
			CFrame.new(rx, -0.2, rz),
			UFO_GREEN, Enum.Material.Neon)
	end

	-- Underside glow ring
	local glow = VU.cylinder(model, "UndersideGlow",
		Vector3.new(0.3, 10, 10),
		CFrame.new(0, -0.9, 0) * CFrame.Angles(0, 0, math.rad(90)),
		UFO_GREEN, Enum.Material.Neon)
	glow.Transparency = 0.35

	-- Laser cannon turret housing
	VU.cylinder(model, "CannonMount",
		Vector3.new(1.2, 4, 4),
		CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(90)),
		UFO_CANNON, Enum.Material.Metal)

	-- Laser barrel (dark cylinder pointing down)
	VU.cylinder(model, "LaserBarrel",
		Vector3.new(3.5, 1.4, 1.4),
		CFrame.new(0, -3, 0) * CFrame.Angles(0, 0, math.rad(90)),
		UFO_CANNON, Enum.Material.DiamondPlate)

	-- Laser tip glow
	local tip = VU.ball(model, "LaserTip",
		Vector3.new(1.6, 1.6, 1.6),
		CFrame.new(0, -4.8, 0),
		laserColor, Enum.Material.Neon)
	tip.Transparency = 0.2

	-- Laser beam start attachment (on the tip)
	local att0 = Instance.new("Attachment")
	att0.Name = "LaserStart"
	att0.Parent = tip

	-- Ground impact part (invisible, 25 studs below root = ground level)
	-- computeVehicleY skips Transparency>=1 parts so this won't break flight height.
	local impact = VU.part(model, "LaserImpact",
		Vector3.new(0.5, 0.5, 0.5),
		CFrame.new(0, -25, 0),
		laserColor, Enum.Material.SmoothPlastic)
	impact.Transparency = 1

	local att1 = Instance.new("Attachment")
	att1.Name = "LaserEnd"
	att1.Parent = impact

	-- Laser beam (outer glow)
	local beam = Instance.new("Beam")
	beam.Name = "LaserBeam"
	beam.Attachment0 = att0
	beam.Attachment1 = att1
	beam.Color = ColorSequence.new(laserColor)
	beam.LightEmission = 1
	beam.LightInfluence = 0
	beam.Brightness = 3
	beam.Width0 = 1.2
	beam.Width1 = 2.5
	beam.Segments = 1
	beam.FaceCamera = true
	beam.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(0.8, 0.15),
		NumberSequenceKeypoint.new(1, 0.4),
	})
	beam.Parent = tip

	-- Inner core beam (brighter, thinner)
	local core = Instance.new("Beam")
	core.Name = "LaserCore"
	core.Attachment0 = att0
	core.Attachment1 = att1
	core.Color = ColorSequence.new(laserCoreColor)
	core.LightEmission = 1
	core.LightInfluence = 0
	core.Brightness = 5
	core.Width0 = 0.4
	core.Width1 = 0.8
	core.Segments = 1
	core.FaceCamera = true
	core.Transparency = NumberSequence.new(0.05)
	core.Parent = tip

	-- Impact glow (PointLight at ground level)
	local impactLight = Instance.new("PointLight")
	impactLight.Name = "LaserGlow"
	impactLight.Color = laserColor
	impactLight.Brightness = 2.5
	impactLight.Range = 18
	impactLight.Parent = impact

	-- Impact sparks (ParticleEmitter shooting up from ground)
	local sparks = Instance.new("ParticleEmitter")
	sparks.Name = "LaserSparks"
	sparks.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, laserCoreColor),
		ColorSequenceKeypoint.new(1, laserColor),
	})
	sparks.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.6),
		NumberSequenceKeypoint.new(1, 0.1),
	})
	sparks.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.7, 0.3),
		NumberSequenceKeypoint.new(1, 1),
	})
	sparks.Lifetime = NumberRange.new(0.2, 0.5)
	sparks.Rate = 60
	sparks.Speed = NumberRange.new(8, 16)
	sparks.SpreadAngle = Vector2.new(45, 45)
	sparks.EmissionDirection = Enum.NormalId.Top
	sparks.LightEmission = 1
	sparks.LightInfluence = 0
	sparks.Parent = impact

	model.PrimaryPart = root
	return model
end

return UFO
