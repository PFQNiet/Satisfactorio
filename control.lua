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
handler.add_libraries(require(modpath.."scripts.gui.lib"))
handler.add_libraries(require(modpath.."scripts.lualib.lib"))

-- filter out ghost-build/destroy events
local function setBuildEventFilter()
	local noghosts = {{filter="ghost",invert=true}}
	local events = {
		defines.events.on_built_entity,
		defines.events.on_robot_built_entity,
		defines.events.script_raised_built,
		defines.events.script_raised_revive,

		defines.events.on_player_mined_entity,
		defines.events.on_robot_mined_entity,
		defines.events.on_entity_died,
		defines.events.script_raised_destroy
	}
	for _,evt in pairs(events) do
		script.set_event_filter(evt, noghosts)
	end
end

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
	end,
	add_remote_interface = function()
		if not remote.interfaces['Satisfactorio'] then
			remote.add_interface("Satisfactorio", {
				---@param bool boolean
				set_no_victory = function(bool)
					if type(bool) ~= "boolean" then error("Value for 'set_no_victory' must be a boolean") end
					global.no_victory = bool
				end
			})
		end
	end,
	on_init = setBuildEventFilter,
	on_load = setBuildEventFilter
})

-- Control-time Mod Compatibility
handler.add_lib(require(modpath.."compatibility.factorissimo2-control"))
