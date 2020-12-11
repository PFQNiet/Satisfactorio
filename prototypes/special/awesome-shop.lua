-- the shop is an assembler that "dispenses" items for coupons ("coin")
local name = "awesome-shop"
local shop = {
	animation = {
		north = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ns.png",
			size = {96,64}
		},
		east = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ew.png",
			size = {64,96}
		},
		south = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ns.png",
			size = {96,64}
		},
		west = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ew.png",
			size = {64,96}
		}
	},
	collision_box = {{-1.2,-0.7},{1.2,0.7}},
	corpse = "big-remnants",
	crafting_categories = {"awesome-shop"},
	crafting_speed = 1,
	dying_explosion = "big-explosion",
	energy_source = {type = "void"},
	energy_usage = "1W",
	open_sound = {
		filename = "__base__/sound/machine-open.ogg",
		volume = 0.5
	},
	close_sound = {
		filename = "__base__/sound/machine-close.ogg",
		volume = 0.5
	},
	-- working_sound = data.raw['assembling-machine']['assembling-machine-1'].working_sound,
	flags = {
		"placeable-neutral",
		"placeable-player",
		"player-creation"
	},
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	max_health = 1,
	minable = {
		mining_time = 1,
		result = name
	},
	name = name,
	selection_box = {{-1.5,-1},{1.5,1}},
	type = "assembling-machine"
}

local shopitem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "s-b["..name.."]",
	place_result = name,
	stack_size = 1,
	subgroup = "special",
	type = "item"
}

local ingredients = {
	{"iron-gear-wheel",200},
	{"iron-plate",10},
	{"copper-cable",30}
}
local shoprecipe = {
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
local _group = data.raw['item-subgroup'][shopitem.subgroup]
local shoprecipe_undo = {
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
	order = _group.order .. "-" .. shopitem.order,
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

data:extend({shop,shopitem,shoprecipe,shoprecipe_undo})

local prices = require(modpath.."constants.sink-cashout")
-- prices = table of [item] = {cost, number}
for item,spec in pairs(prices) do
	local cost = spec[1]
	local count = spec[2]
	local recipe = {
		name = "awesome-shop-"..item,
		type = "recipe",
		ingredients = {{"coin",cost}},
		result = item,
		result_count = count,
		energy_required = 1,
		category = "awesome-shop",
		allow_intermediates = false,
		allow_as_intermediate = false,
		hide_from_stats = true,
		hide_from_player_crafting = true,
		enabled = item == "iron-plate" or item == "iron-stick"
	}
	data:extend({recipe})
end
