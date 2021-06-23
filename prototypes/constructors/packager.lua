makeAssemblingMachine{
	name = "packager",
	size = {5,5},
	category = "packaging",
	pipe_connections = {
		input = {{-1,999}},
		output = {{-1,-999}}
	},
	energy = 10,
	allow_power_shards = true,
	sounds = copySoundsFrom(data.raw["assembling-machine"]["assembling-machine-2"]),
	subgroup = "production-manufacturer",
	order = "g",
	ingredients = {
		{"steel-beam",20},
		{"rubber",10},
		{"plastic",10}
	}
}
