local shardname = "power-shard"
local powershard = {
	type = "module",
	name = shardname,
	icon = graphics.."icons/"..shardname..".png",
	icon_size = 64,
	stack_size = 50,
	subgroup = "mineral-resource",
	order = "s[power-slugs]-a["..shardname.."]",
	category = "speed",
	tier = 3,
	effect = {
		consumption = {bonus=1},
		speed = {bonus=0.5}
	}
}
data:extend{powershard}

local function makePowerSlug(params)
	---@type string
	local name = params.name
	---@type string
	local order = params.order
	---@type int
	local shards = params.shards
	---@type int
	local time = params.craft_time
	---@type int
	local hand = params.hand_craft_time

	local slug = {
		type = "simple-entity-with-owner",
		name = name,
		icon = graphics.."icons/"..name..".png",
		icon_size = 64,
		selection_box = {{-1,-1},{1,1}},
		collision_box = {{-0.7,-0.7},{0.7,0.7}},
		collision_mask = {"object-layer","train-layer"},
		picture = {
			filename = graphics.."icons/"..name..".png",
			size = {64,64}
		},
		render_layer = "lower-object",
		flags = {
			"placeable-neutral",
			"placeable-off-grid",
			"not-on-map"
		},
		max_health = 1,
		minable = {
			mining_time = 5,
			result = name
		}
	}
	local decorative = table.deepcopy(slug)
	decorative.name = name.."-decorative"
	decorative.localised_name = {"entity-name."..name}
	decorative.flags = {"placeable-player"}

	local item = {
		type = "item",
		name = name,
		icon = graphics.."icons/"..name..".png",
		icon_size = 64,
		place_result = name.."-decorative",
		stack_size = 50,
		subgroup = "mineral-resource",
		order = "s[power-slugs]-"..order.."["..name.."]"
	}
	local recipe = {
		type = "recipe",
		name = shardname.."-from-"..name,
		localised_name = {"recipe-name.x-from-y",{"item-name."..shardname},{"entity-name."..name}},
		ingredients = {{name,1}},
		result = shardname,
		result_count = shards,
		energy_required = time,
		category = "constructing",
		order = "s[power-slugs]-"..order.."["..name.."]",
		icons = {
			{icon = graphics.."icons/"..shardname..".png", icon_size = 64},
			{icon = graphics.."icons/"..name..".png", icon_size = 64, scale = 0.25, shift = {-8, 8}}
		},
		enabled = false
	}
	copyToHandcraft(recipe, hand)

	data:extend{slug, decorative, item, recipe}
end

makePowerSlug{
	name = "green-power-slug",
	order = "b",
	shards = 1,
	craft_time = 8,
	hand_craft_time = 4
}

makePowerSlug{
	name = "yellow-power-slug",
	order = "c",
	shards = 2,
	craft_time = 12,
	hand_craft_time = 6
}

makePowerSlug{
	name = "purple-power-slug",
	order = "d",
	shards = 5,
	craft_time = 24,
	hand_craft_time = 12
}

data:extend{
	{
		type = "autoplace-control",
		name = "x-powerslug",
		order = "t",
		richness = false,
		category = "terrain"
	},
	{
		type = "noise-layer",
		name = "x-powerslug"
	}
}
