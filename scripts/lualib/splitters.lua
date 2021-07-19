---@alias SmartSplitterDirection '"left"'|'"forward"'|'"right"'
---@type table<SmartSplitterDirection, SmartSplitterDirection>
local directions = {
	left = "left",
	forward = "forward",
	right = "right"
}
---@alias SmartSplitterSpecialFilter '"any"'|'"any-undefined"'|'"overflow"'
---@type table<SmartSplitterSpecialFilter, SmartSplitterSpecialFilter>
local specials = {
	any = "any",
	["any-undefined"] = "any-undefined",
	overflow = "overflow"
}

return {
	directions = directions,
	specials = specials
}
