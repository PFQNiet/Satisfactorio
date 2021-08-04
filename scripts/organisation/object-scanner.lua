local gui = {
	object = require(modpath.."scripts.gui.object-scanner"),
	beacon = require(modpath.."scripts.gui.beacon-scanner")
}
local pings = require(modpath.."scripts.lualib.pings")

local scanner = "object-scanner"

---@class ObjectScannerEntryTags
---@field recipe string
---@field type string
---@field name string
---@field localised_name LocalisedString
---@field sprite SpritePath

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

---@param player LuaPlayer
local function putObjectScannerInCursor(player)
	if not player.is_cursor_empty() then
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

---@param player LuaPlayer
---@param tags ObjectScannerEntryTags
gui.object.callbacks.scan = function(player, tags)
	script_data.scans[player.index] = {
		type = tags.name,
		target = nil,
		ping = nil
	}
	if tags.name == "map-marker" then
		if not gui.beacon.open_gui(player) then
			gui.object.open_gui(player)
			player.print{"message.beacon-scanner-no-beacons-placed"}
		end
	else
		putObjectScannerInCursor(player)
		updateScan(player)
	end
end

---@param player LuaPlayer
---@param tags BeaconScannerEntryTags
gui.beacon.callbacks.scan = function(player, tags)
	local beacon = player.surface.find_entity("map-marker", tags.position)
	if not beacon then return end
	script_data.scans[player.index] = {
		type = "map-marker",
		target = {
			surface = beacon.surface,
			position = beacon.position,
			sprite = tags.icon
		},
		ping = nil
	}
	putObjectScannerInCursor(player)
	updateScan(player)
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
				gui.object.open_gui(player)
			end
		end
	}
}
