-- TrafficLight.luau
-- Procedural traffic light builders: pole-mounted and overhead (floating arm).
-- Light parts are named RedLight/YellowLight/GreenLight with OnColor/OffColor attributes
-- so VehicleTraffic can toggle them based on the traffic light phase.

local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local TrafficLight = {}

local TERRAIN_TOP = DecorUtils.TERRAIN_TOP

-- Colors
local POLE_COLOR = Color3.fromRGB(50, 55, 50)
local HOUSING_COLOR = Color3.fromRGB(30, 30, 30)

-- Light definitions: name, vertical offset from housing center, on/off colors
local LIGHT_DEFS = {
	{ name = "RedLight",    offY =  1.0, on = Color3.fromRGB(255, 30, 20),  off = Color3.fromRGB(60, 12, 8) },
	{ name = "YellowLight", offY =  0.0, on = Color3.fromRGB(255, 200, 0),  off = Color3.fromRGB(60, 45, 0) },
	{ name = "GreenLight",  offY = -1.0, on = Color3.fromRGB(20, 255, 40),  off = Color3.fromRGB(8, 50, 12) },
}

--------------------------------------------------------------------------------
-- LIGHT HEAD (shared between both styles)
--------------------------------------------------------------------------------

-- Create 3-light head (housing box + red/yellow/green) at world position.
-- yaw follows traffic convention: 0=south, π/2=east, -π/2=west, π=north.
-- Lights face TOWARD approaching traffic (-Z local after rotation).
local function createLightHead(parent, hx, hy, hz, yaw)
	local housingCF = CFrame.new(hx, hy, hz) * CFrame.Angles(0, yaw, 0)

	-- Housing box
	local housing = Instance.new("Part")
	housing.Name = "LightHousing"
	housing.Size = Vector3.new(1.4, 4, 1)
	housing.CFrame = housingCF
	housing.Anchored = true
	housing.Material = Enum.Material.Metal
	housing.Color = HOUSING_COLOR
	housing:SetAttribute("ThemeRole", "traffic_housing")
	housing:SetAttribute("BaseColor", HOUSING_COLOR)
	housing.Parent = parent

	-- Three signal lights on the front face
	for _, ld in ipairs(LIGHT_DEFS) do
		local light = Instance.new("Part")
		light.Name = ld.name
		light.Size = Vector3.new(0.8, 0.8, 0.2)
		light.CFrame = housingCF * CFrame.new(0, ld.offY, -0.55)
		light.Anchored = true
		light.CanCollide = false
		light.Material = Enum.Material.SmoothPlastic
		light.Color = ld.off
		light:SetAttribute("OnColor", ld.on)
		light:SetAttribute("OffColor", ld.off)
		light.Parent = parent
	end
end

--------------------------------------------------------------------------------
-- POLE-MOUNTED (short post with light head on top, ~10 studs)
--------------------------------------------------------------------------------

function TrafficLight.createPoleLight(x, z, yaw)
	if not DecorUtils.decorFolder then return nil end

	local model = Instance.new("Model")
	model.Name = "TrafficLight_Pole"

	local poleH = 14
	local baseY = TERRAIN_TOP

	-- Vertical pole
	local pole = Instance.new("Part")
	pole.Name = "Pole"
	pole.Size = Vector3.new(0.5, poleH, 0.5)
	pole.Position = Vector3.new(x, baseY + poleH / 2, z)
	pole.Anchored = true
	pole.Material = Enum.Material.Metal
	pole.Color = POLE_COLOR
	pole:SetAttribute("ThemeRole", "traffic_pole")
	pole:SetAttribute("BaseColor", POLE_COLOR)
	pole.Parent = model

	-- Light head at top
	createLightHead(model, x, baseY + poleH - 2, z, yaw)

	model.Parent = DecorUtils.decorFolder
	return model
end

--------------------------------------------------------------------------------
-- OVERHEAD / FLOATING (tall pole + horizontal arm with hanging light)
--------------------------------------------------------------------------------

function TrafficLight.createOverheadLight(x, z, yaw, armLength)
	if not DecorUtils.decorFolder then return nil end
	armLength = armLength or 12

	local model = Instance.new("Model")
	model.Name = "TrafficLight_Overhead"

	local poleH = 20
	local baseY = TERRAIN_TOP

	-- Tall vertical pole
	local pole = Instance.new("Part")
	pole.Name = "Pole"
	pole.Size = Vector3.new(0.7, poleH, 0.7)
	pole.Position = Vector3.new(x, baseY + poleH / 2, z)
	pole.Anchored = true
	pole.Material = Enum.Material.Metal
	pole.Color = POLE_COLOR
	pole:SetAttribute("ThemeRole", "traffic_pole")
	pole:SetAttribute("BaseColor", POLE_COLOR)
	pole.Parent = model

	-- Horizontal arm extending over the road (toward approaching traffic)
	local armCF = CFrame.new(x, baseY + poleH, z)
		* CFrame.Angles(0, yaw, 0)
		* CFrame.new(0, 0, -armLength / 2)

	local arm = Instance.new("Part")
	arm.Name = "Arm"
	arm.Size = Vector3.new(0.4, 0.4, armLength)
	arm.CFrame = armCF
	arm.Anchored = true
	arm.Material = Enum.Material.Metal
	arm.Color = POLE_COLOR
	arm:SetAttribute("ThemeRole", "traffic_pole")
	arm:SetAttribute("BaseColor", POLE_COLOR)
	arm.Parent = model

	-- Light head hanging from end of arm
	local endCF = CFrame.new(x, baseY + poleH, z)
		* CFrame.Angles(0, yaw, 0)
		* CFrame.new(0, 0, -armLength)

	createLightHead(model, endCF.X, baseY + poleH - 2.5, endCF.Z, yaw)

	model.Parent = DecorUtils.decorFolder
	return model
end

return TrafficLight
