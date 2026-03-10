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
local VehicleTraffic = require(script:WaitForChild("VehicleTraffic"))
local VehicleDriving = require(script:WaitForChild("VehicleDriving"))

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
reportProgress("City built!", 0.85)

-- 7. Start vehicle traffic (road vehicles + train)
print("[Server] Starting vehicle traffic...")
reportProgress("Starting traffic...", 0.90)
VehicleTraffic.init()

-- 8. Drivable vehicles
VehicleDriving.init(vehicleFolder)
-- NPC traffic avoids drivable vehicles
VehicleTraffic.setObstacleSource(VehicleDriving.getVehiclePositions)
-- Spawn a Convertible near the player spawn point
local spawnPos = GTAConfig.SPAWN_POSITION
VehicleDriving.spawnVehicle("Convertible_Drivable", spawnPos.X + 15, spawnPos.Z + 10, 0)

-- 9. Set default environment
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

	-- Send traffic state snapshot (vehicles + light phase)
	VehicleTraffic.sendFullState(player)

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
-- DEBUG HANDLERS (Studio-only on server, client already checks IS_STUDIO)
--------------------------------------------------------------------------------

local IS_STUDIO = RunService:IsStudio()

-- Teleport to position
local debugTeleport = Remotes.get("DebugTeleport")
if debugTeleport then
	debugTeleport.OnServerEvent:Connect(function(player, position)
		if not IS_STUDIO then return end
		local character = player.Character
		if not character then return end
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.CFrame = CFrame.new(position)
			print("[Debug] Teleported", player.Name, "to", position)
		end
	end)
end

-- Reset player to spawn
local debugReset = Remotes.get("DebugResetPlayer")
if debugReset then
	debugReset.OnServerEvent:Connect(function(player)
		if not IS_STUDIO then return end
		local character = player.Character
		if not character then return end
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.CFrame = CFrame.new(GTAConfig.SPAWN_POSITION)
		end
	end)
end

-- Spawn vehicle near player
local debugSpawnVehicle = Remotes.get("DebugSpawnVehicle")
if debugSpawnVehicle then
	debugSpawnVehicle.OnServerEvent:Connect(function(player, templateName)
		if not IS_STUDIO then return end
		local templates = ReplicatedStorage:FindFirstChild("VehicleTemplates")
		if not templates then return end
		local template = templates:FindFirstChild(templateName)
		if not template then
			-- Try with _1 suffix
			template = templates:FindFirstChild(templateName .. "_1")
		end
		if not template then
			warn("[Debug] Vehicle template not found:", templateName)
			return
		end

		local character = player.Character
		if not character then return end
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		local clone = template:Clone()
		local spawnPos = hrp.Position + hrp.CFrame.LookVector * 20
		clone:PivotTo(CFrame.new(spawnPos.X, GTAConfig.GROUND_Y + 2, spawnPos.Z))
		clone.Parent = vehicleFolder
		print("[Debug] Spawned", templateName, "near", player.Name)
	end)
end

-- Toggle god mode
local debugGodMode = Remotes.get("DebugToggleGodMode")
if debugGodMode then
	debugGodMode.OnServerEvent:Connect(function(player, enabled)
		if not IS_STUDIO then return end
		if not playerState[player] then return end
		playerState[player].godMode = enabled
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				if enabled then
					humanoid.MaxHealth = math.huge
					humanoid.Health = math.huge
				else
					humanoid.MaxHealth = 100
					humanoid.Health = 100
				end
			end
		end
		print("[Debug] God mode", enabled and "ON" or "OFF", "for", player.Name)
	end)
end

-- Set environment
local debugSetEnv = Remotes.get("DebugSetEnvironment")
if debugSetEnv then
	debugSetEnv.OnServerEvent:Connect(function(player, envName)
		if not IS_STUDIO then return end
		local envRemote = Remotes.get("EnvironmentChanged")
		if envRemote then
			envRemote:FireClient(player, { envName = envName, transition = true })
		end
	end)
end

-- Set theme
local debugSetTheme = Remotes.get("DebugSetTheme")
if debugSetTheme then
	debugSetTheme.OnServerEvent:Connect(function(player, themeName)
		if not IS_STUDIO then return end
		if not playerState[player] then return end
		playerState[player].selectedTheme = themeName
		local themeRemote = Remotes.get("ThemeChanged")
		if themeRemote then
			themeRemote:FireClient(player, themeName)
		end
	end)
end

-- Set time of day
local debugSetTime = Remotes.get("DebugSetTime")
if debugSetTime then
	debugSetTime.OnServerEvent:Connect(function(player, clockTime)
		if not IS_STUDIO then return end
		local Lighting = game:GetService("Lighting")
		Lighting.ClockTime = clockTime
		print("[Debug] ClockTime set to", clockTime)
	end)
end

-- Give coins
local debugGiveCoins = Remotes.get("DebugGiveCoins")
if debugGiveCoins then
	debugGiveCoins.OnServerEvent:Connect(function(player, amount)
		if not IS_STUDIO then return end
		if not playerState[player] then return end
		playerState[player].coins = (playerState[player].coins or 0) + amount
		local coinsRemote = Remotes.get("CoinsUpdated")
		if coinsRemote then
			coinsRemote:FireClient(player, playerState[player].coins)
		end
		print("[Debug] Gave", amount, "coins to", player.Name, "→ total:", playerState[player].coins)
	end)
end

--------------------------------------------------------------------------------
-- TRAFFIC HIT (player hit by NPC vehicle → kill)
--------------------------------------------------------------------------------

local trafficHitRemote = Remotes.get("TrafficHit")
if trafficHitRemote then
	trafficHitRemote.OnServerEvent:Connect(function(player, _vehicleId)
		if not playerState[player] then return end
		if playerState[player].godMode then return end

		local character = player.Character
		if not character then return end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then return end

		humanoid:TakeDamage(humanoid.Health)
		print("[Traffic] Player", player.Name, "hit by NPC vehicle")
	end)
end

--------------------------------------------------------------------------------
-- SAVE ON CLOSE
--------------------------------------------------------------------------------

game:BindToClose(function()
	DataStoreManager.saveAllPlayers(playerState)
end)

print("[Server] MiniGTA server ready!")
