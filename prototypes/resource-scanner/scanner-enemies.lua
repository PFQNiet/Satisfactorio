local name = "enemies"
data:extend({
	{
		name = "scanner-"..name,
		localised_name = {"recipe-name.scanner",{"item-name."..name}},
		icons = {
			{icon = graphics.."icons/"..name..".png", icon_size = 64},
			{icon = graphics.."icons/object-scanner.png", icon_size = 64, scale = 0.25, shift = {-8,8}}
		},
		type = "recipe",
		ingredients = {},
		result = name,
		energy_required = 1,
		category = "object-scanner",
		order = "f",
		allow_intermediates = false,
		allow_as_intermediate = false,
		hide_from_stats = true,
		hide_from_player_crafting = true,
		always_show_products = true,
		enabled = false
	},
	{
		type = "item",
		name = name,
		icon = graphics.."icons/"..name..".png",
		icon_size = 64,
		flags = {"hidden"},
		stack_size = 1
	}
})
