local placeholder = require("graphics.placeholders.builder")

local name = "geothermal-generator"
local animation = placeholder().addBox(-4,-4,9,9,{},{}).addIcon(graphics.."icons/"..name..".png",128).result()
local mask = table.deepcopy(animation)
for _,layer in pairs(mask.layers) do layer.tint = {0.5,0.5,0.5,0.5} end
table.insert(mask.layers, {
	filename = graphics.."placeholders/geyser.png",
	width = 160,
	height = 160
})
local miner = {
	type = "mining-drill",
	name = name,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	animations = mask,
	selection_box = {{-4.5,-4.5},{4.5,4.5}},
	collision_box = {{-4.2,-4.2},{4.2,4.2}},
	collision_mask = {"item-layer","object-layer","player-layer"},
	energy_source = {type = "void"},
	energy_usage = "200MW",
	flags = {
		"placeable-player",
		"player-creation",
		"not-rotatable"
	},
	max_health = 1,
	mining_speed = 1,
	resource_categories = {"geothermal"},
	resource_searching_radius = 0.49,
	vector_to_place_result = {0,0}
}
local interface = {
	type = "electric-energy-interface",
	name = name.."-eei",
	localised_name = {"entity-name."..name},
	localised_description = {"entity-description."..name},
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	subgroup = "placeholder-buildings",
	selection_box = {{-4.5,-4.5},{4.5,4.5}},
	collision_box = {{-4.2,-4.2},{4.2,4.2}},
	energy_source = {
		type = "electric",
		buffer_capacity = "200000001W",
		usage_priority = "primary-output"
	},
	energy_production = "200000001W", -- produce 1 extra watt for the buffer
	animation = animation,
	flags = {
		"not-rotatable"
	},
	max_health = 1,
	minable = {
		mining_time = 0.5,
		result = name
	},
	placeable_by = {item=name,count=1}
}
local accumulator = {
	type = "electric-energy-interface",
	name = name.."-buffer",
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	localised_name = {"entity-name.generator-buffer",{"entity-name."..name}},
	selection_box = interface.selection_box,
	selectable_in_game = false,
	collision_box = interface.collision_box,
	collision_mask = {},
	picture = {
		filename = "__core__/graphics/empty.png",
		size = {1,1}
	},
	energy_source = {
		type = "electric",
		buffer_capacity = "1W",
		usage_priority = "secondary-input"
	},
	energy_usage = "1W",
	flags = {
		"not-on-map"
	},
	max_health = 1
}

local mineritem = {
	type = "item",
	name = name,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	place_result = name,
	stack_size = 50,
	subgroup = "production-power",
	order = "e["..name.."]"
}

local minerrecipe = makeBuildingRecipe{
	name = name,
	ingredients = {
		{"supercomputer",8},
		{"heavy-modular-frame",16},
		{"high-speed-connector",16},
		{"copper-sheet",40},
		{"rubber",80}
	},
	result = name
}

data:extend{miner,interface,accumulator,mineritem,minerrecipe}
