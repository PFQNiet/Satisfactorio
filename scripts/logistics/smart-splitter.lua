-- a splitter that allows setting a single filter on each output
local io = require(modpath.."scripts.lualib.input-output")
local bev = require(modpath.."scripts.lualib.build-events")
local link = require(modpath.."scripts.lualib.linked-entity")

local splitter = "smart-splitter"
local buffer = "merger-splitter-box"

local script_data = require(modpath.."scripts.logistics.splitters").data

---@param entity LuaEntity
local function findStruct(entity)
	return script_data.splitters[entity.unit_number]
end
---@param player LuaPlayer
local function closeGui(player)
	local gui = player.gui.screen['smart-splitter']
	if gui then gui.visible = false end
	player.opened = nil
	script_data.gui[player.index] = nil
end

---@param event on_build
local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not (entity and entity.valid) then return end

	if entity.name == splitter then
		local box = entity.surface.create_entity{
			name = buffer,
			position = entity.position,
			force = entity.force,
			raise_built = true
		}
		link.register(entity, box)

		local struct = {
			base = entity,
			filters = {
				left = nil,
				forward = "any",
				right = nil
			},
			connections = {
				left = {},
				forward = {},
				right = {}
			},
			buffer = box
		}

		local control = entity.get_or_create_control_behavior()
		control.set_signal(2, {signal={type="virtual",name="signal-any"},count=1})
		control.enabled = false

		local conn = io.addConnection(entity, {0,1}, "input", box)
		-- connect inserters to buffer and only enable if item count = 0
		for _,inserter in pairs{conn.inserter_left, conn.inserter_right} do
			inserter.connect_neighbour{
				wire = defines.wire_type.red,
				target_entity = box
			}
			inserter.get_or_create_control_behavior().circuit_condition = {
				condition = {
					first_signal = {
						type="virtual", name="signal-everything"
					},
					comparator = "=",
					constant = 0
				}
			}
		end

		local outputs = {
			{side="forward",position={0,-1}, direction=defines.direction.north},
			{side="right", position={1,0}, direction=defines.direction.east},
			{side="left", position={-1,0}, direction=defines.direction.west}
		}
		for _,pos in pairs(outputs) do
			local conn = io.addConnection(entity, pos.position, "output", box, pos.direction)
			conn.inserter_left.inserter_filter_mode = "whitelist"
			conn.inserter_right.inserter_filter_mode = "whitelist"
			struct.connections[pos.side] = conn
		end

		entity.rotatable = false
		script_data.splitters[entity.unit_number] = struct
	end
end

---@param event on_destroy
local function onRemoved(event)
	local entity = event.entity
	if not (entity and entity.valid) then return end

	if entity.name == splitter then
		script_data.splitters[entity.unit_number] = nil
		-- find any players that had this GUI open and close it
		for pid,struct in pairs(script_data.gui) do
			if struct.base == entity then
				closeGui(game.players[pid])
			end
		end
	end
end

local others = {
	left = {"forward","right"},
	forward = {"left","right"},
	right = {"left","forward"}
}
---@param filter string|string[]|nil Item name or any/any-undefined/overflow
---@param item string Name of the item being checked
---@param struct SmartSplitterData
---@param look string[] Other directions to peek at
local function testFilter(filter, item, struct, look)
	-- "overflow" is treated as "any-undefined" here
	if type(filter) == "table" then
		for _,f in pairs(filter) do
			if testFilter(f, item, struct, look) then
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
					if f and (f == "any" or f == item) then
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
---@param filter string|string[]|nil
local function filterContainsOverflow(filter)
	if not filter then
		return false
	elseif type(filter) == "table" then
		for _,f in pairs(filter) do
			if filterContainsOverflow(f) then return true end
		end
		return false
	else
		return filter == "overflow"
	end
end
---@param look string[] Directions to peek in - if all are filled then overflow is true
---@param valid string[] List of directions to consider in the first place
---@param struct SmartSplitterData
local function checkOverflow(look, valid, struct)
	for _,dir in pairs(look) do
		local active = (valid[1] and valid[1] == dir) or (valid[2] and valid[2] == dir) or (valid[3] and valid[3] == dir) -- unrolled in_array
		if active then
			-- check inserters to see if they are holding stuff
			-- if one of them isn't, then the lane isn't overflowed
			if not struct.connections[dir].inserter_left.held_stack.valid_for_read or not struct.connections[dir].inserter_right.held_stack.valid_for_read then
				return false
			end
		end
	end
	return true
end

