local io = require("scripts.lualib.input-output")
local getitems = require("scripts.lualib.get-items-from")

local splitter = "conveyor-merger"
local buffer = "conveyor-merger-box"

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == splitter then
		local buffer = entity.surface.create_entity{
			name = buffer,
			position = entity.position,
			force = entity.force,
			raise_built = true
		}
		local inputs = {
			{position={0,1}, direction=defines.direction.north},
			{position={1,0}, direction=defines.direction.west},
			{position={-1,0}, direction=defines.direction.east}
		}
		for _,pos in pairs(inputs) do
			local belt, inserter1, inserter2, graphic = io.addInput(entity, pos.position, buffer, pos.direction)
			-- connect inserters to buffer and only enable if item count = 0
			inserter1.connect_neighbour({
				wire = defines.wire_type.red,
				target_entity = buffer
			})
			inserter1.get_or_create_control_behavior().circuit_condition = {condition={first_signal={type="virtual",name="signal-everything"},comparator="=",constant=0}}
			inserter2.connect_neighbour({
				wire = defines.wire_type.red,
				target_entity = buffer
			})
			inserter2.get_or_create_control_behavior().circuit_condition = {condition={first_signal={type="virtual",name="signal-everything"},comparator="=",constant=0}}
		end

		io.addOutput(entity, {0,-1}, buffer)
		entity.operable = false
		entity.rotatable = false
		entity.destructible = false
	end
end

local function onRemoved(event)
	local entity = event.entity
	if not entity or not entity.valid then return end
	if entity.name == splitter then
		local box = entity.surface.find_entity(buffer, entity.position)
		if box and box.valid then
			getitems.storage(box, event.buffer)
			io.removeInput(entity, {0,1}, event)
			io.removeInput(entity, {-1,0}, event)
			io.removeInput(entity, {1,0}, event)
			io.removeOutput(entity, {0,-1}, event)
			box.destroy()
		else
			game.print("Could not find the buffer")
		end
	end
end

return {
	events = {
		[defines.events.on_built_entity] = onBuilt,
		[defines.events.on_robot_built_entity] = onBuilt,
		[defines.events.script_raised_built] = onBuilt,
		[defines.events.script_raised_revive] = onBuilt,

		[defines.events.on_player_mined_entity] = onRemoved,
		[defines.events.on_robot_mined_entity] = onRemoved,
		[defines.events.on_entity_died] = onRemoved,
		[defines.events.script_raised_destroy] = onRemoved
	}
}