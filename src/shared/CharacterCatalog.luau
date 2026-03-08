-- CharacterCatalog.luau
-- Shared module defining all available characters
-- Characters are stored as Models in ReplicatedStorage/Characters/

local CharacterCatalog = {}

--------------------------------------------------------------------------------
-- ANIMATION PACKS
-- Official Roblox R15 animation IDs from the catalog.
-- Each pack contains: idle (3 variants), walk, run, jump, fall, climb
-- "default" uses nil (Roblox built-in Animate script handles it)
--------------------------------------------------------------------------------

CharacterCatalog.ANIMATION_PACKS = {
	ninja = {
		idle  = { "rbxassetid://656117400", "rbxassetid://656118341", "rbxassetid://886742569" },
		walk  = "rbxassetid://656121766",
		run   = "rbxassetid://656118852",
		jump  = "rbxassetid://656117878",
		fall  = "rbxassetid://656115606",
		climb = "rbxassetid://656114359",
	},
	knight = {
		idle  = { "rbxassetid://657595757", "rbxassetid://657568135", "rbxassetid://885499184" },
		walk  = "rbxassetid://657552124",
		run   = "rbxassetid://657564596",
		jump  = "rbxassetid://658409194",
		fall  = "rbxassetid://657600338",
		climb = "rbxassetid://658360781",
	},
	robot = {
		idle  = { "rbxassetid://616088211", "rbxassetid://616089559", "rbxassetid://885531463" },
		walk  = "rbxassetid://616095330",
		run   = "rbxassetid://616091570",
		jump  = "rbxassetid://616090535",
		fall  = "rbxassetid://616087089",
		climb = "rbxassetid://616086039",
	},
	vampire = {
		idle  = { "rbxassetid://1083445855", "rbxassetid://1083450166", "rbxassetid://1088037547" },
		walk  = "rbxassetid://1083473930",
		run   = "rbxassetid://1083462077",
		jump  = "rbxassetid://1083455352",
		fall  = "rbxassetid://1083443587",
		climb = "rbxassetid://1083439238",
	},
	werewolf = {
		idle  = { "rbxassetid://1083195517", "rbxassetid://1083214717", "rbxassetid://1099492820" },
		walk  = "rbxassetid://1083178339",
		run   = "rbxassetid://1083216690",
		jump  = "rbxassetid://1083218792",
		fall  = "rbxassetid://1083189019",
		climb = "rbxassetid://1083182000",
	},
	mage = {
		idle  = { "rbxassetid://707742142", "rbxassetid://707855907", "rbxassetid://885508740" },
		walk  = "rbxassetid://707897309",
		run   = "rbxassetid://707861613",
		jump  = "rbxassetid://707853694",
		fall  = "rbxassetid://707829716",
		climb = "rbxassetid://707826056",
	},
}

--------------------------------------------------------------------------------
-- CHARACTER DEFINITIONS
-- modelName must match the Model name in ReplicatedStorage/Characters/
-- animationPack references a key in ANIMATION_PACKS (nil = default animations)
--------------------------------------------------------------------------------

CharacterCatalog.CHARACTERS = {
	{
		id = "default",
		name = "Default",
		modelName = "Default",
		description = "The classic Roblox avatar",
		price = 0,
		currency = "free",
		animationPack = nil,  -- uses Roblox default
		unlockCondition = nil,
	},
	{
		id = "blaze",
		name = "Blaze",
		modelName = "Blaze",
		description = "A fire-forged runner with ember trails",
		price = 0,
		currency = "free",
		animationPack = "ninja",
		unlockCondition = nil,
	},
	{
		id = "glacier",
		name = "Glacier",
		modelName = "Glacier",
		description = "An ice-forged runner with frost trails",
		price = 0,
		currency = "free",
		animationPack = "knight",
		unlockCondition = nil,
	},
	{
		id = "volt",
		name = "Volt",
		modelName = "Volt",
		description = "A lightning-charged runner with spark trails",
		price = 500,
		currency = "coins",
		animationPack = "robot",
		unlockCondition = nil,
	},
	{
		id = "shadow",
		name = "Shadow",
		modelName = "Shadow",
		description = "A phantom runner with expanding dark trails",
		price = 1000,
		currency = "coins",
		animationPack = "vampire",
		unlockCondition = nil,
	},
	{
		id = "terra",
		name = "Terra",
		modelName = "Terra",
		description = "An earth-forged runner with crumbling stone trails",
		price = 1500,
		currency = "coins",
		animationPack = "werewolf",
		unlockCondition = nil,
	},
	{
		id = "aqua",
		name = "Aqua",
		modelName = "Aqua",
		description = "A deep-sea runner with flowing water trails",
		price = 2000,
		currency = "coins",
		animationPack = "mage",
		unlockCondition = nil,
	},
}

-- Get character by ID
function CharacterCatalog.getById(id: string)
	for _, char in ipairs(CharacterCatalog.CHARACTERS) do
		if char.id == id then
			return char
		end
	end
	return nil
end

-- Get character by model name
function CharacterCatalog.getByModelName(modelName: string)
	for _, char in ipairs(CharacterCatalog.CHARACTERS) do
		if char.modelName == modelName then
			return char
		end
	end
	return nil
end

-- Get all free characters (for debug menu / new players)
function CharacterCatalog.getFreeCharacters()
	local free = {}
	for _, char in ipairs(CharacterCatalog.CHARACTERS) do
		if char.currency == "free" then
			table.insert(free, char)
		end
	end
	return free
end

-- Get all character IDs (for debug menu dropdown)
function CharacterCatalog.getAllIds(): {string}
	local ids = {}
	for _, char in ipairs(CharacterCatalog.CHARACTERS) do
		table.insert(ids, char.id)
	end
	return ids
end

-- Get all character names (for debug menu display)
function CharacterCatalog.getAllNames(): {string}
	local names = {}
	for _, char in ipairs(CharacterCatalog.CHARACTERS) do
		table.insert(names, char.name)
	end
	return names
end

return CharacterCatalog
