local VU = require(script.Parent:WaitForChild("VehicleUtils"))

local SemiTruck = {}

--------------------------------------------------------------------------------
-- Semi truck cab palette
--------------------------------------------------------------------------------
local C_BODY          = Color3.fromRGB(180, 30, 30)   -- red cab
local C_TRIM          = Color3.fromRGB(35, 35, 40)    -- dark trim
local C_CHROME        = Color3.fromRGB(190, 190, 195) -- chrome details
local C_GLASS         = Color3.fromRGB(120, 150, 170) -- tinted glass
local C_INTERIOR      = Color3.fromRGB(50, 50, 55)    -- dark interior
local C_RUBBER        = Color3.fromRGB(30, 30, 30)    -- tires
local C_HUB           = Color3.fromRGB(160, 160, 165) -- alloy wheels
local C_HEADLIGHT     = Color3.fromRGB(255, 250, 230) -- warm white
local C_TAILLIGHT     = Color3.fromRGB(220, 30, 30)   -- red
local C_TURN_SIGNAL   = Color3.fromRGB(255, 160, 30)  -- amber

--------------------------------------------------------------------------------
-- Shared Y constants (used by init.luau for NPC seating)
--------------------------------------------------------------------------------
local FLOOR_Y = 8.0  -- high cab like real American trucks
SemiTruck.FLOOR_Y = FLOOR_Y
SemiTruck.SEAT_Y  = 11.5
SemiTruck.DRIVER_Z = 1.0

