local function starts_with(str, start)
	return str:sub(1, string.len(start)) == start
end
local function remove_prefix(str, prefix)
	return str:sub(string.len(prefix)+1)
end
local function ends_with(str, suf)
	return str:sub(-string.len(suf)) == suf
end
local function remove_suffix(str, suffix)
	return str:sub(1, -(string.len(suffix)+1))
end

local function split(str, sep)
	local match = {}
	for part in str:gmatch("([^"..sep.."]+)") do
		table.insert(match, part)
	end
	return match
end

return {
	starts_with = starts_with,
	ends_with = ends_with,
	remove_prefix = remove_prefix,
	remove_suffix = remove_suffix,
	split = split
}
