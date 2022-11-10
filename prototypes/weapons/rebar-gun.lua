-- tweak vanilla Pistol
local name = "rebar-gun"
local item = table.deepcopy(data.raw.gun.pistol)
item.name = name
item.flags = {}
item.attack_parameters.ammo_category = "rebar"
item.attack_parameters.cooldown = 3.5*60
item.attack_parameters.range = 50
item.icon = graphics.."icons/"..name..".png"
item.icon_mipmaps = 0
item.stack_size = 1

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"reinforced-iron-plate",6},
		{"iron-rod",16},
		{"screw",100}
	},
	result = name,
	energy_required = 25/4,
	category = "equipment",
	enabled = false
}
data:extend{item, recipe}

local ammoname = "iron-rebar"
local ammo = {
	type = "ammo",
	name = ammoname,
	icon = graphics.."icons/"..ammoname..".png",
	icon_size = 64,
	ammo_type = {
		category = "rebar",
		target_type = "direction",
		action = {
			{
				type = "direct",
				action_delivery = {
					{
						type = "projectile",
						projectile = ammoname,
						starting_speed = 1,
						direction_deviation = 0.05,
						range_deviation = 0.15,
						max_range = 50,
						source_effects = {
							{
								type = "create-explosion",
								entity_name = "explosion-gunshot"
							}
						}
					}
				}
			}
		}
	},
	magazine_size = 1,
	subgroup = "ammo",
	order = "a[basic-clips]-1["..ammoname.."]",
	stack_size = 100
}
local projectile = {
	type = "projectile",
	name = ammoname,
	flags = {"not-on-map"},
	collision_box = {{-0.5, -1}, {0.5, 1}},
	acceleration = -0.015,
	action = {
		type = "direct",
		action_delivery = {
			{
				type = "instant",
				target_effects = {
					{
						type = "create-entity",
						entity_name = "explosion-hit"
					},
					{
						type = "damage",
						damage = {amount=15,type="physical"}
					}
				}
			}
		}
	},
	animation = {
		filename = graphics.."particles/spiked-rebar.png",
		frame_count = 1,
		width = 5,
		height = 50,
		priority = "high"
	},
	shadow = {
		filename = graphics.."particles/spiked-rebar.png",
		frame_count = 1,
		width = 5,
		height = 50,
		priority = "high",
		draw_as_shadow = true
	},
	force_condition = "not-same",
	light = {
		intensity = 0.45,
		size = 5,
		color = {1,1,1}
	}
}
recipe = {
	name = ammoname,
	type = "recipe",
	ingredients = {
		{"iron-rod",1}
	},
	result = ammoname,
	energy_required = 4,
	category = "constructing",
	enabled = false
}
copyToHandcraft(recipe, 1, true)
data:extend{ammo, projectile, recipe}

ammoname = "stun-rebar"
ammo = {
	type = "ammo",
	name = ammoname,
	icon = graphics.."icons/"..ammoname..".png",
	icon_size = 64,
	ammo_type = {
		category = "rebar",
		target_type = "direction",
		action = {
			{
				type = "direct",
				action_delivery = {
					{
						type = "projectile",
						projectile = ammoname,
						starting_speed = 1,
						direction_deviation = 0.05,
						range_deviation = 0.15,
						max_range = 50,
						source_effects = {
							{
								type = "create-explosion",
								entity_name = "explosion-gunshot"
							}
						}
					}
				}
			}
		}
	},
	magazine_size = 1,
	subgroup = "ammo",
	order = "a[basic-clips]-2["..ammoname.."]",
	stack_size = 100
}
local stun = {
	duration_in_ticks = 5*60,
	flags = {"not-on-map"},
	name = name.."-stun-sticker",
	target_movement_modifier = 0,
	type = "sticker"
}
projectile = {
	type = "projectile",
	name = ammoname,
	flags = {"not-on-map"},
	collision_box = {{-0.5, -1}, {0.5, 1}},
	acceleration = -0.015,
	action = {
		type = "direct",
		action_delivery = {
			{
				type = "instant",
				target_effects = {
					{
						type = "create-entity",
						entity_name = "explosion-hit"
					},
					{
						type = "damage",
						damage = {amount=5,type="physical"}
					},
					{
						type = "create-sticker",
						sticker = name.."-stun-sticker"
					}
				}
			}
		}
	},
	animation = {
		filename = graphics.."particles/spiked-rebar.png",
		tint = {0.2,0.8,1},
		frame_count = 1,
		width = 5,
		height = 50,
		priority = "high"
	},
	shadow = {
		filename = graphics.."particles/spiked-rebar.png",
		frame_count = 1,
		width = 5,
		height = 50,
		priority = "high",
		draw_as_shadow = true
	},
	force_condition = "not-same",
	light = {
		intensity = 0.45,
		size = 5,
		color = {1,1,1}
	}
}
recipe = {
	name = ammoname,
	type = "recipe",
	ingredients = {
		{"iron-rebar",1},
		{"quickwire",5}
	},
	result = ammoname,
	energy_required = 6,
	category = "assembling",
	enabled = false
}
copyToHandcraft(recipe, 2, true)
data:extend{ammo, stun, projectile, recipe}

