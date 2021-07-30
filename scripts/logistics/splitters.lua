local consts = require(modpath.."scripts.lualib.splitters")
local bev = require(modpath.."scripts.lualib.build-events")
local string = require(modpath.."scripts.lualib.string")
local gui = {
	["smart-splitter"] = require(modpath.."scripts.gui.smart-splitter"),
	["programmable-splitter"] = require(modpath.."scripts.gui.programmable-splitter")
}

---@class SmartSplitterData
---@field base LuaEntity ConstantCombinator
---@field buffer LuaEntity Container
---@field itemstack LuaItemStack
---@field filters table<SmartSplitterDirection, SmartSplitterFilter> Names of one or more items or any/any-undefined/overflow to allow through the given direction
---@field connections table<string, MachineConnection>
---@field cycle uint8 Count number of items that pass through, mod 6

---@alias SmartSplitterFilterSingle SmartSplitterSpecialFilter|string|nil
---@alias SmartSplitterFilter SmartSplitterFilterSingle|SmartSplitterFilterSingle[]

---@type table<SmartSplitterDirection, SmartSplitterDirection[]>
local other_directions = {
	[consts.directions.left] = {consts.directions.forward, consts.directions.right},
	[consts.directions.forward] = {consts.directions.left, consts.directions.right},
	[consts.directions.right] = {consts.directions.left, consts.directions.forward}
}

---@class global.magic_splitters
---@field splitters table<uint,SmartSplitterData>
local script_data = {
	splitters = {}
}

---@type table<SmartSplitterDirection, uint8>
local direction_bitmask = {
	[consts.directions.left] = 4,
	[consts.directions.forward] = 2,
	[consts.directions.right] = 1
}
-- Arrange the splitter's filters into signals and save on the constant combinator
---@param struct SmartSplitterData
local function serialise(struct)
	---@type LuaConstantCombinatorControlBehavior
	local control = struct.base.get_or_create_control_behavior()
	---@type ConstantCombinatorParameters[]
	local signals = {}
	for dir,filter in pairs(struct.filters) do
		local dirindex = direction_bitmask[dir]
		if filter then
			if type(filter) == "string" then
				filter = {filter}
			end
			---@typelist number, SmartSplitterFilterSingle
			for _,f in pairs(filter) do
				---@type SignalID
				local signal = consts.specials[f] and {type="virtual",name="signal-"..f} or {type="item",name=f}
				---@type ConstantCombinatorParameters
				local param = {
					index = #signals+1,
					signal = signal,
					count = dirindex
				}
				signals[param.index] = param
			end
		end
	end
	control.parameters = signals
end

-- Load signals from constant combinator and parse into filter data
---@param struct SmartSplitterData
local function unserialise(struct)
	---@type LuaConstantCombinatorControlBehavior
	local control = struct.base.get_or_create_control_behavior()
	local signals = control.parameters
	---@type table<SmartSplitterDirection, SmartSplitterFilterSingle[]>
	local filters = {
		[consts.directions.left] = {},
		[consts.directions.forward] = {},
		[consts.directions.right] = {}
	}
	for _,signal in pairs(signals) do
		local sig = signal.signal
		local result
		if sig.type == "virtual" and consts.specials[string.remove_prefix(sig.name, "signal-")] then
			result = string.remove_prefix(sig.name, "signal-")
		elseif sig.type == "item" then
			result = sig.name
		end
		if result then
			for dir,bit in pairs(direction_bitmask) do
				if bit32.btest(signal.count, bit) then
					table.insert(filters[dir], result)
				end
			end
		end
	end
	if #filters[consts.directions.left] + #filters[consts.directions.forward] + #filters[consts.directions.right] == 0 then
		-- no filters set, default to forward:Any
		filters[consts.directions.forward] = {"any"}
	end
	for dir,flist in pairs(filters) do
		if struct.base.name == "smart-splitter" then
			-- only allowed one filter per direction, so take the first in case a programmable splitter is copied in
			struct.filters[dir] = flist[1]
		else
			struct.filters[dir] = flist
		end
	end
end

---@param base LuaEntity ConstantCombinator
---@param buffer LuaEntity Container
---@param connections table<SmartSplitterDirection, MachineConnection>
local function setupSplitter(base, buffer, connections)
	---@type SmartSplitterData
	local struct = {
		base = base,
		filters = {
			left = {},
			forward = {"any"},
			right = {}
		},
		connections = connections,
		buffer = buffer,
		itemstack = buffer.get_inventory(defines.inventory.chest)[1]
	}
	-- set connection inserters to "whitelist" mode so that they don't pick up anything
	for _,conn in pairs(struct.connections) do
		conn.inserter_left.inserter_filter_mode = "whitelist"
		conn.inserter_right.inserter_filter_mode = "whitelist"
	end
	-- load filters from the combinator
	unserialise(struct)
	script_data.splitters[base.unit_number] = struct
end

---@param base LuaEntity
local function getSplitter(base)
	return script_data.splitters[base.unit_number]
end

