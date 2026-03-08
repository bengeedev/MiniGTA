-- GlassCubeStore: transparent glass cube retail store (Apple Store Fifth Avenue parody)
local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local GlassCubeStore = {}

function GlassCubeStore.createGlassCubeStore(x, z, scale)
	local decorFolder = DecorUtils.decorFolder
	if not decorFolder then return nil end
	scale = scale or 1

	local BUILDING_BASE = DecorUtils.BUILDING_BASE
	local getFrontX = DecorUtils.getFrontX

	local model = Instance.new("Model")
	model.Name = "GlassCubeStore"

	local sign_dir = x > 0 and 1 or -1

	-- Cube dimensions
	local cubeW = 36 * scale -- width (along Z)
	local cubeH = 28 * scale -- height
	local cubeD = 36 * scale -- depth (along X)
	local slabW = 40 * scale
	local slabD = 40 * scale

	-- Center the cube so its front face aligns with the road side
	local frontX = getFrontX(x, cubeD)
	local centerX = frontX + sign_dir * (cubeD / 2)
	local centerZ = z
	local baseY = BUILDING_BASE

	-- Concrete base slab
	local slab = Instance.new("Part")
	slab.Name = "BaseSlab"
	slab.Size = Vector3.new(slabD, 0.5 * scale, slabW)
	slab.Position = Vector3.new(centerX, baseY + 0.25 * scale, centerZ)
	slab.Anchored = true
	slab.Material = Enum.Material.Concrete
	slab.Color = Color3.fromRGB(190, 190, 195)
	slab.Parent = model

	local floorY = baseY + 0.5 * scale -- top of slab

	-- Interior white floor
	local floor = Instance.new("Part")
	floor.Name = "InteriorFloor"
	floor.Size = Vector3.new(cubeD - 1, 0.2, cubeW - 1)
	floor.Position = Vector3.new(centerX, floorY + 0.1, centerZ)
	floor.Anchored = true
	floor.CanCollide = false
	floor.Material = Enum.Material.SmoothPlastic
	floor.Color = Color3.fromRGB(245, 245, 250)
	floor:SetAttribute("ThemeRole", "shop_floor")
	floor:SetAttribute("BaseColor", floor.Color)
	floor.Parent = model

	-- Steel frame: 4 corner posts
	local postThick = 0.5 * scale
	local postH = cubeH
	for dx = -1, 1, 2 do
		for dz = -1, 1, 2 do
			local post = Instance.new("Part")
			post.Name = "CornerPost"
			post.Size = Vector3.new(postThick, postH, postThick)
			post.Position = Vector3.new(
				centerX + dx * (cubeD / 2 - postThick / 2),
				floorY + postH / 2,
				centerZ + dz * (cubeW / 2 - postThick / 2)
			)
			post.Anchored = true
			post.Material = Enum.Material.DiamondPlate
			post.Color = Color3.fromRGB(160, 160, 165)
			post:SetAttribute("ThemeRole", "shop_mullion")
			post:SetAttribute("BaseColor", post.Color)
			post.Parent = model
		end
	end

	-- Horizontal mid-beam (separates upper/lower glass rows)
	local mullionThick = 0.3 * scale
	local midY = floorY + cubeH / 2

	-- Glass panels: 4 walls, each with 4 panels wide x 2 rows tall
	local panelW = (cubeW - postThick * 2 - mullionThick * 3) / 4 -- panels along Z-axis walls
	local panelWx = (cubeD - postThick * 2 - mullionThick * 3) / 4 -- panels along X-axis walls
	local panelH = (cubeH - mullionThick) / 2
	local glassColor = Color3.fromRGB(200, 230, 255)

	-- Helper: build one glass wall
	local function buildWall(axis, faceCoord, wallWidth, panelCount)
		local pw = (wallWidth - postThick * 2 - mullionThick * (panelCount - 1)) / panelCount
		local startOffset = -wallWidth / 2 + postThick + pw / 2

		for row = 0, 1 do
			local rowY = floorY + mullionThick / 2 + panelH / 2 + row * (panelH + mullionThick)

			for col = 0, panelCount - 1 do
				local offset = startOffset + col * (pw + mullionThick)

				local panel = Instance.new("Part")
				panel.Name = "GlassPanel"
				if axis == "x" then
					panel.Size = Vector3.new(0.2, panelH, pw)
					panel.Position = Vector3.new(faceCoord, rowY, centerZ + offset)
				else
					panel.Size = Vector3.new(pw, panelH, 0.2)
					panel.Position = Vector3.new(centerX + offset, rowY, faceCoord)
				end
				panel.Anchored = true
				panel.CanCollide = false
				panel.Material = Enum.Material.Glass
				panel.Color = glassColor
				panel.Transparency = 0.6
				panel:SetAttribute("ThemeRole", "shop_glass")
				panel:SetAttribute("BaseColor", glassColor)
				panel.Parent = model
			end

			-- Horizontal mullion between rows (only after first row)
			if row == 0 then
				local hMullion = Instance.new("Part")
				hMullion.Name = "HMullion"
				if axis == "x" then
					hMullion.Size = Vector3.new(mullionThick, mullionThick, wallWidth - postThick * 2)
					hMullion.Position = Vector3.new(faceCoord, midY, centerZ)
				else
					hMullion.Size = Vector3.new(wallWidth - postThick * 2, mullionThick, mullionThick)
					hMullion.Position = Vector3.new(centerX, midY, faceCoord)
				end
				hMullion.Anchored = true
				hMullion.CanCollide = false
				hMullion.Material = Enum.Material.DiamondPlate
				hMullion.Color = Color3.fromRGB(160, 160, 165)
				hMullion:SetAttribute("ThemeRole", "shop_mullion")
				hMullion:SetAttribute("BaseColor", hMullion.Color)
				hMullion.Parent = model
			end
		end

		-- Vertical mullions between panels
		for col = 1, panelCount - 1 do
			local offset = startOffset + (col - 1) * (pw + mullionThick) + pw + mullionThick / 2
			local vMullion = Instance.new("Part")
			vMullion.Name = "VMullion"
			if axis == "x" then
				vMullion.Size = Vector3.new(mullionThick, cubeH, mullionThick)
				vMullion.Position = Vector3.new(faceCoord, floorY + cubeH / 2, centerZ + offset)
			else
				vMullion.Size = Vector3.new(mullionThick, cubeH, mullionThick)
				vMullion.Position = Vector3.new(centerX + offset, floorY + cubeH / 2, faceCoord)
			end
			vMullion.Anchored = true
			vMullion.CanCollide = false
			vMullion.Material = Enum.Material.DiamondPlate
			vMullion.Color = Color3.fromRGB(160, 160, 165)
			vMullion:SetAttribute("ThemeRole", "shop_mullion")
			vMullion:SetAttribute("BaseColor", vMullion.Color)
			vMullion.Parent = model
		end
	end

	-- Front and back walls (X-axis faces, span along Z = cubeW)
	buildWall("x", centerX - cubeD / 2, cubeW, 4)
	buildWall("x", centerX + cubeD / 2, cubeW, 4)
	-- Side walls (Z-axis faces, span along X = cubeD)
	buildWall("z", centerZ - cubeW / 2, cubeD, 4)
	buildWall("z", centerZ + cubeW / 2, cubeD, 4)

	-- Flat roof
	local roof = Instance.new("Part")
	roof.Name = "Roof"
	roof.Size = Vector3.new(cubeD + 0.4, 0.4 * scale, cubeW + 0.4)
	roof.Position = Vector3.new(centerX, floorY + cubeH + 0.2 * scale, centerZ)
	roof.Anchored = true
	roof.Material = Enum.Material.DiamondPlate
	roof.Color = Color3.fromRGB(170, 170, 175)
	roof:SetAttribute("ThemeRole", "shop_roof")
	roof:SetAttribute("BaseColor", roof.Color)
	roof.Parent = model

	-- Interior tables: 4 tables in 2 rows
	local tableH = 3 * scale
	local tableW = 10 * scale
	local tableD = 2.5 * scale
	for row = -1, 1, 2 do
		for col = -1, 1, 2 do
			local table = Instance.new("Part")
			table.Name = "DisplayTable"
			table.Size = Vector3.new(tableD, tableH, tableW)
			table.Position = Vector3.new(
				centerX + row * 8 * scale,
				floorY + tableH / 2,
				centerZ + col * 8 * scale
			)
			table.Anchored = true
			table.Material = Enum.Material.SmoothPlastic
			table.Color = Color3.fromRGB(240, 240, 245)
			table:SetAttribute("ThemeRole", "shop_floor")
			table:SetAttribute("BaseColor", table.Color)
			table.Parent = model

			-- Devices on each table (4 per table)
			for d = -1.5, 1.5, 1 do
				local device = Instance.new("Part")
				device.Name = "Device"
				device.Size = Vector3.new(1.2 * scale, 0.15 * scale, 0.8 * scale)
				device.Position = Vector3.new(
					centerX + row * 8 * scale,
					floorY + tableH + 0.075 * scale,
					centerZ + col * 8 * scale + d * 2.2 * scale
				)
				device.Anchored = true
				device.CanCollide = false
				device.Material = Enum.Material.Neon
				device.Color = Color3.fromRGB(255, 255, 255)
				device.Parent = model
			end
		end
	end

	-- Ceiling light strip
	local ceilingLight = Instance.new("Part")
	ceilingLight.Name = "CeilingLight"
	ceilingLight.Size = Vector3.new(cubeD * 0.6, 0.3, cubeW * 0.6)
	ceilingLight.Position = Vector3.new(centerX, floorY + cubeH - 0.3, centerZ)
	ceilingLight.Anchored = true
	ceilingLight.CanCollide = false
	ceilingLight.Material = Enum.Material.Neon
	ceilingLight.Color = Color3.fromRGB(255, 255, 255)
	ceilingLight:SetAttribute("ThemeRole", "shop_ceiling")
	ceilingLight:SetAttribute("BaseColor", ceilingLight.Color)
	ceilingLight.Parent = model

	local pointLight = Instance.new("PointLight")
	pointLight.Color = Color3.fromRGB(255, 255, 255)
	pointLight.Brightness = 0.8
	pointLight.Range = 28
	pointLight.Parent = ceilingLight

	-- Glowing logo on front face (facing the road / x=0)
	local logoSize = 14 * scale
	local logoPart = Instance.new("Part")
	logoPart.Name = "LogoGlow"
	logoPart.Size = Vector3.new(0.4, logoSize, logoSize)
	-- Place just outside the glass face so it's clearly visible
	local logoX = centerX - sign_dir * (cubeD / 2 + 0.25)
	logoPart.Position = Vector3.new(logoX, floorY + cubeH * 0.62, centerZ)
	logoPart.Anchored = true
	logoPart.CanCollide = false
	logoPart.Material = Enum.Material.SmoothPlastic
	logoPart.Color = Color3.fromRGB(255, 255, 255)
	logoPart.Transparency = 1
	logoPart.Parent = model

	local logoGlow = Instance.new("PointLight")
	logoGlow.Color = Color3.fromRGB(255, 255, 255)
	logoGlow.Brightness = 1.2
	logoGlow.Range = 16
	logoGlow.Parent = logoPart

	local logoGui = Instance.new("SurfaceGui")
	logoGui.Name = "LogoGui"
	logoGui.Face = x > 0 and Enum.NormalId.Left or Enum.NormalId.Right
	logoGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	logoGui.PixelsPerStud = 50
	logoGui.LightInfluence = 0
	logoGui.Parent = logoPart

	local logoImage = Instance.new("ImageLabel")
	logoImage.Name = "Logo"
	logoImage.Size = UDim2.new(1, 0, 1, 0)
	logoImage.BackgroundTransparency = 1
	logoImage.Image = "rbxassetid://73932591058200"
	logoImage.ImageColor3 = Color3.fromRGB(255, 255, 255)
	logoImage.ScaleType = Enum.ScaleType.Fit
	logoImage.Parent = logoGui

	model.Parent = decorFolder
	return model
end

return GlassCubeStore
