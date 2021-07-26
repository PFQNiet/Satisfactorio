data:extend{
	-- Hard Drive item used for submission, and as a fake item on the individual tech's consumption (the real tech uses mam-hard-drive from technology.lua)
	{
		type = "tool",
		name = "hard-drive",
		subgroup = "special",
		order = "z[hard-drive]",
		stack_size = 100,
		icon = graphics.."icons/hard-drive.png",
		icon_size = 64,
		infinite = true
	}
}

local alts = require(modpath.."constants.alt-recipes")
local recipes = {}
for i,r in pairs(alts) do
	r = table.deepcopy(r)
	if r.ingredients then
		local icons = r.icons
		local product = data.raw.item[r.main_product or r.result] or data.raw.capsule[r.result] or data.raw.fluid[r.main_product]
		r.icons = {
			{icon = product.icon, icon_size = 64}
		}
		for n,icon in pairs(icons) do
			table.insert(r.icons, {icon = graphics.."icons/"..icon..".png", icon_size = 64, scale = 0.25, shift = {-8, 8-(n-1)*8}})
		end
		r.type = "recipe"
		r.localised_name = {"recipe-name."..r.name}
		r.order = product.order.."-x-alt["..i.."]"
		r.allow_decomposition = r.name == "compacted-coal" or r.name == "turbofuel"
		r.enabled = false
		r.prerequisites = nil
		table.insert(recipes, r)
	end
end
data:extend(recipes)

for _,r in pairs(alts) do
	-- table.insert(prereq,"mam-hard-drive")
	if #r.prerequisites == 0 then r.prerequisites = {"hub-tier1-field-research"} end
	local recipe = data.raw.recipe[r.name]
	local product = recipe and (data.raw.item[recipe.main_product or recipe.result] or data.raw.capsule[recipe.result] or data.raw.fluid[recipe.main_product]) or nil
	local order = "m-x-"..(product and data.raw['item-subgroup'][product.subgroup].order.."-"..product.order or "z")
	data:extend({
		{
			type = "technology",
			name = "alt-"..r.name,
			localised_name = recipe and {"recipe-name."..recipe.name} or {"technology-name.alt-"..r.name},
			localised_description = {"technology-description.hard-drive"},
			order = order,
			icons = {
				{icon = "__Satisfactorio__/graphics/technology/mam/hard-drive.png", icon_size = 256},
				product
					and {icon = product.icon, icon_size = 64, scale = 2, shift = {-64,64}}
					or {icon = "__Satisfactorio__/graphics/technology/mam/thumbsup.png", icon_size = 256, scale = 0.5, shift = {-64,64}}
			},
			prerequisites = r.prerequisites,
			unit = {
				count = 1,
				time = 600,
				ingredients = {{"hard-drive",1}}
			},
			effects = {
				recipe
					and {type="unlock-recipe",recipe=r.name}
					or {type="character-inventory-slots-bonus",modifier=6,use_icon_overlay_constant=false}
			}
		}
	})
end
-- add packaging/unpacking turbofuel
table.insert(data.raw.technology['alt-turbofuel'].effects, {type="unlock-recipe",recipe="packaged-turbofuel"})
table.insert(data.raw.technology['alt-turbofuel'].effects, {type="unlock-recipe",recipe="unpack-turbofuel"})
table.insert(data.raw.technology['alt-turbo-heavy-fuel'].effects, {type="unlock-recipe",recipe="packaged-turbofuel"})
table.insert(data.raw.technology['alt-turbo-heavy-fuel'].effects, {type="unlock-recipe",recipe="unpack-turbofuel"})
table.insert(data.raw.technology['alt-turbo-blend-fuel'].effects, {type="unlock-recipe",recipe="packaged-turbofuel"})
table.insert(data.raw.technology['alt-turbo-blend-fuel'].effects, {type="unlock-recipe",recipe="unpack-turbofuel"})
