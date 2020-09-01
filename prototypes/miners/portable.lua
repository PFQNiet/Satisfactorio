-- repurpose burner mining drill as portable
-- mining speed is 2/3 that of electric miner
local pm = table.deepcopy(data.raw['mining-drill']['burner-mining-drill'])

pm.name = "portable-miner-drill"
pm.vector_to_place_result = {0,0.01}
pm.resource_searching_radius = 0.49
pm.mining_speed = 1/3
pm.energy_source = {type="void"}
pm.collision_box = {{-0.4,-0.4},{0.4,0.4}}
pm.selection_box = {{-0.5,-0.5},{0.5,0.5}}
pm.minable = nil
if not pm.flags then pm.flags = {} end
table.insert(pm.flags,"not-deconstructable")

local pmbox = table.deepcopy(data.raw['container']['wooden-chest'])
pmbox.name = "portable-miner"
pmbox.inventory_size = 1
pmbox.enable_inventory_bar = false
pmbox.minable.result = "portable-miner"
pmbox.selection_priority = (pmbox.selection_priority or 50) + 10 -- increase priority to default + 10
pmbox.placeable_by = {item="portable-miner",count=1}
pmbox.allow_copy_paste = false
pmbox.placeable_off_grid = true
if not pmbox.flags then pmbox.flags = {} end
table.insert(pmbox.flags,"not-blueprintable")
table.insert(pmbox.flags,"no-automated-item-removal")
table.insert(pmbox.flags,"no-copy-paste")
table.insert(pmbox.flags,"placeable-off-grid")

local pmitem = table.deepcopy(data.raw['item']['burner-mining-drill'])
pmitem.name = "portable-miner"
pmitem.stack_size = 1
pmitem.place_result = "portable-miner-drill"

local pmrecipe = {
	name = "portable-miner",
	type = "recipe",
	ingredients = {
		{"iron-plate",2},
		{"iron-stick",4}
	},
	result = "portable-miner",
	energy_required = 1
}

data:extend({pm,pmbox,pmitem,pmrecipe})