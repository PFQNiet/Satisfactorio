local name = "computer"
local computer = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "c[computer]-d["..name.."]",
	stack_size = 50,
	subgroup = "components",
	type = "item"
}

local ingredients = {
	{"electronic-circuit",10},
	{"copper-cable",9},
	{"plastic-bar",18},
	{"screw",52}
}
local computerrecipe1 = { -- by hand in Craft Bench
	name = name.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 18/4,
	category = "craft-bench",
	hide_from_player_crafting = true,
	enabled = false
}
local computerrecipe2 = { -- in Manufacturer
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 24,
	category = "manufacturing",
	enabled = false
}

data:extend({computer,computerrecipe1,computerrecipe2})
