local name = "alien-organs"
data:extend({
	{
		type = "item",
		name = name,
		icon = "__Satisfactorio__/graphics/icons/"..name..".png",
		icon_size = 64,
		subgroup = "organic-resource",
		order = "f["..name.."]",
		stack_size = 50,
		fuel_category = "chemical",
		fuel_value = "250MJ"
	}
})
