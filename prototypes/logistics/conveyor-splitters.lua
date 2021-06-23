local bufferbox = {
	type = "container",
	name = "merger-splitter-box",
	collision_box = {{-0.5,-0.5},{0.5,0.5}},
	collision_mask = {},
	enable_inventory_bar = false,
	flags = {
		"not-on-map",
		"hide-alt-info"
	},
	icon = "__base__/graphics/icons/wooden-chest.png",
	icon_mipmaps = 4,
	icon_size = 64,
	inventory_size = 1,
	max_health = 1,
	picture = empty_graphic,
	selection_box = {{-0.5,-0.5},{0.5,0.5}},
	selectable_in_game = false,
	circuit_wire_max_distance = 1
}
data:extend{bufferbox}

local function makeSplitter(params)
	---@type string
	local name = params.name
	---@type int
	local slots = params.signal_slots or 0
	---@type string
	local order = params.order
	---@type table
	local ingredients = params.ingredients

	local entity = {
		type = "constant-combinator",
		name = name,
		open_sound = basesounds.machine_open,
		close_sound = basesounds.machine_close,
		activity_led_light_offsets = {{0,0},{0,0},{0,0},{0,0}},
		activity_led_sprites = empty_graphic,
		circuit_wire_connection_points = data.raw['constant-combinator']['constant-combinator'].circuit_wire_connection_points,
		item_slot_count = slots,
		sprites = makeRotatedSprite(name, 96, 96),
		max_health = 1,
		icon = graphics.."icons/"..name..".png",
		icon_size = 64,
		collision_box = {{-1.2,-1.2},{1.2,1.2}},
		flags = {
			"placeable-player",
			"player-creation",
			"hide-alt-info"
		},
		friendly_map_color = data.raw['utility-constants'].default.chart.default_friendly_color_by_type.splitter,
		minable = {
			mining_time = 0.5,
			result = name
		},
		selection_box = {{-1.5,-1.5},{1.5,1.5}}
	}

	local item = {
		type = "item",
		name = name,
		icon = graphics.."icons/"..name..".png",
		icon_size = 64,
		stack_size = 50,
		place_result = name,
		subgroup = "belt",
		order = "c[splitter]-"..order.."["..name.."]"
	}

	local recipe = makeBuildingRecipe{
		name = name,
		ingredients = ingredients,
		result = name
	}

	data:extend({entity,item,recipe})
end

makeSplitter{
	name = "conveyor-merger",
	order = "a",
	ingredients = {
		{"iron-plate",2},
		{"iron-rod",2}
	}
}
makeSplitter{
	name = "conveyor-splitter",
	order = "b",
	ingredients = {
		{"iron-plate",2},
		{"copper-cable",2}
	}
}
makeSplitter{
	name = "smart-splitter",
	signal_slots = 3,
	order = "c",
	ingredients = {
		{"reinforced-iron-plate",2},
		{"rotor",2},
		{"ai-limiter",1}
	}
}
makeSplitter{
	name = "programmable-splitter",
	signal_slots = 3*32,
	order = "d",
	ingredients = {
		{"heavy-modular-frame",1},
		{"motor",1},
		{"supercomputer",1}
	}
}

-- signals for Any, Any Undefined and Overflow filters
data:extend{
	{
		type = "virtual-signal",
		name = "signal-any",
		icon = "__base__/graphics/icons/signal/signal_anything.png",
		icon_mipmaps = 4,
		icon_size = 64,
		order = "s[splitter]-a[any]"
	},
	{
		type = "virtual-signal",
		name = "signal-any-undefined",
		icon = "__base__/graphics/icons/signal/signal_each.png",
		icon_mipmaps = 4,
		icon_size = 64,
		order = "s[splitter]-b[any-undefined]"
	},
	{
		type = "virtual-signal",
		name = "signal-overflow",
		icon = "__base__/graphics/icons/signal/signal_everything.png",
		icon_mipmaps = 4,
		icon_size = 64,
		order = "s[splitter]-c[overflow]"
	}
}
