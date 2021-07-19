local gui = require(modpath.."scripts.gui.resource-scanner")
local resource_spawner = require(modpath..'scripts.lualib.resource-spawner')
local pings = require(modpath.."scripts.lualib.pings")

---@class ResourceScannerNotFoundData
---@field sprite SpritePath
---@field name LocalisedString

---@class ResourceScannerQueuedEffect
---@field type '"pulse"'|'"ping"'|'"unping"'|'"notfound"
---@field player LuaPlayer
---@field surface LuaSurface
---@field target PingTarget
---@field ping uint
---@field searched_for ResourceScannerNotFoundData

--- A queue of effects
---@class global.resource_scanner
---@field fx table<uint, ResourceScannerQueuedEffect[]>
local script_data = {
	fx = {}
}

---@param tick uint
local function popEffects(tick)
	local fx = script_data.fx[tick]
	script_data.fx[tick] = nil
	return fx
end

---@param tick uint
---@param effect ResourceScannerQueuedEffect
local function queueEffect(tick, effect)
	if not script_data.fx[tick] then script_data.fx[tick] = {} end
	table.insert(script_data.fx[tick], effect)
end

---@param player LuaPlayer
---@param scan ResourceScannerEntryTags
gui.callbacks.scan = function(player, scan)
	local types = {scan.name}
	if scan.name == "crude-oil" then
		types = {scan.name, scan.name.."-well"}
	elseif scan.name == "water" or scan.name == "nitrogen-gas" then
		types = {scan.name.."-well"}
	end

	local nodes = {}
	local playerpos = player.position
	for _,name in pairs(types) do
		for _,node in pairs(resource_spawner.getNodes(name, player.surface, playerpos)) do
			table.insert(nodes, node)
		end
	end

	-- sort nodes according to distance from player (note there's at most 25 nodes so this should be quite fast!)
	table.sort(nodes, function(a,b)
		local adx = playerpos.x-a[1]
		local ady = playerpos.y-a[2]
		local bdx = playerpos.x-b[1]
		local bdy = playerpos.y-b[2]
		local adist = adx*adx+ady*ady
		local bdist = bdx*bdx+bdy*bdy
		if adist == bdist then -- how???
			if a[1] == b[1] then -- same X position too??
				return a[2] < b[2] -- Y positon can only be the same if it's the same, so...
			else
				return a[1] < b[1]
			end
		else
			return adist < bdist
		end
	end)
	-- get nearest 3
	local closest = {table.unpack(nodes, 1, math.min(3,#nodes))}

	queueEffect(game.tick + 30, {
		type = "pulse",
		player = player,
		surface = player.surface
	})
	if #closest == 0 then
		queueEffect(game.tick + 240, {
			type = "notfound",
			player = player,
			searched_for = {
				sprite = scan.sprite,
				name = scan.localised_name
			}
		})
	else
		for _,pos in pairs(closest) do
			local dx = pos[1] - playerpos.x
			local dy = pos[2] - playerpos.y
			local distance = math.sqrt(dx*dx+dy*dy)
			local delay = math.floor(distance/2+1)
			queueEffect(game.tick + delay + 30, {
				type = "ping",
				player = player,
				surface = player.surface,
				target = {
					surface = player.surface,
					position = {x=pos[1], y=pos[2]},
					sprite = scan.sprite
				}
			})
		end
	end
end

---@param event on_tick
local function onTick(event)
	local fx = popEffects(event.tick)
	if fx then
		for _,effect in pairs(fx) do
			if effect.type == "notfound" then
				effect.player.print{"message.resource-not-found", effect.searched_for.sprite, effect.searched_for.name}
			elseif effect.surface ~= effect.player.surface then
				-- skip this effect
			elseif effect.type == "pulse" then
				effect.player.surface.create_trivial_smoke{
					name = "resource-scanner-pulse",
					position = effect.player.position
				}
			elseif effect.type == "ping" then
				local ping = pings.addPing(effect.player, effect.target)
				-- queue deleting the ping in 20 seconds
				local ttl = 20*60
				queueEffect(event.tick + ttl, {
					type = "unping",
					player = effect.player,
					surface = effect.surface,
					target = effect.target,
					ping = ping
				})
			elseif effect.type == "unping" then
				pings.deletePing(effect.ping)
			end
		end
	end
end

return {
	on_init = function()
		global.resource_scanner = global.resource_scanner or script_data
	end,
	on_load = function()
		script_data = global.resource_scanner or script_data
	end,

	events = {
		["resource-scanner"] = function(event)
			gui.toggle_gui(game.players[event.player_index])
		end,
		[defines.events.on_lua_shortcut] = function(event)
			if event.prototype_name == "resource-scanner" then
				gui.toggle_gui(game.players[event.player_index])
			end
		end,
		[defines.events.on_tick] = onTick
	}
}
