--[[
	Resources are spawned using a poisson-disc distribution, with the small change that nodes outside the bounding box of the generated map are "asleep"
	Sleeping nodes won't be considered for expansion until the bounding box of generated chunks contains them
	Uses global['queued-nodes'] to track nodes that should have spawned, but whose location wasn't generated yet
	Uses global['resource-node-count'] to store a running total of open nodes
	Uses global['resources'] to store data relating to resource generation
	Each resource is a table: {
		r = radius, nodes will spawn between r and 2r tiles away from any other nodes
		k = attempts to spawn a node before considering the node "closed" (30)
		value = how strongly it should be defended (0-6)
		size = {min,max} range for total purity value of node cluster, where impure=1, normal=2, pure=4
		gridsize = r/sqrt(2)
		grid = grid size ensures there can only ever be one node in a grid square and allows for much faster checking of proximity
			the grid is indexed by cell coordinates (y, then x), and contains the precise location of the node
			it starts with {0,0} as a seed, but a resource node won't be created there
			grid is also used for the Resource Scanner to find nodes as it scans outwards from the player's position on use
		nodes = list of open nodes - if a node is checked for expansion but is out of range, it is moved to sleep instead
		sleep = list of sleeping nodes - when the generated map is expanded they are moved to open nodes (and may be immediately put back to sleep again)
		(grid, nodes, sleep) are grouped by surface index
	}
	When spawned, a "node" can actually be a cluster of resource nodes, akin to oil patches in vanilla
	Special resource "types": x-plant, x-deposit, x-powerslug, x-crashsite
]]
local crash_site = require("scripts.lualib.crash-sites")
local enemies = require("scripts.lualib.enemy-spawning")

local function registerResource(name, radius, min, max, value)
	if global['resources'][name] then return end
	local settings = game.default_map_gen_settings.autoplace_controls[name] or {frequency=1,richness=1,size=1}
	if settings.size == 0 then return end

	-- settings are supposed to be in the range 1/6 to 6
	-- frequency affects the radius at which things spawn
	-- example: to make things 6x more common, divide the radius by sqrt(6)
	if name == "x-plant" or name == "x-deposit" then
		-- plants and deposits use the inverse for... some reason
		radius = radius * math.sqrt(settings.frequency)
		-- "size" should also affect "richness" - although richness isn't used for deposits
		min = math.ceil(min * settings.size)
		max = math.ceil(max * settings.size)
	else
		radius = radius / math.sqrt(settings.frequency)
		-- within a node, richness affects min/max setting
		min = math.ceil(min * settings.richness)
		max = math.ceil(max * settings.richness)
	end
	-- buffer determines how big a space the resource node reserves for itself (+2 border) and spreads its contents
	local buffer = 8 * math.sqrt(settings.size) -- setting size too small may result in just single nodes as there's nowhere to spawn others!

	global['resources'][name] = {
		type = name,
		r = radius,
		border = buffer,
		k = 30,
		value = value,
		size = {min,max},
		gridsize = radius/math.sqrt(2),
		grid = {},
		nodes = {},
		sleep = {}
	}
end
local function registerSurface(surface)
	for _,struct in pairs(global['resources']) do
		struct.nodes[surface.index] = {{0,0}}
		struct.sleep[surface.index] = {}
		struct.grid[surface.index] = {[0]={[0]={0,0}}}
		global['resource-node-count'] = global['resource-node-count'] + 1
	end
end

local function queueEntity(entity, surface, chunkpos)
	if not global['queued-nodes'] then global['queued-nodes'] = {} end
	if not global['queued-nodes'][surface.index] then global['queued-nodes'][surface.index] = {} end
	if not global['queued-nodes'][surface.index][chunkpos.y] then global['queued-nodes'][surface.index][chunkpos.y] = {} end
	if not global['queued-nodes'][surface.index][chunkpos.y][chunkpos.x] then global['queued-nodes'][surface.index][chunkpos.y][chunkpos.x] = {} end
	table.insert(global['queued-nodes'][surface.index][chunkpos.y][chunkpos.x], entity)
end
local function getQueuedEntities(surface, chunkpos)
	return global['queued-nodes']
		and global['queued-nodes'][surface.index]
		and global['queued-nodes'][surface.index][chunkpos.y]
		and global['queued-nodes'][surface.index][chunkpos.y][chunkpos.x]
		or nil
