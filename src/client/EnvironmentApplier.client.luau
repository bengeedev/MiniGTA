-- EnvironmentApplier.client.luau
-- Client-side environment rendering: receives env name from server,
-- applies lighting/fog/sky/effects locally. Theme-specific environments
-- override the server's requested preset.

local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared", 10)
local EnvironmentConfig = require(Shared:WaitForChild("EnvironmentConfig"))
local ThemeConfig = require(Shared:WaitForChild("ThemeConfig"))
local Remotes = require(Shared:WaitForChild("Remotes"))

task.wait(1) -- wait for remotes

local TRANSITION_DURATION = 3

--------------------------------------------------------------------------------
-- STATE
--------------------------------------------------------------------------------

local activeTransitionId = 0
local currentTheme = "default"
local debugEnvOverride = nil -- set by debug menu to bypass theme environment

--------------------------------------------------------------------------------
-- LIGHTING HELPERS (adapted from server EnvironmentManager)
--------------------------------------------------------------------------------

local function clearLightingClass(className)
	for _, child in pairs(Lighting:GetChildren()) do
		if child:IsA(className) then
			child:Destroy()
		end
	end
end

local function getOrCreate(className, name)
	local existing = Lighting:FindFirstChildOfClass(className)
	if existing then return existing end
	local inst = Instance.new(className)
	inst.Name = name or className
	inst.Parent = Lighting
	return inst
end

--------------------------------------------------------------------------------
-- RESOLVE CONFIG
--------------------------------------------------------------------------------

local function resolveConfig(envName)
	if not envName or envName == "default" then
		return EnvironmentConfig.DEFAULT
	end
	return EnvironmentConfig.ENVIRONMENTS[envName]
		or EnvironmentConfig.WORLDS[envName]
		or EnvironmentConfig.DEFAULT
end

--------------------------------------------------------------------------------
-- APPLY INSTANTLY
--------------------------------------------------------------------------------

local function applyEnvironment(config)
	config = config or EnvironmentConfig.DEFAULT

	activeTransitionId += 1

	-- Lighting properties
	Lighting.ClockTime = config.ClockTime
	Lighting.Brightness = config.Brightness
	Lighting.Ambient = config.Ambient
	Lighting.OutdoorAmbient = config.OutdoorAmbient

	-- Fog
	Lighting.FogStart = config.FogStart
	Lighting.FogEnd = config.FogEnd
	Lighting.FogColor = config.FogColor

	-- Clear existing effects
	clearLightingClass("Atmosphere")
	clearLightingClass("Sky")
	clearLightingClass("BloomEffect")
	clearLightingClass("ColorCorrectionEffect")
	clearLightingClass("DepthOfFieldEffect")

	-- Atmosphere
	if config.Atmosphere then
		local atmo = Instance.new("Atmosphere")
		atmo.Density = config.Atmosphere.Density
		atmo.Offset = config.Atmosphere.Offset
		atmo.Color = config.Atmosphere.Color
		atmo.Decay = config.Atmosphere.Decay
		atmo.Glare = config.Atmosphere.Glare
		atmo.Haze = config.Atmosphere.Haze
		atmo.Parent = Lighting
	end

	-- Sky
	if config.Sky then
		local sky = Instance.new("Sky")
		sky.CelestialBodiesShown = config.Sky.CelestialBodiesShown ~= false
		sky.StarCount = config.Sky.StarCount or 3000
		sky.MoonAngularSize = config.Sky.MoonAngularSize or 11
		sky.SunAngularSize = config.Sky.SunAngularSize or 21
		if config.Sky.SkyboxBk then sky.SkyboxBk = config.Sky.SkyboxBk end
		if config.Sky.SkyboxDn then sky.SkyboxDn = config.Sky.SkyboxDn end
		if config.Sky.SkyboxFt then sky.SkyboxFt = config.Sky.SkyboxFt end
		if config.Sky.SkyboxLf then sky.SkyboxLf = config.Sky.SkyboxLf end
		if config.Sky.SkyboxRt then sky.SkyboxRt = config.Sky.SkyboxRt end
		if config.Sky.SkyboxUp then sky.SkyboxUp = config.Sky.SkyboxUp end
		sky.Parent = Lighting
	end

	-- Bloom
	if config.Bloom then
		local bloom = Instance.new("BloomEffect")
		bloom.Intensity = config.Bloom.Intensity or 0.5
		bloom.Size = config.Bloom.Size or 24
		bloom.Threshold = config.Bloom.Threshold or 0.8
		bloom.Parent = Lighting
	end

	-- ColorCorrection
	if config.ColorCorrection then
		local cc = Instance.new("ColorCorrectionEffect")
		cc.Brightness = config.ColorCorrection.Brightness or 0
		cc.Contrast = config.ColorCorrection.Contrast or 0
		cc.Saturation = config.ColorCorrection.Saturation or 0
		cc.TintColor = config.ColorCorrection.TintColor or Color3.new(1, 1, 1)
		cc.Parent = Lighting
	end

	-- Ground material color
	if config.GroundColor then
		local material = config.GroundMaterial or Enum.Material.Grass
		Workspace.Terrain:SetMaterialColor(material, config.GroundColor)
	end
