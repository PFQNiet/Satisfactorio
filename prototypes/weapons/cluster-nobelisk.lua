local name = "cluster-nobelisk"
local capsule = {
	name = name,
	type = "capsule",
	subgroup = "ammo",
	order = "c[nobelisk]-d["..name.."]",
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
		{
			type = "direct",
			action_delivery = {
				type = "instant",
				target_effects = {
					{
						type = "create-entity",
						entity_name = "big-explosion"
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
						type = "destroy-decoratives",
						from_render_layer = "decorative",
						to_render_layer = "object",
						include_soft_decoratives = true, -- soft decoratives are decoratives with grows_through_rail_path = true
						include_decals = false,
						invoke_decorative_trigger = true,
						decoratives_with_trigger_only = false, -- if true, destroys only decoratives that have trigger_effect set
						radius = 3.5 -- large radius for demostrative purposes
					},
					{
						type = "nested-result",
						action = {
							type = "area",
							radius = 7,
							action_delivery = {
								type = "instant",
								target_effects = {
									{
										type = "damage",
										damage = {amount = 50, type = "explosion"},
										apply_damage_to_trees = false,
										lower_distance_threshold = 0,
										upper_distance_threshold = 7,
										lower_damage_modifier = 1,
										upper_damage_modifier = 0.5
									},
									{
										type = "create-entity",
										entity_name = "explosion"
									}
								}
							}
						}
					},
					{
						type = "nested-result",
						action = {
							type = "area",
							radius = 7,
							trigger_target_mask = {"nobelisk-explodable"},
							action_delivery = {
								type = "instant",
								target_effects = {
									{
										type = "script",
										effect_id = "nobelisk-explodable"
									}
								}
							}
						}
					},
					{
						type = "nested-result",
						action = {
							type = "area",
							radius = 7,
							trigger_target_mask = {"chainsawable"},
							action_delivery = {
								type = "instant",
								target_effects = {
									{
										type = "damage",
										damage = {
											amount = 100,
											type = "explosion"
										},
										vaporize = true
									}
								}
							}
						}
					},
					{
						type = "destroy-cliffs",
						radius = 7
					}
				}
			}
		},
		{
			type = "cluster",
			cluster_count = 5,
			distance = 8,
			distance_deviation = 3,
			action_delivery = {
				type = "projectile",
				projectile = name.."-cluster",
				direction_deviation = 6.28,
				starting_speed = 0.25,
				starting_speed_deviation = 0.3
			}
		}
	}
}

local cluster = {
	type = "projectile",
	name = name.."-cluster",
	flags = {"not-on-map"},
	collision_box = {{-0.25,-0.25},{0.25,0.25}},
	acceleration = 0,
	hit_at_collision_position = true,
	animation = projectile.animation,
	shadow = projectile.shadow,
	light = projectile.light,
	action = detonation.action[1]
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"nobelisk",3},
		{"smokeless-powder",4}
	},
	result = name,
	energy_required = 24,
	category = "assembling",
	enabled = false
}
copyToHandcraft(recipe, 5, true)

data:extend{capsule,projectile,sticker,onground,detonation,cluster,recipe}
