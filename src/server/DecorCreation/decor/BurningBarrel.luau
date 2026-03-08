-- BurningBarrel.luau
-- Rusty oil drum with fire coming out the top. Classic urban/industrial obstacle.

local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local BurningBarrel = {}

function BurningBarrel.create(x, z, scale, offsetY)
	scale = scale or 1
	offsetY = offsetY or 0
	local baseY = DecorUtils.TERRAIN_TOP + offsetY

	local barrelH = 4 * scale
	local barrelR = 1.5 * scale

	local model = Instance.new("Model")
	model.Name = "BurningBarrel"

	-- Barrel body (cylinder on its side → rotate upright)
	local barrel = Instance.new("Part")
	barrel.Name = "Barrel"
	barrel.Shape = Enum.PartType.Cylinder
	barrel.Size = Vector3.new(barrelH, barrelR * 2, barrelR * 2)
	barrel.CFrame = CFrame.new(x, baseY + barrelH / 2, z)
		* CFrame.Angles(0, 0, math.rad(90))  -- stand upright
	barrel.Anchored = true
	barrel.CanCollide = true
	barrel.Material = Enum.Material.CorrodedMetal
	barrel.Color = Color3.fromRGB(60, 45, 30)
	barrel.Parent = model

	-- Rust ring near top
	local ring = Instance.new("Part")
	ring.Name = "Ring"
	ring.Shape = Enum.PartType.Cylinder
	ring.Size = Vector3.new(0.3 * scale, barrelR * 2 + 0.2, barrelR * 2 + 0.2)
	ring.CFrame = CFrame.new(x, baseY + barrelH - 0.3 * scale, z)
		* CFrame.Angles(0, 0, math.rad(90))
	ring.Anchored = true
	ring.CanCollide = false
	ring.Material = Enum.Material.Metal
	ring.Color = Color3.fromRGB(45, 40, 35)
	ring.Parent = model

	-- Rust ring near bottom
	local ring2 = Instance.new("Part")
	ring2.Name = "Ring2"
	ring2.Shape = Enum.PartType.Cylinder
	ring2.Size = Vector3.new(0.3 * scale, barrelR * 2 + 0.2, barrelR * 2 + 0.2)
	ring2.CFrame = CFrame.new(x, baseY + 0.3 * scale, z)
		* CFrame.Angles(0, 0, math.rad(90))
	ring2.Anchored = true
	ring2.CanCollide = false
	ring2.Material = Enum.Material.Metal
	ring2.Color = Color3.fromRGB(45, 40, 35)
	ring2.Parent = model

	-- Dark interior (top opening)
	local opening = Instance.new("Part")
	opening.Name = "Opening"
	opening.Shape = Enum.PartType.Cylinder
	opening.Size = Vector3.new(0.1, barrelR * 1.6, barrelR * 1.6)
	opening.CFrame = CFrame.new(x, baseY + barrelH + 0.05, z)
		* CFrame.Angles(0, 0, math.rad(90))
	opening.Anchored = true
	opening.CanCollide = false
	opening.Material = Enum.Material.SmoothPlastic
	opening.Color = Color3.fromRGB(15, 10, 5)
	opening.Parent = model

	-- Fire emitter (attached to opening)
	local fire = Instance.new("ParticleEmitter")
	fire.Rate = 40
	fire.Lifetime = NumberRange.new(0.3, 0.8)
	fire.Speed = NumberRange.new(4, 8)
	fire.SpreadAngle = Vector2.new(12, 12)
	fire.EmissionDirection = Enum.NormalId.Top
	fire.LightEmission = 1
	fire.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 50)),
		ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 100, 20)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 20, 5)),
	})
	fire.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5 * scale),
		NumberSequenceKeypoint.new(0.3, 1.8 * scale),
		NumberSequenceKeypoint.new(1, 0.2 * scale),
	})
	fire.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.5, 0.4),
		NumberSequenceKeypoint.new(1, 1),
	})
	fire.Parent = opening

	-- Smoke emitter (above fire)
	local smoke = Instance.new("ParticleEmitter")
	smoke.Rate = 15
	smoke.Lifetime = NumberRange.new(1.0, 2.0)
	smoke.Speed = NumberRange.new(2, 5)
	smoke.SpreadAngle = Vector2.new(20, 20)
	smoke.EmissionDirection = Enum.NormalId.Top
	smoke.LightEmission = 0
	smoke.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 45, 40)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 30)),
	})
	smoke.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.8 * scale),
		NumberSequenceKeypoint.new(1, 3.0 * scale),
	})
	smoke.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(1, 1),
	})
	smoke.Parent = opening

	-- Warm fire glow
	local glow = Instance.new("PointLight")
	glow.Color = Color3.fromRGB(255, 140, 40)
	glow.Brightness = 2
	glow.Range = 12 * scale
	glow.Shadows = true
	glow.Parent = opening

	model.PrimaryPart = barrel
	model.Parent = DecorUtils.decorFolder
	return model
end

return BurningBarrel
