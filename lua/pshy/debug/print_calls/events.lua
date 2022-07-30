--- pshy.debug.print_calls.events
--
-- Prints calls to the tfm api functions.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.events")
local print_calls = pshy.require("pshy.utils.print_calls")



-- Wrapping:
function eventInit()
	for obj_name, obj in pairs(_ENV) do
		print(obj_name)
		if type(obj) == "function" and obj_name:sub(1, 5) == "event" then
			print("<r>" .. obj_name)
			print_calls.WrapFunction(nil, _G, obj_name)
		end
	end
end
