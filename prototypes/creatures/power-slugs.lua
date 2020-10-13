local shardname = "power-shard"
local powershard = {
	type = "module",
	name = shardname,
	icon = "__Satisfactorio__/graphics/icons/"..shardname..".png",
	icon_size = 64,
	stack_size = 50,
	subgroup = "mineral-resource",
	order = "k[power-slugs]-a["..shardname.."]",
	category = "speed",
	tier = 3,
	effect = {
		consumption = {bonus=1},
		speed = {bonus=0.5}
	}
}

local name = "green-power-slug"
local green = {
	picture = {
		filename = "__Satisfactorio__/graphics/icons/"..name..".png",
		size = {64,64},
	},
	collision_box = {{-0.8,-0.8},{0.8,0.8}},
	corpse = "big-remnants",
	dying_explosion = "big-explosion",
	flags = {
		"placeable-neutral",
		"placeable-off-grid",
		"not-on-map"
	},
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	max_health = 1,
	minable = {
		mining_time = 5,
		result = name
	},
	name = name,
	selection_box = {{-1,-1},{1,1}},
	render_layer = "object",
	max_health = 1,
	type = "simple-entity-with-owner"
}
local greenitem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "k[power-slugs]-b["..name.."]",
	place_result = name,
	stack_size = 50,
	subgroup = "mineral-resource",
	type = "item"
}
local greenrecipe1 = {
	type = "recipe",
	name = shardname.."-from-"..name.."-manual",
	localised_name = {"recipe-name.x-from-y",{"item-name."..shardname},{"item-name."..name}},
	order = "p-1",
	ingredients = {{name,1}},
	result = shardname,
	result_count = 1,
	energy_required = 4/4,
	category = "craft-bench",
	icons = {
		{icon = "__Satisfactorio__/graphics/icons/"..shardname..".png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64, scale = 0.25, shift = {-8, 8}}
	},
	hide_from_stats = true,
	enabled = false
}
local greenrecipe2 = {
	type = "recipe",
	name = shardname.."-from-"..name,
	localised_name = {"recipe-name.x-from-y",{"item-name."..shardname},{"item-name."..name}},
	order = "p-1",
	ingredients = {{name,1}},
	result = shardname,
	result_count = 1,
	energy_required = 8,
	category = "constructing",
	icons = {
		{icon = "__Satisfactorio__/graphics/icons/"..shardname..".png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64, scale = 0.25, shift = {-8, 8}}
	},
	hide_from_stats = true,
	hide_from_player_crafting = true,
	enabled = false
}

name = "yellow-power-slug"
local yellow = {
	picture = {
		filename = "__Satisfactorio__/graphics/icons/"..name..".png",
		size = {64,64},
	},
	collision_box = {{-0.8,-0.8},{0.8,0.8}},
	corpse = "big-remnants",
	dying_explosion = "big-explosion",
	flags = {
		"placeable-neutral",
		"placeable-off-grid",
		"not-on-map"
	},
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	max_health = 1,
	minable = {
		mining_time = 5,
		result = name
	},
	name = name,
	selection_box = {{-1,-1},{1,1}},
	render_layer = "object",
	max_health = 1,
	type = "simple-entity-with-owner"
}
local yellowitem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "k[power-slugs]-c["..name.."]",
	place_result = name,
	stack_size = 50,
	subgroup = "mineral-resource",
	type = "item"
}
local yellowrecipe1 = {
	type = "recipe",
	name = shardname.."-from-"..name.."-manual",
	localised_name = {"recipe-name.x-from-y",{"item-name."..shardname},{"item-name."..name}},
	order = "p-2",
	ingredients = {{name,1}},
	result = shardname,
	result_count = 2,
	energy_required = 6/4,
	category = "craft-bench",
	icons = {
		{icon = "__Satisfactorio__/graphics/icons/"..shardname..".png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64, scale = 0.25, shift = {-8, 8}}
	},
	hide_from_stats = true,
	enabled = false
}
local yellowrecipe2 = {
	type = "recipe",
	name = shardname.."-from-"..name,
	localised_name = {"recipe-name.x-from-y",{"item-name."..shardname},{"item-name."..name}},
	order = "p-2",
	ingredients = {{name,1}},
	result = shardname,
	result_count = 2,
	energy_required = 12,
	category = "constructing",
	icons = {
		{icon = "__Satisfactorio__/graphics/icons/"..shardname..".png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64, scale = 0.25, shift = {-8, 8}}
	},
	hide_from_stats = true,
	hide_from_player_crafting = true,
	enabled = false
}

name = "purple-power-slug"
local purple = {
	picture = {
		filename = "__Satisfactorio__/graphics/icons/"..name..".png",
		size = {64,64},
	},
	collision_box = {{-0.8,-0.8},{0.8,0.8}},
	corpse = "big-remnants",
	dying_explosion = "big-explosion",
	flags = {
		"placeable-neutral",
		"placeable-off-grid",
		"not-on-map"
	},
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	max_health = 1,
	minable = {
		mining_time = 5,
		result = name
	},
	name = name,
	selection_box = {{-1,-1},{1,1}},
	render_layer = "object",
	max_health = 1,
	type = "simple-entity-with-owner"
}
local purpleitem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "k[power-slugs]-d["..name.."]",
	place_result = name,
	stack_size = 50,
	subgroup = "mineral-resource",
	type = "item"
}
local purplerecipe1 = {
	type = "recipe",
	name = shardname.."-from-"..name.."-manual",
	localised_name = {"recipe-name.x-from-y",{"item-name."..shardname},{"item-name."..name}},
	order = "p-3",
	ingredients = {{name,1}},
	result = shardname,
	result_count = 5,
	energy_required = 12/4,
	category = "craft-bench",
	icons = {
		{icon = "__Satisfactorio__/graphics/icons/"..shardname..".png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64, scale = 0.25, shift = {-8, 8}}
	},
	hide_from_stats = true,
	enabled = false
}
local purplerecipe2 = {
	type = "recipe",
	name = shardname.."-from-"..name,
	localised_name = {"recipe-name.x-from-y",{"item-name."..shardname},{"item-name."..name}},
	order = "p-3",
	ingredients = {{name,1}},
	result = shardname,
	result_count = 5,
	energy_required = 24,
	category = "constructing",
	icons = {
		{icon = "__Satisfactorio__/graphics/icons/"..shardname..".png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64, scale = 0.25, shift = {-8, 8}}
	},
	hide_from_stats = true,
	hide_from_player_crafting = true,
	enabled = false
}

data:extend({
	powershard,
	green,greenitem,greenrecipe1,greenrecipe2,
	yellow,yellowitem,yellowrecipe1,yellowrecipe2,
	purple,purpleitem,purplerecipe1,purplerecipe2
})
