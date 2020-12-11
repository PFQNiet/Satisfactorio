local name = "paleberry"
data:extend({{
	name = "scanner-"..name,
	localised_name = {"recipe-name.scanner",{"entity-name."..name}},
	type = "recipe",
	ingredients = {},
	result = name,
	energy_required = 1,
	category = "object-scanner",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	hide_from_player_crafting = true,
	always_show_products = true,
	enabled = false
}})
