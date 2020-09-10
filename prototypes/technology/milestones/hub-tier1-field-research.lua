data:extend({{
	type = "technology",
	name = "hub-tier1-field-research",
	order = "a-1-3",
	icon = "__Satisfactorio__/graphics/icons/mam.png",
	icon_size = 64,
	prerequisites = {"hub-tier0-hub-upgrade-6"},
	unit = {
		count = 1,
		time = 180,
		ingredients = {{"hub-tier1-field-research",1}},
	},
	effects = {
		{type="unlock-recipe",recipe="mam"},
		{type="unlock-recipe",recipe="wooden-chest"},
		{type="unlock-recipe",recipe="map-marker"},
		{type="character-inventory-slots-bonus",modifier=5}
	}
}})
