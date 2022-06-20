--- pshy.utils.strings
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local utils_strings = {}



--- string.isalnum(str)
-- us this instead: `not str:match("%W")`



--- Split a string
-- Ignores empty fields
-- @param str String to split.
-- @param separator Char to split at, default to whitespaces.
-- @param max Max amount of returned strings.
function utils_strings.Split(str, separator, max)
	assert(type(str) == "string", "str need to be of type string (was " .. type(str) .. ")" .. debug.traceback())
	separator = separator or "%s"
	max = max or -1
	remlen = #str
	local parts = {}
	for part in string.gmatch(str, "([^" .. separator .. "]+)") do
		if max == 1 and remlen >= 0 then
			table.insert(parts, string.sub(str, -remlen))
			return parts
		end
		table.insert(parts, part)
		remlen = remlen - #part - 1
		max = max - 1
	end
	return parts
end



--- Same as pshy.StrSplit but does not ignore empty fields.
function utils_strings.Split2(str, separator)
	assert(type(str) == "string")
	separator = separator or '%s'
	local fields = {}
	for field, s in string.gmatch(str, "([^".. separator .."]*)(".. separator .."?)") do
		table.insert(fields, field)
		if s == "" then --@TODO: learn about this
			return fields
		end
	end
	return fields
end



--- Split a string to an array of strings of a maximum length.
function utils_strings.StrLenSplit(str, len)
	local to_return = {}
	while #str > 0 do
		part = string.sub(str, 1, len)
		table.insert(to_return, part)
		str = string.sub(str, len + 1, #str)
	end
	return to_return
end



return utils_strings
