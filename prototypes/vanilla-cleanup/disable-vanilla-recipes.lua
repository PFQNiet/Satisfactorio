local to_disable = {
	"wooden-chest",
	"iron-chest",
	"burner-inserter",
	"inserter",
	"small-electric-pole",
	"pipe",
	"pipe-to-ground",
	"stone-brick",
	"repair-pack",
	"boiler",
	"steam-engine",
	"burner-mining-drill",
	"electric-mining-drill",
	"offshore-pump",
	"stone-furnace",
	"lab",
	"iron-gear-wheel",
	"electronic-circuit",
	"automation-science-pack",
	"pistol",
	"firearm-magazine",
	"light-armor",
	"radar"
}

for _,key in ipairs(to_disable) do
	local recipe = data.raw.recipe[key]
	if recipe.enabled ~= nil or recipe.normal == nil then
		recipe.enabled = false
	end
	if recipe.normal and (recipe.normal.enabled ~= nil or recipe.enabled == nil) then
		recipe.normal.enabled = false
	end
	if recipe.expensive and (recipe.expensive.enabled ~= nil or recipe.enabled == nil) then
		recipe.expensive.enabled = false
	end
end
