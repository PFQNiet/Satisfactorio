-- uses global.beacons.opened as Player index -> opened beacon GUI
local bev = require(modpath.."scripts.lualib.build-events")

local script_data = {}

local item_name = "map-marker"

---@param beacon LuaEntity
---@return LuaCustomChartTag
local function findBeaconTag(beacon)
	return beacon.force.find_chart_tags(beacon.surface, {{beacon.position.x-0.1,beacon.position.y-0.1},{beacon.position.x+0.1,beacon.position.y+0.1}})[1]
end

---@param beacon LuaEntity
---@param player LuaPlayer
local function openBeaconGUI(beacon, player)
	local tag = findBeaconTag(beacon)
	if player.gui.screen['beacon-naming'] then return end
	local gui = player.gui.screen.add{
		type = "frame",
		name = "beacon-naming",
		direction = "vertical",
		caption = {"gui.beacon-title"},
		style = "inner_frame_in_outer_frame"
	}
	local inner = gui.add{
		type = "frame",
		name = "beacon-naming-inner",
		direction = "vertical",
		style = "inside_shallow_frame_with_padding"
	}
	local table = inner.add{
		type = "table",
		name = "beacon-naming-table",
		column_count = 2
	}
	table.add{
		type = "label",
		caption = {"gui.beacon-name"}
	}
	table.add{
		type = "textfield",
		name = "beacon-naming-name",
		text = tag.text,
		style = "textbox"
	}
	table.add{
		type = "label",
		caption = {"gui.beacon-icon"}
	}
	table.add{
		type = "choose-elem-button",
		name = "beacon-naming-icon",
		elem_type = "signal",
		signal = tag.icon,
		style = "slot_button_in_shallow_frame"
	}
	local bottom = gui.add{
		type = "flow",
		direction = "horizontal"
	}
	bottom.style.top_margin = 4
	local pusher = bottom.add{type = "empty-widget"}
	pusher.style.horizontally_stretchable = true
	bottom.add{
		type = "button",
		name = "beacon-naming-confirm",
		style = "confirm_button",
		caption = {"gui.beacon-confirm"}
	}
	player.opened = gui
	gui.force_auto_center()
	script_data[player.index] = beacon
end
--- TODO Don't destroy the gui, just hide it and repopulate it later
---@param player LuaPlayer
local function closeBeaconGUI(player)
	local gui = player.gui.screen['beacon-naming']
	if gui then gui.destroy() end
	script_data[player.index] = nil
	player.opened = nil
end

---@param event on_gui_opened
local function onGuiOpened(event)
	if event.entity and event.entity.valid and event.entity.name == item_name then
		openBeaconGUI(event.entity, game.players[event.player_index])
	end
end

---@param beacon LuaEntity
---@param gui LuaGuiElement
local function saveBeacon(beacon, gui)
	local tag = findBeaconTag(beacon)
	if tag and tag.valid then
		tag.destroy()
		local params = {position=beacon.position,icon={type="item",name="map-marker"}}
		if gui['beacon-naming-icon'].elem_value then params.icon = gui['beacon-naming-icon'].elem_value end
		if gui['beacon-naming-name'].text then params.text = gui['beacon-naming-name'].text end
		beacon.force.add_chart_tag(beacon.surface, params)
	end
end
---@param event on_gui_click
local function onGuiClick(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	if event.element.name == "beacon-naming-confirm" then
		local beacon = script_data[player.index]
		if beacon and beacon.valid then
			local gui = player.gui.screen['beacon-naming']['beacon-naming-inner']['beacon-naming-table']
			saveBeacon(beacon, gui)
		end
		closeBeaconGUI(player)
	end
end

---@param event on_build
local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == item_name then
		entity.force.add_chart_tag(entity.surface, {position=entity.position,icon={type="item",name="map-marker"}})
		if event.name == defines.events.on_built_entity then
			local player = game.players[event.player_index]
			player.clear_cursor()
			openBeaconGUI(entity, player)
		end
	end
end
---@param event on_destroy
local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == item_name then
		local tag = findBeaconTag(entity)
		if tag and tag.valid then
			tag.destroy()
		end
		-- if a player had this beacon's GUI open, close it
		for pid,beacon in pairs(script_data) do
			if beacon == entity then
				closeBeaconGUI(game.players[pid])
			end
		end
	end
end

---@param event on_player_changed_position
local function onMove(event)
	-- if the player moves and has a beacon open, check that the beacon can still be reached
	local player = game.players[event.player_index]
	local open = script_data[player.index]
	if open and not player.can_reach_entity(open) then
		closeBeaconGUI(player)
	end
end

return bev.applyBuildEvents{
	on_init = function()
		global.beacons = global.beacons or script_data
	end,
	on_load = function()
		script_data = global.beacons or script_data
	end,
	on_build = onBuilt,
	on_destroy = onRemoved,
	events = {
		[defines.events.on_gui_opened] = onGuiOpened,
		[defines.events.on_gui_click] = onGuiClick,
		[defines.events.on_gui_closed] = function(event)
			if event.gui_type == defines.gui_type.custom and event.element and event.element.valid and event.element.name == "beacon-naming" then
				local player = game.players[event.player_index]
				local beacon = script_data[player.index]
				if beacon then
					local gui = player.gui.screen['beacon-naming']['beacon-naming-inner']['beacon-naming-table']
					saveBeacon(beacon, gui)
				end
				closeBeaconGUI(game.players[event.player_index])
			end
		end,

		[defines.events.on_player_changed_position] = onMove
	}
}
