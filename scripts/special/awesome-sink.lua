-- sink is a furnace that produces awesome-points "fluid"
-- n = tickets earned so far, next ticket earned at 500*floor(n/3)^2+1000 points

---@class global.awesome
---@field sinks table<uint,LuaEntity> Sinks indexed by unit number
---@field coupons number[] Total earned, total unprinted, points towards next, points per minute
local script_data = {
	sinks = {},
	coupons = {}
}

---@param earned uint Number of earned tickets
local function pointsToNext(earned)
	return 500 * math.floor(earned / 3)^2 + 1000
end
---@param force LuaForce
---@param points uint
local function gainPoints(force, points)
	if not script_data.coupons[force.index] then script_data.coupons[force.index] = {0,0,0,0} end
	local entry = script_data.coupons[force.index]
	entry[3] = entry[3] + points
	entry[4] = entry[4] + points*12 -- updated every 5 seconds, so 12x is per minute
	local tonext = pointsToNext(entry[1])
	while entry[3] > tonext do
		entry[1] = entry[1] + 1
		entry[2] = entry[2] + 1
		entry[3] = entry[3] - tonext
		tonext = pointsToNext(entry[1])
	end
end

local io = require(modpath.."scripts.lualib.input-output")
local bev = require(modpath.."scripts.lualib.build-events")

local base = "awesome-sink"

---@param sink LuaEntity
local function processSink(sink)
	local fluidbox = sink.fluidbox[1]
	if fluidbox then
		-- we have some fluid!
		gainPoints(sink.force, fluidbox.amount)
		sink.fluidbox[1] = nil -- delete the fluid
	end
end

---@param event on_build
local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not (entity and entity.valid) then return end
	if entity.name == base then
		io.addConnection(entity, {-0.5,3}, "input")
		entity.rotatable = false
		script_data.sinks[entity.unit_number] = entity
	end
end

---@param event on_destroy
local function onRemoved(event)
	local entity = event.entity
	if not (entity and entity.valid) then return end
	if entity.name == base then
		processSink(entity)
		script_data.sinks[entity.unit_number] = nil
	end
end

---@param player LuaPlayer
local function updatePlayerGui(player)
	if player.opened and player.opened_gui_type == defines.gui_type.entity and player.opened.valid and player.opened.name == base then
		-- GUI can be assumed to exist
		local gui = player.gui.relative['awesome-sink'].content
		local table = gui.table
		local coupons = script_data.coupons[player.force.index] or {0,0,0,0}
		table.tickets.caption = util.format_number(coupons[2])
		table.gain.caption = util.format_number(coupons[4])
		table.tonext.caption = util.format_number(pointsToNext(coupons[1]) - coupons[3])
		gui.bottom['awesome-sink-print'].enabled = coupons[2] > 0
	end
end
local function updateAllPlayerGuis()
	for _,player in pairs(game.players) do
		updatePlayerGui(player)
	end
end

---@param event on_gui_opened
local function onGuiOpened(event)
	local player = game.players[event.player_index]
	if event.gui_type == defines.gui_type.entity and event.entity.valid and event.entity.name == base then
		-- create additional GUI for showing points and redeeming coupons
		local gui = player.gui.relative
		if not gui['awesome-sink'] then
			local force_idx = player.force.index
			local coupons = script_data.coupons[force_idx] or {0,0,0,0}
			local frame = gui.add{
				type = "frame",
				name = "awesome-sink",
				anchor = {
					gui = defines.relative_gui_type.furnace_gui,
					position = defines.relative_gui_position.right,
					name = base
				},
				direction = "vertical",
				caption = {"gui.awesome-sink-gui-title"}
			}
			local inner = frame.add{
				type = "frame",
				name = "content",
				style = "inside_shallow_frame_with_padding_and_spacing",
				direction = "vertical"
			}
			local table = inner.add{
				type = "table",
				name = "table",
				style = "awesome_sink_table",
				column_count = 2
			}
			table.add{
				type = "label",
				caption = {"gui.awesome-sink-printable-coupons"},
				style = "bold_label"
			}
			table.add{
				type = "label",
				name = "tickets",
				caption = util.format_number(coupons[2])
			}

			table.add{
				type = "label",
				caption = {"gui.awesome-sink-gain"}
			}
			table.add{
				type = "label",
				name = "gain",
				caption = util.format_number(coupons[4] or 0)
			}

			table.add{
				type = "label",
				caption = {"gui.awesome-sink-to-next"}
			}
			table.add{
				type = "label",
				name = "tonext",
				caption = util.format_number(pointsToNext(coupons[1]) - coupons[3])
			}

			local bottom = inner.add{
				type = "flow",
				name = "bottom"
			}
			bottom.add{type="empty-widget", style="filler_widget"}
			local button = bottom.add{
				type = "button",
				style = "submit_button",
				name = "awesome-sink-print",
				caption = {"gui.awesome-sink-print"}
			}
			button.enabled = coupons[2] > 0
			inner.add{
				type = "empty-widget",
				style = "vertical_lines_slots_filler"
			}
		else
			updatePlayerGui(player)
		end
	end
end
---@param event on_gui_click
local function onGuiClick(event)
	if event.element.valid and event.element.name == "awesome-sink-print" then
		local player = game.players[event.player_index]
		local force_idx = player.force.index
		local inventory = player.get_main_inventory()
		local caninsert = inventory.get_insertable_count("coin")
		local print = script_data.coupons[force_idx] and script_data.coupons[force_idx][2] or 0
		if print > 0 then
			if caninsert == 0 then
				print = 0
				player.print({"inventory-restriction.player-inventory-full",{"item-name.coin"},{"inventory-full-message.main"}})
			else
				if print > caninsert then
					print = caninsert
				end
				player.force.print({"message.received-awesome-coupons",player.name,print})
			end
			if print > 0 then
				inventory.insert{name="coin",count=print}
			end
			script_data.coupons[force_idx][2] = script_data.coupons[force_idx][2] - print
			updateAllPlayerGuis()
		end
	end
end

return bev.applyBuildEvents{
	on_init = function()
		global.awesome = global.awesome or script_data
	end,
	on_load = function()
		script_data = global.awesome or script_data
	end,
	on_nth_tick = {
		[300] = function()
			for _,entry in pairs(script_data.coupons) do
				entry[4] = 0
			end
			for _,sink in pairs(script_data.sinks) do
				processSink(sink)
			end
			updateAllPlayerGuis()
		end
	},
	on_build = onBuilt,
	on_destroy = onRemoved,
	events = {
		[defines.events.on_gui_opened] = onGuiOpened,
		[defines.events.on_gui_click] = onGuiClick
	}
}

