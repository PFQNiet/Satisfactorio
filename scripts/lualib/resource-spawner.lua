--[[
	Resources are spawned using a poisson-disc distribution, with the small change that nodes outside the bounding box of the generated map are "asleep"
	Sleeping nodes won't be considered for expansion until the bounding box of generated chunks contains them
	Uses global['queued-nodes'] to track nodes that should have spawned, but whose location wasn't generated yet
	Uses global['resources'] to store data relating to resource generation
	Each resource is a table: {
		r = radius, nodes will spawn between r and 2r tiles away from any other nodes
		k = attempts to spawn a node before considering the node "closed" (30)
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
	Special resource "types": x-plant, x-powerslug, x-crashsite
]]
local crash_site = require("scripts.lualib.crash-sites")

local function registerResource(name, radius, min, max)
	if global['resources'][name] then return end
	global['resources'][name] = {
		type = name,
		r = radius,
		k = 30,
		size = {min,max},
		gridsize = radius/math.sqrt(2),
		grid = {},
		nodes = {},
		sleep = {}
	}
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
		local r = math.random()*8+2
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
					surface.create_entity(entity)
				end
			elseif resource.type == "x-powerslug" then
				pval = purity -- always just a single slug, purity value affects rarity of slug
				local tiers = {"green","green","green","green","green","green","yellow","yellow","yellow","purple"}
				local slug = tiers[pval].."-power-slug"
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
				else
					surface.create_entity(entity)
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
					queueEntity({
						name = "big-biter",
						position = {tx,ty},
						force = game.forces.enemy
					}, surface, chunkpos)
				else
					surface.create_entity(entity)
					surface.create_entity({
						name = "big-biter",
						position = {tx,ty},
						force = game.forces.enemy
					})
				end
			end
			purity = purity - pval
		end
		if purity <= 0 then break end
	end
end

local function addNode(resource, surface, x, y)
	local gx = math.floor(x/resource.gridsize);
	local gy = math.floor(y/resource.gridsize);
	if not resource.grid[surface.index][gy] then resource.grid[surface.index][gy] = {} end
	resource.grid[surface.index][gy][gx] = {x,y}
	table.insert(resource.nodes[surface.index], {x,y})
	spawnNode(resource, surface, x, y)
end
local function existsNear(mytype, surface, x, y)
	-- scan the grid cells near the target (x,y) position to see if another resource node is too close
	-- this is going to be checking ALL other resources to ensure there's enough space to spawn a cluster, but different node types are allowed much closer together
	for type,resource in pairs(global['resources']) do
		local gx = math.floor(x/resource.gridsize);
		local gy = math.floor(y/resource.gridsize);
		local r = type == mytype and resource.r or 15
		for dy=-2,2 do
			for dx=-2,2 do
				local node = resource.grid[surface.index][gy+dy] and resource.grid[surface.index][gy+dy][gx+dx] or nil
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
	return false
end
local function scanForResources(surface, nodecount)
	-- pick a random number and iterate the groups again until that many have passed
	local rand = math.random(1,nodecount)
	for name,data in pairs(global['resources']) do
		if rand <= #data.nodes[surface.index] then
			-- found it!
			local node = data.nodes[surface.index][rand]
			-- but if the node is outside the generated surface, put it to sleep
			if not surface.is_chunk_generated{x=math.floor(node[1]/32), y=math.floor(node[2]/32)} then
				table.insert(data.sleep[surface.index], node)
				table.remove(data.nodes[surface.index], rand)
			else
				for _=1,data.k do
					-- pick a random point between r and 2r distance away
					local theta = math.random()*math.pi*2
					local range = math.random()*data.r+data.r
					local test = {node[1]+math.cos(theta)*range, node[2]+math.sin(theta)*range}
					if not existsNear(name, surface, test[1], test[2]) then
						-- it's free real estate!
						addNode(data, surface, test[1], test[2])
						break
					end
					if _ == data.k then
						-- give up on this node, it is now closed
						table.remove(data.nodes[surface.index],rand)
					end
				end
			end
			break
		else
			rand = rand - #data.nodes[surface.index]
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
			else
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
		for _,data in pairs(global['resources']) do
			for surfid,nodes in pairs(data.sleep) do
				for k,v in pairs(nodes) do
					if v[1] >= bbox[1][1] and v[1] <= bbox[2][1] and v[2] >= bbox[1][2] and v[2] <= bbox[2][2] then
						table.remove(data.sleep[surfid],k)
						table.insert(data.nodes[surfid],v)
					end
				end
			end
		end
	end
end

local function onInit()
	if not global['resources'] then global['resources'] = {} end
	registerResource("iron-ore", 150, 4, 8)
	registerResource("copper-ore", 180, 2, 6)
	registerResource("stone", 175, 3, 7)
	registerResource("coal", 250, 2, 6)
	registerResource("crude-oil", 500, 3, 7)
	registerResource("caterium-ore", 600, 2, 4)
	registerResource("sulfur", 750, 1, 4)
	registerResource("raw-quartz", 800, 1, 6)
	registerResource("bauxite", 1000, 2, 6)
	registerResource("uranium-ore", 1400, 2, 2)
	registerResource("geyser", 850, 1, 1)

	registerResource("x-plant", 100, 1, 3)
	registerResource("x-powerslug", 200, 1, 10)
	registerResource("x-crashsite", 450, 1, 1)
end
local function onTick()
	local total_per_surface = {}
	-- check for open nodes and process one
	for _,surface in pairs(game.surfaces) do
		local total = 0
		for name,data in pairs(global['resources']) do
			if not data.nodes[surface.index] then data.nodes[surface.index] = {{0,0}} end
			if not data.sleep[surface.index] then data.sleep[surface.index] = {} end
			if not data.grid[surface.index] then data.grid[surface.index] = {[0]={[0]={0,0}}} end
			total = total + #data.nodes[surface.index]
		end
		if total > 0 then
			scanForResources(surface, total)
		end
		total_per_surface[surface.index] = total
	end
	-- if there are many nodes on the player's current surface, show a GUI to indicate the map is loading
	for _,player in pairs(game.players) do
		local gui = player.gui.screen['resources-loading']
		if not gui then
			gui = player.gui.screen.add{
				type = "frame",
				name = "resources-loading",
				direction = "vertical",
				caption = {"gui.map-generator-working-title"},
				style = mod_gui.frame_style
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
		if total_per_surface[player.surface.index] < 10 then
			if gui.visible then
				gui.visible = false
			end
		else
			if not gui.visible then
				gui.visible = true
				gui.location = {(player.display_resolution.width-300)/2, 280}
			end
			gui.content.count.caption = {"gui.map-generator-node-count",total_per_surface[player.surface.index]}
		end
	end
end

return {
	on_init = onInit,
	on_nth_tick = {
		[10] = onTick
	},
	events = {
		[defines.events.on_chunk_generated] = onChunkGenerated
	}
}
