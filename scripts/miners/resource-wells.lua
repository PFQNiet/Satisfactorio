-- on first-time placement, spawn satellite nodes
-- periodically check power and modules, distributing those effects to extractors
-- on removal, signal extractors to shut down, and on re-placement check for existing extractors and power them up
-- uses global.wells to track data
-- note that resource entities do not have a unit_number, so script.register_on_entity_destroyed(entity) is used to get a UID for them

local bev = require(modpath.."scripts.lualib.build-events")
local string = require(modpath.."scripts.lualib.string")

local pressuriser = "resource-well-pressuriser"
local extractor = "resource-well-extractor"

---@class ResourceWell
---@field pressuriser LuaEntity
---@field nodes uint64[] IDs for the satellite nodes

---@class ResourceWellPressuriser
---@field entity LuaEntity
---@field well_id uint64 ID of the well this is built on

---@alias ResourceWellPressuriserBucket table<uint, ResourceWellPressuriser>

---@class ResourceWellNode
---@field node LuaEntity Resource
---@field amount uint Base amount of the resource
---@field well_id uint64 ID of the well this belongs to

---@class ResourceWellExtractor
---@field entity LuaEntity
---@field node_id uint64 ID of the node this is built on

---@class global.wells
---@field pressurisers ResourceWellPressuriserBucket[]
---@field wells table<uint64, ResourceWell>
---@field nodes table<uint64, ResourceWellNode>
---@field extractors table<uint, ResourceWellExtractor>
local script_data = {
	pressurisers = {},
	wells = {},
	nodes = {},
	extractors = {}
}
for i=0,60-1 do script_data.pressurisers[i] = {} end

---@param entity LuaEntity
---@return LuaEntity
local function getPressuriserForExtractor(entity)
	local exdata = script_data.extractors[entity.unit_number]
	if not exdata then return end
	local ndata = script_data.nodes[exdata.node_id]
	if not ndata then return end
	local well = script_data.wells[ndata.well_id]
	return well and well.pressuriser
end
---@param entity LuaEntity
local function getSatelliteNodesForPressuriser(entity)
	local pdata = script_data.pressurisers[entity.unit_number % 60][entity.unit_number]
	if not pdata then return end
	local well = script_data.wells[pdata.well_id]
	return well.nodes
end

---@param entity LuaEntity
local function onBuilt(entity)
	if entity.name == pressuriser then
		-- if the well hasn't been registered yet, spawn satellite nodes
		local well = entity.surface.find_entities_filtered{position=entity.position, type="resource"}[1] -- can be assumed to exist since we built a miner on it
		local well_id = script.register_on_entity_destroyed(well)
		if not script_data.wells[well_id] then
			local nodetype = string.remove_suffix(well.name, "-well").."-node"
			local nodes = {}
			local total_yield = 0
			local settings = game.default_map_gen_settings.autoplace_controls[well.name] or {frequency=1,richness=1,size=1}
			local size = settings.size
			if size == 0 then size = 1 end
			local richness = settings.richness
			if richness == 0 then richness = 1 end
			-- settings.size = minimum radius of node
			-- settings.richness = scaling factor for total purity, default 18
			for maxrange=10+size*6,100 do
				-- keep trying with bigger and bigger ranges until we get at least one satellite spawned
				local offset = math.random()
				local total_purity = 18*richness
				for i=1,48 do
					local purity = math.random(0,4)
					if purity > total_purity then purity = total_purity end
					if purity == 3 then purity = 2 end
					if purity > 0 then
						local r = math.random(9,maxrange)
						local th = (offset+i*5/12)*math.pi*2
						local dx = math.floor(r*math.cos(th))+0.5
						local dy = math.floor(r*math.sin(th))+0.5
						local pos = entity.surface.find_non_colliding_position(nodetype, {entity.position.x+dx, entity.position.y+dy}, 5, 1, true)
						if pos then
							local amount = 3000*purity
							total_yield = total_yield + amount
							local node = entity.surface.create_entity{
								name = nodetype,
								position = pos,
								force = game.forces.neutral,
								amount = amount
							}
							local node_id = script.register_on_entity_destroyed(node)
							script_data.nodes[node_id] = {
								node = node,
								amount = amount,
								well_id = well_id
							}
							table.insert(nodes, node_id)
						end
						total_purity = total_purity - purity
					end
					if total_purity <= 0 then break end
				end
				if #nodes > 0 then break end
			end
			script_data.wells[well_id] = {
				pressuriser = entity,
				nodes = nodes
			}
			well.amount = total_yield
		end
		script_data.wells[well_id].pressuriser = entity
		script_data.pressurisers[entity.unit_number % 60][entity.unit_number] = {
			entity = entity,
			well_id = well_id
		}
	end
	if entity.name == extractor then
		local node = entity.surface.find_entities_filtered{position=entity.position, type="resource"}[1] -- can be assumed to exist since we built a miner on it
		local node_id = script.register_on_entity_destroyed(node)
		script_data.extractors[entity.unit_number] = {
			entity = entity,
			node_id = node_id
		}
		-- if there is no pressuriser, set the node to minimal yield
		if not getPressuriserForExtractor(entity) then
			node.amount = 1
		-- else it'll get updated on the next tick of the pressuriser anyway so don't worry about it
		end
	end
end

---@param entity LuaEntity
local function onRemoved(entity)
	if entity.name == pressuriser then
		-- pressuriser removed: depressurise all satellite nodes
		local nodes = getSatelliteNodesForPressuriser(entity)
		for _,node_id in pairs(nodes) do
			local node = script_data.nodes[node_id].node
			node.amount = 1
		end

		script_data.pressurisers[entity.unit_number % 60][entity.unit_number] = nil
	end
	if entity.name == extractor then
		-- extractor removed: just unregister it
		script_data.extractors[entity.unit_number] = nil
	end
end

---@param event on_tick
local function onTick(event)
	for _,entry in pairs(script_data.pressurisers[event.tick%60]) do
		-- each station will "tick" once every 60 in-game ticks, ie. every second
		-- check pressuriser for power and modules, and modify the satellite nodes accordingly
		local pressure = entry.entity
		local nodes = getSatelliteNodesForPressuriser(pressure)
		local modifier = 0
		if pressure.energy > 0 then
			modifier = 1 + pressure.speed_bonus
		end
		for _,node_id in pairs(nodes) do
			local ndata = script_data.nodes[node_id]
			ndata.node.amount = math.max(1, ndata.amount * modifier)
		end
	end
end

return bev.applyBuildEvents{
	on_init = function()
		global.wells = global.wells or script_data
	end,
	on_load = function()
		script_data = global.wells or script_data
	end,
	on_build = {
		callback = onBuilt,
		filter = {name={pressuriser,extractor}}
	},
	on_destroy = {
		callback = onRemoved,
		filter = {name={pressuriser,extractor}}
	},
	events = {
		[defines.events.on_tick] = onTick
	}
}
