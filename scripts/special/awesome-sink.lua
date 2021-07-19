local gui = require(modpath.."scripts.gui.awesome-sink")

-- sink is a furnace that produces awesome-points "fluid"
-- n = tickets earned so far, next ticket earned at 500*floor(n/3)^2+1000 points

---@class AwesomeSinkData
---@field tickets AwesomeSinkTicketData
---@field points AwesomeSinkPointData
---@field tonext uint64

---@class AwesomeSinkTicketData
---@field earned uint
---@field printed uint

---@class AwesomeSinkPointData
---@field earned uint64
---@field per_minute uint

---@class global.awesome
---@field sinks table<uint,LuaEntity> Sinks indexed by unit number
---@field coupons table<uint,AwesomeSinkData> Map of force index to earning data
local script_data = {
	sinks = {},
	coupons = {}
}

---@param earned uint Number of earned tickets
local function pointsToNext(earned)
	return 500 * math.floor(earned / 3)^2 + 1000
end

---@param force LuaForce
---@return AwesomeSinkData
local function getStruct(force)
	if not script_data.coupons[force.index] then
		script_data.coupons[force.index] = {
			tickets = {
				earned = 0,
				printed = 0
			},
			points = {
				earned = 0,
				per_minute = 0
			},
			tonext = pointsToNext(0)
		}
	end
	return script_data.coupons[force.index]
end

---@param force LuaForce
---@param points uint
local function gainPoints(force, points)
	local entry = getStruct(force)
	entry.points.earned = entry.points.earned + points
	entry.points.per_minute = entry.points.per_minute + points*12 -- reset every 5 seconds, so 12x is per minute
	while entry.points.earned > entry.tonext do
		entry.tickets.earned = entry.tickets.earned + 1
		entry.points.earned = entry.points.earned - entry.tonext
		entry.tonext = pointsToNext(entry.tickets.earned)
	end
end

local io = require(modpath.."scripts.lualib.input-output")
local bev = require(modpath.."scripts.lualib.build-events")

local base = "awesome-sink"

---@param sink LuaEntity
local function processSink(sink)
	local fluidbox = sink.fluidbox[1]
	if fluidbox then
		-- we have some fluid!
		gainPoints(sink.force, fluidbox.amount)
		sink.fluidbox[1] = nil -- delete the fluid
	end
end

---@param event on_build
local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not (entity and entity.valid) then return end
	if entity.name == base then
		io.addConnection(entity, {-0.5,3}, "input")
		entity.rotatable = false
		script_data.sinks[entity.unit_number] = entity
	end
end

---@param event on_destroy
local function onRemoved(event)
	local entity = event.entity
	if not (entity and entity.valid) then return end
	if entity.name == base then
		processSink(entity)
		script_data.sinks[entity.unit_number] = nil
	end
end

---@param event on_gui_opened
local function onGuiOpened(event)
	local player = game.players[event.player_index]
	if event.gui_type == defines.gui_type.entity and event.entity.valid and event.entity.name == base then
		gui.open_gui(player, getStruct(player.force))
	end
end

---@param col Color
---@return string formatted R,G,B
local function formatColor(col)
	return table.concat({col.r, col.g, col.b}, ",")
end

---@param player LuaPlayer
gui.callbacks.print = function(player)
	local inventory = player.get_main_inventory()
	local caninsert = inventory.get_insertable_count("coin")
	local data = getStruct(player.force)
	local printable = data.tickets.earned - data.tickets.printed
	if printable > 0 then
		if caninsert == 0 then
			player.print{"inventory-restriction.player-inventory-full",{"item-name.coin"},{"inventory-full-message.main"}}
			return
		end
		if printable > caninsert then
			printable = caninsert
		end
		if printable > 0 then
			player.force.print{"message.received-awesome-coupons",formatColor(player.chat_color),player.name,printable}
			inventory.insert{name="coin",count=printable}
			data.tickets.printed = data.tickets.printed + printable
		end
		gui.update_gui(player.force, data)
	end
end

return bev.applyBuildEvents{
	on_init = function()
		global.awesome = global.awesome or script_data
	end,
	on_load = function()
		script_data = global.awesome or script_data
	end,
	on_nth_tick = {
		[300] = function()
			for _,entry in pairs(script_data.coupons) do
				entry.points.per_minute = 0
			end
			for _,sink in pairs(script_data.sinks) do
				processSink(sink)
			end
			for _,force in pairs(game.forces) do
				gui.update_gui(force, getStruct(force))
			end
		end
	},
	on_build = onBuilt,
	on_destroy = onRemoved,
	events = {
		[defines.events.on_gui_opened] = onGuiOpened
	}
}

