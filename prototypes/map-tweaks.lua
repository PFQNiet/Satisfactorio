-- remove starting lake - expression is basically clamp(real_map, -math.huge, starting_lakes) so this replaces it with just real_map
data.raw['noise-expression']['0_17-lakes-elevation'].expression = data.raw['noise-expression']['0_17-lakes-elevation'].expression.arguments[1]
-- remove enemy base autoplacement (they will be spawned manually around places of interest)
data.raw['unit-spawner']['biter-spawner'].autoplace = nil
data.raw['unit-spawner']['spitter-spawner'].autoplace = nil
data.raw['turret']['small-worm-turret'].autoplace = nil
data.raw['turret']['medium-worm-turret'].autoplace = nil
data.raw['turret']['big-worm-turret'].autoplace = nil
data.raw['turret']['behemoth-worm-turret'].autoplace = nil
-- disable enemy settings by default
local settings = data.raw['map-settings']['map-settings']
settings.enemy_evolution.enabled = false
settings.enemy_expansion.enabled = false

data.raw['map-gen-presets'].default.blank = {
	order = "zzz",
	basic_settings = {
		water = "none",
		autoplace_controls = {
			["iron-ore"] = {size="none"},
			["copper-ore"] = {size="none"},
			["stone"] = {size="none"},
			["coal"] = {size="none"},
			["crude-oil"] = {size="none"},
			["caterium-ore"] = {size="none"},
			["bauxite"] = {size="none"},
			["raw-quartz"] = {size="none"},
			["sulfur"] = {size="none"},
			["uranium-ore"] = {size="none"},
			["water-well"] = {size="none"},
			["crude-oil-well"] = {size="none"},
			["nitrogen-gas-well"] = {size="none"},
			["trees"] = {size="none"},
			["x-plant"] = {size="none"},
			["x-deposit"] = {size="none"},
			["x-powerslug"] = {size="none"},
			["x-crashsite"] = {size="none"},
			["geyser"] = {size="none"},
			["enemy-base"] = {size="none"}
		},
		cliff_settings = {
			name = "cliff",
			richness = 0
		}
	},
	advanced_settings = {
		pollution = {enabled = false},
		enemy_evolution = {enabled = false},
		enemy_expansion = {enabled = false},
	}
}

-- Minimap and main map are disabled until unlocked by technology later in the game
data:extend({
	{
		type = "custom-input",
		name = "open-map",
		key_sequence = "",
		linked_game_control = "toggle-map",
		consuming = "game-only",
		action = "lua"
	}
})
