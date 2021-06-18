-- scan generated chunks once per minute for any radioactive entities
-- this includes entities directly (and item-on-ground of radioactive types) but also the inventories of buildings, the transport lines of belts, inserter held items...
-- also include character/vehicle inventories, although these should be updated when the character/vehicle crosses chunk lines as well to keep things reasonably updated
-- ^ then again maybe this doesn't need to be updated too often - if you drop radioactive items, they're still right there at your feet!
-- the player takes damage if the chunk they are in is polluted, proportional to pollution but capped to 20dps
-- the hazmat suit protects the player from radiation damage, provided the player has filters (similar to the Gas Mask)
-- uses global.radioactivity.chunks to store chunks in a surface-Y-X array
-- uses global.radioactivity.buckets to spread chunks out over the course of a minute rather than trying to do them all at once
-- uses global.radioactivity.count to count the total number of chunks being tracked

local script_data = {
	enabled = true,
	chunks = {},
	buckets = {},
	count = 0
}

local bucket_metatable = {
	__index = function(tab, key)
		local raw = rawget(tab, key)
		if raw == nil then
			raw = {}
			rawset(tab, key, raw)
		end
		return raw
	end
}

-- using a 10-bit number for 1024 buckets
local function bitrev10(n)
	local rshift = bit32.rshift
	local bor = bit32.bor
	local band = bit32.band
	local lshift = bit32.lshift

	n = bor(rshift(band(n,0xFF00),8), lshift(band(n,0x00FF),8))
	n = bor(rshift(band(n,0xF0F0),4), lshift(band(n,0x0F0F),4))
	n = bor(rshift(band(n,0xCCCC),2), lshift(band(n,0x3333),2))
	n = bor(rshift(band(n,0xAAAA),1), lshift(band(n,0x5555),1))
	-- that flips a 16-bit number, so shift the result right by 6 bits to make it 10-bit again
	return rshift(n,6)
end

local function onChunkGenerated(event)
	local surface = event.surface
	local pos = event.position
	local area = event.area
	area[1] = area[1] or area.left_top
	area[1][1] = area[1][1] or area[1].x
	area[1][2] = area[1][2] or area[1].y
	area[2] = area[2] or area.right_bottom
	area[2][1] = area[2][1] or area[2].x
	area[2][2] = area[2][2] or area[2].y
	if not script_data.chunks[surface.index] then script_data.chunks[surface.index] = {} end
	local chunk = script_data.chunks[surface.index]
	if not chunk[pos.y] then chunk[pos.y] = {} end
	local entry = {
		x = pos.x,
		y = pos.y,
		surface = surface,
		area = area, -- normalised to {{x1,y1},{x2,y2}}
		radioactivity = 0,
		entities = {},
		containers = {}
	}
	chunk[pos.y][pos.x] = entry
	-- convert count to Grey number and reverse bits to get index into buckets
	-- this optimally spreads chunks out among the buckets, although honestly... 1024 buckets is gonna get filled with chunks fast so I dunno why I bothered LMAO
	local count = (script_data.count or 0) % 1024
	local grey = bit32.bxor(count, bit32.rshift(count, 1))
	local bucketindex = bitrev10(grey)
	table.insert(script_data.buckets[bucketindex], entry)
	script_data.count = count+1
end
local function getRadiationForChunk(surface, cx, cy)
	local obj = script_data.chunks
	if not obj then return 0 end
	obj = obj[surface.index]
	if not obj then return 0 end
	obj = obj[cy]
	if not obj then return 0 end
	obj = obj[cx]
	if not obj then return 0 end
	return obj.radioactivity
end

local function addRadiationForResource(entity)
	-- the only radioactive resource is uranium-ore
	return entity.name == "uranium-ore" and 10000*entity.amount/120 or 0
end
local function addRadiationForSimpleEntity(entity)
	-- the only radioactive simple entity is rock-big-uranium-ore
	return entity.name == "rock-big-uranium-ore" and 1250 or 0
end
local function addRadiationForInventory(inventory)
	if not (inventory and inventory.valid) then return 0 end
	-- once an inventory has been identified, check it for radioactive items
	local contents = inventory.get_contents()
	return (contents['uranium-ore'] or 0) * 15
		+ (contents['uranium-fuel-cell'] or 0) * 0.5
		+ (contents['nuclear-fuel'] or 0) * 50
		+ (contents['uranium-waste'] or 0) * 10
		+ (contents['non-fissile-uranium'] or 0) * 0.75
		+ (contents['plutonium-pellet'] or 0) * 20
		+ (contents['encased-plutonium-cell'] or 0) * 120
		+ (contents['plutonium-fuel-rod'] or 0) * 120
		+ (contents['plutonium-waste'] or 0) * 20
