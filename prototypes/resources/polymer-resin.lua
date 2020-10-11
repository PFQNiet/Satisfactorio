local name = "polymer-resin"
local item = {
	type = "item",
	name = name,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	subgroup = "organic-resource",
	order = "f[oil]-c["..name.."]",
	stack_size = 200
}

-- no recipe as it is a by-product
data:extend({item})
