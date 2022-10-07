local placeholder = require("graphics.placeholders.builder")

local name = "biomass-burner-hub"
local sounds = copySoundsFrom(data.raw.furnace["stone-furnace"])
local burner = {
	type = "burner-generator",
	name = name,
	localised_description = {"entity-description.biomass-burner"},
	icon = graphics.."icons/biomass-burner.png",
	icon_size = 64,
	selection_box = {{-1.5,-1.5},{1.5,1.5}},
	collision_box = {{-1.2,-1.2},{1.2,1.2}},
	animation = placeholder().addBox(-1,-1,3,3,{},{}).addIcon(graphics.."icons/biomass-burner.png",64).result(),
	burner = {
		type = "burner",
		fuel_category = "chemical",
		fuel_inventory_size = 1
	},
	energy_source = {
		type = "electric",
		usage_priority = "secondary-output"
	},
	max_power_output = "21000001W",
	open_sound = sounds.open_sound,
	close_sound = sounds.close_sound,
	working_sound = sounds.working_sound,
	flags = {
		"no-automated-item-removal",
		"no-automated-item-insertion",
		"not-on-map"
	},
	max_health = 1
}
local accumulator = {
	type = "electric-energy-interface",
	name = name.."-buffer",
	localised_name = {"entity-name.generator-buffer",{"entity-name."..name}},
	icon = graphics.."icons/biomass-burner.png",
	icon_size = 64,
	selection_box = burner.selection_box,
	selectable_in_game = false,
	collision_box = burner.collision_box,
	picture = empty_graphic,
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

data:extend{burner,accumulator}
