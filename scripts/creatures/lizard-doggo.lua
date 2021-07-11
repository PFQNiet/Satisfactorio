-- Lizard Doggo - tameable entity
-- By default it wanders, but it will flee from players that come too close
-- If a Paleberry is on the ground nearby, it will instead go to it and eat one from the item stack, becoming tamed
-- Once tamed it will follow its owner and gains a GUI. The GUI sometimes gives a free item, and can also be used to give "follow" and "stay" commands
-- If a tamed doggo gets too far from its owner it will go back to wandering but will be on the lookout for its owner to follow them again

-- uses global.small_biter.lizard-doggos to track all of this, indexed by unit_number
-- uses global.small_biter.dropped-bait to track dropped berries, as they sadly lack a "last_user"
-- uses global.small_biter.lizard-doggo-gui to track which doggo a player has opened

local bev = require(modpath.."scripts.lualib.build-events")
local loot = require(modpath.."constants.doggo-loot")

local doggo = "lizard-doggo"
local bait = "paleberry"

---@class BaitData
---@field entity LuaEntity ItemOnGround
---@field player LuaPlayer

---@class DoggoData
---@field entity LuaEntity Unit
---@field owner LuaPlayer|nil No owner = wild
---@field itemtimer uint Tick at which the next item will be generated
---@field helditem DoggoLoot|nil Found loot

---@class DoggoLoot
---@field name string
---@field localised_name LocalisedString
---@field count uint8

---@class global.pets
---@field lizard_doggos table<uint, DoggoData> Indexed by unit number of the doggo
---@field lizard_doggo_gui table<uint, uint> Player index => doggo unit number
---@field dropped_bait table<uint64, BaitData> Entity destroyed reg number => bait information
local script_data = {
	lizard_doggos = {},
	lizard_doggo_gui = {},
	dropped_bait = {}
}

---@param player LuaPlayer
local function closeGui(player)
	local gui = player.gui.screen['lizard-doggo']
	if gui then gui.visible = false end
	player.opened = nil
	script_data.lizard_doggo_gui[player.index] = nil
end

---@param event on_build
local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == doggo then
		script_data.lizard_doggos[entity.unit_number] = {
			entity = entity,
			owner = nil, -- no owner = wild
			itemtimer = nil,
			helditem = nil
		}
		entity.set_command{
			type = defines.command.wander,
			radius = 20,
			ticks_to_wait = 180,
			distraction = defines.distraction.none
		}
	end
end
---@param event on_player_dropped_item
local function onDroppedItem(event)
	if event.entity.stack.name == bait then
		local reg = script.register_on_entity_destroyed(event.entity)
		script_data.dropped_bait[reg] = {
			entity = event.entity,
			player = game.players[event.player_index]
		}
	end
end
---@param event on_entity_destroyed
local function onEntityDestroyed(event)
	if script_data.dropped_bait[event.registration_number] then
		script_data.dropped_bait[event.registration_number] = nil
	end
end
---@param event on_entity_died
local function onEntityDied(event)
	if event.entity.valid and event.entity.name == doggo then
		local doggos = script_data.lizard_doggos
		local item = doggos[event.entity.unit_number] and doggos[event.entity.unit_number].helditem
		if item then
			event.entity.surface.spill_item_stack(
				event.entity.position,
				item,
				true, nil, false
			)
		end
		doggos[event.entity.unit_number] = nil
		-- find any players that had this pet's GUI open and close it
		for pid,uid in pairs(script_data.lizard_doggo_gui) do
			if uid == event.entity.unit_number then
				closeGui(game.players[pid])
			end
		end
	end
end

---@param struct DoggoData
local function generateDoggoLoot(struct)
	local rand = math.random()*100
	for name,entry in pairs(loot) do
		rand = rand - entry.probability
		if rand < 0 then
			struct.helditem = {
				name = name,
				localised_name = game.item_prototypes[name].localised_name,
				count = math.random(entry.amount_min, entry.amount_max)
			}
			return
		end
	end
end
---@param struct DoggoData
local function clearDoggoLoot(struct)
	struct.helditem = nil
	struct.itemtimer = game.tick + math.random(8*60*60,15*60*60) -- 8-15 minutes
	-- find any player with this doggo open and clear their GUI
	for pid,uid in pairs(script_data.lizard_doggo_gui) do
		if uid == struct.entity.unit_number then
			-- GUI can be assumed to exist if the player has it open
			local gui = game.players[pid].gui.screen['lizard-doggo'].content.table.right.loot
			local sprite = gui['view-lizard-doggo-loot']
			local button = gui['take-lizard-doggo-loot']
			sprite.sprite = nil
			sprite.number = nil
			sprite.tooltip = ""
			button.enabled = false
		end
	end
end

--#region Doggo AI

-- Look for a Paleberry and return it if found
---@param unit LuaEntity Unit
---@return BaitData|nil
local function lookForFood(unit)
	local itemsonground = unit.surface.find_entities_filtered{
		type = "item-entity",
		position = unit.position,
		radius = 15
	}
	for _,item in pairs(itemsonground) do
		if item.valid and item.stack.valid_for_read and item.stack.name == bait then
			-- ensure berry item is in dropped bait list, so it's assigned to a player
			for _,entry in pairs(script_data.dropped_bait) do
				if entry.entity == item then
					return entry
				end
			end
		end
	end
