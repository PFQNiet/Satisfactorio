-- milestone "recipes" and dummy items
data:extend({
	{
		icon = "__Satisfactorio__/graphics/icons/portable-miner.png",
		icon_size = 64,
		name = "hub-tier0-hub-upgrade-1",
		order = "a",
		stack_size = 1,
		subgroup = "hub-tier0",
		type = "tool",
		infinite = true,
		flags = {"hidden"}
	},
	{
		name = "hub-tier0-hub-upgrade-1",
		type = "recipe",
		ingredients = {
			{"iron-stick",10}
		},
		result = "hub-tier0-hub-upgrade-1",
		energy_required = 1,
		category = "hub-progressing",
		allow_intermediates = false,
		allow_as_intermediate = false,
		hide_from_stats = true,
		hide_from_player_crafting = true
	},
	{
		icon = "__Satisfactorio__/graphics/icons/copper-ingot.png",
		icon_size = 64,
		name = "hub-tier0-hub-upgrade-2",
		order = "b",
		stack_size = 1,
		subgroup = "hub-tier0",
		type = "tool",
		infinite = true,
		flags = {"hidden"}
	},
	{
		name = "hub-tier0-hub-upgrade-2",
		type = "recipe",
		ingredients = {
			{"iron-stick",20},
			{"iron-plate",10}
		},
		result = "hub-tier0-hub-upgrade-2",
		energy_required = 1,
		category = "hub-progressing",
		allow_intermediates = false,
		allow_as_intermediate = false,
		hide_from_stats = true,
		hide_from_player_crafting = true,
		enabled = false
	},
	{
		icon = "__Satisfactorio__/graphics/icons/concrete.png",
		icon_size = 64,
		name = "hub-tier0-hub-upgrade-3",
		order = "c",
		stack_size = 1,
		subgroup = "hub-tier0",
		type = "tool",
		infinite = true,
		flags = {"hidden"}
	},
	{
		name = "hub-tier0-hub-upgrade-3",
		type = "recipe",
		ingredients = {
			{"iron-plate",20},
			{"iron-stick",20},
			{"wire",20}
		},
		result = "hub-tier0-hub-upgrade-3",
		energy_required = 1,
		category = "hub-progressing",
		allow_intermediates = false,
		allow_as_intermediate = false,
		hide_from_stats = true,
		hide_from_player_crafting = true,
		enabled = false
	},
	{
		icon = "__Satisfactorio__/graphics/icons/conveyor-belt-mk-1.png",
		icon_size = 64,
		name = "hub-tier0-hub-upgrade-4",
		order = "d",
		stack_size = 1,
		subgroup = "hub-tier0",
		type = "tool",
		infinite = true,
		flags = {"hidden"}
	},
	{
		name = "hub-tier0-hub-upgrade-4",
		type = "recipe",
		ingredients = {
			{"iron-plate",75},
			{"copper-cable",20},
			{"concrete",10}
		},
		result = "hub-tier0-hub-upgrade-4",
		energy_required = 1,
		category = "hub-progressing",
		allow_intermediates = false,
		allow_as_intermediate = false,
		hide_from_stats = true,
		hide_from_player_crafting = true,
		enabled = false
	},
	{
		icon = "__Satisfactorio__/graphics/icons/miner-mk-1.png",
		icon_size = 64,
		name = "hub-tier0-hub-upgrade-5",
		order = "e",
		stack_size = 1,
		subgroup = "hub-tier0",
		type = "tool",
		infinite = true,
		flags = {"hidden"}
	},
	{
		name = "hub-tier0-hub-upgrade-5",
		type = "recipe",
		ingredients = {
			{"iron-stick",75},
			{"copper-cable",50},
			{"concrete",20}
		},
		result = "hub-tier0-hub-upgrade-5",
		energy_required = 1,
		category = "hub-progressing",
		allow_intermediates = false,
		allow_as_intermediate = false,
		hide_from_stats = true,
		hide_from_player_crafting = true,
		enabled = false
	},
	{
		icon = "__Satisfactorio__/graphics/icons/mycelia.png",
		icon_size = 64,
		name = "hub-tier0-hub-upgrade-6",
		order = "f",
		stack_size = 1,
		subgroup = "hub-tier0",
		type = "tool",
		infinite = true,
		flags = {"hidden"}
	},
	{
		name = "hub-tier0-hub-upgrade-6",
		type = "recipe",
		ingredients = {
			{"iron-stick",100},
			{"iron-plate",100},
			{"wire",100},
			{"concrete",50}
		},
		result = "hub-tier0-hub-upgrade-6",
		energy_required = 1,
		category = "hub-progressing",
		allow_intermediates = false,
		allow_as_intermediate = false,
		hide_from_stats = true,
		hide_from_player_crafting = true,
		enabled = false
	}
})
