local name = "power-slugs"
data:extend({{
	name = "scanner-"..name,
	localised_name = {"recipe-name.scanner-power-slugs"},
	icons = {
		{icon = graphics.."icons/blue-power-slug.png", icon_size = 64},
		{icon = graphics.."icons/object-scanner.png", icon_size = 64, scale = 0.25, shift = {-8,8}}
	},
	type = "recipe",
	ingredients = {},
	result = "blue-power-slug",
	energy_required = 1,
	category = "object-scanner",
	order = "a",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	hide_from_player_crafting = true,
	always_show_products = true,
	enabled = false
}})
