local name = "aluminium-ingot"
local ingot = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "h[aluminium]-b["..name.."]",
	stack_size = 100,
	subgroup = "intermediate-product",
	type = "item"
}

local ingredients = {
	{"aluminium-scrap",12},
	{"silica",7}
}
local ingotrecipe1 = {
	name = name.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = name,
	result_count = 4,
	energy_required = 5/4,
	category = "craft-bench",
	hide_from_player_crafting = true,
	enabled = false
}
local ingotrecipe2 = { -- in Foundry
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	result_count = 4,
	energy_required = 3,
	category = "foundry",
	enabled = false
}

data:extend({ingot,ingotrecipe1,ingotrecipe2})
