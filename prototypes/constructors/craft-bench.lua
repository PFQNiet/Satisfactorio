local sounds = copySoundsFrom(data.raw["assembling-machine"]["assembling-machine-1"])
sounds.working_sound.sound[1].filename = "__base__/sound/manual-repair-simple.ogg"
local bench = makeAssemblingMachine{
	name = "craft-bench",
	size = {3,2},
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
