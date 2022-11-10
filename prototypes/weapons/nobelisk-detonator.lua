local name = "nobelisk-detonator"
local detonator = {
	name = name,
	type = "capsule",
	subgroup = "gun",
	order = "c[nobelisk]",
	stack_size = 1,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	capsule_action = {
		type = "throw",
		uses_stack = false,
		attack_parameters = {
			type = "projectile",
			activation_type = "activate",
			range = 0,
			cooldown = 60,
			ammo_category = "capsule",
			ammo_type = {
				category = "capsule",
				target_type = "direction",
				action = {
					type = "direct",
					action_delivery = {
						type = "instant",
						target_effects = {
							{
								type = "script",
								effect_id = "nobelisk-detonator"
							}
						}
					}
				}
			}
		}
	}
}
local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"object-scanner",1},
		{"steel-beam",10},
		{"copper-cable",50}
	},
	result = name,
	energy_required = 20/4,
	category = "equipment",
	enabled = false
}

data:extend{
	detonator,
	recipe,
	{
		type = "sound",
		name = "nobelisk-detonator",
		filename = "__base__/sound/construction-robot-8.ogg",
		volume = 0.7
	},
	{
		type = "trigger-target-type",
		name = "nobelisk-explodable"
	},
	{
		type = "trigger-target-type",
		name = "nobelisk-nukable"
	}
}
