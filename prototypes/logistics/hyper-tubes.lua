local placeholder = require("graphics.placeholders.builder")
-- fake fluid to filter the hyper-tube "fluid box"
local name = "hyper-tube"
data:extend{
	{
		type = "fluid",
		name = name,
		hidden = true,
		icon = "__core__/graphics/empty.png",
		icon_size = 1,
		default_temperature = 15,
		max_temperature = 15,
		base_color = {1,1,1},
		flow_color = {1,1,1}
	}
}

local entity = table.deepcopy(data.raw.pipe.pipe)
entity.name = name
entity.minable.result = name
entity.icon = graphics.."icons/"..name..".png"
entity.icon_mipmaps = 0
entity.max_health = 1
for _,pic in pairs(entity.pictures) do
	pic.tint = {1,0.8,0}
	if pic.hr_version then
		pic.hr_version.tint = {1,0.8,0}
	end
end
-- no windows allowed!
entity.pictures.straight_horizontal_window = entity.pictures.straight_horizontal
entity.pictures.straight_vertical_window = entity.pictures.straight_vertical
entity.fluid_box.filter = name
entity.fast_replaceable_group = "hyper-tube"

local item = {
	type = "item",
	name = name,
	icon = entity.icon,
	icon_size = 64,
	stack_size = 50,
	subgroup = "transport-player",
	order = "b[hypertube]-b["..name.."]",
	place_result = name
}
local recipe = makeBuildingRecipe{
	name = name,
	ingredients = {
		{"copper-sheet",1},
		{"steel-pipe",1}
	},
	result = name
}
data:extend{entity,item,recipe}

-- Underground
name = "underground-hyper-tube"
entity = table.deepcopy(data.raw["pipe-to-ground"]["pipe-to-ground"])
entity.name = name
entity.minable.result = name
entity.icon = graphics.."icons/"..name..".png"
entity.icon_mipmaps = 0
entity.max_health = 1
for _,pic in pairs(entity.pictures) do
	pic.tint = {1,0.8,0}
	if pic.hr_version then
		pic.hr_version.tint = {1,0.8,0}
	end
end
entity.fluid_box.pipe_connections[2].max_underground_distance = 20
entity.fluid_box.filter = "hyper-tube"
entity.fast_replaceable_group = "hyper-tube"

item = {
	type = "item",
	name = name,
	icon = entity.icon,
	icon_size = 64,
	stack_size = 50,
	subgroup = "transport-player",
	order = "b[hypertube]-c["..name.."]",
	place_result = name
}
recipe = makeBuildingRecipe{
	name = name,
	ingredients = {
		{"copper-sheet",8},
		{"steel-pipe",8}
	},
	result = name
}
data:extend{entity,item,recipe}

-- Entrance
name = "hyper-tube-entrance"
entity = table.deepcopy(data.raw.pump.pump)
entity.name = name
entity.minable.result = name
entity.icon = graphics.."icons/"..name..".png"
entity.icon_mipmaps = 0
entity.max_health = 1
entity.energy_source.drain = "10MW"
entity.energy_source.buffer_capacity = "10MW"
entity.energy_usage = "10MW"
entity.glass_pictures = nil
entity.animations = placeholder().fourway().addBox(0,0,1,1,{},{}).addIcon(graphics.."icons/"..name..".png",32).result()
entity.fluid_animations = nil
entity.pumping_speed = 0
entity.fluid_wagon_connector_frame_count = 0
entity.fluid_box = {
	pipe_connections = {
		{
			position = {0,-1},
			type = "output"
		}
	},
	filter = "hyper-tube"
}
entity.collision_box = {{-0.5,-0.3},{0.3,0.3}}
entity.collision_mask = {"item-layer", "object-layer", "water-tile"}
entity.selection_box = {{-0.5,-0.5},{0.5,0.5}}
entity.fast_replaceable_group = "hyper-tube"

item = {
	type = "item",
	name = name,
	icon = entity.icon,
	icon_size = 64,
	stack_size = 50,
	subgroup = "transport-player",
	order = "b[hypertube]-a["..name.."]",
	place_result = name
}
recipe = makeBuildingRecipe{
	name = name,
	ingredients = {
		{"encased-industrial-beam",4},
		{"rotor",4},
		{"steel-pipe",10}
	},
	result = name
}
data:extend{entity,item,recipe}

local vehicle = {
	-- a fake car for the player to enter the tube
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
	icon = item.icon,
	icon_size = item.icon_size,
	collision_box = entity.collision_box,
	selection_box = entity.selection_box,
	selection_priority = 40,
	selectable_in_game = false,
	minable = nil,
	flags = {
		"not-on-map",
		"placeable-off-grid",
		"no-automated-item-removal",
		"no-automated-item-insertion",
		"hidden"
	}
}
data:extend{vehicle}
