-- Minimap and main map are disabled until unlocked by technology later in the game
local maptech = "mam-quartz-frequency-mapping"
return {
	events = {
		[defines.events.on_player_created] = function(event)
			local player = game.players[event.player_index]
			player.minimap_enabled = player.force.technologies[maptech].researched
			player.permission_group.set_allows_action(defines.input_action.edit_custom_tag, false)
			player.permission_group.set_allows_action(defines.input_action.delete_custom_tag, false)
		end,
		["open-map"] = function(event)
			local player = game.players[event.player_index]
			if player.render_mode == defines.render_mode.game then
				if not player.force.technologies[maptech].researched then
					player.print({"message.map-needs-research"})
				else
					player.open_map(player.position)
				end
			else
				-- map was opened, so close it
				player.close_map()
			end
		end,
		["place-marker"] = function(event)
			local player = game.players[event.player_index]
			if player.render_mode == defines.render_mode.chart then
				player.print({"message.tag-needs-beacon"})
			end
		end,
		[defines.events.on_research_finished] = function(event)
			if event.research.name == maptech then
				for _,player in pairs(event.research.force.players) do
					player.minimap_enabled = true
				end
			end
		end
	}
}
