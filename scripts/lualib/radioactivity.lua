-- scan generated chunks once per minute for any radioactive entities
-- this includes entities directly (and item-on-ground of radioactive types) but also the inventories of buildings, the transport lines of belts, inserter held items...
-- also include character/vehicle inventories, although these should be updated when the character/vehicle crosses chunk lines as well to keep things reasonably updated
-- ^ then again maybe this doesn't need to be updated too often - if you drop radioactive items, they're still right there at your feet!
-- the player takes damage if the chunk they are in is polluted, proportional to pollution but capped to 20dps
-- the hazmat suit protects the player from radiation damage, provided the player has filters (similar to the Gas Mask)
-- uses global['rad-chunks'] to store chunks in a surface-Y-X array
-- uses global['rad-buckets'] to spread chunks out over the course of a minute rather than trying to do them all at once
-- uses global['rad-chunks-count'] to count the total number of chunks being tracked
local mod_gui = require("mod-gui")

-- using a 10-bit number for 1024 buckets
local function bitrev10(n)
	n = bit32.bor(bit32.rshift(bit32.band(n,0xFF00),8), bit32.lshift(bit32.band(n,0x00FF),8))
	n = bit32.bor(bit32.rshift(bit32.band(n,0xF0F0),4), bit32.lshift(bit32.band(n,0x0F0F),4))
	n = bit32.bor(bit32.rshift(bit32.band(n,0xCCCC),2), bit32.lshift(bit32.band(n,0x3333),2))
	n = bit32.bor(bit32.rshift(bit32.band(n,0xAAAA),1), bit32.lshift(bit32.band(n,0x5555),1))
	-- that flips a 16-bit number, so shift the result right by 6 bits to make it 10-bit again
	return bit32.rshift(n,6)
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
	if not global['rad-chunks'] then global['rad-chunks'] = {} end
	if not global['rad-chunks'][surface.index] then global['rad-chunks'][surface.index] = {} end
	if not global['rad-chunks'][surface.index][pos.y] then global['rad-chunks'][surface.index][pos.y] = {} end
	local entry = {
		x = pos.x,
		y = pos.y,
		surface = surface,
		area = area, -- normalised to {{x1,y1},{x2,y2}}
		radioactivity = 0,
		entities = {}
	}
	global['rad-chunks'][surface.index][pos.y][pos.x] = entry
	-- convert count to Grey number and reverse bits to get index into buckets
	-- this optimally spreads chunks out among the buckets, although honestly... 1024 buckets is gonna get filled with chunks fast so I dunno why I bothered LMAO
	local count = (global['rad-chunks-count'] or 0) % 1024
	local grey = bit32.bxor(count, bit32.rshift(count, 1))
	local bucketindex = bitrev10(grey)
	if not global['rad-buckets'] then global['rad-buckets'] = {} end
	if not global['rad-buckets'][bucketindex] then global['rad-buckets'][bucketindex] = {} end
	table.insert(global['rad-buckets'][bucketindex], entry)
	global['rad-chunks-count'] = count+1
end
local function getRadiationForChunk(surface, cx, cy)
	if not global['rad-chunks'] then return 0 end
	if not global['rad-chunks'][surface.index] then return 0 end
	if not global['rad-chunks'][surface.index][cy] then return 0 end
	if not global['rad-chunks'][surface.index][cy][cx] then return 0 end
	return global['rad-chunks'][surface.index][cy][cx].radioactivity
end

local radioactive_items = {
	["uranium-ore"] = 15,
	["uranium-pellet"] = 7.5,
	["uranium-fuel-cell"] = 7.5,
	["nuclear-fuel"] = 60,
	["nuclear-waste"] = 20
}

local function addRadiationForResource(entity)
	-- the only radioactive resource is uranium-ore
	return entity.name == "uranium-ore" and 10000*entity.amount/120 or 0
end
local function addRadiationForInventory(inventory)
	if not (inventory and inventory.valid) then return 0 end
	-- once an inventory has been identified, check it for radioactive items
	local rad = 0
	for name,strength in pairs(radioactive_items) do
		rad = rad + strength * inventory.get_item_count(name)
	end
	return rad
end
local function addRadiationForItemStack(stack)
	if not (stack and stack.valid and stack.valid_for_read) then return 0 end
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
local radioactivity_functions = {
	["resource"] = addRadiationForResource,
	["container"] = addRadiationForContainer,
	["assembling-machine"] = addRadiationForAssembler,
	["car"] = addRadiationForCar,
	["locomotive"] = addRadiationForTrain, -- shouldn't be used since trains are electric
	["cargo-wagon"] = addRadiationForCargoWagon,
	["character"] = addRadiationForCharacter,
	["item-entity"] = addRadiationForItemOnGround,
	["inserter"] = addRadiationForInserter,
	["transport-belt"] = addRadiationForTransportBelt,
	["underground-belt"] = addRadiationForTransportBelt,
	["splitter"] = addRadiationForTransportBelt
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
local function onTick(event)
	local tick = event.tick
	local bucket = tick % 1024
	if global['rad-buckets'] and global['rad-buckets'][bucket] then
		for _,entry in pairs(global['rad-buckets'][bucket]) do
			local area = entry.area
			local entities = entry.surface.find_entities_filtered{
				area = area,
				type = radioactive_containers
			}
			local radiation = 0
			for _,entity in pairs(entities) do
				-- ensure entity's position is in fact within the bounding box, since find_entities_filtered will find entities even if they just overlap the area slightly
				if entity.position.x >= area[1][1] and entity.position.x < area[2][1] and entity.position.y >= area[1][2] and entity.position.y < area[2][2] then
					radiation = radiation + radioactivity_functions[entity.type](entity)
				end
			end
			radiation = math.floor(radiation/100)
			entry.radioactivity = radiation
			-- create/remove entities to diffuse this amount of radiation per minute
			for i=0,32 do
				if radiation%2 == 1 then
					if not entry.entities[i] then
						entry.entities[i] = entry.surface.create_entity{
							name = "radioactivity-"..i,
							position = {entry.area[1][1]+0.5, entry.area[1][2]+0.5},
							force = game.forces.neutral,
							raise_built = true
						}
					end
				else
					if entry.entities[i] then
						if entry.entities[i].valid then entry.entities[i].destroy() end
						entry.entities[i] = nil
					end
				end
				radiation = bit32.rshift(radiation, 1)
			end
		end
	end
	if tick%6 == 0 then
		for _,player in pairs(game.players) do
			if player.character then
				-- radiation damage is based on pollution of the current chunk
				local radiation = player.character.surface.get_pollution(player.character.position)
					+ getRadiationForChunk(player.surface,math.floor(player.position.x/32),math.floor(player.position.y/32))
					+ addRadiationForCharacter(player.character)/10
				if tick%60 == 0 then
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
				local gui = player.gui.screen.radiation
				if not gui then
					gui = player.gui.screen.add{
						type = "frame",
						name = "radiation",
						direction = "vertical",
						caption = {"gui.radiation"},
						style = mod_gui.frame_style
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
		end
	end
end

return {
	events = {
		[defines.events.on_chunk_generated] = onChunkGenerated,
		[defines.events.on_tick] = onTick,

		[defines.events.on_player_display_resolution_changed] = onResolutionChanged,
		[defines.events.on_player_display_scale_changed] = onResolutionChanged
	}
}
