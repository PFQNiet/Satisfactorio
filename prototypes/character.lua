local char = data.raw.character.character
char.inventory_size = 18
char.max_health = 100
char.crafting_categories = {"building"}
char.mining_categories = {"solid"}
char.mining_speed = 1

-- character healing is handled by script and capped at 30 HP
char.healing_per_tick = 0
char.ticks_to_stay_in_combat = 50*60

-- character can't damage targets without a weapon, but can at least "punch" them away and stun them
local stun = {
	duration_in_ticks = 150,
	flags = {"not-on-map"},
	name = "unarmed-strike-stun-sticker",
	target_movement_modifier = 0,
	type = "sticker"
}
data:extend{stun}
char.tool_attack_distance = 3
char.tool_attack_result = {
	type = "direct",
	action_delivery = {
		type = "instant",
		target_effects = {
			{
				type = "create-sticker",
				sticker = stun.name
			},
			{
				type = "push-back",
				distance = 3
			}
		}
	}
}

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
	},
	--[[ wanted feature but can't do due to transport belt interaction
	{
		type = "custom-input",
		name = "fast-stack-transfer",
		key_sequence = "",
		linked_game_control = "fast-entity-transfer",
		consuming = "none",
		action = "lua"
	}
	]]
})
-- delete some unused controls
data.raw['custom-input']['toggle-equipment-movement-bonus'] = nil
data.raw['custom-input']['toggle-personal-logistic-requests'] = nil
data.raw['custom-input']['toggle-personal-roboport'] = nil
data.raw['shortcut']['toggle-equipment-movement-bonus'] = nil
data.raw['shortcut']['toggle-personal-roboport'] = nil

-- Sandbox mode
table.insert(data.raw['god-controller'].default.crafting_categories, "building")
table.insert(data.raw['god-controller'].default.mining_categories, "solid")
data.raw['god-controller'].default.mining_speed = 2
data.raw['god-controller'].default.inventory_size = 18
