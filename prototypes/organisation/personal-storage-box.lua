local placeholder = require("graphics.placeholders.builder")

local name = "personal-storage-box"
local sounds = copySoundsFrom(data.raw.container["wooden-chest"])
local box = {
	type = "container",
	name = name,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	selection_box = {{-0.5,-0.5},{0.5,0.5}},
	collision_box = {{-0.2,-0.2},{0.2,0.2}},
	flags = {"placeable-neutral", "player-creation"},
	open_sound = sounds.open_sound,
	close_sound = sounds.close_sound,
	max_health = 1,
	picture = placeholder().addBox(0,0,1,1,{},{}).addIcon(graphics.."icons/"..name..".png",32).result(),
	inventory_size = 25,
	enable_inventory_bar = false,
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
	place_result = name,
	stack_size = 50,
	subgroup = "storage",
	order = "a["..name.."]"
}

local boxrecipe = makeBuildingRecipe{
	name = name,
	ingredients = {
		{"iron-plate",6},
		{"iron-rod",6}
	},
	result = name
}

data:extend{box, boxitem, boxrecipe}
