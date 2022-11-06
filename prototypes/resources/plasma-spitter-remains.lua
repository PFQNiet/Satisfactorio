local name = "plasma-spitter-remains"
data:extend({
	{
		type = "item",
		name = name,
		icon = graphics.."icons/"..name..".png",
		icon_size = 64,
		subgroup = "organic-resource",
		order = "r[remains]-b["..name.."]",
		stack_size = 50
	}
})
