-- EnvironmentConfig.luau
-- Per-world environment presets (lighting, fog, atmosphere, sky, post-processing)

local EnvironmentConfig = {}

-- Default environment (menu, debug)
EnvironmentConfig.DEFAULT = {
	ClockTime = 14,
	Brightness = 2,
	Ambient = Color3.fromRGB(140, 140, 140),
	OutdoorAmbient = Color3.fromRGB(140, 140, 140),

	FogStart = 100,
	FogEnd = 400,
	FogColor = Color3.fromRGB(170, 190, 210),

	Atmosphere = {
		Density = 0.35,
		Offset = 0.25,
		Color = Color3.fromRGB(200, 210, 220),
		Decay = Color3.fromRGB(120, 140, 180),
		Glare = 0,
		Haze = 1,
	},

	GroundMaterial = Enum.Material.Grass,
	GroundColor = Color3.fromRGB(90, 130, 90),
}

-- Per-world presets
EnvironmentConfig.WORLDS = {
	world1 = {
		-- City: stripped down, sky only — add effects back one by one
		ClockTime = 21.5,
		Brightness = 1.5,
		Ambient = Color3.fromRGB(110, 115, 140),
		OutdoorAmbient = Color3.fromRGB(95, 100, 125),

		FogStart = 1000,
		FogEnd = 10000,
		FogColor = Color3.fromRGB(0, 0, 0),

		Sky = {
			CelestialBodiesShown = true,
			StarCount = 5000,
			MoonAngularSize = 11,
			SunAngularSize = 0,
		},

		Bloom = {
			Intensity = 0.3,
			Size = 24,
			Threshold = 0.9,
		},

		GroundMaterial = Enum.Material.Asphalt,
		GroundColor = Color3.fromRGB(30, 30, 35),
	},

}

