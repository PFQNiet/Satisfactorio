-- the character only regenerates to 30HP, and also respawns at 30HP
---@param event NthTickEventData
local function onSecond(event)
	for _,player in pairs(game.players) do
		local character = player.character
		if character then
			if character.health < 30 and character.tick_of_last_damage + character.prototype.ticks_to_stay_in_combat < event.tick then
				character.health = math.min(30, character.health + 1)
			end
		end
	end
end
---@param event on_player_respawned
local function onRespawn(event)
	local player = game.players[event.player_index]
	local character = player.character
	if character then
		character.health = 30
	end
end

return {
	on_nth_tick = {
		[60] = onSecond
	},
	events = {
		[defines.events.on_player_respawned] = onRespawn
	}
}
