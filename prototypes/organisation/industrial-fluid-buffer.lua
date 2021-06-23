local name = "industrial-fluid-buffer"
local tank = {
	type = "storage-tank",
	name = name,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	open_sound = basesounds.machine_open,
	close_sound = basesounds.machine_close,
	collision_box = {{-3.2,-3.2},{3.2,3.2}},
	flags = {
		"placeable-player",
		"player-creation"
	},
	fluid_box = {
		height = pipe_height_2,
		base_area = 24/pipe_height_2, -- 2400 capacity
		pipe_connections = {
			{position={0,-4}},
			{position={0,4}}
		},
		pipe_covers = pipecoverspictures()
	},
	max_health = 1,
	minable = {
		mining_time = 0.5,
		result = name
	},
	flow_length_in_ticks = 360,
	pictures = {
		window_background = empty_graphic,
		fluid_background = empty_graphic,
		flow_sprite = empty_graphic,
		gas_flow = empty_graphic,
		picture = {
			north = {
				filename = graphics.."placeholders/"..name.."-ns.png",
				size = {224,224}
			},
			east = {
				filename = graphics.."placeholders/"..name.."-ew.png",
				size = {224,224}
			},
			south = {
				filename = graphics.."placeholders/"..name.."-ns.png",
				size = {224,224}
			},
			west = {
				filename = graphics.."placeholders/"..name.."-ew.png",
				size = {224,224}
			}
		}
	},
	selection_box = {{-3.5,-3.5},{3.5,3.5}},
	two_direction_only = true,
	window_bounding_box = {{-0.125,0.6875},{0.1875,1.1875}},
	working_sound = copySoundsFrom(data.raw['storage-tank']['storage-tank']).working_sound
}

local tankitem = {
	type = "item",
	name = name,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	place_result = name,
	stack_size = 50,
	subgroup = "storage",
	order = "t["..name.."]"
}

local tankrecipe = makeBuildingRecipe{
	name = name,
	ingredients = {
		{"plastic",30},
		{"heavy-modular-frame",3}
	},
	result = name
}

data:extend{tank,tankitem,tankrecipe}