end
local function addRadiationForItemStack(stack)
	if not (stack and stack.valid and stack.valid_for_read) then return 0 end
	local radioactive_items = {
		["uranium-ore"] = 15,
		["uranium-fuel-cell"] = 0.5,
		["nuclear-fuel"] = 50,
		["uranium-waste"] = 10,
		["non-fissile-uranium"] = 0.75,
		["plutonium-pellet"] = 20,
		["encased-plutonium-cell"] = 120,
		["plutonium-fuel-rod"] = 120,
		["plutonium-waste"] = 20
	}
	
	if not radioactive_items[stack.name] then return 0 end
	return radioactive_items[stack.name] * stack.count
end

local function addRadiationForContainer(entity)
	return addRadiationForInventory(entity.get_inventory(defines.inventory.chest))
end
local function addRadiationForAssembler(entity)
	return addRadiationForInventory(entity.get_inventory(defines.inventory.fuel))
		+ addRadiationForInventory(entity.get_inventory(defines.inventory.assembling_machine_input))
		+ addRadiationForInventory(entity.get_inventory(defines.inventory.assembling_machine_output))
end
local function addRadiationForCar(entity)
	return addRadiationForInventory(entity.get_inventory(defines.inventory.fuel))
		+ addRadiationForInventory(entity.get_inventory(defines.inventory.car_trunk))
end
local function addRadiationForTrain(entity)
	return addRadiationForInventory(entity.get_inventory(defines.inventory.fuel))
end
local function addRadiationForCargoWagon(entity)
	return addRadiationForInventory(entity.get_inventory(defines.inventory.cargo_wagon))
end
local function addRadiationForSpiderVehicle(entity)
	return addRadiationForInventory(entity.get_inventory(defines.inventory.spider_trunk))
end
local function addRadiationForCharacter(entity)
	return addRadiationForInventory(entity.get_inventory(defines.inventory.character_main))
		+ addRadiationForInventory(entity.get_inventory(defines.inventory.character_trash))
		+ addRadiationForItemStack(entity.cursor_stack)
	-- no radioactive items can go in guns, armor, etc. so skip those
end
local function addRadiationForItemOnGround(entity)
	return addRadiationForItemStack(entity.stack)
end
local function addRadiationForInserter(entity)
	return addRadiationForItemStack(entity.held_stack)
end
local function addRadiationForTransportBelt(entity)
	local max = entity.get_max_transport_line_index()
	local rad = 0
	for i=1,max do
		-- transport lines are similar enough to inventories for this (ie. they have get_item_count(item) available)
		rad = rad + addRadiationForInventory(entity.get_transport_line(i))
	end
	return rad
end
local function addRadiationForUnit(entity)
	-- tamed Lizard Doggos may sometimes find Nuclear Waste, which should be accounted for
	local doggos = global.small_biter.lizard_doggos
	local stack = doggos[entity.unit_number] and doggos[entity.unit_number].helditem
	return stack and addRadiationForItemStack{
		valid = true,
		valid_for_read = true,
		name = stack.name,
		count = stack.count
	} or 0
end
local radioactivity_functions = {
	["resource"] = addRadiationForResource,
	["container"] = addRadiationForContainer,
	["assembling-machine"] = addRadiationForAssembler,
	["car"] = addRadiationForCar,
	["locomotive"] = addRadiationForTrain, -- shouldn't be used since trains are electric
	["cargo-wagon"] = addRadiationForCargoWagon,
	["spider-vehicle"] = addRadiationForSpiderVehicle,
	["character"] = addRadiationForCharacter,
	["item-entity"] = addRadiationForItemOnGround,
	["inserter"] = addRadiationForInserter,
	["transport-belt"] = addRadiationForTransportBelt,
	["underground-belt"] = addRadiationForTransportBelt,
	["splitter"] = addRadiationForTransportBelt,
	["unit"] = addRadiationForUnit,
	["simple-entity"] = addRadiationForSimpleEntity
}
local radioactive_containers = {}
for k,_ in pairs(radioactivity_functions) do
	table.insert(radioactive_containers, k)
end

local function onResolutionChanged(event)
	local player = game.players[event.player_index]
	local gui = player.gui.screen.radiation
	if gui then
		gui.location = {(player.display_resolution.width-250*player.display_scale)/2, 160*player.display_scale}
	end
end

