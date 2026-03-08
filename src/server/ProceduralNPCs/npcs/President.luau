-- President.luau
-- Dark-suited president NPC with red tie and white collar accents.

local R15Rig = require(script.Parent.Parent.Parent.ProceduralCharacters.characters.R15Rig)

local President = {}

-- Colors
local CHARCOAL   = Color3.fromRGB(40, 40, 45)
local DARK_GRAY  = Color3.fromRGB(55, 55, 60)
local BLACK      = Color3.fromRGB(25, 25, 25)
local SKIN       = Color3.fromRGB(234, 192, 150) -- fair skin
local RED        = Color3.fromRGB(180, 30, 30)
local WHITE      = Color3.fromRGB(240, 240, 240)

local MAT = Enum.Material.SmoothPlastic

local PART_STYLES = {
	HumanoidRootPart = { color = CHARCOAL,  material = MAT },
	Head             = { color = SKIN,      material = MAT },
	UpperTorso       = { color = CHARCOAL,  material = MAT },
	LowerTorso       = { color = CHARCOAL,  material = MAT },
	LeftUpperArm     = { color = CHARCOAL,  material = MAT },
	LeftLowerArm     = { color = CHARCOAL,  material = MAT },
	LeftHand         = { color = SKIN,      material = MAT },
	RightUpperArm    = { color = CHARCOAL,  material = MAT },
	RightLowerArm    = { color = CHARCOAL,  material = MAT },
	RightHand        = { color = SKIN,      material = MAT },
	LeftUpperLeg     = { color = DARK_GRAY, material = MAT },
	LeftLowerLeg     = { color = DARK_GRAY, material = MAT },
	LeftFoot         = { color = BLACK,     material = MAT },
	RightUpperLeg    = { color = DARK_GRAY, material = MAT },
	RightLowerLeg    = { color = DARK_GRAY, material = MAT },
	RightFoot        = { color = BLACK,     material = MAT },
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

	-- White shirt collar — two angled strips at neckline
	for _, side in ipairs({-1, 1}) do
		weldAccent(
			upperTorso,
			CFrame.new(side * 0.3, 0.7, -0.52) * CFrame.Angles(0, 0, side * math.rad(15)),
			Vector3.new(0.35, 0.15, 0.04),
			WHITE
		)
	end

	-- Red tie — vertical strip down center chest
	-- Knot (wider at top)
	weldAccent(
		upperTorso,
		CFrame.new(0, 0.55, -0.52),
		Vector3.new(0.2, 0.15, 0.04),
		RED
	)
	-- Main tie body
	weldAccent(
		upperTorso,
		CFrame.new(0, 0.05, -0.52),
		Vector3.new(0.15, 0.85, 0.04),
		RED
	)
	-- Tie point (narrow at bottom)
	weldAccent(
		upperTorso,
		CFrame.new(0, -0.45, -0.52),
		Vector3.new(0.1, 0.15, 0.04),
		RED
	)

	-- Hair — simple dark block on top of head
	weldAccent(
		head,
		CFrame.new(0, 0.55, 0.05),
		Vector3.new(1.15, 0.25, 1.1),
		DARK_GRAY
	)
end

function President.build(): Model
	return R15Rig.build({
		name = "President",
		partStyles = PART_STYLES,
		addEffects = addEffects,
	})
end

return President
