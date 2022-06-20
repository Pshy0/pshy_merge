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
function utils_types.ToBoolean(value)
	if value == "true" then
		return true
	end
	if value == "false" then
		return false
	end
	return nil
end



--- Convert a string to a boolean (andles yes/no and on/off).
-- @param string "true" or "false".
-- @return Boolean true or false, or nil.
function utils_types.ToPermissiveBoolean(value)
	if value == "true" or value == "on" or value == "yes" then
		return true
	end
	if value == "false" or value == "off" or value == "no" then
		return false
	end
	return nil
end



--- Convert a string value to the given type.
-- nil value is not supported for `string` and `player`.
-- @param value String to convert.
-- @param type string representing the type to convert to.
-- @return The converted value.
-- @todo Should t be a table to represent enum keys?
function utils_types.ToType(value, t)
	assert(type(value) == "string", "wrong argument type")
	assert(type(t) == "string", "wrong argument type")
	-- string
	if t == "string" then
		return value
	end
	-- player
	if t == "player" then
		return utils_tfm.FindPlayerName(value)
	end
	-- nil
	if value == "nil" then
		return nil
	end
	-- boolean
	if t == "bool" or t == "boolean" then
		return utils_types.ToPermissiveBoolean(value)
	end
	-- number
	if t == "number" then
		return tonumber(value)
	end
	-- color
	if t == "color" then
		if colors[value] then
			return colors[value]
		end
		t = "hexnumber"
	end
	-- hexnumber
	if t == "hexnumber" then
		if string.sub(value, 1, 1) == '#' then
			value = string.sub(value, 2, #value)
		end
		return tonumber(value, 16)
	end
	-- enums
	local enum = utils_lua.LuaGet(t)
	if type(enum) == "table" then
		return enum[value]
	end
	-- not supported
	error("type not supported")
end



--- Convert an argument to anoter type automatically.
-- @param value String to convert.
-- @return the same value represented by the best type possible (bool/number/string).
function utils_types.AutoType(value)
	assert(type(value) == "string", "wrong argument type")
	local rst
	-- nil
	if value == "nil" then
		return nil
	end
	-- boolean
	if value == "true" then
		return true
	end
	if value == "false" then
		return false
	end
	-- number
	rst = tonumber(value, 10)
	if rst then
		return rst
	end
	-- empty table
	if value == "{}" then
		return {}
	end
	-- tfm enums
	rst = utils_tfm.EnumGet(value)
	if rst then
		return rst
	end
	-- lua object
	rst = utils_lua.LuaGet(value)
	if rst then
		return rst
	end
	-- color code / hex number
	if string.sub(value, 1, 1) == '#' then
		rst = tonumber(string.sub(value, 2, #value), 16)
		if rst then
			return rst
		end
	end
	-- string
	return value
end



return utils_types
