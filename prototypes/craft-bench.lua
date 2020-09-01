local bench = table.deepcopy(data.raw['assembling-machine']['assembling-machine-1'])
bench.name = "craft-bench"
bench.gui_title_key = "craft-bench"
bench.crafting_categories = {"crafting","smelting"}
bench.crafting_speed = 1
bench.energy_source = {type="void"}
bench.allowed_effects = nil

local benchitem = table.deepcopy(data.raw['item']['assembling-machine-1'])
benchitem.name = "craft-bench"
benchitem.stack_size = 1
benchitem.place_result = "craft-bench"

local benchrecipe = {
	name = "craft-bench",
	type = "recipe",
	ingredients = {
		{"iron-plate",3},
		{"iron-stick",3}
	},
	result = "craft-bench",
	energy_required = 1,
	category = "building",
	hide_from_stats = true
}

data:extend({bench,benchitem,benchrecipe})