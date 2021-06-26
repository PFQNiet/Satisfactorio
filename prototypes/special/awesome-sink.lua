-- the Sink is a furnace that converts items into a fake "fluid" for points, which is periodically emptied out to award tickets
-- its GUI will be supplemented by a count of points and a button to claim Coupons
local base = makeAssemblingMachine{
	name = "awesome-sink",
	type = "furnace",
	size = {8,7},
	energy = 30,
	category = "awesome-sink",
	sounds = copySoundsFrom(data.raw["mining-drill"]["electric-mining-drill"]),
	subgroup = "special",
	order = "c",
	ingredients = {
		{"reinforced-iron-plate",15},
		{"copper-cable",30},
		{"concrete",45}
	}
}
base.machine.source_inventory_size = 1
base.machine.result_inventory_size = 0
base.machine.fluid_boxes = {
	{
		base_area = 1000000, -- space for up to 100M fluid because there's no kill like overkill
		production_type = "output",
		pipe_connections = {}
	}
}

-- pseudo "points" fluid for stat purposes
data:extend{
	{
		type = "fluid",
		hidden = true,
		name = "awesome-points",
		icon = graphics.."icons/coupon.png",
		icon_size = 64,
		subgroup = "special",
		order = "z",
		default_temperature = 25,
		base_color = {0,0,0},
		flow_color = {0,0,0}
	}
}
-- change vanilla "coin" to be a Coupon
local coupon = data.raw.item.coin
coupon.flags = nil
coupon.icon = graphics.."icons/coupon.png"
coupon.icon_size = 64
coupon.icon_mipmaps = 0
coupon.subgroup = "special"
coupon.stack_size = 500

local paytable = require("constants.sink-tradein")
for item,reward in pairs(paytable) do
	data:extend{
		{
			type = "recipe",
			name = "sink-"..item,
			icons = {
				{icon = coupon.icon, icon_size = 64},
				{icon = graphics.."icons/"..item..".png", icon_size = 64, scale = 0.25, shift = {-8,8}}
			},
			ingredients = {{item,1}},
			results = {{type="fluid",name="awesome-points",amount=reward}},
			energy_required = 0.01,
			category = "awesome-sink",
			hide_from_player_crafting = true
		}
	}
end
