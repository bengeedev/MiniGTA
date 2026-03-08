local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local Billboard = {}

function Billboard.createBillboard(x, z, scale)
	if not DecorUtils.decorFolder then return nil end
	scale = scale or 1
	local model = Instance.new("Model")
	model.Name = "Billboard"

	local BASE = DecorUtils.BUILDING_BASE
	local poleHeight = 18 * scale
	local poleWidth = 1.5 * scale
	local screenW = 40 * scale
	local screenH = 20 * scale
	local borderThick = 1 * scale
	local poleSpacing = 14 * scale -- half-distance between poles along X

	-- Two thick metal support poles
	for _, dx in ipairs({ -poleSpacing, poleSpacing }) do
		local pole = Instance.new("Part")
		pole.Name = "Pole"
		pole.Size = Vector3.new(poleWidth, poleHeight, poleWidth)
		pole.Position = Vector3.new(x + dx, BASE + poleHeight / 2, z)
		pole.Anchored = true
		pole.Material = Enum.Material.Metal
		pole.Color = Color3.fromRGB(70, 70, 75)
		pole.Parent = model
	end

	-- Screen — neon panel, faces approaching player (-Z)
	local screenY = BASE + poleHeight + screenH / 2
	local screen = Instance.new("Part")
	screen.Name = "Screen"
	screen.Size = Vector3.new(screenW, screenH, 1 * scale)
	screen.Position = Vector3.new(x, screenY, z)
	screen.Anchored = true
	screen.CanCollide = false
	screen.Material = Enum.Material.Neon
	screen.Color = Color3.fromRGB(15, 15, 20)
	screen.Parent = model

	-- SurfaceGui + ImageLabel on the front face
	-- Replace the asset ID with your own billboard art later
	local gui = Instance.new("SurfaceGui")
	gui.Name = "BillboardGui"
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 50
	gui.Parent = screen

	local img = Instance.new("ImageLabel")
	img.Name = "AdImage"
	img.Size = UDim2.new(1, 0, 1, 0)
	img.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	img.Image = "" -- set to "rbxassetid://XXXXX" when art is ready
	img.ScaleType = Enum.ScaleType.Stretch
	img.Parent = gui

	-- Metal border frame (4 pieces)
	local borderColor = Color3.fromRGB(50, 50, 55)
	local borders = {
		{ name = "BorderTop",    size = Vector3.new(screenW + borderThick * 2, borderThick, 2 * scale), pos = Vector3.new(x, screenY + screenH / 2 + borderThick / 2, z) },
		{ name = "BorderBottom", size = Vector3.new(screenW + borderThick * 2, borderThick, 2 * scale), pos = Vector3.new(x, screenY - screenH / 2 - borderThick / 2, z) },
		{ name = "BorderLeft",   size = Vector3.new(borderThick, screenH, 2 * scale), pos = Vector3.new(x - screenW / 2 - borderThick / 2, screenY, z) },
		{ name = "BorderRight",  size = Vector3.new(borderThick, screenH, 2 * scale), pos = Vector3.new(x + screenW / 2 + borderThick / 2, screenY, z) },
	}
	for _, b in ipairs(borders) do
		local border = Instance.new("Part")
		border.Name = b.name
		border.Size = b.size
		border.Position = b.pos
		border.Anchored = true
		border.CanCollide = false
		border.Material = Enum.Material.Metal
		border.Color = borderColor
		border.Parent = model
	end

	-- Top beam connecting the two poles (structural crossbar)
	local beam = Instance.new("Part")
	beam.Name = "TopBeam"
	beam.Size = Vector3.new(poleSpacing * 2 + poleWidth, poleWidth * 0.8, poleWidth)
	beam.Position = Vector3.new(x, BASE + poleHeight, z)
	beam.Anchored = true
	beam.CanCollide = false
	beam.Material = Enum.Material.Metal
	beam.Color = Color3.fromRGB(70, 70, 75)
	beam.Parent = model

	-- Spotlight housing bar above the screen
	local lightBarY = screenY + screenH / 2 + borderThick + 0.3 * scale
	local lightBar = Instance.new("Part")
	lightBar.Name = "LightBar"
	lightBar.Size = Vector3.new(screenW * 0.8, 1.2 * scale, 2 * scale)
	lightBar.Position = Vector3.new(x, lightBarY, z - 1 * scale)
	lightBar.Anchored = true
	lightBar.CanCollide = false
	lightBar.Material = Enum.Material.Metal
	lightBar.Color = Color3.fromRGB(50, 50, 55)
	lightBar.Parent = model

	-- 3 SpotLights in front of the screen, shining back at it
	local lightSpacing = screenW * 0.3
	for _, dx in ipairs({ -lightSpacing, 0, lightSpacing }) do
		local lampPart = Instance.new("Part")
		lampPart.Name = "SpotLamp"
		lampPart.Size = Vector3.new(2 * scale, 1 * scale, 1.5 * scale)
		lampPart.Position = Vector3.new(x + dx, lightBarY - 0.2 * scale, z - 2 * scale)
		lampPart.Anchored = true
		lampPart.CanCollide = false
		lampPart.Material = Enum.Material.Metal
		lampPart.Color = Color3.fromRGB(40, 40, 45)
		lampPart.Parent = model

		local spot = Instance.new("SpotLight")
		spot.Brightness = 3
		spot.Range = 40
		spot.Angle = 50
		spot.Face = Enum.NormalId.Back -- shines toward +Z (onto screen face)
		spot.Color = Color3.fromRGB(255, 250, 230)
		spot.Parent = lampPart
	end

	model.Parent = DecorUtils.decorFolder
	return model
end

return Billboard
