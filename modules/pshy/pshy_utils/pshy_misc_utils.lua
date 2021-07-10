--- pshy_misc_utils.lua
--
-- This module contains functions that are temporarily needed.
--
-- @author DC:Pshy#7998 TFM:Pshy#3752
-- @hardmerge
-- @namespace pshy
-- @require pshy_lua_utils.lua
pshy = pshy or {}



--- Convert string arguments of a table to the specified types, 
-- or attempt to guess the types.
-- @param args Table of elements to convert.
-- @param types Table of types.
-- @todo This function should be better in `pshy_commands.lua`.
function pshy.TableStringsToType(args, types)
	for index = 1, #args do
		if types and index <= #types then
			args[index] = pshy.ToType(args[index], types[index])
		else
			args[index] = pshy.AutoType(args[index])
		end
	end	
end
