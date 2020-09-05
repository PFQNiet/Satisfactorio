data:extend({{
	type = "technology",
	name = "hub-tier0-hub-upgrade-5",
	order = "a-0-5",
	icon = "__Satisfactorio__/graphics/icons/miner-mk-1.png",
	icon_size = 64,
	prerequisites = {"hub-tier0-hub-upgrade-4"},
	unit = {
		count = 1,
		time = 1,
		ingredients = {{"hub-tier0-hub-upgrade-5",1}},
	},
	effects = {
		{type="unlock-recipe",recipe="miner-mk-1"},
		-- {type="unlock-recipe",recipe="miner-mk-1-undo"}, -- TODO Implement as part of handler
		{type="unlock-recipe",recipe="iron-chest"},
		-- {type="unlock-recipe",recipe="iron-chest-undo"}, -- TODO Implement as part of handler
		{type="nothing",effect_description={"technology-effect.add-biomass-burner-to-hub"}}
	}
}})
