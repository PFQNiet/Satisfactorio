-- tweak vanilla crash-site-spaceship
-- these are hardcoded into crash-site lib code, so I can't just clone them...
local ship = data.raw.container['crash-site-spaceship']
ship.max_health = 1
ship.inventory_size = 1
ship.minable = {mining_time=60}
local sounds = copySoundsFrom(data.raw.container["steel-chest"])
ship.open_sound = sounds.open_sound
ship.close_sound = sounds.close_sound

-- alter crash site parts to also have 1 max HP (although they need to be set indestructible manually since Factorio doesn't trigger raise_built on them)
for _,n in pairs({
	"crash-site-spaceship-wreck-big-1", "crash-site-spaceship-wreck-big-2"
}) do
	local box = data.raw.container[n]
	box.max_health = 1
	box.minable = nil
	box.inventory_size = 6
	box.localised_description = {"entity-description.crash-site-debris"}
end
for _,n in pairs({
	"crash-site-spaceship-wreck-medium-1", "crash-site-spaceship-wreck-medium-2", "crash-site-spaceship-wreck-medium-3"
}) do
	local box = data.raw.container[n]
	box.max_health = 1
	box.minable = nil
	box.inventory_size = 4
	box.localised_description = {"entity-description.crash-site-debris"}
end
for _,n in pairs({
	"crash-site-spaceship-wreck-small-1", "crash-site-spaceship-wreck-small-2", "crash-site-spaceship-wreck-small-3",
	"crash-site-spaceship-wreck-small-4", "crash-site-spaceship-wreck-small-5", "crash-site-spaceship-wreck-small-6"
}) do
	local box = data.raw['simple-entity-with-owner'][n]
	box.max_health = 1
	box.minable = nil
	box.localised_description = {"entity-description.crash-site-debris"}
end

-- add an EEI to accept power
local interface = {
	type = "electric-energy-interface",
	name = ship.name.."-power",
	localised_name = {"entity-name."..ship.name},
	energy_source = {
		type = "electric",
		buffer_capacity = "50MW",
		usage_priority = "secondary-input",
		drain = "0W",
		output_flow_limit = "0W"
	},
	energy_usage = "50MW", -- default value, varies depending on the crash site
	picture = empty_graphic,
	resistances = {
		{type="fire",percent=100}
	},
	max_health = 1,
	icon = "__base__/graphics/icons/"..ship.name..".png",
	icon_mipmaps = 4,
	icon_size = 64,
	collision_box = ship.collision_box,
	flags = {
		"placeable-off-grid"
	},
	selection_box = ship.selection_box,
	selectable_in_game = false
}
data:extend{interface}

data:extend{
	{
		type = "autoplace-control",
		name = "x-crashsite",
		order = "u",
		richness = false,
		category = "terrain"
	},
	{
		type = "noise-layer",
		name = "x-crashsite"
	}
}
