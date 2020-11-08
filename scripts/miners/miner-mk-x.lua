local io = require("scripts.lualib.input-output")
local getitems = require("scripts.lualib.get-items-from")

local box_map = {
    ["miner-mk-1-box"] = "miner-mk-1",
    ["miner-mk-2-box"] = "miner-mk-2",
    ["miner-mk-3-box"] = "miner-mk-3"
}

local miner_map = {
    ["miner-mk-1"] = "miner-mk-1-box",
    ["miner-mk-2"] = "miner-mk-2-box",
    ["miner-mk-3"] = "miner-mk-3-box"
}

local function onBuilt(event)
	local entity = event.created_entity or event.entity
    if not entity or not entity.valid then return end
    local name = entity.name
	if miner_map[name] then
		-- spawn a box for this drill
		local store = entity.surface.create_entity{
			name = box_map[name],
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
	if miner_map[name] then
		local store = entity.surface.find_entity(miner_map[name], entity.position)
		getitems.storage(store, event and event.buffer or nil)
		store.destroy()
		io.remove(entity, event)
	end
	if box_map[name] then
		local drill = entity.surface.find_entity(box_map[name],entity.position)
		io.remove(drill, event)
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
