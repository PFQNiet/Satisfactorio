local placeholder = require("graphics.placeholders.builder")

local name = "industrial-storage-container"
local sounds = copySoundsFrom(data.raw.container["steel-chest"])
local box = {
	type = "container",
	name = name,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	subgroup = "placeholder-buildings",
	selection_box = {{-1.5,-1.5},{1.5,1.5}},
	selectable_in_game = false,
	collision_box = {{-1.2,-1.2},{1.2,1.2}},
	collision_mask = {},
	flags = {"not-on-map"},
	open_sound = sounds.open_sound,
	close_sound = sounds.close_sound,
	max_health = 1,
	picture = empty_graphic,
	scale_info_icons = true,
	inventory_size = 48,
	enable_inventory_bar = false,
	placeable_by = {item=name,count=1} -- item places a placeholder entity
}

-- the box cannot be the full size of the entity or the loader-inserters get confused
-- and besides, containers cannot be rotated...
local fakebox = {
	type = "constant-combinator",
	name = name.."-placeholder",
	localised_name = {"entity-name."..name},
	localised_description = {"entity-description."..name},
	icon = box.icon,
	icon_size = box.icon_size,
	allow_copy_paste = false,
	selection_box = {{-2.5,-2.5},{2.5,2.5}},
	collision_box = {{-2.2,-2.2},{2.2,2.2}},
	activity_led_light_offsets = {{0,0},{0,0},{0,0},{0,0}},
	activity_led_sprites = empty_graphic,
	circuit_wire_connection_points = data.raw['constant-combinator']['constant-combinator'].circuit_wire_connection_points,
	item_slot_count = box.inventory_size,
	sprites = placeholder().fourway().addBox(-2,-2,5,5,{{-1,2},{1,2}},{{-1,-2},{1,-2}}).addIcon(graphics.."icons/"..name..".png",64).result(),
	max_health = 1,
	open_sound = box.open_sound,
	close_sound = box.close_sound,
	flags = {
		"placeable-player",
		"player-creation",
		"hide-alt-info"
	},
	minable = {
		mining_time = 0.5,
		result = name
	}
}

local boxitem = {
	type = "item",
	name = name,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	place_result = fakebox.name,
	stack_size = 50,
	subgroup = "storage",
	order = "c["..name.."]"
}

local boxrecipe = makeBuildingRecipe{
	name = name,
	ingredients = {
		{"steel-beam",20},
		{"steel-pipe",20}
	},
	result = name
}

data:extend{box, fakebox, boxitem, boxrecipe}
