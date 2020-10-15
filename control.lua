local handler = require("event_handler")

handler.add_lib(require("scripts.freeplay"))
handler.add_lib(require("scripts.indestructible"))
handler.add_libraries(require("scripts.creatures"))
handler.add_libraries(require("scripts.constructors"))
handler.add_libraries(require("scripts.equipment"))
handler.add_libraries(require("scripts.miners"))
handler.add_libraries(require("scripts.special"))
handler.add_libraries(require("scripts.logistics"))
handler.add_libraries(require("scripts.organisation"))
handler.add_libraries(require("scripts.power"))
handler.add_libraries(require("scripts.vehicles"))
handler.add_libraries(require("scripts.weapons"))
handler.add_lib(require("scripts.lualib.resource-spawner"))
handler.add_lib(require("scripts.lualib.resource-scanner"))
handler.add_lib(require("scripts.lualib.power-trip").lib)
handler.add_lib(require("scripts.lualib.self-driving"))
handler.add_lib(require("scripts.tech-extras"))
handler.add_lib(require("scripts.map-tweaks"))

handler.add_lib({
	add_commands = function()
		commands.add_command("fill-hub","Instantly fill the HUB Terminal with the items needed to progress.",function(event)
			local player = game.players[event.player_index]
			local pos = global['hub-terminal'] and global['hub-terminal'][player.force.index] or nil
			if not pos then
				player.print("No HUB built",{1,0,0})
				return
			end
			local terminal = game.get_surface(pos[1]).find_entity("the-hub-terminal",pos[2])
			if not terminal then
				player.print("No HUB built",{1,0,0})
				return
			end
			local recipe = terminal.get_recipe()
			if not recipe then
				player.print("No Milestone selected in the HUB",{1,0,0})
				return
			end
			local inventory = terminal.get_inventory(defines.inventory.assembling_machine_input)
			local submitted = inventory.get_contents()
			for _,ingredient in pairs(recipe.ingredients) do
				local amount = ingredient.amount - (submitted[ingredient.name] or 0)
				inventory.insert{name=ingredient.name, count=amount}
			end
			if global['hub-cooldown'] and global['hub-cooldown'][player.force.index] and global['hub-cooldown'][player.force.index] > game.tick then
				global['hub-cooldown'][player.force.index] = game.tick
			end
		end)
	end
})
