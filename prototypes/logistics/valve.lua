local name = "valve"
local tank = {
	-- placeholder entity that contains both input and output for visualisation purposes - these will then be split to separate entities by script
	type = "storage-tank",
	name = name,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	open_sound = {
		filename = "__base__/sound/machine-open.ogg",
		volume = 0.5
	},
	close_sound = {
		filename = "__base__/sound/machine-close.ogg",
		volume = 0.5
	},
	collision_box = {{-0.4,-0.9},{0.4,0.9}},
	flags = {
		"placeable-player",
		"player-creation"
	},
	fluid_box = {
		height = data.raw.pipe.pipe.fluid_box.height,
		base_area = 0.1/data.raw.pipe.pipe.fluid_box.height, -- 10 capacity - should be sufficient for sending 600/m through if polled every 30 ticks
		pipe_connections = {},
		pipe_covers = table.deepcopy(data.raw['storage-tank']['storage-tank'].fluid_box.pipe_covers)
	},
	max_health = 1,
	minable = {
		mining_time = 0.5,
		result = name
	},
	flow_length_in_ticks = 360,
	pictures = {
		window_background = data.raw['storage-tank']['storage-tank'].pictures.window_background,
		fluid_background = data.raw['storage-tank']['storage-tank'].pictures.fluid_background,
		flow_sprite = data.raw['storage-tank']['storage-tank'].pictures.flow_sprite,
		gas_flow = data.raw['storage-tank']['storage-tank'].pictures.gas_flow,
		picture = {
			north = {
				filename = "__Satisfactorio__/graphics/placeholders/"..name.."-n.png",
				size = {32,64}
			},
			east = {
				filename = "__Satisfactorio__/graphics/placeholders/"..name.."-e.png",
				size = {64,32}
			},
			south = {
				filename = "__Satisfactorio__/graphics/placeholders/"..name.."-s.png",
				size = {32,64}
			},
			west = {
				filename = "__Satisfactorio__/graphics/placeholders/"..name.."-w.png",
				size = {64,32}
			}
		}
	},
	selection_box = {{-0.5,-1},{0.5,1}},
	window_bounding_box = {{-0.125,0.0875},{0.1875,0.4875}},
	working_sound = data.raw['storage-tank']['storage-tank'].working_sound
}
local tankin = table.deepcopy(tank)
tankin.name = name.."-input"
tankin.minable = nil
tankin.fluid_box.pipe_connections = {{type="input",position={0,1}}}
tankin.pictures.picture = {
	filename = "__core__/graphics/empty.png",
	size = {1,1}
}
table.insert(tankin.flags,"hide-alt-info")
tankin.collision_box = {{-0.4,-0.4},{0.4,0.4}}
tankin.collision_mask = {}
tankin.selection_box = {{-0.5,-0.5},{0.5,0.5}}
tankin.selection_priority = 40
tankin.selectable_in_game = false

local tankout = table.deepcopy(tank)
tankout.name = name.."-output"
tankout.minable = nil
tankout.fluid_box.pipe_connections = {{type="output",position={0,-1}}}
tankout.pictures.picture = {
	filename = "__core__/graphics/empty.png",
	size = {1,1}
}
table.insert(tankout.flags,"hide-alt-info")
tankout.collision_box = {{-0.4,-0.4},{0.4,0.4}}
tankout.collision_mask = {}
tankout.selection_box = {{-0.5,-0.5},{0.5,0.5}}
tankout.selection_priority = 40
tankout.selectable_in_game = false

tank.fast_replaceable_group = "pipe"
tank.fluid_box.base_area = 6/data.raw.pipe.pipe.fluid_box.height -- 600 capacity - for visualisation purposes only

local tankitem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "d["..name.."]",
	place_result = name,
	stack_size = 50,
	subgroup = "pipe-distribution",
	type = "item"
}

local ingredients = {
	{"rubber",4},
	{"steel-plate",4}
}
local tankrecipe = {
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 1,
	category = "building",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	enabled = false
}
local _group = data.raw['item-subgroup'][tankitem.subgroup]
local tankrecipe_undo = {
	name = name.."-undo",
	localised_name = {"recipe-name.dismantle",{"entity-name."..name}},
	type = "recipe",
	ingredients = {
		{name,1}
	},
	results = ingredients,
	energy_required = 1,
	category = "unbuilding",
	subgroup = _group.group .. "-undo",
	order = _group.order .. "-" .. tankitem.order,
	allow_decomposition = false,
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	enabled = false,
	icons = {
		{icon = "__base__/graphics/icons/deconstruction-planner.png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64}
	}
}

data:extend({tank,tankin,tankout,tankitem,tankrecipe,tankrecipe_undo})
