local name = "hub-parts"
local hubparts = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "a["..name.."]",
	stack_size = 1,
	subgroup = "raw-material",
	type = "item"
}

data:extend({hubparts})