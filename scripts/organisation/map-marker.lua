-- uses global['beacon-opened'] as Player index -> opened beacon GUI
local beacon = "map-marker"

local function findBeaconTag(beacon)
	return beacon.force.find_chart_tags(beacon.surface, {{beacon.position.x-0.1,beacon.position.y-0.1},{beacon.position.x+0.1,beacon.position.y+0.1}})[1]
end
local function openBeaconGUI(beacon, player)
	local tag = findBeaconTag(beacon)
	if player.gui.screen['beacon-naming'] then return end
	local gui = player.gui.screen.add{
		type = "frame",
		name = "beacon-naming",
		direction = "vertical",
		caption = {"gui.beacon-title"},
		style = mod_gui.frame_style
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
	local textbox = table.add{
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
	if not global['beacon-opened'] then global['beacon-opened'] = {} end
	global['beacon-opened'][player.index] = beacon
end
local function closeBeaconGUI(player)
	local gui = player.gui.screen['beacon-naming']
	if gui then gui.visible = false end
	gui.destroy()
	player.opened = nil
end
local function onGuiOpened(event)
	if event.entity and event.entity.valid and event.entity.name == beacon then
		openBeaconGUI(event.entity, game.players[event.player_index])
	end
end
local function onGuiClick(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	if event.element.name == "beacon-naming-confirm" then
		local beacon = global['beacon-opened'][player.index] -- can be assumed to exist, otherwise how did we get here?
		local tag = findBeaconTag(beacon)
		if tag and tag.valid then
			local gui = player.gui.screen['beacon-naming']['beacon-naming-inner']['beacon-naming-table']
			tag.destroy()
			local params = {position=beacon.position,icon={type="item",name="map-marker"}}
			if gui['beacon-naming-icon'].elem_value then params.icon = gui['beacon-naming-icon'].elem_value end
			if gui['beacon-naming-name'].text then params.text = gui['beacon-naming-name'].text end
			beacon.force.add_chart_tag(beacon.surface, params)
		end
		closeBeaconGUI(player)
	end
end
local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == beacon then
		entity.force.add_chart_tag(entity.surface, {position=entity.position,icon={type="item",name="map-marker"}})
		if event.type == defines.events.on_build_entity then
			local player = game.players[event.player_index]
			openBeaconGUI(entity, player)
		end
	end
end
local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == beacon then
		local tag = findBeaconTag(entity)
		if tag and tag.valid then
			tag.destroy()
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

		[defines.events.on_gui_opened] = onGuiOpened,
		[defines.events.on_gui_click] = onGuiClick,
		[defines.events.on_gui_closed] = function(event)
			if event.gui_type == defines.gui_type.custom and event.element.valid and event.element.name == "beacon-naming" then
				closeBeaconGUI(game.players[event.player_index])
			end
		end
	}
}