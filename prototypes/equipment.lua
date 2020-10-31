require("prototypes.equipment.parachute")
require("prototypes.equipment.blade-runners")
require("prototypes.equipment.jetpack")
require("prototypes.equipment.gas-mask")
require("prototypes.equipment.hazmat-suit")

-- generic power source for all equipment
data:extend({
	{
		type = "equipment-category",
		name = "equipment-power-source"
	},
	{
		type = "item",
		name = "equipment-power-source",
		icon = "__Satisfactorio__/graphics/icons/battery.png",
		icon_size = 64,
		stack_size = 1,
		flags = {"hidden"},
		place_as_equipment_result = "equipment-power-source"
	},
	{
		type = "generator-equipment",
		name = "equipment-power-source",
		sprite = {
			filename = "__Satisfactorio__/graphics/icons/battery.png",
			size = {64,64}
		},
		categories = {"equipment-power-source"},
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
	},
	{
		type = "custom-input",
		name = "jump",
		key_sequence = "J",
		consuming = "game-only",
		action = "lua"
	}
})
