local io = require(modpath.."scripts.lualib.input-output")
local getitems = require(modpath.."scripts.lualib.get-items-from")

local miners = {
	["miner-mk-1"] = true,
	["miner-mk-2"] = true,
	["miner-mk-3"] = true
}
local box = "miner-box"

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	local name = entity.name
	if miners[name] then
		-- spawn a box for this drill
		local store = entity.surface.create_entity{
			name = box,
			position = entity.position,
			force = entity.force,
			raise_built = true
		}
		io.addOutput(entity, {0,-6})
		entity.rotatable = false
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	local name = entity.name
	if miners[name] then
		local store = entity.surface.find_entity(box, entity.position)
		getitems.storage(store, event and event.buffer or nil)
		store.destroy()
		io.remove(entity, event)
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
