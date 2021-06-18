local name = "blade-runners"
local item = {
	type = "armor",
	name = name,
	icon = "__Satisfactorio__/graphics/icons/"..name..".png",
	icon_size = 64,
	infinite = true,
	order = "s-b["..name.."]",
	subgroup = "armor",
	stack_size = 1,
	equipment_grid = name
}
local grid = {
	type = "equipment-grid",
	name = name,
	locked = true,
	width = 2,
	height = 1,
	equipment_categories = {name}
}
local category = {
	type = "equipment-category",
	name = name
}
-- adjust Exoskeleton
data.raw.recipe['exoskeleton-equipment'] = {
	name = "exoskeleton-equipment",
	type = "recipe",
	ingredients = {
		{"quickwire",50},
		{"modular-frame",3},
		{"rotor",3}
	},
	result = name,
	energy_required = 20/4,
	category = "equipment",
	enabled = false
}
local exoitem = data.raw.item['exoskeleton-equipment']
exoitem.icon = "__Satisfactorio__/graphics/icons/"..name..".png"
exoitem.icon_mipmaps = 0
exoitem.stack_size = 1
exoitem.flags = {"hidden"}
local exo = data.raw['movement-bonus-equipment']['exoskeleton-equipment']
exo.categories = {name}
exo.movement_bonus = 0.5
exo.shape = {
	width = 1,
	height = 1,
	type = "full"
}
exo.sprite = {
	filename = "__Satisfactorio__/graphics/icons/"..name..".png",
	size = {64,64}
}
exo.energy_consumption = "1MW"

data:extend{item, grid, category}

data:extend{
	{
		type = "item",
		name = name.."-power",
		localised_name = {"item-name.exoskeleton-equipment"},
		icon = "__Satisfactorio__/graphics/icons/battery.png",
		icon_size = 64,
		stack_size = 1,
		flags = {"hidden"},
		place_as_equipment_result = name.."-power"
	},
	{
		type = "generator-equipment",
		name = name.."-power",
		sprite = {
			filename = "__Satisfactorio__/graphics/icons/battery.png",
			size = {64,64}
		},
		categories = {name},
		energy_source = {
			type = "electric",
			usage_priority = "primary-output"
		},
		power = "1MW",
		shape = {
			width = 1,
			height = 1,
			type = "full"
		}
	}
}
