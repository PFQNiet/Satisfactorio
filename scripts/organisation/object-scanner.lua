-- uses global['object-scanner-pings'] as table of player => {type, target, graphics} for active pings
local scanner = "object-scanner"

local mod_gui = require("mod-gui")
local util = require("util")

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
local function openObjectScanner(player)
	local gui = player.gui.screen['object-scanner']
	local menu
	if not gui then
		if not global['object-scanner-pings'] then global['object-scanner-pings'] = {} end
		if not global['object-scanner-pings'][player.index] then global['object-scanner-pings'][player.index] = {} end

		gui = player.gui.screen.add{
			type = "frame",
			name = "object-scanner",
			direction = "vertical",
			style = mod_gui.frame_style
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
		menu = gui.add{
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
	else
		menu = gui['object-scanner-item']
	end
	local index = menu.selected_index or 0
	if index == 0 then index = 1 end
	menu.clear_items()
	for i,recipe in ipairs(getUnlockedScans(player.force)) do
		local product = recipe.products[1]
		local scan_for = game[product.type.."_prototypes"][product.name].localised_name
		if product.name == "green-power-slug" then scan_for = {"gui.object-scanner-power-slugs"} end
		menu.add_item({"","[img="..product.type.."."..product.name.."] ",scan_for})
		if global['object-scanner-pings'][player.index].type == product.name then
			index = i
		end
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
local function closeObjectScanner(player)
	local gui = player.gui.screen['object-scanner']
	if gui then gui.visible = false end
	player.opened = nil
end

local function onGuiClick(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	if event.element.name == "object-scanner-close" then
		closeObjectScanner(player)
	end
	if event.element.name == "object-scanner-select" then
		closeObjectScanner(player)
		local index = player.gui.screen['object-scanner']['object-scanner-item'].selected_index
		if not index or index == 0 then
			return
		end
		local type = getUnlockedScans(player.force)[index].products[1].name
		global['object-scanner-pings'][player.index].type = type
		-- if cursor is empty, find an object scanner in player's inventory and put it in the cursor
		if not player.cursor_stack.valid_for_read then
			local stack = player.get_main_inventory().find_item_stack(scanner)
			if stack then
				player.cursor_stack.swap_stack(stack)
			end
		end
	end
end

local function onTick(event)
	if not global['object-scanner-pings'] then return end
	for pid,ping in ipairs(global['object-scanner-pings']) do
		local player = game.players[pid]
		if not (ping.type and player.cursor_stack.valid_for_read and player.cursor_stack.name == scanner) then
			if ping.graphics then
				for _,rid in pairs(ping.graphics) do
					if rendering.is_valid(rid) then
						rendering.destroy(rid)
					end
				end
				ping.graphics = nil
			end
		else
			if not ping.target or event.tick%60 == (pid*13)%60 then
				-- update target entity
				local search_for = ping.type
				if ping.type == "green-power-slug" then
					search_for = {"green-power-slug","yellow-power-slug","purple-power-slug"}
				elseif ping.type == "crash-site" then
					search_for = "crash-site-spaceship"
				end

				local entities
				if ping.type == "enemies" then
					entities = player.surface.find_enemy_units(player.position, 250, player.force)
				else
					entities = player.surface.find_entities_filtered{
						name = search_for,
						position = player.position,
						radius = 250
					}
				end
				ping.target = #entities > 0 and player.surface.get_closest(player.position, entities) or nil
				if ping.target and ping.target.valid and ping.graphics and rendering.is_valid(ping.graphics.item) then
					rendering.set_sprite(ping.graphics.item, "entity/"..ping.target.name)
				end
			end

			if ping.graphics and (not rendering.is_valid(ping.graphics.background) or not ping.target or not ping.target.valid) then
				-- changed surface or lost signal
				for _,rid in pairs(ping.graphics) do
					if rendering.is_valid(rid) then
						rendering.destroy(rid)
					end
				end
				ping.graphics = nil
			end
			if ping.target and ping.target.valid then
				if not ping.graphics then
					ping.graphics = {
						background = rendering.draw_sprite{
							sprite = "resource-scanner-ping",
							target = player.position,
							surface = player.surface,
							players = {player}
						},
						item = rendering.draw_sprite{
							sprite = "entity/"..ping.target.name,
							target = player.position,
							surface = player.surface,
							players = {player}
						},
						arrow = rendering.draw_sprite{
							sprite = "utility/indication_arrow",
							orientation = 0,
							target = player.position,
							surface = player.surface,
							players = {player}
						},
						label = rendering.draw_text{
							text = {"gui.resource-scanner-distance","-"},
							color = {1,1,1},
							surface = player.surface,
							target = player.position,
							players = {player},
							alignment = "center"
						}
					}
				end

				local dx = ping.target.position.x - player.position.x
				local dy = player.position.y - ping.target.position.y
				local dist = 7 -- ping distance around the player
				local ring = 3 -- thickness of "transition" ring between pointing away and pointing at target
				local distance = math.sqrt(dx*dx+dy*dy)+1
				local direction = math.atan2(dy,dx)
				if distance < dist-ring+2 then
					rendering.set_target(ping.graphics.background, {ping.target.position.x, ping.target.position.y-1})
					rendering.set_target(ping.graphics.item, {ping.target.position.x, ping.target.position.y-1})
					rendering.set_target(ping.graphics.arrow, ping.target.position)
					rendering.set_orientation(ping.graphics.arrow, 0.5)
					rendering.set_target(ping.graphics.label, {ping.target.position.x, ping.target.position.y-0.75})
				elseif distance < dist+2 then
					-- point at target but interpolate angle
					local lerp = ((dist+2)-distance)/ring -- at 1 it's pointing straight down, at 0 it's pointing in "direction"
					local target = direction > math.pi/2 and 3*math.pi/2 or -math.pi/2 -- top-left quadrant needs to go the other way
					local angle = direction + (target-direction)*lerp
					local offset = {
						math.cos(angle),
						-math.sin(angle)
					}
					rendering.set_target(ping.graphics.background, {ping.target.position.x-offset[1], ping.target.position.y-offset[2]})
					rendering.set_target(ping.graphics.item, {ping.target.position.x-offset[1], ping.target.position.y-offset[2]})
					rendering.set_target(ping.graphics.arrow, ping.target.position)
					rendering.set_orientation(ping.graphics.arrow, 0.25 - angle / math.pi/2)
					rendering.set_target(ping.graphics.label, {ping.target.position.x-offset[1], ping.target.position.y-offset[2]+0.25})
				else
					local offset = {
						math.cos(direction),
						-math.sin(direction)
					}
					rendering.set_target(ping.graphics.background, {player.position.x+offset[1]*dist, player.position.y+offset[2]*dist})
					rendering.set_target(ping.graphics.item, {player.position.x+offset[1]*dist, player.position.y+offset[2]*dist})
					rendering.set_target(ping.graphics.arrow, {player.position.x+offset[1]*(dist+1), player.position.y+offset[2]*(dist+1)})
					rendering.set_orientation(ping.graphics.arrow, 0.25 - direction / math.pi/2)
					rendering.set_target(ping.graphics.label, {player.position.x+offset[1]*dist, player.position.y+offset[2]*dist+0.25})
				end
				rendering.set_text(ping.graphics.label, {"gui.object-scanner-distance", util.format_number(math.floor(distance))})
			end
		end
	end
end

return {
	events = {
		[defines.events.on_mod_item_opened] = function(event)
			local player = game.players[event.player_index]
			if event.item.name == scanner then
				openObjectScanner(player)
			end
		end,
		[defines.events.on_tick] = onTick,
		[defines.events.on_gui_click] = onGuiClick,
		[defines.events.on_gui_closed] = function(event)
			if event.element and event.element.valid and event.element.name == "object-scanner" then
				closeObjectScanner(game.players[event.player_index])
			end
		end
	}
}