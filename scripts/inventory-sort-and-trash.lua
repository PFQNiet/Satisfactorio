-- add a trash slot to the player inventory gui (controller_gui)
local sinkable = require(modpath.."constants.sink-tradein") -- items that can be sunk can also be trashed

local function onPlayerCreated(event)
	local player = game.players[event.player_index]
	local frame = player.gui.relative.add{
		type = "frame",
		name = "trash-slot",
		anchor = {
			gui = defines.relative_gui_type.controller_gui,
			position = defines.relative_gui_position.bottom
		},
		direction = "horizontal",
		style = "inset_frame_container_frame"
	}
	local slot = frame.add{
		type = "sprite-button",
		style = "slot",
		sprite = "utility/trash_white",
		name = "player-trash-slot",
		tooltip = {"gui.trash-slot-tooltip"}
	}
	slot.style.padding = 6
end

local function onGuiOpened(event)
	local player = game.players[event.player_index]
	if player.opened_gui_type ~= defines.gui_type.entity then return end
	local flow = player.gui.relative['sort-storage-flow']
	if not flow then
		flow = player.gui.relative.add{
			type = "flow",
			name = "sort-storage-flow",
			anchor = {
				gui = defines.relative_gui_type.container_gui,
				position = defines.relative_gui_position.bottom
			},
			direction = "horizontal"
		}
		flow.add{type="empty-widget"}.style.horizontally_stretchable = true
		local frame = flow.add{
			type = "frame",
			name = "sort-storage-frame",
			direction = "horizontal",
			style = "inset_frame_container_frame"
		}
		frame.style.horizontally_stretchable = false
		frame.style.use_header_filler = false
		local button = frame.add{
			type = "button",
			style = "dialog_button",
			name = "sort-storage",
			caption = {"gui.sort-storage"}
		}
	end
	-- change anchor depending on opened entity
	local type
	if player.opened.type == "container" then
		if #player.opened.get_inventory(defines.inventory.chest) > 1 then
			type = defines.relative_gui_type.container_gui
		end
	elseif player.opened.type == "cargo-wagon" then
		type = defines.relative_gui_type.container_gui
	elseif player.opened.type == "linked-chest" then
		type = defines.relative_gui_type.linked_container_gui
	elseif player.opened.type == "car" then
		type = defines.relative_gui_type.car_gui
	end
	if type then
		flow.visible = true
		flow.anchor = {
			gui = type,
			position = defines.relative_gui_position.bottom
		}
	else
		flow.visible = false
	end
end

local function onGuiClick(event)
	if event.element and event.element.valid then
		local player = game.players[event.player_index]
		if event.element.name == "player-trash-slot" then
			local stack = player.cursor_stack
			if stack.valid_for_read then
				if stack.name == "hub-parts" then
					player.create_local_flying_text{
						text = {"message.trash-slot-hub-parts",stack.name,stack.prototype.localised_name},
						create_at_cursor = true
					}
					player.play_sound{
						path = "utility/cannot_build"
					}
				elseif stack.name == "uranium-waste" or stack.name == "plutonium-waste" then
					player.create_local_flying_text{
						text = {"message.trash-slot-nuclear-waste",stack.name,stack.prototype.localised_name},
						create_at_cursor = true
					}
					player.play_sound{
						path = "utility/cannot_build"
					}
				elseif stack.prototype.place_result and not sinkable[stack.name] then
					player.create_local_flying_text{
						text = {"message.trash-slot-building",stack.name,stack.prototype.localised_name},
						create_at_cursor = true
					}
					player.play_sound{
						path = "utility/cannot_build"
					}
				elseif (stack.type == "armor" or stack.type == "gun") and not event.shift then
					player.create_local_flying_text{
						text = {"message.trash-slot-equipment"},
						create_at_cursor = true
					}
					player.play_sound{
						path = "utility/cannot_build"
					}
				else
					if event.button == defines.mouse_button_type.right and stack.count > 1 then
						stack.count = stack.count - 1
					else
						stack.clear()
					end
				end
			end
		elseif event.element.name == "sort-storage" then
			player.opened.get_output_inventory().sort_and_merge()
		end
	end
end

--[[ FEATURE WANTED but doesn't work due to transport belt interactions https://forums.factorio.com/92323 
local function dropStack(event)
	local player = game.players[event.player_index]
	if not player.selected and player.cursor_stack.valid_for_read then
		-- spill one item, then boost its count to the stack's count, but only if it wasn't dropped too far away
		local cursor = player.cursor_stack
		local position = player.surface.find_non_colliding_position("stack-on-ground",event.cursor_position,2,0.1,false)
		if position then
			local stack = {
				name = cursor.name,
				count = 1
			}
			local entity = player.surface.create_entity{
				name = "stack-on-ground",
				position = position,
				stack = stack
			}
			entity.stack.swap_stack(cursor)
			cursor.clear()
			player.play_sound{path="utility/drop_item"}
		end
	end
end
--]]

return {
	events = {
		[defines.events.on_player_created] = onPlayerCreated,
		[defines.events.on_gui_click] = onGuiClick,
		[defines.events.on_gui_opened] = onGuiOpened,

		["fast-stack-transfer"] = dropStack
	}
}
