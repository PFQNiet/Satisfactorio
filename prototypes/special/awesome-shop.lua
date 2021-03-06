-- the shop is an assembler that "dispenses" items for coupons ("coin")
local shop = makeAssemblingMachine{
	name = "awesome-shop",
	size = {3,2},
	category = "awesome-shop",
	sounds = copySoundsFrom(data.raw.roboport.roboport),
	subgroup = "special",
	order = "d",
	ingredients = {
		{"screw",200},
		{"iron-plate",10},
		{"copper-cable",30}
	}
}
shop.machine.bottleneck_ignore = true

local prices = require("constants.sink-cashout")
-- prices = table of [item] = {cost, number}
for item,spec in pairs(prices) do
	local cost = spec[1]
	local count = spec[2]
	local recipe = {
		name = "awesome-shop-"..item,
		type = "recipe",
		icons = {
			{icon = graphics.."icons/"..item..".png", icon_size = 64},
			{icon = graphics.."icons/coupon.png", icon_size = 64, scale = 0.25, shift = {-8,8}}
		},
		ingredients = {{"coin",cost}},
		result = item,
		result_count = count,
		energy_required = 1,
		category = "awesome-shop",
		allow_intermediates = false,
		allow_as_intermediate = false,
		hide_from_stats = true,
		hide_from_player_crafting = true,
		enabled = item == "iron-plate" or item == "iron-rod"
	}
	data:extend{recipe}
end
