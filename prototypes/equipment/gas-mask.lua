local name = "gas-mask"
local item = {
	type = "armor",
	name = name,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	infinite = true,
	order = "s-c1["..name.."]",
	subgroup = "environment",
	stack_size = 1,
	resistances = {
		{
			type = "poison",
			percent = 100
		}
	},
	equipment_grid = name
}
local grid = {
	type = "equipment-grid",
	name = name,
	locked = true,
	width = 1,
	height = 1,
	equipment_categories = {name}
}
local category = {
	type = "equipment-category",
	name = name
}
local fakeitem = {
	type = "item",
	name = name.."-equipment",
	icon = "__Satisfactorio__/graphics/icons/gas-filter.png",
	icon_size = 64,
	stack_size = 1,
	flags = {"hidden"},
	place_as_equipment_result = name.."-equipment"
}
local fakeequip = {
	type = "battery-equipment",
	name = name.."-equipment",
	sprite = {
		filename = "__Satisfactorio__/graphics/icons/gas-filter.png",
		size = {64,64}
	},
	categories = {name},
	energy_source = {
		type = "electric",
		usage_priority = "secondary-output",
		buffer_capacity = "45MJ"
	},
	shape = {
		width = 1,
		height = 1,
		type = "full"
	}
}
local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"rubber",100},
		{"plastic-bar",100},
		{"fabric",100}
	},
	result = name,
	energy_required = 20/4,
	category = "equipment",
	enabled = false
}

name = "gas-filter"
local filter = {
	name = name,
	type = "tool",
	durability = 45, -- number of seconds it should last for a single gas cloud
	durability_description_key = "description.gas-mask-durability-key",
	durability_description_value = "description.gas-mask-durability-value",
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	order = "s-c2["..name.."]",
	subgroup = "environment",
	stack_size = 50
}
local filterrecipe1 = { -- manually in equipment workshop
	name = name.."-manual",
	type = "recipe",
	ingredients = {
		{"coal",5},
		{"rubber",2},
		{"fabric",2}
	},
	result = name,
	energy_required = 2/4,
	category = "equipment",
	hide_from_player_crafting = true,
	enabled = false
}
local filterrecipe2 = { -- in Manufacturer
	name = name,
	type = "recipe",
	ingredients = {
		{"coal",5},
		{"rubber",2},
		{"fabric",2}
	},
	result = name,
	energy_required = 8,
	category = "manufacturing",
	enabled = false
}

-- "poison" damage type for when the player has the Mask equipped, but doesn't have any filters
local damage = {
	type = "damage-type",
	name = "poison-no-filter"
}

data:extend({item, grid, category, fakeitem, fakeequip, recipe, filter, filterrecipe1, filterrecipe2, damage})