end

-- Go to the Paleberry if needed, and eat it once close enough
---@param struct DoggoData
---@param berry BaitData
local function eatFood(struct, berry)
	local unit = struct.entity
	local mypos = unit.position
	local target = berry.entity
	local position = target.position
	local dist = (position.x-mypos.x)^2 + (position.y-mypos.y)^2
	if dist > 3*3 then
		-- go to the berry
		unit.set_command{
			type = defines.command.go_to_location,
			destination_entity = target,
			radius = 2,
			distraction = defines.distraction.none
		}
	else
		-- eat the berry and become tamed by whoever placed it
		struct.owner = berry.player
		struct.itemtimer = game.tick + math.random(8*60*60,15*60*60) -- 8-15 minutes
		if target.stack.count == 1 then
			target.destroy()
		else
			target.stack.count = target.stack.count - 1
		end
		unit.set_command{
			type = defines.command.stop,
			ticks_to_wait = 60,
			distraction = defines.distraction.none
		}
	end
end

-- Find any nearby character to flee from
---@param unit LuaEntity Unit
---@return LuaEntity|nil
local function findNearbyCharacter(unit)
	return unit.surface.find_entities_filtered{
		type = "character",
		position = unit.position,
		radius = 10,
		limit = 1
	}[1]
end

---@param unit LuaEntity Unit
---@param character LuaEntity Character
local function runAwayFrom(unit, character)
	unit.set_command{
		type = defines.command.flee,
		from = character,
		distraction = defines.distraction.none
	}
end
---@param unit LuaEntity Unit
local function wanderFreely(unit)
	unit.set_command{
		type = defines.command.wander,
		radius = 20,
		ticks_to_wait = 180,
		distraction = defines.distraction.none
	}
end

-- Returns distance^2 between the doggo and its owner
---@param struct DoggoData
---@return number
local function howFarIsMyOwner(struct)
	local mypos = struct.entity.position
	local ownerpos = struct.owner.position
	return (ownerpos.x-mypos.x)^2 + (ownerpos.y-mypos.y)^2
end

---@param unit LuaEntity Unit
---@param time uint Ticks to wait
local function stayPut(unit, time)
	unit.set_command{
		type = defines.command.stop,
		ticks_to_wait = time,
		distraction = defines.distraction.none
	}
end

---@param unit LuaEntity Unit
---@param owner LuaPlayer
local function followOwner(unit, owner)
	unit.set_command{
		type = defines.command.go_to_location,
		destination = owner.position,
		radius = 3,
		distraction = defines.distraction.none
	}
end

---@param event on_ai_command_completed
local function onCommandCompleted(event)
	local struct = script_data.lizard_doggos[event.unit_number]
	if struct then
		if struct.entity.valid then
			if not struct.owner then
				local berry = lookForFood(struct.entity)
				if berry then
					eatFood(struct, berry)
				else
					local character = findNearbyCharacter(struct.entity)
					if character then
						runAwayFrom(struct.entity, character)
					else
						wanderFreely(struct.entity)
					end
				end
			else
				local dist = howFarIsMyOwner(struct)
				if dist < 5*5 then
					stayPut(struct.entity, 60)
				elseif dist < 20*20 then
					followOwner(struct.entity, struct.owner)
				else
					wanderFreely(struct.entity)
				end
			end
		else
			-- died perhaps, clean up the struct
			script_data.lizard_doggos[event.unit_number] = nil
		end
	end
end
--#endregion

