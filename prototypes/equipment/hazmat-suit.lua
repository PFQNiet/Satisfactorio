local name = "hazmat-suit"
local equipment = makeEquipment{
	name = name,
	subgroup = "environment",
	order = "b1",
	type = "battery-equipment",
	energy_source = {
		type = "electric",
		usage_priority = "secondary-output",
		buffer_capacity = "12MW"
	},
	ingredients = {
		{"rubber",50},
		{"plastic",50},
		{"alclad-aluminium-sheet",50},
		{"fabric",50}
	},
	craft_time = 30/4
}
equipment.item.resistances = {{type="radiation",percent=100}}

name = "iodine-infused-filter"
local filter = {
	name = name,
	type = "tool",
	durability = 12, -- number of seconds it should last for a single gas cloud
	durability_description_key = "description.gas-mask-durability-key",
	durability_description_value = "description.gas-mask-durability-value",
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	order = "b2["..name.."]",
	subgroup = "environment",
	stack_size = 50
}
local filterrecipe = { -- in Manufacturer
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
copyToHandcraft(filterrecipe, 4, true)

-- "radiation" damage type for when the player has the Suit equipped, but doesn't have any filters
local damage = {
	type = "damage-type",
	name = "radiation-no-filter"
}

data:extend({filter, filterrecipe, damage})
