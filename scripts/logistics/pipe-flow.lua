-- uses global.pipe_flow to track rolling average flow
-- opening a pipe's GUI adds it to the tracking list, closing it (provided no other player has it open) removes it

---@class PipeFlowData
---@field entity LuaEntity Pipe or PipeToGround
---@field opened_by table<uint, LuaGuiElement> Map of players who have this pipe open, to the GUI element showing pipe flow
---@field rolling_average number[] Flow rate over the last 60 ticks

---@alias global.pipe_flow table<uint, PipeFlowData>
---@type global.pipe_flow
local script_data = {}

local tier1 = {flow = 300, distance = 20}
local tier2 = {flow = 600, distance = 50}
local entities = {
	["pipeline"] = tier1,
	["underground-pipeline"] = tier1,
	-- ["pump"] = tier1,
	["pipeline-mk-2"] = tier2,
	["underground-pipeline-mk-2"] = tier2,
	-- ["pipeline-pump-mk-2"] = tier2
}
local entity_names = {}
for k,_ in pairs(entities) do table.insert(entity_names,k) end

---@param root LuaEntity
---@return number|LocalisedString
local function measurePipeSection(root)
	local visited = {[root.unit_number] = true}
	local bailout = 200 -- entities[root.name].distance * 1.5
	local addself = root.type == "pump" and 0 or 1 -- add self if self is a pipe or pipe-to-ground
	local function recurse(node, length)
		visited[node.unit_number] = true
		if length > bailout then return bailout end
		local max = length
		for _,next in pairs(node.neighbours[1]) do
			if (next.type == "pipe" or next.type == "pipe-to-ground") and not visited[next.unit_number] then
				local upstream = recurse(next, length+1)
				if upstream > max then max = upstream end
			end
		end
		return max
	end

	local lengths = {}
	for _,next in pairs(root.neighbours[1]) do
		if (next.type == "pipe" or next.type == "pipe-to-ground") and not visited[next.unit_number] then
			table.insert(lengths, recurse(next,1))
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
				rolling_average = {}
			}
		end
		local player = game.players[event.player_index]
		local gui = player.gui.relative
		if not gui['pipe-flow'] then
			local frame = player.gui.relative.add{
				type = "frame",
				name = "pipe-flow",
				anchor = {
					gui = defines.relative_gui_type.pipe_gui,
					position = defines.relative_gui_position.bottom,
					names = entity_names
				},
				direction = "vertical",
				style = "inset_frame_container_frame"
			}
			frame.style.use_header_filler = false

			local inner = frame.add{
				type = "frame",
				name = "inner",
				direction = "vertical",
				style = "inside_shallow_frame_with_padding"
			}
			inner.add{
				type = "label",
				caption = {"gui.pipe-flow-title"},
				style = "heading_3_label"
			}
			local flow = inner.add{
				type = "flow",
				direction = "horizontal",
				name = "content"
			}
			flow.style.top_margin = 4
			flow.style.bottom_margin = 12
			flow.style.horizontal_spacing = 12
			flow.add{
				type = "sprite-button",
				name = "fluid",
				style = "transparent_slot"
			}
			local flow2 = flow.add{
				type = "flow",
				direction = "vertical",
				name = "details"
			}
			flow2.add{
				type = "label",
				caption = {"gui.pipe-flow-calculating"},
				name = "flowtext"
			}
			local bar = flow2.add{
				type = "progressbar",
				name = "bar"
			}
			bar.style.horizontally_stretchable = true

			inner.add{
				type = "label",
				name = "pipe-length"
			}
		end

		gui['pipe-flow'].inner['pipe-length'].caption = {"gui.pipe-length",measurePipeSection(event.entity),entities[event.entity.name].distance}

		script_data[event.entity.unit_number].opened_by[player.index] = gui['pipe-flow'].inner.content
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
			local sprite = "fluid/"..(fluid and fluid.name or "fluid-unknown")
			local caption
			local bar = 0
			local max = entities[struct.entity.name].flow
			if fluid then
				table.insert(struct.rolling_average, fluidbox.get_flow(1))
				if #struct.rolling_average > 60 then
					table.remove(struct.rolling_average,1)
					local avg = 0
					for _,val in pairs(struct.rolling_average) do
						avg = avg + val*60 -- /60 values * 60t/s * 60s/m
					end
					caption = {"gui.pipe-flow-details",{"fluid-name."..fluid.name},string.format("%.1f",avg),max,{"per-minute-suffix"}}
					bar = avg / max
				else
					caption = {"gui.pipe-flow-calculating"}
				end
			else
				caption = {"gui.pipe-flow-details",{"gui.pipe-flow-no-fluid"},"---.-",max,{"per-minute-suffix"}}
			end
			for _,gui in pairs(struct.opened_by) do
				gui['fluid'].sprite = sprite
				gui['details'].flowtext.caption = caption
				gui['details'].bar.value = bar
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
