-- DebugMenu.client.luau
-- MiniGTA development tools: teleport, spawn vehicles, god mode, environment,
-- theme, time of day, noclip fly, coins. Studio-only floating panel.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Shared = ReplicatedStorage:WaitForChild("Shared", 10)
local GTAConfig = require(Shared:WaitForChild("GTAConfig"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local ThemeConfig = require(Shared:WaitForChild("ThemeConfig"))
local EnvironmentConfig = require(Shared:WaitForChild("EnvironmentConfig"))

local IS_STUDIO = RunService:IsStudio()

task.wait(1)

--------------------------------------------------------------------------------
-- COLORS
--------------------------------------------------------------------------------

local BG_DARK = Color3.fromRGB(30, 30, 35)
local BG_TITLE = Color3.fromRGB(45, 45, 50)
local BG_SECTION = Color3.fromRGB(38, 38, 44)
local TEXT_WHITE = Color3.fromRGB(255, 255, 255)
local TEXT_DIM = Color3.fromRGB(130, 130, 130)
local TEXT_LABEL = Color3.fromRGB(160, 170, 190)

local BTN_TELEPORT = Color3.fromRGB(50, 90, 140)
local BTN_VEHICLE = Color3.fromRGB(50, 130, 90)
local BTN_GOD_ON = Color3.fromRGB(50, 130, 90)
local BTN_GOD_OFF = Color3.fromRGB(100, 50, 50)
local BTN_CYCLE = Color3.fromRGB(60, 70, 100)
local BTN_ACTION = Color3.fromRGB(120, 90, 40)
local BTN_RESET = Color3.fromRGB(160, 70, 70)
local BTN_NOCLIP = Color3.fromRGB(100, 60, 130)

--------------------------------------------------------------------------------
-- UI CONSTRUCTION
--------------------------------------------------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DebugMenu"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Main frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 340, 0, 680)
mainFrame.Position = UDim2.new(0, 20, 0, 60)
mainFrame.BackgroundColor3 = BG_DARK
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

-- Title bar (draggable)
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundColor3 = BG_TITLE
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 8)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -20, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "MINI GTA — DEBUG"
titleLabel.TextColor3 = TEXT_WHITE
titleLabel.TextSize = 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

--------------------------------------------------------------------------------
-- HELPER: Create a row with label + button
--------------------------------------------------------------------------------

local nextY = 44 -- below title bar

local function addSectionLabel(text)
	local divider = Instance.new("Frame")
	divider.Size = UDim2.new(1, -24, 0, 1)
	divider.Position = UDim2.new(0, 12, 0, nextY)
	divider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	divider.BorderSizePixel = 0
	divider.Parent = mainFrame

	nextY += 4

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -24, 0, 20)
	lbl.Position = UDim2.new(0, 12, 0, nextY)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamBold
	lbl.Text = text
	lbl.TextColor3 = TEXT_DIM
	lbl.TextSize = 10
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = mainFrame

	nextY += 24
end

local function addRow(labelText, btnText, btnColor)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0, 80, 0, 28)
	lbl.Position = UDim2.new(0, 12, 0, nextY)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamBold
	lbl.Text = labelText
	lbl.TextColor3 = TEXT_LABEL
	lbl.TextSize = 11
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = mainFrame

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 228, 0, 28)
	btn.Position = UDim2.new(0, 96, 0, nextY)
	btn.BackgroundColor3 = btnColor
	btn.BorderSizePixel = 0
	btn.Font = Enum.Font.GothamBold
	btn.Text = btnText
	btn.TextColor3 = TEXT_WHITE
	btn.TextSize = 12
	btn.AutoButtonColor = false
	btn.Parent = mainFrame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	-- Hover effect
	local base = btnColor
	btn.MouseEnter:Connect(function()
		btn.BackgroundColor3 = Color3.new(
			math.min(base.R + 0.08, 1),
			math.min(base.G + 0.08, 1),
			math.min(base.B + 0.08, 1)
		)
	end)
	btn.MouseLeave:Connect(function()
		btn.BackgroundColor3 = base
	end)

	nextY += 34
	return btn
