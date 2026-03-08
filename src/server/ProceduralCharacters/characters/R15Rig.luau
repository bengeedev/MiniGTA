-- R15Rig.luau
-- Shared R15 rig factory. Builds a valid R15 character Model from a config table.
-- Reusable for every procedural character — only colors/materials/effects change.
--
-- Creates: 16 parts, 15 Motor6D joints, paired RigAttachments on every joint,
-- standard functional attachments, Humanoid with body scales, HumanoidDescription
-- (blocks avatar appearance override).

local R15Rig = {}

-- Standard R15 part sizes (matching Roblox defaults, BodyTypeScale=0)
local PART_DATA = {
	HumanoidRootPart = { size = Vector3.new(2, 2, 1),     transparency = 1, canCollide = true },
	Head             = { size = Vector3.new(1.2, 1.2, 1.2), transparency = 0 },
	UpperTorso       = { size = Vector3.new(2, 1.6, 1),    transparency = 0 },
	LowerTorso       = { size = Vector3.new(2, 0.4, 1),    transparency = 0 },
	LeftUpperArm     = { size = Vector3.new(1, 1.2, 1),    transparency = 0 },
	LeftLowerArm     = { size = Vector3.new(1, 1.2, 1),    transparency = 0 },
	LeftHand         = { size = Vector3.new(1, 0.3, 1),    transparency = 0 },
	RightUpperArm    = { size = Vector3.new(1, 1.2, 1),    transparency = 0 },
	RightLowerArm    = { size = Vector3.new(1, 1.2, 1),    transparency = 0 },
	RightHand        = { size = Vector3.new(1, 0.3, 1),    transparency = 0 },
	LeftUpperLeg     = { size = Vector3.new(1, 1.35, 1),   transparency = 0 },
	LeftLowerLeg     = { size = Vector3.new(1, 1.35, 1),   transparency = 0 },
	LeftFoot         = { size = Vector3.new(1, 0.3, 1),    transparency = 0 },
	RightUpperLeg    = { size = Vector3.new(1, 1.35, 1),   transparency = 0 },
	RightLowerLeg    = { size = Vector3.new(1, 1.35, 1),   transparency = 0 },
	RightFoot        = { size = Vector3.new(1, 0.3, 1),    transparency = 0 },
}

-- Rest-pose positions relative to HumanoidRootPart at origin.
-- Computed from Motor6D C0/C1: Part1 = Part0 * C0 * C1:Inverse()
local REST_OFFSETS = {
	HumanoidRootPart = CFrame.new(0, 0, 0),
	LowerTorso       = CFrame.new(0, -0.8, 0),
	UpperTorso       = CFrame.new(0, 0.2, 0),
	Head             = CFrame.new(0, 1.6, 0),
	LeftUpperArm     = CFrame.new(-1.5, 0.2, 0),
	LeftLowerArm     = CFrame.new(-1.5, -1.0, 0),
	LeftHand         = CFrame.new(-1.5, -1.75, 0),
	RightUpperArm    = CFrame.new(1.5, 0.2, 0),
	RightLowerArm    = CFrame.new(1.5, -1.0, 0),
	RightHand        = CFrame.new(1.5, -1.75, 0),
	LeftUpperLeg     = CFrame.new(-0.5, -1.675, 0),
	LeftLowerLeg     = CFrame.new(-0.5, -3.025, 0),
	LeftFoot         = CFrame.new(-0.5, -3.85, 0),
	RightUpperLeg    = CFrame.new(0.5, -1.675, 0),
	RightLowerLeg    = CFrame.new(0.5, -3.025, 0),
	RightFoot        = CFrame.new(0.5, -3.85, 0),
}

