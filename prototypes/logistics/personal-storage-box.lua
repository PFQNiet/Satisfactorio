-- adjust vanilla Wooden Chest
local name = "personal-storage-box"
local basename = "wooden-chest"
local box = data.raw['container'][basename]
box.icon = "__Satisfactorio__/graphics/icons/"..name..".png"
box.icon_mipmaps = 0
box.max_health = 1
box.enable_inventory_bar = false
box.inventory_size = 25
table.insert(box.flags,"no-automated-item-insertion")
table.insert(box.flags,"no-automated-item-removal")

local boxitem = data.raw.item[basename]
boxitem.icon = box.icon
boxitem.icon_mipmaps = 0
boxitem.stack_size = 1

local ingredients = {
	{"iron-plate",6},
	{"iron-stick",6}
}
local boxrecipe = {
	name = basename,
	type = "recipe",
	ingredients = ingredients,
	result = basename,
	energy_required = 1,
	category = "building",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	enabled = false
}
local boxrecipe_undo = {
	name = basename.."-undo",
	localised_name = {"recipe-name."..basename.."-undo"},
	type = "recipe",
	ingredients = {
		{basename,1}
	},
	results = ingredients,
	energy_required = 1,
	category = "unbuilding",
	subgroup = boxitem.subgroup .. "-undo",
	order = boxitem.order,
	allow_decomposition = false,
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	icons = {
		{icon = "__base__/graphics/icons/deconstruction-planner.png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64}
	},
	enabled = false
}

data.raw.recipe[basename] = boxrecipe
data:extend({boxrecipe_undo})