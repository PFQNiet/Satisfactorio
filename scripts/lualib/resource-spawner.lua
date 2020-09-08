--[[
	Resources are spawned using a poisson-disc distribution, with the small change that nodes outside the bounding box of the generated map are "asleep"
	Sleeping nodes won't be considered for expansion until the bounding box of generated chunks contains them
	Uses global['surface-bboxes'] to store bounding box of generated area
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
		grid = {[0]={[0]={0,0}}},
		nodes = {},
		sleep = {{0,0}}
	}
end
local function addNode(surface, resource, x, y)
	local gx = math.floor(x/resource.gridsize);
	local gy = math.floor(y/resource.gridsize);
	if not resource.grid[gy] then resource.grid[gy] = {} end
	resource.grid[gy][gx] = {x,y}
	table.insert(resource.nodes, {x,y})
	-- TODO actually spawn the node! For now just log it and make them all Pure nodes
	game.print("Spawned "..resource.type.." at "..math.floor(x)..","..math.floor(y))
	for dx=-1,1 do
		for dy=-1,1 do
			surface.create_entity{
				name = resource.type,
				position = {dx+math.floor(x)+0.5, dy+math.floor(y)+0.5},
				force = game.forces.neutral,
				amount = 240 -- just slap a single pure tile down for now
			}
		end
	end
end
local function existsNear(mytype, x, y)
	-- scan the grid cells near the target (x,y) position to see if another resource node is too close
	-- this is going to be checking ALL other resources to ensure there's enough space to spawn a cluster, but different node types are allowed much closer together
	for type,resource in pairs(global['resources']) do
		local gx = math.floor(x/resource.gridsize);
		local gy = math.floor(y/resource.gridsize);
		local r = type == mytype and resource.r or 10
		for dy=-2,2 do
			for dx=-2,2 do
				local node = resource.grid[gy+dy] and resource.grid[gy+dy][gx+dx] or nil
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
local function scanForResources(surface)
	if not surface then
		for _,surface in pairs(game.surfaces) do
			scanForResources(surface)
		end
		return
	end

	if not global['surface-bboxes'] then global['surface-bboxes'] = {} end
	if not global['surface-bboxes'][surface.index] then global['surface-bboxes'][surface.index] = {{-100,-100},{100,100}} end
	local bbox = global['surface-bboxes'][surface.index]

	log("Initiate scan in box "..serpent.line(global['surface-bboxes'][surface.index]))
	-- move all sleeping nodes to open nodes
	local function map(tbl,f)
		local t = {}
		for k,v in pairs(tbl) do t[k] = f(v) end
		return t
	end
	for _,data in pairs(global['resources']) do
		log("Resource "..data.type..": "..#data.sleep.." nodes")
		data.nodes = data.sleep
		data.sleep = {}
	end

	repeat
		-- count all the open nodes...
		local node_counts = {}
		local total = 0
		for name,data in pairs(global['resources']) do
			node_counts[name] = #data.nodes
			total = total + #data.nodes
		end
		if total > 0 then
			-- now pick a random number and iterate the groups again until that many have passed
			local rand = math.random(1,total)
			for name,data in pairs(global['resources']) do
				if rand <= #data.nodes then
					-- found it!
					local node = data.nodes[rand]
					-- but if the node is outside the bounding box of the surface, put it to sleep
					if node[1] < bbox[1][1] or node[1] > bbox[2][1] or node[2] < bbox[1][2] or node[2] > bbox[2][2] then
						table.insert(data.sleep, node)
						table.remove(data.nodes, rand)
					else
						for _=1,data.k do
							-- pick a random point between r and 2r distance away
							local theta = math.random()*math.pi*2
							local range = math.random()*data.r+data.r
							local test = {node[1]+math.cos(theta)*range, node[2]+math.sin(theta)*range}
							if not existsNear(name, test[1], test[2]) then
								-- it's free real estate!
								addNode(surface, data, test[1], test[2])
								break
							end
							if _ == data.k then
								-- give up on this node, it is now closed
								table.remove(data.nodes,rand)
							end
						end
					end
					break
				else
					rand = rand - #data.nodes
				end
			end
		end
	until total == 0
end
local function onChunkCharted(event)
	log("Chunk charted: "..serpent.line(event.area))
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

	if changed then scanForResources(surface) end
end

local function onInit()
	if not global['resources'] then global['resources'] = {} end
	registerResource("iron-ore", 50, 4, 8)
	registerResource("copper-ore", 60, 2, 6)
	scanForResources()
end

return {
	on_init = onInit,
	events = {
		[defines.events.on_chunk_charted] = onChunkCharted
	}
}
