-- uses global['crash-sites'] to track requirements for unlocking the spaceship
-- uses global['opened-crash-site'] to track last opened crash site GUI

local data = require("constants.crash-sites")
local loot_table = data.loot
local requirement_table = data.requirements
local crash_site = require("crash-site")
local spaceship = "crash-site-spaceship"

local function generateLoot()
	local loot = {}
	for item,data in pairs(loot_table) do
		if math.random() < data.probability then
			loot[item] = math.random(data.amount[1],data.amount[2])
		end
	end
	return loot
end
local function generateRequirements()
	local selected = math.random(requirement_table.total)
	local power = math.random(2,20)*5
	for item,frequency in pairs(requirement_table.items) do
		selected = selected - frequency
		if selected <= 0 then
			return {
				item = item,
				count = math.random(4,20),
				power = math.random(0,1) == 0 and power or 0 -- 50% chance of also needing power
			}
		end
	end
	-- no item requirement, must have power requirement
	return {
		power = power
	}
end
local function createCrashSite(surface, position)
	crash_site.create_crash_site(
		surface,
		position,
		{},
		generateLoot()
	)
	-- game doesn't trigger raise-built for this so handle that manually
	local wreckage = surface.find_entities_filtered{
		name = {
			"crash-site-spaceship",
			"crash-site-spaceship-wreck-big-1", "crash-site-spaceship-wreck-big-2",
			"crash-site-spaceship-wreck-medium-1", "crash-site-spaceship-wreck-medium-2", "crash-site-spaceship-wreck-medium-3",
			"crash-site-spaceship-wreck-small-1", "crash-site-spaceship-wreck-small-2", "crash-site-spaceship-wreck-small-3",
			"crash-site-spaceship-wreck-small-4", "crash-site-spaceship-wreck-small-5", "crash-site-spaceship-wreck-small-6"
		},
		position = position,
		radius = 50
	}
	for _,wreck in pairs(wreckage) do
		wreck.force = "neutral"
		wreck.destructible = false
	end

	local ship = surface.find_entity(spaceship, position)
	local reqs = generateRequirements()
	local eei
	if reqs.power > 0 then
		eei = surface.create_entity{
			name = ship.name.."-power",
			position = ship.position,
			force = ship.force,
			raise_built = true
		}
		eei.power_usage = reqs.power*1000*1000/60
		eei.electric_buffer_size = eei.power_usage
	end
	-- register ship's requirements
	if not global['crash-sites'] then global['crash-sites'] = {} end
	global['crash-sites'][ship.unit_number] = {
		ship = ship,
		eei = eei,
		requirements = reqs
	}
end

