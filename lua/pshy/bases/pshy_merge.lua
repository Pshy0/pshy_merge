--- pshy_merge.py
--
-- This module is used by `combine.py` to merge TFM modules.
--
-- Calls `eventInit()` when all scripts have been loaded.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_version.lua
--
-- @hardmerge
pshy = pshy or {}



--- Help Page
pshy.help_pages = pshy.help_pages or {}						-- touching the help_pages table
pshy.help_pages["pshy_merge"] = {title = "Merging (Modules)", text = "This module merge other modules, and can enable or disable them at any moment.", commands = {}}



--- Internal Use:
pshy.merge_has_module_began = false
pshy.merge_has_finished	= false						-- did merging finish
pshy.merge_pending_regenerate = false
pshy.commands = pshy.commands or {}					-- touching the commands table
pshy.modules = {}									-- map of module tables (key is name)
pshy.modules_list = {}								-- list of module tables (in include order)
pshy.events = {}									-- map of event function lists (events[event_name][function_index])
pshy.events_module_names = {}						-- corresponding module names for entries in `pshy.events`
pshy.merge_minimize_events = {}						-- event that require to be fast and not to have all the features
pshy.merge_minimize_events["eventKeyboard"] = true



--- Create a module table and returns it.
-- @private
function pshy.merge_CreateModule(module_name)
	assert(pshy.merge_has_finished == false, "pshy.merge_CreateModule(): Merging have already been finished!")
	local new_module = {}
	pshy.modules[module_name] = new_module
	table.insert(pshy.modules_list, new_module)
	new_module.index = #pshy.modules_list			-- index of the event in `pshy.modules_list`
	new_module.name = module_name					-- index of the event in `pshy.modules`
	new_module.events = {}							-- map of events (function name -> function)
	new_module.event_count = 0						-- counter for event functions
	new_module.eventModuleEnabled = nil				-- function called when the module is enabled
	new_module.eventModuleDisabled = nil			-- function called when the module is disabled
	new_module.enabled = true						-- index of the event in `pshy.modules`
	return new_module
end



--- Begin a module.
-- @private
-- Call before a new module's code, in the merged source.
function pshy.merge_ModuleBegin(module_name)
	assert(pshy.merge_has_module_began == false, "pshy.merge_ModuleBegin(): A previous module have not been ended!")
	assert(pshy.merge_has_finished == false, "pshy.merge_MergeBegin(): Merging have already been finished!")
	pshy.merge_has_module_began = true
	return pshy.merge_CreateModule(module_name)
	--print("[Merge] Loading " .. module_name .. "...")
end



