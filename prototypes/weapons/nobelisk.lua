local name = "nobelisk"
local capsule = {
	name = name,
	type = "capsule",
	subgroup = "ammo",
	order = "b[nobelisk]",
	stack_size = 50,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	capsule_action = {
		type = "throw",
		attack_parameters = {
			type = "projectile",
			range = 30,
			cooldown = 60,
			ammo_category = "capsule",
			ammo_type = {
				category = "capsule",
				target_type = "position",
				action = {{
					type = "direct",
					action_delivery = {
						type = "projectile",
						starting_speed = 0.3,
						projectile = name
					}
				}}
			}
		}
	}
}
local projectile = {
	type = "projectile",
	name = name,
	flags = {"not-on-map"},
	collision_box = {{-0.5, -0.5}, {0.5, 0.5}},
	acceleration = 0,
	hit_at_collision_position = true,
	action = {
		type = "direct",
		action_delivery = {
			type = "instant",
			target_effects = {
				{
					type = "damage",
					damage = {
						type = "physical",
						amount = 1
					}
				}
			}
		}
	},
	final_action = {
		type = "direct",
		action_delivery = {
			type = "instant",
			target_effects = {
				{
					type = "script",
					effect_id = "nobelisk"
				}
			}
		}
	},
	animation = {
		filename = "__Satisfactorio__/graphics/particles/"..name..".png",
		frame_count = 1,
		width = 32,
		height = 32,
		priority = "high"
	},
	shadow = {
		filename = "__Satisfactorio__/graphics/particles/"..name..".png",
		frame_count = 1,
		width = 32,
		height = 32,
		priority = "high",
		draw_as_shadow = true
	},
	force_condition = "not-same",
	light = {
		intensity = 0.45,
		size = 5,
		color = {1,0.5,0.5}
	}
}

local sticker = {
	type = "sticker",
	name = name.."-armed",
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	flags = {"not-on-map"},
	single_particle = true,
	duration_in_ticks = 24*3600*60, -- idk man, why you not detonating Nobelisks within 24 hours?
	animation = {
		filename = "__Satisfactorio__/graphics/particles/"..name.."-sticker.png",
		size = 16
	}
}
local onground = {
	type = "simple-entity",
	name = name.."-on-ground",
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	flags = {"not-on-map","hidden","placeable-off-grid"},
	picture = {
		filename = "__Satisfactorio__/graphics/particles/"..name.."-sticker.png",
		size = 16
	},
	collision_box = {{-0.125,-0.125},{0.125,0.125}},
	collision_mask = {},
	selection_box = {{-0.125,-0.125},{0.125,0.125}},
	selectable_in_game = false
}

local recipe1 = {
	name = name,
	type = "recipe",
	ingredients = {
		{"black-powder",5},
		{"steel-pipe",10}
	},
	result = name,
	energy_required = 20,
	category = "assembling",
	enabled = false
}
local recipe2 = {
	name = name.."-manual",
	type = "recipe",
	ingredients = {
		{"black-powder",5},
		{"steel-pipe",10}
	},
	result = name,
	energy_required = 5/4,
	category = "equipment",
	hide_from_player_crafting = true,
	enabled = false
}

data:extend{capsule,projectile,sticker,onground,recipe1,recipe2}

name = "nobelisk-detonator"
detonator = {
	name = name,
	type = "capsule",
	subgroup = "gun",
	order = "b[nobelisk]",
	stack_size = 1,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	capsule_action = {
		type = "throw",
		uses_stack = false,
		attack_parameters = {
			type = "projectile",
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
		{"object-scanner",5},
		{"encased-industrial-beam",5},
		{"copper-cable",50}
	},
	result = name,
	energy_required = 20/4,
	category = "equipment",
	enabled = false
}

data:extend{detonator,recipe}
data:extend{
	{
		type = "sound",
		name = "nobelisk-detonator",
		filename = "__base__/sound/construction-robot-8.ogg",
		volume = 0.7
	}
}
