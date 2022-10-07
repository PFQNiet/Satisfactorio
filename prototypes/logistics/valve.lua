local placeholder = require("graphics.placeholders.builder")
local name = "valve"
local sprites = placeholder().fourway().addBox(0,-0.5,1,2,{},{}).addIcon(graphics.."icons/valve.png",32)
sprites.north().addMark('arrow','north',{0,-0.75})
sprites.east().addMark('arrow','east',{0.75,0})
sprites.south().addMark('arrow','south',{0,0.75})
sprites.west().addMark('arrow','west',{-0.75,0})
local valve = {
	type = "constant-combinator",
	name = name,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	open_sound = basesounds.machine_open,
	close_sound = basesounds.machine_close,
	activity_led_light_offsets = {{0,0},{0,0},{0,0},{0,0}},
	activity_led_sprites = empty_graphic,
	circuit_wire_connection_points = data.raw['constant-combinator']['constant-combinator'].circuit_wire_connection_points,
	item_slot_count = 2,
	sprites = sprites.result(),
	max_health = 1,
	collision_box = {{-0.4,-0.9},{0.4,0.9}},
	flags = {
		"placeable-player",
		"player-creation",
		"hide-alt-info"
	},
	friendly_map_color = data.raw['utility-constants'].default.chart.default_friendly_color_by_type['storage-tank'],
	minable = {
		mining_time = 0.5,
		result = name
	},
	selection_box = {{-0.5,-1},{0.5,1}}
}

local tank_template = {
	type = "storage-tank",
	-- name = name,
	localised_name = {"entity-name."..name},
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	open_sound = basesounds.machine_open,
	close_sound = basesounds.machine_close,
	collision_box = {{-0.4,-0.4},{0.4,0.4}},
	collision_mask = {},
	flags = {
		"placeable-player",
		"player-creation",
		"hide-alt-info"
	},
	fluid_box = {
		height = pipe_height_2,
		base_area = 0.01/pipe_height_2, -- 1 capacity
		pipe_connections = {},
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
	selection_box = {{-0.5,-0.5},{0.5,0.5}},
	selectable_in_game = false,
	window_bounding_box = {{-0.125,0.0875},{0.1875,0.4875}},
	working_sound = data.raw['storage-tank']['storage-tank'].working_sound
}
local tankin = table.deepcopy(tank_template)
tankin.name = name.."-input"
tankin.fluid_box.pipe_connections = {{type="input",position={0,1}}}

local tankout = table.deepcopy(tankin)
tankout.name = name.."-output"
tankout.fluid_box.pipe_connections = {{type="output",position={0,-1}}}

local tankitem = {
	type = "item",
	name = name,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	place_result = name,
	stack_size = 50,
	subgroup = "pipe-distribution",
	order = "d["..name.."]"
}

local tankrecipe = makeBuildingRecipe{
	name = name,
	ingredients = {
		{"rubber",4},
		{"steel-beam",4}
	},
	result = name
}

data:extend{valve,tankin,tankout,tankitem,tankrecipe}
