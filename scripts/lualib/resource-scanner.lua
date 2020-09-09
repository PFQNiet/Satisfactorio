local mod_gui = require("mod-gui")
local string = require("scripts.lualib.string")

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
local function openResourceScanner(event)
	local player = game.players[event.player_index]
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
end
local function onGuiClick(event)
	local player = game.players[event.player_index]
	if event.element.name == "resource-scanner-close" then
		closeResourceScanner(player)
		player.opened = nil
	end
	if event.element.name == "resource-scanner-scan" then
		closeResourceScanner(player)
		player.opened = nil
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

		player.surface.create_trivial_smoke{
			name = "resource-scanner-pulse",
			position = player.position
		}
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
			player.print({"","[img=item."..rdata.type.."] ",{"item-name."..rdata.type}," found at [gps=",math.floor(pos[1]),",",math.floor(pos[2]),"]"})
		end
	end
end

return {
	events = {
		["resource-scanner"] = openResourceScanner,
		[defines.events.on_gui_click] = onGuiClick,
		[defines.events.on_gui_closed] = function(event)
			if event.gui_type == defines.gui_type.custom and event.element.name == "resource-scanner" then
				closeResourceScanner(game.players[event.player_index])
			end
		end
	}
}
