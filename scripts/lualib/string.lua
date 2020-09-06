local function starts_with(str, start)
	return str.sub(str, 1, string.len(start)) == start
end

return {
	starts_with = starts_with
}
