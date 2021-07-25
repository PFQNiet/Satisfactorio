local gui = require(modpath.."scripts.gui.crash-sites")
local link = require(modpath.."scripts.lualib.linked-entity")
local getitems = require(modpath.."scripts.lualib.get-items-from")

local data = require(modpath.."constants.crash-sites")
local loot_table = data.loot
local requirement_table = data.requirements
local crash_site = require("crash-site")
local spaceship = "crash-site-spaceship"

---@class CrashSiteRequirements
---@field item string|nil
---@field count uint8|nil
---@field power uint

---@class CrashSiteData
---@field ship LuaEntity Container
---@field eei LuaEntity ElectricEnergyInterface
---@field requirements CrashSiteRequirements

---@class global.crash_site
---@field sites table<uint, CrashSiteData>
local script_data = {
	sites = {}
}

---@return table<string, uint8>
local function generateLoot()
	local loot = {}
	local random = math.random
	for item,entry in pairs(loot_table) do
		if random() < entry.probability then
			loot[item] = random(entry.amount[1],entry.amount[2])
		end
	end
	return loot
end
---@return CrashSiteRequirements
local function generateRequirements()
	local random = math.random
	local selected = random(requirement_table.total)
	local power = random(2,20)*5
	for item,frequency in pairs(requirement_table.items) do
		selected = selected - frequency
		if selected <= 0 then
			return {
				item = item,
				count = random(4,20),
				power = random(0,1) == 0 and power or 0 -- 50% chance of also needing power
			}
		end
	end
	-- no item requirement, must have power requirement
	return {
		power = power
	}
end

---@param surface LuaSurface
---@param position Position
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
		radius = 55
	}
	for _,wreck in pairs(wreckage) do
		wreck.force = "neutral"
		wreck.destructible = false
	end

	local ship = surface.find_entity(spaceship, position)
	ship.minable = false
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
		link.register(ship, eei)
	end
	-- register ship's requirements
	script_data.sites[ship.unit_number] = {
		ship = ship,
		eei = eei,
		requirements = reqs
	}
end

-- on opening a spaceship, check to see if it is registered in crash-sites. If so, it is locked and should present a new GUI to accept items/power
-- if it isn't registered, then either something went wrong or the player actually unlocked it, so just allow the entity to be opened from then on
---@param event on_gui_opened
local function onGuiOpened(event)
	local player = game.players[event.player_index]
	if event.gui_type ~= defines.gui_type.entity then return end
	if event.entity.name ~= spaceship then return end

	local struct = script_data.sites[event.entity.unit_number]
	if not struct then
		gui.close_gui(player)
		event.entity.minable = true -- ensure entity can be mined
		return
	end

	gui.open_gui(player, struct)

	-- look for the repair item in the player's inventory, and auto-insert if available
	if struct.requirements.item then
		local need = struct.requirements.count - struct.ship.get_item_count(struct.requirements.item)
		local inventory = player.get_main_inventory()
		local available = inventory.get_item_count(struct.requirements.item)
		if need > 0 and available >= need then
			inventory.remove{
				name = struct.requirements.item,
				count = struct.ship.insert{
					name = struct.requirements.item,
					count = need
				}
			}
		end
	end
end

---@param player LuaPlayer
---@param ship LuaEntity
gui.callbacks.repair = function(player, ship)
	local struct = script_data.sites[ship.unit_number]
	if not struct then return gui.close_gui(player) end

	---@param player LuaPlayer
	---@param reason LocalisedString
	local function failRepairs(player, reason)
		player.create_local_flying_text{text = reason, create_at_cursor = true}
		player.play_sound{path = "utility/cannot_build"}
	end
	if struct.requirements.item then
		local has_item = struct.ship.get_item_count(struct.requirements.item) >= struct.requirements.count
		if not has_item then
			return failRepairs(player, {"message.crash-site-missing-items"})
		end
	end
	if struct.requirements.power > 0 then
		local has_power = struct.eei.energy > 0
		if not has_power then
			return failRepairs(player, {"message.crash-site-missing-power"})
		end
	end

	-- consume repair items
	if struct.requirements.item then
		struct.ship.remove_item{name=struct.requirements.item, count=struct.requirements.count}
	end

	-- insert hard drive into spaceship
	getitems.storage(struct.ship, player.get_main_inventory())
	struct.ship.insert{name="hard-drive",count=1}

	-- delete entry from global table to mark it as unlocked
	script_data.sites[ship.unit_number] = nil

	-- close gui for any players that have this ship open
	for _,p in pairs(game.players) do
		if p.opened == ship then
			gui.close_gui(p)
		end
	end
end

-- if crash sites are disabled, enable the awesome-shop-hard-drive recipe
---@param event on_force_created|on_technology_effects_reset
local function alternativeHardDrives(event)
	if game.default_map_gen_settings.autoplace_controls['x-crashsite'].size == 0 then
		event.force.recipes['awesome-shop-hard-drive'].enabled = true
	end
end

return {
	createCrashSite = createCrashSite,

	lib = {
		on_init = function()
			global.crash_site = global.crash_site or script_data
			alternativeHardDrives{force=game.forces.player}
		end,
		on_load = function()
			script_data = global.crash_site or script_data
		end,
		events = {
			[defines.events.on_gui_opened] = onGuiOpened,

			[defines.events.on_force_created] = alternativeHardDrives,
			[defines.events.on_technology_effects_reset] = alternativeHardDrives
		}
	}
}
