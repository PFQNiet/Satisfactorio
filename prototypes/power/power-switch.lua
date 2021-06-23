-- tweak the Power Switch
local name = "power-switch"
local pole = data.raw['power-switch'][name]
pole.icon = "__Satisfactorio__/graphics/icons/"..name..".png"
pole.icon_size = 64
pole.icon_mipmaps = 0
pole.max_health = 1

local poleitem = data.raw.item[name]
poleitem.icon = pole.icon
poleitem.icon_mipmaps = 0
poleitem.stack_size = 50
poleitem.subgroup = "energy-pipe-distribution"

local polerecipe = makeBuildingRecipe{
	name = name,
	ingredients = {
		{"quickwire",20},
		{"steel-beam",4},
		{"ai-limiter",1}
	},
	result = name
}

data.raw.recipe[name] = polerecipe
