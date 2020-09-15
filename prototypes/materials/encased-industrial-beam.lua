local name = "encased-industrial-beam"
local beam = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "d[steel]-c["..name.."]",
	stack_size = 100,
	subgroup = "intermediate-product",
	type = "item"
}

local ingredients = {
	{"steel-plate",4},
	{"concrete",5}
}
local beamrecipe1 = { -- by hand in Craft Bench
	name = name.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 5/4,
	category = "craft-bench",
	enabled = false
}
local beamrecipe2 = { -- in Assembler
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 10,
	category = "assembling",
	hide_from_player_crafting = true,
	enabled = false
}

data:extend({beam,beamrecipe1,beamrecipe2})
