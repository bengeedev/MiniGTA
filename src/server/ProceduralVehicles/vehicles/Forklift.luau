local VU = require(script.Parent:WaitForChild("VehicleUtils"))

local Forklift = {}

--------------------------------------------------------------------------------
-- FORKLIFT  (faces +Z forward, wheels on ground at Y=0)
-- Yellow industrial forklift with overhead guard, fork arms, pallet + boxes,
-- and Part-based driver (R15 upgrade deferred).
--------------------------------------------------------------------------------

local BLACK    = Color3.fromRGB(25, 25, 28)

local C_YELLOW  = Color3.fromRGB(240, 190, 30)
local C_FRAME   = Color3.fromRGB(55, 55, 60)
local C_SEAT    = Color3.fromRGB(40, 40, 45)
local C_METAL   = Color3.fromRGB(130, 130, 135)
local C_PALLET  = Color3.fromRGB(160, 120, 60)
local C_HUB     = Color3.fromRGB(100, 100, 105)

function Forklift.build()
	local model = Instance.new("Model")
	model.Name = "Forklift_1"

	-- Layout
	local wheelR = 1.2
	local wheelW = 1.0
	local frontZ = 3.5
	local rearZ  = -3.5
	local halfW  = 2.8
	local floorY = wheelR + 0.3

	---------------------------------------------------------------------------
	-- WHEELS (small industrial)
	---------------------------------------------------------------------------
	-- Front wheels (larger)
	for _, sx in ipairs({-1, 1}) do
		VU.cylinder(model, "FrontTire",
			Vector3.new(wheelW, wheelR * 2, wheelR * 2),
			CFrame.new(sx * halfW, wheelR, frontZ),
			BLACK, Enum.Material.SmoothPlastic)
		VU.cylinder(model, "FrontHub",
			Vector3.new(wheelW + 0.1, wheelR * 0.5, wheelR * 0.5),
			CFrame.new(sx * halfW, wheelR, frontZ),
			C_HUB, Enum.Material.Metal)
	end
	-- Rear wheels (slightly smaller)
	for _, sx in ipairs({-1, 1}) do
		VU.cylinder(model, "RearTire",
			Vector3.new(wheelW * 0.8, wheelR * 1.6, wheelR * 1.6),
			CFrame.new(sx * (halfW - 0.4), wheelR * 0.8, rearZ),
			BLACK, Enum.Material.SmoothPlastic)
		VU.cylinder(model, "RearHub",
			Vector3.new(wheelW * 0.8 + 0.1, wheelR * 0.4, wheelR * 0.4),
			CFrame.new(sx * (halfW - 0.4), wheelR * 0.8, rearZ),
			C_HUB, Enum.Material.Metal)
	end

	---------------------------------------------------------------------------
	-- BODY / CHASSIS
	---------------------------------------------------------------------------
	local chassis = VU.part(model, "Chassis",
		Vector3.new(5.5, 0.5, 8),
		CFrame.new(0, floorY, 0),
		C_YELLOW, Enum.Material.SmoothPlastic)

	-- Engine hood (rear section, behind driver)
	VU.part(model, "EngineHood",
		Vector3.new(5, 2.5, 3),
		CFrame.new(0, floorY + 1.5, -2.5),
		C_YELLOW, Enum.Material.SmoothPlastic)

	-- Counterweight (very back)
	VU.part(model, "Counterweight",
		Vector3.new(5.5, 2, 1),
		CFrame.new(0, floorY + 1.2, -4),
		C_FRAME, Enum.Material.Metal)

	---------------------------------------------------------------------------
	-- MAST / FORK ASSEMBLY (front)
	---------------------------------------------------------------------------
	local mastH = 7
	local mastY = floorY + mastH / 2
	local mastZ = frontZ + 1

	-- Mast rails (two vertical rails)
	for _, sx in ipairs({-1.2, 1.2}) do
		VU.part(model, "MastRail",
			Vector3.new(0.4, mastH, 0.4),
			CFrame.new(sx, mastY, mastZ),
			C_FRAME, Enum.Material.Metal)
	end

	-- Mast cross brace
	VU.part(model, "MastBrace",
		Vector3.new(2.8, 0.3, 0.3),
		CFrame.new(0, floorY + mastH * 0.6, mastZ),
		C_FRAME, Enum.Material.Metal)

	-- Fork carriage (slides on mast)
	local forkY = floorY + 0.8
	VU.part(model, "ForkCarriage",
		Vector3.new(2.8, 1.5, 0.4),
		CFrame.new(0, forkY + 0.75, mastZ + 0.3),
		C_METAL, Enum.Material.Metal)

	-- Fork tines (two flat prongs sticking forward)
	for _, sx in ipairs({-1, 1}) do
		VU.part(model, "ForkTine",
			Vector3.new(0.5, 0.15, 4),
			CFrame.new(sx * 0.9, forkY, mastZ + 2.3),
			C_METAL, Enum.Material.Metal)
	end

	---------------------------------------------------------------------------
	-- PALLET + BOXES on fork
	---------------------------------------------------------------------------
	local palletZ = mastZ + 2.5
	local palletY = forkY + 0.2

	-- Pallet (wooden base)
	VU.part(model, "Pallet",
		Vector3.new(5, 0.4, 5),
		CFrame.new(0, palletY, palletZ),
		C_PALLET, Enum.Material.Wood)

	-- Boxes on pallet (stacked, various sizes and colors)
	local boxColors = {
		Color3.fromRGB(160, 120, 60),  -- cardboard
		Color3.fromRGB(140, 100, 50),  -- darker cardboard
		Color3.fromRGB(180, 140, 70),  -- light cardboard
	}
	-- Bottom row (3 boxes filling the pallet)
	VU.part(model, "Box1",
		Vector3.new(2.3, 2.0, 2.3),
		CFrame.new(-1.1, palletY + 1.2, palletZ - 1.0),
		boxColors[1], Enum.Material.SmoothPlastic)
	VU.part(model, "Box2",
		Vector3.new(2.0, 1.8, 2.5),
		CFrame.new(1.2, palletY + 1.1, palletZ + 0.5),
		boxColors[2], Enum.Material.SmoothPlastic)
	VU.part(model, "Box3",
		Vector3.new(2.2, 1.6, 2.0),
		CFrame.new(-0.8, palletY + 1.0, palletZ + 1.2),
		boxColors[3], Enum.Material.SmoothPlastic)
	-- Top box
	VU.part(model, "Box4",
		Vector3.new(2.0, 1.5, 2.0),
		CFrame.new(0, palletY + 2.8, palletZ),
		boxColors[1], Enum.Material.SmoothPlastic)

	---------------------------------------------------------------------------
	-- OVERHEAD GUARD (safety cage above driver)
	---------------------------------------------------------------------------
	local guardH = 6.5
	local guardY = floorY + guardH

	-- Four posts
	for _, sx in ipairs({-2.2, 2.2}) do
		for _, sz in ipairs({1, -2}) do
			VU.part(model, "GuardPost",
				Vector3.new(0.3, guardH, 0.3),
				CFrame.new(sx, (floorY + guardY) / 2, sz),
				C_YELLOW, Enum.Material.Metal)
		end
	end

	-- Roof frame
	VU.part(model, "GuardRoof",
		Vector3.new(5, 0.25, 3.5),
		CFrame.new(0, guardY, -0.5),
		C_YELLOW, Enum.Material.Metal)

	-- Roof mesh grid (cross bars)
	for _, sx in ipairs({-1, 0, 1}) do
		VU.part(model, "GuardBar",
			Vector3.new(0.15, 0.15, 3.5),
			CFrame.new(sx * 1.5, guardY - 0.1, -0.5),
			C_YELLOW, Enum.Material.Metal)
	end

	---------------------------------------------------------------------------
	-- SEAT + STEERING
	---------------------------------------------------------------------------
	VU.part(model, "Seat",
		Vector3.new(2.5, 0.5, 2),
		CFrame.new(0, floorY + 0.6, -0.5),
		C_SEAT, Enum.Material.Fabric)
	VU.part(model, "SeatBack",
		Vector3.new(2.5, 2.5, 0.4),
		CFrame.new(0, floorY + 2.0, -1.5),
		C_SEAT, Enum.Material.Fabric)

	-- Steering wheel (lower, closer to driver lap)
	VU.cylinder(model, "SteeringWheel",
		Vector3.new(0.15, 1.4, 1.4),
		CFrame.new(0, floorY + 2.0, 0.8) * CFrame.Angles(math.rad(60), math.rad(90), 0),
		C_FRAME, Enum.Material.SmoothPlastic)
	VU.part(model, "SteerColumn",
		Vector3.new(0.2, 1.0, 0.2),
		CFrame.new(0, floorY + 1.4, 1.0) * CFrame.Angles(math.rad(-30), 0, 0),
		C_FRAME, Enum.Material.Metal)

	---------------------------------------------------------------------------
	-- LIGHTS
	---------------------------------------------------------------------------
	-- Headlights
	for _, sx in ipairs({-1.5, 1.5}) do
		VU.part(model, "Headlight",
			Vector3.new(0.8, 0.6, 0.2),
			CFrame.new(sx, floorY + 0.6, frontZ + 0.5),
			Color3.fromRGB(255, 240, 200), Enum.Material.Neon)
	end
	-- Warning beacon on roof
	VU.part(model, "Beacon",
		Vector3.new(0.8, 0.5, 0.8),
		CFrame.new(0, guardY + 0.35, -0.5),
		Color3.fromRGB(255, 140, 0), Enum.Material.Neon)

	model.PrimaryPart = chassis
	return model
end

return Forklift
