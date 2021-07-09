local resource_spawner = require(modpath..'scripts.lualib.resource-spawner')
local pings = require(modpath.."scripts.lualib.pings")

---@class ResourceScannerQueuedEffect
---@field type "pulse"|"ping"|"unping"
---@field player LuaPlayer
---@field surface LuaSurface
---@field target PingTarget
---@field ping uint

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

---@param force LuaForce
---@return LuaRecipe[]
local function getUnlockedScans(force)
	local recipes = {}
	for _,recipe in pairs(force.recipes) do
		if recipe.category == "resource-scanner" and recipe.enabled then
			table.insert(recipes, recipe)
		end
	end
	table.sort(recipes, function(a,b) return (a.order or a.name) < (b.order or b.name) end)
	return recipes
end

---@param player LuaPlayer
local function openResourceScanner(player)
	local screen = player.gui.screen
	if not screen['resource-scanner'] then
		local gui = screen.add{
			type = "frame",
			name = "resource-scanner",
			direction = "vertical",
			style = "inner_frame_in_outer_frame"
		}
		local title_flow = gui.add{type = "flow", name = "title_flow"}
		local title = title_flow.add{type = "label", caption = {"gui.resource-scanner-title"}, style = "frame_title"}
		title.drag_target = gui
		local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_header"}
		pusher.style.height = 24
		pusher.style.horizontally_stretchable = true
		pusher.drag_target = gui
		title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white", name = "resource-scanner-close"}

		gui.add{
			type = "label",
			caption = {"","[font=heading-2]",{"gui.resource-scanner-scan-for"},"[/font]"}
		}

		local menu = gui.add{
			type = "list-box",
			name = "resource-scanner-item"
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
			name = "resource-scanner-scan",
			caption = {"gui.resource-scanner-scan"}
		}
	end

	local gui = screen['resource-scanner']
	local menu = gui['resource-scanner-item']
	-- record last selected menu item before refreshing the list
	local index = menu.selected_index or 0
	if index == 0 then index = 1 end
	menu.clear_items()
	for _,recipe in pairs(getUnlockedScans(player.force)) do
		local product = recipe.products[1]
		menu.add_item({"","[img="..product.type.."."..product.name.."] ",game[product.type.."_prototypes"][product.name].localised_name})
	end
	menu.selected_index = index

	gui.visible = true
	player.opened = gui
	gui.force_auto_center()
end

---@param player LuaPlayer
local function closeResourceScanner(player)
	local gui = player.gui.screen['resource-scanner']
	if gui then
		gui.visible = false
	end
end

---@param event on_lua_shortcut
local function toggleResourceScanner(event)
	local player = game.players[event.player_index]
	if event.name == defines.events.on_lua_shortcut and event.prototype_name ~= "resource-scanner" then
		return
	end
	if player.opened_gui_type == defines.gui_type.custom and player.opened.name == "resource-scanner" then
		player.opened = nil
	else
		openResourceScanner(player)
	end
end

---@param event on_gui_click
local function onGuiClick(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	if event.element.name == "resource-scanner-close" then
		player.opened = nil
	end
	if event.element.name == "resource-scanner-scan" then
		player.opened = nil
		local index = player.gui.screen['resource-scanner']['resource-scanner-item'].selected_index
		if not index then
			return
		end

		local selected = getUnlockedScans(player.force)[index].products[1].name
		local types = {selected}
		if selected == "crude-oil" then
			types = {selected, selected.."-well"}
		elseif selected == "water" or selected == "nitrogen-gas" then
			types = {selected.."-well"}
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

		queueEffect(event.tick + 30, {
			type = "pulse",
			player = player,
			surface = player.surface
		})
		for _,pos in pairs(closest) do
			local dx = pos[1] - playerpos.x
			local dy = pos[2] - playerpos.y
			local distance = math.sqrt(dx*dx+dy*dy)
			local delay = math.floor(distance/2+1)
			queueEffect(event.tick + delay + 30, {
				type = "ping",
				player = player,
				surface = player.surface,
				target = {
					surface = player.surface,
					position = {x=pos[1], y=pos[2]},
					sprite = (game.fluid_prototypes[selected] and "fluid" or "item").."/"..selected
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
			if effect.surface ~= effect.player.surface then
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
		["resource-scanner"] = toggleResourceScanner,
		[defines.events.on_lua_shortcut] = toggleResourceScanner,
		[defines.events.on_tick] = onTick,
		[defines.events.on_gui_click] = onGuiClick,
		---@param event on_gui_closed
		[defines.events.on_gui_closed] = function(event)
			if event.element and event.element.valid and event.element.name == "resource-scanner" then
				closeResourceScanner(game.players[event.player_index])
			end
		end
	}
}
