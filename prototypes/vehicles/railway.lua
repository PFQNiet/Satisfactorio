data.raw['straight-rail']['straight-rail'].max_health = 1
data.raw['straight-rail']['straight-rail'].selection_priority = 45
data.raw['curved-rail']['curved-rail'].max_health = 1
data.raw['curved-rail']['curved-rail'].selection_priority = 45

local rail = data.raw['rail-planner']['rail']
rail.localised_description = {"", {"item-description.rail"}, {"item-description.rail-cost"}}
rail.icon = "__Satisfactorio__/graphics/icons/railway.png"
rail.icon_size = 64
rail.icon_mipmaps = 1
rail.stack_size = 50
local recipe = makeBuildingRecipe{
	name = "rail",
	ingredients = {
		{"steel-pipe",1},
		{"steel-beam",1}
	},
	result = "rail",
	result_count = 6
}
data.raw.recipe.rail = recipe

rail = data.raw.item['rail-signal']
rail.stack_size = 50
local signal = makeBuildingRecipe{
	name = "rail-signal",
	ingredients = {
		{"circuit-board",1},
		{"iron-plate",5}
	},
	result = "rail-signal"
}
data.raw.recipe['rail-signal'] = signal

rail = data.raw.item['rail-chain-signal']
rail.stack_size = 50
signal = makeBuildingRecipe{
	name = "rail-chain-signal",
	ingredients = {
		{"circuit-board",1},
		{"iron-plate",5}
	},
	result = "rail-chain-signal"
}
data.raw.recipe['rail-chain-signal'] = signal
