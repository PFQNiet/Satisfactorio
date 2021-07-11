-- uses global.valves to track valves, which consist of an input and output. the script then averages their contents but only in the forward direction
local math2d = require("math2d")
local bev = require(modpath.."scripts.lualib.build-events")
local link = require(modpath.."scripts.lualib.linked-entity")

local valve = "valve"
local valvein = valve.."-input"
local valveout = valve.."-output"

---@class ValveData
---@field base LuaEntity
---@field flow number Set by the player
---@field input LuaEntity
---@field output LuaEntity
---@field arrow uint64

---@alias ValveBucket table<uint, ValveData>

local buckets = 30
---@alias global.valves ValveBucket[]
---@type global.valves
local script_data = {}
for i=0,buckets-1 do script_data[i] = {} end
local function getBucket(tick)
	return script_data[tick%buckets]
end
---@param entity LuaEntity
local function createStruct(entity)
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
	link.register(struct.base, struct.input)
	link.register(struct.base, struct.output)
	script_data[entity.unit_number%buckets][entity.unit_number] = struct
end
---@param entity LuaEntity
local function getStruct(entity)
	return script_data[entity.unit_number%buckets][entity.unit_number]
end
---@param entity LuaEntity
local function deleteStruct(entity)
	script_data[entity.unit_number%buckets][entity.unit_number] = nil
end

---@param event on_build
local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not (entity and entity.valid) then return end
	if entity.name == valve then
		createStruct(entity)
	end
end

---@param event on_destroy
local function onRemoved(event)
	local entity = event.entity
	if not (entity and entity.valid) then return end
	if entity.name == valve then
		deleteStruct(entity)
	end
end

---@param event on_player_rotated_entity
local function onRotated(event)
	local entity = event.entity
	if not (entity and entity.valid) then return end
	if entity.name == valve then
		local struct = getStruct(entity)
		struct.input.direction = entity.direction
		struct.input.teleport(math2d.position.add(entity.position, math2d.position.rotate_vector({0,0.5},entity.direction*45)))
		struct.output.direction = entity.direction
		struct.output.teleport(math2d.position.add(entity.position, math2d.position.rotate_vector({0,-0.5},entity.direction*45)))
		rendering.set_orientation(struct.arrow, struct.base.direction/8)
		rendering.set_target(struct.arrow, entity, math2d.position.rotate_vector({0,-1}, entity.direction*45))
	end
end

---@param event on_tick
local function onTick(event)
	for _,struct in pairs(getBucket(event.tick)) do
		-- transfer half the difference between input and output in the forward direction, if fluids match
		local input_name, input_count = next(struct.input.get_fluid_contents())
		local output_name, output_count = next(struct.output.get_fluid_contents())
		if input_name and (not output_name or input_name == output_name) and input_count > (output_count or 0) then
			local transfer = (input_count - (output_count or 0)) / 2
			-- set max flow rate... (flow/minute / 60seconds/minute / 60ticks/second * ticks/update = flow/update)
			if transfer > struct.flow/60/60*buckets then transfer = struct.flow/60/60*buckets end
			struct.input.remove_fluid{name=input_name, amount=transfer}
			struct.output.insert_fluid{name=input_name, amount=transfer}
			-- for rendering purposes, show fluid being transferred per minute in the base
			struct.base.fluidbox[1] = {name=input_name, amount=transfer*60/buckets*60}
		end
	end
end

---@param event on_gui_opened
local function onGuiOpened(event)
	local player = game.players[event.player_index]
	if event.gui_type == defines.gui_type.entity and event.entity.name == valve then
		-- create the custom gui and open that instead
		local gui = player.gui.relative
		if not gui['valve'] then
			local frame = player.gui.relative.add{
				type = "frame",
				name = "valve",
				anchor = {
					gui = defines.relative_gui_type.storage_tank_gui,
					position = defines.relative_gui_position.bottom,
					name = valve
				},
				direction = "vertical",
				style = "frame_with_even_paddings"
			}

			local inner = frame.add{
				type = "frame",
				style = "inside_shallow_frame_with_padding",
				name = "frame"
			}
			local content = inner.add{
				type = "flow",
				direction = "vertical",
				style = "vertical_flow_with_extra_spacing",
				name = "content"
			}
			content.add{
				type = "label",
				style = "heading_2_label",
				caption = {"gui.valve-flow-rate-label"}
			}
			content.add{
				type = "slider",
				name = "valve-flow-slider",
				minimum_value = 0,
				maximum_value = 300,
				value = 300,
				value_step = 0.1
			}
			local bottom = content.add{
				type = "flow",
				direction = "horizontal",
				style = "vertically_aligned_flow",
				name = "bottom"
			}
			bottom.add{
				type = "textfield",
				numeric = true,
				allow_decimal = true,
				allow_negative = false,
				lose_focus_on_confirm = true,
				name = "valve-flow-input",
				style = "short_number_textfield"
			}
			bottom.add{
				type = "label",
				caption = {"gui.valve-flow-rate-unit-and-max",{"per-minute-suffix"},600}
			}
		end
		local frame = gui['valve']
		local content = frame.frame.content

		local struct = getStruct(event.entity)
		content['valve-flow-slider'].set_slider_minimum_maximum(0,struct.base.force.recipes['pipeline-mk-2'].enabled and 600 or 300)
		content['valve-flow-slider'].slider_value = struct.flow
		content.bottom['valve-flow-input'].text = tostring(struct.flow)
	end
end
---@param event on_gui_value_changed
local function onGuiValueChanged(event)
	if event.element and event.element.valid and event.element.name == "valve-flow-slider" then
		local player = game.players[event.player_index]
		local val = event.element.slider_value
		local struct = getStruct(player.opened)
		struct.flow = val
		-- push change to anyone else with the same valve open
		for _,p in pairs(game.players) do
			if p.opened == struct.base then
				local gui = p.gui.relative['valve'].frame.content
				if p.index ~= player.index then
					gui['valve-flow-slider'].slider_value = val
				end
				gui.bottom['valve-flow-input'].text = tostring(val)
			end
		end
	end
end
---@param event on_gui_confirmed
local function onGuiConfirmed(event)
	if event.element and event.element.valid and event.element.name == "valve-flow-input" then
		local player = game.players[event.player_index]
		local val = tonumber(event.element.text)
		local struct = getStruct(player.opened)
		struct.flow = val
		-- push change to anyone else with the same valve open
		for _,p in pairs(game.players) do
			if p.opened == struct.base then
				local gui = p.gui.relative['valve'].frame.content
				if p.index ~= player.index then
					gui.bottom['valve-flow-input'].text = val
				end
				gui['valve-flow-slider'].slider_value = tostring(val)
			end
		end
	end
end

return bev.applyBuildEvents{
	on_init = function()
		global.valves = global.valves or script_data
	end,
	on_load = function()
		script_data = global.valves or script_data
	end,
	on_build = onBuilt,
	on_destroy = onRemoved,
	events = {
		[defines.events.on_player_rotated_entity] = onRotated,

		[defines.events.on_gui_opened] = onGuiOpened,
		[defines.events.on_gui_value_changed] = onGuiValueChanged,
		[defines.events.on_gui_confirmed] = onGuiConfirmed,

		[defines.events.on_tick] = onTick
	}
}
