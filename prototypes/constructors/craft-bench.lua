local placeholder = require("graphics.placeholders.builder")

local sounds = copySoundsFrom(data.raw["assembling-machine"]["assembling-machine-1"])
sounds.working_sound.sound[1].filename = "__base__/sound/manual-repair-simple.ogg"
local bench = makeAssemblingMachine{
	name = "craft-bench",
	size = {3,2},
	animation = placeholder().fourway().addBox(-1,-0.5,3,2,{},{}).addIcon(graphics.."icons/craft-bench.png",64).result(),
	category = "craft-bench",
	sounds = sounds,
	subgroup = "production-workstation",
	order = "a",
	ingredients = {
		{"iron-plate",3},
		{"iron-rod",3}
	}
}
bench.machine.bottleneck_ignore = true
