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
