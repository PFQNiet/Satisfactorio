-- uses global.accelerators to track entities for the purpose of updating power use
local io = require(modpath.."scripts.lualib.input-output")
local bev = require(modpath.."scripts.lualib.build-events")
local link = require(modpath.."scripts.lualib.linked-entity")

local accelerator = "particle-accelerator"
local eei = accelerator.."-eei"

local script_data = {}
local buckets = 30
for i=0,buckets-1 do script_data[i] = {} end
local function getBucket(tick)
	return script_data[tick%buckets]
end
local function getStruct(entity)
	return script_data[entity.unit_number%buckets][entity.unit_number]
end
local function createStruct(entity)
	local pow = entity.surface.create_entity{
		name = eei,
		position = entity.position,
		direction = entity.direction,
		force = entity.force,
		raise_built = true
	}
	pow.rotatable = false

	local struct = {
		accelerator = entity,
		interface = pow
	}
	link.register(pow, entity)

	-- the EEI is the interactible entity
	script_data[pow.unit_number%buckets][pow.unit_number] = struct
end
local function deleteStruct(entity)
	script_data[entity.unit_number%buckets][entity.unit_number] = nil
end

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not (entity and entity.valid) then return end

	if entity.name == accelerator then
		io.addConnection(entity, {-8,5.5}, "input")
		io.addConnection(entity, {-6,5.5}, "input")
		io.addConnection(entity, {-8,-5.5}, "output")
		createStruct(entity)
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not (entity and entity.valid) then return end

	if entity.name == eei then
		deleteStruct(entity)
	end
end

local POWER = {
	["instant-plutonium-cell"] = {250, 500},
	["nuclear-pasta"] = {500, 1500},
	["plutonium-pellet"] = {250, 750}
}
local function onTick(event)
	for _,struct in pairs(getBucket(event.tick)) do
		-- power consumption ranges based on recipe and crafting progress
		if not struct.accelerator.is_crafting() then
			struct.interface.power_usage = 0
		else
			local recipe = struct.accelerator.get_recipe().name
			local scale = 1 + struct.accelerator.speed_bonus*2
			local range = POWER[recipe] or {500,1500}
			local pow = (range[1] + (range[2] - range[1]) * struct.accelerator.crafting_progress) * scale
			struct.interface.power_usage = pow * 1000 * 1000 / 60 -- megawatts => joules/tick
			struct.interface.electric_buffer_size = struct.interface.power_usage
		end
	end
end

local function onGuiOpened(event)
	local player = game.players[event.player_index]
	if event.entity and event.entity.valid and event.entity.name == eei then
		-- opening the EEI instead opens the accelerator
		player.opened = getStruct(event.entity).accelerator
	end
end

return bev.applyBuildEvents{
	on_init = function()
		global.accelerators = global.accelerators or script_data
	end,
	on_load = function()
		script_data = global.accelerators or script_data
	end,
	on_build = onBuilt,
	on_destroy = onRemoved,
	events = {
		[defines.events.on_tick] = onTick,
		[defines.events.on_gui_opened] = onGuiOpened
	}
}
