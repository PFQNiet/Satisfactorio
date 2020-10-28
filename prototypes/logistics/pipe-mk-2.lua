local name = "pipeline-mk-2"
local basename = "pipe"

-- flow rate calculated as 600/min over 50 pipes
local pipe = table.deepcopy(data.raw.pipe[basename])
pipe.name = name
pipe.icon = "__Satisfactorio__/graphics/icons/"..name..".png"
local box = pipe.fluid_box
box.height = 0.0093
box.base_area = 0.01/box.height
for _,pic in pairs(pipe.pictures) do
	pic.tint = {0.2,0.8,1}
	if pic.hr_version then
		pic.hr_version.tint = {0.2,0.8,1}
	end
end

local pipeitem = table.deepcopy(data.raw.item[basename])
pipeitem.name = name
pipeitem.icon = pipe.icon
pipeitem.place_result = name
pipeitem.order = pipeitem.order.."-2"

local ingredients = {
	{"alclad-aluminium-sheet",1},
	{"plastic-bar",1}
}
local piperecipe = {
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 0.5,
	category = "building",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	enabled = false
}
local _group = data.raw['item-subgroup'][pipeitem.subgroup]
local piperecipe_undo = {
	name = name.."-undo",
	localised_name = {"recipe-name.dismantle",{"item-name."..name}},
	type = "recipe",
	ingredients = {
		{name,1}
	},
	results = ingredients,
	energy_required = 0.5,
	category = "unbuilding",
	subgroup = _group.group .. "-undo",
	order = _group.order .. "-" .. pipeitem.order,
	allow_decomposition = false,
	allow_intermediates = false,
	allow_as_intermediate = false,
	always_show_products = true,
	hide_from_stats = true,
	icons = {
		{icon = "__base__/graphics/icons/deconstruction-planner.png", icon_size = 64},
		{icon = "__Satisfactorio__/graphics/icons/"..name..".png", icon_size = 64}
	},
	enabled = false
}

data:extend({pipe,pipeitem,piperecipe,piperecipe_undo})
