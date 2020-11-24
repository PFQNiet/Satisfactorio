local tip = data.raw['tips-and-tricks-item']['drag-building']
tip.simulation = {
	init = [[
		global.player = game.create_test_player{name = "kovarex"}
		global.character = global.player.character
		global.character.teleport{0, 0.5}
		game.camera_player = global.player
		game.camera_player_cursor_position = {0, 0}
		
		update_camera = function()
			game.camera_position = {global.player.position.x, global.player.position.y - 2}
		end
		
		step_0 = function()
			target_cursor_position = {global.character.position.x - 2.5, global.character.position.y - 4}
			update_camera()
			script.on_nth_tick(1, function()
				local finished = game.move_cursor{position = target_cursor_position}
				if finished then
					step_1()
				end
			end)
		end
		
		step_1 = function()
			global.character.cursor_stack.set_stack{name = "constructor", count = 1}
			target_cursor_position = {global.character.position.x + 2.5, global.character.position.y - 4}
			script.on_nth_tick(1, function()
				local finished = game.move_cursor({position = target_cursor_position})
				
				if global.player.can_build_from_cursor{position = game.camera_player_cursor_position} then
					global.player.build_from_cursor{position = game.camera_player_cursor_position}
					global.character.cursor_stack.set_stack{name = "constructor", count = 1}
				end
				
				if finished then
					step_2()
				end
			end)
		end
		
		step_2 = function()
			global.character.walking_state = {walking = true, direction = defines.direction.east}
			local repeat_count = 7
			local offset = {2.5, -4}
			script.on_nth_tick(1, function()
				
				game.camera_player_cursor_position = {global.character.position.x + offset[1], global.character.position.y + offset[2]}
				
				if global.player.can_build_from_cursor{position = game.camera_player_cursor_position} then
					global.player.build_from_cursor{position = game.camera_player_cursor_position}
					repeat_count = repeat_count - 1
					if repeat_count > 0 then
						global.character.cursor_stack.set_stack{name = "constructor", count = 1}
					end
				end
				
				if game.tick % 60 == 0 then
					game.surfaces[1].build_checkerboard({{global.character.position.x + 10, global.character.position.y - 10},
					{global.character.position.x + 25, global.character.position.y + 10}})
				end
				
				update_camera()
				
				if repeat_count == 0 then
					step_3()
				end
			end)
		end
		
		step_3 = function()
			global.character.walking_state = {walking = false}
			local player_position = global.player.position
			target_cursor_position = {player_position.x + 3.5, player_position.y - 1}
			game.camera_player_cursor_direction = defines.direction.west
			script.on_nth_tick(1, function()
				update_camera()
				
				if game.move_cursor({position = target_cursor_position}) then
					step_4()
				end
			end)
		end
		
		step_4 = function()
			global.character.cursor_stack.set_stack{name = "transport-belt", count = 24}
			
			local player_position = global.player.position
			target_cursor_position = {player_position.x - 3.5, player_position.y - 1}
			
			script.on_nth_tick(1, function()
				local finished = game.move_cursor({position = target_cursor_position})
				
				if global.player.can_build_from_cursor{position = game.camera_player_cursor_position} then
					global.player.build_from_cursor{position = game.camera_player_cursor_position, direction = defines.direction.west}
				end
				
				update_camera()
				
				if finished then
					step_5()
				end
			end)
		end
		
		step_5 = function()
			global.character.walking_state = {walking = true, direction = defines.direction.west}
			
			offset = {-3.5, -1}
			script.on_nth_tick(1, function()
				game.camera_player_cursor_position = {global.character.position.x + offset[1], global.character.position.y + offset[2]}
				
				if global.player.can_build_from_cursor{position = game.camera_player_cursor_position} then
					global.player.build_from_cursor{position = game.camera_player_cursor_position, direction = defines.direction.west}
				end
				
				update_camera()
				
				if global.player.cursor_stack.count == 0 then
					finish()
				end
				
			end)
		end
		
		finish = function()
			update_camera()
			global.character.walking_state = {walking = false}
			global.character.direction = defines.direction.south
			script.on_nth_tick(1, nil)
		end
		
		step_0()
	]]
}
