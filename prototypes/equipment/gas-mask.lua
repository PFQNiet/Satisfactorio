local name = "gas-mask"
local equipment = makeEquipment{
	name = name,
	subgroup = "environment",
	order = "a1",
	type = "battery-equipment",
	energy_source = {
		type = "electric",
		usage_priority = "secondary-output",
		buffer_capacity = "45MW"
	},
	ingredients = {
		{"rubber",100},
		{"plastic",100},
		{"fabric",100}
	},
	craft_time = 20/4
}
equipment.item.resistances = {{type="poison",percent=100}}

name = "gas-filter"
local filter = {
	name = name,
	type = "tool",
	durability = 45, -- number of seconds it should last for a single gas cloud
	durability_description_key = "description.gas-mask-durability-key",
	durability_description_value = "description.gas-mask-durability-value",
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	order = "a2["..name.."]",
	subgroup = "environment",
	stack_size = 50
}
local filterrecipe = { -- in Manufacturer
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
copyToHandcraft(filterrecipe, 2, true)

-- "poison" damage type for when the player has the Mask equipped, but doesn't have any filters
local damage = {
	type = "damage-type",
	name = "poison-no-filter"
}

data:extend({filter, filterrecipe, damage})
