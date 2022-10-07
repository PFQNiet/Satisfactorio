local placeholder = require("graphics.placeholders.builder")

-- the Sink is a furnace that converts items into a fake "fluid" for points, which is periodically emptied out to award tickets
-- its GUI will be supplemented by a count of points and a button to claim Coupons
local base = makeAssemblingMachine{
	name = "awesome-sink",
	type = "furnace",
	animation = placeholder().fourway().addBox(-3.5,-3,8,7,{{-0.5,3}},{}).addIcon(graphics.."icons/awesome-sink.png",64).result(),
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
base.machine.allowed_effects = "speed" -- can be sped up by the fake beacon
base.machine.fluid_boxes = {
	{
		base_area = 1000000, -- space for up to 100M fluid because there's no kill like overkill
		production_type = "output",
		pipe_connections = {}
	}
}

data:extend{
	{
		type = "beacon",
		name = "awesome-sink-beacon",
		localised_name = {"entity-name.awesome-sink"},
		icon = base.machine.icon,
		icon_size = base.machine.icon_size,
		energy_source = {type="void"},
		energy_usage = "1W",
		supply_area_distance = 1,
		distribution_effectivity = 1,
		module_specification = {module_slots = 6}, -- fastest belt is 7x the speed of the slowest, or +6 x100%
		allowed_effects = "speed",
		base_picture = empty_graphic,
		animation = empty_graphic,
		max_health = 1,
		collision_box = {{-0.3,-0.3},{0.3,0.3}},
		collision_mask = {},
		selection_box = {{-0.5,-0.5},{0.5,0.5}},
		selectable_in_game = false,
		flags = {
			"hidden",
			"hide-alt-info",
			"not-on-map"
		}
	},
	{
		type = "module",
		name = "awesome-sink-module",
		localised_name = {"entity-name.awesome-sink"},
		icon = base.machine.icon,
		icon_size = base.machine.icon_size,
		stack_size = 50,
		category = "speed",
		tier = 3,
		effect = {
			speed = {bonus=1}
		},
		flags = {
			"hidden",
			"only-in-cursor"
		}
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
			energy_required = 60/112.5, -- base rate that a conveyor mk 1 can carry
			category = "awesome-sink",
			hide_from_player_crafting = true
		}
	}
end
