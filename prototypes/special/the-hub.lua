local name = "the-hub"
local hub = {
	type = "simple-entity-with-owner",
	name = name,
	picture = {
		north = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ns.png",
			size = {416,224},
			shift = {1,0}
		},
		east = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ew.png",
			size = {224,416},
			shift = {0,1}
		},
		south = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ns.png",
			size = {416,224},
			shift = {-1,0}
		},
		west = {
			filename = "__Satisfactorio__/graphics/placeholders/"..name.."-ew.png",
			size = {224,416},
			shift = {0,-1}
		}
	},
	collision_box = {{-5.3,-3.3},{7.3,3.3}},
	collision_mask = {"object-layer","floor-layer","water-tile"},
	selection_box = {{-5.5,-3.5},{7.5,3.5}},
	selectable_in_game = false,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	max_health = 1,
	flags = {
		"placeable-player",
		"player-creation"
	},
	render_layer = "floor"
}

local hubterminal = {
	allowed_effects = {},
	animation = {
		filename = "__base__/graphics/entity/steel-chest/steel-chest.png",
		size = {32,40},
		shift = {0,-0.015625}
	},
	collision_box = {{-0.35,-0.85},{0.35,0.85}},
	crafting_categories = {"hub-progressing"},
	crafting_speed = 1,
	energy_source = {type="void"},
	energy_usage = "1W",
	open_sound = {
		filename = "__base__/sound/machine-open.ogg",
		volume = 0.5
	},
	close_sound = {
		filename = "__base__/sound/machine-close.ogg",
		volume = 0.5
	},
	flags = {
		"placeable-player",
		"player-creation",
		"not-blueprintable",
		"placeable-off-grid", -- it goes between two tiles
		"no-automated-item-removal",
		"no-automated-item-insertion"
	},
	draw_entity_info_icon_background = false,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	max_health = 1,
	minable = {
		mining_time = 1,
		result = name
	},
	name = name.."-terminal",
	placeable_by = {item=name,count=1},
	selection_box = {{-0.5,-1},{0.5,1}},
	type = "assembling-machine",
	return_ingredients_on_change = false
}

local hubitem = {
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	name = name,
	order = "a["..name.."]",
	place_result = name,
	stack_size = 1,
	subgroup = "special",
	type = "item"
}

