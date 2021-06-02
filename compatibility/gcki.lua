-- add compatibility for GCKI
local mod = "GCKI"
if mods[mod] then
	-- add car keys to vehicular transport
	table.insert(data.raw.technology['hub-tier3-vehicular-transport'].effects, {type="unlock-recipe",recipe="car-key"})

	-- tweak recipe of car keys as electronic-circuit is a mid-game item
	-- original recipe is electronic-circuit(2), copper-plate(2), iron-stick(2)
	local recipe = data.raw.recipe['car-key']
	recipe.ingredients[1] = {"map-marker",1}
	recipe.category = "equipment"
end
