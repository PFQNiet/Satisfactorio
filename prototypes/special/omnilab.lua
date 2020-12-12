-- a special invisible lab that accepts all of the "fake" items used to progress the game
local name = "omnilab"

local empty = {
	filename = "__core__/graphics/empty.png",
	size = {1,1}
}
local lab = {
	off_animation = empty,
	on_animation = empty,
	collision_box = {{-1.3,-1.3},{1.3,1.3}},
	collision_mask = {},
	inputs = {},
	researching_speed = 1,
	energy_source = {type="void"},
	energy_usage = "1W",
	flags = {"hidden","hide-alt-info"},
	selectable_in_game = false,
	icon = "__Satisfactorio__/graphics/icons/mam.png",
	icon_size = 64,
	max_health = 1,
	minable = nil,
	name = name,
	selection_box = {{-1.5,-1.5},{1.5,1.5}},
	type = "lab"
}

data:extend({lab})