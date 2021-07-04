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
-- @module pshy_merge
-- @hardmerge
-- @namespace pshy
pshy = pshy or {}



--- List of tfm event callbacks by name.
-- Note that it doesnt matter if a function is missing in this list,  
-- any function startiong by "event" in _G will be handled.
-- Every entry is a function to call.
pshy.tfm_events = {}
-- player
--pshy.tfm_events.eventPlayerGetCheese = {}
--pshy.tfm_events.eventPlayerWon = {}
--pshy.tfm_events.eventPlayerDied = {}
--pshy.tfm_events.eventPlayerRespawn = {}
--pshy.tfm_events.eventPlayerVampire = {}
--pshy.tfm_events.eventEmotePlayed = {}
--pshy.tfm_events.eventPlayerMeep = {}
-- shaman
--pshy.tfm_events.eventSummoningStart = {}
--pshy.tfm_events.eventSummoningCancel = {}
--pshy.tfm_events.eventSummoningEnd = {}
-- room
--pshy.tfm_events.eventNewGame = {}
--pshy.tfm_events.eventNewPlayer = {}
--pshy.tfm_events.eventLoop = {}
--pshy.tfm_events.eventChatCommand = {}
--pshy.tfm_events.eventChatMessage = {}
--pshy.tfm_events.eventPlayerLeft = {}
-- popups and text areas
--pshy.tfm_events.eventPopupAnswer = {}
--pshy.tfm_events.eventTextAreaCallback = {}
--pshy.tfm_events.eventColorPicked = {}
-- controls
--pshy.tfm_events.eventKeyboard = {}
--pshy.tfm_events.eventMouse = {}
-- file
--pshy.tfm_events.eventFileSaved = {}
--pshy.tfm_events.eventFileLoaded = {}
--pshy.tfm_events.eventPlayerDataLoaded = {}



--- Begin another module.
-- @deprecated
-- Call after a new module's code, in the merged source (hard version only).
-- @private
function pshy.ModuleHard(module_name)
	print("[Merge] Loading " .. module_name .. " (fast)")
end



--- Begin another module.
-- Call before a new module's code, in the merged source.
-- @private
function pshy.ModuleBegin(module_name)
	print("[Merge] Loading " .. module_name .. "...")
end



--- Begin another module.
-- Call after a module's code, in the merged source.
-- @private
-- @deprecated
function pshy.OldModuleEnd()
	-- move tfm global events to pshy.tfm_events
	for e_name, e_func_list in pairs(pshy.tfm_events) do
		if type(_G[e_name]) == "function" then
			table.insert(e_func_list, _G[e_name])
			_G[e_name] = nil
		end
	end
	print("[Merge] Module loaded.")
end



--- Begin another module.
-- Call after a module's code, in the merged source.
-- @private
function pshy.ModuleEnd()
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
	print("[Merge] Module loaded.")
end



--- Final step for merging modules.
-- Call this when you're done putting modules together.
-- @private
function pshy.MergeFinish()
	print("[Merge] Finishing... (generating " .. #pshy.tfm_events .. " events)")
	for e_name, e_func_list in pairs(pshy.tfm_events) do
		if #e_func_list > 0 then
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
end
