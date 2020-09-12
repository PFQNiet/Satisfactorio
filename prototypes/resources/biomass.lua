local name = "biomass"
data:extend({
	{
		type = "item",
		name = name,
		icon = "__Satisfactorio__/graphics/icons/"..name..".png",
		icon_size = 64,
		subgroup = "organic-resource",
		order = "t["..name.."]",
		stack_size = 200,
		fuel_category = "chemical",
		fuel_value = "180MJ"
	}
})

local ingredients = {
	{"leaves",10}
}
local recipe1 = { -- by hand in Craft Bench
	name = name.."-from-"..ingredients[1][1].."-manual",
	localised_name = {"recipe-name."..name.."-from-"..ingredients[1][1]},
	type = "recipe",
	icons = {
		{ icon = "__Satisfactorio__/graphics/icons/biomass.png", icon_size = 64 },
		{ icon = "__Satisfactorio__/graphics/icons/"..ingredients[1][1]..".png", icon_size = 64, scale = 0.25, shift = {-8, 8} }
	},
	ingredients = ingredients,
	result = name,
	result_count = 5,
	energy_required = 1/4,
	category = "craft-bench",
	enabled = false
}
local recipe2 = { -- in Constructor
	name = name.."-from-"..ingredients[1][1],
	localised_name = {"recipe-name."..name.."-from-"..ingredients[1][1]},
	type = "recipe",
	icons = recipe1.icons,
	ingredients = ingredients,
	result = name,
	result_count = 5,
	energy_required = 5,
	category = "constructing",
	hide_from_player_crafting = true,
	enabled = false
}
data:extend({recipe1,recipe2})

ingredients = {
	{"wood",4}
}
recipe1 = { -- by hand in Craft Bench
	name = name.."-from-"..ingredients[1][1].."-manual",
	localised_name = {"recipe-name."..name.."-from-"..ingredients[1][1]},
	type = "recipe",
	icons = {
		{ icon = "__Satisfactorio__/graphics/icons/biomass.png", icon_size = 64 },
		{ icon = "__Satisfactorio__/graphics/icons/"..ingredients[1][1]..".png", icon_size = 64, scale = 0.25, shift = {-8, 8} }
	},
	ingredients = ingredients,
	result = name,
	result_count = 20,
	energy_required = 2/4,
	category = "craft-bench",
	enabled = false
}
recipe2 = { -- in Constructor
	name = name.."-from-"..ingredients[1][1],
	localised_name = {"recipe-name."..name.."-from-"..ingredients[1][1]},
	type = "recipe",
	icons = recipe1.icons,
	ingredients = ingredients,
	result = name,
	result_count = 20,
	energy_required = 4,
	category = "constructing",
	hide_from_player_crafting = true,
	enabled = false
}
data:extend({recipe1,recipe2})

ingredients = {
	{"alien-carapace",1}
}
recipe1 = { -- by hand in Craft Bench
	name = name.."-from-alien-carapace-manual",
	localised_name = {"recipe-name."..name.."-from-alien-carapace"},
	type = "recipe",
	icons = {
		{ icon = "__Satisfactorio__/graphics/icons/biomass.png", icon_size = 64 },
		{ icon = "__Satisfactorio__/graphics/icons/"..ingredients[1][1]..".png", icon_size = 64, scale = 0.25, shift = {-8, 8} }
	},
	ingredients = ingredients,
	result = name,
	result_count = 100,
	energy_required = 2/4,
	category = "craft-bench",
	enabled = false
}
recipe2 = { -- in Constructor
	name = name.."-from-"..ingredients[1][1],
	localised_name = {"recipe-name."..name.."-from-"..ingredients[1][1]},
	type = "recipe",
	icons = recipe1.icons,
	ingredients = ingredients,
	result = name,
	result_count = 100,
	energy_required = 4,
	category = "constructing",
	hide_from_player_crafting = true,
	enabled = false
}
data:extend({recipe1,recipe2})
