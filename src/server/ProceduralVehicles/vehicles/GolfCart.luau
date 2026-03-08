local VU = require(script.Parent:WaitForChild("VehicleUtils"))

local GolfCart = {}

--------------------------------------------------------------------------------
-- GOLF CART  (faces +Z forward, wheels on ground at Y=0)
-- Scaled up for R15 NPCs sitting inside. Passengers added via build() step.
--------------------------------------------------------------------------------

local RUBBER  = Color3.fromRGB(35, 35, 38)

local C_BODY   = Color3.fromRGB(240, 245, 240)
local C_FRAME  = Color3.fromRGB(60, 65, 70)
local C_SEAT   = Color3.fromRGB(190, 170, 130)
local C_HUB    = Color3.fromRGB(180, 180, 185)
local C_ROOF   = Color3.fromRGB(250, 250, 252)
local C_GLASS  = Color3.fromRGB(180, 210, 235)
local C_GBAG   = Color3.fromRGB(40, 120, 50)

local GOLF_FLOOR_Y = 2.5  -- shared between cart builder and NPC seating

GolfCart.FLOOR_Y = GOLF_FLOOR_Y

function GolfCart.build()
	local model = Instance.new("Model")
	model.Name = "GolfCart_1"

	-- Layout (scaled up for R15 characters sitting inside)
	local floorY  = GOLF_FLOOR_Y
	local wheelR  = 1.5
	local wheelW  = 1.2
	local frontZ  = 5.0
	local rearZ   = -5.0
	local halfW   = 3.5
	local roofY   = 8.0
	local postH   = roofY - floorY - 0.5

	---------------------------------------------------------------------------
	-- WHEELS
	---------------------------------------------------------------------------
	for _, wz in ipairs({frontZ, rearZ}) do
		for _, sx in ipairs({-1, 1}) do
			VU.cylinder(model, "Tire",
				Vector3.new(wheelW, wheelR * 2, wheelR * 2),
				CFrame.new(sx * halfW, wheelR, wz),
				RUBBER, Enum.Material.SmoothPlastic)
			VU.cylinder(model, "Hub",
				Vector3.new(wheelW + 0.15, wheelR * 0.7, wheelR * 0.7),
				CFrame.new(sx * halfW, wheelR, wz),
				C_HUB, Enum.Material.Metal)
		end
	end

	---------------------------------------------------------------------------
	-- CHASSIS + BODY
	---------------------------------------------------------------------------
	local chassis = VU.part(model, "Chassis",
		Vector3.new(7.5, 0.5, 13),
		CFrame.new(0, floorY, 0),
		C_BODY, Enum.Material.SmoothPlastic)

	VU.part(model, "FrontBumper",
		Vector3.new(7, 1, 0.6),
		CFrame.new(0, floorY + 0.3, 6.5),
		C_FRAME, Enum.Material.SmoothPlastic)
	VU.part(model, "RearBumper",
		Vector3.new(7, 1, 0.6),
		CFrame.new(0, floorY + 0.3, -6.5),
		C_FRAME, Enum.Material.SmoothPlastic)

	-- Dashboard
	VU.part(model, "Dashboard",
		Vector3.new(6, 1.5, 0.6),
		CFrame.new(0, floorY + 1.2, 3.5),
		C_BODY, Enum.Material.SmoothPlastic)

	-- Windshield (tilted back)
	local ws = VU.part(model, "Windshield",
		Vector3.new(6, 2.5, 0.15),
		CFrame.new(0, floorY + 3.0, 4.2) * CFrame.Angles(math.rad(-15), 0, 0),
		C_GLASS, Enum.Material.SmoothPlastic)
	ws.Transparency = 0.5

	---------------------------------------------------------------------------
	-- SEATS
	---------------------------------------------------------------------------
	for _, sx in ipairs({-2, 2}) do
		VU.part(model, "Seat",
			Vector3.new(3, 0.6, 2.8),
			CFrame.new(sx, floorY + 0.7, 0),
			C_SEAT, Enum.Material.Fabric)
		VU.part(model, "SeatBack",
			Vector3.new(3, 2.8, 0.5),
			CFrame.new(sx, floorY + 2.3, -1.4),
			C_SEAT, Enum.Material.Fabric)
	end

	---------------------------------------------------------------------------
	-- ROOF + POSTS
	---------------------------------------------------------------------------
	for _, pz in ipairs({3.0, -2.0}) do
		for _, sx in ipairs({-3.0, 3.0}) do
			VU.part(model, "RoofPost",
				Vector3.new(0.4, postH, 0.4),
				CFrame.new(sx, floorY + 0.5 + postH / 2, pz),
				C_FRAME, Enum.Material.Metal)
		end
	end
	VU.part(model, "Roof",
		Vector3.new(7.5, 0.3, 7),
		CFrame.new(0, roofY, 0.5),
		C_ROOF, Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- STEERING (driver at X=-2, Z=0; dashboard at Z=3.5; wheel between them)
	-- Cylinder axis default = X. Rotate 90 around Y to face driver (axis->Z).
	-- Then tilt top toward driver with X rotation.
	---------------------------------------------------------------------------
	VU.cylinder(model, "SteeringWheel",
		Vector3.new(0.2, 1.4, 1.4),
		CFrame.new(-2, floorY + 3.2, 2.2) * CFrame.Angles(math.rad(25), math.rad(90), 0),
		C_FRAME, Enum.Material.SmoothPlastic)
	VU.part(model, "SteerColumn",
		Vector3.new(0.2, 1.8, 0.2),
		CFrame.new(-2, floorY + 2.3, 2.5) * CFrame.Angles(math.rad(-20), 0, 0),
		C_FRAME, Enum.Material.Metal)

	---------------------------------------------------------------------------
	-- GOLF BAG RACK (rear, behind seats)
	---------------------------------------------------------------------------
	VU.part(model, "BagRack",
		Vector3.new(5.5, 0.3, 2.0),
		CFrame.new(0, floorY + 0.3, -4.5),
		C_FRAME, Enum.Material.Metal)

	-- Two golf bags standing upright, side by side, different colors
	local bagColors = {
		Color3.fromRGB(40, 120, 50),   -- green
		Color3.fromRGB(45, 55, 120),   -- navy blue
	}
	for bi, bagX in ipairs({-1.2, 1.2}) do
		VU.cylinder(model, "GolfBag",
			Vector3.new(3.0, 1.6, 1.6),
			CFrame.new(bagX, floorY + 1.8, -4.5) * CFrame.Angles(0, 0, math.rad(90)),
			bagColors[bi], Enum.Material.Fabric)

		-- Club shafts (thin rods) sticking out the top, fanning out slightly
		for i = -2, 2 do
			VU.part(model, "ClubShaft",
				Vector3.new(0.08, 1.8, 0.08),
				CFrame.new(bagX + i * 0.15, floorY + 4.0, -4.5) * CFrame.Angles(math.rad(2), 0, math.rad(3 * i)),
				C_HUB, Enum.Material.Metal)
			-- Club head (small block at the top of each shaft)
			VU.part(model, "ClubHead",
				Vector3.new(0.3, 0.15, 0.5),
				CFrame.new(bagX + i * 0.2, floorY + 4.9, -4.35) * CFrame.Angles(0, 0, math.rad(3 * i)),
				C_HUB, Enum.Material.Metal)
		end
	end

	---------------------------------------------------------------------------
	-- LIGHTS
	---------------------------------------------------------------------------
	for _, sx in ipairs({-2.0, 2.0}) do
		VU.part(model, "Headlight",
			Vector3.new(1.0, 0.8, 0.25),
			CFrame.new(sx, floorY + 0.6, 6.6),
			Color3.fromRGB(255, 240, 200), Enum.Material.Neon)
		VU.part(model, "TailLight",
			Vector3.new(0.8, 0.5, 0.25),
			CFrame.new(sx, floorY + 0.6, -6.6),
			Color3.fromRGB(200, 30, 20), Enum.Material.Neon)
	end

	model.PrimaryPart = chassis
	return model
end

return GolfCart
