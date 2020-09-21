local extractor = "water-extractor"
local placeholder = extractor.."-placeholder"

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == placeholder then
		-- swap it for the non-placeholder and spawn a "water resource node" under it
		entity.surface.create_entity{
			name = "water",
			position = entity.position,
			force = game.forces.neutral,
			amount = 60
		}
		entity.surface.create_entity{
			name = extractor,
			position = entity.position,
			direction = entity.direction,
			force = entity.force,
			raise_built = true
		}
		entity.destroy()
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == extractor then
		-- remove the resource node
		local node = entity.surface.find_entity("water",entity.position)
		if not node then
			game.print("Could not find resource placeholder")
		else
			node.destroy()
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
		[defines.events.script_raised_destroy] = onRemoved
	}
}
