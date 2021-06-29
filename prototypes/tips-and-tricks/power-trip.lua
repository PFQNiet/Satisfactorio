return {
	type = "tips-and-tricks-item",
	name = "power-trip",
	order = "d[power-trip]",
	tag = "[img=utility/electricity_icon]",
	trigger = {
		-- type = "low-power",
		-- count = 1
		type = "unlocked-recipe",
		recipe = "smelter" -- first biomass burner acquired
	},
	image = graphics.."tips-and-tricks/power-trip.png"
}
