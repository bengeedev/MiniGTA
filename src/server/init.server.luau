-- MiniGTA — Server Orchestrator
-- Builds procedural assets, sets up world, manages player state.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

-- Force landscape on mobile
StarterGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeSensor

-- Wait for shared modules (Rojo sync)
local Shared = ReplicatedStorage:WaitForChild("Shared", 10)
local Remotes = require(Shared:WaitForChild("Remotes"))
local GTAConfig = require(Shared:WaitForChild("GTAConfig"))
local CharacterCatalog = require(Shared:WaitForChild("CharacterCatalog"))
local EnvironmentConfig = require(Shared:WaitForChild("EnvironmentConfig"))

-- Server modules
local ProceduralNPCs = require(script:WaitForChild("ProceduralNPCs"))
local ProceduralVehicles = require(script:WaitForChild("ProceduralVehicles"))
local ProceduralCharacters = require(script:WaitForChild("ProceduralCharacters"))
local DecorCreation = require(script:WaitForChild("DecorCreation"))
local NPCManager = require(script:WaitForChild("NPCManager"))
local CharacterManager = require(script:WaitForChild("CharacterManager"))
local DataStoreManager = require(script:WaitForChild("DataStoreManager"))
local CityBuilder = require(script:WaitForChild("CityBuilder"))

--------------------------------------------------------------------------------
-- SETUP
--------------------------------------------------------------------------------

-- Create remotes
Remotes.createAll()

-- Create workspace folders
local worldFolder = Instance.new("Folder")
worldFolder.Name = "World"
worldFolder.Parent = Workspace

local decorFolder = Instance.new("Folder")
decorFolder.Name = "Decor"
decorFolder.Parent = worldFolder

local npcFolder = Instance.new("Folder")
npcFolder.Name = "NPCs"
npcFolder.Parent = worldFolder

local vehicleFolder = Instance.new("Folder")
vehicleFolder.Name = "Vehicles"
vehicleFolder.Parent = worldFolder

-- Create ReplicatedStorage template folders
local function ensureFolder(parent, name)
	local f = parent:FindFirstChild(name)
	if not f then
		f = Instance.new("Folder")
		f.Name = name
		f.Parent = parent
	end
	return f
end

local npcTemplates = ensureFolder(ReplicatedStorage, "NPCTemplates")
local vehicleTemplates = ensureFolder(ReplicatedStorage, "VehicleTemplates")
local characterTemplates = ensureFolder(ReplicatedStorage, "Characters")
local decorTemplates = ensureFolder(ReplicatedStorage, "DecorTemplates")

--------------------------------------------------------------------------------
-- PLAYER STATE
--------------------------------------------------------------------------------

local playerState = {}  -- [Player] = { coins, selectedCharacter, ... }

--------------------------------------------------------------------------------
-- LOADING SEQUENCE
--------------------------------------------------------------------------------

local loadingStartTime = tick()

local function reportProgress(message, progress)
	print(string.format("[Loading] %s (%.0f%%)", message, progress * 100))
	local remote = Remotes.get("LoadingProgress")
	if remote then
		for _, player in ipairs(Players:GetPlayers()) do
			remote:FireClient(player, { message = message, progress = progress })
		end
	end
end

-- 1. Build NPC templates (must be first — vehicles need them for seated NPCs)
print("[Server] Building NPC templates...")
ProceduralNPCs.build(function(name, step, total)
	reportProgress("Building NPCs: " .. name, 0.05 + (step / total) * 0.10)
end)

-- 2. Build vehicle templates
print("[Server] Building vehicle templates...")
ProceduralVehicles.build(function(name, step, total)
	reportProgress("Building vehicles: " .. name, 0.15 + (step / total) * 0.25)
end)

-- 3. Build character templates
print("[Server] Building character templates...")
ProceduralCharacters.build(function(name, step, total)
	reportProgress("Building characters: " .. name, 0.40 + (step / total) * 0.10)
end)

-- 4. Initialize decor system
print("[Server] Initializing decor system...")
DecorCreation.init(decorFolder, decorTemplates)

-- 5. Initialize NPC manager
NPCManager.init(npcFolder)

-- 6. Build the city
print("[Server] Building city...")
reportProgress("Building city...", 0.55)
CityBuilder.build(decorFolder, vehicleFolder, npcFolder)
reportProgress("City built!", 0.90)

-- 7. Set default environment
reportProgress("Finalizing...", 0.95)

local loadTime = tick() - loadingStartTime
print(string.format("[Server] World ready in %.1fs", loadTime))

--------------------------------------------------------------------------------
-- PLAYER MANAGEMENT
--------------------------------------------------------------------------------

local function onPlayerAdded(player)
	-- Load saved data
	local data = DataStoreManager.loadPlayer(player)
	playerState[player] = {
		coins = data.coins,
		selectedCharacter = data.selectedCharacter,
		ownedCharacters = data.ownedCharacters,
		selectedTheme = data.selectedTheme or "default",
		ownedThemes = data.ownedThemes or { "default" },
	}

	-- Sync data to client
	local syncRemote = Remotes.get("PlayerDataSync")
	if syncRemote then
		syncRemote:FireClient(player, playerState[player])
	end

	-- Send loading complete
	local loadComplete = Remotes.get("LoadingComplete")
	if loadComplete then
		loadComplete:FireClient(player)
	end

	-- Apply environment
	local envRemote = Remotes.get("EnvironmentChanged")
	if envRemote then
		envRemote:FireClient(player, { envName = "default", transition = false })
	end

	-- Handle character spawns
	player.CharacterAdded:Connect(function(character)
		CharacterManager.onCharacterAdded(player, character, playerState)

		-- Teleport to spawn
		local hrp = character:WaitForChild("HumanoidRootPart", 5)
		if hrp then
			hrp.CFrame = CFrame.new(GTAConfig.SPAWN_POSITION)
		end
	end)
end

local function onPlayerRemoving(player)
	if playerState[player] then
		DataStoreManager.savePlayer(player, playerState[player])
		playerState[player] = nil
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Handle players already connected (Studio fast-start)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end

--------------------------------------------------------------------------------
-- REMOTE HANDLERS
--------------------------------------------------------------------------------

-- Character selection
local selectCharRemote = Remotes.get("SelectCharacter")
if selectCharRemote then
	selectCharRemote.OnServerEvent:Connect(function(player, characterId)
		CharacterManager.handleSelectCharacter(player, characterId, playerState)
	end)
end

-- Theme selection
local selectThemeRemote = Remotes.get("SelectTheme")
if selectThemeRemote then
	selectThemeRemote.OnServerEvent:Connect(function(player, themeName)
		if not playerState[player] then return end
		playerState[player].selectedTheme = themeName
		local themeRemote = Remotes.get("ThemeChanged")
		if themeRemote then
			themeRemote:FireClient(player, themeName)
		end
	end)
end

--------------------------------------------------------------------------------
-- SAVE ON CLOSE
--------------------------------------------------------------------------------

game:BindToClose(function()
	DataStoreManager.saveAllPlayers(playerState)
end)

print("[Server] MiniGTA server ready!")
