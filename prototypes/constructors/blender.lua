makeAssemblingMachine{
	name = "blender",
	size = {9,8},
	category = "blending",
	pipe_connections = {
		input = {{1,999},{3,999}},
		output = {{3,-999}}
	},
	energy = 75,
	allow_power_shards = true,
	sounds = copySoundsFrom(data.raw["assembling-machine"].centrifuge),
	subgroup = "production-manufacturer",
	order = "e",
	ingredients = {
		{"motor",20},
		{"heavy-modular-frame",10},
		{"aluminium-casing",50},
		{"radio-control-unit",5}
	}
}
