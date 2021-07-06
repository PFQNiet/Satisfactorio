local name = "xeno-zapper"
local gun = {
	type = "gun",
	name = name,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	stack_size = 1,
	subgroup = "melee",
	order = "s-a["..name.."]",
	attack_parameters = {
		type = "projectile",
		range = 2,
		cooldown = 20,
		movement_slow_down_factor = 0.25,
		movement_slow_down_cooldown = 30,
		ammo_category = "infinite",
		sound = {
			filename = "__base__/sound/fight/pulse.ogg",
			volume = 0.7
		}
	}
}
local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"iron-rod",10},
		{"reinforced-iron-plate",2},
		{"copper-cable",15},
		{"wire",50}
	},
	result = name,
	energy_required = 10/4,
	category = "equipment",
	enabled = true
}

local stun = {
	duration_in_ticks = 30,
	flags = {"not-on-map"},
	name = name.."-stun-sticker",
	target_movement_modifier = 0,
	type = "sticker"
}

local ammo = {
	type = "ammo",
	name = name.."-ammo",
	icon = gun.icon,
	icon_size = gun.icon_size,
	flags = {"hidden"},
	magazine_size = 2,
	subgroup = "ammo",
	stack_size = 1,
	reload_time = 60,
	ammo_type = {
		category = "infinite",
		target_type = "entity",
		action = {
			type = "direct",
			action_delivery = {
				type = "instant",
				target_effects = {
					{
						type = "damage",
						damage = {
							amount = 5,
							type = "electric"
						}
					},
					{
						type = "create-sticker",
						sticker = name.."-stun-sticker"
					},
					{
						type = "push-back",
						distance = 3
					}
				}
			}
		}
	}
}

data:extend{gun,recipe,stun,ammo}
