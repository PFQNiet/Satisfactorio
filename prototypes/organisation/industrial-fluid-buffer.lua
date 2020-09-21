local name = "industrial-fluid-buffer"
local tank = {
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
	collision_box = {{-3.2,-3.2},{3.2,3.2}},
	corpse = "big-remnants",
	dying_explosion = "big-explosion",
	flags = {
		"placeable-player",
		"player-creation"
	},
	fluid_box = {
		base_area = 24,
		pipe_connections = {
			{position={0,-4}},
			{position={0,4}}
		},
		pipe_covers = table.deepcopy(data.raw['storage-tank']['storage-tank'].fluid_box.pipe_covers)
	},
	max_health = 1,
	minable = {
		mining_time = 1,
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
				filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ns.png",
				size = {224,224}
			},
			east = {
				filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ew.png",
				size = {224,224}
			},
			south = {
				filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ns.png",
				size = {224,224}
			},
			west = {
				filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ew.png",
				size = {224,224}
			}
		}
	},
	selection_box = {{-3.5,-3.5},{3.5,3.5}},
	two_direction_only = true,
	window_bounding_box = {{-0.125,0.6875},{0.1875,1.1875}},
	working_sound = data.raw['storage-tank']['storage-tank'].working_sound
}

local tankitem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "t["..name.."]",
	place_result = name,
	stack_size = 1,
	subgroup = "storage",
	type = "item"
}

local ingredients = {
	{"plastic-bar",30},
	{"heavy-modular-frame",3}
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
	localised_name = {"recipe-name.dismantle",{"item-name."..name}},
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

data:extend({tank,tankitem,tankrecipe,tankrecipe_undo})
