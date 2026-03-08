local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local AirportTerminal = {}

function AirportTerminal.createAirportTerminal(x, z, scale)
	local decorFolder = DecorUtils.decorFolder
	if not decorFolder then return nil end
	scale = scale or 1
	local BUILDING_BASE = DecorUtils.BUILDING_BASE

	local building = Instance.new("Model")
	building.Name = "AirportTerminal"

	local FACADE = 160 * scale
	local B_DEPTH = 28 * scale
	local FLOOR_H = 12 * scale
	local HEIGHT = 2 * FLOOR_H
	local wallColor = Color3.fromRGB(215, 220, 230)
	local glassColor = Color3.fromRGB(150, 200, 255)

	local frontZ = z + B_DEPTH / 2 + 0.2
	local backZ = z - B_DEPTH / 2

	-- Back wall
	local back = Instance.new("Part")
	back.Name = "BackWall"
	back.Size = Vector3.new(FACADE, HEIGHT, 0.5)
	back.Position = Vector3.new(x, BUILDING_BASE + HEIGHT / 2, backZ)
	back.Anchored = true
	back.Material = Enum.Material.SmoothPlastic
	back.Color = wallColor
	back.Parent = building

	-- Side walls
	for i = -1, 1, 2 do
		local side = Instance.new("Part")
		side.Name = "SideWall"
		side.Size = Vector3.new(0.5, HEIGHT, B_DEPTH)
		side.Position = Vector3.new(x + i * FACADE / 2, BUILDING_BASE + HEIGHT / 2, z)
		side.Anchored = true
		side.Material = Enum.Material.SmoothPlastic
		side.Color = wallColor
		side.Parent = building
	end

	-- Upper front wall (floor 2)
	local upperH = HEIGHT - FLOOR_H
	local upperFront = Instance.new("Part")
	upperFront.Name = "UpperFrontWall"
	upperFront.Size = Vector3.new(FACADE, upperH, 0.5)
	upperFront.Position = Vector3.new(x, BUILDING_BASE + FLOOR_H + upperH / 2, frontZ)
	upperFront.Anchored = true
	upperFront.Material = Enum.Material.SmoothPlastic
	upperFront.Color = wallColor
	upperFront.Parent = building

	-- Upper windows (front Z face)
	local upWinW = 3.5 * scale
	local upWinH = 5 * scale
	local upWinY = BUILDING_BASE + FLOOR_H + FLOOR_H * 0.45
	local numUpWin = math.floor(FACADE / (upWinW + 2.5))
	local totalUpW = numUpWin * upWinW + (numUpWin - 1) * 2.5
	local startOff = -totalUpW / 2 + upWinW / 2
	for w = 1, numUpWin do
		local off = startOff + (w - 1) * (upWinW + 2.5)
		local win = Instance.new("Part")
		win.Size = Vector3.new(upWinW, upWinH, 0.3)
		win.Position = Vector3.new(x + off, upWinY, frontZ)
		win.Anchored = true
		win.CanCollide = false
		win.Material = math.random() < 0.6 and Enum.Material.Neon or Enum.Material.Glass
		win.Color = math.random() < 0.6 and glassColor or Color3.fromRGB(80, 120, 160)
		win.Parent = building
	end

	-- Glass storefront (floor 1)
	local glassH = FLOOR_H * 0.88
	local glassY = BUILDING_BASE + glassH / 2 + 0.2
	local glass = Instance.new("Part")
	glass.Size = Vector3.new(FACADE * 0.95, glassH, 0.3)
	glass.Position = Vector3.new(x, glassY, frontZ)
	glass.Anchored = true
	glass.CanCollide = false
	glass.Material = Enum.Material.Glass
	glass.Color = Color3.fromRGB(200, 230, 255)
	glass.Transparency = 0.55
	glass.Parent = building

	-- Mullions
	local numMullions = 28
	local mullionSpacing = (FACADE * 0.95) / (numMullions + 1)
	for m = 1, numMullions do
		local mullion = Instance.new("Part")
		mullion.Size = Vector3.new(0.15, glassH, 0.15)
		mullion.Position = Vector3.new(x - (FACADE * 0.95) / 2 + m * mullionSpacing, glassY, frontZ + 0.1)
		mullion.Anchored = true
		mullion.CanCollide = false
		mullion.Material = Enum.Material.Metal
		mullion.Color = Color3.fromRGB(120, 120, 130)
		mullion.Parent = building
	end

	-- Canopy
	local awning = Instance.new("Part")
	awning.Size = Vector3.new(FACADE * 0.92, 0.5, 5 * scale)
	awning.Position = Vector3.new(x, BUILDING_BASE + FLOOR_H - 0.5, frontZ + 2.5 * scale)
	awning.Anchored = true
	awning.Material = Enum.Material.Metal
	awning.Color = Color3.fromRGB(60, 65, 75)
	awning.Parent = building

	-- Individual "T E R M I N A L" letter signs
	local letters = { "T", "E", "R", "M", "I", "N", "A", "L" }
	local letterH = 4 * scale
	local letterW = 4 * scale
	local letterGap = 3 * scale
	local totalLettersW = #letters * letterW + (#letters - 1) * letterGap
	local letterStartX = x - totalLettersW / 2 + letterW / 2
	local letterY = BUILDING_BASE + FLOOR_H + letterH / 2 + 1

	for i, letter in ipairs(letters) do
		local lX = letterStartX + (i - 1) * (letterW + letterGap)
		local sign = Instance.new("Part")
		sign.Name = "Letter_" .. letter
		sign.Size = Vector3.new(letterW, letterH, 0.4)
		sign.Position = Vector3.new(lX, letterY, frontZ + 0.3)
		sign.Anchored = true
		sign.CanCollide = false
		sign.Material = Enum.Material.Neon
		sign.Color = Color3.fromRGB(50, 180, 255)
		sign.Parent = building

		local gui = Instance.new("SurfaceGui")
		gui.Face = Enum.NormalId.Back
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud = 50
		gui.Parent = sign

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, 0, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = letter
		lbl.TextColor3 = Color3.new(1, 1, 1)
		lbl.TextScaled = true
		lbl.Font = Enum.Font.GothamBold
		lbl.Parent = gui
	end

	-- Interior floor
	local iFloor = Instance.new("Part")
	iFloor.Size = Vector3.new(FACADE * 0.9, 0.3, B_DEPTH * 0.85)
	iFloor.Position = Vector3.new(x, BUILDING_BASE + 0.15, z)
	iFloor.Anchored = true
	iFloor.CanCollide = false
	iFloor.Material = Enum.Material.SmoothPlastic
	iFloor.Color = Color3.fromRGB(200, 195, 185)
	iFloor.Parent = building

	-- Interior ceiling light
	local cLight = Instance.new("Part")
	cLight.Size = Vector3.new(FACADE * 0.7, 0.3, B_DEPTH * 0.5)
	cLight.Position = Vector3.new(x, BUILDING_BASE + FLOOR_H - 0.3, z)
	cLight.Anchored = true
	cLight.CanCollide = false
	cLight.Material = Enum.Material.Neon
	cLight.Color = Color3.fromRGB(255, 245, 220)
	cLight.Parent = building

	local ptLight = Instance.new("PointLight")
	ptLight.Color = Color3.fromRGB(255, 240, 200)
	ptLight.Brightness = 0.6
	ptLight.Range = 30
	ptLight.Parent = cLight

	-- Check-in desks (9 along X)
	local DESK_COUNT = 9
	local deskW = 8 * scale
	local deskH = 3.5 * scale
	local deskD = 2.5 * scale
	local deskGap = 5 * scale
	local totalDesksW = DESK_COUNT * deskW + (DESK_COUNT - 1) * deskGap
	local deskStartX = x - totalDesksW / 2 + deskW / 2

	for d = 0, DESK_COUNT - 1 do
		local dX = deskStartX + d * (deskW + deskGap)
		local front = Instance.new("Part")
		front.Size = Vector3.new(deskW, deskH, 0.4)
		front.Position = Vector3.new(dX, BUILDING_BASE + deskH / 2, z + deskD / 2)
		front.Anchored = true
		front.CanCollide = false
		front.Material = Enum.Material.SmoothPlastic
		front.Color = Color3.fromRGB(60, 65, 75)
		front.Parent = building

		local top = Instance.new("Part")
		top.Size = Vector3.new(deskW, 0.3, deskD)
		top.Position = Vector3.new(dX, BUILDING_BASE + deskH, z)
		top.Anchored = true
		top.CanCollide = false
		top.Material = Enum.Material.SmoothPlastic
		top.Color = Color3.fromRGB(180, 180, 190)
		top.Parent = building
	end

	-- Roof
	local roof = Instance.new("Part")
	roof.Size = Vector3.new(FACADE + 0.5, 0.5, B_DEPTH + 0.5)
	roof.Position = Vector3.new(x, BUILDING_BASE + HEIGHT + 0.25, z)
	roof.Anchored = true
	roof.Material = Enum.Material.Metal
	roof.Color = Color3.fromRGB(50, 50, 55)
	roof.Parent = building

	building.Parent = decorFolder
	return building
end

return AirportTerminal
