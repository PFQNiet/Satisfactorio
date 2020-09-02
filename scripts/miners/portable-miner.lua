local miner = "portable-miner"
local box = "portable-miner-box"

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == miner then
		-- spawn a box for this drill
		entity.surface.create_entity{
			name = box,
			position = entity.position,
			force = entity.force,
			raise_built = true
		}
		-- make the drill intangible
		entity.operable = false
		entity.minable = false
		entity.destructible = false
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == box then
		-- find the drill that should be right here
		local drill = entity.surface.find_entity(miner,entity.position)
		if not drill or not drill.valid then
			game.print("Couldn't find the drill")
			return
		end
		drill.destroy()
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
		[defines.events.script_raised_destroy] = onRemoved
	}
}
