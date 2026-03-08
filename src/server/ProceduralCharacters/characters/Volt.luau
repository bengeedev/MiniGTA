-- Volt.luau
-- Tesla Tech / Cyber Runner themed R15 character: dark metal core, electric neon
-- extremities, smooth dome helmet with dual eye LEDs and antenna prongs, tesla coil
-- shoulder discs, circuit board torso pattern with power core orb, tesla coil backpack,
-- capacitor arm rings, electric static crackling aura, rapid arc zap foot trails.

local R15Rig = require(script.Parent.R15Rig)

local Volt = {}

-- Color palette
local DEEP_PURPLE  = Color3.fromRGB(80, 40, 140)     -- head — electric plasma
local SILVER       = Color3.fromRGB(180, 185, 195)    -- torso/limb core — chrome
local VOLT_YELLOW  = Color3.fromRGB(255, 240, 50)     -- electric neon glow
local ARC_BLUE     = Color3.fromRGB(100, 180, 255)    -- secondary accent
local BRIGHT_WHITE = Color3.fromRGB(245, 250, 255)    -- hot spark tips

-- Part styles: purple head → silver core → neon yellow extremities
local PART_STYLES = {
	HumanoidRootPart = { color = SILVER,       material = Enum.Material.SmoothPlastic },
	Head             = { color = DEEP_PURPLE,  material = Enum.Material.Metal },
	UpperTorso       = { color = SILVER,       material = Enum.Material.ForceField },
	LowerTorso       = { color = SILVER,       material = Enum.Material.ForceField },
	LeftUpperArm     = { color = SILVER,       material = Enum.Material.ForceField },
	LeftLowerArm     = { color = VOLT_YELLOW,  material = Enum.Material.Neon },
	LeftHand         = { color = BRIGHT_WHITE, material = Enum.Material.Neon },
	RightUpperArm    = { color = SILVER,       material = Enum.Material.ForceField },
	RightLowerArm    = { color = VOLT_YELLOW,  material = Enum.Material.Neon },
	RightHand        = { color = BRIGHT_WHITE, material = Enum.Material.Neon },
	LeftUpperLeg     = { color = SILVER,       material = Enum.Material.ForceField },
	LeftLowerLeg     = { color = VOLT_YELLOW,  material = Enum.Material.Neon },
	LeftFoot         = { color = DEEP_PURPLE,  material = Enum.Material.Neon },
	RightUpperLeg    = { color = SILVER,       material = Enum.Material.ForceField },
	RightLowerLeg    = { color = VOLT_YELLOW,  material = Enum.Material.Neon },
	RightFoot        = { color = DEEP_PURPLE,  material = Enum.Material.Neon },
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

-- Effects callback: adds smooth dome, dual eye LEDs, antenna prongs, tesla coil
-- shoulders, circuit board torso, power core, backpack, capacitor rings, sparks + zaps
local function addEffects(model: Model, parts: { [string]: BasePart })
	local head = parts.Head
	local upperTorso = parts.UpperTorso
	local leftFoot = parts.LeftFoot
	local rightFoot = parts.RightFoot

	-- ============================
	-- HEAD: Smooth Dome + Dual Eyes + Antenna Prongs
	-- ============================

	-- Helmet shell — smooth dome, NO mohawk/crest
	local shell = weldAccent(
		head,
		CFrame.new(0, 0.1, 0.1),
		Vector3.new(1.45, 1.35, 1.1),
		DEEP_PURPLE, Enum.Material.SmoothPlastic
	)
	shell.Name = "HelmetShell"

	-- Sleek brow ridge — thinner than Blaze's
	weldAccent(
		head,
		CFrame.new(0, 0.32, -0.5),
		Vector3.new(1.2, 0.08, 0.3),
		DEEP_PURPLE, Enum.Material.SmoothPlastic
	)

	-- Two separate eye LEDs instead of visor slit
	for _, side in ipairs({-1, 1}) do
		local eye = weldAccent(
			head,
			CFrame.new(side * 0.25, 0.12, -0.64),
			Vector3.new(0.25, 0.2, 0.05),
			VOLT_YELLOW
		)
		eye.Name = side == -1 and "EyeL" or "EyeR"

		local eyeLight = Instance.new("PointLight")
		eyeLight.Color = VOLT_YELLOW
		eyeLight.Brightness = 0.4
		eyeLight.Range = 3
		eyeLight.Parent = eye
	end

	-- Two antenna prongs — thin rods from top-sides, angled backward
	for _, side in ipairs({-1, 1}) do
		weldAccent(
			head,
			CFrame.new(side * 0.35, 0.9, 0.2) * CFrame.Angles(math.rad(35), 0, side * math.rad(10)),
			Vector3.new(0.06, 0.8, 0.06),
			ARC_BLUE
		)
	end

	-- ============================
	-- SHOULDERS: Tesla Coil Discs
	-- ============================
	for _, side in ipairs({-1, 1}) do
		local arm = parts[side == -1 and "LeftUpperArm" or "RightUpperArm"]

		-- Disc base — flat cylinder shape on top of shoulder
		weldAccent(
			arm,
			CFrame.new(side * 0.05, 0.5, 0),
			Vector3.new(0.8, 0.15, 0.8),
			DEEP_PURPLE, Enum.Material.SmoothPlastic
		)
		-- Glowing coil core — smaller neon center
		weldAccent(
			arm,
			CFrame.new(side * 0.05, 0.58, 0),
			Vector3.new(0.35, 0.08, 0.35),
			VOLT_YELLOW
		)
	end

	-- ============================
	-- TORSO: Circuit Board Pattern + Power Core
	-- ============================

	-- Horizontal circuit lines (front) — 4 lines at different heights
	local circuitYPositions = { 0.35, 0.1, -0.15, -0.4 }
	local circuitWidths = { 0.9, 1.1, 1.0, 0.8 }
	for i, y in ipairs(circuitYPositions) do
		weldAccent(
			upperTorso,
			CFrame.new(0, y, -0.51),
			Vector3.new(circuitWidths[i], 0.04, 0.02),
			VOLT_YELLOW
		)
	end

	-- Vertical circuit connectors (front) — 3 short verticals linking horizontal lines
	local connectorXPositions = { -0.3, 0.0, 0.3 }
	for _, x in ipairs(connectorXPositions) do
		weldAccent(
			upperTorso,
			CFrame.new(x, 0.1, -0.51),
			Vector3.new(0.04, 0.55, 0.02),
			ARC_BLUE
		)
	end

	-- Central power core — glowing sphere in chest center
	local core = weldAccent(
		upperTorso,
		CFrame.new(0, 0.05, -0.55),
		Vector3.new(0.3, 0.3, 0.15),
		BRIGHT_WHITE
	)
	core.Name = "PowerCore"
	core.Shape = Enum.PartType.Ball

	local coreLight = Instance.new("PointLight")
	coreLight.Color = BRIGHT_WHITE
	coreLight.Brightness = 0.5
	coreLight.Range = 3
	coreLight.Parent = core

	-- ============================
	-- BACK: Tesla Coil Backpack
	-- ============================

	-- Left coil cylinder
	weldAccent(
		upperTorso,
		CFrame.new(-0.3, 0.3, 0.65),
		Vector3.new(0.25, 1.0, 0.25),
		DEEP_PURPLE, Enum.Material.SmoothPlastic
	)
	-- Right coil cylinder
	weldAccent(
		upperTorso,
		CFrame.new(0.3, 0.3, 0.65),
		Vector3.new(0.25, 1.0, 0.25),
		DEEP_PURPLE, Enum.Material.SmoothPlastic
	)
	-- Connecting bar between cylinders
	weldAccent(
		upperTorso,
		CFrame.new(0, 0.2, 0.65),
		Vector3.new(0.6, 0.12, 0.15),
		DEEP_PURPLE, Enum.Material.SmoothPlastic
	)
	-- Neon coil ring atop left cylinder
	weldAccent(
		upperTorso,
		CFrame.new(-0.3, 0.82, 0.65),
		Vector3.new(0.35, 0.06, 0.35),
		ARC_BLUE
	)
	-- Neon coil ring atop right cylinder
	weldAccent(
		upperTorso,
		CFrame.new(0.3, 0.82, 0.65),
		Vector3.new(0.35, 0.06, 0.35),
		ARC_BLUE
	)

	-- ============================
	-- ARMS: Capacitor Rings
	-- ============================
	for _, side in ipairs({-1, 1}) do
		local lowerArm = parts[side == -1 and "LeftLowerArm" or "RightLowerArm"]

		-- Upper ring
		weldAccent(
			lowerArm,
			CFrame.new(0, 0.15, 0),
			Vector3.new(0.75, 0.06, 0.75),
			VOLT_YELLOW
		)
		-- Lower ring
		weldAccent(
			lowerArm,
			CFrame.new(0, -0.2, 0),
			Vector3.new(0.75, 0.06, 0.75),
			VOLT_YELLOW
		)
	end

	-- ============================
	-- BELT: Circuit-Style Belt
	-- ============================
	-- Main belt strip
	weldAccent(
		parts.LowerTorso,
		CFrame.new(0, 0, -0.51),
		Vector3.new(1.8, 0.1, 0.05),
		VOLT_YELLOW
	)
	-- Node dots along the belt (tiny neon squares)
	for _, x in ipairs({-0.6, -0.2, 0.2, 0.6}) do
		weldAccent(
			parts.LowerTorso,
			CFrame.new(x, 0, -0.53),
			Vector3.new(0.12, 0.12, 0.04),
			BRIGHT_WHITE
		)
	end

	-- ============================
	-- TRAILS: Quad electric zap wires on feet
	-- 4 narrow bands per foot, each with distinct color + slightly
	-- different lifetime so they desync and create a shifting effect
	-- ============================
	local zapDefs = {
		{ offset = Vector3.new( 0.12, 0.12, 0), color = ARC_BLUE,    midColor = DEEP_PURPLE, life = 0.22 },
		{ offset = Vector3.new(-0.12, 0.04, 0), color = DEEP_PURPLE, midColor = ARC_BLUE,    life = 0.28 },
		{ offset = Vector3.new( 0.06,-0.04, 0), color = ARC_BLUE,    midColor = ARC_BLUE,    life = 0.20 },
		{ offset = Vector3.new(-0.06,-0.12, 0), color = DEEP_PURPLE, midColor = DEEP_PURPLE, life = 0.26 },
	}

	for _, foot in ipairs({leftFoot, rightFoot}) do
		-- Glow trail — wider, more transparent, sits behind the zap wires
		local glowA0 = Instance.new("Attachment")
		glowA0.Name = "GlowTop"
		glowA0.Position = Vector3.new(0, 0.3, 0)
		glowA0.Parent = foot

		local glowA1 = Instance.new("Attachment")
		glowA1.Name = "GlowBottom"
		glowA1.Position = Vector3.new(0, -0.3, 0)
		glowA1.Parent = foot

		local glow = Instance.new("Trail")
		glow.Name = "ElectricGlow"
		glow.Attachment0 = glowA0
		glow.Attachment1 = glowA1
		glow.Lifetime = 0.3
		glow.MinLength = 0.05
		glow.FaceCamera = true
		glow.LightEmission = 1
		glow.LightInfluence = 0
		glow.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, ARC_BLUE),
			ColorSequenceKeypoint.new(1, DEEP_PURPLE),
		})
		glow.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(0.5, 0.75),
			NumberSequenceKeypoint.new(1, 1),
		})
		glow.WidthScale = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1.5),
			NumberSequenceKeypoint.new(0.5, 1.0),
			NumberSequenceKeypoint.new(1, 0.3),
		})
		glow.Parent = foot

		-- 4 narrow zap wires on top of the glow
		for i, def in ipairs(zapDefs) do
			local a0 = Instance.new("Attachment")
			a0.Name = "Zap" .. i .. "A"
			a0.Position = def.offset + Vector3.new(0, 0.08, 0)
			a0.Parent = foot

			local a1 = Instance.new("Attachment")
			a1.Name = "Zap" .. i .. "B"
			a1.Position = def.offset - Vector3.new(0, 0.08, 0)
			a1.Parent = foot

			local zap = Instance.new("Trail")
			zap.Name = "ElectricZap" .. i
			zap.Attachment0 = a0
			zap.Attachment1 = a1
			zap.Lifetime = def.life
			zap.MinLength = 0.05
			zap.FaceCamera = true
			zap.LightEmission = 1
			zap.LightInfluence = 0
			zap.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, def.color),
				ColorSequenceKeypoint.new(0.5, def.midColor),
				ColorSequenceKeypoint.new(1, DEEP_PURPLE),
			})
			zap.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.4, 0.5),
				NumberSequenceKeypoint.new(1, 1),
			})
			zap.WidthScale = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(1, 0),
			})
			zap.Parent = foot
		end
	end
end

function Volt.build(): Model
	return R15Rig.build({
		name = "Volt",
		partStyles = PART_STYLES,
		addEffects = addEffects,
	})
end

return Volt
