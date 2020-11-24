local tip = data.raw['tips-and-tricks-item']['ghost-building']
tip.simulation = {
	init = [[
		player = game.create_test_player{name = "Niet"}
		player.teleport({0, 2})
		game.camera_player = player
		game.camera_player_cursor_position = player.position
		game.camera_alt_info = true
		
		step_1 = function()
			player.cursor_stack.set_stack{name = "smelter"}
			script.on_nth_tick(1, function()
				if game.move_cursor({position = {-5, -2}}) then
					step_2()
				end
			end)
		end
		
		step_2 = function()
			script.on_nth_tick(1, function()
				local finished = game.move_cursor({position = {5, -2}, speed = 0.1})
				player.build_from_cursor
				{
					position = game.camera_player_cursor_position,
					alt = true
				}
				if finished then step_3() end
			end)
		end
		
		step_3 = function()
			script.on_nth_tick(1, function()
				if game.move_cursor({position = player.position}) then
					reset()
				end
			end)
		end
		
		reset = function()
			local reset_tick = game.tick + 60
			player.cursor_stack.clear()
			script.on_nth_tick(1, function()
				if game.tick >= reset_tick then
					for k, v in pairs (game.surfaces[1].find_entities_filtered{type = "entity-ghost"}) do
						v.destroy()
					end
					start()
				end
			end)
		end
		
		start = function()
			local start_tick = game.tick + 60
			script.on_nth_tick(1, function()
				if game.tick >= start_tick then
					step_1()
				end
			end)
		end
		
		start()
	]]
}
