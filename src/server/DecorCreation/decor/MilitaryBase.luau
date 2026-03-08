-- MilitaryBase decor builder
-- Interior compound decor for the military_zone lane.
-- Fences and warning panels are handled by the separate military_warning lane.

local DecorUtils = require(script.Parent:WaitForChild("DecorUtils"))

local MilitaryBase = {}

--------------------------------------------------------------------------------
-- MAIN BUILDER (placeholder — props will be added later)
--------------------------------------------------------------------------------

function MilitaryBase.createMilitaryBase(x, z, scale)
	local folder = DecorUtils.decorFolder
	if not folder then return nil end

	local model = Instance.new("Model")
	model.Name = "MilitaryBase"

	model.Parent = folder
	return model
end

return MilitaryBase
