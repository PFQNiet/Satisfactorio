local name = "resource-well-pressuriser"
local sounds = copySoundsFrom(data.raw["mining-drill"].pumpjack)
local miner = {
	type = "mining-drill",
	name = name,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	animations = {
		filename = graphics.."placeholders/"..name..".png",
		size = {320,320}
	},
	selection_box = {{-5,-5},{5,5}},
	collision_box = {{-4.7,-4.7},{4.7,4.7}},
	energy_source = {
		type = "electric",
		usage_priority = "secondary-input"
	},
	energy_usage = "150MW",
	open_sound = sounds.open_sound,
	close_sound = sounds.close_sound,
	working_sound = sounds.working_sound,
	flags = {
		"placeable-player",
		"player-creation",
		"not-rotatable"
	},
	max_health = 1,
	minable = {
		mining_time = 0.5,
		result = name
	},
	mining_speed = 1,
	resource_categories = {"resource-well"},
	resource_searching_radius = 0.49,
	allowed_effects = {"speed","consumption"},
	module_specification = {module_slots = 3},
	vector_to_place_result = {0,0}
}
local mineritem = {
	type = "item",
	name = name,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	place_result = name,
	stack_size = 1,
	subgroup = "production-fluid",
	order = "f["..name.."]"
}

local minerrecipe = makeBuildingRecipe{
	name = name,
	ingredients = {
		{"wire",200},
		{"rubber",50},
		{"encased-industrial-beam",50},
		{"motor",50}
	},
	result = name
}

data:extend{miner,mineritem,minerrecipe}
