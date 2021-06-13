local empty_sprite = {
	filename = "__core__/graphics/empty.png",
	width = 1,
	height = 1
}
-- adjust vanilla Steel Chest
local name = "industrial-storage-container"
local basename = "steel-chest"
local box = data.raw['container'][basename]
box.icon = "__Satisfactorio__/graphics/icons/"..name..".png"
box.icon_mipmaps = 0
box.max_health = 1
box.enable_inventory_bar = false
box.inventory_size = 48
box.collision_box = {{-1.2,-1.2},{1.2,1.2}}
box.collision_mask = {}
box.selection_box = {{-1.5,-1.5},{1.5,1.5}}
box.selectable_in_game = false
box.picture = empty_sprite
box.minable.mining_time = 1
box.placeable_by = {item=basename, count=1}
box.next_upgrade = nil
box.fast_replaceable_group = ""
box.flags = {"not-on-map"}

-- but in order to allow rotation of the box, we need a rotatable entity
-- apparently constant combinator is the item of choice for that, so...
local fakebox = {
	type = "constant-combinator",
	name = name.."-placeholder",
	activity_led_light_offsets = {{0,0},{0,0},{0,0},{0,0}},
	activity_led_sprites = empty_sprite,
	circuit_wire_connection_points = data.raw['constant-combinator']['constant-combinator'].circuit_wire_connection_points,
	item_slot_count = box.inventory_size,
	sprites = {
		north = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-n.png",
			size = {160,160}
		},
		east = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-e.png",
			size = {160,160}
		},
		south = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-s.png",
			size = {160,160}
		},
		west = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-w.png",
			size = {160,160}
		}
	},
	max_health = 1,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	collision_box = {{-2.2,-2.2},{2.2,2.2}},
	open_sound = box.open_sound,
	close_sound = box.close_sound,
	flags = {
		"placeable-player",
		"player-creation",
		"hide-alt-info"
	},
	minable = {
		mining_time = 1,
		result = basename
	},
	selection_box = {{-2.5,-2.5},{2.5,2.5}},
	selection_priority = 40
}

local boxitem = data.raw.item[basename]
boxitem.icon = box.icon
boxitem.icon_mipmaps = 0
boxitem.stack_size = 50
boxitem.place_result = fakebox.name

local ingredients = {
	{"steel-plate",20},
	{"steel-pipe",20}
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
local _group = data.raw['item-subgroup'][boxitem.subgroup]
local boxrecipe_undo = {
	name = basename.."-undo",
	localised_name = {"recipe-name.dismantle",{"entity-name."..basename}},
	type = "recipe",
	ingredients = {
		{basename,1}
	},
	results = ingredients,
	energy_required = 1,
	category = "unbuilding",
	subgroup = _group.group .. "-undo",
	order = _group.order .. "-" .. boxitem.order,
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
