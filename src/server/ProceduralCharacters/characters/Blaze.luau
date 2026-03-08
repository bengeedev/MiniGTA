-- Blaze.luau
-- Fire-themed R15 character: dark charcoal body, neon orange extremities,
-- glowing visor, lava crack accents, ember aura, flame trail on feet.

local R15Rig = require(script.Parent.R15Rig)

local Blaze = {}

-- Color palette
local CHARCOAL    = Color3.fromRGB(40, 40, 45)
local DARK_GRAY   = Color3.fromRGB(55, 55, 60)
local EMBER       = Color3.fromRGB(255, 100, 20)
local BRIGHT_FIRE = Color3.fromRGB(255, 170, 30)
local DEEP_RED    = Color3.fromRGB(200, 30, 10)

-- Part styles: core body is dark Slate, extremities gradient to Neon orange
local PART_STYLES = {
	HumanoidRootPart = { color = CHARCOAL,    material = Enum.Material.SmoothPlastic },
	Head             = { color = CHARCOAL,    material = Enum.Material.Slate },
	UpperTorso       = { color = CHARCOAL,    material = Enum.Material.Slate },
	LowerTorso       = { color = DARK_GRAY,   material = Enum.Material.Slate },
	LeftUpperArm     = { color = DARK_GRAY,   material = Enum.Material.Slate },
	LeftLowerArm     = { color = EMBER,       material = Enum.Material.Neon },
	LeftHand         = { color = BRIGHT_FIRE, material = Enum.Material.Neon },
	RightUpperArm    = { color = DARK_GRAY,   material = Enum.Material.Slate },
	RightLowerArm    = { color = EMBER,       material = Enum.Material.Neon },
	RightHand        = { color = BRIGHT_FIRE, material = Enum.Material.Neon },
	LeftUpperLeg     = { color = DARK_GRAY,   material = Enum.Material.Slate },
	LeftLowerLeg     = { color = EMBER,       material = Enum.Material.Neon },
	LeftFoot         = { color = BRIGHT_FIRE, material = Enum.Material.Neon },
	RightUpperLeg    = { color = DARK_GRAY,   material = Enum.Material.Slate },
	RightLowerLeg    = { color = EMBER,       material = Enum.Material.Neon },
	RightFoot        = { color = BRIGHT_FIRE, material = Enum.Material.Neon },
}

-- Helper: create a welded accent part (Neon by default)
local function weldAccent(parent: BasePart, offset: CFrame, size: Vector3, color: Color3, material: Enum.Material?): BasePart
	local accent = Instance.new("Part")
	accent.Name = "Accent"
	accent.Size = size
	accent.Color = color
	accent.Material = material or Enum.Material.Neon
	accent.Anchored = false
	accent.CanCollide = false
	accent.Massless = true
	accent.TopSurface = Enum.SurfaceType.Smooth
	accent.BottomSurface = Enum.SurfaceType.Smooth

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = parent
	weld.Part1 = accent
	weld.Parent = accent

	accent.CFrame = parent.CFrame * offset
	accent.Parent = parent.Parent  -- same model
	return accent
end

-- Helper: create a welded WedgePart accent
local function weldWedge(parent: BasePart, offset: CFrame, size: Vector3, color: Color3, material: Enum.Material?): WedgePart
	local wedge = Instance.new("WedgePart")
	wedge.Name = "Accent"
	wedge.Size = size
	wedge.Color = color
	wedge.Material = material or Enum.Material.Neon
	wedge.Anchored = false
	wedge.CanCollide = false
	wedge.Massless = true
	wedge.TopSurface = Enum.SurfaceType.Smooth
	wedge.BottomSurface = Enum.SurfaceType.Smooth

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = parent
	weld.Part1 = wedge
	weld.Parent = wedge

	wedge.CFrame = parent.CFrame * offset
	wedge.Parent = parent.Parent
	return wedge
end

