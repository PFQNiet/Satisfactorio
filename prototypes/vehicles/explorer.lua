local name = "explorer"
local car = table.deepcopy(data.raw.car.car)

car.name = name
car.consumption = "90MW"
car.weight = 90000
car.friction = 0.01
car.braking_power = "40MW"
car.energy_per_hit_point = 450
car.max_health = 100
car.burner.fuel_category = nil
car.burner.fuel_categories = {"chemical","carbon","packaged-fuel","battery","nuclear"}
car.burner.fuel_inventory_size = 1
car.inventory_size = 24
car.guns = {}
car.minable.result = name

local caritem = {
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "t-v-c["..name.."]",
	place_result = name,
	stack_size = 50,
	subgroup = "transport",
	type = "item-with-entity-data"
}

local carrecipe = makeBuildingRecipe{
	name = name,
	ingredients = {
		{"crystal-oscillator",5},
		{"motor",5},
		{"map-marker",15},
		{"heavy-modular-frame",5}
	},
	result = name
}

data:extend{car,caritem,carrecipe}
