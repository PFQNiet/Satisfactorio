---@class LizardDoggoGui
---@field player LuaPlayer
---@field doggo DoggoData
---@field components LizardDoggoGuiComponents

---@class LizardDoggoGuiComponents
---@field frame LuaGuiElement
---@field close LuaGuiElement
---@field preview LuaGuiElement
---@field loot_button LuaGuiElement
---@field take_button LuaGuiElement
---@field stay_button LuaGuiElement

---@alias global.gui.lizard_doggo table<uint, LizardDoggoGui>
---@type global.gui.lizard_doggo
local script_data = {}

---@class LizardDoggoGuiCallbacks
---@field take_loot fun(player:LuaPlayer, doggo:DoggoData)
---@field fast_take_loot fun(player:LuaPlayer, doggo:DoggoData)
---@field stay fun(doggo:DoggoData)
local callbacks = {
	take_loot = function() end,
	fast_take_loot = function() end,
	stay = function() end
}

---@param player LuaPlayer
---@return LizardDoggoGui|nil
local function getGui(player)
	return script_data[player.index]
end

---@param player LuaPlayer
---@return LizardDoggoGui
local function createGui(player)
	local gui = player.gui.screen
	local frame = gui.add{
		type = "frame",
		direction = "vertical",
		style = "inner_frame_in_outer_frame"
	}
	local title_flow = frame.add{type = "flow"}
	local title = title_flow.add{type = "label", caption = {"entity-name.small-biter"}, style = "frame_title"}
	title.drag_target = frame
	local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_in_window_title"}
	pusher.drag_target = frame
	local close = title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white"}

	local content = frame.add{
		type = "frame",
		style = "inside_shallow_frame_with_padding",
		direction = "vertical"
	}
	local columns = content.add{
		type = "flow",
		direction = "horizontal",
		style = "horizontal_flow_with_extra_spacing"
	}
	local col1 = columns.add{
		type = "frame",
		direction = "vertical",
		style = "deep_frame_in_shallow_frame"
	}
	local preview = col1.add{
		type = "entity-preview",
		style = "entity_button_base"
	}
	local col2 = columns.add{
		type = "flow",
		direction = "vertical"
	}
	col2.add{
		type = "label",
		style = "heading_2_label",
		caption = {"gui.lizard-doggo-loot"}
	}
	local lootbox = col2.add{
		type = "flow",
		direction = "horizontal",
		style = "vertically_aligned_flow"
	}
	local lootbtn = lootbox.add{
		type = "sprite-button",
		style = "slot_button_in_shallow_frame",
		mouse_button_filter = {"left"}
	}
	local takebtn = lootbox.add{
		type = "button",
		caption = {"gui.lizard-doggo-take"}
	}
	col2.add{type="line",direction="horizontal"}
	local staybtn = col2.add{
		type = "button",
		caption = {"gui.lizard-doggo-stay"},
		tooltip = {"gui.lizard-doggo-stay-description"}
	}

	script_data[player.index] = {
		player = player,
		doggo = nil,
		components = {
			frame = frame,
			close = close,
			preview = preview,
			loot_button = lootbtn,
			take_button = takebtn,
			stay_button = staybtn
		}
	}
	return script_data[player.index]
end

---@param player LuaPlayer
---@param doggo DoggoData
local function updateGui(player, doggo)
	local data = script_data[player.index]
	data.doggo = doggo

	local components = data.components
	components.preview.entity = doggo.entity

	local lootbtn = data.components.loot_button
	if doggo.helditem then
		lootbtn.sprite = "item/"..doggo.helditem.name
		lootbtn.tooltip = doggo.helditem.localised_name
		lootbtn.number = doggo.helditem.count
		components.take_button.enabled = true
	else
		lootbtn.sprite = nil
		lootbtn.tooltip = ""
		lootbtn.number = nil
		components.take_button.enabled = false
	end
end

-- Force a GUI update for every player that has the given Doggo open
---@param doggo DoggoData
local function updateAllGui(doggo)
	for _,player in pairs(game.players) do
		local data = getGui(player)
		if data and data.doggo == doggo then
			updateGui(player, doggo)
		end
	end
end

---@param player LuaPlayer
---@param doggo DoggoData
---@return LizardDoggoGui
local function openGui(player, doggo)
	local data = getGui(player)
	if not data then data = createGui(player) end

	updateGui(player, doggo)

	local frame = data.components.frame
	frame.visible = true
	player.opened = frame
	frame.force_auto_center()
	return data
end

---@param player LuaPlayer
local function closeGui(player)
	local data = script_data[player.index]
	if not data then return end
	if player.opened == data.components.frame then
		player.opened = nil
	end
	data.components.frame.visible = false
	data.doggo = nil
end

-- Close gui for all players that have this Doggo open
---@param doggo DoggoData
local function closeAllGui(doggo)
	for _,player in pairs(game.players) do
		local data = getGui(player)
		if data and data.doggo == doggo then
			closeGui(player)
		end
	end
end

---@param event on_gui_closed
local function onGuiClosed(event)
	local player = game.players[event.player_index]
	closeGui(player)
end

---@param event on_gui_click
local function onGuiClick(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	local data = script_data[player.index]
	if not data then return end
	local components = data.components

	if event.element == components.close then
		closeGui(player)

	elseif event.element == components.take_button or (event.element == components.loot_button and event.shift) then
		callbacks.fast_take_loot(player, data.doggo)
		updateAllGui(data.doggo)

	elseif event.element == components.loot_button then -- click without shift
		callbacks.take_loot(player, data.doggo)
		updateAllGui(data.doggo)

	elseif event.element == components.stay_button then
		callbacks.stay(data.doggo)
		closeGui(player)
	end
end

-- if the player moves and has a pet open, check that the pet can still be reached
local function onMove(event)
	local player = game.players[event.player_index]
	local data = getGui(player)
	if data and data.doggo then
		local pet = data.doggo.entity
		if not (pet.valid and player.can_reach_entity(pet)) then
			closeGui(player)
		end
	end
end

return {
	open_gui = openGui,
	close_gui = closeGui,
	close_all_gui = closeAllGui,
	callbacks = callbacks,
	lib = {
		on_init = function()
			global.gui.lizard_doggo = global.gui.lizard_doggo or script_data
		end,
		on_load = function()
			script_data = global.gui and global.gui.lizard_doggo or script_data
		end,
		events = {
			[defines.events.on_gui_closed] = onGuiClosed,
			[defines.events.on_gui_click] = onGuiClick,
			[defines.events.on_player_changed_position] = onMove
		}
	}
}
