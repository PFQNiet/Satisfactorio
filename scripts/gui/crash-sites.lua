---@class CrashSiteGui
---@field player LuaPlayer
---@field ship LuaEntity
---@field components CrashSiteGuiComponents

---@class CrashSiteGuiComponents
---@field frame LuaGuiElement
---@field parts LuaGuiElement
---@field power LuaGuiElement
---@field button LuaGuiElement

---@alias global.gui.crash_site table<uint, CrashSiteGui>
---@type global.gui.crash_site
local script_data = {}

---@class CrashSiteGuiCallbacks
---@field repair fun(player:LuaPlayer, site:CrashSiteData)
local callbacks = {
	repair = function() end
}

---@param player LuaPlayer
---@return CrashSiteGui|nil
local function getGui(player)
	return script_data[player.index]
end

---@param player LuaPlayer
---@return CrashSiteGui
local function createGui(player)
	if script_data[player.index] then return script_data[player.index] end
	local gui = player.gui.relative
	local frame = gui.add{
		type = "frame",
		direction = "vertical",
		anchor = {
			gui = defines.relative_gui_type.container_gui,
			position = defines.relative_gui_position.right,
			name = "crash-site-spaceship"
		},
		caption = {"gui.crash-site-repairs-required"}
	}

	local content = frame.add{
		type = "frame",
		style = "inside_shallow_frame_with_padding_and_spacing",
		direction = "vertical"
	}
	content.style.minimal_width = 200
	local parts = content.add{
		type = "flow",
		direction = "horizontal"
	}
	parts.add{
		type = "label",
		style = "caption_label",
		caption = {"gui.crash-site-parts-label"}
	}
	local parts_label = parts.add{
		type = "label",
		caption = {"gui.crash-site-not-needed"}
	}

	local power = content.add{
		type = "flow",
		direction = "horizontal"
	}
	power.add{
		type = "label",
		style = "caption_label",
		caption = {"gui.crash-site-power-label"}
	}
	local power_label = power.add{
		type = "label",
		caption = {"gui.crash-site-not-needed"}
	}
	local bottom = content.add{type = "flow"}
	bottom.add{type="empty-widget", style="filler_widget"}
	local button = bottom.add{
		type = "button",
		style = "submit_button",
		caption = {"gui.crash-site-open"}
	}

	content.add{
		type = "empty-widget",
		style = "vertical_lines_slots_filler"
	}

	script_data[player.index] = {
		player = player,
		site = nil,
		components = {
			frame = frame,
			parts = parts_label,
			power = power_label,
			button = button
		}
	}
	return script_data[player.index]
end

---@param player LuaPlayer
---@param site CrashSiteData
local function openGui(player, site)
	local data = getGui(player)
	if not data then data = createGui(player) end
	local components = data.components

	if site.requirements.item then
		components.parts.caption = {
			"gui.crash-site-parts",
			site.requirements.count,
			site.requirements.item,
			game.item_prototypes[site.requirements.item].localised_name
		}
	else
		components.parts.caption = {"gui.crash-site-not-needed"}
	end

	if site.requirements.power > 0 then
		components.power.caption = {
			"gui.crash-site-power",
			site.requirements.power
		}
	else
		components.power.caption = {"gui.crash-site-not-needed"}
	end

	data.ship = site.ship
	components.frame.visible = true
end

---@param player LuaPlayer
local function closeGui(player)
	local data = getGui(player)
	if not data then return end
	data.ship = nil
	data.components.frame.visible = false
end

---@param event on_gui_click
local function onGuiClick(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	local data = getGui(player)
	if not data then return end
	local components = data.components

	if event.element == components.button then
		callbacks.repair(player, data.ship)
	end
end

return {
	open_gui = openGui,
	close_gui = closeGui,
	callbacks = callbacks,
	lib = {
		on_init = function()
			global.gui.crash_site = global.gui.crash_site or script_data
		end,
		on_load = function()
			script_data = global.gui and global.gui.crash_site or script_data
		end,
		events = {
			[defines.events.on_gui_click] = onGuiClick
		}
	}
}
