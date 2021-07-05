-- on equipping body items, populate their equipment grid accordingly
local gear = "blade-runners"
local equip = "blade-runners-equipment"

---@param event on_player_armor_inventory_changed
local function onEquipBody(event)
	local player = game.players[event.player_index]
	local armour = player.get_inventory(defines.inventory.character_armor)[1]
	if not armour.valid_for_read then return end
	if armour.name == gear then
		-- Blade runner grid requires power
		local grid = armour.grid
		grid.clear()
		grid.put{name = gear.."-power"}
		grid.put{name = equip}
	end
end

return {
	events = {
		[defines.events.on_player_armor_inventory_changed] = onEquipBody
	}
}
