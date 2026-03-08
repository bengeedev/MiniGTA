-- Terra.luau
-- Earth / Crystal themed R15 character: stone helm with asymmetric amber crystal
-- growths, chunky rock pauldrons with moss accents, cracked chest plate with
-- glowing vein lines, spine crystal cluster, and a unique CRUMBLING EARTH trail
-- that drops heavy debris behind the character.

local R15Rig = require(script.Parent.R15Rig)

local Terra = {}

-- Color palette
local EARTH_BROWN    = Color3.fromRGB(100, 70, 40)   -- warm brown stone core
local DEEP_STONE     = Color3.fromRGB(60, 50, 35)    -- dark rock base tone
local AMBER_CRYSTAL  = Color3.fromRGB(220, 170, 50)  -- golden crystal glow
local JADE_GREEN     = Color3.fromRGB(60, 160, 80)   -- moss/mineral green accents
local GRANITE_GRAY   = Color3.fromRGB(130, 120, 110) -- neutral stone secondary

-- Part styles: rough stone head → slate core → cobblestone crumbling limbs → neon extremities
local PART_STYLES = {
	HumanoidRootPart = { color = EARTH_BROWN,    material = Enum.Material.Slate },
	Head             = { color = EARTH_BROWN,    material = Enum.Material.Slate },
	UpperTorso       = { color = EARTH_BROWN,    material = Enum.Material.Slate },
	LowerTorso       = { color = DEEP_STONE,     material = Enum.Material.Slate },
	LeftUpperArm     = { color = EARTH_BROWN,    material = Enum.Material.Slate },
	LeftLowerArm     = { color = GRANITE_GRAY,   material = Enum.Material.Cobblestone },
	LeftHand         = { color = AMBER_CRYSTAL,  material = Enum.Material.Neon },
	RightUpperArm    = { color = EARTH_BROWN,    material = Enum.Material.Slate },
	RightLowerArm    = { color = GRANITE_GRAY,   material = Enum.Material.Cobblestone },
	RightHand        = { color = AMBER_CRYSTAL,  material = Enum.Material.Neon },
	LeftUpperLeg     = { color = EARTH_BROWN,    material = Enum.Material.Slate },
	LeftLowerLeg     = { color = GRANITE_GRAY,   material = Enum.Material.Cobblestone },
	LeftFoot         = { color = JADE_GREEN,     material = Enum.Material.Neon },
	RightUpperLeg    = { color = EARTH_BROWN,    material = Enum.Material.Slate },
	RightLowerLeg    = { color = GRANITE_GRAY,   material = Enum.Material.Cobblestone },
	RightFoot        = { color = JADE_GREEN,     material = Enum.Material.Neon },
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

-- Effects callback: adds stone helm with crystal spikes, rock pauldrons, cracked
-- chest with glowing veins, spine crystal cluster, rocky gauntlets, stone belt,
-- crumbling earth trails, rock debris + crystal dust particles
local function addEffects(model: Model, parts: { [string]: BasePart })
	local head = parts.Head
	local upperTorso = parts.UpperTorso
	local lowerTorso = parts.LowerTorso
	local leftFoot = parts.LeftFoot
	local rightFoot = parts.RightFoot

	-- ============================
	-- HEAD: Stone Helm with Crystal Growth
	-- ============================

	-- Thick helm shell wrapping the head
	weldAccent(
		head,
		CFrame.new(0, 0.2, 0),
		Vector3.new(1.4, 0.9, 1.3),
		DEEP_STONE, Enum.Material.SmoothPlastic
	)

	-- Brow ridge — horizontal bar across forehead
	weldAccent(
		head,
		CFrame.new(0, 0.25, -0.55),
		Vector3.new(1.3, 0.2, 0.25),
		GRANITE_GRAY, Enum.Material.Cobblestone
	)

	-- Asymmetric crystal spikes — RIGHT side only (distinct from Glacier's symmetric crown)
	-- Spike 1: tall main crystal
	weldWedge(
		head,
		CFrame.new(0.45, 0.7, -0.1) * CFrame.Angles(math.rad(-10), 0, math.rad(-15)),
		Vector3.new(0.18, 0.7, 0.2),
		AMBER_CRYSTAL, Enum.Material.Glass
	)

	-- Spike 2: shorter crystal angled outward
	weldWedge(
		head,
		CFrame.new(0.55, 0.5, 0.15) * CFrame.Angles(math.rad(5), math.rad(20), math.rad(-25)),
		Vector3.new(0.14, 0.45, 0.16),
		AMBER_CRYSTAL, Enum.Material.Glass
	)

	-- Spike 3: small crystal nub behind the others
	weldAccent(
		head,
		CFrame.new(0.35, 0.55, 0.3) * CFrame.Angles(0, 0, math.rad(-10)),
		Vector3.new(0.12, 0.3, 0.12),
		AMBER_CRYSTAL, Enum.Material.Glass
	)

	-- Narrow visor slit — glowing amber gaze
	local visor = weldAccent(
		head,
		CFrame.new(0, 0.05, -0.62),
		Vector3.new(0.8, 0.12, 0.06),
		AMBER_CRYSTAL
	)
	visor.Name = "Visor"

	local visorLight = Instance.new("PointLight")
	visorLight.Color = AMBER_CRYSTAL
	visorLight.Brightness = 2.0
	visorLight.Range = 8
	visorLight.Parent = visor

	-- Jaw guard plate below visor
	weldAccent(
		head,
		CFrame.new(0, -0.25, -0.55),
		Vector3.new(1.0, 0.35, 0.2),
		DEEP_STONE, Enum.Material.SmoothPlastic
	)

	-- ============================
	-- SHOULDERS: Rock Pauldrons
	-- ============================
	for _, side in ipairs({-1, 1}) do
		local arm = parts[side == -1 and "LeftUpperArm" or "RightUpperArm"]

		-- Chunky rectangular shoulder plate
		weldAccent(
			arm,
			CFrame.new(side * 0.15, 0.4, 0),
			Vector3.new(1.4, 0.3, 1.2),
			EARTH_BROWN, Enum.Material.Cobblestone
		)

		-- Small embedded crystal shard
		weldWedge(
			arm,
			CFrame.new(side * 0.3, 0.6, 0) * CFrame.Angles(0, 0, side * math.rad(-20)),
			Vector3.new(0.1, 0.25, 0.12),
			AMBER_CRYSTAL, Enum.Material.Glass
		)

		-- Moss tuft accent on top
		weldAccent(
			arm,
			CFrame.new(side * -0.1, 0.58, 0.2),
			Vector3.new(0.4, 0.12, 0.35),
			JADE_GREEN, Enum.Material.SmoothPlastic
		)
	end

	-- ============================
	-- TORSO: Cracked Stone with Glowing Veins
	-- ============================

	-- Front chest plate
	weldAccent(
		upperTorso,
		CFrame.new(0, 0, -0.56),
		Vector3.new(1.6, 1.0, 0.1),
		GRANITE_GRAY, Enum.Material.Cobblestone
	)

	-- Glowing vein line 1 — diagonal crack upper left to center
	weldAccent(
		upperTorso,
		CFrame.new(-0.2, 0.2, -0.62) * CFrame.Angles(0, 0, math.rad(25)),
		Vector3.new(0.7, 0.06, 0.04),
		AMBER_CRYSTAL
	)

	-- Glowing vein line 2 — diagonal crack upper right to center
	weldAccent(
		upperTorso,
		CFrame.new(0.15, 0.05, -0.62) * CFrame.Angles(0, 0, math.rad(-30)),
		Vector3.new(0.6, 0.06, 0.04),
		AMBER_CRYSTAL
	)

	-- Glowing vein line 3 — horizontal crack lower chest
	weldAccent(
		upperTorso,
		CFrame.new(0, -0.25, -0.62) * CFrame.Angles(0, 0, math.rad(8)),
		Vector3.new(0.5, 0.05, 0.04),
		AMBER_CRYSTAL
	)

	-- Back: Large crystal cluster growing out of spine (like a geode breaking through)
	-- Main crystal
	weldWedge(
		upperTorso,
		CFrame.new(0, 0.15, 0.6) * CFrame.Angles(math.rad(10), 0, 0),
		Vector3.new(0.3, 0.8, 0.35),
		AMBER_CRYSTAL, Enum.Material.Glass
	)

	-- Side crystal left
	weldWedge(
		upperTorso,
		CFrame.new(-0.25, 0.05, 0.55) * CFrame.Angles(math.rad(15), math.rad(-15), math.rad(20)),
		Vector3.new(0.2, 0.5, 0.25),
		AMBER_CRYSTAL, Enum.Material.Glass
	)

	-- Side crystal right
	weldWedge(
		upperTorso,
		CFrame.new(0.2, -0.05, 0.55) * CFrame.Angles(math.rad(5), math.rad(10), math.rad(-15)),
		Vector3.new(0.18, 0.45, 0.2),
		AMBER_CRYSTAL, Enum.Material.Glass
	)

	-- Small moss patch on lower back
	weldAccent(
		lowerTorso,
		CFrame.new(0.15, 0, 0.53),
		Vector3.new(0.5, 0.3, 0.08),
		JADE_GREEN, Enum.Material.SmoothPlastic
	)

	-- ============================
	-- ARMS: Rocky Gauntlet Bracers
	-- ============================
	for _, side in ipairs({-1, 1}) do
		local lowerArm = parts[side == -1 and "LeftLowerArm" or "RightLowerArm"]

		-- Chunky bracer — wider than arm
		weldAccent(
			lowerArm,
			CFrame.new(0, 0, 0),
			Vector3.new(1.2, 0.7, 1.2),
			EARTH_BROWN, Enum.Material.Cobblestone
		)

		-- Small amber crystal embedded in bracer
		weldAccent(
			lowerArm,
			CFrame.new(side * 0.5, 0.05, -0.15),
			Vector3.new(0.1, 0.15, 0.1),
			AMBER_CRYSTAL, Enum.Material.Glass
		)
	end

	-- ============================
	-- BELT: Stone Band + Crystal Buckle
	-- ============================

	-- Stone belt band front
	weldAccent(
		lowerTorso,
		CFrame.new(0, 0.15, -0.52),
		Vector3.new(1.8, 0.3, 0.1),
		DEEP_STONE, Enum.Material.Cobblestone
	)

	-- Stone belt band back
	weldAccent(
		lowerTorso,
		CFrame.new(0, 0.15, 0.52),
		Vector3.new(1.8, 0.3, 0.1),
		DEEP_STONE, Enum.Material.Cobblestone
	)

	-- Amber buckle crystal centered on front belt
	weldAccent(
		lowerTorso,
		CFrame.new(0, 0.15, -0.58),
		Vector3.new(0.25, 0.25, 0.1),
		AMBER_CRYSTAL, Enum.Material.Glass
	)

	-- Hanging rock chunk on right hip
	weldAccent(
		lowerTorso,
		CFrame.new(0.7, -0.2, 0),
		Vector3.new(0.25, 0.4, 0.2),
		GRANITE_GRAY, Enum.Material.Cobblestone
	)

	-- ============================
	-- PARTICLES: Crystal dust drifting upward on torso
	-- ============================
	local crystalDust = Instance.new("ParticleEmitter")
	crystalDust.Name = "CrystalDust"
	crystalDust.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	crystalDust.Rate = 3
	crystalDust.Lifetime = NumberRange.new(1.5, 2.5)
	crystalDust.Speed = NumberRange.new(0.2, 0.5)
	crystalDust.SpreadAngle = Vector2.new(50, 50)
	crystalDust.EmissionDirection = Enum.NormalId.Top
	crystalDust.Drag = 2
	crystalDust.RotSpeed = NumberRange.new(-20, 20)
	crystalDust.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, AMBER_CRYSTAL),
		ColorSequenceKeypoint.new(0.5, JADE_GREEN),
		ColorSequenceKeypoint.new(1, DEEP_STONE),
	})
	crystalDust.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.15),
		NumberSequenceKeypoint.new(0.5, 0.12),
		NumberSequenceKeypoint.new(1, 0.04),
	})
	crystalDust.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(0.5, 0.4),
		NumberSequenceKeypoint.new(1, 1),
	})
	crystalDust.LightEmission = 0.5
	crystalDust.LightInfluence = 0
	crystalDust.Parent = upperTorso

	-- ============================
	-- FEET: Rock debris + crumbling earth trails
	-- ============================
	for _, foot in ipairs({leftFoot, rightFoot}) do

		-- Rock debris particles — brown chunks drifting DOWN with gravity
		local debris = Instance.new("ParticleEmitter")
		debris.Name = "RockDebris"
		debris.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		debris.Rate = 6
		debris.Lifetime = NumberRange.new(0.8, 1.5)
		debris.Speed = NumberRange.new(0.5, 1.5)
		debris.SpreadAngle = Vector2.new(40, 40)
		debris.EmissionDirection = Enum.NormalId.Bottom
		debris.Drag = 1
		debris.Acceleration = Vector3.new(0, -4, 0)
		debris.RotSpeed = NumberRange.new(-40, 40)
		debris.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, EARTH_BROWN),
			ColorSequenceKeypoint.new(0.5, GRANITE_GRAY),
			ColorSequenceKeypoint.new(1, DEEP_STONE),
		})
		debris.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.25),
			NumberSequenceKeypoint.new(0.3, 0.2),
			NumberSequenceKeypoint.new(1, 0.08),
		})
		debris.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.1),
			NumberSequenceKeypoint.new(0.5, 0.3),
			NumberSequenceKeypoint.new(1, 1),
		})
		debris.LightEmission = 0
		debris.LightInfluence = 0.5
		debris.Parent = foot

		-- Trail attachments (shared by both trail layers)
		local attachTop = Instance.new("Attachment")
		attachTop.Name = "TrailTop"
		attachTop.Position = Vector3.new(0, 0.5, 0)
		attachTop.Parent = foot

		local attachBottom = Instance.new("Attachment")
		attachBottom.Name = "TrailBottom"
		attachBottom.Position = Vector3.new(0, -0.5, 0)
		attachBottom.Parent = foot

		-- Layer 1: Outer debris trail — opaque earth, crumbles apart
		-- WidthScale 1.0 → 0.5 → 0.2 (breaks apart / narrows as debris falls away)
		local outerTrail = Instance.new("Trail")
		outerTrail.Name = "EarthTrailOuter"
		outerTrail.Attachment0 = attachTop
		outerTrail.Attachment1 = attachBottom
		outerTrail.Lifetime = 0.6
		outerTrail.MinLength = 0.1
		outerTrail.FaceCamera = true
		outerTrail.LightEmission = 0
		outerTrail.LightInfluence = 0.5
		outerTrail.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, EARTH_BROWN),
			ColorSequenceKeypoint.new(0.4, GRANITE_GRAY),
			ColorSequenceKeypoint.new(1, DEEP_STONE),
		})
		outerTrail.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.05),
			NumberSequenceKeypoint.new(0.3, 0.15),
			NumberSequenceKeypoint.new(0.7, 0.5),
			NumberSequenceKeypoint.new(1, 1),
		})
		outerTrail.WidthScale = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1.0),
			NumberSequenceKeypoint.new(0.3, 0.7),
			NumberSequenceKeypoint.new(0.7, 0.5),
			NumberSequenceKeypoint.new(1, 0.2),
		})
		outerTrail.Parent = foot

		-- Layer 2: Inner crystal vein glow — bright cracks in the trail
		local innerAttachTop = Instance.new("Attachment")
		innerAttachTop.Name = "InnerTrailTop"
		innerAttachTop.Position = Vector3.new(0, 0.3, 0)
		innerAttachTop.Parent = foot

		local innerAttachBottom = Instance.new("Attachment")
		innerAttachBottom.Name = "InnerTrailBottom"
		innerAttachBottom.Position = Vector3.new(0, -0.3, 0)
		innerAttachBottom.Parent = foot

		local innerTrail = Instance.new("Trail")
		innerTrail.Name = "EarthTrailInner"
		innerTrail.Attachment0 = innerAttachTop
		innerTrail.Attachment1 = innerAttachBottom
		innerTrail.Lifetime = 0.4
		innerTrail.MinLength = 0.1
		innerTrail.FaceCamera = true
		innerTrail.LightEmission = 1
		innerTrail.LightInfluence = 0
		innerTrail.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, AMBER_CRYSTAL),
			ColorSequenceKeypoint.new(0.5, JADE_GREEN),
			ColorSequenceKeypoint.new(1, DEEP_STONE),
		})
		innerTrail.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.3, 0.15),
			NumberSequenceKeypoint.new(0.7, 0.5),
			NumberSequenceKeypoint.new(1, 1),
		})
		innerTrail.WidthScale = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.4),
			NumberSequenceKeypoint.new(0.3, 0.3),
			NumberSequenceKeypoint.new(0.7, 0.15),
			NumberSequenceKeypoint.new(1, 0.05),
		})
		innerTrail.Parent = foot
	end
end

function Terra.build(): Model
	return R15Rig.build({
		name = "Terra",
		partStyles = PART_STYLES,
		addEffects = addEffects,
	})
end

return Terra
