modpath = "__Satisfactorio__."
local handler = require("event_handler")

if remote.interfaces['SatisfactoryDemoScenario'] then
	remote.remove_interface('SatisfactoryDemoScenario')
	return
end
if script.mod_name == "level" then
	remote.add_interface('SatisfactoryDemoScenario',{})
end

-- Add deepcopy for migrations
local util = require('util')
table.deepcopy = util.table.deepcopy

handler.add_lib(require(modpath.."scripts.freeplay"))
handler.add_lib(require(modpath.."scripts.build-gun")) -- must be early in the event handlers so it can "cancel" build events
handler.add_lib(require(modpath.."scripts.indestructible"))
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
handler.add_lib(require(modpath.."scripts.lualib.input-output"))
handler.add_lib(require(modpath.."scripts.lualib.recipe-browser"))
handler.add_lib(require(modpath.."scripts.lualib.radioactivity"))
handler.add_lib(require(modpath.."scripts.lualib.resources"))
handler.add_lib(require(modpath.."scripts.lualib.resource-spawner"))
handler.add_lib(require(modpath.."scripts.lualib.resource-scanner"))
handler.add_lib(require(modpath.."scripts.lualib.character-healing"))
handler.add_lib(require(modpath.."scripts.lualib.corpse-scanner"))
handler.add_lib(require(modpath.."scripts.lualib.power-trip"))
handler.add_lib(require(modpath.."scripts.lualib.crash-sites"))
handler.add_lib(require(modpath.."scripts.lualib.enemy-spawning"))
handler.add_lib(require(modpath.."scripts.lualib.self-driving"))
handler.add_lib(require(modpath.."scripts.lualib.omnilab"))
handler.add_lib(require(modpath.."scripts.tech-extras"))
handler.add_lib(require(modpath.."scripts.inventory-sort-and-trash"))
handler.add_lib(require(modpath.."scripts.map-tweaks"))

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
-- handler.add_lib(require(modpath.."compatibility.companion-drones-control")) -- no longer compatible
handler.add_lib(require(modpath.."compatibility.factorissimo2-control"))
