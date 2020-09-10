-- milestone "recipes" and dummy items
data:extend({
	{
		icon = "__Satisfactorio__/graphics/icons/foundation.png",
		icon_size = 64,
		name = "hub-tier1-base-building",
		order = "a",
		stack_size = 1,
		subgroup = "hub-tier1",
		type = "tool",
		infinite = true,
		flags = {"hidden"}
	},
	{
		name = "hub-tier1-base-building",
		type = "recipe",
		ingredients = {
			{"concrete",200},
			{"iron-plate",100},
			{"iron-stick",100}
		},
		result = "hub-tier1-base-building",
		energy_required = 120,
		category = "hub-progressing",
		allow_intermediates = false,
		allow_as_intermediate = false,
		hide_from_stats = true,
		hide_from_player_crafting = true,
		enabled = false
	},
	{
		icon = "__Satisfactorio__/graphics/icons/conveyor-splitter.png",
		icon_size = 64,
		name = "hub-tier1-logistics",
		order = "b",
		stack_size = 1,
		subgroup = "hub-tier1",
		type = "tool",
		infinite = true,
		flags = {"hidden"}
	},
	{
		name = "hub-tier1-logistics",
		type = "recipe",
		ingredients = {
			{"iron-plate",150},
			{"iron-stick",150},
			{"wire",300}
		},
		result = "hub-tier1-logistics",
		energy_required = 240,
		category = "hub-progressing",
		allow_intermediates = false,
		allow_as_intermediate = false,
		hide_from_stats = true,
		hide_from_player_crafting = true,
		enabled = false
	},
	{
		icon = "__Satisfactorio__/graphics/icons/mam.png",
		icon_size = 64,
		name = "hub-tier1-field-research",
		order = "c",
		stack_size = 1,
		subgroup = "hub-tier1",
		type = "tool",
		infinite = true,
		flags = {"hidden"}
	},
	{
		name = "hub-tier1-field-research",
		type = "recipe",
		ingredients = {
			{"wire",300},
			{"screw",300},
			{"iron-plate",100}
		},
		result = "hub-tier1-field-research",
		energy_required = 180,
		category = "hub-progressing",
		allow_intermediates = false,
		allow_as_intermediate = false,
		hide_from_stats = true,
		hide_from_player_crafting = true,
		enabled = false
	}
})
