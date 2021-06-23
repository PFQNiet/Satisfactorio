makeAssemblingMachine{
	name = "constructor",
	size = {3,5},
	category = "constructing",
	energy = 4,
	allow_power_shards = true,
	sounds = copySoundsFrom(data.raw["assembling-machine"]["assembling-machine-1"]),
	subgroup = "production-manufacturer",
	order = "a",
	ingredients = {
		{"reinforced-iron-plate",2},
		{"copper-cable",8}
	}
}
