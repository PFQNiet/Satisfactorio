local name = "truck"
local car = table.deepcopy(data.raw.car.tank)

car.name = name
car.consumption = "75MW"
car.weight = 1100000
car.braking_power = "100MW"
car.energy_per_hit_point = 2000
car.max_health = 100
car.burner.fuel_category = nil
car.burner.fuel_categories = {"chemical","carbon","packaged-fuel","battery","nuclear"}
car.burner.fuel_inventory_size = 1
car.inventory_size = 48
car.guns = {}
car.immune_to_rock_impacts = false
car.immune_to_tree_impacts = false
car.minable.result = name

local caritem = {
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "t-v-b["..name.."]",
	place_result = name,
	stack_size = 50,
	subgroup = "transport",
	type = "item-with-entity-data"
}

local carrecipe = makeBuildingRecipe{
	name = name,
	ingredients = {
		{"motor",15},
		{"circuit-board",10},
		{"heavy-modular-frame",5},
		{"rubber",50},
		{"encased-industrial-beam",20}
	},
	result = name
}

data:extend{car,caritem,carrecipe}
