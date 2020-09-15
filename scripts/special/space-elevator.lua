local io = require("scripts.lualib.input-output")

local elevator = "space-elevator"

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == elevator then
		io.addInput(entity, {-10,13})
		io.addInput(entity, {-8,13})
		io.addInput(entity, {-6,13})
		io.addInput(entity, {-10,-13}, nil, defines.direction.south)
		io.addInput(entity, {-8,-13}, nil, defines.direction.south)
		io.addInput(entity, {-6,-13}, nil, defines.direction.south)
		local silo = entity.surface.create_entity{
			name = elevator.."-silo",
			position = entity.position,
			force = entity.force,
			raise_built = true
		}
		silo.operable = false
		silo.minable = false
		silo.destructible = false
		silo.auto_launch = true

		local inserter = silo.surface.create_entity{
			name = "loader-inserter",
			position = silo.position,
			force = silo.force,
			raise_built = true
		}
		inserter.drop_position = silo.position
		inserter.operable = false
		inserter.minable = false
		inserter.destructible = false

		entity.active = false
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == elevator then
		-- remove the input/output
		io.removeInput(entity, {-10,13}, event)
		io.removeInput(entity, {-8,13}, event)
		io.removeInput(entity, {-6,13}, event)
		io.removeInput(entity, {-10,-13}, event)
		io.removeInput(entity, {-8,-13}, event)
		io.removeInput(entity, {-6,-13}, event)
		local silo = entity.surface.find_entity(elevator.."-silo", entity.position)
		if not silo then
			game.print("Could not find Space Elevator silo")
		else
			silo.destroy()
		end
		local inserter = entity.surface.find_entity("loader-inserter", entity.position)
		if not silo then
			game.print("Could not find Space Elevator inserter")
		else
			silo.destroy()
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
