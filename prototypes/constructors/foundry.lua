local placeholder = require("graphics.placeholders.builder")

makeAssemblingMachine{
	name = "foundry",
	size = {5,4},
	animation = placeholder().fourway().addBox(-2,-1.5,5,4,{{-1,1.5},{1,1.5}},{{1,-1.5}}).addIcon(graphics.."icons/foundry.png",64).result(),
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
