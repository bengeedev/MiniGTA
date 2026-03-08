-- ThemeApplier.client.luau
-- Per-player theme system: recolors tagged parts and terrain locally.
-- Server builds with default colors + ThemeRole attributes.
-- This client reads the player's selected theme and applies overrides.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

local Shared = ReplicatedStorage:WaitForChild("Shared", 10)
local ThemeConfig = require(Shared:WaitForChild("ThemeConfig"))
local Remotes = require(Shared:WaitForChild("Remotes"))

task.wait(1) -- wait for remotes to be created

--------------------------------------------------------------------------------
-- STATE
--------------------------------------------------------------------------------

local currentTheme = "default"
local savedTheme = "default" -- the persisted theme (vs. temporary preview)

--------------------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------------------

local function pickRandom(t)
	if not t or #t == 0 then return nil end
	return t[math.random(1, #t)]
end

-- Cache: per-vehicle-instance color picks so all body parts of the same car
-- get the same theme color, but different car instances get different colors.
-- Key = vehicle Model, value = { [baseColorKey] = themeColor }
local vehicleColorCache = {}

-- Common terrain materials that may need color overrides
local TERRAIN_MATERIALS = {
	Enum.Material.Concrete,
	Enum.Material.Asphalt,
	Enum.Material.Cobblestone,
	Enum.Material.Sand,
	Enum.Material.Grass,
	Enum.Material.Slate,
	Enum.Material.Brick,
	Enum.Material.Salt,
	Enum.Material.Glacier,
	Enum.Material.CrackedLava,
	Enum.Material.Basalt,
	Enum.Material.Ground,
	Enum.Material.Limestone,
	Enum.Material.LeafyGrass,
	Enum.Material.Ice,
}

-- Cache default terrain colors at startup so we can restore them
local defaultTerrainColors = {}
do
	local terrain = Workspace.Terrain
	for _, mat in ipairs(TERRAIN_MATERIALS) do
		defaultTerrainColors[mat] = terrain:GetMaterialColor(mat)
	end
end

-- Resolve Enum.Material from string name
local function getMaterial(name)
	local ok, mat = pcall(function()
		return Enum.Material[name]
	end)
	return ok and mat or nil
end

--------------------------------------------------------------------------------
-- THEME APPLICATION
--------------------------------------------------------------------------------

local function applyThemeToPart(inst)
	local role = inst:GetAttribute("ThemeRole")
	if not role then return end

	local theme = ThemeConfig.THEMES[currentTheme]

	-- For "default" theme: revert to base values
	if not theme or currentTheme == "default" then
		local baseColor = inst:GetAttribute("BaseColor")
		local baseMat = inst:GetAttribute("BaseMaterial")
		if baseColor and inst:IsA("BasePart") then
			inst.Color = baseColor
		end
		if baseColor and inst:IsA("PointLight") then
			inst.Color = baseColor
		end
		if baseMat and inst:IsA("BasePart") then
			local mat = getMaterial(baseMat)
			if mat then inst.Material = mat end
		end
		-- TextLabels don't need revert (server built with defaults)
		return
	end

	-- Non-default theme: apply overrides
	local shops = theme.shops
	local tree = theme.tree
	local lamp = theme.lamp
	local bldg = theme.buildings
	local veh = theme.vehicles

	if role == "tree_trunk" and tree and inst:IsA("BasePart") then
		inst.Color = tree.trunk
	elseif role == "tree_leaves" and tree and inst:IsA("BasePart") then
		inst.Color = tree.leaves
	elseif role == "tree_bush" and tree and inst:IsA("BasePart") then
		inst.Color = tree.bush
	elseif role == "lamp_pole" and lamp and inst:IsA("BasePart") then
		inst.Color = lamp.pole
	elseif role == "lamp_housing" and lamp and inst:IsA("BasePart") then
		inst.Color = lamp.housing
	elseif role == "lamp_light" and inst:IsA("PointLight") then
		if lamp then inst.Color = lamp.light end
	elseif role == "building_body" and bldg and inst:IsA("BasePart") then
		inst.Color = pickRandom(bldg.bodyColors) or inst.Color
		if bldg.bodyMaterial then inst.Material = bldg.bodyMaterial end
	elseif role == "building_roof" and bldg and inst:IsA("BasePart") then
		inst.Color = bldg.roofColor or inst.Color
	elseif role == "building_window_lit" and bldg and inst:IsA("BasePart") then
		inst.Color = pickRandom(bldg.windowLit) or inst.Color
	elseif role == "building_window" and bldg and inst:IsA("BasePart") then
		inst.Color = pickRandom(bldg.windowDark) or inst.Color
	elseif role == "vehicle_body" and veh and inst:IsA("BasePart") then
		-- Per-instance random: all body parts of same vehicle get same color,
		-- but different vehicle instances get different random picks.
		if veh.bodyColors and #veh.bodyColors > 0 then
			-- Walk up to find the vehicle Model
			local vehicleModel = inst.Parent
			while vehicleModel and not vehicleModel:IsA("Model") do
				vehicleModel = vehicleModel.Parent
			end
			if vehicleModel then
				local cache = vehicleColorCache[vehicleModel]
				if not cache then
					cache = {}
					vehicleColorCache[vehicleModel] = cache
				end
				-- Group by BaseColor so semi trailers (different base) get different theme colors
				local baseColor = inst:GetAttribute("BaseColor")
				local key = baseColor and tostring(baseColor) or "default"
				if not cache[key] then
					cache[key] = pickRandom(veh.bodyColors)
				end
				inst.Color = cache[key]
			end
		end
	elseif shops then
		if role == "shop_wall" and inst:IsA("BasePart") then
			inst.Color = pickRandom(shops.wallColors) or inst.Color
			if shops.wallMaterial then inst.Material = shops.wallMaterial end
		elseif role == "shop_glass" and inst:IsA("BasePart") then
			inst.Color = shops.glass or inst.Color
		elseif role == "shop_mullion" and inst:IsA("BasePart") then
			inst.Color = shops.mullion or inst.Color
		elseif role == "shop_floor" and inst:IsA("BasePart") then
			inst.Color = shops.floorColor or inst.Color
		elseif role == "shop_ceiling" and inst:IsA("BasePart") then
			inst.Color = shops.ceilingColor or inst.Color
		elseif role == "shop_awning" and inst:IsA("BasePart") then
			inst.Color = pickRandom(shops.signColors) or inst.Color
			if shops.awningMaterial then inst.Material = shops.awningMaterial end
		elseif role == "shop_window" and inst:IsA("BasePart") then
			inst.Color = pickRandom(shops.windowColors) or inst.Color
		elseif role == "shop_darkwindow" and inst:IsA("BasePart") then
			inst.Color = shops.darkWindow or inst.Color
		elseif role == "shop_sign" and inst:IsA("BasePart") then
			inst.Color = pickRandom(shops.signColors) or inst.Color
		elseif role == "shop_signtext" and inst:IsA("TextLabel") then
			if shops.nameList then inst.Text = pickRandom(shops.nameList) end
			if shops.signFonts then inst.Font = pickRandom(shops.signFonts) end
		elseif role == "shop_roof" and inst:IsA("BasePart") then
			inst.Color = shops.roofColor or inst.Color
		elseif role == "shop_shoplight" and inst:IsA("PointLight") then
			inst.Color = shops.shopLight or inst.Color
		end
	end
end

--------------------------------------------------------------------------------
-- SCAN ALL EXISTING PARTS
--------------------------------------------------------------------------------

local function scanAll()
	vehicleColorCache = {} -- clear so each vehicle gets a fresh random pick
	for _, desc in ipairs(Workspace:GetDescendants()) do
		applyThemeToPart(desc)
	end
end

--------------------------------------------------------------------------------
-- TERRAIN OVERRIDE
--------------------------------------------------------------------------------

local function applyTerrainColors()
	local theme = ThemeConfig.THEMES[currentTheme]
	local terrain = Workspace.Terrain

	if not theme or currentTheme == "default" then
		-- Restore default terrain colors
		for _, mat in ipairs(TERRAIN_MATERIALS) do
			if defaultTerrainColors[mat] then
				terrain:SetMaterialColor(mat, defaultTerrainColors[mat])
			end
		end
		return
	end

	local terrainData = theme.terrain
	if not terrainData or not terrainData.color then return end

	for _, mat in ipairs(TERRAIN_MATERIALS) do
		terrain:SetMaterialColor(mat, terrainData.color)
	end
end

--------------------------------------------------------------------------------
-- WATCH FOR NEW PARTS (streaming / lane creation)
--------------------------------------------------------------------------------

Workspace.DescendantAdded:Connect(function(inst)
	-- Small delay to ensure attributes are replicated
	task.defer(function()
		if inst:GetAttribute("ThemeRole") then
			applyThemeToPart(inst)
		end
	end)
end)

--------------------------------------------------------------------------------
-- LISTEN FOR THEME CHANGES
--------------------------------------------------------------------------------

local themeChangedRemote = Remotes.waitFor("ThemeChanged", 10)
if themeChangedRemote then
	themeChangedRemote.OnClientEvent:Connect(function(themeName)
		if not ThemeConfig.THEMES[themeName] then return end
		savedTheme = themeName
		currentTheme = themeName
		print("[ThemeApplier] Theme changed to: " .. themeName)
		scanAll()
		applyTerrainColors()
	end)
end

--------------------------------------------------------------------------------
-- LISTEN FOR PLAYER DATA (initial theme on join)
--------------------------------------------------------------------------------

local dataSyncRemote = Remotes.waitFor("PlayerDataSync", 10)
if dataSyncRemote then
	dataSyncRemote.OnClientEvent:Connect(function(data)
		if data and data.selectedTheme and data.selectedTheme ~= currentTheme then
			savedTheme = data.selectedTheme
			currentTheme = data.selectedTheme
			print("[ThemeApplier] Initial theme from save: " .. currentTheme)
			scanAll()
			applyTerrainColors()
		end
	end)
end

--------------------------------------------------------------------------------
-- TERRAIN REFRESH LOOP (override server-side fillTerrain replication)
--------------------------------------------------------------------------------

task.spawn(function()
	while true do
		task.wait(1)
		if currentTheme ~= "default" then
			applyTerrainColors()
		end
	end
end)

--------------------------------------------------------------------------------
-- PREVIEW THEME SUPPORT (ThemeSelect sets this attribute for live preview)
--------------------------------------------------------------------------------

local playerGui = player:WaitForChild("PlayerGui")
playerGui:GetAttributeChangedSignal("PreviewTheme"):Connect(function()
	local preview = playerGui:GetAttribute("PreviewTheme")
	if preview and preview ~= "" and ThemeConfig.THEMES[preview] then
		currentTheme = preview
	else
		currentTheme = savedTheme
	end
	scanAll()
	applyTerrainColors()
end)

print("[ThemeApplier] Loaded")
