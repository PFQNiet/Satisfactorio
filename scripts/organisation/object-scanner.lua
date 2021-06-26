local pings = require(modpath.."scripts.lualib.pings")

local scanner = "object-scanner"

---@class ObjectScan
---@field type string
---@field target LuaEntity|PingTarget
---@field ping uint64 Ping ID

---@class global.object_scanner
---@field cached_beacon_order table<uint64, LuaEntity[]> Player index => beacons in GUI list
---@field scans table<uint64, ObjectScan> Player index => scan data
local script_data = {
	cached_beacon_order = {},
	scans = {}
}

---@param player LuaPlayer
local function updateScan(player)
	local scan = script_data.scans[player.index]
	if not scan then return end
	-- ensure player is still holding Object Scanner
	if not (player.cursor_stack.valid_for_read and player.cursor_stack.name == scanner) then
		pings.deletePing(scan.ping)
		return
	end

	local search_for = scan.type
	local candidates = {}
	if search_for == "map-marker" then
		-- updating the entity is handled by the additional GUI
	elseif search_for == "enemies" then
		candidates = player.surface.find_enemy_units(player.position, 250, player.force)
	else
		local names = {search_for}
		if search_for == "green-power-slug" then
			names = {"green-power-slug", "yellow-power-slug", "purple-power-slug"}
		elseif search_for == "crash-site" then
			names = {"crash-site-spaceship"}
		end
		candidates = player.surface.find_entities_filtered{
			name = names,
			position = player.position,
			radius = 250
		}
	end

	if #candidates > 0 then
		scan.target = player.surface.get_closest(player.position, candidates)
	end
	if not scan.target then
		pings.deletePing(scan.ping)
	elseif pings.isValid(scan.ping) then
		pings.updatePingTarget(scan.ping, scan.target)
	else
		scan.ping = pings.addPing(player, scan.target)
	end
end

---@param force LuaForce
---@return LuaRecipe[]
local function getUnlockedScans(force)
	local recipes = {}
	for _,recipe in pairs(force.recipes) do
		if recipe.category == "object-scanner" and recipe.enabled then
			table.insert(recipes, recipe)
		end
	end
	table.sort(recipes, function(a,b) return (a.order or a.name) < (b.order or b.name) end)
	return recipes
end

---@param player LuaPlayer
local function openObjectScanner(player)
	if not player.gui.screen['object-scanner'] then
		local gui = player.gui.screen.add{
			type = "frame",
			name = "object-scanner",
			direction = "vertical",
			style = "inner_frame_in_outer_frame"
		}
		local title_flow = gui.add{type = "flow", name = "title_flow"}
		local title = title_flow.add{type = "label", caption = {"gui.object-scanner-title"}, style = "frame_title"}
		title.drag_target = gui
		local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_header"}
		pusher.style.height = 24
		pusher.style.horizontally_stretchable = true
		pusher.drag_target = gui
		title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white", name = "object-scanner-close"}

		gui.add{
			type = "label",
			caption = {"","[font=heading-2]",{"gui.object-scanner-scan-for"},"[/font]"}
		}

		local menu = gui.add{
			type = "list-box",
			name = "object-scanner-item"
		}
		menu.style.top_margin = 4
		menu.style.bottom_margin = 4

		local flow = gui.add{
			type = "flow",
			direction = "horizontal"
		}
		pusher = flow.add{type = "empty-widget"}
		pusher.style.horizontally_stretchable = true
		flow.add{
			type = "button",
			style = "confirm_button",
			name = "object-scanner-select",
			caption = {"gui.object-scanner-select"}
		}
	end

	local gui = player.gui.screen['object-scanner']
	local menu = gui['object-scanner-item']
	-- record last selected menu item before refreshing the list
	local index = menu.selected_index or 0
	if index == 0 then index = 1 end
	menu.clear_items()
	for _,recipe in pairs(getUnlockedScans(player.force)) do
		local product = recipe.products[1]
		local scan_for = game[product.type.."_prototypes"][product.name].localised_name
		if product.name == "green-power-slug" then scan_for = {"gui.object-scanner-power-slugs"} end
		menu.add_item({"","[img="..product.type.."."..product.name.."] ",scan_for})
	end

	if #menu.items == 0 then
		player.opened = nil
		player.print({"message.object-scanner-no-scans-unlocked"})
	else
		menu.selected_index = index

		gui.visible = true
		player.opened = gui
		gui.force_auto_center()
	end
end

---@param player LuaPlayer
local function closeObjectScanner(player)
	local gui = player.gui.screen['object-scanner']
	if gui then gui.visible = false end
	if player.opened_gui_type == defines.gui_type.custom and player.opened.name == "object-scanner" then
		player.opened = nil
	end
end

---@param beacon LuaEntity
---@return LuaCustomChartTag
local function findBeaconTag(beacon)
	local pos = beacon.position
	return beacon.force.find_chart_tags(beacon.surface, {{pos.x-0.1,pos.y-0.1},{pos.x+0.1,pos.y+0.1}})[1]
end

