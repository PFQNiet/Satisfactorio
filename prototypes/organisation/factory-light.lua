-- tweak the Small Lamp
local basename = "small-lamp"
local lamp = data.raw.lamp[basename]
-- lamp.icon = "__Satisfactorio__/graphics/icons/"..name..".png"
-- lamp.icon_mipmaps = 0
lamp.max_health = 1
lamp.energy_usage_per_tick = "1MW"

local lampitem = data.raw.item[basename]
lampitem.stack_size = 50
lampitem.subgroup = "logistics-observation"

local lamprecipe = makeBuildingRecipe{
	name = basename,
	ingredients = {
		{"quartz-crystal",20},
		{"wire",16},
		{"steel-beam",6}
	},
	result = basename
}
data.raw.recipe[basename] = lamprecipe
