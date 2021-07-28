local name = "fuel-generator"

-- There IS an entity type for burning fuel, however it produces variable power for a fixed fluid consumption
-- This entity instead produces fixed power for a variable fluid consumption
local boiler = makeAssemblingMachine{
	name = name,
	type = "furnace", -- allow auto-selection of steaming recipe based on provided fuel
	size = {10,10},
	energy = 150,
	category = "fuel-generator",
	sounds = copySoundsFrom(data.raw["assembling-machine"]["oil-refinery"]),
	subgroup = "production-power",
	order = "c",
	ingredients = {
		{"computer",5},
		{"heavy-modular-frame",10},
		{"motor",15},
		{"rubber",50},
		{"quickwire",50}
	},
	pipe_connections = {
		input = {{0.5,-999}}
	}
}
boiler.machine.energy_source = {type="void"} -- the furnace ingredient becomes the fuel
boiler.machine.animation = {filename = graphics.."placeholders/"..name..".png", size = {10*32,10*32}}
boiler.machine.source_inventory_size = 0
boiler.machine.result_inventory_size = 0
boiler.machine.fluid_boxes[1].base_area = 0.05

local steaming1 = {
	name = name.."-fuel",
	type = "recipe",
	localised_description = {"recipe-description."..name.."-power"},
	icon = graphics.."icons/power.png",
	icon_size = 64,
	subgroup = "fluid-fuel",
	ingredients = {{type="fluid", name="fuel", amount=1}},
	results = {},
	energy_required = 5, -- 5s * 150MW = 750MJ
	category = "fuel-generator",
	show_amount_in_title = false,
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_player_crafting = true
}
local steaming2 = {
	name = name.."-biofuel",
	type = "recipe",
	localised_description = {"recipe-description."..name.."-power"},
	icon = graphics.."icons/power.png",
	icon_size = 64,
	subgroup = "fluid-fuel",
	ingredients = {{type="fluid", name="liquid-biofuel", amount=1}},
	results = {},
	energy_required = 5, -- 5s * 150MW = 750MJ
	category = "fuel-generator",
	show_amount_in_title = false,
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_player_crafting = true
}
local steaming3 = {
	name = name.."-turbofuel",
	type = "recipe",
	localised_name = {"recipe-name."..name.."-power"},
	localised_description = {"recipe-description."..name.."-power"},
	icon = graphics.."icons/power.png",
	icon_size = 64,
	subgroup = "fluid-fuel",
	ingredients = {{type="fluid", name="turbofuel", amount=0.75}},
	results = {},
	energy_required = 10, -- 10s * 150MW / 0.75 = 2GJ
	category = "fuel-generator",
	show_amount_in_title = false,
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_player_crafting = true
}

local interface = {
	type = "electric-energy-interface",
	name = name.."-eei",
	localised_name = {"entity-name."..name},
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	selection_box = boiler.machine.selection_box,
	selectable_in_game = false,
	collision_box = boiler.machine.collision_box,
	collision_mask = {},
	energy_source = {
		type = "electric",
		buffer_capacity = "150000001W",
		usage_priority = "primary-output",
		drain = "0W"
	},
	energy_production = "150000001W",
	picture = empty_graphic,
	max_health = 1,
	flags = {
		"not-on-map"
	}
}
local accumulator = {
	type = "electric-energy-interface",
	name = name.."-buffer",
	icon = graphics.."icons/"..name..".png",
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

data:extend{steaming1, steaming2, steaming3, interface, accumulator}