--- End a module.
-- @private
-- Call after a module's code, in the merged source.
function pshy.merge_ModuleEnd()
	assert(pshy.merge_has_module_began == true, "pshy.merge_ModuleEnd(): No module to end!")
	assert(pshy.merge_has_finished == false, "pshy.merge_MergeEnd(): Merging have already been finished!")
	pshy.merge_has_module_began = false
	local mod = pshy.modules_list[#pshy.modules_list]
	-- `Enable` and `Disable` events
	if _G["eventModuleEnabled"] then
		assert(type(_G["eventModuleEnabled"]) == "function")
		mod.eventModuleEnabled = _G["eventModuleEnabled"]
		_G["eventModuleEnabled"] = nil
	end
	if _G["eventModuleDisabled"] then
		assert(type(_G["eventModuleDisabled"]) == "function")
		mod.eventModuleDisabled = _G["eventModuleDisabled"]
		_G["eventModuleDisabled"] = nil
	end
	-- find used event names
	for e_name, e in pairs(_G) do
		if type(e) == "function" and string.sub(e_name, 1, 5) == "event" then
			mod.events[e_name] = e
			mod.event_count = mod.event_count + 1
		end
	end
	--
	if mod.event_count == 0 then
		mod.enabled = false
	end
	-- remove the events from _G
	for e_name in pairs(mod.events) do
		_G[e_name] = nil
	end
	--print("[Merge] Module loaded.")
end



--- Final step for merging modules.
-- Call this when you're done putting modules together.
-- @private
function pshy.merge_Finish()
	assert(pshy.merge_has_module_began == false, "pshy.merge_Finish(): A previous module have not been ended!")
	assert(pshy.merge_has_finished == false, "pshy.merge_Finish(): Merging have already been finished!")
	pshy.merge_has_finished = true
	pshy.merge_GenerateEvents()
	local event_count = pshy.merge_CreateEventFuntions()
	if _G["eventInit"] then
		eventInit()
	end
	print(string.format("<vp>[Merge] </vp><v>Created <ch2>%d events</ch2> for <ch>%d modules</ch>.", event_count, #pshy.modules_list))
end



--- Get a map of event function lists (events.event_names.functions).
function pshy.merge_GetEventsFunctions()
	--print_debug("pshy.merge_GetEventsFunctions()")
	local events = pshy.events
	local events_module_names = pshy.events_module_names
	-- clear the tables
	for e_name, e_list in pairs(events) do
		while #e_list > 0 do
			table.remove(e_list, #e_list)
		end
	end
	for e_name, e_list in pairs(events_module_names) do
		while #e_list > 0 do
			table.remove(e_list, #e_list)
		end
	end
	--local events = {}
	--local events_module_names = {}
	for i_mod, mod in ipairs(pshy.modules_list) do
		if mod.enabled then
			for e_name, e in pairs(mod.events) do
				events[e_name] = events[e_name] or {}
				table.insert(events[e_name], e)
				events_module_names[e_name] = events_module_names[e_name] or {}
				table.insert(events_module_names[e_name], mod.name)
			end
		end
	end
	return events, events_module_names
end



--- Create the event functions.
-- @TODO: test performances against ipairs.
-- @TODO: test performances with inlining the function call.
function pshy.merge_CreateEventFuntions()
	--print_debug("pshy.merge_CreateEventFuntions()")
	local event_count = 0
	local pshy_events = pshy.events
	for e_name, e_func_list in pairs(pshy_events) do
		if #e_func_list > 0 then
			event_count = event_count + 1
			if not pshy.merge_minimize_events[e_name] then
				_G[e_name] = function(...)
					-- Event functions's code
					local rst = nil
					--for i_func = 1, #e_func_list do
						--rst = e_func_list[i_func](...)
					for i_func, func in ipairs(e_func_list) do
						rst = func(...)
						if rst ~= nil then
							break
						end
					end
					if pshy.merge_pending_regenerate then
						--print_debug("event regeneration was pending")
						pshy.merge_GenerateEvents()
						pshy.merge_pending_regenerate = false
					end
				end
			else
				-- this is a minimum optimized version of the above
				_G[e_name] = function(...)
					for i_func, func in ipairs(e_func_list) do
						func(...)
					end
				end
			end
		end
	end
	-- return the events count
	return event_count
end



--- Generate the global events.
function pshy.merge_GenerateEvents()
	--print_debug("pshy.merge_GenerateEvents()")
	assert(pshy.merge_has_module_began == false, "pshy.merge_GenerateEvents(): A previous module have not been ended!")
	assert(pshy.merge_has_finished == true, "pshy.merge_GenerateEvents(): Merging have not been finished!")
	-- create list of events
	--pshy.events, pshy.events_module_names = pshy.merge_GetEventsFunctions()
	pshy.merge_GetEventsFunctions()
	pshy.merge_CreateEventFuntions()
	return #pshy.events
end



--- Enable a list of modules.
function pshy.merge_EnableModules(module_list)
	--print_debug("pshy.merge_EnableModules(module_list)")
	for i, module_name in pairs(module_list) do
		local mod = pshy.modules[module_name]
		if mod then
			if not mod.enabled and mod.eventModuleEnabled then
				mod.eventModuleEnabled()
			end
			mod.enabled = true
			pshy.merge_pending_regenerate = true
		else
			print("<r>[Merge] Cannot enable module " .. module_name .. "! (not found)</r>")
		end
	end
end



--- Disable a list of modules.
function pshy.merge_DisableModules(module_list)
	--print_debug("pshy.merge_DisableModules(module_list)")
	for i, module_name in pairs(module_list) do
		local mod = pshy.modules[module_name]
		if mod then
			if mod.enabled and mod.eventModuleDisabled then
				mod.eventModuleDisabled()
			end
			mod.enabled = false
			pshy.merge_pending_regenerate = true
		else
			print("<r>[Merge] Cannot disable module " .. module_name .. "! (not found)</r>")
		end
	end
end



--- Enable a module.
-- @public
function pshy.merge_EnableModule(mname)
	--print_debug("pshy.merge_EnableModule(%s)", mname)
	local mod = pshy.modules[mname]
	assert(mod, "Unknown " .. mname .. "module.")
	if mod.enabled then
		return false, "Already enabled."
	end
	mod.enabled = true
	if mod.eventEnableModule then
		mod.eventEnableModule()
	end
	pshy.merge_pending_regenerate = true
end



--- Disable a module.
-- @public
function pshy.merge_DisableModule(mname)
	--print_debug("pshy.merge_DisableModule(%s)", mname)
	local mod = pshy.modules[mname]
	assert(mod, "Unknown " .. mname .. " module.")
	if not mod.enabled then
		return false, "Already disabled."
	end
	mod.enabled = false
	if mod.eventDisableModule then
		mod.eventDisableModule()
	end
	pshy.merge_pending_regenerate = true
end



--- !modules
function pshy.merge_ChatCommandModules(user, event_name)
	tfm.exec.chatMessage("<r>[Merge]</r> Modules (in load order):", user)
	for i_module, mod in pairs(pshy.modules_list) do
		if not event_name or mod.events[event_name] then
			local line = (mod.enabled and "<v>" or "<g>") ..tostring(mod.index) .. "\t" .. mod.name
			if mod.event_count > 0 then
				line = line .. " \t" .. tostring(mod.event_count) .. " events"
			end
			tfm.exec.chatMessage(line, user)
		end
	end
end
pshy.commands["modules"] = {func = pshy.merge_ChatCommandModules, desc = "see a list of loaded modules", argc_min = 0, argc_max = 1, arg_types = {"string"}, arg_names = {"event_name"}}
pshy.help_pages["pshy_merge"].commands["modules"] = pshy.commands["modules"]



--- !enablemodule
function pshy.merge_ChatCommandModuleenable(user, mname)
	tfm.exec.chatMessage("[Merge] Enabling " .. mname)
	return pshy.merge_EnableModule(mname)
end
pshy.commands["enablemodule"] = {func = pshy.merge_ChatCommandModuleenable, desc = "enable a module", argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_merge"].commands["enablemodule"] = pshy.commands["enablemodule"]



--- !disablemodule
function pshy.merge_ChatCommandModuledisable(user, mname)
	tfm.exec.chatMessage("[Merge] Disabling " .. mname)
	return pshy.merge_DisableModule(mname)
end
pshy.commands["disablemodule"] = {func = pshy.merge_ChatCommandModuledisable, desc = "disable a module", argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_merge"].commands["disablemodule"] = pshy.commands["disablemodule"]



-- Create pshy_merge.lua module
pshy.merge_CreateModule("pshy_merge.lua")
