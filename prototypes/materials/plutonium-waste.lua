local name = "plutonium-waste"
local item = {
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	localised_description = {"item-description.radioactivity",{"item-description.radioactivity-extreme"}},
	name = name,
	order = "k[uranium]-h["..name.."]",
	stack_size = 500,
	subgroup = "nuclear",
	type = "item"
}

data:extend{item}
