local placeholder = require("graphics.placeholders.builder")

assert(train_platform_layer ~= nil, "Train station must be defined before freight platform, as it uses its collision mask")

local name = "empty-platform"
local base = {
	type = "electric-energy-interface",
	name = name,
	energy_source = {
		type = "electric",
		buffer_capacity = "0J",
		usage_priority = "secondary-input",
		drain = "0W",
		input_flow_limit = "0W",
		output_flow_limit = "0W",
		render_no_power_icon = false,
		render_no_network_icon = false
	},
	pictures = placeholder().fourway().addBox(-6.5,-3,6,7,{},{}).addBox(1.5,-3,6,7,{},{}).addIcon(graphics.."icons/"..name..".png",64,{4,0}).result(),
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
	open_sound = basesounds.machine_open,
	close_sound = basesounds.machine_close,
	selection_box = {{-7,-3.5},{7,3.5}}
}

local item = {
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "a[train-system]-b[platforms]-d["..name.."]",
	place_result = name,
	stack_size = 50,
	subgroup = "train-transport",
	type = "item"
}

local recipe = makeBuildingRecipe{
	name = name,
	ingredients = {
		{"heavy-modular-frame",6},
		{"concrete",50}
	},
	result = name
}

data:extend{base,item,recipe}
