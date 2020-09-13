local tower = "lookout-tower"
local car = "lookout-tower-car"

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == tower then
		-- add an invisible "car" that, when entered, zooms the map
		entity.surface.create_entity{
			name = car,
			position = entity.position,
			force = entity.force,
			raise_built = true
		}
		entity.destructible = false
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == tower then
		-- remove the vehicle
		local box = entity.surface.find_entity(car, entity.position)
		if box and box.valid then
			box.destroy()
		else
			game.print("Could not find the vehicle placeholder")
		end
	end
end

local function onVehicle(event)
	local player = game.players[event.player_index]
	local entity = event.entity
	if entity and entity.valid and entity.name == car then
		if player.driving then
			player.zoom = 0.1
			player.character_build_distance_bonus = player.character_build_distance_bonus + 100
		else
			player.zoom = 1
			player.character_build_distance_bonus = math.max(0,player.character_build_distance_bonus - 100)
		end
	end
end

return {
	events = {
		[defines.events.on_built_entity] = onBuilt,
		[defines.events.on_robot_built_entity] = onBuilt,
		[defines.events.script_raised_built] = onBuilt,
		[defines.events.script_raised_revive] = onBuilt,

		[defines.events.on_player_mined_entity] = onRemoved,
		[defines.events.on_robot_mined_entity] = onRemoved,
		[defines.events.on_entity_died] = onRemoved,
		[defines.events.script_raised_destroy] = onRemoved,

		[defines.events.on_player_driving_changed_state] = onVehicle
	}
}
