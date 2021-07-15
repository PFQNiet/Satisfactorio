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

style['filler_widget'] = {
	type = "empty_widget_style",
	parent = "empty_widget",
	horizontally_stretchable = "on"
}
style['vertical_filler_widget'] = {
	type = "empty_widget_style",
	parent = "empty_widget",
	vertically_stretchable = "on"
}

style['goal_inner_frame_with_spacing'] = {
	type = "frame_style",
	parent = "goal_inner_frame",
	vertical_flow_style = {
		type = "vertical_flow_style",
		vertical_spacing = 8
	}
}

style['horizontal_flow_with_extra_spacing'] = {
	type = "horizontal_flow_style",
	parent = "horizontal_flow",
	horizontal_spacing = 12
}
style['vertical_flow_with_extra_spacing'] = {
	type = "vertical_flow_style",
	parent = "vertical_flow",
	vertical_spacing = 12
}
style['horizontally_aligned_flow'] = {
	type = "vertical_flow_style",
	parent = "vertical_flow",
	horizontally_stretchable = "on",
	horizontal_align = "center"
}
style['vertically_aligned_flow'] = {
	type = "horizontal_flow_style",
	parent = "horizontal_flow",
	vertical_align = "center"
}

style['frame_without_filler'] = {
	type = "frame_style",
	parent = "frame",
	use_header_filler = false
}
style['frame_with_vertical_spacing'] = {
	type = "frame_style",
	parent = "frame",
	vertical_flow_style = style['vertical_flow_with_extra_spacing']
}

style['resource_loading_frame'] = {
	type = "frame_style",
	parent = "frame_without_filler",
	width = 300,
	drag_by_title = false
}

style['draggable_space_in_window_title'] = {
	type = "empty_widget_style",
	parent = "draggable_space_header",
	horizontally_stretchable = "on",
	height = 24
}
style['full_subheader_frame'] = {
	type = "frame_style",
	parent = "subheader_frame",
	horizontally_stretchable = "on"
}
style['full_subheader_frame_in_padded_frame'] = {
	type = "frame_style",
	parent = "full_subheader_frame",
	left_margin = -12,
	right_margin = -12,
	top_margin = -12
}

style['inside_shallow_frame_with_padding_and_spacing'] = {
	type = "frame_style",
	parent = "inside_shallow_frame_with_padding",
	vertical_flow_style = style['vertical_flow_with_extra_spacing']
}

style['stretched_progressbar'] = {
	type = "progressbar_style",
	parent = "progressbar",
	horizontally_stretchable = "on"
}

style['build_gun_frame'] = {
	type = "frame_style",
	parent = "blurry_frame",
	width = 540,
	use_header_filler = false,
	horizontally_stretchable = "off",
	vertical_flow_style = style['horizontally_aligned_flow']
}
style['build_gun_slot'] = {
	type = "button_style",
	parent = "transparent_slot",
	size = 64
}
style['build_gun_progressbar'] = {
	type = "progressbar_style",
	parent = "electric_satisfaction_statistics_progressbar",
	width = 64
}

style['radioactivity_frame'] = {
	type = "frame_style",
	parent = "blurry_frame",
	use_header_filler = false,
	horizontal_flow_style = style['vertically_aligned_flow']
}
style['radioactivity_progressbar'] = {
	type = "progressbar_style",
	parent = "progressbar",
	color = {1,0,0},
	bar_width = 13,
	width = 200
}

style['scanner_scroll_pane'] = {
	type = "scroll_pane_style",
	parent = "scroll_pane_under_subheader",
	maximal_height = 500,
	padding = 12
}
style['scanner_table'] = {
	type = "table_style",
	parent = "table",
	horizontal_spacing = 12,
	vertical_spacing = 18
}
style['scanner_flow'] = {
	type = "vertical_flow_style",
	parent = "vertical_flow",
	horizontal_align = "center",
	vertical_spacing = 6
}
style['scanner_button'] = {
	type = "button_style",
	size = 100,
	draw_shadow_under_picture = true,
	left_click_sound = style['confirm_button'].left_click_sound
}
style['scanner_minimap'] = {
	type = "minimap_style",
	size = 100
}

