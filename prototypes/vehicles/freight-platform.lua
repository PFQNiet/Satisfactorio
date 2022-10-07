local placeholder = require("graphics.placeholders.builder")

assert(train_platform_layer ~= nil, "Train station must be defined before freight platform, as it uses its collision mask")

local sounds = copySoundsFrom(data.raw.container["steel-chest"])
local name = "freight-platform"
local base = {
	type = "electric-energy-interface",
	name = name,
	energy_source = {
		type = "electric",
		buffer_capacity = "50MW",
		input_flow_limit = "50MW",
		usage_priority = "secondary-input",
		drain = "0W"
	},
	energy_usage = "50MW",
	pictures = placeholder().fourway().addBox(-6.5,-3,6,7,{},{}).addBox(1.5,-3,6,7,{{6.5,-1},{6.5,1}},{{6.5,-2},{6.5,2}}).addIcon(graphics.."icons/"..name..".png",64,{4,0}).result(),
	max_health = 1,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	render_layer = "lower-object",
	collision_box = {{-6.7,-3.2},{6.7,3.2}},
	collision_mask = {train_platform_layer},
	flags = {
		"placeable-player",
		"player-creation"
	},
	minable = {
		mining_time = 0.5,
		result = name
	},
	remove_decoratives = "true",
	open_sound = sounds.open_sound,
	close_sound = sounds.close_sound,
	selection_box = {{-7,-3.5},{7,3.5}},
	selection_priority = 49
}

local walkable = {
	type = "simple-entity-with-owner",
	name = "platform-walkable",
	picture = empty_graphic,
	max_health = 1,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	collision_box = {{-2.7,-3.2},{2.7,3.2}},
	collision_mask = {"object-layer", "floor-layer", "water-tile"},
	flags = {
		"placeable-off-grid"
	},
	selection_box = {{-3,-3.5},{3,3.5}},
	selectable_in_game = false
}
local collision = {
	type = "simple-entity-with-owner",
	name = "platform-collision",
	picture = empty_graphic,
	max_health = 1,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	collision_box = {{-2.7,-3.2},{2.7,3.2}},
	flags = {
		"placeable-off-grid"
	},
	selection_box = {{-3,-3.5},{3,3.5}},
	selectable_in_game = false
}

local storage = {
	type = "container",
	name = name.."-box",
	localised_name = {"entity-name."..name},
	icon = base.icon,
	icon_size = base.icon_size,
	open_sound = sounds.open_sound,
	close_sound = sounds.close_sound,
	collision_box = {{-2.2,-2.2},{2.2,2.2}},
	collision_mask = {},
	flags = {"not-on-map"},
	inventory_size = 48,
	enable_inventory_bar = false,
	max_health = 1,
	picture = empty_graphic,
	selection_box = {{-2.5,-2.5},{2.5,2.5}},
	selectable_in_game = false,
	scale_info_icons = true
}

local item = {
	icons = {
		{icon = graphics.."icons/"..name..".png", icon_size = 64},
		{icon = graphics.."icons/hub-parts.png", icon_size = 64, scale = 0.25, shift = {-8,8}}
	},
	name = name,
	order = "a[train-system]-b[platforms]-b["..name.."]",
	place_result = name,
	stack_size = 50,
	subgroup = "train-transport",
	type = "item"
}

local recipe = makeBuildingRecipe{
	name = name,
	ingredients = {
		{"heavy-modular-frame",6},
		{"computer",2},
		{"concrete",50},
		{"copper-cable",25},
		{"motor",5}
	},
	result = name
}

data:extend{base,walkable,collision,storage,item,recipe}
