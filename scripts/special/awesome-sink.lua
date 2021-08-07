local gui = require(modpath.."scripts.gui.awesome-sink")
local link = require(modpath.."scripts.lualib.linked-entity")
local io = require(modpath.."scripts.lualib.input-output")
local bev = require(modpath.."scripts.lualib.build-events")

-- sink is a furnace that produces awesome-points "fluid"
-- a hidden beacon speeds up the furnace based on the connected belt speed
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

---@class AwesomeSinkStruct
---@field sink LuaEntity
---@field connection MachineConnection
---@field modules LuaInventory

---@class global.awesome
---@field structs table<uint,AwesomeSinkStruct> Sinks indexed by unit number
---@field coupons table<uint,AwesomeSinkData> Map of force index to earning data
local script_data = {
	structs = {},
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

local base = "awesome-sink"
local beacon = base.."-beacon"
local module = base.."-module"
local counts = {
	["loader-conveyor-belt-mk-1"] = 0,
	["loader-conveyor-belt-mk-2"] = 1,
	["loader-conveyor-belt-mk-3"] = 2,
	["loader-conveyor-belt-mk-4"] = 4,
	["loader-conveyor-belt-mk-5"] = 6
}

---@param struct AwesomeSinkStruct
local function processSink(struct)
	local mods = struct.modules
	local count = counts[struct.connection.belt.name] or 0
	local delta = count - mods.get_item_count(module)
	if delta > 0 then
		mods.insert{name=module, count=delta}
	elseif delta < 0 then
		mods.remove{name=module, count=-delta}
	end

	local sink = struct.sink
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
		local conn = io.addConnection(entity, {-0.5,3}, "input")
		local emit = entity.surface.create_entity{
			name = beacon,
			position = {entity.position.x+2, entity.position.y},
			force = entity.force,
			raise_built = true
		}
		link.register(entity, emit)
		local mods = emit.get_inventory(defines.inventory.beacon_modules)
		local count = counts[conn.belt.name] or 0
		if count > 0 then
			mods.insert{name=module, count=count}
		end
		entity.rotatable = false

		local struct = {
			sink = entity,
			connection = conn,
			modules = mods
		}
		script_data.structs[entity.unit_number] = struct
	end
end

---@param event on_destroy
local function onRemoved(event)
	local entity = event.entity
	if not (entity and entity.valid) then return end
	if entity.name == base then
		processSink(script_data.structs[entity.unit_number])
		script_data.structs[entity.unit_number] = nil
	end
end

---@param event on_gui_opened
local function onGuiOpened(event)
	local player = game.players[event.player_index]
	local entity = event.entity
	if not (entity and entity.valid) then return end
	if entity.name == beacon then
		player.opened = entity.surface.find_entity(base, entity.position)
	end
	if entity.name == base then
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
	on_configuration_changed = function()
		if script_data['sinks'] and not script_data.structs then
			script_data.structs = {}
			---@typelist number,LuaEntity
			for i,sink in pairs(script_data['sinks']) do
				local emit = sink.surface.create_entity{
					name = beacon,
					position = {sink.position.x+2,sink.position.y},
					force = sink.force,
					raise_built = true
				}
				emit.operable = false
				script_data.structs[i] = {
					sink = sink,
					connection = io.getConnections(sink).connections[1],
					modules = emit.get_inventory(defines.inventory.beacon_modules)
				}
			end
			script_data['sinks'] = nil
		end
	end,
	on_nth_tick = {
		[300] = function()
			for _,entry in pairs(script_data.coupons) do
				entry.points.per_minute = 0
			end
			for _,sink in pairs(script_data.structs) do
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

