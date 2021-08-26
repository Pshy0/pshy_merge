--- pshy_merge.py
--
-- This module is used by `combine.py` to merge TFM modules.
--
-- If you dont use `combine.py`, merge modules this way:
--	- paste the content of `pshy_merge.py`
--	- for each module to merge:
--		- paste `pshy.merge_ModuleBegin("your_module_name.py")`
--		- paste the content of the module
--		- paste `pshy.merge_ModuleEnd()`
--	- paste `pshy.merge_ModuleFinish()`
--
-- Also adds the event `eventInit()`, called when all modules have been merged (after calling `pshy.merge_Finish()`).
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @hardmerge
-- @namespace pshy
if pshy then
	print("<r>[PshyMerge] </r><d>`pshy` was already defined, perhaps the previous script didnt end cleanly!</d>")
	system.exit()
end
pshy = pshy or {}



--- Help Page
pshy.help_pages = pshy.help_pages or {}						-- touching the help_pages table
pshy.help_pages["pshy_merge"] = {title = "Merging (Modules)", text = "This module merge other modules, and can enable or disable them at any moment.", commands = {}}



--- Internal Use:
pshy.merge_has_module_began = false
pshy.merge_has_finished	= false						-- did merging finish
pshy.merge_pending_regenerate = false
pshy.chat_commands = pshy.chat_commands or {}		-- touching the chat_commands table
pshy.modules = {}									-- map of module tables (key is name)
pshy.modules_list = {}								-- list of module tables
pshy.events = {}



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
	new_module.Enable = nil							-- function called when the module is enabled
	new_module.Disable = nil						-- function called when the module is disabled
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
	-- `Enable` and `Disable` functions
	if _G["Enable"] then
		assert(type(_G["Enable"]) == "function")
		mod.Enable = _G["Enable"]
		_G["Enable"] = nil
	end
	if _G["Disable"] then
		assert(type(_G["Disable"]) == "function")
		mod.Enable = _G["Disable"]
		_G["Disable"] = nil
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
	print("<vp>[PshyMerge] </vp><v>Finished loading <ch>" .. tostring(event_count) .. " events</ch> in <ch2>" .. tostring(#pshy.modules_list) .. " modules</ch2>.</v>")
end



--- Generate the global events.
function pshy.merge_GenerateEvents()
	assert(pshy.merge_has_module_began == false, "pshy.merge_GenerateEvents(): A previous module have not been ended!")
	assert(pshy.merge_has_finished == true, "pshy.merge_GenerateEvents(): Merging have not been finished!")
	-- create list of events
	pshy.events = pshy.events or {}
	for e_name, e_list in pairs(pshy.events) do
		while #e_list > 0 do
			table.remove(e_list, #e_list)
		end
	end
	for i_mod, mod in ipairs(pshy.modules_list) do
		if mod.enabled then
			for e_name, e in pairs(mod.events) do
				pshy.events[e_name] = pshy.events[e_name] or {}
				table.insert(pshy.events[e_name], e)
			end
		end
	end
	-- create events functions
	local event_count = 0
	for e_name, e_func_list in pairs(pshy.events) do
		if #e_func_list > 0 then
			event_count = event_count + 1
			_G[e_name] = nil
			_G[e_name] = function(...)
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
--  for e_name, e_func_list in pairs(pshy.events) do
--		if #e_func_list > 0 then
--			event_count = event_count + 1
--			_G[e_name] = nil
--			_G[e_name] = function(...)
--				local rst = nil
--				for i_func = 1, #e_func_list do
--					rst = e_func_list[i_func](...)
--					if rst ~= nil then
--						break
--					end
--				end
--				if pshy.merge_pending_regenerate then
--					pshy.merge_GenerateEvents()
--					pshy.merge_pending_regenerate = false
--				end
--			end
--		end
--	end


--- Enable a module.
-- @public
function pshy.merge_EnableModule(mname)
	local mod = pshy.modules[mname]
	assert(mod, "Unknown " .. mname .. "module.")
	if mod.enabled then
		return false, "Already enabled."
	end
	mod.enabled = true
	if mod.Enable then
		mod.Enable()
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
	if mod.Disable then
		mod.Disable()
	end
	pshy.merge_pending_regenerate = true
end



--- !modules
function pshy.merge_ChatCommandModules(user, mname)
	tfm.exec.chatMessage("<r>[PshyMerge]</r> Modules (in load order):", user)
	for i_module, mod in pairs(pshy.modules_list) do
		tfm.exec.chatMessage((mod.enabled and "<v>" or "<g>") ..tostring(mod.index) .. "\t" .. mod.name .. "\t" .. tostring(mod.event_count) .. " events", user)
	end
end
pshy.chat_commands["modules"] = {func = pshy.merge_ChatCommandModules, desc = "see a list of loaded modules", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_merge"].commands["modules"] = pshy.chat_commands["modules"]



--- !enablemodule
function pshy.merge_ChatCommandModuleenable(user, mname)
	tfm.exec.chatMessage("[PshyMerge] Enabling " .. mname)
	return pshy.merge_EnableModule(mname)
end
pshy.chat_commands["enablemodule"] = {func = pshy.merge_ChatCommandModuleenable, desc = "enable a module", argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_merge"].commands["enablemodule"] = pshy.chat_commands["enablemodule"]



--- !disablemodule
function pshy.merge_ChatCommandModuledisable(user, mname)
	tfm.exec.chatMessage("[PshyMerge] Disabling " .. mname)
	return pshy.merge_DisableModule(mname)
end
pshy.chat_commands["disablemodule"] = {func = pshy.merge_ChatCommandModuledisable, desc = "disable a module", argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_merge"].commands["disablemodule"] = pshy.chat_commands["disablemodule"]



-- Create pshy_merge.lua module
pshy.merge_CreateModule("pshy_merge.lua")
