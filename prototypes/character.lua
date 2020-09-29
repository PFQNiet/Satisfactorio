local char = data.raw.character.character
char.inventory_size = 16
char.max_health = 100
char.crafting_categories = {"building","unbuilding"}
char.mining_categories = {"solid"}
char.mining_speed = 1

-- trigger an event on "open gui" so that certain entities can respond to being clicked on
data:extend({
	{
		type = "custom-input",
		name = "interact",
		key_sequence = "",
		linked_game_control = "open-gui",
		consuming = "none",
		action = "lua"
	}
})
