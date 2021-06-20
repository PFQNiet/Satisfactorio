-- the Sink is a storage chest that periodically voids itself
-- its GUI will be supplemented by a count of points and a button to claim Coupons
-- since chests can't be rotated and don't draw power, both of these problems will be solved by the entity being an EEI with storage attached
local name = "awesome-sink"
local empty_sprite = {
	filename = "__core__/graphics/empty.png",
	width = 1,
	height = 1
}

local base = {
	type = "electric-energy-interface",
	name = name,
	energy_source = {
		type = "electric",
		buffer_capacity = "30MW",
		input_flow_limit = "30MW",
		usage_priority = "secondary-input",
		drain = "0W"
	},
	energy_usage = "30MW",
	pictures = {
		north = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-n.png",
			size = {256,224}
		},
		east = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-e.png",
			size = {224,256}
		},
		south = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-s.png",
			size = {256,224}
		},
		west = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-w.png",
			size = {224,256}
		}
	},
	max_health = 1,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	collision_box = {{-3.7,-3.2},{3.7,3.2}},
	flags = {
		"placeable-player",
		"player-creation"
	},
	minable = {
		mining_time = 0.5,
		result = name
	},
	open_sound = {
		filename = "__base__/sound/metallic-chest-open.ogg",
		volume = 0.5
	},
	close_sound = {
		filename = "__base__/sound/metallic-chest-close.ogg",
		volume = 0.5
	},
	selection_box = {{-4,-3.5},{4,3.5}},
	selection_priority = 40
}

local storage = {
	collision_box = {{-2.2,-2.2},{2.2,2.2}},
	enable_inventory_bar = false,
	flags = {
		"placeable-off-grid", -- it goes between two grid squares
		"not-on-map"
	},
	open_sound = {
		filename = "__base__/sound/metallic-chest-open.ogg",
		volume = 0.5
	},
	close_sound = {
		filename = "__base__/sound/metallic-chest-close.ogg",
		volume = 0.5
	},
	icon = base.icon,
	icon_size = base.icon_size,
	inventory_size = 1,
	max_health = 1,
	minable = {
		mining_time = 0.5,
		result = name
	},
	name = name.."-box",
	localised_name = {"entity-name."..name},
	picture = empty_sprite,
	placeable_by = {item=name,count=1},
	selection_box = {{-2.5,-2.5},{2.5,2.5}},
	selectable_in_game = false,
	type = "container"
}

local sinkitem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "s-a["..name.."]",
	place_result = name,
	stack_size = 50,
	subgroup = "special",
	type = "item"
}

local ingredients = {
	{"reinforced-iron-plate",15},
	{"copper-cable",30},
	{"concrete",45}
}
local sinkrecipe = {
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 1,
	category = "building",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	enabled = false
}
local _group = data.raw['item-subgroup'][sinkitem.subgroup]
local sinkrecipe_undo = {
	name = name.."-undo",
	localised_name = {"recipe-name.dismantle",{"entity-name."..name}},
	type = "recipe",
	ingredients = {
		{name,1}
	},
	results = ingredients,
	energy_required = 1,
	category = "unbuilding",
	subgroup = _group.group .. "-undo",
	order = _group.order .. "-" .. sinkitem.order,
	allow_decomposition = false,
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	icons = {
		{icon = "__base__/graphics/icons/deconstruction-planner.png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64}
	},
	enabled = false
}

data:extend({base,storage,sinkitem,sinkrecipe,sinkrecipe_undo})

-- pseudo "points" item for stat purposes
data:extend({
	{
		type = "item",
		flags = {"hidden"},
		name = "awesome-points",
		icon = "__Satisfactorio__/graphics/icons/coupon.png",
		icon_size = 64,
		subgroup = "special",
		order = "z",
		stack_size = 1000000
	}
})
-- change vanilla "coin" to be a Coupon
local coupon = data.raw.item.coin
coupon.flags = nil
coupon.icon = "__Satisfactorio__/graphics/icons/coupon.png"
coupon.icon_mipmaps = 1
coupon.subgroup = "special"
coupon.stack_size = 500
