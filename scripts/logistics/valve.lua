-- uses global['valves'] to track valves, which consist of an input and output. the script then averages their contents but only in the forward direction
-- uses global['gui-valve'] to track which valve a player has open, for syncronisation purposes
local math2d = require("math2d")

local valve = "valve"
local valvein = valve.."-input"
local valveout = valve.."-output"

local function findStruct(entity)
	return global['valves'] and global['valved'][entity.unit_number]
end

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == valve then
		if not global['valves'] then global['valves'] = {} end
		local struct = {
			base = entity,
			flow = entity.force.recipes['pipeline-mk-2'].enabled and 600 or 300,
			input = entity.surface.create_entity{
				name = valvein,
				position = math2d.position.add(entity.position, math2d.position.rotate_vector({0,0.5},entity.direction*45)),
				direction = entity.direction,
				force = entity.force,
				raise_built = true
			},
			output = entity.surface.create_entity{
				name = valveout,
				position = math2d.position.add(entity.position, math2d.position.rotate_vector({0,-0.5},entity.direction*45)),
				direction = entity.direction,
				force = entity.force,
				raise_built = true
			},
			arrow = rendering.draw_sprite{
				sprite = "utility.fluid_indication_arrow",
				orientation = entity.direction/8,
				render_layer = "arrow",
				target = entity,
				target_offset = math2d.position.rotate_vector({0, -1}, entity.direction*45),
				surface = entity.surface,
				only_in_alt_mode = true
			}
		}
		global['valves'][entity.unit_number] = struct
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == valve then
		local struct = findStruct(entity)
		struct.input.destroy()
		struct.output.destroy()
		global['valves'][entity.unit_number] = nil
	end
end

