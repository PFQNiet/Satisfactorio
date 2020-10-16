-- uses tick events from smart-splitter, just with a table of filters instead of just one (up to 32 per side)
-- uses global['smart-splitters'] to track structures {base, buffer, filters, {left1, left2}, {middle1, middle2}, {right1, right2}}
-- GUI uses global['gui-splitter'] to track player > opened programmable splitter
local mod_gui = require("mod-gui")
local io = require("scripts.lualib.input-output")
local getitems = require("scripts.lualib.get-items-from")

local splitter = "programmable-splitter"
local buffer = "programmable-splitter-box"

local function findStruct(entity)
	for i,splitter in pairs(global['smart-splitters']) do
		if splitter.base == entity then
			return splitter, i
		end
	end
end
local function signalIndex(side, index)
	return ({left=0,forward=1,right=2})[side]*32+index
end

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == splitter then
		local struct = {
			base = entity,
			filters = {
				left = {},
				forward = {"any"},
				right = {}
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
		control.set_signal(signalIndex("forward",1), {signal={type="virtual",name="signal-any"},count=1})
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
		table.insert(global['smart-splitters'], struct)
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == splitter then
		local box = entity.surface.find_entity(buffer, entity.position)
		if box and box.valid then
			getitems.storage(box, event.buffer)
			io.removeInput(entity, {0,1}, event)
			io.removeOutput(entity, {0,-1}, event)
			io.removeOutput(entity, {-1,0}, event)
			io.removeOutput(entity, {1,0}, event)
			box.destroy()
			local splitter, i = findStruct(entity)
			table.remove(global['smart-splitters'],i)
		else
			game.print("Could not find the buffer")
		end
	end
end

local function updateSplitter(struct, gui)
	-- gui is the table
	local orientations = ({
		[defines.direction.north] = {input=8, left=4, forward=2, right=6},
		[defines.direction.east] = {input=4, left=2, forward=6, right=8},
		[defines.direction.south] = {input=2, left=6, forward=8, right=4},
		[defines.direction.west] = {input=6, left=8, forward=4, right=2},
	})[struct.base.direction]
	local control = struct.base.get_control_behavior()
	for i=1,96 do control.set_signal(i,nil) end
	for _,dir in pairs({"left","forward","right"}) do
		local list = gui.children[orientations[dir]].list
		struct.filters[dir] = {}
		for i,flow in pairs(list.children) do
			local index = flow.children[1].selected_index
			local item = flow.children[2].elem_value
			if index ~= 1 and not (index == 5 and not item) then
				table.insert(struct.filters[dir], ({
					nil, "any", "any-undefined", "overflow"
				})[index] or item)
				control.set_signal(signalIndex(dir,#struct.filters[dir]),({
					nil,
					{signal={type="virtual",name="signal-any"},count=1},
					{signal={type="virtual",name="signal-any-undefined"},count=1},
					{signal={type="virtual",name="signal-overflow"},count=1}
				})[index]
					or (item and {signal={type="item",name=item},count=1} or nil)
				)
			end
		end
	end
end
local function onPaste(event)
	if event.destination.name == splitter then
		-- read signals and update struct accordingly
		local struct = findStruct(event.destination)
		local control = struct.base.get_control_behavior()
		for _,dir in pairs({"left","forward","right"}) do
			struct.filters[dir] = {}
			for slot=1,32 do
				local signal = control.get_signal(signalIndex(dir,slot)).signal
				if not signal then
					-- don't insert an empty signal
				elseif signal.type == "virtual" then
					struct.filters[dir][slot] = ({
						["signal-any"] = "any",
						["signal-any-undefined"] = "any-undefined",
						["signal-overflow"] = "overflow"
					})[signal.name] or nil
				elseif signal.type == "item" then
					struct.filters[dir][slot] = signal.name
				end
			end
		end
		-- TODO check if anyone has this entity open and update GUI accordingly
	end
end

local function addFilterEntry(list, struct, dir, index)
	local flow = list.add{type = "flow", name = "flow-"..index}
	flow.style.vertical_align = "center"
	flow.style.minimal_height = 40
	local menu = flow.add{
		type = "drop-down",
		name = "programmable-splitter-"..dir.."-selection",
		items = {
			"None",
			{"","[img=virtual-signal.signal-any] ",{"gui.smart-splitter-any"}},
			{"","[img=virtual-signal.signal-any-undefined] ",{"gui.smart-splitter-any-undefined"}},
			{"","[img=virtual-signal.signal-overflow] ",{"gui.smart-splitter-overflow"}},
			"Item..."
		},
		selected_index = struct.filters[dir][index] and (({
			["any"] = 2,
			["any-undefined"] = 3,
			["overflow"] = 4
		})[struct.filters[dir][index]] or 5) or 1
	}
	menu.style.horizontally_stretchable = true
	local item = flow.add{
		type = "choose-elem-button",
		name = "programmable-splitter-"..dir.."-item",
		elem_type = "item",
		item = struct.filters[dir][index] and game.item_prototypes[struct.filters[dir][index]] and struct.filters[dir][index] or nil
	}
	item.visible = menu.selected_index == 5
	local caption = list.parent.children[1]
	caption.caption = {"gui.programmable-splitter-"..dir,math.max(1,#list.children)}
end

local function onGuiOpened(event)
	local player = game.players[event.player_index]
	if event.gui_type == defines.gui_type.entity and event.entity.name == splitter then
		-- create the custom gui and open that instead
		local gui = player.gui.screen['programmable-splitter']
		local table
		if not gui then
			gui = player.gui.screen.add{
				type = "frame",
				name = "programmable-splitter",
				direction = "vertical",
				style = mod_gui.frame_style
			}
			local title_flow = gui.add{type = "flow", name = "title_flow"}
			local title = title_flow.add{type = "label", caption = {"item-name.programmable-splitter"}, style = "frame_title"}
			title.drag_target = gui
			local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_header"}
			pusher.style.height = 24
			pusher.style.horizontally_stretchable = true
			pusher.drag_target = gui
			title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white", name = "programmable-splitter-close"}
			
			local content = gui.add{
				type = "frame",
				name = "content",
				style = "inside_shallow_frame_with_padding"
			}
			table = content.add{
				type = "table",
				column_count = 3,
				name = "table"
			}
			table.style.horizontally_stretchable = true
			table.style.cell_padding = 6
			for i=1,9 do
				local cell = i%2 == 0 and (table.add{
					type = "scroll-pane",
					direction = "vertical",
					horizontal_scroll_policy = "never",
					vertical_scroll_policy = "auto-and-reserve-space",
					name = "cell-"..i,
					style = "scroll_pane_in_shallow_frame"
				}) or (table.add{
					type = "flow",
					direction = "vertical",
					name = "cell-"..i
				})
				cell.style.minimal_height = 150
				cell.style.maximal_height = 150
				cell.style.minimal_width = 200
				cell.style.maximal_width = 200
				cell.style.vertical_align = "center"
			end
			local cell = table.children[5]
			cell.style.horizontal_align = "center"
			local preview = cell.add{
				type = "frame",
				name = "preview-container",
				style = "deep_frame_in_shallow_frame"
			}
			preview.add{
				type = "entity-preview",
				name = "preview",
				style = "entity_button_base"
			}
		else
			table = gui.content.table
		end
		
		local struct = findStruct(event.entity)
		table.children[5]['preview-container'].preview.entity = struct.base
		local orientations = ({
			[defines.direction.north] = {input=8, left=4, forward=2, right=6},
			[defines.direction.east] = {input=4, left=2, forward=6, right=8},
			[defines.direction.south] = {input=2, left=6, forward=8, right=4},
			[defines.direction.west] = {input=6, left=8, forward=4, right=2},
		})[event.entity.direction]

		local cell = table.children[orientations.input]
		cell.clear()
		cell.style.horizontal_align = "center"
		cell.add{
			type = "label",
			caption = {"gui.programmable-splitter-input"},
			style = "heading_1_label"
		}
		for _,dir in pairs({"left","forward","right"}) do
			cell = table.children[orientations[dir]]
			cell.clear()
			cell.style.horizontal_align = "left"
			cell.add{
				type = "label",
				caption = {"gui.programmable-splitter-"..dir,math.max(1,#struct.filters[dir])},
				style = "heading_1_label"
			}
			local list = cell.add{type = "flow", name = "list", direction = "vertical"}
			for i=1,math.max(1,#struct.filters[dir]) do
				addFilterEntry(list, struct, dir, i)
			end
			local button = cell.add{
				type = "sprite-button",
				name = "programmable-splitter-"..dir.."-add",
				style = "tool_button_green",
				tooltip = {"gui.programmable-splitter-filter-add"},
				sprite = "utility.add"
			}
		end
		
		gui.visible = true
		player.opened = gui
		if not global['gui-splitter'] then global['gui-splitter'] = {} end
		global['gui-splitter'][player.index] = struct
		gui.force_auto_center()
	end
end
local function _closeGui(player)
	local gui = player.gui.screen['programmable-splitter']
	if gui then gui.visible = false end
	player.opened = nil
	global['gui-splitter'][player.index] = nil
end
local function onGuiClosed(event)
	if event.element and event.element.valid and event.element.name == "programmable-splitter" then
		local player = game.players[event.player_index]
		_closeGui(player)
	end
end
local function onGuiClick(event)
	if event.element and event.element.valid then
		if event.element.name == "programmable-splitter-close" then
			local player = game.players[event.player_index]
			_closeGui(player)
		elseif (
			event.element.name == "programmable-splitter-left-add"
			or event.element.name == "programmable-splitter-forward-add"
			or event.element.name == "programmable-splitter-right-add"
	 	) then
			local struct = global['gui-splitter'][event.player_index]
			local base = struct.base
			local cell = event.element.parent.name
			local dir = ({
				["programmable-splitter-left-add"] = "left",
				["programmable-splitter-forward-add"] = "forward",
				["programmable-splitter-right-add"] = "right"
			})[event.element.name]
			-- apply this change to other players with this entity open, including the current player
			for pid,struct in pairs(global['gui-splitter']) do
				if struct.base == base then
					local list = game.players[pid].gui.screen['programmable-splitter'].content.table[cell].list
					local i = #list.children+1
					if i > 32 then
						break
					elseif i == 32 then
						game.players[pid].gui.screen['programmable-splitter'].content.table[cell].children[3].enabled = false
					end
					addFilterEntry(list, struct, dir, i)
				end
			end
		end
	end
end
local function onGuiSelected(event)
	local player = game.players[event.player_index]
	if event.element.valid and (
		event.element.name == "programmable-splitter-left-selection"
		or event.element.name == "programmable-splitter-forward-selection"
		or event.element.name == "programmable-splitter-right-selection"
 	) then
		local struct = global['gui-splitter'][event.player_index]
		updateSplitter(struct, game.players[event.player_index].gui.screen['programmable-splitter'].content.table)

		local index = event.element.selected_index
		local itemsel = event.element.parent.children[2]
		itemsel.visible = index == 5
		-- mirror this change to other players with this entity open
		local base = struct.base
		local cell = event.element.parent.parent.name
		for pid,struct in pairs(global['gui-splitter']) do
			if event.player_index ~= pid and struct.base == base then
				local flow = game.players[pid].gui.screen['programmable-splitter'].content.table[cell].flow
				flow.children[1].selected_index = index
				flow.children[2].visible = index == 5
			end
		end
	end
end
local function onGuiElemChanged(event)
	if event.element.valid and (
		event.element.name == "programmable-splitter-left-item"
		or event.element.name == "programmable-splitter-forward-item"
		or event.element.name == "programmable-splitter-right-item"
	) then
		local struct = global['gui-splitter'][event.player_index]
		updateSplitter(struct, game.players[event.player_index].gui.screen['programmable-splitter'].content.table)
		-- mirror this change to other players with this entity open
		local base = struct.base
		local cell = event.element.parent.parent.name
		for pid,struct in pairs(global['gui-splitter']) do
			if event.player_index ~= pid and struct.base == base then
				local flow = game.players[pid].gui.screen['programmable-splitter'].content.table[cell].flow
				flow.children[2].elem_value = event.element.elem_value
			end
		end
	end
end

return {
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
