function makeEquipment(params)
	---@type string
	local name = params.name
	---@type string
	local subgroup = params.subgroup
	---@type string
	local order = params.order
	---@type string
	local type = params.type
	---@type table
	local energy_source = params.energy_source
	---@type table
	local properties = params.properties
	---@type table
	local ingredients = params.ingredients
	---@type number
	local time = params.craft_time

	local item = {
		type = "armor",
		name = name,
		icon = graphics.."icons/"..name..".png",
		icon_size = 64,
		infinite = true,
		order = order.."["..name.."]",
		subgroup = subgroup,
		stack_size = 1,
		equipment_grid = name
	}
	local grid = {
		type = "equipment-grid",
		name = name,
		locked = true,
		width = 1,
		height = 1,
		equipment_categories = {name}
	}
	local category = {
		type = "equipment-category",
		name = name
	}
	local fakeitem = {
		type = "item",
		name = name.."-equipment",
		icon = item.icon,
		icon_size = item.icon_size,
		stack_size = 1,
		flags = {"hidden"},
		place_as_equipment_result = name.."-equipment"
	}
	local fakeequip = {
		type = type,
		name = name.."-equipment",
		categories = {name},
		energy_source = energy_source,
		shape = {
			width = 1,
			height = 1,
			type = "full"
		},
		sprite = {
			filename = item.icon,
			size = {64,64}
		}
	}
	for k,v in pairs(properties or {}) do
		fakeequip[k] = v
	end
	local recipe = {
		name = name,
		type = "recipe",
		ingredients = ingredients,
		result = name,
		energy_required = time,
		category = "equipment",
		enabled = false
	}

	data:extend{item, grid, category, fakeitem, fakeequip, recipe}

	return {
		item = item,
		grid = grid,
		category = category,
		fakeitem = fakeitem,
		fakeequip = fakeequip,
		recipe = recipe
	}
end

require("prototypes.equipment.medicinal-inhaler")
require("prototypes.equipment.parachute")
require("prototypes.equipment.blade-runners")
require("prototypes.equipment.zipline")
require("prototypes.equipment.jetpack")
require("prototypes.equipment.hover-pack")
require("prototypes.equipment.gas-mask")
require("prototypes.equipment.hazmat-suit")

-- Jump!
data:extend({
	{
		type = "custom-input",
		name = "jump",
		key_sequence = "J",
		order = "c",
		consuming = "game-only",
		action = "lua"
	}
})
