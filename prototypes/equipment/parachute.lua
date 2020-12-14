local name = "parachute"
local item = {
	type = "armor",
	name = name,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	infinite = true,
	order = "s-a["..name.."]",
	subgroup = "armor",
	stack_size = 50
}
local vehicle = {
	type = "car",
	name = name.."-flying",
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
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	collision_box = {{-0.2,-0.2},{0.2,0.2}},
	collision_mask = {},
	selection_box = {{-0.5,-0.5},{0.5,0.5}},
	render_layer = "air-object",
	selectable_in_game = false,
	flags = {
		"not-on-map",
		"building-direction-8-way",
		"placeable-off-grid",
		"no-automated-item-removal",
		"no-automated-item-insertion",
		"hidden"
	}
}
local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"fabric",10},
		{"copper-cable",5}
	},
	result = name,
	result_count = 5,
	energy_required = 10/4,
	category = "equipment",
	enabled = false
}

data:extend({item, vehicle, recipe})

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
