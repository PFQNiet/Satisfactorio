local name = "alien-protein"
local item = {
	type = "item",
	name = name,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	subgroup = "organic-resource",
	order = "r[remains]-p["..name.."]",
	stack_size = 100
}
data:extend{item}
