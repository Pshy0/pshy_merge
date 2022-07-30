--- pshy.debug.print_calls.tfm
--
-- Prints calls to the tfm api functions.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local print_calls = pshy.require("pshy.utils.print_calls")



-- Wrapping:
print_calls.RecursiveWrap("debug")
print_calls.RecursiveWrap("system")
print_calls.RecursiveWrap("tfm.exec", tfm.exec)
print_calls.RecursiveWrap("ui")
