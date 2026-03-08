-- Civilian.luau
-- 20 civilian NPC variants (Boy_1..10, Girl_1..10) built from combinatorial palettes.
-- No addEffects — civilians are plain SmoothPlastic geometry (lightweight for 500+ instances).

local R15Rig = require(script.Parent.Parent.Parent.ProceduralCharacters.characters.R15Rig)

local Civilian = {}

-- Skin tones (light → dark)
local SKIN_TONES = {
	Color3.fromRGB(255, 224, 189), -- light
	Color3.fromRGB(234, 192, 150), -- fair
	Color3.fromRGB(198, 152, 108), -- medium
	Color3.fromRGB(141, 100, 65),  -- tan
	Color3.fromRGB(90, 60, 40),    -- dark
}

-- Shirt colors
local SHIRT_COLORS = {
	Color3.fromRGB(200, 50, 50),   -- red
	Color3.fromRGB(50, 80, 180),   -- blue
	Color3.fromRGB(50, 150, 60),   -- green
	Color3.fromRGB(220, 200, 50),  -- yellow
	Color3.fromRGB(230, 230, 230), -- white
	Color3.fromRGB(70, 70, 70),    -- dark gray
	Color3.fromRGB(220, 120, 30),  -- orange
	Color3.fromRGB(130, 50, 170),  -- purple
}

-- Pants colors
local PANTS_COLORS = {
	Color3.fromRGB(50, 70, 120),   -- jeans
	Color3.fromRGB(55, 55, 55),    -- dark gray
	Color3.fromRGB(180, 160, 110), -- khaki
	Color3.fromRGB(30, 30, 30),    -- black
}

-- Shoe colors
local SHOE_COLORS = {
	Color3.fromRGB(30, 30, 30),    -- black
	Color3.fromRGB(100, 60, 30),   -- brown
	Color3.fromRGB(220, 220, 220), -- white
}

-- Deterministic palette selection by 1-based index (1..20)
local function getPalette(index: number)
	local i = index - 1 -- 0-based for modular arithmetic
	return {
		skin  = SKIN_TONES[(i % #SKIN_TONES) + 1],
		shirt = SHIRT_COLORS[(i % #SHIRT_COLORS) + 1],
		pants = PANTS_COLORS[(math.floor(i / 2) % #PANTS_COLORS) + 1],
		shoes = SHOE_COLORS[(math.floor(i / 3) % #SHOE_COLORS) + 1],
	}
end

local MAT = Enum.Material.SmoothPlastic

local function buildVariant(name: string, index: number): Model
	local p = getPalette(index)

	local partStyles = {
		HumanoidRootPart = { color = p.shirt,  material = MAT },
		Head             = { color = p.skin,   material = MAT },
		UpperTorso       = { color = p.shirt,  material = MAT },
		LowerTorso       = { color = p.pants,  material = MAT },
		LeftUpperArm     = { color = p.shirt,  material = MAT },
		LeftLowerArm     = { color = p.skin,   material = MAT },
		LeftHand         = { color = p.skin,   material = MAT },
		RightUpperArm    = { color = p.shirt,  material = MAT },
		RightLowerArm    = { color = p.skin,   material = MAT },
		RightHand        = { color = p.skin,   material = MAT },
		LeftUpperLeg     = { color = p.pants,  material = MAT },
		LeftLowerLeg     = { color = p.pants,  material = MAT },
		LeftFoot         = { color = p.shoes,  material = MAT },
		RightUpperLeg    = { color = p.pants,  material = MAT },
		RightLowerLeg    = { color = p.pants,  material = MAT },
		RightFoot        = { color = p.shoes,  material = MAT },
	}

	return R15Rig.build({
		name = name,
		partStyles = partStyles,
	})
end

-- Build a named civilian variant. Index 1..10 = Boy, 11..20 = Girl.
function Civilian.build(name: string, index: number): Model
	return buildVariant(name, index)
end

return Civilian
