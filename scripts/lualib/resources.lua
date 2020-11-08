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