local name = "rotor"
local rotor = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "a["..name.."]",
	stack_size = 100,
	subgroup = "components",
	type = "item"
}

local ingredients = {
	{"iron-stick",5},
	{"screw",25}
}
local rotorrecipe1 = { -- by hand in Craft Bench
	name = name.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 6/4,
	category = "craft-bench",
	hide_from_player_crafting = true,
	enabled = false
}
local rotorrecipe2 = { -- in Assembler
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 15,
	category = "assembling",
	enabled = false
}

data:extend({rotor,rotorrecipe1,rotorrecipe2})
