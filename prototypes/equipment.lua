---@class makeEquipment_params
---@field name string
---@field subgroup string
---@field order string
---@field type string
---@field energy_source LuaElectricEnergySourcePrototype
---@field properties table Additional properties of the equipment
---@field ingredients Ingredient[]
---@field craft_time number

---@class makeEquipment_return
---@field item table
---@field grid table
---@field category table
---@field equipment table
---@field recipe table

---@param params makeEquipment_params
---@return makeEquipment_return
function makeEquipment(params)
	local name = params.name
	local subgroup = params.subgroup
	local order = params.order
	local type = params.type
	local energy_source = params.energy_source
	local properties = params.properties
	local ingredients = params.ingredients
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
		},
		take_result = "raw-fish"
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

	data:extend{item, grid, category, fakeequip, recipe}

	return {
		item = item,
		grid = grid,
		category = category,
		equipment = fakeequip,
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

data:extend({
	{type="item-subgroup",group="combat",name="environment",order="f"},
	-- Jump!
	{
		type = "custom-input",
		name = "jump",
		key_sequence = "J",
		order = "c",
		consuming = "game-only",
		action = "lua"
	}
})
