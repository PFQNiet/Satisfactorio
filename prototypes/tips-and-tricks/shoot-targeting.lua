local tip = data.raw['tips-and-tricks-item']['shoot-targeting']
tip.trigger = {
	type = "research",
	technology = "mam-sulfur-rifle"
}
tip.simulation = {
	init = [[
		player = game.create_test_player{name = "Niet"}
		player.teleport({-4, 0.5})
		player.character.direction = 2
		game.camera_player = player
		game.camera_player_cursor_position = player.position
		game.camera_alt_info = true
		
		step_1 = function()
			biter = game.surfaces[1].create_entity{name = "big-biter", position = {10 + (math.random() * 2), -4 + (math.random() * 4)}}
			biter.speed = 0.05
			biter.set_command{
				type = defines.command.attack,
				target = player.character
			}
			
			tree = game.surfaces[1].create_entity{name = "tree-02", position = {4, 2.5}}
			
			local count = 60
			script.on_nth_tick(1, function()
				if count > 0 then count = count - 1 return end
				step_2()
			end)
		end
		
		step_2 = function()
			local rand_x = -1.5
			local rand_y = -1
			local position = {0.5 * ((biter.position.x + rand_x) + player.position.x), 0.5 * ((biter.position.y + rand_y) + player.position.y)}
			player.clear_items_inside()
			player.insert("submachine-gun")
			player.insert("firearm-magazine")
			
			script.on_nth_tick(1, function()
				if not biter.valid then
					step_3()
					return
				end
				if game.move_cursor({position = position}) then
					player.shooting_state = {state  = defines.shooting.shooting_enemies, position = position}
				end
			end)
			
		end
		
		step_3 = function()
			local count = 60
			script.on_nth_tick(1, function()
				if count > 0 then count = count - 1 return end
				
				if game.move_cursor({position = tree.position}) then
					step_4()
				end
			end)
		end
		
		step_4 = function()
			local count = 30
			script.on_nth_tick(1, function()
				if count > 0 then count = count - 1 return end
				if not tree.valid then
					step_5()
				end
				player.shooting_state = {state  = defines.shooting.shooting_selected, position = game.camera_player_cursor_position}
			end)
		end
		
		step_5 = function()
			local count = 30
			script.on_nth_tick(1, function()
				if count > 0 then count = count - 1 return end
				if game.move_cursor({position = player.position}) then
					reset()
				end
			end)
		end
		
		reset = function()
			local count = 30
			script.on_nth_tick(1, function()
				if count > 0 then count = count - 1 return end
				start()
			end)
		end
		
		start = function()
			local count = 30
			script.on_nth_tick(1, function()
				if count > 0 then count = count - 1 return end
				step_1()
			end)
		end
		
		start()
	]]
}
