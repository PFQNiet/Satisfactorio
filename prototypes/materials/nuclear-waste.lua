local name = "nuclear-waste"
local ingot = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "k[uranium]-e["..name.."]",
	stack_size = 500,
	subgroup = "nuclear",
	type = "item"
}

local ingredients = {
	{type="fluid",name="water",amount=60}
}
local ingotrecipe = { -- in Nuclear Power Plant
	name = name,
	type = "recipe",
	ingredients = ingredients,
	results = {
		{name,1},
		{type="fluid",name="steam",amount=60,temperature=515}
	},
	main_product = name,
	energy_required = 12,
	category = "nuclear-power",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_player_crafting = true,
	hide_from_stats = true
}

data:extend({ingot,ingotrecipe})
