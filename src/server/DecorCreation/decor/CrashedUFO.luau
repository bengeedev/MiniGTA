-- CrashedUFO decor builder
-- Destroyed UFO crash sites for the military zone: real saucer geometry
-- (matching the flying UFO from ProceduralVehicles) tilted on the ground,
-- with scorch marks, fire, smoke, debris, and broken lights.

local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local CrashedUFO = {}

-- Match flying UFO colors from ProceduralVehicles.buildUFO()
local UFO_BODY   = Color3.fromRGB(55, 55, 65)
local UFO_DOME   = Color3.fromRGB(40, 60, 70)
local UFO_GREEN  = Color3.fromRGB(0, 255, 80)
local UFO_RED    = Color3.fromRGB(255, 30, 20)
local UFO_CANNON = Color3.fromRGB(30, 30, 35)

--------------------------------------------------------------------------------
-- HELPER: build a single crash wreck at (wx, wz)
--------------------------------------------------------------------------------

local function createWreck(model, wx, wz, scale)
	local TERRAIN_TOP = DecorUtils.TERRAIN_TOP
	local s = scale

	-- Random tilt for the whole saucer (crashed orientation)
	local yaw = math.rad(math.random(0, 360))
	local tiltAngle = math.rad(20 + math.random() * 20) -- 20-40°

	-- The saucer's center pivot, sitting on the ground and tilted
	local saucerCF = CFrame.new(wx, TERRAIN_TOP + 1 * s, wz)
		* CFrame.Angles(0, yaw, 0)
		* CFrame.Angles(tiltAngle, 0, 0)

	----------------------------------------------------------------------
	-- Saucer disc (main body) — same as flying: cylinder lying flat
	----------------------------------------------------------------------
	local disc = Instance.new("Part")
	disc.Name = "SaucerDisc"
	disc.Shape = Enum.PartType.Cylinder
	disc.Size = Vector3.new(1.8 * s, 18 * s, 18 * s)
	disc.CFrame = saucerCF * CFrame.Angles(0, 0, math.rad(90))
	disc.Anchored = true
	disc.Material = Enum.Material.Metal
	disc.Color = UFO_BODY
	disc.Parent = model

	----------------------------------------------------------------------
	-- Upper ridge
	----------------------------------------------------------------------
	local ridge = Instance.new("Part")
	ridge.Name = "UpperRidge"
	ridge.Shape = Enum.PartType.Cylinder
	ridge.Size = Vector3.new(0.6 * s, 12 * s, 12 * s)
	ridge.CFrame = saucerCF * CFrame.new(0, 0.7 * s, 0) * CFrame.Angles(0, 0, math.rad(90))
	ridge.Anchored = true
	ridge.Material = Enum.Material.Metal
	ridge.Color = UFO_BODY
	ridge.Parent = model

	----------------------------------------------------------------------
	-- Dome (cracked — more transparent, slightly darkened)
	----------------------------------------------------------------------
	local dome = Instance.new("Part")
	dome.Name = "CrackedDome"
	dome.Shape = Enum.PartType.Ball
	dome.Size = Vector3.new(7 * s, 4.5 * s, 7 * s)
	dome.CFrame = saucerCF * CFrame.new(0, 1.8 * s, 0)
	dome.Anchored = true
	dome.Material = Enum.Material.Glass
	dome.Color = UFO_DOME
	dome.Transparency = 0.5
	dome.Parent = model

	----------------------------------------------------------------------
	-- Dome accent lights (4 red, some broken/dimmed)
	----------------------------------------------------------------------
	for i = 0, 3 do
		local angle = math.rad(i * 90)
		local dl = Instance.new("Part")
		dl.Name = "DomeLight"
		dl.Shape = Enum.PartType.Ball
		dl.Size = Vector3.new(0.5 * s, 0.5 * s, 0.5 * s)
		dl.CFrame = saucerCF * CFrame.new(math.cos(angle) * 3 * s, 1.2 * s, math.sin(angle) * 3 * s)
		dl.Anchored = true
		dl.Material = Enum.Material.Neon
		dl.Color = UFO_RED
		-- Some broken (dimmed)
		dl.Transparency = math.random() < 0.5 and 0.8 or 0.1
		dl.CanCollide = false
		dl.Parent = model
	end

	----------------------------------------------------------------------
	-- Rim lights (8 green, most broken/dimmed)
	----------------------------------------------------------------------
	for i = 0, 7 do
		local angle = math.rad(i * 45)
		local rl = Instance.new("Part")
		rl.Name = "RimLight"
		rl.Shape = Enum.PartType.Ball
		rl.Size = Vector3.new(0.9 * s, 0.9 * s, 0.9 * s)
		rl.CFrame = saucerCF * CFrame.new(math.cos(angle) * 8 * s, -0.2 * s, math.sin(angle) * 8 * s)
		rl.Anchored = true
		rl.Material = Enum.Material.Neon
		rl.Color = UFO_GREEN
		-- Most broken, a couple still flicker
		rl.Transparency = math.random() < 0.25 and 0.2 or (0.65 + math.random() * 0.25)
		rl.CanCollide = false
		rl.Parent = model
	end

	----------------------------------------------------------------------
	-- Underside glow ring (damaged, high transparency)
	----------------------------------------------------------------------
	local glow = Instance.new("Part")
	glow.Name = "GlowRing"
	glow.Shape = Enum.PartType.Cylinder
	glow.Size = Vector3.new(0.3 * s, 10 * s, 10 * s)
	glow.CFrame = saucerCF * CFrame.new(0, -0.9 * s, 0) * CFrame.Angles(0, 0, math.rad(90))
	glow.Anchored = true
	glow.Material = Enum.Material.Neon
	glow.Color = UFO_GREEN
	glow.Transparency = 0.7
	glow.CanCollide = false
	glow.Parent = model

	----------------------------------------------------------------------
	-- Cannon mount + barrel (snapped, dangling from underside)
	----------------------------------------------------------------------
	local mount = Instance.new("Part")
	mount.Name = "CannonMount"
	mount.Shape = Enum.PartType.Cylinder
	mount.Size = Vector3.new(1.2 * s, 4 * s, 4 * s)
	mount.CFrame = saucerCF * CFrame.new(0, -1.2 * s, 0) * CFrame.Angles(0, 0, math.rad(90))
	mount.Anchored = true
	mount.Material = Enum.Material.Metal
	mount.Color = UFO_CANNON
	mount.Parent = model

	-- Barrel bent at odd angle (snapped off)
	local barrel = Instance.new("Part")
	barrel.Name = "LaserBarrel"
	barrel.Shape = Enum.PartType.Cylinder
	barrel.Size = Vector3.new(3.5 * s, 1.4 * s, 1.4 * s)
	local barrelTilt = math.rad(30 + math.random() * 40) -- 30-70° from vertical
	barrel.CFrame = saucerCF
		* CFrame.new(0, -1.5 * s, 0)
		* CFrame.Angles(0, math.rad(math.random(0, 360)), barrelTilt)
		* CFrame.new(0, -1.5 * s, 0)
	barrel.Anchored = true
	barrel.Material = Enum.Material.DiamondPlate
	barrel.Color = UFO_CANNON
	barrel.Parent = model

	----------------------------------------------------------------------
	-- Scorch mark (flat dark disc on ground under the wreck)
	----------------------------------------------------------------------
	local scorchDiam = (22 + math.random() * 6) * s -- wider than saucer
	local scorch = Instance.new("Part")
	scorch.Name = "ScorchMark"
	scorch.Shape = Enum.PartType.Cylinder
	scorch.Size = Vector3.new(0.15, scorchDiam, scorchDiam)
	scorch.CFrame = CFrame.new(wx, TERRAIN_TOP + 0.08, wz) * CFrame.Angles(0, 0, math.rad(90))
	scorch.Anchored = true
	scorch.Material = Enum.Material.Neon
	scorch.Color = Color3.fromRGB(60, 35, 5)
	scorch.Transparency = 0.55
	scorch.CanCollide = false
	scorch.Parent = model

	----------------------------------------------------------------------
	-- Fire (same style as Junkyard barrels)
	----------------------------------------------------------------------
	local firePart = Instance.new("Part")
	firePart.Name = "FireSource"
	firePart.Size = Vector3.new(4 * s, 1, 4 * s)
	firePart.CFrame = saucerCF * CFrame.new(0, 0.5 * s, 0)
	firePart.Anchored = true
	firePart.Transparency = 1
	firePart.CanCollide = false
	firePart.Parent = model

	local fire = Instance.new("Fire")
	fire.Size = 12 * s
	fire.Heat = 8
	fire.Color = Color3.fromRGB(255, 140, 30)
	fire.SecondaryColor = Color3.fromRGB(255, 60, 0)
	fire.Parent = firePart

	----------------------------------------------------------------------
	-- Smoke (dark column rising from wreck)
	----------------------------------------------------------------------
	local smokePart = Instance.new("Part")
	smokePart.Name = "SmokeSource"
	smokePart.Size = Vector3.new(6 * s, 1, 6 * s)
	smokePart.CFrame = saucerCF * CFrame.new(0, 1 * s, 0)
	smokePart.Anchored = true
	smokePart.Transparency = 1
	smokePart.CanCollide = false
	smokePart.Parent = model

	local smoke = Instance.new("Smoke")
	smoke.Size = 4 * s
	smoke.RiseVelocity = 2
	smoke.Opacity = 0.15
	smoke.Color = Color3.fromRGB(60, 60, 60)
	smoke.Parent = smokePart

	----------------------------------------------------------------------
	-- Metal debris scattered around the crash site
	----------------------------------------------------------------------
	local debrisCount = math.random(4, 6)
	local debrisColors = {
		Color3.fromRGB(55, 55, 65),
		Color3.fromRGB(45, 45, 50),
		Color3.fromRGB(65, 60, 55),
		Color3.fromRGB(30, 30, 35),
	}
	for i = 1, debrisCount do
		local debris = Instance.new("Part")
		debris.Name = "Debris" .. i
		local dSize = (0.8 + math.random() * 2) * s
		debris.Size = Vector3.new(dSize, dSize * 0.5, dSize * 0.7)
		local angle = math.rad(math.random(0, 360))
		local dist = (10 + math.random() * 8) * s
		debris.CFrame = CFrame.new(
			wx + math.cos(angle) * dist,
			TERRAIN_TOP + dSize * 0.25,
			wz + math.sin(angle) * dist
		) * CFrame.Angles(
			math.rad(math.random(-25, 25)),
			math.rad(math.random(0, 360)),
			math.rad(math.random(-20, 20))
		)
		debris.Anchored = true
		debris.Material = Enum.Material.DiamondPlate
		debris.Color = debrisColors[math.random(#debrisColors)]
		debris.Parent = model
	end
end

--------------------------------------------------------------------------------
-- MAIN BUILDER
--------------------------------------------------------------------------------

function CrashedUFO.createCrashedUFO(x, z, scale)
	local folder = DecorUtils.decorFolder
	if not folder then return nil end
	scale = scale or 1

	local model = Instance.new("Model")
	model.Name = "CrashedUFO"

	-- 5-7 crash wrecks distributed across the full lane depth (60 studs)
	local wreckCount = math.random(5, 7)
	local halfDepth = 28 * scale
	local halfWidth = 30 * scale
	for i = 1, wreckCount do
		-- Evenly space along Z with some jitter
		local t = (i - 0.5) / wreckCount -- 0..1 evenly distributed
		local wz = z + (t * 2 - 1) * halfDepth + (math.random() - 0.5) * 8 * scale
		-- Spread across playable width
		local wx = x + (math.random() - 0.5) * 2 * halfWidth
		createWreck(model, wx, wz, scale)
	end

	model.Parent = folder
	return model
end

return CrashedUFO
