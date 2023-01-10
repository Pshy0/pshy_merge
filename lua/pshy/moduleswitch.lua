--- pshy.moduleswitch
--
-- Handles enabling and disabling modules.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998



--- Dummy function.
local dummy_func = function() end



--- Enable a module events
local function EnableModuleEvents(module_name)
	local module = pshy.modules[module_name]
	if not module then
		print(string.format("<r>[ERROR]: EnableModule: Module `%s` not found!<n>", module_name))
		return
	end
	if module.enabled == false then
		module.enabled = true
		for event_name, event in pairs(events.events) do
			local module_index = event.module_indices[module_name]
			if module_index then
				event.functions[module_index] = event.original_functions[module_index]
			end
		end
	end
end



--- Disable a module events.
local function DisableModuleEvents(module_name)
	local module = pshy.modules[module_name]
	if not module then
		print(string.format("<r>[ERROR]: DisableModule: Module `%s` not found!<n>", module_name))
		return
	end
	if module.enabled ~= false then
		module.enabled = false
		for event_name, event in pairs(events.events) do
			local module_index = event.module_indices[module_name]
			if module_index then
				event.functions[module_index] = dummy_func
			end
		end
	end
end



local function InternalAdditiveEnableModule(module)
	assert(type(module) == "table")
	module.enable_count = (module.enable_count or 0) + 1
	for module_name, module in pairs(module.required_modules) do
		InternalAdditiveEnableModule(module)
	end
	if module.enable_count == 1 then
		module.enabled = true
		if module.eventModuleEnabled then
			module.eventModuleEnabled()
		end
	end
end



local function InternalAdditiveDisableModule(module)
	assert(type(module) == "table")
	if (not module.enable_count or module.enable_count <= 0) then
		module.enable_count = 0
		print(string.format("<r>ERROR: <n>InternalAdditiveDisableModule: Module `%s` was already disabled!", module_name))
	end
	module.enable_count = module.enable_count - 1
	for module_name, module in pairs(module.required_modules) do
		InternalAdditiveDisableModule(module)
	end
	if module.enable_count == 0 then
		module.enabled = false
		if module.eventModuleDisabled then
			module.eventModuleDisabled()
		end
	end
end



--- Enable a module.
-- Dependencies are also enabled when needed.
-- Calls of EnableModule and DisableModule must pair.
function pshy.EnableModule(module_name)
	assert(type(module_name) == "string")
	local module = pshy.modules[module_name]
	InternalAdditiveEnableModule(module)
end



--- Disable a module.
-- Dependencies are also disabled when no longer needed.
-- Calls of EnableModule and DisableModule must pair.
-- If the module was required to be enabled somewhere else, it will stay enabled.
function pshy.DisableModule(module_name)
	assert(type(module_name) == "string")
	local module = pshy.modules[module_name]
	InternalAdditiveDisableModule(module)
end