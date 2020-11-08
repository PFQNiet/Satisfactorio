local script_data = {
    resources = {},
    node_count = {}
}

return {
	on_init = function()
		global.resources = global.resources or script_data
	end,
	on_load = function()
		script_data = global.resources or script_data
	end,
    resources = script_data.resources,
    node_count = script_data.node_count,
    add_node = function(name, value)
        script_data.resources[name] = value
    end,
    add_count = function(add)
        script_data.node_count = script_data.node_count + add
    end
}