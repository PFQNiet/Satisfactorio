---@class makeAssemblingMachine_params
---@field name string
---@field type string
---@field size int[]
---@field category string
---@field energy int
---@field allow_power_shards boolean
---@field sounds table
---@field subgroup string
---@field order string
---@field ingredients Ingredient[]
---@field available_from_start boolean
---@field pipe_connections table

---@class makeAssemblingMachine_return
---@field machine table
---@field item table
---@field recipe table

---@param params makeAssemblingMachine_params
---@return makeAssemblingMachine_return
function makeAssemblingMachine(params)
	local name = params.name
	local type = params.type or "assembling-machine"
	local width = params.size[1]
	local height = params.size[2]
	local category = params.category
	local energy = params.energy
	local shards = params.allow_power_shards
	local sounds = params.sounds or {}
	local subgroup = params.subgroup
	local order = params.order
	local ingredients = params.ingredients
	local enabled = params.available_from_start
	local pipes = params.pipe_connections

	local machine = {
		type = type,
		name = name,
		icon = graphics.."icons/"..name..".png",
		icon_size = 64,
		max_health = 1,
		minable = {
			mining_time = 0.5,
			result = name
		},
		selection_box = {{-width/2, -height/2}, {width/2, height/2}},
		collision_box = {{-width/2+0.3, -height/2+0.3}, {width/2-0.3, height/2-0.3}},
		animation = makeRotatedSprite(name, width*32, height*32),
		energy_source = {type="void"},
		energy_usage = "1W",
		crafting_speed = 1,
		crafting_categories = {category},
		open_sound = sounds.open_sound or basesounds.machine_open,
		close_sound = sounds.close_sound or basesounds.machine_close,
		working_sound = sounds.working_sound or nil,
		flags = {
			"placeable-player",
			"player-creation"
		}
	}
	if energy then
		machine.energy_source = {
			type = "electric",
			usage_priority = "secondary-input",
			drain = "0W"
		}
		machine.energy_usage = energy.."MW"
	end
	if shards then
		machine.allowed_effects = {"speed","consumption"}
		machine.module_specification = {module_slots=3}
	end
	if pipes then
		machine.fluid_boxes = {}
		local snapToBoundingBox = function(pos)
			return {
				math.max(machine.selection_box[1][1]-0.5, math.min(machine.selection_box[2][1]+0.5, pos[1])),
				math.max(machine.selection_box[1][2]-0.5, math.min(machine.selection_box[2][2]+0.5, pos[2]))
			}
		end
		for _,pos in pairs(pipes.input or {}) do
			table.insert(machine.fluid_boxes, {
				base_area = 0.5,
				base_level = -1,
				production_type = "input",
				filter = pipes.filter,
				pipe_connections = {{
					type = "input",
					position = snapToBoundingBox(pos)
				}},
				pipe_covers = pipecoverspictures()
			})
		end
		for _,pos in pairs(pipes.output or {}) do
			table.insert(machine.fluid_boxes, {
				base_area = 0.5,
				base_level = 1,
				production_type = "output",
				pipe_connections = {{
					type = "output",
					position = snapToBoundingBox(pos)
				}},
				pipe_covers = pipecoverspictures()
			})
		end
	end

	local item = {
		type = "item",
		name = name,
		icon = machine.icon,
		icon_size = machine.icon_size,
		place_result = name,
		stack_size = 50,
		subgroup = subgroup,
		order = order.."["..name.."]",
		flags = {"only-in-cursor"}
	}

	local recipe = {
		type = "recipe",
		name = name,
		ingredients = ingredients,
		result = name,
		energy_required = 1,
		category = "building",
		allow_intermediates = false,
		allow_as_intermediate = false,
		hide_from_stats = true,
		enabled = false
	}
	if enabled then
		recipe.enabled = true
	end

	data:extend{machine, item, recipe}
	return {
		machine = machine,
		item = item,
		recipe = recipe
	}
end

require("prototypes.constructors.craft-bench")
require("prototypes.constructors.equipment-workshop")
require("prototypes.constructors.smelter")
require("prototypes.constructors.foundry")
require("prototypes.constructors.constructor")
require("prototypes.constructors.assembler")
require("prototypes.constructors.manufacturer")
require("prototypes.constructors.refinery")
require("prototypes.constructors.blender")
require("prototypes.constructors.particle-accelerator")
require("prototypes.constructors.packager")
