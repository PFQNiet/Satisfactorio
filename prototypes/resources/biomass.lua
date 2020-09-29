local name = "biomass"
data:extend({
	{
		type = "item",
		name = name,
		icon = "__Satisfactorio__/graphics/icons/"..name..".png",
		icon_size = 64,
		subgroup = "organic-resource",
		order = "f["..name.."]",
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
	localised_name = {"recipe-name.x-from-y",{"item-name."..name}, {"item-name."..ingredients[1][1]}},
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
	hide_from_player_crafting = true,
	enabled = false
}
local recipe2 = { -- in Constructor
	name = name.."-from-"..ingredients[1][1],
	localised_name = {"recipe-name.x-from-y",{"item-name."..name}, {"item-name."..ingredients[1][1]}},
	type = "recipe",
	icons = recipe1.icons,
	ingredients = ingredients,
	result = name,
	result_count = 5,
	energy_required = 5,
	category = "constructing",
	enabled = false
}
data:extend({recipe1,recipe2})

ingredients = {
	{"wood",4}
}
recipe1 = { -- by hand in Craft Bench
	name = name.."-from-"..ingredients[1][1].."-manual",
	localised_name = {"recipe-name.x-from-y",{"item-name."..name}, {"item-name."..ingredients[1][1]}},
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
	hide_from_player_crafting = true,
	enabled = false
}
recipe2 = { -- in Constructor
	name = name.."-from-"..ingredients[1][1],
	localised_name = {"recipe-name.x-from-y",{"item-name."..name}, {"item-name."..ingredients[1][1]}},
	type = "recipe",
	icons = recipe1.icons,
	ingredients = ingredients,
	result = name,
	result_count = 20,
	energy_required = 4,
	category = "constructing",
	enabled = false
}
data:extend({recipe1,recipe2})

ingredients = {
	{"mycelia",10}
}
recipe1 = { -- by hand in Craft Bench
	name = name.."-from-"..ingredients[1][1].."-manual",
	localised_name = {"recipe-name.x-from-y",{"item-name."..name}, {"item-name."..ingredients[1][1]}},
	type = "recipe",
	icons = {
		{ icon = "__Satisfactorio__/graphics/icons/biomass.png", icon_size = 64 },
		{ icon = "__Satisfactorio__/graphics/icons/"..ingredients[1][1]..".png", icon_size = 64, scale = 0.25, shift = {-8, 8} }
	},
	ingredients = ingredients,
	result = name,
	result_count = 10,
	energy_required = 1/4,
	category = "craft-bench",
	hide_from_player_crafting = true,
	enabled = false
}
recipe2 = { -- in Constructor
	name = name.."-from-"..ingredients[1][1],
	localised_name = {"recipe-name.x-from-y",{"item-name."..name}, {"item-name."..ingredients[1][1]}},
	type = "recipe",
	icons = recipe1.icons,
	ingredients = ingredients,
	result = name,
	result_count = 10,
	energy_required = 4,
	category = "constructing",
	enabled = false
}
data:extend({recipe1,recipe2})

ingredients = {
	{"alien-carapace",1}
}
recipe1 = { -- by hand in Craft Bench
	name = name.."-from-"..ingredients[1][1].."-manual",
	localised_name = {"recipe-name.x-from-y",{"item-name."..name}, {"item-name."..ingredients[1][1]}},
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
	hide_from_player_crafting = true,
	enabled = false
}
recipe2 = { -- in Constructor
	name = name.."-from-"..ingredients[1][1],
	localised_name = {"recipe-name.x-from-y",{"item-name."..name}, {"item-name."..ingredients[1][1]}},
	type = "recipe",
	icons = recipe1.icons,
	ingredients = ingredients,
	result = name,
	result_count = 100,
	energy_required = 4,
	category = "constructing",
	enabled = false
}
data:extend({recipe1,recipe2})

ingredients = {
	{"alien-organs",1}
}
recipe1 = { -- by hand in Craft Bench
	name = name.."-from-"..ingredients[1][1].."-manual",
	localised_name = {"recipe-name.x-from-y",{"item-name."..name}, {"item-name."..ingredients[1][1]}},
	type = "recipe",
	icons = {
		{ icon = "__Satisfactorio__/graphics/icons/biomass.png", icon_size = 64 },
		{ icon = "__Satisfactorio__/graphics/icons/"..ingredients[1][1]..".png", icon_size = 64, scale = 0.25, shift = {-8, 8} }
	},
	ingredients = ingredients,
	result = name,
	result_count = 200,
	energy_required = 4/4,
	category = "craft-bench",
	hide_from_player_crafting = true,
	enabled = false
}
recipe2 = { -- in Constructor
	name = name.."-from-"..ingredients[1][1],
	localised_name = {"recipe-name.x-from-y",{"item-name."..name}, {"item-name."..ingredients[1][1]}},
	type = "recipe",
	icons = recipe1.icons,
	ingredients = ingredients,
	result = name,
	result_count = 200,
	energy_required = 8,
	category = "constructing",
	enabled = false
}
data:extend({recipe1,recipe2})
