-- add a trash slot to the player inventory gui (controller_gui)
local sinkable = require(modpath.."constants.sink-tradein") -- items that can be sunk can also be trashed
local trash = require(modpath.."scripts.gui.trash-slot")
local sort = require(modpath.."scripts.gui.sort-container")

---@param event on_player_created
local function onPlayerCreated(event)
	local player = game.players[event.player_index]
	trash.create_gui(player)
end

local function rejectTrash(player, reason)
	player.create_local_flying_text{
		text = reason,
		create_at_cursor = true
	}
	player.play_sound{path="utility/cannot_build"}
end

---@param player LuaPlayer
---@param stack LuaItemStack
---@param event on_gui_click
trash.callbacks.trash = function(player, stack, event)
	if stack.name == "hub-parts" then
		rejectTrash(player, {"message.trash-slot-hub-parts",stack.name,stack.prototype.localised_name})
	elseif stack.name == "uranium-waste" or stack.name == "plutonium-waste" then
		rejectTrash(player, {"message.trash-slot-nuclear-waste",stack.name,stack.prototype.localised_name})
	elseif stack.prototype.place_result and not sinkable[stack.name] then
		rejectTrash(player, {"message.trash-slot-building",stack.name,stack.prototype.localised_name})
	elseif (stack.type == "armor" or stack.type == "gun") and not event.shift then
		rejectTrash(player, {"message.trash-slot-equipment"})
	else
		if event.button == defines.mouse_button_type.right and stack.count > 1 then
			stack.count = stack.count - 1
		else
			stack.clear()
		end
	end
end

---@param event on_gui_opened
local function onGuiOpened(event)
	local player = game.players[event.player_index]
	if player.opened_gui_type ~= defines.gui_type.entity then return end
	sort.open_gui(player, player.opened)
end

return {
	events = {
		[defines.events.on_player_created] = onPlayerCreated,
		[defines.events.on_gui_opened] = onGuiOpened
	}
}
