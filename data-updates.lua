-- add a description to all recipes for which a *-manual version exists, explaining that it can be hand-crafted
local string = require("scripts.lualib.string")
local workstations = {
	["craft-bench"] = "craft-bench",
	["equipment"] = "equipment-workshop"
}
for _,recipe in pairs(data.raw.recipe) do
	if string.ends_with(recipe.name, "-manual") then
		local auto = data.raw.recipe[string.remove_suffix(recipe.name, "-manual")]
		if auto then
			local workstation = workstations[recipe.category]
			local workname = data.raw['assembling-machine'][workstation].localised_name or {"entity-name."..workstation}
			if auto.localised_description then
				auto.localised_description = {"", {"recipe-description.can-be-handcrafted", workstation, workname}, "\n", auto.localised_description}
			else
				auto.localised_description = {"recipe-description.can-be-handcrafted", workstation, workname}
			end
		end
	end
end

-- give all tiles a fixed pollution absorption so that radioactivity falls off with distance rather than based on terrain
-- one chunk contains 1024 tiles
-- (Note: divide radiation numbers by 100 so that it doesn't full-strength the redness on the map)
for _,tile in pairs(data.raw.tile) do
	tile.pollution_absorption_per_second = 40/60/1024 -- 40.00 pollution per minute per chunk
end
-- trees don't absorb radiation
for _,tree in pairs(data.raw.tree) do
	tree.emissions_per_second = 0
end

-- remove "resource-layer" from the collision masks of water tiles
for _,tile in pairs(data.raw.tile) do
	if tile.draw_in_water_layer then
		for i,mask in pairs(tile.collision_mask) do
			if mask == "resource-layer" then
				table.remove(tile.collision_mask,i)
				break
			end
		end
	end
end

-- if a car is destructible (has more then 1 max health) then give it resistance to all damage and also make it breathe air (to receive poison damage)
local resists = {}
for name,_ in pairs(data.raw['damage-type']) do
	table.insert(resists, {type=name,percent=100})
end
for _,car in pairs(data.raw.car) do
	if car.max_health > 1 then
		if not car.flags then car.flags = {} end
		table.insert(car.flags,"breaths-air")
		car.resistances = resists
	end
end