---@param struct SmartSplitterData
local function cleanupSplitter(struct)
	gui[struct.base.name].destroy_gui(struct)
	script_data.splitters[struct.base.unit_number] = nil
end

---@param struct SmartSplitterData
---@param filter SmartSplitterFilter Item name or any/any-undefined/overflow
---@param item string Name of the item being checked
---@param look string[] Other directions to peek at
local function testFilter(struct, filter, item, look)
	-- "overflow" is treated as "any-undefined" here
	if type(filter) == "table" then
		for _,f in pairs(filter) do
			if testFilter(struct, f, item, look) then
				return true
			end
		end
		return false
	elseif filter == "any" then
		return true
	elseif filter == "any-undefined" or filter == "overflow" then
		-- check the other filters and, if none of them match, then this one matches
		for _,dir in pairs(look) do
			local other = struct.filters[dir]
			if not other then
				-- can't match
			elseif type(other) == "table" then
				for _,f in pairs(other) do
					if f == "any" or f == item then
						return false
					end
				end
			elseif other == "any" or other == item then
				return false
			end
		end
		return true
	else
		return filter == item
	end
end

---@param filter SmartSplitterFilter
local function filterContainsOverflow(filter)
	if not filter then
		return false
	elseif type(filter) == "table" then
		for _,f in pairs(filter) do
			if f == "overflow" then return true end
		end
		return false
	else
		return filter == "overflow"
	end
end

---@param struct SmartSplitterData
---@param look string[] Directions to peek in - if all are filled then overflow is true
---@param valid string[] List of directions to consider in the first place
local function checkOverflow(struct, look, valid)
	for _,dir in pairs(look) do
		if valid[dir] then
			-- check inserters to see if they are holding stuff
			-- if one of them isn't, then the lane isn't overflowed
			if not struct.connections[dir].inserter_left.held_stack.valid_for_read then
				return false
			end
			if not struct.connections[dir].inserter_right.held_stack.valid_for_read then
				return false
			end
		end
	end
	return true
end

---@param event NthTickEventData
local function processSplitters(event)
	for _,struct in pairs(script_data.splitters) do
		if not struct.itemstack then
			struct.itemstack = struct.buffer.get_inventory(defines.inventory.chest)[1]
		end
		local contents = struct.itemstack
		if contents.valid_for_read then
			---@type table<defines.direction,boolean> Directions that the item could go if there is space
			local valid = {}
			for dir,look in pairs(other_directions) do
				-- first pass: everything except overflow
				local filter = struct.filters[dir]
				if testFilter(struct, filter, contents.name, look) then
					valid[dir] = true
				end
			end
			for dir,look in pairs(other_directions) do
				-- second pass: overflow
				-- this is done in a second pass so that only options that are enabled are considered for overflowing
				-- this means that if one side takes iron and the other copper, the current item is iron, iron is full but copper isn't, copper isn't considered anyway
				local filter = struct.filters[dir]
				if filterContainsOverflow(filter) then
					if checkOverflow(struct, look, valid) then
						valid[dir] = true
					end
				end
			end
			---@type LuaItemStack[] Inserter held stacks that have space to receive the item
			local candidates = {}
			for dir in pairs(valid) do
				-- final pass: get inserters that aren't already holding something
				if struct.connections[dir].inserter_left.active and not struct.connections[dir].inserter_left.held_stack.valid_for_read then
					table.insert(candidates, struct.connections[dir].inserter_left.held_stack)
				end
				if struct.connections[dir].inserter_right.active and not struct.connections[dir].inserter_right.held_stack.valid_for_read then
					table.insert(candidates, struct.connections[dir].inserter_right.held_stack)
				end
			end
			local index = (struct.cycle or 0)
			struct.cycle = (index + contents.count) % 6
			for _=1,contents.count do
				if #candidates > 0 then
					-- found at least one candidate for receiving the item!
					local choose = (index % #candidates) + 1
					if contents.count > 1 then
						candidates[choose].set_stack{name=contents.name, count=1}
						contents.count = contents.count - 1
					else
						candidates[choose].transfer_stack(contents)
					end
					table.remove(candidates, choose)
					-- else the item stays stuck in the splitter's buffer until deconstructed or filters are set to allow it through
				end
			end
		end
	end
end

---@param event on_destroy
local function onRemoved(event)
	local struct = getSplitter(event.entity)
	if not struct then return end
	cleanupSplitter(struct)
end

---@param event on_entity_settings_pasted
local function onPaste(event)
	local struct = getSplitter(event.destination)
	if not struct then return end
	unserialise(struct)
	serialise(struct)
	gui[struct.base.name].update_gui(struct)
end

return {
	create = setupSplitter,
	get = getSplitter,
	refresh = serialise,
	lib = bev.applyBuildEvents{
		on_destroy = onRemoved,
		on_init = function()
			global.splitters = global.splitters or script_data
		end,
		on_load = function()
			script_data = global.splitters or script_data
		end,
		on_nth_tick = {
			[4] = processSplitters
		},
		events = {
			[defines.events.on_entity_settings_pasted] = onPaste
		}
	}
}
