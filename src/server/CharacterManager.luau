-- CharacterManager Module
-- Character swap/selection system using Roblox StarterCharacter.
-- Extracted from init.server.luau.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Shared = ReplicatedStorage:WaitForChild("Shared", 10)
local Remotes = require(Shared:WaitForChild("Remotes"))
local CharacterCatalog = require(Shared:WaitForChild("CharacterCatalog"))

local CharacterManager = {}

local CharactersFolder = ReplicatedStorage:FindFirstChild("Characters")
local isSwappingCharacter = {} -- Prevent re-entry during character swap

--------------------------------------------------------------------------------
-- ANIMATION PACK OVERRIDE
-- Replaces the default Animate script's animation IDs with pack-specific ones.
-- The Animate LocalScript uses child StringValue objects (e.g. "walk", "run")
-- each containing an Animation child with the AnimationId.
--------------------------------------------------------------------------------

local function applyAnimationPack(character, characterId)
	local charData = CharacterCatalog.getById(characterId)
	if not charData or not charData.animationPack then return end

	local pack = CharacterCatalog.ANIMATION_PACKS[charData.animationPack]
	if not pack then return end

	-- Wait for the Animate script (Roblox inserts it automatically)
	local animate = character:WaitForChild("Animate", 5)
	if not animate then return end

	-- Map: Animate child name -> pack key
	local ANIM_MAP = {
		walk  = "walk",
		run   = "run",
		jump  = "jump",
		fall  = "fall",
		climb = "climb",
		idle  = "idle",
	}

	for childName, packKey in pairs(ANIM_MAP) do
		local animValue = animate:FindFirstChild(childName)
		if not animValue then continue end

		local packData = pack[packKey]
		if not packData then continue end

		if type(packData) == "table" then
			-- Idle has multiple variants (Animation1, Animation2, etc.)
			local idx = 1
			for _, child in animValue:GetChildren() do
				if child:IsA("Animation") and packData[idx] then
					child.AnimationId = packData[idx]
					idx = idx + 1
				end
			end
		else
			-- Single animation (walk, run, jump, fall, climb)
			for _, child in animValue:GetChildren() do
				if child:IsA("Animation") then
					child.AnimationId = packData
					break
				end
			end
		end
	end
end

-- Swap to a custom character using Roblox's proper spawn system
function CharacterManager.swapCharacter(player, characterId, playerState)
	local charData = CharacterCatalog.getById(characterId)
	if not charData then
		warn("[Character] Unknown character ID: " .. characterId)
		return false
	end

	-- Store selection for future respawns
	if not playerState[player] then playerState[player] = {} end
	playerState[player].selectedCharacter = characterId

	-- Set flag to prevent re-entry
	isSwappingCharacter[player] = true

	-- Remove any existing StarterCharacter
	local existingStarter = StarterPlayer:FindFirstChild("StarterCharacter")
	if existingStarter then
		existingStarter:Destroy()
	end

	-- For "default", just respawn normally (no StarterCharacter)
	if characterId == "default" then
		print("[Character] " .. player.Name .. " switching to default avatar")
		player:LoadCharacter()
		-- Wait for avatar appearance (Shirt, Pants, accessories) to load
		if not player.HasAppearanceLoaded then
			player.CharacterAppearanceLoaded:Wait()
		end
		task.delay(1, function()
			isSwappingCharacter[player] = nil
		end)
		return true
	end

	-- Note: animation packs are applied in onCharacterAdded after LoadCharacter

	-- Find the character model
	if not CharactersFolder then
		CharactersFolder = ReplicatedStorage:FindFirstChild("Characters")
		if not CharactersFolder then
			warn("[Character] Characters folder not found in ReplicatedStorage")
			isSwappingCharacter[player] = nil
			return false
		end
	end

	local charModel = CharactersFolder:FindFirstChild(charData.modelName)
	if not charModel then
		warn("[Character] Model not found: " .. charData.modelName)
		isSwappingCharacter[player] = nil
		return false
	end

	-- Clone and set as StarterCharacter
	local starterChar = charModel:Clone()
	starterChar.Name = "StarterCharacter"
	starterChar.Parent = StarterPlayer

	-- Let Roblox spawn the character properly
	player:LoadCharacter()

	-- Clean up StarterCharacter after spawn
	task.delay(1, function()
		local sc = StarterPlayer:FindFirstChild("StarterCharacter")
		if sc then
			sc:Destroy()
		end
		isSwappingCharacter[player] = nil
	end)

	print("[Character] " .. player.Name .. " is now " .. charData.name)
	return true
end

-- Handle character selection from client
function CharacterManager.handleSelectCharacter(player, characterId, playerState)
	print("[Character] " .. player.Name .. " selecting: " .. characterId)

	local success = CharacterManager.swapCharacter(player, characterId, playerState)

	local remote = Remotes.get("CharacterSelected")
	if remote then
		remote:FireClient(player, characterId, success)
	end
end

-- Apply selected character on natural respawn (death, etc.)
function CharacterManager.onCharacterAdded(player, character, playerState)
	local state = playerState[player]

	-- Skip if we're in the middle of a character swap (prevents loop)
	if isSwappingCharacter[player] then
		-- Still apply animation pack even during swap (character just loaded)
		if state and state.selectedCharacter then
			task.spawn(function()
				applyAnimationPack(character, state.selectedCharacter)
			end)
		end
		return
	end

	-- Disable swimming (terrain water should kill, not swim)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
	end

	-- Apply animation pack for current character
	if state and state.selectedCharacter then
		task.spawn(function()
			applyAnimationPack(character, state.selectedCharacter)
		end)
	end

	-- Swap to custom character if one was selected
	if state and state.selectedCharacter and state.selectedCharacter ~= "default" then
		task.delay(0.5, function()
			if player.Character == character and not isSwappingCharacter[player] then
				CharacterManager.swapCharacter(player, state.selectedCharacter, playerState)
			end
		end)
	end

	-- Reapply god mode if enabled
	task.defer(function()
		local currentChar = player.Character
		if currentChar and state and state.godMode then
			local hum = currentChar:FindFirstChildOfClass("Humanoid")
			if hum then
				hum.MaxHealth = math.huge
				hum.Health = math.huge
			end
		end
	end)
end

return CharacterManager
