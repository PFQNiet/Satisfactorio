local name = "leaves"
data:extend({
	{
		type = "item",
		name = name,
		icon = graphics.."icons/"..name..".png",
		icon_size = 64,
		subgroup = "organic-resource",
		order = "a["..name.."]",
		stack_size = 500,
		fuel_category = "chemical",
		fuel_value = "15MJ"
	}
})
