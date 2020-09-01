local workshop = table.deepcopy(data.raw['assembling-machine']['assembling-machine-1'])
workshop.name = "equipment-workshop"
workshop.gui_title_key = "equipment-workshop"
workshop.minable.result = "equipment-workshop"
workshop.crafting_categories = {"equipment"}
workshop.crafting_speed = 1
workshop.energy_source = {type="void"}
workshop.allowed_effects = nil
workshop.collision_box = {{-2.4,-1.4},{2.4,1.4}}
workshop.selection_box = {{-2.5,-1.5},{2.5,1.5}}
workshop.next_upgrade = nil
workshop.fast_replace_group = ""
workshop.icons = {{
	icon = "__Satisfactorio__/graphics/icons/equipment-workshop.png",
	icon_size = 64
}}

local workshopitem = table.deepcopy(data.raw['item']['assembling-machine-1'])
workshopitem.name = "equipment-workshop"
workshopitem.subgroup = "production-workstation"
workshopitem.order = "b"
workshopitem.stack_size = 1
workshopitem.place_result = "equipment-workshop"
workshopitem.order = "s-b[equipment-workshop]"
workshopitem.icons = {{
	icon = "__Satisfactorio__/graphics/icons/equipment-workshop.png",
	icon_size = 64
}}

local workshoprecipe = {
	name = "equipment-workshop",
	type = "recipe",
	ingredients = {
		{"iron-plate",6},
		{"iron-stick",4}
	},
	result = "equipment-workshop",
	energy_required = 1,
	category = "building",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true
}
local workshoprecipe_undo = {
	name = "equipment-workshop-undo",
	type = "recipe",
	ingredients = {
		{"equipment-workshop",1}
	},
	results = {
		{"iron-plate",6},
		{"iron-stick",4}
	},
	energy_required = 1,
	category = "unbuilding",
	subgroup = workshopitem.subgroup .. "-undo",
	order = workshopitem.order,
	allow_decomposition = false,
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	icons = {
		{icon = "__base__/graphics/icons/deconstruction-planner.png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/equipment-workshop.png", icon_size = 64}
	}
}

data:extend({workshop,workshopitem,workshoprecipe,workshoprecipe_undo})