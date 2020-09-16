local io = require("scripts.lualib.input-output")
local getitems = require("scripts.lualib.get-items-from")
local math2d = require("math2d")

local base = "truck-station"
local storage = base.."-box"
local storage_pos = {1,-0.5}
local fuelbox = base.."-fuelbox"
local fuelbox_pos = {-4,2.5}
local energy = base.."-energy"

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == base then
		-- add storage boxes
		local store = entity.surface.create_entity{
			name = storage,
			position = math2d.position.add(entity.position, math2d.position.rotate_vector(storage_pos, entity.direction*45)),
			force = entity.force,
			raise_built = true
		}
		local fuel = entity.surface.create_entity{
			name = fuelbox,
			position = math2d.position.add(entity.position, math2d.position.rotate_vector(fuelbox_pos, entity.direction*45)),
			force = entity.force,
			raise_built = true
		}
		local eei = entity.surface.create_entity{
			name = energy,
			position = entity.position,
			direction = entity.direction,
			force = entity.force,
			raise_built = true
		}
		io.addInput(entity, {-4,3.5}, fuel)
		io.addInput(entity, {-2,3.5}, store)
		io.addInput(entity, {0,3.5}, store)
		io.addOutput(entity, {2,3.5}, store, defines.direction.south)
		io.addOutput(entity, {4,3.5}, store, defines.direction.south)
		-- default to Input mode
		io.toggleOutput(entity, {2,3.5}, false)
		io.toggleOutput(entity, {4,3.5}, false)
		entity.operable = false
		entity.rotatable = false
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == base or entity.name == storage or entity.name == fuelbox then
		-- find components
		local floor = entity.name == base and entity or entity.surface.find_entity(base, entity.position)
		local store = entity.name == storage and entity or floor.surface.find_entity(storage, math2d.position.add(floor.position, math2d.position.rotate_vector(storage_pos, floor.direction*45)))
		local fuel = entity.name == fuelbox and entity or floor.surface.find_entity(fuelbox, math2d.position.add(floor.position, math2d.position.rotate_vector(fuelbox_pos, floor.direction*45)))
		local eei = floor.surface.find_entity(energy, floor.position)
		if entity.name ~= storage then
			getitems.storage(store, event and event.buffer or nil)
			store.destroy()
		end
		if entity.name ~= fuelbox then
			getitems.storage(fuel, event and event.buffer or nil)
			fuel.destroy()
		end
		io.removeInput(floor, {-4,3.5}, event)
		io.removeInput(floor, {-2,3.5}, event)
		io.removeInput(floor, {0,3.5}, event)
		io.removeOutput(floor, {2,3.5}, event)
		io.removeOutput(floor, {4,3.5}, event)
		eei.destroy()
		if entity.name ~= base then
			floor.destroy()
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
