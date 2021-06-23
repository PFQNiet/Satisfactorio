makeAssemblingMachine{
	name = "smelter",
	size = {3,5},
	category = "smelter",
	energy = 4,
	allow_power_shards = true,
	sounds = copySoundsFrom(data.raw.furnace["stone-furnace"]),
	subgroup = "production-smelter",
	order = "a",
	ingredients = {
		{"iron-rod",5},
		-- {"iron-rod",5},
		{"wire",8}
	}
}
