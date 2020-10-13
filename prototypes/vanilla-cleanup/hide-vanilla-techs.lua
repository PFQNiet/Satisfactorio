--[[
for _, tech in pairs(data.raw.technology) do
	tech.hidden = true
end
]]
data.raw.technology = {}
for _,s in pairs(data.raw.shortcut) do
	if s.technology_to_unlock == "construction-robotics" then
		s.technology_to_unlock = nil
	end
end
data.raw.tutorial = {}
data.raw['research-achievement'] = {}
