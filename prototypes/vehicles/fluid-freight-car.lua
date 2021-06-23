local fluid = data.raw['fluid-wagon']['fluid-wagon']
fluid.capacity = 1600
fluid.max_health = 1
fluid.weight = 425000/2

fluid = data.raw['item-with-entity-data']['fluid-wagon']
fluid.icon = nil
fluid.icon_size = nil
fluid.icon_mipmaps = nil
fluid.icons = {
	{icon = "__Satisfactorio__/graphics/icons/freight-car.png", icon_size = 64},
	{icon = "__Satisfactorio__/graphics/icons/water.png", icon_size = 64, scale = 0.25, shift = {-8,8}}
}
fluid.stack_size = 50

local recipe = makeBuildingRecipe{
	name = "fluid-wagon",
	ingredients = {
		{"heavy-modular-frame",4},
		{"steel-pipe",10}
	},
	result = "fluid-wagon"
}
data.raw.recipe['fluid-wagon'] = recipe