local function onRotated(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == valve then
		local struct,i = findStruct(entity)
		struct.input.direction = entity.direction
		struct.input.teleport(math2d.position.add(entity.position, math2d.position.rotate_vector({0,0.5},entity.direction*45)))
		struct.output.direction = entity.direction
		struct.output.teleport(math2d.position.add(entity.position, math2d.position.rotate_vector({0,-0.5},entity.direction*45)))
		rendering.set_orientation(struct.arrow, struct.base.direction/8)
		rendering.set_target(struct.arrow, entity, math2d.position.rotate_vector({0,-1}, entity.direction*45))
	end
end

local function onTick(event)
	if not global['valves'] then return end
	local polltime = 30
	for i,struct in pairs(global['valves']) do
		if event.tick%polltime == i%polltime then
			-- transfer half the difference between input and output in the forward direction, if fluids match
			local input_name, input_count = next(struct.input.get_fluid_contents())
			local output_name, output_count = next(struct.output.get_fluid_contents())
			if input_name and (not output_name or input_name == output_name) and input_count > (output_count or 0) then
				local transfer = (input_count - (output_count or 0)) / 2
				-- set max flow rate... (flow/minute / 60seconds/minute / 60ticks/second * ticks/update = flow/update)
				if transfer > struct.flow/60/60*polltime then transfer = struct.flow/60/60*polltime end
				struct.input.remove_fluid{name=input_name, amount=transfer}
				struct.output.insert_fluid{name=input_name, amount=transfer}
				-- for rendering purposes, show fluid being transferred per minute in the base
				struct.base.fluidbox[1] = {name=input_name, amount=transfer*60/polltime*60}
			end
		end
	end
end

local function onGuiOpened(event)
	local player = game.players[event.player_index]
	if event.gui_type == defines.gui_type.entity and event.entity.name == valve then
		-- create the custom gui and open that instead
		local gui = player.gui.screen['valve']
		if not gui then
			gui = player.gui.screen.add{
				type = "frame",
				name = "valve",
				direction = "vertical",
				style = mod_gui.frame_style
			}
			local title_flow = gui.add{type = "flow", name = "title_flow"}
			local title = title_flow.add{type = "label", caption = {"item-name.valve"}, style = "frame_title"}
			title.drag_target = gui
			local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_header"}
			pusher.style.height = 24
			pusher.style.horizontally_stretchable = true
			pusher.drag_target = gui
			title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white", name = "valve-close"}
			
			local frame = gui.add{
				type = "frame",
				style = "inside_shallow_frame_with_padding",
				direction = "horizontal",
				name = "frame"
			}
			local content = frame.add{
				type = "flow",
				direction = "horizontal",
				name = "content"
			}
			content.style.horizontal_spacing = 12
			local col1 = content.add{
				type = "frame",
				direction = "vertical",
				name = "left",
				style = "deep_frame_in_shallow_frame"
			}
			local preview = col1.add{
				type = "entity-preview",
				name = "preview",
				style = "entity_button_base"
			}
			local col2 = content.add{
				type = "flow",
				direction = "vertical",
				name = "right"
			}
			col2.style.vertical_spacing = 12
			col2.add{
				type = "label",
				style = "heading_2_label",
				caption = {"gui.valve-flow-rate-label"}
			}
			col2.add{
				type = "slider",
				name = "valve-flow-slider",
				minimum_value = 0,
				maximum_value = 300,
				value = 300,
				value_step = 0.1
			}
			local bottom = col2.add{
				type = "flow",
				direction = "horizontal",
				name = "bottom"
			}
			bottom.style.vertical_align = "center"
			local input = bottom.add{
				type = "textfield",
				numeric = true,
				allow_decimal = true,
				allow_negative = false,
				lose_focus_on_confirm = true,
				name = "valve-flow-input"
			}
			input.style.width = 80
			bottom.add{
				type = "label",
				caption = {"gui.valve-flow-rate-unit-and-max",{"per-minute-suffix"},600}
			}
		end
		
		local struct = findStruct(event.entity)
		gui.frame.content.left.preview.entity = struct.base
		gui.frame.content.right['valve-flow-slider'].set_slider_minimum_maximum(0,struct.base.force.recipes['pipeline-mk-2'].enabled and 600 or 300)
		gui.frame.content.right['valve-flow-slider'].slider_value = struct.flow
		gui.frame.content.right.bottom['valve-flow-input'].text = struct.flow
		
		gui.visible = true
		player.opened = gui
		if not global['gui-valve'] then global['gui-valve'] = {} end
		global['gui-valve'][player.index] = struct
		gui.force_auto_center()
	end
end
local function _closeGui(player)
	local gui = player.gui.screen['valve']
	if gui then gui.visible = false end
	player.opened = nil
	global['gui-valve'][player.index] = nil
end
local function onGuiClosed(event)
	if event.element and event.element.valid and event.element.name == "valve" then
		local player = game.players[event.player_index]
		_closeGui(player)
	end
end
local function onGuiClick(event)
	if event.element and event.element.valid and event.element.name == "valve-close" then
		local player = game.players[event.player_index]
		_closeGui(player)
	end
end
local function onGuiValueChanged(event)
	if event.element and event.element.valid and event.element.name == "valve-flow-slider" then
		local player = game.players[event.player_index]
		local val = event.element.slider_value
		local struct = global['gui-valve'][player.index]
		struct.flow = val
		-- push change to anyone else with the same valve open
		local base = struct.base
		for pid,struct in pairs(global['gui-valve']) do
			if struct.base == base then
				local gui = player.gui.screen['valve'].frame.content.right
				if pid ~= player.index then
					gui['valve-flow-slider'].slider_value = val
				end
				gui.bottom['valve-flow-input'].text = val
			end
		end
	end
end
local function onGuiConfirmed(event)
	if event.element and event.element.valid and event.element.name == "valve-flow-input" then
		local player = game.players[event.player_index]
		local val = tonumber(event.element.text)
		local struct = global['gui-valve'][player.index]
		struct.flow = val
		-- push change to anyone else with the same valve open
		local base = struct.base
		for pid,struct in pairs(global['gui-valve']) do
			if struct.base == base then
				local gui = player.gui.screen['valve'].frame.content.right
				if pid ~= player.index then
					gui.bottom['valve-flow-input'].text = val
				end
				gui['valve-flow-slider'].slider_value = val
			end
		end
	end
end

return {
	events = {
		[defines.events.on_built_entity] = onBuilt,
		[defines.events.on_robot_built_entity] = onBuilt,
		[defines.events.script_raised_built] = onBuilt,
		[defines.events.script_raised_revive] = onBuilt,

		[defines.events.on_player_mined_entity] = onRemoved,
		[defines.events.on_robot_mined_entity] = onRemoved,
		[defines.events.on_entity_died] = onRemoved,
		[defines.events.script_raised_destroy] = onRemoved,

		[defines.events.on_player_rotated_entity] = onRotated,

		[defines.events.on_gui_opened] = onGuiOpened,
		[defines.events.on_gui_closed] = onGuiClosed,
		[defines.events.on_gui_click] = onGuiClick,
		[defines.events.on_gui_value_changed] = onGuiValueChanged,
		[defines.events.on_gui_confirmed] = onGuiConfirmed,

		[defines.events.on_tick] = onTick
	}
}