-- Motor6D joint definitions: {name, part0Name, part1Name, C0, C1}
-- C0/C1 values match standard Roblox R15 rig (BodyTypeScale=0, BodyProportionScale=0)
local JOINTS = {
	{ "Root",           "HumanoidRootPart", "LowerTorso",
		CFrame.new(0, -1, 0),                       CFrame.new(0, -0.2, 0) },
	{ "Waist",          "LowerTorso",       "UpperTorso",
		CFrame.new(0, 0.2, 0),                      CFrame.new(0, -0.8, 0) },
	{ "Neck",           "UpperTorso",       "Head",
		CFrame.new(0, 0.8, 0),                      CFrame.new(0, -0.6, 0) },
	{ "LeftShoulder",   "UpperTorso",       "LeftUpperArm",
		CFrame.new(-1, 0.6, 0),                     CFrame.new(0.5, 0.6, 0) },
	{ "LeftElbow",      "LeftUpperArm",     "LeftLowerArm",
		CFrame.new(-0.5, -0.6, 0),                  CFrame.new(-0.5, 0.6, 0) },
	{ "LeftWrist",      "LeftLowerArm",     "LeftHand",
		CFrame.new(-0.5, -0.6, 0),                  CFrame.new(-0.5, 0.15, 0) },
	{ "RightShoulder",  "UpperTorso",       "RightUpperArm",
		CFrame.new(1, 0.6, 0),                      CFrame.new(-0.5, 0.6, 0) },
	{ "RightElbow",     "RightUpperArm",    "RightLowerArm",
		CFrame.new(0.5, -0.6, 0),                   CFrame.new(0.5, 0.6, 0) },
	{ "RightWrist",     "RightLowerArm",    "RightHand",
		CFrame.new(0.5, -0.6, 0),                   CFrame.new(0.5, 0.15, 0) },
	{ "LeftHip",        "LowerTorso",       "LeftUpperLeg",
		CFrame.new(-0.5, -0.2, 0),                  CFrame.new(0, 0.675, 0) },
	{ "LeftKnee",       "LeftUpperLeg",     "LeftLowerLeg",
		CFrame.new(0, -0.675, 0),                   CFrame.new(0, 0.675, 0) },
	{ "LeftAnkle",      "LeftLowerLeg",     "LeftFoot",
		CFrame.new(0, -0.675, 0),                   CFrame.new(0, 0.15, 0) },
	{ "RightHip",       "LowerTorso",       "RightUpperLeg",
		CFrame.new(0.5, -0.2, 0),                   CFrame.new(0, 0.675, 0) },
	{ "RightKnee",      "RightUpperLeg",    "RightLowerLeg",
		CFrame.new(0, -0.675, 0),                   CFrame.new(0, 0.675, 0) },
	{ "RightAnkle",     "RightLowerLeg",    "RightFoot",
		CFrame.new(0, -0.675, 0),                   CFrame.new(0, 0.15, 0) },
}

-- Standard functional attachments (accessory mount points, grip, root)
-- {partName, attachmentName, position}
local FUNCTIONAL_ATTACHMENTS = {
	-- HumanoidRootPart
	{"HumanoidRootPart", "RootAttachment",          Vector3.new(0, 0, 0)},
	-- Head
	{"Head",             "HatAttachment",            Vector3.new(0, 0.6, 0)},
	{"Head",             "HairAttachment",           Vector3.new(0, 0.6, 0)},
	{"Head",             "FaceFrontAttachment",      Vector3.new(0, 0, -0.6)},
	{"Head",             "FaceCenterAttachment",     Vector3.new(0, 0, 0)},
	-- UpperTorso
	{"UpperTorso",       "BodyFrontAttachment",      Vector3.new(0, 0, -0.5)},
	{"UpperTorso",       "BodyBackAttachment",       Vector3.new(0, 0, 0.5)},
	{"UpperTorso",       "LeftCollarAttachment",     Vector3.new(-1, 0.8, 0)},
	{"UpperTorso",       "RightCollarAttachment",    Vector3.new(1, 0.8, 0)},
	{"UpperTorso",       "NeckAttachment",           Vector3.new(0, 1, 0)},
	-- LowerTorso
	{"LowerTorso",       "WaistCenterAttachment",   Vector3.new(0, -0.2, 0)},
	{"LowerTorso",       "WaistFrontAttachment",    Vector3.new(0, -0.2, -0.5)},
	{"LowerTorso",       "WaistBackAttachment",     Vector3.new(0, -0.2, 0.5)},
	-- Hands
	{"LeftHand",         "LeftGripAttachment",       Vector3.new(0, -0.1, 0)},
	{"RightHand",        "RightGripAttachment",      Vector3.new(0, -0.1, 0)},
	-- Feet
	{"LeftFoot",         "LeftFootAttachment",       Vector3.new(0, -0.1, 0)},
	{"RightFoot",        "RightFootAttachment",      Vector3.new(0, -0.1, 0)},
}