style['self_driving_list_box'] = {
	type = "list_box_style",
	parent = "list_box_in_shallow_frame",
	width = 300,
	height = 200
}

style['smart_splitter_filter_flow'] = {
	type = "horizontal_flow_style",
	parent = "vertically_aligned_flow",
	height = 40
}
style['smart_splitter_filter_dropdown'] = {
	type = "dropdown_style",
	parent = "dropdown",
	horizontally_stretchable = "on"
}
style['smart_splitter_scroll_pane'] = {
	type = "scroll_pane_style",
	parent = "scroll_pane_under_subheader",
	padding = 12,
	width = 240,
	height = 400
}
style['smart_splitter_filter_container_flow'] = {
	type = "vertical_flow_style",
	parent = "vertical_flow",
	padding = 12,
	width = 240
}

style['text_sized_transparent_slot'] = {
	type = "button_style",
	parent = "transparent_slot",
	size = 20
}
style['awesome_sink_table'] = {
	type = "table_style",
	parent = "table",
	column_widths = {
		{
			column = 2,
			minimal_width = 80
		}
	},
	column_alignments = {
		{
			column = 2,
			alignment = "right"
		}
	}
}

style['hub_milestone_frame'] = {
	type = "frame_style",
	parent = "frame_without_filler",
	horizontally_stretchable = "off"
}

style['recipe_browser_scroll_pane'] = {
	type = "scroll_pane_style",
	parent = "scroll_pane_under_subheader",
	width = 560,
	height = 400,
	padding = 12,
	vertical_flow_style = style['vertical_flow_with_extra_spacing']
}
style['recipe_browser_item_sprite'] = {
	type = "image_style",
	parent = "image",
	size = 64,
	margin = 8,
	stretch_image_to_widget_size = true
}

style['todolist_recipe_frame'] = {
	type = "frame_style",
	parent = "slot_button_deep_frame",
	minimal_height = 40,
	width = 200,
	margin = 12
}
style['todolist_scroll_pane'] = {
	type = "scroll_pane_style",
	parent = "scroll_pane_in_shallow_frame",
	width = 224,
	padding = 12,
	maximal_height = 400,
	vertical_flow_style = style['vertical_flow_with_extra_spacing']
}
style['todolist_ingredient_flow'] = {
	type = "horizontal_flow_style",
	parent = "vertically_aligned_flow",
	horizontal_spacing = 12
}
style['todolist_ingredient_label'] = {
	type = "label_style",
	parent = "label",
	horizontally_squashable = "on"
}

style['hard_drive_column_flow'] = {
	type = "vertical_flow_style",
	parent = "vertical_flow_with_extra_spacing",
	width = 260,
	horizontal_align = "center"
}
style['hard_drive_recipe_sprite'] = {
	type = "image_style",
	parent = "image",
	size = 64,
	margin = 8,
	stretch_image_to_widget_size = true
}

style['stretched_textbox'] = {
	type = "textbox_style",
	parent = "textbox",
	maximal_width = 0,
	horizontally_stretchable = "on"
}
style['stretched_slider'] = {
	type = "slider_style",
	parent = "slider",
	horizontally_stretchable = "on"
}
style['multiline_label'] = {
	type = "label_style",
	parent = "label",
	single_line = false
}

style['drone_port_destination_list_box'] = {
	type = "list_box_style",
	parent = "list_box_in_shallow_frame",
	height = 120,
	horizontally_stretchable = "on"
}

style['station_mode_button'] = {
	type = "button_style",
	parent = "slot_sized_button",
	size = 80,
	padding = 8
}
style['station_mode_button_pressed'] = {
	type = "button_style",
	parent = "slot_sized_button_pressed",
	size = 80,
	padding = 8
}