end

--------------------------------------------------------------------------------
-- SMOOTH TRANSITION
--------------------------------------------------------------------------------

local function transitionTo(config, duration)
	config = config or EnvironmentConfig.DEFAULT
	duration = duration or TRANSITION_DURATION

	activeTransitionId += 1
	local myId = activeTransitionId

	-- Ensure Atmosphere, Bloom, ColorCorrection exist
	local atmo = getOrCreate("Atmosphere", "Atmosphere")
	local bloom = getOrCreate("BloomEffect", "BloomEffect")
	local cc = getOrCreate("ColorCorrectionEffect", "ColorCorrectionEffect")

	local toAtmo = config.Atmosphere or {
		Density = atmo.Density, Offset = atmo.Offset,
		Color = atmo.Color, Decay = atmo.Decay,
		Glare = atmo.Glare, Haze = atmo.Haze,
	}
	local toBloom = config.Bloom or { Intensity = 0, Size = bloom.Size, Threshold = bloom.Threshold }
	local toCC = config.ColorCorrection or { Brightness = 0, Contrast = 0, Saturation = 0, TintColor = Color3.new(1, 1, 1) }

	-- Sky: swap instantly
	clearLightingClass("Sky")
	if config.Sky then
		local sky = Instance.new("Sky")
		sky.CelestialBodiesShown = config.Sky.CelestialBodiesShown ~= false
		sky.StarCount = config.Sky.StarCount or 3000
		sky.MoonAngularSize = config.Sky.MoonAngularSize or 11
		sky.SunAngularSize = config.Sky.SunAngularSize or 21
		sky.Parent = Lighting
	end

	-- Ground material: swap instantly
	if config.GroundColor then
		local material = config.GroundMaterial or Enum.Material.Grass
		Workspace.Terrain:SetMaterialColor(material, config.GroundColor)
	end

	-- Tween Lighting properties
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

	TweenService:Create(Lighting, tweenInfo, {
		ClockTime = config.ClockTime,
		Brightness = config.Brightness,
		Ambient = config.Ambient,
		OutdoorAmbient = config.OutdoorAmbient,
		FogStart = config.FogStart,
		FogEnd = config.FogEnd,
		FogColor = config.FogColor,
	}):Play()

	TweenService:Create(atmo, tweenInfo, {
		Density = toAtmo.Density,
		Offset = toAtmo.Offset,
		Color = toAtmo.Color,
		Decay = toAtmo.Decay,
		Glare = toAtmo.Glare,
		Haze = toAtmo.Haze,
	}):Play()

	TweenService:Create(bloom, tweenInfo, {
		Intensity = toBloom.Intensity or 0,
		Size = toBloom.Size or 24,
		Threshold = toBloom.Threshold or 0.8,
	}):Play()

	TweenService:Create(cc, tweenInfo, {
		Brightness = toCC.Brightness or 0,
		Contrast = toCC.Contrast or 0,
		Saturation = toCC.Saturation or 0,
		TintColor = toCC.TintColor or Color3.new(1, 1, 1),
	}):Play()
