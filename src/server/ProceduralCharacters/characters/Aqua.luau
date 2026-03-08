-- Aqua.luau
-- Water / Ocean themed R15 character: smooth dark shell pushed back with
-- wide dive-mask visor, asymmetric coral branches growing from LEFT side,
-- flowing current line torso pattern, thin dorsal fin ridge on back,
-- water spray particles, and a swelling wave-shaped trail.

local R15Rig = require(script.Parent.R15Rig)

local Aqua = {}

-- Color palette
local OCEAN_BLUE  = Color3.fromRGB(30, 100, 180)  -- deep ocean core
local SEAFOAM     = Color3.fromRGB(120, 220, 200) -- light foam/spray highlight
local ABYSS_DARK  = Color3.fromRGB(15, 40, 70)    -- deep water shadow
local CORAL_PINK  = Color3.fromRGB(230, 120, 100)  -- living coral accent
local PEARL_WHITE = Color3.fromRGB(220, 230, 240)  -- foam/pearl secondary

-- Part styles: dark head (shell covers) → Glass core → Foil shimmer limbs → Neon extremities
local PART_STYLES = {
	HumanoidRootPart = { color = ABYSS_DARK,  material = Enum.Material.SmoothPlastic },
	Head             = { color = ABYSS_DARK,  material = Enum.Material.SmoothPlastic },
	UpperTorso       = { color = OCEAN_BLUE,  material = Enum.Material.Glass },
	LowerTorso       = { color = OCEAN_BLUE,  material = Enum.Material.Glass },
	LeftUpperArm     = { color = OCEAN_BLUE,  material = Enum.Material.Glass },
	LeftLowerArm     = { color = ABYSS_DARK,  material = Enum.Material.Foil },
	LeftHand         = { color = SEAFOAM,     material = Enum.Material.Neon },
	RightUpperArm    = { color = OCEAN_BLUE,  material = Enum.Material.Glass },
	RightLowerArm    = { color = ABYSS_DARK,  material = Enum.Material.Foil },
	RightHand        = { color = SEAFOAM,     material = Enum.Material.Neon },
	LeftUpperLeg     = { color = OCEAN_BLUE,  material = Enum.Material.Glass },
	LeftLowerLeg     = { color = ABYSS_DARK,  material = Enum.Material.Foil },
	LeftFoot         = { color = OCEAN_BLUE,  material = Enum.Material.Neon },
	RightUpperLeg    = { color = OCEAN_BLUE,  material = Enum.Material.Glass },
	RightLowerLeg    = { color = ABYSS_DARK,  material = Enum.Material.Foil },
	RightFoot        = { color = OCEAN_BLUE,  material = Enum.Material.Neon },
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

-- Effects callback
local function addEffects(model: Model, parts: { [string]: BasePart })
	local head = parts.Head
	local upperTorso = parts.UpperTorso
	local leftFoot = parts.LeftFoot
	local rightFoot = parts.RightFoot

	-- ============================
	-- HEAD: Coral Crown Helm
	-- ============================

	-- Helmet shell — wraps back and sides (same proven geometry as Blaze/Glacier/Volt)
	local shell = weldAccent(
		head,
		CFrame.new(0, 0.1, 0.1),
		Vector3.new(1.45, 1.35, 1.1),
		ABYSS_DARK, Enum.Material.SmoothPlastic
	)
	shell.Name = "HelmetShell"

	-- Brow ridge — smooth Glass bar above visor
	weldAccent(
		head,
		CFrame.new(0, 0.35, -0.5),
		Vector3.new(1.35, 0.15, 0.35),
		OCEAN_BLUE, Enum.Material.Glass
	)

	-- Visor — wide dive-mask band (wider+taller than other characters)
	local visor = weldAccent(
		head,
		CFrame.new(0, 0.12, -0.62),
		Vector3.new(1.0, 0.22, 0.05),
		SEAFOAM
	)
	visor.Name = "Visor"

	local visorLight = Instance.new("PointLight")
	visorLight.Color = SEAFOAM
	visorLight.Brightness = 1
	visorLight.Range = 8
	visorLight.Parent = visor

	-- Chin guard — smooth plate under visor
	weldAccent(
		head,
		CFrame.new(0, -0.3, -0.5),
		Vector3.new(0.8, 0.2, 0.25),
		ABYSS_DARK, Enum.Material.SmoothPlastic
	)

	-- Coral branch growth on LEFT — signature asymmetric silhouette
	-- Main branch (tall, growing upward-outward)
	weldWedge(
		head,
		CFrame.new(-0.5, 0.85, -0.05) * CFrame.Angles(math.rad(-5), 0, math.rad(12)),
		Vector3.new(0.14, 0.7, 0.2),
		CORAL_PINK, Enum.Material.SmoothPlastic
	)

	-- Sub-branch (shorter, angled further outward)
	weldWedge(
		head,
		CFrame.new(-0.65, 0.75, 0.15) * CFrame.Angles(math.rad(10), math.rad(15), math.rad(25)),
		Vector3.new(0.1, 0.45, 0.14),
		CORAL_PINK, Enum.Material.SmoothPlastic
	)

	-- Rear vent glow — seafoam strip at helmet back
	weldAccent(
		head,
		CFrame.new(0, 0.05, 0.62),
		Vector3.new(0.5, 0.1, 0.05),
		SEAFOAM
	)

	-- ============================
	-- SHOULDERS: Smooth Wave Plates
	-- ============================
	for _, side in ipairs({-1, 1}) do
		local arm = parts[side == -1 and "LeftUpperArm" or "RightUpperArm"]

		-- Smooth glass shoulder plate
		weldAccent(
			arm,
			CFrame.new(side * -0.05, 0.45, 0) * CFrame.Angles(0, 0, side * math.rad(-12)),
			Vector3.new(1.1, 0.25, 1.1),
			OCEAN_BLUE, Enum.Material.Glass
		)

		-- Seafoam glow strip on front edge
		weldAccent(
			arm,
			CFrame.new(side * -0.1, 0.5, -0.35),
			Vector3.new(0.7, 0.08, 0.08),
			SEAFOAM
		)
	end

	-- ============================
	-- TORSO: Flowing Current Lines
	-- ============================

	-- Front: center vertical current + 2 gentle diagonals
	weldAccent(
		upperTorso,
		CFrame.new(0, 0, -0.51),
		Vector3.new(0.08, 1.4, 0.02),
		SEAFOAM
	)
	weldAccent(
		upperTorso,
		CFrame.new(-0.35, -0.1, -0.51) * CFrame.Angles(0, 0, math.rad(12)),
		Vector3.new(0.06, 0.8, 0.02),
		OCEAN_BLUE
	)
	weldAccent(
		upperTorso,
		CFrame.new(0.35, -0.1, -0.51) * CFrame.Angles(0, 0, math.rad(-15)),
		Vector3.new(0.06, 0.8, 0.02),
		OCEAN_BLUE
	)

	-- Back: mirrored current lines
	weldAccent(
		upperTorso,
		CFrame.new(0, 0, 0.51),
		Vector3.new(0.08, 1.4, 0.02),
		SEAFOAM
	)
	weldAccent(
		upperTorso,
		CFrame.new(-0.35, -0.1, 0.51) * CFrame.Angles(0, 0, math.rad(12)),
		Vector3.new(0.06, 0.8, 0.02),
		OCEAN_BLUE
	)
	weldAccent(
		upperTorso,
		CFrame.new(0.35, -0.1, 0.51) * CFrame.Angles(0, 0, math.rad(-15)),
		Vector3.new(0.06, 0.8, 0.02),
		OCEAN_BLUE
	)

	-- Back: Dorsal fin ridge — thinner/sleeker than Glacier's chunky spine crystal
	-- Main fin
	weldWedge(
		upperTorso,
		CFrame.new(0, 0.5, 0.58) * CFrame.Angles(math.rad(-10), math.rad(180), 0),
		Vector3.new(0.1, 0.65, 0.4),
		OCEAN_BLUE, Enum.Material.Glass
	)
	-- Secondary fin (shorter, lower)
	weldWedge(
		upperTorso,
		CFrame.new(0, 0.0, 0.55) * CFrame.Angles(math.rad(-5), math.rad(180), 0),
		Vector3.new(0.14, 0.35, 0.3),
		ABYSS_DARK, Enum.Material.Glass
	)

	-- ============================
	-- BELT: Current Strip + Pearl Buckle
	-- ============================
	weldAccent(
		parts.LowerTorso,
		CFrame.new(0, 0, -0.51),
		Vector3.new(1.8, 0.15, 0.05),
		OCEAN_BLUE
	)
	weldAccent(
		parts.LowerTorso,
		CFrame.new(0, 0, -0.52),
		Vector3.new(0.3, 0.25, 0.04),
		PEARL_WHITE
	)

	-- ============================
	-- PARTICLES: Bubble aura on torso
	-- ============================
	local bubbleAura = Instance.new("ParticleEmitter")
	bubbleAura.Name = "BubbleAura"
	bubbleAura.Rate = 6
	bubbleAura.Lifetime = NumberRange.new(0.6, 1.2)
	bubbleAura.Speed = NumberRange.new(0.5, 1.5)
	bubbleAura.SpreadAngle = Vector2.new(30, 30)
	bubbleAura.EmissionDirection = Enum.NormalId.Top
	bubbleAura.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, SEAFOAM),
		ColorSequenceKeypoint.new(0.5, PEARL_WHITE),
		ColorSequenceKeypoint.new(1, OCEAN_BLUE),
	})
	bubbleAura.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.15),
		NumberSequenceKeypoint.new(1, 0.05),
	})
	bubbleAura.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(1, 1),
	})
	bubbleAura.LightEmission = 0.5
	bubbleAura.LightInfluence = 0
	bubbleAura.Parent = upperTorso

	-- ============================
	-- FEET: Water spray + wave trail
	-- ============================
	for _, foot in ipairs({leftFoot, rightFoot}) do

		-- Water spray particles (mirrors Blaze's flame trail pattern)
		local spray = Instance.new("ParticleEmitter")
		spray.Name = "WaterSpray"
		spray.Rate = 20
		spray.Lifetime = NumberRange.new(0.3, 0.8)
		spray.Speed = NumberRange.new(1, 3)
		spray.SpreadAngle = Vector2.new(20, 20)
		spray.EmissionDirection = Enum.NormalId.Bottom
		spray.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, SEAFOAM),
			ColorSequenceKeypoint.new(0.6, OCEAN_BLUE),
			ColorSequenceKeypoint.new(1, ABYSS_DARK),
		})
		spray.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.4),
			NumberSequenceKeypoint.new(0.5, 0.2),
			NumberSequenceKeypoint.new(1, 0),
		})
		spray.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.7, 0.5),
			NumberSequenceKeypoint.new(1, 1),
		})
		spray.LightEmission = 0.5
		spray.LightInfluence = 0
		spray.Parent = foot

		-- Wave trail — swells in middle then tapers (wave shape)
		local attach0 = Instance.new("Attachment")
		attach0.Name = "TrailTop"
		attach0.Position = Vector3.new(0, 0.3, 0)
		attach0.Parent = foot

		local attach1 = Instance.new("Attachment")
		attach1.Name = "TrailBottom"
		attach1.Position = Vector3.new(0, -0.3, 0)
		attach1.Parent = foot

		local trail = Instance.new("Trail")
		trail.Name = "WaterTrail"
		trail.Attachment0 = attach0
		trail.Attachment1 = attach1
		trail.Lifetime = 0.6
		trail.MinLength = 0.1
		trail.FaceCamera = true
		trail.LightEmission = 0.5
		trail.LightInfluence = 0
		trail.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, SEAFOAM),
			ColorSequenceKeypoint.new(0.4, OCEAN_BLUE),
			ColorSequenceKeypoint.new(1, ABYSS_DARK),
		})
		trail.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.5, 0.3),
			NumberSequenceKeypoint.new(1, 1),
		})
		trail.WidthScale = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.8),
			NumberSequenceKeypoint.new(0.3, 1.3),
			NumberSequenceKeypoint.new(1, 0.3),
		})
		trail.Parent = foot
	end
end

function Aqua.build(): Model
	return R15Rig.build({
		name = "Aqua",
		partStyles = PART_STYLES,
		addEffects = addEffects,
	})
end

return Aqua
