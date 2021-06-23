local name = "valve"
local tank = {
	-- placeholder entity that contains both input and output for visualisation purposes - these will then be split to separate entities by script
	type = "storage-tank",
	name = name,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	open_sound = basesounds.machine_open,
	close_sound = basesounds.machine_close,
	collision_box = {{-0.4,-0.9},{0.4,0.9}},
	flags = {
		"placeable-player",
		"player-creation"
	},
	fluid_box = {
		height = pipe_height_2,
		base_area = 0.1/pipe_height_2, -- 10 capacity - should be sufficient for sending 600/m through if polled every 30 ticks
		pipe_connections = {},
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
		picture = makeRotatedSprite(name, 32, 64)
	},
	selection_box = {{-0.5,-1},{0.5,1}},
	window_bounding_box = {{-0.125,0.0875},{0.1875,0.4875}},
	working_sound = data.raw['storage-tank']['storage-tank'].working_sound
}
local tankin = table.deepcopy(tank)
tankin.name = name.."-input"
tankin.localised_name = {"entity-name."..name}
tankin.minable = nil
tankin.fluid_box.pipe_connections = {{type="input",position={0,1}}}
tankin.pictures.picture = empty_graphic
table.insert(tankin.flags,"hide-alt-info")
tankin.collision_box = {{-0.4,-0.4},{0.4,0.4}}
tankin.collision_mask = {}
tankin.selection_box = {{-0.5,-0.5},{0.5,0.5}}
tankin.selectable_in_game = false

local tankout = table.deepcopy(tankin)
tankout.name = name.."-output"
tankout.fluid_box.pipe_connections = {{type="output",position={0,-1}}}

tank.fast_replaceable_group = "pipe"
tank.fluid_box.base_area = 6/pipe_height_2 -- 600 capacity - for visualisation purposes only

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

data:extend{tank,tankin,tankout,tankitem,tankrecipe}
