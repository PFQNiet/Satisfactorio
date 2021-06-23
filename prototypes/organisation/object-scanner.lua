local name = "object-scanner"
local scanneritem = {
	type = "selection-tool",
	name = name,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	stack_size = 1,
	subgroup = "logistics-observation",
	order = "f["..name.."]",
	selection_mode = {"nothing"},
	selection_color = {a=0},
	selection_cursor_box_type = "entity",
	alt_selection_mode = {"nothing"},
	alt_selection_color = {a=0},
	alt_selection_cursor_box_type = "entity",
	mouse_cursor = name,
	flags = {"mod-openable"}
}
local defaultcursor = {
	type = "mouse-cursor",
	name = name,
	system_cursor = "arrow"
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
	energy_required = 10/4,
	category = "equipment",
	enabled = false
}

data:extend({scanneritem,defaultcursor,scannerrecipe})
