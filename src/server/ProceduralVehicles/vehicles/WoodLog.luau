local VU = require(script.Parent:WaitForChild("VehicleUtils"))

local WoodLog = {}

--------------------------------------------------------------------------------
-- WOOD LOG  (horizontal cylinder, faces +Z forward, bottom at Y=0)
-- Rideable floating log for water river lanes. Players hop on to cross.
-- Half-submerged at water surface (Y=4).
--------------------------------------------------------------------------------

-- Colors
local C_BARK   = Color3.fromRGB(101, 67, 33)   -- brown bark (same as Tree trunks)
local C_RINGS  = Color3.fromRGB(82, 54, 27)    -- darker cross-section rings

-- Dimensions (baked at final size, scale=1)
local LOG_LENGTH = 18
local LOG_RADIUS = 3   -- diameter = 6
local CAP_THICK  = 0.3

function WoodLog.build()
	local model = Instance.new("Model")
	model.Name = "WoodLog"

	-- Main trunk (Roblox cylinders extend along X — keep default orientation)
	local trunk = VU.cylinder(model, "Trunk",
		Vector3.new(LOG_LENGTH, LOG_RADIUS * 2, LOG_RADIUS * 2),
		CFrame.new(0, LOG_RADIUS, 0),
		C_BARK, Enum.Material.Wood)
	trunk.CanCollide = true

	-- Left end-cap disc (thin cylinder)
	VU.cylinder(model, "CapLeft",
		Vector3.new(CAP_THICK, LOG_RADIUS * 2 - 0.2, LOG_RADIUS * 2 - 0.2),
		CFrame.new(-LOG_LENGTH / 2, LOG_RADIUS, 0),
		C_RINGS, Enum.Material.Wood)

	-- Right end-cap disc
	VU.cylinder(model, "CapRight",
		Vector3.new(CAP_THICK, LOG_RADIUS * 2 - 0.2, LOG_RADIUS * 2 - 0.2),
		CFrame.new(LOG_LENGTH / 2, LOG_RADIUS, 0),
		C_RINGS, Enum.Material.Wood)

	model.PrimaryPart = trunk
	return model
end

return WoodLog
