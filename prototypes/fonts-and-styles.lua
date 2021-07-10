data:extend{
	{
		type = "font",
		name = "ada-console-heading",
		from = "default-bold",
		border = true,
		border_color = {},
		size = 18
	},
	{
		type = "font",
		name = "ada-console-semibold",
		from = "default-semibold",
		border = true,
		border_color = {},
		size = 18
	}
}

local style = data.raw["gui-style"].default
style['submit_button'] = table.deepcopy(style['confirm_button'])
style['submit_button'].tooltip = nil
