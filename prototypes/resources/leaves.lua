local name = "leaves"
data:extend({
	{
		type = "item",
		name = name,
		icon = "__Satisfactorio__/graphics/icons/"..name..".png",
		icon_size = 64,
		subgroup = "raw-resource",
		order = "a["..name.."]",
		stack_size = 500,
		fuel_category = "chemical",
		fuel_value = "15MJ"
	}
})