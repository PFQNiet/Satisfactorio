-- when damage is taken from poison gas, if the gas mask is equipped...
-- - if there are gas filters in the player's inventory, then drain 1 durability from it
-- - otherwise damage the player despite resistance
-- uses global['poison-damage'] to track player > last tick poison damage was taken, to prevent multiple clouds from stacking
local function onEquipBody(event)
	local player = game.players[event.player_index]
	local armour = player.get_inventory(defines.inventory.character_armor)[1]
	if not armour.valid_for_read then return end
	if armour.name == "gas-mask" then
		local grid = armour.grid
		grid.clear()
		local power = grid.put{name = "gas-mask-equipment"}
		local inventory = player.get_main_inventory()
		local filter = inventory.find_item_stack("gas-filter")
		if filter then
			local max_durability = game.item_prototypes["gas-filter"].durability
			power.energy = filter.durability / max_durability * power.max_energy
		end
	end
end

local function onDamaged(event)
	local entity = event.entity
	if not (entity and entity.valid and entity.type == "character") then return end
	if event.damage_type.name ~= "poison" then return end
	if not global['poison-damage'] then global['poison-damage'] = {} end
	if not global['poison-damage'][entity.player.index] then global['poison-damage'][entity.player.index] = -100 end
	local mask = entity.get_inventory(defines.inventory.character_armor)[1]
	if not mask.valid_for_read then
		-- no mask so damage is taken in full, but only if it wasn't too recent
		if global['poison-damage'][entity.player.index] + 12 > event.tick then
			-- heal the player for the damage taken
			entity.health = entity.health + event.final_damage_amount
		else
			global['poison-damage'][entity.player.index] = event.tick
		end
	else
		if global['poison-damage'][entity.player.index] + 12 > event.tick then
			-- too recent, no effect
		else
			-- mask equipped, check for and consume filters if available
			local inventory = entity.get_main_inventory()
			local filter = inventory.find_item_stack("gas-filter")
			if not filter then
				entity.damage(event.original_damage_amount, event.force, "poison-no-filter")
			else
				filter.drain_durability(event.original_damage_amount/5) -- durability is in seconds, and base damage is 5/s
				-- update gas mask "equipment" energy - if we got this far, ie resisted poison damage with filter, then we can assume it's all valid
				local equipment = entity.get_inventory(defines.inventory.character_armor)[1].grid.equipment[1]
				local max_durability = game.item_prototypes["gas-filter"].durability
				equipment.energy = filter.valid_for_read and (filter.durability / max_durability * equipment.max_energy) or 0
			end
			global['poison-damage'][entity.player.index] = event.tick
		end
	end
end

return {
	events = {
		[defines.events.on_player_armor_inventory_changed] = onEquipBody,
		[defines.events.on_entity_damaged] = onDamaged
	}
}