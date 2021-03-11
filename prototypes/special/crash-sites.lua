-- tweak vanilla crash-site-spaceship
local ship = data.raw.container['crash-site-spaceship']
ship.max_health = 1
ship.inventory_size = 1
ship.minable = nil
ship.open_sound = {
	filename = "__base__/sound/metallic-chest-open.ogg",
	volume = 0.5
}
ship.close_sound = {
	filename = "__base__/sound/metallic-chest-close.ogg",
	volume = 0.5
}

-- alter crash site parts to also have 1 max HP (although they need to be set indestructible manually since Factorio doesn't trigger raise_built on them)
for _,n in pairs({
	"crash-site-spaceship-wreck-big-1", "crash-site-spaceship-wreck-big-2"
}) do
	data.raw.container[n].max_health = 1
	data.raw.container[n].minable = nil
	data.raw.container[n].inventory_size = 6
end
for _,n in pairs({
	"crash-site-spaceship-wreck-medium-1", "crash-site-spaceship-wreck-medium-2", "crash-site-spaceship-wreck-medium-3"
}) do
	data.raw.container[n].max_health = 1
	data.raw.container[n].minable = nil
	data.raw.container[n].inventory_size = 4
end
for _,n in pairs({
	"crash-site-spaceship-wreck-small-1", "crash-site-spaceship-wreck-small-2", "crash-site-spaceship-wreck-small-3",
	"crash-site-spaceship-wreck-small-4", "crash-site-spaceship-wreck-small-5", "crash-site-spaceship-wreck-small-6"
}) do
	data.raw['simple-entity-with-owner'][n].max_health = 1
	data.raw['simple-entity-with-owner'][n].minable = nil
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
	picture = {
		filename = "__core__/graphics/empty.png",
		size = {1,1}
	},
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
	selection_priority = 40
}
data:extend{interface}

data:extend({
	{
		type = "autoplace-control",
		name = "x-crashsite",
		order = "u",
		richness = false,
		category = "resource"
	},
	{
		type = "noise-layer",
		name = "x-crashsite"
	}
})
