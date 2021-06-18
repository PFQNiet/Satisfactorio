require("prototypes.equipment.parachute")
require("prototypes.equipment.blade-runners")
require("prototypes.equipment.zipline")
require("prototypes.equipment.jetpack")
require("prototypes.equipment.hover-pack")
require("prototypes.equipment.gas-mask")
require("prototypes.equipment.hazmat-suit")

-- Jump!
data:extend({
	{
		type = "custom-input",
		name = "jump",
		key_sequence = "J",
		order = "c",
		consuming = "game-only",
		action = "lua"
	}
})
