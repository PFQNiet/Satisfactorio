local name = "pipeline-pump-mk-2"
local basename = "pump"

local pump = table.deepcopy(data.raw.pump[basename])
pump.name = name
pump.icon = "__Satisfactorio__/graphics/icons/"..name..".png"
pump.pumping_speed = 600/60/60 -- 600/minute
pump.energy_usage = "12MW"
local box = pump.fluid_box
for _,pic in pairs(pump.animations) do
	pic.tint = {0.2,0.8,1}
	if pic.hr_version then
		pic.hr_version.tint = {0.2,0.8,1}
	end
end

local pumpitem = table.deepcopy(data.raw.item[basename])
pumpitem.name = name
pumpitem.icon = pump.icon
pumpitem.place_result = name
pumpitem.order = pumpitem.order.."-2"

local ingredients = {{"motor",2},{"alclad-aluminium-sheet",4},{"plastic-bar",8}}
local pumprecipe = {
	name = name,
	type = "recipe",
	ingredients = ingredients,
	result = name,
	energy_required = 0.1,
	category = "building",
	allow_intermediates = false,
	allow_as_intermediate = false,
	hide_from_stats = true,
	enabled = false
}
local _group = data.raw['item-subgroup'][pumpitem.subgroup]
local pumprecipe_undo = {
	name = name.."-undo",
	localised_name = {"recipe-name.dismantle",{"item-name."..name}},
	type = "recipe",
	ingredients = {
		{name,1}
	},
	results = ingredients,
	energy_required = 0.1,
	category = "unbuilding",
	subgroup = _group.group .. "-undo",
	order = _group.order .. "-" .. pumpitem.order,
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

data:extend({pump,pumpitem,pumprecipe,pumprecipe_undo})
