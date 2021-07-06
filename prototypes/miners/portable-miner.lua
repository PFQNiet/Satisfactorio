local name = "portable-miner"
local sounds = copySoundsFrom(data.raw["mining-drill"]["burner-mining-drill"])
local pm = {
	type = "mining-drill",
	name = name,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	animations = {
		filename = graphics.."placeholders/"..name..".png",
		size = {32,32}
	},
	selection_box = {{-0.5,-0.5},{0.5,0.5}},
	selectable_in_game = false,
	collision_box = {{-0.2,-0.2},{0.2,0.2}},
	energy_source = {type = "void"},
	energy_usage = "1W",
	open_sound = sounds.open_sound,
	close_sound = sounds.close_sound,
	working_sound = sounds.working_sound,
	flags = {
		"placeable-player",
		"player-creation"
	},
	max_health = 1,
	minable = nil, -- mine the box
	mining_speed = 1/3, -- base 20/min
	resource_categories = {"solid"},
	resource_searching_radius = 1.49,
	vector_to_place_result = {0,0}
}

local pmbox = {
	type = "container",
	name = name.."-box",
	localised_name = {"entity-name."..name},
	localised_description = {"entity-description."..name},
	icon = pm.icon,
	icon_size = pm.icon_size,
	selection_box = {{-0.5,-0.5},{0.5,0.5}},
	collision_box = {{-0.2,-0.2},{0.2,0.2}},
	inventory_size = 1,
	enable_inventory_bar = false,
	flags = {"not-on-map"},
	max_health = 1,
	open_sound = sounds.open_sound,
	close_sound = sounds.close_sound,
	minable = {
		mining_time = 0.5,
		result = name,
	},
	picture = empty_graphic,
	placeable_by = {item=name,count=1}
}

local pmitem = {
	type = "item",
	name = name,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	place_result = name,
	stack_size = 1,
	flags = {"not-stackable"},
	subgroup = "production-miner",
	order = "b["..name.."]"
}

local pmrecipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"iron-plate",2},
		{"iron-rod",4}
	},
	result = name,
	energy_required = 10/4,
	category = "equipment",
	hide_from_stats = true,
	enabled = false
}

data:extend{pm,pmbox,pmitem,pmrecipe}
