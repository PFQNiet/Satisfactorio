local placeholder = require("graphics.placeholders.builder")

local sounds = copySoundsFrom(data.raw["assembling-machine"]["assembling-machine-1"])
sounds.working_sound.sound[1].filename = "__base__/sound/manual-repair-simple.ogg"
local bench = makeAssemblingMachine{
	name = "equipment-workshop",
	size = {5,3},
	animation = placeholder().fourway().addBox(-2,-1,5,3,{},{}).addIcon(graphics.."icons/equipment-workshop.png",64).result(),
	category = "equipment",
	sounds = sounds,
	subgroup = "production-workstation",
	order = "b",
	ingredients = {
		{"iron-plate",6},
		{"iron-rod",4}
		-- {"iron-rod",4}
	}
}
bench.machine.bottleneck_ignore = true
