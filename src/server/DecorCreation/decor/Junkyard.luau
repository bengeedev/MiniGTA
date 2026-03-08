local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))
local Fences = require(script.Parent:WaitForChild("Fences"))
local JunkCar = require(script.Parent:WaitForChild("JunkCar"))

local Junkyard = {}

function Junkyard.createJunkyard(x, z, scale)
	local decorFolder = DecorUtils.decorFolder
	if not decorFolder then return nil end
	scale = scale or 1
	local TERRAIN_TOP = DecorUtils.TERRAIN_TOP

	local model = Instance.new("Model")
	model.Name = "Junkyard"

	-- Match building lane positioning: buildings start at x and extend outward
	-- x is already half + offsetX (e.g. 40+10=50 for right side)
	local sign = x > 0 and 1 or -1
	local innerX = x                        -- fence starts at road edge
	local outerX = x + sign * 50 * scale    -- fence extends 50 studs outward (wide)
	local halfD = 18 * scale                -- depth along Z

	-- 4 corners for the enclosure (always wound correctly)
	local x1 = math.min(innerX, outerX)
	local x2 = math.max(innerX, outerX)
	local corners = {
		{ x = x1, z = z - halfD },
		{ x = x2, z = z - halfD },
		{ x = x2, z = z + halfD },
		{ x = x1, z = z + halfD },
	}
	Fences.createCrossGridFence(model, corners, 16 * scale)

	-- Center of the enclosure for barrel placement
	local cx = (innerX + outerX) / 2

	-- Oil barrels (cylinders) spread across the wider enclosure
	local barrelPositions = {
		{ dx = -15, dz = -8  },
		{ dx = -5,  dz = -10 },
		{ dx = 8,   dz = -4  },
		{ dx = -18, dz = 5   },
		{ dx = 12,  dz = 8   },
		{ dx = 0,   dz = 2   },
		{ dx = 18,  dz = -6  },
	}
	-- Oil drum colors (dark industrial, not rust)
	local drumColors = {
		Color3.fromRGB(35, 55, 35),   -- dark green
		Color3.fromRGB(30, 35, 55),   -- dark blue
		Color3.fromRGB(50, 40, 30),   -- dark brown
		Color3.fromRGB(55, 30, 30),   -- dark red
		Color3.fromRGB(40, 40, 45),   -- charcoal
	}
	for _, bp in ipairs(barrelPositions) do
		local bx = cx + bp.dx * scale
		local bz = z + bp.dz * scale
		local barrelH = 5 * scale
		local barrelD = 3 * scale
		local baseY = TERRAIN_TOP + 2
		local drumColor = drumColors[math.random(#drumColors)]

		-- Outer shell (painted metal drum)
		local shell = Instance.new("Part")
		shell.Name = "OilBarrel"
		shell.Shape = Enum.PartType.Cylinder
		shell.Size = Vector3.new(barrelH, barrelD, barrelD)
		shell.CFrame = CFrame.new(bx, baseY + barrelH / 2, bz) * CFrame.Angles(0, 0, math.rad(90))
		shell.Anchored = true
		shell.Material = Enum.Material.DiamondPlate
		shell.Color = drumColor
		shell.Parent = model

		-- Dark inner cavity (visible hollow from top)
		local inner = Instance.new("Part")
		inner.Name = "BarrelInner"
		inner.Shape = Enum.PartType.Cylinder
		inner.Size = Vector3.new(barrelH * 0.85, barrelD * 0.75, barrelD * 0.75)
		inner.CFrame = CFrame.new(bx, baseY + barrelH / 2 + 0.3, bz) * CFrame.Angles(0, 0, math.rad(90))
		inner.Anchored = true
		inner.Material = Enum.Material.Metal
		inner.Color = Color3.fromRGB(15, 15, 18)
		inner.Parent = model

		-- Top rim ring
		local rim = Instance.new("Part")
		rim.Name = "BarrelRim"
		rim.Shape = Enum.PartType.Cylinder
		rim.Size = Vector3.new(0.3, barrelD + 0.3, barrelD + 0.3)
		rim.CFrame = CFrame.new(bx, baseY + barrelH - 0.1, bz) * CFrame.Angles(0, 0, math.rad(90))
		rim.Anchored = true
		rim.Material = Enum.Material.Metal
		rim.Color = Color3.fromRGB(60, 60, 65)
		rim.Parent = model

		-- Bottom rim ring
		local rimBot = Instance.new("Part")
		rimBot.Name = "BarrelRimBot"
		rimBot.Shape = Enum.PartType.Cylinder
		rimBot.Size = Vector3.new(0.3, barrelD + 0.3, barrelD + 0.3)
		rimBot.CFrame = CFrame.new(bx, baseY + 0.15, bz) * CFrame.Angles(0, 0, math.rad(90))
		rimBot.Anchored = true
		rimBot.Material = Enum.Material.Metal
		rimBot.Color = Color3.fromRGB(60, 60, 65)
		rimBot.Parent = model

		-- Fire source covers full barrel top
		local firePart = Instance.new("Part")
		firePart.Name = "FireSource"
		firePart.Size = Vector3.new(barrelD * 0.8, 0.5, barrelD * 0.8)
		firePart.Position = Vector3.new(bx, baseY + barrelH * 0.7, bz)
		firePart.Anchored = true
		firePart.Transparency = 1
		firePart.CanCollide = false
		firePart.Parent = model

		local fire = Instance.new("Fire")
		fire.Size = 8
		fire.Heat = 6
		fire.Color = Color3.fromRGB(255, 140, 30)
		fire.SecondaryColor = Color3.fromRGB(255, 60, 0)
		fire.Parent = firePart
	end

	-- Junk cars arranged in piles (procedural)
	local groundY = TERRAIN_TOP + 5
	local carPlacements = {
		{ variant = 1, dx = -15, dz = -5, rot = 25 },
		{ variant = 3, dx = -12, dz = 3,  rot = -50 },
		{ variant = 2, dx = 10,  dz = -6, rot = -40 },
		{ variant = 4, dx = 14,  dz = 4,  rot = 60 },
		{ variant = 5, dx = -5,  dz = -10, rot = 45 },
		{ variant = 1, dx = 0,   dz = 8,  rot = -70 },
		{ variant = 3, dx = -18, dz = 10, rot = 15 },
		{ variant = 2, dx = 18,  dz = -2, rot = -30 },
	}
	for i, cp in ipairs(carPlacements) do
		local car = JunkCar.build(cp.variant, i + 100)
		local carX = cx + cp.dx * scale
		local carZ = z + cp.dz * scale
		car:PivotTo(CFrame.new(carX, groundY, carZ) * CFrame.Angles(0, math.rad(cp.rot), 0))
		car.Parent = model
	end

	model.Parent = decorFolder
	return model
end

return Junkyard
