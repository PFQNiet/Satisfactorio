-- Minimap and main map are disabled until unlocked by technology later in the game
return {
	events = {
		[defines.events.on_player_created] = function(event)
			local player = game.players[event.player_index]
			player.minimap_enabled = false -- TODO check if player joined after research was complete, and enable minimap if so
			player.permission_group.set_allows_action(defines.input_action.edit_custom_tag, false)
			player.permission_group.set_allows_action(defines.input_action.delete_custom_tag, false)
		end,
		["open-map"] = function(event)
			-- TODO check if player's force has researched the map
			local player = game.players[event.player_index]
			if player.render_mode == defines.render_mode.game then
				player.print({"message.map-needs-research"})
			else
				-- map was opened somehow, so close it
				player.close_map()
			end
		end,
		["place-marker"] = function(event)
			local player = game.players[event.player_index]
			if player.render_mode == defines.render_mode.chart then
				player.print({"message.tag-needs-beacon"})
			end
		end
	}
}
