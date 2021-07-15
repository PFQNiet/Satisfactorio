-- uses global.valves to track valves, which consist of an input and output. the script then averages their contents but only in the forward direction
local gui = require(modpath.."scripts.gui.valve")
local bev = require(modpath.."scripts.lualib.build-events")
local link = require(modpath.."scripts.lualib.linked-entity")

local valve = "valve"
local valvein = valve.."-input"
local valveout = valve.."-output"

---@class ValveData
---@field base LuaEntity
---@field control LuaConstantCombinatorControlBehavior
---@field flow number Set by the player
---@field input LuaEntity
---@field output LuaEntity
---@field arrow uint64

---@alias global.valves table<uint, ValveData>
---@type global.valves
local script_data = {}

---@class ValveVectorSet
---@field input Vector
---@field output Vector
---@field arrow Vector

---@type table<defines.direction, ValveVectorSet>
local vectors = {
	[defines.direction.north] = {
		input = {0,0.5},
		output = {0,-0.5},
		arrow = {0,-1}
	},
	[defines.direction.east] = {
		input = {-0.5,0},
		output = {0.5,0},
		arrow = {1,0}
	},
	[defines.direction.south] = {
		input = {0,-0.5},
		output = {0,0.5},
		arrow = {0,1}
	},
	[defines.direction.west] = {
		input = {0.5,0},
		output = {-0.5,0},
		arrow = {-1,0}
	}
}
---@param position Position
---@param vector Vector
---@return Position
local function addVectorToPosition(position, vector)
	return {
		x = position.x + vector[1],
		y = position.y + vector[2]
	}
end

---@param force LuaForce
local function getMaxFlow(force)
	return force.recipes['pipeline-mk-2'].enabled and 600 or 300
end

---@param entity LuaEntity
local function createStruct(entity)
	---@type LuaConstantCombinatorControlBehavior
	local control = entity.get_or_create_control_behavior()
	local flow = getMaxFlow(entity.force)
	local existing = control.get_signal(1)
	if existing.signal and existing.signal.name == "signal-L" then
		flow = existing.count
	end
	local struct = {
		base = entity,
		control = control,
		flow = flow,
		input = entity.surface.create_entity{
			name = valvein,
			position = addVectorToPosition(entity.position, vectors[entity.direction].input),
			direction = entity.direction,
			force = entity.force,
			raise_built = true
		},
		output = entity.surface.create_entity{
			name = valveout,
			position = addVectorToPosition(entity.position, vectors[entity.direction].output),
			direction = entity.direction,
			force = entity.force,
			raise_built = true
		},
		arrow = rendering.draw_sprite{
			sprite = "utility.fluid_indication_arrow",
			orientation = entity.direction/8,
			render_layer = "arrow",
			target = entity,
			target_offset = vectors[entity.direction].arrow,
			surface = entity.surface,
			only_in_alt_mode = true
		}
	}
	link.register(struct.base, struct.input)
	link.register(struct.base, struct.output)
	control.parameters = {
		{
			index = 1,
			signal = {type="virtual", name="signal-L"},
			count = struct.flow
		}
	}
	script_data[entity.unit_number] = struct
end
---@param entity LuaEntity
local function getStruct(entity)
	return script_data[entity.unit_number]
end
---@param entity LuaEntity
local function deleteStruct(entity)
	script_data[entity.unit_number] = nil
end

---@param event on_build
local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not (entity and entity.valid) then return end
	if entity.name == valve then
		createStruct(entity)
	end
end

---@param event on_destroy
local function onRemoved(event)
	local entity = event.entity
	if not (entity and entity.valid) then return end
	if entity.name == valve then
		deleteStruct(entity)
	end
end

---@param event on_player_rotated_entity
local function onRotated(event)
	local entity = event.entity
	if not (entity and entity.valid) then return end
	if entity.name == valve then
		local struct = getStruct(entity)
		struct.input.teleport(addVectorToPosition(entity.position, vectors[entity.direction].input))
		struct.output.teleport(addVectorToPosition(entity.position, vectors[entity.direction].output))
		struct.input.direction = entity.direction
		struct.output.direction = entity.direction
		rendering.set_orientation(struct.arrow, struct.base.direction/8)
		rendering.set_target(struct.arrow, entity, vectors[entity.direction].arrow)
	end
end

-- transfer half the difference between input and output in the forward direction, if fluids match
---@param event on_tick
local function onTick(event)
	for _,struct in pairs(script_data) do
		---@type Fluid
		local input = struct.input.fluidbox[1]
		local transfer = 0
		if input then
			---@type Fluid
			local output = struct.output.fluidbox[1] or {name=input.name, amount=0}
			if input.name == output.name and input.amount > output.amount and struct.control.enabled and struct.flow > 0 then
				transfer = (input.amount - output.amount) / 2
				-- set max flow rate... (flow/minute / 60seconds/minute / 60ticks/second = flow/tick)
				if transfer > struct.flow/60/60 then transfer = struct.flow/60/60 end
				struct.input.remove_fluid{name=input.name, amount=transfer}
				struct.output.insert_fluid{name=input.name, amount=transfer}
			end
			struct.control.set_signal(2, {
				signal = {type="fluid", name=input.name},
				count = transfer * 3600
			})
		else
			struct.control.set_signal(2, nil)
		end
		struct.control.set_signal(1, {
			signal = {type="virtual", name="signal-L"},
			count = struct.flow
		})
	end
end

---@param event on_entity_settings_pasted
local function onPaste(event)
	if event.destination.name ~= valve then return end
	-- read signals and update struct accordingly
	local struct = getStruct(event.destination)
	local control = struct.control
	local signal = control.get_signal(1)
	if not (signal.signal and signal.signal.name == "signal-L") then return end
	local flow = signal.count
	if flow < 0 or flow > getMaxFlow(struct.base.force) then return end
	struct.flow = flow
	gui.update_gui(struct)
end

---@param event on_gui_opened
local function onGuiOpened(event)
	local player = game.players[event.player_index]
	if event.gui_type == defines.gui_type.entity and event.entity.name == valve then
		local struct = getStruct(event.entity)
		gui.open_gui(player, struct, getMaxFlow(player.force))
	end
end

---@param player LuaPlayer
---@param struct ValveData
---@param flow number
gui.callbacks.set_flow = function(player, struct, flow)
	local max = getMaxFlow(player.force)
	if flow < 0 then flow = 0 end
	if flow > max then flow = max end
	struct.flow = flow
	struct.control.set_signal(1, {
		signal = {type="virtual", name="signal-L"},
		count = flow
	})
end

return bev.applyBuildEvents{
	on_init = function()
		global.valves = global.valves or script_data
	end,
	on_load = function()
		script_data = global.valves or script_data
	end,
	on_configuration_changed = function()
		if script_data[0] then
			local copy = table.deepcopy(script_data)
			for i in pairs(script_data) do script_data[i] = nil end
			for _,row in pairs(copy) do
				for n,s in pairs(row) do script_data[n] = s end
			end
		end
	end,
	on_build = onBuilt,
	on_destroy = onRemoved,
	events = {
		[defines.events.on_player_rotated_entity] = onRotated,
		[defines.events.on_entity_settings_pasted] = onPaste,

		[defines.events.on_gui_opened] = onGuiOpened,

		[defines.events.on_tick] = onTick
	}
}
