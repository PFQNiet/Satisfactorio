local name = "motor"
local motor = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "c["..name.."]",
	stack_size = 50,
	subgroup = "components",
	type = "item"
}

local ingredients = {
	{"rotor",2},
	{"stator",2}
}
local motorrecipe1 = { -- by hand in Craft Bench
	name = name.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 12/4,
	category = "craft-bench",
	enabled = false
}
local motorrecipe2 = { -- in Assembler
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 12,
	category = "assembling",
	hide_from_player_crafting = true,
	enabled = false
}

data:extend({motor,motorrecipe1,motorrecipe2})
