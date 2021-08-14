local tower = "lookout-tower"

---@param event on_player_driving_changed_state
local function onVehicle(event)
	local player = game.players[event.player_index]
	local entity = event.entity
	if entity and entity.valid and entity.name == tower then
		if player.driving then
			player.zoom = 0.1
		else
			player.zoom = 1
		end
	end
end

return {
	events = {
		[defines.events.on_player_driving_changed_state] = onVehicle
	}
}
