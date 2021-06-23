local name = "fluid-buffer"
local tank = {
	type = "storage-tank",
	name = name,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	open_sound = basesounds.machine_open,
	close_sound = basesounds.machine_close,
	collision_box = {{-1.2,-1.2},{1.2,1.2}},
	flags = {
		"placeable-player",
		"player-creation"
	},
	fluid_box = {
		height = pipe_height_2,
		base_area = 4/pipe_height_2, -- 400 capacity
		pipe_connections = {
			{position={0,-2}},
			{position={0,2}}
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
				size = {96,96}
			},
			east = {
				filename = graphics.."placeholders/"..name.."-ew.png",
				size = {96,96}
			},
			south = {
				filename = graphics.."placeholders/"..name.."-ns.png",
				size = {96,96}
			},
			west = {
				filename = graphics.."placeholders/"..name.."-ew.png",
				size = {96,96}
			}
		}
	},
	selection_box = {{-1.5,-1.5},{1.5,1.5}},
	two_direction_only = true,
	window_bounding_box = {{-0.125,0.6875},{0.1875,1.1875}},
	working_sound = copySoundsFrom(data.raw['storage-tank']['storage-tank']).working_sound
}

local tankitem = {
	type = "item",
	name = name,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	place_result = name,
	stack_size = 50,
	subgroup = "storage",
	order = "s["..name.."]"
}

local tankrecipe = makeBuildingRecipe{
	name = name,
	ingredients = {
		{"copper-sheet",10},
		{"modular-frame",5}
	},
	result = name
}

data:extend{tank,tankitem,tankrecipe}
