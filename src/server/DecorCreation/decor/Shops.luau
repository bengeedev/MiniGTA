local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local Shops = {}

local SHOP_DEPTH_BASE = 16

-- Shop name pool
local SHOP_NAMES = {
	"PIZZA", "COFFEE", "DINER", "NOODLES", "BURGERS",
	"BOOKS", "SHOES", "VINYL", "TOYS", "ARCADE",
	"NAILS", "BARBER", "SUSHI", "TACOS", "BAKERY",
	"FLOWERS", "CANDY", "JAZZ", "RECORDS", "COMICS",
	"ICE CREAM", "LAUNDRY", "DELI", "BAGELS", "DONUTS",
}

local SHOP_FACADES = { 20, 24, 18, 22, 26, 16, 24, 20, 22, 18 }

-- Export constants for reuse (HoodBuilding needs these)
Shops.SHOP_DEPTH_BASE = SHOP_DEPTH_BASE
Shops.SHOP_FACADES = SHOP_FACADES

-- facing: "x" = glass faces toward x=0 (avenue), "z" = glass faces toward -Z (player)
function Shops.buildShopUnit(x, z, scale, facadeLen, facing, opts)
	facing = facing or "x"
	opts = opts or {}
	local decorFolder = DecorUtils.decorFolder
	local BUILDING_BASE = DecorUtils.BUILDING_BASE
	local pickRandom = DecorUtils.pickRandom
	local getFrontX = DecorUtils.getFrontX

	-- Style overrides from opts, fallback to defaults
	local wallColors = opts.wallColors or DecorUtils.WALL_COLORS
	local signColors = opts.signColors or DecorUtils.SIGN_COLORS
	local signFonts = opts.signFonts or DecorUtils.SIGN_FONTS
	local windowColors = opts.windowColors or DecorUtils.WINDOW_COLORS
	local wallMaterial = opts.wallMaterial or Enum.Material.Brick
	local awningMaterial = opts.awningMaterial or Enum.Material.Fabric
	local floorColor = opts.floorColor or Color3.fromRGB(180, 160, 130)
	local ceilingColor = opts.ceilingColor or Color3.fromRGB(255, 240, 210)
	local roofColor = opts.roofColor or Color3.fromRGB(40, 40, 45)

	local building = Instance.new("Model")
	building.Name = "Building_Shop"

	local sign_dir = x > 0 and 1 or -1
	local bDepth = SHOP_DEPTH_BASE * scale
	local floorHeight = 10 * scale
	local floors = 2
	local height = floors * floorHeight
	local wallColor = pickRandom(wallColors)
	local signColor = pickRandom(signColors)

	-- Dimensions: W runs along the facade (glass side), D runs perpendicular
	-- For Z-facing shops, swap so they fit the X spacing
	local W, D
	if facing == "x" then
		W = facadeLen
		D = bDepth
	else
		W = bDepth
		D = facadeLen
	end

	-- Front/back positions depend on facing
	local frontPos, backPos, awningOffset
	if facing == "x" then
		local frontX = getFrontX(x, D)
		local backX = x + sign_dir * (D / 2)
		frontPos = { x = frontX, z = z }
		backPos = { x = backX, z = z }
		awningOffset = { x = -sign_dir * 1.5 * scale, z = 0 }
	else -- "z"
		frontPos = { x = x, z = z + D / 2 + 0.2 }
		backPos = { x = x, z = z - D / 2 }
		awningOffset = { x = 0, z = 1.5 * scale }
	end

	-- Helper: size and position based on facing
	-- For "x" facing: thin along X, wide along Z
	-- For "z" facing: wide along X, thin along Z
	local function wallSize(thin, h, wide)
		if facing == "x" then
			return Vector3.new(thin, h, wide)
		else
			return Vector3.new(wide, h, thin)
		end
	end

	-- Back wall
	local back = Instance.new("Part")
	back.Name = "BackWall"
	back.Size = wallSize(0.5, height, W)
	back.Position = Vector3.new(backPos.x, BUILDING_BASE + height / 2, backPos.z)
	back.Anchored = true
	back.Material = wallMaterial
	back.Color = wallColor
	back:SetAttribute("ThemeRole", "shop_wall")
	back:SetAttribute("BaseColor", wallColor)
	back:SetAttribute("BaseMaterial", wallMaterial.Name)
	back.Parent = building

	-- Side walls (perpendicular to facade)
	for i = -1, 1, 2 do
		local side = Instance.new("Part")
		side.Name = "SideWall"
		if facing == "x" then
			side.Size = Vector3.new(D, height, 0.5)
			side.Position = Vector3.new(x, BUILDING_BASE + height / 2, z + i * W / 2)
		else
			side.Size = Vector3.new(0.5, height, D)
			side.Position = Vector3.new(x + i * W / 2, BUILDING_BASE + height / 2, z)
		end
		side.Anchored = true
		side.Material = wallMaterial
		side.Color = wallColor
		side:SetAttribute("ThemeRole", "shop_wall")
		side:SetAttribute("BaseColor", wallColor)
		side:SetAttribute("BaseMaterial", wallMaterial.Name)
		side.Parent = building
	end

	-- Upper front wall (2nd floor, opaque above glass)
	local upperFrontH = height - floorHeight
	local upperFront = Instance.new("Part")
	upperFront.Name = "UpperFrontWall"
	upperFront.Size = wallSize(0.5, upperFrontH, W)
	upperFront.Position = Vector3.new(frontPos.x, BUILDING_BASE + floorHeight + upperFrontH / 2, frontPos.z)
	upperFront.Anchored = true
	upperFront.Material = wallMaterial
	upperFront.Color = wallColor
	upperFront:SetAttribute("ThemeRole", "shop_wall")
	upperFront:SetAttribute("BaseColor", wallColor)
	upperFront:SetAttribute("BaseMaterial", wallMaterial.Name)
	upperFront.Parent = building

	-- Glass storefront
	local glassHeight = floorHeight * 0.92
	local glassY = BUILDING_BASE + glassHeight / 2 + 0.2
	local glass = Instance.new("Part")
	glass.Name = "StorefrontGlass"
	glass.Size = wallSize(0.3, glassHeight, W * 0.95)
	glass.Position = Vector3.new(frontPos.x, glassY, frontPos.z)
	glass.Anchored = true
	glass.CanCollide = true
	glass.Material = Enum.Material.Glass
	glass.Color = opts.glass or Color3.fromRGB(200, 230, 255)
	glass.Transparency = 0.65
	glass:SetAttribute("ThemeRole", "shop_glass")
	glass:SetAttribute("BaseColor", glass.Color)
	glass.Parent = building

	-- Mullions
	local numMullions = 4
	local mullionSpacing = (W * 0.95) / (numMullions + 1)
	for m = 1, numMullions do
		local mullion = Instance.new("Part")
		mullion.Name = "Mullion"
		mullion.Size = Vector3.new(0.15, glassHeight, 0.15)
		if facing == "x" then
			mullion.Position = Vector3.new(frontPos.x - sign_dir * 0.1, glassY, z - (W * 0.95) / 2 + m * mullionSpacing)
		else
			mullion.Position = Vector3.new(x - (W * 0.95) / 2 + m * mullionSpacing, glassY, frontPos.z + 0.1)
		end
		mullion.Anchored = true
		mullion.CanCollide = false
		mullion.Material = Enum.Material.Metal
		mullion.Color = opts.mullion or Color3.fromRGB(120, 120, 125)
		mullion:SetAttribute("ThemeRole", "shop_mullion")
		mullion:SetAttribute("BaseColor", mullion.Color)
		mullion.Parent = building
	end

	-- Interior: floor
	local interiorFloor = Instance.new("Part")
	interiorFloor.Name = "InteriorFloor"
	interiorFloor.Size = Vector3.new(
		facing == "x" and D * 0.8 or W * 0.9,
		0.3,
		facing == "x" and W * 0.9 or D * 0.8
	)
	interiorFloor.Position = Vector3.new(x, BUILDING_BASE + 0.15, z)
	interiorFloor.Anchored = true
	interiorFloor.CanCollide = false
	interiorFloor.Material = Enum.Material.SmoothPlastic
	interiorFloor.Color = floorColor
	interiorFloor:SetAttribute("ThemeRole", "shop_floor")
	interiorFloor:SetAttribute("BaseColor", floorColor)
	interiorFloor.Parent = building

	-- Interior: ceiling light
	local ceilingLight = Instance.new("Part")
	ceilingLight.Name = "CeilingLight"
	ceilingLight.Size = Vector3.new(
		facing == "x" and D * 0.4 or W * 0.6,
		0.3,
		facing == "x" and W * 0.6 or D * 0.4
	)
	ceilingLight.Position = Vector3.new(x, BUILDING_BASE + floorHeight - 0.3, z)
	ceilingLight.Anchored = true
	ceilingLight.CanCollide = false
	ceilingLight.Material = Enum.Material.Neon
	ceilingLight.Color = ceilingColor
	ceilingLight:SetAttribute("ThemeRole", "shop_ceiling")
	ceilingLight:SetAttribute("BaseColor", ceilingColor)
	ceilingLight.Parent = building

	local shopLight = Instance.new("PointLight")
	shopLight.Color = opts.shopLight or Color3.fromRGB(255, 230, 180)
	shopLight.Brightness = 0.5
	shopLight.Range = 12
	shopLight:SetAttribute("ThemeRole", "shop_shoplight")
	shopLight:SetAttribute("BaseColor", shopLight.Color)
	shopLight.Parent = ceilingLight

	-- Interior: back wall accent
	local interiorBack = Instance.new("Part")
	interiorBack.Name = "InteriorBackWall"
	if facing == "x" then
		interiorBack.Size = Vector3.new(0.3, floorHeight * 0.7, W * 0.7)
		interiorBack.Position = Vector3.new(x + sign_dir * (D * 0.35), BUILDING_BASE + floorHeight * 0.4, z)
	else
		interiorBack.Size = Vector3.new(W * 0.7, floorHeight * 0.7, 0.3)
		interiorBack.Position = Vector3.new(x, BUILDING_BASE + floorHeight * 0.4, z - D * 0.35)
	end
	interiorBack.Anchored = true
	interiorBack.CanCollide = false
	interiorBack.Material = Enum.Material.SmoothPlastic
	interiorBack.Color = pickRandom(wallColors)
	interiorBack:SetAttribute("ThemeRole", "shop_wall")
	interiorBack:SetAttribute("BaseColor", interiorBack.Color)
	interiorBack:SetAttribute("BaseMaterial", Enum.Material.SmoothPlastic.Name)
	interiorBack.Parent = building

	-- Awning
	local awning = Instance.new("Part")
	awning.Name = "Awning"
	if facing == "x" then
		awning.Size = Vector3.new(3 * scale, 0.4, W * 0.9)
	else
		awning.Size = Vector3.new(W * 0.9, 0.4, 3 * scale)
	end
	awning.Position = Vector3.new(frontPos.x + awningOffset.x, BUILDING_BASE + floorHeight - 0.5, frontPos.z + awningOffset.z)
	awning.Anchored = true
	awning.Material = awningMaterial
	awning.Color = signColor
	awning:SetAttribute("ThemeRole", "shop_awning")
	awning:SetAttribute("BaseColor", signColor)
	awning:SetAttribute("BaseMaterial", awningMaterial.Name)
	awning.Parent = building

	-- Second floor: smaller windows on front face
	local upWinW = 2.5 * scale
	local upWinH = 3 * scale
	local upWinY = BUILDING_BASE + floorHeight + floorHeight * 0.45
	local numUpWin = math.floor(W / (upWinW + 2))
	local totalUpW = numUpWin * upWinW + (numUpWin - 1) * 2
	local startOff = -totalUpW / 2 + upWinW / 2

	for w = 1, numUpWin do
		local off = startOff + (w - 1) * (upWinW + 2)
		local win = Instance.new("Part")
		win.Name = "UpperWindow"
		if facing == "x" then
			win.Size = Vector3.new(0.3, upWinH, upWinW)
			win.Position = Vector3.new(frontPos.x, upWinY, z + off)
		else
			win.Size = Vector3.new(upWinW, upWinH, 0.3)
			win.Position = Vector3.new(x + off, upWinY, frontPos.z)
		end
		win.Anchored = true
		win.CanCollide = false
		if math.random() < 0.5 then
			win.Material = Enum.Material.Neon
			win.Color = pickRandom(windowColors)
			win:SetAttribute("ThemeRole", "shop_window")
			win:SetAttribute("BaseColor", win.Color)
		else
			win.Material = Enum.Material.Glass
			win.Color = opts.darkWindow or Color3.fromRGB(80, 120, 160)
			win:SetAttribute("ThemeRole", "shop_darkwindow")
			win:SetAttribute("BaseColor", win.Color)
		end
		win.Parent = building
	end

	-- Neon text sign above storefront
	local nameList = opts.nameList or SHOP_NAMES
	local shopName = pickRandom(nameList)
	local signH = 2.5 * scale
	local signW = W * 0.6
	local neonSign = Instance.new("Part")
	neonSign.Name = "NeonSign"
	neonSign.Size = wallSize(0.4, signH, signW)
	if facing == "x" then
		neonSign.Position = Vector3.new(frontPos.x - sign_dir * 0.3, BUILDING_BASE + floorHeight + signH / 2 + 0.5, z)
	else
		neonSign.Position = Vector3.new(x, BUILDING_BASE + floorHeight + signH / 2 + 0.5, frontPos.z + 0.3)
	end
	neonSign.Anchored = true
	neonSign.CanCollide = false
	neonSign.Material = Enum.Material.Neon
	neonSign.Color = signColor
	neonSign:SetAttribute("ThemeRole", "shop_sign")
	neonSign:SetAttribute("BaseColor", signColor)
	neonSign.Parent = building

	-- SurfaceGui with text on the sign face
	local signFace = facing == "x" and (x > 0 and Enum.NormalId.Left or Enum.NormalId.Right) or Enum.NormalId.Back
	local gui = Instance.new("SurfaceGui")
	gui.Name = "SignGui"
	gui.Face = signFace
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 50
	gui.Parent = neonSign

	local label = Instance.new("TextLabel")
	label.Name = "ShopName"
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = shopName
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	label.Font = pickRandom(signFonts)
	label:SetAttribute("ThemeRole", "shop_signtext")
	label.Parent = gui

	-- Roof cap
	local roof = Instance.new("Part")
	if facing == "x" then
		roof.Size = Vector3.new(D + 0.5, 0.5, W + 0.5)
	else
		roof.Size = Vector3.new(W + 0.5, 0.5, D + 0.5)
	end
	roof.Position = Vector3.new(x, BUILDING_BASE + height + 0.25, z)
	roof.Anchored = true
	roof.Material = Enum.Material.Metal
	roof.Color = roofColor
	roof:SetAttribute("ThemeRole", "shop_roof")
	roof:SetAttribute("BaseColor", roofColor)
	roof.Parent = building

	building.Parent = decorFolder
	return building
