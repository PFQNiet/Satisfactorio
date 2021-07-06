-- tweak vanilla Pistol
local name = "rebar-gun"
local item = table.deepcopy(data.raw.gun.pistol)
item.name = name
item.flags = {}
item.attack_parameters.ammo_category = "rebar"
item.attack_parameters.cooldown = 3.5*60
item.attack_parameters.range = 50
item.icon = "__Satisfactorio__/graphics/icons/"..name..".png"
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

local ammoname = "spiked-rebar"
local ammo = {
	type = "ammo",
	name = ammoname,
	icon = "__Satisfactorio__/graphics/icons/"..ammoname..".png",
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
	stack_size = 50
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
		filename = "__Satisfactorio__/graphics/particles/"..ammoname..".png",
		frame_count = 1,
		width = 5,
		height = 50,
		priority = "high"
	},
	shadow = {
		filename = "__Satisfactorio__/graphics/particles/"..ammoname..".png",
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
