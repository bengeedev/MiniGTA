-- ProceduralNPCs Module
-- Builds NPC template models from code and inserts them into ReplicatedStorage/NPCTemplates.
-- Called once at server startup before NPCManager.init() and ProceduralVehicles.build().

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Civilian = require(script.npcs.Civilian)
local PoliceOfficer = require(script.npcs.PoliceOfficer)
local President = require(script.npcs.President)

local ProceduralNPCs = {}

-- All 22 NPC templates to build
local function getTemplateList()
	local list = {}

	-- Boy_1 .. Boy_10 (civilian indices 1..10)
	for i = 1, 10 do
		table.insert(list, {
			name = "Boy_" .. i,
			build = function() return Civilian.build("Boy_" .. i, i) end,
		})
	end

	-- Girl_1 .. Girl_10 (civilian indices 11..20)
	for i = 1, 10 do
		table.insert(list, {
			name = "Girl_" .. i,
			build = function() return Civilian.build("Girl_" .. i, 10 + i) end,
		})
	end

	-- Special NPCs
	table.insert(list, { name = "police_officer_01", build = PoliceOfficer.build })
	table.insert(list, { name = "President",         build = President.build })

	return list
end

function ProceduralNPCs.build(onProgress)
	-- Get or create NPCTemplates folder
	local folder = ReplicatedStorage:FindFirstChild("NPCTemplates")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "NPCTemplates"
		folder.Parent = ReplicatedStorage
	end

	local templates = getTemplateList()
	local totalSteps = #templates
	local currentStep = 0

	for _, entry in ipairs(templates) do
		currentStep += 1

		-- Destroy existing template with same name (override Studio imports)
		local existing = folder:FindFirstChild(entry.name)
		if existing then
			existing:Destroy()
		end

		local model = entry.build()
		model.Parent = folder
		print("[ProceduralNPCs] Created " .. entry.name)

		if onProgress then
			onProgress(entry.name, currentStep, totalSteps)
		end
	end

	print("[ProceduralNPCs] All " .. totalSteps .. " templates ready")
end

return ProceduralNPCs
