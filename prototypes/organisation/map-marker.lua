local name = "map-marker"

local beacon = {
	type = "constant-combinator",
	name = name,
	activity_led_light_offsets = {{0,0},{0,0},{0,0},{0,0}},
	activity_led_sprites = empty_graphic,
	circuit_wire_connection_points = data.raw['constant-combinator']['constant-combinator'].circuit_wire_connection_points,
	item_slot_count = 0,
	sprites = {
		filename = "__Satisfactorio__/graphics/placeholders/"..name..".png",
		size = {32,32}
	},
	max_health = 1,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	collision_box = {{-0.2,-0.2},{0.2,0.2}},
	flags = {
		"placeable-player",
		"player-creation"
	},
	open_sound = basesounds.machine_open,
	close_sound = basesounds.machine_close,
	minable = {
		mining_time = 0.5,
		result = name
	},
	selection_box = {{-0.5,-0.5},{0.5,0.5}}
}

local beaconitem = {
	type = "item",
	name = name,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	place_result = name,
	stack_size = 100,
	subgroup = "logistics-observation",
	order = "e["..name.."]"
}

local beaconrecipe = { -- in Manufacturer
	name = name,
	type = "recipe",
	ingredients = {
		{"iron-plate",3},
		{"iron-rod",1},
		{"wire",15},
		{"copper-cable",2}
	},
	result = name,
	energy_required = 8,
	category = "manufacturing",
	enabled = false
}
copyToHandcraft(beaconrecipe, 2, true)

data:extend({beacon,beaconitem,beaconrecipe})