-- Environment presets (usable per-group via weather/environment system)
EnvironmentConfig.ENVIRONMENTS = {
	golden_hour = {
		ClockTime = 17.5,
		Brightness = 2.5,
		Ambient = Color3.fromRGB(180, 140, 100),
		OutdoorAmbient = Color3.fromRGB(200, 160, 110),

		FogStart = 150,
		FogEnd = 600,
		FogColor = Color3.fromRGB(255, 200, 130),

		Atmosphere = {
			Density = 0.4,
			Offset = 0.3,
			Color = Color3.fromRGB(255, 210, 150),
			Decay = Color3.fromRGB(200, 130, 60),
			Glare = 0.5,
			Haze = 2,
		},

		Bloom = {
			Intensity = 0.6,
			Size = 30,
			Threshold = 0.7,
		},

		ColorCorrection = {
			Brightness = 0.05,
			Contrast = 0.1,
			Saturation = 0.2,
			TintColor = Color3.fromRGB(255, 230, 200),
		},

		GroundMaterial = Enum.Material.Grass,
		GroundColor = Color3.fromRGB(120, 140, 80),
	},

	overcast = {
		ClockTime = 12,
		Brightness = 1,
		Ambient = Color3.fromRGB(120, 120, 125),
		OutdoorAmbient = Color3.fromRGB(110, 110, 115),

		FogStart = 80,
		FogEnd = 350,
		FogColor = Color3.fromRGB(160, 165, 170),

		Atmosphere = {
			Density = 0.5,
			Offset = 0.2,
			Color = Color3.fromRGB(180, 185, 190),
			Decay = Color3.fromRGB(140, 145, 150),
			Glare = 0,
			Haze = 3,
		},

		GroundMaterial = Enum.Material.Grass,
		GroundColor = Color3.fromRGB(80, 110, 80),
	},

	desert = {
		ClockTime = 13,
		Brightness = 3,
		Ambient = Color3.fromRGB(180, 160, 130),
		OutdoorAmbient = Color3.fromRGB(200, 180, 140),

		FogStart = 200,
		FogEnd = 800,
		FogColor = Color3.fromRGB(220, 200, 160),

		Atmosphere = {
			Density = 0.3,
			Offset = 0.4,
			Color = Color3.fromRGB(230, 210, 170),
			Decay = Color3.fromRGB(180, 150, 100),
			Glare = 0.3,
			Haze = 2,
		},

		ColorCorrection = {
			Brightness = 0.05,
			Contrast = 0.15,
			Saturation = -0.1,
			TintColor = Color3.fromRGB(255, 240, 200),
		},

		GroundMaterial = Enum.Material.Sand,
		GroundColor = Color3.fromRGB(194, 178, 128),
	},

	foggy = {
		ClockTime = 8,
		Brightness = 1.2,
		Ambient = Color3.fromRGB(140, 145, 150),
		OutdoorAmbient = Color3.fromRGB(130, 135, 140),

		FogStart = 20,
		FogEnd = 150,
		FogColor = Color3.fromRGB(190, 195, 200),

		Atmosphere = {
			Density = 0.8,
			Offset = 0.1,
			Color = Color3.fromRGB(200, 205, 210),
			Decay = Color3.fromRGB(160, 165, 170),
			Glare = 0,
			Haze = 6,
		},

		GroundMaterial = Enum.Material.Grass,
		GroundColor = Color3.fromRGB(85, 120, 85),
	},

	neon_night = {
		ClockTime = 22,
		Brightness = 1,
		Ambient = Color3.fromRGB(80, 70, 120),
		OutdoorAmbient = Color3.fromRGB(70, 60, 110),

		FogStart = 100,
		FogEnd = 500,
		FogColor = Color3.fromRGB(20, 10, 40),

		Sky = {
			CelestialBodiesShown = true,
			StarCount = 3000,
			MoonAngularSize = 11,
			SunAngularSize = 0,
		},

		Bloom = {
			Intensity = 0.5,
			Size = 32,
			Threshold = 0.75,
		},

		ColorCorrection = {
			Brightness = 0,
			Contrast = 0.2,
			Saturation = 0.3,
			TintColor = Color3.fromRGB(220, 200, 255),
		},

		GroundMaterial = Enum.Material.Asphalt,
		GroundColor = Color3.fromRGB(25, 20, 35),
	},

	dawn = {
		ClockTime = 6,
		Brightness = 1.8,
		Ambient = Color3.fromRGB(150, 120, 130),
		OutdoorAmbient = Color3.fromRGB(160, 130, 140),

		FogStart = 100,
		FogEnd = 500,
		FogColor = Color3.fromRGB(230, 180, 160),

		Atmosphere = {
			Density = 0.35,
			Offset = 0.3,
			Color = Color3.fromRGB(240, 190, 170),
			Decay = Color3.fromRGB(200, 140, 120),
			Glare = 0.2,
			Haze = 2,
		},

		Bloom = {
			Intensity = 0.4,
			Size = 28,
			Threshold = 0.8,
		},

		GroundMaterial = Enum.Material.Grass,
		GroundColor = Color3.fromRGB(90, 125, 85),
	},

	storm = {
		ClockTime = 15,
		Brightness = 0.5,
		Ambient = Color3.fromRGB(60, 60, 65),
		OutdoorAmbient = Color3.fromRGB(50, 50, 55),

		FogStart = 40,
		FogEnd = 250,
		FogColor = Color3.fromRGB(70, 75, 80),

		Atmosphere = {
			Density = 0.6,
			Offset = 0.15,
			Color = Color3.fromRGB(90, 95, 100),
			Decay = Color3.fromRGB(60, 65, 70),
			Glare = 0,
			Haze = 5,
		},

		ColorCorrection = {
			Brightness = -0.1,
			Contrast = 0.15,
			Saturation = -0.2,
			TintColor = Color3.fromRGB(200, 210, 220),
		},

		GroundMaterial = Enum.Material.Grass,
		GroundColor = Color3.fromRGB(60, 80, 60),
	},

	space = {
		ClockTime = 0,
		Brightness = 0.3,
		Ambient = Color3.fromRGB(15, 15, 20),
		OutdoorAmbient = Color3.fromRGB(10, 10, 15),

		FogStart = 10000,
		FogEnd = 10000,
		FogColor = Color3.fromRGB(0, 0, 0),

		Sky = {
			CelestialBodiesShown = true,
			StarCount = 8000,
			MoonAngularSize = 14,
			SunAngularSize = 0,
		},

		GroundMaterial = Enum.Material.Slate,
		GroundColor = Color3.fromRGB(20, 20, 25),
	},

	underwater = {
		ClockTime = 12,
		Brightness = 0.4,
		Ambient = Color3.fromRGB(20, 50, 70),
		OutdoorAmbient = Color3.fromRGB(15, 40, 60),

		FogStart = 10,
		FogEnd = 80,
		FogColor = Color3.fromRGB(10, 30, 50),

		Atmosphere = {
			Density = 0.9,
			Offset = 0.0,
			Color = Color3.fromRGB(20, 60, 90),
			Decay = Color3.fromRGB(10, 30, 50),
			Glare = 0,
			Haze = 8,
		},

		ColorCorrection = {
			Brightness = -0.15,
			Contrast = 0.1,
			Saturation = -0.1,
			TintColor = Color3.fromRGB(100, 180, 220),
		},

		Bloom = {
			Intensity = 0.3,
			Size = 20,
			Threshold = 0.85,
		},

		GroundMaterial = Enum.Material.Sand,
		GroundColor = Color3.fromRGB(120, 110, 80),
	},
}

-- Alias: WORLDS entries are also valid environment presets
for id, preset in pairs(EnvironmentConfig.WORLDS) do
	if not EnvironmentConfig.ENVIRONMENTS[id] then
		EnvironmentConfig.ENVIRONMENTS[id] = preset
	end
end

function EnvironmentConfig.getPresetNames(): { string }
	local names = {}
	for name in pairs(EnvironmentConfig.ENVIRONMENTS) do
		table.insert(names, name)
	end
	table.sort(names)
	return names
end

return EnvironmentConfig
