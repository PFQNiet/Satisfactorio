local name = "object-scanner"
local sounds = copySoundsFrom(data.raw.blueprint.blueprint)
local scanneritem = {
	type = "selection-tool",
	name = name,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	stack_size = 1,
	subgroup = "logistics-observation",
	order = "f["..name.."]",
	open_sound = sounds.open_sound,
	close_sound = sounds.close_sound,
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
	filename = graphics.."empty.png",
	hot_pixel_x = 0,
	hot_pixel_y = 0
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
