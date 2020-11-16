require("compatibility.construction-drones")

-- scan recipes for "iron-gear-wheel" and replace with "screw"
local function process(recipe)
	for _,ingredient in pairs(recipe.ingredients) do
		if ingredient[1] == "iron-gear-wheel" then
			ingredient[1] = "screw"
		elseif ingredient.name == "iron-gear-wheel" then
			ingredient.name = "screw"
		end
	end
end
for _,recipe in pairs(data.raw.recipe) do
	if recipe.normal then process(recipe.normal) end
	if recipe.expensive then process(recipe.expensive) end
	if recipe.ingredients then process(recipe) end
end
