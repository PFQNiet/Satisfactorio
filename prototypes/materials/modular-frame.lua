local name = "modular-frame"
local frame = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "e["..name.."]",
	stack_size = 50,
	subgroup = "components",
	type = "item"
}

local ingredients = {
	{"reinforced-iron-plate",3},
	{"iron-stick",12}
}
local framerecipe1 = { -- by hand in Craft Bench
	name = name.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 15/4,
	category = "craft-bench",
	hide_from_player_crafting = true,
	enabled = false
}
local framerecipe2 = { -- in Assembler
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 60,
	category = "assembling",
	enabled = false
}

data:extend({frame,framerecipe1,framerecipe2})
