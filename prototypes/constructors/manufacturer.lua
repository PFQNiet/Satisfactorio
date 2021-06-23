makeAssemblingMachine{
	name = "manufacturer",
	size = {9,10},
	category = "manufacturing",
	energy = 55,
	allow_power_shards = true,
	sounds = copySoundsFrom(data.raw["assembling-machine"]["assembling-machine-3"]),
	subgroup = "production-manufacturer",
	order = "c",
	ingredients = {
		{"motor",5},
		{"heavy-modular-frame",10},
		{"copper-cable",50},
		{"plastic",50}
	}
}
