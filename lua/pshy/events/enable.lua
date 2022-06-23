--- pshy.events.enable
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local events = pshy.require("pshy.events")



--- Enable a module.
local function EnableModuleEvents(module_name)
	local module = pshy.modules[module_name]
	if not module then
		print(string.format("<r>[ERROR]: EnableModule: Module `%s` not found!<n>", module_name))
	end
	if module.enabled == false then
		module.enabled = true
		for event_name, event in pairs(events.events) do
			module_index = event.module_indices[module_name]
			if module_index then
				event.functions[module_index] = event.original_functions[module_index]
			end
		end
	end
end



return EnableModuleEvents
