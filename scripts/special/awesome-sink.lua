-- sink is an EEI, which must spawn a chest (and input)
-- chest has a single slot and is frequently checked for contents - if found they are voided and points are awarded
-- points earned according to data in constants.sink-tradein
-- n = tickets earned so far, next ticket earned at 500*floor(n/3)^2+1000 points
-- uses global.awesome.sinks'] to track sinks to iterate through
-- uses global.awesome.coupons'] to track force => {earned, printed, points}

local script_data = {
	sinks = {},
	coupons = {}
}

local function pointsToNext(earned)
	return 500 * math.floor(earned / 3)^2 + 1000
end
local function gainPoints(force, points)
	if not script_data.coupons[force.index] then script_data.coupons[force.index] = {0,0,0} end
	local entry = script_data.coupons[force.index]
	entry[3] = entry[3] + points
	force.item_production_statistics.on_flow("awesome-points",points)
	local tonext = pointsToNext(entry[1])
	while entry[3] > tonext do
		entry[1] = entry[1] + 1
		entry[2] = entry[2] + 1
		entry[3] = entry[3] - tonext
		tonext = pointsToNext(entry[1])
	end
end

local io = require(modpath.."scripts.lualib.input-output")
local paytable = require(modpath.."constants.sink-tradein")

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
		io.addInput(entity, {-0.5,3}, store)
		entity.rotatable = false
		script_data.sinks[entity.unit_number] = entity
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == base or entity.name == storage then
		-- find components
		local floor = entity.name == base and entity or entity.surface.find_entity(base, entity.position)
		local store = entity.name == storage and entity or entity.surface.find_entity(storage, entity.position)
		io.remove(floor, event)
		script_data.sinks[floor.unit_number] = nil
		(entity == floor and store or floor).destroy()
	end
end

local function on4thTick()
	for i,sink in pairs(script_data.sinks) do
		-- the fastest belt carries a max of 1 item every 4.5 ticks, so this should easily keep up with that
		if sink.energy > 0 then
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
end
local function on60thTick()
	-- if a player has a sink entity open, update their GUI
	for _,player in pairs(game.players) do
		if player.opened and player.opened_gui_type == defines.gui_type.entity and player.opened.valid and player.opened.name == storage then
			-- GUI can be assumed to exist
			local gui = player.gui.relative['awesome-sink'].content
			local table = gui.table
			local coupons = script_data.coupons[player.force.index] or {0,0,0}
			table.tickets.count.caption = util.format_number(coupons[2])
			table.tonext.count.caption = util.format_number(pointsToNext(coupons[1]) - coupons[3])
			gui.bottom['awesome-sink-print'].enabled = coupons[2] > 0
		end
	end
end

local function onGuiOpened(event)
	local player = game.players[event.player_index]
	if event.gui_type == defines.gui_type.entity and event.entity.valid and event.entity.name == base then
		player.opened = event.entity.surface.find_entity(storage, event.entity.position)
	end
	if event.gui_type == defines.gui_type.entity and event.entity.valid and event.entity.name == storage then
		local floor = event.entity.surface.find_entity(base, event.entity.position)
		-- create additional GUI for switching input/output mode
		local gui = player.gui.relative
		if not gui['awesome-sink'] then
			local force_idx = player.force.index
			local frame = gui.add{
				type = "frame",
				name = "awesome-sink",
				anchor = {
					gui = defines.relative_gui_type.container_gui,
					position = defines.relative_gui_position.right,
					name = "awesome-sink-box"
				},
				direction = "vertical",
				caption = {"gui.awesome-sink-gui-title"},
				style = "inset_frame_container_frame"
			}
			frame.style.horizontally_stretchable = false
			local inner = frame.add{
				type = "frame",
				name = "content",
				style = "inside_shallow_frame_with_padding",
				direction = "vertical"
			}
			inner.style.horizontally_stretchable = true
			local table = inner.add{
				type = "table",
				name = "table",
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
				name = "tickets"
			}
			local pusher = count_flow.add{type="empty-widget"}
			pusher.style.horizontally_stretchable = true
			count_flow.add{
				type = "label",
				name = "count",
				caption = util.format_number(
					script_data.coupons[force_idx] and script_data.coupons[force_idx][2] or 0
				)
			}
			table.add{type="empty-widget"}
			table.add{
				type = "label",
				caption = {"gui.awesome-sink-to-next"}
			}
			count_flow = table.add{
				type = "flow",
				name = "tonext"
			}
			count_flow.style.minimal_width = 80
			pusher = count_flow.add{type="empty-widget"}
			pusher.style.horizontally_stretchable = true
			count_flow.add{
				type = "label",
				name = "count",
				caption = util.format_number(
					pointsToNext(script_data.coupons[force_idx] and script_data.coupons[force_idx][1] or 0)
					-(script_data.coupons[force_idx] and script_data.coupons[force_idx][3] or 0)
				)
			}
			local bottom = inner.add{
				type = "flow",
				name = "bottom"
			}
			bottom.style.top_margin = 12
			bottom.style.bottom_margin = 12
			bottom.add{type="empty-widget"}.style.horizontally_stretchable = true
			local button = bottom.add{
				type = "button",
				style = "confirm_button",
				name = "awesome-sink-print",
				caption = {"gui.awesome-sink-print"}
			}
			button.enabled = false
			inner.add{
				type = "empty-widget",
				style = "vertical_lines_slots_filler"
			}
		end
	end
end
local function onGuiClick(event)
	if event.element.valid and event.element.name == "awesome-sink-print" then
		local player = game.players[event.player_index]
		local force_idx = player.force.index
		local inventory = player.get_main_inventory()
		local caninsert = inventory.get_insertable_count("coin")
		local print = script_data.coupons[force_idx] and script_data.coupons[force_idx][2] or 0
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
			script_data.coupons[force_idx][2] = script_data.coupons[force_idx][2] - print
			on60thTick()
		end
	end
end
local function onGuiClosed(event)
	if event.gui_type == defines.gui_type.entity and event.entity.valid and event.entity.name == storage then
		local player = game.players[event.player_index]
		local gui = player.gui.relative['awesome-sink-gui']
		if gui then gui.destroy() end
	end
end

return {
	on_init = function()
		global.awesome = global.awesome or script_data
	end,
	on_load = function()
		script_data = global.awesome or script_data
	end,
	on_nth_tick = {
		[4] = on4thTick,
		[60] = on60thTick
	},
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
		[defines.events.on_gui_click] = onGuiClick
	}
}