end

--------------------------------------------------------------------------------
-- HANDLE SERVER ENVIRONMENT EVENTS
--------------------------------------------------------------------------------

local function handleEnvironmentChanged(data)
	if not data or not data.envName then return end

	-- Debug override takes priority, then theme override, then server env
	local theme = ThemeConfig.THEMES[currentTheme]
	local effectiveEnv = data.envName
	if debugEnvOverride then
		effectiveEnv = debugEnvOverride
	elseif theme and theme.environment and currentTheme ~= "default" then
		effectiveEnv = theme.environment
	end

	local config = resolveConfig(effectiveEnv)

	if data.transition then
		transitionTo(config)
	else
		applyEnvironment(config)
	end

	print("[EnvironmentApplier] Applied: " .. effectiveEnv .. (data.transition and " (transition)" or ""))
end

local envRemote = Remotes.waitFor("EnvironmentChanged", 10)
if envRemote then
	envRemote.OnClientEvent:Connect(handleEnvironmentChanged)
end

--------------------------------------------------------------------------------
-- LISTEN FOR THEME CHANGES (re-apply environment with new theme override)
--------------------------------------------------------------------------------

local themeChangedRemote = Remotes.waitFor("ThemeChanged", 10)
if themeChangedRemote then
	themeChangedRemote.OnClientEvent:Connect(function(themeName)
		if not ThemeConfig.THEMES[themeName] then return end
		local oldTheme = currentTheme
		currentTheme = themeName

		-- Clear debug override when theme changes (so new theme's env takes effect)
		debugEnvOverride = nil

		-- If theme environment changed, re-apply
		local oldEnv = ThemeConfig.THEMES[oldTheme] and ThemeConfig.THEMES[oldTheme].environment
		local newEnv = ThemeConfig.THEMES[themeName] and ThemeConfig.THEMES[themeName].environment
		if oldEnv ~= newEnv then
			local effectiveEnv = newEnv or "world1"
			local config = resolveConfig(effectiveEnv)
			applyEnvironment(config)
			print("[EnvironmentApplier] Theme changed → env: " .. effectiveEnv)
		end
	end)
end

--------------------------------------------------------------------------------
-- DEBUG ENVIRONMENT OVERRIDE (set by DebugMenu via player attribute)
--------------------------------------------------------------------------------

local player = game:GetService("Players").LocalPlayer

player:GetAttributeChangedSignal("DebugEnvOverride"):Connect(function()
	local override = player:GetAttribute("DebugEnvOverride")
	if override and override ~= "" and override ~= "default" then
		debugEnvOverride = override
	else
		debugEnvOverride = nil
	end
	-- Apply immediately
	local config = resolveConfig(debugEnvOverride or (ThemeConfig.THEMES[currentTheme] and ThemeConfig.THEMES[currentTheme].environment) or "world1")
	applyEnvironment(config)
	print("[EnvironmentApplier] Debug env override: " .. (debugEnvOverride or "cleared"))
end)

--------------------------------------------------------------------------------
-- LISTEN FOR PLAYER DATA (initial theme on join)
--------------------------------------------------------------------------------

local dataSyncRemote = Remotes.waitFor("PlayerDataSync", 10)
if dataSyncRemote then
	dataSyncRemote.OnClientEvent:Connect(function(data)
		if data and data.selectedTheme then
			currentTheme = data.selectedTheme
		end
	end)
end

print("[EnvironmentApplier] Loaded")
