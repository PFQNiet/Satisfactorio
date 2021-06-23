local name = "wall"

local wall = table.deepcopy(data.raw.wall["stone-wall"])
wall.name = name
wall.minable.result = name
wall.icon = graphics.."icons/"..name..".png"
wall.icon_size = 64
wall.icon_mipmaps = 0
wall.max_health = 1

local wallitem = {
	type = "item",
	name = name,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	place_result = name,
	stack_size = 50,
	subgroup = "logistics-wall",
	order = "b["..name.."]"
}

local wallrecipe = makeBuildingRecipe{
	name = name,
	ingredients = {
		{"iron-plate",4},
		{"concrete",3}
	},
	result = name
}

data:extend{wall,wallitem,wallrecipe}
