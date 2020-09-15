local name = "object-scanner"
local scanneritem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "f["..name.."]",
	stack_size = 1,
	subgroup = "logistics-observation",
	type = "item"
}

local ingredients = {
	{"reinforced-iron-plate",4},
	{"map-marker",3},
	{"screw",50}
}
local scannerrecipe = {
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 1,
	category = "equipment",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	enabled = false
}

data:extend({scanneritem,scannerrecipe})
