-- modifiy submachine-gun
local name = "rifle"
local item = table.deepcopy(data.raw.gun["submachine-gun"])
item.name = name
item.flags = {}
item.attack_parameters.ammo_category = "rifle"
item.attack_parameters.cooldown = 12 -- 5 per second
item.attack_parameters.range = 50
item.icon = graphics.."icons/"..name..".png"
item.icon_mipmaps = 0
item.stack_size = 1

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"steel-pipe",25},
		{"heavy-modular-frame",3},
		{"circuit-board",20},
		{"screw",250}
	},
	result = name,
	energy_required = 30/4,
	category = "equipment",
	enabled = false
}
data:extend{item, recipe}

local ammoname = "rifle-ammo"
item = {
	type = "ammo",
	name = ammoname,
	icon = graphics.."icons/"..ammoname..".png",
	icon_size = 64,
	subgroup = "ammo",
	order = "b[rifle-ammo]-1["..ammoname.."]",
	stack_size = 50,
	ammo_type = {
		category = "rifle",
		target_type = "direction",
		action = {
			type = "direct",
			action_delivery = {
				type = "projectile",
				projectile = ammoname,
				starting_speed = 1,
				direction_deviation = 0.1,
				max_range = 50,
				source_effects = {
					{
						type = "create-explosion",
						entity_name = "explosion-gunshot"
					}
				}
			}
		}
	},
	reload_time = 180,
	magazine_size = 15
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
						damage = {amount=5,type="physical"}
					}
				}
			}
		}
	},
	animation = {
		filename = graphics.."particles/rifle-bullet.png",
		frame_count = 1,
		width = 3,
		height = 50,
		priority = "high"
	},
	shadow = {
		filename = graphics.."particles/rifle-bullet.png",
		frame_count = 1,
		width = 3,
		height = 50,
		priority = "high",
		draw_as_shadow = true
	},
	force_condition = "not-same",
	light = {
		intensity = 0.45,
		size = 5,
		color = {1,1,0.5}
	}
}
recipe = {
	name = ammoname,
	type = "recipe",
	ingredients = {
		{"smokeless-powder",2},
		{"copper-sheet",3}
	},
	result = ammoname,
	energy_required = 12,
	category = "assembling",
	enabled = false
}
copyToHandcraft(recipe, 5, true)
data:extend{item, projectile, recipe}

ammoname = "homing-rifle-ammo"
item = {
	type = "ammo",
	name = ammoname,
	icon = graphics.."icons/"..ammoname..".png",
	icon_size = 64,
	stack_size = 50,
	subgroup = "ammo",
	order = "b[rifle-ammo]-2["..ammoname.."]",
	ammo_type = {
		category = "rifle",
		target_type = "entity",
		action = {
			type = "direct",
			action_delivery = {
				type = "projectile",
				projectile = ammoname,
				starting_speed = 1,
				direction_deviation = 0,
				max_range = 50,
				source_effects = {
					{
						type = "create-explosion",
						entity_name = "explosion-gunshot"
					}
				}
			}
		}
	},
	reload_time = 180,
	magazine_size = 10
}
projectile = {
	type = "projectile",
	name = ammoname,
	flags = {"not-on-map"},
	collision_box = {{-0.5, -1}, {0.5, 1}},
	acceleration = 0.005,
	turn_speed = 0.03,
	turning_speed_increases_exponentially_with_projectile_speed = true,
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
						damage = {amount=4,type="physical"}
					}
				}
			}
		}
	},
	animation = {
		filename = graphics.."particles/rifle-bullet.png",
		frame_count = 1,
		width = 3,
		height = 50,
		priority = "high"
	},
	shadow = {
		filename = graphics.."particles/rifle-bullet.png",
		frame_count = 1,
		width = 3,
		height = 50,
		priority = "high",
		draw_as_shadow = true
	},
	force_condition = "not-same",
	light = {
		intensity = 0.45,
		size = 5,
		color = {1,1,0.5}
	}
}
recipe = {
	name = ammoname,
	type = "recipe",
	ingredients = {
		{"rifle-ammo",1},
		{"high-speed-connector",3}
	},
	result = ammoname,
	energy_required = 24,
	category = "assembling",
	enabled = false
}
copyToHandcraft(recipe, 5, true)
data:extend{item, projectile, recipe}

ammoname = "turbo-rifle-ammo"
item = {
	type = "ammo",
	name = ammoname,
	icon = graphics.."icons/"..ammoname..".png",
	icon_size = 64,
	stack_size = 50,
	subgroup = "ammo",
	order = "b[rifle-ammo]-3["..ammoname.."]",
	ammo_type = {
		category = "rifle",
		target_type = "direction",
		cooldown_modifier = 0.4,
		action = {
			type = "direct",
			action_delivery = {
				type = "projectile",
				projectile = ammoname,
				starting_speed = 1.5,
				direction_deviation = 0.3,
				max_range = 50,
				source_effects = {
					{
						type = "create-explosion",
						entity_name = "explosion-gunshot"
					}
				}
			}
		}
	},
	reload_time = 180,
	magazine_size = 50
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
						damage = {amount=3,type="physical"}
					}
				}
			}
		}
	},
	animation = {
		filename = graphics.."particles/rifle-bullet.png",
		frame_count = 1,
		width = 3,
		height = 50,
		priority = "high"
	},
	shadow = {
		filename = graphics.."particles/rifle-bullet.png",
		frame_count = 1,
		width = 3,
		height = 50,
		priority = "high",
		draw_as_shadow = true
	},
	force_condition = "not-same",
	light = {
		intensity = 0.45,
		size = 5,
		color = {1,1,0.5}
	}
}
recipe = {
	name = ammoname,
	type = "recipe",
	ingredients = {
		{"rifle-ammo",1},
		{"aluminium-casing",3},
		{"packaged-turbofuel",3}
	},
	result = ammoname,
	energy_required = 12,
	category = "manufacturing",
	enabled = false
}
copyToHandcraft(recipe, 5, true)
data:extend{item, projectile, recipe}

recipe = {
	name = ammoname.."-2",
	type = "recipe",
	ingredients = {
		{"rifle-ammo",1},
		{"aluminium-casing",3},
		{type="fluid",name="turbofuel",amount=3}
	},
	result = ammoname,
	energy_required = 12,
	category = "blending",
	enabled = false
}
data:extend{recipe}
