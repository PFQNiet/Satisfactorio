local name = "pulse-nobelisk"
local capsule = {
	name = name,
	type = "capsule",
	subgroup = "ammo",
	order = "c[nobelisk]-c["..name.."]",
	stack_size = 50,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	capsule_action = {
		type = "throw",
		attack_parameters = {
			type = "projectile",
			activation_type = "throw",
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
					effect_id = name
				}
			}
		}
	},
	animation = {
		filename = graphics.."particles/"..name..".png",
		frame_count = 1,
		width = 32,
		height = 32,
		priority = "high"
	},
	shadow = {
		filename = graphics.."particles/"..name..".png",
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
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	flags = {"not-on-map"},
	single_particle = true,
	duration_in_ticks = 24*3600*60, -- idk man, why you not detonating Nobelisks within 24 hours?
	animation = {
		filename = graphics.."particles/"..name.."-sticker.png",
		size = 16
	}
}
local onground = {
	type = "simple-entity",
	name = name.."-on-ground",
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	flags = {"not-on-map","hidden","placeable-off-grid"},
	picture = {
		filename = graphics.."particles/"..name.."-sticker.png",
		size = 16
	},
	collision_box = {{-0.125,-0.125},{0.125,0.125}},
	collision_mask = {},
	selection_box = {{-0.125,-0.125},{0.125,0.125}},
	selectable_in_game = false
}

local detonation = {
	type = "projectile",
	name = name.."-detonation",
	flags = {"not-on-map"},
	collision_box = {{-0.125,-0.125},{0.125,0.125}},
	acceleration = 0,
	animation = empty_graphic,
	action = {
		type = "direct",
		action_delivery = {
			type = "instant",
			target_effects = {
				{
					type = "play-sound",
					sound = {
						filename = "__base__/sound/fight/pulse.ogg",
						volume = 0.7
					}
				},
				{
					type = "create-entity",
					entity_name = "medium-scorchmark-tintable",
					check_buildability = true
				},
				{
					type = "invoke-tile-trigger",
					repeat_count = 1
				},
				{
					type = "nested-result",
					action = {
						type = "area",
						radius = 7,
						action_delivery = {
							{
								type = "instant",
								target_effects = {
									{
										type = "create-sticker",
										sticker = name.."-stun-sticker"
									},
									{
										type = "push-back",
										distance = 4
									}
								}
							},
							{
								type = "beam",
								beam = "electric-beam-no-sound",
								max_length = 16,
								duration = 15,
								add_to_shooter = false
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
		{"nobelisk",5},
		{"crystal-oscillator",1}
	},
	result = name,
	result_count = 5,
	energy_required = 60,
	category = "assembling",
	enabled = false
}
copyToHandcraft(recipe, 25, true)

local stun = {
	duration_in_ticks = 5*60,
	flags = {"not-on-map"},
	name = name.."-stun-sticker",
	target_movement_modifier = 0,
	type = "sticker"
}

data:extend{capsule,projectile,sticker,onground,detonation,recipe,stun}
