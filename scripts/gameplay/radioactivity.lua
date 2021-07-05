-- scan generated chunks once per minute for any radioactive containers
-- the player takes damage if the chunk they are in is polluted, or they are standing near radioactive items, proportional to pollution but capped to 20dps
-- the hazmat suit protects the player from radiation damage, provided the player has filters (similar to the Gas Mask)

local bev = require(modpath.."scripts.lualib.build-events")

---@class RadioactiveChunkData
---@field id uint Identifier given to this chunk
---@field x int
---@field y int
---@field surface LuaSurface,
---@field area BoundingBox
---@field radioactivity number
---@field entities LuaEntity[] Radiation emitters
---@field containers LuaEntity[] Containers built on this chunk
---@field behemoths LuaEntity[] Behemoth Worms ("gas emitters") may be weakened by exposure to radiation

---@class global.radioactivity
---@field enabled boolean
---@field chunks RadioactiveChunkData[] Surface.Y.X => chunk
---@field buckets RadioactiveChunkData[] Grouped based on index
---@field count uint
local script_data = {
	enabled = true,
	chunks = {},
	buckets = {},
	count = 0
}

-- each chunk will be visited every 30 seconds
local bucket_count = 1800

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

---@param surface LuaSurface
---@param chunkpos ChunkPosition
---@return RadioactiveChunkData
local function getOrCreateChunk(surface, chunkpos)
	local x = chunkpos.x or chunkpos[1]
	local y = chunkpos.y or chunkpos[2]
	local ref = surface.index.."."..y.."."..x
	if not script_data.chunks[ref] then
		local id = script_data.count + 1
		script_data.count = id
		script_data.chunks[ref] = {
			id = id,
			x = x,
			y = y,
			surface = surface,
			area = {{x*32,y*32},{(x+1)*32,(y+1)*32}},
			radioactivity = 0,
			entities = {},
			containers = {},
			behemoths = {}
		}
		table.insert(script_data.buckets[id % bucket_count], script_data.chunks[ref])
	end
	return script_data.chunks[ref]
end
local function getBucket(tick)
	return script_data.buckets[tick % bucket_count]
end

---@param event on_chunk_generated
local function onChunkGenerated(event)
	local surface = event.surface
	local pos = event.position
	getOrCreateChunk(surface, pos)
end

---@param entity LuaEntity Resource
local function addRadiationForResource(entity)
	-- the only radioactive resource is uranium-ore
	return entity.name == "uranium-ore" and 10000*entity.amount/120 or 0
end
---@param entity LuaEntity SimpleEntity
local function addRadiationForSimpleEntity(entity)
	-- the only radioactive simple entity is rock-big-uranium-ore
	return entity.name == "rock-big-uranium-ore" and 1250 or 0
end
---@param inventory LuaInventory
local function addRadiationForInventory(inventory)
	if not (inventory and inventory.valid) then return 0 end
	-- once an inventory has been identified, check it for radioactive items
	local contents = inventory.get_contents()
	return (contents['uranium-ore'] or 0) * 15
		+ (contents['encased-uranium-cell'] or 0) * 0.5
		+ (contents['uranium-fuel-rod'] or 0) * 50
		+ (contents['uranium-waste'] or 0) * 10
		+ (contents['non-fissile-uranium'] or 0) * 0.75
		+ (contents['plutonium-pellet'] or 0) * 20
		+ (contents['encased-plutonium-cell'] or 0) * 120
		+ (contents['plutonium-fuel-rod'] or 0) * 120
		+ (contents['plutonium-waste'] or 0) * 20
