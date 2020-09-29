local name = "conveyor-lift-mk-5"
local beltname = "ultimate-transport-belt"
local basename = "ultimate-underground-belt"
local sourcename = "express-underground-belt"
local belt = table.deepcopy(data.raw['underground-belt'][sourcename])
belt.name = basename
belt.order = "b[underground-belt]-e["..basename.."]"
belt.icon = "__Satisfactorio__/graphics/icons/"..name..".png"
belt.icon_mipmaps = 0
belt.max_health = 1
belt.speed = 7/256
belt.max_distance = 5
belt.belt_animation_set.animation_set.filename = "__Satisfactorio__/graphics/entities/"..beltname.."/"..beltname..".png"
belt.belt_animation_set.animation_set.hr_version.filename = "__Satisfactorio__/graphics/entities/"..beltname.."/hr-"..beltname..".png"
belt.structure.direction_in.sheet.filename = "__Satisfactorio__/graphics/entities/"..basename.."/"..basename.."-structure.png"
belt.structure.direction_in.sheet.hr_version.filename = "__Satisfactorio__/graphics/entities/"..basename.."/hr-"..basename.."-structure.png"
belt.structure.direction_in_side_loading.sheet.filename = "__Satisfactorio__/graphics/entities/"..basename.."/"..basename.."-structure.png"
belt.structure.direction_in_side_loading.sheet.hr_version.filename = "__Satisfactorio__/graphics/entities/"..basename.."/hr-"..basename.."-structure.png"
belt.structure.direction_out.sheet.filename = "__Satisfactorio__/graphics/entities/"..basename.."/"..basename.."-structure.png"
belt.structure.direction_out.sheet.hr_version.filename = "__Satisfactorio__/graphics/entities/"..basename.."/hr-"..basename.."-structure.png"
belt.structure.direction_out_side_loading.sheet.filename = "__Satisfactorio__/graphics/entities/"..basename.."/"..basename.."-structure.png"
belt.structure.direction_out_side_loading.sheet.hr_version.filename = "__Satisfactorio__/graphics/entities/"..basename.."/hr-"..basename.."-structure.png"
belt.structure.back_patch.sheet.filename = "__Satisfactorio__/graphics/entities/"..basename.."/"..basename.."-structure-back-patch.png"
belt.structure.back_patch.sheet.hr_version.filename = "__Satisfactorio__/graphics/entities/"..basename.."/hr-"..basename.."-structure-back-patch.png"
belt.structure.front_patch.sheet.filename = "__Satisfactorio__/graphics/entities/"..basename.."/"..basename.."-structure-front-patch.png"
belt.structure.front_patch.sheet.hr_version.filename = "__Satisfactorio__/graphics/entities/"..basename.."/hr-"..basename.."-structure-front-patch.png"
belt.minable.result = basename

local beltitem = table.deepcopy(data.raw.item[sourcename])
beltitem.name = basename
beltitem.icon = belt.icon
beltitem.icon_mipmaps = 0
beltitem.stack_size = 20
beltitem.place_result = basename

local ingredients = {{"alclad-aluminium-sheet",8}}
local beltrecipe = {
	name = basename,
	type = "recipe",
	ingredients = ingredients,
	result = basename,
	result_count = 2,
	energy_required = 0.5,
	category = "building",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	enabled = false
}
local _group = data.raw['item-subgroup'][beltitem.subgroup]
local beltrecipe_undo = {
	name = basename.."-undo",
	localised_name = {"recipe-name.dismantle",{"item-name."..basename}},
	show_amount_in_title = false,
	type = "recipe",
	ingredients = {
		{basename,2}
	},
	results = ingredients,
	energy_required = 0.5,
	category = "unbuilding",
	subgroup = _group.group .. "-undo",
	order = _group.order .. "-" .. beltitem.order,
	allow_decomposition = false,
	allow_intermediates = false,
	allow_as_intermediate = false,
	always_show_products = true,
	hide_from_stats = true,
	icons = {
		{icon = "__base__/graphics/icons/deconstruction-planner.png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64}
	},
	enabled = false
}

data:extend({belt, beltitem, beltrecipe, beltrecipe_undo})