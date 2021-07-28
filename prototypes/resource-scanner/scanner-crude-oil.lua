local name = "crude-oil"
data:extend({{
	name = "scanner-"..name,
	localised_name = {"recipe-name.scanner",{"fluid-name."..name}},
	icons = {
		{icon = graphics.."icons/"..name..".png", icon_size = 64},
		{icon = graphics.."icons/resource-scanner-white.png", icon_size = 64, scale = 0.25, shift = {-8,8}}
	},
	type = "recipe",
	ingredients = {},
	results = {{type="fluid",name=name,amount=1}},
	energy_required = 1,
	category = "resource-scanner",
	order = "e",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	hide_from_player_crafting = true,
	always_show_products = true,
	enabled = false
}})
