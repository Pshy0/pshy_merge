--- pshy_merge
--
-- This module is used to merge TFM modules.
-- So you can run 2 modules in a single room for instance.
--
-- not every module will be compatible yet, take caution with:
--   modules using hard-coded ids
--   modules loading/saving player data/files
--   modules calling an event themselves before initialization
--
-- Other modules will have a dependency to this one by default if you use the compiler.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @hardmerge
-- @namespace pshy
pshy = pshy or {}



--- Internal Use:
pshy.tfm_events = {}				-- map (key == event name) of tfm events function lists (every event may have one function per module) 
									-- any function startiong by "event" in _G will be included in this map
pshy.merge_modules_count = 0		-- count of merged modules
pshy.merge_has_module_began = false
pshy.merge_has_finished	= false		-- did merging finish




--- Begin another module.
-- @deprecated
-- Call after a new module's code, in the merged source (hard version only, dont call pshy.ModuleEnd).
-- @private
function pshy.merge_ModuleHard(module_name)
	assert(pshy.merge_has_module_began == false, "pshy.ModuleHard(): A previous module have not been ended!")
	assert(pshy.merge_has_finished == false, "pshy.MergeFinish(): Merging have already been finished!")
	pshy.merge_modules_count = pshy.merge_modules_count + 1
	--print("[Merge] Loading " .. module_name .. " (fast)")
end



--- Begin another module.
-- Call before a new module's code, in the merged source.
-- @private
function pshy.merge_ModuleBegin(module_name)
	assert(pshy.merge_has_module_began == false, "pshy.ModuleBegin(): A previous module have not been ended!")
	assert(pshy.merge_has_finished == false, "pshy.MergeFinish(): Merging have already been finished!")
	pshy.merge_has_module_began = true
	pshy.merge_modules_count = pshy.merge_modules_count + 1
	--print("[Merge] Loading " .. module_name .. "...")
end



--- Begin another module.
-- Call after a module's code, in the merged source.
-- @private
function pshy.merge_ModuleEnd()
	assert(pshy.merge_has_module_began == true, "pshy.ModuleEnd(): No module to end!")
	assert(pshy.merge_has_finished == false, "pshy.MergeFinish(): Merging have already been finished!")
	pshy.merge_has_module_began = false
	-- find used event names
	local events = {}
	for e_name, e in pairs(_G) do
		if type(e) == "function" and string.sub(e_name, 1, 5) == "event" then
			table.insert(events, e_name)
		end
	end
	-- move tfm global events to pshy.tfm_events
	for i_e, e_name in ipairs(events) do
		if not pshy.tfm_events[e_name] then
			pshy.tfm_events[e_name] = {}
		end
		local e_func_list = pshy.tfm_events[e_name]
		table.insert(e_func_list, _G[e_name])
		_G[e_name] = nil
	end
	--print("[Merge] Module loaded.")
end



--- Final step for merging modules.
-- Call this when you're done putting modules together.
-- @private
function pshy.merge_Finish()
	assert(pshy.merge_has_module_began == false, "pshy.MergeFinish(): A previous module have not been ended!")
	assert(pshy.merge_has_finished == false, "pshy.MergeFinish(): Merging have already been finished!")
	pshy.merge_has_finished = true
	local count_events = 0
	for e_name, e_func_list in pairs(pshy.tfm_events) do
		if #e_func_list > 0 then
			count_events = count_events + 1
			-- @todo generated functions should abort if a subfunction returns non-nil
			_G[e_name] = function(...)
				local rst = nil
				for i_func = 1, #e_func_list do
					rst = e_func_list[i_func](...)
					if rst ~= nil then
						break
					end
				end
			end
		end
	end
	print("[Merge] Finished loading " .. tostring(count_events) .. " events in " .. tostring(pshy.merge_modules_count) .. " modules.")
end
