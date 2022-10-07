local placeholder = require("graphics.placeholders.builder")

local name = "drop-pod"
local pod = {
	picture = placeholder().addBox(-1,-1,3,3,{},{}).addIcon(graphics.."icons/"..name..".png",64).result(),
	collision_box = {{-1.2,-1.2},{1.2,1.2}},
	flags = {
		"placeable-player"
	},
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	max_health = 1,
	minable = {
		mining_time = 2,
		result = "hub-parts"
	},
	name = name,
	selection_box = {{-1.5,-1.5},{1.5,1.5}},
	render_layer = "object",
	type = "simple-entity-with-owner"
}

data:extend{pod}
