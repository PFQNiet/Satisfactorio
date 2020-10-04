-- on equipping body items, populate their equipment grid accordingly
local bodyequipment = {
	["blade-runners"] = "exoskeleton-equipment"
}

local function onEquipBody(event)
	local player = game.players[event.player_index]
	local armour = player.get_inventory(defines.inventory.character_armor)[1]
	if not armour.valid_for_read then return end
	if bodyequipment[armour.name] then
		-- Satisfactorio "armour" items have a corresponding grid, which is 2x1 and accepts the "equipment-power-source" and its own equipment item
		local grid = armour.grid
		grid.clear()
		grid.put{name = "equipment-power-source"}
		grid.put{name = bodyequipment[armour.name]}
	end
end

return {
	events = {
		[defines.events.on_player_armor_inventory_changed] = onEquipBody
	}
}
