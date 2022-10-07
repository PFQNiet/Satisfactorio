local placeholder = require("graphics.placeholders.builder")

makeAssemblingMachine{
	name = "manufacturer",
	size = {9,10},
	animation = placeholder().fourway().addBox(-4,-4.5,9,10,{{-3,4.5},{-1,4.5},{1,4.5},{3,4.5}},{{0,-4.5}}).addIcon(graphics.."icons/manufacturer.png",64).result(),
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
