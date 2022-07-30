--- pshy.utils.args
--
-- @author TFM:Pshy#3752 DC:Pshy#7998



--- Namespace:
local args_utils = {}



--- Internal use:
local math_max = math.max
local pairs = pairs
local tostring = tostring
local type = type



--- Get the argument count in a vararg.
function args_utils.GetCount(...)
	local args = {...}
	local len = 0
	for i_arg in pairs(args) do
		len = math_max(len, i_arg)
	end
	return len
end
local GetCount = args_utils.GetCount



--- Convert a vararg to a string representation.
function args_utils.ToString(...)
	local args = {...}
	local argc = GetCount(...)
	local str = ""
	for i_arg = 1, argc do
		local arg = args[i_arg]
		if str ~= "" then
			str = str .. ", "
		end
		if type(arg) == "string" then
			str = str .. "\"" .. tostring(arg) .. "\""
		else
			str = str .. tostring(arg)
		end
	end
	return str
end



return args_utils
