---@class OnboardingGui
---@field player LuaPlayer
---@field components OnboardingGuiComponents

---@class OnboardingGuiComponents
---@field frame LuaGuiElement
---@field message LuaGuiElement
---@field button_flow LuaGuiElement
---@field button LuaGuiElement

---@alias global.gui.onboarding table<uint, OnboardingGui>
---@type global.gui.onboarding
local script_data = {}

---@class OnboardingGuiCallbacks
---@field continue fun(player:LuaPlayer)
local callbacks = {
	continue = function() end
}

---@param player LuaPlayer
---@return OnboardingGui|nil
local function getGui(player)
	return script_data[player.index]
end

---@param player LuaPlayer
---@return OnboardingGui
local function createGui(player)
	if script_data[player.index] then return script_data[player.index] end
	local gui = player.gui.left
	local frame = gui.add{
		type = "frame",
		index = 1,
		style = "goal_frame",
		caption = {"story-message.title"}
	}
	local inner = frame.add{
		type = "frame",
		direction = "vertical",
		style = "goal_inner_frame_with_spacing"
	}
	local content = inner.add{
		type = "label",
		style = "goal_label",
		caption = script_data.message
	}
	local flow = inner.add{
		type = "flow",
		direction = "horizontal"
	}
	flow.add{
		type = "empty-widget",
		style = "filler_widget"
	}
	local button = flow.add{
		type = "button",
		style = "submit_button",
		caption = {"story-message.continue"}
	}

	script_data[player.index] = {
		player = player,
		components = {
			frame = frame,
			message = content,
			button_flow = flow,
			button = button
		}
	}
	return script_data[player.index]
end

---@param player LuaPlayer
---@param message LocalisedString
---@param continuable boolean
local function updateGUI(player, message, continuable)
	local data = getGui(player)
	if not data then data = createGui(player) end

	if not message or message == "" then
		data.components.frame.visible = false
	else
		data.components.frame.visible = true
		data.components.message.caption = message
		data.components.button_flow.visible = continuable
	end
end

---@param event on_gui_click
local function onGuiClick(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	local data = getGui(player)
	if not data then return end
	local components = data.components

	if event.element == components.button then
		callbacks.continue(player)
	end
end

return {
	update = updateGUI,
	callbacks = callbacks,
	lib = {
		on_init = function()
			global.gui.onboarding = global.gui.onboarding or script_data
		end,
		on_load = function()
			script_data = global.gui and global.gui.onboarding or script_data
		end,
		events = {
			[defines.events.on_gui_click] = onGuiClick
		}
	}
}
