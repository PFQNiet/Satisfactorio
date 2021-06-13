local name = "coal"
data:extend({{
	name = "scanner-"..name,
	localised_name = {"recipe-name.scanner",{"entity-name."..name}},
	icons = {
		{icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/resource-scanner-white.png", icon_size = 64, scale = 0.25, shift = {-8,8}}
	},
	type = "recipe",
	ingredients = {},
	result = name,
	energy_required = 1,
	category = "resource-scanner",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	hide_from_player_crafting = true,
	always_show_products = true,
	enabled = false
}})
