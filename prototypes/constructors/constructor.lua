local placeholder = require("graphics.placeholders.builder")

makeAssemblingMachine{
	name = "constructor",
	size = {3,5},
	animation = placeholder().fourway().addBox(-1,-2,3,5,{{0,2}},{{0,-2}}).addIcon(graphics.."icons/constructor.png",64).result(),
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
