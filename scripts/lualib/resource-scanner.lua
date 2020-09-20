-- uses global['resource-scanner-fx'] as a queue of effects
-- uses global['resource-scanner-pings'] as table of player => {pos, graphics}[] for active pings
local mod_gui = require("mod-gui")
local util = require("util")

local function queueEffect(tick, effect)
	if not global['resource-scanner-fx'] then global['resource-scanner-fx'] = {} end
	if not global['resource-scanner-fx'][tick] then global['resource-scanner-fx'][tick] = {} end
	table.insert(global['resource-scanner-fx'][tick], effect)
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
			style = mod_gui.frame_style
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
		menu.add_item({"","[img=item."..recipe.products[1].name.."] ",game.item_prototypes[recipe.products[1].name].localised_name})
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
		log("Event was on_lua_shortcut but prototype_name was "..event.prototype_name)
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
		if not global['resources'] then
			player.print("Resource entities not loaded yet")
			return
		end
		local type = getUnlockedScans(player.force)[index].products[1].name
		if not global['resources'][type] then
			player.print("Selected resource "..type.." has no resource data")
			return
		end

		queueEffect(event.tick + 30, {type="pulse", player=player})
		local rdata = global['resources'][type]
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
		-- for now just insta-ping them
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
	if not global['resource-scanner-pings'] then return end
	for i,ping in ipairs(global['resource-scanner-pings']) do
		-- check if ping hasn't expired
		if not rendering.is_valid(ping.graphics.background) then
			table.remove(global['resource-scanner-pings'],i)
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
				rendering.set_target(ping.graphics.background, ping.player.character, {offset[1]*dist,offset[2]*dist})
				rendering.set_target(ping.graphics.item, ping.player.character, {offset[1]*dist,offset[2]*dist})
				rendering.set_target(ping.graphics.arrow, ping.player.character, {offset[1]*(dist+1),offset[2]*(dist+1)})
				rendering.set_orientation(ping.graphics.arrow, 0.25 - direction / math.pi/2)
				rendering.set_target(ping.graphics.label, ping.player.character, {offset[1]*dist,offset[2]*dist+0.25})
			end
			rendering.set_text(ping.graphics.label, {"gui.resource-scanner-distance", util.format_number(math.floor(distance))})
		end
	end
end
local function onTick(event)
	if global['resource-scanner-fx'] and global['resource-scanner-fx'][event.tick] then
		for _,effect in pairs(global['resource-scanner-fx'][event.tick]) do
			if effect.type == "pulse" then
				effect.player.surface.create_trivial_smoke{
					name = "resource-scanner-pulse",
					position = effect.player.position
				}
			elseif effect.type == "ping" then
				local ttl = 20*60
				if not global['resource-scanner-pings'] then global['resource-scanner-pings'] = {} end
				-- graphics are created with no offset and placeholder text, as they are immediately updated in updatePings()
				table.insert(global['resource-scanner-pings'], {
					player = effect.player,
					position = effect.position,
					graphics = {
						background = rendering.draw_sprite{
							sprite = "resource-scanner-ping",
							target = effect.player.character,
							target_offset = {0,0},
							surface = effect.player.surface,
							time_to_live = ttl,
							players = {effect.player}
						},
						item = rendering.draw_sprite{
							sprite = "item/"..effect.resource,
							target = effect.player.character,
							target_offset = {0,0},
							surface = effect.player.surface,
							time_to_live = ttl,
							players = {effect.player}
						},
						arrow = rendering.draw_sprite{
							sprite = "utility/indication_arrow",
							orientation = 0,
							target = effect.player.character,
							target_offset = {0,0},
							surface = effect.player.surface,
							time_to_live = ttl,
							players = {effect.player}
						},
						label = rendering.draw_text{
							text = {"gui.resource-scanner-distance","-"},
							color = {1,1,1},
							surface = effect.player.surface,
							target = effect.player.character,
							target_offset = {0,0},
							time_to_live = ttl,
							players = {effect.player},
							alignment = "center"
						}
					}
				})
			end
		end
		global['resource-scanner-fx'][event.tick] = nil
	end
	updatePings()
end

return {
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
