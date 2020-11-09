--[[
	Uses global.resource.add_count to store a running total of open nodes
	Uses global.resource.node_count to get the running total of open nodes
	Uses global.resources.resources to store data relating to resource generation
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
local script_data = {
	resources = {},
	node_count = 0
}

return {
	on_init = function()
		global.resources = global.resources or script_data
	end,
	on_load = function()
		script_data = global.resources or script_data
	end,
	on_configuration_changed = function()
		if global.resources and not global.resources.resources then
			script_data = {
				resources = table.deepcopy(global.resources),
				node_count = 0
			}
			global.resources = script_data
		end
	end,

	resources = script_data.resources,
	node_count = function(default)
		if script_data.node_count > 0 then
			return script_data.node_count
		end
		return default == nil and 0 or default
	end,
	add_node = function(name, value)
		script_data.resources[name] = value
	end,
	add_count = function(add)
		script_data.node_count = script_data.node_count + add
	end
}
