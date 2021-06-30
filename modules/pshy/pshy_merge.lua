--- pshy_merge
--
-- This module is used to merge TFM modules.
-- So you can run 2 modules in a single room.
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
-- Every entry is a function to call.
pshy.tfm_events = {}
-- player
pshy.tfm_events.eventPlayerGetCheese = {}
pshy.tfm_events.eventPlayerWon = {}
pshy.tfm_events.eventPlayerDied = {}
pshy.tfm_events.eventPlayerRespawn = {}
pshy.tfm_events.eventPlayerVampire = {}
pshy.tfm_events.eventEmotePlayed = {}
pshy.tfm_events.eventPlayerMeep = {}
-- shaman
pshy.tfm_events.eventSummoningStart = {}
pshy.tfm_events.eventSummoningCancel = {}
pshy.tfm_events.eventSummoningEnd = {}
-- room
pshy.tfm_events.eventNewGame = {}
pshy.tfm_events.eventNewPlayer = {}
pshy.tfm_events.eventLoop = {}
pshy.tfm_events.eventChatCommand = {}
pshy.tfm_events.eventChatMessage = {}
pshy.tfm_events.eventPlayerLeft = {}
-- popups and text areas
pshy.tfm_events.eventPopupAnswer = {}
pshy.tfm_events.eventTextAreaCallback = {}
pshy.tfm_events.eventColorPicked = {}
-- controls
pshy.tfm_events.eventKeyboard = {}
pshy.tfm_events.eventMouse = {}
-- file
pshy.tfm_events.eventFileSaved = {}
pshy.tfm_events.eventFileLoaded = {}
pshy.tfm_events.eventPlayerDataLoaded = {}



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
function pshy.ModuleEnd()
	-- move tfm global events to pshy.tfm_events
	for e_name, e_func_list in pairs(pshy.tfm_events) do
		if type(_G[e_name]) == "function" then
			table.insert(e_func_list, _G[e_name])
			_G[e_name] = nil
		end
	end
	print("[Merge] Module loaded.")
end



--- Final step for merging modules.
-- Call this when you're done putting modules together.
-- @private
function pshy.MergeFinish()
	print("[Merge] Finishing...")
	for e_name, e_func_list in pairs(pshy.tfm_events) do
		if #e_func_list > 0 then
			_G[e_name] = function(...)
				for i_func = 1, #e_func_list do
					e_func_list[i_func](...)
				end
			end
		end
	end	
end
