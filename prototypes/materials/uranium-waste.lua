local name = "uranium-waste"
local item = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "k[uranium]-c["..name.."]",
	stack_size = 500,
	subgroup = "nuclear",
	type = "item"
}

data:extend{item}
