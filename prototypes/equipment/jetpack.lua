local name = "jetpack"
local item = {
	type = "armor",
	name = name,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	infinite = true,
	order = "s-d["..name.."]",
	subgroup = "armor",
	stack_size = 1
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
		"placeable-off-grid",
		"no-automated-item-removal",
		"no-automated-item-insertion",
		"hidden"
	},
	equipment_grid = name
}
local grid = {
	type = "equipment-grid",
	name = name,
	locked = true,
	width = 1,
	height = 1,
	equipment_categories = {name}
}
local category = {
	type = "equipment-category",
	name = name
}
local fakeitem = {
	type = "item",
	name = name.."-equipment",
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	stack_size = 1,
	flags = {"hidden"},
	place_as_equipment_result = name.."-equipment"
}
local fakeequip = {
	type = "battery-equipment",
	name = name.."-equipment",
	sprite = {
		filename = "__Satisfactorio__/graphics/icons/"..name..".png",
		size = {64,64}
	},
	categories = {name},
	energy_source = {
		type = "electric",
		usage_priority = "secondary-output",
		buffer_capacity = (6*60).."MJ" -- 1MJ/tick
	},
	shape = {
		width = 1,
		height = 1,
		type = "full"
	}
}
local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"plastic-bar",50},
		{"electronic-circuit",15},
		{"rubber",50},
		{"copper-cable",25}
	},
	result = name,
	energy_required = 30/4,
	category = "equipment",
	enabled = false
}

data:extend({item, vehicle, grid, category, fakeitem, fakeequip, recipe})

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
