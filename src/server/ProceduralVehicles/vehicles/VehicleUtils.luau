local VehicleUtils = {}

function VehicleUtils.part(parent, name, size, cf, color, material, shape)
	local p = Instance.new("Part")
	p.Name = name
	if shape then p.Shape = shape end
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = false
	p.Parent = parent
	return p
end

function VehicleUtils.cylinder(parent, name, size, cf, color, material)
	return VehicleUtils.part(parent, name, size, cf, color, material, Enum.PartType.Cylinder)
end

function VehicleUtils.ball(parent, name, size, cf, color, material)
	return VehicleUtils.part(parent, name, size, cf, color, material, Enum.PartType.Ball)
end

function VehicleUtils.wedge(parent, name, size, cf, color, material)
	local w = Instance.new("WedgePart")
	w.Name = name
	w.Size = size
	w.CFrame = cf
	w.Color = color
	w.Material = material or Enum.Material.SmoothPlastic
	w.Anchored = true
	w.CanCollide = false
	w.Parent = parent
	return w
end

return VehicleUtils
