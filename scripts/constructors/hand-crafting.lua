local bev = require(modpath.."scripts.lualib.build-events")

---@class CraftBenchData
---@field entity LuaEntity
---@field products uint Number of products this building has made when last queried
---@field players table<uint, boolean> Map of player IDs that have this bench open

---@alias global.craft_bench table<uint, CraftBenchData>
---@type global.craft_bench Map unit number of bench/workshop to its data
local script_data = {}

local bench = "craft-bench"
local workshop = "equipment-workshop"

---@param data CraftBenchData
local function updateBenchData(data)
	local entity = data.entity
	local crafted = entity.products_finished
	if crafted > data.products then
		local difference = crafted - data.products
		local credit_to = next(data.players)
		-- NB: craft bench recipes always have a single solid product with no probability factors
		local recipe = entity.get_recipe()
		if recipe then
			local output = entity.get_output_inventory()[1]
			for _=1,difference do
				script.raise_player_crafted_item{
					item_stack = output,
					player_index = credit_to,
					recipe = recipe
				}
			end
		end
		data.products = crafted
	end
end

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not (entity and entity.valid) then return end
	if entity.name ~= bench and entity.name ~= workshop then return end

	entity.active = false
end

local function onRemoved(event)
	local entity = event.created_entity or event.entity
	if not (entity and entity.valid) then return end
	if entity.name ~= bench and entity.name ~= workshop then return end

	local map = script_data[entity.unit_number]
	if map then
		updateBenchData(map)
		script_data[entity.unit_number] = nil
	end
end

---@param event on_gui_opened
local function onGuiOpened(event)
	if event.gui_type ~= defines.gui_type.entity then return end
	local entity = event.entity
	if not (entity and entity.valid) then return end
	if entity.name ~= bench and entity.name ~= workshop then return end

	entity.active = true
	if not script_data[entity.unit_number] then
		script_data[entity.unit_number] = {
			entity = entity,
			products = entity.products_finished,
			players = {}
		}
	end
	script_data[entity.unit_number].players[event.player_index] = true
end

---@param event on_gui_closed
local function onGuiClosed(event)
	if event.gui_type ~= defines.gui_type.entity then return end
	local entity = event.entity
	if not (entity and entity.valid) then return end
	if entity.name ~= bench and entity.name ~= workshop then return end

	local map = script_data[entity.unit_number]
	if map then
		updateBenchData(map)
		map.players[event.player_index] = nil
		-- if there are no more players with this entity open, unregister it
		if not next(map.players) then
			script_data[entity.unit_number] = nil
			map = nil
		end
	end
	-- new check instead of "else" because it may have changed above
	if not map then
		entity.active = false
	end
end

local function updateAllBenches()
	for _,data in pairs(script_data) do
		updateBenchData(data)
	end
end

return bev.applyBuildEvents{
	on_init = function()
		global.craft_bench = global.craft_bench or script_data
	end,
	on_load = function()
		script_data = global.craft_bench or script_data
	end,
	on_configuration_changed = function()
		global.craft_bench = global.craft_bench or script_data
	end,
	on_nth_tick = {
		[60] = updateAllBenches
	},
	on_build = onBuilt,
	on_destroy = onRemoved,
	events = {
		[defines.events.on_gui_opened] = onGuiOpened,
		[defines.events.on_gui_closed] = onGuiClosed
	}
}
