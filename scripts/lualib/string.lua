local function starts_with(str, start)
	return string.sub(str, 1, string.len(start)) == start
end
local function remove_prefix(str, prefix)
	return string.sub(str, string.len(prefix)+1)
end
local function ends_with(str, suf)
	return string.sub(str, -string.len(suf)) == suf
end
local function remove_suffix(str, suffix)
	return string.sub(str, 1, -(string.len(suffix)+1))
end

return {
	starts_with = starts_with,
	ends_with = ends_with,
	remove_prefix = remove_prefix,
	remove_suffix = remove_suffix
}
