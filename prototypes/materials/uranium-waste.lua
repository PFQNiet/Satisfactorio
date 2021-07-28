local name = "uranium-waste"
local item = {
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	name = name,
	localised_description = {"item-description.radioactivity",{"item-description.radioactivity-average"}},
	order = "k[uranium]-c["..name.."]",
	stack_size = 500,
	subgroup = "nuclear",
	type = "item"
}

data:extend{item}
