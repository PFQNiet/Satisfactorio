local name = "alien-carapace"
data:extend({
	{
		type = "item",
		name = name,
		icon = graphics.."icons/"..name..".png",
		icon_size = 64,
		subgroup = "organic-resource",
		order = "e["..name.."]",
		stack_size = 50,
		fuel_category = "chemical",
		fuel_value = "250MJ"
	}
})
