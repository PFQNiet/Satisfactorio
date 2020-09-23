local name = "quartz-crystal"
local crystal = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "i[quartz]-a["..name.."]",
	stack_size = 100,
	subgroup = "ingots",
	type = "item"
}

local ingredients = {
	{"raw-quartz",5}
}
local crystalrecipe1 = { -- by hand in Craft Bench
	name = name.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = name,
	result_count = 3,
	energy_required = 8/4,
	category = "craft-bench",
	hide_from_player_crafting = true,
	enabled = false
}
local crystalrecipe2 = { -- in Constructor
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	result_count = 3,
	energy_required = 8,
	category = "constructing",
	enabled = false
}

data:extend({crystal,crystalrecipe1,crystalrecipe2})
