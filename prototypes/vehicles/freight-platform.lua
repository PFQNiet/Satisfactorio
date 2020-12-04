local empty_sprite = {
	filename = "__core__/graphics/empty.png",
	width = 1,
	height = 1
}

local name = "freight-platform"
local base = {
	type = "electric-energy-interface",
	name = name,
	energy_source = {
		type = "electric",
		buffer_capacity = "50MW",
		usage_priority = "secondary-input",
		drain = "0W"
	},
	energy_usage = "50MW",
	pictures = {
		north = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-n.png",
			size = {448,224}
		},
		east = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-e.png",
			size = {224,448}
		},
		south = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-s.png",
			size = {448,224}
		},
		west = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-w.png",
			size = {224,448}
		}
	},
	max_health = 1,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	render_layer = "lower-object",
	collision_box = {{-6.7,-3.2},{6.7,3.2}},
	collision_mask = {"player-layer"}, -- object collision will be checked by script but this covers most cases
	corpse = "big-remnants",
	dying_explosion = "big-explosion",
	flags = {
		"placeable-player",
		"player-creation"
	},
	minable = {
		mining_time = 1,
		result = name
	},
	remove_decoratives = "true",
	selection_box = {{-7,-3.5},{7,3.5}},
	selection_priority = 40
}

local walkable = {
	type = "constant-combinator",
	name = name.."-walkable",
	activity_led_light_offsets = {{0,0},{0,0},{0,0},{0,0}},
	activity_led_sprites = empty_sprite,
	circuit_wire_connection_points = data.raw['constant-combinator']['constant-combinator'].circuit_wire_connection_points,
	item_slot_count = 0,
	sprites = empty_sprite,
	max_health = 1,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	collision_box = {{-2.7,-3.2},{2.7,3.2}},
	collision_mask = {"object-layer", "floor-layer", "water-tile"},
	corpse = "big-remnants",
	dying_explosion = "big-explosion",
	flags = {
		"placeable-player",
		"placeable-off-grid",
		"player-creation",
		"not-blueprintable",
		"no-copy-paste"
	},
	minable = nil,
	selection_box = {{-3,-3.5},{3,3.5}},
	selection_priority = 30
}
local collision = {
	type = "constant-combinator",
	name = name.."-collision",
	activity_led_light_offsets = {{0,0},{0,0},{0,0},{0,0}},
	activity_led_sprites = empty_sprite,
	circuit_wire_connection_points = data.raw['constant-combinator']['constant-combinator'].circuit_wire_connection_points,
	item_slot_count = 0,
	sprites = empty_sprite,
	max_health = 1,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	collision_box = {{-2.7,-3.2},{2.7,3.2}},
	corpse = "big-remnants",
	dying_explosion = "big-explosion",
	flags = {
		"placeable-player",
		"placeable-off-grid",
		"player-creation",
		"not-blueprintable",
		"no-copy-paste"
	},
	minable = nil,
	selection_box = {{-3,-3.5},{3,3.5}},
	selection_priority = 30
}

local storage = {
	collision_box = {{-2.2,-2.2},{2.2,2.2}},
	collision_mask = {},
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
	open_sound = {
		filename = "__base__/sound/metallic-chest-open.ogg",
		volume = 0.5
	},
	close_sound = {
		filename = "__base__/sound/metallic-chest-close.ogg",
		volume = 0.5
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
	selection_box = {{-2.5,-2.5},{2.5,2.5}},
	type = "container"
}

local item = {
	icons = {
		{icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/hub-parts.png", icon_size = 64, scale = 0.25, shift = {-8,8}}
	},
	name = name,
	order = "a[train-system]-b[platforms]-b["..name.."]",
	place_result = name,
	stack_size = 1,
	subgroup = "train-transport",
	type = "item"
}

local ingredients = {
	{"heavy-modular-frame",6},
	{"computer",2},
	{"concrete",50},
	{"copper-cable",25},
	{"motor",5}
}
local recipe = {
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
local _group = data.raw['item-subgroup'][item.subgroup]
local recipe_undo = {
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
	order = _group.order .. "-" .. item.order,
	allow_decomposition = false,
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	icons = {
		{icon = "__base__/graphics/icons/deconstruction-planner.png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/hub-parts.png", icon_size = 64, scale = 0.25, shift = {-8,8}}
	},
	enabled = false
}

data:extend({base,walkable,collision,storage,item,recipe,recipe_undo})
