-- range: 40 tiles ; launch speed = 20m/s = 1 tile / 3 ticks ; launch height = 10m ; flight time = 120 ticks
local name = "jump-pad"
local interface = {
	type = "electric-energy-interface",
	name = name,
	energy_source = {
		type = "electric",
		buffer_capacity = "2MW",
		input_flow_limit = "2MW",
		usage_priority = "secondary-input",
		drain = "0W"
	},
	energy_usage = "2MW",
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
	flags = {
		"placeable-player",
		"player-creation"
	},
	minable = {
		mining_time = 0.5,
		result = name
	},
	selection_box = {{-1.5,-1.5},{1.5,1.5}}
}
local vehicle = {
	-- a fake car for the player to initiate launch with Enter
	type = "car",
	name = name.."-car",
	localised_name = {"entity-name."..name},
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
	-- allow_passengers = false,
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
	selectable_in_game = false,
	minable = {
		mining_time = 0.5,
		result = name
	},
	flags = {
		"not-on-map",
		"no-automated-item-removal",
		"no-automated-item-insertion",
		"hidden"
	}
}
local vehicle2 = {
	-- a fake car that looks like the player, just without a shadow attached
	type = "car",
	name = name.."-flying",
	localised_name = {"entity-name."..name},
	animation = {
		layers = {
			table.deepcopy(data.raw.character.character.animations[1].running.layers[1]),
			table.deepcopy(data.raw.character.character.animations[1].running.layers[2])
		}
	},
	braking_power = "200kW",
	burner = {
		effectivity = 1,
		fuel_category = "chemical",
		fuel_inventory_size = 0,
		render_no_power_icon = false
	},
	-- allow_passengers = false,
	light = table.deepcopy(data.raw.character.character.light),
	consumption = "1W",
	effectivity = 1,
	weight = 1,
	braking_force = 1,
	friction_force = 1,
	energy_per_hit_point = 1,
	inventory_size = 0,
	rotation_speed = 0,
	max_health = 1,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	collision_box = {{-0.2,-0.2},{0.2,0.2}},
	collision_mask = {},
	selection_box = {{-0.5,-0.5},{0.5,0.5}},
	render_layer = "air-object",
	selectable_in_game = false,
	flags = {
		"not-on-map",
		"placeable-off-grid",
		"no-automated-item-removal",
		"no-automated-item-insertion",
		"hidden"
	}
}
local shadow = {
	type = "sprite",
	-- name = to be set in loop
	filename = "__base__/graphics/entity/character/level1_running_shadow-1.png",
	draw_as_shadow = true,
	width = 96,
	height = 34,
	x = 0,
	-- y = to be set in loop,
	shift = {0.9375,0.0625},
	hr_version = {
		filename = "__base__/graphics/entity/character/hr-level1_running_shadow-1.png",
		draw_as_shadow = true,
		width = 190,
		height = 68,
		x = 0,
		-- y = to be set in loop,
		shift = {0.9375,0.78125},
		scale = 0.5
	}
}
for i,dir in pairs({defines.direction.north, defines.direction.east, defines.direction.south, defines.direction.west}) do
	local clone = table.deepcopy(shadow)
	clone.name = name.."-flying-shadow-"..dir
	clone.y = clone.height*(i-1)*2
	clone.hr_version.y = clone.hr_version.height*(i-1)*2
	data:extend{clone}
end

local item = {
	type = "item",
	name = name,
	icon = interface.icon,
	icon_size = 64,
	stack_size = 50,
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
	localised_name = {"recipe-name.dismantle",{"entity-name."..name}},
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
data:extend{interface,vehicle,vehicle2,item,recipe,undo}

name = "u-jelly-landing-pad"
interface = {
	type = "electric-energy-interface",
	name = name,
	energy_source = {
		type = "electric",
		buffer_capacity = "5MW",
		input_flow_limit = "5MW",
		usage_priority = "secondary-input",
		drain = "0W"
	},
	energy_usage = "5MW",
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
	flags = {
		"placeable-player",
		"player-creation",
		"not-rotatable"
	},
	minable = {
		mining_time = 0.5,
		result = name
	},
	selection_box = {{-2.5,-2.5},{2.5,2.5}}
}
item = {
	type = "item",
	name = name,
	icon = interface.icon,
	icon_size = 64,
	stack_size = 50,
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
	localised_name = {"recipe-name.dismantle",{"entity-name."..name}},
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
		filename = "__base__/sound/fight/rocket-launcher.ogg",
		volume = 0.5
	},
	{
		type = "custom-input",
		name = "tile-bigger",
		key_sequence = "",
		linked_game_control = "larger-terrain-building-area",
		consuming = "none",
		action = "lua"
	},
	{
		type = "custom-input",
		name = "tile-smaller",
		key_sequence = "",
		linked_game_control = "smaller-terrain-building-area",
		consuming = "none",
		action = "lua"
	},
	{
		type = "sprite",
		name = "jump-pad-landing",
		filename = "__Satisfactorio__/graphics/particles/jump-pad-landing.png",
		size = {64,64}
	}
}
