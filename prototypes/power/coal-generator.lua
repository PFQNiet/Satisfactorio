local name = "coal-generator"
local boiler = makeAssemblingMachine{
	name = name,
	size = {5,12},
	energy = 75,
	category = "coal-generator",
	sounds = copySoundsFrom(data.raw.generator["steam-engine"]),
	subgroup = "production-power",
	order = "b",
	ingredients = {
		{"reinforced-iron-plate",20},
		{"rotor",10},
		{"copper-cable",30}
	},
	pipe_connections = {
		filter = "water",
		input = {{-1,999}}
	}
}
boiler.machine.energy_source = {
	type = "burner",
	fuel_category = "carbon",
	fuel_inventory_size = 1
}
boiler.machine.fixed_recipe = name.."-steam"

local steaming = {
	type = "recipe",
	name = name.."-steam",
	localised_name = {"recipe-name."..name.."-steam"},
	localised_description = {"recipe-description."..name.."-steam"},
	icon = "__Satisfactorio__/graphics/icons/power.png",
	icon_size = 64,
	subgroup = "fluid-fuel",
	ingredients = {{type="fluid", name="water", amount=0.75}},
	results = {},
	energy_required = 1,
	category = name,
	show_amount_in_title = false,
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_player_crafting = true
}

local interface = {
	type = "electric-energy-interface",
	name = name.."-eei",
	localised_name = {"entity-name."..name},
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	selection_box = boiler.machine.selection_box,
	selectable_in_game = false,
	collision_box = boiler.machine.collision_box,
	collision_mask = {},
	energy_source = {
		type = "electric",
		buffer_capacity = "75000001W",
		usage_priority = "primary-output",
		drain = "0W"
	},
	energy_production = "75000001W",
	picture = empty_graphic,
	max_health = 1,
	flags = {
		"not-on-map"
	}
}
local accumulator = {
	type = "electric-energy-interface",
	name = name.."-buffer",
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	localised_name = {"entity-name.generator-buffer",{"entity-name."..name}},
	selection_box = boiler.machine.selection_box,
	selectable_in_game = false,
	collision_box = boiler.machine.collision_box,
	collision_mask = {},
	energy_source = {
		type = "electric",
		buffer_capacity = "1W",
		usage_priority = "secondary-input"
	},
	energy_usage = "1W",
	picture = empty_graphic,
	max_health = 1,
	flags = {
		"not-on-map"
	}
}

data:extend{steaming, interface, accumulator}
