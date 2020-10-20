-- when damage is taken from radiation, if the hazmat suit is equipped...
-- - if there are iodine-infused filters in the player's inventory, then drain 1 durability from it
-- - otherwise damage the player despite resistance
-- doesn't use a debounce timer since radiation damage is already applied periodically
local function onEquipBody(event)
	local player = game.players[event.player_index]
	local armour = player.get_inventory(defines.inventory.character_armor)[1]
	if not armour.valid_for_read then return end
	if armour.name == "hazmat-suit" then
		local grid = armour.grid
		grid.clear()
		local power = grid.put{name = "hazmat-suit-equipment"}
		local inventory = player.get_main_inventory()
		local filter = inventory.find_item_stack("iodine-infused-filter")
		if filter then
			local max_durability = game.item_prototypes["iodine-infused-filter"].durability
			power.energy = filter.durability / max_durability * power.max_energy
		end
	end
end

local function onDamaged(event)
	local entity = event.entity
	if not (entity and entity.valid and entity.type == "character") then return end
	if event.damage_type.name ~= "radiation" then return end
	local mask = entity.get_inventory(defines.inventory.character_armor)[1]
	if not mask.valid_for_read or mask.name ~= "hazmat-suit" then
		-- no mask so damage is taken in full
	else
		-- mask equipped, check for and consume filters if available
		local inventory = entity.get_main_inventory()
		local filter = inventory.find_item_stack("iodine-infused-filter")
		if not filter then
			entity.damage(event.original_damage_amount, event.force, "radiation-no-filter")
		else
			filter.drain_durability(event.original_damage_amount/20) -- durability is in seconds, and base damage is 20/s
			-- update hazmat "equipment" energy - if we got this far, ie resisted radiation damage with filter, then we can assume it's all valid
			local equipment = entity.get_inventory(defines.inventory.character_armor)[1].grid.equipment[1]
			local max_durability = game.item_prototypes["iodine-infused-filter"].durability
			equipment.energy = filter.valid_for_read and (filter.durability / max_durability * equipment.max_energy) or 0
		end
	end
end

return {
	events = {
		[defines.events.on_player_armor_inventory_changed] = onEquipBody,
		[defines.events.on_entity_damaged] = onDamaged
	}
}