end

--------------------------------------------------------------------------------
-- TELEPORT TO DISTRICTS
--------------------------------------------------------------------------------

addSectionLabel("TELEPORT")

local DISTRICTS = {
	-- Central band (rows 3-6)
	{ name = "Downtown",    key = "downtown" },
	{ name = "Commercial",  key = "commercial" },
	{ name = "Government",  key = "government" },
	{ name = "Prison",      key = "prison" },
	{ name = "Residential", key = "residential" },
	-- North band (rows 0-2)
	{ name = "Airport",     key = "airport" },
	{ name = "Industrial",  key = "industrial" },
	{ name = "Power Plant", key = "power_plant" },
	{ name = "Military",    key = "military" },
	{ name = "Nuclear",     key = "nuclear" },
	-- South band (rows 7-9)
	{ name = "Harbor",      key = "harbor" },
	{ name = "Water Plant", key = "water_plant" },
	{ name = "Waterfront",  key = "waterfront" },
	{ name = "Beach",       key = "beach" },
	{ name = "Space",       key = "space" },
}

local districtIndex = 1
local teleportBtn = addRow("DISTRICT", DISTRICTS[1].name, BTN_TELEPORT)

teleportBtn.MouseButton1Click:Connect(function()
	local dist = DISTRICTS[districtIndex]
	local remote = Remotes.get("DebugTeleport")
	if remote then
		remote:FireServer(dist.key)
		print("[Debug] Teleporting to " .. dist.name .. " pad")
	end
	-- Cycle to next district
	districtIndex = districtIndex % #DISTRICTS + 1
	teleportBtn.Text = DISTRICTS[districtIndex].name
end)

local resetBtn = addRow("RESET", "Back to Spawn", BTN_RESET)
resetBtn.MouseButton1Click:Connect(function()
	local remote = Remotes.get("DebugResetPlayer")
	if remote then
		remote:FireServer()
	end
end)

--------------------------------------------------------------------------------
-- SPAWN VEHICLES
--------------------------------------------------------------------------------

addSectionLabel("VEHICLES")

local VEHICLE_LIST = {
	"Sedan_Red_1", "Convertible_Drivable", "PoliceCar_1", "Taxi_1",
	"PoliceMotorcycle_Drivable", "MonsterTruck", "SchoolBus_1",
	"SemiTruck_Red_1", "Jetski_Drivable", "Speedboat_1",
	"Helicopter_Police_1", "JumboJet_AF1",
	"SUV_Black_1", "Crossover_White_1", "MilitaryJeep_1",
}

local vehicleIndex = 1
local vehicleBtn = addRow("SPAWN", VEHICLE_LIST[1], BTN_VEHICLE)

vehicleBtn.MouseButton1Click:Connect(function()
	local templateName = VEHICLE_LIST[vehicleIndex]
	local remote = Remotes.get("DebugSpawnVehicle")
	if remote then
		remote:FireServer(templateName)
		print("[Debug] Spawning vehicle: " .. templateName)
	end
	vehicleIndex = vehicleIndex % #VEHICLE_LIST + 1
	vehicleBtn.Text = VEHICLE_LIST[vehicleIndex]
end)

--------------------------------------------------------------------------------
-- GOD MODE
--------------------------------------------------------------------------------

addSectionLabel("PLAYER")

local godModeOn = false
local godBtn = addRow("GOD MODE", "OFF", BTN_GOD_OFF)

godBtn.MouseButton1Click:Connect(function()
	godModeOn = not godModeOn
	godBtn.Text = godModeOn and "ON" or "OFF"
	godBtn.BackgroundColor3 = godModeOn and BTN_GOD_ON or BTN_GOD_OFF
	local remote = Remotes.get("DebugToggleGodMode")
	if remote then
		remote:FireServer(godModeOn)
	end
end)

