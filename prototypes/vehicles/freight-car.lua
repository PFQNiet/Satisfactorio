local cargo = data.raw['cargo-wagon']['cargo-wagon']
cargo.inventory_size = 32
cargo.max_health = 1
cargo.weight = 425000/2

cargo = data.raw['item-with-entity-data']['cargo-wagon']
cargo.icon = nil
cargo.icon_size = nil
cargo.icon_mipmaps = nil
cargo.icons = {
	{icon = graphics.."icons/freight-car.png", icon_size = 64},
	{icon = graphics.."icons/hub-parts.png", icon_size = 64, scale = 0.25, shift = {-8,8}}
}
cargo.stack_size = 50

local recipe = makeBuildingRecipe{
	name = "cargo-wagon",
	ingredients = {
		{"heavy-modular-frame",4},
		{"steel-pipe",10}
	},
	result = "cargo-wagon"
}
data.raw.recipe['cargo-wagon'] = recipe
