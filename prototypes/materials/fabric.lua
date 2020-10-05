local name = "fabric"
local fabric = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "m[mycelia]-a["..name.."]",
	stack_size = 100,
	subgroup = "parts",
	type = "item"
}

local ingredients = {
	{"mycelia",1},
	{"biomass",5}
}
local fabricrecipe1 = { -- by hand in Craft Bench
	name = name.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 2/4,
	category = "craft-bench",
	hide_from_player_crafting = true,
	enabled = false
}
local fabricrecipe2 = { -- in Constructor
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 4,
	category = "constructing",
	enabled = false
}

data:extend({fabric,fabricrecipe1,fabricrecipe2})
