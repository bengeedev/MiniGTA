-- Glacier.luau
-- Ice Knight / Frost Golem themed R15 character: deep navy core, icy translucent
-- extremities, ice crown with crystal spikes, knight faceplate with narrow visor,
-- jagged crystal shoulder formations, chest plate + dorsal spine, ice gauntlet
-- bracers, floating ice debris aura, ground-hugging frost mist foot trails,
-- and a Highlight outline for icy shimmer.

local R15Rig = require(script.Parent.R15Rig)

local Glacier = {}

-- Color palette
local FROST_WHITE  = Color3.fromRGB(220, 230, 245)   -- head — pale ice
local STEEL_BLUE   = Color3.fromRGB(70, 130, 180)    -- torso/limb core
local DEEP_CRYSTAL = Color3.fromRGB(40, 100, 200)    -- neon lower limbs
local BRIGHT_CYAN  = Color3.fromRGB(50, 200, 255)    -- neon hands/feet
local PALE_BLUE    = Color3.fromRGB(190, 220, 240)   -- accent / particles

-- Part styles: light head → blue core → saturated neon extremities
local PART_STYLES = {
	HumanoidRootPart = { color = STEEL_BLUE,   material = Enum.Material.SmoothPlastic },
	Head             = { color = FROST_WHITE,   material = Enum.Material.Ice },
	UpperTorso       = { color = STEEL_BLUE,    material = Enum.Material.Ice },
	LowerTorso       = { color = STEEL_BLUE,    material = Enum.Material.Ice },
	LeftUpperArm     = { color = STEEL_BLUE,    material = Enum.Material.Ice },
	LeftLowerArm     = { color = DEEP_CRYSTAL,  material = Enum.Material.Neon },
	LeftHand         = { color = BRIGHT_CYAN,   material = Enum.Material.Neon },
	RightUpperArm    = { color = STEEL_BLUE,    material = Enum.Material.Ice },
	RightLowerArm    = { color = DEEP_CRYSTAL,  material = Enum.Material.Neon },
	RightHand        = { color = BRIGHT_CYAN,   material = Enum.Material.Neon },
	LeftUpperLeg     = { color = STEEL_BLUE,    material = Enum.Material.Ice },
	LeftLowerLeg     = { color = DEEP_CRYSTAL,  material = Enum.Material.Neon },
	LeftFoot         = { color = BRIGHT_CYAN,   material = Enum.Material.Neon },
	RightUpperLeg    = { color = STEEL_BLUE,    material = Enum.Material.Ice },
	RightLowerLeg    = { color = DEEP_CRYSTAL,  material = Enum.Material.Neon },
	RightFoot        = { color = BRIGHT_CYAN,   material = Enum.Material.Neon },
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

-- Effects callback: adds ice crown, knight faceplate, crystal shoulders, chest plate,
-- frozen spine, ice gauntlets, highlight, floating ice debris + frost mist trails
local function addEffects(model: Model, parts: { [string]: BasePart })
	local head = parts.Head
	local upperTorso = parts.UpperTorso
	local leftFoot = parts.LeftFoot
	local rightFoot = parts.RightFoot

	-- ============================
	-- HEAD: Ice Crown + Knight Faceplate
	-- ============================

	-- Helmet shell — wraps back and sides of head
	local shell = weldAccent(
		head,
		CFrame.new(0, 0.1, 0.1),
		Vector3.new(1.45, 1.35, 1.1),
		STEEL_BLUE, Enum.Material.SmoothPlastic
	)
	shell.Name = "HelmetShell"

	-- Crown circlet band — horizontal ring around the head (4 thin parts)
	-- Front band
	weldAccent(
		head,
		CFrame.new(0, 0.55, -0.6),
		Vector3.new(1.2, 0.12, 0.08),
		FROST_WHITE, Enum.Material.Glass
	)
	-- Back band
	weldAccent(
		head,
		CFrame.new(0, 0.55, 0.55),
		Vector3.new(1.2, 0.12, 0.08),
		FROST_WHITE, Enum.Material.Glass
	)
	-- Left band
	weldAccent(
		head,
		CFrame.new(-0.62, 0.55, 0),
		Vector3.new(0.08, 0.12, 1.2),
		FROST_WHITE, Enum.Material.Glass
	)
	-- Right band
	weldAccent(
		head,
		CFrame.new(0.62, 0.55, 0),
		Vector3.new(0.08, 0.12, 1.2),
		FROST_WHITE, Enum.Material.Glass
	)

	-- Ice crystal spikes rising from crown (WedgeParts, Glass)
	-- Front spike (tallest — crown jewel)
	weldWedge(
		head,
		CFrame.new(0, 1.2, -0.35) * CFrame.Angles(math.rad(10), 0, 0),
		Vector3.new(0.14, 1.2, 0.3),
		FROST_WHITE, Enum.Material.Glass
	)
	-- Front-left spike
	weldWedge(
		head,
		CFrame.new(-0.35, 1.0, -0.3) * CFrame.Angles(math.rad(15), math.rad(20), math.rad(-15)),
		Vector3.new(0.1, 0.8, 0.2),
		PALE_BLUE, Enum.Material.Glass
	)
	-- Front-right spike
	weldWedge(
		head,
		CFrame.new(0.35, 1.0, -0.3) * CFrame.Angles(math.rad(15), math.rad(-20), math.rad(15)),
		Vector3.new(0.1, 0.8, 0.2),
		PALE_BLUE, Enum.Material.Glass
	)
	-- Left side spike (shorter)
	weldWedge(
		head,
		CFrame.new(-0.5, 0.85, 0.05) * CFrame.Angles(0, 0, math.rad(-25)),
		Vector3.new(0.08, 0.6, 0.18),
		BRIGHT_CYAN, Enum.Material.Glass
	)
	-- Right side spike (shorter)
	weldWedge(
		head,
		CFrame.new(0.5, 0.85, 0.05) * CFrame.Angles(0, 0, math.rad(25)),
		Vector3.new(0.08, 0.6, 0.18),
		BRIGHT_CYAN, Enum.Material.Glass
	)
	-- Back spike (medium)
	weldWedge(
		head,
		CFrame.new(0, 0.95, 0.35) * CFrame.Angles(math.rad(-20), math.rad(180), 0),
		Vector3.new(0.1, 0.7, 0.25),
		PALE_BLUE, Enum.Material.Glass
	)

	-- Knight faceplate — large face guard covering most of the face
	weldAccent(
		head,
		CFrame.new(0, -0.05, -0.6),
		Vector3.new(1.1, 0.9, 0.1),
		STEEL_BLUE, Enum.Material.SmoothPlastic
	)

	-- Narrow horizontal visor slit
	local visor = weldAccent(
		head,
		CFrame.new(0, 0.12, -0.66),
		Vector3.new(0.8, 0.1, 0.05),
		BRIGHT_CYAN
	)
	visor.Name = "Visor"

	-- Visor glow
	local light = Instance.new("PointLight")
	light.Color = BRIGHT_CYAN
	light.Brightness = 1
	light.Range = 8
	light.Parent = visor

	-- ============================
	-- SHOULDERS: Crystal Formations (jagged ice spikes)
	-- ============================
	for _, side in ipairs({-1, 1}) do
		local arm = parts[side == -1 and "LeftUpperArm" or "RightUpperArm"]

		-- Tallest crystal spike — upward/outward
		weldWedge(
			arm,
			CFrame.new(side * 0.15, 0.8, 0) * CFrame.Angles(0, 0, side * math.rad(20)),
			Vector3.new(0.12, 0.8, 0.25),
			PALE_BLUE, Enum.Material.Glass
		)
		-- Medium crystal spike — angled forward
		weldWedge(
			arm,
			CFrame.new(side * 0.1, 0.65, -0.2) * CFrame.Angles(math.rad(15), 0, side * math.rad(10)),
			Vector3.new(0.1, 0.55, 0.2),
			FROST_WHITE, Enum.Material.Glass
		)
		-- Short crystal spike — angled back
		weldWedge(
			arm,
			CFrame.new(side * 0.05, 0.55, 0.2) * CFrame.Angles(math.rad(-10), 0, side * math.rad(15)),
			Vector3.new(0.08, 0.4, 0.18),
			BRIGHT_CYAN, Enum.Material.Glass
		)
	end

	-- ============================
	-- TORSO: Chest Plate + Frozen Spine
	-- ============================

	-- Front chest plate — thick Glass panel protruding from upper torso
	weldAccent(
		upperTorso,
		CFrame.new(0, 0.1, -0.58),
		Vector3.new(1.2, 0.8, 0.15),
		FROST_WHITE, Enum.Material.Glass
	)

	-- Frozen spine crystal — large angular WedgePart on upper back (dorsal fin)
	weldWedge(
		upperTorso,
		CFrame.new(0, 0.6, 0.55) * CFrame.Angles(math.rad(-15), math.rad(180), 0),
		Vector3.new(0.6, 1.0, 0.4),
		DEEP_CRYSTAL, Enum.Material.Glass
	)

	-- ============================
	-- ARMS: Ice Gauntlet Bracers
	-- ============================
	for _, side in ipairs({-1, 1}) do
		local lowerArm = parts[side == -1 and "LeftLowerArm" or "RightLowerArm"]

		-- Angular bracer — wider than the arm itself
		weldAccent(
			lowerArm,
			CFrame.new(0, 0, 0),
			Vector3.new(1.2, 0.8, 1.2),
			PALE_BLUE, Enum.Material.Glass
		)
	end

	-- ============================
	-- BELT: Chunky Ice Band
	-- ============================
	-- Front ice belt band
	weldAccent(
		parts.LowerTorso,
		CFrame.new(0, 0, -0.52),
		Vector3.new(1.8, 0.3, 0.08),
		PALE_BLUE, Enum.Material.Glass
	)
	-- Back ice belt band
	weldAccent(
		parts.LowerTorso,
		CFrame.new(0, 0, 0.52),
		Vector3.new(1.8, 0.3, 0.08),
		PALE_BLUE, Enum.Material.Glass
	)
	-- Belt buckle crystal
	weldAccent(
		parts.LowerTorso,
		CFrame.new(0, 0, -0.56),
		Vector3.new(0.35, 0.35, 0.06),
		FROST_WHITE, Enum.Material.Glass
	)

	-- ============================
	-- HIGHLIGHT: Icy shimmer outline
	-- ============================
	local highlight = Instance.new("Highlight")
	highlight.FillTransparency = 0.85
	highlight.FillColor = DEEP_CRYSTAL
	highlight.OutlineColor = FROST_WHITE
	highlight.OutlineTransparency = 0.3
	highlight.Parent = model

	-- ============================
	-- PARTICLES: Drifting ice crystal aura on torso
	-- ============================
	local iceDebris = Instance.new("ParticleEmitter")
	iceDebris.Name = "IceDebrisAura"
	iceDebris.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	iceDebris.Rate = 5
	iceDebris.Lifetime = NumberRange.new(1.5, 3.0)
	iceDebris.Speed = NumberRange.new(0.2, 0.6)
	iceDebris.SpreadAngle = Vector2.new(80, 80)
	iceDebris.EmissionDirection = Enum.NormalId.Top
	iceDebris.Drag = 2
	iceDebris.RotSpeed = NumberRange.new(-40, 40)
	iceDebris.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, FROST_WHITE),
		ColorSequenceKeypoint.new(0.5, DEEP_CRYSTAL),
		ColorSequenceKeypoint.new(1, PALE_BLUE),
	})
	iceDebris.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.25),
		NumberSequenceKeypoint.new(0.5, 0.18),
		NumberSequenceKeypoint.new(1, 0.08),
	})
	iceDebris.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(0.6, 0.5),
		NumberSequenceKeypoint.new(1, 1),
	})
	iceDebris.LightEmission = 0.8
	iceDebris.LightInfluence = 0
	iceDebris.Parent = upperTorso

	-- ============================
	-- PARTICLES: Ground-hugging frost fog on feet
	-- Smoke texture + high drag + downward accel = crawling mist
	-- ============================
	for _, foot in ipairs({leftFoot, rightFoot}) do
		local mist = Instance.new("ParticleEmitter")
		mist.Name = "FrostMistTrail"
		mist.Texture = "rbxasset://textures/particles/smoke_main.dds"
		mist.Rate = 12
		mist.Lifetime = NumberRange.new(1.0, 2.0)
		mist.Speed = NumberRange.new(0.3, 1.0)
		mist.SpreadAngle = Vector2.new(60, 60)
		mist.EmissionDirection = Enum.NormalId.Bottom
		mist.Drag = 4
		mist.Acceleration = Vector3.new(0, -0.5, 0)
		mist.RotSpeed = NumberRange.new(-30, 30)
		mist.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, FROST_WHITE),
			ColorSequenceKeypoint.new(0.4, DEEP_CRYSTAL),
			ColorSequenceKeypoint.new(1, PALE_BLUE),
		})
		mist.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.4),
			NumberSequenceKeypoint.new(0.3, 1.0),
			NumberSequenceKeypoint.new(1, 1.5),
		})
		mist.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(0.3, 0.5),
			NumberSequenceKeypoint.new(1, 1),
		})
		mist.LightEmission = 0.4
		mist.LightInfluence = 0
		mist.Parent = foot

		-- Icy ribbon trail — wide, lingering frozen stream
		local attach0 = Instance.new("Attachment")
		attach0.Name = "TrailTop"
		attach0.Position = Vector3.new(0, 0.5, 0)
		attach0.Parent = foot

		local attach1 = Instance.new("Attachment")
		attach1.Name = "TrailBottom"
		attach1.Position = Vector3.new(0, -0.5, 0)
		attach1.Parent = foot

		local trail = Instance.new("Trail")
		trail.Name = "FrostTrail"
		trail.Attachment0 = attach0
		trail.Attachment1 = attach1
		trail.Lifetime = 0.8
		trail.MinLength = 0.1
		trail.FaceCamera = true
		trail.LightEmission = 0.8
		trail.LightInfluence = 0
		trail.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, BRIGHT_CYAN),
			ColorSequenceKeypoint.new(0.4, DEEP_CRYSTAL),
			ColorSequenceKeypoint.new(1, STEEL_BLUE),
		})
		trail.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.3, 0.2),
			NumberSequenceKeypoint.new(0.7, 0.6),
			NumberSequenceKeypoint.new(1, 1),
		})
		trail.WidthScale = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.8),
			NumberSequenceKeypoint.new(0.2, 1.2),
			NumberSequenceKeypoint.new(0.6, 1.0),
			NumberSequenceKeypoint.new(1, 0.3),
		})
		trail.Parent = foot
	end
end

function Glacier.build(): Model
	return R15Rig.build({
		name = "Glacier",
		partStyles = PART_STYLES,
		addEffects = addEffects,
	})
end

return Glacier
