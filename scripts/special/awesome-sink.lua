-- sink is an EEI, which must spawn a chest (and input)
-- chest has a single slot and is frequently checked for contents - if found they are voided and points are awarded
-- points earned according to data in constants.sink-tradein
-- n = tickets earned so far, next ticket earned at 500*floor(n/3)^2+1000 points
-- uses global['awesome-sinks'] to track sinks to iterate through
-- uses global['awesome-coupons'] to track force => {earned, printed, points}
local function pointsToNext(earned)
	return 500 * math.floor(earned / 3)^2 + 1000
end
local function gainPoints(force, points)
	if not global['awesome-coupons'] then global['awesome-coupons'] = {} end
	if not global['awesome-coupons'][force.index] then global['awesome-coupons'][force.index] = {0,0,0} end
	local entry = global['awesome-coupons'][force.index]
	entry[3] = entry[3] + points
	local tonext = pointsToNext(entry[1])
	while entry[3] > tonext do
		entry[1] = entry[1] + 1
		entry[2] = entry[2] + 1
		entry[3] = entry[3] - tonext
		tonext = pointsToNext(entry[1])
	end
end

local io = require("scripts.lualib.input-output")
local paytable = require("constants.sink-tradein")

local base = "awesome-sink"
local storage = base.."-box"

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == base then
		-- add storage box
		local store = entity.surface.create_entity{
			name = storage,
			position = entity.position,
			force = entity.force,
			raise_built = true
		}
		io.addInput(entity, {-1,2.5}, store)
		entity.rotatable = false
		if not global['awesome-sinks'] then global['awesome-sinks'] = {} end
		table.insert(global['awesome-sinks'], entity)
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == base or entity.name == storage then
		-- find components
		local floor = entity.name == base and entity or entity.surface.find_entity(base, entity.position)
		local store = entity.name == storage and entity or entity.surface.find_entity(storage, entity.position)
		io.removeInput(floor, {-1,2.5}, event)
		-- remove from global table
		for i,x in ipairs(global['awesome-sinks']) do
			if x == floor then
				table.remove(global['awesome-sinks'], i)
				break
			end
		end
		(entity == floor and store or floor).destroy()
	end
end

local function onGuiOpened(event)
	local player = game.players[event.player_index]
	if event.gui_type == defines.gui_type.entity and event.entity.valid and event.entity.name == storage then
		local floor = event.entity.surface.find_entity(base, event.entity.position)
		-- create additional GUI for switching input/output mode
		local gui = player.gui.left
		if not gui['awesome-sink-gui'] then
			local frame = gui.add{
				type = "frame",
				name = "awesome-sink-gui",
				direction = "vertical",
				caption = {"gui.awesome-sink-gui-title"},
				style = mod_gui.frame_style
			}
			frame.style.horizontally_stretchable = false
			frame.style.use_header_filler = false
			local inner = frame.add{
				type = "frame",
				name = "awesome-sink-content",
				style = "inside_shallow_frame",
				direction = "vertical"
			}
			inner.style.horizontally_stretchable = true
			inner.style.top_margin = 4
			inner.style.bottom_margin = 4
			local table = inner.add{
				type = "table",
				name = "awesome-sink-table",
				style = "bordered_table",
				column_count = 3
			}
			local sprite = table.add{
				type = "sprite-button",
				sprite = "item/coin",
				style = "transparent_slot"
			}
			sprite.style.width = 20
			sprite.style.height = 20
			table.add{
				type = "label",
				caption = {"item-name.coin"},
				style = "bold_label"
			}
			local count_flow = table.add{
				type = "flow",
				name = "awesome-sink-count-flow1"
			}
			local pusher = count_flow.add{type="empty-widget"}
			pusher.style.horizontally_stretchable = true
			count_flow.add{
				type = "label",
				name = "awesome-sink-count",
				caption = util.format_number(
					global['awesome-coupons'] and global['awesome-coupons'][player.force.index] and global['awesome-coupons'][player.force.index][2] or 0
				)
			}
			table.add{type="empty-widget"}
			table.add{
				type = "label",
				caption = {"gui.awesome-sink-to-next"}
			}
			count_flow = table.add{
				type = "flow",
				name = "awesome-sink-count-flow2"
			}
			pusher = count_flow.add{type="empty-widget"}
			pusher.style.horizontally_stretchable = true
			count_flow.add{
				type = "label",
				name = "awesome-sink-to-next",
				caption = util.format_number(
					pointsToNext(global['awesome-coupons'] and global['awesome-coupons'][player.force.index] and global['awesome-coupons'][player.force.index][1] or 0)
					-(global['awesome-coupons'] and global['awesome-coupons'][player.force.index] and global['awesome-coupons'][player.force.index][3] or 0)
				)
			}
			local bottom = frame.add{
				type = "flow",
				name = "awesome-sink-bottom"
			}
			local pusher = bottom.add{type="empty-widget"}
			pusher.style.horizontally_stretchable = true
			bottom.add{
				type = "button",
				style = "confirm_button",
				name = "awesome-sink-print",
				caption = {"gui.awesome-sink-print"}
			}
		end
	end
