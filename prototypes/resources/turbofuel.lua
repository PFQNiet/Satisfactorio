local name = "turbofuel"

local fluid = {
	type = "fluid",
	name = name,
	order = "u["..name.."]",
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	max_temperature = 25,
	default_temperature = 25,
	base_color = {103,1,5},
	flow_color = {168,0,13},
	fuel_value = "2GJ"
}
data:extend({fluid})
