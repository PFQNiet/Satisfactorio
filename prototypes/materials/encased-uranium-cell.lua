-- repurpose vanilla uranium cell
local name = "encased-uranium-cell"
local basename = "uranium-fuel-cell"

local ingot = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = basename,
	order = "k[uranium]-b["..basename.."]",
	stack_size = 200,
	subgroup = "nuclear",
	type = "item"
}

local ingredients = {
	{"uranium-pellet",40},
	{"concrete",9}
}
local ingotrecipe = { -- in Assembler
	name = basename,
	type = "recipe",
	ingredients = ingredients,
	result = basename,
	result_count = 10,
	energy_required = 60,
	category = "constructing",
	enabled = false
}

data.raw.item[basename] = ingot
data.raw.recipe[basename] = ingotrecipe
