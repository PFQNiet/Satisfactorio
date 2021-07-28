assert(train_platform_layer ~= nil, "Train station must be defined before freight platform, as it uses its collision mask")

local sounds = copySoundsFrom(data.raw["storage-tank"]["storage-tank"])
local name = "fluid-freight-platform"
local base = {
	type = "electric-energy-interface",
	name = name,
	energy_source = {
		type = "electric",
		buffer_capacity = "50MW",
		input_flow_limit = "50MW",
		usage_priority = "secondary-input",
		drain = "0W"
	},
	energy_usage = "50MW",
	pictures = makeRotatedSprite(name, 448, 224),
	max_health = 1,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	render_layer = "lower-object",
	collision_box = {{-6.7,-3.2},{6.7,3.2}},
	collision_mask = {train_platform_layer},
	flags = {
		"placeable-player",
		"player-creation"
	},
	minable = {
		mining_time = 0.5,
		result = name
	},
	remove_decoratives = "true",
	open_sound = sounds.open_sound,
	close_sound = sounds.close_sound,
	selection_box = {{-7,-3.5},{7,3.5}},
	selection_priority = 49
}

local storage = {
	type = "storage-tank",
	name = name.."-tank",
	localised_name = {"entity-name."..name},
	icon = base.icon,
	icon_size = base.icon_size,
	open_sound = sounds.open_sound,
	close_sound = sounds.close_sound,
	working_sound = sounds.working_sound,
	collision_box = {{-2.2,-2.2},{2.2,2.2}},
	collision_mask = {},
	flags = {"not-on-map"},
	fluid_box = {
		height = pipe_height_2,
		base_area = 24/pipe_height_2, -- 2400 capacity
		pipe_connections = {
			{position={3,-2},type="output"},
			{position={3,-1},type="input"},
			{position={3,1},type="input"},
			{position={3,2},type="output"}
		},
		pipe_covers = pipecoverspictures()
	},
	max_health = 1,
	flow_length_in_ticks = 360,
	pictures = {
		window_background = empty_graphic,
		fluid_background = empty_graphic,
		flow_sprite = empty_graphic,
		gas_flow = empty_graphic,
		picture = empty_graphic
	},
	selection_box = {{-2.5,-2.5},{2.5,2.5}},
	selectable_in_game = false,
	two_direction_only = false,
	window_bounding_box = {{-0.125,0.6875},{0.1875,1.1875}},
	scale_info_icons = true
}

local item = {
	icons = {
		{icon = graphics.."icons/"..name..".png", icon_size = 64},
		{icon = graphics.."icons/water.png", icon_size = 64, scale = 0.25, shift = {-8,8}}
	},
	name = name,
	order = "a[train-system]-b[platforms]-c["..name.."]",
	place_result = name,
	stack_size = 50,
	subgroup = "train-transport",
	type = "item"
}

local recipe = makeBuildingRecipe{
	name = name,
	ingredients = {
		{"heavy-modular-frame",6},
		{"computer",2},
		{"concrete",50},
		{"copper-cable",25},
		{"motor",5}
	},
	result = name
}

data:extend{base,storage,item,recipe}