---@param event on_tick
local function onTick(event)
	for _,struct in pairs(script_data.splitters) do
		local contents = struct.buffer.get_inventory(defines.inventory.chest)[1]
		if contents.valid_for_read then
			local valid = {}
			for dir,look in pairs(others) do
				-- first pass: everything except overflow
				local filter = struct.filters[dir]
				if testFilter(filter, contents.name, struct, look) then
					table.insert(valid, dir)
				end
			end
			for dir,look in pairs(others) do
				-- second pass: overflow
				-- this is done in a second pass so that only options that are enabled are considered for overflowing
				-- this means that if one side takes iron and the other copper, the current item is iron, iron is full but copper isn't, copper isn't considered anyway
				local filter = struct.filters[dir]
				if filterContainsOverflow(filter) then
					if checkOverflow(look, valid, struct) then
						table.insert(valid, dir)
					end
				end
			end
			local candidates = {}
			for _,dir in pairs(valid) do
				-- final pass: get inserters that aren't already holding something
				if struct.connections[dir].inserter_left.active and not struct.connections[dir].inserter_left.held_stack.valid_for_read then
					table.insert(candidates, struct.connections[dir].inserter_left.held_stack)
				end
				if struct.connections[dir].inserter_right.active and not struct.connections[dir].inserter_right.held_stack.valid_for_read then
					table.insert(candidates, struct.connections[dir].inserter_right.held_stack)
				end
			end
			if #candidates > 0 then
				-- found at least one candidate for receiving the item!
				local choose = math.floor(event.tick/4) % #candidates -- this should cycle through candidates equally
				candidates[choose+1].transfer_stack(contents)
			-- else the item stays stuck in the splitter's buffer until deconstructed or filters are set to allow it through
			end
		end
	end
end

---@param struct SmartSplitterData
---@param columns LuaGuiElement
local function fullGuiUpdate(struct, columns)
	local prototypes = game.item_prototypes

	for _,dir in pairs({"left","forward","right"}) do
		local list = columns["filter-"..dir].filters
		list.clear()
		local flow = list.add{
			type = "flow",
			style = "smart_splitter_filter_flow"
		}
		local menu = flow.add{
			type = "drop-down",
			name = "smart-splitter-"..dir.."-selection",
			style = "smart_splitter_filter_dropdown",
			items = {
				"None",
				{"","[img=virtual-signal.signal-any] ",{"gui.smart-splitter-any"}},
				{"","[img=virtual-signal.signal-any-undefined] ",{"gui.smart-splitter-any-undefined"}},
				{"","[img=virtual-signal.signal-overflow] ",{"gui.smart-splitter-overflow"}},
				"Item..."
			},
			selected_index = struct.filters[dir] and (({
				["any"] = 2,
				["any-undefined"] = 3,
				["overflow"] = 4
			})[struct.filters[dir]] or 5) or 1
		}
		local item = flow.add{
			type = "choose-elem-button",
			name = "smart-splitter-"..dir.."-item",
			elem_type = "item",
			item = struct.filters[dir] and prototypes[struct.filters[dir]] and struct.filters[dir] or nil
		}
		item.visible = menu.selected_index == 5
	end
end
---@param struct SmartSplitterData
---@param gui LuaGuiElement columns (left forward right) each containing a "filters" as an array of one (multiple for programmable) consisting of the drop-down and item elements
local function updateSplitter(struct, gui)
	---@type LuaConstantCombinatorControlBehavior
	local control = struct.base.get_control_behavior()
	for slot,dir in pairs({"left","forward","right"}) do
		local flow = gui["filter-"..dir].filters.children[1]
		local index = flow.children[1].selected_index
		local item = flow.children[2].elem_value
		struct.filters[dir] = ({
			nil, "any", "any-undefined", "overflow"
		})[index] or item
		control.set_signal(slot,({
			nil,
			{signal={type="virtual",name="signal-any"},count=1},
			{signal={type="virtual",name="signal-any-undefined"},count=1},
			{signal={type="virtual",name="signal-overflow"},count=1}
		})[index]
			or (item and {signal={type="item",name=item},count=1} or nil)
		)
	end
end
---@param event on_entity_settings_pasted
local function onPaste(event)
	if event.destination.name == splitter then
		-- read signals and update struct accordingly
		local players = game.players
		local struct = findStruct(event.destination)
		---@type LuaConstantCombinatorControlBehavior
		local control = struct.base.get_control_behavior()
		for slot,dir in pairs({"left","forward","right"}) do
			local signal = control.get_signal(slot).signal
			if not signal then
				struct.filters[dir] = nil
			elseif signal.type == "virtual" then
				struct.filters[dir] = ({
					["signal-any"] = "any",
					["signal-any-undefined"] = "any-undefined",
					["signal-overflow"] = "overflow"
				})[signal.name] or nil
			elseif signal.type == "item" then
				struct.filters[dir] = signal.name
			end
		end
		for pid,other in pairs(script_data.gui) do
			if other.base == struct.base then
				fullGuiUpdate(other, players[pid].gui.screen['smart-splitter'].columns)
			end
		end
	end
end

--[[
	GUI[screen]
	- frame[smart-splitter]
	-- title[title_flow]
	-- columns[columns] (left, forward, right)
	--- frame[filter-{DIR}]
	---- title
	----- label
	---- flow[filters]
	----- flow
	------ dropdown[smart-splitter-{DIR}-selection]
	------ item[smart-splitter-{DIR}-item]
]]

