local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))
local Shops = require(script.Parent:WaitForChild("Shops"))

local HoodBuilding = {}

local HOOD_WALL_COLORS = {
	Color3.fromRGB(140, 120, 100),  -- dirty beige
	Color3.fromRGB(120, 110, 100),  -- grimy grey
	Color3.fromRGB(130, 100, 80),   -- faded brown
	Color3.fromRGB(110, 105, 95),   -- dark concrete
	Color3.fromRGB(100, 90, 80),    -- smoky
}

local HOOD_SHOP_NAMES = {
	"LAUNDRY", "BARBER", "BODEGA", "TIRES", "99c STORE",
	"AUTO PARTS", "NAILS", "CHICKEN", "TACOS", "PHONE FIX",
	"SNEAKERS", "MUSIC", "PET SHOP", "CANDY", "JUICE BAR",
}

function HoodBuilding.createHoodBuilding(x, z, scale)
	local decorFolder = DecorUtils.decorFolder
	if not decorFolder then return nil end
	scale = scale or 1
	local BUILDING_BASE = DecorUtils.BUILDING_BASE
	local getFrontX = DecorUtils.getFrontX
	local SHOP_DEPTH_BASE = Shops.SHOP_DEPTH_BASE
	local SHOP_FACADES = Shops.SHOP_FACADES

	local sign_dir = x > 0 and 1 or -1
	local bDepth = SHOP_DEPTH_BASE * scale
	local shopFloorH = 10 * scale  -- shop is 2 floors (20 studs)
	local shopH = 2 * shopFloorH

	-- Build shops (same layout as createShopRow: first faces road, rest face player)
	-- Then stack hood apartment floors on top of each
	local facades = SHOP_FACADES
	local curX = x

	for i = 1, #facades do
		local facadeLen = facades[i] * scale
		local facing = (i == 1) and "x" or "z"

		-- Shop at ground level (reuse existing shop builder, hood names)
		Shops.buildShopUnit(curX, z, scale, facadeLen, facing, { nameList = HOOD_SHOP_NAMES })

		-- Hood apartment block on top of the shop
		local extraFloors = math.random(2, 4)
		local floorH = 8 * scale
		local extraH = extraFloors * floorH
		local wallColor = HOOD_WALL_COLORS[math.random(#HOOD_WALL_COLORS)]

		local upper = Instance.new("Model")
		upper.Name = "HoodUpper"

		-- Body size depends on facing
		local bodyW, bodyD
		if facing == "x" then
			bodyW = facadeLen  -- along Z
			bodyD = bDepth     -- along X
		else
			bodyW = bDepth     -- along Z
			bodyD = facadeLen  -- along X
		end

		-- Main brick body
		local body = Instance.new("Part")
		body.Name = "UpperBody"
		body.Size = Vector3.new(bodyD, extraH, bodyW)
		body.Position = Vector3.new(curX, BUILDING_BASE + shopH + extraH / 2, z)
		body.Anchored = true
		body.Material = Enum.Material.Brick
		body.Color = wallColor
		body:SetAttribute("ThemeRole", "building_body")
		body:SetAttribute("BaseColor", wallColor)
		body:SetAttribute("BaseMaterial", "Brick")
		body.Parent = upper

		-- Windows on the front face (facing the road for "x", facing player for "z")
		local winW = 2 * scale
		local winH = 3 * scale
		local winGap = 2 * scale
		local winFacade = (facing == "x") and bodyW or bodyD
		local available = winFacade - 3
		local numWin = math.floor((available + winGap) / (winW + winGap))
		if numWin > 0 then
			local totalWinW = numWin * winW + (numWin - 1) * winGap
			local winStart = -totalWinW / 2 + winW / 2

			for floor = 1, extraFloors do
				local floorY = BUILDING_BASE + shopH + (floor - 0.5) * floorH
				for w = 1, numWin do
					local offset = winStart + (w - 1) * (winW + winGap)
					local win = Instance.new("Part")
					win.Name = "Window"
					win.Anchored = true
					win.CanCollide = false

					if facing == "x" then
						local frontX = getFrontX(curX, bodyD)
						win.Size = Vector3.new(0.3, winH, winW)
						win.Position = Vector3.new(frontX, floorY, z + offset)
					else
						win.Size = Vector3.new(winW, winH, 0.3)
						win.Position = Vector3.new(curX + offset, floorY, z + bodyW / 2 + 0.2)
					end

					if math.random() < 0.4 then
						win.Material = Enum.Material.Neon
						win.Color = Color3.fromRGB(255, 200, 100)
						win:SetAttribute("ThemeRole", "building_window_lit")
						win:SetAttribute("BaseColor", Color3.fromRGB(255, 200, 100))
						win:SetAttribute("BaseMaterial", "Neon")
					else
						win.Material = Enum.Material.Glass
						win.Color = Color3.fromRGB(50, 60, 70)
						win:SetAttribute("ThemeRole", "building_window")
						win:SetAttribute("BaseColor", Color3.fromRGB(50, 60, 70))
						win:SetAttribute("BaseMaterial", "Glass")
					end
					win.Parent = upper
				end
			end
		end

		-- Flat roof edge
		local roofEdge = Instance.new("Part")
		roofEdge.Name = "RoofEdge"
		roofEdge.Size = Vector3.new(bodyD + 0.5, 0.8, bodyW + 0.5)
		roofEdge.Position = Vector3.new(curX, BUILDING_BASE + shopH + extraH + 0.4, z)
		roofEdge.Anchored = true
		roofEdge.Material = Enum.Material.Concrete
		roofEdge.Color = Color3.fromRGB(80, 75, 70)
		roofEdge:SetAttribute("ThemeRole", "building_roof")
		roofEdge:SetAttribute("BaseColor", Color3.fromRGB(80, 75, 70))
		roofEdge:SetAttribute("BaseMaterial", "Concrete")
		roofEdge.Parent = upper

		upper.Parent = decorFolder
		curX = curX + sign_dir * bDepth
	end
end

return HoodBuilding
