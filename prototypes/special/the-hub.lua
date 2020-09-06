--[[
13x7 tiles
/-----------\
|           |
|           |
|    TX     |
|           |
|           |
\-----------/
]]

local name = "the-hub"
local hub = {
	allowed_effects = {},
	animation = {
		north = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ns.png",
			size = {416,224},
			shift = {1,0}
		},
		east = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ew.png",
			size = {224,416},
			shift = {0,1}
		},
		south = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ns.png",
			size = {416,224},
			shift = {-1,0}
		},
		west = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ew.png",
			size = {224,416},
			shift = {0,-1}
		}
	},
	collision_box = {{-5.3,-3.3},{7.3,3.3}},
	corpse = "big-remnants",
	crafting_categories = {"nil"},
	crafting_speed = 1,
	dying_explosion = "big-explosion",
	energy_source = {type="void"},
	energy_usage = "1W",
	flags = {
		"placeable-neutral",
		"placeable-player",
		"player-creation",
		"no-automated-item-removal",
		"no-automated-item-insertion"
	},
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	max_health = 1,
	minable = {
		mining_time = 1,
		result = name
	},
	name = name,
	selection_box = {{-6.5,-3.5},{6.5,3.5}},
	type = "assembling-machine"
}
local hubterminal = {
	allowed_effects = {},
	animation = {
		filename = "__base__/graphics/entity/steel-chest/steel-chest.png",
		size = {32,40},
		shift = {0,-0.015625}
	},
	collision_box = {{-0.35,-0.85},{0.35,0.85}},
	corpse = "small-remnants",
	crafting_categories = {"hub-progressing"},
	crafting_speed = 1,
	dying_explosion = "explosion",
	energy_source = {type="void"},
	energy_usage = "1W",
	flags = {
		"placeable-neutral",
		"placeable-player",
		"player-creation",
		"not-blueprintable",
		"placeable-off-grid", -- it goes between two tiles
		"no-automated-item-removal",
		"no-automated-item-insertion"
	},
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	max_health = 1,
	minable = {
		mining_time = 1,
		result = name
	},
	name = name.."-terminal",
	placeable_by = {item=name,count=1},
	selection_box = {{-0.5,-1},{0.5,1}},
	type = "assembling-machine"
}

local hubgraphic_north = {
	type = "simple-entity-with-owner",
	name = name.."-north",
	picture = {
		filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ns.png",
		size = {416,224},
		shift = {1,0}
	},
	collision_box = {{-5.3,-3.3},{7.3,3.3}},
	collision_mask = {"object-layer","floor-layer","water-tile"},
	render_layer = "floor"
}
local hubgraphic_east = {
	type = "simple-entity-with-owner",
	name = name.."-east",
	picture = {
		filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ew.png",
		size = {224,416},
		shift = {0,1}
	},
	collision_box = {{-3.3,-5.3},{3.3,7.3}},
	collision_mask = {"object-layer","floor-layer","water-tile"},
	render_layer = "floor"
}
local hubgraphic_south = {
	type = "simple-entity-with-owner",
	name = name.."-south",
	picture = {
		filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ns.png",
		size = {416,224},
		shift = {-1,0}
	},
	collision_box = {{-7.3,-3.3},{5.3,3.3}},
	collision_mask = {"object-layer","floor-layer","water-tile"},
	render_layer = "floor"
}
local hubgraphic_west = {
	type = "simple-entity-with-owner",
	name = name.."-west",
	picture = {
		filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ew.png",
		size = {224,416},
		shift = {0,-1}
	},
	collision_box = {{-3.3,-7.3},{3.3,5.3}},
	collision_mask = {"object-layer","floor-layer","water-tile"},
	render_layer = "floor"
}

local hubitem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "a["..name.."]",
	place_result = name,
	stack_size = 1,
	subgroup = "special",
	type = "item"
}

local ingredients = {
	{"hub-parts",1}
}
local hubrecipe = {
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 1,
	category = "building",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true
}
local hubrecipe_undo = {
	name = name.."-undo",
	localised_name = name.."-undo",
	type = "recipe",
	ingredients = {
		{name,1}
	},
	results = ingredients,
	energy_required = 1,
	category = "unbuilding",
	subgroup = hubitem.subgroup .. "-undo",
	order = hubitem.order,
	allow_decomposition = false,
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	icons = {
		{icon = "__base__/graphics/icons/deconstruction-planner.png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64}
	}
}

data:extend({hub,hubterminal,hubgraphic_north,hubgraphic_east,hubgraphic_south,hubgraphic_west,hubitem,hubrecipe,hubrecipe_undo})
