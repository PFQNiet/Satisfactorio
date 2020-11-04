local name = "hazmat-suit"
local item = {
	type = "armor",
	name = name,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	infinite = true,
	order = "s-e1["..name.."]",
	subgroup = "armor",
	stack_size = 1,
	resistances = {
		{
			type = "radiation",
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
	icon = "__Satisfactorio__/graphics/icons/iodine-infused-filter.png",
	icon_size = 64,
	stack_size = 1,
	flags = {"hidden"},
	place_as_equipment_result = name.."-equipment"
}
local fakeequip = {
	type = "battery-equipment",
	name = name.."-equipment",
	sprite = {
		filename = "__Satisfactorio__/graphics/icons/iodine-infused-filter.png",
		size = {64,64}
	},
	categories = {name},
	energy_source = {
		type = "electric",
		usage_priority = "secondary-output",
		buffer_capacity = "12MJ"
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
		{"rubber",50},
		{"plastic-bar",50},
		{"alclad-aluminium-sheet",50},
		{"fabric",50}
	},
	result = name,
	energy_required = 30/4,
	category = "equipment",
	enabled = false
}

name = "iodine-infused-filter"
local filter = {
	name = name,
	type = "tool",
	durability = 12, -- number of seconds it should last for a single gas cloud
	durability_description_key = "description.gas-mask-durability-key",
	durability_description_value = "description.gas-mask-durability-value",
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	order = "s-e2["..name.."]",
	subgroup = "armor",
	stack_size = 50
}
local filterrecipe1 = { -- manually in equipment workshop
	name = name.."-manual",
	type = "recipe",
	ingredients = {
		{"gas-filter",1},
		{"quickwire",8},
		{"rubber",2}
	},
	result = name,
	energy_required = 4/4,
	category = "equipment",
	hide_from_player_crafting = true,
	enabled = false
}
local filterrecipe2 = { -- in Manufacturer
	name = name,
	type = "recipe",
	ingredients = {
		{"gas-filter",1},
		{"quickwire",8},
		{"rubber",2}
	},
	result = name,
	energy_required = 16,
	category = "manufacturing",
	enabled = false
}

-- "radiation" damage type for when the player has the Suit equipped, but doesn't have any filters
local damage = {
	type = "damage-type",
	name = "radiation-no-filter"
}

data:extend({item, grid, category, fakeitem, fakeequip, recipe, filter, filterrecipe1, filterrecipe2, damage})
