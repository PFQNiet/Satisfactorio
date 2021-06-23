local name = "resource-well-extractor"
local sounds = copySoundsFrom(data.raw["mining-drill"].pumpjack)
local miner = {
	type = "mining-drill",
	name = name,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	animations = {
		filename = "__Satisfactorio__/graphics/placeholders/"..name..".png",
		size = {96,96}
	},
	selection_box = {{-1.5,-1.5},{1.5,1.5}},
	collision_box = {{-1.2,-1.2},{1.2,1.2}},
	energy_source = {type = "void"},
	energy_usage = "1W",
	open_sound = sounds.open_sound,
	close_sound = sounds.close_sound,
	working_sound = sounds.working_sound,
	flags = {
		"placeable-player",
		"player-creation"
	},
	max_health = 1,
	minable = {
		mining_time = 0.5,
		result = name
	},
	mining_speed = 1, -- base 60/min
	resource_categories = {"resource-node"},
	resource_searching_radius = 0.49,
	allowed_effects = {"speed","consumption"},
	module_specification = {module_slots = 3},
	vector_to_place_result = {0,0},
	output_fluid_box = {
		base_area = 0.1,
		base_level = 1,
		pipe_connections = {
			{positions = {
				{0,-2},
				{2,0},
				{0,2},
				{-2,0}
			}}
		},
		pipe_covers = pipecoverspictures()
	}
}

local mineritem = {
	type = "item",
	name = name,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	place_result = name,
	stack_size = 50,
	subgroup = "production-miner",
	order = "g["..name.."]"
}

local minerrecipe = makeBuildingRecipe{
	name = name,
	ingredients = {
		{"steel-beam",10},
		{"plastic",10}
	},
	result = name
}

data:extend{miner,mineritem,minerrecipe}
