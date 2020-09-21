local name = "battery"
local item = {
	type = "item",
	name = name,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	subgroup = "components",
	order = "v["..name.."]",
	stack_size = 100,
	fuel_category = "packaged-fuel",
	fuel_value = "6GJ"
}

local ingredients = {
	{"alclad-aluminium-sheet",8},
	{"wire",16},
	{"sulphur",20},
	{"plastic-bar",8}
}
local recipe1 = { -- by hand in Craft Bench
	name = name.."-manual",
	type = "recipe",
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	ingredients = ingredients,
	result = name,
	result_count = 3,
	energy_required = 16/4,
	category = "craft-bench",
	enabled = false
}
local recipe2 = { -- in Manufacturer
	name = name,
	type = "recipe",
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	ingredients = ingredients,
	result = name,
	result_count = 3,
	energy_required = 32,
	category = "manufacturing",
	hide_from_player_crafting = true,
	enabled = false
}
data:extend({item,recipe1,recipe2})
