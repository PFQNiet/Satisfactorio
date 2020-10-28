local powertrip = require("scripts.lualib.power-trip")

local miner = "geothermal-generator"
local gen = miner.."-eei"
local accumulator = miner.."-accumulator"

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == miner then
		-- spawn a generator
		local gen = entity.surface.create_entity{
			name = gen,
			position = entity.position,
			force = entity.force,
			raise_built = true
		}
		gen.rotatable = false
		entity.destroy()
		powertrip.registerGenerator(nil, gen, accumulator)
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == gen then
		powertrip.unregisterGenerator(entity)
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
