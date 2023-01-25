--- pshy.utils.args
--
-- @author TFM:Pshy#3752 DC:Pshy#7998



--- Namespace:
local args_utils = {}



--- Internal use:
local tostring = tostring
local type = type



--- Convert a vararg to a string representation.
function args_utils.ToString(...)
	local args = {...}
	local argc = select('#', ...)
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
