local gui = require(modpath.."scripts.gui.pipe-flow")

-- uses global.pipe_flow to track rolling average flow
-- opening a pipe's GUI adds it to the tracking list, closing it (provided no other player has it open) removes it

---@class PipeFlowData
---@field entity LuaEntity Pipe or PipeToGround
---@field opened_by table<uint, boolean> Map of players who have this pipe open
---@field rolling_average number Flow rate over the last 60 ticks

---@alias global.pipe_flow table<uint, PipeFlowData>
---@type global.pipe_flow
local script_data = {}

local tier1 = {flow = 300, distance = 20}
local tier2 = {flow = 600, distance = 50}
local entities = {
	["pipeline"] = tier1,
	["underground-pipeline"] = tier1,
	["pipeline-mk-2"] = tier2,
	["underground-pipeline-mk-2"] = tier2
}

---@param root LuaEntity
---@return number|LocalisedString
local function measurePipeSection(root)
	local visited = {[root.unit_number] = true}
	local bailout = 200 -- entities[root.name].distance * 1.5
	local addself = root.type == "pump" and 0 or 1 -- add self if self is a pipe or pipe-to-ground
	---@param node LuaEntity
	---@param length number
	local function recurse(node, length)
		visited[node.unit_number] = true
		if length > bailout then return bailout end
		local max = length
		for _,neighbour in pairs(node.neighbours[1]) do
			if entities[neighbour.name] and not visited[neighbour.unit_number] then
				local upstream = recurse(neighbour, length+1)
				if upstream > max then max = upstream end
			end
		end
		return max
	end

	local lengths = {}
	for _,neighbour in pairs(root.neighbours[1]) do
		if entities[neighbour.name] and not visited[neighbour.unit_number] then
			table.insert(lengths, recurse(neighbour,1))
		end
	end
	local count = #lengths
	local total
	if count == 0 then
		total = addself
	elseif count == 1 then
		total = lengths[1] + addself
	else
		-- add the two longest lengths to get the total length
		table.sort(lengths)
		total = lengths[count] + lengths[count-1] + addself
	end
	return total < bailout and total or {"gui.pipe-too-long"}
end

---@param event on_gui_opened
local function onGuiOpened(event)
	if not (event.entity and event.entity.valid) then return end
	if entities[event.entity.name] then
		if not script_data[event.entity.unit_number] then
			script_data[event.entity.unit_number] = {
				entity = event.entity,
				opened_by = {},
				rolling_average = nil
			}
		end
		local player = game.players[event.player_index]

		local length_string = {"gui.pipe-length",measurePipeSection(event.entity),entities[event.entity.name].distance}
		gui.open_gui(player, event.entity, length_string)

		script_data[event.entity.unit_number].opened_by[player.index] = true
	end
end

---@param event on_gui_closed
local function onGuiClosed(event)
	if not (event.entity and event.entity.valid) then return end
	if entities[event.entity.name] and script_data[event.entity.unit_number] then
		local player = game.players[event.player_index]
		local struct = script_data[event.entity.unit_number]
		struct.opened_by[player.index] = nil
		if not next(struct.opened_by) then
			script_data[event.entity.unit_number] = nil
		end
	end
end

local function onTick()
	for id,struct in pairs(script_data) do
		if not struct.entity.valid then
			script_data[id] = nil
		else
			local fluidbox = struct.entity.fluidbox
			local fluid = fluidbox[1]
			local max = entities[struct.entity.name].flow
			if fluid then
				local flow = fluidbox.get_flow(1)
				struct.rolling_average = ((struct.rolling_average or flow) * 299 + flow) / 300
				for pid in pairs(struct.opened_by) do
					gui.update_flow(game.players[pid], fluid, struct.rolling_average * 3600, max)
				end
			else
				for pid in pairs(struct.opened_by) do
					gui.update_flow(game.players[pid], nil, 0, max)
				end
			end
		end
	end
end

return {
	on_init = function()
		global.pipe_flow = global.pipe_flow or script_data
	end,
	on_load = function()
		script_data = global.pipe_flow or script_data
	end,
	events = {
		[defines.events.on_gui_opened] = onGuiOpened,
		[defines.events.on_gui_closed] = onGuiClosed,
		[defines.events.on_tick] = onTick
	}
}