-- on opening a spaceship, check to see if it is registered in crash-sites. If so, it is locked and should present a new GUI to accept items/power
-- if it isn't registered, then either something went wrong or the player actually unlocked it, so just allow the entity to be opened from then on
local function onGuiOpened(event)
	local player = game.players[event.player_index]
	if event.gui_type ~= defines.gui_type.entity then return end
	if event.entity.name ~= spaceship then return end
	if not global['crash-sites'] then return end
	local struct = global['crash-sites'][event.entity.unit_number]
	if not struct then return end
	if not global['opened-crash-site'] then global['opened-crash-site'] = {} end
	global['opened-crash-site'][player.index] = event.entity.unit_number
	
	local gui = player.gui.screen['crash-site-locked']
	if not gui then
		gui = player.gui.screen.add{
			type = "frame",
			name = "crash-site-locked",
			direction = "vertical",
			style = mod_gui.frame_style
		}
		local title_flow = gui.add{type = "flow", name = "title_flow"}
		local title = title_flow.add{type = "label", caption = {"gui.crash-site-title"}, style = "frame_title"}
		title.drag_target = gui
		local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_header"}
		pusher.style.height = 24
		pusher.style.horizontally_stretchable = true
		pusher.drag_target = gui
		title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/close_white", name = "crash-site-close"}

		local content = gui.add{
			type = "frame",
			style = "inside_shallow_frame_with_padding",
			direction = "vertical",
			name = "content"
		}
		local columns = content.add{
			type = "flow",
			direction = "horizontal",
			name = "table"
		}
		columns.style.horizontal_spacing = 12
		local col1 = columns.add{
			type = "frame",
			direction = "vertical",
			name = "left",
			style = "deep_frame_in_shallow_frame"
		}
		local preview = col1.add{
			type = "entity-preview",
			name = "preview",
			style = "entity_button_base"
		}
		local col2 = columns.add{
			type = "flow",
			direction = "vertical",
			name = "right"
		}
		col2.add{
			type = "label",
			style = "heading_2_label",
			caption = {"gui.crash-site-repairs-required"}
		}
		local repairs = col2.add{
			type = "table",
			column_count = 3,
			style = "bordered_table",
			name = "repairs"
		}
		repairs.style.horizontally_stretchable = true
		repairs.add{
			type = "label",
			style = "caption_label",
			caption = {"gui.crash-site-parts-label"}
		}
		repairs.add{
			type = "label",
			name = "parts-needed",
			caption = {"gui.crash-site-not-needed"}
		}
		repairs.add{
			type = "sprite",
			name = "parts-complete",
			sprite = "utility/check_mark_white"
		}
		repairs.add{
			type = "label",
			style = "caption_label",
			caption = {"gui.crash-site-power-label"}
		}
		repairs.add{
			type = "label",
			name = "power-needed",
			caption = {"gui.crash-site-not-needed"}
		}
		repairs.add{
			type = "sprite",
			name = "power-complete",
			sprite = "utility/check_mark_white"
		}
		local bottom = col2.add{
			type = "flow",
			name = "button"
		}
		local pusher = bottom.add{type="empty-widget"}
		pusher.style.horizontally_stretchable = true
		bottom.add{
			type = "button",
			style = "confirm_button",
			name = "crash-site-repair-submit",
			caption = {"gui.crash-site-open"}
		}
	end

	gui.content.table.left.preview.entity = struct.ship
	local repairs = gui.content.table.right.repairs
	local ready = true
	if struct.requirements.item then
		repairs['parts-needed'].caption = {"gui.crash-site-parts",struct.requirements.count,struct.requirements.item,{"item-name."..struct.requirements.item}}
		local has_item = player.get_main_inventory().get_item_count(struct.requirements.item) >= struct.requirements.count
		repairs['parts-complete'].sprite = has_item and "utility/check_mark_white" or "utility/close_white"
		if not has_item then ready = false end
	else
		repairs['parts-needed'].caption = {"gui.crash-site-not-needed"}
		repairs['parts-complete'].sprite = "utility/check_mark_white"
	end
	if struct.requirements.power > 0 then
		repairs['power-needed'].caption = {"gui.crash-site-power",struct.requirements.power}
		local has_power = struct.eei.energy > 0
		repairs['power-complete'].sprite = has_power and "utility/check_mark_white" or "utility/close_white"
		if not has_power then ready = false end
	else
		repairs['power-needed'].caption = {"gui.crash-site-not-needed"}
		repairs['power-complete'].sprite = "utility/check_mark_white"
	end
	repairs.parent.button['crash-site-repair-submit'].enabled = ready

	gui.visible = true
	player.opened = gui
	gui.force_auto_center()
end
local function closeGui(player)
	local gui = player.gui.screen['crash-site-locked']
	if gui then gui.visible = false end
	player.opened = nil
end
local function onGuiClosed(event)
	if event.element and event.element.valid and event.element.name == "crash-site-locked" then
		closeGui(game.players[event.player_index])
	end
end
local function onGuiClick(event)
	if not (event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	if event.element.name == "crash-site-close" then
		closeGui(player)
	end
	if event.element.name == "crash-site-repair-submit" then
		local struct = global['crash-sites'][global['opened-crash-site'][player.index]]
		if struct then
			-- struct may be gone if say another player completed it for you, but if it's still here then it's mine
			local ready = true
			if struct.requirements.item then
				local has_item = player.get_main_inventory().get_item_count(struct.requirements.item) >= struct.requirements.count
				if not has_item then ready = false end
			end
			if struct.requirements.power > 0 then
				local has_power = struct.eei.energy > 0
				if not has_power then ready = false end
			end
			if ready then
				if struct.requirements.item then
					player.get_main_inventory().remove{name=struct.requirements.item,count=struct.requirements.count}
				end
				-- insert hard drive into spaceship (ejecting anything the player may have fast-inserted into it)
				local inventory = struct.ship.get_inventory(defines.inventory.chest)
				if inventory[1].valid_for_read then
					struct.ship.surface.spill_item_stack(struct.ship.position, inventory[1], true, player.force, false)
					inventory.remove(inventory[1])
				end
				inventory.insert{name="hard-drive",count=1}
				-- delete entry from global table to mark it as unlocked
				global['crash-sites'][global['opened-crash-site'][player.index]] = nil
				player.opened = struct.ship
			end
		end
	end
end

return {
	createCrashSite = createCrashSite,
	lib = {
		events = {
			[defines.events.on_gui_opened] = onGuiOpened,
			[defines.events.on_gui_closed] = onGuiClosed,
			[defines.events.on_gui_click] = onGuiClick
		}
	}
}