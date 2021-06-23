local function clonePowerPole(params)
	---@type string
	local source = params.source
	---@type string
	local name = params.name
	---@type table
	local ingredients = params.ingredients

	local pole = table.deepcopy(data.raw["electric-pole"][source])
	pole.name = name
	pole.minable.result = name
	pole.icon = graphics.."icons/"..name..".png"
	pole.icon_size = 64
	pole.icon_mipmaps = 0
	pole.max_health = 1

	local sourceitem = data.raw.item[source]
	local poleitem = {
		type = "item",
		name = name,
		icon = graphics.."icons/"..name..".png",
		icon_size = 64,
		place_result = name,
		stack_size = 50,
		subgroup = sourceitem.subgroup,
		order = sourceitem.order
	}

	local polerecipe = makeBuildingRecipe{
		name = name,
		ingredients = ingredients,
		result = name
	}

	data:extend{pole, poleitem, polerecipe}
end

clonePowerPole{
	source = "small-electric-pole",
	name = "power-pole-mk-1",
	ingredients = {
		{"wire",3},
		{"iron-rod",1},
		{"concrete",1}
	}
}

clonePowerPole{
	source = "medium-electric-pole",
	name = "power-pole-mk-2",
	ingredients = {
		{"quickwire",6},
		{"iron-rod",2},
		{"concrete",2}
	}
}

clonePowerPole{
	source = "big-electric-pole",
	name = "power-pole-mk-3",
	ingredients = {
		{"high-speed-connector",2},
		{"steel-pipe",2},
		{"concrete",3}
	}
}