--------------------------------------------------------------------------------
-- NOCLIP FLY
--------------------------------------------------------------------------------

local noclipOn = false
local noclipBtn = addRow("NOCLIP", "OFF", BTN_NOCLIP)

-- Client-side noclip implementation
local flyConnection = nil
local FLY_SPEED = 80

local function startNoclip()
	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then return end

	-- Disable gravity
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Name = "NoclipVelocity"
	bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bodyVelocity.Velocity = Vector3.zero
	bodyVelocity.Parent = hrp

	-- Disable collision
	for _, part in character:GetDescendants() do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end

	flyConnection = RunService.Heartbeat:Connect(function()
		if not hrp or not hrp.Parent then
			if flyConnection then flyConnection:Disconnect() end
			return
		end

		local camera = workspace.CurrentCamera
		local moveDir = Vector3.zero

		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			moveDir += camera.CFrame.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			moveDir -= camera.CFrame.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			moveDir -= camera.CFrame.RightVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			moveDir += camera.CFrame.RightVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			moveDir += Vector3.new(0, 1, 0)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
			moveDir -= Vector3.new(0, 1, 0)
		end

		if moveDir.Magnitude > 0 then
			moveDir = moveDir.Unit
		end

		bodyVelocity.Velocity = moveDir * FLY_SPEED

		-- Keep collision off
		for _, part in character:GetDescendants() do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end)
end

local function stopNoclip()
	if flyConnection then
		flyConnection:Disconnect()
		flyConnection = nil
	end

	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp then
		local bv = hrp:FindFirstChild("NoclipVelocity")
		if bv then bv:Destroy() end
	end

	-- Re-enable collision
	for _, part in character:GetDescendants() do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			part.CanCollide = true
		end
	end
end

noclipBtn.MouseButton1Click:Connect(function()
	noclipOn = not noclipOn
	noclipBtn.Text = noclipOn and "ON" or "OFF"
	noclipBtn.BackgroundColor3 = noclipOn and BTN_GOD_ON or BTN_NOCLIP
	if noclipOn then
		startNoclip()
	else
		stopNoclip()
	end
end)

-- Stop noclip on respawn
player.CharacterAdded:Connect(function()
	if noclipOn then
		task.wait(0.5)
		startNoclip()
	end
end)

--------------------------------------------------------------------------------
-- COINS
--------------------------------------------------------------------------------

local coinsBtn = addRow("COINS", "+1000", BTN_ACTION)
coinsBtn.MouseButton1Click:Connect(function()
	local remote = Remotes.get("DebugGiveCoins")
	if remote then
		remote:FireServer(1000)
		print("[Debug] +1000 coins")
	end
end)

--------------------------------------------------------------------------------
-- ENVIRONMENT
--------------------------------------------------------------------------------

addSectionLabel("WORLD")

local envPresets = {}
if EnvironmentConfig.getPresetNames then
	envPresets = EnvironmentConfig.getPresetNames()
end
table.insert(envPresets, 1, "default")
local envIndex = 1

local envBtn = addRow("ENVIRON", "default", BTN_CYCLE)
envBtn.MouseButton1Click:Connect(function()
	envIndex = envIndex % #envPresets + 1
	local preset = envPresets[envIndex]
	envBtn.Text = preset
	player:SetAttribute("DebugEnvOverride", preset)
	local remote = Remotes.get("DebugSetEnvironment")
	if remote then
		remote:FireServer(preset)
	end
end)

--------------------------------------------------------------------------------
-- THEME
--------------------------------------------------------------------------------

local themeNames = ThemeConfig.THEME_NAMES or { "default" }
local themeIndex = 1

