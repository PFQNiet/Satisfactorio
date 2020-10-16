-- a splitter that allows setting a single filter on each output
-- uses global['smart-splitters'] to track structures {base, buffer, {left1, left2}, {middle1, middle2}, {right1, right2}}
local io = require("scripts.lualib.input-output")
local getitems = require("scripts.lualib.get-items-from")

local splitter = "smart-splitter"
local buffer = "smart-splitter-box"

local slot = {
	left = 1,
	forward = 2,
	right = 3
}

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	if entity.name == splitter then
		local struct = {base=entity}
		local buffer = entity.surface.create_entity{
			name = buffer,
			position = entity.position,
			force = entity.force,
			raise_built = true
		}
		struct.buffer = buffer

		local control = entity.get_or_create_control_behavior()
		control.set_signal(slot.forward, {signal={type="virtual",name="signal-any"},count=1})
		
		local belt, inserter1, inserter2, graphic = io.addInput(entity, {0,1}, buffer)
		-- connect inserters to buffer and only enable if item count = 0
		inserter1.connect_neighbour({wire = defines.wire_type.red, target_entity = buffer})
		inserter1.get_or_create_control_behavior().circuit_condition = {condition={first_signal={type="virtual",name="signal-everything"},comparator="=",constant=0}}
		inserter2.connect_neighbour({wire = defines.wire_type.red, target_entity = buffer})
		inserter2.get_or_create_control_behavior().circuit_condition = {condition={first_signal={type="virtual",name="signal-everything"},comparator="=",constant=0}}

		-- connect inserters to base and enable when it gets a virtual signal
		belt, inserter1, inserter2, graphic = io.addOutput(entity, {0,-1}, buffer)
		inserter1.inserter_filter_mode = "whitelist"
		inserter2.inserter_filter_mode = "whitelist"
		struct.forward = {inserter1, inserter2}

		belt, inserter1, inserter2, graphic = io.addOutput(entity, {-1,0}, buffer, defines.direction.west)
		inserter1.inserter_filter_mode = "whitelist"
		inserter2.inserter_filter_mode = "whitelist"
		struct.left = {inserter1, inserter2}

		belt, inserter1, inserter2, graphic = io.addOutput(entity, {1,0}, buffer, defines.direction.east)
		inserter1.inserter_filter_mode = "whitelist"
		inserter2.inserter_filter_mode = "whitelist"
		struct.right = {inserter1, inserter2}

		entity.rotatable = false
		if not global['smart-splitters'] then global['smart-splitters'] = {} end
		table.insert(global['smart-splitters'], struct)
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
			io.removeOutput(entity, {0,-1}, event)
			io.removeOutput(entity, {-1,0}, event)
			io.removeOutput(entity, {1,0}, event)
			box.destroy()
			for i,splitter in pairs(global['smart-splitters']) do
				if splitter.base == entity then
					table.remove(global['smart-splitters'],i)
					break
				end
			end
		else
			game.print("Could not find the buffer")
		end
	end
end

local others = {
	left = {"forward","right"},
	forward = {"left","right"},
	right = {"left","forward"}
}
local function onTick(event)
	if not global['smart-splitters'] then return end
	local modulo = event.tick % 4
	for i,struct in ipairs(global['smart-splitters']) do
		if i%4 == modulo then
			local control = struct.base.get_control_behavior()
			local contents = struct.buffer.get_inventory(defines.inventory.chest)[1]
			if contents.valid_for_read then
				local valid = {}
				for dir,look in pairs(others) do
					-- first pass: everything except overflow
					local signal = (control.get_signal(slot[dir]) or {signal=nil}).signal
					if not signal then
						-- no filter set = nothing passes
					elseif signal.type == "item" then
						if signal.name == contents.name then
							table.insert(valid,dir)
						end
					elseif signal.type == "virtual" and signal.name == "signal-any" then
						table.insert(valid,dir)
					elseif signal.type == "virtual" and signal.name == "signal-any-undefined" then
						-- check the other filters and, if none of them match, then this one matches
						local undef = true
						for _,dir in pairs(look) do
							local other = (control.get_signal(slot[dir]) or {signal=nil}).signal
							if other and (
								(other.type == "item" and other.name == contents.name)
								or
								(other.type == "virtual" and other.name == "signal-any")
						 	) then
								undef = false
								break
							end
						end
						if undef then
							table.insert(valid,dir)
						end
					end
				end
				for dir,look in pairs(others) do
					-- second pass: overflow
					-- this is done in a second pass so that only options that are enabled are considered for overflowing
					-- this means that if one side takes iron and the other copper, the current item is iron, iron is full but copper isn't, copper isn't considered anyway
					local signal = (control.get_signal(slot[dir]) or {signal=nil}).signal
					if signal and signal.type == "virtual" and signal.name == "signal-overflow" then
						local overflow = true
						for _,dir in pairs(look) do
							local active = (valid[1] and valid[1] == dir) or (valid[2] and valid[2] == dir) or (valid[3] and valid[3] == dir)
							if active then
								-- check inserters to see if they are holding stuff
								-- if one of them isn't, then the lane isn't overflowed
								if not struct[dir][1].held_stack.valid_for_read or not struct[dir][2].held_stack.valid_for_read then
									overflow = false
									break
								end
							end
						end
						if overflow then
							table.insert(valid,dir)
						end
					end
				end
				local candidates = {}
				for _,dir in pairs(valid) do
					-- final pass: get inserters that aren't already holding something
					if not struct[dir][1].held_stack.valid_for_read then
						table.insert(candidates, struct[dir][1].held_stack)
					end
					if not struct[dir][2].held_stack.valid_for_read then
						table.insert(candidates, struct[dir][2].held_stack)
					end
				end
				if #candidates > 0 then
					-- found at least one candidate for receiving the item!
					local choose = math.floor(event.tick/4) % #candidates -- this should cycle through candidates equally
					candidates[choose+1].transfer_stack(contents)
				-- else the item stays stuck in the splitter's buffer until deconstructed or filters are set to allow it through
				end
			end
		end
	end
end

return {
	events = {
		[defines.events.on_tick] = onTick,

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
