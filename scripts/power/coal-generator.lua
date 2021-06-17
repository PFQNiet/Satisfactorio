local io = require(modpath.."scripts.lualib.input-output")
local getitems = require(modpath.."scripts.lualib.get-items-from")
local math2d = require("math2d")
local powertrip = require(modpath.."scripts.lualib.power-trip")

local boiler = "coal-generator"
local buffer = "coal-generator-eei"
local accumulator = "coal-generator-buffer"
local energy = "energy"

local script_data = {}
for i=0,60-1 do script_data[i] = {} end

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == boiler then
		io.addInput(entity, {1,5.5})
		local eei = entity.surface.create_entity{
			name = buffer,
			position = entity.position,
			direction = entity.direction,
			force = entity.force,
			raise_built = true
		}
		eei.rotatable = false
		powertrip.registerGenerator(entity, eei, accumulator)
		script_data[entity.unit_number%60][entity.unit_number] = entity
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == boiler or entity.name == buffer then
		local store = entity.name == boiler and entity or entity.surface.find_entity(boiler, entity.position)
		local gen = entity.name == buffer and entity or entity.surface.find_entity(buffer, entity.position)
		script_data[store.unit_number%60][store.unit_number] = nil
		powertrip.unregisterGenerator(store)
		io.remove(store, event)
		if entity.name ~= boiler then
			store.destroy()
		end
		if entity.name ~= buffer then
			gen.destroy()
		end
	end
end

local function onTick(event)
	for i,storage in pairs(script_data[event.tick%60]) do
		-- each station will "tick" once every 60 in-game ticks, ie. every second
		-- if the machine is crafting then output power, and don't if not
		-- power production is 75MW
		local eei = storage.surface.find_entity(buffer, storage.position)
		if eei.active then
			if storage.is_crafting() then
				eei.power_production = (75*1000*1000+1)/60 -- 75MW, +1 for the buffer
			else
				eei.power_production = 0
			end
		end
	end
end
local function onGuiOpened(event)
	local player = game.players[event.player_index]
	if event.entity and event.entity.valid and event.entity.name == buffer then
		-- opening the EEI instead opens the tank
		player.opened = event.entity.surface.find_entity(boiler, event.entity.position)
	end
end

return {
	on_init = function()
		global.coal_generators = global.coal_generators or script_data
	end,
	on_load = function()
		script_data = global.coal_generators or script_data
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

		[defines.events.on_tick] = onTick,
		[defines.events.on_gui_opened] = onGuiOpened
	}
}
