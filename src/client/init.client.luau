-- MiniGTA — Client Entry
-- Sets up player UI, camera, controls.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer

-- Disable default Roblox UI elements we don't need
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

-- Wait for shared modules
local Shared = ReplicatedStorage:WaitForChild("Shared", 10)
local Remotes = require(Shared:WaitForChild("Remotes"))
local GTAConfig = require(Shared:WaitForChild("GTAConfig"))

-- Wait for remotes to be created by server
task.wait(1)

--------------------------------------------------------------------------------
-- LOADING SCREEN (simple text-based)
--------------------------------------------------------------------------------

local playerGui = player:WaitForChild("PlayerGui")

local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "LoadingScreen"
loadingGui.IgnoreGuiInset = true
loadingGui.DisplayOrder = 100
loadingGui.Parent = playerGui

local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
bg.BorderSizePixel = 0
bg.Parent = loadingGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 60)
title.Position = UDim2.new(0, 0, 0.35, 0)
title.BackgroundTransparency = 1
title.Text = "MINI GTA"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 48
title.Font = Enum.Font.GothamBold
title.Parent = bg

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.6, 0, 0, 30)
statusLabel.Position = UDim2.new(0.2, 0, 0.55, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Loading..."
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.TextSize = 20
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = bg

-- Progress bar
local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(0.5, 0, 0, 8)
barBg.Position = UDim2.new(0.25, 0, 0.62, 0)
barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
barBg.BorderSizePixel = 0
barBg.Parent = bg

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(0, 4)
barCorner.Parent = barBg

local barFill = Instance.new("Frame")
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
barFill.BorderSizePixel = 0
barFill.Parent = barBg

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(0, 4)
fillCorner.Parent = barFill

-- Listen for loading progress
local progressRemote = Remotes.waitFor("LoadingProgress", 10)
if progressRemote then
	progressRemote.OnClientEvent:Connect(function(data)
		if data.message then
			statusLabel.Text = data.message
		end
		if data.progress then
			barFill.Size = UDim2.new(math.clamp(data.progress, 0, 1), 0, 1, 0)
		end
	end)
end

-- Wait for loading complete
local completeRemote = Remotes.waitFor("LoadingComplete", 30)
if completeRemote then
	completeRemote.OnClientEvent:Connect(function()
		statusLabel.Text = "Ready!"
		barFill.Size = UDim2.new(1, 0, 1, 0)
		task.wait(0.5)
		loadingGui:Destroy()
	end)
end

-- Fallback: destroy loading screen after 15 seconds regardless
task.delay(15, function()
	if loadingGui and loadingGui.Parent then
		loadingGui:Destroy()
	end
end)

print("[Client] MiniGTA client loaded")