end
local function onGuiClick(event)
	if event.element.valid and event.element.name == "awesome-sink-print" then
		local player = game.players[event.player_index]
		local inventory = player.get_main_inventory()
		local caninsert = inventory.get_insertable_count("coin")
		local print = global['awesome-coupons'] and global['awesome-coupons'][player.force.index] and global['awesome-coupons'][player.force.index][2] or 0
		if print > 0 then
			if caninsert == 0 then
				print = 0
				player.print({"inventory-restriction.player-inventory-full",{"item-name.coin"},{"inventory-full-message.main"}})
			elseif print > caninsert then
				print = caninsert
				player.print({"message.received-awesome-coupons-more",print})
			else
				player.print({"message.received-awesome-coupons",print})
			end
			if print > 0 then
				inventory.insert{name="coin",count=print}
			end
			global['awesome-coupons'][player.force.index][2] = global['awesome-coupons'][player.force.index][2] - print
		end
	end
end
local function onGuiClosed(event)
	if event.gui_type == defines.gui_type.entity and event.entity.valid and event.entity.name == storage then
		local player = game.players[event.player_index]
		local gui = player.gui.left['awesome-sink-gui']
		if gui then gui.destroy() end
	end
end

local function onTick(event)
	if not global['awesome-sinks'] then return end
	local modulo = event.tick % 4 -- the fastest belt carries a max of 1 item every 4.5 ticks, so this should easily keep up with that
	for i,sink in ipairs(global['awesome-sinks']) do
		if i%4 == modulo and sink.energy >= 30*1000*1000 then
			-- entity can charge at 40MW and store 30MW, with a drain of 30MW, so it'll take a few seconds to power up, which is fine
			local store = sink.surface.find_entity(storage, sink.position)
			local inventory = store.get_inventory(defines.inventory.chest)
			local content = inventory[1].valid_for_read and inventory[1] or nil
			if content then
				-- check if item is in the pay table
				if paytable[content.name] then
					gainPoints(sink.force, paytable[content.name] * content.count)
					content.clear()
				end
				-- otherwise, sink jams until player removes the offending item from the chest
				-- (so it's better than Satisfactory where you have to deconstruct the whole conveyor!)
			end
		end
	end
	if event.tick % 6 == 0 then
		-- if a player has a sink entity open, update their GUI
		for _,player in pairs(game.players) do
			if player.opened and player.opened_gui_type == defines.gui_type.entity and player.opened.valid and player.opened.name == storage then
				-- GUI can be assumed to exist
				local gui = player.gui.left['awesome-sink-gui']['awesome-sink-content']['awesome-sink-table']['awesome-sink-count-flow1']['awesome-sink-count']
				gui.caption = util.format_number(
					global['awesome-coupons'] and global['awesome-coupons'][player.force.index] and global['awesome-coupons'][player.force.index][2] or 0
				)
				gui = player.gui.left['awesome-sink-gui']['awesome-sink-content']['awesome-sink-table']['awesome-sink-count-flow2']['awesome-sink-to-next']
				gui.caption = util.format_number(
					pointsToNext(global['awesome-coupons'] and global['awesome-coupons'][player.force.index] and global['awesome-coupons'][player.force.index][1] or 0)
					-(global['awesome-coupons'] and global['awesome-coupons'][player.force.index] and global['awesome-coupons'][player.force.index][3] or 0)
				)
			end
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
		[defines.events.on_gui_closed] = onGuiClosed,
		[defines.events.on_gui_click] = onGuiClick,

		[defines.events.on_tick] = onTick
	}
}

