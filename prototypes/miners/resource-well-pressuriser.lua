local name = "resource-well-pressuriser"
local miner = {
	allowed_effects = {"speed","consumption"},
	module_specification = {module_slots = 3},
	animations = {
		filename = "__Satisfactorio__/graphics/placeholders/"..name..".png",
		size = {320,320}
	},
	collision_box = {{-4.7,-4.7},{4.7,4.7}},
	energy_source = {
		type = "electric",
		usage_priority = "secondary-input"
	},
	energy_usage = "150MW",
	working_sound = data.raw['mining-drill']['pumpjack'].working_sound,
	flags = {
		"placeable-player",
		"player-creation",
		"not-rotatable"
	},
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	max_health = 1,
	minable = {
		mining_time = 0.5,
		result = name
	},
	mining_speed = 1,
	name = name,
	resource_categories = {"resource-well"},
	resource_searching_radius = 0.49,
	selection_box = {{-5,-5},{5,5}},
	type = "mining-drill",
	vector_to_place_result = {0,0}
}
local mineritem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "c["..name.."]",
	place_result = name,
	stack_size = 1,
	subgroup = "production-fluid",
	type = "item"
}

local mineritem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "f["..name.."]",
	place_result = name,
	stack_size = 50,
	subgroup = "production-miner",
	type = "item"
}

local ingredients = {
	{"wire",200},
	{"rubber",50},
	{"encased-industrial-beam",50},
	{"motor",50}
}
local minerrecipe = {
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 1,
	category = "building",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	enabled = false
}
local _group = data.raw['item-subgroup'][mineritem.subgroup]
local minerrecipe_undo = {
	name = name.."-undo",
	localised_name = {"recipe-name.dismantle",{"entity-name."..name}},
	type = "recipe",
	ingredients = {
		{name,1}
	},
	results = ingredients,
	energy_required = 1,
	category = "unbuilding",
	subgroup = _group.group .. "-undo",
	order = _group.order .. "-" .. mineritem.order,
	allow_decomposition = false,
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	icons = {
		{icon = "__base__/graphics/icons/deconstruction-planner.png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64}
	},
	enabled = false
}

data:extend({miner,mineritem,minerrecipe,minerrecipe_undo})
