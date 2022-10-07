local placeholder = require("graphics.placeholders.builder")

local name = "oil-extractor"
local sounds = copySoundsFrom(data.raw["mining-drill"].pumpjack)
local miner = {
	type = "mining-drill",
	name = name,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	animations = placeholder().fourway().addBox(-2,-6,5,9,{},{{0,-6}}).addIcon(graphics.."icons/oil-extractor.png",64).result(),
	selection_box = {{-2.5,-6.5},{2.5,2.5}},
	collision_box = {{-2.2,-6.2},{2.2,2.2}},
	energy_source = {
		type = "electric",
		usage_priority = "secondary-input"
	},
	energy_usage = "40MW",
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
	resource_categories = {"crude-oil"},
	resource_searching_radius = 1.49,
	allowed_effects = {"speed","consumption"},
	module_specification = {module_slots = 3},
	vector_to_place_result = {0,0},
	output_fluid_box = {
		base_area = 0.1,
		base_level = 1,
		pipe_connections = {
			{positions = {
				{0,-7},
				{7,0},
				{0,7},
				{-7,0}
			},type="output"}
		},
		pipe_covers = pipecoverspictures()
	}
}

local mineritem = {
	type = "item",
	name = name,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	place_result = name,
	stack_size = 50,
	subgroup = "production-fluid",
	order = "b["..name.."]"
}

local minerrecipe = makeBuildingRecipe{
	name = name,
	ingredients = {
		{"motor",15},
		{"encased-industrial-beam",20},
		{"copper-cable",60}
	},
	result = name
}

data:extend{miner,mineritem,minerrecipe}
