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

---@param event on_technology_effects_reset
local on_technology_effects_reset = function(event)
	local force = event.force
	force.recipes['infinity-storage-container'].enabled = true
	force.recipes['infinity-pipeline'].enabled = true
end

return {
	on_init = function()
		remote.call("Satisfactorio", "set_no_victory", true)
	end,
	add_commands = function()
		if not commands.commands['character'] then
			commands.add_command("character", {"command.character"}, function(event)
				local player = game.players[event.player_index]
				local mode = event.parameter or (player.character and "off" or "on")
				if mode == "on" then
					if not player.character then
						player.character = player.surface.create_entity{
							name = "character",
							position = player.surface.find_non_colliding_position("character", player.position, 0, 0.1),
							force = player.force
						}
					end
				elseif mode == "off" then
					if player.character then
						local char = player.character
						player.character = nil
						char.destroy()
					end
				end
			end)
		end
	end,
	events = {
		[defines.events.on_player_created] = on_player_created,
		[defines.events.on_technology_effects_reset] = on_technology_effects_reset
	}
}
