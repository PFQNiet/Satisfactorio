local io = require("scripts.lualib.input-output")

local box = "steel-chest"
local fakebox = "industrial-storage-container-placeholder"

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == fakebox then
		-- add the "real" box
		local realbox = entity.surface.create_entity{
			name = box,
			position = entity.position,
			force = entity.force,
			raise_built = true
		}
		io.addInput(entity, {-1,2}, realbox)
		io.addInput(entity, {1,2}, realbox)
		io.addOutput(entity, {-1,-2}, realbox)
		io.addOutput(entity, {1,-2}, realbox)
		entity.operable = false
		entity.rotatable = false
		entity.minable = false -- mine the box!
		entity.destructible = false
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == box then
		-- remove the fakebox graphic
		local fake = entity.surface.find_entity(fakebox, entity.position)
		if fake and fake.valid then
			-- remove the input/output
			io.removeInput(fake, {-1,2}, event)
			io.removeInput(fake, {1,2}, event)
			io.removeOutput(fake, {-1,-2}, event)
			io.removeOutput(fake, {1,-2}, event)
			fake.destroy()
		else
			game.print("Could not find the box graphic")
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
