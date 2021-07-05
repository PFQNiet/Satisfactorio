-- uses tick events from smart-splitter, just with a table of filters instead of just one (up to 32 per side)
-- uses global.splitters.splitters to track structures {base, buffer, filters, {left1, left2}, {middle1, middle2}, {right1, right2}}
-- GUI uses global.splitters.gui to track player > opened programmable splitter
local io = require(modpath.."scripts.lualib.input-output")
local bev = require(modpath.."scripts.lualib.build-events")
local link = require(modpath.."scripts.lualib.linked-entity")

local splitter = "programmable-splitter"
local buffer = "merger-splitter-box"

local script_data = require(modpath.."scripts.logistics.splitters").data

---@param entity LuaEntity
local function findStruct(entity)
	return script_data.splitters[entity.unit_number]
end
-- Determine which signal slot to use for the given side and slot number
---@param side string
---@param index number
local function signalIndex(side, index)
	return ({left=0,forward=1,right=2})[side]*32+index
end
---@param player LuaPlayer
local function closeGui(player)
	local gui = player.gui.screen['programmable-splitter']
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
				left = {},
				forward = {"any"},
				right = {}
			},
			connections = {
				left = {},
				forward = {},
				right = {}
			},
			buffer = box
		}

		local control = entity.get_or_create_control_behavior()
		control.set_signal(signalIndex("forward",1), {signal={type="virtual",name="signal-any"},count=1})
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

