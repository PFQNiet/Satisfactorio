local name = "power-slugs"
data:extend({{
	name = "scanner-"..name,
	localised_name = {"recipe-name.scanner-power-slugs"},
	type = "recipe",
	ingredients = {},
	result = "green-power-slug",
	energy_required = 1,
	category = "object-scanner",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	hide_from_player_crafting = true,
	always_show_products = true,
	enabled = false
}})
