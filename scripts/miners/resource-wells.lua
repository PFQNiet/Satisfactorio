-- on first-time placement, spawn satellite nodes
-- periodically check power and modules, distributing those effects to extractors
-- on removal, signal extractors to shut down, and on re-placement check for existing extractors and power them up
-- uses global.wells to track data
-- note that resource entities do not have a unit_number, so script.register_on_entity_destroyed(entity) is used to get a UID for them

local string = require(modpath.."scripts.lualib.string")

local pressuriser = "resource-well-pressuriser"
local extractor = "resource-well-extractor"

local script_data = {
	pressurisers = {}, -- partitioned, entry = {entity, well_id}
	wells = {}, -- map well UID to entity, pressuriser (if present), and satellite node UIDs
	nodes = {}, -- map node UID to entity, base amount, and well UID
	extractors = {} -- map extractor unit number to its entity and corresponding node UID
}
for i=0,60-1 do script_data.pressurisers[i] = {} end

local function getPressuriserForExtractor(extractor)
	local exdata = script_data.extractors[extractor.unit_number]
	if not exdata then return end
	local ndata = script_data.wells[exdata.node_id]
	if not ndata then return end
	local well = script_data.wells[ndata.well_id]
	return well and well.pressuriser
end
local function getSatelliteNodesForPressuriser(pressuriser)
	local pdata = script_data.pressurisers[pressuriser.unit_number % 60][pressuriser.unit_number]
	if not pdata then return end
	local well = script_data.wells[pdata.well_id]
	return well.nodes
end

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == pressuriser then
		-- if the well hasn't been registered yet, spawn satellite nodes
		local well = entity.surface.find_entities_filtered{position=entity.position, type="resource"}[1] -- can be assumed to exist since we built a miner on it
		local well_id = script.register_on_entity_destroyed(well)
		if not script_data.wells[well_id] then
			local nodetype = string.remove_suffix(well.name, "-well").."-node"
			local nodes = {}
			local total_yield = 0
			for maxrange=16,100 do
				-- keep trying with bigger and bigger ranges until we get at least one satellite spawned
				for i=0,11 do
					-- TODO vary based on map richness settings
					if math.random() < 0.75 then
						local r = math.random(9,maxrange)
						local th = i/12*math.pi*2
						local dx = math.floor(r*math.cos(th))+0.5
						local dy = math.floor(r*math.sin(th))+0.5
						local pos = entity.surface.find_non_colliding_position(nodetype, {entity.position.x+dx, entity.position.y+dy}, 5, 1, true)
						if pos then
							local amount = 60
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
					end
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

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
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

local function onTick(event)
	for i,entry in pairs(script_data.pressurisers[event.tick%60]) do
		-- each station will "tick" once every 60 in-game ticks, ie. every second
		-- check pressuriser for power and modules, and modify the satellite nodes accordingly
		local pressuriser = entry.entity
		local well_id = entry.well_id
		local nodes = getSatelliteNodesForPressuriser(pressuriser)
		local modifier = 0
		if pressuriser.energy > 0 then
			modifier = 1 + pressuriser.speed_bonus
		end
		for _,node_id in pairs(nodes) do
			local ndata = script_data.nodes[node_id]
			ndata.node.amount = math.max(1, ndata.amount * modifier)
		end
	end
end

return {
	on_init = function()
		global.wells = global.wells or script_data
	end,
	on_load = function()
		script_data = global.wells or script_data
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
