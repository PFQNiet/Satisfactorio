local name = "mycelia"
data:extend({
	{
		type = "item",
		name = name,
		icon = "__Satisfactorio__/graphics/icons/"..name..".png",
		icon_size = 64,
		subgroup = "organic-resource",
		order = "r["..name.."]",
		stack_size = 200,
		fuel_category = "chemical",
		fuel_value = "20MJ"
	}
})