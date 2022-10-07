local placeholder = require("graphics.placeholders.builder")

makeAssemblingMachine{
	name = "assembler",
	size = {5,7},
	animation = placeholder().fourway().addBox(-2,-3,5,7, {{-1,3},{1,3}}, {{0,-3}}).addIcon(graphics.."icons/assembler.png",64).result(),
	category = "assembling",
	energy = 15,
	allow_power_shards = true,
	sounds = copySoundsFrom(data.raw["assembling-machine"]["assembling-machine-2"]),
	subgroup = "production-manufacturer",
	order = "b",
	ingredients = {
		{"reinforced-iron-plate",8},
		{"rotor",4},
		{"copper-cable",10}
	}
}
