local name = "storage-container"
local sounds = copySoundsFrom(data.raw.container["iron-chest"])
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
	inventory_size = 24,
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
	selection_box = {{-1.5,-2.5},{1.5,2.5}},
	collision_box = {{-1.2,-2.2},{1.2,2.2}},
	activity_led_light_offsets = {{0,0},{0,0},{0,0},{0,0}},
	activity_led_sprites = empty_graphic,
	circuit_wire_connection_points = data.raw['constant-combinator']['constant-combinator'].circuit_wire_connection_points,
	item_slot_count = box.inventory_size,
	sprites = makeRotatedSprite(name, 96, 160),
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
	order = "b["..name.."]"
}

local boxrecipe = makeBuildingRecipe{
	name = name,
	ingredients = {
		{"iron-plate",10},
		{"iron-rod",10}
	},
	result = name
}

data:extend{box, fakebox, boxitem, boxrecipe}

-- Infinity version
box = table.deepcopy(box)
box.name = "infinity-"..box.name
box.type = "infinity-container"
box.erase_contents_when_mined = true
box.icons = {
	{icon = box.icon, icon_size = box.icon_size},
	{icon = "__core__/graphics/icons/mip/infinity.png", icon_size = 32, icon_mipmaps = 2, scale = 0.5, shift = {-8,8}, tint = {255,128,255}}
}

fakebox = table.deepcopy(fakebox)
fakebox.name = "infinity-"..fakebox.name
for _,sprite in pairs(fakebox.sprites) do
	sprite.tint = {255,128,255}
end
fakebox.minable.result = "infinity-"..fakebox.minable.result
fakebox.icons = box.icons
fakebox.localised_name = {"entity-name."..box.name}
fakebox.localised_description = {"entity-description."..box.name}
fakebox.allow_copy_paste = true

boxitem = table.deepcopy(boxitem)
boxitem.name = "infinity-"..boxitem.name
boxitem.place_result = "infinity-"..boxitem.place_result
boxitem.order = "c["..boxitem.name.."]"
boxitem.flags = {"hidden"}
boxitem.icons = box.icons

boxrecipe = table.deepcopy(boxrecipe)
boxrecipe.name = "infinity-"..boxrecipe.name
boxrecipe.result = "infinity-"..boxrecipe.result

data:extend{box, fakebox, boxitem, boxrecipe}
