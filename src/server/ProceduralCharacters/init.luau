-- ProceduralCharacters Module
-- Builds character models from code and inserts them into ReplicatedStorage/Characters.
-- Called once at server startup before clients connect.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Blaze = require(script.characters.Blaze)
local Glacier = require(script.characters.Glacier)
local Volt = require(script.characters.Volt)
local Shadow = require(script.characters.Shadow)
local Terra = require(script.characters.Terra)
local Aqua = require(script.characters.Aqua)

local ProceduralCharacters = {}

local CHARACTERS = {
	{ name = "Blaze", builder = Blaze },
	{ name = "Glacier", builder = Glacier },
	{ name = "Volt", builder = Volt },
	{ name = "Shadow", builder = Shadow },
	{ name = "Terra", builder = Terra },
	{ name = "Aqua", builder = Aqua },
}

function ProceduralCharacters.build(onProgress)
	-- Create Characters folder if missing
	local folder = ReplicatedStorage:FindFirstChild("Characters")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Characters"
		folder.Parent = ReplicatedStorage
	end

	local totalSteps = #CHARACTERS
	local currentStep = 0

	for _, entry in ipairs(CHARACTERS) do
		currentStep += 1

		-- Skip if already exists (idempotent)
		if not folder:FindFirstChild(entry.name) then
			local model = entry.builder.build()
			model.Parent = folder
			print("[ProceduralCharacters] Created " .. entry.name)
		end

		if onProgress then
			onProgress(entry.name, currentStep, totalSteps)
		end
	end
end

return ProceduralCharacters
