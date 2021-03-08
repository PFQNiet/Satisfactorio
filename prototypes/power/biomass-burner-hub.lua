local name = "biomass-burner-hub"
local burner = {
	animation = {
		filename = "__Satisfactorio__/graphics/placeholders/"..name..".png",
		size = {96,96},
	},
	collision_box = {{-1.2,-1.2},{1.2,1.2}},
	energy_source = {
		type = "electric",
		usage_priority = "secondary-output"
	},
	burner = {
		type = "burner",
		fuel_category = "chemical",
		fuel_inventory_size = 1
	},
	max_power_output = "20000001W",
	open_sound = {
		filename = "__base__/sound/machine-open.ogg",
		volume = 0.5
	},
	close_sound = {
		filename = "__base__/sound/machine-close.ogg",
		volume = 0.5
	},
	working_sound = data.raw['furnace']['stone-furnace'].working_sound,
	flags = {
		"no-automated-item-removal",
		"no-automated-item-insertion",
		"not-on-map"
	},
	icon = "__Satisfactorio__/graphics/icons/biomass-burner.png",
	icon_size = 64,
	max_health = 1,
	minable = nil,
	name = name,
	selection_box = {{-1.5,-1.5},{1.5,1.5}},
	type = "burner-generator"
}
local accumulator = {
	type = "electric-energy-interface",
	name = name.."-buffer",
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
	collision_box = burner.collision_box,
	flags = {
		"not-on-map"
	},
	icon = "__Satisfactorio__/graphics/icons/biomass-burner.png",
	icon_size = 64,
	max_health = 1,
	selection_box = burner.selection_box,
	selectable_in_game = false
}

data:extend({burner,accumulator})
