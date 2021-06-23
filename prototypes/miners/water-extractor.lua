assert(foundation_layer ~= nil, "Foundation must be defined before water extractor, as it uses its collision mask")

local name = "water-extractor"
local sounds = copySoundsFrom(data.raw["offshore-pump"]["offshore-pump"])
local extractor = {
	type = "mining-drill",
	name = name,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	animations = makeRotatedSprite(name, 320, 320),
	selection_box = {{-5,-5},{5,5}},
	collision_box = {{-4.7,-4.7},{4.7,4.7}},
	collision_mask = {"ground-tile","object-layer",foundation_layer},
	energy_source = {
		type = "electric",
		usage_priority = "secondary-input"
	},
	energy_usage = "20MW",
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
	mining_speed = 2, -- base 120/min
	resource_categories = {"water"},
	resource_searching_radius = 1.99,
	allowed_effects = {"speed","consumption"},
	module_specification = {module_slots = 3},
	vector_to_place_result = {0,0},
	output_fluid_box = {
		base_area = 0.1,
		base_level = 1,
		pipe_connections = {
			{positions = {
				{0.5,-5.5},
				{5.5,0.5},
				{-0.5,5.5},
				{-5.5,-0.5}
			}}
		},
		pipe_covers = pipecoverspictures()
	},
	placeable_by = {item=name,count=1}, -- the item places a placeholder entity
}
-- "placeholder" that can be placed on any water tiles, will spawn a water "resource node" beneath itself
-- EEI type is used so that tooltip provides power info
local placeholder = {
	type = "electric-energy-interface",
	name = name.."-placeholder",
	localised_name = {"entity-name."..name},
	energy_source = {
		type = "electric",
		buffer_capacity = "20MW",
		usage_priority = "secondary-input",
		drain = "0W"
	},
	energy_usage = "20MW",
	animations = extractor.animations,
	max_health = 1,
	icon = extractor.icon,
	icon_size = 64,
	collision_box = {{-4.7,-4.7},{4.7,4.7}},
	collision_mask = {"ground-tile","object-layer",foundation_layer},
	flags = {
		"placeable-player",
		"player-creation"
	},
	minable = nil, -- auto-removed on placement of the extractor
	selection_box = {{-5,-5},{5,5}}
}

local extractoritem = {
	type = "item",
	name = name,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	place_result = name.."-placeholder",
	stack_size = 50,
	subgroup = "production-fluid",
	order = "a["..name.."]"
}

local extractorrecipe = makeBuildingRecipe{
	name = name,
	ingredients = {
		{"copper-sheet",20},
		{"reinforced-iron-plate",10},
		{"rotor",10}
	},
	result = name
}

data:extend{extractor,placeholder,extractoritem,extractorrecipe}
