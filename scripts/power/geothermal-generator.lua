-- uses global.geogens to track generators for power cycling
local powertrip = require(modpath.."scripts.lualib.power-trip")

local miner = "geothermal-generator"
local gen = miner.."-eei"
local accumulator = miner.."-buffer"

local script_data = {}
for i=0,60-1 do script_data[i] = {} end

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == miner then
		local node = entity.surface.find_entity("geyser", entity.position)
		-- spawn a generator
		local gen = entity.surface.create_entity{
			name = gen,
			position = entity.position,
			force = entity.force,
			raise_built = true
		}
		gen.rotatable = false
		gen.electric_buffer_size = (node.amount/120*300*1000*1000+1)/60
		entity.destroy()
		powertrip.registerGenerator(nil, gen, accumulator)

		script_data[gen.unit_number%60][gen.unit_number] = {node=node, generator=gen}
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == gen then
		powertrip.unregisterGenerator(entity)
	end
end

local function onTick(event)
	for i,entry in pairs(script_data[event.tick%60]) do
		-- each station will "tick" once every 60 in-game ticks, ie. every second
		-- power consumption ranges based on the resource node, in a sine wave. Node amount 120 = 100-300 MW
		-- entry.node, entry.generator
		local min = entry.node.amount/120*100
		local max = entry.node.amount/120*300
		local t = (event.tick + entry.generator.unit_number * 133) / (60 * 60) * math.pi
		local pow = (min + max) / 2 + (max - min) / 2 * math.sin(t)
		entry.generator.power_production = (pow * 1000 * 1000 + 1) / 60 -- MW to joules-per-tick, plus one for the buffer
	end
end

return {
	on_init = function()
		global.geogens = global.geogens or script_data
	end,
	on_load = function()
		script_data = global.geogens or script_data
	end,
	events = {
		[defines.events.on_built_entity] = onBuilt,
		[defines.events.on_robot_built_entity] = onBuilt,
		[defines.events.script_raised_built] = onBuilt,
		[defines.events.script_raised_revive] = onBuilt,

		[defines.events.on_player_mined_entity] = onRemoved,
		[defines.events.on_robot_mined_entity] = onRemoved,
		[defines.events.on_entity_died] = onRemoved,
		[defines.events.script_raised_destroy] = onRemoved,

		[defines.events.on_tick] = onTick
	}
}
