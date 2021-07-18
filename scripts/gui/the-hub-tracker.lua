---@class HubTrackerGui
---@field player LuaPlayer
---@field milestone LuaRecipePrototype
---@field components HubTrackerGuiComponents

---@class HubTrackerGuiComponents
---@field frame LuaGuiElement
---@field title LuaGuiElement
---@field table LuaGuiElement
---@field ingredients table<string, LuaGuiElement> Ingredient name => Quantity label
---@field cooldown LuaGuiElement

---@alias global.gui.hub_tracker table<uint, HubTrackerGui>
---@type global.gui.hub_tracker
local script_data = {}

---@class HubTrackerGuiCallbacks
---@field submit fun(player:LuaPlayer, milestone:LuaRecipePrototype)
local callbacks = {
	submit = function() end
}

---@param player LuaPlayer
---@return HubTrackerGui|nil
local function getGui(player)
	return script_data[player.index]
end

---@param player LuaPlayer
---@return HubTrackerGui
local function createGui(player)
	if script_data[player.index] then return script_data[player.index] end
	local gui = player.gui.left
	local frame = gui.add{
		type = "frame",
		direction = "vertical",
		caption = {"gui.hub-milestone-tracking-caption"},
		style = "hub_milestone_frame"
	}

	local content = frame.add{
		type = "frame",
		style = "inside_shallow_frame_with_padding_and_spacing",
		direction = "vertical",
		tags = {
			milestone = "none"
		}
	}
	local head = content.add{
		type = "frame",
		name = "head",
		style = "full_subheader_frame_in_padded_frame"
	}
	local title = head.add{
		type = "label",
		style = "heading_2_label",
		caption = {"gui.hub-milestone-tracking-none-selected"}
	}

	local table = content.add{
		type = "table",
		style = "hub_milestone_table",
		column_count = 3
	}
	table.visible = false

	local cooldown = content.add{type = "label"}
	cooldown.visible = false

	script_data[player.index] = {
		player = player,
		terminal = nil,
		components = {
			frame = frame,
			title = title,
			table = table,
			cooldown = cooldown
		}
	}
	return script_data[player.index]
end

---@param player LuaPlayer
---@param milestone LuaRecipePrototype
---@param submitted table<string,number>
---@return boolean
local function updateGui(player, milestone, cooldown, submitted)
	local data = getGui(player)
	if not data then return end

	local components = data.components
	if milestone ~= data.milestone then
		if not milestone then
			components.title.caption = {"gui.hub-milestone-tracking-none-selected"}
			components.table.visible = false
		else
			components.title.caption = {"", "[img=recipe/"..milestone.name.."] ", milestone.localised_name}
			components.ingredients = {}
			local table = components.table
			table.clear()
			for _,ingredient in pairs(milestone.ingredients) do
				table.add{
					type = "sprite-button",
					sprite = "item/"..ingredient.name,
					style = "text_sized_transparent_slot"
				}
				table.add{
					type = "label",
					caption = game.item_prototypes[ingredient.name].localised_name,
					style = "bold_label"
				}
				components.ingredients[ingredient.name] = table.add{
					type = "label"
				}
			end
			table.visible = true
		end
		data.milestone = milestone
	end

	if cooldown > game.tick then
		local ticks = cooldown - game.tick
		local minutes = math.floor(ticks/3600)
		local seconds = math.floor(ticks/60)%60
		local pad_seconds = seconds < 10 and "0" or ""
		local tenths = math.floor(ticks/6)%10
		components.cooldown.caption = {"gui.hub-milestone-cooldown", minutes, pad_seconds, seconds, tenths}
		components.cooldown.visible = true
	else
		components.cooldown.visible = false
	end

	if data.milestone and submitted then
		local ready = true
		for _,ingredient in pairs(data.milestone.ingredients) do
			local label = data.components.ingredients[ingredient.name]
			label.caption = {
				"gui.fraction",
				util.format_number(math.min(submitted[ingredient.name] or 0, ingredient.amount)),
				util.format_number(ingredient.amount)
			}
			if not submitted[ingredient.name] or submitted[ingredient.name] < ingredient.amount then
				ready = false
			end
		end
		return ready
	end
	return false
end

return {
	create_gui = createGui,
	update_gui = updateGui,
	lib = {
		on_init = function()
			global.gui.hub_tracker = global.gui.hub_tracker or script_data
		end,
		on_load = function()
			script_data = global.gui and global.gui.hub_tracker or script_data
		end
	}
}
