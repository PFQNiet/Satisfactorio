local io = require(modpath.."scripts.lualib.input-output")

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
		entity.rotatable = false
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == fakebox or entity.name == box then
		local fake = entity.name == fakebox and entity or entity.surface.find_entity(fakebox, entity.position)
		local real = entity.name == box and entity or entity.surface.find_entity(box, entity.position)
		io.remove(fake, event)
		if entity ~= fake then
			fake.destroy()
		end
		if entity ~= real then
			real.destroy()
		end
	end
end

local function onGuiOpened(event)
	if event.entity and event.entity.valid and event.entity.name == fakebox then
		game.players[event.player_index].opened = event.entity.surface.find_entity(box, event.entity.position)
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

		[defines.events.on_gui_opened] = onGuiOpened
	}
}
