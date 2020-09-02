return {
	events = {
		[defines.events.on_player_mined_entity] = function(event)
			local entity = event.entity
			if entity and entity.valid and entity.type == "resource" and entity.amount == 240 then -- 240 is a pure resource node
				-- pure resource nods should only yield 3 items, not 4
				local buffer = event.buffer
				buffer[1].count = 3
			end
		end
	}
}