--------------------------------------------------------------------------------
-- SEMI TRUCK CAB BUILDER
-- American-style cab-over or conventional truck cab.
-- Faces +Z forward, wheels on ground Y=0.
--------------------------------------------------------------------------------
function SemiTruck.build(modelName, bodyColor, trailerCount)
	modelName = modelName or "SemiTruck_1"
	bodyColor = bodyColor or C_BODY
	trailerCount = trailerCount or 1  -- 0, 1, or 2 trailers

	local model = Instance.new("Model")
	model.Name = modelName

	---------------------------------------------------------------------------
	-- Dimensions (based on bus proportions, bigger wheels)
	---------------------------------------------------------------------------
	local wheelR     = 3.5
	local wheelW     = 1.5
	local halfW      = 5.0
	local bodyW      = halfW * 2  -- 10.0

	-- Cab dimensions (shorter than bus, just the cab)
	local frontEndZ  =  8.0
	local rearEndZ   = -8.0
	local cabLen     = frontEndZ - rearEndZ  -- 16.0

	local frontAxleZ =  5.0
	local rearAxleZ  = -5.5

	local floorY     = FLOOR_Y
	local beltY      = floorY + 3.0           -- window sill
	local cabRoofY   = floorY + 7.5           -- 12.0
	local winH       = cabRoofY - beltY - 0.4

	---------------------------------------------------------------------------
	-- 1. WHEELS (front single, rear dual)
	---------------------------------------------------------------------------
	-- Front wheels
	for _, sx in ipairs({-1, 1}) do
		VU.cylinder(model, "FrontTire",
			Vector3.new(wheelW, wheelR * 2, wheelR * 2),
			CFrame.new(sx * halfW, wheelR, frontAxleZ),
			C_RUBBER, Enum.Material.SmoothPlastic)
		VU.cylinder(model, "FrontHub",
			Vector3.new(wheelW + 0.1, wheelR * 0.5, wheelR * 0.5),
			CFrame.new(sx * halfW, wheelR, frontAxleZ),
			C_HUB, Enum.Material.Metal)
	end

	-- Rear dual wheels
	for _, sx in ipairs({-1, 1}) do
		VU.cylinder(model, "RearTireOuter",
			Vector3.new(wheelW, wheelR * 2, wheelR * 2),
			CFrame.new(sx * (halfW + 0.3), wheelR, rearAxleZ),
			C_RUBBER, Enum.Material.SmoothPlastic)
		VU.cylinder(model, "RearTireInner",
			Vector3.new(wheelW, wheelR * 2, wheelR * 2),
			CFrame.new(sx * (halfW - 0.9), wheelR, rearAxleZ),
			C_RUBBER, Enum.Material.SmoothPlastic)
		VU.cylinder(model, "RearHub",
			Vector3.new(wheelW + 0.1, wheelR * 0.5, wheelR * 0.5),
			CFrame.new(sx * (halfW + 0.3), wheelR, rearAxleZ),
			C_HUB, Enum.Material.Metal)
	end

	---------------------------------------------------------------------------
	-- 2. CHASSIS / FRAME
	---------------------------------------------------------------------------
	local chassis = VU.part(model, "Chassis",
		Vector3.new(bodyW - 2, 0.8, cabLen + 4),
		CFrame.new(0, floorY - 1.0, (frontEndZ + rearEndZ) / 2 - 2),
		C_TRIM, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- 3. CAB BODY
	---------------------------------------------------------------------------
	local cabLowerH = beltY - floorY

	-- Cab floor
	VU.part(model, "CabFloor",
		Vector3.new(bodyW - 0.6, 0.3, cabLen),
		CFrame.new(0, floorY, (frontEndZ + rearEndZ) / 2),
		C_INTERIOR, Enum.Material.SmoothPlastic)

	-- Cab sides (lower, below windows) - extends down toward wheels
	local doorH = cabLowerH + 2.5  -- taller door panel
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "CabSideLower",
			Vector3.new(0.4, doorH, cabLen),
			CFrame.new(sx * (halfW - 0.2), floorY + cabLowerH / 2 - 1.0, (frontEndZ + rearEndZ) / 2),
			bodyColor, Enum.Material.SmoothPlastic)
	end

	-- Hood (long American-style hood)
	local hoodLen = 5.5
	local hoodH = 2.2
	VU.part(model, "Hood",
		Vector3.new(bodyW - 1.0, hoodH, hoodLen),
		CFrame.new(0, floorY + hoodH / 2 - 0.5, frontEndZ - hoodLen / 2 + 0.5),
		bodyColor, Enum.Material.SmoothPlastic)

	-- Hood top (air intake style)
	VU.part(model, "HoodScoop",
		Vector3.new(3.0, 0.5, 2.5),
		CFrame.new(0, floorY + hoodH, frontEndZ - 2.5),
		bodyColor, Enum.Material.SmoothPlastic)

	-- Front face (vertical, from floor down to bumper)
	local frontFaceTop = floorY + hoodH - 0.5
	local frontFaceBottom = wheelR - 1.0
	local frontFaceH = frontFaceTop - frontFaceBottom
	VU.part(model, "FrontFace",
		Vector3.new(bodyW - 0.5, frontFaceH, 0.5),
		CFrame.new(0, frontFaceBottom + frontFaceH / 2, frontEndZ + 0.2),
		bodyColor, Enum.Material.SmoothPlastic)

	-- Front grille (chrome, centered on front face)
	local grilleH = frontFaceH - 2.0
	VU.part(model, "Grille",
		Vector3.new(bodyW - 3.0, grilleH, 0.3),
		CFrame.new(0, frontFaceBottom + frontFaceH / 2, frontEndZ + 0.4),
		C_CHROME, Enum.Material.Metal)

	-- Grille slats
	local slotCount = 5
	for i = 0, slotCount - 1 do
		VU.part(model, "GrilleSlat",
			Vector3.new(bodyW - 4.0, 0.15, 0.12),
			CFrame.new(0, frontFaceBottom + 1.5 + i * (grilleH - 2) / slotCount, frontEndZ + 0.5),
			C_TRIM, Enum.Material.SmoothPlastic)
	end

	---------------------------------------------------------------------------
	-- 4. CAB UPPER (windows)
	---------------------------------------------------------------------------
	-- Cab roof
	VU.part(model, "CabRoof",
		Vector3.new(bodyW, 0.4, cabLen - hoodLen + 1),
		CFrame.new(0, cabRoofY, (frontEndZ + rearEndZ) / 2 - hoodLen / 2),
		bodyColor, Enum.Material.SmoothPlastic)

	-- Windshield
	local wsH = winH + 0.8
	local wsg = VU.part(model, "Windshield",
		Vector3.new(bodyW - 1.5, wsH, 0.2),
		CFrame.new(0, beltY + wsH / 2, frontEndZ - hoodLen + 0.8)
			* CFrame.Angles(math.rad(-12), 0, 0),
		C_GLASS, Enum.Material.Glass)
	wsg.Transparency = 0.4

	-- A-pillars
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "APillar",
			Vector3.new(0.35, wsH + 0.3, 0.35),
			CFrame.new(sx * (halfW - 0.4), beltY + wsH / 2, frontEndZ - hoodLen + 0.5),
			C_TRIM, Enum.Material.SmoothPlastic)
	end

	-- Side windows
	for _, sx in ipairs({-1, 1}) do
		local swg = VU.part(model, "SideWindow",
			Vector3.new(0.15, winH, cabLen - hoodLen - 1.5),
			CFrame.new(sx * halfW, beltY + winH / 2 + 0.15, (frontEndZ + rearEndZ) / 2 - hoodLen / 2),
			C_GLASS, Enum.Material.Glass)
		swg.Transparency = 0.4
	end

	-- Cab rear wall
	VU.part(model, "CabRearWall",
		Vector3.new(bodyW - 0.6, cabRoofY - floorY, 0.4),
		CFrame.new(0, floorY + (cabRoofY - floorY) / 2, rearEndZ + 0.2),
		bodyColor, Enum.Material.SmoothPlastic)

	-- Rear window (small)
	local rwg = VU.part(model, "RearWindow",
		Vector3.new(bodyW - 2.5, 1.5, 0.15),
		CFrame.new(0, beltY + 1.5, rearEndZ),
		C_GLASS, Enum.Material.Glass)
	rwg.Transparency = 0.5

	---------------------------------------------------------------------------
	-- 5. FRONT BUMPER + LIGHTS
	---------------------------------------------------------------------------
	-- Chrome bumper (at bottom of front face)
	VU.part(model, "FrontBumper",
		Vector3.new(bodyW + 0.8, 1.2, 1.0),
		CFrame.new(0, frontFaceBottom - 0.3, frontEndZ + 0.5),
		C_CHROME, Enum.Material.Metal)

	-- Headlights (on front face, upper area)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Headlight",
			Vector3.new(1.8, 1.8, 0.3),
			CFrame.new(sx * 3.8, frontFaceBottom + frontFaceH - 2.0, frontEndZ + 0.5),
			C_HEADLIGHT, Enum.Material.Neon)

		-- Turn signals (below headlights)
		VU.part(model, "TurnSignal",
			Vector3.new(1.2, 0.8, 0.25),
			CFrame.new(sx * 3.8, frontFaceBottom + frontFaceH - 4.0, frontEndZ + 0.5),
			C_TURN_SIGNAL, Enum.Material.Neon)
	end

	-- Marker lights on top of cab
	for _, sx in ipairs({-2.5, -1.2, 0, 1.2, 2.5}) do
		VU.part(model, "MarkerLight",
			Vector3.new(0.4, 0.25, 0.3),
			CFrame.new(sx, cabRoofY + 0.3, frontEndZ - hoodLen + 1.0),
			C_TURN_SIGNAL, Enum.Material.Neon)
	end

	---------------------------------------------------------------------------
	-- 6. REAR LIGHTS
	---------------------------------------------------------------------------
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "Taillight",
			Vector3.new(0.6, 1.0, 0.2),
			CFrame.new(sx * 4.2, floorY + 0.5, rearEndZ - 0.1),
			C_TAILLIGHT, Enum.Material.Neon)
	end

	---------------------------------------------------------------------------
	-- 7. SIDE MIRRORS
	---------------------------------------------------------------------------
	for _, sx in ipairs({-1, 1}) do
		-- Long mirror arms (truck style)
		VU.part(model, "MirrorArm",
			Vector3.new(1.5, 0.15, 0.15),
			CFrame.new(sx * (halfW + 0.7), beltY + 1.0, frontEndZ - hoodLen + 0.5),
			C_CHROME, Enum.Material.Metal)
		VU.part(model, "MirrorHead",
			Vector3.new(0.5, 1.2, 0.6),
			CFrame.new(sx * (halfW + 1.4), beltY + 0.8, frontEndZ - hoodLen + 0.5),
			C_TRIM, Enum.Material.SmoothPlastic)
	end

	---------------------------------------------------------------------------
	-- 8. EXHAUST STACKS (tall vertical American-style, behind cab)
	---------------------------------------------------------------------------
	for _, sx in ipairs({-1, 1}) do
		-- Main vertical pipe (wider/more massive)
		VU.cylinder(model, "ExhaustStack",
			Vector3.new(12.0, 1.4, 1.4),
			CFrame.new(sx * (halfW + 0.6), cabRoofY - 2.0, rearEndZ + 1.5)
				* CFrame.Angles(0, 0, math.rad(90)),
			C_CHROME, Enum.Material.Metal)
		-- Chrome cap on top with smoke
		local cap = VU.cylinder(model, "ExhaustCap",
			Vector3.new(0.5, 1.8, 1.8),
			CFrame.new(sx * (halfW + 0.6), cabRoofY + 4.2, rearEndZ + 1.5)
				* CFrame.Angles(0, 0, math.rad(90)),
			C_TRIM, Enum.Material.Metal)
		-- Smoke particles (dense)
		local smoke = Instance.new("ParticleEmitter")
		smoke.Color = ColorSequence.new(Color3.fromRGB(60, 60, 65))
		smoke.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.8),
			NumberSequenceKeypoint.new(1, 4.0),
		})
		smoke.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2),
			NumberSequenceKeypoint.new(0.5, 0.5),
			NumberSequenceKeypoint.new(1, 1),
		})
		smoke.Lifetime = NumberRange.new(2.0, 3.0)
		smoke.Rate = 25
		smoke.Speed = NumberRange.new(4, 7)
		smoke.SpreadAngle = Vector2.new(15, 15)
		smoke.Rotation = NumberRange.new(0, 360)
		smoke.RotSpeed = NumberRange.new(-40, 40)
		smoke.EmissionDirection = Enum.NormalId.Top
		smoke.Parent = cap
	end

	---------------------------------------------------------------------------
	-- 9. FIFTH WHEEL COUPLING (behind cab)
	---------------------------------------------------------------------------
	local fifthWheelZ = rearEndZ - 2.0
	-- Coupling platform
	VU.part(model, "FifthWheelPlatform",
		Vector3.new(bodyW - 2, 0.5, 4.0),
		CFrame.new(0, floorY - 1.5, fifthWheelZ),
		C_TRIM, Enum.Material.SmoothPlastic)
	-- Coupling mechanism
	VU.cylinder(model, "FifthWheel",
		Vector3.new(0.8, 4.0, 4.0),
		CFrame.new(0, floorY - 1.0, fifthWheelZ)
			* CFrame.Angles(0, 0, math.rad(90)),
		C_TRIM, Enum.Material.Metal)

	---------------------------------------------------------------------------
	-- 10. CARGO TRAILERS
	---------------------------------------------------------------------------
	local trailerColors = {
		Color3.fromRGB(50, 80, 140),   -- blue
		Color3.fromRGB(180, 50, 50),   -- red
		Color3.fromRGB(60, 120, 60),   -- green
		Color3.fromRGB(200, 160, 50),  -- yellow/gold
	}

	local trailerStartZ = fifthWheelZ - 3.0  -- start of first trailer
	local trailerLen = 32.0  -- longer trailers
	local trailerH = 10.0
	local trailerW = bodyW
	local trailerGap = 8.0  -- gap between trailers for dolly

	for t = 1, trailerCount do
		local trailerZ = trailerStartZ - (t - 1) * (trailerLen + trailerGap)
		local trailerColor = trailerColors[(t - 1) % #trailerColors + 1]
		local trailerRearZ = trailerZ - trailerLen

		-- Trailer frame/undercarriage
		VU.part(model, "TrailerFrame_" .. t,
			Vector3.new(trailerW - 2, 0.6, trailerLen + 2),
			CFrame.new(0, floorY - 2.0, trailerZ - trailerLen / 2),
			C_TRIM, Enum.Material.SmoothPlastic)

		-- Trailer floor
		VU.part(model, "TrailerFloor_" .. t,
			Vector3.new(trailerW - 0.5, 0.3, trailerLen),
			CFrame.new(0, floorY - 1.5, trailerZ - trailerLen / 2),
			C_INTERIOR, Enum.Material.SmoothPlastic)

		-- Trailer walls (sides)
		for _, sx in ipairs({-1, 1}) do
			local side = VU.part(model, "TrailerSide_" .. t,
				Vector3.new(0.4, trailerH, trailerLen),
				CFrame.new(sx * (halfW - 0.2), floorY - 1.5 + trailerH / 2, trailerZ - trailerLen / 2),
				trailerColor, Enum.Material.SmoothPlastic)
			side:SetAttribute("ThemeRole", "vehicle_body")
			side:SetAttribute("BaseColor", trailerColor)
			side:SetAttribute("BaseMaterial", "SmoothPlastic")
		end

		-- Trailer front wall
		local tFront = VU.part(model, "TrailerFront_" .. t,
			Vector3.new(trailerW - 0.5, trailerH, 0.4),
			CFrame.new(0, floorY - 1.5 + trailerH / 2, trailerZ),
			trailerColor, Enum.Material.SmoothPlastic)
		tFront:SetAttribute("ThemeRole", "vehicle_body")
		tFront:SetAttribute("BaseColor", trailerColor)
		tFront:SetAttribute("BaseMaterial", "SmoothPlastic")

		-- Trailer rear doors
		local tRear = VU.part(model, "TrailerRear_" .. t,
			Vector3.new(trailerW - 0.5, trailerH, 0.4),
			CFrame.new(0, floorY - 1.5 + trailerH / 2, trailerRearZ),
			trailerColor, Enum.Material.SmoothPlastic)
		tRear:SetAttribute("ThemeRole", "vehicle_body")
		tRear:SetAttribute("BaseColor", trailerColor)
		tRear:SetAttribute("BaseMaterial", "SmoothPlastic")
		-- Door seam
		VU.part(model, "TrailerDoorSeam_" .. t,
			Vector3.new(0.1, trailerH - 1, 0.45),
			CFrame.new(0, floorY - 1.5 + trailerH / 2, trailerRearZ - 0.02),
			C_TRIM, Enum.Material.SmoothPlastic)
		-- Door handles
		for _, sx in ipairs({-1, 1}) do
			VU.part(model, "TrailerHandle_" .. t,
				Vector3.new(0.3, 1.5, 0.2),
				CFrame.new(sx * 1.5, floorY + trailerH / 2 - 1, trailerRearZ - 0.15),
				C_CHROME, Enum.Material.Metal)
		end

		-- Trailer roof
		local tRoof = VU.part(model, "TrailerRoof_" .. t,
			Vector3.new(trailerW, 0.4, trailerLen + 0.5),
			CFrame.new(0, floorY - 1.5 + trailerH, trailerZ - trailerLen / 2),
			trailerColor, Enum.Material.SmoothPlastic)
		tRoof:SetAttribute("ThemeRole", "vehicle_body")
		tRoof:SetAttribute("BaseColor", trailerColor)
		tRoof:SetAttribute("BaseMaterial", "SmoothPlastic")

		-- Trailer wheels (2 axles spread apart: rear and middle)
		local trailerWheelR = wheelR  -- same size as cab wheels
		local trailerWheelW = wheelW
		local rearAxleZ = trailerRearZ + 4.0
		local frontAxleZ = trailerZ - 6.0  -- near front of trailer

		for _, axleZ in ipairs({rearAxleZ, frontAxleZ}) do
			for _, sx in ipairs({-1, 1}) do
				-- Outer wheel
				VU.cylinder(model, "TrailerWheelOuter_" .. t,
					Vector3.new(trailerWheelW, trailerWheelR * 2, trailerWheelR * 2),
					CFrame.new(sx * (halfW + 0.6), trailerWheelR, axleZ),
					C_RUBBER, Enum.Material.SmoothPlastic)
				-- Inner wheel
				VU.cylinder(model, "TrailerWheelInner_" .. t,
					Vector3.new(trailerWheelW, trailerWheelR * 2, trailerWheelR * 2),
					CFrame.new(sx * (halfW - 0.6), trailerWheelR, axleZ),
					C_RUBBER, Enum.Material.SmoothPlastic)
				-- Hub outer
				VU.cylinder(model, "TrailerHubOuter_" .. t,
					Vector3.new(trailerWheelW + 0.1, trailerWheelR * 0.5, trailerWheelR * 0.5),
					CFrame.new(sx * (halfW + 0.6), trailerWheelR, axleZ),
					C_HUB, Enum.Material.Metal)
			end
		end

		-- Trailer lights (rear)
		for _, sx in ipairs({-1, 1}) do
			VU.part(model, "TrailerTaillight_" .. t,
				Vector3.new(0.8, 1.2, 0.2),
				CFrame.new(sx * 4.0, floorY, trailerRearZ - 0.1),
				C_TAILLIGHT, Enum.Material.Neon)
		end

		-- Landing gear (folded up, small detail under trailer)
		for _, sx in ipairs({-1, 1}) do
			VU.part(model, "LandingGear_" .. t,
				Vector3.new(0.3, 1.5, 0.5),
				CFrame.new(sx * 3.5, floorY - 2.5, trailerZ - 2.0),
				C_TRIM, Enum.Material.SmoothPlastic)
		end

		-- Connecting bar to previous trailer (for trailer 2+)
		if t > 1 then
			-- Previous trailer rear Z = current trailer front Z + gap
			local prevTrailerRearZ = trailerZ + trailerGap
			local barLen = trailerGap - 1.0  -- leave small margin
			local barMidZ = trailerZ + trailerGap / 2

			-- Simple connecting bar (center)
			VU.part(model, "ConnectBar_" .. t,
				Vector3.new(2.5, 1.5, barLen),
				CFrame.new(0, floorY - 2.0, barMidZ),
				C_CHROME, Enum.Material.Metal)

			-- Side rails
			for _, sx in ipairs({-1, 1}) do
				VU.part(model, "ConnectRail_" .. t,
					Vector3.new(0.8, 1.0, barLen),
					CFrame.new(sx * 3.0, floorY - 2.2, barMidZ),
					C_TRIM, Enum.Material.SmoothPlastic)
			end
		end
	end

	---------------------------------------------------------------------------
	-- Finalize
	---------------------------------------------------------------------------
	model.PrimaryPart = chassis
	return model
end

return SemiTruck
