local char = data.raw.character.character
char.inventory_size = 16
char.max_health = 100
char.crafting_categories = {"building","unbuilding"}
char.mining_categories = {"solid"}
char.mining_speed = 1

-- ensure character corpse doesn't expire
data.raw['character-corpse']['character-corpse'].time_to_live = 60*60*60*24*7
-- you have a *week* to retrieve your corpse. If that's not enough then I don't know what to say...

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
-- delete some unused controls
data.raw['custom-input']['toggle-equipment-movement-bonus'] = nil
data.raw['custom-input']['toggle-personal-logistic-requests'] = nil
data.raw['custom-input']['toggle-personal-roboport'] = nil
data.raw['shortcut']['toggle-equipment-movement-bonus'] = nil
data.raw['shortcut']['toggle-personal-roboport'] = nil
