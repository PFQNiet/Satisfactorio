local name = "high-speed-connector"
local basename = "advanced-circuit"
local circuit = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = basename,
	order = "g["..name.."]",
	stack_size = 100,
	subgroup = "components",
	type = "item"
}

local ingredients = {
	{"quickwire",56},
	{"copper-cable",10},
	{"electronic-circuit",1}
}
local circuitrecipe1 = { -- by hand in Craft Bench
	name = basename.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = basename,
	energy_required = 8/4,
	category = "craft-bench",
	enabled = false
}
local circuitrecipe2 = { -- in Manufacturer
	name = basename,
	type = "recipe",
	ingredients = ingredients,
	result = basename,
	energy_required = 16,
	category = "manufacturing",
	hide_from_player_crafting = true,
	enabled = false
}

data.raw.item[basename] = circuit
data.raw.recipe[basename] = circuitrecipe2
data:extend({circuitrecipe1})
