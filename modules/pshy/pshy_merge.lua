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
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @hardmerge
-- @namespace pshy
pshy = pshy or {}



--- Internal Use:
pshy.tfm_events = {}					-- map (key == event name) of tfm events function lists (every event may have one function per module) 
										-- any function startiong by "event" in _G will be included in this map
pshy.merge_standard_modules_count = 0	-- count of merged modules
pshy.merge_hard_modules_count = 0		-- count of merged modules
pshy.merge_has_module_began = false
pshy.merge_has_finished	= false			-- did merging finish




--- Begin another module.
-- @deprecated
-- Call after a new module's code, in the merged source (hard version only, dont call pshy.ModuleEnd).
-- @private
function pshy.merge_ModuleHard(module_name)
	assert(pshy.merge_has_module_began == false, "pshy.ModuleHard(): A previous module have not been ended!")
	assert(pshy.merge_has_finished == false, "pshy.MergeFinish(): Merging have already been finished!")
	pshy.merge_hard_modules_count = pshy.merge_hard_modules_count + 1
	--print("[Merge] Loading " .. module_name .. " (fast)")
end



--- Begin another module.
-- Call before a new module's code, in the merged source.
-- @private
function pshy.merge_ModuleBegin(module_name)
	assert(pshy.merge_has_module_began == false, "pshy.ModuleBegin(): A previous module have not been ended!")
	assert(pshy.merge_has_finished == false, "pshy.MergeFinish(): Merging have already been finished!")
	pshy.merge_has_module_began = true
	pshy.merge_standard_modules_count = pshy.merge_standard_modules_count + 1
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
	print("[PshyMerge] Finished loading " .. tostring(count_events) .. " events in " .. tostring(pshy.merge_standard_modules_count) .. " modules (+ " .. tostring(pshy.merge_hard_modules_count) .. " hard merged modules).")
end
