-- Lizard Doggo - tameable entity
-- By default it wanders, but it will flee from players that come too close
-- If a Paleberry is on the ground nearby, it will instead go to it and eat one from the item stack, becoming tamed
-- Once tamed it will follow its owner and gains a GUI. The GUI sometimes gives a free item, and can also be used to give "follow" and "stay" commands
-- If a tamed doggo gets too far from its owner it will go back to wandering but will be on the lookout for its owner to follow them again

-- uses global['lizard-doggos'] to track all of this, indexed by unit_number
-- uses global['dropped-bait'] to track dropped berries, as they sadly lack a "last_user"
-- uses global['lizard-doggo-gui'] to track which doggo a player has opened

local loot = require("constants.doggo-loot")

local doggo = "small-biter"
local bait = "paleberry"

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == doggo then
		if not global['lizard-doggos'] then global['lizard-doggos'] = {} end
		global['lizard-doggos'][entity.unit_number] = {
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
local function onDroppedItem(event)
	if event.entity.stack.name == bait then
		if not global['dropped-bait'] then global['dropped-bait'] = {} end
		local reg = script.register_on_entity_destroyed(event.entity)
		global['dropped-bait'][reg] = {
			entity = event.entity,
			player = game.players[event.player_index]
		}
	end
end
local function onEntityDestroyed(event)
	if global['dropped-bait'] and global['dropped-bait'][event.registration_number] then
		global['dropped-bait'][event.registration_number] = nil
	end
end
local function onEntityDied(event)
	if event.entity.valid and event.entity.name == doggo then
		local item = global['lizard-doggos'][event.entity.unit_number] and global['lizard-doggos'][event.entity.unit_number].helditem
		if item then
			event.entity.surface.spill_item_stack(
				event.entity.position,
				item,
				true, nil, false
			)
		end
		global['lizard-doggos'][event.entity.unit_number] = nil
	end
end
local function onCommandCompleted(event)
	local struct = global['lizard-doggos'] and global['lizard-doggos'][event.unit_number]
	if struct then
		if struct.entity.valid then
			if not struct.owner then
				-- look for food
				local itemsonground = struct.entity.surface.find_entities_filtered{
					type = "item-entity",
					position = struct.entity.position,
					radius = 15
				}
				local berry = nil
				local player = nil
				for _,item in pairs(itemsonground) do
					if item.valid and item.stack.valid_for_read and item.stack.name == bait then
						-- ensure berry item is in dropped bait list, so it's assigned to a player
						for _,bait in pairs(global['dropped-bait']) do
							if bait.entity == item then
								berry = item
								player = bait.player
								break
							end
						end
						if berry then break end
					end
				end
				if berry then
					local dist = (berry.position.x-struct.entity.position.x)^2 + (berry.position.y-struct.entity.position.y)^2
					if dist < 3*3 then
						-- eat the berry
						struct.owner = player
						struct.itemtimer = event.tick + math.random(8*60*60,15*60*60) -- 8-15 minutes
						if berry.stack.count == 1 then
							berry.destroy()
						else
							berry.stack.count = berry.stack.count - 1
						end
						struct.entity.set_command{
							type = defines.command.stop,
							ticks_to_wait = 60,
							distraction = defines.distraction.none
						}
					else
						-- go to the berry
						struct.entity.set_command{
							type = defines.command.go_to_location,
							destination_entity = berry,
							radius = 2,
							distraction = defines.distraction.none
						}
					end
				else
					-- look for nearby players
					local player = struct.entity.surface.find_entities_filtered{
						type = "character",
						position = struct.entity.position,
						radius = 10,
						limit = 1
					}[1]
					if player then
						-- run away
						struct.entity.set_command{
							type = defines.command.flee,
							from = player,
							distraction = defines.distraction.none
						}
					else
						-- nothing wrong here, just keep wandering
						struct.entity.set_command{
							type = defines.command.wander,
							radius = 20,
							ticks_to_wait = 180,
							distraction = defines.distraction.none
						}
					end
				end
			else
				-- tame doggo, follow player if nearby
				local dist = (struct.owner.position.x-struct.entity.position.x)^2 + (struct.owner.position.y-struct.entity.position.y)^2
				if dist < 5*5 then
					-- sit :D
					struct.entity.set_command{
						type = defines.command.stop,
						ticks_to_wait = 60,
						distraction = defines.distraction.none
					}
				elseif dist < 20*20 then
					struct.entity.set_command{
						type = defines.command.go_to_location,
						destination = struct.owner.position,
						radius = 3,
						distraction = defines.distraction.none
					}
				else
					-- player abandoned me :'c
					struct.entity.set_command{
						type = defines.command.wander,
						radius = 20,
						ticks_to_wait = 180,
						distraction = defines.distraction.none
					}
				end
			end
		else
			-- died perhaps, clean up the struct
			global['lizard-doggos'][event.unit_number] = nil
		end
	end
end

local function onInteract(event)
	local player = game.players[event.player_index]
	if player.selected and player.selected.valid and player.selected.name == doggo and player.can_reach_entity(player.selected) then
		local struct = global['lizard-doggos'] and global['lizard-doggos'][player.selected.unit_number]
		if struct and struct.owner == player then
			local gui = player.gui.screen['lizard-doggo']
			if not gui then
				gui = player.gui.screen.add{
					type = "frame",
					name = "lizard-doggo",
					direction = "vertical",
					style = "inner_frame_in_outer_frame"
				}
				local title_flow = gui.add{type = "flow", name = "title_flow"}
				local title = title_flow.add{type = "label", caption = {"entity-name.small-biter"}, style = "frame_title"}
				title.drag_target = gui
				local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_header"}
				pusher.style.height = 24
				pusher.style.horizontally_stretchable = true
				pusher.drag_target = gui
				title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white", name = "lizard-doggo-close"}
		
				local content = gui.add{
					type = "frame",
					style = "inside_shallow_frame_with_padding",
					direction = "vertical",
					name = "content"
				}
				local columns = content.add{
					type = "flow",
					direction = "horizontal",
					name = "table"
				}
				columns.style.horizontal_spacing = 12
				local col1 = columns.add{
					type = "frame",
					direction = "vertical",
					name = "left",
					style = "deep_frame_in_shallow_frame"
				}
				local preview = col1.add{
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
				local loot = col2.add{
					type = "flow",
					direction = "horizontal",
					name = "loot"
				}
				loot.style.vertical_align = "center"
				loot.add{
					type = "sprite-button",
					style = "slot_button_in_shallow_frame",
					name = "lootsprite",
					mouse_button_filter = {}
				}
				loot.add{
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
				local rand = math.random()*100
				for name,entry in pairs(loot) do
					rand = rand - entry.probability
					if rand < 0 then
						struct.helditem = {
							name = name,
							count = math.random(entry.amount_min, entry.amount_max)
						}
						break
					end
				end
			end

			gui.content.table.left.preview.entity = struct.entity
			local lootbtn = gui.content.table.right.loot.lootsprite
			lootbtn.tooltip = struct.helditem and {"item-name."..struct.helditem.name} or ""
			lootbtn.sprite = struct.helditem and "item/"..struct.helditem.name or nil
			lootbtn.number = struct.helditem and struct.helditem.count or nil
			gui.content.table.right.loot['take-lizard-doggo-loot'].enabled = struct.helditem and true or false

			gui.visible = true
			player.opened = gui
			gui.force_auto_center()
			if not global['lizard-doggo-gui'] then global['lizard-doggo-gui'] = {} end
			global['lizard-doggo-gui'][player.index] = struct.entity.unit_number
		end
	end
end
local function closeGui(player)
	local gui = player.gui.screen['lizard-doggo']
	if gui then gui.visible = false end
	player.opened = nil
	global['lizard-doggo-gui'][player.index] = nil
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
	elseif event.element.name == "take-lizard-doggo-loot" then
		local struct = global['lizard-doggos'][global['lizard-doggo-gui'][player.index]]
		if struct and struct.owner == player and struct.entity and struct.entity.valid and struct.helditem then
			local transferred = player.insert(struct.helditem)
			local gui = player.gui.screen['lizard-doggo'].content.table.right.loot
			if transferred == struct.helditem.count then
				-- set new loot timer
				struct.helditem = nil
				struct.itemtimer = event.tick + math.random(8*60*60,15*60*60) -- 8-15 minutes
				gui.lootsprite.tooltip = nil
				gui.lootsprite.sprite = nil
				gui.lootsprite.number = nil
				gui['take-lizard-doggo-loot'].enabled = false
			else
				struct.helditem.count = struct.helditem.count - transferred
				gui.lootsprite.number = struct.helditem.count
			end
		end
	elseif event.element.name == "stop-lizard-doggo" then
		local struct = global['lizard-doggos'][global['lizard-doggo-gui'][player.index]]
		if struct and struct.owner == player and struct.entity and struct.entity.valid then
			struct.entity.set_command{
				type = defines.command.stop,
				ticks_to_wait = 30*60, -- stay for 30s
				distraction = defines.distraction.none
			}
			closeGui(player)
		end
	end
end

return {
	events = {
		[defines.events.on_built_entity] = onBuilt,
		[defines.events.on_robot_built_entity] = onBuilt,
		[defines.events.script_raised_built] = onBuilt,
		[defines.events.script_raised_revive] = onBuilt,

		[defines.events.on_player_dropped_item] = onDroppedItem,
		[defines.events.on_entity_destroyed] = onEntityDestroyed,

		[defines.events.on_entity_died] = onEntityDied,
		[defines.events.on_ai_command_completed] = onCommandCompleted,
		["interact"] = onInteract,
		[defines.events.on_gui_closed] = onGuiClosed,
		[defines.events.on_gui_click] = onGuiClick
	}
}
