local containers = require(modpath.."scripts.organisation.containers")

local io = require(modpath.."scripts.lualib.input-output")
local bev = require(modpath.."scripts.lualib.build-events")
local link = require(modpath.."scripts.lualib.linked-entity")

local box = "industrial-storage-container"
local fakebox = "industrial-storage-container-placeholder"

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

		io.addConnection(entity, {-1,2}, "input", realbox)
		io.addConnection(entity, {1,2}, "input", realbox)
		io.addConnection(entity, {-1,-2}, "output", realbox)
		io.addConnection(entity, {1,-2}, "output", realbox)
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

return bev.applyBuildEvents{
	on_build = onBuilt,
	events = {
		[defines.events.on_gui_opened] = onGuiOpened
	}
}
