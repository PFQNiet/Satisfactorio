local name = "ai-limiter"
local basename = "processing-unit"
local circuit = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = basename,
	order = "h["..name.."]",
	stack_size = 100,
	subgroup = "components",
	type = "item"
}

local ingredients = {
	{"copper-plate",5},
	{"quickwire",20}
}
local circuitrecipe1 = { -- by hand in Craft Bench
	name = basename.."-manual",
	type = "recipe",
	ingredients = ingredients,
	result = basename,
	energy_required = 6/4,
	category = "craft-bench",
	hide_from_player_crafting = true,
	enabled = false
}
local circuitrecipe2 = { -- in Assembler
	name = basename,
	type = "recipe",
	ingredients = ingredients,
	result = basename,
	energy_required = 12,
	category = "assembling",
	enabled = false
}

data.raw.item[basename] = circuit
data.raw.recipe[basename] = circuitrecipe2
data:extend({circuitrecipe1})
