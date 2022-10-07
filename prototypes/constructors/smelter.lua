local placeholder = require("graphics.placeholders.builder")

makeAssemblingMachine{
	name = "smelter",
	size = {3,5},
	animation = placeholder().fourway().addBox(-1,-2,3,5,{{0,2}},{{0,-2}}).addIcon(graphics.."icons/smelter.png",64).result(),
	category = "smelter",
	energy = 4,
	allow_power_shards = true,
	sounds = copySoundsFrom(data.raw.furnace["stone-furnace"]),
	subgroup = "production-smelter",
	order = "a",
	ingredients = {
		{"iron-rod",5},
		{"wire",8}
	}
}
