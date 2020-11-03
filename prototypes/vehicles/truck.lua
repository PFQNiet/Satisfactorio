local name = "truck"
local car = table.deepcopy(data.raw.car.tank)

car.name = name
car.consumption = "75MW"
car.weight = 1100000
car.braking_power = "100MW"
car.energy_per_hit_point = 1000
car.max_health = 100
car.burner.fuel_category = nil
car.burner.fuel_categories = {"chemical","carbon","packaged-fuel","packaged-alt-fuel","nuclear"}
car.burner.fuel_inventory_size = 1
car.inventory_size = 48
car.guns = {}
car.immune_to_rock_impacts = false
car.immune_to_tree_impacts = false
car.minable.result = name

local caritem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "t-v-b["..name.."]",
	place_result = name,
	stack_size = 1,
	subgroup = "transport",
	type = "item-with-entity-data"
}

local ingredients = {
	{"motor",8},
	{"computer",10},
	{"heavy-modular-frame",4},
	{"rubber",50},
	{"map-marker",10}
}
local carrecipe = {
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
local _group = data.raw['item-subgroup'][caritem.subgroup]
local carrecipe_undo = {
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
	order = _group.order .. "-" .. caritem.order,
	allow_decomposition = false,
	allow_intermediates = false,
	allow_as_intermediate = false,
	always_show_products = true,
	hide_from_stats = true,
	icons = {
		{icon = "__base__/graphics/icons/deconstruction-planner.png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64}
	},
	enabled = false
}

data:extend({car,caritem,carrecipe,carrecipe_undo})
