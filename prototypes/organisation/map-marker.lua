local name = "map-marker"
local empty_sprite = {
	filename = "__core__/graphics/empty.png",
	width = 1,
	height = 1
}

local beacon = {
	type = "constant-combinator",
	name = name,
	activity_led_light_offsets = {{0,0},{0,0},{0,0},{0,0}},
	activity_led_sprites = empty_sprite,
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
	open_sound = {
		filename = "__base__/sound/machine-open.ogg",
		volume = 0.5
	},
	close_sound = {
		filename = "__base__/sound/machine-close.ogg",
		volume = 0.5
	},
	minable = {
		mining_time = 1,
		result = name
	},
	selection_box = {{-0.5,-0.5},{0.5,0.5}}
}

local beaconitem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "e["..name.."]",
	place_result = name,
	stack_size = 100,
	subgroup = "logistics-observation",
	type = "item"
}

local ingredients = {
	{"iron-plate",3},
	{"iron-stick",1},
	{"wire",15},
	{"copper-cable",2}
}
local beaconrecipe1 = { -- by hand in Equipment Workshop
	name = name.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 1,
	category = "equipment",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	hide_from_player_crafting = true,
	enabled = false
}
local beaconrecipe2 = { -- in Manufaturer
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 8,
	category = "manufacturing",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	enabled = false
}

data:extend({beacon,beaconitem,beaconrecipe1,beaconrecipe2})
