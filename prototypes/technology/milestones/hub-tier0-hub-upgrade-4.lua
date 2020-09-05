data:extend({{
	type = "technology",
	name = "hub-tier0-hub-upgrade-4",
	order = "a-0-4",
	icon = "__Satisfactorio__/graphics/icons/conveyor-belt-mk-1.png",
	icon_size = 64,
	prerequisites = {"hub-tier0-hub-upgrade-3"},
	unit = {
		count = 1,
		time = 1,
		ingredients = {{"hub-tier0-hub-upgrade-4",1}},
	},
	effects = {
		{type="unlock-recipe",recipe="transport-belt"},
		-- {type="unlock-recipe",recipe="transport-belt-undo"}, -- TODO Implement as part of handler
		{type="character-inventory-slots-bonus",modifier=3}
	}
}})