---@param event on_gui_opened
local function onGuiOpened(event)
	local player = game.players[event.player_index]
	if event.gui_type == defines.gui_type.entity and event.entity.name == splitter then
		-- create the custom gui and open that instead
		local gui = player.gui.screen
		if not gui['smart-splitter'] then
			local frame = player.gui.screen.add{
				type = "frame",
				name = "smart-splitter",
				direction = "vertical",
				style = "inner_frame_in_outer_frame"
			}
			local title_flow = frame.add{type = "flow", name = "title_flow"}
			local title = title_flow.add{type = "label", caption = event.entity.localised_name, style = "frame_title"}
			title.drag_target = frame
			local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_in_window_title"}
			pusher.drag_target = frame
			title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white", name = "smart-splitter-close"}

			local columns = frame.add{
				type = "flow",
				name = "columns",
				style = "horizontal_flow_with_extra_spacing"
			}
			for _,dir in pairs({"left","forward","right"}) do
				local col = columns.add{
					type = "frame",
					style = "inside_shallow_frame",
					direction = "vertical",
					name = "filter-"..dir
				}
				local subtitle = col.add{
					type = "frame",
					style = "full_subheader_frame"
				}
				subtitle.add{
					type = "label",
					style = "heading_2_label",
					caption = {"gui.smart-splitter-"..dir}
				}
				col.add{
					type = "flow",
					style = "smart_splitter_filter_container_flow",
					direction = "vertical",
					name = "filters"
				}
			end
		end
		local frame = gui['smart-splitter']
		local columns = frame.columns

		local struct = findStruct(event.entity)
		fullGuiUpdate(struct, columns)

		frame.visible = true
		player.opened = frame
		script_data.gui[player.index] = struct
		frame.force_auto_center()
	end
end
---@param event on_gui_closed
local function onGuiClosed(event)
	if event.element and event.element.valid and event.element.name == "smart-splitter" then
		local player = game.players[event.player_index]
		closeGui(player)
	end
end
---@param event on_gui_click
local function onGuiClick(event)
	if event.element and event.element.valid and event.element.name == "smart-splitter-close" then
		local player = game.players[event.player_index]
		closeGui(player)
	end
end
---@param event on_gui_selection_state_changed
local function onGuiSelected(event)
	if event.element.valid and (
		event.element.name == "smart-splitter-left-selection"
		or event.element.name == "smart-splitter-forward-selection"
		or event.element.name == "smart-splitter-right-selection"
 	) then
		local players = game.players
		local struct = script_data.gui[event.player_index]
		updateSplitter(struct, game.players[event.player_index].gui.screen['smart-splitter'].columns)

		local index = event.element.selected_index
		local itemsel = event.element.parent.children[2]
		itemsel.visible = index == 5
		-- mirror this change to other players with this entity open
		local dir = ({
			["smart-splitter-left-selection"] = "left",
			["smart-splitter-forward-selection"] = "forward",
			["smart-splitter-right-selection"] = "right"
		})[event.element.name]

		for pid,other in pairs(script_data.gui) do
			if event.player_index ~= pid and other.base == struct.base then
				local flow = players[pid].gui.screen['smart-splitter'].columns["filter-"..dir].filters.children[1]
				flow.children[1].selected_index = index
				flow.children[2].visible = index == 5
			end
		end
	end
end
---@param event on_gui_elem_changed
local function onGuiElemChanged(event)
	if event.element.valid and (
		event.element.name == "smart-splitter-left-item"
		or event.element.name == "smart-splitter-forward-item"
		or event.element.name == "smart-splitter-right-item"
	) then
		local struct = script_data.gui[event.player_index]
		updateSplitter(struct, game.players[event.player_index].gui.screen['smart-splitter'].columns)
		-- mirror this change to other players with this entity open
		local dir = ({
			["smart-splitter-left-item"] = "left",
			["smart-splitter-forward-item"] = "forward",
			["smart-splitter-right-item"] = "right"
		})[event.element.name]
		for pid,other in pairs(script_data.gui) do
			if event.player_index ~= pid and other.base == struct.base then
				local flow = game.players[pid].gui.screen['smart-splitter'].columns["filter-"..dir].filters.children[1]
				flow.children[2].elem_value = event.element.elem_value
			end
		end
	end
end

-- if the player moves and has a splitter open, check that the splitter can still be reached
---@param event on_player_changed_position
local function onMove(event)
	local player = game.players[event.player_index]
	local struct = script_data.gui[player.index]
	if struct and struct.base.name == splitter then
		if not player.can_reach_entity(struct.base) then
			closeGui(player)
		end
	end
end

return bev.applyBuildEvents{
	on_build = onBuilt,
	on_destroy = onRemoved,
	on_nth_tick = {
		[4] = onTick
	},
	events = {
		[defines.events.on_gui_opened] = onGuiOpened,
		[defines.events.on_gui_closed] = onGuiClosed,
		[defines.events.on_gui_click] = onGuiClick,
		[defines.events.on_gui_selection_state_changed] = onGuiSelected,
		[defines.events.on_gui_elem_changed] = onGuiElemChanged,

		[defines.events.on_entity_settings_pasted] = onPaste,

		[defines.events.on_player_changed_position] = onMove
	}
}
