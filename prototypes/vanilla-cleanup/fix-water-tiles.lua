-- in vanilla, water tiles have a collision mask of {"water-tile", "item-layer", "resource-layer", "player-layer", "doodad-layer"}
-- but really it should be {"water-tile", "doodad-layer"}, and items/resources/players should be responsible for colliding with water
-- to fix: loop through tiles and see if they have the water-tile layer. If so, make that the only layer

for _,tile in pairs(data.raw.tile) do
	if tile.collision_mask then
		for _,layer in pairs(tile.collision_mask) do
			if layer == "water-tile" then
				tile.collision_mask = {"water-tile", "doodad-layer"}
				break
			end
		end
	end
end

-- make item-on-ground responsible for colliding with water
local iog = data.raw['item-entity']['item-on-ground']
if not iog.collision_mask then iog.collision_mask = {"item-layer"} end
table.insert(iog.collision_mask, "water-tile")

-- the player also needs to be responsible for water collisions
local char = data.raw.character.character
if not char.collision_mask then char.collision_mask = {"player-layer", "train-layer", "consider-tile-transitions"} end
table.insert(char.collision_mask, "water-tile")

-- Units do too
for _,unit in pairs(data.raw.unit) do
	if not unit.collision_mask then unit.collision_mask = {"player-layer", "train-layer", "not-colliding-with-itself"} end
	table.insert(unit.collision_mask, "water-tile")
end

-- now the pipe can be made buildable on water by excluding water-tile from its collision mask
data.raw.pipe.pipe.collision_mask = {"item-layer", "object-layer", "player-layer"}
