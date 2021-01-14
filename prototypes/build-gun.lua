-- final-fixes stage
-- All undo-able recipes have a corresponding non-undo recipe
local string = require("scripts.lualib.string")

for name,recipe in pairs(data.raw.recipe) do
	if string.ends_with(name, "-undo") then
		-- force-disable the recipe, should really only apply to the-hub-undo but just in case...
		recipe.enabled = false

		local itemname = recipe.ingredients[1][1]
		local item = data.raw.item[itemname] or data.raw['item-with-entity-data'][itemname] or data.raw['rail-planner'][itemname]
		assert(item, "Cannot find item "..itemname)
		if not item.flags then item.flags = {} end
		table.insert(item.flags, "only-in-cursor")
		item.stack_size = math.max(5,item.stack_size) -- must be at least 2 so that the build gun cursor can hold two. Setting 5 makes it play nicer with cheat mode
	end
end
