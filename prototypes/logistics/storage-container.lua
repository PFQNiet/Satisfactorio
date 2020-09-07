local empty_sprite = {
	filename = "__core__/graphics/empty.png",
	width = 1,
	height = 1
}
-- adjust vanilla Iron Chest
local name = "storage-container"
local basename = "iron-chest"
local box = data.raw['container'][basename]
box.icon = "__Satisfactorio__/graphics/icons/"..name..".png"
box.icon_mipmaps = 0
box.max_health = 1
box.enable_inventory_bar = false
box.inventory_size = 24
box.collision_box = {{-1.3,-1.3},{1.3,1.3}}
box.selection_box = {{-1.5,-1.5},{1.5,1.5}}
box.picture = empty_sprite
box.placeable_by = {item=basename, count=1}

-- but in order to allow rotation of the non-square box, we need a rotatable entity
-- apparently constant combinator is the item of choice for that, so...
local fakebox = {
	type = "constant-combinator",
	name = name.."-placeholder",
	activity_led_light_offsets = {{0,0},{0,0},{0,0},{0,0}},
	activity_led_sprites = empty_sprite,
	circuit_wire_connection_points = data.raw['constant-combinator']['constant-combinator'].circuit_wire_connection_points,
	item_slot_count = 0,
	sprites = {
		north = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ns.png",
			size = {96,160}
		},
		east = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ew.png",
			size = {160,96}
		},
		south = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ns.png",
			size = {96,160}
		},
		west = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ew.png",
			size = {160,96}
		}
	},
	max_health = 1,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	collision_box = {{-1.3,-2.3},{1.3,2.3}},
	corpse = "big-remnants",
	dying_explosion = "big-explosion",
	flags = {
		"placeable-neutral",
		"placeable-player",
		"player-creation"
	},
	minable = nil, -- mine the container itself
	selection_box = {{-1.5,-2.5},{1.5,2.5}},
	selection_priority = 40
}

local boxitem = data.raw.item[basename]
boxitem.icon = box.icon
boxitem.icon_mipmaps = 0
boxitem.stack_size = 1
boxitem.place_result = fakebox.name

local ingredients = {
	{"iron-plate",10},
	{"iron-stick",10}
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
data:extend({fakebox,boxrecipe_undo})
