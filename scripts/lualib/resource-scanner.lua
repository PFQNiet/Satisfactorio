-- uses global.resource_scanner.fx as a queue of effects
-- uses global.resource_scanner.pings as table of player => {pos, graphics}[] for active pings
local util = require("util")
local table_size = table_size
local script_data = {
	fx = {},
	pings = {}
}
local resources = require('scripts.lualib.resources')

local function queueEffect(tick, effect)
	if not script_data.fx[tick] then script_data.fx[tick] = {} end
	table.insert(script_data.fx[tick], effect)
end

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
local function openResourceScanner(player)
	local gui = player.gui.screen['resource-scanner']
	local menu
	if not gui then
		gui = player.gui.screen.add{
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
		menu = gui.add{
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
	else
		menu = gui['resource-scanner-item']
	end
	local index = menu.selected_index or 0
	if index == 0 then index = 1 end
	menu.clear_items()
	for _,recipe in ipairs(getUnlockedScans(player.force)) do
		local product = recipe.products[1]
		menu.add_item({"","[img="..product.type.."."..product.name.."] ",game[product.type.."_prototypes"][product.name].localised_name})
	end
	menu.selected_index = index

	gui.visible = true
	player.opened = gui
	gui.force_auto_center()
end
local function closeResourceScanner(player)
	local gui = player.gui.screen['resource-scanner']
	if gui then gui.visible = false end
	player.opened = nil
end

local function toggleResourceScanner(event)
	local player = game.players[event.player_index]
	if event.name == defines.events.on_lua_shortcut and event.prototype_name ~= "resource-scanner" then
		return
	end
	if player.opened and player.opened.name == "resource-scanner" then
		closeResourceScanner(player)
	else
		openResourceScanner(player)
	end
end
local function onGuiClick(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	if event.element.name == "resource-scanner-close" then
		closeResourceScanner(player)
	end
	if event.element.name == "resource-scanner-scan" then
		closeResourceScanner(player)
		local index = player.gui.screen['resource-scanner']['resource-scanner-item'].selected_index
		if not index then
			return
		end
		local resource_list = resources.resources
		if table_size(resource_list) == 0 then
			player.print("Resource entities not loaded yet")
			return
		end
		local type = getUnlockedScans(player.force)[index].products[1].name
		local rdata = resource_list[type]
		if not rdata then
			player.print("Selected resource "..type.." has no resource data")
			return
		end

		queueEffect(event.tick + 30, {type="pulse", player=player})
		-- find nearest grid squares having nodes
		local nodes = {}
		local origin = {math.floor(player.position.x/rdata.gridsize), math.floor(player.position.y/rdata.gridsize)}
		for dx=-2,2 do
			for dy=-2,2 do
				if rdata.grid[player.surface.index][origin[2]+dy] and rdata.grid[player.surface.index][origin[2]+dy][origin[1]+dx] then
					-- ignore origin node as it is fake
					if origin[1]+dx ~= 0 or origin[2]+dy ~= 0 then
						table.insert(nodes, rdata.grid[player.surface.index][origin[2]+dy][origin[1]+dx])
					end
				end
			end
		end
		-- sort nodes according to distance from player (note there's at most 25 nodes so this should be quite fast!)
		table.sort(nodes, function(a,b)
			local adx = player.position.x-a[1]
			local ady = player.position.y-a[2]
			local bdx = player.position.x-b[1]
			local bdy = player.position.y-b[2]
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
		for _,pos in pairs(closest) do
			local dx = pos[1] - player.position.x
			local dy = pos[2] - player.position.y
			local distance = math.floor(math.sqrt(dx*dx+dy*dy)+1)
			queueEffect(event.tick + distance + 30, {
				type = "ping",
				player = player,
				resource = rdata.type,
				position = pos
			})
		end
	end
end

local function updatePings()
	local rendering = rendering
	for i,ping in pairs(script_data.pings) do
		-- check if ping hasn't expired
		if not rendering.is_valid(ping.graphics.background) then
			table.remove(script_data.pings,i)
		else
			local dx = ping.position[1] - ping.player.position.x
			local dy = ping.player.position.y - ping.position[2]
			local dist = 7 -- ping distance around the player
			local ring = 3 -- thickness of "transition" ring between pointing away and pointing at target
			local distance = math.sqrt(dx*dx+dy*dy)+1
			local direction = math.atan2(dy,dx)
			if distance < dist-ring+2 then
				rendering.set_target(ping.graphics.background, {ping.position[1], ping.position[2]-1})
				rendering.set_target(ping.graphics.item, {ping.position[1], ping.position[2]-1})
				rendering.set_target(ping.graphics.arrow, ping.position)
				rendering.set_orientation(ping.graphics.arrow, 0.5)
				rendering.set_target(ping.graphics.label, {ping.position[1], ping.position[2]-0.75})
			elseif distance < dist+2 then
				-- point at target but interpolate angle
				local lerp = ((dist+2)-distance)/ring -- at 1 it's pointing straight down, at 0 it's pointing in "direction"
				local target = direction > math.pi/2 and 3*math.pi/2 or -math.pi/2 -- top-left quadrant needs to go the other way
				local angle = direction + (target-direction)*lerp
				local offset = {
					math.cos(angle),
					-math.sin(angle)
				}
				rendering.set_target(ping.graphics.background, {ping.position[1]-offset[1], ping.position[2]-offset[2]})
				rendering.set_target(ping.graphics.item, {ping.position[1]-offset[1], ping.position[2]-offset[2]})
				rendering.set_target(ping.graphics.arrow, ping.position)
				rendering.set_orientation(ping.graphics.arrow, 0.25 - angle / math.pi/2)
				rendering.set_target(ping.graphics.label, {ping.position[1]-offset[1], ping.position[2]-offset[2]+0.25})
			else
				local offset = {
					math.cos(direction),
					-math.sin(direction)
				}
				rendering.set_target(ping.graphics.background, {ping.player.position.x+offset[1]*dist, ping.player.position.y+offset[2]*dist})
				rendering.set_target(ping.graphics.item, {ping.player.position.x+offset[1]*dist, ping.player.position.y+offset[2]*dist})
				rendering.set_target(ping.graphics.arrow, {ping.player.position.x+offset[1]*(dist+1), ping.player.position.y+offset[2]*(dist+1)})
				rendering.set_orientation(ping.graphics.arrow, 0.25 - direction / math.pi/2)
				rendering.set_target(ping.graphics.label, {ping.player.position.x+offset[1]*dist, ping.player.position.y+offset[2]*dist+0.25})
			end
			rendering.set_text(ping.graphics.label, {"gui.resource-scanner-distance", util.format_number(math.floor(distance))})
		end
	end
end
local function onTick(event)
	if script_data.fx[event.tick] then
		local rendering = rendering
		for _,effect in pairs(script_data.fx[event.tick]) do
			if effect.type == "pulse" then
				effect.player.surface.create_trivial_smoke{
					name = "resource-scanner-pulse",
					position = effect.player.position
				}
			elseif effect.type == "ping" then
				local ttl = 20*60
				-- graphics are created with no offset and placeholder text, as they are immediately updated in updatePings()
				-- TODO make it compatible with Sandbox, where there is no effect.player.character
				table.insert(script_data.pings, {
					player = effect.player,
					position = effect.position,
					graphics = {
						background = rendering.draw_sprite{
							sprite = "resource-scanner-ping",
							target = effect.player.position,
							surface = effect.player.surface,
							time_to_live = ttl,
							players = {effect.player}
						},
						item = rendering.draw_sprite{
							sprite = (effect.resource == "crude-oil" and "fluid" or "item").."/"..effect.resource,
							target = effect.player.position,
							surface = effect.player.surface,
							time_to_live = ttl,
							players = {effect.player}
						},
						arrow = rendering.draw_sprite{
							sprite = "utility/indication_arrow",
							orientation = 0,
							target = effect.player.position,
							surface = effect.player.surface,
							time_to_live = ttl,
							players = {effect.player}
						},
						label = rendering.draw_text{
							text = {"gui.resource-scanner-distance","-"},
							color = {1,1,1},
							surface = effect.player.surface,
							target = effect.player.position,
							time_to_live = ttl,
							players = {effect.player},
							alignment = "center"
						}
					}
				})
			end
		end
		script_data.fx[event.tick] = nil
	end
	updatePings()
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
		[defines.events.on_gui_closed] = function(event)
			if event.element and event.element.valid and event.element.name == "resource-scanner" then
				closeResourceScanner(game.players[event.player_index])
			end
		end
	}
}
