local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local Lamp = {}

function Lamp.createStreetLamp(x, z, scale)
	if not DecorUtils.decorFolder then return nil end
	scale = scale or 1
	local lamp = Instance.new("Model")
	lamp.Name = "StreetLamp"

	local poleColor = Color3.fromRGB(50, 50, 50)
	local pole = Instance.new("Part")
	pole.Size = Vector3.new(0.5 * scale, 12 * scale, 0.5 * scale)
	pole.Position = Vector3.new(x, 6 * scale, z)
	pole.Anchored = true
	pole.Material = Enum.Material.Metal
	pole.Color = poleColor
	pole:SetAttribute("ThemeRole", "lamp_pole")
	pole:SetAttribute("BaseColor", poleColor)
	pole.Parent = lamp

	local housingColor = Color3.fromRGB(60, 60, 60)
	local housing = Instance.new("Part")
	housing.Size = Vector3.new(2 * scale, 1 * scale, 2 * scale)
	housing.Position = Vector3.new(x, 12.5 * scale, z)
	housing.Anchored = true
	housing.Material = Enum.Material.Metal
	housing.Color = housingColor
	housing:SetAttribute("ThemeRole", "lamp_housing")
	housing:SetAttribute("BaseColor", housingColor)
	housing.Parent = lamp

	local lightColor = Color3.fromRGB(255, 240, 200)
	local light = Instance.new("PointLight")
	light.Color = lightColor
	light.Brightness = 1
	light.Range = 40
	light:SetAttribute("ThemeRole", "lamp_light")
	light:SetAttribute("BaseColor", lightColor)
	light.Parent = housing

	lamp.Parent = DecorUtils.decorFolder
	return lamp
end

return Lamp
