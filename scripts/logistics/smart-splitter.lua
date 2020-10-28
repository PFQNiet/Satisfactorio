-- a splitter that allows setting a single filter on each output
-- uses global['smart-splitters'] to track structures {base, buffer, filters, {left1, left2}, {middle1, middle2}, {right1, right2}}
-- GUI uses global['gui-splitter'] to track player > opened smart splitter
local mod_gui = require("mod-gui")
local io = require("scripts.lualib.input-output")
local getitems = require("scripts.lualib.get-items-from")

local splitter = "smart-splitter"
local buffer = "smart-splitter-box"

local function findStruct(entity)
	return global['smart-splitters'] and global['smart-splitters'][entity.unit_number]
end

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == splitter then
		local struct = {
			base = entity,
			filters = {
				left = nil,
				forward = "any",
				right = nil
			}
		}
		local buffer = entity.surface.create_entity{
			name = buffer,
			position = entity.position,
			force = entity.force,
			raise_built = true
		}
		struct.buffer = buffer

		local control = entity.get_or_create_control_behavior()
		control.set_signal(2, {signal={type="virtual",name="signal-any"},count=1})
		control.enabled = false
		
		local belt, inserter1, inserter2, graphic = io.addInput(entity, {0,1}, buffer)
		-- connect inserters to buffer and only enable if item count = 0
		inserter1.connect_neighbour({wire = defines.wire_type.red, target_entity = buffer})
		inserter1.get_or_create_control_behavior().circuit_condition = {condition={first_signal={type="virtual",name="signal-everything"},comparator="=",constant=0}}
		inserter2.connect_neighbour({wire = defines.wire_type.red, target_entity = buffer})
		inserter2.get_or_create_control_behavior().circuit_condition = {condition={first_signal={type="virtual",name="signal-everything"},comparator="=",constant=0}}

		-- connect inserters to base and enable when it gets a virtual signal
		belt, inserter1, inserter2, graphic = io.addOutput(entity, {0,-1}, buffer)
		inserter1.inserter_filter_mode = "whitelist"
		inserter2.inserter_filter_mode = "whitelist"
		struct.forward = {inserter1, inserter2}

		belt, inserter1, inserter2, graphic = io.addOutput(entity, {-1,0}, buffer, defines.direction.west)
		inserter1.inserter_filter_mode = "whitelist"
		inserter2.inserter_filter_mode = "whitelist"
		struct.left = {inserter1, inserter2}

		belt, inserter1, inserter2, graphic = io.addOutput(entity, {1,0}, buffer, defines.direction.east)
		inserter1.inserter_filter_mode = "whitelist"
		inserter2.inserter_filter_mode = "whitelist"
		struct.right = {inserter1, inserter2}

		entity.rotatable = false
		if not global['smart-splitters'] then global['smart-splitters'] = {} end
		global['smart-splitters'][entity.unit_number] = struct
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == splitter then
		local box = entity.surface.find_entity(buffer, entity.position)
		if box and box.valid then
			getitems.storage(box, event.buffer)
			io.remove(entity, event)
			box.destroy()
			global['smart-splitters'][entity.unit_number] = nil
		else
			game.print("Could not find the buffer")
		end
	end
end

local others = {
	left = {"forward","right"},
	forward = {"left","right"},
	right = {"left","forward"}
}
local function testFilter(filter, item, struct, look)
	-- "overflow" is treated as "any-undefined" here
	if type(filter) == "table" then
		local any = false
		for _,f in pairs(filter) do
			if testFilter(f, item, struct, look) then
				any = true
				break
			end
		end
		return any
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
local function checkOverflow(look, valid, struct)
	for _,dir in pairs(look) do
		local active = (valid[1] and valid[1] == dir) or (valid[2] and valid[2] == dir) or (valid[3] and valid[3] == dir) -- unrolled in_array
		if active then
			-- check inserters to see if they are holding stuff
			-- if one of them isn't, then the lane isn't overflowed
			if not struct[dir][1].held_stack.valid_for_read or not struct[dir][2].held_stack.valid_for_read then
				return false
			end
		end
	end
	return true
end
local function onTick(event)
	if not global['smart-splitters'] then return end
	for i,struct in pairs(global['smart-splitters']) do
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
				if not struct[dir][1].held_stack.valid_for_read then
					table.insert(candidates, struct[dir][1].held_stack)
				end
				if not struct[dir][2].held_stack.valid_for_read then
					table.insert(candidates, struct[dir][2].held_stack)
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

