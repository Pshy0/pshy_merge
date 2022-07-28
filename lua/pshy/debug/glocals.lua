--- pshy.debug.glocals
--
-- Creates a `~` table in _G tu access locals.
-- This features require the script to be compiled with `--referencelocals`.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.events")



--- Internal use:
local ms = {}



function eventInit()
	_G["~"] = {}
	for module_name, module in pairs(pshy.modules) do
		_G["~"][module_name] = setmetatable({["~access"] = module.locals}, {
			__index = function(t, k)
				if k == "~" then
					local locals_clone = {}
					for local_name, access in pairs(t["~access"]) do
						locals_clone[local_name] = access.Get()
					end
					return locals_clone
				else
					return t["~access"][k].Get()
				end
			end;
			__newindex = function(t, k, v)
				t["~access"][k].Set(v)
			end;
		})
	end
end
