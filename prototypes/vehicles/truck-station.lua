-- base entity is an electric-energy-interface to manage power consumption
-- station itself is a pair of storage chests: one with a single slot and single input for fuel, and one with 48 slots, one input and one output
-- building itself is 8x11 so the layout can be |F---I-O--|
-- docking area is 8x8
-- entity.get_inventory(defines.inventory.fuel).can_insert(itemstack) to see if it's insertable at all
-- entity.get_inventory(defines.inventory.fuel).get_insertable_count(itemname) to determine how many can be inserted
-- then insert that much and remove the same amount from the fuel supply
-- The storage part can just find_empty_stack() and just transfer a stack from the storage to the car or vice-versa

local name = "truck-station"

local sounds = copySoundsFrom(data.raw.container["steel-chest"])
local base = {
	type = "electric-energy-interface",
	name = name,
	energy_source = {
		type = "electric",
		buffer_capacity = "20MW",
		input_flow_limit = "20MW",
		usage_priority = "secondary-input",
		drain = "0W"
	},
	energy_usage = "20MW",
	pictures = makeRotatedSprite(name, 352, 256),
	radius_visualisation_specification = {
		sprite = {
			filename = "__Satisfactorio__/graphics/particles/"..name.."-zone.png",
			size = {256,256}
		},
		distance = 4,
		offset = {-0.5,-8}
	},
	max_health = 1,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	collision_box = {{-5.2,-3.7},{5.2,3.7}},
	flags = {
		"placeable-player",
		"player-creation"
	},
	minable = {
		mining_time = 0.5,
		result = name
	},
	open_sound = sounds.open_sound,
	close_sound = sounds.close_sound,
	selection_box = {{-5.5,-4},{5.5,4}}
}

local storage = {
	type = "container",
	name = name.."-box",
	localised_name = {"entity-name."..name},
	selection_box = {{-3.5,-3.5},{3.5,3.5}},
	selectable_in_game = false,
	collision_box = {{-3.2,-3.2},{3.2,3.2}},
	flags = {"not-on-map"},
	open_sound = sounds.open_sound,
	close_sound = sounds.close_sound,
	icon = base.icon,
	icon_size = base.icon_size,
	inventory_size = 48,
	enable_inventory_bar = false,
	max_health = 1,
	picture = empty_graphic
}

sounds = copySoundsFrom(data.raw.container["wooden-chest"])
local fuelbox = {
	type = "container",
	name = name.."-fuelbox",
	selection_box = {{-0.5,-0.5},{0.5,0.5}},
	selectable_in_game = false,
	collision_box = {{-0.2,-0.2},{0.2,0.2}},
	flags = {"not-on-map"},
	open_sound = sounds.open_sound,
	close_sound = sounds.close_sound,
	icon = base.icon,
	icon_size = base.icon_size,
	inventory_size = 1,
	enable_inventory_bar = false,
	max_health = 1,
	picture = empty_graphic
}

local stationitem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "t-s-a["..name.."]",
	place_result = name,
	stack_size = 50,
	subgroup = "transport",
	type = "item"
}

local stationrecipe = makeBuildingRecipe{
	name = name,
	ingredients = {
		{"modular-frame",15},
		{"rotor",20},
		{"copper-cable",50}
	},
	result = name
}

data:extend{base,storage,fuelbox,stationitem,stationrecipe}
