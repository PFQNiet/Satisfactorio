-- tends to grow in grassy areas
local name = "paleberry"
local plant = {
	name = name,
	type = "simple-entity",
	collision_box = {{-0.2,-0.2},{0.2,0.2}},
	collision_mask = {"object-layer"},
	count_as_rock_for_filtered_deconstruction = true,
	flags = {
		"placeable-neutral",
		"not-on-map"
	},
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	picture = {
		filename = "__Satisfactorio__/graphics/placeholders/"..name..".png",
		size = {32,32}
	},
	max_health = 50,
	minable = {
		mining_time = 2,
		results = {{
			name = name,
			amount_min = 1,
			amount_max = 3
		}}
	},
	mining_sound = data.raw['utility-sounds'].default.mining_wood,
	mined_sound = data.raw.tree['tree-01'].mined_sound,
	render_layer = "object",
	selection_box = {{-0.5,-0.5},{0.5,0.5}},
	subgroup = "grass",
	trigger_target_mask = {"common", "chainsawable"}
}
local harvested = {
	name = name.."-harvested",
	type = "simple-entity",
	collision_box = {{-0.2,-0.2},{0.2,0.2}},
	count_as_rock_for_filtered_deconstruction = true,
	flags = {
		"placeable-neutral",
		"not-on-map"
	},
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	picture = {
		filename = "__Satisfactorio__/graphics/placeholders/"..name.."-harvested.png",
		size = {32,32}
	},
	max_health = 50,
	minable = {
		mining_time = 2
	},
	mining_sound = data.raw['utility-sounds'].default.mining_wood,
	mined_sound = data.raw.tree['tree-01'].mined_sound,
	render_layer = "object",
	selection_box = {{-0.5,-0.5},{0.5,0.5}},
	subgroup = "grass",
	trigger_target_mask = {"common", "chainsawable"}
}

local item = {
	name = name,
	type = "capsule",
	subgroup = "organic-resource",
	order = "p[plant]-b["..name.."]",
	stack_size = 50,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	capsule_action = { -- why tf is this so complicated?
		type = "use-on-self",
		attack_parameters = {
			type = "projectile",
			activation_type = "consume",
			range = 0,
			cooldown = 30,
			ammo_category = "capsule",
			ammo_type = {
				category = "capsule",
				target_type = "position",
				action = {
					type = "direct",
					action_delivery = {
						type = "instant",
						target_effects = {
							{
								type = "damage",
								damage = {
									type = "physical",
									amount = -10
								}
							},
							{
								type = "play-sound",
								sound = data.raw.capsule['raw-fish'].capsule_action.attack_parameters.ammo_type.action.action_delivery.target_effects[2].sound
							}
						}
					}
				}
			}
		}
	}
}

data:extend({plant,harvested,item})
