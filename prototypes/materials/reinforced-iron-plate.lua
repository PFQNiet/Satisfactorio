local name = "reinforced-iron-plate"
local plate = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "c["..name.."]",
	stack_size = 100,
	subgroup = "intermediate-product",
	type = "item"
}

local ingredients = {
	{"iron-plate",6},
	{"screw",12}
}
local platerecipe1 = { -- by hand in Craft Bench
	name = name.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 6/4,
	category = "craft-bench",
	enabled = false
}
local platerecipe2 = { -- in Assembler
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 12,
	category = "assembling",
	hide_from_player_crafting = true,
	enabled = false
}

data:extend({plate,platerecipe1,platerecipe2})