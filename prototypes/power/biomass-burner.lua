local name = "biomass-burner"
local sounds = copySoundsFrom(data.raw.furnace["stone-furnace"])
local burner = {
	type = "burner-generator",
	name = name,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	selection_box = {{-2,-2},{2,2}},
	collision_box = {{-1.7,-1.7},{1.7,1.7}},
	animation = {
		filename = "__Satisfactorio__/graphics/placeholders/"..name..".png",
		size = {128,128},
	},
	burner = {
		type = "burner",
		fuel_category = "chemical",
		fuel_inventory_size = 1
	},
	energy_source = {
		type = "electric",
		usage_priority = "secondary-output"
	},
	max_power_output = "30000001W",
	open_sound = sounds.open_sound,
	close_sound = sounds.close_sound,
	working_sound = sounds.working_sound,
	flags = {
		"placeable-player",
		"player-creation",
		"no-automated-item-removal",
		"no-automated-item-insertion"
	},
	max_health = 1,
	minable = {
		mining_time = 0.5,
		result = name
	}
}
local accumulator = {
	type = "electric-energy-interface",
	name = name.."-buffer",
	localised_name = {"entity-name.generator-buffer",{"entity-name."..name}},
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	selection_box = burner.selection_box,
	selectable_in_game = false,
	collision_box = burner.collision_box,
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

local burneritem = {
	type = "item",
	name = name,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	place_result = name,
	stack_size = 50,
	subgroup = "production-power",
	order = "a["..name.."]"
}

local burnerrecipe = makeBuildingRecipe{
	name = name,
	ingredients = {
		{"iron-plate",15},
		{"iron-rod",15},
		{"wire",25}
	},
	result = name
}

data:extend{burner,accumulator,burneritem,burnerrecipe}
