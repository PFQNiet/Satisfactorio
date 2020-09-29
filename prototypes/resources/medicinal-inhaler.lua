local name = "medicinal-inhaler"
local item = {
	name = name,
	type = "capsule",
	subgroup = "organic-resource",
	order = "p[plant]-d["..name.."]",
	stack_size = 50,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	capsule_action = { -- why tf is this so complicated?
		type = "use-on-self",
		attack_parameters = {
			type = "projectile",
			range = 0,
			cooldown = 300,
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
									amount = -100
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

local recipe1 = {
	name = name,
	type = "recipe",
	ingredients = {
		{"bacon-agaric",1},
		{"paleberry",2},
		{"beryl-nut",3},
		{"mycelia",5}
	},
	result = name,
	energy_required = 5/4,
	category = "equipment",
	enabled = false
}
local recipe2 = {
	name = name.."-from-alien-organs",
	localised_name = {"recipe-name.x-from-y",name,{"item-name.alien-organs"}},
	type = "recipe",
	ingredients = {
		{"alien-organs",3},
		{"mycelia",5}
	},
	result = name,
	energy_required = 5/4,
	category = "equipment",
	enabled = false
}
local recipe3 = {
	name = "nutritional-inhaler",
	type = "recipe",
	ingredients = {
		{"bacon-agaric",1},
		{"paleberry",3},
		{"beryl-nut",7}
	},
	result = name,
	energy_required = 5/4,
	category = "equipment",
	enabled = false
}

data:extend({item,recipe1,recipe2,recipe3})
