--- pshy.utils.lua
--
-- Basic functions related to LUA.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local colors = pshy.require("pshy.enums.colors")
local utils_strings = pshy.require("pshy.utils.strings")
local utils_lua = {}



--- string.isalnum(str)
-- us this instead: `not str:match("%W")`



--- Split a string
-- Ignores empty fields
-- @param str String to split.
-- @param separator Char to split at, default to whitespaces.
-- @param max Max amount of returned strings.
function utils_lua.StrSplit(str, separator, max)
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
function utils_lua.StrSplit2(str, separator)
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
function utils_lua.StrLenSplit(str, len)
	local to_return = {}
	while #str > 0 do
		part = string.sub(str, 1, len)
		table.insert(to_return, part)
		str = string.sub(str, len + 1, #str)
	end
	return to_return
end



--- Interpret a namespace expression (resolve lua path from string)
-- @param path lua path (such as "tfm.enum.bonus")*
-- @return the object represented by path or nil if not found
function utils_lua.LuaGet(path)
	assert(type(path) == "string", debug.traceback())
	local parts = utils_strings.StrSplit(path, ".")
	local cur = _G
	for index, value in pairs(parts) do
		possible_int = tonumber(value)
		value = possible_int or value
		cur = cur[value]
		if cur == nil then
			return nil
		end
	end
	return cur
end



--- Set the value to a lua object.
-- The path is created if it does not exist.
-- @param obj_path Lua path to the object.
-- @param value Value to set, any type.
function utils_lua.LuaSet(obj_path, value)
	assert(type(obj_path) == "string", debug.traceback())
	local parts = utils_strings.StrSplit(obj_path, ".")
	local cur = _G
	for i_part, part in pairs(parts) do
		possible_int = tonumber(part)
		part = possible_int or part
		if i_part == #parts then
			-- last iteration
			cur[part] = value
			return cur[part]
		end
		cur[part] = cur[part] or {}
		if type(cur) ~= "table" then
			return nil
		end
		cur = cur[part]
	end
	error("unreachable code")
end



return utils_lua