local function updateChunk(entry)
	local surface = entry.surface
	local area = entry.area
	local x1 = area[1][1]
	local x2 = area[2][1]
	local y1 = area[1][2]
	local y2 = area[2][2]
	local entities = entry.containers
	local radiation = 0
	for i=#entities,1,-1 do
		local entity = entities[i]
		if not entity.valid then
			table.remove(entities,i)
		else
			radiation = radiation + addRadiationForContainer(entity)
		end
	end
	radiation = math.ceil(radiation/100)
	-- for many chunks, radiation won't change much, so skip update if radiation is the same as last time
	if radiation ~= entry.radioactivity then
		entry.radioactivity = radiation
		local entities = entry.entities
		-- create/remove entities to diffuse this amount of radiation per minute
		for i=0,32 do
			local entity = entities[i]
			if radiation%2 == 1 then
				if not entity then
					entities[i] = surface.create_entity{
						name = "radioactivity-"..i,
						position = {x1+0.5, y1+0.5},
						force = game.forces.neutral,
						raise_built = true
					}
				end
			else
				if entity then
					if entity.valid then entity.destroy() end
					entities[i] = nil
				end
			end
			radiation = bit32.rshift(radiation, 1)
		end
	end
	local pollution = surface.get_pollution({x1+1,y1+1})
	if pollution > 1 then
		entities = entry.behemoths
		local damage = pollution
		for i=#entities,1,-1 do
			local entity = entities[i]
			if not entity.valid then
				table.remove(entities,i)
			else
				entity.destructible = true
				entity.damage(math.min(entity.health-1, damage), game.forces.neutral, "radiation")
				entity.destructible = false
			end
		end
	end
end
local function updateGui(player, radiation)
	local gui = player.gui.screen.radiation
	if not gui then
		gui = player.gui.screen.add{
			type = "frame",
			name = "radiation",
			direction = "vertical",
			caption = {"gui.radiation"},
			style = "inner_frame_in_outer_frame"
		}
		gui.style.horizontally_stretchable = false
		gui.style.use_header_filler = false
		gui.style.width = 250
		local flow = gui.add{
			type = "flow",
			direction = "horizontal",
			name = "content"
		}
		flow.style.horizontally_stretchable = true
		flow.style.vertical_align = "center"
		local sprite = flow.add{
			type = "sprite",
			sprite = "tooltip-category-nuclear"
		}
		local bar = flow.add{
			type = "progressbar",
			name = "bar",
			style = "radioactivity-progressbar"
		}
		gui.visible = false
	end
	if radiation < 1 then
		if gui.visible then
			gui.visible = false
		end
	else
		if not gui.visible then
			gui.visible = true
			onResolutionChanged({player_index=player.index})
		end
		gui.content.bar.value = math.min(radiation/145,1)
	end
end
local function updatePlayerCharacter(player, damage)
	if player.character then
		-- radiation damage is based on pollution of the current chunk
		local radiation = player.character.surface.get_pollution(player.character.position)
			-- + getRadiationForChunk(player.surface,math.floor(player.position.x/32),math.floor(player.position.y/32))
		local pos = player.position
		local cx = pos.x
		local cy = pos.y
		local proximity = 8
		local entities = player.surface.find_entities_filtered{
			position = player.position,
			radius = proximity,
			type = radioactive_containers
		}

		for _,entity in pairs(entities) do
			local pos = entity.position
			local x = pos.x
			local y = pos.y
			local dx = x-cx
			local dy = y-cy
			local distance2 = dx*dx + dy*dy
			radiation = radiation + radioactivity_functions[entity.type](entity) / (distance2/(proximity*proximity)*90 + 10) -- falls off with square of distance
		end
		
		-- radiation = radiation + addRadiationForCharacter(player.character)/10 -- note that background radiation is /100, so this is 10x stronger
		if damage then
			if radiation >= 1 then
				local rad = radiation
				-- anything above 2k is capped
				if rad > 2000 then rad = 2000 end
				-- crude approximation of inverse-square law...
				rad = math.sqrt(rad)
				-- this gives a number between 0 and 45 or so, re-scale this to max out at 20dps
				local damage = rad/45*20
				player.character.damage(damage, game.forces.neutral, "radiation")
				-- hazmat suit is handled separately
			end
		end

		updateGui(player, radiation)
	end
end

local function onTick(event)
	if not script_data.enabled then return end
	local tick = event.tick
	local bucket = tick % 1024
	for _,entry in pairs(script_data.buckets[bucket]) do
		updateChunk(entry)
	end

	if tick%15 == 0 then
		for _,player in pairs(game.players) do
			updatePlayerCharacter(player, tick%60 == 0)
		end
	end
end

