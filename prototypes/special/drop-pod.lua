local name = "drop-pod"
local pod = {
	picture = {
		filename = "__Satisfactorio__/graphics/placeholders/"..name..".png",
		size = {96,96},
	},
	collision_box = {{-1.2,-1.2},{1.2,1.2}},
	flags = {
		"placeable-player"
	},
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	max_health = 1,
	minable = {
		mining_time = 2,
		result = "hub-parts"
	},
	name = name,
	selection_box = {{-1.5,-1.5},{1.5,1.5}},
	render_layer = "object",
	max_health = 1,
	type = "simple-entity-with-owner"
}

data:extend({pod})
