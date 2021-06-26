local bev = require(modpath.."scripts.lualib.build-events")

local tower = "lookout-tower"

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not (entity and entity.valid) then return end
	if entity.name == tower then
		entity.operable = false
	end
end

local function onVehicle(event)
	local player = game.players[event.player_index]
	local entity = event.entity
	if entity and entity.valid and entity.name == tower then
		if player.driving then
			player.zoom = 0.1
		else
			player.zoom = 1
		end
	end
end

return bev.applyBuildEvents{
	on_build = onBuilt,
	events = {
		[defines.events.on_player_driving_changed_state] = onVehicle
	}
}
