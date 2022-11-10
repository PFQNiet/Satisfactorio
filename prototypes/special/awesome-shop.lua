local placeholder = require("graphics.placeholders.builder")

-- the shop is an assembler that "dispenses" items for coupons ("coin")
local shop = makeAssemblingMachine{
	name = "awesome-shop",
	size = {3,2},
	animation = placeholder().fourway().addBox(-1,-0.5,3,2,{},{}).addIcon(graphics.."icons/awesome-shop.png",64).result(),
	category = "awesome-shop",
	sounds = copySoundsFrom(data.raw.roboport.roboport),
	subgroup = "special",
	order = "d",
	ingredients = {
		{"screw",200},
		{"iron-plate",10},
		{"copper-cable",30}
	}
}
shop.machine.bottleneck_ignore = true

-- automatically sort shop recipes by insertion order
local shopgrouporder = {
	letters = "abcdefghijklmnopqrstuvwxyz"
}
---@param item string
---@param cost uint8
---@param qty uint8
---@param subgroup string
local function createShopRecipe(item, cost, qty, subgroup)
	local order = (shopgrouporder[subgroup] or 0) + 1
	shopgrouporder[subgroup] = order
	data:extend{
		{
			type = "recipe",
			name = "awesome-shop-"..item,
			icons = {
				{icon = graphics.."icons/"..item..".png", icon_size = 64},
				{icon = graphics.."icons/coupon.png", icon_size = 64, scale = 0.25, shift = {-8,8}}
			},
			ingredients = {{"coin",cost}},
			result = item,
			result_count = qty,
			energy_required = 1,
			category = "awesome-shop",
			subgroup = "awesome-shop-"..subgroup,
			order = shopgrouporder.letters:sub(order,order),
			allow_intermediates = false,
			allow_as_intermediate = false,
			hide_from_stats = true,
			hide_from_player_crafting = true,
			enabled = false
		}
	}
end

data:extend{
	{type="item-subgroup", group="awesome-shop", name="awesome-shop-hard-drive", order="a"},
	-- {type="item-subgroup", group="awesome-shop", name="awesome-shop-statues", order="b"},
	{type="item-subgroup", group="awesome-shop", name="awesome-shop-equipment", order="c"},
	{type="item-subgroup", group="awesome-shop", name="awesome-shop-biomass", order="d"},
	{type="item-subgroup", group="awesome-shop", name="awesome-shop-electronics", order="e"},
	{type="item-subgroup", group="awesome-shop", name="awesome-shop-minerals", order="f"},
	{type="item-subgroup", group="awesome-shop", name="awesome-shop-standard", order="g"},
	{type="item-subgroup", group="awesome-shop", name="awesome-shop-industrial", order="h"},
	{type="item-subgroup", group="awesome-shop", name="awesome-shop-communications", order="i"},
	{type="item-subgroup", group="awesome-shop", name="awesome-shop-oil-products", order="j"}
}
createShopRecipe("hard-drive", 5, 1, "hard-drive")
-- createShopRecipe("adequate-pioneering", 25, 1, "statues")
-- createShopRecipe("pretty-good-pioneering", 50, 1, "statues")
-- createShopRecipe("satisfactory-pioneering", 150, 1, "statues")
-- createShopRecipe("silver-hog-statue", 50, 1, "statues")
-- createShopRecipe("lizard-doggo-statue", 100, 1, "statues")
-- createShopRecipe("confusing-creature-statue", 200, 1, "statues")
-- createShopRecipe("golden-nut-statue", 1000, 1, "statues")
-- createShopRecipe("rifle-cartridge", 2, 5, "equipment")
-- createShopRecipe("spiked-rebar", 1, 25, "equipment")
createShopRecipe("map-marker", 1, 10, "equipment")
-- createShopRecipe("ficsit-coffee-cup", 1, 1, "equipment")
-- createShopRecipe("colour-cartridge", 1, 50, "equipment")
createShopRecipe("nobelisk", 1, 10, "equipment")
createShopRecipe("gas-filter", 1, 25, "equipment")
createShopRecipe("medicinal-inhaler", 1, 5, "equipment")
createShopRecipe("parachute", 1, 10, "equipment")
createShopRecipe("iodine-infused-filter", 1, 10, "equipment")
createShopRecipe("biomass", 1, 200, "biomass")
createShopRecipe("solid-biofuel", 2, 200, "biomass")
createShopRecipe("fabric", 3, 100, "biomass")
createShopRecipe("packaged-liquid-biofuel", 3, 100, "biomass")
createShopRecipe("copper-cable", 2, 100, "electronics")
createShopRecipe("wire", 1, 500, "electronics")
createShopRecipe("ai-limiter", 3, 100, "electronics")
createShopRecipe("quickwire", 1, 500, "electronics")
createShopRecipe("circuit-board", 3, 200, "electronics")
createShopRecipe("high-speed-connector", 4, 100, "electronics")
createShopRecipe("battery", 5, 100, "electronics")
createShopRecipe("concrete", 1, 100, "minerals")
createShopRecipe("black-powder", 3, 100, "minerals")
createShopRecipe("silica", 1, 100, "minerals")
createShopRecipe("iron-plate", 1, 100, "standard")
createShopRecipe("iron-rod", 1, 100, "standard")
createShopRecipe("screw", 2, 500, "standard")
createShopRecipe("copper-sheet", 1, 100, "standard")
createShopRecipe("reinforced-iron-plate", 3, 100, "standard")
createShopRecipe("steel-beam", 1, 100, "standard")
createShopRecipe("steel-pipe", 1, 100, "standard")
createShopRecipe("encased-industrial-beam", 3, 100, "standard")
createShopRecipe("alclad-aluminium-sheet", 2, 100, "standard")
createShopRecipe("modular-frame", 4, 50, "industrial")
createShopRecipe("heavy-modular-frame", 6, 50, "industrial")
createShopRecipe("rotor", 3, 100, "industrial")
createShopRecipe("stator", 3, 100, "industrial")
createShopRecipe("motor", 5, 50, "industrial")
createShopRecipe("heat-sink", 3, 100, "industrial")
createShopRecipe("turbo-motor", 8, 50, "industrial")
createShopRecipe("crystal-oscillator", 4, 100, "communications")
createShopRecipe("computer", 6, 50, "communications")
createShopRecipe("radio-control-unit", 7, 50, "communications")
createShopRecipe("supercomputer", 8, 50, "communications")
createShopRecipe("empty-canister", 2, 100, "oil-products")
createShopRecipe("petroleum-coke", 1, 200, "oil-products")
createShopRecipe("plastic", 1, 100, "oil-products")
createShopRecipe("rubber", 1, 100, "oil-products")
createShopRecipe("packaged-fuel", 3, 100, "oil-products")
createShopRecipe("polymer-resin", 1, 200, "oil-products")
