local placeholder = require("graphics.placeholders.builder")

makeAssemblingMachine{
	name = "blender",
	size = {9,8},
	animation = placeholder().fourway().addBox(-4,-3.5,9,8,{{-3,3.5},{-1,3.5},{1,3.5},{3,3.5}},{{1,-3.5},{3,-3.5}}).addIcon(graphics.."icons/blender.png", 64).result(),
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
