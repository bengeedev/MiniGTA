-- Remotes.luau
-- MiniGTA remote events/functions. Server creates, client accesses.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = {}

Remotes.FUNCTIONS = {}

Remotes.EVENTS = {
	-- Character system (reused from DashOrCrash)
	"SelectCharacter",
	"CharacterSelected",
	"PurchaseCharacter",
	"CharacterPurchased",
	"PlayerDataSync",

	-- Theme / Environment (reused)
	"SelectTheme",
	"PurchaseTheme",
	"ThemePurchased",
	"ThemeChanged",
	"EnvironmentChanged",

	-- Economy
	"CoinsUpdated",

	-- Vehicle system (MiniGTA)
	"VehicleEntered",      -- Server -> Client: player entered vehicle { vehicleType, model }
	"VehicleExited",       -- Server -> Client: player exited vehicle
	"ExitVehicle",         -- Client -> Server: player wants to exit
	"VehicleTypeChanged",  -- Server -> Client: vehicle domain changed (ground/water/air/sub)

	-- Interaction
	"InteractPrompt",      -- Client -> Server: player pressed E on something

	-- Loading
	"LoadingProgress",
	"LoadingComplete",

	-- Sprint
	"SprintToggle",        -- Client -> Server: sprint state changed

	-- Debug (Studio-only)
	"DebugTeleport",       -- Client -> Server: teleport to district
	"DebugSpawnVehicle",   -- Client -> Server: spawn vehicle template near player
	"DebugToggleGodMode",  -- Client -> Server: toggle invincibility
	"DebugSetEnvironment", -- Client -> Server: set environment preset
	"DebugSetTheme",       -- Client -> Server: set visual theme
	"DebugSetTime",        -- Client -> Server: set ClockTime
	"DebugToggleNoclip",   -- Client -> Server: toggle noclip fly mode
	"DebugResetPlayer",    -- Client -> Server: teleport to spawn
	"DebugGiveCoins",      -- Client -> Server: add coins for testing
}

-- Get or create the Remotes folder
function Remotes.getFolder()
	local folder = ReplicatedStorage:FindFirstChild("Remotes")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Remotes"
		folder.Parent = ReplicatedStorage
	end
	return folder
end

-- Server: Create all RemoteEvents and RemoteFunctions
function Remotes.createAll()
	local folder = Remotes.getFolder()

	for _, eventName in ipairs(Remotes.EVENTS) do
		if not folder:FindFirstChild(eventName) then
			local remote = Instance.new("RemoteEvent")
			remote.Name = eventName
			remote.Parent = folder
		end
	end

	for _, funcName in ipairs(Remotes.FUNCTIONS) do
		if not folder:FindFirstChild(funcName) then
			local remote = Instance.new("RemoteFunction")
			remote.Name = funcName
			remote.Parent = folder
		end
	end

	print("[Remotes] Created " .. #Remotes.EVENTS .. " RemoteEvents, " .. #Remotes.FUNCTIONS .. " RemoteFunctions")
	return folder
end

-- Client/Server: Get a specific RemoteEvent
function Remotes.get(eventName: string): RemoteEvent?
	local folder = Remotes.getFolder()
	return folder:FindFirstChild(eventName)
end

-- Client: Wait for a specific RemoteEvent
function Remotes.waitFor(eventName: string, timeout: number?): RemoteEvent?
	local folder = Remotes.getFolder()
	return folder:WaitForChild(eventName, timeout or 10)
end

return Remotes
