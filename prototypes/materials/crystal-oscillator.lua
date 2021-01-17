local name = "crystal-oscillator"
local oscillator = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "i[quartz]-a["..name.."]",
	stack_size = 100,
	subgroup = "components",
	type = "item"
}

local ingredients = {
	{"quartz-crystal",36},
	{"copper-cable",28},
	{"reinforced-iron-plate",5}
}
local oscillatorrecipe1 = { -- by hand in Craft Bench
	name = name.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = name,
	result_count = 2,
	energy_required = 18/4,
	category = "craft-bench",
	hide_from_player_crafting = true,
	enabled = false
}
local oscillatorrecipe2 = { -- in Manufacturer
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	result_count = 2,
	energy_required = 120,
	category = "manufacturing",
	enabled = false
}

data:extend({oscillator,oscillatorrecipe1,oscillatorrecipe2})