export type Config = {
	name: string,
	-- Map of part name → {color, material} or just color
	partStyles: { [string]: { color: Color3, material: Enum.Material? } },
	-- Optional callback to add effects (particles, lights, welded accents)
	addEffects: ((model: Model, parts: { [string]: BasePart }) -> ())?,
}

function R15Rig.build(config: Config): Model
	local model = Instance.new("Model")
	model.Name = config.name

	-- Create all 16 parts with proper rest-pose CFrames
	local parts: { [string]: BasePart } = {}
	for partName, data in pairs(PART_DATA) do
		local part = Instance.new("Part")
		part.Name = partName
		part.Size = data.size
		part.Transparency = data.transparency
		part.Anchored = false
		part.CanCollide = data.canCollide or false
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth

		-- Non-root parts are massless (character controller only uses HRP mass)
		if partName ~= "HumanoidRootPart" then
			part.Massless = true
		end

		-- Apply style from config
		local style = config.partStyles[partName]
		if style then
			part.Color = style.color
			part.Material = style.material or Enum.Material.SmoothPlastic
		else
			part.Color = Color3.fromRGB(128, 128, 128)
			part.Material = Enum.Material.SmoothPlastic
		end

		-- Head gets a special SpecialMesh (sphere-like)
		if partName == "Head" then
			local mesh = Instance.new("SpecialMesh")
			mesh.MeshType = Enum.MeshType.Head
			mesh.Scale = Vector3.new(1.25, 1.25, 1.25)
			mesh.Parent = part
		end

		-- Set proper rest-pose position (prevents physics chaos on spawn)
		part.CFrame = REST_OFFSETS[partName] or CFrame.new()
		part.Parent = model
		parts[partName] = part
	end

	-- Set PrimaryPart
	model.PrimaryPart = parts.HumanoidRootPart

	-- Create Motor6D joints + paired RigAttachments
	for _, jointDef in ipairs(JOINTS) do
		local jointName = jointDef[1]
		local part0Name = jointDef[2]
		local part1Name = jointDef[3]
		local c0 = jointDef[4]
		local c1 = jointDef[5]

		-- Motor6D
		local motor = Instance.new("Motor6D")
		motor.Name = jointName
		motor.Part0 = parts[part0Name]
		motor.Part1 = parts[part1Name]
		motor.C0 = c0
		motor.C1 = c1
		motor.Parent = parts[part1Name]

		-- RigAttachment on Part0 (at C0 position)
		local att0 = Instance.new("Attachment")
		att0.Name = jointName .. "RigAttachment"
		att0.CFrame = c0
		att0.Parent = parts[part0Name]

		-- RigAttachment on Part1 (at C1 position)
		local att1 = Instance.new("Attachment")
		att1.Name = jointName .. "RigAttachment"
		att1.CFrame = c1
		att1.Parent = parts[part1Name]
	end

	-- Standard functional attachments (accessory points, grip, root)
	for _, attDef in ipairs(FUNCTIONAL_ATTACHMENTS) do
		local partName, attName, pos = attDef[1], attDef[2], attDef[3]
		local att = Instance.new("Attachment")
		att.Name = attName
		att.Position = pos
		att.Parent = parts[partName]
	end

	-- Humanoid
	local humanoid = Instance.new("Humanoid")
	humanoid.RigType = Enum.HumanoidRigType.R15
	humanoid.HipHeight = 1.35
	humanoid.Parent = model

	-- Body scale values (NumberValues inside Humanoid)
	local scales = {
		BodyDepthScale = 1,
		BodyHeightScale = 1,
		BodyWidthScale = 1,
		HeadScale = 1,
		BodyProportionScale = 0,
		BodyTypeScale = 0,
	}
	for scaleName, value in pairs(scales) do
		local nv = Instance.new("NumberValue")
		nv.Name = scaleName
		nv.Value = value
		nv.Parent = humanoid
	end

	-- HumanoidDescription prevents Roblox from applying the player's avatar appearance
	-- on top of our custom character. We set explicit head/torso/limb asset IDs to 0
	-- so nothing overrides our procedural parts.
	local desc = Instance.new("HumanoidDescription")
	desc.Head = 0
	desc.Torso = 0
	desc.LeftArm = 0
	desc.RightArm = 0
	desc.LeftLeg = 0
	desc.RightLeg = 0
	desc.Parent = humanoid

	-- Apply custom effects (particles, lights, welded accents)
	if config.addEffects then
		config.addEffects(model, parts)
	end

	return model
end

return R15Rig
