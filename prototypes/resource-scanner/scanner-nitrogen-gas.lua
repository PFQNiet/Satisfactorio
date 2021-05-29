local name = "nitrogen-gas"
data:extend({{
	name = "scanner-"..name,
	localised_name = {"recipe-name.scanner",{"fluid-name."..name}},
	type = "recipe",
	ingredients = {},
	results = {{type="fluid",name=name,amount=1}},
	energy_required = 1,
	category = "resource-scanner",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	hide_from_player_crafting = true,
	always_show_products = true,
	enabled = false
}})
