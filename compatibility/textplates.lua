-- add compatibility for textplates
local mod = "textplates"
if mods[mod] then
	local materials = {
		["stone"] = "stone",
		["iron"] = "iron-plate",
		["copper"] = "copper-sheet",
		["steel"] = "steel-beam",
		["concrete"] = "concrete",
		["glass"] = "quartz-crystal",
		["gold"] = "caterium-ingot",
		["uranium"] = "uranium-ore",
	}

	for _, type in pairs(textplates.types) do
		local recipe = data.raw.recipe[type.name]
		recipe.category = "building"
		recipe.energy_required = 1
		recipe.allow_intermediates = false
		recipe.allow_as_intermediate = false
		recipe.hide_from_stats = true
		recipe.enabled = false
		recipe.ingredients[1].name = materials[type.material]
		recipe.result = type.name

		local entity = data.raw["simple-entity-with-force"][type.name]
		entity.max_health = 1
		-- apply purple tint to quartz-glass
		if type.material == "glass" then
			for _,pic in pairs(entity.pictures) do
				pic.layers[1].tint = {0.95,0.9,1}
			end
		end

		local item = data.raw.item[type.name]
		if not item.flags then item.flags = {} end
		table.insert(item.flags, "only-in-cursor")
	end

	-- add various plate recipes to tech tree when their materials are unlocked
	-- recipe name: textplate-(small|large)-(%material)
	data.raw.recipe['textplate-small-iron'].enabled = true
	data.raw.recipe['textplate-large-iron'].enabled = true
	local fx = data.raw.technology['hub-tier2-part-assembly'].effects
	table.insert(fx, {type="unlock-recipe",recipe="textplate-small-copper"})
	table.insert(fx, {type="unlock-recipe",recipe="textplate-large-copper"})
	fx = data.raw.technology['hub-tier0-hub-upgrade3'].effects
	table.insert(fx, {type="unlock-recipe",recipe="textplate-small-stone"})
	table.insert(fx, {type="unlock-recipe",recipe="textplate-large-stone"})
	table.insert(fx, {type="unlock-recipe",recipe="textplate-small-concrete"})
	table.insert(fx, {type="unlock-recipe",recipe="textplate-large-concrete"})
	fx = data.raw.technology['hub-tier3-basic-steel-production'].effects
	table.insert(fx, {type="unlock-recipe",recipe="textplate-small-steel"})
	table.insert(fx, {type="unlock-recipe",recipe="textplate-large-steel"})
	fx = data.raw.technology['mam-quartz-quartz-crystals'].effects
	table.insert(fx, {type="unlock-recipe",recipe="textplate-small-glass"})
	table.insert(fx, {type="unlock-recipe",recipe="textplate-large-glass"})
	fx = data.raw.technology['mam-caterium-caterium-ingots'].effects
	table.insert(fx, {type="unlock-recipe",recipe="textplate-small-gold"})
	table.insert(fx, {type="unlock-recipe",recipe="textplate-large-gold"})
	fx = data.raw.technology['hub-tier8-nuclear-power'].effects
	table.insert(fx, {type="unlock-recipe",recipe="textplate-small-uranium"})
	table.insert(fx, {type="unlock-recipe",recipe="textplate-large-uranium"})
end
