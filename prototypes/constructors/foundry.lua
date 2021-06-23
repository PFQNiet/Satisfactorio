makeAssemblingMachine{
	name = "foundry",
	size = {5,4},
	category = "foundry",
	energy = 16,
	allow_power_shards = true,
	sounds = copySoundsFrom(data.raw.furnace["electric-furnace"]),
	subgroup = "production-smelter",
	order = "b",
	ingredients = {
		{"modular-frame",10},
		{"rotor",10},
		{"concrete",20}
	}
}
