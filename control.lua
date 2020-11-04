if script.active_mods.debugadapter then require("profiler") end
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
handler.add_lib(require("scripts.lualib.recipe-browser"))
handler.add_lib(require("scripts.lualib.resource-spawner"))
handler.add_lib(require("scripts.lualib.resource-scanner"))
handler.add_lib(require("scripts.lualib.power-trip").lib)
handler.add_lib(require("scripts.lualib.crash-sites").lib)
handler.add_lib(require("scripts.lualib.enemy-spawning").lib)
handler.add_lib(require("scripts.lualib.self-driving"))
handler.add_lib(require("scripts.lualib.radioactivity"))
handler.add_lib(require("scripts.tech-extras"))
handler.add_lib(require("scripts.map-tweaks"))

handler.add_lib({
	add_commands = function()
		commands.add_command("respawn","Kills your character, allowing you to respawn. Handy if you somehow manage to get yourself stuck.",function(event)
			local player = game.players[event.player_index]
			if player.character then
				player.character.die()
			end
		end)
	end
})
