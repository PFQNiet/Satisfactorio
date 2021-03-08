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

data:extend({ingot})
