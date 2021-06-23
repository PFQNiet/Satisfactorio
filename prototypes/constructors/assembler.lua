makeAssemblingMachine{
	name = "assembler",
	size = {5,7},
	category = "assembling",
	energy = 15,
	allow_power_shards = true,
	sounds = copySoundsFrom(data.raw["assembling-machine"]["assembling-machine-2"]),
	subgroup = "production-manufacturer",
	order = "b",
	ingredients = {
		{"reinforced-iron-plate",8},
		{"rotor",4},
		{"copper-cable",10}
	}
}
