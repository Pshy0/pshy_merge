--- pshy.utils.print_calls
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local args_utils = pshy.require("pshy.utils.args")



--- Namespace:
local print_calls = {}



--- Internal use:
local is_printing = false
local ArgsToString = args_utils.ToString
local assert = assert
local pairs = pairs
local print = print
local string_format = string.format
local type = type



--- Print a function call with a list of arguments.
function print_calls.PrintCall(f_name, ...)
	if not is_printing then
		is_printing = true
		print(string_format("%s(%s)", f_name, ArgsToString(...)))
		is_printing = false
	end
end
local PrintCall = print_calls.PrintCall



--- Generate a function that calls another but prints its arguments.
function print_calls.WrapFunction(f_name, f)
	assert(type(f_name) == "string")
	if not f then
		f = _ENV[f_name]
	end
	assert(type(f) == "function")
	return function(...)
		PrintCall(f_name, ...)
		return f(...)
	end
end
local WrapFunction = print_calls.WrapFunction



--- Override all functions in a table, recusive.
function print_calls.RecursiveWrap(origin, t)
	if not t then
		t = _ENV[origin]
	end
	assert(type(t) == "table")
	for obj_name, obj in pairs(t) do
		if type(obj) == "function" then
			t[obj_name] = WrapFunction(origin .. "." .. obj_name, obj)
		elseif type(obj) == "table" then
			print_calls.RecursiveWrap(origin .. "." .. obj_name, obj)
		end
	end
end



--- Override all system calls:
return print_calls
