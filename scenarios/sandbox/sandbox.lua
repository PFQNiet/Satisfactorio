---@param event on_player_created
local on_player_created = function(event)
	local player = game.players[event.player_index]
	local character = player.character
	player.character = nil
	if character then
		character.destroy()
	end

	player.force.chart(player.surface, {{player.position.x - 200, player.position.y - 200}, {player.position.x + 200, player.position.y + 200}})
	player.force.research_all_technologies()
	player.cheat_mode = true
	player.surface.always_day = true

	player.force.recipes['infinity-storage-container'].enabled = true
	player.force.recipes['infinity-pipeline'].enabled = true

	player.print({"msg-introduction"})
end

return {
	events = {
		[defines.events.on_player_created] = on_player_created
	}
}
