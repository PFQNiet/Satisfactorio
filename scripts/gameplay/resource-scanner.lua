local resource_spawner = require(modpath..'scripts.lualib.resource-spawner')
local pings = require(modpath.."scripts.lualib.pings")

---@class ResourceScannerEntryTags
---@field recipe string
---@field type string
---@field name string
---@field localised_name LocalisedString

---@class ResourceScannerNotFoundData
---@field sprite SpritePath
---@field name LocalisedString

---@class ResourceScannerQueuedEffect
---@field type "pulse"|"ping"|"unping"|"notfound"
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

---@return LuaRecipe[]
local function getAllScans()
	local recipes = {}
	for _,recipe in pairs(game.recipe_prototypes) do
		if recipe.category == "resource-scanner" then
			table.insert(recipes, recipe)
		end
	end
	table.sort(recipes, function(a,b) return a.order < b.order end)
	return recipes
end

---@param player LuaPlayer
local function openResourceScanner(player)
	local gui = player.gui.screen
	if not gui['resource-scanner'] then
		local frame = gui.add{
			type = "frame",
			name = "resource-scanner",
			direction = "vertical",
			style = "inner_frame_in_outer_frame"
		}
		local title_flow = frame.add{type = "flow", name = "title_flow"}
		local title = title_flow.add{type = "label", caption = {"gui.resource-scanner-title"}, style = "frame_title"}
		title.drag_target = frame
		local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_in_window_title"}
		pusher.drag_target = frame
		title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white", name = "resource-scanner-close"}

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
			caption = {"gui.resource-scanner-scan-for"}
		}

		local list = content.add{
			type = "table",
			name = "list",
			style = "scanner_table",
			column_count = 5
		}

		for _,recipe in pairs(getAllScans()) do
			local product = recipe.products[1]
			---@type LuaItemPrototype|LuaFluidPrototype
			local proto = game[product.type.."_prototypes"][product.name]
			local sprite = product.type.."/"..product.name
			local name = proto.localised_name

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
				name = "resource-scanner-scan",
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

	local frame = gui['resource-scanner']
	---@type LuaGuiElement
	local menu = frame.content.list
	for _,flow in pairs(menu.children) do
		---@type LuaGuiElement
		local label = flow['label']
		---@type LuaGuiElement
		local button = flow['resource-scanner-scan']
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
local function closeResourceScanner(player)
	local frame = player.gui.screen['resource-scanner']
	if frame then
		frame.visible = false
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

		---@type ResourceScannerEntryTags
		local data = event.element.parent.tags['scan']

		local types = {data.name}
		if data.name == "crude-oil" then
			types = {data.name, data.name.."-well"}
		elseif data.name == "water" or data.name == "nitrogen-gas" then
			types = {data.name.."-well"}
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
		if #closest == 0 then
			queueEffect(event.tick + 240, {
				type = "notfound",
				player = player,
				searched_for = {
					sprite = data.type.."/"..data.name,
					name = data.localised_name
				}
			})
		else
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
						sprite = data.type.."/"..data.name
					}
				})
			end
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
