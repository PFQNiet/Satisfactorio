--[[
	Resources are spawned using a poisson-disc distribution, with the small change that nodes outside the bounding box of the generated map are "asleep"
	Sleeping nodes won't be considered for expansion until the bounding box of generated chunks contains them
	Uses global['surface-bboxes'] to store bounding box of generated area
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
]]
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

local function _array_contains(arr, find)
	for _,v in ipairs(arr) do
		if v == find then return true end
	end
	return false
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
			purity = purity - pval
			local landfill = {}
			for dx=-1,1 do
				for dy=-1,1 do
					local tx = cx+dx+math.floor(x+0.5)
					local ty = cy+dy+math.floor(y+0.5)
					local chunkpos = {x=math.floor(tx/32), y=math.floor(ty/32)}
					local entity = {
						name = resource.type,
						position = {tx,ty},
						force = game.forces.neutral,
						amount = 60*pval
					}
					if not surface.is_chunk_generated({chunkpos.x, chunkpos.y}) then
						if not global['queued-nodes'] then global['queued-nodes'] = {} end
						if not global['queued-nodes'][chunkpos.y] then global['queued-nodes'][chunkpos.y] = {} end
						if not global['queued-nodes'][chunkpos.y][chunkpos.x] then global['queued-nodes'][chunkpos.y][chunkpos.x] = {} end
						table.insert(global['queued-nodes'][chunkpos.y][chunkpos.x], entity)
					else
						table.insert(landfill, {name="landfill",position={tx,ty}})
						surface.create_entity(entity)
					end
				end
			end
			if #landfill > 0 then
				surface.set_tiles(landfill, true, false, false, false)
			end
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
		local r = type == mytype and resource.r or 10
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
local function scanForResources(surface, bbox, nodecount)
	-- pick a random number and iterate the groups again until that many have passed
	local rand = math.random(1,nodecount)
	for name,data in pairs(global['resources']) do
		if rand <= #data.nodes[surface.index] then
			-- found it!
			local node = data.nodes[surface.index][rand]
			-- but if the node is outside the bounding box of the surface, put it to sleep
			if node[1] < bbox[1][1] or node[1] > bbox[2][1] or node[2] < bbox[1][2] or node[2] > bbox[2][2] then
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

local function onChunkCharted(event)
	local surface = game.surfaces[event.surface_index]
	if not global['surface-bboxes'] then global['surface-bboxes'] = {} end
	if not global['surface-bboxes'][surface.index] then global['surface-bboxes'][surface.index] = {{-100,-100},{100,100}} end
	local bbox = global['surface-bboxes'][surface.index]
	local changed = false
	if event.area.left_top.x < bbox[1][1] then
		bbox[1][1] = event.area.left_top.x
		changed = true
	end
	if event.area.left_top.y < bbox[1][2] then
		bbox[1][2] = event.area.left_top.y
		changed = true
	end
	if event.area.right_bottom.x > bbox[2][1] then
		bbox[2][1] = event.area.right_bottom.x
		changed = true
	end
	if event.area.right_bottom.y > bbox[2][2] then
		bbox[2][2] = event.area.right_bottom.y
		changed = true
	end

	if changed then
		-- move all sleeping nodes to open nodes
		for _,data in pairs(global['resources']) do
			for k,v in pairs(data.sleep[surface.index]) do
				table.insert(data.nodes[surface.index],v)
			end
			data.sleep[surface.index] = {}
		end
	end
end
local function onChunkGenerated(event)
	-- check if this chunk has queued nodes on it and spawn them if so
	local pos = event.position
	if global['queued-nodes'] and global['queued-nodes'][pos.y] and global['queued-nodes'][pos.y][pos.x] and #global['queued-nodes'][pos.y][pos.x] > 0 then
		local landfill = {}
		for _,node in pairs(global['queued-nodes'][pos.y][pos.x]) do
			table.insert(landfill, {name="landfill",position={node.position[1],node.position[2]}})
			event.surface.create_entity(node)
		end
		if #landfill > 0 then
			event.surface.set_tiles(landfill, true, false, false, false)
		end
		global['queued-nodes'][pos.y][pos.x] = nil
	end
end

local function onInit()
	if not global['resources'] then global['resources'] = {} end
	registerResource("iron-ore", 150, 4, 8)
	registerResource("copper-ore", 180, 2, 6)
	registerResource("stone", 175, 3, 7)
	registerResource("coal", 250, 2, 6)
	registerResource("crude-oil", 500, 3, 7)
	registerResource("uranium-ore", 1000, 2, 2)
end
local function onTick()
	-- check for open nodes and process one
	if not global['surface-bboxes'] then global['surface-bboxes'] = {} end
	for _,surface in pairs(game.surfaces) do
		if not global['surface-bboxes'][surface.index] then global['surface-bboxes'][surface.index] = {{-100,-100},{100,100}} end
		local bbox = global['surface-bboxes'][surface.index]
		local total = 0
		for name,data in pairs(global['resources']) do
			if not data.nodes[surface.index] then data.nodes[surface.index] = {{0,0}} end
			if not data.sleep[surface.index] then data.sleep[surface.index] = {} end
			if not data.grid[surface.index] then data.grid[surface.index] = {[0]={[0]={0,0}}} end
			total = total + #data.nodes[surface.index]
		end
		if total > 0 then
			scanForResources(surface, bbox, total)
		end
	end
end

return {
	on_init = onInit,
	on_nth_tick = {
		[10] = onTick
	},
	events = {
		[defines.events.on_chunk_charted] = onChunkCharted,
		[defines.events.on_chunk_generated] = onChunkGenerated
	}
}
