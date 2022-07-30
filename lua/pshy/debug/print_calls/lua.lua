--- pshy.debug.print_calls.lua
--
-- Prints calls to the tfm api.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local print_calls = pshy.require("pshy.utils.print_calls")



-- Wrapping:
print_calls.WrapFunction(nil, _G, "assert")
print_calls.RecursiveWrap("bit32")
print_calls.RecursiveWrap("coroutine")
print_calls.WrapFunction(nil, _G, "error")
print_calls.WrapFunction(nil, _G, "getmetatable")
--print_calls.WrapFunction("ipairs")
print_calls.RecursiveWrap("math")
--print_calls.WrapFunction("next")
print_calls.RecursiveWrap("os")
--print_calls.WrapFunction("pairs")
print_calls.WrapFunction(nil, _G, "pcall")
print_calls.WrapFunction(nil, _G, "rawequal")
print_calls.WrapFunction(nil, _G, "rawget")
print_calls.WrapFunction(nil, _G, "rawlen")
print_calls.WrapFunction(nil, _G, "rawset")
print_calls.WrapFunction(nil, _G, "select")
print_calls.WrapFunction(nil, _G, "setmetatable")
print_calls.RecursiveWrap("string")
print_calls.RecursiveWrap("table")
print_calls.WrapFunction(nil, _G, "tonumber")
print_calls.WrapFunction(nil, _G, "tostring")
print_calls.WrapFunction(nil, _G, "type")
print_calls.WrapFunction(nil, _G, "xpcall")
