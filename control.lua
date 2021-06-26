modpath = "__Satisfactorio__."

-- ensure system only loads once - it may try to load twice in Menu Sims or the Sandbox scenario
if remote.interfaces['SatisfactorioLoaded'] then
	return
end
remote.add_interface('SatisfactorioLoaded',{})

local handler = require("event_handler")

-- Add deepcopy for migrations
local util = require('util')
table.deepcopy = util.table.deepcopy

handler.add_lib(require(modpath.."scripts.freeplay"))
handler.add_libraries(require(modpath.."scripts.gameplay")) -- must be early in the event handlers
handler.add_libraries(require(modpath.."scripts.creatures"))
handler.add_libraries(require(modpath.."scripts.constructors"))
handler.add_libraries(require(modpath.."scripts.equipment"))
handler.add_libraries(require(modpath.."scripts.miners"))
handler.add_libraries(require(modpath.."scripts.special"))
handler.add_libraries(require(modpath.."scripts.logistics"))
handler.add_libraries(require(modpath.."scripts.organisation"))
handler.add_libraries(require(modpath.."scripts.power"))
handler.add_libraries(require(modpath.."scripts.vehicles"))
handler.add_libraries(require(modpath.."scripts.weapons"))
handler.add_lib(require(modpath.."scripts.lualib.input-output").lib)
handler.add_lib(require(modpath.."scripts.lualib.linked-entity").lib)
handler.add_lib(require(modpath.."scripts.lualib.pings").lib)
handler.add_lib(require(modpath.."scripts.lualib.resource-spawner").lib)
handler.add_lib(require(modpath.."scripts.lualib.power-trip").lib)
handler.add_lib(require(modpath.."scripts.lualib.enemy-spawning").lib)
handler.add_lib(require(modpath.."scripts.lualib.crash-sites").lib)

handler.add_lib({
	add_commands = function()
		if not commands.commands['respawn'] then
			commands.add_command("respawn",{"command.respawn"},function(event)
				local player = game.players[event.player_index]
				if player.character and not player.character.driving then
					player.character.die()
				end
			end)
		end
	end
})

-- Control-time Mod Compatibility
handler.add_lib(require(modpath.."compatibility.factorissimo2-control"))
