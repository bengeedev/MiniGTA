-- DataStoreManager.luau
-- Handles player data persistence (coins, bestScore, selectedCharacter)
-- and global leaderboard via OrderedDataStore.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local DataStoreManager = {}

--------------------------------------------------------------------------------
-- DATASTORES
--------------------------------------------------------------------------------

local playerDataStore
local leaderboardStore

local IS_STUDIO = RunService:IsStudio()

local function initStores()
	local ok, err = pcall(function()
		playerDataStore = DataStoreService:GetDataStore("PlayerData")
		leaderboardStore = DataStoreService:GetOrderedDataStore("Leaderboard")
	end)
	if not ok then
		warn("[DataStoreManager] Failed to initialize DataStores: " .. tostring(err))
	end
end

initStores()

--------------------------------------------------------------------------------
-- DEFAULTS
--------------------------------------------------------------------------------

local DEFAULT_DATA = {
	coins = 0,
	bestScore = 0,
	selectedCharacter = "default",
	ownedCharacters = { "default" },
	ghostsEnabled = true,
	zoneBadges = {},
	seenUnlocks = {},
	selectedTheme = "default",
	ownedThemes = { "default" },
	welcomeBonusGranted = false,
	lastDailyBonusDate = "",
	lastDailyChallengeDate = "",
	dailyChallengeStreak = 0,
}

--------------------------------------------------------------------------------
-- PLAYER DATA
--------------------------------------------------------------------------------

function DataStoreManager.loadPlayer(player: Player): { coins: number, bestScore: number, selectedCharacter: string, ownedCharacters: { string } }
	if not playerDataStore then
		warn("[DataStoreManager] PlayerDataStore not available, using defaults")
		return table.clone(DEFAULT_DATA)
	end

	local key = "player_" .. tostring(player.UserId)
	local ok, result = pcall(function()
		return playerDataStore:GetAsync(key)
	end)

	if ok and result then
		-- Merge with defaults to handle missing fields
		local data = table.clone(DEFAULT_DATA)
		for k, v in pairs(result) do
			data[k] = v
		end
		print("[DataStoreManager] Loaded data for " .. player.Name .. ": coins=" .. data.coins .. " bestScore=" .. data.bestScore .. " char=" .. tostring(data.selectedCharacter))
		return data
	end

	if not ok then
		warn("[DataStoreManager] Failed to load data for " .. player.Name .. ": " .. tostring(result))
	end

	return table.clone(DEFAULT_DATA)
end

function DataStoreManager.savePlayer(player: Player, data: { coins: number, bestScore: number, selectedCharacter: string, ownedCharacters: { string }? })
	if not playerDataStore then
		warn("[DataStoreManager] PlayerDataStore not available, skipping save")
		return
	end

	local key = "player_" .. tostring(player.UserId)
	local saveData = {
		coins = data.coins or 0,
		bestScore = data.bestScore or 0,
		selectedCharacter = data.selectedCharacter or "default",
		ownedCharacters = data.ownedCharacters or { "default" },
		zoneBadges = data.zoneBadges or {},
		seenUnlocks = data.seenUnlocks or {},
		selectedTheme = data.selectedTheme or "default",
		ownedThemes = data.ownedThemes or { "default" },
		welcomeBonusGranted = data.welcomeBonusGranted or false,
		lastDailyBonusDate = data.lastDailyBonusDate or "",
		lastDailyChallengeDate = data.lastDailyChallengeDate or "",
		dailyChallengeStreak = data.dailyChallengeStreak or 0,
	}

	local ok, err = pcall(function()
		playerDataStore:SetAsync(key, saveData)
	end)

	if ok then
		print("[DataStoreManager] Saved data for " .. player.Name .. ": coins=" .. saveData.coins .. " bestScore=" .. saveData.bestScore)
	else
		warn("[DataStoreManager] Failed to save data for " .. player.Name .. ": " .. tostring(err))
	end
end

--------------------------------------------------------------------------------
-- LEADERBOARD
--------------------------------------------------------------------------------

function DataStoreManager.submitScore(player: Player, score: number)
	if not leaderboardStore then
		warn("[DataStoreManager] LeaderboardStore not available, skipping submit")
		return
	end

	local key = tostring(player.UserId)
	local ok, err = pcall(function()
		leaderboardStore:SetAsync(key, score)
	end)

	if ok then
		print("[DataStoreManager] Submitted leaderboard score for " .. player.Name .. ": " .. score)
	else
		warn("[DataStoreManager] Failed to submit score for " .. player.Name .. ": " .. tostring(err))
	end
end

function DataStoreManager.getLeaderboard(count: number?): { { name: string, score: number } }
	if not leaderboardStore then
		warn("[DataStoreManager] LeaderboardStore not available")
		return {}
	end

	local limit = count or 100
	local results = {}

	local ok, pages = pcall(function()
		return leaderboardStore:GetSortedAsync(false, limit)
	end)

	if not ok or not pages then
		warn("[DataStoreManager] Failed to get leaderboard: " .. tostring(pages))
		return {}
	end

	local entries = pages:GetCurrentPage()
	for _, entry in ipairs(entries) do
		-- entry.key is the UserId, entry.value is the score
		local userId = tonumber(entry.key)
		local playerName = "Player"

		if userId then
			local nameOk, name = pcall(function()
				return Players:GetNameFromUserIdAsync(userId)
			end)
			if nameOk and name then
				playerName = name
			end
		end

		table.insert(results, {
			name = playerName,
			score = entry.value,
		})
	end

	print("[DataStoreManager] Retrieved " .. #results .. " leaderboard entries")
	return results
end

--------------------------------------------------------------------------------
-- SAVE ALL (for BindToClose)
--------------------------------------------------------------------------------

function DataStoreManager.saveAllPlayers(playerStateMap: { [Player]: any })
	for player, state in pairs(playerStateMap) do
		if player:IsDescendantOf(Players) then
			DataStoreManager.savePlayer(player, {
				coins = state.coins or 0,
				bestScore = state.bestScore or 0,
				selectedCharacter = state.selectedCharacter or "default",
				ownedCharacters = state.ownedCharacters or { "default" },
				ghostsEnabled = state.ghostsEnabled ~= false,
				zoneBadges = state.zoneBadges or {},
				seenUnlocks = state.seenUnlocks or {},
				selectedTheme = state.selectedTheme or "default",
				ownedThemes = state.ownedThemes or { "default" },
				welcomeBonusGranted = state.welcomeBonusGranted or false,
				lastDailyBonusDate = state.lastDailyBonusDate or "",
				lastDailyChallengeDate = state.lastDailyChallengeDate or "",
				dailyChallengeStreak = state.dailyChallengeStreak or 0,
			})
		end
	end
end

return DataStoreManager
