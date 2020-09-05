local name = "biomass"
data:extend({
	{
		type = "item",
		name = name,
		icon = "__Satisfactorio__/graphics/icons/"..name..".png",
		icon_size = 64,
		subgroup = "raw-resource",
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
	name = name.."-from-leaves-manual",
	localised_name = {"recipe-name."..name.."-from-leaves"},
	type = "recipe",
	icons = {
		{ icon = "__Satisfactorio__/graphics/icons/biomass.png", icon_size = 64 },
		{ icon = "__Satisfactorio__/graphics/icons/leaves.png", icon_size = 64, scale = 0.25, shift = {-8, 8} }
	},
	ingredients = ingredients,
	result = name,
	result_count = 5,
	energy_required = 1/4,
	category = "craft-bench",
	enabled = false
}
local recipe2 = { -- in Constructor
	name = name.."-from-leaves",
	localised_name = {"recipe-name."..name.."-from-leaves"},
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
	name = name.."-from-wood-manual",
	localised_name = {"recipe-name."..name.."-from-wood"},
	type = "recipe",
	icons = {
		{ icon = "__Satisfactorio__/graphics/icons/biomass.png", icon_size = 64 },
		{ icon = "__Satisfactorio__/graphics/icons/wood.png", icon_size = 64, scale = 0.25, shift = {-8, 8} }
	},
	ingredients = ingredients,
	result = name,
	result_count = 20,
	energy_required = 2/4,
	category = "craft-bench",
	enabled = false
}
recipe2 = { -- in Constructor
	name = name.."-from-wood",
	localised_name = {"recipe-name."..name.."-from-wood"},
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
