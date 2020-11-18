-- ensure no mods have added techs using Science Packs that haven't been made compatible
local vanillapacks = {
	["automation-science-pack"] = true,
	["logistic-science-pack"] = true,
	["military-science-pack"] = true,
	["chemical-science-pack"] = true,
	["production-science-pack"] = true,
	["utility-science-pack"] = true,
	["space-science-pack"] = true
}
for _,tech in pairs(data.raw.technology) do
	if tech.enabled and not tech.hidden then
		for _,item in pairs(tech.unit.ingredients) do
			if vanillapacks[item[1] or item.name] then
				error("Technology "..tech.name.." uses "..(item[1] or item.name)..", which is unsupported by Satisfactorio.")
			end
		end
	end
end
