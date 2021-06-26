local io = require(modpath.."scripts.lualib.input-output")
local powertrip = require(modpath.."scripts.lualib.power-trip")
local bev = require(modpath.."scripts.lualib.build-events")
local link = require(modpath.."scripts.lualib.linked-entity")

local boiler = "nuclear-power-plant"
local buffer = "nuclear-power-plant-eei"
local accumulator = "nuclear-power-plant-buffer"
local power = 2500

local script_data = {}
local buckets = 60
for i=0,buckets-1 do script_data[i] = {} end
local function getBucket(tick)
	return script_data[tick%buckets]
end
local function getStruct(entity)
	return script_data[entity.unit_number%buckets][entity.unit_number]
end
local function createStruct(entity)
	local pow = entity.surface.create_entity{
		name = buffer,
		position = entity.position,
		direction = entity.direction,
		force = entity.force,
		raise_built = true
	}
	pow.rotatable = false

	local struct = {
		generator = entity,
		interface = pow,
		ticks = 0
	}
	link.register(entity, pow)
	powertrip.registerGenerator(entity, pow, accumulator)
	script_data[entity.unit_number%buckets][entity.unit_number] = struct
end
local function deleteStruct(entity)
	script_data[entity.unit_number%buckets][entity.unit_number] = nil
end

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not (entity and entity.valid) then return end
	if entity.name == boiler then
		io.addConnection(entity, {-2,10}, "input")
		io.addConnection(entity, {2,10}, "output", nil, defines.direction.south)
		createStruct(entity)
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not (entity and entity.valid) then return end
	if entity.name == boiler then
		deleteStruct(entity)
	end
end

local waste_data = {
	["uranium-fuel-rod"] = {
		name = "uranium-waste",
		ticks = 6*60 -- ticks per waste
	},
	["plutonium-fuel-rod"] = {
		name = "plutonium-waste",
		ticks = 60*60 -- ticks per waste
	}
}
local function onTick(event)
	for _,struct in pairs(getBucket(event.tick)) do
		-- if the machine is crafting then output power, and don't if not
		local eei = struct.interface
		if eei.active then
			if struct.generator.is_crafting() then
				eei.power_production = (power*1000*1000+1)/60 -- +1 for the buffer

				struct.ticks = struct.ticks + buckets
				local burning = struct.generator.burner.currently_burning
				if burning then
					local fuel = burning.name
					if fuel then
						local waste = waste_data[fuel]
						if waste then
							if struct.ticks >= waste.ticks then
								struct.ticks = struct.ticks - waste.ticks
								struct.generator.get_inventory(defines.inventory.assembling_machine_output).insert{name=waste.name,count=1}
								struct.generator.force.item_production_statistics.on_flow(waste.name,1)
							end
						end
					end
				end
			else
				eei.power_production = 0
			end
		end
	end
end

return bev.applyBuildEvents{
	on_init = function()
		global.nuclear_generators = global.nuclear_generators or script_data
	end,
	on_load = function()
		script_data = global.nuclear_generators or script_data
	end,
	on_build = onBuilt,
	on_destrory = onRemoved,
	events = {
		[defines.events.on_tick] = onTick
	}
}
