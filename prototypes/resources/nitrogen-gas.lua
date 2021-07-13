local name = "nitrogen-gas"

local fluid = {
	type = "fluid",
	name = name,
	order = "d[nitro]-a["..name.."]",
	subgroup = "fluid-resource",
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	max_temperature = 25,
	default_temperature = 25,
	base_color = {180,180,180},
	flow_color = {180,180,180}
}

data:extend({fluid})
