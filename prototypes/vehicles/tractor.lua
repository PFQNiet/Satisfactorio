local name = "tractor"
local car = table.deepcopy(data.raw.car.car)

car.name = name
car.consumption = "55MW"
car.weight = 720000
car.braking_power = "80MW"
car.energy_per_hit_point = 1000
car.max_health = 100
car.burner.fuel_category = nil
car.burner.fuel_categories = {"chemical","carbon","packaged-fuel","battery","nuclear"}
car.burner.fuel_inventory_size = 1
car.inventory_size = 25
car.guns = {}
car.minable.result = name

local caritem = {
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "t-v-a["..name.."]",
	place_result = name,
	stack_size = 50,
	subgroup = "transport",
	type = "item-with-entity-data"
}

local carrecipe = makeBuildingRecipe{
	name = name,
	ingredients = {
		{"modular-frame",5},
		{"rotor",5},
		{"reinforced-iron-plate",10}
	},
	result = name
}

data:extend{car,caritem,carrecipe}
