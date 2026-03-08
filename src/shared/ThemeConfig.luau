-- ThemeConfig.luau
-- Defines available visual themes for decor/vehicles.
-- Each theme has per-builder palette overrides; missing keys = use builder defaults.

local ThemeConfig = {}

ThemeConfig.DEFAULT_THEME = "default"

ThemeConfig.THEMES = {
	default = {}, -- no environment override = use per-group environments as normal

	neon = {
		environment = "golden_hour",
		terrain = {
			material = Enum.Material.Asphalt,
			color = Color3.fromRGB(25, 20, 35),
		},
		tree = {
			trunk = Color3.fromRGB(30, 30, 40),
			leaves = Color3.fromRGB(0, 255, 180),
			bush = Color3.fromRGB(255, 50, 100),
		},
		lamp = {
			pole = Color3.fromRGB(20, 20, 25),
			housing = Color3.fromRGB(25, 25, 30),
			light = Color3.fromRGB(0, 200, 255),
		},
		buildings = {
			bodyColors = { Color3.fromRGB(30, 25, 45), Color3.fromRGB(20, 25, 40), Color3.fromRGB(35, 20, 35) },
			bodyMaterial = Enum.Material.SmoothPlastic,
			roofColor = Color3.fromRGB(20, 15, 30),
			windowLit = { Color3.fromRGB(0, 255, 180), Color3.fromRGB(255, 60, 80), Color3.fromRGB(0, 180, 255), Color3.fromRGB(120, 50, 255), Color3.fromRGB(255, 200, 0) },
			windowDark = { Color3.fromRGB(20, 30, 50), Color3.fromRGB(30, 20, 45), Color3.fromRGB(15, 25, 40) },
		},
		vehicles = {
			bodyColors = { Color3.fromRGB(0, 255, 180), Color3.fromRGB(0, 180, 255), Color3.fromRGB(120, 50, 255), Color3.fromRGB(255, 60, 80), Color3.fromRGB(255, 200, 0), Color3.fromRGB(255, 0, 200) },
		},
		shops = {
			wallColors = { Color3.fromRGB(30, 25, 45), Color3.fromRGB(25, 30, 45), Color3.fromRGB(35, 20, 40) },
			signColors = { Color3.fromRGB(0, 255, 180), Color3.fromRGB(255, 60, 80), Color3.fromRGB(0, 180, 255), Color3.fromRGB(255, 200, 0) },
			windowColors = { Color3.fromRGB(0, 255, 180), Color3.fromRGB(120, 80, 255), Color3.fromRGB(255, 60, 100), Color3.fromRGB(0, 200, 255) },
			floorColor = Color3.fromRGB(25, 20, 35),
			ceilingColor = Color3.fromRGB(0, 200, 255),
			roofColor = Color3.fromRGB(20, 15, 30),
			shopLight = Color3.fromRGB(120, 80, 255),
			glass = Color3.fromRGB(80, 120, 255),
			mullion = Color3.fromRGB(60, 80, 120),
			darkWindow = Color3.fromRGB(20, 30, 50),
			wallMaterial = Enum.Material.SmoothPlastic,
			awningMaterial = Enum.Material.Neon,
			nameList = {
				"PIXEL", "CYBER", "GLITCH", "SYNTH", "VAPOR",
				"HOLO", "NEON", "BYTE", "PULSE", "LASER",
			},
			signFonts = { Enum.Font.FredokaOne, Enum.Font.Bangers },
		},
	},

	western = {
		environment = "desert",
		terrain = {
			material = Enum.Material.Sand,
			color = Color3.fromRGB(210, 180, 130),
		},
		tree = {
			trunk = Color3.fromRGB(90, 55, 25),
			leaves = Color3.fromRGB(140, 110, 40),
			bush = Color3.fromRGB(120, 100, 35),
		},
		lamp = {
			pole = Color3.fromRGB(70, 50, 30),
			housing = Color3.fromRGB(80, 55, 35),
			light = Color3.fromRGB(255, 180, 80),
		},
		buildings = {
			bodyColors = { Color3.fromRGB(180, 140, 90), Color3.fromRGB(160, 110, 70), Color3.fromRGB(190, 150, 100) },
			bodyMaterial = Enum.Material.WoodPlanks,
			roofColor = Color3.fromRGB(60, 40, 25),
			windowLit = { Color3.fromRGB(255, 200, 100), Color3.fromRGB(255, 170, 60), Color3.fromRGB(255, 220, 140) },
			windowDark = { Color3.fromRGB(100, 70, 40), Color3.fromRGB(80, 55, 30), Color3.fromRGB(110, 80, 50) },
		},
		vehicles = {
			bodyColors = { Color3.fromRGB(160, 90, 40), Color3.fromRGB(180, 160, 120), Color3.fromRGB(120, 80, 50), Color3.fromRGB(90, 70, 40), Color3.fromRGB(200, 60, 40) },
		},
		shops = {
			wallColors = { Color3.fromRGB(180, 110, 70), Color3.fromRGB(160, 100, 60), Color3.fromRGB(190, 130, 80) },
			signColors = { Color3.fromRGB(200, 60, 40), Color3.fromRGB(220, 150, 40), Color3.fromRGB(240, 200, 140) },
			windowColors = { Color3.fromRGB(255, 200, 100), Color3.fromRGB(255, 180, 80), Color3.fromRGB(240, 160, 60) },
			floorColor = Color3.fromRGB(140, 100, 65),
			ceilingColor = Color3.fromRGB(255, 220, 160),
			roofColor = Color3.fromRGB(60, 40, 25),
			shopLight = Color3.fromRGB(255, 190, 100),
			glass = Color3.fromRGB(230, 200, 150),
			mullion = Color3.fromRGB(90, 65, 40),
			darkWindow = Color3.fromRGB(100, 70, 40),
			wallMaterial = Enum.Material.WoodPlanks,
			awningMaterial = Enum.Material.Wood,
			nameList = {
				"VINYL", "JUKEBOX", "DINER", "DRIVE-IN", "MALT SHOP",
				"RECORDS", "ROLLER", "SODA POP", "PINBALL", "OLDIES",
			},
			signFonts = { Enum.Font.PermanentMarker, Enum.Font.LuckiestGuy, Enum.Font.PatrickHand },
		},
	},

	candy = {
		environment = "desert",
		terrain = {
			material = Enum.Material.Salt,
			color = Color3.fromRGB(255, 180, 200),
		},
		tree = {
			trunk = Color3.fromRGB(255, 100, 120),
			leaves = Color3.fromRGB(255, 80, 180),
			bush = Color3.fromRGB(100, 220, 255),
		},
		lamp = {
			pole = Color3.fromRGB(255, 255, 255),
			housing = Color3.fromRGB(255, 200, 220),
			light = Color3.fromRGB(255, 150, 200),
		},
		buildings = {
			bodyColors = { Color3.fromRGB(255, 170, 200), Color3.fromRGB(180, 220, 255), Color3.fromRGB(200, 170, 255), Color3.fromRGB(255, 230, 150) },
			bodyMaterial = Enum.Material.SmoothPlastic,
			roofColor = Color3.fromRGB(220, 160, 200),
			windowLit = { Color3.fromRGB(255, 180, 220), Color3.fromRGB(180, 255, 230), Color3.fromRGB(200, 180, 255), Color3.fromRGB(255, 230, 140) },
			windowDark = { Color3.fromRGB(180, 140, 170), Color3.fromRGB(140, 160, 180), Color3.fromRGB(170, 150, 180) },
		},
		vehicles = {
			bodyColors = { Color3.fromRGB(255, 130, 180), Color3.fromRGB(130, 230, 200), Color3.fromRGB(200, 160, 255), Color3.fromRGB(255, 230, 100), Color3.fromRGB(130, 210, 255) },
		},
		shops = {
			wallColors = { Color3.fromRGB(255, 140, 170), Color3.fromRGB(130, 210, 255), Color3.fromRGB(180, 140, 255), Color3.fromRGB(255, 200, 100), Color3.fromRGB(140, 230, 180) },
			signColors = { Color3.fromRGB(255, 80, 150), Color3.fromRGB(100, 220, 200), Color3.fromRGB(255, 180, 50) },
			windowColors = { Color3.fromRGB(255, 180, 220), Color3.fromRGB(180, 255, 230), Color3.fromRGB(200, 180, 255) },
			floorColor = Color3.fromRGB(255, 230, 240),
			ceilingColor = Color3.fromRGB(255, 200, 230),
			roofColor = Color3.fromRGB(200, 150, 180),
			shopLight = Color3.fromRGB(255, 200, 230),
			glass = Color3.fromRGB(255, 210, 240),
			mullion = Color3.fromRGB(220, 180, 200),
			darkWindow = Color3.fromRGB(180, 140, 170),
			wallMaterial = Enum.Material.SmoothPlastic,
			awningMaterial = Enum.Material.Fabric,
			nameList = {
				"GUMMY", "LOLLIPOP", "TAFFY", "CUPCAKE", "SPRINKLES",
				"BONBON", "FROSTING", "JELLYBEAN", "SUGAR", "MARSHMALLOW",
			},
			signFonts = { Enum.Font.FredokaOne, Enum.Font.LuckiestGuy },
		},
	},

	frost = {
		environment = "world1",
		terrain = {
			material = Enum.Material.Glacier,
			color = Color3.fromRGB(200, 230, 255),
		},
		tree = {
			trunk = Color3.fromRGB(180, 200, 220),
			leaves = Color3.fromRGB(220, 240, 255),
			bush = Color3.fromRGB(190, 225, 250),
		},
		lamp = {
			pole = Color3.fromRGB(180, 195, 210),
			housing = Color3.fromRGB(200, 215, 230),
			light = Color3.fromRGB(180, 220, 255),
		},
		buildings = {
			bodyColors = { Color3.fromRGB(210, 225, 240), Color3.fromRGB(190, 215, 235), Color3.fromRGB(225, 240, 255) },
			bodyMaterial = Enum.Material.Ice,
			roofColor = Color3.fromRGB(150, 170, 190),
			windowLit = { Color3.fromRGB(160, 220, 255), Color3.fromRGB(200, 240, 255), Color3.fromRGB(140, 200, 250) },
			windowDark = { Color3.fromRGB(120, 150, 180), Color3.fromRGB(100, 130, 165), Color3.fromRGB(140, 165, 190) },
		},
		vehicles = {
			bodyColors = { Color3.fromRGB(200, 220, 240), Color3.fromRGB(180, 200, 220), Color3.fromRGB(230, 240, 255), Color3.fromRGB(160, 190, 210), Color3.fromRGB(240, 245, 255) },
		},
		shops = {
			wallColors = { Color3.fromRGB(210, 225, 240), Color3.fromRGB(190, 210, 230), Color3.fromRGB(220, 235, 250) },
			signColors = { Color3.fromRGB(100, 180, 255), Color3.fromRGB(150, 220, 255), Color3.fromRGB(200, 240, 255) },
			windowColors = { Color3.fromRGB(160, 210, 255), Color3.fromRGB(180, 230, 255), Color3.fromRGB(140, 200, 250) },
			floorColor = Color3.fromRGB(230, 240, 250),
			ceilingColor = Color3.fromRGB(200, 230, 255),
			roofColor = Color3.fromRGB(150, 170, 190),
			shopLight = Color3.fromRGB(180, 220, 255),
			glass = Color3.fromRGB(200, 235, 255),
			mullion = Color3.fromRGB(170, 185, 200),
			darkWindow = Color3.fromRGB(120, 150, 180),
			wallMaterial = Enum.Material.Ice,
			awningMaterial = Enum.Material.SmoothPlastic,
			nameList = {
				"GLACIER", "FROST", "ICEBERG", "SNOWFLAKE", "ARCTIC",
				"POLAR", "BLIZZARD", "CRYSTAL", "FROZEN", "AVALANCHE",
			},
			signFonts = { Enum.Font.GothamBold, Enum.Font.Oswald },
		},
	},

	lava = {
		environment = "golden_hour",
		terrain = {
			material = Enum.Material.CrackedLava,
			color = Color3.fromRGB(40, 10, 5),
		},
		tree = {
			trunk = Color3.fromRGB(30, 15, 10),
			leaves = Color3.fromRGB(255, 80, 0),
			bush = Color3.fromRGB(255, 40, 0),
		},
		lamp = {
			pole = Color3.fromRGB(25, 15, 10),
			housing = Color3.fromRGB(40, 20, 10),
			light = Color3.fromRGB(255, 120, 0),
		},
		buildings = {
			bodyColors = { Color3.fromRGB(35, 15, 10), Color3.fromRGB(50, 20, 10), Color3.fromRGB(30, 10, 5) },
			bodyMaterial = Enum.Material.CorrodedMetal,
			roofColor = Color3.fromRGB(15, 8, 5),
			windowLit = { Color3.fromRGB(255, 80, 0), Color3.fromRGB(255, 160, 0), Color3.fromRGB(255, 40, 0), Color3.fromRGB(255, 220, 50) },
			windowDark = { Color3.fromRGB(60, 20, 5), Color3.fromRGB(40, 10, 5), Color3.fromRGB(70, 30, 10) },
		},
		vehicles = {
			bodyColors = { Color3.fromRGB(40, 10, 5), Color3.fromRGB(80, 20, 10), Color3.fromRGB(30, 30, 35), Color3.fromRGB(255, 80, 0), Color3.fromRGB(50, 15, 30) },
		},
		shops = {
			wallColors = { Color3.fromRGB(35, 15, 10), Color3.fromRGB(50, 20, 10), Color3.fromRGB(30, 10, 5) },
			signColors = { Color3.fromRGB(255, 60, 0), Color3.fromRGB(255, 160, 0), Color3.fromRGB(255, 220, 50) },
			windowColors = { Color3.fromRGB(255, 100, 20), Color3.fromRGB(255, 160, 0), Color3.fromRGB(255, 60, 0) },
			floorColor = Color3.fromRGB(20, 10, 5),
			ceilingColor = Color3.fromRGB(255, 80, 0),
			roofColor = Color3.fromRGB(15, 8, 5),
			shopLight = Color3.fromRGB(255, 100, 0),
			glass = Color3.fromRGB(255, 60, 10),
			mullion = Color3.fromRGB(50, 25, 10),
			darkWindow = Color3.fromRGB(60, 20, 5),
			wallMaterial = Enum.Material.CorrodedMetal,
			awningMaterial = Enum.Material.Neon,
			nameList = {
				"INFERNO", "MAGMA", "EMBER", "VOLCANO", "HELLFIRE",
				"CINDER", "ERUPTION", "MOLTEN", "FURNACE", "PYROCLASM",
			},
			signFonts = { Enum.Font.Bangers, Enum.Font.PermanentMarker },
		},
	},

	greenery = {
		environment = "default",
		terrain = {
			material = Enum.Material.Grass,
			color = Color3.fromRGB(60, 140, 50),
		},
		tree = {
			trunk = Color3.fromRGB(60, 40, 20),
			leaves = Color3.fromRGB(30, 120, 25),
			bush = Color3.fromRGB(40, 100, 30),
		},
		lamp = {
			pole = Color3.fromRGB(70, 55, 30),
			housing = Color3.fromRGB(55, 45, 25),
			light = Color3.fromRGB(200, 255, 100),
		},
		buildings = {
			bodyColors = { Color3.fromRGB(60, 100, 50), Color3.fromRGB(50, 80, 40), Color3.fromRGB(70, 110, 60) },
			bodyMaterial = Enum.Material.Grass,
			roofColor = Color3.fromRGB(40, 50, 20),
			windowLit = { Color3.fromRGB(180, 230, 100), Color3.fromRGB(120, 200, 80), Color3.fromRGB(200, 240, 60) },
			windowDark = { Color3.fromRGB(50, 70, 35), Color3.fromRGB(35, 55, 25), Color3.fromRGB(60, 80, 40) },
		},
		vehicles = {
			bodyColors = { Color3.fromRGB(40, 100, 40), Color3.fromRGB(80, 70, 30), Color3.fromRGB(110, 90, 50), Color3.fromRGB(30, 80, 30), Color3.fromRGB(60, 50, 25) },
		},
		shops = {
			wallColors = { Color3.fromRGB(50, 120, 40), Color3.fromRGB(40, 100, 30), Color3.fromRGB(60, 130, 50) },
			signColors = { Color3.fromRGB(80, 200, 50), Color3.fromRGB(200, 180, 60), Color3.fromRGB(150, 100, 40) },
			windowColors = { Color3.fromRGB(120, 200, 80), Color3.fromRGB(180, 220, 100), Color3.fromRGB(100, 180, 60) },
			floorColor = Color3.fromRGB(70, 55, 30),
			ceilingColor = Color3.fromRGB(140, 180, 80),
			roofColor = Color3.fromRGB(40, 50, 20),
			shopLight = Color3.fromRGB(180, 230, 100),
			glass = Color3.fromRGB(140, 200, 120),
			mullion = Color3.fromRGB(80, 60, 30),
			darkWindow = Color3.fromRGB(50, 70, 35),
			wallMaterial = Enum.Material.Grass,
			awningMaterial = Enum.Material.LeafyGrass,
			nameList = {
				"CANOPY", "VINE", "PARROT", "SAFARI", "BAMBOO",
				"MANGROVE", "ORCHID", "TOUCAN", "JAGUAR", "RAPIDS",
			},
			signFonts = { Enum.Font.PatrickHand, Enum.Font.FredokaOne },
		},
	},

	steampunk = {
		environment = "golden_hour",
		terrain = {
			material = Enum.Material.Basalt,
			color = Color3.fromRGB(60, 55, 50),
		},
		tree = {
			trunk = Color3.fromRGB(100, 60, 30),
			leaves = Color3.fromRGB(160, 120, 50),
			bush = Color3.fromRGB(130, 100, 45),
		},
		lamp = {
			pole = Color3.fromRGB(140, 90, 40),
			housing = Color3.fromRGB(170, 110, 50),
			light = Color3.fromRGB(255, 180, 60),
		},
		buildings = {
			bodyColors = { Color3.fromRGB(180, 50, 30), Color3.fromRGB(30, 60, 120), Color3.fromRGB(20, 130, 110), Color3.fromRGB(120, 25, 70), Color3.fromRGB(200, 140, 40) },
			bodyMaterial = Enum.Material.SmoothPlastic,
			roofColor = Color3.fromRGB(40, 30, 25),
			windowLit = { Color3.fromRGB(255, 200, 100), Color3.fromRGB(240, 180, 60), Color3.fromRGB(255, 220, 140) },
			windowDark = { Color3.fromRGB(80, 55, 30), Color3.fromRGB(60, 40, 20), Color3.fromRGB(90, 65, 35) },
		},
		vehicles = {
			bodyColors = { Color3.fromRGB(180, 50, 30), Color3.fromRGB(30, 60, 120), Color3.fromRGB(20, 130, 110), Color3.fromRGB(120, 25, 70), Color3.fromRGB(200, 140, 40) },
		},
		shops = {
			wallColors = { Color3.fromRGB(180, 50, 30), Color3.fromRGB(30, 60, 120), Color3.fromRGB(20, 130, 110), Color3.fromRGB(120, 25, 70), Color3.fromRGB(200, 140, 40) },
			signColors = { Color3.fromRGB(180, 130, 40), Color3.fromRGB(200, 160, 60), Color3.fromRGB(160, 100, 30) },
			windowColors = { Color3.fromRGB(255, 200, 100), Color3.fromRGB(240, 180, 80), Color3.fromRGB(220, 160, 60) },
			floorColor = Color3.fromRGB(90, 70, 50),
			ceilingColor = Color3.fromRGB(255, 200, 100),
			roofColor = Color3.fromRGB(100, 65, 30),
			shopLight = Color3.fromRGB(255, 190, 80),
			glass = Color3.fromRGB(200, 170, 100),
			mullion = Color3.fromRGB(160, 110, 50),
			darkWindow = Color3.fromRGB(80, 55, 30),
			wallMaterial = Enum.Material.SmoothPlastic,
			awningMaterial = Enum.Material.Metal,
			nameList = {
				"GEARS", "FOUNDRY", "BOILER", "PISTON", "CLOCKWORK",
				"COPPER", "AIRSHIP", "FORGE", "GADGET", "SPROCKET",
			},
			signFonts = { Enum.Font.Oswald, Enum.Font.GothamBold },
		},
	},

	forge = {
		environment = "overcast",
		terrain = {
			material = Enum.Material.Ground,
			color = Color3.fromRGB(50, 50, 55),
		},
		tree = {
			trunk = Color3.fromRGB(40, 40, 45),
			leaves = Color3.fromRGB(0, 160, 255),
			bush = Color3.fromRGB(255, 220, 60),
		},
		lamp = {
			pole = Color3.fromRGB(50, 50, 55),
			housing = Color3.fromRGB(70, 70, 80),
			light = Color3.fromRGB(80, 180, 255),
		},
		buildings = {
			bodyColors = { Color3.fromRGB(160, 40, 20), Color3.fromRGB(30, 80, 140), Color3.fromRGB(60, 60, 70), Color3.fromRGB(180, 140, 30), Color3.fromRGB(40, 45, 50) },
			bodyMaterial = Enum.Material.DiamondPlate,
			roofColor = Color3.fromRGB(25, 25, 30),
			windowLit = { Color3.fromRGB(0, 160, 255), Color3.fromRGB(255, 240, 180), Color3.fromRGB(255, 180, 40), Color3.fromRGB(100, 200, 255) },
			windowDark = { Color3.fromRGB(20, 25, 35), Color3.fromRGB(30, 30, 40), Color3.fromRGB(15, 20, 30) },
		},
		vehicles = {
			bodyColors = { Color3.fromRGB(160, 40, 20), Color3.fromRGB(30, 80, 140), Color3.fromRGB(60, 60, 70), Color3.fromRGB(180, 140, 30), Color3.fromRGB(40, 45, 50) },
		},
		shops = {
			wallColors = { Color3.fromRGB(160, 40, 20), Color3.fromRGB(30, 80, 140), Color3.fromRGB(60, 60, 70), Color3.fromRGB(180, 140, 30), Color3.fromRGB(40, 45, 50) },
			signColors = { Color3.fromRGB(0, 180, 255), Color3.fromRGB(255, 240, 120), Color3.fromRGB(255, 100, 20) },
			windowColors = { Color3.fromRGB(0, 160, 255), Color3.fromRGB(255, 240, 180), Color3.fromRGB(100, 200, 255) },
			floorColor = Color3.fromRGB(35, 35, 40),
			ceilingColor = Color3.fromRGB(80, 180, 255),
			roofColor = Color3.fromRGB(25, 25, 30),
			shopLight = Color3.fromRGB(80, 180, 255),
			glass = Color3.fromRGB(60, 140, 200),
			mullion = Color3.fromRGB(70, 70, 80),
			darkWindow = Color3.fromRGB(20, 25, 35),
			wallMaterial = Enum.Material.DiamondPlate,
			awningMaterial = Enum.Material.Metal,
			nameList = {
				"ANVIL", "HAMMER", "SMELT", "INGOT", "CRUCIBLE",
				"BELLOWS", "TEMPER", "ALLOY", "RIVET", "FURNACE",
			},
			signFonts = { Enum.Font.Oswald, Enum.Font.Bangers },
		},
	},

	artdeco = {
		environment = "desert",
		terrain = {
			material = Enum.Material.Limestone,
			color = Color3.fromRGB(220, 215, 210),
		},
		tree = {
			trunk = Color3.fromRGB(200, 195, 190),
			leaves = Color3.fromRGB(180, 230, 200),
			bush = Color3.fromRGB(170, 210, 190),
		},
		lamp = {
			pole = Color3.fromRGB(190, 190, 195),
			housing = Color3.fromRGB(200, 200, 205),
			light = Color3.fromRGB(255, 255, 255),
		},
		buildings = {
			bodyColors = { Color3.fromRGB(235, 240, 245), Color3.fromRGB(240, 235, 245), Color3.fromRGB(245, 240, 235) },
			bodyMaterial = Enum.Material.Glass,
			roofColor = Color3.fromRGB(200, 200, 205),
			windowLit = { Color3.fromRGB(220, 240, 255), Color3.fromRGB(240, 220, 240), Color3.fromRGB(230, 245, 230) },
			windowDark = { Color3.fromRGB(180, 190, 200), Color3.fromRGB(190, 185, 195), Color3.fromRGB(175, 185, 195) },
		},
		vehicles = {
			bodyColors = { Color3.fromRGB(245, 242, 235), Color3.fromRGB(210, 195, 165), Color3.fromRGB(185, 185, 190), Color3.fromRGB(30, 40, 70), Color3.fromRGB(90, 30, 45) },
		},
		shops = {
			wallColors = { Color3.fromRGB(230, 240, 250), Color3.fromRGB(240, 230, 245), Color3.fromRGB(235, 245, 240), Color3.fromRGB(245, 235, 230), Color3.fromRGB(230, 235, 245) },
			signColors = { Color3.fromRGB(100, 200, 180), Color3.fromRGB(180, 130, 220), Color3.fromRGB(200, 170, 100) },
			windowColors = { Color3.fromRGB(200, 240, 220), Color3.fromRGB(220, 200, 240), Color3.fromRGB(240, 220, 200) },
			floorColor = Color3.fromRGB(240, 240, 245),
			ceilingColor = Color3.fromRGB(255, 255, 255),
			roofColor = Color3.fromRGB(200, 200, 205),
			shopLight = Color3.fromRGB(255, 255, 255),
			glass = Color3.fromRGB(230, 240, 250),
			mullion = Color3.fromRGB(200, 200, 210),
			darkWindow = Color3.fromRGB(180, 190, 200),
			wallMaterial = Enum.Material.Glass,
			awningMaterial = Enum.Material.Glass,
			nameList = {
				"PRISM", "CRYSTAL", "MIRROR", "DIAMOND", "OPTIC",
				"SHARD", "REFRACT", "LUCID", "CLARITY", "SPECTRUM",
			},
			signFonts = { Enum.Font.GothamBold, Enum.Font.Oswald },
		},
	},
}

-- Ordered list for debug cycling
ThemeConfig.THEME_NAMES = { "default", "neon", "western", "candy", "frost", "lava", "greenery", "steampunk", "forge", "artdeco" }

-- Theme prices (0 = free, >0 = coin cost)
ThemeConfig.PRICES = {
	default   = 0,
	neon      = 0,
	western   = 0,
	candy     = 500,
	frost     = 500,
	lava      = 1000,
	greenery  = 1000,
	steampunk = 1500,
	forge     = 1500,
	artdeco   = 2000,
}

return ThemeConfig
