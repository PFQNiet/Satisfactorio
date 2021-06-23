makeAssemblingMachine{
	name = "refinery",
	size = {7,10},
	category = "refining",
	pipe_connections = {
		input = {{-1,999}},
		output = {{-1,-999}}
	},
	energy = 30,
	allow_power_shards = true,
	sounds = copySoundsFrom(data.raw["assembling-machine"]["chemical-plant"]),
	subgroup = "production-manufacturer",
	order = "d",
	ingredients = {
		{"motor",10},
		{"encased-industrial-beam",10},
		{"steel-pipe",30},
		{"copper-sheet",20}
		-- {"copper-sheet",20}
	}
}
