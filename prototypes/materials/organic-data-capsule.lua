local name = "organic-data-capsule"
local item = {
	type = "item",
	name = name,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	subgroup = "organic-resource",
	order = "r[remains]-r["..name.."]",
	stack_size = 50
}
data:extend{item}
