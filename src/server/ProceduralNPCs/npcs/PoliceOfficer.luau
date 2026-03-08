-- PoliceOfficer.luau
-- Navy-uniformed police officer NPC with gold badge, dark belt, and cap.

local R15Rig = require(script.Parent.Parent.Parent.ProceduralCharacters.characters.R15Rig)

local PoliceOfficer = {}

-- Colors
local NAVY       = Color3.fromRGB(25, 35, 70)
local DARK_NAVY  = Color3.fromRGB(18, 25, 50)
local BLACK      = Color3.fromRGB(25, 25, 25)
local SKIN       = Color3.fromRGB(198, 152, 108) -- medium skin tone
local GOLD       = Color3.fromRGB(218, 175, 50)
local DARK_BROWN = Color3.fromRGB(50, 40, 30)

local MAT = Enum.Material.SmoothPlastic

local PART_STYLES = {
	HumanoidRootPart = { color = NAVY,  material = MAT },
	Head             = { color = SKIN,  material = MAT },
	UpperTorso       = { color = NAVY,  material = MAT },
	LowerTorso       = { color = NAVY,  material = MAT },
	LeftUpperArm     = { color = NAVY,  material = MAT },
	LeftLowerArm     = { color = NAVY,  material = MAT },
	LeftHand         = { color = SKIN,  material = MAT },
	RightUpperArm    = { color = NAVY,  material = MAT },
	RightLowerArm    = { color = NAVY,  material = MAT },
	RightHand        = { color = SKIN,  material = MAT },
	LeftUpperLeg     = { color = DARK_NAVY, material = MAT },
	LeftLowerLeg     = { color = DARK_NAVY, material = MAT },
	LeftFoot         = { color = BLACK, material = MAT },
	RightUpperLeg    = { color = DARK_NAVY, material = MAT },
	RightLowerLeg    = { color = DARK_NAVY, material = MAT },
	RightFoot        = { color = BLACK, material = MAT },
}

-- Weld a box accent to a parent part
local function weldAccent(parent: BasePart, offset: CFrame, size: Vector3, color: Color3, material: Enum.Material?): BasePart
	local accent = Instance.new("Part")
	accent.Name = "Accent"
	accent.Size = size
	accent.Color = color
	accent.Material = material or Enum.Material.SmoothPlastic
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
	accent.Parent = parent.Parent
	return accent
end

local function addEffects(model: Model, parts: { [string]: BasePart })
	local head = parts.Head
	local upperTorso = parts.UpperTorso
	local lowerTorso = parts.LowerTorso

	-- Police cap — flat brim + crown
	-- Crown (top of cap)
	weldAccent(
		head,
		CFrame.new(0, 0.65, 0),
		Vector3.new(1.1, 0.35, 1.1),
		DARK_NAVY
	)
	-- Brim (visor)
	weldAccent(
		head,
		CFrame.new(0, 0.45, -0.55),
		Vector3.new(1.2, 0.08, 0.5),
		BLACK
	)
	-- Cap badge (small gold square on front of cap)
	weldAccent(
		head,
		CFrame.new(0, 0.6, -0.56),
		Vector3.new(0.25, 0.2, 0.04),
		GOLD, Enum.Material.Neon
	)

	-- Chest badge — gold shield on left chest
	weldAccent(
		upperTorso,
		CFrame.new(-0.4, 0.2, -0.52),
		Vector3.new(0.3, 0.35, 0.04),
		GOLD, Enum.Material.Neon
	)

	-- Belt — dark strip across lower torso
	weldAccent(
		lowerTorso,
		CFrame.new(0, 0, -0.52),
		Vector3.new(2.05, 0.2, 0.04),
		DARK_BROWN
	)
	-- Belt buckle
	weldAccent(
		lowerTorso,
		CFrame.new(0, 0, -0.53),
		Vector3.new(0.25, 0.2, 0.04),
		GOLD, Enum.Material.Neon
	)
end

function PoliceOfficer.build(): Model
	return R15Rig.build({
		name = "police_officer_01",
		partStyles = PART_STYLES,
		addEffects = addEffects,
	})
end

return PoliceOfficer