end
local function clearQueuedEntities(surface, chunkpos)
	-- only called if it has been processed, therefore indices must exist already
	global['queued-nodes'][surface.index][chunkpos.y][chunkpos.x] = nil
end

local function spawnNode(resource, surface, cx, cy)
	-- scatter a cluster of nodes, of total purity value between the bounds defined on the resource data, within a radius of 4-8 using a mini-poisson distribution
	local purity = math.random(resource.size[1], resource.size[2])
	local points = {}
	-- just generate local points within radius 4-8 and check against all others - it's so small that the "grid" method doesn't do anything for us.
	for _=1,30 do
		local theta = math.random()*math.pi*2
		local r = math.sqrt(math.random())*resource.border
		local x = math.cos(theta)*r
		local y = math.sin(theta)*r
		local ok = true
		for _,p in pairs(points) do
			local dx = p[1]-x
			local dy = p[2]-y
			if dx*dx+dy*dy < 4.5*4.5 then
				ok = false
				break
			end
		end
		if ok then
			table.insert(points, {x,y})
			local pval = math.random(1,4)
			if pval > purity then pval = purity end
			if pval == 3 then pval = 2 end
			if resource.type == "x-plant" then
				pval = 1 -- "purity" is just the number of plants
				-- "plant" spawns bacon agaric where elevation is near or below 0, paleberry when moisture is >50% and beryl nut otherwise
				local tx = cx+math.floor(x+0.5)
				local ty = cy+math.floor(y+0.5)
				local chunkpos = {x=math.floor(tx/32), y=math.floor(ty/32)}
				local tiledata = surface.calculate_tile_properties({"elevation","moisture"},{{tx,ty}})
				local elevation = tiledata.elevation[1]
				local moisture = tiledata.moisture[1]
				local plant = "bacon-agaric"
				if elevation > 5 then
					plant = moisture < 0.5 and "beryl-nut" or "paleberry"
				end
				local entity = {
					name = plant,
					position = {tx,ty},
					force = game.forces.neutral
				}
				if not surface.is_chunk_generated({chunkpos.x, chunkpos.y}) then
					queueEntity(entity, surface, chunkpos)
				else
					entity.position = surface.find_non_colliding_position(entity.name, entity.position, 0, 1, true)
					surface.create_entity(entity)
				end
			elseif resource.type == "x-deposit" then
				pval = purity -- just a single deposit
				local tiers = {1,1,1,1,1,1,2,2,2,3}
				local deposits = {
					{"rock-big-iron-ore","rock-big-copper-ore","rock-big"},
					{"rock-big-coal","rock-big-caterium-ore","rock-big-raw-quartz"},
					{"rock-big-sulfur","rock-big-bauxite"}
				}
				local tier = tiers[math.random(#tiers)]
				local deposit = deposits[tier][math.random(#deposits[tier])]
				local tx = cx+x+0.5
				local ty = cy+y+0.5
				local chunkpos = {x=math.floor(tx/32), y=math.floor(ty/32)}
				local entity = {
					name = deposit,
					position = {tx,ty},
					force = game.forces.neutral,
					raise_built = true
				}
				if not surface.is_chunk_generated({chunkpos.x, chunkpos.y}) then
					queueEntity(entity, surface, chunkpos)
				else
					surface.create_entity(entity)
				end
			elseif resource.type == "x-powerslug" then
				pval = purity -- always just a single slug, purity value affects rarity of slug
				local tiers = {"green","green","green","green","green","green","yellow","yellow","yellow","purple"}
				local slug = tiers[pval].."-power-slug"
				resource.value = math.ceil(pval/2) -- remap 1-10 as 1-5
				local tx = cx+x+0.5
				local ty = cy+y+0.5
				local chunkpos = {x=math.floor(tx/32), y=math.floor(ty/32)}
				local entity = {
					name = slug,
					position = {tx,ty},
					force = game.forces.neutral,
					raise_built = true
				}
				if not surface.is_chunk_generated({chunkpos.x, chunkpos.y}) then
					queueEntity(entity, surface, chunkpos)
					if math.random()<0.2 then
						queueEntity({
							name = "rock-huge",
							position = entity.position,
							nobump = true,
							force = game.forces.neutral,
							raise_built = true
						}, surface, chunkpos)
					end
				else
					surface.create_entity(entity)
					if math.random()<0.2 then
						surface.create_entity({
							name = "rock-huge",
							position = entity.position,
							force = game.forces.neutral,
							raise_built = true
						}, surface, chunkpos)
					end
				end
			elseif resource.type == "x-crashsite" then
				pval = purity -- always just one crash site
				local tx = cx+x+0.5
				local ty = cy+y+0.5
				local chunkpos = {x=math.floor(tx/32), y=math.floor(ty/32)}
				if not surface.is_chunk_generated({chunkpos.x, chunkpos.y}) then
					queueEntity({name="x-crashsite",position={tx,ty}}, surface, chunkpos)
				else
					crash_site.createCrashSite(surface, {tx,ty})
				end
			else
				local tx = cx+math.floor(x+0.5)
				local ty = cy+math.floor(y+0.5)
				local chunkpos = {x=math.floor(tx/32), y=math.floor(ty/32)}
				local entity = {
					name = resource.type,
					position = {tx,ty},
					force = game.forces.neutral,
					amount = 60*pval
				}
				if not surface.is_chunk_generated({chunkpos.x, chunkpos.y}) then
					queueEntity(entity, surface, chunkpos)
					if resource.type == "iron-ore" or resource.type == "copper-ore" or (resource.type == "stone" and math.random()<0.5) then
						queueEntity({
							name = resource.type == "stone" and "rock-big" or "rock-big-"..resource.type,
							position = entity.position,
							nobump = true,
							force = game.forces.neutral
						}, surface, chunkpos)
					elseif math.random()<0.15 then
						queueEntity({
							name = "rock-huge",
							position = entity.position,
							nobump = true,
							force = game.forces.neutral,
							raise_built = true
						}, surface, chunkpos)
					end
				else
					entity.position = surface.find_non_colliding_position(entity.name, entity.position, 0, 1, true)
					surface.create_entity(entity)
					if resource.type == "iron-ore" or resource.type == "copper-ore" or (resource.type == "stone" and math.random()<0.5) then
						surface.create_entity({
							name = resource.type == "stone" and "rock-big" or "rock-big-"..resource.type,
							position = entity.position,
							force = game.forces.neutral
						})
					elseif math.random()<0.15 then
						surface.create_entity({
							name = "rock-huge",
							position = entity.position,
							force = game.forces.neutral,
							raise_built = true
						})
					end
				end
			end
			purity = purity - pval
		end
		if purity <= 0 then break end
	end
	-- everything except plants is guarded (maybe plants too but with a low value parameter?)
	local chunkpos = {x=math.floor(cx/32), y=math.floor(cy/32)}
	if resource.type == "x-deposit" then
		-- nothing
	elseif resource.type == "x-plant" then
		-- plants may have a Lizard Doggo nearby
		if math.random()<0.1 then
			local entity = {
				name = "small-biter",
				position = {cx,cy},
				force = "neutral",
				raise_built = true
			}
			if not surface.is_chunk_generated({chunkpos.x, chunkpos.y}) then
				queueEntity(entity, surface, chunkpos)
			else
				local pos = surface.find_non_colliding_position(entity.name, entity.position, 6, 0.1, false)
				if pos then
					entity.position = pos
					surface.create_entity(entity)
				end
			end
		end
	else
		if not surface.is_chunk_generated({chunkpos.x, chunkpos.y}) then
			queueEntity({
				name = "x-enemies",
				position = {cx,cy},
				value = resource.value,
				base_distance = resource.r
			}, surface, chunkpos)
		else
			enemies.spawnGroup(surface, {cx,cy}, resource.value, resource.r)
		end
	end
end

local function addNode(resource, surface, x, y)
	local gx = math.floor(x/resource.gridsize);
	local gy = math.floor(y/resource.gridsize);
	if not resource.grid[surface.index][gy] then resource.grid[surface.index][gy] = {} end
	resource.grid[surface.index][gy][gx] = {x,y}
	table.insert(resource.nodes[surface.index], {x,y})
	global['resource-node-count'] = global['resource-node-count'] + 1
	spawnNode(resource, surface, x, y)
end
local function existsNear(mytype, surface, x, y)
	-- scan the grid cells near the target (x,y) position to see if another resource node is too close
	-- this is going to be checking ALL other resources to ensure there's enough space to spawn a cluster, but different node types are allowed much closer together
	for type,resource in pairs(global['resources']) do
		local gx = math.floor(x/resource.gridsize);
		local gy = math.floor(y/resource.gridsize);
		local r = type == mytype and resource.r or (resource.border*2+2)
		local grid = resource.grid[surface.index]
		for dy=-2,2 do
			local row = grid[gy+dy]
			if row then
				for dx=-2,2 do
					local node = row[gx+dx]
					if node then
						-- check if it's too close
						local mx = node[1]-x;
						local my = node[2]-y;
						if mx*mx+my*my < r*r then
							return true
						end
					end
				end
			end
		end
	end
	return false
end
local function scanForResources()
	-- pick a random number and iterate the groups again until that many have passed
	local rand = math.random(1,global['resource-node-count'])
	for _,surface in pairs(game.surfaces) do
		for name,data in pairs(global['resources']) do
			if not data.nodes[surface.index] then break end

			if rand <= #data.nodes[surface.index] then
				-- found it!
				local node = data.nodes[surface.index][rand]
				-- but if the node is outside the generated surface, put it to sleep
				if not surface.is_chunk_generated{x=math.floor(node[1]/32), y=math.floor(node[2]/32)} then
					table.insert(data.sleep[surface.index], node)
					table.remove(data.nodes[surface.index], rand)
					global['resource-node-count'] = global['resource-node-count'] - 1
				else
					for _=1,data.k do
						-- pick a random point between r and 2r distance away
						local theta = math.random()*math.pi*2
						-- local range = data.r * math.sqrt(math.random()*3 + 1)
						local range = data.r * (math.random() + 1)
						local test = {node[1]+math.cos(theta)*range, node[2]+math.sin(theta)*range}
						if not existsNear(name, surface, test[1], test[2]) then
							-- it's free real estate!
							addNode(data, surface, test[1], test[2])
							break
						end
						if _ == data.k then
							-- give up on this node, it is now closed
							table.remove(data.nodes[surface.index],rand)
							global['resource-node-count'] = global['resource-node-count'] - 1
						end
					end
				end
				return
			else
				rand = rand - #data.nodes[surface.index]
			end
		end
	end
end

local function onChunkGenerated(event)
	-- check if this chunk has queued nodes on it and spawn them if so
	local pos = event.position
	local surface = event.surface
	local queued = getQueuedEntities(surface, pos)
	if queued and #queued > 0 then
		for _,node in pairs(queued) do
			if node.name == "x-crashsite" then
				crash_site.createCrashSite(event.surface, node.position)
			elseif node.name == "x-enemies" then
				enemies.spawnGroup(event.surface, node.position, node.value, node.base_distance)
			elseif node.name == "small-biter" then
				local pos = surface.find_non_colliding_position(node.name, node.position, 6, 0.1, false)
				if pos then
					node.position = pos
					event.surface.create_entity(node)
				end
			else
				if node.nobump then
					node.nobump = nil
				else
					node.position = surface.find_non_colliding_position(node.name, node.position, 0, 1, true)
				end
				event.surface.create_entity(node)
			end
		end
		clearQueuedEntities(surface, pos)
	end
	-- move sleeping nodes in this chunk to open nodes
	local bbox = {event.area.left_top or event.area[1], event.area.right_bottom or event.area[2]}
	bbox[1] = {bbox[1].x or bbox[1][1], bbox[1].y or bbox[1][2]}
	bbox[2] = {bbox[2].x or bbox[2][1], bbox[2].y or bbox[2][2]}
	if global['resources'] then
		local awaken = 0
		for _,data in pairs(global['resources']) do
			for surfid,nodes in pairs(data.sleep) do
				for k,v in pairs(nodes) do
					if v[1] >= bbox[1][1] and v[1] <= bbox[2][1] and v[2] >= bbox[1][2] and v[2] <= bbox[2][2] then
						table.remove(data.sleep[surfid],k)
						table.insert(data.nodes[surfid],v)
						awaken = awaken + 1
					end
				end
			end
		end
		if awaken > 0 then
			global['resource-node-count'] = global['resource-node-count'] + awaken
		end
	end
end

local function onInit()
	if not global['resources'] then global['resources'] = {} end
	if not global['resource-node-count'] then global['resource-node-count'] = 0 end

	registerResource("iron-ore", 150, 4, 8, 1)
	registerResource("copper-ore", 180, 2, 6, 1)
	registerResource("stone", 175, 3, 7, 1)
	registerResource("coal", 250, 2, 6, 2)
	registerResource("crude-oil", 450, 3, 7, 3)
	registerResource("caterium-ore", 500, 2, 4, 2)
	registerResource("sulfur", 600, 1, 4, 4)
	registerResource("raw-quartz", 600, 1, 6, 3)
	registerResource("bauxite", 800, 2, 6, 5)
	registerResource("uranium-ore", 1000, 2, 2, 6)
	registerResource("geyser", 750, 1, 1, 4)

	registerResource("x-plant", 100, 1, 3, 0)
	registerResource("x-deposit", 100, 1, 10, 0) -- "value" is unused
	registerResource("x-powerslug", 160, 1, 10, 0) -- "value" is dynamic 1-5 based on slug type
	registerResource("x-crashsite", 190, 1, 1, 5)

	registerSurface(game.surfaces.nauvis)
end

local function onResolutionChanged(event)
	local player = game.players[event.player_index]
	local gui = player.gui.screen['resources-loading']
	if gui then
		gui.location = {(player.display_resolution.width-300*player.display_scale)/2, 40*player.display_scale}
	end
end
local profiler = require("profiler")
local function onTick(event)
	local count = global['resource-node-count']
	-- run more often the more open nodes there are
	if count > 30 or (count > 20 and event.tick%4 == 0) or (count > 10 and event.tick%6 == 0) or (count > 5 and event.tick%8 == 0) or (count > 0 and event.tick%10 == 0) then
		scanForResources()
	end
	if event.tick == 0 then
		-- draw blackness over the screen
		for _,player in pairs(game.players) do
			rendering.draw_rectangle{
				color = {}, -- black
				filled = true,
				left_top = {player.position.x-player.display_resolution.width/64-1, player.position.y-player.display_resolution.height/64-1},
				right_bottom = {player.position.x+player.display_resolution.width/64+1, player.position.y+player.display_resolution.height/64+1},
				surface = player.surface,
				time_to_live = 5,
				players = {player}
			}
		end
	elseif event.tick == 3 then
		-- process all nodes
		while global['resource-node-count'] > 2 do
			scanForResources()
		end
	end
	if event.tick%30 == 0 then
		-- if there are many nodes on the player's current surface, show a GUI to indicate the map is loading
		for _,player in pairs(game.players) do
			local gui = player.gui.screen['resources-loading']
			if not gui then
				gui = player.gui.screen.add{
					type = "frame",
					name = "resources-loading",
					direction = "vertical",
					caption = {"gui.map-generator-working-title"},
					style = "inner_frame_in_outer_frame"
				}
				gui.style.horizontally_stretchable = false
				gui.style.use_header_filler = false
				gui.style.width = 300
				local flow = gui.add{
					type = "frame",
					direction = "vertical",
					name = "content",
					style = "inside_shallow_frame_with_padding"
				}
				flow.style.horizontally_stretchable = true
				flow.add{
					type = "label",
					style = "heading_2_label",
					caption = {"gui.map-generator-working-label"}
				}.style.bottom_margin = 12
				flow.add{
					type = "label",
					name = "count"
				}
				gui.visible = false
			end
			if count < 5 then
				if gui.visible then
					gui.visible = false
				end
			else
				if not gui.visible then
					gui.visible = true
					onResolutionChanged({player_index=player.index})
				end
				if event.tick > 0 then -- don't show node count on first tick
					gui.content.count.caption = {"gui.map-generator-node-count",count}
				end
			end
		end
	end
end

return {
	on_init = onInit,
	events = {
		[defines.events.on_tick] = onTick,
		[defines.events.on_chunk_generated] = onChunkGenerated,

		[defines.events.on_player_display_resolution_changed] = onResolutionChanged,
		[defines.events.on_player_display_scale_changed] = onResolutionChanged
	}
}
