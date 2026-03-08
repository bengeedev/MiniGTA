-- NPCManager.luau
-- Spawns R15 humanoid NPCs from pre-built templates in ReplicatedStorage/NPCTemplates.
-- Instant clone, no network calls needed.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InsertService = game:GetService("InsertService")

local NPCManager = {}

local npcFolder: Folder? = nil
local activeNPCs: { Model } = {}
local PLAYABLE_WIDTH = 80

--------------------------------------------------------------------------------
-- CIVILIAN TEMPLATE POOL (boy_1–boy_10, girl_1–girl_10 in NPCTemplates)
--------------------------------------------------------------------------------

local CIVILIAN_POOL: { string } = {}
for i = 1, 10 do
	table.insert(CIVILIAN_POOL, "Boy_" .. i)
	table.insert(CIVILIAN_POOL, "Girl_" .. i)
end

function NPCManager.randomCivilian(): string
	return CIVILIAN_POOL[math.random(#CIVILIAN_POOL)]
end

--------------------------------------------------------------------------------
-- NPC TEMPLATES
-- Maps template names to optional accessory asset IDs.
-- Templates live in ReplicatedStorage/NPCTemplates/{name}.
-- Accessories are loaded via InsertService and attached at init time.
--------------------------------------------------------------------------------

local TEMPLATE_ACCESSORIES: { [string]: { number } } = {
	-- Example:
	-- shopkeeper_01 = { 123456789, 987654321 },
}

local templatesFolder: Folder? = nil
local templatesReady = false

--------------------------------------------------------------------------------
-- SEATED POSE: Precomputed R15 part CFrames relative to HumanoidRootPart.
-- Legs bent 90° at hips, knees bent 90° back (hanging down).
-- Arms tucked ~30° forward and ~15° inward for a "hands on lap" pose.
-- Eliminates the need for animation playback + task.wait() during vehicle builds.
--------------------------------------------------------------------------------

local HIP_Y   = -1.0     -- LowerTorso.Y(-0.8) + Hip.C0.Y(-0.2)
local THIGH   = 0.675    -- half upper-leg length
local SHIN    = 0.675    -- half lower-leg length
local KNEE_Z  = -THIGH * 2  -- knee Z when thigh is horizontal
local ARM_FWD = math.rad(30)
local ARM_IN  = math.rad(15)

-- Compute tucked arm offsets (rotate arm chain around shoulder pivot)
local function tuckArmOffsets(shoulderX, sign)
	local pivot = CFrame.new(shoulderX, 0.8, 0)  -- shoulder in UpperTorso space → +0.6 from UT center, UT at 0.2 → 0.8 from HRP
	local tuck = CFrame.Angles(ARM_FWD, 0, sign * ARM_IN)
	-- Rest arm offsets relative to HRP
	local offsets = {
		{ shoulderX, 0.2, 0 },    -- UpperArm
		{ shoulderX, -1.0, 0 },   -- LowerArm
		{ shoulderX, -1.75, 0 },  -- Hand
	}
	local result = {}
	for _, o in ipairs(offsets) do
		local restCF = CFrame.new(o[1], o[2], o[3])
		table.insert(result, pivot * tuck * pivot:Inverse() * restCF)
	end
	return result
end

local leftArmTucked = tuckArmOffsets(-1.5, 1)
local rightArmTucked = tuckArmOffsets(1.5, -1)

local SEATED_OFFSETS = {
	HumanoidRootPart = CFrame.new(0, 0, 0),
	LowerTorso       = CFrame.new(0, -0.8, 0),
	UpperTorso       = CFrame.new(0, 0.2, 0),
	Head             = CFrame.new(0, 1.6, 0),
	-- Arms: tucked forward + inward
	LeftUpperArm     = leftArmTucked[1],
	LeftLowerArm     = leftArmTucked[2],
	LeftHand         = leftArmTucked[3],
	RightUpperArm    = rightArmTucked[1],
	RightLowerArm    = rightArmTucked[2],
	RightHand        = rightArmTucked[3],
	-- Legs: 90° forward at hip, 90° back at knee (hanging down)
	LeftUpperLeg     = CFrame.new(-0.5, HIP_Y, -THIGH) * CFrame.Angles(math.rad(90), 0, 0),
	LeftLowerLeg     = CFrame.new(-0.5, HIP_Y - SHIN, KNEE_Z),
	LeftFoot         = CFrame.new(-0.5, HIP_Y - SHIN * 2 - 0.15, KNEE_Z),
	RightUpperLeg    = CFrame.new(0.5, HIP_Y, -THIGH) * CFrame.Angles(math.rad(90), 0, 0),
	RightLowerLeg    = CFrame.new(0.5, HIP_Y - SHIN, KNEE_Z),
	RightFoot        = CFrame.new(0.5, HIP_Y - SHIN * 2 - 0.15, KNEE_Z),
}


--------------------------------------------------------------------------------
-- INTERNAL: Animation setup (server-side, since Animate LocalScript won't run)
-- Standard R15 animation IDs from Roblox defaults.
--------------------------------------------------------------------------------

local R15_ANIMS = {
	idle = "rbxassetid://507766666",
	walk = "rbxassetid://507777826",
	sit  = "rbxassetid://2506281703",
}

local function setupAnimations(model, humanoid, behavior)
	-- Get or create Animator
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	-- Remove the Animate LocalScript (won't run on server, just clutter)
	local animateScript = model:FindFirstChild("Animate")
	if animateScript then
		animateScript:Destroy()
	end

	if behavior == "sit" then
		-- Sitting animation only
		local sitAnim = Instance.new("Animation")
		sitAnim.AnimationId = R15_ANIMS.sit
		local sitTrack = animator:LoadAnimation(sitAnim)
		sitTrack.Looped = true
		sitTrack.Priority = Enum.AnimationPriority.Movement
		sitTrack:Play()
		return
	end

	-- Load and play idle
	local idleAnim = Instance.new("Animation")
	idleAnim.AnimationId = R15_ANIMS.idle
	local idleTrack = animator:LoadAnimation(idleAnim)
	idleTrack.Looped = true
	idleTrack.Priority = Enum.AnimationPriority.Idle
	idleTrack:Play()

	if behavior == "pace" then
		local walkAnim = Instance.new("Animation")
		walkAnim.AnimationId = R15_ANIMS.walk
		local walkTrack = animator:LoadAnimation(walkAnim)
		walkTrack.Looped = true
		walkTrack.Priority = Enum.AnimationPriority.Movement

		-- Switch between idle/walk based on movement
		humanoid.Running:Connect(function(speed)
			if speed > 0.5 then
				if not walkTrack.IsPlaying then walkTrack:Play() end
				if idleTrack.IsPlaying then idleTrack:Stop() end
			else
				if walkTrack.IsPlaying then walkTrack:Stop() end
				if not idleTrack.IsPlaying then idleTrack:Play() end
			end
		end)
	end
end

--------------------------------------------------------------------------------
-- INTERNAL: Start pacing behavior (walks back and forth)
--------------------------------------------------------------------------------

local function startPacing(model, humanoid, origin, paceRange, paceAxis)
	local axis = paceAxis or "x"
	local pointA, pointB

	if axis == "z" then
		pointA = Vector3.new(origin.X, origin.Y, origin.Z - paceRange)
		pointB = Vector3.new(origin.X, origin.Y, origin.Z + paceRange)
	else
		pointA = Vector3.new(origin.X - paceRange, origin.Y, origin.Z)
		pointB = Vector3.new(origin.X + paceRange, origin.Y, origin.Z)
	end

	task.spawn(function()
		task.wait(math.random() * 2)
		while model and model.Parent and humanoid and humanoid.Health > 0 do
			humanoid:MoveTo(pointA)
			humanoid.MoveToFinished:Wait()
			task.wait(1 + math.random() * 2)
			humanoid:MoveTo(pointB)
			humanoid.MoveToFinished:Wait()
			task.wait(1 + math.random() * 2)
		end
	end)
end

--------------------------------------------------------------------------------
-- INTERNAL: Common NPC setup
--------------------------------------------------------------------------------

local function setupNPC(model, name, position, faceAngle, behavior, behaviorData)
	model.Name = "NPC_" .. name

	local hrp = model:FindFirstChild("HumanoidRootPart")
	local humanoid = model:FindFirstChildOfClass("Humanoid")

	if not hrp or not humanoid then
		warn("[NPCManager] Missing HumanoidRootPart or Humanoid in:", name)
		model:Destroy()
		return nil
	end

	-- Position and face direction
	local angle = math.rad(faceAngle or 0)
	hrp.CFrame = CFrame.new(position) * CFrame.Angles(0, angle, 0)

	-- Walk speed (default 16 is a jog, 6-8 is a casual walk)
	humanoid.WalkSpeed = behaviorData and behaviorData.walkSpeed or 8

	-- Make NPC invincible and hide health bar
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	humanoid.MaxHealth = math.huge
	humanoid.Health = math.huge

	-- Disable NPC-to-player collision
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end

	behavior = behavior or "idle"

	model.Parent = npcFolder

	-- Wait a frame so the Humanoid can apply R15 body scaling
	task.wait()

	-- Anchor stationary NPCs AFTER scaling has applied
	if behavior == "idle" or behavior == "sit" then
		hrp.Anchored = true
	end

	-- Animate (must be after parenting so Animator can replicate)
	setupAnimations(model, humanoid, behavior)

	-- Start pacing if requested (must be after parenting)
	if behavior == "pace" then
		local data = behaviorData or {}
		startPacing(model, humanoid, position, data.paceRange or 10, data.paceAxis or "x")
	end

	table.insert(activeNPCs, model)
	return model
end

--------------------------------------------------------------------------------
-- PUBLIC API
--------------------------------------------------------------------------------

function NPCManager.init(folder: Folder)
	npcFolder = folder
	templatesFolder = ReplicatedStorage:FindFirstChild("NPCTemplates")

	if templatesFolder then
		print("[NPCManager] Found NPCTemplates folder with", #templatesFolder:GetChildren(), "templates")

		-- Attach accessories to templates (one-time, at server start)
		for templateName, accessoryIds in pairs(TEMPLATE_ACCESSORIES) do
			local template = templatesFolder:FindFirstChild(templateName)
			if not template then
				warn("[NPCManager] Template not found for accessories:", templateName)
				continue
			end

			local humanoid = template:FindFirstChildOfClass("Humanoid")
			if not humanoid then
				warn("[NPCManager] No Humanoid in template:", templateName)
				continue
			end

			for _, assetId in ipairs(accessoryIds) do
				local ok, asset = pcall(function()
					return InsertService:LoadAsset(assetId)
				end)
				if ok and asset then
					local accessory = asset:FindFirstChildOfClass("Accessory")
					if accessory then
						humanoid:AddAccessory(accessory)
						print("[NPCManager] Attached accessory", assetId, "to", templateName)
					else
						warn("[NPCManager] Asset", assetId, "has no Accessory child")
					end
					asset:Destroy()
				else
					warn("[NPCManager] Failed to load accessory", assetId, ":", tostring(asset))
				end
			end
		end

		templatesReady = true
	else
		warn("[NPCManager] No NPCTemplates folder found — NPCs will not spawn")
	end

	print("[NPCManager] Initialized, folder:", folder:GetFullName())
end

--- Spawn an NPC from a template in ReplicatedStorage/NPCTemplates.
--- Clones the template, positions it, sets up behavior and animations.
function NPCManager.spawnFromTemplate(templateName: string, position: Vector3, faceAngle: number?, behavior: string?, behaviorData: {}?)
	if not npcFolder then
		warn("[NPCManager] No folder set, cannot spawn")
		return nil
	end

	if not templatesFolder then
		warn("[NPCManager] NPCTemplates folder not found, cannot spawn:", templateName)
		return nil
	end

	local template = templatesFolder:FindFirstChild(templateName)
	if not template then
		warn("[NPCManager] Template not found:", templateName)
		return nil
	end

	local model = template:Clone()
	local result = setupNPC(model, templateName, position, faceAngle, behavior, behaviorData)

	if result then
		print("[NPCManager] Template NPC spawned:", templateName)
	end

	return result
end

--- Spawn an NPC from a template and seat it inside a vehicle model.
--- Seat an NPC in a vehicle using precomputed seated pose CFrames.
--- Zero task.wait() calls — fully synchronous, instant.
--- Returns the NPC model (already parented into vehicleModel) or nil.
function NPCManager.spawnSeatedInVehicle(templateName: string, vehicleModel: Model, seatCFrame: CFrame)
	if not templatesFolder then
		warn("[NPCManager] NPCTemplates folder not found, cannot spawn seated:", templateName)
		return nil
	end

	local template = templatesFolder:FindFirstChild(templateName)
	if not template then
		warn("[NPCManager] Template not found:", templateName)
		return nil
	end

	local model = template:Clone()
	model.Name = "NPC_" .. templateName

	local hrp = model:FindFirstChild("HumanoidRootPart")
	local humanoid = model:FindFirstChildOfClass("Humanoid")

	if not hrp or not humanoid then
		warn("[NPCManager] Template missing HumanoidRootPart or Humanoid:", templateName)
		model:Destroy()
		return nil
	end

	-- Hide health bar
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff

	-- Remove Animate LocalScript (won't run on server)
	local animateScript = model:FindFirstChild("Animate")
	if animateScript then
		animateScript:Destroy()
	end

	-- Position all parts using precomputed seated offsets relative to seatCFrame.
	-- No animation, no temp workspace folder, no task.wait() needed.
	for partName, offset in pairs(SEATED_OFFSETS) do
		local part = model:FindFirstChild(partName)
		if part then
			part.CFrame = seatCFrame * offset
			part.Anchored = true
			part.CanCollide = false
		end
	end

	-- Anchor any remaining BaseParts (accents, effects)
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = true
			part.CanCollide = false
		end
	end

	-- Clear the NPC model's PrimaryPart so it doesn't interfere with the parent
	-- vehicle's ScaleTo/PivotTo operations. When a nested Model has its own
	-- PrimaryPart, Roblox treats it as a separate transform unit, causing NPCs
	-- to appear outside the car after the vehicle is repositioned.
	model.PrimaryPart = nil

	model.Parent = vehicleModel

	print("[NPCManager] Seated NPC spawned:", templateName, "in", vehicleModel.Name)
	return model
end


--- Spawn NPCs for a lane from template entries.
--- Supports `template = "random_civilian"` for random boy/girl picks.
function NPCManager.spawnForLane(npcEntries, laneZ: number)
	if not npcFolder or not npcEntries then return end
	local half = PLAYABLE_WIDTH / 2

	print("[NPCManager] Spawning", #npcEntries, "NPCs for lane at Z=" .. laneZ)

	for _, entry in ipairs(npcEntries) do
		local offsetX = entry.offsetX or 0
		local offsetZ = entry.offsetZ or 0
		local side = entry.side or "right"
		local x

		if side == "right" then
			x = half + offsetX
		elseif side == "left" then
			x = -(half + offsetX)
		else
			x = offsetX
		end

		local y = entry.y or 7
		local position = Vector3.new(x, y, laneZ + offsetZ)

		task.spawn(function()
			local templateName = entry.template
			if not templateName then
				warn("[NPCManager] NPC entry has no template field")
				return
			end
			if not templatesReady then
				warn("[NPCManager] Templates not ready, skipping:", templateName)
				return
			end
			if templateName == "random_civilian" then
				templateName = NPCManager.randomCivilian()
			end
			NPCManager.spawnFromTemplate(
				templateName,
				position,
				entry.faceAngle or 0,
				entry.behavior or "idle",
				entry
			)
		end)
	end
end

function NPCManager.clearAll()
	print("[NPCManager] Clearing", #activeNPCs, "NPCs")
	for _, npc in ipairs(activeNPCs) do
		if npc and npc.Parent then
			npc:Destroy()
		end
	end
	activeNPCs = {}
end

-- GC: destroy NPCs whose Z position is greater than (behind) the threshold.
function NPCManager.clearBehind(zThreshold: number)
	local kept = {}
	local count = 0
	for _, npc in ipairs(activeNPCs) do
		if npc and npc.Parent then
			local hrp = npc:FindFirstChild("HumanoidRootPart")
			local npcZ = hrp and hrp.Position.Z or 0
			if npcZ > zThreshold then
				npc:Destroy()
				count += 1
			else
				table.insert(kept, npc)
			end
		end
	end
	activeNPCs = kept
	if count > 0 then
		print("[NPCManager] GC cleared " .. count .. " NPCs behind Z=" .. string.format("%.0f", zThreshold))
	end
end

return NPCManager
