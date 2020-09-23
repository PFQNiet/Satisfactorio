local name = "solid-biofuel"
data:extend({
	{ -- Solid Biofuel is used as "ammo" for the Chainsaw. 1 Solid Biofuel lasts for 6 seconds of continuous fire.
		type = "ammo",
		name = name,
		icon = "__Satisfactorio__/graphics/icons/"..name..".png",
		icon_size = 64,
		subgroup = "organic-resource",
		order = "h["..name.."]",
		stack_size = 200,
		fuel_category = "chemical",
		fuel_value = "450MJ",
		magazine_size = 6*60, -- one "ammo" per tick of use
		ammo_type = {
			category = "solid-biofuel",
			target_type = "entity",
			action = {
				type = "direct",
				trigger_target_mask = {"chainsawable"},
				filter_enabled = true,
				action_delivery = {
					type = "instant",
					target_effects = {
						{
							type = "damage",
							damage = {
								amount = 0.5,
								type = "chainsaw"
							}
						}
					}
				}
			}
		}
	},
	{
		type = "damage-type",
		name = "chainsaw"
	},
	{
		type = "trigger-target-type",
		name = "chainsawable"
	}
})

local ingredients = {
	{"biomass",8}
}
local recipe1 = { -- by hand in Craft Bench
	name = name.."-manual",
	type = "recipe",
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	ingredients = ingredients,
	result = name,
	result_count = 4,
	energy_required = 10/4,
	category = "craft-bench",
	hide_from_player_crafting = true,
	enabled = false
}
local recipe2 = { -- in Constructor
	name = name,
	type = "recipe",
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	ingredients = ingredients,
	result = name,
	result_count = 4,
	energy_required = 4,
	category = "constructing",
	enabled = false
}
data:extend({recipe1,recipe2})