local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	-- we can assume the chunk structure exists, otherwise the player has just built something in an un-generated chunk!
	local chunk = script_data.chunks[entity.surface.index][math.floor(entity.position.y/32)][math.floor(entity.position.x/32)]
	if entity.name == "behemoth-worm-turret" then
		table.insert(chunk.behemoths, entity)
		return
	end

	if entity.type ~= "container" then return end
	-- exclude fake boxes used in splitters and mergers, as they may only hold one item at a time so contribute negligible radiation to the chunk
	if entity.name == "conveyor-merger-box" then return end
	if entity.name == "conveyor-splitter-box" then return end
	if entity.name == "smart-splitter-box" then return end
	if entity.name == "programmable-splitter-box" then return end
	-- add this entity to the chunk's list of containers
	table.insert(chunk.containers, entity)
end

return {
	on_init = function()
		if not global.radioactivity then
			setmetatable(script_data.buckets, bucket_metatable)
		end

		global.radioactivity = global.radioactivity or script_data
		global.radioactivity.enabled = game.map_settings.pollution.enabled
	end,
	on_load = function()
		script_data = global.radioactivity or script_data
		setmetatable(script_data.buckets, bucket_metatable)
	end,
	on_configuration_changed = function()
		local data = global.radioactivity
		if not data then return end
		if script.level.is_simulation then
			data.enabled = false
			return
		end
		if data.enabled == nil then
			data.enabled = game.map_settings.pollution.enabled
		end
		if data.chunks[1] and data.chunks[1][0] and data.chunks[1][0][0] and not data.chunks[1][0][0].containers then
			-- find existing containers, but not splitter/merger fake boxes, and list them
			for surface,chunks in pairs(data.chunks) do
				for y,row in pairs(chunks) do
					for x,chunk in pairs(row) do
						local area = chunk.area
						local x1 = area[1][1]
						local y1 = area[1][2]
						local x2 = area[2][1]
						local y2 = area[2][2]
						chunk.containers = {}
						local entities = game.surfaces[surface].find_entities_filtered{
							area = area,
							type = "container"
						}
						for _,entity in pairs(entities) do
							if entity.name ~= "conveyor-merger-box"
							and entity.name ~= "conveyor-splitter-box"
							and entity.name ~= "smart-splitter-box"
							and entity.name ~= "programmable-splitter-box" then
								local pos = entity.position
								local x = pos.x
								local y = pos.y
								-- ensure entity's position is in fact within the bounding box, since find_entities_filtered will find entities even if they just overlap the area slightly
								if x >= x1 and x < x2 and y >= y1 and y < y2 then
									table.insert(chunk.containers, entity)
								end
							end
						end
					end
				end
			end
		end
		if data.chunks[1] and data.chunks[1][0] and data.chunks[1][0][0] and not data.chunks[1][0][0].behemoths then
			-- find existing Behemoth Worms and list them
			for surface,chunks in pairs(data.chunks) do
				for y,row in pairs(chunks) do
					for x,chunk in pairs(row) do
						local area = chunk.area
						local x1 = area[1][1]
						local y1 = area[1][2]
						local x2 = area[2][1]
						local y2 = area[2][2]
						chunk.behemoths = {}
						local entities = game.surfaces[surface].find_entities_filtered{
							area = area,
							name = "behemoth-worm-turret"
						}
						for _,entity in pairs(entities) do
							local pos = entity.position
							local x = pos.x
							local y = pos.y
							-- ensure entity's position is in fact within the bounding box, since find_entities_filtered will find entities even if they just overlap the area slightly
							if x >= x1 and x < x2 and y >= y1 and y < y2 then
								table.insert(chunk.behemoths, entity)
							end
						end
					end
				end
			end
		end
	end,
	add_commands = function()
		if not commands.commands['toggle-radiation'] then
			commands.add_command("toggle-radiation",{"command.toggle-radiation"},function(event)
				local player = game.players[event.player_index]
				if player.admin then
					if script_data.enabled then
						script_data.enabled = false
						game.map_settings.pollution.enabled = false
						game.print({"message.radiation-disabled",player.name})
					else
						script_data.enabled = true
						game.map_settings.pollution.enabled = true
						game.print({"message.radiation-enabled",player.name})
					end
				end
			end)
		end
	end,
	events = {
		[defines.events.on_chunk_generated] = onChunkGenerated,
		[defines.events.on_tick] = onTick,

		[defines.events.on_built_entity] = onBuilt,
		[defines.events.on_robot_built_entity] = onBuilt,
		[defines.events.script_raised_built] = onBuilt,
		[defines.events.script_raised_revive] = onBuilt,
		-- removing entities will invalidate them, which will be detected when the chunk is scanned

		[defines.events.on_player_display_resolution_changed] = onResolutionChanged,
		[defines.events.on_player_display_scale_changed] = onResolutionChanged
	}
}