end
---@param stack LuaItemStack
local function addRadiationForItemStack(stack)
	if not (stack and stack.valid and stack.valid_for_read) then return 0 end
	local radioactive_items = {
		["uranium-ore"] = 15,
		["encased-uranium-cell"] = 0.5,
		["uranium-fuel-rod"] = 50,
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

---@param entity LuaEntity Container
local function addRadiationForContainer(entity)
	return addRadiationForInventory(entity.get_inventory(defines.inventory.chest))
end
---@param entity LuaEntity AssemblingMachine
local function addRadiationForAssembler(entity)
	return addRadiationForInventory(entity.get_inventory(defines.inventory.fuel))
		+ addRadiationForInventory(entity.get_inventory(defines.inventory.assembling_machine_input))
		+ addRadiationForInventory(entity.get_inventory(defines.inventory.assembling_machine_output))
end
---@param entity LuaEntity Car
local function addRadiationForCar(entity)
	return addRadiationForInventory(entity.get_inventory(defines.inventory.fuel))
		+ addRadiationForInventory(entity.get_inventory(defines.inventory.car_trunk))
end
---@param entity LuaEntity Locomotive
local function addRadiationForTrain(entity)
	return addRadiationForInventory(entity.get_inventory(defines.inventory.fuel))
end
---@param entity LuaEntity CargoWagon
local function addRadiationForCargoWagon(entity)
	return addRadiationForInventory(entity.get_inventory(defines.inventory.cargo_wagon))
end
---@param entity LuaEntity SpiderVehicle
local function addRadiationForSpiderVehicle(entity)
	return addRadiationForInventory(entity.get_inventory(defines.inventory.spider_trunk))
end
---@param entity LuaEntity Character
local function addRadiationForCharacter(entity)
	return addRadiationForInventory(entity.get_inventory(defines.inventory.character_main))
		+ addRadiationForInventory(entity.get_inventory(defines.inventory.character_trash))
		+ addRadiationForItemStack(entity.cursor_stack)
	-- no radioactive items can go in guns, armor, etc. so skip those
end
---@param entity LuaEntity ItemEntity
local function addRadiationForItemOnGround(entity)
	return addRadiationForItemStack(entity.stack)
end
---@param entity LuaEntity Inserter
local function addRadiationForInserter(entity)
	return addRadiationForItemStack(entity.held_stack)
end
---@param entity LuaEntity TransportBelt
local function addRadiationForTransportBelt(entity)
	local max = entity.get_max_transport_line_index()
	local rad = 0
	for i=1,max do
		-- transport lines are similar enough to inventories for this (ie. they have get_contents() available)
		rad = rad + addRadiationForInventory(entity.get_transport_line(i))
	end
	return rad
end
-- tamed Lizard Doggos may sometimes find Nuclear Waste, which should be accounted for
---@param entity LuaEntity Unit
local function addRadiationForUnit(entity)
	---@type global.pets
	local petdata = global.pets
	local doggos = petdata.lizard_doggos
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
for k in pairs(radioactivity_functions) do
	table.insert(radioactive_containers, k)
end

---@param event on_player_display_resolution_changed
local function onResolutionChanged(event)
	local player = game.players[event.player_index]
	local gui = player.gui.screen['radiation']
	if gui then
		gui.location = {(player.display_resolution.width-250*player.display_scale)/2, 160*player.display_scale}
	end
end

---@param entry RadioactiveChunkData
local function updateChunk(entry)
	local surface = entry.surface
	local area = entry.area
	local x1 = area[1][1]
	local x2 = area[2][1]
	local y1 = area[1][2]
	local y2 = area[2][2]

	local containers = entry.containers
	local radiation = 0
	for i=#containers,1,-1 do
		local entity = containers[i]
		if not entity.valid then
			table.remove(containers,i)
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
		local worms = entry.behemoths
		local damage = pollution * 2
		for i=#worms,1,-1 do
			local entity = worms[i]
			if not entity.valid then
				table.remove(worms,i)
			else
				entity.destructible = true
				entity.damage(math.min(entity.health-1, damage), game.forces.neutral, "radiation")
				entity.destructible = false
			end
		end
	end
end

---@param player LuaPlayer
---@param radiation number
local function updateGui(player, radiation)
	local screen = player.gui.screen
	if not screen['radiation'] then
		local gui = player.gui.screen.add{
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
		flow.add{
			type = "sprite",
			sprite = "tooltip-category-nuclear"
		}
		flow.add{
			type = "progressbar",
			name = "bar",
			style = "radioactivity-progressbar"
		}
		gui.visible = false
	end
	local gui = screen['radiation']
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
---@param player LuaPlayer
---@param do_damage boolean
local function updatePlayerCharacter(player, do_damage)
	if player.character then
		-- radiation damage is based on pollution of the current chunk
		local radiation = player.character.surface.get_pollution(player.character.position)
		-- + local entities
		local pos = player.position
		local cx = pos.x
		local cy = pos.y
		local proximity = 12
		local entities = player.surface.find_entities_filtered{
			position = player.position,
			radius = proximity,
			type = radioactive_containers
		}

		for _,entity in pairs(entities) do
			local pos2 = entity.position
			local x = pos2.x
			local y = pos2.y
			local dx = x-cx
			local dy = y-cy
			local distance2 = dx*dx + dy*dy
			radiation = radiation + radioactivity_functions[entity.type](entity) / (distance2/(proximity*proximity)*90 + 10) -- falls off with square of distance
		end

		-- radiation = radiation + addRadiationForCharacter(player.character)/10 -- note that background radiation is /100, so this is 10x stronger
		if do_damage then
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

---@param event on_tick
local function onTick(event)
	if not script_data.enabled then return end
	local tick = event.tick
	for _,entry in pairs(getBucket(tick)) do
		updateChunk(entry)
	end

	if tick%10 == 0 then
		for _,player in pairs(game.players) do
			updatePlayerCharacter(player, tick%60 == 0)
		end
	end
end

---@param event on_build
local function onBuilt(event)
	local entity = event.created_entity or event.entity
	if not entity or not entity.valid then return end
	local chunk = getOrCreateChunk(entity.surface, {math.floor(entity.position.x/32), math.floor(entity.position.x/32)})
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

return bev.applyBuildEvents{
	on_init = function()
		if not global.radioactivity then
			setmetatable(script_data.buckets, bucket_metatable)
		end

		global.radioactivity = global.radioactivity or script_data
		global.radioactivity.enabled = game.map_settings['pollution'].enabled
	end,
	on_load = function()
		script_data = global.radioactivity or script_data
		setmetatable(script_data.buckets, bucket_metatable)
	end,
	add_commands = function()
		if not commands.commands['toggle-radiation'] then
			commands.add_command("toggle-radiation",{"command.toggle-radiation"},function(event)
				local player = game.players[event.player_index]
				if player.admin then
					if script_data.enabled then
						script_data.enabled = false
						game.map_settings['pollution'].enabled = false
						game.print({"message.radiation-disabled",player.name})
					else
						script_data.enabled = true
						game.map_settings['pollution'].enabled = true
						game.print({"message.radiation-enabled",player.name})
					end
				end
			end)
		end
	end,
	on_build = onBuilt,
	-- removing entities will invalidate them, which will be detected when the chunk is scanned
	events = {
		[defines.events.on_chunk_generated] = onChunkGenerated,
		[defines.events.on_tick] = onTick,

		[defines.events.on_player_display_resolution_changed] = onResolutionChanged,
		[defines.events.on_player_display_scale_changed] = onResolutionChanged
	}
}
