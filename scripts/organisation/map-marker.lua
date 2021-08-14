local gui = require(modpath.."scripts.gui.map-marker")
local bev = require(modpath.."scripts.lualib.build-events")

local item_name = "map-marker"

---@param beacon LuaEntity
---@return LuaCustomChartTag
local function findBeaconTag(beacon)
	return beacon.force.find_chart_tags(beacon.surface, {{beacon.position.x-0.1,beacon.position.y-0.1},{beacon.position.x+0.1,beacon.position.y+0.1}})[1]
end

---@param event on_gui_opened
local function onGuiOpened(event)
	local entity = event.entity
	if not (entity and entity.valid) then return end
	if entity.name ~= item_name then return end
	local player = game.players[event.player_index]
	if entity.force ~= player.force then return end
	local tag = findBeaconTag(entity)
	gui.open_gui(player, entity, tag)
end

---@param player LuaPlayer
---@param marker LuaEntity
---@param name string
---@param icon SignalID
gui.callbacks.save = function(player, marker, name, icon)
	local tag = findBeaconTag(marker)
	if tag then
		tag.text = name
		tag.icon = icon or {type="item", name=item_name}
	else
		marker.force.add_chart_tag(marker.surface, {
			position = marker.position,
			icon = icon or {type="item", name=item_name},
			text = name
		})
	end
end

---@param entity LuaEntity
local function onBuilt(entity)
	local tag = entity.force.add_chart_tag(entity.surface, {position=entity.position,icon={type="item",name="map-marker"}})
	local player = entity.last_user
	if player then
		player.clear_cursor()
		gui.open_gui(player, entity, tag)
	end
end
---@param entity LuaEntity
local function onRemoved(entity)
	local tag = findBeaconTag(entity)
	if tag then tag.destroy() end
end

-- prevent manual editing of chart tags

---@param event on_chart_tag_added
local function onTagAdded(event)
	if event.player_index then
		local player = game.players[event.player_index]
		player.print{"message.tag-needs-beacon"}
		event.tag.destroy()
	end
end
---@param event on_chart_tag_modified
local function onTagModified(event)
	if event.player_index then
		local player = game.players[event.player_index]
		player.print{"message.tag-needs-beacon"}
		-- change it back
		event.tag.text = event.old_text
		event.tag.icon = event.old_icon
	end
end
---@param event on_chart_tag_removed
local function onTagRemoved(event)
	if event.player_index then
		local player = game.players[event.player_index]
		player.print{"message.tag-needs-beacon"}
		-- create a new tag in its place
		event.force.add_chart_tag(event.tag.surface, {
			position = event.tag.position,
			text = event.tag.text,
			icon = event.tag.icon
		})
	end
end

return bev.applyBuildEvents{
	on_build = {
		callback = onBuilt,
		filter = {name=item_name}
	},
	on_destroy = {
		callback = onRemoved,
		filter = {name=item_name}
	},
	events = {
		[defines.events.on_gui_opened] = onGuiOpened,
		[defines.events.on_chart_tag_added] = onTagAdded,
		[defines.events.on_chart_tag_modified] = onTagModified,
		[defines.events.on_chart_tag_removed] = onTagRemoved
	}
}
