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
--- Enable a list of modules.
function pshy.merge_EnableModules(module_list)
	for i, module_name in pairs(module_list) do
		local mod = pshy.modules[module_name]
		if mod then
			print(mod.eventModuleEnabled)
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
local new_mod = pshy.merge_ModuleBegin("pshy_keycodes.lua")
function new_mod.Content()
--- pshy_keycodes.lua
--
-- This file is a memo for key codes.
-- This contains two maps:
--	- pshy.keycodes: map of key names to key codes
--	- pshy.keynames: map of key codes to key names
--
-- @author TFM:Pshy#3753 DC:Pshy#7998
-- @hardmerge
-- @namespace pshy
-- @source https://help.adobe.com/fr_FR/FlashPlatform/reference/actionscript/3/flash/ui/Keyboard.html
pshy = pshy or {}
--- Map of key name -> key code
pshy.keycodes = {}
-- Directions:
pshy.keycodes.LEFT = 0
pshy.keycodes.UP = 1
pshy.keycodes.RIGHT = 2
pshy.keycodes.DOWN = 3
-- modifiers
pshy.keycodes.SHIFT = 16
pshy.keycodes.CTRL = 17
pshy.keycodes.ALT = 18
-- Arrows:
pshy.keycodes.ARROW_LEFT = 37
pshy.keycodes.ARROW_UP = 38
pshy.keycodes.ARROW_RIGHT = 39
pshy.keycodes.ARROW_DOWN = 40
-- Letters
for i_letter = 0, 25 do
	pshy.keycodes[string.char(65 + i_letter)] = 65 + i_letter
end
-- Numbers (48 - 57):
for number = 0, 9 do
	pshy.keycodes["NUMBER_" .. tostring(number)] = 48 + number
end
-- Numpad Numbers (96 - 105):
for number = 0, 9 do
	pshy.keycodes["NUMPAD_" .. tostring(number)] = 96 + number
end
-- Numpad
pshy.keycodes.NUMPAD_MULTIPLY = 106
pshy.keycodes.NUMPAD_ADD = 107
pshy.keycodes.NUMPAD_SUBTRACT = 109
pshy.keycodes.NUMPAD_ENTER = 108
pshy.keycodes.NUMPAD_DECIMAL = 110
pshy.keycodes.NUMPAD_DIVIDE = 111
-- F1 - F12 (112 - 123)
for f_index = 0, 11 do
	pshy.keycodes["NUMBER_" .. tostring(f_index + 1)] = 112 + f_index
end
-- Other
pshy.keycodes.BACKSPACE = 8
pshy.keycodes.TAB = 9
pshy.keycodes.ENTER = 13
pshy.keycodes.PAUSE = 19
pshy.keycodes.CAPSLOCK = 20
pshy.keycodes.ESCAPE = 27
pshy.keycodes.SPACE = 32
pshy.keycodes.PAGE_UP = 33
pshy.keycodes.PAGE_DOWN = 34
pshy.keycodes.END = 35
pshy.keycodes.HOME = 36
pshy.keycodes.INSERT = 45
pshy.keycodes.DELETE = 46
pshy.keycodes.SEMICOLON = 186
pshy.keycodes.EQUALS = 187
pshy.keycodes.COMMA = 188
pshy.keycodes.HYPHEN = 189
pshy.keycodes.PERIOD = 190
pshy.keycodes.SLASH = 191
pshy.keycodes.GRAVE = 192
pshy.keycodes.LEFTBRACKET = 219
pshy.keycodes.BACKSLASH = 220
pshy.keycodes.RIGHTBRACKET = 221
--- Map of key code -> key name
pshy.keynames = {}
for keyname, keycode in pairs(pshy.keycodes) do
	pshy.keynames[keycode] = keyname
end 
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_loopmore.lua")
function new_mod.Content()
--- pshy_loopmore.lua
--
-- Triggers an event `eventLoopMore` with higger frequency than the default `eventLoop`.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
pshy = pshy or {}
--- Module Settings:
pshy.loopmore_call_standard_loop = false			-- if true, call `eventLoop` on `eventLoopOften`
pshy.loopmore_down_keys = {0, 1, 2, 3}				-- keys to listen to when pressed (used to trigger events, not needed if you bind these yourself)
pshy.loopmore_up_keys = {0, 2}						-- keys to listen to when released (used to trigger events, not needed if you bind these yourself)
--- Internal use:
pshy.loopmore_interval = nil						-- interval between calls to `eventLoopMore`
pshy.loopmore_tfm_timers_interval = nil				-- chosen interval for timers
pshy.loopmore_map_start_os_time = nil				-- map start os time
pshy.loopmore_map_end_os_time = nil					-- expected map end os time
pshy.loopmore_last_loopmore_os_time = os.time()		-- last time of last loopmore loop
pshy.loopmore_anticipated_skips = 0					-- @todo used to skip event when there is too many, avoiding calls to os.time()
pshy.loopmore_missing_time = 0						-- as loops may not be 100% accurate, store what time is missing
pshy.loopmore_missed_loops_to_recover = 1.0			-- how many missed loops to recover
pshy.loopmore_timers = {}							-- store timers and timers sync
--system.newTimer ( callback, time, loop, arg1, arg2, arg3, arg4 )
--- Set the loop_more interval.
-- @public
-- @param interval New loop interval (have limitations).
function pshy.loopmore_SetInterval(interval)
	assert(type(interval) == "number")
	assert(interval >= 100)
	assert(interval <= 500)
	pshy.loopmore_interval = interval
	-- destroy timers
	for i_timer, timer in ipairs(pshy.loopmore_timers) do
		system.removeTimer(timer.id)
	end
	pshy.loopmore_timers = {}
	-- choose tfm timers intervals and count
	local tfm_interval = interval
	while tfm_interval < 1000 do
		tfm_interval = tfm_interval + interval
	end
	pshy.loopmore_tfm_timers_interval = tfm_interval
	local timer_count = tfm_interval / interval
	assert(timer_count >= 1)
	assert(timer_count <= 10)
	-- make place for new timers
	for i_timer = 1, timer_count do
		pshy.loopmore_timers[i_timer] = {}
		local timer = pshy.loopmore_timers[i_timer]
		timer.sync_time = interval * (i_timer - 1)
		timer.id = system.newTimer(pshy.loopmore_InitTimerCallback, pshy.loopmore_tfm_timers_interval + timer.sync_time, false, i_timer)
		timer.i_timer = i_timer
	end
end
--- Callback supposed to create the initial timers with different sync times.
-- When this function is called, the timer is recreated to loop in constent time.
function pshy.loopmore_InitTimerCallback(tid, i_timer)
	local timer = pshy.loopmore_timers[i_timer]
	assert(timer.id ~= nil)
	system.removeTimer(timer.id)
	timer.id = system.newTimer(pshy.loopmore_TimerCallback, pshy.loopmore_tfm_timers_interval, true, i_timer)
end
--- Pshy event eventLoopMore.
function eventLoopMore(time, time_remaining)
	if pshy.loopmore_call_standard_loop and eventLoop then
		eventLoop(time, time_remaining)
	end
end
--- Trigger an `eventLoopMore`.
function pshy.loopmore_RunLoopMore()
	-- skip initial times (information missing)
	if not pshy.loopmore_map_start_os_time or not pshy.loopmore_map_end_os_time then
		return
	end
	-- ok, loop
	local os_time = os.time()
	eventLoopMore(os_time - pshy.loopmore_map_start_os_time, pshy.loopmore_map_end_os_time - os_time)
	--if pshy.loopmore_last_loopmore_os_time then
	--	print("duration: " .. tostring(os_time - pshy.loopmore_last_loopmore_os_time))
	--end
	pshy.loopmore_last_loopmore_os_time = os_time
end
--- Timer callback
function pshy.loopmore_TimerCallback(tfmid, id)
	local timer = pshy.loopmore_timers[id]
	--print("timer #" .. tostring(id) .. "/" .. tostring(#pshy.loopmore_timers) .. ": " .. tostring(os.time() % 10000))
	assert(timer ~= nil, "timer #" .. tostring(id) .. "/" .. tostring(#pshy.loopmore_timers) .. ": " .. tostring(os.time() % 10000))
	--timer.sync_time = os.time() % pshy.loopmore_tfm_timers_interval
	pshy.loopmore_RunLoopMore()
end
--- TFM event eventNewGame()
function eventNewGame()
	pshy.loopmore_map_start_os_time = os.time()
	pshy.loopmore_map_end_os_time = nil
	pshy.loopmore_anticipated_skips = 0
end
--- TFM event eventLoop()
function eventLoop(time, time_remaining)
	local os_time = os.time()
	-- eventLoop can also be used to update our information
	pshy.loopmore_map_start_os_time = os_time - time
	pshy.loopmore_map_end_os_time = os_time + time_remaining
	--pshy.loopmore_Check()
end
--- Override of `tfm.exec.setGameTime`.
function pshy.loopmore_setGameTime(time_remaining, init)
	local os_time = os.time()
	if init then
		pshy.loopmore_map_end_os_time = os_time + time_remaining
	elseif pshy.loopmore_map_end_os_time and time_remaining < (pshy.loopmore_map_end_os_time - os_time) then
		pshy.loopmore_map_end_os_time = os_time + time_remaining
	end
	pshy.loopmore_original_setGameTime(time_remaining, init)
end
pshy.loopmore_original_setGameTime = tfm.exec.setGameTime
tfm.exec.setGameTime = pshy.loopmore_setGameTime
--- Initialization:
pshy.loopmore_SetInterval(250)
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_splashscreen.lua")
function new_mod.Content()
--- pshy_splashscreen.lua
--
-- Adds a splashscreen to a module that is displayed on startup or when a player join.
--
-- @todo: Use timers?
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
-- @require pshy_merge.lua
--- Module Settings:
pshy.splashscreen_image = "17ab692dc8e.png"		-- splash image
pshy.splashscreen_x = 0							-- x location
pshy.splashscreen_y = -10						-- y location
pshy.splashscreen_sx = 1						-- scale on x
pshy.splashscreen_sy = 1						-- scale on y
pshy.splashscreen_text = "<fc>Pshy Module</fc>"	-- @todo splash text (over the image)
pshy.splashscreen_text_x = 0					-- x location of the text
pshy.splashscreen_text_y = 0					-- y location of the text
pshy.splashscreen_text_w = nil					-- width of the text, nil for auto
pshy.splashscreen_text_h = nil					-- height of the text, nil for auto
pshy.splashscreen_text_arbitrary_id = 13
pshy.splashscreen_text_backcolor = 0x0			-- back color of the text area
pshy.splashscreen_text_bordercolor = 0x0		-- border color of the text area
pshy.splashscreen_text_alpha = 1.0				-- opacity of the text
pshy.splashscreen_duration = 8 * 1000			-- duration of the splashscreen in milliseconds
--- Internal Use
pshy.splashscreen_players_ids = {}
pshy.splashscreen_players_end_times = {}
pshy.splashscreen_last_loop_time = nil
pshy.splashscreen_have_shown = false
--- Hide the splashscreen from a player.
-- This is called automatically after `pshy.splashscreen_duration` milliseconds.
function pshy.splashscreen_Hide(player_name)
	if pshy.splashscreen_players_ids[player_name] then
		tfm.exec.removeImage(pshy.splashscreen_players_ids[player_name])
		pshy.splashscreen_players_ids[player_name] = nil
	end
	ui.removeTextArea(pshy.splashscreen_text_arbitrary_id, player_name)
	pshy.splashscreen_players_end_times[player_name] = nil
end
--- Show the splashscreen to a player.
-- This is called automatically when a player join or the game start.
function pshy.splashscreen_Show(player_name)
	pshy.splashscreen_players_end_times[player_name] = pshy.splashscreen_last_loop_time + pshy.splashscreen_duration
	if pshy.splashscreen_image then
		pshy.splashscreen_players_ids[player_name] = tfm.exec.addImage(pshy.splashscreen_image, "&0", pshy.splashscreen_x, pshy.splashscreen_y, player_name, pshy.splashscreen_sx, pshy.splashscreen_sy)
	end
	if pshy.splashscreen_text then
		ui.addtextArea(pshy.splashscreen_text_arbitrary_id, pshy.splashscreen_text, player_name, pshy.splashscreen_text_x, pshy.splashscreen_text_y, pshy.splashscreen_text_w, pshy.splashscreen_text_h, pshy.splashscreen_text_backcolor, pshy.splashscreen_bordercolor, pshy.splashscreen_alpha, false)
	end
end
--- TFM event eventNewPlayer
function eventNewPlayer(player_name)
	pshy.splashscreen_Show(player_name)
end
--- TFM event eventPlayerLeft
function eventPlayerLeft(player_name)
	pshy.splashscreen_Hide(player_name)
end
--- TFM event eventNewGame
-- Remove splashscreens on new games.
-- @todo Check if the game does automatically remove images already between games?
function eventNewGame()
	if pshy.splashscreen_last_loop_time then
		local timeouted = {}
		for player_name in pairs(pshy.splashscreen_players_end_times) do
			timeouted[player_name] = true
		end
		for player_name in pairs(timeouted) do
			pshy.splashscreen_Hide(player_name)
		end
	end
	pshy.splashscreen_last_loop_time = 0
end
--- TFM event eventLoop
function eventLoop(time, time_remaining)
	-- remove timeouted splashscreens
	local timeouted = {}
	for player_name in pairs(pshy.splashscreen_players_end_times) do
		if pshy.splashscreen_players_end_times[player_name] < time then
			timeouted[player_name] = true
		end
	end
	for player_name in pairs(timeouted) do
		pshy.splashscreen_Hide(player_name)
	end
	-- update last time
	pshy.splashscreen_last_loop_time = time
	-- first splash
	if not pshy.splashscreen_have_shown then
		for player_name in pairs(tfm.get.room.playerList) do
			pshy.splashscreen_Show(player_name)
		end
		pshy.splashscreen_have_shown = true
	end
end
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_perms.lua")
function new_mod.Content()
--- pshy_perms
--
-- This module adds permission functionalities.
--
-- Main features (also check the settings):
--	- `pshy.loader`: The script launcher.
--	- `pshy.admins`: Set of admin names (use `pshy.authors` to add permanent admins).
--	- `pshy.HavePerm(player_name, permission)`: Check if a player have a permission (always true for admins).
--	- `pshy.perms.everyone`: Set of permissions every player have by default.
--	- `pshy.perms.PLAYER#0000`: Set of permissions the player "PLAYER#0000" have.
--
-- Some players are automatically added as admin after the first eventNewGame or after they joined.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
pshy = pshy or {}
--- Module Settings and Public Members:
pshy.loader = string.match(({pcall(nil)})[2], "^(.-)%.")		-- script loader
pshy.admins = {}												-- set of room admins
pshy.admins[pshy.loader] = true									-- should the loader be an admin
pshy.perms = {}													-- map of players's sets of permissions (a perm is a string, preferably with no ` ` nor `.`, prefer `-`, `/` is reserved for future use)
pshy.perms.everyone = {}										-- set of permissions everyone has
pshy.perms.cheats = {}											-- set of permissions everyone has when cheats are enabled
pshy.perms.admins = {}											-- set of permissions room admins have
pshy.perms_auto_admin_admins = true								-- add the game admins as room admin automatically
pshy.perms_auto_admin_moderators = true							-- add the moderators as room admin automatically
pshy.perms_auto_admin_funcorps = true							-- add the funcorps as room admin automatically (from a list, ask to be added in it)
pshy.funcorps = {}												-- set of funcorps who asked to be added, they can use !adminme
pshy.funcorps["Pshy#3752"] = true
pshy.funcorps["Aurion#8655"] = true
pshy.funcorps["Gabicamila#0000"] = true
pshy.perms_auto_admin_authors = true							-- add the authors of the final modulepack as admin
pshy.authors = {}												-- set of modulepack authors (add them from your module script)
pshy.authors["Pshy#3752"] = true
pshy.funcorp = (tfm.exec.getPlayerSync() ~= nil)				-- false if tribehouse or non-funcorp, true if funcorp features available
pshy.public_room = (string.sub(tfm.get.room.name, 1, 1) ~= "@")	-- limit admin features in public rooms
pshy.admin_instructions = {}									-- add instructions to admins
pshy.perms_cheats_enabled = false								-- do players have the perms in `pshy.perms.cheats`
--- Help page:
pshy.help_pages = pshy.help_pages or {}						-- touching the help_pages table
pshy.help_pages["pshy_perms"] = {title = "Permissions", text = "Player permissions are stored in sets such as `pshy.perms.Player#0000`.\n`pshy.perms.everyone` contains default permissions.\nRoom admins from the set `pshy.admins` have all permissions.\n", commands = {}}
--- Internal use:
pshy.chat_commands = pshy.chat_commands or {}				-- touching the chat_commands table
--- Check if a player have a permission.
-- @public
-- @param The name of the player.
-- @param perm The permission name.
-- @return true if the player have the required permission.
function pshy.HavePerm(player_name, perm)
	assert(type(perm) == "string", "permission must be a string")
	if player_name == pshy.loader or pshy.admins[player_name] and ((not pshy.public_room) or pshy.perms.admins[perm] or pshy.perms.cheats[perm]) then
		return true
	end
	if pshy.perms.everyone[perm] or (pshy.perms_cheats_enabled and pshy.perms.cheats[perm]) or (pshy.perms[player_name] and pshy.perms[player_name][perm])then
		return true
	end
	return false
end
--- Add an admin with a reason, and broadcast it to other admins.
-- @private
-- @param new_admin The new room admin's Name#0000.
-- @param reason A message displayed as the reason for the promotion.
function pshy.perms_AddAdmin(new_admin, reason)
	pshy.admins[new_admin] = true
	for an_admin, void in pairs(pshy.admins) do
		tfm.exec.chatMessage("<r>[PshyPerms]</r> " .. new_admin .. " added as a room admin" .. (reason and (" (" .. reason .. ")") or "") .. ".", an_admin)
	end
end
--- Check if a player could me set as admin automatically.
-- @param player_name The player's Name#0000.
-- @return true/false (can become admin), reason
-- @private
function pshy.perms_CanAutoAdmin(player_name)
	if pshy.admins[player_name] then
		return false, "Already Admin"
	elseif player_name == pshy.loader then
		return true, "Script Loader"
	elseif pshy.perms_auto_admin_admins and string.sub(player_name, -5) == "#0001" then
		return true, "Admin &lt;3"
	elseif pshy.perms_auto_admin_moderators and string.sub(player_name, -5) == "#0010" then
		return true, "Moderator"
	elseif pshy.perms_auto_admin_funcorps and pshy.funcorps[player_name] then
		return true, "FunCorp"
	elseif pshy.perms_auto_admin_authors and pshy.authors[player_name] then
		return true, "Author"
	else
		return false, "Not Allowed"
	end
end
--- Check if a player use `!adminme` and notify them if so.
-- @private
-- @param player_name The player's Name#0000.
function pshy.perms_TouchPlayer(player_name)
	local can_admin, reason = pshy.perms_CanAutoAdmin(player_name)
	if can_admin then
		tfm.exec.chatMessage("<r>[PshyPerms]</r> <j>You may set yourself as a room admin (" .. reason .. ").</j>", player_name)
		for instruction in ipairs(pshy.admin_instructions) do
			tfm.exec.chatMessage("<r>[PshyPerms]</r> <fc>" .. instruction .. "</fc>", player_name)
		end
		tfm.exec.chatMessage("<r>[PshyPerms]</r> <j>To become a room admin, use `<fc>!adminme</fc>`</j>", player_name)
		print("[PshyPerms] " .. player_name .. " can join room admins.")
	end
end
--- TFM event eventNewPlayer.
function eventNewPlayer(player_name)
	pshy.perms_TouchPlayer(player_name)
end
--- !admin <NewAdmin#0000>
-- Add an admin in the pshy.admins set.
function pshy.perms_ChatCommandAdmin(user, new_admin_name)
	pshy.admins[new_admin_name] = true
	for admin_name, void in pairs(pshy.admins) do
		tfm.exec.chatMessage("<r>[PshyPerms]</r> " .. user .. " added " .. new_admin_name .. " as room admin.", admin_name)
	end
end
pshy.chat_commands["admin"] = {func = pshy.perms_ChatCommandAdmin, desc = "add a room admin", argc_min = 1, argc_max = 1, arg_types = {"string"}, arg_names = {"Newadmin#0000"}}
pshy.help_pages["pshy_perms"].commands["admin"] = pshy.chat_commands["admin"]
--- !adminme
-- Add yourself as an admin if allowed by the module configuration.
function pshy.perms_ChatCommandAdminme(user)
	local allowed, reason = pshy.perms_CanAutoAdmin(user)
	if allowed then
		pshy.perms_AddAdmin(user, reason)
	else
		return false, reason
	end
end
pshy.chat_commands["adminme"] = {func = pshy.perms_ChatCommandAdminme, desc = "join room admins if allowed", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_perms"].commands["adminme"] = pshy.chat_commands["adminme"]
pshy.perms.everyone["!adminme"] = true
--- !admins
-- Add yourself as an admin if allowed by the module configuration.
function pshy.perms_ChatCommandAdmins(user)
	local strlist = ""
	for an_admin, is_admin in pairs(pshy.admins) do
		if is_admin then
			if #strlist > 0 then
				strlist = strlist .. ", "
			end
			strlist = strlist .. an_admin
		end
	end
	tfm.exec.chatMessage("<r>[PshyPerms]</r> Script Loader: " .. tostring(pshy.loader), user)
	tfm.exec.chatMessage("<r>[PshyPerms]</r> Room admins: " .. strlist .. ".", user)
end
pshy.chat_commands["admins"] = {func = pshy.perms_ChatCommandAdmins, desc = "see a list of room admins", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_perms"].commands["admins"] = pshy.chat_commands["admins"]
pshy.perms.everyone["!admins"] = true
--- Pshy event eventInit.
function eventInit()
	for player_name in pairs(tfm.get.room.playerList) do
		pshy.perms_TouchPlayer(player_name)
	end
end
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_alloc.lua")
function new_mod.Content()
--- pshy_alloc.lua
--
-- Functions to allocate unique ids for your modules, to avoid conflicts.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
pshy = pshy or {}
--- Internal Use:
pshy.alloc_id_pools = {}				-- map of id pools
pshy.alloc_id_pools["Popup"]			= {first = 20, last = 200, allocated = {}}
pshy.alloc_id_pools["ColorPicker"]		= {first = 20, last = 200, allocated = {}}
pshy.alloc_id_pools["Bonus"]			= {first = 200, last = 1000, allocated = {}}
pshy.alloc_id_pools["Joint"]			= {first = 200, last = 1000, allocated = {}}
pshy.alloc_id_pools["TextArea"]			= {first = 200, last = 1000, allocated = {}}
pshy.alloc_id_pools["PhysicObject"]		= {first = 200, last = 1000, allocated = {}}
-- No "ShamanObject": returned by tfm.exec.addShamanObject.
-- No "Image": returned by tfm.exec.addImage.
--- Alloc an Id.
-- @public
-- @param pool The Id pool to allocate from.
-- @return An unique id, or nil if no id is available.
function pshy.AllocId(pool)
	if type(pool) == "string" then
		pool = pshy.alloc_id_pools[pool]
	end
	local found_id
	-- finding an id
	if pool.last_freed_id and not pool.allocated[pool.last_freed_id] then
		-- last freed id is available
		found_id = pool.last_freed_id
		if pool.last_freed_id - 1 >= pool.first and not pool.allocated[pool.last_freed_id - 1] then
			-- so the next allocation will check 
			pool.last_freed_id = pool.last_freed_id - 1
		end
	else
		-- last resort: check every id
		local id = pool.first
		while pool.allocated[id] do
			id = id + 1
		end
		if id > pool.last then
			return nil
		end
	end
	-- return
	pool.allocated[found_id] = true
	pool.last_allocated_id = found_id
	return found_id
end
--- Free an Id.
-- @param pool The Id pool to free from.
-- @param id The id to free in the pool.
-- @public
function pshy.FreeId(pool, id)
	if type(pool) == "string" then
		pool = pshy.alloc_id_pools[pool]
	end
	assert(type(id) == "number")
	assert(type(id) == pool.allocated[id], "this id is not allocated")
	pool.allocated[id] = nil
	pool.last_freed_id = id
end
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_utils_lua.lua")
function new_mod.Content()
--- pshy_utils_lua.lua
--
-- Basic functions related to LUA.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @hardmerge
-- @namespace pshy
pshy = pshy or {}
--- string.isalnum(str)
-- us this instead: `not str:match("%W")`
--- Split a string
-- @param str String to split.
-- @param separator Char to split at, default to whitespaces.
-- @param max Max amount of returned strings.
function pshy.StrSplit(str, separator, max)
	assert(type(str) == "string", debug.traceback())
	separator = separator or "%s"
	max = max or -1
	remlen = #str
	local parts = {}
	for part in string.gmatch(str, "([^" .. separator .. "]+)") do
		if max == 1 and remlen >= 0 then
			table.insert(parts, string.sub(str, -remlen))
			return parts
		end
		table.insert(parts, part)
		remlen = remlen - #part - 1
		max = max - 1
	end
	return parts
end
--- Convert a string to a boolean.
-- @param string "true" or "false".
-- @return Boolean true or false, or nil.
function pshy.ToBoolean(value)
	if value == "true" then
		return true
	end
	if value == "false" then
		return false
	end
	return nil
end
--- Convert a string to a boolean (andles yes/no and on/off).
-- @param string "true" or "false".
-- @return Boolean true or false, or nil.
function pshy.ToPermissiveBoolean(value)
	if value == "true" or value == "on" or value == "yes" then
		return true
	end
	if value == "false" or value == "off" or value == "no" then
		return false
	end
	return nil
end
--- Interpret a namespace expression (resolve lua path from string)
-- @param path lua path (such as "tfm.enum.bonus")*
-- @return the object represented by path or nil if not found
function pshy.LuaGet(path)
	assert(type(path) == "string", debug.traceback())
	local parts = pshy.StrSplit(path, ".")
	local cur = _G
	for index, value in pairs(parts) do
		possible_int = tonumber(value)
		value = possible_int or value
		cur = cur[value]
		if cur == nil then
			return nil
		end
	end
	return cur
end
--- Set the value to a lua object.
-- The path is created if it does not exist.
-- @param obj_path Lua path to the object.
-- @param value Value to set, any type.
function pshy.LuaSet(obj_path, value)
	assert(type(obj_path) == "string", debug.traceback())
	local parts = pshy.StrSplit(obj_path, ".")
	local cur = _G
	for i_part, part in pairs(parts) do
		possible_int = tonumber(part)
		part = possible_int or part
		if i_part == #parts then
			-- last iteration
			cur[part] = value
			return cur[part]
		end
		cur[part] = cur[part] or {}
		if type(cur) ~= "table" then
			return nil
		end
		cur = cur[part]
	end
	error("unreachable code")
end
--- Get a random key from a table.
-- @param t The table.
function pshy.LuaRandomTableKey(t)
	local keylist = {}
	for k in pairs(t) do
	    table.insert(keylist, k)
	end
	return keylist[math.random(#keylist)]
end
--- Convert a string value to the given type.
-- nil value is not supported for `string` and `player`.
-- @param value String to convert.
-- @param type string representing the type to convert to.
-- @return The converted value.
-- @todo Should t be a table to represent enum keys?
function pshy.ToType(value, t)
	assert(type(value) == "string", "wrong argument type")
	assert(type(t) == "string", "wrong argument type")
	-- string
	if t == "string" then
		return value
	end
	-- player
	if t == "player" then
		return pshy.FindPlayerName(value)
	end
	-- nil
	if value == "nil" then
		return nil
	end
	-- boolean
	if t == "bool" or t == "boolean" then
		return pshy.ToPermissiveBoolean(value)
	end
	-- number
	if t == "number" then
		return tonumber(value)
	end
	-- hexnumber
	if t == "hexnumber" then
		if string.sub(value, 1, 1) == '#' then
			value = string.sub(value, 2, #value)
		end
		return tonumber(value, 16)
	end
	-- enums
	local enum = pshy.LuaGet(t)
	if type(enum) == "table" then
		return enum[value]
	end
	-- not supported
	error("type not supported")
end
--- Convert an argument to anoter type automatically.
-- @param value String to convert.
-- @return the same value represented by the best type possible (bool/number/string).
function pshy.AutoType(value)
	assert(type(value) == "string", "wrong argument type")
	local rst
	-- nil
	if value == "nil" then
		return nil
	end
	-- boolean
	if value == "true" then
		return true
	end
	if value == "false" then
		return false
	end
	-- number
	rst = tonumber(value, 10)
	if rst then
		return rst
	end
	-- empty table
	if value == "{}" then
		return {}
	end
	-- tfm enums
	rst = pshy.TFMEnumGet(value)
	if rst then
		return rst
	end
	-- lua object
	rst = pshy.LuaGet(value)
	if rst then
		return rst
	end
	-- color code / hex number
	if string.sub(value, 1, 1) == '#' then
		rst = tonumber(string.sub(value, 2, #value), 16)
		if rst then
			return rst
		end
	end
	-- string
	return value
end
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_utils_math.lua")
function new_mod.Content()
--- pshy_utils_math.lua
--
-- Basic math functions.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @hardmerge
-- @namespace pshy
pshy = pshy and pshy or {}
--- Distance between points.
-- @return The distance between the points.
function pshy.Distance(x1, y1, x2, y2)
	return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_utils_tfm.lua")
function new_mod.Content()
--- pshy_utils_tfm.lua
--
-- Basic functions related to TFM.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @hardmerge
-- @namespace pshy
-- @require pshy_perms.lua
-- @require pshy_utils_lua.lua
pshy = pshy or {}
--- Get the display nick of a player.
-- @param player_name The player name.
-- @return either the part of the name before '#' or an entry from `pshy.nicks`.
function pshy.GetPlayerNick(player_name)
	if pshy.nicks and pshy.nicks[player_name] then
		return pshy.nicks[player_name]
	else
		return pshy.StrSplit(player_name, "#", 2)[1]
	end
end
--- Find a player's full Name#0000.
-- @param partial_name The beginning of the player name.
-- @return The player full name or (nil, reason).
-- @todo Search in nicks as well.
function pshy.FindPlayerName(partial_name)
	local player_list = tfm.get.room.playerList
	if player_list[partial_name] then
		return partial_name
	else
		local real_name
		for player_name in pairs(player_list) do
			if string.sub(player_name, 1, #partial_name) == partial_name then
				if real_name then
					return nil, "several players found" -- 2 players have this name
				end
				real_name = player_name
			end
		end
		if pshy.nicks then
			for player_name, nick in pairs(pshy.nicks) do
				if string.sub(nick, 1, #partial_name) == partial_name then
					if real_name then
						return nil, "several players found" -- 2 players have this name
					end
					real_name = player_name
				end
			end
		end
		if not real_name then
			return nil, "player not found"
		end
		return real_name -- found
	end
end
--- Find a player's full Name#0000 or throw an error.
-- @return The player full Name#0000 (or throw an error).
function pshy.FindPlayerNameOrError(partial_name)
	local real_name, reason = pshy.FindPlayerName(partial_name)
	if not real_name then
		error(reason)
	end
	return real_name
end
--- Convert a tfm enum index to an interger, searching in all tfm enums.
-- Search in bonus, emote, ground, particle and shamanObject.
-- @param index a string, either representing a tfm enum value or integer.
-- @return the existing enum value or nil
function pshy.TFMEnumGet(index)
	assert(type(index) == "string")
	local value
	for enum_name, enum in pairs(tfm.enum) do
		value = enum[index]
		if value then
			return value
		end
	end
	return nil
end
--- Get how many players are alive in tfm.get
function pshy.CountPlayersAlive()
	local count = 0
	for player_name, player in pairs(tfm.get.room.playerList) do
		if not player.isDead then
			count = count + 1
		end
	end
	return count
end
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_utils_tables.lua")
function new_mod.Content()
--- pshy_utils_tables.lua
--
-- Basic functions related to LUA tables.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @hardmerge
-- @namespace pshy
pshy = pshy or {}
--- Copy a table.
-- @param t The table to copy.
-- @return a copy of the table.
function pshy.TableCopy(t)
	assert(type(t) == "table")
	local new_table = {}
	for key, value in pairs(t) do
		new_table[key] = value
	end
	return new_table
end
--- Copy a table, recursively.
-- @param t The table to copy.
-- @return a copy of the table.
function pshy.TableDeepCopy(t)
	assert(type(t) == "table")
	local new_table = {}
	for key, value in pairs(t) do
		if type(value) == "table" then
			value = pshy.TableDeepCopy(value)
		end
		new_table[key] = value
	end
	return new_table
end
--- Get a table's keys as a list.
-- @public
-- @param t The table.
-- @return A list of the keys from the given table.
function pshy.TableKeys(t)
	local keys
	for key in pairs(t) do
		table.insert(keys, key)
	end
	return keys
end
--- Count the keys in a table.
-- @public
-- @param t The table.
-- @return The count of keys in the given table.
function pshy.TableCountKeys(t)
	local count = 0
	for key, value in pairs(t) do
		count = count + 1	
	end
	return count
end
--- Append a list to another.
-- @param dst_list The list receiving the new items/
-- @param src_list The list containing the items to appen to the other list.
function pshy.ListAppend(dst_list, src_list)
	assert(type(dst_list) == "table")
	assert(type(dst_list) == "table")
	for i_item, item in ipairs(src_list) do
		table.insert(dst_list, item)
	end
end
--- Get a random key from a table.
-- @param t The table.
function pshy.TableGetRandomKey(t)
	local keylist = {}
	for k in pairs(t) do
	    table.insert(keylist, k)
	end
	return keylist[math.random(#keylist)]
end
--- Count a value in a table.
-- @param t The table to count from.
-- @param v The value to search.
function pshy.TableCountValue(t, v)
	local count = 0
	for key, value in pairs(t) do
		if value == v then
			count = count + 1
		end
	end
	return count
end
--- Remove all instances of a value from a list.
-- @param l List to remove from.
-- @param v Value to remove.
function pshy.ListRemoveValue(l, v)
	for i = #l, 1, -1 do
		if l[i] == v then
			table.remove(l, i)
		end
	end
end
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_utils_messages.lua")
function new_mod.Content()
--- pshy_utils_messages.lua
--
-- Basic functions related to sending messages to players.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @hardmerge
-- @namespace pshy
pshy = pshy or {}
--- Answer a player's command.
-- @param msg The message to send.
-- @param player_name The player who will receive the message.
function pshy.Answer(msg, player_name)
	assert(player_name ~= nil)
	tfm.exec.chatMessage("<n> ↳ " .. tostring(msg), player_name)
end
--- Answer a player's command (on error).
-- @param msg The message to send.
-- @param player_name The player who will receive the message.
function pshy.AnswerError(msg, player_name)
	assert(player_name ~= nil)
	tfm.exec.chatMessage("<r> × " .. tostring(msg), player_name)
end
--- Send a message.
-- @param msg The message to send.
-- @param player_name The player who will receive the message (nil for everyone).
function pshy.Message(msg, player_name)
	tfm.exec.chatMessage("<n> ⚛ " .. tostring(msg), player_name)
end
--- Send a message as the module.
-- @param msg The message to send.
-- @param player_name The player who will receive the message (nil for everyone).
function pshy.System(msg, player_name)
	tfm.exec.chatMessage("<n> ⚒ " .. tostring(msg), player_name)
end
--- Log a message and also display it to the host.
-- @param msg Message to log.
-- @todo This may have to be overloaded by pshy_perms?
function pshy.Log(msg)
	tfm.exec.chatMessage("log: " .. tostring(msg), pshy.loader)
	print("log: " .. tostring(msg))
end
--- Show the dialog window with a message (simplified)
-- @param player_name The player who see the popup.
-- @param message The message the player will see.
function pshy.Popup(player_name, message)
	ui.addPopup(4097, 0, tostring(message), player_name, 40, 20, 720, true)
end
--- Show a html title at the top of the screen.
-- @param html The html to display, or nil to hide.
-- @param player_name The player name to display the title to, or nil for all players.
function pshy.Title(html, player_name)
	html = html or nil
	player_name = player_name or nil
	local title_id = 82 -- arbitrary random id
	if html then
		ui.addTextArea(title_id, html, player_name, 0, 20, 800, nil, 0x000000, 0x000000, 1.0, true)
	else
		ui.removeTextArea(title_id, player_name)
	end
end
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_utils.lua")
function new_mod.Content()
--- pshy_utils.lua
--
-- This module gather basic functions.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @hardmerge
-- @namespace pshy
-- @require pshy_alloc.lua
-- @require pshy_keycodes.lua
-- @require pshy_utils_lua.lua
-- @require pshy_utils_math.lua
-- @require pshy_utils_tfm.lua
-- @require pshy_utils_tables.lua
-- @require pshy_utils_messages.lua
pshy = pshy or {}
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_rotation.lua")
function new_mod.Content()
--- pshy_rotation.lua
--
-- Adds a table type that can be used to create random rotations.
--
-- A rotation is a table with the folowing fields:
--	- items: List of items to be randomly returned.
--	- next_indices: Private list of item indices that have not been done yet.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @hardmerge
-- @require pshy_utils.lua
pshy = pshy or {}
--- Create a rotation.
-- @public
-- You can then add items in its `items` field.
function pshy.rotation_Create()
	local rotation = {}
	rotation.items = {}
	return rotation
end
--- Reset a rotation.
-- @public
-- Its state will be back as if you had never poped items from it.
function pshy.rotation_Reset(rotation)
	assert(type(rotation) == "table", "unexpected type " .. type(rotation))
	rotation.next_indices = {}
	if #rotation.items > 0 then
		for i = 1, #rotation.items do
			table.insert(rotation.next_indices, i)
		end
	end
end
--- Get a random item from a rotation.
-- @param rotation The rotation table.
-- @return A random item from the rotation.
function pshy.rotation_Next(rotation)
	assert(type(rotation) == "table", "unexpected type " .. type(rotation))
	if #rotation.items == 0 then
		return nil
	end
	-- reset the rotation if needed
	rotation.next_indices = rotation.next_indices or {}
	if #rotation.next_indices == 0 then
		pshy.rotation_Reset(rotation)
	end
	-- pop the item
	local i_index = math.random(#rotation.next_indices)
	local item = rotation.items[rotation.next_indices[i_index]]
	table.remove(rotation.next_indices, i_index)
	-- returning
	return item
end
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_commands.lua")
function new_mod.Content()
--- pshy_commands.lua
--
-- This module can be used to implement in-game commands.
--
-- Example adding a command 'demo':
--   function my.function.demo(user, arg_int, arg_str)
--       print("hello " .. user .. "! " .. tostring(arg_int) .. tostring(arg_str))
--   end
--   pshy.commands["demo"] = {func = my.function.demo}			-- the function to call
--   pshy.commands["demo"].desc = "my demo function"			-- short description
--   pshy.commands["demo"].help = "longer help message to detail how this command works"	-- @deprecated: this will be removed and currently does nothing
--   pshy.commands["demo"].no_user = false						-- true to not pass the command user as the 1st arg
--   pshy.commands["demo"].argc_min = 1							-- need at least 1 arg	
--   pshy.commands["demo"].argc_max = 2							-- max args (remaining args will be considered a single one)
--   pshy.commands["demo"].arg_types = {"number", "string"}		-- argument type as a string, nil for auto, a table to use as an enum, or a function to use for the conversion
--   pshy.commands["demo"].arg_names = {"index", "message"}		-- argument names
--   pshy.command_aliases["ddeemmoo"] = "demo"					-- create an alias
--   pshy.perms.everyone["demo"] = true							-- everyone can run the command
--   pshy.perms.cheats["demo"] = true							-- everyone can run the command when cheats are enabled (useless in this example)
--   pshy.perms.admins["demo"] = true							-- admins can run the command (useless in this example)
--
-- This submodule add the folowing commands:
--   !help [command]				- show general or command help
--
-- @author DC: Pshy#7998
-- @namespace pshy
-- @require pshy_utils.lua
-- @require pshy_perms.lua
pshy = pshy or {}
--- Module Settings:
pshy.commands_require_prefix = false		-- if true, all commands must start with `!pshy.`
--- Chat commands lists
-- keys represent the lowecase command name.
-- values are tables with the folowing fields:
-- - func: the function to run
--   the functions will take the player name as the first argument, 
--   then the remaining ones.
-- - help: the help string to display when querying for help.
-- - arg_types: an array the argument types (not including the player name).
--   if arg_types is undefined then this is determined automatically.
-- - arg_names: 
-- - no_user: true if the called function doesnt take the command user as
--   a first argument.
pshy.chat_commands = pshy.chat_commands or {}
pshy.commands = pshy.chat_commands					-- seek to replace chat_commands by this
--- Map of command aliases (string -> string)
pshy.chat_command_aliases = pshy.chat_command_aliases or {}
pshy.commands_aliases = pshy.chat_command_aliases	-- seek to replace chat_command_aliases by this
--- Get a command target player or throw on permission issue.
-- This function can be used to check if a player can run a command on another one.
-- @private
function pshy.commands_GetTargetOrError(user, target, perm_prefix)
	assert(type(perm_prefix) == "string")
	if not target then
		return user
	end
	if target == user then
		return user
	elseif not pshy.HavePerm(user, perm_prefix .. "-others") then
		error("You do not have permission to use this command on others.")
		return
	end
	return target
end
--- Get the real command name
-- @private
-- @param alias_name Command name or alias without `!`.
function pshy.commands_ResolveAlias(alias_name)
	while not pshy.commands[alias_name] and pshy.commands_aliases[alias_name] do
		alias_name = pshy.commands_aliases[alias_name]
	end
	return alias_name
end
--- Get a chat command by name
-- @private
-- @param alias_name Can be the command name or an alias, without `!`.
function pshy.commands_Get(alias_name)
	return (pshy.chat_commands[pshy.commands_ResolveAlias(alias_name)])
end
--- Get a command usage.
-- @private
-- The returned string represent how to use the command.
-- @param cmd_name The name of the command.
-- @return HTML text for the command's usage.
function pshy.commands_GetUsage(cmd_name)
	local text = "!" .. cmd_name
	local real_command = pshy.commands_Get(cmd_name)
	local min = real_command.argc_min or 0
	local max = real_command.argc_max or min
	if max > 0 then
		for i = 1, max do
			text = text .. " " .. ((i <= min) and "&lt;" or "[")
			if real_command.arg_names and i <= #real_command.arg_names then
				text = text .. real_command.arg_names[i]
			elseif real_command.arg_types and i <= #real_command.arg_types then
				if type(real_command.arg_types[i]) == "string" then
					text = text .. real_command.arg_types[i]
				else
					text = text .. type(real_command.arg_types[i])
				end
			else
				text = text .. "?"
			end
			text = text .. ((i <= min) and "&gt;" or "]")
		end
	end
	if not real_command.argc_max then
		text = text .. " [...]"
	end
	return text
end
--- Rename a command and set the old name as an alias.
-- @private
-- @deprecated
function pshy.RenameChatCommand(old_name, new_name, keep_previous)
	print("Used deprecated pshy.RenameChatCommand")
	if old_name == new_name or not pshy.chat_commands[old_name] then
		print("<o>[PshyCmds] Warning: command not renamed!")
	end
	if keep_previous then
		pshy.chat_command_aliases[old_name] = new_name
	end
	pshy.chat_commands[new_name] = pshy.chat_commands[old_name]
	pshy.chat_commands[old_name] = nil
end
--- Convert string arguments of a table to the specified types, 
-- or attempt to guess the types.
-- @private
-- @param args Table of elements to convert.
-- @param types Table of types.
-- @return true or (false, reason)
function pshy.commands_ConvertArgs(args, types)
	local reason
	local has_multiple_players = false
	for index = 1, #args do
		if (not types) or index > #types or types[index] == nil then
			-- automatic conversion
			args[index] = pshy.AutoType(args[index])
		elseif type(types[index]) == "function" then
			-- a function is used for conversion
			args[index], reason = types[index](args[index])
			if args[index] == nil then
				return false, (reason or ("wrong type for argument " .. tostring(index) .. ", conversion function returned `nil`"))
			end
		elseif type(types[index]) == "table" then
			-- a function is used as an enum
			args[index] = types[index][args[index]]
			if args[index] == nil then
				return false, "wrong type for argument " .. tostring(index) .. ", expected an enum value"
			end
		elseif types[index] == 'player' and args[index] == '*' then
			if has_multiple_players then
				return false, "only a single '*' argument may represent all the players"
			end
			has_multiple_players = true
		else
			-- using pshy.ToType with the given type string
			args[index], reason = pshy.ToType(args[index], types[index])
			if reason ~= nil then
				return false, reason
			end
			if args[index] == nil then
				return false, "wrong type for argument " .. tostring(index) .. ", expected " .. types[index]
			end
		end
	end
	return true
end
--- Run a command as a player.
-- @param user The Name#0000 of the player running the command.
-- @param command_str The full command the player have input, without "!".
-- @return false on permission failure, true if handled and not to handle, nil otherwise
function pshy.commands_Run(user, command_str)
	assert(type(user) == "string")
	assert(type(command_str) == "string")
	-- log non-admin players commands use
	if not pshy.admins[user] then
		print("[PshyCmds] " .. user .. ": !" .. command_str)
	end
	local had_prefix = false
	-- remove 'pshy.' prefix
	-- @todo This is now obsolete
	if #command_str > 5 and string.sub(command_str, 1, 5) == "pshy." then
		command_str = string.sub(command_str, 6, #command_str)
		had_prefix = true
		tfm.exec.chatMessage("[PshyCmds] <j>The `!pshy.` prefix is now deprecated, please use the `!pshy` command instead.</j>", user)
	elseif pshy.commands_require_prefix then
		tfm.exec.chatMessage("[PshyCmds] Ignoring commands without a `!pshy.` prefix.", user)
		return
	end
	-- get command
	local args = pshy.StrSplit(command_str, " ", 2)
	return pshy.commands_RunArgs(user, args[1], args[2])
end
--- Run a command (with separate arguments) as a player.
-- @param user The Name#0000 of the player running the command.
-- @param command_name The name of the command used.
-- @param args_str A string corresponding to the argument part of the command.
-- @return false on permission failure, true if handled and not to handle, nil otherwise
function pshy.commands_RunArgs(user, command_name, args_str)
	local final_command_name = pshy.commands_ResolveAlias(command_name)
	-- disallowed command
	if not pshy.HavePerm(user, "!" .. final_command_name) then
		pshy.AnswerError("You do not have permission to use this command.", user)
		return false
	end
	local command = pshy.commands_Get(command_name)
	-- non-existing command
	local command = pshy.commands_Get(command_name)
	if not command then
		if had_prefix then
			pshy.AnswerError("Unknown pshy command.", user)
			return false
		else
			tfm.exec.chatMessage("Another module may handle that command.", user)
			return nil
		end
	end
	-- get args
	args = args_str and pshy.StrSplit(args_str, " ", command.argc_max or 32) or {} -- max command args set to 32 to prevent abuse
	--table.remove(args, 1)
	-- missing arguments
	if command.argc_min and #args < command.argc_min then
		pshy.AnswerError("Usage: " .. pshy.commands_GetUsage(final_command_name), user)
		return false
	end
	-- too many arguments
	if command.argc_max == 0 and args_str ~= nil then
		pshy.AnswerError("This command do not use arguments.", user)
		return false
	end
	-- multiple players args
	local multiple_players_index = nil
	if command.arg_types then
		for i_type, type in ipairs(command.arg_types) do
			if type == "player" and args[i_type] == '*' then
				multiple_players_index = i_type
			end
		end
	end
	-- convert arguments
	local rst, rtn = pshy.commands_ConvertArgs(args, command.arg_types)
	if not rst then
		pshy.AnswerError(tostring(rtn), user)
		return not had_prefix
	end
	-- runing
	local pcallrst, rst, rtn
	if multiple_players_index then
		-- command affect all players
		for player_name in pairs(tfm.get.room.playerList) do
			args[multiple_players_index] = player_name
			if not command.no_user then
				pcallrst, rst, rtn = pcall(command.func, user, table.unpack(args))
			else
				pcallrst, rst, rtn = pcall(command.func, table.unpack(args))
			end
			if pcallrst == false or rst == false then 
				break
			end
		end
	else
		-- standard		
		if not command.no_user then
			pcallrst, rst, rtn = pcall(command.func, user, table.unpack(args))
		else
			pcallrst, rst, rtn = pcall(command.func, table.unpack(args))
		end
	end
	-- error handling
	if pcallrst == false then
		-- pcall failed
		pshy.AnswerError(rst, user)
	elseif rst == false then
		-- command function returned false
		pshy.AnswerError(rtn, user)
	end
end
--- !pshy <command>
-- Run a pshy command.
function pshy.commands_CommandPshy(user, command)
	if command then
		pshy.commands_Run(user, command)
	else
		pshy.commands_Run(user, "help")
	end
end
pshy.commands["pshy"] = {func = pshy.commands_CommandPshy, desc = "run a command listed in `pshy.commands`", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.commands_aliases["pshycmd"] = "pshy"
pshy.perms.everyone["!pshy"] = true
--- TFM event eventChatCommand.
function eventChatCommand(player_name, message)
	return pshy.commands_Run(player_name, message)
end
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_ui.lua")
function new_mod.Content()
--- pshy_ui.lua
--
-- Module simplifying ui creation.
-- Every ui is represented by a pshy ui table storing its informations.
--
-- @author Pshy
-- @namespace pshy
-- @require pshy_commands.lua
-- @require pshy_utils.lua
pshy = pshy or {}
-- ui.addTextArea (id, text, targetPlayer, x, y, width, height, backgroundColor, borderColor, backgroundAlpha, fixedPos)
-- ui.updateTextArea (id, text, targetPlayer)
-- ui.removeTextArea (id, targetPlayer)
--
-- ui.addPopup (id, type, text, targetPlayer, x, y, width, fixedPos)
-- ui.showColorPicker (id, targetPlayer, defaultColor, title)
--
-- <p align='center'><font color='#badb2f' size='24' face='Soopafresh'>Help</font></p><br>hejsfsejh<u></u><i></i><b></b>
--- Create a pshy ui
function pshy.UICreate(text)
	local ui = {}
	ui.id = 2049
	ui.text = text or "<b>New Control</b>"
	ui.player = nil
	ui.x = 50
	ui.y = 50
	ui.w = nil --700
	ui.h = nil --500
	--ui.back_color = 0x010101
	--ui.border_color = 0xffff00
	ui.alpha = 1.0
	ui.fixed = true
	return ui
end
--- Show a pshy ui
function pshy.UIShow(u, player_name)
	ui.addTextArea(u.id, u.text, player_name or u.player, u.x, u.y, u.w, u.h, u.back_color, u.border_color, u.alpha, u.fixed)
end
--- TFM text area click
-- events are separated by a '\n', so a single click can trigger several events.
-- events close, closeall, pcmd and cmd are hardcoded
function eventTextAreaCallback(textAreaId, playerName, callback)
	callbacks = pshy.StrSplit(callback, "\n")
	for i_c, c in ipairs(callbacks) do
		-- close callback
		if (c == "close") then
			ui.removeTextArea(textAreaId, playerName)
		end
		-- closeall callback
		if (c == "closeall") then
			if pshy.admins[playerName] then
				ui.removeTextArea(textAreaId, nil)
			end
		end
		-- pcmd callback
		if (string.sub(c, 1, 5) == "pcmd ") then
			pshy.commands_Run(playerName, pshy.StrSplit(c, " ", 2)[2])
		end
		-- apcmd callback
		if (string.sub(c, 1, 6) == "apcmd ") then
			if pshy.admins[playerName] then
				pshy.commands_Run(playerName, pshy.StrSplit(c, " ", 2)[2])
			else
				return
			end
		end
		-- cmd callback
		if (string.sub(c, 1, 4) == "cmd ") then
			eventChatCommand(playerName, pshy.StrSplit(c, " ", 2)[2])
			eventChatMessage(playerName, "!" .. pshy.StrSplit(c, " ", 2)[2])
		end
	end
end
--- TFM event eventChatMessage
-- This is just to touch the event so it exists.
function eventChatMessage(player_name, message)	
end
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_help.lua")
function new_mod.Content()
--- pshy_help.lua
--
-- Add a help commands and in-game help functionalities.
--
-- @author tfm:Pshy#3752
-- @hardmerge
-- @require pshy_commands.lua
-- @require pshy_ui.lua
--- Help pages.
-- Key is the name page.
-- Value is the help table (help page).
-- Help pages fields:
--	string:back		- upper page.
--	string:title		- title of the page.
--	string:text		- text to display at the top of the page.
--	set:commands		- set of chat command names.
--	set:examples		- map of action (string) -> command (string) (click to run).
--	set:subpages		- set of pages to be listed in that one at the bottom.
--	bool:restricted	- if true, require the permission "!help page_name"
pshy.help_pages = pshy.help_pages or {}
--- Main help page (`!help`).
-- This page describe the help available.
pshy.help_pages[""] = {title = "Main Help", text = "This page list the available help pages.\n", subpages = {}}
pshy.help_pages["pshy"] = {back = "", title = "Pshy Modules (pshy_*)", text = "You may optionaly prefix pshy's commands by 'pshy '\nUse * to run a command on every player.\n", subpages = {}}
pshy.help_pages[""].subpages["pshy"] = pshy.help_pages["pshy"]
--- Get a chat command desc text.
-- @param chat_command_name The name of the chat command.
function pshy.GetChatCommandDesc(chat_command_name)
	local cmd = pshy.chat_commands[chat_command_name]
	local desc = cmd.desc or "no description"
	return desc
end
--- Get a chat command help html.
-- @param chat_command_name The name of the chat command.
function pshy.GetChatCommandHelpHtml(command_name)
	local real_command = pshy.GetChatCommand(command_name)
	local html = "<j><i><b>"
	-- usage
	local html = html .. pshy.commands_GetUsage(command_name)
	-- short description
	html = html .. "</b></i>\t - " .. (real_command.desc and tostring(real_command.desc) or "no description")
	-- help + other info
	if real_command.help then
		html = html .. "\n" .. real_command.help
	end
	if not real_command.func then
		html = html .. "\nThis command is not handled by pshy_commands."
	end
	html = html .. "</j>"
	return html
end
--- Get html things to add before and after a command to display it with the right color.
function pshy.help_GetPermColorMarkups(perm)
	if pshy.perms.everyone[perm] then
		return "<v>", "</v>"
	elseif pshy.perms.cheats[perm] then
		return "<j>", "</j>"
	elseif pshy.perms.admins[perm] then
		return "<r>", "</r>"
	else
		return "<vi>", "</vi>"
	end
end
--- Get the html to display for a page.
function pshy.GetHelpPageHtml(page_name, is_admin)
	local page = pshy.help_pages[page_name]
	page = page or pshy.help_pages[""]
	local html = ""
	-- title menu
	local html = "<p align='right'>"
	html = html .. " <bl><a href='event:pcmd help " .. (page.back or "") .. "'>[ ↶ ]</a></bl>"
	html = html .. " <r><a href='event:close'>[ × ]</a></r>"
	html = html .. "</p>"
	-- title
	html = html .. "<p align='center'><font size='16'>" .. (page.title or page_name) .. '</font></p>\n'
	-- restricted ?
	if page.restricted and not is_admin then
		html = html .. "<p align='center'><font color='#ff4444'>Access to this page is restricted.</font></p>\n"
		return html
	end
	-- text
	html = html .. "<p align='center'>" .. (page.text or "") .. "</p>"
	-- commands
	if page.commands then
		html = html .. "<bv><p align='center'><font size='16'>Commands" .. "</font></p>\n"
		for cmd_name, cmd in pairs(page.commands) do
			local m1, m2 = pshy.help_GetPermColorMarkups("!" .. cmd_name)
			--html = html .. '!' .. ex_cmd .. "\t - " .. (cmd.desc or "no description") .. '\n'
			html = html .. m1
			--html = html .. "<u><a href='event:pcmd help " .. cmd_name .. "'>" .. pshy.commands_GetUsage(cmd_name) .. "</a></u>"
			html = html .. "<u>" .. pshy.commands_GetUsage(cmd_name) .. "</u>"
			html = html .. m2
			html = html .. "\t - " .. (cmd.desc or "no description") .. "\n"
		end
		html = html .. "</bv>\n"
	end
	-- examples
	if page.examples then
		html = html .. "<rose><p align='center'><font size='16'>Examples" .. "</font> (click to run)</p>\n"
		for ex_cmd, ex_desc in pairs(page.examples) do
			--html = html .. "!" .. ex_cmd .. "\t - " .. ex_desc .. '\n' 
			html = html .. "<j><i><a href='event:cmd " .. ex_cmd .. "'>!" .. ex_cmd .. "</a></i></j>\t - " .. ex_desc .. '\n' 
		end
		html = html .. "</rose>\n"
	end
	-- subpages
	if page.subpages then
		html = html .. "<ch><p align='center'><font size='16'>Subpages:" .. "</font></p>\n<p align='center'>"
		for subpage_name, subpage in pairs(page.subpages) do
			--html = html .. subpage .. '\n'
			if subpage and subpage.title then
				html = html .. "<u><a href='event:pcmd help " .. subpage_name .. "'>" .. subpage.title .. "</a></u>\n"
			else
				html = html .. "<u><a href='event:pcmd help " .. subpage_name .. "'>" .. subpage_name .. "</a></u>\n" 
			end
		end
		html = html .. "</p></ch>"
	end
	return html
end
--- !help [command]
-- Get general help or help about a specific page/command.
function pshy.ChatCommandHelp(user, page_name)
	if page_name == nil then
		html = pshy.GetHelpPageHtml(nil)
	elseif string.sub(page_name, 1, 1) == '!' then
		html = pshy.GetChatCommandHelpHtml(string.sub(page_name, 2, #page_name))
		tfm.exec.chatMessage(html, user)
		return true
	elseif pshy.help_pages[page_name] then
		html = pshy.GetHelpPageHtml(page_name, pshy.HavePerm(user, "!help " .. page_name))
	elseif pshy.chat_commands[page_name] then
		html = pshy.GetChatCommandHelpHtml(page_name)
		tfm.exec.chatMessage(html, user)
		return true
	else
		html = pshy.GetHelpPageHtml(page_name)
	end
	html = "<font size='10'><b><n>" .. html .. "</n></b></font>"
	if #html > 2000 then
		error("#html is too big: == " .. tostring(#html))
	end
	local ui = pshy.UICreate(html)
	ui.x = 100
	ui.y = 50
	ui.w = 600
	--ui.h = 440
	ui.back_color = 0x003311
	ui.border_color = 0x77ff77
	ui.alpha = 0.9
	pshy.UIShow(ui, user)
	return true
end
pshy.chat_commands["help"] = {func = pshy.ChatCommandHelp, desc = "list pshy's available commands", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.perms.everyone["!help"] = true
--- Pshy event eventInit
function eventInit()
	-- other page
	pshy.help_pages["other"] = {title = "Other Pages", subpages = {}}
	for page_name, help_page in pairs(pshy.help_pages) do
		if not help_page.back then
			pshy.help_pages["other"].subpages[page_name] = help_page
		end
	end
	pshy.help_pages["pshy"].subpages["other"] = pshy.help_pages["other"]
	-- all page
	pshy.help_pages["all"] = {title = "All Pages", subpages = {}}
	for page_name, help_page in pairs(pshy.help_pages) do
		pshy.help_pages["all"].subpages[page_name] = help_page
	end
	pshy.help_pages["pshy"].subpages["all"] = pshy.help_pages["all"]
end
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_emoticons.lua")
function new_mod.Content()
--- pshy_emoticons.lua
--
-- Adds emoticons you can use with SHIFT and ALT.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @require pshy_commands.lua
-- @require pshy_help.lua
-- @require pshy_perms.lua
-- @require pshy_utils.lua
pshy = pshy or {}
--- Module Help Page:
pshy.help_pages["pshy_emoticons"] = {back = "pshy", title = "Emoticons", text = "Adds custom emoticons\nUse the numpad numbers to use them. You may also use ALT or CTRL for more emoticons.\nThanks to <ch>Nnaaaz#0000</ch>\nIncludes emoticons from <ch>Feverchild#0000</ch>\nIncludes emoticons from <ch>Rchl#3416</ch>\nThanks to <ch>Sky#1999</ch>\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_emoticons"] = pshy.help_pages["pshy_emoticons"]
--- Module Settings:
pshy.perms.everyone["emoticons"] = true		-- allow everybody to use emoticons
pshy.emoticons_mod1 = 18 					-- alternative emoji modifier key 1 (18 == ALT)
pshy.emoticons_mod2 = 17 					-- alternative emoji modifier key 2 (17 == CTRL)
pshy.emoticons = {}							-- list of available emoticons (image -> code, x/y -> top left location, sx/sy -> scale)
-- unknown author, https://atelier801.com/topic?f=6&t=894050&p=1#m16
pshy.emoticons["unknown_vomit"]			= {image = "16f56cbc4d7.png", x = -15, y = -60} 
pshy.emoticons["unknown_cry"]			= {image = "17088661168.png", x = -15, y = -60}
pshy.emoticons["unknown_rogue"]			= {image = "16f5d8c7401.png", x = -15, y = -60}
pshy.emoticons["unknown_happycry"]		= {image = "16f56ce925e.png", x = -15, y = -60}
pshy.emoticons["unknown_wonder"]		= {image = "16f56cdf28f.png", x = -15, y = -60}
pshy.emoticons["unknown_happycry2"]		= {image = "16f56d09dc2.png", x = -15, y = -60}
-- vanilla-like, unknown author
pshy.emoticons["vanlike_novoice"]		= {image = "178ea94a353.png", x = -16, y = -60, sx = 0.9, sy = 0.9}
pshy.emoticons["vanlike_vomit"]			= {image = "178ea9d3ff4.png", x = -17, y = -61, sx = 0.92, sy = 0.92}
pshy.emoticons["vanlike_bigeyes"]		= {image = "178ea9d5bc3.png", x = -16, y = -60, sx = 0.9, sy = 0.9}
pshy.emoticons["vanlike_pinklove"]		= {image = "178ea9d7876.png", x = -16, y = -60, sx = 0.9, sy = 0.9}
pshy.emoticons["vanlike_eyelove"]		= {image = "178ea9d947c.png", x = -16, y = -60, sx = 0.9, sy = 0.9}
-- drawing, unknown author
pshy.emoticons["drawing_zzz"]			= {image = "178eac181f1.png", x = -16, y = -60, sx = 0.9, sy = 0.9}
-- rchl#0000, perm obtained
pshy.emoticons["rchl_glasses1"]			= {image = "178ebdf194a.png", x = -16, y = -62, sx = 0.9, sy = 0.9}
pshy.emoticons["rchl_glasses2"]			= {image = "178ebdf317a.png", x = -16, y = -62, sx = 0.9, sy = 0.9}
pshy.emoticons["rchl_clown"]			= {image = "178ebdf0153.png", x = -16, y = -62, sx = 0.9, sy = 0.9}
pshy.emoticons["rchl_sad"]				= {image = "178ebdf495d.png", x = -16, y = -62, sx = 0.9, sy = 0.9}
pshy.emoticons["rchl_vomit"]			= {image = "178ebdee617.png", x = -16, y = -62, sx = 0.9, sy = 0.9}
pshy.emoticons["rchl_sad2"]				= {image = "17aa125e853.png", x = -16, y = -62, sx = 0.65, sy = 0.65}
-- feverchild#0000, perm obtained, https://discord.com/channels/246815328103825409/522398576706322454/834007372640419851
pshy.emoticons["feverchild_zzz"]		= {image = "17aa1265ea4.png", x = -17, y = -64, sx = 0.61, sy = 0.61}
pshy.emoticons["feverchild_novoice"]	= {image = "17aa1264731.png", x = -17, y = -64, sx = 0.61, sy = 0.61}
-- Nnaaaz#0000, request
pshy.emoticons["pro"]					= {image = "17aa1bcf1d4.png", x = -20, y = -70, sx = 1, sy = 1, keep = true}
pshy.emoticons["pro2"]					= {image = "17aa1bd0944.png", x = -20, y = -70, sx = 1, sy = 1, keep = true}
pshy.emoticons["noob"]					= {image = "17aa1bd3a05.png", x = -30, y = -60, sx = 1, sy = 1, keep = true}
pshy.emoticons["noob2"]					= {image = "17aa1bd20b5.png", x = -30, y = -60, sx = 1, sy = 1, keep = true}
-- other https://atelier801.com/topic?f=6&t=827044&p=1#m14
pshy.emoticons["WTF_cat"]				= {image = "15565dbc655.png", x = -15, y = -65, sx = 0.75, sy = 0.75}
pshy.emoticons["FUUU"]					= {image = "15568238225.png", x = -15, y = -60, sx = 0.75, sy = 0.75}
pshy.emoticons["me_gusta"]				= {image = "155682434d5.png", x = -15, y = -60, sx = 0.75, sy = 0.75}
pshy.emoticons["trollface"]				= {image = "1556824ac1a.png", x = -15, y = -60, sx = 0.75, sy = 0.75}
pshy.emoticons["cheese_right"]			= {image = "155592fd7d0.png", x = -15, y = -55, sx = 0.50, sy = 0.50}
pshy.emoticons["cheese_left"]			= {image = "155593003fc.png", x = -15, y = -55, sx = 0.50, sy = 0.50}
-- unknown
pshy.emoticons["mario_left"]			= {image = "156d7dafb2d.png", x = -25, y = -35, sx = 1, sy = 1, replace = true}
pshy.emoticons["mario_right"]			= {image = "156d7dafb2d.png", x = 25, y = -35, sx = -1, sy = 1, replace = true}
-- emoticons / index is (key_number + (100 * mod1) + (200 * mod2)) for up to 40 emoticons with only the numbers, ctrl and alt, including the defaults
pshy.emoticons_binds = {}	
pshy.emoticons_binds[101] = "vanlike_pinklove"
pshy.emoticons_binds[102] = "unknown_cry"
pshy.emoticons_binds[103] = "unknown_rogue"
pshy.emoticons_binds[104] = "feverchild_zzz"
pshy.emoticons_binds[105] = "unknown_happycry"
pshy.emoticons_binds[106] = nil
pshy.emoticons_binds[107] = "unknown_wonder"
pshy.emoticons_binds[108] = "rchl_sad2"
pshy.emoticons_binds[109] = "unknown_happycry2"
pshy.emoticons_binds[100] = "unknown_vomit"
pshy.emoticons_binds[201] = "rchl_glasses1"
pshy.emoticons_binds[202] = "rchl_sad"
pshy.emoticons_binds[203] = "vanlike_bigeyes"
pshy.emoticons_binds[204] = "rchl_glasses2"
pshy.emoticons_binds[205] = "vanlike_eyelove"
pshy.emoticons_binds[206] = "rchl_clown"
pshy.emoticons_binds[207] = "vanlike_novoice"
pshy.emoticons_binds[208] = "drawing_zzz"
pshy.emoticons_binds[209] = "feverchild_novoice"
pshy.emoticons_binds[200] = "rchl_vomit"
pshy.emoticons_binds[301] = nil
pshy.emoticons_binds[302] = nil
pshy.emoticons_binds[303] = nil
pshy.emoticons_binds[304] = "FUUU"
pshy.emoticons_binds[305] = "me_gusta"
pshy.emoticons_binds[306] = "trollface"
pshy.emoticons_binds[307] = nil
pshy.emoticons_binds[308] = "WTF_cat"
pshy.emoticons_binds[309] = nil
pshy.emoticons_binds[300] = nil
-- @todo 30 available slots in total :>
-- Internal Use:
pshy.emoticons_players_mod2 = {}				-- shift keys state
pshy.emoticons_players_mod1 = {}				-- alt keys state
pshy.emoticons_last_loop_time = 0				-- last loop time
pshy.emoticons_players_image_ids = {}			-- the emote id started by the player
pshy.emoticons_players_emoticon = {}			-- the current emoticon of players
pshy.emoticons_players_end_times = {}			-- time at wich players started an emote / NOT DELETED
--- Listen for a players modifiers:
function pshy.EmoticonsBindPlayerKeys(player_name)
	system.bindKeyboard(player_name, pshy.emoticons_mod1, true, true)
	system.bindKeyboard(player_name, pshy.emoticons_mod1, false, true)
	system.bindKeyboard(player_name, pshy.emoticons_mod2, true, true)
	system.bindKeyboard(player_name, pshy.emoticons_mod2, false, true)
	for number = 0, 9 do -- numbers
		system.bindKeyboard(player_name, 48 + number, true, true)
	end
	for number = 0, 9 do -- numpad numbers
		system.bindKeyboard(player_name, 96 + number, true, true)
	end
end
--- Stop an imoticon from playing over a player.
function pshy.EmoticonsStop(player_name)
	if pshy.emoticons_players_image_ids[player_name] then
		tfm.exec.removeImage(pshy.emoticons_players_image_ids[player_name])
	end
	pshy.emoticons_players_end_times[player_name] = nil
	pshy.emoticons_players_image_ids[player_name] = nil
	pshy.emoticons_players_emoticon[player_name] = nil
end
--- Get an emoticon from name or bind index.
function pshy.EmoticonsGetEmoticon(emoticon)
	if type(emoticon) == "number" then
		emoticon = pshy.emoticons_binds[emoticon]
	end
	if type(emoticon) == "string" then
		emoticon = pshy.emoticons[emoticon]
	end
	return emoticon
end
--- Play an emoticon over a player.
-- Also removes the current one if being played.
-- Does nothing if the emoticon is invalid
-- @param player_name The name of the player.
-- @param emoticon Emoticon table, bind index, or name.
-- @param end_time Optional end time (relative to the current round).
function pshy.EmoticonsPlay(player_name, emoticon, end_time)
	end_time = end_time or pshy.emoticons_last_loop_time + 4500
	if type(emoticon) ~= "table" then
		emoticon = pshy.EmoticonsGetEmoticon(emoticon)
	end
	if not emoticon then
		if pshy.emoticons_players_emoticon[player_name] and not pshy.emoticons_players_emoticon[player_name].keep then
			pshy.EmoticonsStop(player_name)
		end
		return
	end
	if pshy.emoticons_players_emoticon[player_name] ~= emoticon then
		if pshy.emoticons_players_image_ids[player_name] then
			tfm.exec.removeImage(pshy.emoticons_players_image_ids[player_name])
		end
		pshy.emoticons_players_image_ids[player_name] = tfm.exec.addImage(emoticon.image, (emoticon.replace and "%" or "$") .. player_name, emoticon.x, emoticon.y, nil, emoticon.sx or 1, emoticon.sy or 1)
		pshy.emoticons_players_emoticon[player_name] = emoticon
	end
	pshy.emoticons_players_end_times[player_name] = end_time
end
--- TFM event eventNewGame
function eventNewGame()
	local timeouts = {}
	for player_name, end_time in pairs(pshy.emoticons_players_end_times) do
		timeouts[player_name] = true
	end
	for player_name in pairs(timeouts) do
		pshy.EmoticonsStop(player_name)
	end
	pshy.emoticons_last_loop_time = 0
end
--- TFM event eventLoop
function eventLoop(time, time_remaining)
	local timeouts = {}
	for player_name, end_time in pairs(pshy.emoticons_players_end_times) do
		if end_time < time then
			timeouts[player_name] = true
		end
	end
	for player_name in pairs(timeouts) do
		pshy.EmoticonsStop(player_name)
	end
	pshy.emoticons_last_loop_time = time
end
--- TFM event eventKeyboard
function eventKeyboard(player_name, key_code, down, x, y)
	if not pshy.HavePerm(player_name, "emoticons") then
		return
	end
	if key_code == pshy.emoticons_mod1 then
		pshy.emoticons_players_mod1[player_name] = down
	elseif key_code == pshy.emoticons_mod2 then
		pshy.emoticons_players_mod2[player_name] = down
	elseif key_code >= 48 and key_code < 58 then -- numbers
		local index = (key_code - 48) + (pshy.emoticons_players_mod1[player_name] and 100 or 0) + (pshy.emoticons_players_mod2[player_name] and 200 or 0)
		pshy.emoticons_players_emoticon[player_name] = nil -- todo sadly, native emoticons will always replace custom ones
		pshy.EmoticonsPlay(player_name, index, pshy.emoticons_last_loop_time + 4500)
	elseif key_code >= 96 and key_code < 106 then -- numpad numbers
		local index = (key_code - 96) + (pshy.emoticons_players_mod2[player_name] and 200 or (pshy.emoticons_players_mod1[player_name] and 300 or 100))
		pshy.emoticons_players_emoticon[player_name] = nil -- todo sadly, native emoticons will always replace custom ones
		pshy.EmoticonsPlay(player_name, index, pshy.emoticons_last_loop_time + 4500)
	end
end
--- TFM event eventNewPlayer
function eventNewPlayer(player_name)
	pshy.EmoticonsBindPlayerKeys(player_name)
end
--- !emoticon <name>
function pshy.ChatCommandEmoticon(user, emoticon_name, target)
	if not target then
		target = user
	elseif not pshy.HavePerm(user, "!emoticon-others") then
		error("You are not allowed to use this command on others :c")
		return
	elseif not tfm.get.room.playerList[target] then
		error("This player is not in the room.")
		return
	end
	pshy.EmoticonsPlay(target, emoticon_name, pshy.emoticons_last_loop_time + 4500)
end
pshy.chat_commands["emoticon"] = {func = pshy.ChatCommandEmoticon, desc = "show an emoticon", argc_min = 1, argc_max = 2, arg_types = {"string", "player"}}
pshy.help_pages["pshy_emoticons"].commands["emoticon"] = pshy.chat_commands["emoticon"]
pshy.chat_command_aliases["em"] = "emoticon"
pshy.perms.everyone["!emoticon"] = true
pshy.perms.admins["!emoticon-others"] = true
--- Initialization:
for player_name in pairs(tfm.get.room.playerList) do
	pshy.EmoticonsBindPlayerKeys(player_name)
end
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_fun_commands.lua")
function new_mod.Content()
--- pshy_fun_commands.lua
--
-- Adds fun commands everyone can use.
-- Expected to be used in chill rooms, such as villages.
--
-- Disable cheat commands with `pshy.fun_commands_DisableCheatCommands()`.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
-- @require pshy_commands.lua
-- @require pshy_help.lua
-- @require pshy_perms.lua
--- Module Help Page:
pshy.help_pages["pshy_fun_commands"] = {back = "pshy", title = "Fun Commands", text = "Adds fun commands everyone can use.\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_fun_commands"] = pshy.help_pages["pshy_fun_commands"]
--- Internal use:
pshy.fun_commands_link_wishes = {}	-- map of player names requiring a link to another one
pshy.fun_commands_players_balloon_id = {}
--- Get the target of the command, throwing on permission issue.
-- @private
function pshy.fun_commands_GetTarget(user, target, perm_prefix)
	assert(type(perm_prefix) == "string")
	if not target then
		return user
	end
	if target == user then
		return user
	elseif not pshy.HavePerm(user, perm_prefix .. "-others") then
		error("you cant use this command on other players :c")
		return
	end
	return target
end
--- !shaman
function pshy.ChatCommandShaman(user, value, target)
	target = pshy.fun_commands_GetTarget(user, target, "!shaman")
	value = value or not tfm.get.room.playerList[target].isShaman
	tfm.exec.setShaman(target, value)
end
pshy.chat_commands["shaman"] = {func = pshy.ChatCommandShaman, desc = "switch you to a shaman", argc_min = 0, argc_max = 2, arg_types = {"bool", "player"}}
pshy.help_pages["pshy_fun_commands"].commands["shaman"] = pshy.chat_commands["shaman"]
pshy.perms.admins["!shaman"] = true
pshy.perms.admins["!shaman-others"] = true
--- !shamanmode
function pshy.ChatCommandShamanmode(user, mode, target)
	target = pshy.fun_commands_GetTarget(user, target, "!shamanmode")
	if mode ~= 0 and mode ~= 1 and mode ~= 2 then
		return false, "Mode must be 0 (normal), 1 (hard) or 2 (divine)."		
	end
	tfm.exec.setShaman(target, value)
end
pshy.chat_commands["shamanmode"] = {func = pshy.ChatCommandShamanmode, desc = "choose your shaman mode (0/1/2)", argc_min = 0, argc_max = 2, arg_types = {"number", "player"}}
pshy.help_pages["pshy_fun_commands"].commands["shamanmode"] = pshy.chat_commands["shamanmode"]
pshy.perms.admins["!shamanmode"] = true
pshy.perms.admins["!shamanmode-others"] = true
--- !vampire
function pshy.ChatCommandVampire(user, value, target)
	target = pshy.fun_commands_GetTarget(user, target, "!vampire")
	value = value or not tfm.get.room.playerList[target].isVampire
	tfm.exec.setVampirePlayer(target, value)
end
pshy.chat_commands["vampire"] = {func = pshy.ChatCommandVampire, desc = "switch you to a vampire", argc_min = 0, argc_max = 2, arg_types = {"bool", "player"}}
pshy.help_pages["pshy_fun_commands"].commands["vampire"] = pshy.chat_commands["vampire"]
pshy.perms.admins["!vampire"] = true
pshy.perms.admins["!vampire-others"] = true
--- !cheese
function pshy.ChatCommandCheese(user, value, target)
	target = pshy.fun_commands_GetTarget(user, target, "!cheese")
	value = value or not tfm.get.room.playerList[target].hasCheese
	if value then
		tfm.exec.giveCheese(target)
	else
		tfm.exec.removeCheese(target)
	end
end
pshy.chat_commands["cheese"] = {func = pshy.ChatCommandCheese, desc = "toggle your cheese", argc_min = 0, argc_max = 2, arg_types = {"bool", "player"}}
pshy.help_pages["pshy_fun_commands"].commands["cheese"] = pshy.chat_commands["cheese"]
pshy.perms.cheats["!cheese"] = true
pshy.perms.admins["!cheese-others"] = true
--- !win
function pshy.ChatCommandWin(user, target)
	target = pshy.fun_commands_GetTarget(user, target, "!win")
	tfm.exec.giveCheese(target)
	tfm.exec.playerVictory(target)
end
pshy.chat_commands["win"] = {func = pshy.ChatCommandWin, desc = "play the win animation", argc_min = 0, argc_max = 1, arg_types = {"player"}}
pshy.help_pages["pshy_fun_commands"].commands["win"] = pshy.chat_commands["win"]
pshy.perms.cheats["!win"] = true
pshy.perms.admins["!win-others"] = true
--- !kill
function pshy.ChatCommandKill(user, target)
	target = pshy.fun_commands_GetTarget(user, target, "!kill")
	if not tfm.get.room.playerList[target].isDead then
		tfm.exec.killPlayer(target)
	else
		tfm.exec.respawnPlayer(target)
	end
end
pshy.chat_commands["kill"] = {func = pshy.ChatCommandKill, desc = "kill or resurect yourself", argc_min = 0, argc_max = 1, arg_types = {"player"}}
pshy.help_pages["pshy_fun_commands"].commands["kill"] = pshy.chat_commands["kill"]
pshy.perms.cheats["!kill"] = true
pshy.perms.admins["!kill-others"] = true
--- !freeze
function pshy.ChatCommandFreeze(user, value, target)
	target = pshy.fun_commands_GetTarget(user, target, "!freeze")
	tfm.exec.freezePlayer(target, value)
end
pshy.chat_commands["freeze"] = {func = pshy.ChatCommandFreeze, desc = "freeze yourself", argc_min = 1, argc_max = 2, arg_types = {"bool", "player"}}
pshy.help_pages["pshy_fun_commands"].commands["freeze"] = pshy.chat_commands["freeze"]
pshy.perms.cheats["!freeze"] = true
pshy.perms.admins["!freeze-others"] = true
--- !size <n>
function pshy.ChatCommandSize(user, size, target)
	assert(size >= 0.2, "minimum size is 0.2")
	assert(size <= 5, "maximum size is 5")
	target = pshy.fun_commands_GetTarget(user, target, "!size")
	tfm.exec.changePlayerSize(target, size)
end 
pshy.chat_commands["size"] = {func = pshy.ChatCommandSize, desc = "change your size", argc_min = 1, argc_max = 2, arg_types = {"number", "player"}}
pshy.help_pages["pshy_fun_commands"].commands["size"] = pshy.chat_commands["size"]
pshy.perms.cheats["!size"] = true
pshy.perms.admins["!size-others"] = true
--- !namecolor
function pshy.ChatCommandNamecolor(user, color, target)
	target = pshy.fun_commands_GetTarget(user, target, "!namecolor")
	tfm.exec.setNameColor(target, color)
end 
pshy.chat_commands["namecolor"] = {func = pshy.ChatCommandNamecolor, desc = "change your name's color", argc_min = 1, argc_max = 2, arg_types = {nil, "player"}}
pshy.help_pages["pshy_fun_commands"].commands["namecolor"] = pshy.chat_commands["namecolor"]
pshy.perms.cheats["!namecolor"] = true
pshy.perms.admins["!namecolor-others"] = true
--- !action
function pshy.ChatCommandAction(user, action)
	tfm.exec.chatMessage("<v>" .. user .. "</v> <n>" .. action .. "</n>")
end 
pshy.chat_commands["action"] = {func = pshy.ChatCommandAction, desc = "send a rp-like/action message", argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_fun_commands"].commands["action"] = pshy.chat_commands["action"]
--- !balloon
function pshy.ChatCommandBalloon(user, target)
	target = pshy.fun_commands_GetTarget(user, target, "!balloon")
	if pshy.fun_commands_players_balloon_id[target] then
		tfm.exec.removeObject(pshy.fun_commands_players_balloon_id[target])
		pshy.fun_commands_players_balloon_id[target] = nil
	end
	pshy.fun_commands_players_balloon_id[target] = tfm.exec.attachBalloon(target, true, math.random(1, 4), true)
end 
pshy.chat_commands["balloon"] = {func = pshy.ChatCommandBalloon, desc = "attach a balloon to yourself", argc_min = 0, argc_max = 1, arg_types = {"player"}}
pshy.help_pages["pshy_fun_commands"].commands["balloon"] = pshy.chat_commands["balloon"]
pshy.perms.cheats["!balloon"] = true
pshy.perms.admins["!balloon-others"] = true
--- !link
function pshy.ChatCommandLink(user, wish, target)
	target = pshy.fun_commands_GetTarget(user, target, "!link")
	if wish == "off" then
		tfm.exec.linkMice(target, target, false)
		return
	else
		wish = pshy.FindPlayerNameOrError(wish)
		pshy.fun_commands_link_wishes[target] = wish
	end
	if wish == target then
		tfm.exec.linkMice(target, wish, false)
	elseif pshy.fun_commands_link_wishes[wish] == target or user ~= target then
		tfm.exec.linkMice(target, wish, true)
	end
end 
pshy.chat_commands["link"] = {func = pshy.ChatCommandLink, desc = "attach yourself to another player (yourself to stop)", argc_min = 1, argc_max = 2, arg_types = {"player", "player"}}
pshy.help_pages["pshy_fun_commands"].commands["link"] = pshy.chat_commands["link"]
pshy.perms.cheats["!link"] = true
pshy.perms.admins["!link-others"] = true
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_lua_commands.lua")
function new_mod.Content()
--- Pshy basic commands module
--
-- This submodule add the folowing commands:
--   !(lua)get <path.to.variable>					- get a lua value
--   !(lua)set <path.to.variable> <new_value>		- set a lua value
--   !(lua)setstr <path.to.variable> <new_value>	- set a lua string value
--   !(lua)call <path.to.function> [args...]		- call a lua function
--
-- To give an idea of what this module makes possible, these commands are valid:
--	!luacall tfm.exec.explosion tfm.get.room.playerList.Pshy#3752.x tfm.get.room.playerList.Pshy#3752.y 10 10 true
--	!luacall tfm.exec.addShamanObject littleBox 200 300 0 0 0 false
--	!luacall tfm.exec.addShamanObject ball tfm.get.room.playerList.Pshy#3752.x tfm.get.room.playerList.Pshy#3752.y 0 0 0 false
--
-- Additionally, this add a command per function in tfm.exec.
--
-- @author Pshy
-- @hardmerge
-- @require pshy_commands.lua
-- @require pshy_help.lua
-- @require pshy_utils.lua
--- Module Help Page:
pshy.help_pages["pshy_lua_commands"] = {back = "pshy", title = "Lua Commands", text = "Commands to interact with lua.\n"}
pshy.help_pages["pshy_lua_commands"].commands = {}
pshy.help_pages["pshy"].subpages["pshy_lua_commands"] = pshy.help_pages["pshy_lua_commands"]
--- Internal Use:
pshy.rst1 = nil		-- store the first return of !call
pshy.rst2 = nil		-- store the second result of !call
--- !luaget <path.to.object>
-- Get the value of a lua object.
function pshy.ChatCommandLuaget(user, obj_name)
	assert(type(obj_name) == "string")
	local obj = pshy.LuaGet(obj_name)
	local result
	if type(obj) == "string" then
		result = obj_name .. " == \"" .. tostring(obj) .. "\""
	elseif type(obj) == "table" then
		result = "{"
		local cnt = 0
		for key, value in pairs(obj) do
			result = result .. ((cnt > 0) and "," or "") .. tostring(key)
			cnt = cnt + 1
			if cnt >= 16 then
				result = result .. ",[...]"
				break
			end
		end
		result = result .. "}"
	else
		result = obj_name .. " == " .. tostring(obj)
	end
	tfm.exec.chatMessage(result, user)
end
pshy.chat_commands["luaget"] = {func = pshy.ChatCommandLuaget, desc = "get a lua object value", argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.chat_command_aliases["get"] = "luaget"
pshy.help_pages["pshy_lua_commands"].commands["luaget"] = pshy.chat_commands["luaget"]
pshy.perms.admins["!luaget"] = true
--- !luaset <path.to.object> <new_value>
-- Set the value of a lua object.
function pshy.ChatCommandLuaset(user, obj_path, obj_value)
	pshy.LuaSet(obj_path, pshy.AutoType(obj_value))
	pshy.ChatCommandLuaget(user, obj_path)
end
pshy.chat_commands["luaset"] = {func = pshy.ChatCommandLuaset, desc = "set a lua object value", argc_min = 2, argc_max = 2, arg_types = {"string", "string"}}
pshy.chat_command_aliases["set"] = "luaset"
pshy.help_pages["pshy_lua_commands"].commands["luaset"] = pshy.chat_commands["luaset"]
--- !luasetstr <path.to.object> <new_value>
-- Set the string value of a lua object.
function pshy.ChatCommandLuasetstr(user, obj_path, obj_value)
	obj_value = string.gsub(string.gsub(obj_value, "&lt;", "<"), "&gt;", ">")
	pshy.LuaSet(obj_path, obj_value)
	pshy.ChatCommandLuaget(user, obj_path)
end
pshy.chat_commands["luasetstr"] = {func = pshy.ChatCommandLuasetstr, desc = "set a lua object string (support html)", argc_min = 2, argc_max = 2, arg_types = {"string", "string"}}
pshy.chat_command_aliases["setstr"] = "luaset"
pshy.help_pages["pshy_lua_commands"].commands["luasetstr"] = pshy.chat_commands["luasetstr"]
--- !luacall <path.to.function> [args...]
-- Call a lua function.
-- @todo use variadics and put the feature un pshy_utils?
function pshy.ChatCommandLuacall(user, funcname, ...)
	local func = pshy.LuaGet(funcname)
	assert(type(func) ~= "nil", "function not found")
	assert(type(func) == "function", "a function name was expected")
	pshy.rst1, pshy.rst2 = func(...)
	tfm.exec.chatMessage(funcname .. " returned " .. tostring(pshy.rst1) .. ", " .. tostring(pshy.rst2), user)
end
pshy.chat_commands["luacall"] = {func = pshy.ChatCommandLuacall, desc = "run a lua function with given arguments", argc_min = 1, arg_types = {"string"}}
pshy.chat_command_aliases["call"] = "luacall"
pshy.help_pages["pshy_lua_commands"].commands["luacall"] = pshy.chat_commands["luacall"]
--- !rejoin [player]
-- Simulate a rejoin.
function pshy.ChatCommandRejoin(user, target)
	target = target or user
	tfm.exec.killPlayer(target)
	eventPlayerLeft(target)
	eventNewPlayer(target)
end
pshy.chat_commands["rejoin"] = {func = pshy.ChatCommandRejoin, desc = "simulate a rejoin (events left + join + died)", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_lua_commands"].commands["rejoin"] = pshy.chat_commands["rejoin"]
pshy.perms.admins["!rejoin"] = true
--- !runas command
-- Run a command as another player (use the other player's permissions).
function pshy.ChatCommandRunas(player_name, target_player, command)
	pshy.Log(player_name .. " running as " .. target_player .. ": " .. command)
	pshy.RunChatCommand(target, command)
end
pshy.chat_commands["runas"] = {func = pshy.ChatCommandRunas, desc = "run a command as another player", argc_min = 2, argc_max = 2, arg_types = {"string", "string"}}
pshy.help_pages["pshy_lua_commands"].commands["runas"] = pshy.chat_commands["runas"]
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_mapdb.lua")
function new_mod.Content()
--- pshy_mapdb.lua
--
-- Handle advanced map features and rotations.
-- Override `tfm.exec.newGame` for easy usage.
--
-- This script may list maps from other authors.
--
-- Listed map and rotation tables can have the folowing fields:
--	- begin_func: Function to run when the map started.
--	- end_func: Function to run when the map stopped.
--	- replace_func: Function to run on the map's xml (or name if not present) that is supposed to return the final xml.
--	- autoskip: If true, the map will change at the end of the timer.
--	- duration: Duration of the map.
--	- xml (maps only): The true map's xml code.
--	- hidden (rotations only): Do not show the rotation is being used to players.
--	- modules: list of module names to enable while the map is playing (to trigger events).
--
-- @author: TFM:Pshy#3752 DC:Pshy#7998 (script)
-- @require pshy_commands.lua
-- @require pshy_help.lua
-- @require pshy_rotation.lua
--- Module Help Page:
pshy.help_pages["pshy_mapdb"] = {back = "pshy", title = "Maps / Rotations", text = "Includes maps from <ch>Nnaaaz#0000</ch>\nIncludes maps from <ch>Pshy#3752</ch>\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_mapdb"] = pshy.help_pages["pshy_mapdb"]
--- Module Settings:
pshy.mapdb_default = "default"			-- default rotation, can be a rotation of rotations
pshy.mapdb_maps = {}					-- map of maps
pshy.mapdb_rotations = {}				-- map of rotations
pshy.mapdb_rotations["default"]			= {hidden = true, items = {}}					-- default rotation, can only use other rotations, no maps
pshy.mapdb_default_rotation 			= pshy.mapdb_rotations["default"]				--
--- Rotations.
-- Basics:
pshy.mapdb_rotations["vanilla"]						= {hidden = true, desc = "0-210", duration = 120, items = {}} for i = 0, 210 do table.insert(pshy.mapdb_rotations["vanilla"].items, i) end
pshy.mapdb_rotations["nosham_vanilla"]				= {desc = "0-210*", duration = 60, items = {"2", "8", "11", "12", "14", "19", "22", "24", "26", "27", "28", "30", "31", "33", "40", "41", "44", "45", "49", "52", "53", "55", "57", "58", "59", "61", "62", "65", "67", "69", "70", "71", "73", "74", "79", "80", "85", "86", "89", "92", "96", "100", "117", "119", "120", "121", "123", "126", "127", "138", "142", "145", "148", "149", "150", "172", "173", "174", "175", "176", "185", "189"}}
pshy.mapdb_rotations["standard"]					= {desc = "P0", duration = 120, items = {"#0"}}
pshy.mapdb_rotations["protected"]					= {desc = "P1", duration = 120, items = {"#1"}}
pshy.mapdb_rotations["mechanisms"]					= {desc = "P6", duration = 120, items = {"#6"}}
pshy.mapdb_rotations["nosham"]						= {desc = "P7", duration = 60, items = {"#7"}}
pshy.mapdb_rotations["racing"]						= {desc = "P17", duration = 60, items = {"#17"}}
pshy.mapdb_rotations["defilante"]					= {desc = "P18", duration = 60, items = {"#18"}}
-- Pshy#3752
pshy.mapdb_rotations["pshy_vanilla_nosham_troll"]	= {hidden = true, desc = "Pshy#3752's maps", duration = 60, items = {"@7871137", "@7871139", "@7871138", "@7871140", "@7871142", "@7871141", "@7871143", "@7871144", "@7871145", "@7871146", "@7871152", "@7871149", "@7871148", "@7871147", "@7871154", "@7871160", "@7871158", "@7871136"}}
pshy.mapdb_rotations["pshy_vanilla_sham_troll"]		= {hidden = true, desc = "Pshy#3752's maps", duration = 60, items = {"@7871134", "@7871157", "@7871155"}}
pshy.mapdb_rotations["pshy_nosham_troll"]			= {hidden = true, desc = "Pshy#3752's maps", duration = 60, items = {"@7840661", "@7871156", "@7871159", "@7871161"}}
pshy.mapdb_rotations["pshy_vanilla_troll"]			= {hidden = true, desc = "Pshy#3752's maps", duration = 120, items = {}}
for i_map, map in ipairs(pshy.mapdb_rotations["pshy_vanilla_nosham_troll"].items) do table.insert(pshy.mapdb_rotations["pshy_vanilla_troll"].items, map) end
for i_map, map in ipairs(pshy.mapdb_rotations["pshy_vanilla_sham_troll"].items) do table.insert(pshy.mapdb_rotations["pshy_vanilla_troll"].items, map) end
-- Nnaaaz#0000:
pshy.mapdb_rotations["nnaaaz_vanilla_nosham_troll"]	= {hidden = true, desc = "Nnaaaz#0000's maps", duration = 60, items = {"@7801848", "@7801850", "@7802588", "@7802592", "@7803100", "@7803618", "@7803013", "@7803900", "@7804144", "@7804211"}} -- https://atelier801.com/topic?f=6&t=892706&p=1
pshy.mapdb_rotations["nnaaaz_nosham_troll"]			= {hidden = true, desc = "Nnaaaz#0000's maps", duration = 60, items = {"@7781189", "@7781560", "@7782831", "@7783745", "@7787472", "@7814117", "@7814126", "@7814248", "@7814488", "@7817779"}}
pshy.mapdb_rotations["nnaaaz_racing_troll"]			= {hidden = true, desc = "Nnaaaz#0000's maps", duration = 60, items = {"@7781575", "@7783458", "@7783472", "@7784221", "@7784236", "@7786652", "@7786707", "@7786960", "@7787034", "@7788567", "@7788596", "@7788673", "@7788967", "@7788985", "@7788990", "@7789010", "@7789484", "@7789524", "@7790734", "@7790746", "@7790938", "@7791293", "@7791550", "@7791709", "@7791865", "@7791877", "@7792434", "@7765843", "@7794331", "@7794726", "@7792626", "@7794874", "@7795585", "@7796272", "@7799753", "@7800330", "@7800998", "@7801670", "@7805437", "@7792149", "@7809901", "@7809905", "@7810816", "@7812751", "@7789538", "@7813075", "@7813248", "@7814099", "@7819315", "@7815695", "@7815703", "@7816583", "@7816748", "@7817111", "@7782820"}}
-- Mix
pshy.mapdb_rotations["nosham_vanilla_troll"]		= {hidden = true, desc = "mix of troll maps", duration = 60, items = {}}
for i_map, map in ipairs(pshy.mapdb_rotations["pshy_vanilla_nosham_troll"].items) do table.insert(pshy.mapdb_rotations["nosham_vanilla_troll"].items, map) end
for i_map, map in ipairs(pshy.mapdb_rotations["nnaaaz_vanilla_nosham_troll"].items) do table.insert(pshy.mapdb_rotations["nosham_vanilla_troll"].items, map) end
pshy.mapdb_rotations["nosham_troll"]				= {hidden = true, desc = "mix of troll maps", duration = 60, items = {}}
for i_map, map in ipairs(pshy.mapdb_rotations["pshy_nosham_troll"].items) do table.insert(pshy.mapdb_rotations["nosham_troll"].items, map) end
for i_map, map in ipairs(pshy.mapdb_rotations["nnaaaz_nosham_troll"].items) do table.insert(pshy.mapdb_rotations["nosham_troll"].items, map) end
-- Misc:
pshy.mapdb_rotations["nosham_mechanisms"]			= {desc = nil, duration = 60, items = {"@1919402", "@7264140", "@7063481", "@1749725", "@176936", "@3514715", "@3150249", "@3506224", "@2030030", "@479001", "@3537313", "@1709809", "@169959", "@313281", "@2868361", "@73039", "@73039", "@2913703", "@2789826", "@298802", "@357666", "@1472765", "@271283", "@3702177", "@2355739", "@4652835", "@164404", "@7273005", "@3061566", "@3199177", "@157312", "@7021280", "@2093284", "@5752223", "@7070948", "@3146116", "@3613020", "@1641262", "@119884", "@3729243", "@1371302", "@6854109", "@2964944", "@3164949", "@149476", "@155262", "@6196297", "@1789012", "@422271", "@3369351", "@3138985", "@3056261", "@5848606", "@931943", "@181693", "@227600", "@2036283", "@6556301", "@3617986", "@314416", "@3495556", "@3112905", "@1953614", "@2469648", "@3493176", "@1009321", "@221535", "@2377177", "@6850246", "@5761423", "@211171", "@1746400", "@1378678", "@246966", "@2008933", "@2085784", "@627958", "@1268022", "@2815209", "@1299248", "@6883670", "@3495694", "@4678821", "@2758715", "@1849769", "@3155991", "@6555713", "@3477737", "@873175", "@141224", "@2167410", "@2629289", "@2888435", "@812822", "@4114065", "@2256415", "@3051008", "@7300333", "@158813", "@3912665", "@6014154", "@163756", "@3446092", "@509879", "@2029308", "@5546337", "@1310605", "@1345662", "@2421802", "@2578335", "@2999901", "@6205570", "@7242798", "@756418", "@2160073", "@3671421", "@5704703", "@3088801", "@7092575", "@3666756", "@3345115", "@1483745", "@3666745", "@2074413", "@2912220", "@3299750"}}
pshy.mapdb_rotations["nosham_simple"]				= {desc = nil, duration = 120, items = {"@1378332", "@485523", "@7816865", "@763608", "@1616913", "@383202", "@2711646", "@446656", "@815716", "@333501", "@7067867", "@973782", "@763961", "@7833293", "@7833270", "@7833269", "@7815665", "@7815151", "@7833288", "@1482492", "@1301712", "@6714567", "@834490", "@712905", "@602906", "@381669", "@4147040", "@564413", "@504951", "@1345805", "@501364"}} -- soso @1356823 @2048879 @2452915 @2751980
pshy.mapdb_rotations["nosham_traps"]				= {desc = nil, duration = 120, items = {"@297063", "@5940448", "@2080757", "@7453256", "@203292", "@108937", "@445078", "@133916", "@7840661", "@115767", "@2918927", "@4684884", "@2868361", "@192144", "@73039", "@1836340", "@726048"}}
pshy.mapdb_rotations["nosham_coop"]					= {desc = nil, duration = 120, items = {"@169909", "@209567", "@273077", "@7485555", "@2618581", "@133916", "@144888", "@1991022", "@7247621", "@3591685", "@6437833", "@3381659", "@121043", "@180468", "@220037", "@882270", "@3265446"}}
-- vanillart? @3624983 @2958393 @624650 @635128 @510084 @7404832 @3463369 @3390119
-- coop ?:		@1327222 @161177 @3147926 @3325842 @4722827
-- troll traps:	@75050 @923485
-- sham troll: @3659540 @6584338
-- almost vanilla sham: @3688504 @2013190 @1466862 @1280404 @2527971 @389123
-- lol: @7466942 @696995 @4117469
-- almost lol: @7285161 @1408189 @6827968
-- sham traps: @171290 @453115 @323597
-- @949687 ?
--- Internal Use:
pshy.mapdb_current_map_name = nil
pshy.mapdb_current_map = nil
pshy.mapdb_current_map_autoskip = false
pshy.mapdb_current_map_duration = 60
pshy.mapdb_current_map_begin_funcs = {}
pshy.mapdb_current_map_end_funcs = {}
pshy.mapdb_current_map_replace_func = nil
pshy.mapdb_current_map_modules = {}			-- list of module names enabled for the map that needs to be disabled
pshy.mapdb_event_new_game_triggered = false
pshy.mapdb_next = nil
pshy.mapdb_force_next = false
pshy.mapdb_current_rotations_names = {}		-- set rotation names we went by when choosing the map
--- Set the next map
-- @param code Map code.
-- @param force Should the map be forced (even if another map is chosen).
function pshy.mapdb_SetNextMap(code, force)
	pshy.mapdb_next = code
	pshy.mapdb_force_next = force or false
end
--- TFM.exec.newGame override.
-- @private
-- @brief mapcode Either a map code or a map rotation code.
function pshy.mapdb_newGame(mapcode)
	pshy.mapdb_EndMap()
	pshy.mapdb_event_new_game_triggered = false
	return pshy.mapdb_Next(mapcode)
end
pshy.mapdb_tfm_newGame = tfm.exec.newGame
tfm.exec.newGame = pshy.mapdb_newGame
--- End the previous map.
-- @private
-- @param abort true if the map have not even been started.
function pshy.mapdb_EndMap(abort)
	if not abort then
		for i_func, end_func in ipairs(pshy.mapdb_current_map_end_funcs) do
			end_func(pshy.mapdb_current_map_name)
		end
	end
	pshy.mapdb_current_map_name = nil
	pshy.mapdb_current_map = nil
	pshy.mapdb_current_map_autoskip = nil
	pshy.mapdb_current_map_duration = nil
	pshy.mapdb_current_map_begin_funcs = {}
	pshy.mapdb_current_map_end_funcs = {}
	pshy.mapdb_current_map_replace_func = nil
	pshy.mapdb_current_rotations_names = {}
	pshy.merge_DisableModules(pshy.mapdb_current_map_modules)
	pshy.mapdb_current_map_modules = {}
end
--- Setup the next map (possibly a rotation), calling newGame.
-- @private
function pshy.mapdb_Next(mapcode)
	if mapcode == nil or pshy.mapdb_force_next then
		if pshy.mapdb_next then
			mapcode = pshy.mapdb_next
		else
			mapcode = pshy.mapdb_default
		end
	end
	pshy.mapdb_force_next = false
	pshy.mapdb_next = nil
	if pshy.mapdb_maps[mapcode] then
		return pshy.mapdb_NextDBMap(mapcode)
	end
	if pshy.mapdb_rotations[mapcode] then
		return pshy.mapdb_NextDBRotation(mapcode)
	end
	if tonumber(mapcode) then
		pshy.mapdb_current_map_name = mapcode
		pshy.merge_EnableModules(pshy.mapdb_current_map_modules)
		return pshy.mapdb_tfm_newGame(mapcode)
	end
	--if #mapcode > 32 then
	--	-- probably an xml
	--	return pshy.mapdb_tfm_newGame(mapcode)
	--end
	pshy.merge_EnableModules(pshy.mapdb_current_map_modules)
	return pshy.mapdb_tfm_newGame(mapcode)
end
--- Add custom settings to the next map.
-- @private
-- Some maps or map rotations have special settings.
-- This function handle both of them
function pshy.mapdb_AddCustomMapSettings(t)
	if t.autoskip ~= nil then
		pshy.mapdb_current_map_autoskip = t.autoskip 
	end
	if t.duration ~= nil then
		pshy.mapdb_current_map_duration = t.duration 
	end
	if t.begin_func ~= nil then
		table.insert(pshy.mapdb_current_map_begin_funcs, t.begin_func)
	end
	if t.end_func ~= nil then
		table.insert(pshy.mapdb_current_map_end_funcs, t.end_func)
	end
	if t.replace_func ~= nil then
		pshy.mapdb_current_map_replace_func = t.replace_func 
	end
	if t.modules then
		for i, module_name in pairs(t.modules) do
			table.insert(pshy.mapdb_current_map_modules, module_name)
		end
	end
end
--- pshy.mapdb_newGame but only for maps listed to this module.
-- @private
function pshy.mapdb_NextDBMap(map_name)
	local map = pshy.mapdb_maps[map_name]
	pshy.mapdb_AddCustomMapSettings(map)
	pshy.mapdb_current_map_name = map_name
	pshy.mapdb_current_map = map
	local map_xml
	if map.xml then
		map_xml = map.xml
	else
		map_xml = map_name
	end
	if pshy.mapdb_current_map_replace_func then
		map_xml = pshy.mapdb_current_map_replace_func(map.xml)
	end
	pshy.merge_EnableModules(pshy.mapdb_current_map_modules)
	return pshy.mapdb_tfm_newGame(map_xml)
end
--- pshy.mapdb_newGame but only for rotations listed to this module.
-- @private
function pshy.mapdb_NextDBRotation(rotation_name)
	if pshy.mapdb_current_rotations_names[rotation_name] then
		print("<r>/!\\ Cyclic map rotation! Going to nil!</r>")
		pshy.mapdb_EndMap(true)
		return pshy.mapdb_tfm_newGame(nil)
	end
	pshy.mapdb_current_rotations_names[rotation_name] = true
	local rotation = pshy.mapdb_rotations[rotation_name]
	pshy.mapdb_AddCustomMapSettings(rotation)
	pshy.mapdb_current_rotation_name = rotation_name
	pshy.mapdb_current_rotation = rotation
	local next_map_name = pshy.rotation_Next(rotation)
	return pshy.mapdb_Next(next_map_name)
end
--- TFM event eventNewGame.
function eventNewGame()
	if not pshy.mapdb_event_new_game_triggered then
		for i_func, begin_func in ipairs(pshy.mapdb_current_map_begin_funcs) do
			begin_func(pshy.mapdb_current_map_name)
		end
		if pshy.mapdb_current_map_duration then
			tfm.exec.setGameTime(pshy.mapdb_current_map_duration, true)
		end
	else
		-- tfm loaded a new map
		pshy.mapdb_EndMap()
	end
	pshy.mapdb_event_new_game_triggered = true
end
--- TFM event eventLoop.
-- Skip the map when the timer is 0.
function eventLoop(time, time_remaining)
	if pshy.mapdb_current_map_autoskip ~= false and time_remaining <= 0 and time > 3000 then
		tfm.exec.newGame(nil)
	end
end
--- !next [map]
function pshy.mapdb_ChatCommandNext(user, code, force)
	pshy.mapdb_SetNextMap(code, force)
end
pshy.chat_commands["next"] = {func = pshy.mapdb_ChatCommandNext, desc = "set the next map to play (no param to cancel)", argc_min = 0, argc_max = 2, arg_types = {"string", "bool"}, arg_names = {"mapcode", "force"}}
pshy.help_pages["pshy_mapdb"].commands["next"] = pshy.chat_commands["next"]
pshy.perms.admins["!next"] = true
pshy.commands_aliases["np"] = "next"
pshy.commands_aliases["npp"] = "next"
--- !skip [map]
function pshy.mapdb_ChatCommandSkip(user, code)
	pshy.mapdb_next = code or pshy.mapdb_next
	pshy.mapdb_force_next = false
	if not pshy.mapdb_next and #pshy.mapdb_default_rotation.items == 0 then
		return false, "First use !rotw to set the rotations you want to use (use !rots for a list)."
	end
	tfm.exec.newGame(pshy.mapdb_next)
end
pshy.chat_commands["skip"] = {func = pshy.mapdb_ChatCommandSkip, desc = "play a different map right now", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_mapdb"].commands["skip"] = pshy.chat_commands["skip"]
pshy.perms.admins["!skip"] = true
pshy.commands_aliases["map"] = "skip"
--- !rotations
function pshy.mapdb_ChatCommandRotations(user)
	pshy.Answer("Available rotations:", user)
	for rot_name, rot in pairs(pshy.mapdb_rotations) do
		if rot ~= pshy.mapdb_default_rotation then
			local count = pshy.TableCountValue(pshy.mapdb_default_rotation.items, rot_name)
			local s = ((count > 0) and "<vp>" or "<fc>")
			s = s .. ((count > 0) and ("<b> ⚖ " .. tostring(count) .. "</b> \t") or "  - \t\t") .. rot_name
			s = s .. ((count > 0) and "</vp>" or "</fc>")
			s = s ..  ": " .. tostring(rot.desc) .. " (" .. #rot.items .. "#)"
			tfm.exec.chatMessage(s, user)
		end
	end
end
pshy.chat_commands["rotations"] = {func = pshy.mapdb_ChatCommandRotations, desc = "list available rotations", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_mapdb"].commands["rotations"] = pshy.chat_commands["rotations"]
pshy.perms.admins["!rotations"] = true
pshy.chat_command_aliases["rots"] = "rotations"
--- !rotationweigth <name> <value>
function pshy.mapdb_ChatCommandRotw(user, rotname, w)
	if not pshy.mapdb_rotations[rotname] then
		return false, "Unknown rotation."
	end
	if rotname == "default" then
		return false, "It's not rotationception."
	end
	if w == nil then
		w = (pshy.TableCountValue(pshy.mapdb_default_rotation.items, rotname) ~= 0) and 0 or 1
	end
	if w < 0 then
		return false, "Use 0 to disable the rotation."
	end
	if w > 100 then
		return false, "The maximum weight is 100."
	end
	pshy.ListRemoveValue(pshy.mapdb_default_rotation.items, rotname)
	if w > 0 then
		for i = 1, w do
			table.insert(pshy.mapdb_default_rotation.items, rotname)
		end
	end
	pshy.rotation_Reset(pshy.mapdb_default_rotation)
end
pshy.chat_commands["rotationweigth"] = {func = pshy.mapdb_ChatCommandRotw, desc = "set a rotation's frequency weight", argc_min = 1, argc_max = 2, arg_types = {"string", "number"}}
pshy.help_pages["pshy_mapdb"].commands["rotationweigth"] = pshy.chat_commands["rotationweigth"]
pshy.perms.admins["!rotationweigth"] = true
pshy.chat_command_aliases["rotw"] = "rotationweigth"
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_scores.lua")
function new_mod.Content()
--- pshy_scores.lua
--
-- Provide customisable player scoring.
-- Adds an event "eventPlayerScore(player_name, points)".
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
-- @require pshy_commands.lua
-- @require pshy_utils.lua
-- @require pshy_ui.lua
-- @require pshy_help.lua
--- TFM Settings
tfm.exec.disableAutoScore(true)
--- Module Help Page.
pshy.help_pages["pshy_scores"] = {back = "pshy", title = "Scores", text = "This module allows to customize how players make score points.\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_scores"] = pshy.help_pages["pshy_scores"]
--- Module Settings.
pshy.scores_per_win = 0								-- points earned per wins
pshy.scores_per_first_wins = {}						-- points earned by the firsts to win
--pshy.scores_per_first_wins[1] = 1					-- points for the very first
pshy.scores_per_cheese = 0							-- points earned per cheese touched
pshy.scores_per_first_cheeses = {}					-- points earned by the firsts to touch the cheese
pshy.scores_per_death = 0							-- points earned by death
pshy.scores_per_first_deaths = {}					-- points earned by the very first to die
pshy.scores_survivors_win = false					-- this round is a survivor round (players win if they survive) (true or the points for surviving)
pshy.scores_ui_arbitrary_id = 2918					-- arbitrary ui id
pshy.scores_show = true								-- show stats for the map
pshy.scores_per_bonus = 0							-- points earned by gettings bonuses of id <= 0
pshy.scores_reset_on_leave = true					-- reset points on leave
--- Internal use.
pshy.scores = {}						-- total scores points per player
pshy.scores_firsts_win = {}				-- total firsts points per player
pshy.scores_round_wins = {}				-- current map's first wins
pshy.scores_round_cheeses = {}			-- current map's first cheeses
pshy.scores_round_deaths = {}			-- current map's first deathes
pshy.scores_round_ended = true			-- the round already ended (now counting survivors, or not counting at all)
pshy.scores_should_update_ui = false	-- if true, scores ui have to be updated
--- pshy event eventPlayerScore
-- Called when a player earned points according to the module configuration.
function eventPlayerScore(player_name, points)
	tfm.exec.setPlayerScore(player_name, pshy.scores[player_name], false)
end
--- Give points to a player
function pshy.ScoresAdd(player_name, points)
	pshy.scores[player_name] = pshy.scores[player_name] + points
	eventPlayerScore(player_name, points)
end
pshy.scores_Add = pshy.ScoresAdd
--- Give points to a player
function pshy.scores_Set(player_name, points)
	pshy.scores[player_name] = points
	tfm.exec.setPlayerScore(player_name, pshy.scores[player_name], false)
end
--- Update the top players scores ui
-- @player_name optional player who will see the changes
function pshy.ScoresUpdateRoundTop(player_name)
	if ((#pshy.scores_round_wins + #pshy.scores_round_cheeses + #pshy.scores_round_deaths) == 0) then
		return
	end
	local text = "<font size='10'><p align='left'>"
	if #pshy.scores_round_wins > 0 then
		text = text .. "<font color='#ff0000'><b> First Win: " .. pshy.scores_round_wins[1] .. "</b></font>\n"
	end
	if #pshy.scores_round_cheeses > 0 then
		text = text .. "<d><b> First Cheese: " .. pshy.scores_round_cheeses[1] .. "</b></d>\n"
	end
	if #pshy.scores_round_deaths > 0 then
		text = text .. "<bv><b> First Death: " .. pshy.scores_round_deaths[1] .. "</b></bv>\n"
	end
	text = text .. "</p></font>"
	local title = pshy.UICreate(text)
	title.id = pshy.scores_ui_arbitrary_id
	title.x = 810
	title.y = 30
	title.w = nil
	title.h = nil
	title.back_color = 0
	title.border_color = 0
	pshy.UIShow(title, player_name)
end
--- Reset a player scores
function pshy.ScoresResetPlayer(player_name)
	assert(type(player_name) == "string")
	pshy.scores[player_name] = 0
	pshy.scores_firsts_win[player_name] = 0
	tfm.exec.setPlayerScore(player_name, 0, false)
end
--- Reset all players scores
function pshy.ScoresResetPlayers()
	pshy.scores = {}
	for player_name, player in pairs(tfm.get.room.playerList) do
		pshy.ScoresResetPlayer(player_name)
	end
end
--- TFM event eventNewGame
function eventNewGame()
	pshy.scores_round_wins = {}
	pshy.scores_round_cheeses = {}
	pshy.scores_round_deaths = {}
	pshy.scores_round_ended = false
	pshy.scores_should_update_ui = false
	ui.removeTextArea(pshy.scores_ui_arbitrary_id, nil)
end
--- TFM event eventLoop
function eventLoop(time, time_remaining)
	-- update score if needed
	if pshy.scores_show and pshy.scores_should_update_ui then
		pshy.ScoresUpdateRoundTop()
		pshy.scores_should_update_ui = false
	end
	-- make players win at the end of survivor rounds
	if time_remaining < 1000 and pshy.scores_survivors_win ~= false then
		pshy.scores_round_ended = true
		for player_name, player in pairs(tfm.get.room.playerList) do
			tfm.giveCheese(player_name, true)
			tfm.playerVictory(player_name)
		end
	end
end
--- TFM event eventPlayerDied
function eventPlayerDied(player_name)
	if not pshy.scores_round_ended then
		local points = pshy.scores_per_death
		table.insert(pshy.scores_round_deaths, player_name)
		local rank = #pshy.scores_round_deaths
		if pshy.scores_per_first_deaths[rank] then
			points = points + pshy.scores_per_first_deaths[rank]
		end
		if points ~= 0 then
			pshy.ScoresAdd(player_name, points)
		end
	end
	pshy.scores_should_update_ui = true
end
--- TFM event eventPlayerGetCheese
function eventPlayerGetCheese(player_name)
	if not pshy.scores_round_ended then
		local points = pshy.scores_per_cheese
		table.insert(pshy.scores_round_cheeses, player_name)
		local rank = #pshy.scores_round_cheeses
		if pshy.scores_per_first_cheeses[rank] then
			points = points + pshy.scores_per_first_cheeses[rank]
		end
		if points ~= 0 then
			pshy.ScoresAdd(player_name, points)
		end
	end
	pshy.scores_should_update_ui = true
end
--- TFM event eventPlayerLeft
function eventPlayerLeft(player_name)
	if pshy.scores_reset_on_leave then
		pshy.scores[player_name] = 0
	end
end
--- TFM event eventPlayerWon
function eventPlayerWon(player_name, time_elapsed)
	local points = 0
	if pshy.scores_round_ended and pshy.scores_survivors_win ~= false then
		-- survivor round
		points = points + ((pshy.scores_survivors_win == true) and pshy.scores_per_win or pshy.scores_survivors_win)
	elseif not pshy.scores_round_ended then
		-- normal
		points = points + pshy.scores_per_win
		table.insert(pshy.scores_round_wins, player_name)
		local rank = #pshy.scores_round_wins
		if pshy.scores_per_first_wins[rank] then
			points = points + pshy.scores_per_first_wins[rank]
		end
		if rank == 1 then
			pshy.scores_firsts_win[player_name] = pshy.scores_firsts_win[player_name] + points
		end
	end
	if points ~= 0 then
		pshy.ScoresAdd(player_name, points)
	end
	pshy.scores_should_update_ui = true
end
--- TFM event eventPlayerBonusGrabbed
function eventPlayerBonusGrabbed(player_name, bonus_id)
	if pshy.scores_per_bonus ~= 0 then
		pshy.ScoresAdd(player_name, pshy.scores_per_bonus)
	end
end
--- TFM event eventNewPlayer
function eventNewPlayer(player_name)
	if not pshy.scores[player_name] then
		pshy.ScoresResetPlayer(player_name)
	else
		tfm.exec.setPlayerScore(player_name, pshy.scores[player_name], false)
	end
end
--- Initialization
pshy.ScoresResetPlayers()
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_tfm_commands.lua")
function new_mod.Content()
--- pshy_tfm_commands.lua
--
-- Adds commands to call basic tfm functions.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
-- @require pshy_commands.lua
-- @require pshy_help.lua
-- @require pshy_perms.lua
--- Module Help Page:
pshy.help_pages["pshy_tfm_commands"] = {back = "pshy", title = "TFM basic commands", text = "", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_tfm_commands"] = pshy.help_pages["pshy_tfm_commands"]
--- Internal use:
pshy.fun_commands_link_wishes = {}	-- map of player names requiring a link to another one
pshy.fun_commands_players_balloon_id = {}
--- !mapflipmode
function pshy.tfm_commands_ChatCommandMapflipmode(user, mapflipmode)
	tfm.exec.disableAutoNewGame(mapflipmode)
end 
pshy.chat_commands["mapflipmode"] = {func = pshy.tfm_commands_ChatCommandMapflipmode, desc = "Set TFM to use mirrored maps (yes/no or no param for default)", argc_min = 0, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_tfm_commands"].commands["mapflipmode"] = pshy.chat_commands["mapflipmode"]
pshy.perms.admins["!mapflipmode"] = true
--- !autonewgame
function pshy.tfm_commands_ChatCommandAutonewgame(user, autonewgame)
	autonewgame = autonewgame or true
	tfm.exec.disableAutoNewGame(not autonewgame)
end 
pshy.chat_commands["autonewgame"] = {func = pshy.tfm_commands_ChatCommandAutonewgame, desc = "enable (or disable) TFM automatic map changes", argc_min = 0, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_tfm_commands"].commands["autonewgame"] = pshy.chat_commands["autonewgame"]
pshy.perms.admins["!autonewgame"] = true
--- !autoshaman
function pshy.tfm_commands_ChatCommandAutoshaman(user, autoshaman)
	autoshaman = autoshaman or true
	tfm.exec.disableAutoShaman(not autoshaman)
end 
pshy.chat_commands["autoshaman"] = {func = pshy.tfm_commands_ChatCommandAutoshaman, desc = "enable (or disable) TFM automatic shaman choice", argc_min = 0, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_tfm_commands"].commands["autoshaman"] = pshy.chat_commands["autoshaman"]
pshy.perms.admins["!autoshaman"] = true
--- !shamanskills
function pshy.tfm_commands_ChatCommandShamanskills(user, shamanskills)
	shamanskills = shamanskills or true
	tfm.exec.disableAllShamanSkills(not shamanskills)
end 
pshy.chat_commands["shamanskills"] = {func = pshy.tfm_commands_ChatCommandShamanskills, desc = "enable (or disable) TFM shaman's skills", argc_min = 0, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_tfm_commands"].commands["shamanskills"] = pshy.chat_commands["shamanskills"]
pshy.perms.admins["!shamanskills"] = true
--- !time
function pshy.tfm_commands_ChatCommandTime(user, time)
	tfm.exec.setGameTime(time)
end 
pshy.chat_commands["time"] = {func = pshy.tfm_commands_ChatCommandTime, desc = "change the TFM clock's time", argc_min = 1, argc_max = 1, arg_types = {"number"}}
pshy.help_pages["pshy_tfm_commands"].commands["time"] = pshy.chat_commands["time"]
pshy.perms.admins["!time"] = true
--- !autotimeleft
function pshy.tfm_commands_ChatCommandAutotimeleft(user, autotimeleft)
	autotimeleft = autotimeleft or true
	tfm.exec.disableAutoTimeLeft(not autotimeleft)
end 
pshy.chat_commands["autotimeleft"] = {func = pshy.tfm_commands_ChatCommandAutotimeleft, desc = "enable (or disable) TFM automatic lowering of time", argc_min = 0, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_tfm_commands"].commands["autotimeleft"] = pshy.chat_commands["autotimeleft"]
pshy.perms.admins["!autotimeleft"] = true
--- !playerscore
function pshy.tfm_commands_ChatCommandPlayerscore(user, score, target)
	score = score or 0
	target = pshy.commands_GetTargetOrError(user, target, "!playerscore")
	tfm.exec.setPlayerScore(target, score, false)
end 
pshy.chat_commands["playerscore"] = {func = pshy.tfm_commands_ChatCommandPlayerscore, desc = "set the TFM score of a player in the scoreboard", argc_min = 0, argc_max = 2, arg_types = {"number", "player"}}
pshy.help_pages["pshy_tfm_commands"].commands["playerscore"] = pshy.chat_commands["playerscore"]
pshy.perms.admins["!playerscore"] = true
pshy.perms.admins["!colorpicker-others"] = true
--- !autoscore
function pshy.tfm_commands_ChatCommandAutoscore(user, autoscore)
	autoscore = autoscore or true
	tfm.exec.disableAutoScore(not autoscore)
end 
pshy.chat_commands["autoscore"] = {func = pshy.tfm_commands_ChatCommandAutoscore, desc = "enable (or disable) TFM score handling", argc_min = 0, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_tfm_commands"].commands["autoscore"] = pshy.chat_commands["autoscore"]
pshy.perms.admins["!autoscore"] = true
--- !afkdeath
function pshy.tfm_commands_ChatCommandAfkdeath(user, afkdeath)
	afkdeath = afkdeath or true
	tfm.exec.disableAutoAfkDeath(not afkdeath)
end 
pshy.chat_commands["afkdeath"] = {func = pshy.tfm_commands_ChatCommandAfkdeath, desc = "enable (or disable) TFM's killing of AFK players", argc_min = 0, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_tfm_commands"].commands["afkdeath"] = pshy.chat_commands["afkdeath"]
pshy.perms.admins["!afkdeath"] = true
--- !allowmort
function pshy.tfm_commands_ChatCommandMortcommand(user, allowmort)
	tfm.exec.disableMortCommand(not allowmort)
end 
pshy.chat_commands["allowmort"] = {func = pshy.tfm_commands_ChatCommandMortcommand, desc = "allow (or prevent) TFM's /mort command", argc_min = 1, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_tfm_commands"].commands["allowmort"] = pshy.chat_commands["allowmort"]
pshy.perms.admins["!allowmort"] = true
--- !allowwatch
function pshy.tfm_commands_ChatCommandWatchcommand(user, allowwatch)
	tfm.exec.disableWatchCommand(not allowwatch)
end 
pshy.chat_commands["allowwatch"] = {func = pshy.tfm_commands_ChatCommandWatchcommand, desc = "allow (or prevent) TFM's /watch command", argc_min = 1, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_tfm_commands"].commands["allowwatch"] = pshy.chat_commands["allowwatch"]
pshy.perms.admins["!allowwatch"] = true
--- !allowdebug
function pshy.tfm_commands_ChatCommandDebugcommand(user, allowdebug)
	tfm.exec.disableDebugCommand(not allowdebug)
end 
pshy.chat_commands["allowdebug"] = {func = pshy.tfm_commands_ChatCommandDebugcommand, desc = "allow (or prevent) TFM's /debug command", argc_min = 1, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_tfm_commands"].commands["allowdebug"] = pshy.chat_commands["allowdebug"]
pshy.perms.admins["!allowdebug"] = true
--- !minimalist
function pshy.tfm_commands_ChatCommandMinimalist(user, debugcommand)
	tfm.exec.disableMinimalistMode(not debugcommand)
end 
pshy.chat_commands["minimalist"] = {func = pshy.tfm_commands_ChatCommandMinimalist, desc = "allow (or prevent) TFM's minimalist mode", argc_min = 1, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_tfm_commands"].commands["minimalist"] = pshy.chat_commands["minimalist"]
pshy.perms.admins["!minimalist"] = true
--- !consumables
function pshy.tfm_commands_ChatCommandAllowconsumables(user, consumables)
	tfm.exec.disablePshysicalConsumables(not consumables)
end 
pshy.chat_commands["consumables"] = {func = pshy.tfm_commands_ChatCommandAllowconsumables, desc = "allow (or prevent) the use of physical consumables", argc_min = 1, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_tfm_commands"].commands["consumables"] = pshy.chat_commands["consumables"]
pshy.perms.admins["!consumables"] = true
--- !chatcommandsdisplay
function pshy.tfm_commands_ChatCommandChatcommandsdisplay(user, display)
	system.disableChatCommandDisplay(nil, not display)
end 
pshy.chat_commands["chatcommandsdisplay"] = {func = pshy.tfm_commands_ChatCommandChatcommandsdisplay, desc = "show (or hide) all chat commands", argc_min = 1, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_tfm_commands"].commands["chatcommandsdisplay"] = pshy.chat_commands["chatcommandsdisplay"]
pshy.perms.admins["!chatcommandsdisplay"] = true
--- !prespawnpreview
function pshy.tfm_commands_ChatCommandPrespawnpreview(user, prespawnpreview)
	tfm.exec.disablePrespawnPreview(not prespawnpreview)
end 
pshy.chat_commands["prespawnpreview"] = {func = pshy.tfm_commands_ChatCommandPrespawnpreview, desc = "show (or hide) what the shaman is spawning", argc_min = 1, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_tfm_commands"].commands["prespawnpreview"] = pshy.chat_commands["prespawnpreview"]
pshy.perms.admins["!prespawnpreview"] = true
--- !gravity
function pshy.tfm_commands_ChatCommandGravity(user, gravity, wind)
	gravity = gravity or 9
	wind = wind or 0
	tfm.exec.setWorldGravity(wind, gravity)
end 
pshy.chat_commands["gravity"] = {func = pshy.tfm_commands_ChatCommandGravity, desc = "change the gravity and wind", argc_min = 0, argc_max = 2, arg_types = {"number", "number"}}
pshy.help_pages["pshy_tfm_commands"].commands["gravity"] = pshy.chat_commands["gravity"]
pshy.perms.admins["!gravity"] = true
--- !exit
function pshy.tfm_commands_ChatCommandExit(user)
	system.exit()
end 
pshy.chat_commands["exit"] = {func = pshy.tfm_commands_ChatCommandExit, desc = "stop the module", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_tfm_commands"].commands["exit"] = pshy.chat_commands["exit"]
pshy.perms.admins["!exit"] = true
--- !colorpicker
function pshy.tfm_commands_ChatCommandColorpicker(user, target)
	target = pshy.commands_GetTarget(user, target, "!colorpicker")
	ui.showColorPicker(49, target, 0, "Get a color code:")
end 
pshy.chat_commands["colorpicker"] = {func = pshy.tfm_commands_ChatCommandColorpicker, desc = "show the colorpicker", argc_min = 0, argc_max = 1, arg_types = {"player"}}
pshy.help_pages["pshy_tfm_commands"].commands["colorpicker"] = pshy.chat_commands["colorpicker"]
pshy.perms.everyone["!colorpicker"] = true
pshy.perms.admins["!colorpicker-others"] = true
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_imagedb.lua")
function new_mod.Content()
--- pshy_imagedb.lua
--
-- Images available for TFM scripts.
-- Note: I did not made the images, 
-- I only gathered and classified them in this script.
--
-- @author: TFM:Pshy#3752 DC:Pshy#7998 (script)
-- @require pshy_commands.lua
-- @require pshy_help.lua
-- @require pshy_perms.lua
--- Module Help Page:
pshy.help_pages["pshy_imagedb"] = {back = "pshy", title = "Image Search", text = "List of common module images.\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_imagedb"] = pshy.help_pages["pshy_imagedb"]
--- Module Settings:
pshy.imagedb_max_search_results = 20		-- maximum search displayed results
--- Images.
-- Map of images.
-- The key is the image code.
-- The value is a table with the folowing fields:
--	- w: The pixel width of the picture.
--	- h: The pixel height of the picture (default to `w`).
pshy.imagedb_images = {}
-- model
pshy.imagedb_images["00000000000.png"] = {w = nil, h = nil, desc = ""}
-- pixels (source: Peanut_butter https://atelier801.com/topic?f=6&t=827044&p=1#m12)
pshy.imagedb_images["165965055b2.png"] = {author = "Dea_bu#0000", w = 25, h = 34, desc = "pixel 1"}
pshy.imagedb_images["1659658dc8f.png"] = {author = "Dea_bu#0000", w = 25, h = 30, desc = "pixel 2"}
pshy.imagedb_images["165966b6346.png"] = {author = "Dea_bu#0000", w = 25, h = 30, desc = "pixel 3"}
pshy.imagedb_images["165966cc2db.png"] = {author = "Dea_bu#0000", w = 25, h = 30, desc = "pixel 4"}
pshy.imagedb_images["165966d9a68.png"] = {author = "Dea_bu#0000", w = 25, h = 30, desc = "pixel 5"}
pshy.imagedb_images["165966f86f6.png"] = {author = "Dea_bu#0000", w = 25, h = 30, desc = "pixel 6"}
pshy.imagedb_images["16596700568.png"] = {author = "Dea_bu#0000", w = 25, h = 30, desc = "pixel 7"}
pshy.imagedb_images["165967088be.png"] = {author = "Dea_bu#0000", w = 25, h = 30, desc = "pixel 8"}
pshy.imagedb_images["1659671b6fb.png"] = {author = "Dea_bu#0000", w = 25, h = 30, desc = "pixel 9"}
pshy.imagedb_images["16596720dd2.png"] = {author = "Dea_bu#0000", w = 25, h = 34, desc = "pixel 10"}
pshy.imagedb_images["1659672d821.png"] = {author = "Dea_bu#0000", w = 25, h = 30, desc = "pixel 11"}
pshy.imagedb_images["16596736237.png"] = {author = "Dea_bu#0000", w = 25, h = 30, desc = "pixel 12"}
pshy.imagedb_images["1659673b8d5.png"] = {author = "Dea_bu#0000", w = 25, h = 30, desc = "pixel 13"}
pshy.imagedb_images["16596740a8f.png"] = {author = "Dea_bu#0000", w = 25, h = 34, desc = "pixel 14"}
pshy.imagedb_images["16596746e71.png"] = {author = "Dea_bu#0000", w = 25, h = 34, desc = "pixel 15"}
-- flags (source: Bolodefchoco https://atelier801.com/topic?f=6&t=877911#m1)
pshy.imagedb_images["1651b327097.png"] = {w = 16, h = 11, desc = "xx flag"}
pshy.imagedb_images["1651b32290a.png"] = {w = 16, h = 11, desc = "ar flag"}
pshy.imagedb_images["1651b300203.png"] = {w = 16, h = 11, desc = "bg flag"}
pshy.imagedb_images["1651b3019c0.png"] = {w = 16, h = 11, desc = "br flag"}
pshy.imagedb_images["1651b3031bf.png"] = {w = 16, h = 11, desc = "cn flag"}
pshy.imagedb_images["1651b304972.png"] = {w = 16, h = 11, desc = "cz flag"}
pshy.imagedb_images["1651b306152.png"] = {w = 16, h = 11, desc = "de flag"}
pshy.imagedb_images["1651b307973.png"] = {w = 16, h = 11, desc = "ee flag"}
pshy.imagedb_images["1651b309222.png"] = {w = 16, h = 11, desc = "es flag"}
pshy.imagedb_images["1651b30aa94.png"] = {w = 16, h = 11, desc = "fi flag"}
pshy.imagedb_images["1651b30c284.png"] = {w = 16, h = 11, desc = "fr flag"}
pshy.imagedb_images["1651b30da90.png"] = {w = 16, h = 11, desc = "gb flag"}
pshy.imagedb_images["1651b30f25d.png"] = {w = 16, h = 11, desc = "hr flag"}
pshy.imagedb_images["1651b310a3b.png"] = {w = 16, h = 11, desc = "hu flag"}
pshy.imagedb_images["1651b3121ec.png"] = {w = 16, h = 11, desc = "id flag"}
pshy.imagedb_images["1651b3139ed.png"] = {w = 16, h = 11, desc = "il flag"}
pshy.imagedb_images["1651b3151ac.png"] = {w = 16, h = 11, desc = "it flag"}
pshy.imagedb_images["1651b31696a.png"] = {w = 16, h = 11, desc = "jp flag"}
pshy.imagedb_images["1651b31811c.png"] = {w = 16, h = 11, desc = "lt flag"}
pshy.imagedb_images["1651b319906.png"] = {w = 16, h = 11, desc = "lv flag"}
pshy.imagedb_images["1651b31b0dc.png"] = {w = 16, h = 11, desc = "nl flag"}
pshy.imagedb_images["1651b31c891.png"] = {w = 16, h = 11, desc = "ph flag"}
pshy.imagedb_images["1651b31e0cf.png"] = {w = 16, h = 11, desc = "pl flag"}
pshy.imagedb_images["1651b31f950.png"] = {w = 16, h = 11, desc = "ro flag"}
pshy.imagedb_images["1651b321113.png"] = {w = 16, h = 11, desc = "ru flag"}
pshy.imagedb_images["1651b3240e8.png"] = {w = 16, h = 11, desc = "tr flag"}
pshy.imagedb_images["1651b3258b3.png"] = {w = 16, h = 11, desc = "vk flag"}
-- Memes (source: Zubki https://atelier801.com/topic?f=6&t=827044&p=1#m1)
--@TODO  (40;50)
-- Misc (source: Shamousey https://atelier801.com/topic?f=6&t=827044&p=1#m5)
--@TODO
-- Jerry (source: Noooooooorr https://atelier801.com/topic?f=6&t=827044&p=1#m13)
pshy.imagedb_images["174d14019e2.png"] = {w = 86, h = 90, desc = "jerry 1"}
pshy.imagedb_images["174d12f1634.png"] = {w = 61, h = 80, desc = "jerry 2"}
pshy.imagedb_images["1717581457e.png"] = {w = 70, h = 100, desc = "jerry 3"}
pshy.imagedb_images["171524ab085.png"] = {w = 67, h = 60, desc = "jerry 4"}
pshy.imagedb_images["1740c7d4de6.png"] = {w = 80, h = 72, desc = "jerry 5"}
pshy.imagedb_images["1718e698ac9.png"] = {w = 85, h = 110, desc = "jerry 6"}
pshy.imagedb_images["17526faf702.png"] = {w = 80, h = 50, desc = "jerry 7"}
pshy.imagedb_images["17526fc5a1c.png"] = {w = 70, h = 73, desc = "jerry 8"}
pshy.imagedb_images["1792c9c8635.png"] = {w = 259, h = 290, desc = "hungry nibbbles"}
-- Among us (source: Noooooooorr https://atelier801.com/topic?f=6&t=827044&p=1#m13)
pshy.imagedb_images["174d9e0072e.png"] = {w = 37, h = 50, desc = "among us red"}
pshy.imagedb_images["174d9e01e9e.png"] = {w = 37, h = 50, desc = "among us cyan"}
pshy.imagedb_images["174d9e03612.png"] = {w = 37, h = 50, desc = "among us blue"}
pshy.imagedb_images["174d9e0c2be.png"] = {w = 37, h = 50, desc = "among us purple"}
pshy.imagedb_images["174d9e04d84.png"] = {w = 37, h = 50, desc = "among us green"}
pshy.imagedb_images["174d9e064f6.png"] = {w = 37, h = 50, desc = "among us pink"}
pshy.imagedb_images["174d9e07c67.png"] = {w = 37, h = 50, desc = "among us yellow"}
pshy.imagedb_images["174d9e093d9.png"] = {w = 37, h = 50, desc = "among us black"}
pshy.imagedb_images["174d9e0ab49.png"] = {w = 37, h = 50, desc = "among us white"}
pshy.imagedb_images["174da01d1ae.png"] = {w = 24, h = 30, desc = "among us mini white"}
-- misc (source: Noooooooorr https://atelier801.com/topic?f=6&t=827044&p=1#m14)
pshy.imagedb_images["1789e6b9058.png"] = {w = 245, h = 264, desc = "skeleton", TFM = true}
pshy.imagedb_images["178cbf1ff84.png"] = {w = 280, h = 290, desc = "meli mouse", TFM = true}
pshy.imagedb_images["1792c9cd64e.png"] = {w = 290, h = 390, desc = "skeleton cat", TFM = true}
pshy.imagedb_images["1789d45e0a4.png"] = {w = 234, h = 280, desc = "explorer dora", TFM = true}
-- misc (source: Wercade https://atelier801.com/topic?f=6&t=827044&p=1#m10)
pshy.imagedb_images["1557c364a52.png"] = {w = 150, h = 100, desc = "mouse"} -- @TODO: resize
pshy.imagedb_images["155c49d0331.png"] = {w = 60, h = 33, desc = "horse"}
pshy.imagedb_images["155c4a31e48.png"] = {w = 50, h = 49,  desc = "poop", oriented = false}
pshy.imagedb_images["155ca47179a.png"] = {w = 74, h = 50, desc = "computer mouse"}
pshy.imagedb_images["155c9e6aad4.png"] = {w = 60, h = 50, desc = "toilet paper"}
pshy.imagedb_images["155c5133917.png"] = {w = 70, h = 45, desc = "waddles pig"}
pshy.imagedb_images["155c4cdd0e3.png"] = {w = 50, h = 51, desc = "cock"}
pshy.imagedb_images["155c4976244.png"] = {w = 60, h = 50, desc = "sponge bob"}
pshy.imagedb_images["155c9fab3f1.png"] = {w = 72, h = 60, desc = "mouse on broom", TFM = true}
-- gravity falls (source: Breathin https://atelier801.com/topic?f=6&t=827044&p=1#m15)
pshy.imagedb_images["17a52468a34.png"] = {w = 30, h = 50, desc = "waddles pig sitting"}
-- pacman (Made by Nnaaaz#0000)
pshy.imagedb_images["17ad578a939.png"] = {pacman = true, w = 45, author = "Nnaaaz#0000", desc = "open pacman"}
pshy.imagedb_images["17ad578c0aa.png"] = {pacman = true, w = 45, author = "Nnaaaz#0000", desc = "closed pacman"}
pshy.imagedb_images["17afe1cf978.png"] = {pacman = true, w = 45, author = "Nnaaaz#0000", desc = "open yellow pac-cheese"}
pshy.imagedb_images["17afe1ce20a.png"] = {pacman = true, w = 45, author = "Nnaaaz#0000", desc = "closed yellow pac-cheese"}
pshy.imagedb_images["17afe2a6882.png"] = {pacman = true, w = 45, author = "Nnaaaz#0000", desc = "open orange pac-cheese"}
pshy.imagedb_images["17afe1d18bc.png"] = {pacman = true, w = 45, author = "Nnaaaz#0000", desc = "closed orange pac-cheese"}
-- pacman fruits (Uploaded by Nnaaaz#0000)
pshy.imagedb_images["17ae46fd894.png"] = {pacman = true, w = 25, desc = "strawberry"}
pshy.imagedb_images["17ae46ff007.png"] = {pacman = true, w = 25, desc = "chicken leg"}
pshy.imagedb_images["17ae4700777.png"] = {pacman = true, w = 25, desc = "burger"}
pshy.imagedb_images["17ae4701ee9.png"] = {pacman = true, w = 25, desc = "rice bowl"}
pshy.imagedb_images["17ae4703658.png"] = {pacman = true, w = 25, desc = "french potatoes"}
pshy.imagedb_images["17ae4704dcc.png"] = {pacman = true, w = 25, desc = "aubergine"}
pshy.imagedb_images["17ae4706540.png"] = {pacman = true, w = 25, desc = "bear candy"}
pshy.imagedb_images["17ae4707cb0.png"] = {pacman = true, w = 25, desc = "butter"}
pshy.imagedb_images["17ae4709422.png"] = {pacman = true, w = 25, desc = "candy"}
pshy.imagedb_images["17ae470ab94.png"] = {pacman = true, w = 25, desc = "bread"}
pshy.imagedb_images["17ae470c307.png"] = {pacman = true, w = 25, desc = "muffin"}
pshy.imagedb_images["17ae470da77.png"] = {pacman = true, w = 25, desc = "raspberry"}
pshy.imagedb_images["17ae470f1e8.png"] = {pacman = true, w = 25, desc = "green lemon"}
pshy.imagedb_images["17ae4710959.png"] = {pacman = true, w = 25, desc = "croissant"}
pshy.imagedb_images["17ae47120dd.png"] = {pacman = true, w = 25, desc = "watermelon"}
pshy.imagedb_images["17ae471383b.png"] = {pacman = true, w = 25, desc = "cookie"}
pshy.imagedb_images["17ae4714fad.png"] = {pacman = true, w = 25, desc = "wrap"}
pshy.imagedb_images["17ae4716720.png"] = {pacman = true, w = 25, desc = "cherry"}
pshy.imagedb_images["17ae4717e93.png"] = {pacman = true, w = 25, desc = "biscuit"}
pshy.imagedb_images["17ae4719605.png"] = {pacman = true, w = 25, desc = "carrot"}
-- emoticons
pshy.imagedb_images["16f56cbc4d7.png"] = {emoticon = true, w = 29, h = 26, desc = "nausea"}
pshy.imagedb_images["17088661168.png"] = {emoticon = true, w = 29, h = 26, desc = "cry"}
pshy.imagedb_images["16f5d8c7401.png"] = {emoticon = true, w = 29, h = 26, desc = "rogue"}
pshy.imagedb_images["16f56ce925e.png"] = {emoticon = true, desc = "happy cry"}
pshy.imagedb_images["16f56cdf28f.png"] = {emoticon = true, desc = "wonder"}
pshy.imagedb_images["16f56d09dc2.png"] = {emoticon = true, desc = "happy cry 2"}
pshy.imagedb_images["178ea94a353.png"] = {emoticon = true, w = 35, h = 30, desc = "vanlike novoice"}
pshy.imagedb_images["178ea9d3ff4.png"] = {emoticon = true, desc = "vanlike vomit"}
pshy.imagedb_images["178ea9d5bc3.png"] = {emoticon = true, desc = "vanlike big eyes"}
pshy.imagedb_images["178ea9d7876.png"] = {emoticon = true, desc = "vanlike pinklove"}
pshy.imagedb_images["178ea9d947c.png"] = {emoticon = true, desc = "vanlike eyelove"}
pshy.imagedb_images["178eac181f1.png"] = {emoticon = true, author = "rchl#0000", w = 35, h = 28, desc = "drawing zzz"}
pshy.imagedb_images["178ebdf194a.png"] = {emoticon = true, author = "rchl#0000", desc = "glasses1"}
pshy.imagedb_images["178ebdf317a.png"] = {emoticon = true, author = "rchl#0000", desc = "glasses2"}
pshy.imagedb_images["178ebdf0153.png"] = {emoticon = true, author = "rchl#0000", w = 35, h = 31, desc = "clown"}
pshy.imagedb_images["178ebdee617.png"] = {emoticon = true, author = "rchl#0000", w = 35, h = 31, desc = "vomit"}
pshy.imagedb_images["178ebdf495d.png"] = {emoticon = true, author = "rchl#0000", w = 35, h = 31, desc = "sad"}
pshy.imagedb_images["17aa125e853.png"] = {emoticon = true, author = "rchl#0000", w = 48, h = 48, desc = "sad2"}
pshy.imagedb_images["17aa1265ea4.png"] = {emoticon = true, author = "feverchild#0000", desc = "ZZZ"} -- https://discord.com/channels/246815328103825409/522398576706322454/834007372640419851
pshy.imagedb_images["17aa1264731.png"] = {emoticon = true, author = "feverchild#0000", desc = "no voice"}
pshy.imagedb_images["17aa1bcf1d4.png"] = {emoticon = true, author = "Nnaaaz#0000", w = 60, h = 60, desc = "pro"}
pshy.imagedb_images["17aa1bd3a05.png"] = {emoticon = true, author = "Nnaaaz#0000", w = 60, h = 49, desc = "noob"}
pshy.imagedb_images["17aa1bd0944.png"] = {emoticon = true, author = "Nnaaaz#0000", desc = "pro2"}
pshy.imagedb_images["17aa1bd20b5.png"] = {emoticon = true, author = "Nnaaaz#0000", desc = "noob2"}
-- memes
pshy.imagedb_images["15565dbc655.png"] = {meme = true, desc = "WTF cat"} -- https://atelier801.com/topic?f=6&t=827044&p=1#m14
pshy.imagedb_images["15568238225.png"] = {meme = true, w = 40, h = 40, desc = "FUUU"}
pshy.imagedb_images["155682434d5.png"] = {meme = true, desc = "me gusta"}
pshy.imagedb_images["1556824ac1a.png"] = {meme = true, w = 40, h = 40, desc = "trollface"}
-- Rats (Processed and uploaded by Nnaaaz#0000)
pshy.imagedb_images["17b23214ca6.png"] = {rats = true, w = 137, h = 80, desc = "true mouse/rat 1"}
pshy.imagedb_images["17b23216417.png"] = {rats = true, w = 216, h = 80, desc = "true mouse/rat 2"}
pshy.imagedb_images["17b23217b8a.png"] = {rats = true, w = 161, h = 80, desc = "true mouse/rat 3"}
pshy.imagedb_images["17b232192fc.png"] = {rats = true, w = 142, h = 80, desc = "true mouse/rat 4"}
pshy.imagedb_images["17b2321aa6f.png"] = {rats = true, w = 217, h = 80, desc = "true mouse/rat 5"}
-- TFM
pshy.imagedb_images["155593003fc.png"] = {TFM = true, w = 48, h = 29, desc = "cheese left"}
pshy.imagedb_images["155592fd7d0.png"] = {TFM = true, w = 48, h = 29, desc = "cheese right"}
pshy.imagedb_images["153d331c6b9.png"] = {TFM = true, desc = "normal mouse"}
-- TFM (source: Laagaadoo https://atelier801.com/topic?f=6&t=877911#m3)
--1569ed22fca.png - Estante de livros
--1569edb5d05.png - Estante de livros (invertida)
--1569ec80946.png - Lareira
--15699c75f35.png - Lareira (invertida)
--1569e9e54f4.png - Caixão
--15699c67278.png - Caixão (invertido)
--1569e7e4495.png - Cemiterio
--156999e1f40.png - Cemiterio (invertido)
--156999ebf03.png - Árvore de natal
--1569e7d3bac.png - Arvore de natal (invertida)
--1569e7ca20e.png - Arvore com neve
--156999e6b7e.png - Árvore com neve (invertida)
--155a7b9a815.png - Árvore
--1569e788f68.png - Árvore (invertida)
--155a7c4e15a.png - Flor vermelha
--155a7c50a6b.png - Flor azul
--155a7c834a4.png - Janela
--1569e9bfb87.png - Janela (invertida)
--155a7ca38b7.png - Sofá
--156999f093a.png - Palmeira
--1569e7706c4.png - Palmeira (invertido)
--15699b2da1f.png - Estante de halloween
--1569e77e3a5.png - Estante de halloween (invertido)
--1569e79c9e3.png - Árvore do outono
--15699b344da.png - Árvore do outono (invertida)
--1569e773235.png - Abobora gigante
--15699c5e038.png - Piano
--15699c3eedd.png - Barril
--15699b15524.png - Guada roupa
--1569e7ae2e0.png - Guarda roupa (invertido)
--1569edb8321.png - Baú
--1569ed263b4.png - Baú (invertido)
--1569edbaea9.png - Postêr
--1569ed28f41.png - Postêr (invertido)
--1569ed2cb80.png - Boneco de neve
--1569edbe194.png - Boneco de neve (invertido)
-- backgrounds (source: Travonrodfer https://atelier801.com/topic?f=6&t=877911#m6)
--14e555a4c1b.jpg - Mapa Independence Day
--14e520635b4.png - Estatua da liberdade(Mapa Independence Day)
--14e78118c13.jpg - Mapa Bastille Day
--14e7811b53a.png - Folha das arvores(Mapa Bastille Day)
--149c04b50ac.jpg - Mapa do ceifador
--149c04bc447.png - Mapa do ceifador(partes em primeiro plano)
--14abae230c8.jpg - Mapa Rua Nuremberg
--14aa6e36f3e.png - Mapa Rua Nuremberg(partes em primeiro plano)
--14a88571f89.jpg - Mapa Fabrica de brinquedos
--14a8d41a838.jpg - Mapa dia das crianças
--14a8d430dfa.png - Mapa dia das crianças(partes em primeiro plano)
--15150c10e92.png - Mapa de ano novo
-- TFM Particles (source: Tempo https://atelier801.com/topic?f=6&t=877911#m7)
--1674801ea08.png ~> Raiva
--16748020179.png ~> Palmas
--167480218ea.png ~> Confete
--1674802305b.png ~> Dança
--167480247cc.png ~> Facepalm
--16748025f3d.png ~> High five
--167480276af.png ~> Abraçar
--16748028e21.png ~> Pedir Beijo
--1674802a592.png ~> Beijar
--1674802bd07.png ~> Risada
--1674802d478.png ~> Pedra papel tesoura
--1674802ebea.png ~> Sentar
--1674803035b.png ~> Dormir
--16748031acc.png ~> Chorar
-- Mario
pshy.imagedb_images["156d7dafb2d.png"] = {mario = true, desc = "mario (undersized)"} -- @TODO: replace whith a properly sized image
pshy.imagedb_images["17aa6f22c53.png"] = {mario = true, w = 27, h = 38, desc = "coin"}
-- Pokemon (source: Shamousey https://atelier801.com/topic?f=6&t=827044&p=1#m6)
--@TODO
--- Tell if an image should be oriented
function pshy.imagedb_IsOriented(image)
	if type(image) == "string" then
		image = pshy.imagedb_images[image]
	end
	assert(type(image) == "table", "wrong type " .. type(image))
	if image.oriented ~= nil then
		return image.oriented
	end
	if image.meme or image.emoticon or image.w <= 30 then
		return false
	end
	return true
end
--- Search for an image.
-- @private
-- This function is currently for testing only.
-- @param desc Text to find in the image's description.
-- @param words words to search for.
-- @return A list of images matching the search.
function pshy.imagedb_Search(words)
	local results = {}
	for image_name, image in pairs(pshy.imagedb_images) do
		local not_matching = false
		for i_word, word in pairs(words) do
			if not string.find(image.desc, word) and not image[word] then
				not_matching = true
				break
			end
		end
		if not not_matching then
			table.insert(results, image_name)
		end
	end
	return results
end
--- !searchimage [words...]
function pshy.changeimage_ChatCommandSearchimage(user, word)
	local words = pshy.StrSplit(word, ' ', 5)
	if #words >= 5 then
		return false, "You can use at most 4 words per search!"
	end
	if #words == 1 and #words[1] <= 1 then
		return false, "Please perform a more accurate search!"
	end
	local image_names = pshy.imagedb_Search(words)
	if #image_names == 0 then
		tfm.exec.chatMessage("No image found.", user)
	else
		for i_image, image_name in pairs(image_names) do
			if i_image > pshy.imagedb_max_search_results then
				tfm.exec.chatMessage("+ " .. tostring(#image_names - pshy.imagedb_max_search_results), user)
				break
			end
			local image = pshy.imagedb_images[image_name]
			tfm.exec.chatMessage(image_name .. "\t - " .. tostring(image.desc) .. " (" .. tostring(image.w) .. "," .. tostring(image.w or image.h) .. ")", user)
		end
	end
end
pshy.chat_commands["searchimage"] = {func = pshy.changeimage_ChatCommandSearchimage, desc = "search for an image", argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_imagedb"].commands["searchimage"] = pshy.chat_commands["searchimage"]
pshy.perms.cheats["!searchimage"] = true
--- Draw an image (wrapper to tfm.exec.addImage).
-- @public
-- @param image_name The image code (called imageId in te original function).
-- @param target On what game element to attach the image to.
-- @param center_x Center coordinates for the image.
-- @param center_y Center coordinates for the image.
-- @param player_name The player who will see the image, or nil for everyone.
-- @param width Width of the image.
-- @param height Height of the image.
-- @param angle The image's rotation (in radians).
-- @param height Opacity of the image.
-- @return The image ID.
function pshy.imagedb_AddImage(image_name, target, center_x, center_y, player_name, width, height, angle, alpha)
	local image = pshy.imagedb_images[image_name] or pshy.imagedb_images["15568238225.png"]
	target = target or "!0"
	width = width or image.w
	height = height or image.h or image.w
	local x = center_x + ((width > 0) and 0 or math.abs(width))-- - width / 2
	local y = center_y + ((height > 0) and 0 or math.abs(height))-- - height / 2
	local sx = width / (image.w)
	local sy = height / (image.h or image.w)
	local anchor_x, anchor_y = 0.5, 0.5
	return tfm.exec.addImage(image_name, target, x, y, player_name, sx, sy, angle, alpha, anchor_x, anchor_y)
end
--- Draw an image (wrapper to tfm.exec.addImage) but keep the image dimentions (making it fit at least the given area).
-- @public
-- @param image_name The image code (called imageId in te original function).
-- @param target On what game element to attach the image to.
-- @param center_x Center coordinates for the image.
-- @param center_y Center coordinates for the image.
-- @param player_name The player who will see the image, or nil for everyone.
-- @param width Width of the image.
-- @param height Height of the image.
-- @param angle The image's rotation (in radians).
-- @param height Opacity of the image.
-- @return The image ID.
function pshy.imagedb_AddImageMin(image_name, target, center_x, center_y, player_name, min_width, min_height, angle, alpha)
	local image = pshy.imagedb_images[image_name] or pshy.imagedb_images["15568238225.png"]
	target = target or "!0"
	local xsign = min_width / (math.abs(min_width))
	local ysign = min_height / (math.abs(min_height))
	width = min_width or image.w
	height = min_height or image.h or image.w
	local sx = width / (image.w)
	local sy = height / (image.h or image.w)
	local sboth = math.max(math.abs(sx), math.abs(sy))
	width = image.w * sboth * xsign
	height = (image.h or image.w) * sboth * ysign
	local x = center_x + ((width > 0) and 0 or math.abs(width))-- - width / 2
	local y = center_y + ((height > 0) and 0 or math.abs(height))-- - height / 2
	local anchor_x, anchor_y = 0.5, 0.5
	return tfm.exec.addImage(image_name, target, x, y, player_name, sboth * xsign, sboth, angle, alpha, anchor_x, anchor_y)
end
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_bonus.lua")
function new_mod.Content()
--- pshy_bonus.lua
--
-- Add custom bonuses.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
-- @require pshy_imagedb.lua
pshy = pshy or {}
--- Bonus types.
-- @public
-- List of bonus types and informations.
--	- image:	Image to display as the bonus.
--	- func:		Function to call when the bonus is picked.
--				Passed arguments are the player name and the bonus table.
pshy.bonus_types = {}						-- default bonus properties
pshy.bonus_types["pickable_cheese_example"]	= {image = "155593003fc.png", func = tfm.exec.giveCheese}
pshy.bonus_types["pickable_win_example"]	= {image = "17aa6f22c53.png", func = tfm.exec.playerVictory}
pshy.bonus_types["pickable_kill_example"]	= {image = "17ae46ff007.png", func = tfm.exec.killPlayer}
--- Bonus List.
-- Keys: The bonus ids.
-- Values: A table with the folowing fields:
--	- type: Bonus type, as a table.
--	- x: Bonus coordinates.
--	- y: Bonus coordinates.
--	- enabled: Is it enabled by default (true == always, false == never/manual, nil == once only).
pshy.bonus_list	= {}						-- list of ingame bonuses
--- Internal Use:
pshy.bonus_players_image_ids = {}
--- Set the list of bonuses, and show them.
-- @public
function pshy.bonus_SetList(bonus_list)
	pshy.bonus_HideAll()
	pshy.bonus_list = bonus_list
	pshy.bonus_ShowAll()
end
--- Create and enable a bonus.
-- @public
-- Either use this function or `pshy.bonus_SetList`, but not both.
-- @param bonus_type The name or table corresponding to the bonus type.
-- @param bonus_x The bonus location.
-- @param bonus_y The bonus location.
-- @param enabled Is the bonus enabled for all players by default (nil is yes but not for new players).
-- @return The id of the created bonus.
function pshy.bonus_Add(bonus_type, bonus_x, bonus_y, bonus_enabled)
	if type(bonus_type) == "string" then
		assert(pshy.bonus_types[bonus_type], "invalid bonus type " .. tostring(bonus_type))
		bonus_type = pshy.bonus_types[bonus_type]
	end
	assert(type(bonus_type) == "table")
	-- insert
	local new_id = #pshy.bonus_list + 1
	local new_bonus = {id = new_id, type = bonus_type, x = bonus_x, y = bonus_y, enabled = bonus_enabled}
	pshy.bonus_list[new_id] = new_bonus
	-- show
	if bonus_enabled ~= false then
		pshy.bonus_Enable(new_id)
	end
	return new_id
end
--- Enable a bonus.
-- @public
-- When a bonus is enabled, it can be picked by players.
function pshy.bonus_Enable(bonus_id, player_name)
	assert(type(bonus_id) == "number")
	if player_name == nil then
		for player_name in pairs(tfm.get.room.playerList) do
			pshy.bonus_Enable(bonus_id, player_name)
		end
		return
	end
	pshy.bonus_players_image_ids[player_name] = pshy.bonus_players_image_ids[player_name] or {}
	local bonus = pshy.bonus_list[bonus_id]
	local ids = pshy.bonus_players_image_ids[player_name]
	-- if already shown
	if ids[bonus_id] ~= nil then
		pshy.bonus_Hide(bonus_id, player_name)
	end
	-- add bonus
	tfm.exec.addBonus(0, bonus.x, bonus.y, bonus_id, 0, false, player_name)
	-- add image
	--ids[bonus_id] = tfm.exec.addImage(bonus.image or bonus.type.image, "!0", bonus.x - 15, bonus.y - 20, player_name) -- todo: location
	ids[bonus_id] = pshy.imagedb_AddImage(bonus.image or bonus.type.image, "!0", bonus.x, bonus.y, player_name, nil, nil, 0, 1.0)
end
--- Hide a bonus.
-- @public
-- This prevent the bonus from being picked, without deleting it.
function pshy.bonus_Disable(bonus_id, player_name)
	assert(type(bonus_id) == "number")
	if player_name == nil then
		for player_name in pairs(tfm.get.room.playerList) do
			pshy.bonus_Disable(bonus_id, player_name)
		end
		return
	end
	if not pshy.bonus_players_image_ids[player_name] then
		return
	end
	local bonus = pshy.bonus_list[bonus_id]
	local ids = pshy.bonus_players_image_ids[player_name]
	-- if already hidden
	if ids[bonus_id] == nil then
		return
	end
	-- remove bonus
	tfm.exec.removeBonus(bonus_id, player_name)
	-- remove image
	tfm.exec.removeImage(ids[bonus_id], "!0", bonus.x - 15, bonus.y - 20, player_name)
end
--- Show all bonuses, except the ones with `visible == false`.
-- @private
function pshy.bonus_EnableAll(player_name)
	for bonus_id, bonus in pairs(pshy.bonus_list) do
		if not bonus.hidden then
			pshy.bonus_Enable(bonus_id, player_name)
		end
	end
end
--- Disable all bonuses for all players.
-- @private
function pshy.bonus_DisableAll(player_name)
	for bonus_id, bonus in pairs(pshy.bonus_list) do
		pshy.bonus_Disable(bonus_id, player_name)
	end
end
--- TFM event eventPlayerBonusGrabbed.
function eventPlayerBonusGrabbed(player_name, id)
	local bonus = pshy.bonus_list[id]
	-- running the callback
	local func = bonus.func or bonus.type.func
	if func then
		func(player_name, bonus)
	end
	pshy.bonus_Disable(id, player_name)
	-- if callback done then skip other bonus events
	if func then
		return false
	end
end
--- TFM event eventNewGame.
function eventNewGame()
	pshy.bonus_list = {}
	pshy.bonus_players_image_ids = {}
end
--- TFM event eventPlayerrespawn.
function eventPlayerRespawn(player_name)
	for bonus_id, bonus in pairs(pshy.bonus_list) do
		if bonus.enabled == true then
			pshy.bonus_Enable(bonus_id, player_name)
		end
	end
end
--- TFM event eventNewPlayer.
function eventNewPlayer(player_name)
	for bonus_id, bonus in pairs(pshy.bonus_list) do
		if bonus.enabled == true then
			pshy.bonus_Enable(bonus_id, player_name)
		end
	end
end
--- TFM event eventPlayerLeft.
function eventPlayerLeft(player_name)
	pshy.bonus_DisableAll(player_name) -- @todo: is this required?
	pshy.bonus_players_image_ids[player_name] = nil
end
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_changeimage.lua")
function new_mod.Content()
--- pshy_changeimage.lua
--
-- Allow players to change their image.
--
-- @author TFM:Pshy#3752 DC:Pshy#3752
-- @require pshy_commands.lua
-- @require pshy_help.lua
-- @require pshy_imagedb.lua
-- @require pshy_utils.lua
--- Module Help Page:
pshy.help_pages["pshy_changeimage"] = {back = "pshy", title = "Image Change", text = "Change your image.\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_changeimage"] = pshy.help_pages["pshy_changeimage"]
--- Module Settings:
pshy.changesize_keep_changes_on_new_game = true
--- Internal Use:
pshy.changeimage_players = {}
--- Remove an image for a player.
function pshy.changeimage_RemoveImage(player_name)
	if pshy.changeimage_players[player_name].image_id then
		tfm.exec.removeImage(pshy.changeimage_players[player_name].image_id)
	end
	pshy.changeimage_players[player_name] = nil
	tfm.exec.changePlayerSize(player_name, 0.9)
	tfm.exec.changePlayerSize(player_name, 1.0)
end
--- Update a player's image.
function pshy.changeimage_UpdateImage(player_name)
	local player = pshy.changeimage_players[player_name]
	-- get draw settings
	local orientation = player.player_orientation or 1
	if not pshy.imagedb_IsOriented(player.image_name) then
		orientation = 1
	end
	-- skip if update not required
	if player.image_id and player.image_orientation == orientation then
		return
	end
	-- update image
	local old_image_id = player.image_id
	player.image_id = pshy.imagedb_AddImageMin(player.image_name, "%" .. player_name, 0, 0, nil, 40 * orientation, 40, 0.0, 1.0)
	player.image_orientation = orientation
	if old_image_id then
		-- remove previous
		tfm.exec.removeImage(old_image_id)
	end
end
--- Change a player's image.
function pshy.changeimage_ChangeImage(player_name, image_name)
	pshy.changeimage_players[player_name] = pshy.changeimage_players[player_name] or {}
	local player = pshy.changeimage_players[player_name]
	if player.image_id then
		tfm.exec.removeImage(player.image_id)
		player.image_id = nil
	end
	player.image_name = nil
	if image_name then
		-- enable the image
		system.bindKeyboard(player_name, 0, true, true)
		system.bindKeyboard(player_name, 2, true, true)
		player.image_name = image_name
		player.player_orientation = (tfm.get.room.playerList[player_name].isFacingRight) and 1 or -1
		player.available_update_count = 2
		pshy.changeimage_UpdateImage(player_name)
	else
		-- disable the image
		pshy.changeimage_RemoveImage(player_name)
	end
end
--- TFM event eventkeyboard.
function eventKeyboard(player_name, keycode, down, x, y)
	if down and (keycode == 0 or keycode == 2) then
		local player = pshy.changeimage_players[player_name]
		if not player or player.available_update_count <= 0 then
			return
		end
		player.available_update_count = player.available_update_count - 1
		player.player_orientation = (keycode == 2) and 1 or -1
		pshy.changeimage_UpdateImage(player_name)
	end
end
--- TFM event eventPlayerRespawn
function eventPlayerRespawn(player_name)
	if pshy.changeimage_players[player_name] then
		pshy.changeimage_UpdateImage(player_name)
	end
end
--- TFM even eventNewGame.
function eventNewGame()
	-- images are deleted on new games
	for player_name in pairs(tfm.get.room.playerList) do
		if pshy.changeimage_players[player_name] then
			pshy.changeimage_players[player_name].image_id = nil
		end
	end
	-- keep player images
	if pshy.changesize_keep_changes_on_new_game then
		for player_name in pairs(tfm.get.room.playerList) do
			if pshy.changeimage_players[player_name] then
				pshy.changeimage_UpdateImage(player_name)
			end
		end
	end
end
--- TFM event eventPlayerDied
function eventPlayerDied(player_name)
	if pshy.changeimage_players[player_name] then
		pshy.changeimage_players[player_name].image_id = nil
	end
end
--- TFM event eventLoop.
function eventLoop(time, time_remaining)
	for player_name, player in pairs(pshy.changeimage_players) do
		player.available_update_count = 2
	end
end
--- !changeimage <image_name> [player_name]
function pshy.changeimage_ChatCommandChangeimage(user, image_name, target)
	target = pshy.commands_GetTargetOrError(user, target, "!changeimage")
	local image = pshy.imagedb_images[image_name]
	if image_name == "off" then
		pshy.changeimage_ChangeImage(target, nil)
		return
	end
	if not image then
		return false, "Unknown or not approved image."
	end
	if not image.w then
		return false, "This image cannot be used (unknown width)."
	end
	if image.w > 400 or (image.h and image.h > 400)  then
		return false, "This image is too big (w/h > 400)."
	end
	pshy.changeimage_ChangeImage(target, image_name)
end
pshy.chat_commands["changeimage"] = {func = pshy.changeimage_ChatCommandChangeimage, desc = "change your image", argc_min = 1, argc_max = 2, arg_types = {"string", "player"}}
pshy.help_pages["pshy_changeimage"].commands["changeimage"] = pshy.chat_commands["changeimage"]
pshy.perms.cheats["!changeimage"] = true
pshy.perms.admins["!changeimage-others"] = true
--- !randomchangeimage <words>
function pshy.changeimage_ChatCommandRandomchangeimage(user, words)
	local words = pshy.StrSplit(words, ' ', 4)
	local image_names = pshy.imagedb_Search(words)
	return pshy.changeimage_ChatCommandChangeimage(user, image_names[math.random(#image_names)])
end
pshy.chat_commands["randomchangeimage"] = {func = pshy.changeimage_ChatCommandRandomchangeimage, desc = "change your image to a random image matching a search", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_changeimage"].commands["randomchangeimage"] = pshy.chat_commands["randomchangeimage"]
pshy.perms.cheats["!randomchangeimage"] = true
--- !randomchangeimages <words>
function pshy.changeimage_ChatCommandRandomchangeimageeveryone(user, words)
	local words = pshy.StrSplit(words, ' ', 4)
	local image_names = pshy.imagedb_Search(words)
	local r1, r2
	for player_name in pairs(tfm.get.room.playerList) do
		r1, r2 = pshy.changeimage_ChatCommandChangeimage(player_name, image_names[math.random(#image_names)])
		if r1 == false then
			return r1, r2
		end
	end
	return r1, r2
end
pshy.chat_commands["randomchangeimages"] = {func = pshy.changeimage_ChatCommandRandomchangeimageeveryone, desc = "change everyone's image to a random image matching a search", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_changeimage"].commands["randomchangeimages"] = pshy.chat_commands["randomchangeimages"]
pshy.perms.admins["!randomchangeimages"] = true
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pacmice.lua")
function new_mod.Content()
--- pacmice.lua
--
-- Pacmouse: -sees mice- "Nom nom nom!".
--
-- To create a new map:
--	- Add the map to the rotation, in the settings with `pathes` being `{{0, 0}}`.
--	- Play the map.
--	- Use `!set pacmice_cur_pilot YourName#3752`.
--	- Click on a free cell, then use arrows to travel the entire map, every possible path.
--	- Use `!call pacmice_GridExportPathes YourName#3752`.
--	- Copy the output, remove the new lines, and add this as the `pathes` field.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998 (script)
-- @author TFM:Nnaaaz#0000 (map)
--
-- @require pshy_bonus.lua
-- @require pshy_changeimage.lua
-- @require pshy_commands.lua
-- @require pshy_emoticons.lua
-- @require pshy_fun_commands.lua
-- @require pshy_keycodes.lua
-- @require pshy_loopmore.lua
-- @require pshy_lua_commands.lua
-- @require pshy_mapdb.lua
-- @require pshy_scores.lua
-- @require pshy_splashscreen.lua
-- @require pshy_tfm_commands.lua
-- @require pshy_utils.lua
--- help Page:
pshy.help_pages[""] = {back = "", title = "PacMice", text = "<r>Run away</r> from the <j>pacmouse</j>!\n\nEvery <ch2>food</ch2> item earns you <ch>2 points</ch>.\n<ch2>Entering the hole</ch2> earns you <ch>16 points</ch>.\nIf you dont enter the hole but <ch2>survive</ch2>, you earn <ch>10 points</ch>.\nThe player with the highest score becomes the next <j>pacmouse</j>.\n"}
pshy.help_pages["pacmice"] = {back = "", title = "PacMice Commands", text = "", commands = {}}
--- TFM Settings
tfm.exec.disableAutoNewGame(true)
tfm.exec.disableAutoShaman(true)
tfm.exec.disableAfkDeath(true)
tfm.exec.disableAutoTimeLeft(true)
system.disableChatCommandDisplay(nil, true)
--- Pshy Settings:
pshy.perms_auto_admin_authors = true
pshy.authors["Nnaaaz#0000"] = true
pshy.splashscreen_image = "17acb076edb.png"	-- splash image
pshy.splashscreen_x = 150					-- x location
pshy.splashscreen_y = 100					-- y location
pshy.splashscreen_sx = 1					-- scale on x
pshy.splashscreen_sy = 1					-- scale on y
pshy.splashscreen_text = nil
pshy.splashscreen_duration = 8 * 1000		-- pacmice screen duration
pacmice_arbitrary_help_btn_id = 7
--- Replace the map's colors.
function pacmice_GetMap(mapname)
	pacmice_map = pacmice_maps[mapname]
	local xml = pacmice_map.axml
	pacmice_map_color_index = (pacmice_map_color_index % #pacmice_map_colors) + 1
	return string.gsub(xml, "1500fb", pacmice_map_colors[pacmice_map_color_index])
end
--- Module Settings:
pacmice_maps = {}						-- game maps tables
-- map 1 (original)
pacmice_maps["pacmice_1"] = {xml = "pacmice_1", x = 91, y = 29, cell_w = 26, cell_h = 26, wall_size = 14, web_x = -100, pac_count = 1, axml = [[<C><P H="720" DS="m;170,165,610,165" /><Z><S><S T="12" X="168" Y="107" L="56" H="56" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="613" Y="107" L="56" H="56" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="286" Y="107" L="79" H="56" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="495" Y="107" L="79" H="56" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="247" Y="263" L="10" H="160" P="0,0,0.5,0.2,0,0,0,0"/><S T="12" X="533" Y="263" L="10" H="160" P="0,0,0.5,0.2,0,0,0,0"/><S T="12" X="390" Y="29" L="605" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="91" Y="130" L="10" H="210" P="0,0,0.5,0.2,0,0,0,0"/><S T="12" X="690" Y="130" L="10" H="210" P="0,0,0.5,0.2,0,0,0,0"/><S T="12" X="141" Y="237" L="110" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="641" Y="237" L="108" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="196" Y="276" L="10" H="87" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="586" Y="277" L="10" H="88" P="0,0,0.5,0.2,0,0,0,0"/><S T="12" X="143" Y="316" L="113" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="636" Y="316" L="101" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="91" Y="343" L="10" H="60" P="0,0,0.5,0.2,0,0,0,0"/><S T="12" X="689" Y="342" L="10" H="62" P="0,0,0.5,0.2,0,0,0,0"/><S T="12" X="145" Y="368" L="111" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="635" Y="368" L="100" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="196" Y="408" L="10" H="83" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="586" Y="406" L="10" H="87" P="0,0,0.5,0.2,0,0,0,0"/><S T="12" X="145" Y="445" L="105" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="638" Y="445" L="105" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="90" Y="575" L="10" H="270" P="0,0,0.5,0.2,0,0,0,0"/><S T="12" X="690" Y="575" L="10" H="270" P="0,0,0.5,0.2,0,0,0,0"/><S T="12" X="390" Y="706" L="608" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="390" Y="82" L="32" H="108" P="0,0,0.5,0.2,0,0,0,0"/><S T="12" X="392" Y="186" L="180" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="391" Y="445" L="176" H="10" P="0,0,0.3,0.2,360,0,0,0"/><S T="12" X="389" Y="550" L="177" H="10" P="0,0,0.3,0.2,360,0,0,0"/><S T="12" X="234" Y="655" L="185" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="547" Y="655" L="184" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="170" Y="186" L="50" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="612" Y="186" L="50" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="390" Y="214" L="32" H="56" P="0,0,0.5,0.2,0,0,0,0"/><S T="12" X="390" Y="476" L="32" H="55" P="0,0,0.5,0.2,360,0,0,0"/><S T="12" X="390" Y="603" L="32" H="103" P="0,0,0.5,0.2,360,0,0,0"/><S T="12" X="172" Y="498" L="55" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="609" Y="498" L="55" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="195" Y="549" L="10" H="107" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="586" Y="549" L="10" H="107" P="0,0,0.5,0.2,0,0,0,0"/><S T="12" X="286" Y="498" L="73" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="495" Y="498" L="75" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="247" Y="420" L="10" H="55" P="0,0,0.5,0.2,0,0,0,0"/><S T="12" X="533" Y="420" L="10" H="56" P="0,0,0.5,0.2,0,0,0,0"/><S T="12" X="248" Y="600" L="10" H="100" P="0,0,0.5,0.2,0,0,0,0"/><S T="12" X="533" Y="600" L="10" H="99" P="0,0,0.5,0.2,0,0,0,0"/><S T="12" X="289" Y="238" L="75" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="493" Y="238" L="75" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="118" Y="576" L="52" H="54" P="0,0,0.5,0.2,0,0,0,0"/><S T="12" X="663" Y="576" L="52" H="54" P="0,0,0.5,0.2,0,0,0,0"/><S T="12" X="391" Y="393" L="190" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="480" Y="300" L="10" H="22" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="301" Y="300" L="10" H="22" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="480" Y="387" L="10" H="22" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="301" Y="387" L="10" H="22" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="325" Y="292" L="60" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="455" Y="292" L="60" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="312" Y="602" L="30" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="469" Y="602" L="30" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="390" Y="292" L="67" H="10" P="0,0,0.3,0.2,0,0,0,0" v="90000"/><S T="12" X="480" Y="342" L="67" H="10" P="0,0,0.3,0.2,90,0,0,0" v="90000"/><S T="12" X="301" Y="342" L="67" H="10" P="0,0,0.3,0.2,90,0,0,0" v="90000"/><S T="12" X="387" Y="724" L="10" H="10" P="1,0,0.3,0.2,0,1,Infinity,0" c="4" v="90000"/><S T="12" X="427" Y="724" L="10" H="10" P="1,0,0.3,0.2,0,1,Infinity,0" c="4" v="89000"/><S T="12" X="467" Y="724" L="10" H="10" P="1,0,0.3,0.2,0,1,Infinity,0" c="4" v="88000"/><S T="12" X="507" Y="724" L="10" H="10" P="1,0,0.3,0.2,0,1,Infinity,0" c="4" v="87000"/><S T="12" X="547" Y="724" L="10" H="10" P="1,0,0.3,0.2,0,1,Infinity,0" c="4" v="86000"/><S T="12" X="587" Y="724" L="10" H="10" P="1,0,0.3,0.2,0,1,Infinity,0" c="4" v="85000"/></S><D><F X="335" Y="379" D=""/><F X="445" Y="379" D=""/><T X="392" Y="387" D=""/></D><O/><L><JD c="000000,250,1,0" P1="-1600,800" P2="2400,800"/><JD c="000000,250,1,0" P1="-1600,1000" P2="2400,1000"/><JD c="000000,250,1,0" P1="-1600,1200" P2="2400,1200"/><JD c="000000,250,1,0" P1="-1600,600" P2="2400,600"/><JD c="000000,250,1,0" P1="-1600,400" P2="2400,400"/><JD c="000000,250,1,0" P1="-1600,200" P2="2400,200"/><JD c="000000,250,1,0" P1="-1600,0" P2="2400,0"/><JD c="000000,250,1,0" P1="-1600,-200" P2="2400,-200"/><JD c="000000,250,1,0" P1="-1600,-400" P2="2400,-400"/><JD c="1500fb,10,1,0" P1="91,29" P2="690,29"/><JD c="1500fb,10,1,0" P1="91,706" P2="690,706"/><JD c="1500fb,10,1,0" P1="91,30" P2="91,236"/><JD c="1500fb,10,1,0" P1="690,30" P2="690,236"/><JD c="1500fb,10,1,0" P1="91,446" P2="91,704"/><JD c="1500fb,10,1,0" P1="690,446" P2="690,704"/><JD c="1500fb,10,1,0" P1="91,237" P2="195,237"/><JD c="1500fb,10,1,0" P1="690,237" P2="586,237"/><JD c="1500fb,10,1,0" P1="149,186" P2="191,186"/><JD c="1500fb,10,1,0" P1="632,186" P2="590,186"/><JD c="1500fb,10,1,0" P1="301,292" P2="352,292"/><JD c="FFFFFF,10,1,0" M1="63" M2="63" P1="362,292" P2="418,292"/><JD c="FFFFFF,10,1,0" M1="63" M2="63" P1="480,316" P2="480,372"/><JD c="FFFFFF,10,1,0" M1="63" M2="63" P1="301,316" P2="301,372"/><JD c="1500fb,10,1,0" M1="64" M2="64" P1="362,292" P2="418,292"/><JD c="1500fb,10,1,0" M1="64" M2="64" P1="480,316" P2="480,372"/><JD c="1500fb,10,1,0" M1="64" M2="64" P1="301,316" P2="301,372"/><JD c="FFFFFF,10,1,0" M1="65" M2="65" P1="362,292" P2="418,292"/><JD c="FFFFFF,10,1,0" M1="65" M2="65" P1="480,316" P2="480,372"/><JD c="FFFFFF,10,1,0" M1="65" M2="65" P1="301,316" P2="301,372"/><JD c="1500fb,10,1,0" M1="66" M2="66" P1="362,292" P2="418,292"/><JD c="1500fb,10,1,0" M1="66" M2="66" P1="480,316" P2="480,372"/><JD c="1500fb,10,1,0" M1="66" M2="66" P1="301,316" P2="301,372"/><JD c="FFFFFF,10,1,0" M1="67" M2="67" P1="362,292" P2="418,292"/><JD c="FFFFFF,10,1,0" M1="67" M2="67" P1="480,316" P2="480,372"/><JD c="FFFFFF,10,1,0" M1="67" M2="67" P1="301,316" P2="301,372"/><JD c="1500fb,10,1,0" M1="68" M2="68" P1="362,292" P2="418,292"/><JD c="1500fb,10,1,0" M1="68" M2="68" P1="480,316" P2="480,372"/><JD c="1500fb,10,1,0" M1="68" M2="68" P1="301,316" P2="301,372"/><JD c="1500fb,10,1,0" P1="480,292" P2="429,292"/><JD c="1500fb,10,1,0" P1="249,238" P2="322,238"/><JD c="1500fb,10,1,0" P1="532,238" P2="459,238"/><JD c="1500fb,10,1,0" P1="92,316" P2="195,316"/><JD c="1500fb,10,1,0" P1="689,316" P2="586,316"/><JD c="1500fb,10,1,0" P1="92,368" P2="195,368"/><JD c="1500fb,10,1,0" P1="689,368" P2="586,368"/><JD c="1500fb,10,1,0" P1="91,445" P2="195,445"/><JD c="1500fb,10,1,0" P1="690,445" P2="586,445"/><JD c="1500fb,10,1,0" P1="307,445" P2="476,445"/><JD c="1500fb,10,1,0" P1="302,393" P2="479,393"/><JD c="1500fb,10,1,0" P1="307,186" P2="478,186"/><JD c="1500fb,10,1,0" P1="305,550" P2="474,550"/><JD c="1500fb,10,1,0" P1="145,655" P2="323,655"/><JD c="1500fb,10,1,0" P1="636,655" P2="458,655"/><JD c="000000,6,1,0" P1="91,30" P2="91,236"/><JD c="000000,6,1,0" P1="690,30" P2="690,236"/><JD c="000000,6,1,0" P1="91,706" P2="690,706"/><JD c="1500fb,10,1,0" P1="148,498" P2="195,498"/><JD c="1500fb,10,1,0" P1="633,498" P2="586,498"/><JD c="1500fb,10,1,0" P1="254,498" P2="318,498"/><JD c="1500fb,10,1,0" P1="527,498" P2="463,498"/><JD c="1500fb,10,1,0" P1="301,602" P2="322,602"/><JD c="1500fb,10,1,0" P1="480,602" P2="459,602"/><JD c="1500fb,10,1,0" P1="195.5,237.5" P2="195.5,315.5"/><JD c="1500fb,10,1,0" P1="585.5,237.5" P2="585.5,315.5"/><JD c="1500fb,10,1,0" P1="480,294" P2="480,306"/><JD c="1500fb,10,1,0" P1="301,294" P2="301,306"/><JD c="1500fb,10,1,0" P1="480,381" P2="480,393"/><JD c="1500fb,10,1,0" P1="301,381" P2="301,393"/><JD c="1500fb,10,1,0" P1="247.5,186.5" P2="247.5,338.5"/><JD c="1500fb,10,1,0" P1="533.5,186.5" P2="533.5,338.5"/><JD c="1500fb,10,1,0" P1="195.5,368" P2="195.5,445"/><JD c="1500fb,10,1,0" P1="585.5,368" P2="585.5,445"/><JD c="000000,6,1,0" P1="91,446" P2="91,704"/><JD c="000000,6,1,0" P1="690,446" P2="690,704"/><JD c="1500fb,10,1,0" P1="247.5,397" P2="247.5,443"/><JD c="1500fb,10,1,0" P1="533.5,397" P2="533.5,443"/><JD c="1500fb,10,1,0" P1="195.5,498" P2="195.5,600"/><JD c="1500fb,10,1,0" P1="585.5,498" P2="585.5,600"/><JD c="1500fb,10,1,0" P1="247.5,553" P2="247.5,655"/><JD c="1500fb,10,1,0" P1="533.5,553" P2="533.5,655"/><JD c="1500fb,10,1,0" P1="91.5,316" P2="91.5,367"/><JD c="1500fb,10,1,0" P1="689.5,316" P2="689.5,367"/><JD c="000000,6,1,0" P1="91,237" P2="195,237"/><JD c="000000,6,1,0" P1="690,237" P2="586,237"/><JD c="000000,6,1,0" P1="149,186" P2="191,186"/><JD c="000000,6,1,0" P1="632,186" P2="590,186"/><JD c="000000,6,1,0" P1="301,292" P2="352,292"/><JD c="000000,6,1,0" M1="63" M2="63" P1="362,292" P2="418,292"/><JD c="000000,6,1,0" M1="63" M2="63" P1="480,316" P2="480,372"/><JD c="000000,6,1,0" M1="63" M2="63" P1="301,316" P2="301,372"/><JD c="000000,6,1,0" P1="480,292" P2="429,292"/><JD c="000000,6,1,0" P1="249,238" P2="322,238"/><JD c="000000,6,1,0" P1="532,238" P2="459,238"/><JD c="000000,6,1,0" P1="92,316" P2="195,316"/><JD c="000000,6,1,0" P1="689,316" P2="586,316"/><JD c="000000,6,1,0" P1="92,368" P2="195,368"/><JD c="000000,6,1,0" P1="689,368" P2="586,368"/><JD c="000000,6,1,0" P1="91,445" P2="195,445"/><JD c="000000,6,1,0" P1="690,445" P2="586,445"/><JD c="000000,6,1,0" P1="307,445" P2="476,445"/><JD c="000000,6,1,0" P1="302,393" P2="479,393"/><JD c="000000,6,1,0" P1="145,655" P2="323,655"/><JD c="000000,6,1,0" P1="636,655" P2="458,655"/><JD c="000000,6,1,0" P1="148,498" P2="195,498"/><JD c="000000,6,1,0" P1="633,498" P2="586,498"/><JD c="000000,6,1,0" P1="254,498" P2="318,498"/><JD c="000000,6,1,0" P1="527,498" P2="463,498"/><JD c="000000,6,1,0" P1="301,602" P2="322,602"/><JD c="000000,6,1,0" P1="480,602" P2="459,602"/><JD c="000000,6,1,0" P1="195.5,237.5" P2="195.5,315.5"/><JD c="000000,6,1,0" P1="585.5,237.5" P2="585.5,315.5"/><JD c="000000,6,1,0" P1="480,294" P2="480,306"/><JD c="000000,6,1,0" P1="301,294" P2="301,306"/><JD c="000000,6,1,0" P1="480,381" P2="480,393"/><JD c="000000,6,1,0" P1="301,381" P2="301,393"/><JD c="000000,6,1,0" P1="247.5,186.5" P2="247.5,338.5"/><JD c="000000,6,1,0" P1="533.5,186.5" P2="533.5,338.5"/><JD c="000000,6,1,0" P1="195.5,368" P2="195.5,445"/><JD c="000000,6,1,0" P1="585.5,368" P2="585.5,445"/><JD c="000000,6,1,0" P1="247.5,397" P2="247.5,443"/><JD c="000000,6,1,0" P1="533.5,397" P2="533.5,443"/><JD c="000000,6,1,0" P1="195.5,498" P2="195.5,600"/><JD c="000000,6,1,0" P1="585.5,498" P2="585.5,600"/><JD c="000000,6,1,0" P1="247.5,553" P2="247.5,655"/><JD c="000000,6,1,0" P1="533.5,553" P2="533.5,655"/><JD c="000000,6,1,0" P1="91.5,316" P2="91.5,367"/><JD c="000000,6,1,0" P1="689.5,316" P2="689.5,367"/><JD c="1500fb,3,1,0" P1="141,80" P2="195,80"/><JD c="1500fb,3,1,0" P1="640,80" P2="586,80"/><JD c="1500fb,3,1,0" P1="248,80" P2="324,80"/><JD c="1500fb,3,1,0" P1="533,80" P2="457,80"/><JD c="1500fb,3,1,0" P1="195,81" P2="195,134"/><JD c="1500fb,3,1,0" P1="586,81" P2="586,134"/><JD c="1500fb,3,1,0" P1="324,81" P2="324,134"/><JD c="1500fb,3,1,0" P1="375,33" P2="375,134"/><JD c="1500fb,3,1,0" P1="375,189" P2="375,240"/><JD c="1500fb,3,1,0" P1="375,450" P2="375,502"/><JD c="1500fb,3,1,0" P1="375,553" P2="375,653"/><JD c="1500fb,3,1,0" P1="405,33" P2="405,134"/><JD c="1500fb,3,1,0" P1="405,189" P2="405,240"/><JD c="1500fb,3,1,0" P1="404.88,450" P2="404.88,502"/><JD c="1500fb,3,1,0" P1="405,553" P2="405,653"/><JD c="1500fb,3,1,0" P1="457,81" P2="457,134"/><JD c="1500fb,3,1,0" P1="141,81" P2="141,134"/><JD c="1500fb,3,1,0" P1="640,81" P2="640,134"/><JD c="1500fb,3,1,0" P1="248,81" P2="248,134"/><JD c="000000,6,1,0" P1="307,186" P2="478,186"/><JD c="1500fb,3,1,0" P1="533,81" P2="533,134"/><JD c="1500fb,3,1,0" P1="141,134" P2="195,134"/><JD c="1500fb,3,1,0" P1="640,134" P2="586,134"/><JD c="1500fb,3,1,0" P1="248,134.5" P2="324,134.5"/><JD c="1500fb,3,1,0" P1="375,134.5" P2="405,134.5"/><JD c="000000,6,1,0" P1="305,550" P2="474,550"/><JD c="1500fb,3,1,0" P1="375,240.5" P2="405,240.5"/><JD c="1500fb,3,1,0" P1="375,502.5" P2="405,502.5"/><JD c="000000,6,1,0" P1="91,29" P2="690,29"/><JD c="1500fb,3,1,0" P1="375,653.5" P2="405,653.5"/><JD c="1500fb,3,1,0" P1="533,134" P2="457,134"/><JD c="1500fb,3,1,0" P1="96,551" P2="143,551"/><JD c="1500fb,3,1,0" P1="685,551" P2="638,551"/><JD c="1500fb,3,1,0" P1="96,601" P2="143,601"/><JD c="1500fb,3,1,0" P1="685,601" P2="638,601"/><JD c="1500fb,3,1,0" P1="143,551" P2="143,601"/><JD c="1500fb,3,1,0" P1="638,551" P2="638,601"/><JD c="000000,5,1,0" P1="379,449" P2="401,449"/><JD c="000000,5,1,0" P1="379,554" P2="401,554"/><JD c="000000,5,1,0" P1="379,190" P2="401,190"/><JD c="000000,5,1,0" P1="379,33" P2="401,33"/><JD c="000000,5,1,0" P1="686,555" P2="686,597"/><JD c="000000,5,1,0" P1="95,555" P2="95,597"/></L></Z></C>]]}
pacmice_maps["pacmice_1"].pathes = {{1, 1}, {2, 1}, {3, 1}, {4, 1}, {5, 1}, {6, 1}, {7, 1}, {8, 1}, {9, 1}, {10, 1}, {13, 1}, {14, 1}, {15, 1}, {16, 1}, {17, 1}, {18, 1}, {19, 1}, {20, 1}, {21, 1}, {22, 1}, {1, 2}, {5, 2}, {10, 2}, {13, 2}, {18, 2}, {22, 2}, {1, 3}, {5, 3}, {10, 3}, {13, 3}, {18, 3}, {22, 3}, {1, 4}, {5, 4}, {10, 4}, {13, 4}, {18, 4}, {22, 4}, {1, 5}, {2, 5}, {3, 5}, {4, 5}, {5, 5}, {6, 5}, {7, 5}, {8, 5}, {9, 5}, {10, 5}, {11, 5}, {12, 5}, {13, 5}, {14, 5}, {15, 5}, {16, 5}, {17, 5}, {18, 5}, {19, 5}, {20, 5}, {21, 5}, {22, 5}, {1, 6}, {5, 6}, {7, 6}, {16, 6}, {18, 6}, {22, 6}, {1, 7}, {2, 7}, {3, 7}, {4, 7}, {5, 7}, {7, 7}, {8, 7}, {9, 7}, {10, 7}, {13, 7}, {14, 7}, {15, 7}, {16, 7}, {18, 7}, {19, 7}, {20, 7}, {21, 7}, {22, 7}, {5, 8}, {10, 8}, {13, 8}, {18, 8}, {5, 9}, {7, 9}, {8, 9}, {9, 9}, {10, 9}, {11, 9}, {12, 9}, {13, 9}, {14, 9}, {15, 9}, {16, 9}, {18, 9}, {5, 10}, {7, 10}, {16, 10}, {18, 10}, {5, 11}, {7, 11}, {16, 11}, {18, 11}, {1, 12}, {2, 12}, {3, 12}, {4, 12}, {5, 12}, {7, 12}, {16, 12}, {18, 12}, {19, 12}, {20, 12}, {21, 12}, {22, 12}, {5, 13}, {6, 13}, {7, 13}, {16, 13}, {17, 13}, {18, 13}, {5, 14}, {7, 14}, {16, 14}, {18, 14}, {5, 15}, {7, 15}, {8, 15}, {9, 15}, {10, 15}, {11, 15}, {12, 15}, {13, 15}, {14, 15}, {15, 15}, {16, 15}, {18, 15}, {5, 16}, {7, 16}, {16, 16}, {18, 16}, {1, 17}, {2, 17}, {3, 17}, {4, 17}, {5, 17}, {6, 17}, {7, 17}, {8, 17}, {9, 17}, {10, 17}, {13, 17}, {14, 17}, {15, 17}, {16, 17}, {17, 17}, {18, 17}, {19, 17}, {20, 17}, {21, 17}, {22, 17}, {1, 18}, {5, 18}, {10, 18}, {13, 18}, {18, 18}, {22, 18}, {1, 19}, {2, 19}, {3, 19}, {5, 19}, {6, 19}, {7, 19}, {8, 19}, {9, 19}, {10, 19}, {11, 19}, {12, 19}, {13, 19}, {14, 19}, {15, 19}, {16, 19}, {17, 19}, {18, 19}, {20, 19}, {21, 19}, {22, 19}, {3, 20}, {5, 20}, {7, 20}, {16, 20}, {18, 20}, {20, 20}, {3, 21}, {5, 21}, {7, 21}, {8, 21}, {9, 21}, {10, 21}, {13, 21}, {14, 21}, {15, 21}, {16, 21}, {18, 21}, {20, 21}, {3, 22}, {5, 22}, {7, 22}, {10, 22}, {13, 22}, {16, 22}, {18, 22}, {20, 22}, {1, 23}, {2, 23}, {3, 23}, {4, 23}, {5, 23}, {7, 23}, {8, 23}, {9, 23}, {10, 23}, {13, 23}, {14, 23}, {15, 23}, {16, 23}, {18, 23}, {19, 23}, {20, 23}, {21, 23}, {22, 23}, {1, 24}, {10, 24}, {13, 24}, {22, 24}, {1, 25}, {2, 25}, {3, 25}, {4, 25}, {5, 25}, {6, 25}, {7, 25}, {8, 25}, {9, 25}, {10, 25}, {11, 25}, {12, 25}, {13, 25}, {14, 25}, {15, 25}, {16, 25}, {17, 25}, {18, 25}, {19, 25}, {20, 25}, {21, 25}, {22, 25}}
pacmice_maps["pacmice_1"].foods = {{x = 285, y = 58}, {x = 495, y = 58}, {x = 390, y = 161}, {x = 274, y = 214}, {x = 502, y = 216}, {x = 389, y = 269}, {x = 117, y = 343}, {x = 117, y = 527}, {x = 218, y = 682}, {x = 390, y = 420}, {x = 390, y = 527}, {x = 352, y = 578}, {x = 427, y = 578}, {x = 561, y = 682}, {x = 667, y = 527}, {x = 661, y = 343}}
-- map 2 (2nd map)
pacmice_maps["pacmice_2"] = {xml = "pacmice_2", x = 91, y = 39, cell_w = 26, cell_h = 26, wall_size = 14, web_x = -100, pac_count = 1, axml = [[<C><P H="720" DS="m;210,175,570,175" /><Z><S><S T="12" X="168" Y="91" L="56" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="612" Y="91" L="56" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="288" Y="91" L="84" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="492" Y="91" L="84" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="236" Y="142" L="84" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="544" Y="142" L="84" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="247" Y="536" L="58" H="10" P="0,0,0.3,0.2,-90,0,0,0"/><S T="12" X="533" Y="536" L="58" H="10" P="0,0,0.3,0.2,90,0,0,0"/><S T="12" X="208" Y="244" L="34" H="103" P="0,0,0.5,0.2,0,0,0,0"/><S T="12" X="572" Y="244" L="34" H="103" P="0,0,0.5,0.2,0,0,0,0"/><S T="12" X="120" Y="222" L="52" H="55" P="0,0,0.5,0.2,0,0,0,0"/><S T="12" X="660" Y="222" L="52" H="55" P="0,0,0.5,0.2,0,0,0,0"/><S T="12" X="390" Y="39" L="605" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="91" Y="91" L="10" H="114" P="0,0,0.5,0.2,0,0,0,0"/><S T="12" X="91" Y="433" L="10" H="569" P="0,0,0.5,0.2,0,0,0,0"/><S T="12" X="690" Y="91" L="10" H="113" P="0,0,0.5,0.2,0,0,0,0"/><S T="12" X="690" Y="433" L="10" H="574" P="0,0,0.5,0.2,0,0,0,0"/><S T="12" X="390" Y="716" L="608" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="390" Y="168" L="27" H="162" P="0,0,0.5,0.2,0,0,0,0"/><S T="12" X="391" Y="234" L="137" H="32" P="0,0,0.5,0.2,0,0,0,0"/><S T="12" X="325" Y="128" L="10" H="80" P="0,0,0.5,0.2,0,0,0,0"/><S T="12" X="455" Y="128" L="10" H="80" P="0,0,0.5,0.2,0,0,0,0"/><S T="12" X="273" Y="193" L="10" H="110" P="0,0,0.5,0.2,0,0,0,0"/><S T="12" X="507" Y="193" L="10" H="109" P="0,0,0.5,0.2,0,0,0,0"/><S T="12" X="285" Y="560" L="10" H="84" P="0,0,0.5,0.2,-90,0,0,0"/><S T="12" X="495" Y="560" L="10" H="84" P="0,0,0.5,0.2,90,0,0,0"/><S T="12" X="119" Y="143" L="50" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="661" Y="143" L="50" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="390" Y="483" L="30" H="55" P="0,0,0.5,0.2,360,0,0,0"/><S T="12" X="390" Y="613" L="32" H="103" P="0,0,0.5,0.2,360,0,0,0"/><S T="12" X="173" Y="417" L="50" H="31" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="607" Y="417" L="50" H="31" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="118" Y="545" L="50" H="35" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="662" Y="545" L="50" H="35" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="181" Y="611" L="81" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="599" Y="611" L="81" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="237" Y="664" L="81" H="10" P="0,0,0.3,0.2,180,0,0,0"/><S T="12" X="543" Y="664" L="81" H="10" P="0,0,0.3,0.2,-180,0,0,0"/><S T="12" X="107" Y="325" L="23" H="60" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="673" Y="325" L="23" H="60" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="210" Y="351" L="81" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="570" Y="351" L="81" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="247" Y="401" L="10" H="107" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="532" Y="401" L="10" H="107" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="390" Y="507" L="10" H="183" P="0,0,0.3,0.2,90,0,0,0"/><S T="12" X="284" Y="454" L="10" H="83" P="0,0,0.3,0.2,90,0,0,0"/><S T="12" X="496" Y="454" L="10" H="83" P="0,0,0.3,0.2,-90,0,0,0"/><S T="12" X="143" Y="443" L="10" H="83" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="637" Y="443" L="10" H="83" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="195" Y="521" L="10" H="80" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="585" Y="521" L="10" H="80" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="143" Y="637" L="10" H="60" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="637" Y="637" L="10" H="60" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="273" Y="638" L="10" H="59" P="0,0,0.3,0.2,180,0,0,0"/><S T="12" X="507" Y="638" L="10" H="59" P="0,0,0.3,0.2,-180,0,0,0"/><S T="12" X="325" Y="662" L="10" H="105" P="0,0,0.3,0.2,180,0,0,0"/><S T="12" X="455" Y="662" L="10" H="105" P="0,0,0.3,0.2,-180,0,0,0"/><S T="12" X="209" Y="299" L="78" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="571" Y="299" L="78" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="391" Y="403" L="190" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="480" Y="308" L="10" H="18" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="300" Y="308" L="10" H="18" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="480" Y="397" L="10" H="18" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="300" Y="397" L="10" H="18" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="325" Y="302" L="60" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="455" Y="302" L="60" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="390" Y="302" L="67" H="10" P="0,0,0.3,0.2,0,0,0,0" v="90000"/><S T="12" X="480" Y="352" L="67" H="10" P="0,0,0.3,0.2,90,0,0,0" v="90000"/><S T="12" X="300" Y="352" L="67" H="10" P="0,0,0.3,0.2,90,0,0,0" v="90000"/><S T="12" X="400" Y="735" L="10" H="10" P="1,0,0.3,0.2,0,1,Infinity,0" c="4" v="90000"/><S T="12" X="400" Y="735" L="10" H="10" P="1,0,0.3,0.2,0,1,Infinity,0" c="4" v="89000"/><S T="12" X="400" Y="735" L="10" H="10" P="1,0,0.3,0.2,0,1,Infinity,0" c="4" v="88000"/><S T="12" X="400" Y="735" L="10" H="10" P="1,0,0.3,0.2,0,1,Infinity,0" c="4" v="87000"/><S T="12" X="400" Y="735" L="10" H="10" P="1,0,0.3,0.2,0,1,Infinity,0" c="4" v="86000"/><S T="12" X="400" Y="735" L="10" H="10" P="1,0,0.3,0.2,0,1,Infinity,0" c="4" v="85000"/></S><D><F X="335" Y="390" D=""/><F X="445" Y="390" D=""/><T X="392" Y="397" D=""/></D><O/><L><JD c="000000,250,1,0" P1="-1620,1040" P2="2380,1040"/><JD c="000000,250,1,0" P1="-1610,840" P2="2390,840"/><JD c="000000,250,1,0" P1="-1610,640" P2="2390,640"/><JD c="000000,250,1,0" P1="-1610,440" P2="2390,440"/><JD c="000000,250,1,0" P1="-1610,240" P2="2390,240"/><JD c="000000,250,1,0" P1="-1610,40" P2="2390,40"/><JD c="000000,250,1,0" P1="-1600,-160" P2="2400,-160"/><JD c="000000,250,1,0" P1="-1590,-360" P2="2410,-360"/><JD c="1500fb,10,1,0" P1="91,39" P2="689,39"/><JD c="1500fb,10,1,0" P1="91,716" P2="689,716"/><JD c="1500fb,10,1,0" P1="91,40" P2="91,143"/><JD c="1500fb,10,1,0" P1="689,40" P2="689,143"/><JD c="1500fb,10,1,0" P1="91,199" P2="91,713"/><JD c="1500fb,10,1,0" P1="689,199" P2="689,713"/><JD c="1500fb,10,1,0" P1="273,143" P2="273,244"/><JD c="1500fb,10,1,0" P1="507,143" P2="507,244"/><JD c="1500fb,10,1,0" P1="325,91" P2="325,163"/><JD c="1500fb,10,1,0" P1="455,91" P2="455,163"/><JD c="1500fb,10,1,0" P1="272,142" P2="199,142"/><JD c="1500fb,10,1,0" P1="508,142" P2="581,142"/><JD c="1500fb,10,1,0" P1="244,299" P2="174,299"/><JD c="FFFFFF,10,1,0" M1="69" M2="69" P1="419,302" P2="361,302"/><JD c="FFFFFF,10,1,0" M1="69" M2="69" P1="480,382" P2="480,324"/><JD c="FFFFFF,10,1,0" M1="69" M2="69" P1="300,382" P2="300,324"/><JD c="1500fb,10,1,0" M1="70" M2="70" P1="419,302" P2="361,302"/><JD c="1500fb,10,1,0" M1="70" M2="70" P1="480,382" P2="480,324"/><JD c="1500fb,10,1,0" M1="70" M2="70" P1="300,382" P2="300,324"/><JD c="FFFFFF,10,1,0" M1="71" M2="71" P1="419,302" P2="361,302"/><JD c="FFFFFF,10,1,0" M1="71" M2="71" P1="480,382" P2="480,324"/><JD c="FFFFFF,10,1,0" M1="71" M2="71" P1="300,382" P2="300,324"/><JD c="1500fb,10,1,0" M1="72" M2="72" P1="419,302" P2="361,302"/><JD c="1500fb,10,1,0" M1="72" M2="72" P1="480,382" P2="480,324"/><JD c="1500fb,10,1,0" M1="72" M2="72" P1="300,382" P2="300,324"/><JD c="FFFFFF,10,1,0" M1="73" M2="73" P1="419,302" P2="361,302"/><JD c="FFFFFF,10,1,0" M1="73" M2="73" P1="480,382" P2="480,324"/><JD c="FFFFFF,10,1,0" M1="73" M2="73" P1="300,382" P2="300,324"/><JD c="1500fb,10,1,0" M1="74" M2="74" P1="419,302" P2="361,302"/><JD c="1500fb,10,1,0" M1="74" M2="74" P1="480,382" P2="480,324"/><JD c="1500fb,10,1,0" M1="74" M2="74" P1="300,382" P2="300,324"/><JD c="1500fb,10,1,0" P1="536,299" P2="606,299"/><JD c="1500fb,10,1,0" P1="245,351" P2="174,351"/><JD c="1500fb,10,1,0" P1="535,351" P2="606,351"/><JD c="1500fb,10,1,0" P1="321,454" P2="249,454"/><JD c="1500fb,10,1,0" P1="478,507" P2="302,507"/><JD c="1500fb,10,1,0" P1="479,403" P2="301,403"/><JD c="1500fb,10,1,0" P1="459,454" P2="531,454"/><JD c="1500fb,10,1,0" P1="322,560" P2="249,560"/><JD c="1500fb,10,1,0" P1="458,560" P2="531,560"/><JD c="1500fb,10,1,0" P1="218,611" P2="144,611"/><JD c="1500fb,10,1,0" P1="562,611" P2="636,611"/><JD c="1500fb,10,1,0" P1="273,664" P2="200,664"/><JD c="1500fb,10,1,0" P1="507,664" P2="580,664"/><JD c="1500fb,10,1,0" P1="323,91" P2="250,91"/><JD c="1500fb,10,1,0" P1="457,91" P2="530,91"/><JD c="1500fb,10,1,0" P1="192,91" P2="144,91"/><JD c="1500fb,10,1,0" P1="588,91" P2="636,91"/><JD c="1500fb,10,1,0" P1="351,302" P2="301,302"/><JD c="1500fb,10,1,0" P1="429,302" P2="479,302"/><JD c="1500fb,10,1,0" P1="140,143" P2="92,143"/><JD c="1500fb,10,1,0" P1="640,143" P2="688,143"/><JD c="1500fb,10,1,0" P1="480,302" P2="480,314"/><JD c="1500fb,10,1,0" P1="300,302" P2="300,314"/><JD c="1500fb,10,1,0" P1="480,391" P2="480,402"/><JD c="1500fb,10,1,0" P1="300,391" P2="300,402"/><JD c="1500fb,10,1,0" P1="247,351" P2="247,454"/><JD c="1500fb,10,1,0" P1="533,351" P2="533,454"/><JD c="1500fb,10,1,0" P1="195,485" P2="195,557"/><JD c="1500fb,10,1,0" P1="585,485" P2="585,557"/><JD c="1500fb,10,1,0" P1="143,406" P2="143,479"/><JD c="1500fb,10,1,0" P1="637,406" P2="637,479"/><JD c="1500fb,10,1,0" P1="247,511" P2="247,560"/><JD c="1500fb,10,1,0" P1="533,511" P2="533,560"/><JD c="1500fb,10,1,0" P1="273,613" P2="273,664"/><JD c="1500fb,10,1,0" P1="507,613" P2="507,664"/><JD c="1500fb,10,1,0" P1="143,612" P2="143,663"/><JD c="1500fb,10,1,0" P1="637,612" P2="637,663"/><JD c="1500fb,10,1,0" P1="325,613" P2="325,716"/><JD c="1500fb,10,1,0" P1="455,613" P2="455,716"/><JD c="000000,6,1,0" P1="91,40" P2="91,143"/><JD c="000000,6,1,0" P1="689,40" P2="689,143"/><JD c="000000,6,1,0" P1="91,198" P2="91,713"/><JD c="000000,6,1,0" P1="689,198" P2="689,713"/><JD c="000000,6,1,0" P1="273,143" P2="273,244"/><JD c="000000,6,1,0" P1="507,143" P2="507,244"/><JD c="000000,6,1,0" P1="325,91" P2="325,163"/><JD c="000000,6,1,0" P1="455,91" P2="455,163"/><JD c="000000,6,1,0" P1="272,142" P2="199,142"/><JD c="000000,6,1,0" P1="508,142" P2="581,142"/><JD c="000000,6,1,0" P1="244,299" P2="174,299"/><JD c="000000,6,1,0" M1="69" M2="69" P1="419,302" P2="361,302"/><JD c="000000,6,1,0" M1="69" M2="69" P1="480,382" P2="480,324"/><JD c="000000,6,1,0" M1="69" M2="69" P1="300,382" P2="300,324"/><JD c="000000,6,1,0" P1="536,299" P2="606,299"/><JD c="000000,6,1,0" P1="245,351" P2="174,351"/><JD c="000000,6,1,0" P1="535,351" P2="606,351"/><JD c="1500fb,3,1,0" P1="141,403" P2="197,403"/><JD c="000000,6,1,0" P1="91,716" P2="689,716"/><JD c="1500fb,3,1,0" P1="639,403" P2="583,403"/><JD c="1500fb,3,1,0" P1="96,529" P2="142,529"/><JD c="1500fb,3,1,0" P1="684,529" P2="638,529"/><JD c="000000,6,1,0" P1="321,454" P2="249,454"/><JD c="000000,6,1,0" P1="478,507" P2="302,507"/><JD c="000000,6,1,0" P1="479,403" P2="301,403"/><JD c="000000,6,1,0" P1="459,454" P2="531,454"/><JD c="000000,6,1,0" P1="322,560" P2="249,560"/><JD c="000000,6,1,0" P1="458,560" P2="531,560"/><JD c="000000,6,1,0" P1="218,611" P2="144,611"/><JD c="000000,6,1,0" P1="562,611" P2="636,611"/><JD c="000000,6,1,0" P1="273,664" P2="200,664"/><JD c="000000,6,1,0" P1="507,664" P2="580,664"/><JD c="000000,6,1,0" P1="323,91" P2="250,91"/><JD c="000000,6,1,0" P1="457,91" P2="530,91"/><JD c="000000,6,1,0" P1="192,91" P2="144,91"/><JD c="000000,6,1,0" P1="588,91" P2="636,91"/><JD c="000000,6,1,0" P1="351,302" P2="301,302"/><JD c="000000,6,1,0" P1="429,302" P2="479,302"/><JD c="000000,6,1,0" P1="140,143" P2="92,143"/><JD c="000000,6,1,0" P1="640,143" P2="688,143"/><JD c="000000,6,1,0" P1="480,302" P2="480,314"/><JD c="000000,6,1,0" P1="300,302" P2="300,314"/><JD c="000000,6,1,0" P1="480,391" P2="480,402"/><JD c="000000,6,1,0" P1="300,391" P2="300,402"/><JD c="000000,6,1,0" P1="247,351" P2="247,454"/><JD c="000000,6,1,0" P1="533,351" P2="533,454"/><JD c="000000,6,1,0" P1="195,485" P2="195,557"/><JD c="000000,6,1,0" P1="585,485" P2="585,557"/><JD c="000000,6,1,0" P1="143,408" P2="143,479"/><JD c="000000,6,1,0" P1="637,407" P2="637,479"/><JD c="000000,6,1,0" P1="247,511" P2="247,560"/><JD c="000000,6,1,0" P1="533,511" P2="533,560"/><JD c="000000,6,1,0" P1="273,613" P2="273,664"/><JD c="000000,6,1,0" P1="507,613" P2="507,664"/><JD c="000000,6,1,0" P1="143,612" P2="143,663"/><JD c="000000,6,1,0" P1="637,612" P2="637,663"/><JD c="000000,6,1,0" P1="325,613" P2="325,716"/><JD c="000000,6,1,0" P1="455,613" P2="455,716"/><JD c="1500fb,3,1,0" P1="88,196" P2="144,196"/><JD c="1500fb,3,1,0" P1="692,196" P2="636,196"/><JD c="1500fb,3,1,0" P1="193,195" P2="223,195"/><JD c="1500fb,3,1,0" P1="376,563" P2="404,563"/><JD c="000000,6,1,0" P1="91,39" P2="689,39"/><JD c="1500fb,3,1,0" P1="376,457" P2="404,457"/><JD c="1500fb,3,1,0" P1="376,663" P2="404,663"/><JD c="1500fb,3,1,0" P1="587,195" P2="557,195"/><JD c="1500fb,3,1,0" P1="402,89" P2="378,89"/><JD c="1500fb,3,1,0" P1="458,220" P2="402,220"/><JD c="1500fb,3,1,0" P1="378,220" P2="324,220"/><JD c="1500fb,3,1,0" P1="458,249" P2="324,249"/><JD c="1500fb,3,1,0" P1="96,297" P2="117,297"/><JD c="1500fb,3,1,0" P1="684,297" P2="663,297"/><JD c="1500fb,3,1,0" P1="148,431" P2="196,431"/><JD c="1500fb,3,1,0" P1="632,431" P2="584,431"/><JD c="1500fb,3,1,0" P1="96,561" P2="142,561"/><JD c="1500fb,3,1,0" P1="684,561" P2="638,561"/><JD c="1500fb,3,1,0" P1="96,353" P2="117,353"/><JD c="1500fb,3,1,0" P1="684,353" P2="663,353"/><JD c="1500fb,3,1,0" P1="96,248" P2="144,248"/><JD c="1500fb,3,1,0" P1="684,248" P2="636,248"/><JD c="1500fb,3,1,0" P1="144,197" P2="144,248"/><JD c="1500fb,3,1,0" P1="324,220" P2="324,248"/><JD c="1500fb,3,1,0" P1="458,220" P2="458,248"/><JD c="1500fb,3,1,0" P1="636,197" P2="636,248"/><JD c="1500fb,3,1,0" P1="117,297" P2="117,353"/><JD c="1500fb,3,1,0" P1="663,297" P2="663,353"/><JD c="1500fb,3,1,0" P1="197,403" P2="197,431"/><JD c="1500fb,3,1,0" P1="404,457" P2="404,502"/><JD c="1500fb,3,1,0" P1="376,457" P2="376,502"/><JD c="1500fb,3,1,0" P1="583,403" P2="583,431"/><JD c="1500fb,3,1,0" P1="142.17,529" P2="142.17,560"/><JD c="1500fb,3,1,0" P1="637.83,529" P2="637.83,560"/><JD c="1500fb,3,1,0" P1="193,195" P2="193,294"/><JD c="1500fb,3,1,0" P1="376,563" P2="376,662"/><JD c="1500fb,3,1,0" P1="587,195" P2="587,294"/><JD c="1500fb,3,1,0" P1="401.79,89" P2="401.79,218"/><JD c="1500fb,3,1,0" P1="223,195" P2="223,294"/><JD c="1500fb,3,1,0" P1="404,563" P2="404,662"/><JD c="1500fb,3,1,0" P1="557,195" P2="557,294"/><JD c="1500fb,3,1,0" P1="378,89" P2="378,218"/><JD c="000000,3,1,0" P1="560,298.16" P2="560,274.75"/><JD c="000000,3,1,0" P1="196,298.16" P2="196,274.75"/><JD c="000000,3,1,0" P1="379,506.16" P2="379,482.75"/><JD c="000000,3,1,0" P1="561,295" P2="583,295"/><JD c="000000,3,1,0" P1="197,295" P2="219,295"/><JD c="000000,3,1,0" P1="379,503" P2="400,503"/><JD c="000000,3,1,0" P1="685,556" P2="685,534"/><JD c="000000,3,1,0" P1="633,428" P2="633,408"/><JD c="000000,3,1,0" P1="147,428" P2="147,408"/><JD c="000000,3,1,0" P1="95,556" P2="95,534"/><JD c="000000,3,1,0" P1="685,348" P2="685,300"/><JD c="000000,3,1,0" P1="95,348" P2="95,300"/><JD c="000000,3,1,0" P1="685,244" P2="685,199"/><JD c="000000,3,1,0" P1="95,244" P2="95,199"/><JD c="000000,3,1,0" P1="584,298.16" P2="584,274.75"/><JD c="000000,3,1,0" P1="220,298.16" P2="220,274.75"/><JD c="000000,3,1,0" P1="401,506.16" P2="401,482.75"/><JD c="000000,3,1,0" P1="687,532" P2="664,532"/><JD c="000000,3,1,0" P1="635,406" P2="612,406"/><JD c="000000,3,1,0" P1="143,406" P2="168,406"/><JD c="000000,3,1,0" P1="93,532" P2="116,532"/><JD c="000000,3,1,0" P1="687,300" P2="673,300"/><JD c="000000,3,1,0" P1="93,300" P2="107,300"/><JD c="000000,3,1,0" P1="687,199" P2="673,199"/><JD c="000000,3,1,0" P1="93,199" P2="107,199"/><JD c="000000,3,1,0" P1="695,193" P2="681,193"/><JD c="000000,3,1,0" P1="85,193" P2="99,193"/><JD c="000000,3,1,0" P1="687,558" P2="664,558"/><JD c="000000,3,1,0" P1="635,428" P2="612,428"/><JD c="000000,3,1,0" P1="145,428" P2="168,428"/><JD c="000000,3,1,0" P1="93,558" P2="116,558"/><JD c="000000,3,1,0" P1="687,350" P2="673,350"/><JD c="000000,3,1,0" P1="93,350" P2="107,350"/><JD c="1500fb,10,1,0" P1="91,189" P2="91,153"/><JD c="1500fb,10,1,0" P1="689,189" P2="689,153"/><JD c="000000,3,1,0" P1="687,245" P2="673,245"/><JD c="000000,3,1,0" P1="93,245" P2="107,245"/><JD c="000000,6,1,0" P1="91,189" P2="91,153"/><JD c="000000,6,1,0" P1="689,189" P2="689,153"/></L></Z></C>]]}
pacmice_maps["pacmice_2"].pathes = {{1, 1}, {2, 1}, {3, 1}, {4, 1}, {5, 1}, {6, 1}, {7, 1}, {8, 1}, {9, 1}, {10, 1}, {11, 1}, {12, 1}, {13, 1}, {14, 1}, {15, 1}, {16, 1}, {17, 1}, {18, 1}, {19, 1}, {20, 1}, {21, 1}, {22, 1}, {1, 2}, {5, 2}, {10, 2}, {13, 2}, {18, 2}, {22, 2}, {1, 3}, {2, 3}, {3, 3}, {4, 3}, {5, 3}, {6, 3}, {7, 3}, {8, 3}, {10, 3}, {13, 3}, {15, 3}, {16, 3}, {17, 3}, {18, 3}, {19, 3}, {20, 3}, {21, 3}, {22, 3}, {3, 4}, {8, 4}, {10, 4}, {13, 4}, {15, 4}, {20, 4}, {1, 5}, {2, 5}, {3, 5}, {4, 5}, {5, 5}, {6, 5}, {8, 5}, {10, 5}, {13, 5}, {15, 5}, {17, 5}, {18, 5}, {19, 5}, {20, 5}, {21, 5}, {22, 5}, {3, 6}, {6, 6}, {8, 6}, {9, 6}, {10, 6}, {13, 6}, {14, 6}, {15, 6}, {17, 6}, {20, 6}, {3, 7}, {6, 7}, {8, 7}, {15, 7}, {17, 7}, {20, 7}, {3, 8}, {6, 8}, {8, 8}, {15, 8}, {17, 8}, {20, 8}, {1, 9}, {2, 9}, {3, 9}, {6, 9}, {7, 9}, {8, 9}, {9, 9}, {10, 9}, {11, 9}, {12, 9}, {13, 9}, {14, 9}, {15, 9}, {16, 9}, {17, 9}, {20, 9}, {21, 9}, {22, 9}, {2, 10}, {7, 10}, {16, 10}, {21, 10}, {2, 11}, {3, 11}, {4, 11}, {5, 11}, {6, 11}, {7, 11}, {16, 11}, {17, 11}, {18, 11}, {19, 11}, {20, 11}, {21, 11}, {2, 12}, {7, 12}, {16, 12}, {21, 12}, {1, 13}, {2, 13}, {3, 13}, {4, 13}, {5, 13}, {7, 13}, {16, 13}, {18, 13}, {19, 13}, {20, 13}, {21, 13}, {22, 13}, {1, 14}, {5, 14}, {7, 14}, {16, 14}, {18, 14}, {22, 14}, {1, 15}, {5, 15}, {7, 15}, {8, 15}, {9, 15}, {10, 15}, {11, 15}, {12, 15}, {13, 15}, {14, 15}, {15, 15}, {16, 15}, {18, 15}, {22, 15}, {1, 16}, {3, 16}, {4, 16}, {5, 16}, {10, 16}, {13, 16}, {18, 16}, {19, 16}, {20, 16}, {22, 16}, {1, 17}, {3, 17}, {5, 17}, {6, 17}, {7, 17}, {8, 17}, {9, 17}, {10, 17}, {13, 17}, {14, 17}, {15, 17}, {16, 17}, {17, 17}, {18, 17}, {20, 17}, {22, 17}, {1, 18}, {2, 18}, {3, 18}, {5, 18}, {7, 18}, {16, 18}, {18, 18}, {20, 18}, {21, 18}, {22, 18}, {3, 19}, {5, 19}, {7, 19}, {8, 19}, {9, 19}, {10, 19}, {11, 19}, {12, 19}, {13, 19}, {14, 19}, {15, 19}, {16, 19}, {18, 19}, {20, 19}, {3, 20}, {5, 20}, {10, 20}, {13, 20}, {18, 20}, {20, 20}, {1, 21}, {2, 21}, {3, 21}, {4, 21}, {5, 21}, {6, 21}, {7, 21}, {8, 21}, {9, 21}, {10, 21}, {13, 21}, {14, 21}, {15, 21}, {16, 21}, {17, 21}, {18, 21}, {19, 21}, {20, 21}, {21, 21}, {22, 21}, {1, 22}, {6, 22}, {8, 22}, {10, 22}, {13, 22}, {15, 22}, {17, 22}, {22, 22}, {1, 23}, {3, 23}, {4, 23}, {5, 23}, {6, 23}, {8, 23}, {10, 23}, {13, 23}, {15, 23}, {17, 23}, {18, 23}, {19, 23}, {20, 23}, {22, 23}, {1, 24}, {3, 24}, {8, 24}, {10, 24}, {13, 24}, {15, 24}, {20, 24}, {22, 24}, {1, 25}, {2, 25}, {3, 25}, {4, 25}, {5, 25}, {6, 25}, {7, 25}, {8, 25}, {10, 25}, {11, 25}, {12, 25}, {13, 25}, {15, 25}, {16, 25}, {17, 25}, {18, 25}, {19, 25}, {20, 25}, {21, 25}, {22, 25}}
pacmice_maps["pacmice_2"].foods = {{x = 170, y = 65}, {x = 390, y = 65}, {x = 607, y = 65}, {x = 347, y = 201}, {x = 432, y = 201}, {x = 390, y = 278}, {x = 203, y = 326}, {x = 574, y = 326}, {x = 170, y = 454}, {x = 345, y = 487}, {x = 390, y = 537}, {x = 435, y = 487}, {x = 607, y = 454}, {x = 170, y = 638}, {x = 235, y = 690}, {x = 390, y = 690}, {x = 540, y = 690}, {x = 607, y = 642}}
-- map 3 (v4)
pacmice_maps["pacmice_3"] = {xml = "pacmice_3", x = 10, y = 27, cell_w = 26, cell_h = 26, grid_w = 31, grid_h = 15, wall_size = 14, web_x = -100, pac_count = 1, axml = [[<C><P DS="m;360,85,440,85" /><Z><S><S T="12" X="190" Y="157" L="58" H="10" P="0,0,0.3,0.2,180,0,0,0"/><S T="12" X="612" Y="157" L="58" H="10" P="0,0,0.3,0.2,-180,0,0,0"/><S T="12" X="788" Y="208" L="369" H="10" P="0,0,0.6,0.2,90,0,0,0"/><S T="12" X="400" Y="27" L="10" H="781" P="0,0,0.3,0.2,90,0,0,0"/><S T="12" X="400" Y="391" L="10" H="781" P="0,0,0.3,0.2,90,0,0,0"/><S T="12" X="10" Y="208" L="372" H="10" P="0,0,0.6,0.2,90,0,0,0"/><S T="12" X="166" Y="119" L="10" H="84" P="0,0,0.6,0.2,180,0,0,0"/><S T="12" X="219" Y="69" L="10" H="84" P="0,0,0.6,0.2,180,0,0,0"/><S T="12" X="583" Y="69" L="10" H="84" P="0,0,0.6,0.2,180,0,0,0"/><S T="12" X="636" Y="119" L="10" H="84" P="0,0,0.6,0.2,-180,0,0,0"/><S T="12" X="401" Y="326" L="32" H="157" P="0,0,0.3,0.2,-450,0,0,0"/><S T="12" X="400" Y="44" L="32" H="157" P="0,0,0.3,0.2,-450,0,0,0"/><S T="12" X="258" Y="305" L="73" H="31" P="0,0,0.6,0.2,90,0,0,0"/><S T="12" X="158" Y="326" L="73" H="31" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="644" Y="326" L="73" H="31" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="544" Y="306" L="75" H="31" P="0,0,0.6,0.2,-90,0,0,0"/><S T="12" X="114" Y="223" L="81" H="10" P="0,0,0.6,0.2,90,0,0,0"/><S T="12" X="687" Y="223" L="81" H="10" P="0,0,0.6,0.2,-90,0,0,0"/><S T="12" X="62" Y="167" L="81" H="10" P="0,0,0.6,0.2,-90,0,0,0"/><S T="12" X="740" Y="167" L="81" H="10" P="0,0,0.6,0.2,90,0,0,0"/><S T="12" X="738" Y="327" L="34" H="10" P="0,0,0.6,0.2,90,0,0,0"/><S T="12" X="62" Y="327" L="34" H="10" P="0,0,0.6,0.2,-90,0,0,0"/><S T="12" X="322" Y="157" L="10" H="110" P="0,0,0.3,0.2,90,0,0,0"/><S T="12" X="477" Y="157" L="10" H="108" P="0,0,0.3,0.2,-90,0,0,0"/><S T="12" X="271" Y="117" L="10" H="83" P="0,0,0.6,0.2,0,0,0,0"/><S T="12" X="400" Y="70" L="10" H="83" P="0,0,0.6,0.2,0,0,0,0"/><S T="12" X="530" Y="120" L="10" H="83" P="0,0,0.6,0.2,0,0,0,0"/><S T="12" X="219" Y="263" L="10" H="108" P="0,0,0.3,0.2,90,0,0,0"/><S T="12" X="116" Y="351" L="10" H="82" P="0,0,0.6,0.2,0,0,0,0"/><S T="12" X="686" Y="350" L="10" H="78" P="0,0,0.6,0.2,0,0,0,0"/><S T="12" X="582" Y="263" L="10" H="107" P="0,0,0.3,0.2,-90,0,0,0"/><S T="12" X="217" Y="209" L="10" H="105" P="0,0,0.3,0.2,90,0,0,0"/><S T="12" X="583" Y="209" L="10" H="106" P="0,0,0.3,0.2,-90,0,0,0"/><S T="12" X="66" Y="261" L="10" H="106" P="0,0,0.3,0.2,90,0,0,0"/><S T="12" X="733" Y="261" L="10" H="99" P="0,0,0.3,0.2,-90,0,0,0"/><S T="12" X="89" Y="131" L="10" H="59" P="0,0,0.3,0.2,-90,0,0,0"/><S T="12" X="714" Y="131" L="10" H="59" P="0,0,0.3,0.2,90,0,0,0"/><S T="12" X="65" Y="79" L="10" H="105" P="0,0,0.3,0.2,-90,0,0,0"/><S T="12" X="738" Y="79" L="10" H="105" P="0,0,0.3,0.2,90,0,0,0"/><S T="12" X="400" Y="260" L="166" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="400" Y="106" L="162" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="342" Y="212" L="47" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="459" Y="212" L="47" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="400" Y="212" L="67" H="10" P="0,0,0.3,0.2,0,0,0,0" v="90000"/><S T="12" X="479" Y="236" L="54" H="10" P="0,0,0.3,0.2,90,0,0,0" v="90000"/><S T="12" X="322" Y="236" L="54" H="10" P="0,0,0.3,0.2,90,0,0,0" v="90000"/><S T="12" X="400" Y="410" L="10" H="10" P="1,0,0.3,0.2,90,1,Infinity,0" c="4" v="90000"/><S T="12" X="400" Y="410" L="10" H="10" P="1,0,0.3,0.2,90,1,Infinity,0" c="4" v="89000"/><S T="12" X="400" Y="410" L="10" H="10" P="1,0,0.3,0.2,90,1,Infinity,0" c="4" v="88000"/><S T="12" X="400" Y="410" L="10" H="10" P="1,0,0.3,0.2,90,1,Infinity,0" c="4" v="87000"/><S T="12" X="400" Y="410" L="10" H="10" P="1,0,0.3,0.2,90,1,Infinity,0" c="4" v="86000"/><S T="12" X="400" Y="410" L="10" H="10" P="1,0,0.3,0.2,90,1,Infinity,0" c="4" v="85000"/></S><D><F X="351" Y="248" D=""/><F X="450" Y="247" D=""/><T X="399" Y="254" D=""/></D><O/><L><JD c="000000,250,1,0" P1="-313,-1676" P2="-313,2324"/><JD c="000000,250,1,0" P1="-113,-1666" P2="-113,2334"/><JD c="000000,250,1,0" P1="87,-1666" P2="87,2334"/><JD c="000000,250,1,0" P1="287,-1666" P2="287,2334"/><JD c="000000,250,1,0" P1="487,-1666" P2="487,2334"/><JD c="000000,250,1,0" P1="687,-1666" P2="687,2334"/><JD c="000000,250,1,0" P1="887,-1656" P2="887,2344"/><JD c="000000,250,1,0" P1="1087,-1646" P2="1087,2354"/><JD c="1500fb,10,1,0" P1="788,27" P2="788,391"/><JD c="1500fb,10,1,0" P1="10,27" P2="10,391"/><JD c="1500fb,10,1,0" P1="787,27" P2="12,27"/><JD c="1500fb,10,1,0" P1="787,391" P2="12,391"/><JD c="1500fb,10,1,0" P1="478,106" P2="323,106"/><JD c="1500fb,10,1,0" P1="400,29" P2="400,106"/><JD c="FFFFFF,10,1,0" M1="46" M2="46" P1="429,212.41" P2="371,212.41"/><JD c="FFFFFF,10,1,0" M1="46" M2="46" P1="478.59,259" P2="478.59,213"/><JD c="FFFFFF,10,1,0" M1="46" M2="46" P1="321.59,259" P2="321.59,213"/><JD c="1500fb,10,1,0" M1="47" M2="47" P1="429,212.41" P2="371,212.41"/><JD c="1500fb,10,1,0" M1="47" M2="47" P1="478.59,259" P2="478.59,213"/><JD c="1500fb,10,1,0" M1="47" M2="47" P1="321.59,259" P2="321.59,213"/><JD c="FFFFFF,10,1,0" M1="48" M2="48" P1="429,212.41" P2="371,212.41"/><JD c="FFFFFF,10,1,0" M1="48" M2="48" P1="478.59,259" P2="478.59,213"/><JD c="FFFFFF,10,1,0" M1="48" M2="48" P1="321.59,259" P2="321.59,213"/><JD c="1500fb,10,1,0" M1="49" M2="49" P1="429,212.41" P2="371,212.41"/><JD c="1500fb,10,1,0" M1="49" M2="49" P1="478.59,259" P2="478.59,213"/><JD c="1500fb,10,1,0" M1="49" M2="49" P1="321.59,259" P2="321.59,213"/><JD c="FFFFFF,10,1,0" M1="50" M2="50" P1="429,212.41" P2="371,212.41"/><JD c="FFFFFF,10,1,0" M1="50" M2="50" P1="478.59,259" P2="478.59,213"/><JD c="FFFFFF,10,1,0" M1="50" M2="50" P1="321.59,259" P2="321.59,213"/><JD c="1500fb,10,1,0" M1="51" M2="51" P1="429,212.41" P2="371,212.41"/><JD c="1500fb,10,1,0" M1="51" M2="51" P1="478.59,259" P2="478.59,213"/><JD c="1500fb,10,1,0" M1="51" M2="51" P1="321.59,259" P2="321.59,213"/><JD c="1500fb,10,1,0" P1="738,314" P2="738,339"/><JD c="1500fb,10,1,0" P1="62,314" P2="62,339"/><JD c="1500fb,10,1,0" P1="478,260" P2="322,260"/><JD c="1500fb,10,1,0" P1="271,80" P2="271,156"/><JD c="1500fb,10,1,0" P1="530,83" P2="530,155"/><JD c="1500fb,10,1,0" P1="166,82" P2="166,155"/><JD c="1500fb,10,1,0" P1="219,28" P2="219,105"/><JD c="1500fb,10,1,0" P1="583,28" P2="583,105"/><JD c="1500fb,10,1,0" P1="636,82" P2="636,155"/><JD c="1500fb,10,1,0" P1="114,186" P2="114,260"/><JD c="1500fb,10,1,0" P1="687,186" P2="687,260"/><JD c="1500fb,10,1,0" P1="62,131" P2="62,204"/><JD c="1500fb,10,1,0" P1="740,131" P2="740,204"/><JD c="1500fb,10,1,0" P1="361,212" P2="322,212"/><JD c="1500fb,10,1,0" P1="439,212" P2="478,212"/><JD c="1500fb,10,1,0" P1="372,157" P2="271,157"/><JD c="1500fb,10,1,0" P1="428,157" P2="530,157"/><JD c="1500fb,10,1,0" P1="266,209" P2="168,209"/><JD c="1500fb,3,1,0" P1="323,31" P2="323,58"/><JD c="1500fb,10,1,0" P1="533,209" P2="632,209"/><JD c="1500fb,10,1,0" P1="269,263" P2="169,263"/><JD c="1500fb,3,1,0" P1="477,31" P2="477,58"/><JD c="1500fb,10,1,0" P1="116.45,314.92" P2="116.45,389.92"/><JD c="1500fb,10,1,0" P1="686.05,314.92" P2="686.05,389.92"/><JD c="1500fb,10,1,0" P1="534,263" P2="632,263"/><JD c="1500fb,10,1,0" P1="215,157" P2="166,157"/><JD c="1500fb,10,1,0" P1="587,157" P2="636,157"/><JD c="1500fb,10,1,0" P1="113,131" P2="62,131"/><JD c="1500fb,10,1,0" P1="689,131" P2="740,131"/><JD c="1500fb,10,1,0" P1="113,261" P2="10,261"/><JD c="1500fb,10,1,0" P1="688,261" P2="787,261"/><JD c="1500fb,10,1,0" P1="113,79" P2="10,79"/><JD c="1500fb,10,1,0" P1="689,79" P2="788,79"/><JD c="1500fb,3,1,0" P1="323,58" P2="477,58"/><JD c="000000,6,1,0" P1="787,27" P2="12,27"/><JD c="000000,6,1,0" P1="787,391" P2="12,391"/><JD c="000000,6,1,0" P1="478,106" P2="323,106"/><JD c="000000,6,1,0" P1="400,29" P2="400,106"/><JD c="000000,6,1,0" M1="46" M2="46" P1="429,212.41" P2="371,212.41"/><JD c="000000,6,1,0" M1="46" M2="46" P1="478.59,259" P2="478.59,213"/><JD c="000000,6,1,0" M1="46" M2="46" P1="321.59,259" P2="321.59,213"/><JD c="000000,6,1,0" P1="738,314" P2="738,339"/><JD c="000000,6,1,0" P1="62,314" P2="62,339"/><JD c="1500fb,3,1,0" P1="272,261" P2="272,340"/><JD c="1500fb,3,1,0" P1="114.45,311.92" P2="193.45,311.92"/><JD c="1500fb,3,1,0" P1="688.05,311.92" P2="609.05,311.92"/><JD c="1500fb,3,1,0" P1="530,261" P2="530,342"/><JD c="000000,6,1,0" P1="10,27" P2="10,391"/><JD c="000000,6,1,0" P1="478,260" P2="322,260"/><JD c="000000,6,1,0" P1="271,80" P2="271,156"/><JD c="000000,6,1,0" P1="530,83" P2="530,155"/><JD c="000000,6,1,0" P1="166,82" P2="166,155"/><JD c="000000,6,1,0" P1="219,28" P2="219,105"/><JD c="000000,6,1,0" P1="583,28" P2="583,105"/><JD c="000000,6,1,0" P1="636,82" P2="636,155"/><JD c="000000,6,1,0" P1="114,186" P2="114,260"/><JD c="000000,6,1,0" P1="687,186" P2="687,260"/><JD c="000000,6,1,0" P1="62,131" P2="62,204"/><JD c="000000,6,1,0" P1="740,131" P2="740,204"/><JD c="000000,6,1,0" P1="361,212" P2="322,212"/><JD c="000000,6,1,0" P1="439,212" P2="478,212"/><JD c="000000,6,1,0" P1="372,157" P2="271,157"/><JD c="000000,6,1,0" P1="428,157" P2="530,157"/><JD c="000000,6,1,0" P1="266,209" P2="168,209"/><JD c="000000,6,1,0" P1="533,209" P2="632,209"/><JD c="000000,6,1,0" P1="267,263" P2="169,263"/><JD c="000000,6,1,0" P1="116.45,316.92" P2="116.45,389.92"/><JD c="000000,6,1,0" P1="686.05,316.92" P2="686.05,389.92"/><JD c="000000,6,1,0" P1="535,263" P2="632,263"/><JD c="000000,6,1,0" P1="215,157" P2="166,157"/><JD c="000000,6,1,0" P1="587,157" P2="636,157"/><JD c="000000,6,1,0" P1="113,131" P2="62,131"/><JD c="000000,6,1,0" P1="689,131" P2="740,131"/><JD c="000000,6,1,0" P1="113,261" P2="10,261"/><JD c="000000,6,1,0" P1="688,261" P2="787,261"/><JD c="000000,6,1,0" P1="113,79" P2="10,79"/><JD c="000000,6,1,0" P1="689,79" P2="788,79"/><JD c="1500fb,3,1,0" P1="324,312" P2="324,340"/><JD c="000000,6,1,0" P1="788,27" P2="788,391"/><JD c="1500fb,3,1,0" P1="478,312" P2="478,340"/><JD c="1500fb,3,1,0" P1="244,268" P2="244,340"/><JD c="1500fb,3,1,0" P1="121.45,339.92" P2="193.45,339.92"/><JD c="1500fb,3,1,0" P1="681.05,339.92" P2="609.05,339.92"/><JD c="1500fb,3,1,0" P1="558,268" P2="558,342"/><JD c="1500fb,3,1,0" P1="272,340" P2="244,340"/><JD c="1500fb,3,1,0" P1="193.45,311.92" P2="193.45,339.92"/><JD c="1500fb,3,1,0" P1="609.05,311.92" P2="609.05,339.92"/><JD c="1500fb,3,1,0" P1="530,342" P2="558,342"/><JD c="1500fb,3,1,0" P1="324,312" P2="478,312"/><JD c="1500fb,3,1,0" P1="324,340" P2="478,340"/><JD c="000000,3,1,0" P1="247,267" P2="267,267"/><JD c="000000,3,1,0" P1="326,31" P2="473,31"/><JD c="000000,3,1,0" P1="390,55" P2="410,55"/><JD c="000000,3,1,0" P1="120.45,336.92" P2="120.45,316.92"/><JD c="000000,3,1,0" P1="682.05,336.92" P2="682.05,316.92"/><JD c="000000,3,1,0" P1="555,267" P2="535,267"/><JD c="000000,3,1,0" P1="269,263" P2="269,288"/><JD c="000000,3,1,0" P1="404,29" P2="404,54"/><JD c="000000,3,1,0" P1="116.45,314.92" P2="141.45,314.92"/><JD c="000000,3,1,0" P1="686.05,314.92" P2="661.05,314.92"/><JD c="000000,3,1,0" P1="533,263" P2="533,288"/><JD c="000000,3,1,0" P1="247,265" P2="247,288"/><JD c="000000,3,1,0" P1="396,30" P2="396,53"/><JD c="000000,3,1,0" P1="474,31" P2="474,54"/><JD c="000000,3,1,0" P1="326,31" P2="326,54"/><JD c="000000,3,1,0" P1="118.45,336.92" P2="141.45,336.92"/><JD c="000000,3,1,0" P1="684.05,336.92" P2="661.05,336.92"/><JD c="000000,3,1,0" P1="555,265" P2="555,288"/></L></Z></C>]]}
pacmice_maps["pacmice_3"].pathes = {{1, 1}, {2, 1}, {3, 1}, {4, 1}, {5, 1}, {6, 1}, {7, 1}, {9, 1}, {10, 1}, {11, 1}, {19, 1}, {20, 1}, {21, 1}, {23, 1}, {24, 1}, {25, 1}, {26, 1}, {27, 1}, {28, 1}, {29, 1}, {5, 2}, {7, 2}, {9, 2}, {11, 2}, {12, 2}, {13, 2}, {14, 2}, {16, 2}, {17, 2}, {18, 2}, {19, 2}, {21, 2}, {23, 2}, {25, 2}, {1, 3}, {2, 3}, {3, 3}, {4, 3}, {5, 3}, {7, 3}, {9, 3}, {11, 3}, {19, 3}, {21, 3}, {23, 3}, {25, 3}, {26, 3}, {27, 3}, {28, 3}, {29, 3}, {1, 4}, {5, 4}, {7, 4}, {8, 4}, {9, 4}, {11, 4}, {12, 4}, {13, 4}, {14, 4}, {15, 4}, {16, 4}, {17, 4}, {18, 4}, {19, 4}, {21, 4}, {22, 4}, {23, 4}, {25, 4}, {29, 4}, {1, 5}, {3, 5}, {4, 5}, {5, 5}, {9, 5}, {15, 5}, {21, 5}, {25, 5}, {26, 5}, {27, 5}, {29, 5}, {1, 6}, {3, 6}, {5, 6}, {6, 6}, {7, 6}, {8, 6}, {9, 6}, {10, 6}, {11, 6}, {12, 6}, {13, 6}, {14, 6}, {15, 6}, {16, 6}, {17, 6}, {18, 6}, {19, 6}, {20, 6}, {21, 6}, {22, 6}, {23, 6}, {24, 6}, {25, 6}, {27, 6}, {29, 6}, {1, 7}, {3, 7}, {5, 7}, {11, 7}, {19, 7}, {25, 7}, {27, 7}, {29, 7}, {1, 8}, {2, 8}, {3, 8}, {5, 8}, {6, 8}, {7, 8}, {8, 8}, {9, 8}, {10, 8}, {11, 8}, {19, 8}, {20, 8}, {21, 8}, {22, 8}, {23, 8}, {24, 8}, {25, 8}, {27, 8}, {28, 8}, {29, 8}, {5, 9}, {11, 9}, {19, 9}, {25, 9}, {1, 10}, {2, 10}, {3, 10}, {4, 10}, {5, 10}, {6, 10}, {7, 10}, {8, 10}, {11, 10}, {12, 10}, {13, 10}, {14, 10}, {15, 10}, {16, 10}, {17, 10}, {18, 10}, {19, 10}, {22, 10}, {23, 10}, {24, 10}, {25, 10}, {26, 10}, {27, 10}, {28, 10}, {29, 10}, {1, 11}, {3, 11}, {8, 11}, {11, 11}, {19, 11}, {22, 11}, {27, 11}, {29, 11}, {1, 12}, {3, 12}, {8, 12}, {11, 12}, {19, 12}, {22, 12}, {27, 12}, {29, 12}, {1, 13}, {2, 13}, {3, 13}, {5, 13}, {6, 13}, {7, 13}, {8, 13}, {9, 13}, {10, 13}, {11, 13}, {12, 13}, {13, 13}, {14, 13}, {15, 13}, {16, 13}, {17, 13}, {18, 13}, {19, 13}, {20, 13}, {21, 13}, {22, 13}, {23, 13}, {24, 13}, {25, 13}, {27, 13}, {28, 13}, {29, 13}}
pacmice_maps["pacmice_3"].foods = {{x = 35, y = 53}, {x = 191, y = 130}, {x = 62, y = 235}, {x = 35, y = 364}, {x = 145, y = 364}, {x = 250, y = 235}, {x = 400, y = 189}, {x = 400, y = 364}, {x = 545, y = 235}, {x = 605, y = 130}, {x = 657, y = 364}, {x = 765, y = 364}, {x = 740, y = 235}, {x = 765, y = 53}}
-- map 4 (v5)
pacmice_maps["pacmice_4"] = {xml = "pacmice_4", x = 10, y = 27, cell_w = 26, cell_h = 26, grid_w = 31, grid_h = 15, wall_size = 14, web_x = -100, pac_count = 1, axml = [[<C><P DS="m;258,58,545,58" /><Z><S><S T="12" X="190" Y="259" L="58" H="10" P="0,0,0.3,0.2,720,0,0,0"/><S T="12" X="610" Y="260" L="58" H="10" P="0,0,0.3,0.2,360,0,0,0"/><S T="12" X="788" Y="210" L="369" H="10" P="0,0,0.6,0.2,630,0,0,0"/><S T="12" X="400" Y="27" L="10" H="781" P="0,0,0.3,0.2,90,0,0,0"/><S T="12" X="400" Y="391" L="10" H="781" P="0,0,0.3,0.2,90,0,0,0"/><S T="12" X="10" Y="210" L="372" H="10" P="0,0,0.6,0.2,630,0,0,0"/><S T="12" X="166" Y="297" L="10" H="84" P="0,0,0.6,0.2,720,0,0,0"/><S T="12" X="218" Y="347" L="10" H="84" P="0,0,0.6,0.2,720,0,0,0"/><S T="12" X="582" Y="347" L="10" H="84" P="0,0,0.6,0.2,720,0,0,0"/><S T="12" X="634" Y="298" L="10" H="84" P="0,0,0.6,0.2,360,0,0,0"/><S T="12" X="401" Y="90" L="32" H="157" P="0,0,0.3,0.2,90,0,0,0"/><S T="12" X="400" Y="377" L="32" H="157" P="0,0,0.3,0.2,90,0,0,0"/><S T="12" X="258" Y="111" L="73" H="31" P="0,0,0.6,0.2,630,0,0,0"/><S T="12" X="157" Y="91" L="73" H="31" P="0,0,0.3,0.2,540,0,0,0"/><S T="12" X="645" Y="91" L="73" H="31" P="0,0,0.3,0.2,540,0,0,0"/><S T="12" X="544" Y="110" L="75" H="31" P="0,0,0.6,0.2,450,0,0,0"/><S T="12" X="114" Y="193" L="81" H="10" P="0,0,0.6,0.2,630,0,0,0"/><S T="12" X="687" Y="193" L="81" H="10" P="0,0,0.6,0.2,450,0,0,0"/><S T="12" X="62" Y="249" L="81" H="10" P="0,0,0.6,0.2,450,0,0,0"/><S T="12" X="739" Y="250" L="81" H="10" P="0,0,0.6,0.2,630,0,0,0"/><S T="12" X="738" Y="89" L="34" H="10" P="0,0,0.6,0.2,630,0,0,0"/><S T="12" X="62" Y="89" L="34" H="10" P="0,0,0.6,0.2,450,0,0,0"/><S T="12" X="285" Y="261" L="34" H="10" P="0,0,0.6,0.2,540,0,0,0"/><S T="12" X="518" Y="262" L="34" H="10" P="0,0,0.6,0.2,540,0,0,0"/><S T="12" X="400" Y="260" L="10" H="110" P="0,0,0.3,0.2,630,0,0,0"/><S T="12" X="271" Y="300" L="10" H="83" P="0,0,0.6,0.2,540,0,0,0"/><S T="12" X="530" Y="298" L="10" H="83" P="0,0,0.6,0.2,540,0,0,0"/><S T="12" X="219" Y="157" L="10" H="108" P="0,0,0.3,0.2,630,0,0,0"/><S T="12" X="115" Y="66" L="10" H="82" P="0,0,0.6,0.2,540,0,0,0"/><S T="12" X="687" Y="67" L="10" H="78" P="0,0,0.6,0.2,540,0,0,0"/><S T="12" X="582" Y="157" L="10" H="107" P="0,0,0.3,0.2,90,0,0,0"/><S T="12" X="217" Y="207" L="10" H="105" P="0,0,0.3,0.2,630,0,0,0"/><S T="12" X="583" Y="207" L="10" H="106" P="0,0,0.3,0.2,450,0,0,0"/><S T="12" X="66" Y="155" L="10" H="106" P="0,0,0.3,0.2,630,0,0,0"/><S T="12" X="733" Y="155" L="10" H="99" P="0,0,0.3,0.2,450,0,0,0"/><S T="12" X="89" Y="285" L="10" H="59" P="0,0,0.3,0.2,450,0,0,0"/><S T="12" X="713" Y="286" L="10" H="59" P="0,0,0.3,0.2,630,0,0,0"/><S T="12" X="65" Y="338" L="10" H="105" P="0,0,0.3,0.2,450,0,0,0"/><S T="12" X="738" Y="337" L="10" H="105" P="0,0,0.3,0.2,630,0,0,0"/><S T="12" X="400" Y="206" L="166" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="400" Y="312" L="162" H="10" P="0,0,0.3,0.2,540,0,0,0"/><S T="12" X="479" Y="181" L="10" H="49" P="0,0,0.6,0.2,0,0,0,0" v="90000"/><S T="12" X="323" Y="181" L="10" H="49" P="0,0,0.6,0.2,0,0,0,0" v="90000"/><S T="12" X="342" Y="158" L="47" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="459" Y="158" L="47" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="400" Y="158" L="67" H="10" P="0,0,0.3,0.2,0,0,0,0" v="90000"/><S T="12" X="400" Y="408" L="10" H="10" P="1,0,0.3,0.2,90,1,Infinity,0" c="4" v="85000"/><S T="12" X="400" Y="448" L="10" H="10" P="1,0,0.3,0.2,90,1,Infinity,0" c="4" v="85000"/><S T="12" X="400" Y="408" L="10" H="10" P="1,0,0.3,0.2,90,1,Infinity,0" c="4" v="86000"/><S T="12" X="400" Y="448" L="10" H="10" P="1,0,0.3,0.2,90,1,Infinity,0" c="4" v="86000"/><S T="12" X="400" Y="407" L="10" H="10" P="1,0,0.3,0.2,90,1,Infinity,0" c="4" v="87000"/><S T="12" X="400" Y="447" L="10" H="10" P="1,0,0.3,0.2,90,1,Infinity,0" c="4" v="87000"/><S T="12" X="400" Y="408" L="10" H="10" P="1,0,0.3,0.2,90,1,Infinity,0" c="4" v="88000"/><S T="12" X="400" Y="448" L="10" H="10" P="1,0,0.3,0.2,90,1,Infinity,0" c="4" v="88000"/><S T="12" X="400" Y="408" L="10" H="10" P="1,0,0.3,0.2,90,1,Infinity,0" c="4" v="89000"/><S T="12" X="400" Y="448" L="10" H="10" P="1,0,0.3,0.2,90,1,Infinity,0" c="4" v="89000"/><S T="12" X="400" Y="408" L="10" H="10" P="1,0,0.3,0.2,90,1,Infinity,0" c="4" v="90000"/><S T="12" X="400" Y="448" L="10" H="10" P="1,0,0.3,0.2,90,1,Infinity,0" c="4" v="90000"/></S><D><F X="352" Y="195" D=""/><F X="452" Y="195" D=""/><T X="402" Y="201" D=""/></D><O/><L><JD c="000000,250,1,0" P1="-316,-1663" P2="-316,2337"/><JD c="000000,250,1,0" P1="-116,-1653" P2="-116,2347"/><JD c="000000,250,1,0" P1="84,-1653" P2="84,2347"/><JD c="000000,250,1,0" P1="284,-1653" P2="284,2347"/><JD c="000000,250,1,0" P1="484,-1653" P2="484,2347"/><JD c="000000,250,1,0" P1="684,-1653" P2="684,2347"/><JD c="000000,250,1,0" P1="884,-1643" P2="884,2357"/><JD c="000000,250,1,0" P1="1084,-1633" P2="1084,2367"/><JD c="1500fb,10,1,0" P1="788,391" P2="788,27"/><JD c="1500fb,10,1,0" P1="10,391" P2="10,27"/><JD c="1500fb,10,1,0" P1="787,27" P2="12,27"/><JD c="1500fb,10,1,0" P1="787,391" P2="12,391"/><JD c="1500fb,10,1,0" P1="477,312" P2="324,312"/><JD c="FFFFFF,10,1,0" M1="56" M2="56" P1="431,159" P2="373,159"/><JD c="1500fb,10,1,0" M1="54" M2="54" P1="431,159" P2="373,159"/><JD c="FFFFFF,10,1,0" M1="52" M2="52" P1="431,159" P2="373,159"/><JD c="1500fb,10,1,0" M1="50" M2="50" P1="431,159" P2="373,159"/><JD c="FFFFFF,10,1,0" M1="48" M2="48" P1="431,159" P2="373,159"/><JD c="1500fb,10,1,0" M1="46" M2="46" P1="431,159" P2="373,159"/><JD c="1500fb,10,1,0" P1="738,102" P2="738,77"/><JD c="1500fb,10,1,0" P1="62,102" P2="62,77"/><JD c="1500fb,10,1,0" P1="272,261" P2="297,261"/><JD c="1500fb,10,1,0" P1="505,262" P2="530,262"/><JD c="1500fb,10,1,0" P1="480,207" P2="324,207"/><JD c="1500fb,10,1,0" P1="271,337" P2="271,261"/><JD c="1500fb,10,1,0" P1="530,335" P2="530,263"/><JD c="1500fb,10,1,0" P1="166,334" P2="166,261"/><JD c="1500fb,10,1,0" P1="218,388" P2="218,311"/><JD c="1500fb,10,1,0" P1="582,388" P2="582,311"/><JD c="1500fb,10,1,0" P1="634,335" P2="634,262"/><JD c="1500fb,10,1,0" P1="114,230" P2="114,156"/><JD c="1500fb,10,1,0" P1="687,230" P2="687,156"/><JD c="1500fb,10,1,0" P1="62,285" P2="62,212"/><JD c="1500fb,10,1,0" P1="739,286" P2="739,213"/><JD c="1500fb,10,1,0" P1="363,159" P2="324,159"/><JD c="1500fb,10,1,0" P1="441,159" P2="480,159"/><JD c="FFFFFF,10,1,0" M1="57" M2="57" P1="480,159" P2="480,206"/><JD c="FFFFFF,10,1,0" M1="57" M2="57" P1="323,159" P2="323,206"/><JD c="1500fb,10,1,0" M1="55" M2="55" P1="480,159" P2="480,206"/><JD c="1500fb,10,1,0" M1="55" M2="55" P1="323,159" P2="323,206"/><JD c="FFFFFF,10,1,0" M1="53" M2="53" P1="480,159" P2="480,206"/><JD c="FFFFFF,10,1,0" M1="53" M2="53" P1="323,159" P2="323,206"/><JD c="1500fb,10,1,0" M1="51" M2="51" P1="480,159" P2="480,206"/><JD c="1500fb,10,1,0" M1="51" M2="51" P1="323,159" P2="323,206"/><JD c="FFFFFF,10,1,0" M1="49" M2="49" P1="480,159" P2="480,206"/><JD c="FFFFFF,10,1,0" M1="49" M2="49" P1="323,159" P2="323,206"/><JD c="1500fb,10,1,0" M1="47" M2="47" P1="480,159" P2="480,206"/><JD c="1500fb,10,1,0" M1="47" M2="47" P1="323,159" P2="323,206"/><JD c="1500fb,10,1,0" P1="450,260" P2="349,260"/><JD c="1500fb,10,1,0" P1="266,207" P2="168,207"/><JD c="1500fb,3,1,0" P1="323,390" P2="323,363"/><JD c="1500fb,10,1,0" P1="533,207" P2="632,207"/><JD c="1500fb,10,1,0" P1="268,157" P2="169,157"/><JD c="1500fb,3,1,0" P1="477,390" P2="477,363"/><JD c="1500fb,10,1,0" P1="115.45,102.08" P2="115.45,27.08"/><JD c="1500fb,10,1,0" P1="687.05,102.08" P2="687.05,27.08"/><JD c="1500fb,10,1,0" P1="534,157" P2="632,157"/><JD c="1500fb,10,1,0" P1="215,259" P2="166,259"/><JD c="1500fb,10,1,0" P1="585,260" P2="634,260"/><JD c="1500fb,10,1,0" P1="113,285" P2="62,285"/><JD c="1500fb,10,1,0" P1="688,286" P2="739,286"/><JD c="1500fb,10,1,0" P1="113,155" P2="10,155"/><JD c="1500fb,10,1,0" P1="688,155" P2="787,155"/><JD c="1500fb,10,1,0" P1="113,338" P2="10,338"/><JD c="1500fb,10,1,0" P1="689,337" P2="788,337"/><JD c="1500fb,3,1,0" P1="323,363" P2="477,363"/><JD c="000000,6,1,0" P1="787,27" P2="12,27"/><JD c="000000,6,1,0" P1="787,391" P2="12,391"/><JD c="000000,6,1,0" P1="477,312" P2="324,312"/><JD c="000000,6,1,0" M1="56" M2="56" P1="431,159" P2="373,159"/><JD c="000000,6,1,0" P1="738,102" P2="738,77"/><JD c="000000,6,1,0" P1="62,102" P2="62,77"/><JD c="000000,6,1,0" P1="272,261" P2="297,261"/><JD c="000000,6,1,0" P1="505,262" P2="530,262"/><JD c="1500fb,3,1,0" P1="272,158" P2="272,75"/><JD c="1500fb,3,1,0" P1="113.45,105.08" P2="192.45,105.08"/><JD c="1500fb,3,1,0" P1="689.05,105.08" P2="610.05,105.08"/><JD c="1500fb,3,1,0" P1="530,156" P2="530,74"/><JD c="000000,6,1,0" P1="10,391" P2="10,27"/><JD c="000000,6,1,0" P1="480,207" P2="324,207"/><JD c="000000,6,1,0" P1="271,337" P2="271,261"/><JD c="000000,6,1,0" P1="530,335" P2="530,263"/><JD c="000000,6,1,0" P1="166,334" P2="166,261"/><JD c="000000,6,1,0" P1="218,388" P2="218,311"/><JD c="000000,6,1,0" P1="582,388" P2="582,311"/><JD c="000000,6,1,0" P1="634,335" P2="634,262"/><JD c="000000,6,1,0" P1="114,230" P2="114,156"/><JD c="000000,6,1,0" P1="687,230" P2="687,156"/><JD c="000000,6,1,0" P1="62,285" P2="62,212"/><JD c="000000,6,1,0" P1="739,286" P2="739,213"/><JD c="000000,6,1,0" P1="363,159" P2="324,159"/><JD c="000000,6,1,0" P1="441,159" P2="480,159"/><JD c="000000,6,1,0" M1="57" M2="57" P1="480,159" P2="480,206"/><JD c="000000,6,1,0" M1="57" M2="57" P1="323,159" P2="323,206"/><JD c="000000,6,1,0" P1="450,260" P2="349,260"/><JD c="000000,6,1,0" P1="266,207" P2="168,207"/><JD c="000000,6,1,0" P1="533,207" P2="632,207"/><JD c="000000,6,1,0" P1="268,157" P2="169,157"/><JD c="000000,6,1,0" P1="115.45,100.08" P2="115.45,27.08"/><JD c="000000,6,1,0" P1="687.05,100.08" P2="687.05,27.08"/><JD c="000000,6,1,0" P1="535,157" P2="632,157"/><JD c="000000,6,1,0" P1="215,259" P2="166,259"/><JD c="000000,6,1,0" P1="585,260" P2="634,260"/><JD c="000000,6,1,0" P1="113,285" P2="62,285"/><JD c="000000,6,1,0" P1="688,286" P2="739,286"/><JD c="000000,6,1,0" P1="113,155" P2="10,155"/><JD c="000000,6,1,0" P1="688,155" P2="787,155"/><JD c="000000,6,1,0" P1="113,338" P2="10,338"/><JD c="000000,6,1,0" P1="689,337" P2="788,337"/><JD c="1500fb,3,1,0" P1="324,104" P2="324,76"/><JD c="000000,6,1,0" P1="788,391" P2="788,27"/><JD c="1500fb,3,1,0" P1="478,104" P2="478,76"/><JD c="1500fb,3,1,0" P1="244,152" P2="244,76"/><JD c="1500fb,3,1,0" P1="120.45,77.08" P2="192.45,77.08"/><JD c="1500fb,3,1,0" P1="682.05,77.08" P2="610.05,77.08"/><JD c="1500fb,3,1,0" P1="558,152" P2="558,74"/><JD c="1500fb,3,1,0" P1="272,76" P2="244,76"/><JD c="1500fb,3,1,0" P1="192.45,105.08" P2="192.45,77.08"/><JD c="1500fb,3,1,0" P1="610.05,105.08" P2="610.05,77.08"/><JD c="1500fb,3,1,0" P1="530,74" P2="558,74"/><JD c="1500fb,3,1,0" P1="324,104" P2="478,104"/><JD c="1500fb,3,1,0" P1="324,76" P2="478,76"/><JD c="000000,3,1,0" P1="247,153" P2="267,153"/><JD c="000000,3,1,0" P1="326,387" P2="474,387"/><JD c="000000,3,1,0" P1="119.45,80.08" P2="119.45,100.08"/><JD c="000000,3,1,0" P1="683.05,80.08" P2="683.05,100.08"/><JD c="000000,3,1,0" P1="555,153" P2="535,153"/><JD c="000000,3,1,0" P1="269,157" P2="269,132"/><JD c="000000,3,1,0" P1="474,391" P2="474,368"/><JD c="000000,3,1,0" P1="115.45,102.08" P2="140.45,102.08"/><JD c="000000,3,1,0" P1="687.05,102.08" P2="662.05,102.08"/><JD c="000000,3,1,0" P1="533,157" P2="533,132"/><JD c="000000,3,1,0" P1="247,155" P2="247,132"/><JD c="000000,3,1,0" P1="326,389" P2="326,368"/><JD c="000000,3,1,0" P1="117.45,80.08" P2="140.45,80.08"/><JD c="000000,3,1,0" P1="685.05,80.08" P2="662.05,80.08"/><JD c="000000,3,1,0" P1="555,155" P2="555,132"/></L></Z></C>]]}
pacmice_maps["pacmice_4"].pathes = {{1, 1}, {2, 1}, {3, 1}, {5, 1}, {6, 1}, {7, 1}, {8, 1}, {9, 1}, {10, 1}, {11, 1}, {12, 1}, {13, 1}, {14, 1}, {15, 1}, {16, 1}, {17, 1}, {18, 1}, {19, 1}, {20, 1}, {21, 1}, {22, 1}, {23, 1}, {24, 1}, {25, 1}, {27, 1}, {28, 1}, {29, 1}, {1, 2}, {3, 2}, {8, 2}, {11, 2}, {19, 2}, {22, 2}, {27, 2}, {29, 2}, {1, 3}, {3, 3}, {8, 3}, {11, 3}, {19, 3}, {22, 3}, {27, 3}, {29, 3}, {1, 4}, {2, 4}, {3, 4}, {4, 4}, {5, 4}, {6, 4}, {7, 4}, {8, 4}, {11, 4}, {12, 4}, {13, 4}, {14, 4}, {15, 4}, {16, 4}, {17, 4}, {18, 4}, {19, 4}, {22, 4}, {23, 4}, {24, 4}, {25, 4}, {26, 4}, {27, 4}, {28, 4}, {29, 4}, {5, 5}, {11, 5}, {19, 5}, {25, 5}, {1, 6}, {2, 6}, {3, 6}, {5, 6}, {6, 6}, {7, 6}, {8, 6}, {9, 6}, {10, 6}, {11, 6}, {19, 6}, {20, 6}, {21, 6}, {22, 6}, {23, 6}, {24, 6}, {25, 6}, {27, 6}, {28, 6}, {29, 6}, {1, 7}, {3, 7}, {5, 7}, {11, 7}, {19, 7}, {25, 7}, {27, 7}, {29, 7}, {1, 8}, {3, 8}, {5, 8}, {6, 8}, {7, 8}, {8, 8}, {9, 8}, {10, 8}, {11, 8}, {12, 8}, {13, 8}, {14, 8}, {15, 8}, {16, 8}, {17, 8}, {18, 8}, {19, 8}, {20, 8}, {21, 8}, {22, 8}, {23, 8}, {24, 8}, {25, 8}, {27, 8}, {29, 8}, {1, 9}, {3, 9}, {4, 9}, {5, 9}, {9, 9}, {12, 9}, {18, 9}, {21, 9}, {25, 9}, {26, 9}, {27, 9}, {29, 9}, {1, 10}, {5, 10}, {7, 10}, {8, 10}, {9, 10}, {11, 10}, {12, 10}, {13, 10}, {14, 10}, {15, 10}, {16, 10}, {17, 10}, {18, 10}, {19, 10}, {21, 10}, {22, 10}, {23, 10}, {25, 10}, {29, 10}, {1, 11}, {2, 11}, {3, 11}, {4, 11}, {5, 11}, {7, 11}, {9, 11}, {11, 11}, {19, 11}, {21, 11}, {23, 11}, {25, 11}, {26, 11}, {27, 11}, {28, 11}, {29, 11}, {5, 12}, {7, 12}, {9, 12}, {11, 12}, {12, 12}, {13, 12}, {14, 12}, {15, 12}, {16, 12}, {17, 12}, {18, 12}, {19, 12}, {21, 12}, {23, 12}, {25, 12}, {1, 13}, {2, 13}, {3, 13}, {4, 13}, {5, 13}, {6, 13}, {7, 13}, {9, 13}, {10, 13}, {11, 13}, {19, 13}, {20, 13}, {21, 13}, {23, 13}, {24, 13}, {25, 13}, {26, 13}, {27, 13}, {28, 13}, {29, 13}}
pacmice_maps["pacmice_4"].foods = {{x = 60, y = 55}, {x = 400, y = 55}, {x = 735, y = 55}, {x = 400, y = 130}, {x = 218, y = 182}, {x = 579, y = 182}, {x = 35, y = 240}, {x = 400, y = 240}, {x = 763, y = 240}, {x = 195, y = 285}, {x = 605, y = 285}, {x = 35, y = 365}, {x = 400, y = 335}, {x = 763, y = 365}}
-- (v3) (first multi)
pacmice_maps["pacmice_5"] = {xml = "pacmice_5", x = 10, y = 35, cell_w = 26, cell_h = 26, grid_w = 31, grid_h = 24, wall_size = 14, web_x = -100, pac_count = 2, axml = [[<C><P H="640" DS="m;205,120,595,120" /><Z><S><S T="12" X="191" Y="191" L="58" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="612" Y="191" L="58" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="190" Y="477" L="58" H="10" P="0,0,0.3,0.2,180,0,0,0"/><S T="12" X="612" Y="477" L="58" H="10" P="0,0,0.3,0.2,-180,0,0,0"/><S T="12" X="788" Y="334" L="605" H="10" P="0,0,0.7,0.2,90,0,0,0"/><S T="12" X="400" Y="35" L="10" H="781" P="0,0,0.3,0.2,90,0,0,0"/><S T="12" X="686" Y="634" L="10" H="213" P="0,0,0.3,0.2,90,0,0,0"/><S T="12" X="294" Y="634" L="10" H="574" P="0,0,0.3,0.2,90,0,0,0"/><S T="12" X="10" Y="334" L="608" H="10" P="0,0,0.7,0.2,90,0,0,0"/><S T="12" X="166" Y="229" L="10" H="84" P="0,0,0.7,0.2,0,0,0,0"/><S T="12" X="636" Y="229" L="10" H="84" P="0,0,0.7,0.2,0,0,0,0"/><S T="12" X="166" Y="439" L="10" H="84" P="0,0,0.7,0.2,180,0,0,0"/><S T="12" X="636" Y="439" L="10" H="84" P="0,0,0.7,0.2,-180,0,0,0"/><S T="12" X="243" Y="334" L="30" H="55" P="0,0,0.3,0.2,450,0,0,0"/><S T="12" X="334" Y="364" L="30" H="32" P="0,0,0.3,0.2,450,0,0,0"/><S T="12" X="465" Y="364" L="30" H="32" P="0,0,0.3,0.2,450,0,0,0"/><S T="12" X="558" Y="334" L="30" H="55" P="0,0,0.3,0.2,-450,0,0,0"/><S T="12" X="114" Y="334" L="32" H="107" P="0,0,0.3,0.2,450,0,0,0"/><S T="12" X="686" Y="334" L="32" H="107" P="0,0,0.3,0.2,-450,0,0,0"/><S T="12" X="309" Y="117" L="50" H="31" P="0,0,0.7,0.2,90,0,0,0"/><S T="12" X="493" Y="117" L="50" H="31" P="0,0,0.7,0.2,-90,0,0,0"/><S T="12" X="308" Y="553" L="50" H="31" P="0,0,0.7,0.2,90,0,0,0"/><S T="12" X="491" Y="554" L="50" H="31" P="0,0,0.7,0.2,-90,0,0,0"/><S T="12" X="181" Y="62" L="50" H="35" P="0,0,0.7,0.2,90,0,0,0"/><S T="12" X="621" Y="62" L="50" H="35" P="0,0,0.7,0.2,-90,0,0,0"/><S T="12" X="180" Y="606" L="50" H="35" P="0,0,0.7,0.2,90,0,0,0"/><S T="12" X="621" Y="606" L="50" H="35" P="0,0,0.7,0.2,-90,0,0,0"/><S T="12" X="115" Y="125" L="81" H="10" P="0,0,0.7,0.2,90,0,0,0"/><S T="12" X="687" Y="125" L="81" H="10" P="0,0,0.7,0.2,-90,0,0,0"/><S T="12" X="115" Y="543" L="81" H="10" P="0,0,0.7,0.2,90,0,0,0"/><S T="12" X="687" Y="543" L="81" H="10" P="0,0,0.7,0.2,-90,0,0,0"/><S T="12" X="62" Y="181" L="81" H="10" P="0,0,0.7,0.2,270,0,0,0"/><S T="12" X="740" Y="181" L="81" H="10" P="0,0,0.7,0.2,-270,0,0,0"/><S T="12" X="62" Y="487" L="81" H="10" P="0,0,0.7,0.2,-90,0,0,0"/><S T="12" X="740" Y="487" L="81" H="10" P="0,0,0.7,0.2,90,0,0,0"/><S T="12" X="400" Y="51" L="23" H="60" P="0,0,0.3,0.2,90,0,0,0"/><S T="12" X="400" Y="617" L="23" H="60" P="0,0,0.3,0.2,90,0,0,0"/><S T="12" X="375" Y="154" L="81" H="10" P="0,0,0.7,0.2,90,0,0,0"/><S T="12" X="426" Y="154" L="81" H="10" P="0,0,0.7,0.2,-90,0,0,0"/><S T="12" X="374" Y="519" L="85" H="10" P="0,0,0.7,0.2,90,0,0,0"/><S T="12" X="426" Y="518" L="89" H="10" P="0,0,0.7,0.2,-90,0,0,0"/><S T="12" X="326" Y="191" L="10" H="107" P="0,0,0.3,0.2,90,0,0,0"/><S T="12" X="477" Y="191" L="10" H="107" P="0,0,0.3,0.2,-90,0,0,0"/><S T="12" X="320" Y="480" L="10" H="107" P="0,0,0.3,0.2,90,0,0,0"/><S T="12" X="477" Y="477" L="10" H="108" P="0,0,0.3,0.2,-90,0,0,0"/><S T="12" X="219" Y="334" L="10" H="183" P="0,0,0.7,0.2,180,0,0,0"/><S T="12" X="582" Y="334" L="10" H="183" P="0,0,0.7,0.2,-180,0,0,0"/><S T="12" X="272" Y="227" L="10" H="83" P="0,0,0.7,0.2,180,0,0,0"/><S T="12" X="530" Y="228" L="10" H="83" P="0,0,0.3,0.2,-180,0,0,0"/><S T="12" X="271" Y="440" L="10" H="83" P="0,0,0.7,0.2,0,0,0,0"/><S T="12" X="400" Y="390" L="10" H="83" P="0,0,0.7,0.2,0,0,0,0"/><S T="12" X="530" Y="440" L="10" H="83" P="0,0,0.7,0.2,0,0,0,0"/><S T="12" X="284" Y="87" L="10" H="83" P="0,0,0.3,0.2,90,0,0,0"/><S T="12" X="519" Y="87" L="10" H="83" P="0,0,0.3,0.2,-90,0,0,0"/><S T="12" X="283" Y="583" L="10" H="83" P="0,0,0.3,0.2,90,0,0,0"/><S T="12" X="517" Y="584" L="10" H="83" P="0,0,0.3,0.2,-90,0,0,0"/><S T="12" X="205" Y="139" L="10" H="80" P="0,0,0.3,0.2,90,0,0,0"/><S T="12" X="597" Y="139" L="10" H="80" P="0,0,0.3,0.2,-90,0,0,0"/><S T="12" X="205" Y="529" L="10" H="80" P="0,0,0.3,0.2,90,0,0,0"/><S T="12" X="597" Y="529" L="10" H="80" P="0,0,0.3,0.2,-90,0,0,0"/><S T="12" X="89" Y="87" L="10" H="60" P="0,0,0.3,0.2,90,0,0,0"/><S T="12" X="713" Y="87" L="10" H="60" P="0,0,0.3,0.2,-90,0,0,0"/><S T="12" X="90" Y="581" L="10" H="60" P="0,0,0.3,0.2,90,0,0,0"/><S T="12" X="713" Y="581" L="10" H="60" P="0,0,0.3,0.2,-90,0,0,0"/><S T="12" X="88" Y="217" L="10" H="59" P="0,0,0.3,0.2,270,0,0,0"/><S T="12" X="714" Y="217" L="10" H="59" P="0,0,0.3,0.2,-270,0,0,0"/><S T="12" X="89" Y="451" L="10" H="59" P="0,0,0.3,0.2,-90,0,0,0"/><S T="12" X="714" Y="451" L="10" H="59" P="0,0,0.3,0.2,90,0,0,0"/><S T="12" X="65" Y="269" L="10" H="105" P="0,0,0.3,0.2,270,0,0,0"/><S T="12" X="738" Y="269" L="10" H="105" P="0,0,0.3,0.2,-270,0,0,0"/><S T="12" X="65" Y="399" L="10" H="105" P="0,0,0.3,0.2,-90,0,0,0"/><S T="12" X="738" Y="399" L="10" H="105" P="0,0,0.3,0.2,90,0,0,0"/><S T="12" X="400" Y="297" L="166" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="400" Y="428" L="162" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="342" Y="249" L="47" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="459" Y="249" L="47" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="401" Y="249" L="67" H="10" P="0,0,0.3,0.2,0,0,0,0" v="90000"/><S T="12" X="478" Y="273" L="56" H="10" P="0,0,0.3,0.2,90,0,0,0" v="90000"/><S T="12" X="322" Y="273" L="56" H="10" P="0,0,0.3,0.2,90,0,0,0" v="90000"/><S T="12" X="400" Y="650" L="10" H="10" P="1,0,0.3,0.2,90,1,Infinity,0" c="4" v="90000"/><S T="12" X="400" Y="650" L="10" H="10" P="1,0,0.3,0.2,90,1,Infinity,0" c="4" v="89000"/><S T="12" X="400" Y="650" L="10" H="10" P="1,0,0.3,0.2,90,1,Infinity,0" c="4" v="88000"/><S T="12" X="400" Y="650" L="10" H="10" P="1,0,0.3,0.2,90,1,Infinity,0" c="4" v="87000"/><S T="12" X="400" Y="650" L="10" H="10" P="1,0,0.3,0.2,90,1,Infinity,0" c="4" v="86000"/><S T="12" X="400" Y="650" L="10" H="10" P="1,0,0.3,0.2,90,1,Infinity,0" c="4" v="85000"/></S><D><F X="351" Y="285" D=""/><F X="450" Y="284" D=""/><T X="399" Y="291" D=""/></D><O/><L><JD c="000000,250,1,0" P1="-313,-1676" P2="-313,2324"/><JD c="000000,250,1,0" P1="-113,-1666" P2="-113,2334"/><JD c="000000,250,1,0" P1="87,-1666" P2="87,2334"/><JD c="000000,250,1,0" P1="287,-1666" P2="287,2334"/><JD c="000000,250,1,0" P1="487,-1666" P2="487,2334"/><JD c="000000,250,1,0" P1="687,-1666" P2="687,2334"/><JD c="000000,250,1,0" P1="887,-1656" P2="887,2344"/><JD c="000000,250,1,0" P1="1087,-1646" P2="1087,2354"/><JD c="1500fb,10,1,0" P1="788,35" P2="788,633"/><JD c="1500fb,10,1,0" P1="10,35" P2="10,633"/><JD c="1500fb,10,1,0" P1="787,35" P2="12,35"/><JD c="1500fb,10,1,0" P1="788,633" P2="13,633"/><JD c="1500fb,10,1,0" P1="478,428" P2="323,428"/><JD c="1500fb,10,1,0" P1="400,353" P2="400,426"/><JD c="FFFFFF,10,1,0" M1="79" M2="79" P1="429,249" P2="371,249"/><JD c="FFFFFF,10,1,0" M1="79" M2="79" P1="478,296" P2="478,250"/><JD c="FFFFFF,10,1,0" M1="79" M2="79" P1="322,296" P2="322,250"/><JD c="1500fb,10,1,0" M1="80" M2="80" P1="429,249" P2="371,249"/><JD c="1500fb,10,1,0" M1="80" M2="80" P1="478,296" P2="478,250"/><JD c="1500fb,10,1,0" M1="80" M2="80" P1="322,296" P2="322,250"/><JD c="FFFFFF,10,1,0" M1="81" M2="81" P1="429,249" P2="371,249"/><JD c="FFFFFF,10,1,0" M1="81" M2="81" P1="478,296" P2="478,250"/><JD c="FFFFFF,10,1,0" M1="81" M2="81" P1="322,296" P2="322,250"/><JD c="1500fb,10,1,0" M1="82" M2="82" P1="429,249" P2="371,249"/><JD c="1500fb,10,1,0" M1="82" M2="82" P1="478,296" P2="478,250"/><JD c="1500fb,10,1,0" M1="82" M2="82" P1="322,296" P2="322,250"/><JD c="FFFFFF,10,1,0" M1="83" M2="83" P1="429,249" P2="371,249"/><JD c="FFFFFF,10,1,0" M1="83" M2="83" P1="478,296" P2="478,250"/><JD c="FFFFFF,10,1,0" M1="83" M2="83" P1="322,296" P2="322,250"/><JD c="1500fb,10,1,0" M1="84" M2="84" P1="429,249" P2="371,249"/><JD c="1500fb,10,1,0" M1="84" M2="84" P1="478,296" P2="478,250"/><JD c="1500fb,10,1,0" M1="84" M2="84" P1="322,296" P2="322,250"/><JD c="1500fb,10,1,0" P1="375,189" P2="375,118"/><JD c="1500fb,10,1,0" P1="426,189" P2="426,118"/><JD c="1500fb,10,1,0" P1="374,480" P2="374,559"/><JD c="1500fb,10,1,0" P1="426,478" P2="426,559"/><JD c="1500fb,10,1,0" P1="272,265" P2="272,193"/><JD c="1500fb,10,1,0" P1="530,265" P2="530,193"/><JD c="1500fb,10,1,0" P1="219,422" P2="219,246"/><JD c="1500fb,10,1,0" P1="582,422" P2="582,246"/><JD c="1500fb,10,1,0" P1="478,297" P2="322,297"/><JD c="1500fb,10,1,0" P1="271,403" P2="271,479"/><JD c="1500fb,10,1,0" P1="530,403" P2="530,475"/><JD c="1500fb,10,1,0" P1="166,266" P2="166,193"/><JD c="1500fb,10,1,0" P1="636,266" P2="636,193"/><JD c="1500fb,10,1,0" P1="166,402" P2="166,475"/><JD c="1500fb,10,1,0" P1="636,402" P2="636,475"/><JD c="1500fb,10,1,0" P1="115,162" P2="115,88"/><JD c="1500fb,10,1,0" P1="687,162" P2="687,88"/><JD c="1500fb,10,1,0" P1="115,506" P2="115,580"/><JD c="1500fb,10,1,0" P1="687,506" P2="687,580"/><JD c="1500fb,10,1,0" P1="62,217" P2="62,144"/><JD c="1500fb,10,1,0" P1="740,217" P2="740,144"/><JD c="1500fb,10,1,0" P1="62,451" P2="62,524"/><JD c="1500fb,10,1,0" P1="740,451" P2="740,524"/><JD c="1500fb,10,1,0" P1="361,249" P2="322,249"/><JD c="1500fb,10,1,0" P1="439,249" P2="478,249"/><JD c="1500fb,10,1,0" P1="375,191" P2="272,191"/><JD c="1500fb,10,1,0" P1="427,191" P2="530,191"/><JD c="1500fb,10,1,0" P1="374,480" P2="271,480"/><JD c="1500fb,10,1,0" P1="426,477" P2="530,477"/><JD c="1500fb,10,1,0" P1="241,139" P2="169,139"/><JD c="1500fb,10,1,0" P1="561,139" P2="633,139"/><JD c="1500fb,10,1,0" P1="241,529" P2="169,529"/><JD c="1500fb,10,1,0" P1="561,529" P2="633,529"/><JD c="1500fb,10,1,0" P1="320,87" P2="247,87"/><JD c="1500fb,10,1,0" P1="483,87" P2="555,87"/><JD c="1500fb,10,1,0" P1="319,583" P2="246,583"/><JD c="1500fb,10,1,0" P1="481,584" P2="552,584"/><JD c="1500fb,10,1,0" P1="215,191" P2="166,191"/><JD c="1500fb,10,1,0" P1="587,191" P2="636,191"/><JD c="1500fb,10,1,0" P1="215,477" P2="166,477"/><JD c="1500fb,10,1,0" P1="587,477" P2="636,477"/><JD c="1500fb,10,1,0" P1="113,217" P2="62,217"/><JD c="1500fb,10,1,0" P1="689,217" P2="740,217"/><JD c="1500fb,10,1,0" P1="113,451" P2="62,451"/><JD c="1500fb,10,1,0" P1="689,451" P2="740,451"/><JD c="1500fb,10,1,0" P1="114,87" P2="63,87"/><JD c="1500fb,10,1,0" P1="688,87" P2="739,87"/><JD c="1500fb,10,1,0" P1="114,581" P2="63,581"/><JD c="1500fb,10,1,0" P1="688,581" P2="739,581"/><JD c="1500fb,10,1,0" P1="113,269" P2="10,269"/><JD c="1500fb,10,1,0" P1="689,269" P2="788,269"/><JD c="1500fb,10,1,0" P1="113,399" P2="10,399"/><JD c="1500fb,10,1,0" P1="689,399" P2="788,399"/><JD c="000000,6,1,0" P1="787,35" P2="12,35"/><JD c="000000,6,1,0" P1="788,633" P2="13,633"/><JD c="000000,6,1,0" P1="478,428" P2="323,428"/><JD c="000000,6,1,0" P1="400,353" P2="400,426"/><JD c="000000,6,1,0" M1="79" M2="79" P1="429,249" P2="371,249"/><JD c="000000,6,1,0" M1="79" M2="79" P1="478,296" P2="478,250"/><JD c="000000,6,1,0" M1="79" M2="79" P1="322,296" P2="322,250"/><JD c="000000,6,1,0" P1="375,189" P2="375,118"/><JD c="000000,6,1,0" P1="426,189" P2="426,118"/><JD c="000000,6,1,0" P1="374,480" P2="374,559"/><JD c="000000,6,1,0" P1="426,478" P2="426,559"/><JD c="1500fb,3,1,0" P1="323,85" P2="323,141"/><JD c="1500fb,3,1,0" P1="479,85" P2="479,141"/><JD c="000000,6,1,0" P1="10,35" P2="10,633"/><JD c="1500fb,3,1,0" P1="322,585" P2="322,529"/><JD c="1500fb,3,1,0" P1="477,586" P2="477,530"/><JD c="1500fb,3,1,0" P1="197,40" P2="197,86"/><JD c="1500fb,3,1,0" P1="605,40" P2="605,86"/><JD c="1500fb,3,1,0" P1="196,628" P2="196,582"/><JD c="1500fb,3,1,0" P1="605,628" P2="605,582"/><JD c="000000,6,1,0" P1="272,265" P2="272,193"/><JD c="000000,6,1,0" P1="530,265" P2="530,193"/><JD c="000000,6,1,0" P1="219,422" P2="219,246"/><JD c="000000,6,1,0" P1="582,422" P2="582,246"/><JD c="000000,6,1,0" P1="478,297" P2="322,297"/><JD c="000000,6,1,0" P1="271,403" P2="271,479"/><JD c="000000,6,1,0" P1="530,403" P2="530,475"/><JD c="000000,6,1,0" P1="166,266" P2="166,193"/><JD c="000000,6,1,0" P1="636,266" P2="636,193"/><JD c="000000,6,1,0" P1="166,402" P2="166,475"/><JD c="000000,6,1,0" P1="636,402" P2="636,475"/><JD c="000000,6,1,0" P1="115,162" P2="115,88"/><JD c="000000,6,1,0" P1="687,162" P2="687,88"/><JD c="000000,6,1,0" P1="115,506" P2="115,580"/><JD c="000000,6,1,0" P1="687,506" P2="687,580"/><JD c="000000,6,1,0" P1="62,217" P2="62,144"/><JD c="000000,6,1,0" P1="740,217" P2="740,144"/><JD c="000000,6,1,0" P1="62,451" P2="62,524"/><JD c="000000,6,1,0" P1="740,451" P2="740,524"/><JD c="000000,6,1,0" P1="361,249" P2="322,249"/><JD c="000000,6,1,0" P1="439,249" P2="478,249"/><JD c="000000,6,1,0" P1="375,191" P2="272,191"/><JD c="000000,6,1,0" P1="427,191" P2="530,191"/><JD c="000000,6,1,0" P1="374,480" P2="271,480"/><JD c="000000,6,1,0" P1="426,477" P2="530,477"/><JD c="000000,6,1,0" P1="241,139" P2="169,139"/><JD c="000000,6,1,0" P1="561,139" P2="633,139"/><JD c="000000,6,1,0" P1="241,529" P2="169,529"/><JD c="000000,6,1,0" P1="561,529" P2="633,529"/><JD c="000000,6,1,0" P1="318,87" P2="247,87"/><JD c="000000,6,1,0" P1="484,87" P2="555,87"/><JD c="000000,6,1,0" P1="318,583" P2="246,583"/><JD c="000000,6,1,0" P1="482,584" P2="551.57,584"/><JD c="000000,6,1,0" P1="215,191" P2="166,191"/><JD c="000000,6,1,0" P1="587,191" P2="636,191"/><JD c="000000,6,1,0" P1="215,477" P2="166,477"/><JD c="000000,6,1,0" P1="587,477" P2="636,477"/><JD c="000000,6,1,0" P1="113,217" P2="62,217"/><JD c="000000,6,1,0" P1="689,217" P2="740,217"/><JD c="000000,6,1,0" P1="113,451" P2="62,451"/><JD c="000000,6,1,0" P1="689,451" P2="740,451"/><JD c="000000,6,1,0" P1="114,87" P2="63,87"/><JD c="000000,6,1,0" P1="688,87" P2="739,87"/><JD c="000000,6,1,0" P1="114,581" P2="63,581"/><JD c="000000,6,1,0" P1="688,581" P2="739,581"/><JD c="000000,6,1,0" P1="113,269" P2="10,269"/><JD c="000000,6,1,0" P1="689,269" P2="788,269"/><JD c="000000,6,1,0" P1="113,399" P2="10,399"/><JD c="000000,6,1,0" P1="689,399" P2="788,399"/><JD c="1500fb,3,1,0" P1="166,320" P2="166,348"/><JD c="1500fb,3,1,0" P1="634,320" P2="634,348"/><JD c="1500fb,3,1,0" P1="450,350" P2="450,378"/><JD c="1500fb,3,1,0" P1="319,350" P2="319,378"/><JD c="000000,6,1,0" P1="788,35" P2="788,633"/><JD c="1500fb,3,1,0" P1="269,320" P2="269,348"/><JD c="1500fb,3,1,0" P1="532,320" P2="532,348"/><JD c="1500fb,3,1,0" P1="62,320" P2="62,348"/><JD c="1500fb,3,1,0" P1="738,320" P2="738,348"/><JD c="1500fb,3,1,0" P1="480,350" P2="480,378"/><JD c="1500fb,3,1,0" P1="349,350" P2="349,378"/><JD c="1500fb,3,1,0" P1="429,40" P2="429,61"/><JD c="1500fb,3,1,0" P1="372,40" P2="372,61"/><JD c="1500fb,3,1,0" P1="429,628" P2="429,607"/><JD c="1500fb,3,1,0" P1="372,628" P2="372,607"/><JD c="1500fb,3,1,0" P1="295,92" P2="295,140"/><JD c="1500fb,3,1,0" P1="507,92" P2="507,140"/><JD c="1500fb,3,1,0" P1="294,578" P2="294,530"/><JD c="1500fb,3,1,0" P1="505,579" P2="505,531"/><JD c="1500fb,3,1,0" P1="165,40" P2="165,86"/><JD c="1500fb,3,1,0" P1="637,40" P2="637,86"/><JD c="1500fb,3,1,0" P1="164,628" P2="164,582"/><JD c="1500fb,3,1,0" P1="637,628" P2="637,582"/><JD c="1500fb,3,1,0" P1="429,61" P2="373,61"/><JD c="1500fb,3,1,0" P1="429,607" P2="373,607"/><JD c="1500fb,3,1,0" P1="323,141" P2="295,141"/><JD c="1500fb,3,1,0" P1="479,141" P2="507,141"/><JD c="1500fb,3,1,0" P1="269,348" P2="224,348"/><JD c="1500fb,3,1,0" P1="532,348" P2="577,348"/><JD c="1500fb,3,1,0" P1="269,320" P2="224,320"/><JD c="1500fb,3,1,0" P1="532,320" P2="577,320"/><JD c="1500fb,3,1,0" P1="322,529" P2="294,529"/><JD c="1500fb,3,1,0" P1="477,530" P2="505,530"/><JD c="1500fb,3,1,0" P1="197,86.17" P2="166,86.17"/><JD c="1500fb,3,1,0" P1="605,86.17" P2="636,86.17"/><JD c="1500fb,3,1,0" P1="196,581.83" P2="165,581.83"/><JD c="1500fb,3,1,0" P1="605,581.83" P2="636,581.83"/><JD c="1500fb,3,1,0" P1="166,320" P2="63,320"/><JD c="1500fb,3,1,0" P1="634,320" P2="737,320"/><JD c="1500fb,3,1,0" P1="450,350" P2="480,350"/><JD c="1500fb,3,1,0" P1="319,350" P2="349,350"/><JD c="1500fb,3,1,0" P1="166,348" P2="63,348"/><JD c="1500fb,3,1,0" P1="634,348" P2="737,348"/><JD c="1500fb,3,1,0" P1="450,378" P2="480,378"/><JD c="1500fb,3,1,0" P1="319,378" P2="349,378"/><JD c="000000,3,1,0" P1="219.84,323" P2="243.25,323"/><JD c="000000,3,1,0" P1="581.16,323" P2="557.75,323"/><JD c="000000,3,1,0" P1="223,323" P2="223,344"/><JD c="000000,3,1,0" P1="578,323" P2="578,344"/><JD c="000000,3,1,0" P1="169,629" P2="191,629"/><JD c="000000,3,1,0" P1="632,629" P2="610,629"/><JD c="000000,3,1,0" P1="297,579" P2="317,579"/><JD c="000000,3,1,0" P1="502,580" P2="482,580"/><JD c="000000,3,1,0" P1="298,91" P2="318,91"/><JD c="000000,3,1,0" P1="504,91" P2="484,91"/><JD c="000000,3,1,0" P1="170,39" P2="192,39"/><JD c="000000,3,1,0" P1="632,39" P2="610,39"/><JD c="000000,3,1,0" P1="377,629" P2="425,629"/><JD c="000000,3,1,0" P1="377,39" P2="425,39"/><JD c="000000,3,1,0" P1="219.84,345" P2="243.25,345"/><JD c="000000,3,1,0" P1="581.16,345" P2="557.75,345"/><JD c="000000,3,1,0" P1="193,631" P2="193,608"/><JD c="000000,3,1,0" P1="608,631" P2="608,608"/><JD c="000000,3,1,0" P1="319,581" P2="319,558"/><JD c="000000,3,1,0" P1="480,583" P2="480,560"/><JD c="000000,3,1,0" P1="320,87" P2="320,112"/><JD c="000000,3,1,0" P1="482,87" P2="482,112"/><JD c="000000,3,1,0" P1="194,37" P2="194,60"/><JD c="000000,3,1,0" P1="608,37" P2="608,60"/><JD c="000000,3,1,0" P1="426,631" P2="426,617"/><JD c="000000,3,1,0" P1="375,631" P2="375,617"/><JD c="000000,3,1,0" P1="426,37" P2="426,51"/><JD c="000000,3,1,0" P1="375,37" P2="375,51"/><JD c="000000,3,1,0" P1="167,631" P2="167,608"/><JD c="000000,3,1,0" P1="634,631" P2="634,608"/><JD c="000000,3,1,0" P1="297,581" P2="297,558"/><JD c="000000,3,1,0" P1="502,582" P2="502,559"/><JD c="000000,3,1,0" P1="298,89" P2="298,112"/><JD c="000000,3,1,0" P1="504,89" P2="504,112"/><JD c="000000,3,1,0" P1="168,37" P2="168,60"/><JD c="000000,3,1,0" P1="634,37" P2="634,60"/></L></Z></C>]]}
pacmice_maps["pacmice_5"].pathes = {{1, 1}, {2, 1}, {3, 1}, {4, 1}, {5, 1}, {8, 1}, {9, 1}, {10, 1}, {11, 1}, {12, 1}, {13, 1}, {17, 1}, {18, 1}, {19, 1}, {20, 1}, {21, 1}, {22, 1}, {25, 1}, {26, 1}, {27, 1}, {28, 1}, {29, 1}, {1, 2}, {5, 2}, {8, 2}, {13, 2}, {14, 2}, {15, 2}, {16, 2}, {17, 2}, {22, 2}, {25, 2}, {29, 2}, {1, 3}, {2, 3}, {3, 3}, {5, 3}, {6, 3}, {7, 3}, {8, 3}, {9, 3}, {10, 3}, {13, 3}, {15, 3}, {17, 3}, {20, 3}, {21, 3}, {22, 3}, {23, 3}, {24, 3}, {25, 3}, {27, 3}, {28, 3}, {29, 3}, {1, 4}, {3, 4}, {5, 4}, {10, 4}, {13, 4}, {15, 4}, {17, 4}, {20, 4}, {25, 4}, {27, 4}, {29, 4}, {1, 5}, {3, 5}, {5, 5}, {6, 5}, {7, 5}, {8, 5}, {9, 5}, {10, 5}, {11, 5}, {12, 5}, {13, 5}, {15, 5}, {17, 5}, {18, 5}, {19, 5}, {20, 5}, {21, 5}, {22, 5}, {23, 5}, {24, 5}, {25, 5}, {27, 5}, {29, 5}, {1, 6}, {3, 6}, {4, 6}, {5, 6}, {9, 6}, {15, 6}, {21, 6}, {25, 6}, {26, 6}, {27, 6}, {29, 6}, {1, 7}, {5, 7}, {7, 7}, {8, 7}, {9, 7}, {11, 7}, {12, 7}, {13, 7}, {14, 7}, {15, 7}, {16, 7}, {17, 7}, {18, 7}, {19, 7}, {21, 7}, {22, 7}, {23, 7}, {25, 7}, {29, 7}, {1, 8}, {2, 8}, {3, 8}, {4, 8}, {5, 8}, {7, 8}, {9, 8}, {11, 8}, {19, 8}, {21, 8}, {23, 8}, {25, 8}, {26, 8}, {27, 8}, {28, 8}, {29, 8}, {5, 9}, {7, 9}, {9, 9}, {11, 9}, {19, 9}, {21, 9}, {23, 9}, {25, 9}, {1, 10}, {2, 10}, {3, 10}, {4, 10}, {5, 10}, {6, 10}, {7, 10}, {9, 10}, {10, 10}, {11, 10}, {19, 10}, {20, 10}, {21, 10}, {23, 10}, {24, 10}, {25, 10}, {26, 10}, {27, 10}, {28, 10}, {29, 10}, {1, 11}, {7, 11}, {11, 11}, {12, 11}, {13, 11}, {14, 11}, {15, 11}, {16, 11}, {17, 11}, {18, 11}, {19, 11}, {23, 11}, {29, 11}, {1, 12}, {7, 12}, {11, 12}, {14, 12}, {16, 12}, {19, 12}, {23, 12}, {29, 12}, {1, 13}, {2, 13}, {3, 13}, {4, 13}, {5, 13}, {6, 13}, {7, 13}, {9, 13}, {10, 13}, {11, 13}, {14, 13}, {16, 13}, {19, 13}, {20, 13}, {21, 13}, {23, 13}, {24, 13}, {25, 13}, {26, 13}, {27, 13}, {28, 13}, {29, 13}, {5, 14}, {7, 14}, {9, 14}, {11, 14}, {12, 14}, {13, 14}, {14, 14}, {16, 14}, {17, 14}, {18, 14}, {19, 14}, {21, 14}, {23, 14}, {25, 14}, {1, 15}, {2, 15}, {3, 15}, {4, 15}, {5, 15}, {7, 15}, {9, 15}, {11, 15}, {19, 15}, {21, 15}, {23, 15}, {25, 15}, {26, 15}, {27, 15}, {28, 15}, {29, 15}, {1, 16}, {5, 16}, {7, 16}, {8, 16}, {9, 16}, {11, 16}, {12, 16}, {13, 16}, {14, 16}, {15, 16}, {16, 16}, {17, 16}, {18, 16}, {19, 16}, {21, 16}, {22, 16}, {23, 16}, {25, 16}, {29, 16}, {1, 17}, {3, 17}, {4, 17}, {5, 17}, {9, 17}, {15, 17}, {21, 17}, {25, 17}, {26, 17}, {27, 17}, {29, 17}, {1, 18}, {3, 18}, {5, 18}, {6, 18}, {7, 18}, {8, 18}, {9, 18}, {10, 18}, {11, 18}, {12, 18}, {13, 18}, {15, 18}, {17, 18}, {18, 18}, {19, 18}, {20, 18}, {21, 18}, {22, 18}, {23, 18}, {24, 18}, {25, 18}, {27, 18}, {29, 18}, {1, 19}, {3, 19}, {5, 19}, {10, 19}, {13, 19}, {15, 19}, {17, 19}, {20, 19}, {25, 19}, {27, 19}, {29, 19}, {1, 20}, {2, 20}, {3, 20}, {5, 20}, {6, 20}, {7, 20}, {8, 20}, {9, 20}, {10, 20}, {13, 20}, {15, 20}, {17, 20}, {20, 20}, {21, 20}, {22, 20}, {23, 20}, {24, 20}, {25, 20}, {27, 20}, {28, 20}, {29, 20}, {1, 21}, {5, 21}, {8, 21}, {13, 21}, {14, 21}, {15, 21}, {16, 21}, {17, 21}, {22, 21}, {25, 21}, {29, 21}, {1, 22}, {2, 22}, {3, 22}, {4, 22}, {5, 22}, {8, 22}, {9, 22}, {10, 22}, {11, 22}, {12, 22}, {13, 22}, {17, 22}, {18, 22}, {19, 22}, {20, 22}, {21, 22}, {22, 22}, {25, 22}, {26, 22}, {27, 22}, {28, 22}, {29, 22}}
pacmice_maps["pacmice_5"].foods = {{x = 87, y = 61}, {x = 282 , y = 61}, {x = 517, y = 61}, {x = 716, y = 61}, {x = 400, y = 88}, {x = 400, y = 218}, {x = 400, y = 330}, {x = 400, y = 522}, {x = 87, y = 195}, {x = 716, y = 195}, {x = 36, y = 330}, {x = 245, y = 373}, {x = 193, y = 452}, {x = 87, y = 517}, {x = 281, y = 610}, {x = 512, y = 610}, {x = 712, y = 519}, {x = 609, y = 452}, {x = 546, y = 373}, {x = 762, y = 330}}
-- rotation
pshy.mapdb_rotations["pacmice"] = {items = {}}
-- pshy mapdbs
for i_map, map in pairs(pacmice_maps) do
	local mapname = "pacmice_" .. tostring(i_map)
	pshy.mapdb_maps[mapname] = pacmice_maps[i_map]
	map.replace_func = pacmice_GetMap
	map.autoskip = false
	table.insert(pshy.mapdb_rotations["pacmice"].items, mapname)
	print("added " .. mapname)
end
-- colors
pacmice_map_colors = {"0000ff", "00ff00", "ff0000", "ffff00", "00ffff", "ff00ff", "ff7700", "d200ff"}
pacmice_map_color_index = math.random(#pacmice_map_colors)
-- food images
pacmice_food_images = {"17ae46fd894.png", "17ae46ff007.png", "17ae4700777.png", "17ae4701ee9.png", "17ae4703658.png", "17ae4704dcc.png", "17ae4706540.png", "17ae4707cb0.png", "17ae4709422.png", "17ae470ab94.png", "17ae470c307.png", "17ae470da77.png", "17ae470f1e8.png", "17ae4710959.png", "17ae47120dd.png", "17ae471383b.png", "17ae4714fad.png", "17ae4716720.png", "17ae4717e93.png", "17ae4719605.png"}
--- Internal use:
pacmice_map = nil				-- current map
pacmice_cur_pilot = nil			-- for generating pathes
pacmice_cur_x = 0
pacmice_cur_y = 0
pacmice_cur_generating = false
pacmice_auto_generating = false
pacmice_auto_x = nil
pacmice_auto_y = nil
pacmice_auto_object_id = nil
pacmice_pacmans = {}			-- map of pacmouces (key is the player name)
pacmice_auto_respawn = true
pacmice_pacmouse_count = 0
pacmice_round_over = false
pacmice_animations = {}
pacmice_animations[1] = {"17afe1cf978.png", "17afe1ce20a.png"}
pacmice_animations[2] = {"17afe2a6882.png", "17afe1d18bc.png"}
--- Custom bonus for pacmice foods
function pacmice_FoodGrabbedCallback(player_name, bonus)
	pshy.scores_Add(player_name, 2)
	pshy.bonus_Disable(bonus.id)
end
for i_image, image_name in pairs(pacmice_food_images) do
	pshy.bonus_types[image_name]	= {image = image_name, func = pacmice_FoodGrabbedCallback}
end
--- For every player, or when a player joins.
function pacmice_TouchPlayer(player_name)
	ui.addTextArea(pacmice_arbitrary_help_btn_id, "<p align='center'><font size='12'><a href='event:pcmd help'>help</a></font></p>", player_name, 5, 25, 40, 20, 0x111111, 0xFFFF00, 0.2, true)
end
--- Alive mice count.
function pacmice_CountMiceAlive()
	local count = 0
	for player_name, player in pairs(tfm.get.room.playerList) do
		if not player.isDead and not pacmice_pacmans[player_name] then
			count = count + 1
		end
	end
	return count
end
--- Pop the best player's score.
function pacmice_PopBestScorePlayer()
	local best_player_name = nil
	for player_name in pairs(tfm.get.room.playerList) do
		if not best_player_name or pshy.scores[player_name] > pshy.scores[best_player_name] then
			best_player_name = player_name
		end
	end
	return best_player_name
end
--- TFM event eventNewGame()
-- Make the next pacmouse.
function eventNewGame()
	-- misc
	ui.setMapName("PAC-MICE")
	-- spawn scrolling
	tfm.exec.addPhysicObject(20, pacmice_map.web_x, 200, {type = tfm.enum.ground.water, width = 80, height = 4000, foreground = false, color = 0x1, miceCollision = false})
	tfm.exec.addPhysicObject(21, pacmice_map.web_x, pacmice_map.y + pacmice_map.grid_h * pacmice_map.cell_h, {type = tfm.enum.ground.rectangle, width = 200, height = 20, foreground = true, color = 0xff0000, miceCollision = true})
	tfm.exec.addPhysicObject(22, pacmice_map.web_x, 200, {type = tfm.enum.ground.rectangle, width = 200, height = 4000, foreground = true, color = 0x1, miceCollision = false})
	pacmice_round_over = false
	if pacmice_cur_generating or pacmice_cur_pilot then
		return
	end
	if pacmice_CountMiceAlive() >= 1 then
		local pacmouse_player = pacmice_PopBestScorePlayer()
		pacmice_CreatePacman(pacmouse_player)
		if pacmice_map.pac_count == 1 or pacmice_CountMiceAlive() <= 1 then
			tfm.exec.chatMessage("<b><fc>The pacmouse is now <j>" .. pshy.GetPlayerNick(pacmouse_player) .. "</j></fc></b>", nil)
			ui.setShamanName(pshy.GetPlayerNick(pacmouse_player))
		else
			old_score = pshy.scores[pacmouse_player]
			pshy.scores[pacmouse_player] = 0
			local pacmouse_player_2 = pacmice_PopBestScorePlayer()
			pshy.scores[pacmouse_player] = old_score
			pacmice_CreatePacman(pacmouse_player_2)
			tfm.exec.chatMessage("<b><fc>The pacmice are now <j>" .. pshy.GetPlayerNick(pacmouse_player) .. "</j> and <j>" .. pshy.GetPlayerNick(pacmouse_player_2) .. "</j></fc></b>", nil)
			pacmice_pacmans[pacmouse_player_2].image_animation_number = 2
			ui.setShamanName(pshy.GetPlayerNick(pacmouse_player) .. " and " .. pshy.GetPlayerNick(pacmouse_player_2))
		end
	end
	-- add bonuses
	for i_bonus, bonus in pairs(pacmice_map.foods) do
		local bonus_type = pacmice_food_images[math.random(#pacmice_food_images)]
		pshy.bonus_Add(bonus_type, bonus.x, bonus.y)
	end
end
--- Create a pacman.
-- @player Player's Name#0000.
function pacmice_CreatePacman(player_name)
	if pacmice_pacmans[player_name] then
		error("should not come here")
		pacmice_DestroyPacman(player_name)
	end
	pacmice_pacmans[player_name] = {}
	local pacman = pacmice_pacmans[player_name]
	pacman.player_name = player_name
	pacman.cell_x = pacmice_map.pathes[#pacmice_map.pathes][1]
	pacman.cell_y = pacmice_map.pathes[#pacmice_map.pathes][2]
	pacman.cell_vx = -1
	pacman.cell_vy = 0
	pacman.wish_vx = -1
	pacman.wish_vy = 0
	pacman.image_id = nil
	pacman.direction = 0
	pacman.speed = 50
	pacman.size = 50
	pacman.image_animation_number = pacmice_pacmouse_count % #pacmice_animations + 1
	pacman.image_animation_index = 0
	pacman.pacman_index = pacmice_pacmouse_count
	-- player
	tfm.exec.setShaman(player_name, false)
	tfm.exec.removeCheese(player_name)
	tfm.exec.respawnPlayer(player_name)
	tfm.exec.freezePlayer(player_name, true)
	tfm.exec.movePlayer(player_name, pacmice_map.web_x, pacman.cell_y * pacmice_map.cell_h + pacmice_map.y, false, 0, 0, false)
	--tfm.exec.changePlayerSize(player_name, (pacman.size - 4) / 35 )
	pacmice_pacmouse_count = pacmice_pacmouse_count + 1
	-- keys
	system.bindMouse(player_name, true)
	system.bindKeyboard(player_name, pshy.keycodes.UP, true, true)
	system.bindKeyboard(player_name, pshy.keycodes.DOWN, true, true)
	system.bindKeyboard(player_name, pshy.keycodes.LEFT, true, true)
	system.bindKeyboard(player_name, pshy.keycodes.RIGHT, true, true)
end
--- Destroy a pacman.
-- @player Player's Name#0000.
function pacmice_DestroyPacman(player_name)
	if pacmice_pacmans[player_name] then
		local pacman = pacmice_pacmans[player_name]
		if pacman.image_id then
			tfm.exec.removeImage(pacman.image_id)
		end
		pacmice_pacmans[player_name] = nil
		pacmice_pacmouse_count = pacmice_pacmouse_count - 1
		if not pacmice_round_over then
			tfm.exec.killPlayer(player_name)
		end
		tfm.get.room.playerList[player_name].isDead = true
		tfm.exec.removePhysicObject(pacman.pacman_index * 2 + 1)
		tfm.exec.removePhysicObject(pacman.pacman_index * 2 + 2)
		pshy.scores_Set(player_name, 0)
	end
end
--- Get a cell screen coordinates.
function pacmice_GetCellDrawCoords(x, y)
	local x = x * pacmice_map.cell_w + pacmice_map.x
	local y = y * pacmice_map.cell_h + pacmice_map.y
	return x, y
end
--- Draw a pacman.
-- @player Player's Name#0000.
function pacmice_DrawPacman(player_name)
	local pacman = pacmice_pacmans[player_name]
	local x, y = pacmice_GetCellDrawCoords(pacman.cell_x, pacman.cell_y)
	local animation = pacmice_animations[pacman.image_animation_number]
	-- next image
	pacman.image_animation_index = (pacman.image_animation_index + 1) % #animation
	local image_code = (animation)[pacman.image_animation_index + 1] -- jerry: 1718e698ac9.png -- pacman: 
	-- @todo
	old_image_id = pacman.image_id
	local size = (pacmice_map.cell_w * 2) - pacmice_map.wall_size
	--tfm.exec.addPhysicObject(5, x, y, {type = tfm.enum.ground.rectangle, width = size, height = size, foreground = false, color = 0xffff00, miceCollision = false})
	pacman.image_id = tfm.exec.addImage(image_code, "!0", x, y, nil, 1.0, 1.0, pacman.direction, 1.0, 0.5, 0.5)
	--pacman.image_id = tfm.exec.addImage("1718e698ac9.png", "$" .. player_name, 0, 0, nil, 0.5, 0.5, pacman.direction, 1.0, 0.5, 0.5)
	if old_image_id then
		tfm.exec.removeImage(old_image_id)
	end
	-- acid
	tfm.exec.addPhysicObject(pacman.pacman_index * 2 + 1, x, y, {type = tfm.enum.ground.acid, width = size, height = size, foreground = false, color = 0x0, miceCollision = true, groundCollision = false})
	tfm.exec.addPhysicObject(pacman.pacman_index * 2 + 2, x, y, {type = tfm.enum.ground.rectangle, width = size, height = size, foreground = false, color = 0x1, miceCollision = false, groundCollision = false})
	-- move the player
	tfm.exec.movePlayer(player_name, 0, 0, true, 0, (y - tfm.get.room.playerList[player_name].y) / 5 + 10 + pacman.cell_vy * 20, false)
end
--- Get a cell value.
function pacmice_GridGet(x, y)
	if x > pacmice_map.grid_w or y > pacmice_map.grid_h then
		return false
	end
	return pacmice_map.linear_grid[y * pacmice_map.grid_w + x]
end
--- Set a cell value.
function pacmice_GridSet(x, y, value)
	pacmice_map.linear_grid[y * pacmice_map.grid_w + x] = value
end
--- Redraw the cursor.
function pacmice_DrawCursor()
	local x = pacmice_cur_x * pacmice_map.cell_w + pacmice_map.x
	local y = pacmice_cur_y * pacmice_map.cell_h + pacmice_map.y
	if pacmice_cur_pilot then
		tfm.exec.addPhysicObject(23, x + pacmice_map.cell_w / 2, y, {type = tfm.enum.ground.rectangle, width = 5, height = 2000, foreground = false, color = 0xdd4400, miceCollision = false, groundCollision = false})
		tfm.exec.addPhysicObject(24, x - pacmice_map.cell_w / 2, y, {type = tfm.enum.ground.rectangle, width = 5, height = 2000, foreground = false, color = 0xdd4400, miceCollision = false, groundCollision = false})
		tfm.exec.addPhysicObject(25, x, y + pacmice_map.cell_h / 2, {type = tfm.enum.ground.rectangle, width = 2000, height = 5, foreground = false, color = 0xdd4400, miceCollision = false, groundCollision = false})
		tfm.exec.addPhysicObject(26, x, y - pacmice_map.cell_h / 2, {type = tfm.enum.ground.rectangle, width = 2000, height = 5, foreground = false, color = 0xdd4400, miceCollision = false, groundCollision = false})
	else
		tfm.exec.removeObject(23)
		tfm.exec.removeObject(24)
		tfm.exec.removeObject(25)
		tfm.exec.removeObject(26)
	end
end
--- Move the generation cursor, handling colisions.
function pacmice_MoveCursor(x, y)
	if not pacmice_cur_generating then
		-- map bounds
		if x < 0 or y < 0 or x >= pacmice_map.grid_w or y >= pacmice_map.grid_h then
			print("out of bounds")
			return
		end
		-- walls
		if not pacmice_GridGet(x, y) then
			return
		end
	end
	pacmice_cur_x = x
	pacmice_cur_y = y
	if pacmice_cur_generating then
		pacmice_GridSet(x, y, true)
	end
end
--- Get a vector from a direction key.
function pacmice_KeycodeToVector(keycode)
	if keycode == pshy.keycodes.UP then
		return 0, -1
	elseif keycode == pshy.keycodes.DOWN then
		return 0, 1
	elseif keycode == pshy.keycodes.LEFT then
		return -1, 0
	elseif keycode == pshy.keycodes.RIGHT then
		return 1, 0
	end
end
--- Get a direction from a vector.
function pacmice_VectorToDirection(x, y)
	if x == 1 and y == 0 then
		return 0
	elseif x == 0 and y == 1 then
		return (math.pi / 2) * 1
	elseif x == -1 and y == 0 then
		return (math.pi / 2) * 2
	elseif x == 0 and y == -1 then
		return (math.pi / 2) * 3
	end
	error("unexpected")
end
--- Get grid coordinates from a point on screen.
function pacmice_GetGridCoords(x, y)
	x = math.floor((x - pacmice_map.x) / pacmice_map.cell_w + 0.5)
	y = math.floor((y - pacmice_map.y) / pacmice_map.cell_h + 0.5)
	return x, y
end
--- Export the grid.
function pacmice_GridExportPathes(player_name)
	local total = "{"
	-- generate export string
	for y = 0, (pacmice_map.grid_h - 1) do
		for x = 0, (pacmice_map.grid_w - 1) do
			if pacmice_GridGet(x, y) then
				if #total > 1 then
					total = total .. ", "
				end
				total = total .. "{" .. tostring(x) .. ", " .. tostring(y) .. "}"
			end
		end
	end
	total = total .. "}"
	-- export
	while #total > 0 do
		subtotal = string.sub(total, 1, 180)
		tfm.exec.chatMessage(subtotal, player_name)
		total = string.sub(total, 181, #total)
	end
end
--- TFM event eventMouse.
function eventMouse(player_name, x, y)
	if player_name == pacmice_cur_pilot then
		x, y = pacmice_GetGridCoords(x, y)
		pacmice_MoveCursor(x, y)
		pacmice_DrawCursor()
		return true
	end
end
--- TFM event eventkeyboard.
function eventKeyboard(player_name, keycode, down, x, y)
	if player_name == pacmice_cur_pilot and (keycode == 0 or keycode == 1 or keycode == 2 or keycode == 3) then
		vx, vy = pacmice_KeycodeToVector(keycode)
		pacmice_MoveCursor(pacmice_cur_x + vx, pacmice_cur_y + vy)
		pacmice_DrawCursor()
	end
	local pacman = pacmice_pacmans[player_name]
	if pacman and (keycode == 0 or keycode == 1 or keycode == 2 or keycode == 3) then
		pacman.wish_vx, pacman.wish_vy = pacmice_KeycodeToVector(keycode)
	end
end
--- TFM event eventLoop.
function eventLoop(time, time_remaining)
	-- auto generating
	if pacmice_auto_generating then
		-- handle previous
		if pacmice_auto_object_id and pacmice_auto_x then
			local tfm_object = tfm.get.room.objectList[pacmice_auto_object_id]
			if tfm_object and tfm_object.id == pacmice_auto_object_id then
				local spawn_x, spawn_y = pacmice_GetCellDrawCoords(pacmice_auto_x, pacmice_auto_y)
				if spawn_x == tfm_object.x and spawn_y == tfm_object.y and tfm_object.angle == 0 and tfm_object.vx == 0 and tfm_object.vy == 0 then
					pacmice_GridSet(pacmice_auto_x, pacmice_auto_y, true)
				else
					pacmice_GridSet(pacmice_auto_x, pacmice_auto_y, false)
				end
				--print("expected x: " .. tostring(spawn_x) " y: " .. tostring(spawn_y) .. " got x: " .. tfm.object.x)
			else
				return
			end
		end
		-- first 
		if not pacmice_auto_x then
			pacmice_auto_x = 0 -- TODO TODO TODO TODO TODO TODO
			pacmice_auto_y = 1 --  TODO TODO TODO TODO TODO
		else
			pacmice_auto_x = pacmice_auto_x + 1
			if pacmice_auto_x >= pacmice_map.grid_w then
				pacmice_auto_x = 0
				pacmice_auto_y = pacmice_auto_y + 1
				tfm.exec.chatMessage("Generating... " .. tostring(math.floor(pacmice_auto_y / pacmice_map.grid_h * 100) .. "%"))
				if pacmice_auto_y >= pacmice_map.grid_h then
					pacmice_auto_x = nil
					pacmice_auto_y = nil
					pacmice_auto_generating = false
					tfm.exec.chatMessage("Finished generating!")
					return
				end
			end
		end
		-- spawn object
		local spawn_x, spawn_y = pacmice_GetCellDrawCoords(pacmice_auto_x, pacmice_auto_y)
		if not pacmice_auto_object_id then
			pacmice_auto_object_id = tfm.exec.addShamanObject(tfm.enum.shamanObject.ball, spawn_x, spawn_y, 0, 0, 0, true)
		else
			tfm.exec.moveObject(pacmice_auto_object_id, spawn_x, spawn_y, false, 0, 0, false, 0, 0)
		end
	end
	-- skip this if generating
	if pacmice_cur_generating or pacmice_cur_pilot then
		return
	end
	-- next game
	if time_remaining <= 1 then
		for player_name, player in pairs(tfm.get.room.playerList) do
			if not player.isDead then
				tfm.exec.playerVictory(player_name)
				pshy.scores_Add(player_name, 10)
			end
		end
	end
	if time_remaining <= 0 then
		pacmice_round_over = true
		local pacmans_names = {}
		for player_name in pairs(pacmice_pacmans) do
			pacmans_names[player_name] = true
		end
		for player_name in pairs(pacmans_names) do
			pacmice_DestroyPacman(player_name)
		end
		tfm.exec.newGame("pacmice")
	elseif pacmice_CountMiceAlive() <= 0 then
		tfm.exec.setGameTime(8, false)
	else
		local is_pacmouse = false
		for player_name in pairs(pacmice_pacmans) do
			is_pacmouse = true
		end
		if not is_pacmouse then
			tfm.exec.setGameTime(8, false)
		end
	end
end
--- pshy event eventLoopMore.
function eventLoopMore(time, time_remaining)
	for player_name, pacman in pairs(pacmice_pacmans) do
		--pacman.cell_x, pacman.cell_y = GetGridCoords(tfm.get.room.playerList[player_name].x, tfm.get.room.playerList[player_name].y)
		local wish_x = pacman.cell_x + pacman.wish_vx
		local wish_y = pacman.cell_y + pacman.wish_vy
		if pacmice_GridGet(wish_x, wish_y) then
			pacman.cell_vx = pacman.wish_vx
			pacman.cell_vy = pacman.wish_vy
		end
		if pacman.cell_vx ~= 0 or pacman.cell_vy ~= 0 then
			local seen_x = pacman.cell_x + pacman.cell_vx
			local seen_y = pacman.cell_y + pacman.cell_vy
			if pacmice_GridGet(seen_x, seen_y) then
				pacman.cell_x = seen_x
				pacman.cell_y = seen_y
				pacman.direction = pacmice_VectorToDirection(pacman.cell_vx, pacman.cell_vy)
			else		
				pacman.cell_vx = 0
				pacman.cell_vy = 0
			end
		end
--		pacman.cell_vx = pacman.wish_vx
--		pacman.cell_vy = pacman.wish_vy
--		pacman.direction = VectorToDirection(pacman.cell_vx, pacman.cell_vy)
--		tfm.exec.movePlayer(player_name, 0, 0, true, pacman.cell_vx * pacman.speed, pacman.cell_vy * pacman.speed, false)
		pacmice_DrawPacman(player_name)
	end
end
--- TFM event eventnewPlayer.
function eventNewPlayer(player_name)
	if auto_respawn and not pacmice_pacmans[player_name] then
		tfm.exec.respawnPlayer(player_name)
	end
	-- misc
	pacmice_TouchPlayer(player_name)
	ui.setMapName("PAC-MICE")
end
--- TFM event eventPlayerWon
function eventPlayerWon(player_name)
	if not pacmice_pacmans[player_name] then
		if pacmice_round_over then
			pshy.scores_Add(player_name, 10)
		else
			pshy.scores_Add(player_name, 16)
		end	
	end
end
--- TFM event eventPlayerDied.
function eventPlayerDied(player_name)
	if pacmice_pacmans[player_name] then
		pacmice_DestroyPacman(player_name)
	elseif auto_respawn then
		tfm.exec.respawnPlayer(player_name)
	else
		if not pacmice_round_over then
			pshy.scores_Add(player_name, 1)	
		end
	end
end
--- !pacmouse
function pacmice_ChatCommandPackmouse(user, target)
	target = target or user
	if target ~= user then
		if target ~= user and not pshy.HavePerm(user, "!pacmouse-others") then
			return false, "You cant use this command on others :c"
		end
		local reason
		target, reason = pshy.FindPlayerName(target)
		if not target then
			return false, reason
		end
	end
	if pacmice_pacmans[target] then
		pacmice_DestroyPacman(target)
	else
		if pacmice_pacmouse_count >= 2 then
			return false, "Too many pacmice :c"
		end
		pacmice_CreatePacman(target)
	end
end
pshy.chat_commands["pacmouse"] = {func = pacmice_ChatCommandPackmouse, desc = "turn into a pacmouse", argc_min = 0, argc_max = 1, arg_types = {"string"}, arg_names = {"Target#0000"}}
pshy.help_pages["pacmice"].commands["pacmouse"] = pshy.chat_commands["pacmouse"]
pshy.perms.admins["!pacmouse"] = true
--- !generatepathes
function pacmice_ChatCommandPackmiceGenerate(user, target)
	target = target or user
	if target ~= user and not pshy.HavePerm(user, "!pacmouse-others") then
		return false, "You cant use this command on others :c"
	end
	if pacmice_cur_pilot ~= target or not pacmice_cur_generating then
		pacmice_cur_pilot = target
		pacmice_cur_generating = true
		system.bindMouse(target, true)
		system.bindKeyboard(target, pshy.keycodes.UP, true, true)
		system.bindKeyboard(target, pshy.keycodes.DOWN, true, true)
		system.bindKeyboard(target, pshy.keycodes.LEFT, true, true)
		system.bindKeyboard(target, pshy.keycodes.RIGHT, true, true)
		tfm.exec.freezePlayer(target, true)
		tfm.exec.chatMessage("Generating!", user)
	else
		pacmice_cur_generating = false
		pacmice_GridExportPathes(target)
		tfm.exec.freezePlayer(target, false)
		tfm.exec.chatMessage("No longer generating.", user)
	end
end
pshy.chat_commands["generatepathes"] = {func = pacmice_ChatCommandPackmiceGenerate, desc = "generate the new map's pathes (see source)", argc_min = 0, argc_max = 1, arg_types = {"player"}, arg_names = {"Target#0000"}}
pshy.help_pages["pacmice"].commands["generatepathes"] = pshy.chat_commands["generatepathes"]
pshy.perms.admins["!generatepathes"] = true
--- !autogeneratepathes
function pacmice_ChatCommandPackmiceGenerate(user)
	local target = user
	if pacmice_cur_pilot ~= target or not pacmice_auto_generating then
		pacmice_cur_pilot = target
		pacmice_auto_generating = true
		tfm.exec.setWorldGravity(0, 0)
		tfm.exec.chatMessage("Auto generating!", user)
	else
		pacmice_auto_generating = false
		pacmice_GridExportPathes(target)
		tfm.exec.chatMessage("No longer auto generating.", user)
	end
end
pshy.chat_commands["autogeneratepathes"] = {func = pacmice_ChatCommandPackmiceGenerate, desc = "autogenerate the new map's pathes (see source)", argc_min = 0, argc_max = 0}
pshy.help_pages["pacmice"].commands["autogeneratepathes"] = pshy.chat_commands["autogeneratepathes"]
pshy.perms.admins["!autogeneratepathes"] = true
--- !skip
function pacmice_ChatCommandSkip(user)
	tfm.exec.setGameTime(1)
end
pshy.chat_commands["skip"] = {func = pacmice_ChatCommandSkip, desc = "skip the map", argc_min = 0, argc_max = 0}
pshy.help_pages["pacmice"].commands["skip"] = pshy.chat_commands["skip"]
pshy.perms.admins["!skip"] = true
--- Initialization:
-- generate other map properties
for i_map, map in pairs(pacmice_maps) do
	pacmice_map = map
	map.linear_grid = {}
	if not map.grid_w then
		local max_grid_x, max_grid_y = 1, 1
		for i_path, path in ipairs(map.pathes) do
			max_grid_x = math.max(max_grid_x, path[1])
			max_grid_y = math.max(max_grid_y, path[2])
		end
		map.grid_w = max_grid_x + 1
		map.grid_h = max_grid_y + 1
	end
	-- load map linear path grid
	for i_path, path in ipairs(map.pathes) do
		pacmice_GridSet(path[1], path[2], true)
	end
end
pacmice_map = pacmice_maps[1]
-- ui
for player_name in pairs(tfm.get.room.playerList) do
	pacmice_TouchPlayer(player_name)
end
-- start
tfm.exec.newGame("pacmice")
end
new_mod.Content()
pshy.merge_ModuleEnd()
pshy.merge_Finish()

