local sounds = copySoundsFrom(data.raw["assembling-machine"]["assembling-machine-1"])
sounds.working_sound.sound[1].filename = "__base__/sound/manual-repair-simple.ogg"
makeAssemblingMachine{
	name = "equipment-workshop",
	size = {5,3},
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
