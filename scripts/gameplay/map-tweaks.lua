-- Minimap and main map are disabled until unlocked by technology later in the game
local maptech = "mam-quartz-frequency-mapping"
return {
	events = {
		[defines.events.on_player_created] = function(event)
			local player = game.players[event.player_index]
			player.minimap_enabled = player.force.technologies[maptech].researched
		end,
		[defines.events.on_tick] = function(event)
			for _,player in pairs(game.players) do
				if player.render_mode ~= defines.render_mode.game and not player.minimap_enabled then
					player.print({"message.map-needs-research"})
					player.close_map()
				end
			end
		end,
		["open-map"] = function(event)
			local player = game.players[event.player_index]
			if player.render_mode == defines.render_mode.game then
				if not player.minimap_enabled then
					player.print({"message.map-needs-research"})
				else
					player.open_map(player.position)
				end
			else
				-- map was opened, so close it
				player.close_map()
			end
		end,
		[defines.events.on_chart_tag_added] = function(event)
			if event.player_index then
				local player = game.players[event.player_index]
				player.print({"message.tag-needs-beacon"})
				event.tag.destroy()
			end
		end,
		[defines.events.on_chart_tag_modified] = function(event)
			if event.player_index then
				local player = game.players[event.player_index]
				player.print({"message.tag-needs-beacon"})
				-- change it back to prevent editing
				event.tag.text = event.old_text
				event.tag.icon = event.old_icon
			end
		end,
		[defines.events.on_chart_tag_removed] = function(event)
			if event.player_index then
				local player = game.players[event.player_index]
				player.print({"message.tag-needs-beacon"})
				-- create a new tag in its place
				event.force.add_chart_tag(event.tag.surface, {
					position = event.tag.position,
					text = event.tag.text,
					icon = event.tag.icon
				})
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
