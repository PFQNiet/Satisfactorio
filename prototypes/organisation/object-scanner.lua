local name = "object-scanner"
local scanneritem = {
	type = "item",
	name = name,
	localised_description = {"item-description.object-scanner",{"gui.instruction-to-open-item","__ALT_CONTROL__1__open-item__"}},
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	stack_size = 1,
	subgroup = "logistics-observation",
	order = "f["..name.."]"
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

local openscanner = {
	type = "custom-input",
	name = "open-object-scanner",
	key_sequence = "",
	linked_game_control = "open-item",
	consuming = "none",
	include_selected_prototype = true,
	action = "lua"
}

data:extend{scanneritem, scannerrecipe, openscanner}
