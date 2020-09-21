local name = "petroleum-coke"
local item = {
	type = "item",
	name = name,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	subgroup = "organic-resource",
	order = "v["..name.."]",
	stack_size = 200,
	fuel_category = "carbon",
	fuel_value = "180MJ"
}

local ingredients = {
	{type="fluid",name="heavy-oil",amount=4}
}
local recipe = { -- in Refinery
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	result_count = 12,
	energy_required = 6,
	category = "refining",
	enabled = false
}
data:extend({item, recipe})
