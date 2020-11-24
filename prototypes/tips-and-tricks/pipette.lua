local tip = data.raw['tips-and-tricks-item']['pipette']
tip.simulation = {
	init = tiptrickutils..[[
		player = game.create_test_player{name = "Niet"}
		player.character.teleport{0, 2.5}
		game.camera_player = player
		game.camera_player_cursor_position = player.position
		pipette_delay = 40
		clear_delay = 60
		
		game.surfaces[1].create_entities_from_blueprint_string{
			string = "0eNqdlmFvgjAQhv/LfQZDC4jwVxZjAE/XBAopxYwZ/vtaXdRM3O7GJ0rb530P7sqdoWpG7I3SFoozqLrTAxRvZxjUUZeNf2anHqEAZbGFAHTZ+pFfZ81Y287AHIDSe/yAQszBnzutKfXQd8aGFTb2YbOctwGgtsoqvHq4DKadHtsKjaO/YgTQd4Pb1mmv6lBhvEoDmNyNXKVOYa8M1td56S3+AMvHsE44dSYc+kZZ6yZfsyMKOv6HZ+HAC6hk8eU/cVj2Urq9NYe7pnMzDjejc1MOd0PnRhxuTucKDldEZDDLr6DXGOu7CUnmsvJMMOpLfoNjEjjhFy4NnPLBT4dYsgRe83OY5jjjJzENvGEnMY2b805KElRG7MqgcQW7Mmjce8Vh4xYaVYeo0Ryn0P3r0RzKGp8lfNp7hR/8AKrxcECzG9Qn+tPndi0p32uyxb0a2/BmoO8afB1XcolLozq+V91ofA8gk+2SQsJUEMkvEvHWNx6XJqV46IYCOKEZrvFvRJLlMhPrLMtzOc9fqP8FKQ==",
			position = {3,1}
		}
		io.generate(game.surfaces[1])
		
		step_1 = function()
			target_position = {3.5, 0.5}
			script.on_nth_tick(1, function()
				if game.move_cursor({position = target_position}) then
					step_2()
				end
			end)
		end
		
		step_2 = function()
			local count = pipette_delay
			script.on_nth_tick(1, function()
				count = count - 1
				if count == math.floor(pipette_delay / 2) then
					player.pipette_entity(player.selected)
					game.camera_player_cursor_direction = player.selected.direction
				end
				
				if count <= 0 then
					step_3()
				end
			end)
		end
		
		step_3 = function()
			target_position = {3.5, -2.5}
			script.on_nth_tick(1, function()
				finished = game.move_cursor({position = target_position})
				if finished then
					player.build_from_cursor{position = game.camera_player_cursor_position, direction = defines.direction.east}
					io.generate(game.surfaces[1])
					step_4()
				end
			end)
		end
		
		step_4 = function()
			local count = clear_delay
			target_position = {6.5, 4.5}
			script.on_nth_tick(1, function()
				count = count - 1
				if count == math.floor(clear_delay / 2) then
					player.clear_cursor()
				end
				if count > math.floor(clear_delay / 3) then return end
				
				finished = game.move_cursor({position = target_position})
				if finished then
					step_5()
				end
			end)
			
		end
		
		step_5 = function()
			local count = pipette_delay
			script.on_nth_tick(1, function()
				count = count - 1
				if count == math.floor(pipette_delay / 2) then
					player.pipette_entity(player.selected)
				end
				
				if count <= 0 then
					step_6()
				end
			end)
		end

		step_6 = function()
			target_position = {6.5, -0.5}
			script.on_nth_tick(1, function()
				finished = game.move_cursor({position = target_position})
				if finished then
					player.build_from_cursor{position = game.camera_player_cursor_position}
					step_7()
				end
			end)
		end

		step_7 = function()
			local count = clear_delay
			target_position = {-3.5, -2.5}
			script.on_nth_tick(1, function()
				count = count - 1
				if count == math.floor(clear_delay / 2) then
					player.clear_cursor()
				end
				
				if count > math.floor(clear_delay / 3) then return end
				
				finished = game.move_cursor({position = target_position})
				if finished then
					step_8()
				end
			end)
			
		end

		step_8 = function()
			local count = pipette_delay
			script.on_nth_tick(1, function()
				count = count - 1
				if count == math.floor(pipette_delay / 2) then
					player.pipette_entity(player.selected)
					game.camera_player_cursor_direction = player.selected.direction
				end
				
				if count <= 0 then
					step_9()
				end
			end)
		end

		step_9 = function()
			target_position = {7.5, -2.5}
			script.on_nth_tick(1, function()
				finished = game.move_cursor({position = target_position})
				player.build_from_cursor{position = game.camera_player_cursor_position, direction = defines.direction.east}
				if finished then
					step_10()
				end
			end)
		end

		step_10 = function()
			local count = clear_delay
			target_position = player.position
			script.on_nth_tick(1, function()
				count = count - 1
				if count == math.floor(clear_delay / 2) then
					player.clear_cursor()
				end
				
				if count > math.floor(clear_delay / 3) then return end
				
				finished = game.move_cursor({position = target_position})
				if finished then
					reset()
				end
			end)
			
		end

		reset = function()
			local count = 60
			script.on_nth_tick(1, function()
				count = count - 1
				if count >= 0 then return end
				
				for k, v in pairs (game.surfaces[1].find_entities_filtered{area = {{-3, -4}, {8, -1}}}) do
					v.destroy()
				end
				local pole = game.surfaces[1].find_entity("medium-electric-pole", {6.5, -0.5})
				pole.destroy()
				
				start()
			end)
		end

		start = function()
			local count = 60
			script.on_nth_tick(1, function()
				count = count - 1
				if count >= 0 then return end
				
				player.character.clear_items_inside()
				player.insert("transport-belt")
				player.insert("constructor")
				player.insert("medium-electric-pole")
				
				step_1()
			end)
		end

		start()
	]]
}