local themeBtn = addRow("THEME", "default", Color3.fromRGB(80, 40, 120))
themeBtn.MouseButton1Click:Connect(function()
	themeIndex = themeIndex % #themeNames + 1
	local themeName = themeNames[themeIndex]
	themeBtn.Text = themeName
	local remote = Remotes.get("DebugSetTheme")
	if remote then
		remote:FireServer(themeName)
		print("[Debug] Theme: " .. themeName)
	end
end)

--------------------------------------------------------------------------------
-- TIME OF DAY
--------------------------------------------------------------------------------

local TIME_PRESETS = {
	{ name = "Dawn",      time = 6 },
	{ name = "Morning",   time = 9 },
	{ name = "Noon",      time = 12 },
	{ name = "Afternoon", time = 14 },
	{ name = "Sunset",    time = 17.5 },
	{ name = "Dusk",      time = 19 },
	{ name = "Night",     time = 22 },
	{ name = "Midnight",  time = 0 },
}
local timeIndex = 4  -- start at Afternoon (matches default ClockTime 14)

local timeBtn = addRow("TIME", "Afternoon", BTN_CYCLE)
timeBtn.MouseButton1Click:Connect(function()
	timeIndex = timeIndex % #TIME_PRESETS + 1
	local preset = TIME_PRESETS[timeIndex]
	timeBtn.Text = preset.name
	local remote = Remotes.get("DebugSetTime")
	if remote then
		remote:FireServer(preset.time)
		print("[Debug] Time: " .. preset.name .. " (" .. preset.time .. ")")
	end
end)

--------------------------------------------------------------------------------
-- FLOATING TOGGLE BUTTON (Studio-only)
--------------------------------------------------------------------------------

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "DebugToggle"
toggleButton.Size = UDim2.new(0, 40, 0, 40)
toggleButton.Position = UDim2.new(1, -56, 1, -56)
toggleButton.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
toggleButton.BorderSizePixel = 0
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Text = "D"
toggleButton.TextColor3 = TEXT_WHITE
toggleButton.TextSize = 16
toggleButton.AutoButtonColor = false
toggleButton.Visible = IS_STUDIO
toggleButton.ZIndex = 100
toggleButton.Parent = screenGui
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 8)

toggleButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

-- Floating god mode shortcut
local floatingGodBtn = Instance.new("TextButton")
floatingGodBtn.Name = "FloatingGodToggle"
floatingGodBtn.Size = UDim2.new(0, 50, 0, 40)
floatingGodBtn.Position = UDim2.new(1, -112, 1, -56)
floatingGodBtn.BackgroundColor3 = BTN_GOD_OFF
floatingGodBtn.BorderSizePixel = 0
floatingGodBtn.Font = Enum.Font.GothamBold
floatingGodBtn.Text = "god"
floatingGodBtn.TextColor3 = TEXT_WHITE
floatingGodBtn.TextSize = 14
floatingGodBtn.AutoButtonColor = false
floatingGodBtn.Visible = IS_STUDIO
floatingGodBtn.ZIndex = 100
floatingGodBtn.Parent = screenGui
Instance.new("UICorner", floatingGodBtn).CornerRadius = UDim.new(0, 8)

floatingGodBtn.MouseButton1Click:Connect(function()
	godModeOn = not godModeOn
	floatingGodBtn.BackgroundColor3 = godModeOn and BTN_GOD_ON or BTN_GOD_OFF
	floatingGodBtn.Text = godModeOn and "GOD" or "god"
	godBtn.Text = godModeOn and "ON" or "OFF"
	godBtn.BackgroundColor3 = godModeOn and BTN_GOD_ON or BTN_GOD_OFF
	local remote = Remotes.get("DebugToggleGodMode")
	if remote then
		remote:FireServer(godModeOn)
	end
end)

--------------------------------------------------------------------------------
-- DRAGGING
--------------------------------------------------------------------------------

local dragging = false
local dragStart = nil
local startPos = nil

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

print("[DebugMenu] MiniGTA debug tools loaded")
