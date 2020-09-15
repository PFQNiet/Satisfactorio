-- make pipes able to be placed on water by changing their collision mask
-- water tiles have a collision mask of {"water-tile", "item-layer", "resource-layer", "player-layer", "doodad-layer"}
-- pipes have a collision mask of {"item-layer", "object-layer", "player-layer", "water-tile"}
-- so change it to {"object-layer", "layer-11"} and add "layer-11" to players, units and items-on-ground
data.raw.pipe.pipe.collision_mask = {"object-layer", "layer-11"}

-- make item-on-ground responsible for colliding with water
local iog = data.raw['item-entity']['item-on-ground']
if not iog.collision_mask then iog.collision_mask = {"item-layer"} end
table.insert(iog.collision_mask, "layer-11")

-- the player also needs to be responsible for water collisions
local char = data.raw.character.character
if not char.collision_mask then char.collision_mask = {"player-layer", "train-layer", "consider-tile-transitions"} end
table.insert(char.collision_mask, "layer-11")

-- Units do too
for _,unit in pairs(data.raw.unit) do
	if not unit.collision_mask then unit.collision_mask = {"player-layer", "train-layer", "not-colliding-with-itself"} end
	table.insert(unit.collision_mask, "layer-11")
end
