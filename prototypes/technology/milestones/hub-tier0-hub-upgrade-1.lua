data:extend({{
	type = "technology",
	name = "hub-tier0-hub-upgrade-1",
	order = "a-0-1",
	icon = "__Satisfactorio__/graphics/icons/portable-miner.png",
	icon_size = 64,
	prerequisites = {"the-hub"},
	unit = {
		count = 1,
		time = 1,
		ingredients = {{"hub-tier0-hub-upgrade-1",1}},
	},
	effects = {
		{type="unlock-recipe",recipe="equipment-workshop"},
		-- {type="unlock-recipe",recipe="equipment-workshop-undo"}, -- TODO Implement as part of handler
		{type="unlock-recipe",recipe="portable-miner"},
		{type="character-inventory-slots-bonus",modifier=3},
		{type="nothing",effect_description={"technology-effect.add-storage-to-hub"}}
	}
}})
