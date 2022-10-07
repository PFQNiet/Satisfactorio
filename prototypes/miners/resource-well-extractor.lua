local placeholder = require("graphics.placeholders.builder")

local name = "resource-well-extractor"
local sounds = copySoundsFrom(data.raw["mining-drill"].pumpjack)
local miner = {
	type = "mining-drill",
	name = name,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	animations = placeholder().fourway().addBox(-1,-1,3,3,{},{{0,-1}}).addIcon(graphics.."icons/"..name..".png",64).result(),
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
