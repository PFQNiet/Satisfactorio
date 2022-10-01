modname = "__Satisfactorio__"
modpath = modname.."."
graphics = modname.."/graphics/"

empty_graphic = {
	filename = graphics.."empty.png",
	width = 32,
	height = 32
}
function makeRotatedSprite(name, width, height, shift)
	local graphic = {
		north = {
			filename = graphics.."placeholders/"..name.."-n.png",
			size = {width,height}
		},
		east = {
			filename = graphics.."placeholders/"..name.."-e.png",
			size = {height,width}
		},
		south = {
			filename = graphics.."placeholders/"..name.."-s.png",
			size = {width,height}
		},
		west = {
			filename = graphics.."placeholders/"..name.."-w.png",
			size = {height,width}
		}
	}
	if shift then
		graphic.north.shift = {shift[1],shift[2]}
		graphic.east.shift = {-shift[2],shift[1]}
		graphic.south.shift = {-shift[1],-shift[2]}
		graphic.west.shift = {shift[2],-shift[1]}
	end
	return graphic
end

basesounds = require("__base__/prototypes/entity/sounds")
function copySoundsFrom(entity)
	return {
		open_sound = table.deepcopy(entity.open_sound),
		close_sound = table.deepcopy(entity.close_sound),
		working_sound = table.deepcopy(entity.working_sound)
	}
end

function copyToHandcraft(recipe, hammers, is_equipment)
	local category = is_equipment and "equipment" or "craft-bench"
	local copy = table.deepcopy(recipe)
	copy.name = copy.name.."-manual"
	copy.energy_required = hammers/4
	copy.hide_from_player_crafting = true
	copy.category = category
	data:extend{copy}
end

function makeBuildingRecipe(recipe)
	recipe.type = "recipe"
	recipe.energy_required = 1
	recipe.category = "building"
	recipe.allow_intermediates = false
	recipe.allow_as_intermediate = false
	recipe.hide_from_stats = true
	recipe.enabled = false
	return recipe
end

foundation_layer = nil
train_platform_layer = nil

data:extend{
	{type="recipe-category",name="building"},
	{type="item-subgroup",name="placeholder-buildings",group="effects",order="zzz"}
}
for _,key in pairs({"logistics","production","intermediate-products","combat"}) do
	local igroup = data.raw["item-group"][key]
	igroup.icon = graphics.."item-group/"..key..".png"
	igroup.icon_size = 64
	igroup.icon_mipmaps = 1
end

require("prototypes.fonts-and-styles")
require("prototypes.character")
require("prototypes.creatures")
require("prototypes.resources")
require("prototypes.resource-scanner")
require("prototypes.materials")
require("prototypes.constructors")
require("prototypes.special")
require("prototypes.power")
require("prototypes.logistics")
require("prototypes.organisation")
require("prototypes.miners")
require("prototypes.vehicles")
require("prototypes.weapons")
require("prototypes.equipment")
require("prototypes.radioactivity")
require("prototypes.technology")
require("prototypes.map-tweaks")
require("prototypes.vanilla-cleanup")
require("prototypes.tips-and-tricks")
require("prototypes.menu-sims")

require("compatibility.factorissimo2")
require("compatibility.gcki")

for _,fluid in pairs(data.raw.fluid) do
	fluid.auto_barrel = false
end

data:extend{
	{
		type = "custom-input",
		name = "recipe-browser",
		key_sequence = "X",
		order = "a",
		consuming = "game-only",
		action = "lua"
	},
	{
		type = "shortcut",
		name = "recipe-browser",
		action = "lua",
		associated_control_input = "recipe-browser",
		icon = {
			filename = "__core__/graphics/icons/mip/list-view.png",
			size = 32,
			mipmap_count = 2
		},
		order = "s-a[recipe-browser]"
	},
	--[[ wanted feature but can't do it because of interaction with transport belts
	{
		type = "item-entity",
		name = "stack-on-ground",
		collision_box = {{-0.14,-0.14},{0.14,0.14}},
		collision_mask = {"item-layer","transport-belt-layer"},
		selection_box = {{-0.17,-0.17},{0.17,0.17}},
		flags = {"placeable-off-grid","not-on-map"},
		icon = "__core__/graphics/item-on-ground.png",
		icon_size = 64,
		minable = {mining_time=0.25}
	}
	]]
}
