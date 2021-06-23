local name = "nuclear-power-plant"
local boiler = makeAssemblingMachine{
	name = name,
	size = {19,21},
	energy = 2500,
	category = "nuclear-power",
	sounds = copySoundsFrom(data.raw.reactor["nuclear-reactor"]),
	subgroup = "production-power",
	order = "d",
	ingredients = {
		{"concrete",250},
		{"heavy-modular-frame",25},
		{"supercomputer",5},
		{"copper-cable",100},
		{"alclad-aluminium-sheet",100}
	},
	pipe_connections = {
		filter = "water",
		input = {{0,999}}
	}
}
boiler.machine.energy_source = {
	type = "burner",
	fuel_category = "nuclear",
	fuel_inventory_size = 1
}
boiler.machine.fixed_recipe = name.."-steam"

local steaming = {
	type = "recipe",
	name = name.."-steam",
	localised_name = {"recipe-name.nuclear-power"},
	localised_description = {"recipe-description.nuclear-power"},
	icon = "__Satisfactorio__/graphics/icons/power.png",
	icon_size = 64,
	subgroup = "fluid-fuel",
	ingredients = {{type="fluid", name="water", amount=5}},
	results = {
		{type="item", name="uranium-waste", amount=0}, -- managed manually by script
		{type="item", name="plutonium-waste", amount=0} -- managed manually by script
	},
	energy_required = 1,
	category = "nuclear-power",
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
		buffer_capacity = "2500000001W",
		usage_priority = "primary-output",
		drain = "0W"
	},
	energy_production = "2500000001W",
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