ammoname = "shatter-rebar"
ammo = {
	type = "ammo",
	name = ammoname,
	icon = graphics.."icons/"..ammoname..".png",
	icon_size = 64,
	ammo_type = {
		category = "rebar",
		target_type = "direction",
		action = {
			{
				type = "direct",
				action_delivery = {
					{
						type = "instant",
						source_effects = {
							{
								type = "create-explosion",
								entity_name = "explosion-gunshot"
							}
						}
					}
				}
			},
			{
				type = "direct",
				repeat_count = 12,
				action_delivery = {
					{
						type = "projectile",
						projectile = ammoname,
						starting_speed = 1,
						direction_deviation = 0.3,
						range_deviation = 0.15,
						max_range = 30
					}
				}
			}
		}
	},
	magazine_size = 1,
	subgroup = "ammo",
	order = "a[basic-clips]-3["..ammoname.."]",
	stack_size = 100
}
projectile = {
	type = "projectile",
	name = ammoname,
	flags = {"not-on-map"},
	collision_box = {{-0.5, -1}, {0.5, 1}},
	acceleration = -0.025,
	action = {
		type = "direct",
		action_delivery = {
			{
				type = "instant",
				target_effects = {
					{
						type = "create-entity",
						entity_name = "explosion-hit"
					},
					{
						type = "damage",
						damage = {amount=2,type="physical"}
					}
				}
			}
		}
	},
	animation = {
		filename = graphics.."particles/spiked-rebar.png",
		tint = {1,0.4,1},
		frame_count = 1,
		width = 5,
		height = 50,
		priority = "high"
	},
	shadow = {
		filename = graphics.."particles/spiked-rebar.png",
		frame_count = 1,
		width = 5,
		height = 50,
		priority = "high",
		draw_as_shadow = true
	},
	force_condition = "not-same",
	light = {
		intensity = 0.45,
		size = 5,
		color = {1,1,1}
	}
}
recipe = {
	name = ammoname,
	type = "recipe",
	ingredients = {
		{"iron-rebar",2},
		{"quartz-crystal",3}
	},
	result = ammoname,
	energy_required = 12,
	category = "assembling",
	enabled = false
}
copyToHandcraft(recipe, 3, true)
data:extend{ammo, projectile, recipe}

ammoname = "explosive-rebar"
ammo = {
	type = "ammo",
	name = ammoname,
	icon = graphics.."icons/"..ammoname..".png",
	icon_size = 64,
	ammo_type = {
		category = "rebar",
		target_type = "direction",
		action = {
			{
				type = "direct",
				action_delivery = {
					{
						type = "projectile",
						projectile = ammoname,
						starting_speed = 1,
						direction_deviation = 0.3,
						range_deviation = 0.15,
						max_range = 50,
						source_effects = {
							{
								type = "create-explosion",
								entity_name = "explosion-gunshot"
							}
						}
					}
				}
			}
		}
	},
	magazine_size = 1,
	subgroup = "ammo",
	order = "a[basic-clips]-4["..ammoname.."]",
	stack_size = 100
}
projectile = {
	type = "projectile",
	name = ammoname,
	flags = {"not-on-map"},
	collision_box = {{-0.5, -1}, {0.5, 1}},
	acceleration = -0.015,
	action = {
		type = "direct",
		action_delivery = {
			{
				type = "instant",
				target_effects = {
					{
						type = "create-entity",
						entity_name = "explosion"
					},
					{
						type = "nested-result",
						action = {
							type = "area",
							radius = 4,
							action_delivery = {
								type = "instant",
								target_effects = {
									{
										type = "damage",
										damage = {amount = 20, type = "explosion"},
										apply_damage_to_trees = false
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
							radius = 3,
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
						type = "create-entity",
						entity_name = "small-scorchmark-tintable",
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
						radius = 1.5 -- large radius for demostrative purposes
					}
				}
			}
		}
	},
	animation = {
		filename = graphics.."particles/spiked-rebar.png",
		tint = {1,0.6,0.2},
		frame_count = 1,
		width = 5,
		height = 50,
		priority = "high"
	},
	shadow = {
		filename = graphics.."particles/spiked-rebar.png",
		frame_count = 1,
		width = 5,
		height = 50,
		priority = "high",
		draw_as_shadow = true
	},
	force_condition = "not-same",
	light = {
		intensity = 0.45,
		size = 5,
		color = {1,1,1}
	}
}
recipe = {
	name = ammoname,
	type = "recipe",
	ingredients = {
		{"iron-rebar",2},
		{"smokeless-powder",2},
		{"steel-pipe",2}
	},
	result = ammoname,
	energy_required = 12,
	category = "manufacturing",
	enabled = false
}
copyToHandcraft(recipe, 4, true)
data:extend{ammo, projectile, recipe}
