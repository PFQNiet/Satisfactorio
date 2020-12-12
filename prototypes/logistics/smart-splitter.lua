local name = "smart-splitter"
local empty_sprite = {
	filename = "__core__/graphics/empty.png",
	width = 1,
	height = 1
}

local splitter = {
	type = "constant-combinator",
	name = name,
	activity_led_light_offsets = {{0,0},{0,0},{0,0},{0,0}},
	activity_led_sprites = empty_sprite,
	circuit_wire_connection_points = data.raw['constant-combinator']['constant-combinator'].circuit_wire_connection_points,
	circuit_wire_max_distance = 1,
	item_slot_count = 3, -- left, forward, right
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
	corpse = "big-remnants",
	dying_explosion = "big-explosion",
	flags = {
		"placeable-player",
		"player-creation",
		"hide-alt-info"
	},
	minable = {
		mining_time = 0.5,
		result = name
	},
	selection_box = {{-1.5,-1.5},{1.5,1.5}}
}
local bufferbox = {
	collision_box = {{-0.2,-0.2},{0.2,0.2}},
	collision_mask = {},
	corpse = "big-remnants",
	dying_explosion = "big-explosion",
	enable_inventory_bar = false,
	flags = {
		"not-blueprintable",
		"not-deconstructable",
		"no-copy-paste"
	},
	icon = splitter.icon,
	icon_size = splitter.icon_size,
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

local splitteritem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "c[splitter]-c["..name.."]",
	place_result = name,
	stack_size = 20,
	subgroup = "belt",
	type = "item"
}

local ingredients = {
	{"reinforced-iron-plate",2},
	{"rotor",2},
	{"processing-unit",1}
}
local splitterrecipe = {
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
local _group = data.raw['item-subgroup'][splitteritem.subgroup]
local splitterrecipe_undo = {
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
	order = _group.order .. "-" .. splitteritem.order,
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

data:extend({splitter,bufferbox,splitteritem,splitterrecipe,splitterrecipe_undo})
