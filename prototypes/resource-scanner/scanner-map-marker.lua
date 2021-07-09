local name = "map-marker"
data:extend({{
	name = "scanner-"..name,
	localised_name = {"recipe-name.scanner",{"entity-name."..name}},
	icons = {
		{icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/object-scanner.png", icon_size = 64, scale = 0.25, shift = {-8,8}}
	},
	type = "recipe",
	ingredients = {},
	result = name,
	energy_required = 1,
	category = "object-scanner",
	order = "g",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	hide_from_player_crafting = true,
	always_show_products = true
}})
