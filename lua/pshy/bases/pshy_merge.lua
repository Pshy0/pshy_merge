--- pshy_merge.py
--
-- This module is used by `combine.py` to merge TFM modules.
--
-- Calls `eventInit()` when all scripts have been loaded.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @require_priority 0
-- @hardmerge
pshy = pshy or {}



--- Help Page
pshy.help_pages = pshy.help_pages or {}						-- touching the help_pages table
pshy.help_pages["pshy_merge"] = {title = "Merging (Modules)", text = "This module merge other modules, and can enable or disable them at any moment.", commands = {}}



--- Module Settings:
__PSHY_TFM_API_VERSION__ = "0.28"					-- The last tfm api version this script was made for.
pshy.merge_days_before_update_request_1	= 7			-- How many days old the script should be before suggesting an update.
pshy.merge_days_before_update_request_2	= 14		-- How many days old the script should be before requesting an update.
pshy.merge_days_before_update_request_3	= 40		-- How many days old the script should be before refusing to start.



--- Internal Use:
pshy.merge_has_module_began = false
pshy.merge_has_finished	= false						-- did merging finish
pshy.merge_pending_regenerate = false
pshy.chat_commands = pshy.chat_commands or {}		-- touching the chat_commands table
pshy.modules = {}									-- map of module tables (key is name)
pshy.modules_list = {}								-- list of module tables
pshy.events = {}									-- map of event function lists (events[event_name][function_index])
pshy.events_module_names = {}						-- corresponding module names for entries in `pshy.events`


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
	local event_count = pshy.merge_GenerateEvents()
	if _G["eventInit"] then
		eventInit()
	end
	print("<vp>[Merge] </vp><v>Finished loading <ch>" .. tostring(event_count) .. " events</ch> in <ch2>" .. tostring(#pshy.modules_list) .. " modules</ch2>.</v>")
end



--- Get a map of event function lists (events.event_names.functions).
function pshy.merge_GetEventsFunctions()
	local events = {}
	local events_module_names = {}
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
	print("DEBUG: generating normal events")
	local event_count = 0
	local pshy_events = pshy.events
	for e_name, e_func_list in pairs(pshy_events) do
		if #e_func_list > 0 then
			event_count = event_count + 1
			_G[e_name] = nil
			_G[e_name] = function(...)
				-- Event functions's code
				local rst = nil
				for i_func = 1, #e_func_list do
					rst = e_func_list[i_func](...)
					if rst ~= nil then
						break
					end
				end
				if pshy.merge_pending_regenerate then
					pshy.merge_GenerateEvents()
					pshy.merge_pending_regenerate = false
				end
			end
		end
	end
	-- return the events count
	return event_count
end



--- Generate the global events.
function pshy.merge_GenerateEvents()
	assert(pshy.merge_has_module_began == false, "pshy.merge_GenerateEvents(): A previous module have not been ended!")
	assert(pshy.merge_has_finished == true, "pshy.merge_GenerateEvents(): Merging have not been finished!")
	-- create list of events
	pshy.events, pshy.events_module_names = pshy.merge_GetEventsFunctions()
	-- create events functions
	local event_count = pshy.merge_CreateEventFuntions()
	return event_count
end



--- Enable a list of modules.
function pshy.merge_EnableModules(module_list)
	for i, module_name in pairs(module_list) do
		local mod = pshy.modules[module_name]
		if mod then
			if not mod.enabled and mod.eventModuleEnabled then
				mod.eventModuleEnabled()
			end
			mod.enabled = true
		else
			print("<r>[Merge] Cannot enable module " .. module_name .. "! (not found)</r>")
		end
	end
	pshy.merge_pending_regenerate = true
end



--- Disable a list of modules.
function pshy.merge_DisableModules(module_list)
	for i, module_name in pairs(module_list) do
		local mod = pshy.modules[module_name]
		if mod then
			if mod.enabled and mod.eventModuleDisabled then
				mod.eventModuleDisabled()
			end
			mod.enabled = false
		else
			print("<r>[Merge] Cannot disable module " .. module_name .. "! (not found)</r>")
		end
	end
	pshy.merge_pending_regenerate = true
end



--- Enable a module.
-- @public
function pshy.merge_EnableModule(mname)
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
pshy.chat_commands["modules"] = {func = pshy.merge_ChatCommandModules, desc = "see a list of loaded modules", argc_min = 0, argc_max = 1, arg_types = {"string"}, arg_names = {"event_name"}}
pshy.help_pages["pshy_merge"].commands["modules"] = pshy.chat_commands["modules"]



--- !enablemodule
function pshy.merge_ChatCommandModuleenable(user, mname)
	tfm.exec.chatMessage("[Merge] Enabling " .. mname)
	return pshy.merge_EnableModule(mname)
end
pshy.chat_commands["enablemodule"] = {func = pshy.merge_ChatCommandModuleenable, desc = "enable a module", argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_merge"].commands["enablemodule"] = pshy.chat_commands["enablemodule"]



--- !disablemodule
function pshy.merge_ChatCommandModuledisable(user, mname)
	tfm.exec.chatMessage("[Merge] Disabling " .. mname)
	return pshy.merge_DisableModule(mname)
end
pshy.chat_commands["disablemodule"] = {func = pshy.merge_ChatCommandModuledisable, desc = "disable a module", argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_merge"].commands["disablemodule"] = pshy.chat_commands["disablemodule"]



--- Perform initial misc checks and actions.
function pshy.merge_Init()
	print("<v>Pshy version <ch>" .. tostring(__PSHY_VERSION__) .. "</ch></v>")
	-- check release age
	local release_days = __PSHY_TIME__ / 60 / 60 / 24
	local current_days = os.time() / 1000 / 60 / 60 / 24
	local days_old = current_days - release_days
	if days_old > pshy.merge_days_before_update_request_3 then
		print(string.format("<r>This version is <vi>%d days</vi> old. Please consider obtaining a newer version.</r>", days_old))
		error(string.format("<r>This version is <vi>%d days</vi> old. Please consider obtaining a newer version.</r>", days_old))
	elseif days_old > pshy.merge_days_before_update_request_2 then
		print(string.format("<o>This version is <r>%d days</r> old. Please obtain a newer version as soon as possible.</o>", days_old))
	elseif days_old > pshy.merge_days_before_update_request_1 then
		print(string.format("<j>This version is <o>%d days</o> old. An update may be available.</j>", days_old))
	else
		print(string.format("<v>This version is <ch>%d days</ch> old.</v>", days_old))
	end
	if days_old > pshy.merge_days_before_update_request_3 / 2 then
		print(string.format("<r>/!\\ This script will not start after being %d days old.</r>", pshy.merge_days_before_update_request_3))
	end
	-- check tfm api version
	local expected_tfm_api_version_numbers = {}
	for number_str in string.gmatch(__PSHY_TFM_API_VERSION__, "([^\.]+)") do
		table.insert(expected_tfm_api_version_numbers, tonumber(number_str))
	end
	local current_tfm_api_version_numbers = {}
	for number_str in string.gmatch(tfm.get.misc.apiVersion, "([^\.]+)") do
		table.insert(current_tfm_api_version_numbers, tonumber(number_str))
	end
	if current_tfm_api_version_numbers[1] and expected_tfm_api_version_numbers[1] ~= current_tfm_api_version_numbers[1] then
		print("<o>The TFM LUA API had a major update, an update of the current script may be available for this new version.</o>")
	elseif current_tfm_api_version_numbers[2] and expected_tfm_api_version_numbers[2] ~= current_tfm_api_version_numbers[2] then
		print("<j>The TFM LUA API had a minor update, an update of the current script may be available for this new version.</j>")
	end
end



-- Create pshy_merge.lua module
pshy.merge_Init()
pshy.merge_CreateModule("pshy_merge.lua")
