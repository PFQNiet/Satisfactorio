local name = "hover-pack"
local item = {
	type = "armor",
	name = name,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	infinite = true,
	order = "e["..name.."]",
	subgroup = "armor",
	stack_size = 1
}
local vehicle = {
	type = "car",
	name = name.."-flying",
	localised_name = {"item-name."..name},
	animation = {
		layers = {
			table.deepcopy(data.raw.character.character.animations[1].idle.layers[1]),
			table.deepcopy(data.raw.character.character.animations[1].idle.layers[2])
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
	max_health = 100,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	collision_box = {{-0.2,-0.2},{0.2,0.2}},
	-- collision_mask = {},
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
local interface = {
	type = "electric-energy-interface",
	name = name.."-eei",
	localised_name = {"entity-name.generator-buffer",{"item-name."..name}},
	energy_source = {
		type = "electric",
		render_no_power_icon = false,
		render_no_network_icon = false,
		buffer_capacity = "100MW",
		input_flow_limit = "100MW",
		usage_priority = "secondary-input",
		drain = "0W"
	},
	energy_usage = "100MW",
	picture = {
		filename = "__core__/graphics/empty.png",
		size = {1,1}
	},
	max_health = 1,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	collision_box = {{-16,-16},{16,16}},
	collision_mask = {},
	flags = {
		"not-on-map",
		"placeable-off-grid"
	},
	selection_box = {{-16,-16},{16,16}},
	selectable_in_game = false
}
local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"motor",8},
		{"heavy-modular-frame",4},
		{"computer",8},
		{"alclad-aluminium-sheet",40}
	},
	result = name,
	energy_required = 30/4,
	category = "equipment",
	enabled = false
}

data:extend({item, vehicle, interface, recipe})

local shadow = {
	type = "sprite",
	-- name = to be set in loop
	filename = "__base__/graphics/entity/character/level1_idle_shadow.png",
	draw_as_shadow = true,
	width = 84,
	height = 40,
	x = 0,
	-- y = to be set in loop,
	shift = {0.96875,0.03125},
	hr_version = {
		filename = "__base__/graphics/entity/character/hr-level1_idle_shadow.png",
		draw_as_shadow = true,
		width = 164,
		height = 78,
		x = 0,
		-- y = to be set in loop,
		shift = {0.953125,0.015625},
		scale = 0.5
	}
}
for i,dir in pairs({
	defines.direction.north, defines.direction.northeast, defines.direction.east, defines.direction.southeast,
	defines.direction.south, defines.direction.southwest, defines.direction.west, defines.direction.northwest
}) do
	local clone = table.deepcopy(shadow)
	clone.name = name.."-flying-shadow-"..dir
	clone.y = clone.height*(i-1)
	clone.hr_version.y = clone.hr_version.height*(i-1)
	data:extend{clone}
end
