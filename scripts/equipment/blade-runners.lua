-- on equipping body items, populate their equipment grid accordingly
local gear = "blade-runners"
local equip = "exoskeleton-equipment"

local function onEquipBody(event)
	local player = game.players[event.player_index]
	local armour = player.get_inventory(defines.inventory.character_armor)[1]
	if not armour.valid_for_read then return end
	if armour.name == gear then
		-- Satisfactorio "armour" items have a corresponding grid, which is 2x1 and accepts the "equipment-power-source" and its own equipment item
		local grid = armour.grid
		grid.clear()
		grid.put{name = "equipment-power-source"}
		grid.put{name = equip}
	end
end

return {
	events = {
		[defines.events.on_player_armor_inventory_changed] = onEquipBody
	}
}
