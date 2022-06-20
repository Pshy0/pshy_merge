--- pshy.events.disable
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.events")



--- Dummy function.
local dummy_func = function() end



--- Disable a module.
local function DisableModule(module_name)
	local module = pshy.modules[module_name]
	if module.enabled ~= false then
		module.enabled = false
		for event_name, event in pairs(pshy.events) do
			module_index = event.module_indices[module_name]
			if module_index then
				event.functions[module_index] = dummy_func
			end
		end
	end
end



return DisableModule
