local function starts_with(str, start)
	return string.sub(str, 1, string.len(start)) == start
end
local function remove_prefix(str, prefix)
	return string.sub(str, string.len(prefix)+1)
end

return {
	starts_with = starts_with,
	remove_prefix = remove_prefix
}