local function fullGuiUpdate(struct, columns)
	for _,dir in pairs({"left","forward","right"}) do
		local list = columns["filter-"..dir].filters
		list.clear()
		local flow = list.add{type = "flow"}
		flow.style.vertical_align = "center"
		flow.style.minimal_height = 40
		local menu = flow.add{
			type = "drop-down",
			name = "smart-splitter-"..dir.."-selection",
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
		menu.style.horizontally_stretchable = true
		local item = flow.add{
			type = "choose-elem-button",
			name = "smart-splitter-"..dir.."-item",
			elem_type = "item",
			item = struct.filters[dir] and game.item_prototypes[struct.filters[dir]] and struct.filters[dir] or nil
		}
		item.visible = menu.selected_index == 5
	end
end
local function updateSplitter(struct, gui)
	-- gui is the columns (left forward right) each containing a "filters" as an array of one (multiple for programmable) consisting of the drop-down and item elements
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
local function onPaste(event)
	if event.destination.name == splitter then
		-- read signals and update struct accordingly
		local struct = findStruct(event.destination)
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
		local base = struct.base
		for pid,struct in pairs(global['gui-splitter']) do
			if struct.base == base then
				fullGuiUpdate(struct, game.players[pid].gui.screen['programmable-splitter'].columns)
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
local function onGuiOpened(event)
	local player = game.players[event.player_index]
	if event.gui_type == defines.gui_type.entity and event.entity.name == splitter then
		-- create the custom gui and open that instead
		local gui = player.gui.screen['smart-splitter']
		local columns
		if not gui then
			gui = player.gui.screen.add{
				type = "frame",
				name = "smart-splitter",
				direction = "vertical",
				style = mod_gui.frame_style
			}
			local title_flow = gui.add{type = "flow", name = "title_flow"}
			local title = title_flow.add{type = "label", caption = {"item-name.smart-splitter"}, style = "frame_title"}
			title.drag_target = gui
			local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_header"}
			pusher.style.height = 24
			pusher.style.horizontally_stretchable = true
			pusher.drag_target = gui
			title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white", name = "smart-splitter-close"}
			
			columns = gui.add{
				type = "flow",
				name = "columns"
			}
			columns.style.horizontal_spacing = 12
			for _,dir in pairs({"left","forward","right"}) do
				local col = columns.add{
					type = "frame",
					style = "inside_shallow_frame",
					direction = "vertical",
					name = "filter-"..dir
				}
				local title = col.add{
					type = "frame",
					style = "subheader_frame"
				}
				title.style.horizontally_stretchable = true
				title.add{
					type = "label",
					style = "heading_2_label",
					caption = {"gui.smart-splitter-"..dir}
				}
				local list = col.add{
					type = "flow",
					direction = "vertical",
					name = "filters"
				}
				list.style.padding = 12
				list.style.horizontally_stretchable = true
				list.style.minimal_width = 240
			end
		else
			columns = gui.columns
		end
		
		local struct = findStruct(event.entity)
		fullGuiUpdate(struct, columns)
		
		gui.visible = true
		player.opened = gui
		if not global['gui-splitter'] then global['gui-splitter'] = {} end
		global['gui-splitter'][player.index] = struct
		gui.force_auto_center()
	end
end
local function _closeGui(player)
	local gui = player.gui.screen['smart-splitter']
	if gui then gui.visible = false end
	player.opened = nil
	global['gui-splitter'][player.index] = nil
end
local function onGuiClosed(event)
	if event.element and event.element.valid and event.element.name == "smart-splitter" then
		local player = game.players[event.player_index]
		_closeGui(player)
	end
end
local function onGuiClick(event)
	if event.element and event.element.valid and event.element.name == "smart-splitter-close" then
		local player = game.players[event.player_index]
		_closeGui(player)
	end
end
local function onGuiSelected(event)
	local player = game.players[event.player_index]
	if event.element.valid and (
		event.element.name == "smart-splitter-left-selection"
		or event.element.name == "smart-splitter-forward-selection"
		or event.element.name == "smart-splitter-right-selection"
 	) then
		local struct = global['gui-splitter'][event.player_index]
		updateSplitter(struct, game.players[event.player_index].gui.screen['smart-splitter'].columns)

		local index = event.element.selected_index
		local itemsel = event.element.parent.children[2]
		itemsel.visible = index == 5
		-- mirror this change to other players with this entity open
		local base = struct.base
		local dir = ({
			["smart-splitter-left-selection"] = "left",
			["smart-splitter-forward-selection"] = "forward",
			["smart-splitter-right-selection"] = "right"
		})[event.element.name]
		for pid,struct in pairs(global['gui-splitter']) do
			if event.player_index ~= pid and struct.base == base then
				local flow = game.players[pid].gui.screen['smart-splitter'].columns["filter-"..dir].filters.children[1]
				flow.children[1].selected_index = index
				flow.children[2].visible = index == 5
			end
		end
	end
end
local function onGuiElemChanged(event)
	if event.element.valid and (
		event.element.name == "smart-splitter-left-item"
		or event.element.name == "smart-splitter-forward-item"
		or event.element.name == "smart-splitter-right-item"
	) then
		local struct = global['gui-splitter'][event.player_index]
		updateSplitter(struct, game.players[event.player_index].gui.screen['smart-splitter'].columns)
		-- mirror this change to other players with this entity open
		local base = struct.base
		local dir = ({
			["smart-splitter-left-item"] = "left",
			["smart-splitter-forward-item"] = "forward",
			["smart-splitter-right-item"] = "right"
		})[event.element.name]
		for pid,struct in pairs(global['gui-splitter']) do
			if event.player_index ~= pid and struct.base == base then
				local flow = game.players[pid].gui.screen['smart-splitter'].columns["filter-"..dir].filters.children[1]
				flow.children[2].elem_value = event.element.elem_value
			end
		end
	end
end

return {
	on_nth_tick = {
		[4] = onTick
	},
	events = {
		[defines.events.on_gui_opened] = onGuiOpened,
		[defines.events.on_gui_closed] = onGuiClosed,
		[defines.events.on_gui_click] = onGuiClick,
		[defines.events.on_gui_selection_state_changed] = onGuiSelected,
		[defines.events.on_gui_elem_changed] = onGuiElemChanged,

		[defines.events.on_built_entity] = onBuilt,
		[defines.events.on_robot_built_entity] = onBuilt,
		[defines.events.script_raised_built] = onBuilt,
		[defines.events.script_raised_revive] = onBuilt,

		[defines.events.on_player_mined_entity] = onRemoved,
		[defines.events.on_robot_mined_entity] = onRemoved,
		[defines.events.on_entity_died] = onRemoved,
		[defines.events.script_raised_destroy] = onRemoved,

		[defines.events.on_entity_settings_pasted] = onPaste
	}
}
