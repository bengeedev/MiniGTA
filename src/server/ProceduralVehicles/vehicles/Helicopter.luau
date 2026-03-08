-- Helicopter.luau
-- Police helicopter with bubble glass canopy (hirondelle style), spinning rotor disc,
-- searchlight beam. NPCs clearly visible through transparent cabin.
-- Follows UFO.luau pattern: build(modelName, beamColor, beamCoreColor)

local VU = require(script.Parent:WaitForChild("VehicleUtils"))

local Helicopter = {}

-- Color constants
local BODY_DARK   = Color3.fromRGB(25, 25, 30)      -- dark fuselage
local BODY_ACCENT = Color3.fromRGB(45, 45, 50)      -- slightly lighter panels
local GLASS_TINT  = Color3.fromRGB(120, 160, 200)   -- light blue-tinted glass
local METAL       = Color3.fromRGB(160, 160, 165)    -- metal struts/skids
local WHITE       = Color3.fromRGB(240, 240, 245)    -- white police markings
local RED_LIGHT   = Color3.fromRGB(255, 30, 20)
local BLUE_LIGHT  = Color3.fromRGB(30, 100, 255)
local DASH_COLOR  = Color3.fromRGB(35, 35, 40)       -- instrument panel

-- Exported beam presets
Helicopter.SEARCHLIGHT = Color3.fromRGB(255, 240, 200)  -- warm white
Helicopter.RED_BEAM    = Color3.fromRGB(255, 50, 30)    -- red targeting