end

-- SHOP ROW: shops extending outward along X, same as building rows
function Shops.createShopRow(x, z, scale, opts)
	local decorFolder = DecorUtils.decorFolder
	if not decorFolder then return nil end
	scale = scale or 1
	opts = opts or {}
	local bDepth = SHOP_DEPTH_BASE * scale
	local dir = x > 0 and 1 or -1

	-- First shop faces the avenue (glass toward x=0)
	Shops.buildShopUnit(x, z, scale, SHOP_FACADES[1] * scale, "x", opts)

	-- Rest face the player (glass toward -Z)
	local curX = x + dir * bDepth
	for i = 2, #SHOP_FACADES do
		Shops.buildShopUnit(curX, z, scale, SHOP_FACADES[i] * scale, "z", opts)
		curX = curX + dir * bDepth
	end
end

function Shops.createShop(x, z, scale)
	return Shops.createShopRow(x, z, scale)
end

-- Luxury / Rodeo Drive style preset
local LUXURY_OPTS = {
	nameList = {
		"MAISON", "ATELIER", "NOIR", "LUXE", "BIJOUX",
		"HAUTE", "GALLERIA", "BONSOIR", "OPALE", "RIVIERA",
		"LUMIERE", "VELOUR", "PRESTIGE", "PALAZZO", "EDEN",
	},
	wallColors = {
		Color3.fromRGB(245, 240, 230),  -- ivory
		Color3.fromRGB(235, 230, 220),  -- cream
		Color3.fromRGB(225, 220, 215),  -- warm white
		Color3.fromRGB(210, 205, 200),  -- light taupe
		Color3.fromRGB(240, 235, 225),  -- pearl
	},
	signColors = {
		Color3.fromRGB(180, 155, 80),   -- gold
		Color3.fromRGB(30, 30, 30),     -- black
		Color3.fromRGB(25, 25, 50),     -- dark navy
		Color3.fromRGB(140, 120, 65),   -- antique gold
	},
	signFonts = {
		Enum.Font.GothamBold,
		Enum.Font.Oswald,
	},
	windowColors = {
		Color3.fromRGB(255, 240, 200),  -- warm champagne
		Color3.fromRGB(255, 230, 180),  -- soft gold
		Color3.fromRGB(240, 235, 220),  -- warm white
	},
	wallMaterial = Enum.Material.SmoothPlastic,
	awningMaterial = Enum.Material.SmoothPlastic,
	floorColor = Color3.fromRGB(240, 235, 225),
	ceilingColor = Color3.fromRGB(255, 245, 225),
	roofColor = Color3.fromRGB(30, 30, 35),
}

function Shops.createShopLuxury(x, z, scale)
	return Shops.createShopRow(x, z, scale, LUXURY_OPTS)
end

return Shops
