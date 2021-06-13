local name = "conveyor-merger"
local empty_sprite = {
	filename = "__core__/graphics/empty.png",
	width = 1,
	height = 1
}

local merger = {
	type = "constant-combinator",
	name = name,
	activity_led_light_offsets = {{0,0},{0,0},{0,0},{0,0}},
	activity_led_sprites = empty_sprite,
	circuit_wire_connection_points = data.raw['constant-combinator']['constant-combinator'].circuit_wire_connection_points,
	item_slot_count = 0,
	sprites = {
		north = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-n.png",
			size = {96,96}
		},
		east = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-e.png",
			size = {96,96}
		},
		south = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-s.png",
			size = {96,96}
		},
		west = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-w.png",
			size = {96,96}
		}
	},
	max_health = 1,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	collision_box = {{-1.2,-1.2},{1.2,1.2}},
	flags = {
		"placeable-player",
		"player-creation"
	},
	friendly_map_color = data.raw['utility-constants'].default.chart.default_friendly_color_by_type.splitter,
	minable = {
		mining_time = 0.5,
		result = name
	},
	selection_box = {{-1.5,-1.5},{1.5,1.5}}
}
local bufferbox = {
	collision_box = {{-0.2,-0.2},{0.2,0.2}},
	collision_mask = {},
	enable_inventory_bar = false,
	flags = {
		"not-on-map",
		"hide-alt-info"
	},
	icon = merger.icon,
	icon_size = merger.icon_size,
	inventory_size = 1,
	max_health = 1,
	minable = nil,
	name = name.."-box",
	picture = empty_sprite,
	selection_box = {{-0.5,-0.5},{0.5,0.5}},
	selection_priority = 40,
	selectable_in_game = false,
	circuit_wire_max_distance = 1,
	type = "container"
}

local mergeritem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "c[splitter]-a["..name.."]",
	place_result = name,
	stack_size = 50,
	subgroup = "belt",
	type = "item"
}

local ingredients = {
	{"iron-plate",2},
	{"iron-stick",2}
}
local mergerrecipe = {
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
local _group = data.raw['item-subgroup'][mergeritem.subgroup]
local mergerrecipe_undo = {
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
	order = _group.order .. "-" .. mergeritem.order,
	allow_decomposition = false,
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	icons = {
		{icon = "__base__/graphics/icons/deconstruction-planner.png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64}
	},
	enabled = false
}

data:extend({merger,bufferbox,mergeritem,mergerrecipe,mergerrecipe_undo})
