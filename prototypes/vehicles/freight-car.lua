local cargo = data.raw['cargo-wagon']['cargo-wagon']
cargo.inventory_size = 32
cargo.max_health = 1
cargo.weight = 425000/2

cargo = data.raw['item-with-entity-data']['cargo-wagon']
cargo.icon = nil
cargo.icon_size = nil
cargo.icon_mipmaps = nil
cargo.icons = {
	{icon = "__Satisfactorio__/graphics/icons/freight-car.png", icon_size = 64},
	{icon = "__Satisfactorio__/graphics/icons/hub-parts.png", icon_size = 64, scale = 0.25, shift = {-8,8}}
}

local ingredients = {
	{"heavy-modular-frame",4},
	{"steel-pipe",10}
}
local recipe = {
	name = "cargo-wagon",
	type = "recipe",
	ingredients = ingredients,
	result = "cargo-wagon",
	energy_required = 1,
	category = "building",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	enabled = false
}
data.raw.recipe['cargo-wagon'] = recipe
local _group = data.raw['item-subgroup'][cargo.subgroup]
local recipe_undo = {
	name = "cargo-wagon-undo",
	localised_name = {"recipe-name.dismantle",{"entity-name.cargo-wagon"}},
	type = "recipe",
	ingredients = {
		{"cargo-wagon",1}
	},
	results = ingredients,
	energy_required = 1,
	category = "unbuilding",
	subgroup = _group.group .. "-undo",
	order = _group.order .. "-" .. cargo.order,
	allow_decomposition = false,
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	icons = {
		{icon = "__base__/graphics/icons/deconstruction-planner.png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/freight-car.png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/hub-parts.png", icon_size = 64, scale = 0.25, shift = {-8,8}}
	},
	enabled = false
}
data:extend({recipe_undo})
