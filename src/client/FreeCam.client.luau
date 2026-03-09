-- FreeCam.client.luau
-- Use Roblox's default third-person camera (already GTA-style):
-- - Auto-follows behind character
-- - Right-click to rotate camera
-- - WASD is camera-relative
-- - Scroll to zoom
-- - Collision avoidance built-in
--
-- We just configure it for a nice GTA feel (zoom, offset).

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- Wait for character to exist
local function setupCamera()
	local camera = Workspace.CurrentCamera
	-- Use default Roblox camera — it already does everything we need
	camera.CameraType = Enum.CameraType.Custom

	-- Set player camera settings for a nice third-person feel
	player.CameraMinZoomDistance = 6
	player.CameraMaxZoomDistance = 50
	player.CameraMode = Enum.CameraMode.Classic
end

-- Apply on spawn
player.CharacterAdded:Connect(function()
	task.wait(0.1)
	setupCamera()
end)

-- Apply now if character exists
if player.Character then
	setupCamera()
end

print("[FreeCam] Default third-person camera configured")
