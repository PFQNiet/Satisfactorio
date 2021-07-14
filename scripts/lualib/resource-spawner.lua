--[[
	Resources are spawned using a poisson-disc distribution, with the small change that nodes outside the bounding box of the generated map are "asleep"
	Sleeping nodes won't be considered for expansion until the bounding box of generated chunks contains them
	Uses global.resource_spawner.queued to track nodes that should have spawned, but whose location wasn't generated yet
	Uses global.resources.add_count() to store a running total of open nodes
	Uses global.resources.resources() to store data relating to resource generation
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
local crash_site = require(modpath.."scripts.lualib.crash-sites")
local enemies = require(modpath.."scripts.lualib.enemy-spawning")
local string = require(modpath.."scripts.lualib.string")

---@class PositionAndSurface : Position
---@field surface LuaSurface

---@class ResourceSpawner
---@field type string
---@field r number
---@field border number
---@field k uint Number of attempts before a node is considered closed
---@field value uint8 Relative value of the resource, for enemy strength modification
---@field size uint[] Min/Max size of the resource cluster
---@field gridsize number Size of the squares of the grid
---@field grid Position[] Surface.gridY.gridX => position of node in that cell
---@field nodes PositionAndSurface[] List of active nodes
---@field sleep PositionAndSurface[] List of nodes that are asleep due to being on chunks that aren't generated yet

---@class global.resources
---@field resources table<string, ResourceSpawner> Type => Spawner
---@field node_count uint Total number of active nodes
---@field queued table<string, table> Queued entities waiting for their chunk to be generated
local script_data = {
	resources = {},
	node_count = 0,
	queued = {}
}

-- "terrain"-type autoplace controls invert the scale parameter
local inverted_frequency_controls = {
	["x-plant"] = true,
	["x-deposit"] = true,
	["x-powerslug"] = true,
	["x-crashsite"] = true,
	["geyser"] = true
}

local function registerResource(name, radius, min, max, value)
	if script_data.resources[name] then return end
	local settings = game.default_map_gen_settings.autoplace_controls[name] or {frequency=1,richness=1,size=1}
	if settings.size == 0 then return end

	-- settings are supposed to be in the range 1/6 to 6
	-- frequency affects the radius at which things spawn
	-- example: to make things 6x more common, divide the radius by sqrt(6)
	if inverted_frequency_controls[name] then
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
	if name == "geyser" then buffer = buffer * 2 end

	script_data.resources[name] = {
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
	for _,struct in pairs(script_data.resources) do
		table.insert(struct.nodes, {0,0,surface=surface})
		struct.grid[surface.index..".0.0"] = {0,0}
		script_data.node_count = script_data.node_count + 1
	end
end

local function queueEntity(entity, surface, chunkpos)
	local ref = surface.index.."."..chunkpos.y.."."..chunkpos.x
	if not script_data.queued[ref] then script_data.queued[ref] = {} end
	table.insert(script_data.queued[ref], entity)
end
local function getQueuedEntities(surface, chunkpos)
	local ref = surface.index.."."..chunkpos.y.."."..chunkpos.x
	return script_data.queued[ref]
end
local function clearQueuedEntities(surface, chunkpos)
	local ref = surface.index.."."..chunkpos.y.."."..chunkpos.x
	script_data.queued[ref] = nil
end

---@param resource ResourceSpawner
---@param surface LuaSurface
---@param cx number
---@param cy number
local function spawnNode(resource, surface, cx, cy)
	-- scatter a cluster of nodes, of total purity value between the bounds defined on the resource data, within a radius of 4-8
	local purity = math.random(resource.size[1], resource.size[2])
	---@type Position[]
	local points = {}
	local neutral_force = game.forces.neutral
	-- just generate local points within radius 4-8 and check against all others - it's so small that the "grid" method doesn't do anything for us.
	for _=1,30 do
		local theta = math.random()*math.pi*2
		local r = math.sqrt(math.random())*resource.border
		local spread = resource.type == "geyser" and 8 or 4.5
		local x = math.cos(theta)*r
		local y = math.sin(theta)*r
		local ok = true
		for _,p in pairs(points) do
			local dx = p[1]-x
			local dy = p[2]-y
			if dx*dx+dy*dy < spread*spread then
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
				local tx = math.floor(cx+x+0.5) + 0.5
				local ty = math.floor(cy+y+0.5) + 0.5
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
					force = neutral_force
				}
				if not surface.is_chunk_generated({chunkpos.x, chunkpos.y}) then
					queueEntity(entity, surface, chunkpos)
				else
					entity.position = surface.find_non_colliding_position(entity.name, entity.position, 0, 1, false)
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
					force = neutral_force,
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
					force = neutral_force,
					raise_built = true
				}
				if not surface.is_chunk_generated({chunkpos.x, chunkpos.y}) then
					queueEntity(entity, surface, chunkpos)
					if game.default_map_gen_settings.autoplace_controls['x-deposit'].size > 0 then
						if math.random()<0.2 then
							queueEntity({
								name = "rock-huge",
								position = entity.position,
								nobump = true,
								force = neutral_force,
								raise_built = true
							}, surface, chunkpos)
						end
					end
				else
					surface.create_entity(entity)
					if game.default_map_gen_settings.autoplace_controls['x-deposit'].size > 0 then
						if math.random()<0.2 then
							surface.create_entity{
								name = "rock-huge",
								position = entity.position,
								force = neutral_force,
								raise_built = true
							}
						end
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
				local tx = math.floor(cx+x+0.5)
				local ty = math.floor(cy+y+0.5)
				-- wells are 10x10 so they go on integer positions. All other resources are 3x3 so go in a tile centre.
				if not string.ends_with(resource.type, "-well") then
					tx = tx + 0.5
					ty = ty + 0.5
				end
				local chunkpos = {x=math.floor(tx/32), y=math.floor(ty/32)}
				local entity = {
					name = resource.type,
					position = {tx,ty},
					force = neutral_force,
					amount = 60*pval,
					snap_to_tile_center = false
				}
				if not surface.is_chunk_generated({chunkpos.x, chunkpos.y}) then
					queueEntity(entity, surface, chunkpos)
					-- only spawn rocks if deposits are enabled
					if game.default_map_gen_settings.autoplace_controls['x-deposit'].size > 0 then
						if resource.type == "iron-ore" or resource.type == "copper-ore" or (resource.type == "stone" and math.random()<0.5) then
							queueEntity({
								name = resource.type == "stone" and "rock-big" or "rock-big-"..resource.type,
								position = entity.position,
								nobump = true,
								force = neutral_force
							}, surface, chunkpos)
						elseif math.random()<0.15 then
							queueEntity({
								name = "rock-huge",
								position = entity.position,
								nobump = true,
								force = neutral_force,
								raise_built = true
							}, surface, chunkpos)
						end
					end
				else
					entity.position = surface.find_non_colliding_position(entity.name, entity.position, 0, 1, false)
					surface.create_entity(entity)
					-- only spawn rocks if deposits are enabled
					if game.default_map_gen_settings.autoplace_controls['x-deposit'].size > 0 then
						if resource.type == "iron-ore" or resource.type == "copper-ore" or (resource.type == "stone" and math.random()<0.5) then
							surface.create_entity({
								name = resource.type == "stone" and "rock-big" or "rock-big-"..resource.type,
								position = entity.position,
								force = neutral_force
							})
						elseif math.random()<0.15 then
							surface.create_entity({
								name = "rock-huge",
								position = entity.position,
								force = neutral_force,
								raise_built = true
							})
						end
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
				name = "lizard-doggo",
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

--- Register a node at this location, and spawn something there
---@param resource ResourceSpawner
---@param surface LuaSurface
---@param x number
---@param y number
local function addNode(resource, surface, x, y)
	local gx = math.floor(x/resource.gridsize);
	local gy = math.floor(y/resource.gridsize);
	local ref = surface.index.."."..gy.."."..gx
	resource.grid[ref] = {x,y}
	table.insert(resource.nodes, {x,y,surface=surface})
	script_data.node_count = script_data.node_count + 1
	spawnNode(resource, surface, x, y)
end

-- Get nodes in and around the given position
---@param name string
---@param surface LuaSurface
---@param position Position
---@return Position[]
local function getNodes(name, surface, position)
	local data = script_data.resources[name]
	if not data then return {} end

	local nodes = {}
	local grid = data.grid
	-- find nearest grid squares having nodes
	local origin = {math.floor(position.x/data.gridsize), math.floor(position.y/data.gridsize)}
	for dx=-2,2 do
		for dy=-2,2 do
			local gx = origin[1] + dx
			local gy = origin[2] + dy
			-- ignore origin node as it is fake
			if gx ~= 0 or gy ~= 0 then
				table.insert(nodes, grid[surface.index.."."..gy.."."..gx])
			end
		end
	end
	return nodes
end

--- scan the grid cells near the target (x,y) position to see if another resource node is too close
---@param resource table
---@param surface LuaSurface
---@param x number
---@param y number
local function existsNear(resource, surface, x, y)
	local function checkCollision(grid,surf,cx,cy,r)
		local node = grid[surf.."."..cy.."."..cx]
		if not node then return false end
		local mx = node[1]-x
		local my = node[2]-y
		return mx*mx+my*my < r*r
	end

	local gx = math.floor(x/resource.gridsize);
	local gy = math.floor(y/resource.gridsize);
	local surf = surface.index
	local grid = resource.grid
	local r = resource.r
	-- unrolled loop over -2,2, starting from the centre to try and bail out as early as possible
	return checkCollision(grid,surf,gx  ,gy  ,r)
		or checkCollision(grid,surf,gx-1,gy  ,r)
		or checkCollision(grid,surf,gx  ,gy-1,r)
		or checkCollision(grid,surf,gx+1,gy  ,r)
		or checkCollision(grid,surf,gx  ,gy+1,r)
		or checkCollision(grid,surf,gx-1,gy-1,r)
		or checkCollision(grid,surf,gx+1,gy-1,r)
		or checkCollision(grid,surf,gx-1,gy+1,r)
		or checkCollision(grid,surf,gx+1,gy+1,r)
		or checkCollision(grid,surf,gx-2,gy  ,r)
		or checkCollision(grid,surf,gx  ,gy-2,r)
		or checkCollision(grid,surf,gx+2,gy  ,r)
		or checkCollision(grid,surf,gx  ,gy+2,r)
		or checkCollision(grid,surf,gx-1,gy-2,r)
		or checkCollision(grid,surf,gx+1,gy-2,r)
		or checkCollision(grid,surf,gx-2,gy-1,r)
		or checkCollision(grid,surf,gx+2,gy-1,r)
		or checkCollision(grid,surf,gx-2,gy+1,r)
		or checkCollision(grid,surf,gx+2,gy+1,r)
		or checkCollision(grid,surf,gx-1,gy+2,r)
		or checkCollision(grid,surf,gx+1,gy+2,r)
		-- checking furthest diagonals seems exceedingly unlikely to provide a collision
		-- or checkCollision(grid,surf,gx-2,gy-2,r)
		-- or checkCollision(grid,surf,gx+2,gy-2,r)
		-- or checkCollision(grid,surf,gx-2,gy+2,r)
		-- or checkCollision(grid,surf,gx+2,gy+2,r)
end

-- pick a random open node and process it
local function scanForResources()
	local rand = math.random(1,script_data.node_count)
	local resource_list = script_data.resources
	for _, data in pairs(resource_list) do
		if rand > #data.nodes then
			rand = rand - #data.nodes
		else
			-- found it!
			local node = data.nodes[rand]
			local surface = node.surface
			-- but if the node is outside the generated surface, put it to sleep
			if not surface.is_chunk_generated{x=math.floor(node[1]/32), y=math.floor(node[2]/32)} then
				table.insert(data.sleep, node)
				table.remove(data.nodes, rand)
				script_data.node_count = script_data.node_count - 1
			else
				for _=1,data.k do
					-- pick a random point between r and 2r distance away
					local theta = math.random()*math.pi*2
					-- local range = data.r * math.sqrt(math.random()*3 + 1)
					local range = data.r * (math.random() + 1)
					local test = {node[1]+math.cos(theta)*range, node[2]+math.sin(theta)*range}
					if not existsNear(data, surface, test[1], test[2]) then
						-- it's free real estate!
						addNode(data, surface, test[1], test[2])
						break
					end
					if _ == data.k then
						-- give up on this node, it is now closed
						table.remove(data.nodes, rand)
						script_data.node_count = script_data.node_count - 1
					end
				end
			end
			return
		end
	end
end

-- check if this chunk has queued nodes on it and spawn them if so
---@param event on_chunk_generated
local function onChunkGenerated(event)
	local pos = event.position
	local surface = event.surface
	local queued = getQueuedEntities(surface, pos)
	if queued and #queued > 0 then
		for _,node in pairs(queued) do
			if node.name == "x-crashsite" then
				crash_site.createCrashSite(event.surface, node.position)
			elseif node.name == "x-enemies" then
				enemies.spawnGroup(event.surface, node.position, node.value, node.base_distance)
			elseif node.name == "lizard-doggo" then
				local pos = surface.find_non_colliding_position(node.name, node.position, 6, 0.1, false)
				if pos then
					node.position = pos
					event.surface.create_entity(node)
				end
			else
				if node.nobump then
					node.nobump = nil
				else
					node.position = surface.find_non_colliding_position(node.name, node.position, 0, 1, false)
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
	local awaken = 0
	for _,data in pairs(script_data.resources) do
		for i=#data.sleep,1,-1 do
			local node = data.sleep[i]
			if node[1] >= bbox[1][1] and node[1] <= bbox[2][1] and node[2] >= bbox[1][2] and node[2] <= bbox[2][2] then
				table.remove(data.sleep, i)
				table.insert(data.nodes, node)
				awaken = awaken + 1
			end
		end
	end
	if awaken > 0 then
		script_data.node_count = script_data.node_count + awaken
	end
end

local function onInit()
	global.resource_spawner = global.resource_spawner or script_data

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

	registerResource("water-well", 500, 1, 1, 1)
	registerResource("crude-oil-well", 700, 1, 1, 3)
	registerResource("nitrogen-gas-well", 900, 1, 1, 6)

	registerResource("x-plant", 80, 1, 3, 0)
	registerResource("x-deposit", 60, 1, 10, 0) -- "value" is unused
	registerResource("x-powerslug", 100, 1, 10, 0) -- "value" is dynamic 1-5 based on slug type
	registerResource("x-crashsite", 190, 1, 1, 5)
	registerResource("geyser", 550, 2, 6, 4)

	registerSurface(game.surfaces.nauvis)
end

---@param event on_player_display_resolution_changed
local function onResolutionChanged(event)
	local player = game.players[event.player_index]
	local gui = player.gui.screen['resources-loading']
	if gui then
		gui.location = {(player.display_resolution.width-300*player.display_scale)/2, 40*player.display_scale}
	end
end

---@param event on_tick
local function onTick(event)
	local count = script_data.node_count
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
		while script_data.node_count > 2 do
			scanForResources()
		end
	end
	if event.tick%30 == 0 then
		-- if there are many nodes on the player's current surface, show a GUI to indicate the map is loading
		for _,player in pairs(game.players) do
			local gui = player.gui.screen
			if not gui['resources-loading'] then
				local frame = player.gui.screen.add{
					type = "frame",
					name = "resources-loading",
					direction = "vertical",
					caption = {"gui.map-generator-working-title"},
					style = "resource_loading_frame"
				}
				local flow = frame.add{
					type = "frame",
					direction = "vertical",
					name = "content",
					style = "inside_shallow_frame_with_padding_and_spacing"
				}
				flow.add{
					type = "label",
					style = "heading_2_label",
					caption = {"gui.map-generator-working-label"}
				}
				flow.add{
					type = "label",
					name = "count"
				}
				frame.visible = false
			end
			local frame = gui['resources-loading']
			if count < 5 then
				if frame.visible then
					frame.visible = false
				end
			else
				if not frame.visible then
					frame.visible = true
					onResolutionChanged({player_index=player.index})
				end
				if event.tick > 0 then -- don't show node count on first tick
					frame.content.count.caption = {"gui.map-generator-node-count",count}
				end
			end
		end
	end
end

return {
	getNodes = getNodes,
	lib = {
		on_init = onInit,
		on_load = function()
			script_data = global.resource_spawner or script_data
		end,

		events = {
			[defines.events.on_tick] = onTick,
			[defines.events.on_chunk_generated] = onChunkGenerated,

			[defines.events.on_player_display_resolution_changed] = onResolutionChanged,
			[defines.events.on_player_display_scale_changed] = onResolutionChanged
		}
	}
}