local function updateSplitter(struct, gui)
	-- gui is the columns (left forward right) each containing a "filters" as an array of flows consisting of the drop-down and item elements
	local control = struct.base.get_control_behavior()
	for i=1,96 do control.set_signal(i,nil) end
	for _,dir in pairs({"left","forward","right"}) do
		local filters = gui["filter-"..dir].filters
		struct.filters[dir] = {}
		for _,flow in pairs(filters.children) do
			local index = flow.children[1].selected_index
			local item = flow.children[2].elem_value
			table.insert(struct.filters[dir], ({
				nil, "any", "any-undefined", "overflow"
			})[index] or item)
			control.set_signal(signalIndex(dir,math.max(1,#struct.filters[dir])),({
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
	local caption = list.parent.title.label
	caption.caption = {"gui.programmable-splitter-"..dir,math.max(1,#list.children)}
end
local function fullGuiUpdate(struct, columns)
	for _,dir in pairs({"left","forward","right"}) do
		local col = columns["filter-"..dir]
		local title = col.title.label
		local fcount = math.max(1,#struct.filters[dir])
		title.caption = {"gui.programmable-splitter-"..dir,fcount}
		local list = col.filters
		list.clear()
		for i=1,fcount do
			addFilterEntry(list, struct, dir, i)
		end
		col.title.children[3].enabled = fcount < 32
	end
end

local function onPaste(event)
	if event.destination.name == splitter then
		-- read signals and update struct accordingly
		local struct = findStruct(event.destination)
		---@type LuaConstantCombinatorControlBehavior
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
		local players = game.players
		for pid,other in pairs(script_data.gui) do
			if other.base == struct.base then
				fullGuiUpdate(other, players[pid].gui.screen['programmable-splitter'].columns)
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
	----- label "{DIR} output (N)"
	---- flow[filters] (scrollable)
	----- flow (repeated)
	------ dropdown[smart-splitter-{DIR}-selection]
	------ item[smart-splitter-{DIR}-item]
	---- button[programmable-splitter-{DIR}-add]
]]

---@param event on_gui_opened
local function onGuiOpened(event)
	local player = game.players[event.player_index]
	if event.gui_type == defines.gui_type.entity and event.entity.name == splitter then
		-- create the custom gui and open that instead
		local gui = player.gui.screen
		if not gui['programmable-splitter'] then
			local frame = player.gui.screen.add{
				type = "frame",
				name = "programmable-splitter",
				direction = "vertical",
				style = "inner_frame_in_outer_frame"
			}
			local title_flow = frame.add{type = "flow", name = "title_flow"}
			local title = title_flow.add{type = "label", caption = event.entity.localised_name, style = "frame_title"}
			title.drag_target = frame
			local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_header"}
			pusher.style.height = 24
			pusher.style.horizontally_stretchable = true
			pusher.drag_target = frame
			title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white", name = "programmable-splitter-close"}

			local columns = frame.add{
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
				local subtitle = col.add{
					type = "frame",
					name = "title",
					style = "subheader_frame"
				}
				subtitle.style.horizontally_stretchable = true
				subtitle.add{
					type = "label",
					name = "label",
					style = "heading_2_label",
					caption = {"gui.programmable-splitter-"..dir,1}
				}
				local list = col.add{
					type = "scroll-pane",
					direction = "vertical",
					horizontal_scroll_policy = "never",
					vertical_scroll_policy = "auto-and-reserve-space",
					name = "filters"
				}
				list.style.padding = 12
				list.style.horizontally_stretchable = true
				list.style.minimal_height = 400
				list.style.maximal_height = 400
				list.style.minimal_width = 240

				subtitle.add{
					type = "empty-widget"
				}.style.horizontally_stretchable = true
				subtitle.add{
					type = "sprite-button",
					name = "programmable-splitter-"..dir.."-add",
					style = "tool_button_green",
					tooltip = {"gui.programmable-splitter-filter-add"},
					sprite = "utility.add"
				}
			end
		end
		local frame = gui['programmable-splitter']
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
	if event.element and event.element.valid and event.element.name == "programmable-splitter" then
		local player = game.players[event.player_index]
		closeGui(player)
	end
end
---@param event on_gui_click
local function onGuiClick(event)
	if event.element and event.element.valid then
		if event.element.name == "programmable-splitter-close" then
			local player = game.players[event.player_index]
			closeGui(player)
		elseif (
			event.element.name == "programmable-splitter-left-add"
			or event.element.name == "programmable-splitter-forward-add"
			or event.element.name == "programmable-splitter-right-add"
	 	) then
			local struct = script_data.gui[event.player_index]
			-- apply this change to other players with this entity open, including the current player
			local dir = ({
				["programmable-splitter-left-add"] = "left",
				["programmable-splitter-forward-add"] = "forward",
				["programmable-splitter-right-add"] = "right"
			})[event.element.name]
			local players = game.players
			for pid,other in pairs(script_data.gui) do
				if other.base == struct.base then
					local player = players[pid]
					local list = player.gui.screen['programmable-splitter'].columns["filter-"..dir].filters
					local i = #list.children+1
					if i > 32 then
						break
					elseif i == 32 then
						player.gui.screen['programmable-splitter'].columns["filter-"..dir].title[event.element.name].enabled = false
					end
					addFilterEntry(list, other, dir, i)
					if event.player_index == pid then list.scroll_to_bottom() end
				end
			end
		end
	end
end
---@param event on_gui_selection_state_changed
local function onGuiSelected(event)
	if event.element.valid and (
		event.element.name == "programmable-splitter-left-selection"
		or event.element.name == "programmable-splitter-forward-selection"
		or event.element.name == "programmable-splitter-right-selection"
	 ) then
		local players = game.players
		local gui_splitter = script_data.gui
		local struct = gui_splitter[event.player_index]
		updateSplitter(struct, players[event.player_index].gui.screen['programmable-splitter'].columns)

		local index = event.element.selected_index
		local itemsel = event.element.parent.children[2]
		itemsel.visible = index == 5
		-- mirror this change to other players with this entity open
		local dir = ({
			["programmable-splitter-left-selection"] = "left",
			["programmable-splitter-forward-selection"] = "forward",
			["programmable-splitter-right-selection"] = "right"
		})[event.element.name]
		local filterid = event.element.parent.name
		for pid,other in pairs(gui_splitter) do
			if event.player_index ~= pid and other.base == struct.base then
				local flow = players[pid].gui.screen['programmable-splitter'].columns["filter-"..dir].filters[filterid]
				flow.children[1].selected_index = index
				flow.children[2].visible = index == 5
			end
		end
	end
end
---@param event on_gui_elem_changed
local function onGuiElemChanged(event)
	if event.element.valid and (
		event.element.name == "programmable-splitter-left-item"
		or event.element.name == "programmable-splitter-forward-item"
		or event.element.name == "programmable-splitter-right-item"
	) then
		local players = game.players
		local gui_splitter = script_data.gui
		local struct = gui_splitter[event.player_index]
		updateSplitter(struct, players[event.player_index].gui.screen['programmable-splitter'].columns)
		-- mirror this change to other players with this entity open
		local dir = ({
			["programmable-splitter-left-item"] = "left",
			["programmable-splitter-forward-item"] = "forward",
			["programmable-splitter-right-item"] = "right"
		})[event.element.name]
		local filterid = event.element.parent.name
		for pid,other in pairs(gui_splitter) do
			if event.player_index ~= pid and other.base == struct.base then
				local flow = players[pid].gui.screen['programmable-splitter'].columns["filter-"..dir].filters[filterid]
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
