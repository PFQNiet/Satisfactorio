local accelerator = makeAssemblingMachine{
	name = "particle-accelerator",
	size = {19,12},
	category = "accelerating",
	pipe_connections = {
		input = {{-4,999}}
	},
	energy = 1,
	allow_power_shards = true,
	sounds = copySoundsFrom(data.raw.lab.lab),
	subgroup = "production-manufacturer",
	order = "f",
	ingredients = {
		{"radio-control-unit",25},
		{"electromagnetic-control-rod",100},
		{"supercomputer",10},
		{"cooling-system",50},
		{"fused-modular-frame",20},
		{"turbo-motor",10}
	}
}
accelerator.machine.energy_usage = "1W" -- power consumption is handled on the EEI but must be set so the machine shuts down in a blackout
accelerator.machine.minable = nil
accelerator.machine.selectable_in_game = false
local interface = {
	type = "electric-energy-interface",
	name = accelerator.machine.name.."-eei",
	localised_name = {"entity-name."..accelerator.machine.name},
	localised_description = {"entity-description."..accelerator.machine.name},
	icon = accelerator.machine.icon,
	icon_size = accelerator.machine.icon_size,
	subgroup = "placeholder-buildings",
	energy_source = {
		type = "electric",
		buffer_capacity = "1500MW",
		usage_priority = "secondary-input",
		drain = "0W"
	},
	energy_usage = "1500MW", -- adjusted based on recipe
	pictures = empty_graphic,
	max_health = 1,
	collision_box = accelerator.machine.collision_box,
	collision_mask = {},
	selection_box = accelerator.machine.selection_box,
	flags = {"not-on-map"},
	minable = {
		mining_time = 0.5,
		result = accelerator.machine.name
	},
	open_sound = accelerator.machine.open_sound,
	close_sound = accelerator.machine.close_sound,
	placeable_by = {item=accelerator.machine.name,count=1}
}
data:extend{interface}
