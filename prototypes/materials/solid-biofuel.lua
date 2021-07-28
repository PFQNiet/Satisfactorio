local name = "solid-biofuel"
local item = {
	-- Solid Biofuel is used as "ammo" for the Chainsaw. 1 Solid Biofuel lasts for 6 seconds of continuous fire.
	type = "ammo",
	name = name,
	icon = graphics.."icons/"..name..".png",
	icon_size = 64,
	subgroup = "organic-resource",
	order = "h["..name.."]",
	stack_size = 200,
	fuel_category = "chemical",
	fuel_value = "450MJ",
	magazine_size = 6*60, -- one "ammo" per tick of use
	ammo_type = {
		category = "solid-biofuel",
		target_type = "entity",
		action = {
			type = "direct",
			trigger_target_mask = {"chainsawable"},
			filter_enabled = true,
			action_delivery = {
				type = "instant",
				target_effects = {
					{
						type = "damage",
						damage = {
							amount = 0.5,
							type = "chainsaw"
						}
					}
				}
			}
		}
	}
}

local recipe = {
	name = name,
	type = "recipe",
	ingredients = {
		{"biomass",8}
	},
	result = name,
	result_count = 4,
	energy_required = 4,
	category = "constructing",
	enabled = false
}
copyToHandcraft(recipe, 10)

data:extend{item,recipe}

data:extend{
	{type="ammo-category",name="solid-biofuel"}, -- for the Chainsaw
	{
		filename = "__base__/graphics/icons/tooltips/tooltip-category-chemical.png",
		flags = {"gui-icon"},
		height = 40,
		mipmap_count = 2,
		name = "tooltip-category-solid-biofuel",
		priority = "extra-high-no-scale",
		scale = 0.5,
		type = "sprite",
		width = 40
	},
	{
		type = "damage-type",
		name = "chainsaw"
	},
	{
		type = "trigger-target-type",
		name = "chainsawable"
	}
}
