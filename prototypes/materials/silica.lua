local name = "silica"
local ingot = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "i[quartz]-b["..name.."]",
	stack_size = 500,
	subgroup = "intermediate-product",
	type = "item"
}

local ingredients = {
	{"raw-quartz",3}
}
local ingotrecipe1 = {
	name = name.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = name,
	result_count = 5,
	energy_required = 8/4,
	category = "craft-bench",
	enabled = false
}
local ingotrecipe2 = { -- in Constructor
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	result_count = 5,
	energy_required = 8,
	category = "constructing",
	hide_from_player_crafting = true,
	enabled = false
}

data:extend({ingot,ingotrecipe1,ingotrecipe2})
