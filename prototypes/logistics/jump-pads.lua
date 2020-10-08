-- range: 40 tiles ; launch speed = 20m/s = 1 tile / 3 ticks ; launch height = 10m ; flight time = 120 ticks
local name = "jump-pad"
local interface = {
	type = "electric-energy-interface",
	name = name,
	energy_source = {
		type = "electric",
		buffer_capacity = "2MJ",
		usage_priority = "secondary-input",
		drain = "2MW",
		input_flow_limit = "3MW",
		output_flow_limit = "0W"
	},
	pictures = {
		north = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-n.png",
			width = 96,
			height = 96
		},
		east = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-e.png",
			width = 96,
			height = 96
		},
		south = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-s.png",
			width = 96,
			height = 96
		},
		west = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-w.png",
			width = 96,
			height = 96
		}
	},
	render_layer = "floor",
	max_health = 1,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	collision_box = {{-1.2,-1.2},{1.2,1.2}},
	collision_mask = {"object-layer","floor-layer","water-tile"},
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
	radius_visualisation_specification = {
		sprite = {
			filename = "__Satisfactorio__/graphics/particles/"..name.."-landing.png",
			size = {64,64}
		},
		distance = 1.5,
		offset = {0,-40}
	},
	selection_box = {{-1.5,-1.5},{1.5,1.5}}
}
local vehicle = {
	-- a fake car for the player to initiate launch with Enter
	type = "car",
	name = name.."-car",
	animation = {
		direction_count = 1,
		filename = "__core__/graphics/empty.png",
		width = 1,
		height = 1
	},
	braking_power = "200kW",
	burner = {
		effectivity = 1,
		fuel_category = "chemical",
		fuel_inventory_size = 0,
		render_no_power_icon = false
	},
	consumption = "1W",
	effectivity = 0.5,
	weight = 1,
	braking_force = 1,
	friction_force = 1,
	energy_per_hit_point = 1,
	inventory_size = 0,
	rotation_speed = 0,
	max_health = 1,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	collision_box = {{-1.2,-1.2},{1.2,1.2}},
	collision_mask = {"object-layer","floor-layer","water-tile"},
	selection_box = {{-1.5,-1.5},{1.5,1.5}},
	selection_priority = 40,
	minable = {
		mining_time = 1,
		result = name
	},
	flags = {
		"not-on-map",
		"no-automated-item-removal",
		"no-automated-item-insertion",
		"hidden"
	}
}

local item = {
	type = "item",
	name = name,
	icon = interface.icon,
	icon_size = 64,
	stack_size = 1,
	subgroup = "transport-player",
	order = "a[jumping]-a["..name.."]",
	place_result = name
}
local ingredients = {
	{"rotor",2},
	{"iron-plate",15},
	{"copper-cable",10}
}
local recipe = {
	type = "recipe",
	name = name,
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
local undo = {
	type = "recipe",
	name = name.."-undo",
	localised_name = {"recipe-name.dismantle",{"item-name."..name}},
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
	always_show_products = true,
	hide_from_stats = true,
	icons = {
		{icon = "__base__/graphics/icons/deconstruction-planner.png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64}
	},
	enabled = false
}
data:extend{interface,vehicle,item,recipe,undo}

name = "u-jelly-landing-pad"
interface = {
	type = "electric-energy-interface",
	name = name,
	energy_source = {
		type = "electric",
		buffer_capacity = "5MJ",
		usage_priority = "secondary-input",
		drain = "5MW",
		input_flow_limit = "6MW",
		output_flow_limit = "0W"
	},
	picture = {
		filename = "__Satisfactorio__/graphics/placeholders/"..name..".png",
		width = 160,
		height = 160
	},
	render_layer = "lower-radius-visualization",
	max_health = 1,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	collision_box = {{-2.2,-2.2},{2.2,2.2}},
	collision_mask = {"object-layer","floor-layer","water-tile"},
	corpse = "big-remnants",
	dying_explosion = "big-explosion",
	flags = {
		"placeable-neutral",
		"placeable-player",
		"player-creation",
		"not-rotatable"
	},
	minable = {
		mining_time = 1,
		result = name
	},
	selection_box = {{-2.5,-2.5},{2.5,2.5}}
}
item = {
	type = "item",
	name = name,
	icon = interface.icon,
	icon_size = 64,
	stack_size = 1,
	subgroup = "transport-player",
	order = "a[jumping]-b["..name.."]",
	place_result = name
}
ingredients = {
	{"rotor",2},
	{"copper-cable",20},
	{"biomass",200}
}
local recipe = {
	type = "recipe",
	name = name,
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
local undo = {
	type = "recipe",
	name = name.."-undo",
	localised_name = {"recipe-name.dismantle",{"item-name."..name}},
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
	always_show_products = true,
	hide_from_stats = true,
	icons = {
		{icon = "__base__/graphics/icons/deconstruction-planner.png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64}
	},
	enabled = false
}
data:extend{interface,item,recipe,undo}

data:extend{
	{
		type = "sound",
		name = "jump-pad-launch",
		filename = "__base__/sound/fight/artillery-shoots-1.ogg",
		volume = 0.5
	}
}
