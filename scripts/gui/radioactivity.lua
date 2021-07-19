---@class RadiationGui
---@field player LuaPlayer
---@field components RadiationGuiComponents

---@class RadiationGuiComponents
---@field frame LuaGuiElement
---@field bar LuaGuiElement

---@alias global.gui.radiation table<uint, RadiationGui>
---@type global.gui.radiation
local script_data = {}

---@param player LuaPlayer
---@param frame LuaGuiElement
local function setFramePosition(player, frame)
	frame.location = {
		(player.display_resolution.width-246*player.display_scale)/2,
		200*player.display_scale
	}
end

---@param player LuaPlayer
---@return RadiationGui|nil
local function getGui(player)
	return script_data[player.index]
end

---@param player LuaPlayer
---@return RadiationGui
local function createGui(player)
	if script_data[player.index] then return script_data[player.index] end
	local gui = player.gui.screen
	local frame = gui.add{
		type = "frame",
		ignored_by_interaction = true,
		direction = "horizontal",
		caption = {"gui.radiation"},
		style = "radioactivity_frame"
	}
	frame.add{
		type = "sprite",
		sprite = "tooltip-category-nuclear"
	}
	local bar = frame.add{
		type = "progressbar",
		style = "radioactivity_progressbar"
	}
	setFramePosition(player, frame)

	script_data[player.index] = {
		player = player,
		components = {
			frame = frame,
			bar = bar
		}
	}
	return script_data[player.index]
end

---@param player LuaPlayer
---@param radiation number
local function updateGUI(player, radiation)
	local data = getGui(player)
	if not data then data = createGui(player) end

	if radiation < 1 then
		data.components.frame.visible = false
	else
		data.components.frame.visible = true
		data.components.bar.value = math.min(radiation/145,1)
	end
end

local function onResolutionChanged(event)
	local player = game.players[event.player_index]
	local data = getGui(player)
	if data then
		setFramePosition(player, data.components.frame)
	end
end

return {
	update = updateGUI,
	lib = {
		on_init = function()
			global.gui.radiation = global.gui.radiation or script_data
		end,
		on_load = function()
			script_data = global.gui and global.gui.radiation or script_data
		end,
		events = {
			[defines.events.on_player_display_resolution_changed] = onResolutionChanged,
			[defines.events.on_player_display_scale_changed] = onResolutionChanged
		}
	}
}
