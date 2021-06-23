local name = "blade-runners"
local equipment = makeEquipment{
	name = name,
	subgroup = "armor",
	order = "b",
	type = "movement-bonus-equipment",
	energy_source = {
		type = "electric",
		usage_priority = "secondary-input"
	},
	properties = {
		energy_consumption = "1MW",
		movement_bonus = 0.5
	},
	ingredients = {
		{"quickwire",50},
		{"modular-frame",3},
		{"rotor",3}
	},
	craft_time = 20/4
}

-- create a fake generator item to power the exoskeleton
equipment.grid.width = 2
local fakegenitem = {
	type = "item",
	name = name.."-power",
	localised_name = {"entity-name.generator-buffer",{"item-name."..name}},
	icon = graphics.."icons/battery.png",
	icon_size = 64,
	stack_size = 1,
	flags = {"hidden"},
	place_as_equipment_result = name.."-power"
}
local fakegen = {
	type = "generator-equipment",
	name = name.."-power",
	localised_name = {"entity-name.generator-buffer",{"item-name."..name}},
	sprite = {
		filename = graphics.."icons/battery.png",
		size = {64,64}
	},
	categories = {name},
	energy_source = {
		type = "electric",
		usage_priority = "primary-output"
	},
	power = "1MW",
	shape = {
		width = 1,
		height = 1,
		type = "full"
	}
}
data:extend{fakegenitem, fakegen}
