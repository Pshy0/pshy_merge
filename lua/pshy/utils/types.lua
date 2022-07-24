--- pshy.utils.types
--
-- Basic functions related to LUA.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local colors = pshy.require("pshy.enums.colors")
local utils_lua = pshy.require("pshy.utils.lua")
local utils_tfm = pshy.require("pshy.utils.tfm")
local utils_types = {}



--- Convert a string to a boolean.
-- @param string "true" or "false".
-- @return Boolean true or false, or nil.
function utils_types.ToBoolean(s)
	if s == "true" then
		return true
	end
	if s == "false" then
		return false
	end
	return nil
end



--- Convert a string to a boolean (andles yes/no and on/off).
-- @param string "true" or "false".
-- @return Boolean true or false, or nil.
function utils_types.ToPermissiveBoolean(s)
	if s == "true" or s == "on" or s == "yes" then
		return true
	end
	if s == "false" or s == "off" or s == "no" then
		return false
	end
	return nil
end
local ToPermissiveBoolean = utils_types.ToPermissiveBoolean



--- Convert a string representing an hex number to a number.
-- @param s A string representing an hex number, optionally prefixed with `#`.
function utils_types.ToNumberHex(s)
	if string.sub(s, 1, 1) == '#' then
		s = string.sub(s, 2, #s)
	end
	return tonumber(s, 16)
end
local ToNumberHex = utils_types.ToNumberHex



--- Convert a string representing a color to a number.
-- @param s A string representing a color as a color name or an hex number (see ToNumberHex).
function utils_types.ToColor(s)
	if colors[s] then
		return colors[s]
	end
	return ToNumberHex(s)
end
local ToColor = utils_types.ToColor



--- Converter functions:
utils_types.converters = {}
utils_types.converters["number"] = tonumber
utils_types.converters["string"] = tostring
utils_types.converters["bool"] = utils_types.ToPermissiveBoolean
utils_types.converters["boolean"] = utils_types.ToPermissiveBoolean
utils_types.converters["player"] = utils_tfm.FindPlayerName
utils_types.converters["hexnumber"] = utils_types.ToNumberHex
utils_types.converters["color"] = utils_types.ToColor
utils_types.converters["lua"] = utils_lua.Get
utils_types.converters["lua/"] = function(s) return utils_lua.Get(s, "/") end
local converters = utils_types.converters



--- Convert a string value to the given type.
-- nil value is not supported for `string` and `player`.
-- @param value String to convert.
-- @param type string representing the type to convert to.
-- @return The converted value.
-- @todo Should t be a table to represent enum keys?
function utils_types.ToType(s, t)
	assert(type(s) == "string", "wrong argument type")
	assert(type(t) == "string", "wrong argument type")
	-- string
	if t == "string" then
		return s
	end
	-- player
	if t == "player" then
		return utils_tfm.FindPlayerName(s)
	end
	-- nil
	if s == "nil" then
		return nil
	end
	-- boolean
	if t == "bool" or t == "boolean" then
		return ToPermissiveBoolean(s)
	end
	-- number
	if t == "number" then
		return tonumber(s)
	end
	-- color
	if t == "color" then
		if colors[s] then
			return colors[s]
		end
		t = "hexnumber"
	end
	-- hexnumber
	if t == "hexnumber" then
		if string.sub(s, 1, 1) == '#' then
			s = string.sub(s, 2, #s)
		end
		return tonumber(s, 16)
	end
	-- enums
	local enum = utils_lua.Get(t)
	if type(enum) == "table" then
		return enum[s]
	end
	-- not supported
	error("type not supported")
end



--- Convert an argument to anoter type automatically.
-- @param value String to convert.
-- @return the same value represented by the best type possible (bool/number/string).
function utils_types.AutoType(s)
	assert(type(s) == "string", "wrong argument type")
	local rst
	-- nil
	if s == "nil" then
		return nil
	end
	-- boolean
	if s == "true" then
		return true
	end
	if s == "false" then
		return false
	end
	-- number
	rst = tonumber(s, 10)
	if rst then
		return rst
	end
	-- empty table
	if s == "{}" then
		return {}
	end
	-- tfm enums
	rst = utils_tfm.EnumGet(s)
	if rst then
		return rst
	end
	-- lua object
	rst = utils_lua.Get(s)
	if rst then
		return rst
	end
	-- color code / hex number
	if string.sub(s, 1, 1) == '#' then
		rst = tonumber(string.sub(s, 2, #s), 16)
		if rst then
			return rst
		end
	end
	-- string
	return s
end
local AutoType = utils_types.AutoType



function utils_types.ToTypeFromPrefix(s)
	assert(type(s) == "string", "wrong argument type")
	local i_colon = s:find(":", 1, true)
	if i_colon and i_colon > 1 and i_colon < 16 then
		local type_str = s:sub(1, i_colon - 1)
		if converters[type_str] then
			return converters[type_str](s:sub(i_colon + 1))
		end
	end
	if #s > 1 and s:sub(1, 1) == "\"" and s:sub(-1, -1) == "\"" then
		return s:sub(2, -2)
	end
	return AutoType(s)
end



return utils_types
