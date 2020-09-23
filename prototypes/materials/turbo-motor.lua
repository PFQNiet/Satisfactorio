local name = "turbo-motor"
local motor = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "d["..name.."]",
	stack_size = 50,
	subgroup = "components",
	type = "item"
}

local ingredients = {
	{"heat-sink",4},
	{"radio-control-unit",2},
	{"motor",4},
	{"rubber",24}
}
local motorrecipe1 = { -- by hand in Craft Bench
	name = name.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 32/4,
	category = "craft-bench",
	hide_from_player_crafting = true,
	enabled = false
}
local motorrecipe2 = { -- in Manufacturer
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 32,
	category = "manufacturing",
	enabled = false
}

data:extend({motor,motorrecipe1,motorrecipe2})