local function onInteract(event)
	local player = game.players[event.player_index]
	if player.selected and player.selected.valid and player.selected.name == doggo then
		if player.can_reach_entity(player.selected) then
			local struct = script_data.lizard_doggos[player.selected.unit_number]
			if struct and struct.owner == player then
				local gui = player.gui.screen
				if not gui['lizard-doggo'] then
					local frame = gui.add{
						type = "frame",
						name = "lizard-doggo",
						direction = "vertical",
						style = "inner_frame_in_outer_frame"
					}
					local title_flow = frame.add{type = "flow", name = "title_flow"}
					local title = title_flow.add{type = "label", caption = {"entity-name.small-biter"}, style = "frame_title"}
					title.drag_target = frame
					local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_in_window_title"}
					pusher.drag_target = frame
					title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white", name = "lizard-doggo-close"}

					local content = frame.add{
						type = "frame",
						style = "inside_shallow_frame_with_padding",
						direction = "vertical",
						name = "content"
					}
					local columns = content.add{
						type = "flow",
						direction = "horizontal",
						name = "table",
						style = "horizontal_flow_with_extra_spacing"
					}
					local col1 = columns.add{
						type = "frame",
						direction = "vertical",
						name = "left",
						style = "deep_frame_in_shallow_frame"
					}
					col1.add{
						type = "entity-preview",
						name = "preview",
						style = "entity_button_base"
					}
					local col2 = columns.add{
						type = "flow",
						direction = "vertical",
						name = "right"
					}
					col2.add{
						type = "label",
						style = "heading_2_label",
						caption = {"gui.lizard-doggo-loot"}
					}
					local lootbox = col2.add{
						type = "flow",
						direction = "horizontal",
						name = "loot",
						style = "vertically_aligned_flow"
					}
					lootbox.add{
						type = "sprite-button",
						style = "slot_button_in_shallow_frame",
						name = "view-lizard-doggo-loot",
						mouse_button_filter = {"left"}
					}
					lootbox.add{
						type = "button",
						name = "take-lizard-doggo-loot",
						caption = {"gui.lizard-doggo-take"}
					}
					col2.add{type="line",direction="horizontal"}
					col2.add{
						type = "button",
						name = "stop-lizard-doggo",
						caption = {"gui.lizard-doggo-stay"},
						tooltip = {"gui.lizard-doggo-stay-description"}
					}
				end

				-- roll for loot!
				if not struct.helditem and struct.itemtimer < event.tick then
					generateDoggoLoot(struct)
				end

				local frame = gui['lizard-doggo']
				local content_table = frame.content.table
				content_table.left.preview.entity = struct.entity
				local lootbtn = content_table.right.loot['view-lizard-doggo-loot']
				lootbtn.tooltip = struct.helditem and struct.helditem.localised_name or ""
				lootbtn.sprite = struct.helditem and "item/"..struct.helditem.name or nil
				lootbtn.number = struct.helditem and struct.helditem.count or nil
				content_table.right.loot['take-lizard-doggo-loot'].enabled = struct.helditem and true or false

				frame.visible = true
				player.opened = frame
				frame.force_auto_center()
				script_data.lizard_doggo_gui[player.index] = struct.entity.unit_number
			end
		else
			-- create flying text like when trying to mine normally
			player.create_local_flying_text{
				text = {"cant-reach"},
				create_at_cursor = true
			}
			player.play_sound{
				path = "utility/cannot_build"
			}
		end
	end
end
local function onGuiClosed(event)
	if event.element and event.element.valid and event.element.name == "lizard-doggo" then
		closeGui(game.players[event.player_index])
	end
end
local function onGuiClick(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	if event.element.name == "lizard-doggo-close" then
		closeGui(player)

	elseif event.element.name == "take-lizard-doggo-loot" or (event.element.name == "view-lizard-doggo-loot" and event.shift) then
		local struct = script_data.lizard_doggos[script_data.lizard_doggo_gui[player.index]]
		if struct and struct.owner == player and struct.entity and struct.entity.valid and struct.helditem then
			local transferred = player.insert(struct.helditem)
			if transferred == struct.helditem.count then
				clearDoggoLoot(struct)
			else
				struct.helditem.count = struct.helditem.count - transferred
				-- find any player with this doggo open and update the number shown in their GUI
				for pid,uid in pairs(script_data.lizard_doggo_gui) do
					if uid == struct.entity.unit_number then
						-- GUI can be assumed to exist if the player has it open
						local gui = game.players[pid].gui.screen['lizard-doggo'].content.table.right.loot
						local sprite = gui['view-lizard-doggo-loot']
						sprite.number = struct.helditem.count
					end
				end
			end
		end

	elseif event.element.name == "view-lizard-doggo-loot" then -- click without shift
		local struct = script_data.lizard_doggos[script_data.lizard_doggo_gui[player.index]]
		if struct and struct.owner == player and player.cursor_stack and not player.cursor_stack.valid_for_read and struct.entity and struct.entity.valid and struct.helditem then
			player.cursor_stack.set_stack(struct.helditem)
			clearDoggoLoot(struct)
		end
	elseif event.element.name == "stop-lizard-doggo" then
		local struct = script_data.lizard_doggos[script_data.lizard_doggo_gui[player.index]]
		if struct and struct.owner == player and struct.entity and struct.entity.valid then
			stayPut(struct.entity, 30*60)
			closeGui(player)
		end
	end
end

local function onMove(event)
	-- if the player moves and has a pet open, check that the pet can still be reached
	local player = game.players[event.player_index]
	local opened = script_data.lizard_doggo_gui[player.index]
	if opened then
		if not player.can_reach_entity(script_data.lizard_doggos[opened].entity) then
			closeGui(player)
		end
	end
end

return bev.applyBuildEvents{
	on_build = onBuilt,
	on_init = function()
		global.pets = global.pets or script_data
	end,
	on_load = function()
		script_data = global.pets or script_data
	end,
	events = {
		[defines.events.on_player_dropped_item] = onDroppedItem,
		[defines.events.on_entity_destroyed] = onEntityDestroyed,

		[defines.events.on_entity_died] = onEntityDied,
		[defines.events.on_ai_command_completed] = onCommandCompleted,
		["interact"] = onInteract,
		[defines.events.on_gui_closed] = onGuiClosed,
		[defines.events.on_gui_click] = onGuiClick,

		[defines.events.on_player_changed_position] = onMove
	}
}