---@param player LuaPlayer
local function openBeaconScanner(player)
	local screen = player.gui.screen
	if not screen['beacon-scanner'] then
		local gui = player.gui.screen.add{
			type = "frame",
			name = "beacon-scanner",
			direction = "vertical",
			style = "inner_frame_in_outer_frame"
		}
		local title_flow = gui.add{type = "flow", name = "title_flow"}
		local title = title_flow.add{type = "label", caption = {"gui.beacon-scanner-title"}, style = "frame_title"}
		title.drag_target = gui
		local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_header"}
		pusher.style.height = 24
		pusher.style.horizontally_stretchable = true
		pusher.drag_target = gui
		title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white", name = "beacon-scanner-close"}

		gui.add{
			type = "label",
			caption = {"","[font=heading-2]",{"gui.beacon-scanner-scan-for"},"[/font]"}
		}

		local menu = gui.add{
			type = "list-box",
			name = "beacon-scanner-item"
		}
		menu.style.top_margin = 4
		menu.style.bottom_margin = 4
		menu.style.height = 200

		local flow = gui.add{
			type = "flow",
			direction = "horizontal"
		}
		pusher = flow.add{type = "empty-widget"}
		pusher.style.horizontally_stretchable = true
		flow.add{
			type = "button",
			style = "confirm_button",
			name = "beacon-scanner-select",
			caption = {"gui.beacon-scanner-select"}
		}
	end

	local gui = screen['beacon-scanner']
	local menu = gui['beacon-scanner-item']
	-- record last selected menu item before refreshing the list
	local index = menu.selected_index or 0
	if index == 0 then index = 1 end
	menu.clear_items()
	local entities = player.surface.find_entities_filtered{name="map-marker",force=player.force}
	local tags = {}
	for _,beacon in pairs(entities) do
		tags[beacon.unit_number] = findBeaconTag(beacon)
	end
	-- sort beacons alphabetically... to help :D
	table.sort(entities, function(a,b)
		if tags[a.unit_number].text ~= tags[b.unit_number].text then
			return tags[a.unit_number].text < tags[b.unit_number].text
		elseif tags[a.unit_number].icon.type ~= tags[b.unit_number].icon.type then
			return tags[a.unit_number].icon.type < tags[b.unit_number].icon.type
		elseif tags[a.unit_number].icon.name ~= tags[b.unit_number].icon.name then
			return tags[a.unit_number].icon.name < tags[b.unit_number].icon.name
		else
			return a.unit_number < b.unit_number
		end
	end)

	local beacon_cache = {}
	for _,beacon in pairs(entities) do
		local tag = tags[beacon.unit_number]
		local type = tag.icon.type
		if type == "virtual" then type = "virtual-signal" end
		menu.add_item({"","[img="..type.."."..tag.icon.name.."] ",tag.text == "" and {"entity-name.map-marker"} or tag.text})
		table.insert(beacon_cache, beacon)
	end
	script_data.cached_beacon_order[player.index] = beacon_cache

	if #menu.items == 0 then
		gui.visible = false
		openObjectScanner(player)
		player.print({"message.beacon-scanner-no-beacons-placed"})
	else
		menu.selected_index = index

		gui.visible = true
		player.opened = gui
		gui.force_auto_center()
	end
end

---@param player LuaPlayer
local function closeBeaconScanner(player)
	local gui = player.gui.screen['beacon-scanner']
	if gui then gui.visible = false end
	if player.opened_gui_type == defines.gui_type.custom and player.opened.name == "beacon-scanner" then
		player.opened = nil
	end
end

---@param player LuaPlayer
local function putObjectScannerInCursor(player)
	if player.cursor_stack.valid_for_read then
		-- player is already holding something
		return
	end
	local stack, index = player.get_main_inventory().find_item_stack(scanner)
	if stack then
		player.cursor_stack.swap_stack(stack)
		player.hand_location = {
			inventory = player.character and defines.inventory.character_main or defines.inventory.god_main,
			slot = index
		}
	end
end

local function onGuiClick(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	if event.element.name == "object-scanner-close" then
		closeObjectScanner(player)
	elseif event.element.name == "object-scanner-select" then
		closeObjectScanner(player)
		local index = player.gui.screen['object-scanner']['object-scanner-item'].selected_index
		if not index or index == 0 then
			return
		end
		local type = getUnlockedScans(player.force)[index].products[1].name

		script_data.scans[player.index] = {
			type = type,
			target = nil,
			ping = nil
		}

		if type == "map-marker" then
			openBeaconScanner(player)
		else
			putObjectScannerInCursor(player)
			updateScan(player)
		end
	elseif event.element.name == "beacon-scanner-close" then
		closeBeaconScanner(player)
	elseif event.element.name == "beacon-scanner-select" then
		closeBeaconScanner(player)
		local index = player.gui.screen['beacon-scanner']['beacon-scanner-item'].selected_index
		if not index or index == 0 then
			return
		end

		local beacon = script_data.cached_beacon_order[player.index][index]
		script_data.cached_beacon_order[player.index] = nil
		if not (beacon and beacon.valid) then
			return
		end
		local tag = findBeaconTag(beacon)
		script_data.scans[player.index] = {
			type = "map-marker",
			target = {
				surface = beacon.surface,
				position = beacon.position,
				sprite = (tag.icon.type == "virtual" and "virtual-signal" or tag.icon.type).."/"..tag.icon.name
			},
			ping = nil
		}
		putObjectScannerInCursor(player)
		updateScan(player)
	end
end

local function on60thTick()
	for _,player in pairs(game.players) do
		updateScan(player)
	end
end

return {
	on_init = function()
		global.object_scanner = global.object_scanner or script_data
	end,
	on_load = function()
		script_data = global.object_scanner or script_data
	end,
	on_nth_tick = {
		[60] = on60thTick
	},
	events = {
		[defines.events.on_mod_item_opened] = function(event)
			local player = game.players[event.player_index]
			if event.item.name == scanner then
				openObjectScanner(player)
			end
		end,
		[defines.events.on_gui_click] = onGuiClick,
		[defines.events.on_gui_closed] = function(event)
			if event.element and event.element.valid then
				if event.element.name == "object-scanner" then
					closeObjectScanner(game.players[event.player_index])
				elseif event.element.name == "beacon-scanner" then
					closeBeaconScanner(game.players[event.player_index])
				end
			end
		end
	}
}
