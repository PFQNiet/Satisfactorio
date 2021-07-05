-- point out the player's corpse(s)

local pings = require(modpath.."scripts.lualib.pings")

---@param corpse LuaEntity
local function onPlayerDied(corpse)
	local player = game.players[corpse.character_corpse_player_index]
	pings.addPing(player, corpse)
end

--- Check for any corpses belonging to this player on this surface and re-establish pings to them
---@param event on_player_changed_surface
local function onSurfaceChanged(event)
	local player = game.players[event.player_index]
	local surface = game.surfaces[event.surface_index]
	local corpses = surface.find_entities_filtered{
		type = "character-corpse"
	}
	for _,corpse in pairs(corpses) do
		if corpse.character_corpse_player_index == player.index then
			pings.addPing(player, corpse)
		end
	end
end

return {
	events = {
		---@param event on_post_entity_died
		[defines.events.on_post_entity_died] = function(event)
			if event.prototype.name == "character" and event.corpses[1] then
				onPlayerDied(event.corpses[1])
			end
		end,
		[defines.events.on_player_changed_surface] = onSurfaceChanged
	}
}
