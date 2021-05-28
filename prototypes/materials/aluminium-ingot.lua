local name = "aluminium-ingot"
local ingot = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "h[bauxite]-c["..name.."]",
	stack_size = 100,
	subgroup = "ingots",
	type = "item"
}

local ingredients = {
	{"aluminium-scrap",6},
	{"silica",5}
}
local ingotrecipe1 = {
	name = name.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = name,
	result_count = 4,
	energy_required = 5/4,
	category = "craft-bench",
	icons = {
		{ icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64 },
		{ icon = "__Satisfactorio__/graphics/icons/silica.png", icon_size = 64, scale = 0.25, shift = {-8, 8} }
	},
	hide_from_player_crafting = true,
	enabled = false
}
local ingotrecipe2 = { -- in Foundry
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	result_count = 4,
	energy_required = 4,
	category = "foundry",
	icons = {
		{ icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64 },
		{ icon = "__Satisfactorio__/graphics/icons/silica.png", icon_size = 64, scale = 0.25, shift = {-8, 8} }
	},
	enabled = false
}

data:extend({ingot,ingotrecipe1,ingotrecipe2})
