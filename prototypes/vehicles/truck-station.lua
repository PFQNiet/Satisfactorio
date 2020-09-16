-- base entity is a constant combinator just so it can be rotated and stuff without any extra shenanigans
-- an electric-energy-interface manages power consumption
-- station itself is a pair of storage chests: one with a single slot and single input for fuel, and one with 48 slots, two inputs and two outputs
-- building itself is 8x11 so the layout can be |F-I-I-O-O|
-- docking area is 8x8
-- entity.get_inventory(defines.inventory.fuel).can_insert(itemstack) to see if it's insertable at all
-- entity.get_inventory(defines.inventory.fuel).get_insertable_count(itemname) to determine how many can be inserted
-- then insert that much and remove the same amount from the fuel supply
-- The storage part can just find_empty_stack() and just transfer a stack from the storage to the car or vice-versa

local name = "truck-station"
local empty_sprite = {
	filename = "__core__/graphics/empty.png",
	width = 1,
	height = 1
}

local base = {
	type = "constant-combinator",
	name = name,
	activity_led_light_offsets = {{0,0},{0,0},{0,0},{0,0}},
	activity_led_sprites = empty_sprite,
	circuit_wire_connection_points = data.raw['constant-combinator']['constant-combinator'].circuit_wire_connection_points,
	item_slot_count = 0,
	sprites = {
		north = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-n.png",
			size = {352,256}
		},
		east = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-e.png",
			size = {256,352}
		},
		south = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-s.png",
			size = {352,256}
		},
		west = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-w.png",
			size = {256,352}
		}
	},
	radius_visualisation_specification = {
		sprite = {
			filename = "__Satisfactorio__/graphics/particles/"..name.."-zone.png",
			size = {256,256}
		},
		distance = 4,
		offset = {-0.5,-8}
	},
	max_health = 1,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	collision_box = {{-5.2,-3.7},{5.2,3.7}},
	corpse = "big-remnants",
	dying_explosion = "big-explosion",
	flags = {
		"placeable-neutral",
		"placeable-player",
		"player-creation"
	},
	minable = {
		mining_time = 1,
		result = name
	},
	selection_box = {{-5.5,-4},{5.5,4}},
	selection_priority = 40
}

local storage = {
	collision_box = {{-3.2,-3.2},{3.2,3.2}},
	corpse = "big-remnants",
	dying_explosion = "big-explosion",
	enable_inventory_bar = false,
	flags = {
		"placeable-neutral",
		"placeable-player",
		"player-creation",
		"not-blueprintable",
		"no-copy-paste"
	},
	icon = base.icon,
	icon_size = base.icon_size,
	inventory_size = 48,
	max_health = 1,
	minable = {
		mining_time = 1,
		result = name
	},
	name = name.."-box",
	picture = empty_sprite,
	placeable_by = {item=name,count=1},
	selection_box = {{-3.5,-3.5},{3.5,3.5}},
	type = "container"
}
local fuelbox = {
	collision_box = {{-0.2,-0.2},{0.2,0.2}},
	corpse = "big-remnants",
	dying_explosion = "big-explosion",
	enable_inventory_bar = false,
	flags = {
		"placeable-neutral",
		"placeable-player",
		"player-creation",
		"not-blueprintable",
		"no-copy-paste"
	},
	icon = base.icon,
	icon_size = base.icon_size,
	inventory_size = 1,
	max_health = 1,
	minable = {
		mining_time = 1,
		result = name
	},
	name = name.."-fuelbox",
	picture = empty_sprite,
	placeable_by = {item=name,count=1},
	selection_box = {{-0.5,-0.5},{0.5,0.5}},
	type = "container"
}

local energy = {
	energy_source = {
		type = "electric",
		buffer_capacity = "20MJ",
		usage_priority = "secondary-input",
		drain = "0W",
		input_flow_limit = "20MW"
	},
	picture = empty_sprite,
	icon = base.icon,
	icon_size = base.icon_size,
	name = name.."-energy",
	type = "electric-energy-interface",
	collision_box = {{-5.2,-3.7},{5.2,3.7}},
	selection_box = {{-5.5,-4},{5.5,4}},
	max_health = 1,
	selection_priority = 30
}

local stationitem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "t-s-a["..name.."]",
	place_result = name,
	stack_size = 1,
	subgroup = "transport",
	type = "item"
}

local ingredients = {
	{"modular-frame",15},
	{"rotor",20},
	{"copper-cable",50}
}
local stationrecipe = {
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
local _group = data.raw['item-subgroup'][stationitem.subgroup]
local stationrecipe_undo = {
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
	order = _group.order .. "-" .. stationitem.order,
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

data:extend({base,storage,fuelbox,energy,stationitem,stationrecipe,stationrecipe_undo})
