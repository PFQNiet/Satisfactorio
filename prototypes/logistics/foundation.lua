foundation_layer = require("collision-mask-util").get_first_unused_layer()

local name = "foundation"
local foundation = {
	type = "simple-entity-with-owner",
	name = name,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	picture = {
		filename = graphics.."placeholders/"..name..".png",
		size = {128,128},
	},
	collision_box = {{-1.8,-1.8},{1.8,1.8}},
	flags = {
		"placeable-player",
		"player-creation",
		"not-rotatable",
		"not-on-map"
	},
	max_health = 1,
	minable = {
		mining_time = 0.2,
		result = name
	},
	selection_box = {{-2,-2},{2,2}},
	selection_priority = 20,
	render_layer = "lower-radius-visualization",
	collision_mask = {foundation_layer}
}

local foundationitem = {
	type = "item",
	name = name,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	place_result = name,
	stack_size = 50,
	subgroup = "logistics-wall",
	order = "a["..name.."]"
}

local foundationrecipe = makeBuildingRecipe{
	name = name,
	ingredients = {
		{"concrete",6}
	},
	result = name
}

data:extend{foundation,foundationitem,foundationrecipe}

-- custom deconstruction planner for foundation only
data:extend({
	{
		type = "selection-tool",
		name = "deconstruct-foundation",
		subgroup = "tool",
		stack_size = 1,
		icons = {
			{icon = "__base__/graphics/icons/deconstruction-planner.png", icon_size = 64},
			{icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64}
		},
		selection_mode = "any-entity",
		selection_color = {1,0,0},
		selection_cursor_box_type = "not-allowed",
		entity_filters = {name},
		alt_selection_mode = "any-entity",
		alt_selection_color = {0,0,1},
		alt_selection_cursor_box_type = "not-allowed",
		alt_entity_filters = {name},
		flags = {
			"only-in-cursor",
			"spawnable",
			"hidden",
			"not-stackable"
		}
	},
	{
		type = "custom-input",
		name = "deconstruct-foundation",
		key_sequence = "ALT + F",
		order = "d",
		consuming = "game-only",
		action = "spawn-item",
		item_to_spawn = "deconstruct-foundation"
	},
	{
		type = "shortcut",
		name = "deconstruct-foundation",
		action = "spawn-item",
		item_to_spawn = "deconstruct-foundation",
		style = "red",
		technology_to_unlock = "hub-tier1-base-building",
		icon = {
			layers = {
				{filename = "__base__/graphics/icons/deconstruction-planner.png", width=64, height=64},
				{filename = "__Satisfactorio__/graphics/icons/"..name..".png", width=64, height=64}
			}
		},
		order = "s-c[deconstruct-foundation]"
	}
})
