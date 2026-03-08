-- Shadow.luau
-- Phantom / Ghost themed R15 character: void-black hooded cowl with diamond
-- eyes, tattered shoulder mantle, chest void rift with spectral chains,
-- wraith arm bands, spectral belt, and a unique EXPANDING dark trail that
-- spreads behind the character instead of tapering.

local R15Rig = require(script.Parent.R15Rig)

local Shadow = {}

-- Color palette
local VOID_BLACK      = Color3.fromRGB(15, 10, 20)    -- near-black core
local SHADOW_GRAY     = Color3.fromRGB(45, 40, 55)    -- dark smoky mid-tone
local PHANTOM_VIOLET  = Color3.fromRGB(100, 50, 160)  -- ghostly purple accents
local WISP_GREEN      = Color3.fromRGB(80, 220, 140)  -- spectral green glow
local SMOKE_ASH       = Color3.fromRGB(90, 85, 95)    -- muted ash secondary

-- Part styles: featureless dark head → slate core → glass translucent limbs → neon extremities
local PART_STYLES = {
	HumanoidRootPart = { color = VOID_BLACK,      material = Enum.Material.SmoothPlastic },
	Head             = { color = VOID_BLACK,      material = Enum.Material.SmoothPlastic },
	UpperTorso       = { color = SHADOW_GRAY,     material = Enum.Material.Slate },
	LowerTorso       = { color = SHADOW_GRAY,     material = Enum.Material.Slate },
	LeftUpperArm     = { color = SHADOW_GRAY,     material = Enum.Material.Slate },
	LeftLowerArm     = { color = SHADOW_GRAY,     material = Enum.Material.Glass },
	LeftHand         = { color = WISP_GREEN,      material = Enum.Material.Neon },
	RightUpperArm    = { color = SHADOW_GRAY,     material = Enum.Material.Slate },
	RightLowerArm    = { color = SHADOW_GRAY,     material = Enum.Material.Glass },
	RightHand        = { color = WISP_GREEN,      material = Enum.Material.Neon },
	LeftUpperLeg     = { color = SHADOW_GRAY,     material = Enum.Material.Slate },
	LeftLowerLeg     = { color = SHADOW_GRAY,     material = Enum.Material.Glass },
	LeftFoot         = { color = PHANTOM_VIOLET,  material = Enum.Material.Neon },
	RightUpperLeg    = { color = SHADOW_GRAY,     material = Enum.Material.Slate },
	RightLowerLeg    = { color = SHADOW_GRAY,     material = Enum.Material.Glass },
	RightFoot        = { color = PHANTOM_VIOLET,  material = Enum.Material.Neon },
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

-- Effects callback: adds hooded cowl, tattered mantle, void rift, wraith bands,
-- spectral belt, expanding shadow trails, soul wisps + shadow mist particles
local function addEffects(model: Model, parts: { [string]: BasePart })
	local head = parts.Head
	local upperTorso = parts.UpperTorso
	local lowerTorso = parts.LowerTorso
	local leftFoot = parts.LeftFoot
	local rightFoot = parts.RightFoot

	-- ============================
	-- HEAD: Hooded Cowl
	-- ============================

	-- Hood main body — WedgePart sloping forward/down over the head
	weldWedge(
		head,
		CFrame.new(0, 0.35, 0.15) * CFrame.Angles(math.rad(15), math.rad(180), 0),
		Vector3.new(1.5, 1.0, 1.3),
		VOID_BLACK, Enum.Material.SmoothPlastic
	)

	-- Hood peak point — small wedge jutting forward from top
	weldWedge(
		head,
		CFrame.new(0, 0.75, -0.45) * CFrame.Angles(math.rad(35), 0, 0),
		Vector3.new(0.3, 0.5, 0.4),
		VOID_BLACK, Enum.Material.SmoothPlastic
	)

	-- Left drape — hangs down the left side
	weldAccent(
		head,
		CFrame.new(-0.65, -0.1, 0.1) * CFrame.Angles(0, 0, math.rad(10)),
		Vector3.new(0.12, 1.0, 0.8),
		SHADOW_GRAY, Enum.Material.SmoothPlastic
	)

	-- Right drape — hangs down the right side
	weldAccent(
		head,
		CFrame.new(0.65, -0.1, 0.1) * CFrame.Angles(0, 0, math.rad(-10)),
		Vector3.new(0.12, 1.0, 0.8),
		SHADOW_GRAY, Enum.Material.SmoothPlastic
	)

	-- Diamond-shaped left eye (rotated 45deg Part)
	local leftEye = weldAccent(
		head,
		CFrame.new(-0.22, 0.1, -0.62) * CFrame.Angles(0, 0, math.rad(45)),
		Vector3.new(0.2, 0.2, 0.06),
		WISP_GREEN
	)
	leftEye.Name = "LeftEye"

	local leftEyeLight = Instance.new("PointLight")
	leftEyeLight.Color = WISP_GREEN
	leftEyeLight.Brightness = 1.5
	leftEyeLight.Range = 6
	leftEyeLight.Parent = leftEye

	-- Diamond-shaped right eye (rotated 45deg Part)
	local rightEye = weldAccent(
		head,
		CFrame.new(0.22, 0.1, -0.62) * CFrame.Angles(0, 0, math.rad(45)),
		Vector3.new(0.2, 0.2, 0.06),
		WISP_GREEN
	)
	rightEye.Name = "RightEye"

	local rightEyeLight = Instance.new("PointLight")
	rightEyeLight.Color = WISP_GREEN
	rightEyeLight.Brightness = 1.5
	rightEyeLight.Range = 6
	rightEyeLight.Parent = rightEye

	-- Chin wisp tendril — Glass phantom violet dangling from under hood
	weldWedge(
		head,
		CFrame.new(0, -0.55, -0.25) * CFrame.Angles(math.rad(-10), 0, 0),
		Vector3.new(0.15, 0.5, 0.2),
		PHANTOM_VIOLET, Enum.Material.Glass
	)

	-- ============================
	-- SHOULDERS: Tattered Mantle
	-- ============================
	for _, side in ipairs({-1, 1}) do
		local arm = parts[side == -1 and "LeftUpperArm" or "RightUpperArm"]

		-- Thin drape plate over shoulder
		weldAccent(
			arm,
			CFrame.new(side * 0.1, 0.45, 0),
			Vector3.new(1.3, 0.12, 1.1),
			SHADOW_GRAY, Enum.Material.SmoothPlastic
		)

		-- Hanging strip 1 (longer, front)
		weldAccent(
			arm,
			CFrame.new(side * 0.35, -0.1, -0.3),
			Vector3.new(0.15, 0.9, 0.08),
			VOID_BLACK, Enum.Material.SmoothPlastic
		)

		-- Hanging strip 2 (shorter, back)
		weldAccent(
			arm,
			CFrame.new(side * 0.4, 0.0, 0.2),
			Vector3.new(0.12, 0.65, 0.08),
			SHADOW_GRAY, Enum.Material.SmoothPlastic
		)

		-- Smoke wisp curling upward (Glass)
		weldWedge(
			arm,
			CFrame.new(side * 0.2, 0.7, 0.15) * CFrame.Angles(math.rad(-20), 0, side * math.rad(15)),
			Vector3.new(0.1, 0.45, 0.15),
			PHANTOM_VIOLET, Enum.Material.Glass
		)
	end

	-- ============================
	-- TORSO: Void Rift + Spectral Chains
	-- ============================

	-- Central dark vertical rift on chest
	weldAccent(
		upperTorso,
		CFrame.new(0, 0, -0.56),
		Vector3.new(0.15, 1.0, 0.06),
		VOID_BLACK, Enum.Material.SmoothPlastic
	)

	-- Neon phantom violet edges framing the rift (left)
	weldAccent(
		upperTorso,
		CFrame.new(-0.12, 0, -0.57),
		Vector3.new(0.06, 0.9, 0.04),
		PHANTOM_VIOLET
	)

	-- Neon phantom violet edges framing the rift (right)
	weldAccent(
		upperTorso,
		CFrame.new(0.12, 0, -0.57),
		Vector3.new(0.06, 0.9, 0.04),
		PHANTOM_VIOLET
	)

	-- 3 diagonal chain strips crossing the rift (WISP_GREEN neon)
	weldAccent(
		upperTorso,
		CFrame.new(0, 0.25, -0.58) * CFrame.Angles(0, 0, math.rad(30)),
		Vector3.new(0.8, 0.07, 0.04),
		WISP_GREEN
	)
	weldAccent(
		upperTorso,
		CFrame.new(0, 0, -0.58) * CFrame.Angles(0, 0, math.rad(-25)),
		Vector3.new(0.7, 0.07, 0.04),
		WISP_GREEN
	)
	weldAccent(
		upperTorso,
		CFrame.new(0, -0.25, -0.58) * CFrame.Angles(0, 0, math.rad(20)),
		Vector3.new(0.65, 0.07, 0.04),
		WISP_GREEN
	)

	-- Back: 3 ghostly spine bumps (SMOKE_ASH Slate)
	for i = 1, 3 do
		local yOff = 0.35 - (i - 1) * 0.35
		weldAccent(
			upperTorso,
			CFrame.new(0, yOff, 0.56),
			Vector3.new(0.3, 0.2, 0.15),
			SMOKE_ASH, Enum.Material.Slate
		)
	end

	-- ============================
	-- ARMS: Wraith Bands on Forearms
	-- ============================
	for _, side in ipairs({-1, 1}) do
		local lowerArm = parts[side == -1 and "LeftLowerArm" or "RightLowerArm"]

		-- Dark ring band
		weldAccent(
			lowerArm,
			CFrame.new(0, 0.1, 0),
			Vector3.new(1.15, 0.2, 1.15),
			VOID_BLACK, Enum.Material.SmoothPlastic
		)

		-- Neon ring band
		weldAccent(
			lowerArm,
			CFrame.new(0, -0.1, 0),
			Vector3.new(1.1, 0.12, 1.1),
			PHANTOM_VIOLET
		)

		-- Dangling chain link
		weldAccent(
			lowerArm,
			CFrame.new(side * 0.45, -0.35, 0),
			Vector3.new(0.08, 0.35, 0.08),
			WISP_GREEN
		)
	end

	-- ============================
	-- BELT: Spectral Belt
	-- ============================

	-- Dark band around waist
	weldAccent(
		lowerTorso,
		CFrame.new(0, 0.1, -0.52),
		Vector3.new(1.8, 0.25, 0.08),
		VOID_BLACK, Enum.Material.SmoothPlastic
	)
	weldAccent(
		lowerTorso,
		CFrame.new(0, 0.1, 0.52),
		Vector3.new(1.8, 0.25, 0.08),
		VOID_BLACK, Enum.Material.SmoothPlastic
	)

	-- Green glow line on front belt
	weldAccent(
		lowerTorso,
		CFrame.new(0, 0.1, -0.56),
		Vector3.new(1.6, 0.06, 0.04),
		WISP_GREEN
	)

	-- Asymmetric sash tail on left hip
	weldAccent(
		lowerTorso,
		CFrame.new(-0.7, -0.35, 0),
		Vector3.new(0.18, 0.7, 0.12),
		SHADOW_GRAY, Enum.Material.SmoothPlastic
	)

	-- ============================
	-- HIGHLIGHT: Ghostly shimmer
	-- ============================
	local highlight = Instance.new("Highlight")
	highlight.FillTransparency = 0.9
	highlight.FillColor = PHANTOM_VIOLET
	highlight.OutlineColor = WISP_GREEN
	highlight.OutlineTransparency = 0.5
	highlight.Parent = model

	-- ============================
	-- PARTICLES: Soul wisps drifting upward on torso
	-- ============================
	local soulWisps = Instance.new("ParticleEmitter")
	soulWisps.Name = "SoulWisps"
	soulWisps.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	soulWisps.Rate = 4
	soulWisps.Lifetime = NumberRange.new(1.5, 2.5)
	soulWisps.Speed = NumberRange.new(0.3, 0.8)
	soulWisps.SpreadAngle = Vector2.new(60, 60)
	soulWisps.EmissionDirection = Enum.NormalId.Top
	soulWisps.Drag = 2
	soulWisps.RotSpeed = NumberRange.new(-30, 30)
	soulWisps.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, WISP_GREEN),
		ColorSequenceKeypoint.new(0.5, PHANTOM_VIOLET),
		ColorSequenceKeypoint.new(1, VOID_BLACK),
	})
	soulWisps.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.5, 0.15),
		NumberSequenceKeypoint.new(1, 0.05),
	})
	soulWisps.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.6, 0.6),
		NumberSequenceKeypoint.new(1, 1),
	})
	soulWisps.LightEmission = 0.6
	soulWisps.LightInfluence = 0
	soulWisps.Parent = upperTorso

	-- ============================
	-- FEET: Shadow mist + expanding dark trails
	-- ============================
	for _, foot in ipairs({leftFoot, rightFoot}) do

		-- Shadow mist particles — dark smoke sinking to ground
		local mist = Instance.new("ParticleEmitter")
		mist.Name = "ShadowMist"
		mist.Texture = "rbxasset://textures/particles/smoke_main.dds"
		mist.Rate = 8
		mist.Lifetime = NumberRange.new(1.0, 2.0)
		mist.Speed = NumberRange.new(0.2, 0.8)
		mist.SpreadAngle = Vector2.new(70, 70)
		mist.EmissionDirection = Enum.NormalId.Bottom
		mist.Drag = 3
		mist.Acceleration = Vector3.new(0, -0.3, 0)
		mist.RotSpeed = NumberRange.new(-20, 20)
		mist.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, SHADOW_GRAY),
			ColorSequenceKeypoint.new(0.5, VOID_BLACK),
			ColorSequenceKeypoint.new(1, VOID_BLACK),
		})
		mist.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(0.4, 1.2),
			NumberSequenceKeypoint.new(1, 2.0),
		})
		mist.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.4),
			NumberSequenceKeypoint.new(0.3, 0.5),
			NumberSequenceKeypoint.new(1, 1),
		})
		mist.LightEmission = 0
		mist.LightInfluence = 0
		mist.Parent = foot

		-- Trail attachments (shared by both trail layers)
		local attachTop = Instance.new("Attachment")
		attachTop.Name = "TrailTop"
		attachTop.Position = Vector3.new(0, 0.5, 0)
		attachTop.Parent = foot

		local attachBottom = Instance.new("Attachment")
		attachBottom.Name = "TrailBottom"
		attachBottom.Position = Vector3.new(0, -0.5, 0)
		attachBottom.Parent = foot

		-- Layer 1: Outer shadow — DARK expanding pool
		-- Key differentiator: WidthScale goes 0.3 → 2.2 (EXPANDS instead of tapering)
		local outerTrail = Instance.new("Trail")
		outerTrail.Name = "ShadowTrailOuter"
		outerTrail.Attachment0 = attachTop
		outerTrail.Attachment1 = attachBottom
		outerTrail.Lifetime = 0.7
		outerTrail.MinLength = 0.1
		outerTrail.FaceCamera = true
		outerTrail.LightEmission = 0
		outerTrail.LightInfluence = 0
		outerTrail.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, PHANTOM_VIOLET),
			ColorSequenceKeypoint.new(0.4, SHADOW_GRAY),
			ColorSequenceKeypoint.new(1, VOID_BLACK),
		})
		outerTrail.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.1),
			NumberSequenceKeypoint.new(0.3, 0.2),
			NumberSequenceKeypoint.new(0.7, 0.5),
			NumberSequenceKeypoint.new(1, 1),
		})
		outerTrail.WidthScale = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(0.3, 1.0),
			NumberSequenceKeypoint.new(0.7, 1.8),
			NumberSequenceKeypoint.new(1, 2.2),
		})
		outerTrail.Parent = foot

		-- Layer 2: Inner spectral glow — bright vein inside the dark pool
		local innerAttachTop = Instance.new("Attachment")
		innerAttachTop.Name = "InnerTrailTop"
		innerAttachTop.Position = Vector3.new(0, 0.3, 0)
		innerAttachTop.Parent = foot

		local innerAttachBottom = Instance.new("Attachment")
		innerAttachBottom.Name = "InnerTrailBottom"
		innerAttachBottom.Position = Vector3.new(0, -0.3, 0)
		innerAttachBottom.Parent = foot

		local innerTrail = Instance.new("Trail")
		innerTrail.Name = "ShadowTrailInner"
		innerTrail.Attachment0 = innerAttachTop
		innerTrail.Attachment1 = innerAttachBottom
		innerTrail.Lifetime = 0.5
		innerTrail.MinLength = 0.1
		innerTrail.FaceCamera = true
		innerTrail.LightEmission = 1
		innerTrail.LightInfluence = 0
		innerTrail.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, WISP_GREEN),
			ColorSequenceKeypoint.new(0.5, PHANTOM_VIOLET),
			ColorSequenceKeypoint.new(1, VOID_BLACK),
		})
		innerTrail.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.3, 0.2),
			NumberSequenceKeypoint.new(0.7, 0.6),
			NumberSequenceKeypoint.new(1, 1),
		})
		innerTrail.WidthScale = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2),
			NumberSequenceKeypoint.new(0.3, 0.5),
			NumberSequenceKeypoint.new(0.7, 0.8),
			NumberSequenceKeypoint.new(1, 1.0),
		})
		innerTrail.Parent = foot
	end
end

function Shadow.build(): Model
	return R15Rig.build({
		name = "Shadow",
		partStyles = PART_STYLES,
		addEffects = addEffects,
	})
end

return Shadow
