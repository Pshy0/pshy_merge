--- pshy.debug.print_calls.lua
--
-- Prints calls to the tfm api.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local print_calls = pshy.require("pshy.utils.print_calls")



-- Wrapping:
print_calls.WrapFunction("assert")
print_calls.RecursiveWrap("bit32")
print_calls.RecursiveWrap("coroutine")
print_calls.WrapFunction("error")
print_calls.WrapFunction("getmetatable")
--print_calls.WrapFunction("ipairs")
print_calls.RecursiveWrap("math")
--print_calls.WrapFunction("next")
print_calls.RecursiveWrap("os")
--print_calls.WrapFunction("pairs")
print_calls.WrapFunction("pcall")
print_calls.WrapFunction("rawequal")
print_calls.WrapFunction("rawget")
print_calls.WrapFunction("rawlen")
print_calls.WrapFunction("rawset")
print_calls.WrapFunction("select")
print_calls.WrapFunction("setmetatable")
print_calls.RecursiveWrap("string")
print_calls.RecursiveWrap("table")
print_calls.WrapFunction("tonumber")
print_calls.WrapFunction("tostring")
print_calls.WrapFunction("type")
print_calls.WrapFunction("xpcall")