local ingredients = {
	{"hub-parts",1}
}
local hubrecipe = {
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 1,
	category = "building",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true
}
local _group = data.raw['item-subgroup'][hubitem.subgroup]
local hubrecipe_undo = {
	name = name.."-undo",
	localised_name = {"recipe-name.dismantle",{"entity-name."..name}},
	type = "recipe",
	ingredients = {
		{name,1}
	},
	results = ingredients,
	energy_required = 1,
	category = "unbuilding",
	subgroup = _group.group .. "-undo",
	order = _group.order .. "-" .. hubitem.order,
	allow_decomposition = false,
	allow_intermediates = false,
	allow_as_intermediate = false,
	always_show_products = true,
	hide_from_stats = true,
	icons = {
		{icon = "__base__/graphics/icons/deconstruction-planner.png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64}
	}
}

data:extend({hub,hubterminal,hubitem,hubrecipe,hubrecipe_undo})

local silo = table.deepcopy(data.raw['rocket-silo']['rocket-silo'])
silo.name = "ficsit-freighter"
silo.icon = "__Satisfactorio__/graphics/icons/drop-pod.png"
silo.icon_size = 64
silo.icon_mipmaps = 1
silo.collision_box = {{-1.3,-1.3},{1.3,1.3}}
silo.selection_box = {{-1.5,-1.5},{1.5,1.5}}
silo.selectable_in_game = false
silo.energy_source = {type="void"}
silo.rocket_parts_required = 1
silo.max_health = 1
silo.fixed_recipe = nil
-- scale silo graphics down to 1/3
for _,key in pairs({
	"arm_01_back_animation", "arm_02_right_animation", "arm_03_front_animation",
	"base_day_sprite", "base_engine_light", "base_front_sprite",
	"door_back_sprite", "door_front_sprite",
	"hole_light_sprite", "hole_sprite",
	"rocket_glow_overlay_sprite", "rocket_shadow_overlay_sprite",
	"satellite_animation", "shadow_sprite"
}) do
	local graphic = silo[key]
	graphic.scale = (graphic.scale or 1) / 3
	if graphic.shift then
		graphic.shift[1] = graphic.shift[1] / 3
		graphic.shift[2] = graphic.shift[2] / 3
	end
	graphic = graphic.hr_version
	if graphic then
		graphic.scale = (graphic.scale or 1) / 3
		if graphic.shift then
			graphic.shift[1] = graphic.shift[1] / 3
			graphic.shift[2] = graphic.shift[2] / 3
		end
	end
end
for _,graphic in pairs(silo.red_lights_back_sprites.layers) do
	graphic.scale = (graphic.scale or 1) / 3
	if graphic.shift then
		graphic.shift[1] = graphic.shift[1] / 3
		graphic.shift[2] = graphic.shift[2] / 3
	end
	graphic = graphic.hr_version
	if graphic then
		graphic.scale = (graphic.scale or 1) / 3
		if graphic.shift then
			graphic.shift[1] = graphic.shift[1] / 3
			graphic.shift[2] = graphic.shift[2] / 3
		end
	end
end
for _,graphic in pairs(silo.red_lights_front_sprites.layers) do
	graphic.scale = (graphic.scale or 1) / 3
	if graphic.shift then
		graphic.shift[1] = graphic.shift[1] / 3
		graphic.shift[2] = graphic.shift[2] / 3
	end
	graphic = graphic.hr_version
	if graphic then
		graphic.scale = (graphic.scale or 1) / 3
		if graphic.shift then
			graphic.shift[1] = graphic.shift[1] / 3
			graphic.shift[2] = graphic.shift[2] / 3
		end
	end
end
silo.door_back_open_offset[1] = silo.door_back_open_offset[1] / 3
silo.door_back_open_offset[2] = silo.door_back_open_offset[2] / 3
silo.door_front_open_offset[1] = silo.door_front_open_offset[1] / 3
silo.door_front_open_offset[2] = silo.door_front_open_offset[2] / 3
silo.hole_clipping_box[1][1] = silo.hole_clipping_box[1][1] / 3
silo.hole_clipping_box[1][2] = silo.hole_clipping_box[1][2] / 3
silo.hole_clipping_box[2][1] = silo.hole_clipping_box[2][1] / 3
silo.hole_clipping_box[2][2] = silo.hole_clipping_box[2][2] / 3
silo.rocket_entity = silo.name.."-rocket"

local rocket = table.deepcopy(data.raw['rocket-silo-rocket']['rocket-silo-rocket'])
rocket.name = silo.rocket_entity
for _,key in pairs({
	"rocket_flame_animation", "rocket_flame_left_animation", "rocket_flame_right_animation",
	"rocket_glare_overlay_sprite", "rocket_shadow_sprite", "rocket_sprite",
	"rocket_smoke_bottom1_animation", "rocket_smoke_bottom2_animation",
	"rocket_smoke_top1_animation", "rocket_smoke_top2_animation", "rocket_smoke_top3_animation"
}) do
	local graphic = rocket[key]
	graphic.scale = (graphic.scale or 1) / 3
	if graphic.shift then
		graphic.shift[1] = graphic.shift[1] / 3
		graphic.shift[2] = graphic.shift[2] / 3
	end
	graphic = graphic.hr_version
	if graphic then
		graphic.scale = (graphic.scale or 1) / 3
		if graphic.shift then
			graphic.shift[1] = graphic.shift[1] / 3
			graphic.shift[2] = graphic.shift[2] / 3
		end
	end
end
rocket.rocket_visible_distance_from_center = rocket.rocket_visible_distance_from_center / 3
rocket.rocket_render_layer_switch_distance = rocket.rocket_render_layer_switch_distance / 3
rocket.full_render_layer_switch_distance = rocket.full_render_layer_switch_distance / 3
rocket.glow_light.shift[1] = rocket.glow_light.shift[1] / 3
rocket.glow_light.shift[2] = rocket.glow_light.shift[2] / 3
rocket.glow_light.size = rocket.glow_light.size / 3
for _,key in pairs({"rocket_initial_offset","rocket_rise_offset","rocket_launch_offset"}) do
	local offset = rocket[key]
	offset[1] = offset[1] / 3
	offset[2] = offset[2] / 3
end
rocket.shadow_slave_entity = rocket.name.."-shadow"

local shadow = table.deepcopy(data.raw['rocket-silo-rocket-shadow']['rocket-silo-rocket-shadow'])
shadow.name = rocket.shadow_slave_entity
shadow.collision_box[1][1] = shadow.collision_box[1][1] / 3
shadow.collision_box[1][2] = shadow.collision_box[1][2] / 3
shadow.collision_box[2][1] = shadow.collision_box[2][1] / 3
shadow.collision_box[2][2] = shadow.collision_box[2][2] / 3

data:extend({silo,rocket,shadow})

-- Dummy recipes that can be used to designate the tiers of HUB progress
for i=0,8 do
	data:extend{{
		type = "recipe",
		name = "hub-tier"..i,
		ingredients = {},
		result = "hub-tier"..i,
		energy_required = 1,
		category = "hub-progressing",
		allow_intermediates = false,
		allow_as_intermediate = false,
		hide_from_stats = true,
		hide_from_player_crafting = true,
		enabled = i == 0
	},{
		type = "item",
		name = "hub-tier"..i,
		icon = "__base__/graphics/icons/signal/signal_"..i..".png",
		icon_mipmaps = 4,
		icon_size = 64,
		stack_size = 1,
		flags = {"hidden"},
		subgroup = "hub-tier"..i,
		order = "0"
	}}
end
