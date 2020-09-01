local bench = table.deepcopy(data.raw['assembling-machine']['assembling-machine-1'])
bench.name = "craft-bench"
bench.gui_title_key = "craft-bench"
bench.minable.result = "craft-bench"
bench.crafting_categories = {"crafting","smelting"}
bench.crafting_speed = 1
bench.energy_source = {type="void"}
bench.allowed_effects = nil
bench.collision_box = {{-1.4,-0.9},{1.4,0.9}}
bench.selection_box = {{-1.5,-1.0},{1.5,1.0}}
bench.next_upgrade = nil
bench.fast_replace_group = ""
bench.icons = {{
	icon = "__Satisfactorio__/graphics/icons/craft-bench.png",
	icon_size = 64
}}

local benchitem = table.deepcopy(data.raw['item']['assembling-machine-1'])
benchitem.name = "craft-bench"
benchitem.subgroup = "production-workstation"
benchitem.order = "a"
benchitem.stack_size = 1
benchitem.place_result = "craft-bench"
benchitem.order = "s-a[craft-bench]"
benchitem.icons = {{
	icon = "__Satisfactorio__/graphics/icons/craft-bench.png",
	icon_size = 64
}}

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
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true
}
local benchrecipe_undo = {
	name = "craft-bench-undo",
	type = "recipe",
	ingredients = {
		{"craft-bench",1}
	},
	results = {
		{"iron-plate",3},
		{"iron-stick",3}
	},
	energy_required = 1,
	category = "unbuilding",
	subgroup = benchitem.subgroup .. "-undo",
	order = benchitem.order,
	allow_decomposition = false,
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	icons = {
		{icon = "__base__/graphics/icons/deconstruction-planner.png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/craft-bench.png", icon_size = 64}
	}
}

data:extend({bench,benchitem,benchrecipe,benchrecipe_undo})