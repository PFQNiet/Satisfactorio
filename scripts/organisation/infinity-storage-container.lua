local containers = require(modpath.."scripts.organisation.containers")

local io = require(modpath.."scripts.lualib.input-output")
local bev = require(modpath.."scripts.lualib.build-events")
local link = require(modpath.."scripts.lualib.linked-entity")

local box = "infinity-storage-container"
local fakebox = "infinity-storage-container-placeholder"

---@param event on_build
local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not (entity and entity.valid) then return end
	if entity.name == fakebox then
		-- add the "real" box
		local realbox = entity.surface.create_entity{
			name = box,
			position = entity.position,
			force = entity.force,
			raise_built = true
		}
		link.register(entity, realbox)

		io.addConnection(entity, {0,2}, "input", realbox)
		io.addConnection(entity, {0,-2}, "output", realbox)
		entity.rotatable = false
		containers.register(entity, realbox)
	end
end

---@param event on_gui_opened
local function onGuiOpened(event)
	if event.entity and event.entity.valid and event.entity.name == fakebox then
		game.players[event.player_index].opened = event.entity.surface.find_entity(box, event.entity.position)
	end
end

---@param event on_entity_settings_pasted
local function onPaste(event)
	if event.source and event.source.valid and event.source.name == fakebox then
		if event.destination and event.destination.valid and event.destination.name == fakebox then
			event.destination.surface.find_entity(box, event.destination.position).copy_settings(
				event.source.surface.find_entity(box, event.source.position),
				game.players[event.player_index]
			)
		end
	end
end

return bev.applyBuildEvents{
	on_build = onBuilt,
	events = {
		[defines.events.on_gui_opened] = onGuiOpened,
		[defines.events.on_entity_settings_pasted] = onPaste
	}
}
