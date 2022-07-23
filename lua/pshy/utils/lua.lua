--- pshy.utils.lua
--
-- Basic functions related to LUA.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local colors = pshy.require("pshy.enums.colors")
local utils_strings = pshy.require("pshy.utils.strings")
local utils_lua = {}



--- Interpret a namespace expression (resolve lua path from string)
-- @param path lua path (such as "tfm.enum.bonus")*
-- @return the object represented by path or nil if not found
function utils_lua.Get(path, sep)
	assert(type(path) == "string", debug.traceback())
	sep = sep or "."
	local parts = utils_strings.Split(path, sep)
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
function utils_lua.Set(obj_path, value, sep)
	assert(type(obj_path) == "string", debug.traceback())
	sep = sep or "."
	local parts = utils_strings.Split(obj_path, sep)
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
