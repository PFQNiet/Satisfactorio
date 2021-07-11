local pings = require(modpath.."scripts.lualib.pings")

local scanner = "object-scanner"

---@class ObjectScannerEntryTags
---@field recipe string
---@field type string
---@field name string
---@field localised_name LocalisedString

---@class BeaconScannerEntryTags
---@field icon SpritePath
---@field name LocalisedString
---@field position Position

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

---@return LuaRecipe[]
local function getAllScans()
	local recipes = {}
	for _,recipe in pairs(game.recipe_prototypes) do
		if recipe.category == "object-scanner" then
			table.insert(recipes, recipe)
		end
	end
	table.sort(recipes, function(a,b) return a.order < b.order end)
	return recipes
end

---@param player LuaPlayer
local function openObjectScanner(player)
	local gui = player.gui.screen
	if not gui['object-scanner'] then
		local frame = gui.add{
			type = "frame",
			name = "object-scanner",
			direction = "vertical",
			style = "inner_frame_in_outer_frame"
		}
		local title_flow = frame.add{type = "flow", name = "title_flow"}
		local title = title_flow.add{type = "label", caption = {"gui.object-scanner-title"}, style = "frame_title"}
		title.drag_target = frame
		local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_in_window_title"}
		pusher.drag_target = frame
		title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white", name = "object-scanner-close"}

		local content = frame.add{
			type = "frame",
			name = "content",
			style = "inside_shallow_frame_with_padding_and_spacing",
			direction = "vertical"
		}
		local head = content.add{
			type = "frame",
			style = "full_subheader_frame_in_padded_frame"
		}
		head.add{
			type = "label",
			style = "heading_2_label",
			caption = {"gui.object-scanner-scan-for"}
		}

		local list = content.add{
			type = "table",
			name = "list",
			style = "scanner_table",
			column_count = 4
		}

		for _,recipe in pairs(getAllScans()) do
			local product = recipe.products[1]
			---@type LuaItemPrototype|LuaFluidPrototype
			local proto = game[product.type.."_prototypes"][product.name]
			local sprite = product.type.."/"..product.name
			local name = proto.localised_name
			if product.name == "green-power-slug" then name = {"gui.object-scanner-power-slugs"} end

			local flow = list.add{
				type = "flow",
				direction = "vertical",
				style = "scanner_flow",
				tags = {
					scan = {
						recipe = recipe.name,
						type = product.type,
						name = product.name,
						localised_name = name
					}
				}
			}

			flow.add{
				type = "sprite-button",
				name = "object-scanner-select",
				sprite = sprite,
				style = "scanner_button"
			}

			flow.add{
				type = "label",
				name = "label",
				caption = name
			}
		end
	end

	local frame = gui['object-scanner']
	---@type LuaGuiElement
	local menu = frame.content.list
	for _,flow in pairs(menu.children) do
		---@type LuaGuiElement
		local label = flow['label']
		---@type LuaGuiElement
		local button = flow['object-scanner-select']
		---@type ResourceScannerEntryTags
		local data = flow.tags['scan']
		local recipe = player.force.recipes[data.recipe]

		if recipe.enabled then
			label.caption = data.localised_name
			button.sprite = data.type.."/"..data.name
			button.enabled = true
		else
			label.caption = {"gui.resource-scanner-unknown"}
			button.sprite = "item/item-unknown"
			button.enabled = false
		end
	end

	frame.visible = true
	player.opened = frame
	frame.force_auto_center()
end

---@param player LuaPlayer
local function closeObjectScanner(player)
	local frame = player.gui.screen['object-scanner']
	if frame then
		frame.visible = false
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
	local gui = player.gui.screen
	if not gui['beacon-scanner'] then
		local frame = player.gui.screen.add{
			type = "frame",
			name = "beacon-scanner",
			direction = "vertical",
			style = "inner_frame_in_outer_frame"
		}
		local title_flow = frame.add{type = "flow", name = "title_flow"}
		local title = title_flow.add{type = "label", caption = {"gui.beacon-scanner-title"}, style = "frame_title"}
		title.drag_target = frame
		local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_in_window_title"}
		pusher.drag_target = frame
		title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white", name = "beacon-scanner-close"}

		local content = frame.add{
			type = "frame",
			name = "content",
			style = "inside_shallow_frame",
			direction = "vertical"
		}
		local head = content.add{
			type = "frame",
			style = "full_subheader_frame"
		}
		head.add{
			type = "label",
			style = "heading_2_label",
			caption = {"gui.beacon-scanner-scan-for"}
		}

		local body = content.add{
			type = "scroll-pane",
			name = "body",
			style = "scanner_scroll_pane"
		}

		local list = body.add{
			type = "table",
			name = "list",
			style = "scanner_table",
			column_count = 6
		}
	end

	local frame = gui['beacon-scanner']
	---@type LuaGuiElement
	local menu = frame.content.body.list
	menu.clear()
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

	local use_minimap = player.minimap_enabled
	for _,beacon in pairs(entities) do
		local tag = tags[beacon.unit_number]
		local type = tag.icon.type
		if type == "virtual" then type = "virtual-signal" end
		local icon = type.."/"..tag.icon.name
		local name = tag.text == "" and {"entity-name.map-marker"} or tag.text

		local flow = menu.add{
			type = "flow",
			direction = "vertical",
			style = "scanner_flow",
			tags = {
				scan = {
					icon = icon,
					name = name,
					position = beacon.position
				}
			}
		}

		if use_minimap then
			local mapframe = flow.add{
				type = "frame",
				style = "deep_frame_in_shallow_frame"
			}
			local map = mapframe.add{
				type = "minimap",
				name = "beacon-scanner-select",
				style = "scanner_minimap",
				position = beacon.position,
				surface_index = beacon.surface.index
			}
		else
			flow.add{
				type = "sprite-button",
				name = "beacon-scanner-select",
				sprite = icon,
				style = "scanner_button"
			}
		end

		flow.add{
			type = "label",
			name = "label",
			caption = {"", "[img="..icon.."] ", name}
		}
	end

	if #entities == 0 then
		frame.visible = false
		openObjectScanner(player)
		player.print{"message.beacon-scanner-no-beacons-placed"}
	else
		frame.visible = true
		player.opened = frame
		frame.force_auto_center()
	end
end

---@param player LuaPlayer
local function closeBeaconScanner(player)
	local gui = player.gui.screen['beacon-scanner']
	if gui then
		gui.visible = false
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

---@param event on_gui_click
local function onGuiClick(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	if event.element.name == "object-scanner-close" then
		player.opened = nil
	elseif event.element.name == "object-scanner-select" then
		player.opened = nil

		---@type ObjectScannerEntryTags
		local data = event.element.parent.tags['scan']
		local scan = data.name

		script_data.scans[player.index] = {
			type = scan,
			target = nil,
			ping = nil
		}

		if scan == "map-marker" then
			openBeaconScanner(player)
		else
			putObjectScannerInCursor(player)
			updateScan(player)
		end
	elseif event.element.name == "beacon-scanner-close" then
		player.opened = nil
	elseif event.element.name == "beacon-scanner-select" then
		player.opened = nil

		local parent = event.element.parent
		if event.element.type == "minimap" then parent = parent.parent end
		---@type BeaconScannerEntryTags
		local data = parent.tags['scan']
		local beacon = player.surface.find_entity("map-marker", data.position)
		if not beacon then return end

		local tag = findBeaconTag(beacon)
		script_data.scans[player.index] = {
			type = "map-marker",
			target = {
				surface = beacon.surface,
				position = beacon.position,
				sprite = data.icon
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
