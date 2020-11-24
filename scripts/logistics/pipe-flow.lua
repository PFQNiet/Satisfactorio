-- uses global.pipe_flow to track rolling average flow
-- opening a pipe's GUI adds it to the tracking list, closing it (provided no other player has it open) removes it
local script_data = {}

local entities = { -- advertised max flow per tracked entity
	["pipe"] = 300,
	["pipe-to-ground"] = 300,
	["pump"] = 300,
	["pipeline-mk-2"] = 600,
	["pipeline-junction-cross-mk-2"] = 600,
	["pipeline-pump-mk-2"] = 600
}
local entity_names = {}
for k,_ in pairs(entities) do table.insert(entity_names,k) end

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
		local gui = player.gui.relative['pipe-flow']
		if not gui then
			gui = player.gui.relative.add{
				type = "frame",
				name = "pipe-flow",
				anchor = {
					gui = defines.relative_gui_type.pipe_gui,
					position = defines.relative_gui_position.right,
					names = entity_names
				},
				direction = "vertical",
				caption = {"gui.pipe-flow-title"},
				style = "inner_frame_in_outer_frame"
			}
			gui.style.horizontally_stretchable = false
			gui.style.use_header_filler = false

			local flow = gui.add{
				type = "flow",
				direction = "horizontal",
				name = "content"
			}
			flow.style.horizontal_spacing = 12
			local sprite = flow.add{
				type = "sprite",
				name = "fluid"
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
			bar.style.width = 200
		else
			gui.visible = true
		end
		script_data[event.entity.unit_number].opened_by[player.index] = gui
	end
end
local function onGuiClosed(event)
	if not (event.entity and event.entity.valid) then return end
	if entities[event.entity.name] and script_data[event.entity.unit_number] then
		local player = game.players[event.player_index]
		local gui = player.gui.relative['pipe-flow']
		if gui then gui.visible = false end
		
		local struct = script_data[event.entity.unit_number]
		struct.opened_by[player.index] = nil
		if not next(struct.opened_by) then
			script_data[event.entity.unit_number] = nil
		end
	end
end

local function onTick(event)
	for id,struct in pairs(script_data) do
		if not struct.entity.valid then
			-- find any players that had it open and close the GUI
			for _,gui in pairs(struct.opened_by) do
				gui.visible = false
			end
			script_data[id] = nil
		else
			local fluidbox = struct.entity.fluidbox
			local fluid = fluidbox[1]
			local sprite = "fluid/"..(fluid and fluid.name or "fluid-unknown")
			local caption
			local bar = 0
			local max = entities[struct.entity.name]
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
				gui.content.fluid.sprite = sprite
				gui.content.details.flowtext.caption = caption
				gui.content.details.bar.value = bar
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
