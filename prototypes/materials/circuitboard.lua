local name = "circuitboard"
local basename = "electronic-circuit"
local circuit = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = basename,
	order = "g["..name.."]",
	stack_size = 200,
	subgroup = "components",
	type = "item"
}

local ingredients = {
	{"copper-plate",2},
	{"plastic-bar",4}
}
local circuitrecipe1 = { -- by hand in Craft Bench
	name = basename.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = basename,
	energy_required = 6/4,
	category = "craft-bench",
	hide_from_player_crafting = true,
	enabled = false
}
local circuitrecipe2 = { -- in Assembler
	name = basename,
	type = "recipe",
	ingredients = ingredients,
	result = basename,
	energy_required = 8,
	category = "assembling",
	enabled = false
}

data.raw.item[basename] = circuit
data.raw.recipe[basename] = circuitrecipe2
data:extend({circuitrecipe1})
