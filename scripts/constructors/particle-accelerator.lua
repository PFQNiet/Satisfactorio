-- uses global.accelerators to track entities for the purpose of updating power use

local io = require(modpath.."scripts.lualib.input-output")

local accelerator = "particle-accelerator"
local eei = accelerator.."-eei"

local script_data = {}
for i=0,30-1 do script_data[i] = {} end

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == accelerator then
		io.addInput(entity, {-8,5.5})
		io.addInput(entity, {-6,5.5})
		io.addOutput(entity, {-8,-5.5})

		local pow = entity.surface.create_entity{
			name = eei,
			position = entity.position,
			direction = entity.direction,
			force = entity.force,
			raise_built = true
		}
		pow.rotatable = false

		script_data[entity.unit_number%30][entity.unit_number] = {accelerator=entity, interface=pow}
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == accelerator or entity.name == eei then
		local acc = entity.name == accelerator and entity or entity.surface.find_entity(accelerator, entity.position)
		local pow = entity.name == eei and entity or entity.surface.find_entity(eei, entity.position)

		io.remove(acc, event)
		if entity.name ~= accelerator then
			acc.destroy()
		end
		if entity.name ~= eei then
			pow.destroy()
		end
		script_data[acc.unit_number%30][acc.unit_number] = nil
	end
end

local POWER = {
	["instant-plutonium-cell"] = {250, 500},
	["nuclear-pasta"] = {500, 1500},
	["plutonium-pellet"] = {250, 750}
}
local function onTick(event)
	for i,entry in pairs(script_data[event.tick%30]) do
		-- each station will "tick" once every 30 in-game ticks, ie. every half-second
		-- power consumption ranges based on recipe and crafting progress
		-- entry.accelerator, entry.interface
		if not entry.accelerator.is_crafting() then
			entry.interface.power_usage = 0
		else
			local recipe = entry.accelerator.get_recipe().name
			local scale = 1 + entry.accelerator.speed_bonus*2
			local range = POWER[recipe] or {500,1500}
			local pow = (range[1] + (range[2] - range[1]) * entry.accelerator.crafting_progress) * scale
			entry.interface.power_usage = pow * 1000 * 1000 / 60 -- megawatts => joules/tick
			entry.interface.electric_buffer_size = entry.interface.power_usage
		end
	end
end
local function onGuiOpened(event)
	local player = game.players[event.player_index]
	if event.entity and event.entity.valid and event.entity.name == eei then
		-- opening the EEI instead opens the tank
		player.opened = event.entity.surface.find_entity(accelerator, event.entity.position)
	end
end

return {
	on_init = function()
		global.accelerators = global.accelerators or script_data
	end,
	on_load = function()
		script_data = global.accelerators or script_data
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
