local name = "lookout-tower"
local tower = {
	type = "radar",
	name = name,
	collision_box = {{-1.7,-1.7},{1.7,1.7}},
	collision_mask = {"item-layer", "object-layer", "water-tile"},
	selection_box = {{-2,-2},{2,2}},
	corpse = "big-remnants",
	dying_explosion = "big-explosion",
	energy_per_nearby_scan = "1J",
	max_distance_of_nearby_sector_revealed = 3,
	energy_per_sector = "1J",
	max_distance_of_sector_revealed = 0,
	energy_source = {type="void"},
	energy_usage = "1W",
	flags = {
		"placeable-player",
		"player-creation"
	},
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	max_health = 1,
	minable = {
		mining_time = 1,
		result = name
	},
	pictures = {
		direction_count = 1,
		filename = "__Satisfactorio__/graphics/placeholders/"..name..".png",
		width = 128,
		height = 128
	},
	radius_minimap_visualisation_color = {
		r = 0.059,
		g = 0.092,
		b = 0.235,
		a = 0.275
	}
}

local toweritem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "a["..name.."]",
	place_result = name,
	stack_size = 1,
	subgroup = "logistics-observation",
	type = "item"
}

local ingredients = {
	{"iron-plate",5},
	{"iron-stick",5}
}
local towerrecipe = {
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 1,
	category = "building",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	enabled = false
}
local _group = data.raw['item-subgroup'][toweritem.subgroup]
local towerrecipe_undo = {
	name = name.."-undo",
	localised_name = {"recipe-name.dismantle",{"item-name."..name}},
	type = "recipe",
	ingredients = {
		{name,1}
	},
	results = ingredients,
	energy_required = 1,
	category = "unbuilding",
	subgroup = _group.group .. "-undo",
	order = _group.order .. "-" .. toweritem.order,
	allow_decomposition = false,
	allow_intermediates = false,
	allow_as_intermediate = false,
	always_show_products = true,
	hide_from_stats = true,
	enabled = false,
	icons = {
		{icon = "__base__/graphics/icons/deconstruction-planner.png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64}
	}
}

local tower_vehicle = {
	-- a fake car for the player to "climb on" the tower
	type = "car",
	name = name.."-car",
	animation = {
		direction_count = 1,
		filename = "__core__/graphics/empty.png",
		width = 1,
		height = 1
	},
	braking_power = "200kW",
	burner = {
		effectivity = 1,
		fuel_category = "chemical",
		fuel_inventory_size = 0,
		render_no_power_icon = false
	},
	consumption = "1W",
	effectivity = 0.5,
	weight = 1,
	braking_force = 1,
	friction_force = 1,
	energy_per_hit_point = 1,
	inventory_size = 0,
	rotation_speed = 0,
	max_health = 1,
	icon = toweritem.icon,
	icon_size = toweritem.icon_size,
	collision_box = tower.collision_box,
	selection_box = tower.selection_box,
	selection_priority = 40,
	minable = nil,
	flags = {
		"not-on-map",
		"no-automated-item-removal",
		"no-automated-item-insertion",
		"hidden"
	}
}

data:extend({tower,toweritem,towerrecipe,towerrecipe_undo,tower_vehicle})
