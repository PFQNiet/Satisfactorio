local mam = makeAssemblingMachine{
	name = "mam",
	size = {4,2},
	category = "mam",
	subgroup = "special",
	order = "b",
	ingredients = {
		{"reinforced-iron-plate",5},
		{"copper-cable",15},
		{"wire",45}
	}
}
mam.machine.draw_entity_info_icon_background = false
mam.machine.return_ingredients_on_change = false
mam.machine.bottleneck_ignore = true
