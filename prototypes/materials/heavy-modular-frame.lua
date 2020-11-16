local name = "heavy-modular-frame"
local frame = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "a[frame]-b["..name.."]",
	stack_size = 50,
	subgroup = "components",
	type = "item"
}

local ingredients = {
	{"modular-frame",5},
	{"steel-pipe",15},
	{"encased-industrial-beam",5},
	{"iron-gear-wheel",100}
}
local framerecipe1 = { -- by hand in Craft Bench
	name = name.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 9/4,
	category = "craft-bench",
	hide_from_player_crafting = true,
	enabled = false
}
local framerecipe2 = { -- in Manufacturer
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 30,
	category = "manufacturing",
	enabled = false
}

data:extend({frame,framerecipe1,framerecipe2})
