local string = require("scripts.lualib.string")

local function onMined(event)
	local entity = event.entity
	if not (entity and entity.valid) then return end
	if entity.type == "resource" and entity.amount == 240 then -- 240 is a pure resource node
		-- pure resource nodes should only yield 3 items, not 4
		local buffer = event.buffer
		buffer[1].count = 3
	end
	if entity.type == "tree" then
		local buffer = event.buffer
		buffer.clear()
		buffer.insert{name="wood",count=math.random(1,2)}
		-- do some fancy shenanigans to add extras to trees
		-- if it's not a dead tree...
		if entity.name ~= "dead-dry-hairy-tree" and entity.name ~= "dead-grey-trunk" and entity.name ~= "dead-tree-desert" and entity.name ~= "dry-hairy-tree" and entity.name ~= "dry-tree" then
			buffer.insert{name="leaves",count=math.random(4,10)}
		end
		-- they'll give Leaves and Wood, but may also give Mycelia (dirt), Flower Petals (grass), Limestone (sand) or Silica (desert) based on the tile
		local tile = entity.surface.get_tile(entity.position).name
		if string.starts_with(tile,"grass") then
			local count = math.floor(math.random(1,5)*math.random(1,5)/5) -- 0-5
			if count > 0 then
				buffer.insert{name="flower-petals",count=count}
			end
		end
		if string.starts_with(tile,"sand") then
			local count = math.floor(math.random(1,4)*math.random(1,4)/4)*2 -- 0,2,4,6,8
			if count > 0 then
				buffer.insert{name="stone",count=count}
			end
		end
		if string.starts_with(tile,"dirt") then
			local count = math.floor(math.random(1,5)*math.random(1,5)/5) -- 0-5
			if count > 0 then
				buffer.insert{name="mycelia",count=count}
			end
		end
		if string.starts_with(tile,"red-desert") then
			local count = math.floor(math.random(1,5)*math.random(1,5)/5) -- 0-5
			if count > 0 then
				--buffer.insert{name="silica",count=count}
			end
		end
	end
end

return {
	events = {
		[defines.events.on_player_mined_entity] = onMined,
		[defines.events.on_robot_mined_entity] = onMined
	}
}