-- Effects callback: adds visor, lava cracks, particles
local function addEffects(model: Model, parts: { [string]: BasePart })
	local head = parts.Head
	local upperTorso = parts.UpperTorso
	local leftFoot = parts.LeftFoot
	local rightFoot = parts.RightFoot

	-- ============================
	-- HEAD: Flame helmet
	-- ============================

	-- Helmet shell — wraps back and sides of head
	local shell = weldAccent(
		head,
		CFrame.new(0, 0.1, 0.1),
		Vector3.new(1.45, 1.35, 1.1),
		CHARCOAL, Enum.Material.SmoothPlastic
	)
	shell.Name = "HelmetShell"

	-- Brow ridge — aggressive strip above visor
	weldAccent(
		head,
		CFrame.new(0, 0.35, -0.5),
		Vector3.new(1.35, 0.15, 0.35),
		CHARCOAL, Enum.Material.SmoothPlastic
	)

	-- Visor — wide angular slit
	local visor = weldAccent(
		head,
		CFrame.new(0, 0.12, -0.62),
		Vector3.new(1.15, 0.18, 0.05),
		BRIGHT_FIRE
	)
	visor.Name = "Visor"

	-- Visor glow
	local light = Instance.new("PointLight")
	light.Color = BRIGHT_FIRE
	light.Brightness = 1
	light.Range = 8
	light.Parent = visor

	-- Central crest fin — the signature flame spike
	-- WedgePart: slope goes from top-back to bottom-front
	-- Rotated 180° on Y so slope faces forward (aerodynamic)
	weldWedge(
		head,
		CFrame.new(0, 0.95, 0.08) * CFrame.Angles(0, math.rad(180), 0),
		Vector3.new(0.12, 0.9, 0.9),
		EMBER
	)

	-- Secondary crest — shorter wedge behind the main one for depth
	weldWedge(
		head,
		CFrame.new(0, 0.7, 0.35) * CFrame.Angles(0, math.rad(180), 0),
		Vector3.new(0.2, 0.5, 0.55),
		DEEP_RED
	)

	-- Side vents — swept-back accent lines on each temple
	for _, side in ipairs({-1, 1}) do
		weldAccent(
			head,
			CFrame.new(side * 0.68, 0.15, 0.05) * CFrame.Angles(0, 0, side * math.rad(10)),
			Vector3.new(0.06, 0.2, 0.55),
			EMBER
		)
	end

	-- Chin guard — small plate under visor
	weldAccent(
		head,
		CFrame.new(0, -0.3, -0.5),
		Vector3.new(0.8, 0.2, 0.25),
		DARK_GRAY, Enum.Material.SmoothPlastic
	)

	-- Rear exhaust vent glow — neon strip at helmet back
	weldAccent(
		head,
		CFrame.new(0, 0.05, 0.62),
		Vector3.new(0.6, 0.12, 0.05),
		DEEP_RED
	)

	-- ============================
	-- SHOULDERS: Armor pads
	-- ============================
	for _, side in ipairs({-1, 1}) do
		-- Main shoulder plate
		weldAccent(
			parts[side == -1 and "LeftUpperArm" or "RightUpperArm"],
			CFrame.new(side * -0.05, 0.45, 0) * CFrame.Angles(0, 0, side * math.rad(-12)),
			Vector3.new(1.1, 0.25, 1.1),
			CHARCOAL, Enum.Material.SmoothPlastic
		)
		-- Shoulder glow strip
		weldAccent(
			parts[side == -1 and "LeftUpperArm" or "RightUpperArm"],
			CFrame.new(side * -0.1, 0.5, -0.35),
			Vector3.new(0.7, 0.08, 0.08),
			EMBER
		)
	end

	-- ============================
	-- BELT: Accent strip on lower torso
	-- ============================
	weldAccent(
		parts.LowerTorso,
		CFrame.new(0, 0, -0.51),
		Vector3.new(1.8, 0.15, 0.05),
		EMBER
	)
	-- Belt buckle glow
	weldAccent(
		parts.LowerTorso,
		CFrame.new(0, 0, -0.52),
		Vector3.new(0.3, 0.25, 0.04),
		BRIGHT_FIRE
	)

	-- ============================
	-- TORSO: Lava crack accent strips
	-- ============================
	-- Vertical center crack
	weldAccent(
		upperTorso,
		CFrame.new(0, 0, -0.51),          -- front face
		Vector3.new(0.08, 1.4, 0.02),
		EMBER
	)
	-- Diagonal left crack
	weldAccent(
		upperTorso,
		CFrame.new(-0.4, -0.1, -0.51) * CFrame.Angles(0, 0, math.rad(25)),
		Vector3.new(0.06, 0.8, 0.02),
		DEEP_RED
	)
	-- Diagonal right crack
	weldAccent(
		upperTorso,
		CFrame.new(0.4, -0.1, -0.51) * CFrame.Angles(0, 0, math.rad(-25)),
		Vector3.new(0.06, 0.8, 0.02),
		DEEP_RED
	)

	-- Back cracks (mirrored from front)
	weldAccent(
		upperTorso,
		CFrame.new(0, 0, 0.51),
		Vector3.new(0.08, 1.4, 0.02),
		EMBER
	)
	weldAccent(
		upperTorso,
		CFrame.new(-0.4, -0.1, 0.51) * CFrame.Angles(0, 0, math.rad(25)),
		Vector3.new(0.06, 0.8, 0.02),
		DEEP_RED
	)
	weldAccent(
		upperTorso,
		CFrame.new(0.4, -0.1, 0.51) * CFrame.Angles(0, 0, math.rad(-25)),
		Vector3.new(0.06, 0.8, 0.02),
		DEEP_RED
	)

	-- ============================
	-- PARTICLES: Ember aura on torso
	-- ============================
	local emberEmitter = Instance.new("ParticleEmitter")
	emberEmitter.Name = "EmberAura"
	emberEmitter.Rate = 8
	emberEmitter.Lifetime = NumberRange.new(0.6, 1.2)
	emberEmitter.Speed = NumberRange.new(1, 3)
	emberEmitter.SpreadAngle = Vector2.new(30, 30)
	emberEmitter.EmissionDirection = Enum.NormalId.Top
	emberEmitter.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, BRIGHT_FIRE),
		ColorSequenceKeypoint.new(0.5, EMBER),
		ColorSequenceKeypoint.new(1, DEEP_RED),
	})
	emberEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.15),
		NumberSequenceKeypoint.new(1, 0.05),
	})
	emberEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(1, 1),
	})
	emberEmitter.LightEmission = 1
	emberEmitter.LightInfluence = 0
	emberEmitter.Parent = upperTorso

	-- ============================
	-- PARTICLES: Flame trails on feet
	-- ============================
	for _, foot in ipairs({leftFoot, rightFoot}) do
		local flame = Instance.new("ParticleEmitter")
		flame.Name = "FlameTrail"
		flame.Rate = 35
		flame.Lifetime = NumberRange.new(0.3, 0.8)
		flame.Speed = NumberRange.new(1, 4)
		flame.SpreadAngle = Vector2.new(20, 20)
		flame.EmissionDirection = Enum.NormalId.Bottom
		flame.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, BRIGHT_FIRE),
			ColorSequenceKeypoint.new(0.6, EMBER),
			ColorSequenceKeypoint.new(1, DEEP_RED),
		})
		flame.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(0.5, 0.25),
			NumberSequenceKeypoint.new(1, 0),
		})
		flame.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.7, 0.5),
			NumberSequenceKeypoint.new(1, 1),
		})
		flame.LightEmission = 1
		flame.LightInfluence = 0
		flame.Parent = foot

		-- Fire ribbon trail
		local attach0 = Instance.new("Attachment")
		attach0.Name = "TrailTop"
		attach0.Position = Vector3.new(0, 0.3, 0)
		attach0.Parent = foot

		local attach1 = Instance.new("Attachment")
		attach1.Name = "TrailBottom"
		attach1.Position = Vector3.new(0, -0.3, 0)
		attach1.Parent = foot

		local trail = Instance.new("Trail")
		trail.Name = "FireTrail"
		trail.Attachment0 = attach0
		trail.Attachment1 = attach1
		trail.Lifetime = 0.4
		trail.MinLength = 0.1
		trail.FaceCamera = true
		trail.LightEmission = 1
		trail.LightInfluence = 0
		trail.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, BRIGHT_FIRE),
			ColorSequenceKeypoint.new(0.4, EMBER),
			ColorSequenceKeypoint.new(1, DEEP_RED),
		})
		trail.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.5, 0.3),
			NumberSequenceKeypoint.new(1, 1),
		})
		trail.WidthScale = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, 0.6),
			NumberSequenceKeypoint.new(1, 0),
		})
		trail.Parent = foot
	end
end

function Blaze.build(): Model
	return R15Rig.build({
		name = "Blaze",
		partStyles = PART_STYLES,
		addEffects = addEffects,
	})
end

return Blaze
