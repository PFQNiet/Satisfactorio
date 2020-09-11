-- remove starting lake
data.raw['noise-expression']['0_17-lakes-elevation'].expression = data.raw['noise-expression']['0_17-lakes-elevation'].expression.arguments[1]
-- remove enemy base autoplacement (they will be spawned manually around places of interest)
data.raw['unit-spawner']['biter-spawner'].autoplace = nil
data.raw['unit-spawner']['spitter-spawner'].autoplace = nil
data.raw['turret']['small-worm-turret'].autoplace = nil
data.raw['turret']['medium-worm-turret'].autoplace = nil
data.raw['turret']['big-worm-turret'].autoplace = nil
data.raw['turret']['behemoth-worm-turret'].autoplace = nil
-- disable pollution and enemy settings by default
local settings = data.raw['map-settings']['map-settings']
settings.pollution.enabled = false
settings.enemy_evolution.enabled = false
settings.enemy_expansion.enabled = false

-- Minimap and main map are disabled until unlocked by technology later in the game
data:extend({
	{
		type = "custom-input",
		name = "open-map",
		key_sequence = "",
		linked_game_control = "toggle-map",
		consuming = "game-only",
		action = "lua"
	},
	{
		type = "custom-input",
		name = "place-marker",
		key_sequence = "",
		linked_game_control = "place-tag",
		consuming = "none", -- doesn't block the tag GUI and triggers out of the map view anyway
		action = "lua"
	}
})