function Helicopter.build(modelName, beamColor, beamCoreColor)
	local model = Instance.new("Model")
	model.Name = modelName

	-- Invisible root (same pattern as UFO -- PivotTo anchor)
	local root = VU.part(model, "Root",
		Vector3.new(1, 1, 1),
		CFrame.new(0, 0, 0),
		BODY_DARK, Enum.Material.SmoothPlastic)
	root.Transparency = 1

	---------------------------------------------------------------------------
	-- CABIN DIMENSIONS
	---------------------------------------------------------------------------
	local cabinW = 6
	local cabinH = 5
	local cabinD = 8
	local floorY = -cabinH / 2
	local roofY  = cabinH / 2
	local pillarT = 0.25  -- pillar thickness

	---------------------------------------------------------------------------
	-- OPAQUE HULL (floor + rear engine bay + roof spine)
	---------------------------------------------------------------------------

	-- Floor pan (belly of helicopter)
	VU.part(model, "Floor",
		Vector3.new(cabinW, 0.4, cabinD + 2),
		CFrame.new(0, floorY, 0.5),
		BODY_DARK, Enum.Material.Metal)

	-- Rear engine cowling (back 40% of cabin, opaque -- hides engine)
	VU.part(model, "EngineCowl",
		Vector3.new(cabinW, cabinH * 0.5, cabinD * 0.35),
		CFrame.new(0, roofY - cabinH * 0.25, -cabinD * 0.33),
		BODY_ACCENT, Enum.Material.Metal)

	-- Thin roof panel
	VU.part(model, "Roof",
		Vector3.new(cabinW - 0.4, 0.3, cabinD * 0.6),
		CFrame.new(0, roofY, cabinD * 0.1),
		BODY_DARK, Enum.Material.Metal)

	---------------------------------------------------------------------------
	-- STRUCTURAL FRAME (thin dark pillars -- hirondelle skeleton)
	---------------------------------------------------------------------------

	-- 4 corner pillars
	for _, sx in ipairs({-1, 1}) do
		-- Front A-pillars (angled slightly outward at top)
		VU.part(model, "APillar",
			Vector3.new(pillarT, cabinH - 0.4, pillarT),
			CFrame.new(sx * (cabinW / 2 - pillarT), 0, cabinD / 2 - 0.2),
			BODY_DARK, Enum.Material.Metal)

		-- Rear C-pillars
		VU.part(model, "CPillar",
			Vector3.new(pillarT, cabinH - 0.4, pillarT),
			CFrame.new(sx * (cabinW / 2 - pillarT), 0, -cabinD * 0.3),
			BODY_DARK, Enum.Material.Metal)

		-- Mid B-pillar (between front door and rear window)
		VU.part(model, "BPillar",
			Vector3.new(pillarT, cabinH - 0.4, pillarT),
			CFrame.new(sx * (cabinW / 2 - pillarT), 0, cabinD * 0.1),
			BODY_DARK, Enum.Material.Metal)
	end

	-- Top frame rails (thin horizontal connecting bars at roof)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "RoofRailSide",
			Vector3.new(pillarT, pillarT, cabinD * 0.85),
			CFrame.new(sx * (cabinW / 2 - pillarT), roofY - 0.15, cabinD * 0.1),
			BODY_DARK, Enum.Material.Metal)
	end

	-- Front cross rail
	VU.part(model, "RoofRailFront",
		Vector3.new(cabinW, pillarT, pillarT),
		CFrame.new(0, roofY - 0.15, cabinD / 2 - 0.2),
		BODY_DARK, Enum.Material.Metal)

	---------------------------------------------------------------------------
	-- GLASS CANOPY (flat panels framed by pillars -- clean, no bulge)
	---------------------------------------------------------------------------

	-- Front windshield (flat panel, angled slightly back)
	local ws = VU.part(model, "Windshield",
		Vector3.new(cabinW - 0.5, cabinH - 0.4, 0.12),
		CFrame.new(0, 0.1, cabinD / 2 - 0.1)
			* CFrame.Angles(math.rad(10), 0, 0),
		GLASS_TINT, Enum.Material.Glass)
	ws.Transparency = 0.55

	-- Side glass panels (left and right -- 2 panels per side: front door + rear)
	for _, sx in ipairs({-1, 1}) do
		-- Front side (door area -- large panel)
		local frontSide = VU.part(model, "SideGlassFront",
			Vector3.new(0.12, cabinH - 0.6, cabinD * 0.38),
			CFrame.new(sx * (cabinW / 2 + 0.02), 0.1, cabinD * 0.2),
			GLASS_TINT, Enum.Material.Glass)
		frontSide.Transparency = 0.55

		-- Rear side panel (smaller)
		local rearSide = VU.part(model, "SideGlassRear",
			Vector3.new(0.12, cabinH - 1.2, cabinD * 0.25),
			CFrame.new(sx * (cabinW / 2 + 0.02), 0.2, -cabinD * 0.1),
			GLASS_TINT, Enum.Material.Glass)
		rearSide.Transparency = 0.55
	end

	-- Rear glass panel (small window into engine bay)
	local rearGlass = VU.part(model, "RearGlass",
		Vector3.new(cabinW - 1, cabinH * 0.4, 0.12),
		CFrame.new(0, 0.8, -cabinD * 0.3 + 0.1),
		GLASS_TINT, Enum.Material.Glass)
	rearGlass.Transparency = 0.6

	---------------------------------------------------------------------------
	-- COCKPIT INTERIOR (dashboard + seats visible through glass)
	---------------------------------------------------------------------------

	-- Dashboard / instrument panel (dark strip at front interior)
	VU.part(model, "Dashboard",
		Vector3.new(cabinW - 1, 1.5, 0.5),
		CFrame.new(0, floorY + 1.5, cabinD / 2 - 0.5),
		DASH_COLOR, Enum.Material.SmoothPlastic)

	-- Center console (between pilot seats)
	VU.part(model, "Console",
		Vector3.new(0.6, 0.8, 2.5),
		CFrame.new(0, floorY + 0.8, cabinD * 0.15),
		DASH_COLOR, Enum.Material.SmoothPlastic)

	-- Cyclic sticks (thin cylinders in front of each seat)
	for _, sx in ipairs({-1, 1}) do
		VU.cylinder(model, "CyclicStick",
			Vector3.new(1.2, 0.15, 0.15),
			CFrame.new(sx * 1.5, floorY + 1.0, cabinD / 2 - 1.5)
				* CFrame.Angles(0, 0, math.rad(90))
				* CFrame.Angles(math.rad(-15), 0, 0),
			BODY_DARK, Enum.Material.Metal)
	end

	---------------------------------------------------------------------------
	-- TAIL BOOM
	---------------------------------------------------------------------------
	local tailLen = 12
	local tailStartZ = -cabinD / 2

	VU.part(model, "TailBoom",
		Vector3.new(1.8, 1.8, tailLen),
		CFrame.new(0, 0.5, tailStartZ - tailLen / 2),
		BODY_ACCENT, Enum.Material.Metal)

	-- Tail fin (vertical stabilizer)
	VU.part(model, "TailFin",
		Vector3.new(0.3, 4, 3),
		CFrame.new(0, 2.5, tailStartZ - tailLen + 1.5),
		BODY_DARK, Enum.Material.Metal)

	-- Horizontal stabilizer
	VU.part(model, "HorizStab",
		Vector3.new(5, 0.3, 2),
		CFrame.new(0, 1, tailStartZ - tailLen + 1),
		BODY_DARK, Enum.Material.Metal)

	---------------------------------------------------------------------------
	-- TAIL ROTOR (sub-Model "TailRotor" — spun by client VehicleSystem)
	---------------------------------------------------------------------------
	local tailRotorY = 2.5
	local tailRotorZ = tailStartZ - tailLen + 1.5
	local BLADE_COLOR = Color3.fromRGB(50, 50, 55)

	-- Tail rotor hub (static, on main model — NOT spun)
	VU.cylinder(model, "TailRotorHub",
		Vector3.new(0.4, 0.8, 0.8),
		CFrame.new(0.3, tailRotorY, tailRotorZ)
			* CFrame.Angles(0, 0, math.rad(90)),
		METAL, Enum.Material.Metal)

	-- Tail blur disc (static, on main model — flat on X axis matching blade rotation)
	local tailDisc = VU.cylinder(model, "TailRotorBlur",
		Vector3.new(0.08, 3.5, 3.5),
		CFrame.new(0.3, tailRotorY, tailRotorZ),
		Color3.fromRGB(180, 180, 185), Enum.Material.Neon)
	tailDisc.Transparency = 0.85

	-- Tail rotor spinning assembly (blades only — no cylinder Z-rotation to corrupt spin)
	local tailRotorModel = Instance.new("Model")
	tailRotorModel.Name = "TailRotor"

	local tailBladeLen = 1.6
	local tailBladeW = 0.4
	-- Invisible pivot anchor at tail rotor center
	local tailPivot = VU.part(tailRotorModel, "TailPivot",
		Vector3.new(0.1, 0.1, 0.1),
		CFrame.new(0.3, tailRotorY, tailRotorZ),
		BLADE_COLOR, Enum.Material.SmoothPlastic)
	tailPivot.Transparency = 1

	for i = 0, 1 do
		local angle = math.rad(i * 90 + 25)
		VU.part(tailRotorModel, "TailBlade",
			Vector3.new(0.08, tailBladeLen * 2, tailBladeW),
			CFrame.new(0.3, tailRotorY, tailRotorZ)
				* CFrame.Angles(angle, 0, 0),
			BLADE_COLOR, Enum.Material.Metal)
	end

	tailRotorModel.PrimaryPart = tailPivot
	tailRotorModel.Parent = model

	---------------------------------------------------------------------------
	-- MAIN ROTOR (sub-Model "MainRotor" — spun by client VehicleSystem)
	---------------------------------------------------------------------------
	local rotorY = roofY + 0.3
	local bladeLen = 10.5   -- half-span (total diameter ~21)
	local bladeW = 0.9      -- blade chord width
	local bladeH = 0.12     -- blade thickness

	-- Rotor mast (fixed to body, NOT part of spinning assembly)
	VU.cylinder(model, "RotorMast",
		Vector3.new(1.5, 0.8, 0.8),
		CFrame.new(0, rotorY + 0.75, 0)
			* CFrame.Angles(0, 0, math.rad(90)),
		METAL, Enum.Material.Metal)

	-- Hub cap (static, on main model — NOT spun)
	VU.cylinder(model, "RotorHub",
		Vector3.new(0.6, 2.0, 2.0),
		CFrame.new(0, rotorY + 1.6, 0)
			* CFrame.Angles(0, 0, math.rad(90)),
		BODY_DARK, Enum.Material.Metal)

	-- Motion blur disc (static, on main model)
	local blurDisc = VU.cylinder(model, "RotorBlur",
		Vector3.new(0.06, 22, 22),
		CFrame.new(0, rotorY + 1.5, 0)
			* CFrame.Angles(0, 0, math.rad(90)),
		Color3.fromRGB(200, 200, 205), Enum.Material.Neon)
	blurDisc.Transparency = 0.88

	-- Main rotor spinning assembly (blades only — no cylinder Z-rotation to corrupt spin)
	local mainRotorModel = Instance.new("Model")
	mainRotorModel.Name = "MainRotor"

	local hubY = rotorY + 1.6
	-- Invisible pivot anchor at rotor center
	local mainPivot = VU.part(mainRotorModel, "MainPivot",
		Vector3.new(0.1, 0.1, 0.1),
		CFrame.new(0, hubY, 0),
		BLADE_COLOR, Enum.Material.SmoothPlastic)
	mainPivot.Transparency = 1

	-- 4 main rotor blades
	for i = 0, 3 do
		local angle = math.rad(i * 90 + 15)
		local dx = math.cos(angle) * (bladeLen / 2 + 0.8)
		local dz = math.sin(angle) * (bladeLen / 2 + 0.8)

		VU.part(mainRotorModel, "RotorBlade",
			Vector3.new(bladeLen, bladeH, bladeW),
			CFrame.new(dx, hubY, dz)
				* CFrame.Angles(0, -angle, 0),
			BLADE_COLOR, Enum.Material.Metal)

		VU.part(mainRotorModel, "BladeTip",
			Vector3.new(1.5, bladeH, bladeW + 0.15),
			CFrame.new(
				math.cos(angle) * (bladeLen + 0.5),
				hubY,
				math.sin(angle) * (bladeLen + 0.5))
				* CFrame.Angles(0, -angle, 0),
			WHITE, Enum.Material.Metal)
	end

	mainRotorModel.PrimaryPart = mainPivot
	mainRotorModel.Parent = model

	---------------------------------------------------------------------------
	-- LANDING SKIDS
	---------------------------------------------------------------------------
	local skidY = floorY - 1.5
	local skidLen = cabinD + 2

	for _, sx in ipairs({-1, 1}) do
		local skidX = sx * 2.8

		VU.cylinder(model, "Skid",
			Vector3.new(skidLen, 0.4, 0.4),
			CFrame.new(skidX, skidY, 0)
				* CFrame.Angles(0, math.rad(90), 0),
			METAL, Enum.Material.Metal)

		-- Front strut
		VU.part(model, "SkidStrut",
			Vector3.new(0.3, 1.8, 0.3),
			CFrame.new(skidX, skidY + 0.9, cabinD / 2 - 1),
			METAL, Enum.Material.Metal)

		-- Rear strut
		VU.part(model, "SkidStrut",
			Vector3.new(0.3, 1.8, 0.3),
			CFrame.new(skidX, skidY + 0.9, -cabinD / 2 + 1),
			METAL, Enum.Material.Metal)
	end

	---------------------------------------------------------------------------
	-- POLICE LIGHTS (red + blue on roof)
	---------------------------------------------------------------------------
	local lightY = roofY + 0.3

	local redLight = VU.ball(model, "LightRed",
		Vector3.new(0.8, 0.8, 0.8),
		CFrame.new(-1.2, lightY, cabinD / 2 - 0.5),
		RED_LIGHT, Enum.Material.Neon)
	local rl = Instance.new("PointLight")
	rl.Color = RED_LIGHT
	rl.Brightness = 4
	rl.Range = 10
	rl.Parent = redLight

	local blueLight = VU.ball(model, "LightBlue",
		Vector3.new(0.8, 0.8, 0.8),
		CFrame.new(1.2, lightY, cabinD / 2 - 0.5),
		BLUE_LIGHT, Enum.Material.Neon)
	local bl = Instance.new("PointLight")
	bl.Color = BLUE_LIGHT
	bl.Brightness = 4
	bl.Range = 10
	bl.Parent = blueLight

	model:SetAttribute("_hasPoliceLight", true)

	---------------------------------------------------------------------------
	-- WHITE POLICE STRIPE (along both sides of lower hull)
	---------------------------------------------------------------------------
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "PoliceStripe",
			Vector3.new(0.05, 0.6, cabinD + 1),
			CFrame.new(sx * (cabinW / 2 + 0.05), floorY + 0.8, 0.3),
			WHITE, Enum.Material.Neon)
	end

	---------------------------------------------------------------------------
	-- SEARCHLIGHT BEAM (volumetric cone: 3 cross-planes at 60° intervals)
	---------------------------------------------------------------------------
	-- Searchlight housing under nose
	VU.ball(model, "SearchlightHousing",
		Vector3.new(1.2, 1.2, 1.2),
		CFrame.new(0, floorY - 0.3, cabinD / 2 + 1),
		Color3.fromRGB(40, 40, 45), Enum.Material.Metal)

	local tip = VU.ball(model, "BeamTip",
		Vector3.new(1.0, 1.0, 1.0),
		CFrame.new(0, floorY - 1, cabinD / 2 + 1),
		beamColor, Enum.Material.Neon)
	tip.Transparency = 0.3

	-- Ground impact part (25 studs below root)
	local impact = VU.part(model, "LaserImpact",
		Vector3.new(0.5, 0.5, 0.5),
		CFrame.new(0, -25, cabinD / 2 + 1),
		beamColor, Enum.Material.SmoothPlastic)
	impact.Transparency = 1

	local att0 = Instance.new("Attachment")
	att0.Name = "BeamStart"
	att0.Parent = tip

	local att1 = Instance.new("Attachment")
	att1.Name = "BeamEnd"
	att1.Parent = impact

	-- Layer 1: Wide outer haze (soft glow, wide cone)
	local haze = Instance.new("Beam")
	haze.Name = "BeamHaze"
	haze.Attachment0 = att0
	haze.Attachment1 = att1
	haze.Color = ColorSequence.new(beamColor)
	haze.LightEmission = 1
	haze.LightInfluence = 0
	haze.Brightness = 1
	haze.Width0 = 2.5
	haze.Width1 = 12
	haze.Segments = 1
	haze.FaceCamera = true
	haze.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.6),
		NumberSequenceKeypoint.new(0.4, 0.75),
		NumberSequenceKeypoint.new(1, 0.92),
	})
	haze.Parent = tip

	-- Layer 2: Mid cone (main visible beam)
	local mid = Instance.new("Beam")
	mid.Name = "BeamMid"
	mid.Attachment0 = att0
	mid.Attachment1 = att1
	mid.Color = ColorSequence.new(beamColor)
	mid.LightEmission = 1
	mid.LightInfluence = 0
	mid.Brightness = 2
	mid.Width0 = 1.5
	mid.Width1 = 7
	mid.Segments = 1
	mid.FaceCamera = true
	mid.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.5, 0.65),
		NumberSequenceKeypoint.new(1, 0.85),
	})
	mid.Parent = tip

	-- Layer 3: Bright inner core (hot center)
	local core = Instance.new("Beam")
	core.Name = "BeamCore"
	core.Attachment0 = att0
	core.Attachment1 = att1
	core.Color = ColorSequence.new(beamCoreColor)
	core.LightEmission = 1
	core.LightInfluence = 0
	core.Brightness = 4
	core.Width0 = 0.4
	core.Width1 = 2
	core.Segments = 1
	core.FaceCamera = true
	core.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.5, 0.45),
		NumberSequenceKeypoint.new(1, 0.7),
	})
	core.Parent = tip

	-- SpotLight for real ground illumination
	local spot = Instance.new("SpotLight")
	spot.Name = "SearchSpot"
	spot.Face = Enum.NormalId.Bottom
	spot.Angle = 35
	spot.Range = 30
	spot.Brightness = 4
	spot.Color = beamColor
	spot.Parent = tip

	-- Ground impact glow
	local impactLight = Instance.new("PointLight")
	impactLight.Name = "LaserGlow"
	impactLight.Color = beamColor
	impactLight.Brightness = 3
	impactLight.Range = 22
	impactLight.Parent = impact

	-- Ground impact dust particles
	local sparks = Instance.new("ParticleEmitter")
	sparks.Name = "LaserSparks"
	sparks.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, beamCoreColor),
		ColorSequenceKeypoint.new(1, beamColor),
	})
	sparks.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.8),
		NumberSequenceKeypoint.new(1, 0.2),
	})
	sparks.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(0.7, 0.4),
		NumberSequenceKeypoint.new(1, 1),
	})
	sparks.Lifetime = NumberRange.new(0.3, 0.6)
	sparks.Rate = 40
	sparks.Speed = NumberRange.new(5, 12)
	sparks.SpreadAngle = Vector2.new(50, 50)
	sparks.EmissionDirection = Enum.NormalId.Top
	sparks.LightEmission = 0.8
	sparks.LightInfluence = 0
	sparks.Parent = impact

	---------------------------------------------------------------------------
	-- INTERIOR CABIN LIGHT (warm glow illuminating NPCs through glass)
	---------------------------------------------------------------------------
	local interiorLight = VU.part(model, "InteriorLight",
		Vector3.new(1, 0.2, 1),
		CFrame.new(0, roofY - 0.5, cabinD * 0.15),
		Color3.fromRGB(255, 230, 180), Enum.Material.Neon)
	interiorLight.Transparency = 0.5

	local cabinGlow = Instance.new("PointLight")
	cabinGlow.Color = Color3.fromRGB(255, 220, 160)
	cabinGlow.Brightness = 1.5
	cabinGlow.Range = 10
	cabinGlow.Parent = interiorLight

	model.PrimaryPart = root
	return model
end

return Helicopter
