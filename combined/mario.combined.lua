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
		tfm.exec.chatMessage((mod.enabled and "<v>" or "<g>") ..tostring(mod.index) .. "\t" .. mod.name .. " \t" .. tostring(mod.event_count) .. " events", user)
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
local new_mod = pshy.merge_ModuleBegin("pshy_assert.lua")
function new_mod.Content()
--- pshy_assert.lua
--
-- Cause lua assert to provide more informations.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy = pshy or {}
--- Custom assert function.
function pshy.assert(condition, message)
	if not condition then
		local error_message = "\n<u><r>ASSERTION FAILED</r></u>"
		if message then
			error_message = error_message .. "\n<b><o>" .. message .. "</o></b>"
		end
		error_message = error_message .. "\n<i><j>" .. debug.traceback() .. "</j></i>"
		error(error_message)
	end
end
assert = pshy.assert
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
pshy.alloc_id_pools["Bonus"]			= {first = 200, last = 1000, allocated = {}}	-- note: Game bonuses are deleted by TFM on eventNewGame.
pshy.alloc_id_pools["Joint"]			= {first = 20, last = 1000, allocated = {}}		-- note: Game joints are deleted by TFM on eventNewGame.
pshy.alloc_id_pools["TextArea"]			= {first = 20, last = 1000, allocated = {}}
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
	pshy.keycodes["F" .. tostring(f_index + 1)] = 112 + f_index
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
	assert(type(str) == "string", "str need to be of type string (was " .. type(str) .. ")" .. debug.traceback())
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
--- Copy a list table.
-- @param t The list table to copy.
-- @return a copy of the list table.
function pshy.ListCopy(t)
	assert(type(t) == "table")
	local new_table = {}
	for key, value in ipairs(t) do
		table.insert(new_table, value)
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
--- Remove duplicates in a sorted list.
-- @return Count of removed items.
function pshy.SortedListRemoveDuplicates(t)
	local prev_size = #t
	local i = #t - 1
	while i >= 1 do
		if t[i] == t[i + 1] then
			table.remove(t, i + 1)
		end
		i = i - 1
	end
	return prev_size - #t
end
--- Remove duplicates in a table.
-- @return Count of removed items.
function pshy.TableRemoveDuplicates(t)
	local prev_size = #t
	local keys = {}
	local i = #t
	while i >= 1 do
		if keys[t[i]] then
			table.remove(t, i + 1)
		else
			keys[t[i]] = true
		end
		i = i - 1
	end
	return prev_size - #t
end
--- Append a list to another.
-- @param dst_list The list receiving the new items.
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
local new_mod = pshy.merge_ModuleBegin("pshy_perms.lua")
function new_mod.Content()
--- pshy_perms.lua
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
pshy.private_room = (string.sub(tfm.get.room.name, 1, 1) == "@")
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
local new_mod = pshy.merge_ModuleBegin("pshy_players.lua")
function new_mod.Content()
--- pshy_players.lua
--
-- A global `pshy.players` table to store players informations.
-- Other modules may add their fields to a player's table, using that module's prefix.
--
-- Player fields provided by this module:
--	- `name`:					The Name#0000 of the player.
--	- `tfm_player`:				The corresponding table entry in `tfm.get.room.playerList`.
--	- `has_admin_tag`		
--	- `has_moderator_tag`		
--	- `has_sentinel_tag`		
--	- `has_mapcrew_tag`				
--	- `has_previous_staff_tag`		
--	- `alive`					`true` if the player is alive.
--	- `won`						`true` if the player has entered the hole.
--	- `cheeses`					How many cheeses this player have.
--
-- Usage of this module by other `pshy` have been dropped, but it may be reimplemented in the future.
-- The advantages of using it are to be evaluated.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy = pshy or {}
--- Module settings and public members:
pshy.delete_players_on_leave = false			-- delete a player's table when they leave
pshy.players = {}								-- the global players table
--- Ensure a table entry exist in `pshy.players` for a player, creating it if required.
-- Default fields `name` and `tfm_player` are also defined.
-- @private
-- @param player_name The Name#0000 if the player.
function pshy.players_Touch(player_name)
	if pshy.players[player_name] then
		return
	end
	local new_player = {}
	new_player.name = player_name
	new_player.tfm_player = tfm.get.room.playerList[player_name]
	new_player.has_admin_tag = (string.sub(player_name, -5) == "#0001")
	new_player.has_moderator_tag = (string.sub(player_name, -5) == "#0010")
	new_player.has_sentinel_tag = (string.sub(player_name, -5) == "#0015")
	new_player.has_mapcrew_tag = (string.sub(player_name, -5) == "#0020")
	new_player.has_previous_staff_tag = (string.sub(player_name, -5) == "#0095")
	new_player.alive = false
	new_player.won = false
	new_player.cheeses = 0
	pshy.players[player_name] = new_player
end
--- TFM event eventNewPlayer.
function eventNewPlayer(player_name)
	pshy.players_Touch(player_name)
end
--- TFM event eventPlayerLeft.
function eventPlayerLeft(player_name)
    if pshy.delete_players_on_leave then
    	pshy.players[player_name] = nil
    end
	local player = pshy.players[player_name]
	player.alive = false
	player.cheeses = 0
end
--- TFM event eventNewGame
-- @TODO: dignore disconneced players
function eventNewGame()
	for player_name, player in pairs(pshy.players) do
		player.alive = true
		player.won = false
		player.cheeses = 0
	end
end
--- TFM event eventPlayerWon.
function eventPlayerWon(player_name)
	local player = pshy.players[player_name]
	player.alive = false
	player.won = true
	player.cheeses = 0
end
--- TFM event eventPlayerDied.
function eventPlayerDied(player_name)
	pshy.players[player_name].alive = false
end
--- TFM event eventPlayerGetCheese.
function eventPlayerGetCheese(player_name)
	local player = pshy.players[player_name]
	player.cheeses = player.cheeses + 1
end
--- TFM event eventPlayeRespawn.
function eventPlayerRespawn(player_name)
	local player = pshy.players[player_name]
	player.alive = true
	if player.won then
		player.won = false
		player.cheeses = 0
	end
end
--- tfm.exec.giveCheese hook.
-- @TODO: test on multicheese maps.
local tfm_giveCheese = tfm.exec.giveCheese
tfm.exec.giveCheese = function(player_name)
	if pshy.players[player_name] then
		pshy.players[player_name].cheeses = 1
	end
	return tfm_giveCheese(player_name)
end
--- tfm.exec.removeCheese hook.
local tfm_removeCheese = tfm.exec.removeCheese
tfm.exec.removeCheese = function(player_name)
	if pshy.players[player_name] then
		pshy.players[player_name].cheeses = 0
	end
	return tfm_removeCheese(player_name)
end
--- tfm.exec.respawnPlayer hook.
local tfm_respawnPlayer = tfm.exec.respawnPlayer
tfm.exec.respawnPlayer = function(player_name)
	if pshy.players[player_name] then
		pshy.players[player_name].cheeses = 0
	end
	return tfm_respawnPlayer(player_name)
end
--- pshy event eventInit.
function eventInit()
	for player_name in pairs(tfm.get.room.playerList) do
		pshy.players_Touch(player_name)
	end	
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
local new_mod = pshy.merge_ModuleBegin("pshy_nofuncorp.lua")
function new_mod.Content()
--- pshy_nofuncorp.lua
--
-- Allow to still use some funcorp-only lua features in non-funcorp rooms.
-- Also works in tribehouse.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @require pshy_perms.lua
-- @require pshy_commands.lua
pshy = pshy or {}
--- Help page:
pshy.help_pages = pshy.help_pages or {}				-- touching the help_pages table
pshy.help_pages["pshy_nofuncorp"] = {title = "No FunCorp Alternatives", text = "Allow some FunCorp only features to not prevent a module from running in non-funcorp rooms.\n", commands = {}}
--- Module Settings:
--pshy.funcorp = (tfm.exec.getPlayerSync() ~= nil)		-- currently defined in `pshy_perms.lua`, true when funcorp features are available
pshy.nofuncorp_chat_arbitrary_id = 14
--- Internal Use:
pshy.chat_commands = pshy.chat_commands or {}			-- touching the chat_commands table
pshy.nofuncorp_chatMessage = tfm.exec.chatMessage		-- original chatMessage function
pshy.nofuncorp_players_chats = {}						-- stores the last messages sent per player with nofuncorp_chatMessage
pshy.nofuncorp_players_hidden_chats = {}				-- status of chats
pshy.nofuncorp_last_loop_time = 0						-- replacement for game timers
pshy.nofuncorp_timers = {}								-- replacement for game timers
--- Get a nofuncorp player's chat content.
function pshy.nofuncorp_GetPlayerChatContent(player_name)
	local chat = pshy.nofuncorp_players_chats[player_name]
	local total = ""
	for i_line, line in ipairs(chat) do
		total = "<n>" .. total .. line .. "</n>\n"
	end
	return total
end
--- Update a nofuncorp player's chat.
function pshy.nofuncorp_UpdatePlayerChat(player_name)
	if not pshy.nofuncorp_players_hidden_chats[player_name] then
		local text = pshy.nofuncorp_GetPlayerChatContent(player_name)
		ui.addTextArea(pshy.nofuncorp_chat_arbitrary_id, text, player_name, 0, 50, 400, nil, 0x0, 0x0, 1.0, true)
	else
		ui.removeTextArea(pshy.nofuncorp_chat_arbitrary_id, player_name)
	end
end
--- Replacement for `tfm.exec.chatMessage`.
-- @TODO: only remove older chat messages if required.
function pshy.nofuncorp_chatMessage(message, player_name)
	-- params checks
	if #message > 200 then
		print("<fc>[PshyNoFuncorp]</fc> chatMessage: Error: message length is limited to 200!")
		return
	end
	-- nil player value
	if not player_name then
		for player_name in pairs(tfm.get.room.playerList) do
			pshy.nofuncorp_chatMessage(message, player_name)
		end
		return
	end
	-- add message
	pshy.nofuncorp_players_chats[player_name] = pshy.nofuncorp_players_chats[player_name] or {}
	local chat = pshy.nofuncorp_players_chats[player_name]
	if #chat > 8 then
		table.remove(chat, 1)
	end
	table.insert(chat, message)
	-- display
	pshy.nofuncorp_UpdatePlayerChat(player_name)
end
--- Replacement for `system.addTimer`.
-- @todo Test this.
function pshy.nofuncorp_newTimer(callback, time, loop, arg1, arg2, arg3, arg4)
	-- params checks
	if time < 1000 then
		print("<fc>[PshyNoFuncorp]</fc> newTimer: Error: minimum time is 1000!")
		return
	end
	-- find an id
	local timer_id = 1
	while pshy.nofuncorp_timers[timer_id] do
		timer_id = timer_id + 1
	end
	-- create
	pshy.nofuncorp_timers[timer_id] = {}
	timer = pshy.nofuncorp_timers[timer_id]
	timer.callback = callback
	timer.time = time
	timer.loop = loop
	timer.arg1 = arg1
	timer.arg2 = arg2
	timer.arg3 = arg3
	timer.arg4 = arg4
	timer.next_run_time = 0 + timer.time
	return timer_id
end
--- Replacement for `system.removeTimer`.
function pshy.nofuncorp_removeTimer(timer_id)
	pshy.nofuncorm_timers[timer_id] = nil
end
--- Replacement for `tfm.exec.getPlayerSync`.
-- Yes, the return is wrong, the goal is only to let modules work without spamming the log.
function pshy.nofuncorp_getPlayerSync()
	return pshy.loader
end
--- !chat
function pshy.nofuncorp_ChatCommandChat(user)
	pshy.nofuncorp_players_hidden_chats[user] = not pshy.nofuncorp_players_hidden_chats[user]
	pshy.nofuncorp_UpdatePlayerChat(user)
end
pshy.chat_commands["chat"] = {func = pshy.nofuncorp_ChatCommandChat, desc = "toggle the nofuncorp chat", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_nofuncorp"].commands["chat"] = pshy.chat_commands["chat"]
pshy.perms.everyone["!chat"] = true
--- TFM event eventNewGame
function eventNewGame()
	if not pshy.funcorp then
		for i_timer,timer in pairs(pshy.nofuncorp_timers) do
			timer.next_run_time = timer.next_run_time - pshy.nofuncorp_last_loop_time
		end
		pshy.nofuncorp_last_loop_time = 0
	end
end
--- TFM event eventLoop.
function eventLoop(time, time_remaining)
	if not pshy.funcorp then
		pshy.nofuncorp_last_loop_time = time
		local ended_timers = {}
		for i_timer, timer in pairs(pshy.nofuncorp_timers) do
			if timer.next_run_time < time then
				timer.callback(timer.arg1, timer.arg2, timer.arg3, timer.arg4)
				if timer.loop then
					timer.next_run_time = timer.next_run_time + timer.time
				else
					ended_timers[i_timer] = true
				end
			end
		end
		for i_ended_timer in pairs(ended_timers) do
			pshy.nofuncorp_timers[i_ended_timer] = nil
		end
	end
end
--- Initialization:
function eventInit()
	if not pshy.funcorp then
		tfm.exec.chatMessage = pshy.nofuncorp_chatMessage
		system.newTimer = pshy.nofuncorp_newTimer
		system.removeTimer = pshy.nofuncorp_removeTimer
		tfm.exec.removeTimer = pshy.nofuncorp_removeTimer
		tfm.exec.getPlayerSync = pshy.nofuncorp_getPlayerSync
		tfm.exec.chatMessage("<fc>[PshyNoFuncorp]</fc> Lua chat messages unavailable, replacing them.")
		tfm.exec.chatMessage("<fc>[PshyNoFuncorp]</fc> Type <ch2>!chat</ch2> to toggle this text.")
	end
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
pshy.imagedb_images["17aa1265ea4.png"] = {emoticon = true, author = "feverchild#0000", desc = "ZZZ"} -- source: https://discord.com/channels/246815328103825409/522398576706322454/834007372640419851
pshy.imagedb_images["17aa1264731.png"] = {emoticon = true, author = "feverchild#0000", desc = "no voice"}
pshy.imagedb_images["17aa1bcf1d4.png"] = {emoticon = true, author = "Nnaaaz#0000", w = 60, h = 60, desc = "pro"}
pshy.imagedb_images["17aa1bd3a05.png"] = {emoticon = true, author = "Nnaaaz#0000", w = 60, h = 49, desc = "noob"}
pshy.imagedb_images["17aa1bd0944.png"] = {emoticon = true, author = "Nnaaaz#0000", desc = "pro2"}
pshy.imagedb_images["17aa1bd20b5.png"] = {emoticon = true, author = "Nnaaaz#0000", desc = "noob2"}
-- memes (source: https://atelier801.com/topic?f=6&t=827044&p=1#m14)
pshy.imagedb_images["15565dbc655.png"] = {meme = true, desc = "WTF cat"} -- 
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
pshy.imagedb_images["17cc269a03d.png"] = {TFM = true, w = 40, h = 30, desc = "mouse hole"}
pshy.imagedb_images["153d331c6b9.png"] = {TFM = true, desc = "normal mouse"}
-- TFM (source: Laagaadoo https://atelier801.com/topic?f=6&t=877911#m3)
pshy.imagedb_images["1569ed22fca.png"] = {TFM = true, furniture = true, desc = ""} -- Estante de livros
pshy.imagedb_images["1569edb5d05.png"] = {TFM = true, furniture = true, desc = ""} -- Estante de livros (invertida)
pshy.imagedb_images["1569ec80946.png"] = {TFM = true, furniture = true, desc = ""} -- Lareira
pshy.imagedb_images["15699c75f35.png"] = {TFM = true, furniture = true, desc = ""} -- Lareira (invertida)
pshy.imagedb_images["1569e9e54f4.png"] = {TFM = true, furniture = true, desc = ""} -- Caixão
pshy.imagedb_images["15699c67278.png"] = {TFM = true, furniture = true, desc = ""} -- Caixão (invertido)
pshy.imagedb_images["1569e7e4495.png"] = {TFM = true, furniture = true, desc = ""} -- Cemiterio
pshy.imagedb_images["156999e1f40.png"] = {TFM = true, furniture = true, desc = ""} -- Cemiterio (invertido)
pshy.imagedb_images["156999ebf03.png"] = {TFM = true, furniture = true, desc = ""} -- Árvore de natal
pshy.imagedb_images["1569e7d3bac.png"] = {TFM = true, furniture = true, desc = ""} -- Arvore de natal (invertida)
pshy.imagedb_images["1569e7ca20e.png"] = {TFM = true, furniture = true, desc = ""} -- Arvore com neve
pshy.imagedb_images["156999e6b7e.png"] = {TFM = true, furniture = true, desc = ""} -- Árvore com neve (invertida)
pshy.imagedb_images["155a7b9a815.png"] = {TFM = true, furniture = true, desc = ""} -- Árvore
pshy.imagedb_images["1569e788f68.png"] = {TFM = true, furniture = true, desc = ""} -- Árvore (invertida)
pshy.imagedb_images["155a7c4e15a.png"] = {TFM = true, furniture = true, desc = ""} -- Flor vermelha
pshy.imagedb_images["155a7c50a6b.png"] = {TFM = true, furniture = true, desc = ""} -- Flor azul
pshy.imagedb_images["155a7c834a4.png"] = {TFM = true, furniture = true, desc = ""} -- Janela
pshy.imagedb_images["1569e9bfb87.png"] = {TFM = true, furniture = true, desc = ""} -- Janela (invertida)
pshy.imagedb_images["155a7ca38b7.png"] = {TFM = true, furniture = true, desc = ""} -- Sofá
pshy.imagedb_images["156999f093a.png"] = {TFM = true, furniture = true, desc = ""} -- Palmeira
pshy.imagedb_images["1569e7706c4.png"] = {TFM = true, furniture = true, desc = ""} -- Palmeira (invertido)
pshy.imagedb_images["15699b2da1f.png"] = {TFM = true, furniture = true, desc = ""} -- Estante de halloween
pshy.imagedb_images["1569e77e3a5.png"] = {TFM = true, furniture = true, desc = ""} -- Estante de halloween (invertido)
pshy.imagedb_images["1569e79c9e3.png"] = {TFM = true, furniture = true, desc = ""} -- Árvore do outono
pshy.imagedb_images["15699b344da.png"] = {TFM = true, furniture = true, desc = ""} -- Árvore do outono (invertida)
pshy.imagedb_images["1569e773235.png"] = {TFM = true, furniture = true, desc = ""} -- Abobora gigante
pshy.imagedb_images["15699c5e038.png"] = {TFM = true, furniture = true, desc = ""} -- Piano
pshy.imagedb_images["15699c3eedd.png"] = {TFM = true, furniture = true, desc = ""} -- Barril
pshy.imagedb_images["15699b15524.png"] = {TFM = true, furniture = true, desc = ""} -- Guada roupa
pshy.imagedb_images["1569e7ae2e0.png"] = {TFM = true, furniture = true, desc = ""} -- Guarda roupa (invertido)
pshy.imagedb_images["1569edb8321.png"] = {TFM = true, furniture = true, desc = ""} -- Baú
pshy.imagedb_images["1569ed263b4.png"] = {TFM = true, furniture = true, desc = ""} -- Baú (invertido)
pshy.imagedb_images["1569edbaea9.png"] = {TFM = true, furniture = true, desc = ""} -- Postêr
pshy.imagedb_images["1569ed28f41.png"] = {TFM = true, furniture = true, desc = ""} -- Postêr (invertido)
pshy.imagedb_images["1569ed2cb80.png"] = {TFM = true, furniture = true, desc = ""} -- Boneco de neve
pshy.imagedb_images["1569edbe194.png"] = {TFM = true, furniture = true, desc = ""} -- Boneco de neve (invertido)
-- backgrounds (source: Travonrodfer https://atelier801.com/topic?f=6&t=877911#m6)
pshy.imagedb_images["14e555a4c1b.jpg"] = {TFM = true, background = true, desc = ""} -- Mapa Independence Day
pshy.imagedb_images["14e520635b4.png"] = {TFM = true, background = true, desc = ""} -- Estatua da liberdade(Mapa Independence Day)
pshy.imagedb_images["14e78118c13.jpg"] = {TFM = true, background = true, desc = ""} -- Mapa Bastille Day
pshy.imagedb_images["14e7811b53a.png"] = {TFM = true, background = true, desc = ""} -- Folha das arvores(Mapa Bastille Day)
pshy.imagedb_images["149c04b50ac.jpg"] = {TFM = true, background = true, desc = ""} -- Mapa do ceifador
pshy.imagedb_images["149c04bc447.png"] = {TFM = true, background = true, desc = ""} -- Mapa do ceifador(partes em primeiro plano)
pshy.imagedb_images["14abae230c8.jpg"] = {TFM = true, background = true, desc = ""} -- Mapa Rua Nuremberg
pshy.imagedb_images["14aa6e36f3e.png"] = {TFM = true, background = true, desc = ""} -- Mapa Rua Nuremberg(partes em primeiro plano)
pshy.imagedb_images["14a88571f89.jpg"] = {TFM = true, background = true, desc = ""} -- Mapa Fabrica de brinquedos
pshy.imagedb_images["14a8d41a838.jpg"] = {TFM = true, background = true, desc = ""} -- Mapa dia das crianças
pshy.imagedb_images["14a8d430dfa.png"] = {TFM = true, background = true, desc = ""} -- Mapa dia das crianças(partes em primeiro plano)
pshy.imagedb_images["15150c10e92.png"] = {TFM = true, background = true, desc = ""} -- Mapa de ano novo
-- TFM Particles (source: Tempo https://atelier801.com/topic?f=6&t=877911#m7)
pshy.imagedb_images["1674801ea08.png"] = {TFM = true, particle = true, desc = ""} -- Raiva
pshy.imagedb_images["16748020179.png"] = {TFM = true, particle = true, desc = ""} -- Palmas
pshy.imagedb_images["167480218ea.png"] = {TFM = true, particle = true, desc = ""} -- Confete
pshy.imagedb_images["1674802305b.png"] = {TFM = true, particle = true, desc = ""} -- Dança
pshy.imagedb_images["167480247cc.png"] = {TFM = true, particle = true, desc = ""} -- Facepalm
pshy.imagedb_images["16748025f3d.png"] = {TFM = true, particle = true, desc = ""} -- High five
pshy.imagedb_images["167480276af.png"] = {TFM = true, particle = true, desc = ""} -- Abraçar
pshy.imagedb_images["16748028e21.png"] = {TFM = true, particle = true, desc = ""} -- Pedir Beijo
pshy.imagedb_images["1674802a592.png"] = {TFM = true, particle = true, desc = ""} -- Beijar
pshy.imagedb_images["1674802bd07.png"] = {TFM = true, particle = true, desc = ""} -- Risada
pshy.imagedb_images["1674802d478.png"] = {TFM = true, particle = true, desc = ""} -- Pedra papel tesoura
pshy.imagedb_images["1674802ebea.png"] = {TFM = true, particle = true, desc = ""} -- Sentar
pshy.imagedb_images["1674803035b.png"] = {TFM = true, particle = true, desc = ""} -- Dormir
pshy.imagedb_images["16748031acc.png"] = {TFM = true, particle = true, desc = ""} -- Chorar
-- Pokemon (source: Shamousey https://atelier801.com/topic?f=6&t=827044&p=1#m6)
-- Mario
pshy.imagedb_images["156d7dafb2d.png"] = {mario = true, desc = "mario (undersized)"} -- @TODO: replace whith a properly sized image
pshy.imagedb_images["17aa6f22c53.png"] = {mario = true, w = 27, h = 38, desc = "mario coin"}
pshy.imagedb_images["17c41851d61.png"] = {mario = true, w = 30, h = 30, desc = "mario flower"}
pshy.imagedb_images["17c41856d4a.png"] = {mario = true, w = 30, h = 30, desc = "mario star"}
pshy.imagedb_images["17c431c5e88.png"] = {mario = true, w = 30, h = 30, desc = "mario mushroom"}
-- Bonuses (Pshy#3752)
pshy.imagedb_images["17bef4f49c5.png"] = {bonus = true, w = 30, h = 30, desc = "empty bonus"}
pshy.imagedb_images["17bf4b75aa7.png"] = {bonus = true, w = 30, h = 30, desc = "question bonus"}
pshy.imagedb_images["17bf4ba4ce5.png"] = {bonus = true, w = 30, h = 30, desc = "teleporter bonus"}
pshy.imagedb_images["17bf4b9e11d.png"] = {bonus = true, w = 30, h = 30, desc = "crate bonus"}
pshy.imagedb_images["17bf4b9af56.png"] = {bonus = true, w = 30, h = 30, desc = "high speed bonus"}
pshy.imagedb_images["17bf4b977f5.png"] = {bonus = true, w = 30, h = 30, desc = "ice cube bonus"}
pshy.imagedb_images["17bf4b94d8a.png"] = {bonus = true, w = 30, h = 30, desc = "snowflake bonus"}
pshy.imagedb_images["17bf4b91c35.png"] = {bonus = true, w = 30, h = 30, desc = "broken heart bonus"}
pshy.imagedb_images["17bf4b8f9e4.png"] = {bonus = true, w = 30, h = 30, desc = "heart bonus"}
pshy.imagedb_images["17bf4b8c42d.png"] = {bonus = true, w = 30, h = 30, desc = "feather bonus"}
pshy.imagedb_images["17bf4b89eba.png"] = {bonus = true, w = 30, h = 30, desc = "cross"}
pshy.imagedb_images["17bf4b868c3.png"] = {bonus = true, w = 30, h = 30, desc = "jumping mouse bonus"}
pshy.imagedb_images["17bf4b80fc3.png"] = {bonus = true, w = 30, h = 30, desc = "balloon bonus"}
pshy.imagedb_images["17bef4f49c5.png"] = {bonus = true, w = 30, h = 30, desc = "empty bonus"}
pshy.imagedb_images["17bf4b7ddd6.png"] = {bonus = true, w = 30, h = 30, desc = "triggered mouse trap"}
pshy.imagedb_images["17bf4b7a091.png"] = {bonus = true, w = 30, h = 30, desc = "mouse trap"}
pshy.imagedb_images["17bf4b7250e.png"] = {bonus = true, w = 30, h = 30, desc = "wings bonus"}
pshy.imagedb_images["17bf4b6f226.png"] = {bonus = true, w = 30, h = 30, desc = "transformations bonus"}
pshy.imagedb_images["17bf4b67579.png"] = {bonus = true, w = 30, h = 30, desc = "grow bonus"}
pshy.imagedb_images["17bf4b63aaa.png"] = {bonus = true, w = 30, h = 30, desc = "shrink bonus"}
pshy.imagedb_images["17bf4c421bb.png"] = {bonus = true, w = 30, h = 30, desc = "flag bonus"}
pshy.imagedb_images["17bf4f3f2fb.png"] = {bonus = true, w = 30, h = 30, desc = "v check"}
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
	if image_name == "none" then
		return nil
	end
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
	if image_name == "none" then
		return nil
	end
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
local new_mod = pshy.merge_ModuleBegin("pshy_checkpoints.lua")
function new_mod.Content()
--- pshy_checkpoints.lua
--
-- Adds respawn features.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
-- @require pshy_commands.lua
-- @require pshy_help.lua
--- Module Help Page:
pshy.help_pages["pshy_checkpoints"] = {back = "pshy", title = "Checkpoints", text = nil, commands = {}}
pshy.help_pages["pshy"].subpages["pshy_checkpoints"] = pshy.help_pages["pshy_checkpoints"]
--- Module Settings:
pshy.checkpoints_reset_on_new_game = true
--- Internal use:
pshy.players = pshy.players or {}			-- adds checkpoint_x, checkpoint_y, checkpoint_hasCheese
local just_dead_players = {}
--- Set the checkpoint of a player.
-- @param player_name The player's name.
-- @param x Optional player x location.
-- @param y Optional player y location.
-- @param hasCheese Optional hasCheese tfm player property.
function pshy.checkpoints_SetPlayerCheckpoint(player_name, x, y, hasCheese)
	pshy.players[player_name] = pshy.players[player_name] or {}
	local player = pshy.players[player_name]
	x = x or tfm.get.room.playerList[player_name].x
	y = y or tfm.get.room.playerList[player_name].y
	hasCheese = hasCheese or tfm.get.room.playerList[player_name].hasCheese
	player.checkpoint_x = x
	player.checkpoint_y = y
	player.checkpoint_hasCheese = hasCheese
end
--- Set the checkpoint of a player.
-- @param player_name The player's name.
function pshy.checkpoints_UnsetPlayerCheckpoint(player_name)
	local player = pshy.players[player_name]
	player.checkpoint_x = nil
	player.checkpoint_y = nil
	player.checkpoint_hasCheese = nil
end
--- Teleport a player to its checkpoint.
-- Also gives him the cheese if he had it.
-- @param player_name The player's name.
-- @param x Optional player x location.
-- @param y Optional player y location.
function pshy.checkpoints_PlayerCheckpoint(player_name)
	local player = pshy.players[player_name]
	if player.checkpoint_x then
		tfm.exec.respawnPlayer(player_name)
		tfm.exec.movePlayer(player_name, player.checkpoint_x, player.checkpoint_y, false, 0, 0, true)
		if player.checkpoint_hasCheese then
			tfm.exec.giveCheese(player_name)
		end
	end
end
--- !checkpoint
pshy.chat_commands["gotocheckpoint"] = {func = pshy.checkpoints_PlayerCheckpoint, desc = "teleport to your checkpoint if you have one", argc_min = 0, argc_max = 0, arg_types = {}}
pshy.help_pages["pshy_checkpoints"].commands["gotocheckpoint"] = pshy.chat_commands["gotocheckpoint"]
pshy.perms.cheats["!gotocheckpoint"] = true
--- !setcheckpoint
pshy.chat_commands["setcheckpoint"] = {func = pshy.checkpoints_SetPlayerCheckpoint, desc = "set your checkpoint to the current location", argc_min = 0, argc_max = 0, arg_types = {}}
pshy.help_pages["pshy_checkpoints"].commands["setcheckpoint"] = pshy.chat_commands["setcheckpoint"]
pshy.perms.cheats["!setcheckpoint"] = true
--- !setcheckpoint
pshy.chat_commands["unsetcheckpoint"] = {func = pshy.checkpoints_UnsetPlayerCheckpoint, desc = "delete your checkpoint", argc_min = 0, argc_max = 0, arg_types = {}}
pshy.help_pages["pshy_checkpoints"].commands["unsetcheckpoint"] = pshy.chat_commands["unsetcheckpoint"]
pshy.perms.cheats["!unsetcheckpoint"] = true
--- TFM event eventPlayerWon.
-- temporary fix
function eventPlayerWon(player_name)
	tfm.get.room.playerList[player_name].hasCheese = false
end
--- TFM event eventPlayerDied.
function eventPlayerDied(player_name)
	just_dead_players[player_name] = true
end
--- TFM event eventLoop.
function eventLoop()
	for dead_player in pairs(just_dead_players) do
		if pshy.players[dead_player].checkpoint_x then
			tfm.exec.respawnPlayer(dead_player)
		end
		just_dead_players[dead_player] = false
	end
end
--- TFM event eventPlayerRespawn.
function eventPlayerRespawn(player_name)
	just_dead_players[player_name] = false
	pshy.checkpoints_PlayerCheckpoint(player_name)
end
--- TFM event eventNewGame.
function eventNewGame(player_name)
	if pshy.checkpoints_reset_on_new_game then
		for player_name, player in pairs(pshy.players) do
			player.checkpoint_x = nil
			player.checkpoint_y = nil
			player.checkpoint_hasCheese = nil
		end
	end
	just_dead_players = {}
end
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
local new_mod = pshy.merge_ModuleBegin("pshy_adminchat.lua")
function new_mod.Content()
--- pshy_adminchat.lua
--
-- Add a room admin chat.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @require pshy_commands.lua
-- @require pshy_help.lua
-- @require pshy_perms.lua
--- Module Help Page:
pshy.help_pages["pshy_adminchat"] = {back = "pshy", title = "Admin Chat", text = "Chat for room admins", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_adminchat"] = pshy.help_pages["pshy_adminchat"]
--- Send a message to room admins.
function pshy.adminchat_Message(origin, message)
	if not message then
		message = origin
		origin = "SCRIPT"
	end
	for admin in pairs(pshy.admins) do
		tfm.exec.chatMessage("<r>⚔ [" .. origin .. "] <o>" .. message, admin)
	end
end
--- !adminchat
local function ChatCommandAdminchat(user, message)
	for admin in pairs(pshy.admins) do
		tfm.exec.chatMessage("<r>⚔ [" .. user .. "] <ch2>" .. message, admin)
	end
end
pshy.chat_commands["adminchat"] = {func = ChatCommandAdminchat, desc = "send a message to room admins", argc_min = 1, argc_max = 1, arg_types = {"string"}, arg_names = {"room-admin-only message"}}
pshy.help_pages["pshy_adminchat"].commands["adminchat"] = pshy.chat_commands["adminchat"]
pshy.perms.admins["!adminchat"] = true
pshy.commands_aliases["ac"] = "adminchat"
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_ban.lua")
function new_mod.Content()
--- pshy_ban.lua
--
-- Allow to ban players from the room.
-- Players are not realy made to leave the room, just prevented from playing.
--
-- You can also shadowban a player.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
-- @require pshy_help.lua
-- @require pshy_merge.lua
-- @require pshy_commands.lua
-- @require pshy_players.lua
pshy = pshy or {}
--- Module Help Page:
pshy.help_pages["pshy_ban"] = {restricted = true, back = "pshy", text = "", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_ban"] = pshy.help_pages["pshy_ban"]
--- Internal use:
pshy.ban_mask_ui_arbitrary_id = 73
--- Proceed with what have to be done on a banned player.
-- @param player_name The Name#0000 of the player to apply the ban effects on.
-- @private
local function ApplyBanEffects(player_name)
	tfm.exec.removeCheese(player_name)
	tfm.exec.movePlayer(player_name, -1001, -1001, false, 0, 0, true)
	tfm.exec.killPlayer(player_name)
	ui.addTextArea(pshy.ban_mask_ui_arbitrary_id, "", player_name, -999, -999, 800 + 2002, 400 + 2002, 0x111111, 0, 0.01, false)
	tfm.exec.setPlayerScore(player_name, -1, false)
end
--- Ban a player from the running script (unban him on leave).
-- @param player_name The player's Name#0000.
-- @param reason The official ban reason.
function pshy.ban_KickPlayer(player_name, reason)
	local player = pshy.players[player_name]
	if player.banned then
		return false, "This player is already banned."
	end
	player.kicked = true
	player.banned = true
	player.ban_reason = reason or "reason not provided"
	return true, "player banned for " .. player.ban_reason
end
pshy.chat_commands["kick"] = {func = pshy.ban_KickPlayer, desc = "'Kick' a player from the script (they need to rejoin).", no_user = true, argc_min = 1, argc_max = 1, arg_types = {"player"}}
pshy.help_pages["pshy_ban"].commands["kick"] = pshy.chat_commands["kick"]
pshy.perms.admins["!kick"] = true
--- Ban a player from the running script.
-- @param player_name The player's Name#0000.
-- @param reason The official ban reason.
function pshy.ban_BanPlayer(player_name, reason)
	local player = pshy.players[player_name]
	player.kicked = false
	player.banned = true
	player.ban_reason = reason or "reason not provided"
	return true, "player banned for " .. player.ban_reason
end
pshy.chat_commands["ban"] = {func = pshy.ban_BanPlayer, desc = "'ban' a player from the script.", no_user = true, argc_min = 1, argc_max = 1, arg_types = {"player"}}
pshy.help_pages["pshy_ban"].commands["ban"] = pshy.chat_commands["ban"]
pshy.perms.admins["!ban"] = true
--- ShadowBan a player from the running script.
-- @param player_name The player's Name#0000.
-- @param reason A ban reason visible only to the room admins.
function pshy.ban_ShadowBanPlayer(player_name, reason)
	local player = pshy.players[player_name]
	player.kicked = false
	player.banned = false
	player.shadow_banned = true
	player.shadow_ban_score = tfm.get.room.playerList[player_name].score
	player.ban_reason = reason or "reason not provided"
	return true, "player shadowbanned for " .. player.ban_reason
end
pshy.chat_commands["shadowban"] = {func = pshy.ban_ShadowBanPlayer, desc = "Disable most of the script's features for this player.", no_user = true, argc_min = 1, argc_max = 1, arg_types = {"player"}}
pshy.help_pages["pshy_ban"].commands["shadowban"] = pshy.chat_commands["shadowban"]
pshy.perms.admins["!shadowban"] = true
--- Unban a player
function pshy.ban_UnbanPlayer(player_name)
	local player = pshy.players[player_name]
	player.kicked = false
	player.banned = false
	player.shadow_banned = false
	ui.removeTextArea(pshy.ban_mask_ui_arbitrary_id, player_name)
	return true, "player unbanned"
end
pshy.chat_commands["unban"] = {func = pshy.ban_UnbanPlayer, desc = "Unban a player from the room.", no_user = true, argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_ban"].commands["unban"] = pshy.chat_commands["unban"]
pshy.perms.admins["!unban"] = true
--- TFM event eventNewPlayer.
-- Apply ban effects on banned players who rejoined.
function eventNewPlayer(player_name)
	if pshy.players[player_name].banned then
        ApplyBanEffects(player_name)
    end
end
--- TFM event eventPlayerLeft.
-- Remove the ban for kiked players.
function eventPlayerLeft(player_name)
	local player = pshy.players[player_name]
	if player.kicked then
        player.kicked = false
        player.banned = false
    end
end
--- TFM event eventNewGame.
-- Apply the ban effects on banned players.
function eventNewGame()
	for player_name in pairs(tfm.get.room.playerList) do
        if pshy.players[player_name].banned then
        	ApplyBanEffects(player_name)
    	end
    end
end
--- TFM event eventPlayerRespawn.
-- Apply the ban effects on banned players who respawn.
function eventPlayerRespawn(player_name)
	if pshy.players[player_name].banned then
        ApplyBanEffects(player_name)
    end
end
--- TFM event eventChatCommand.
-- Return false for banned players to hope that the command processing will be canceled.
function eventChatCommand(player_name, message)
    if pshy.players[player_name].banned then
        return false
    end
end
--- TFM event eventPlayerWon.
-- Cancel this event for shadow_banned players.
-- Also override the player's score in `tfm.get.room.playerList`.
function eventPlayerWon(player_name)
	if pshy.players[player_name].shadow_banned then
		local player = pshy.players[player_name]
		player.won = false
		tfm.exec.setPlayerScore(player_name, player.shadow_ban_score, false)
		tfm.get.room.playerList[player_name].score = player.shadow_ban_score
        return false
    end
end
--- TFM event eventPlayerGetCheese.
-- Cancel this event for shadow_banned players.
function eventPlayerGetCheese(player_name)
	if pshy.players[player_name].shadow_banned then
        return false
    end
end
--- Display a list of banned players.
local function ChatCommandBanlist(user)
	tfm.exec.chatMessage("<r><b>SCRIPT-BANNED PLAYERS:</b></r>", user)
	for player_name, player in pairs(pshy.players) do
		if player.kicked then
			tfm.exec.chatMessage(string.format("<j>%s KICKED:<j> %s", player_name, player.ban_reason), user)
		elseif player.banned then
			tfm.exec.chatMessage(string.format("<r>%s BANNED:<r> %s", player_name, player.ban_reason), user)
		elseif player.shadow_banned then
			tfm.exec.chatMessage(string.format("<vi>%s SHADOW BANNED:<vi> %s", player_name, player.ban_reason), user)
		end
	end
end
pshy.chat_commands["banlist"] = {func = ChatCommandBanlist, desc = "See the bans list.", argc_min = 0, argc_max = 0, arg_types = {}}
pshy.help_pages["pshy_ban"].commands["banlist"] = pshy.chat_commands["banlist"]
pshy.chat_command_aliases["banlist"] = "bans"
pshy.perms.admins["!banlist"] = true
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_bindkey.lua")
function new_mod.Content()
--- pshy_bindkey.lua
--
-- Bind your keys to a command.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
-- @require pshy_keycodes.lua
-- @require pshy_commands.lua
-- @require pshy_help.lua
--- Module Help Page:
pshy.help_pages["pshy_bindkey"] = {back = "pshy", title = "Key Binds", text = "Bind a command to a key (use %d and %d for x and y)\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_bindkey"] = pshy.help_pages["pshy_bindkey"]
--- Internal use:
pshy.bindkey_players_binds = {}			-- players binds
--- TFM event eventKeyboard.
function eventKeyboard(player_name, key_code, down, x, y)
	if pshy.bindkey_players_binds[player_name] then
		local binds = pshy.bindkey_players_binds[player_name]
		if binds[key_code] then
			local cmd = string.format(binds[key_code], x, y) -- only in Lua!
			eventChatCommand(player_name, cmd)
			return false
		end
	end
end
--- !bindkey <key> [command]
function pshy.bindkey_ChatCommandBindkey(user, keyname, command)
	if not keyname then
		pshy.bindkey_players_binds[user] = nil
		return true, "Deleted key binds."
	end
	keycode = tonumber(keyname)
	if not keycode then
		keycode = pshy.keycodes[keyname]
	end
	if not keycode then
		return false, "unknown key, use the KEY_NAME ('A', 'SLASH', 'NUMPAD_ADD', ...)"
	end
	local binds = pshy.bindkey_players_binds[user]
	pshy.bindkey_players_binds[user] = pshy.bindkey_players_binds[user] or {}
	if command == nil then
		binds[keycode] = nil
		tfm.exec.chatMessage("Key bind removed.", user)
	else
		if string.sub(command, 1, 1) == "!" then
			command = string.sub(command, 2, #command)
		end
		binds[keycode] = command
		tfm.exec.chatMessage("Key bound to `" .. command .. "`.", user)
		tfm.exec.bindKeyboard(user, keycode, true, true)
	end
end
pshy.chat_commands["bindkey"] = {func = pshy.bindkey_ChatCommandBindkey, desc = "bind a command to a key, use $d and $d for coordinates", argc_min = 0, argc_max = 2, arg_types = {"string", "string"}, arg_names = {"KEYNAME", "command"}}
pshy.help_pages["pshy_bindkey"].commands["bindkey"] = pshy.chat_commands["bindkey"]
pshy.perms.admins["!bindkey"] = true
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_bindmouse.lua")
function new_mod.Content()
--- pshy_bindmouse.lua
--
-- Bind your mouse to a command.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
-- @require pshy_commands.lua
-- @require pshy_help.lua
--- Module Help Page:
pshy.help_pages["pshy_bindmouse"] = {back = "pshy", title = "Mouse Binds", text = "Bind a command to your mouse (use $d and $d for x and y)\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_bindmouse"] = pshy.help_pages["pshy_bindmouse"]
--- Internal use:
pshy.bindmouse_players_bind = {}
--- TFM event eventMouse.
function eventMouse(player_name, x, y)
	if pshy.bindmouse_players_bind[player_name] then
		local cmd = string.format(pshy.bindmouse_players_bind[player_name], x, y) -- only in Lua!
		eventChatCommand(player_name, cmd)
		return false
	end
end
--- !bindmouse [command]
function pshy.bindmouse_ChatCommandMousebind(user, command)
	if command == nil then
		pshy.bindmouse_players_bind[user] = nil
		tfm.exec.chatMessage("Mouse bind disabled.", user)
	else
		if string.sub(command, 1, 1) == "!" then
			command = string.sub(command, 2, #command)
		end
		pshy.bindmouse_players_bind[user] = command
		tfm.exec.chatMessage("Mouse bound to `" .. command .. "`.", user)
		system.bindMouse(user, true)
	end
end
pshy.chat_commands["bindmouse"] = {func = pshy.bindmouse_ChatCommandMousebind, desc = "bind a command to your mouse, use %d and %d for coordinates", argc_min = 0, argc_max = 1, arg_types = {"string"}, arg_names = {"command"}}
pshy.help_pages["pshy_bindmouse"].commands["bindmouse"] = pshy.chat_commands["bindmouse"]
pshy.perms.admins["!bindmouse"] = true
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
--- !exit
function pshy.tfm_commands_ChatCommandExit(user)
	system.exit()
end 
pshy.chat_commands["exit"] = {func = pshy.tfm_commands_ChatCommandExit, desc = "stop the module", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_lua_commands"].commands["exit"] = pshy.chat_commands["exit"]
pshy.perms.admins["!exit"] = true
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_motd.lua")
function new_mod.Content()
--- pshy_motd.lua
--
-- Add announcement features.
--
--	!setmotd <join_message>		- Set a message for joining players.
--	!motd						- See the current motd.
--	!announce <message>			- Send an orange message.
--	!luaset pshy.motd_every <n> - Repeat the motd every n messages.
--	!clear						- Clear the chat.
--
-- @author Pshy
-- @namespace pshy
-- @require pshy_commands.lua
-- @require pshy_help.lua
--- Module settings:
pshy.motd = nil			-- The message to display to joining players.
pshy.motd_every = -1			-- Every how many chat messages to display the motd.
--- Module Help Page:
pshy.help_pages["pshy_motd"] = {back = "pshy", title = "MOTD / Announcements", text = "This module adds announcement features.\nThis include a MOTD displayed to joining players.\n", examples = {}}
pshy.help_pages["pshy_motd"].commands = {}
pshy.help_pages["pshy_motd"].examples["luaset pshy.motd_every 100"] = "Show the motd to all players every 100 messages."
pshy.help_pages["pshy"].subpages["pshy_motd"] = pshy.help_pages["pshy_motd"]
--- Internal use.
pshy.message_count_since_motd = 0
--- !setmotd <join_message>
-- Set the motd (or html).
function pshy.ChatCommandSetmotd(user, message)
	if string.sub(message, 1, 1) == "&" then
		pshy.motd = string.gsub(string.gsub(message, "&lt;", "<"), "&gt;", ">")
	else
		pshy.motd = "<fc>" .. message .. "</fc>"
	end
	pshy.ChatCommandMotd(user)
end
pshy.chat_commands["setmotd"] = {func = pshy.ChatCommandSetmotd, desc = "Set the motd (support html).", argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.chat_commands["setmotd"].help = "You may also use html /!\\ BUT CLOSE MARKUPS!\n"
pshy.help_pages["pshy_motd"].commands["setmotd"] = pshy.chat_commands["setmotd"]
--- !motd
-- See the current motd.
function pshy.ChatCommandMotd(user)
	if pshy.motd then
		tfm.exec.chatMessage(pshy.motd, user)
	else
		return false, "No MOTD set."
	end
end
pshy.chat_commands["motd"] = {func = pshy.ChatCommandMotd, desc = "See the current motd.", argc_min = 0, argc_max = 0, arg_types = {}}
pshy.help_pages["pshy_motd"].commands["motd"] = pshy.chat_commands["motd"]
pshy.perms.everyone["!motd"] = true
--- !announce <message>
-- Send an orange message (or html).
function pshy.ChatCommandAnnounce(player_name, message)
	if string.sub(message, 1, 1) == "&" then
		tfm.exec.chatMessage(string.gsub(string.gsub(message, "&lt;", "<"), "&gt;", ">"), nil)
	else
		tfm.exec.chatMessage("<fc>" .. message .. "</fc>", nil)
	end
	-- <r><bv><bl><j><vp>
end
pshy.chat_commands["announce"] = {func = pshy.ChatCommandAnnounce, desc = "Send an orange message in the chat (support html).", argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.chat_commands["announce"].help = "You may also use html /!\\ BUT CLOSE MARKUPS!\n"
pshy.help_pages["pshy_motd"].commands["announce"] = pshy.chat_commands["announce"]
--- TFM event eventNewPlayer
function eventNewPlayer(player_name)
	if pshy.motd then
		tfm.exec.chatMessage(pshy.motd, player_name)
	end
end
--- TFM event eventChatMessage
function eventChatMessage(player_name, message)
	if pshy.motd and pshy.motd_every > 0 then
		pshy.message_count_since_motd = pshy.message_count_since_motd + 1
		if pshy.message_count_since_motd >= pshy.motd_every then
			tfm.exec.chatMessage(pshy.motd, nil)
			pshy.message_count_since_motd = 0
		end
	end
end
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_nicks.lua")
function new_mod.Content()
--- pshy_nicks.lua
--
-- Module to keep track of nicks.
--
-- @author Pshy
-- @hardmerge
-- @require pshy_commands.lua
-- @require pshy_help.lua
-- @require pshy_perms.lua
-- @require pshy_ui.lua
-- @require pshy_utils.lua
-- @namespace Pshy
pshy = pshy or {}
--- Module settings:
pshy.nick_size_min = 2				-- Minimum nick size
pshy.nick_size_max = 24				-- Maximum nick size
pshy.nick_char_set = "[^%w_ %+%-]"	-- Chars not allowed in a nick (using the lua match function)
table.insert(pshy.admin_instructions, "Please use `<ch>!changenick Player#0000 new_name</ch>` before using `<ch2>/changenick</ch2>`.")
--- Help page:
pshy.help_pages["pshy_nicks"] = {back = "pshy", title = "Nicks", text = "This module helps to keep track of player nicks.\n"}
pshy.help_pages["pshy_nicks"].commands = {}
pshy.help_pages["pshy"].subpages["pshy_nicks"] = pshy.help_pages["pshy_nicks"]
--- Nick requests table.
-- key is the player, value is the requested nick
pshy.nick_requests = {}
--- Nick list.
-- Map of player nicks.
-- key is the player, value is the nick
pshy.nicks = {}
--- !nick <new_nick>
-- Request to change nick
function pshy.ChatCommandNick(user, nick)
    if string.match(nick, pshy.nick_char_set) then
        tfm.exec.chatMessage("<r>Please choose an alphanumeric nick.</r>", user)
        return false
    end
    if #nick < pshy.nick_size_min then
        tfm.exec.chatMessage("<r>Please choose a nick of more than " .. pshy.nick_size_min .. " chars.</r>", user)
        return false
    end
    if #nick > pshy.nick_size_max then
        tfm.exec.chatMessage("<r>Please choose a nick of less than " .. pshy.nick_size_max .. " chars.</r>", user)
        return false
    end
    pshy.nick_requests[user] = nick
    tfm.exec.chatMessage("<j>Your request is being reviewed...</j>", user)
    for admin in pairs(pshy.admins) do
        tfm.exec.chatMessage("<j>Player request: <b>!nickaccept " .. user .. " " .. nick .. "</b></j>", admin)
    end
end
pshy.chat_commands["nick"] = {func = pshy.ChatCommandNick, desc = "Request a nick change.", argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.perms.everyone["!nick"] = true
pshy.help_pages["pshy_nicks"].commands["nick"] = pshy.chat_commands["nick"]
pshy.perms.everyone["!nick"] = true
--- !nickdeny <target> [reason]
function pshy.ChatCommandNickdeny(user, target, reason)
    if pshy.nick_requests[target] then
        pshy.nick_requests[target] = nil
        tfm.exec.chatMessage("<r>Sorry, your nick request have been denied :c</r>" .. (reason and (" (" .. reason .. ")") or ""), target)
        tfm.exec.chatMessage("Denied nick request.", user)
    else
        tfm.exec.chatMessage("<r>No pending request for this user</r>", user)
    end
end
pshy.chat_commands["nickdeny"] = {func = pshy.ChatCommandNickdeny, desc = "Deny a nick request.", argc_min = 1, argc_max = 2, arg_types = {"string", "string"}}
pshy.chat_commands["nickdeny"].help = "Deny a nick request for an user, with an optional reason to display to them."
pshy.help_pages["pshy_nicks"].commands["nickdeny"] = pshy.chat_commands["nickdeny"]
pshy.perms.admins["!nickdeny"] = true
--- !nickaccept <target> [nick]
function pshy.ChatCommandNickaccept(user, target, nick)
    if pshy.nick_requests[target] then
        nick = nick or pshy.nick_requests[target]
        pshy.nicks[target] = nick
        pshy.nick_requests[target] = nil
        tfm.exec.chatMessage("<font color='#00ff00'>Your nick will be changed by " .. user .. " :&gt;", target)
        tfm.exec.chatMessage("<fc>Enter this command " .. user .. ": \n<font size='12'><b>/changenick " .. target .. " " .. nick .. " </b></fc></font>", user)
    else
        tfm.exec.chatMessage("<r>No pending request for this user</r>", user)
    end
end
pshy.chat_commands["nickaccept"] = {func = pshy.ChatCommandNickaccept, desc = "Change a nick folowing a request.", argc_min = 1, argc_max = 2, arg_types = {"string", "string"}}
pshy.chat_commands["nickaccept"].help = "Accept a nick request for an user, with an optional alternative nick.\n"
pshy.help_pages["pshy_nicks"].commands["nickaccept"] = pshy.chat_commands["nickaccept"]
pshy.perms.admins["!nickaccept"] = true
--- !changenick <target> <nick>
function pshy.ChatCommandChangenick(user, target, nick)
	target = pshy.FindPlayerNameOrError(target)
	if nick == "off" then
		nick = pshy.StrSplit(target, "#")[1]
	end
	pshy.nicks[target] = nick
	pshy.nick_requests[target] = nil
	tfm.exec.chatMessage("<fc>Please enter this command: \n<font size='12'><b>/changenick " .. target .. " " .. nick .. " </b></fc></font>", user)
end
pshy.chat_commands["changenick"] = {func = pshy.ChatCommandChangenick, desc = "Inform the module of a nick change.", argc_min = 2, argc_max = 2, arg_types = {"string", "string"}}
pshy.chat_commands["changenick"].help = "Inform the module that you changed a nick.\nThis does not change the player nick, you need to use /changenick as well!\nNo message is sent to the player."
pshy.help_pages["pshy_nicks"].commands["changenick"] = pshy.chat_commands["changenick"]
pshy.perms.admins["!changenick"] = true
--- !nicks
-- Opens an ui to accept or deny names
function pshy.ChatCommandNicks(user)
	local popup = pshy.UICreate()
	popup.id = popup.id + 700
	popup.x = 550
	popup.y = 25
	popup.w = 250
	popup.h = nil
	popup.alpha = 0.5
	popup.player = player_name
	-- current nicks
	popup.text = "<p align='center'><font size='16'>Player Nicks</font></p>"
	popup.text = popup.text .. "<font color='#ccffcc'>"
    for player_name, player_nick in pairs(pshy.nicks) do
        popup.text = popup.text .. "" .. player_nick .. " &lt;- " .. player_name .. "<br>"
    end
    popup.text = popup.text .. "</font><br>"
    -- requests
    popup.text = popup.text .. "<p align='center'><font size='16'>Requests</font></p>"
	popup.text = popup.text .. "<font color='#ffffaa'>"
	local request_count = 0
    for player_name, player_nick in pairs(pshy.nick_requests) do
    	request_count = request_count + 1
        popup.text = popup.text .. player_name .. " -&gt; " .. player_nick .. " "
        popup.text = popup.text .. "<p align='right'><a href='event:apcmd nickaccept " .. player_name .. " " .. player_nick .. "\napcmd nicks'><font color='#00ff00'>accept</font></a>/<a href='event:apcmd nickdeny " .. player_name .. "\napcmd nicks'><font color='#ff0000'>deny</font></a></p>"
    	if request_count >= 4 then
    		break
    	end
    end
    popup.text = popup.text .. "</font>"
    -- close
    popup.text = popup.text .. "\n<br><font size='16' color='#ffffff'><p align='right'><a href='event:close'>[ CLOSE ]</a></p></font>"
	pshy.UIShow(popup, user)
end
pshy.chat_commands["nicks"] = {func = pshy.ChatCommandNicks, desc = "Show the nicks interface.", argc_min = 0, argc_max = 0, arg_types = {}}
pshy.help_pages["pshy_nicks"].commands["nicks"] = pshy.chat_commands["nicks"]
pshy.perms.everyone["!nicks"] = true
--- TFM event eventPlayerLeft
-- @brief deleted cause players keep names on rejoin
--function eventPlayerLeft(playerName)
--    pshy.nicks[playerName] = nil
--    pshy.nick_requests[playerName] = nil
--end
--- Debug Initialization
--pshy.nick_requests["User1#0000"] = "john shepard"
--pshy.nick_requests["Troll2#0000"] = "prout camembert"
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_rain.lua")
function new_mod.Content()
--- pshy_rain.lua
--
-- Start item rains.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @require pshy_commands.lua
-- @require pshy_help.lua
-- @require pshy_utils.lua
--- Module's help page.
pshy.help_pages["pshy_rain"] = {back = "pshy", title = "Object Rains", text = "Cause weird rains.", commands = {}}
pshy.help_pages["pshy_rain"].commands = {}
pshy.help_pages["pshy"].subpages["pshy_rain"] = pshy.help_pages["pshy_rain"]
--- Internal use:
pshy.rain_enabled = false
pshy.rain_next_drop_time = 0
pshy.rain_object_types = {}
pshy.rain_spawned_object_ids = {}
--- Random TFM objects.
-- List of objects for random selection.
pshy.rain_random_object_types = {}
table.insert(pshy.rain_random_object_types, 1) -- little box
table.insert(pshy.rain_random_object_types, 2) -- box
table.insert(pshy.rain_random_object_types, 3) -- little board
table.insert(pshy.rain_random_object_types, 6) -- ball
table.insert(pshy.rain_random_object_types, 7) -- trampoline
table.insert(pshy.rain_random_object_types, 10) -- anvil
table.insert(pshy.rain_random_object_types, 17) -- cannon
table.insert(pshy.rain_random_object_types, 33) -- chicken
table.insert(pshy.rain_random_object_types, 39) -- apple
table.insert(pshy.rain_random_object_types, 40) -- sheep
table.insert(pshy.rain_random_object_types, 45) -- little board ice
table.insert(pshy.rain_random_object_types, 54) -- ice cube
table.insert(pshy.rain_random_object_types, 68) -- triangle
--- Get a random TFM object.
function pshy.rain_RandomTFMObjectType()
	return pshy.rain_random_object_types[math.random(1, #pshy.rain_random_object_types)]
end
--- Spawn a random TFM object in the sky.
function pshy.rain_SpawnRandomTFMObject(object_type)
	return tfm.exec.addShamanObject(object_type or pshy.rain_RandomTFMObjectType(), math.random(0, 800), -60, math.random(0, 359), 0, 0, math.random(0, 8) == 0)
end
--- Drop an object in the sky when the rain is active.
-- @private
function pshy.rain_Drop()
	if math.random(0, 1) == 0 then 
		if pshy.rain_object_types == nil then
			local new_id = pshy.rain_SpawnRandomTFMObject()
			table.insert(pshy.rain_spawned_object_ids, new_id)
		else
			local new_object_type = pshy.rain_object_types[math.random(#pshy.rain_object_types)]
			assert(new_object_type ~= nil)
			local new_id = pshy.rain_SpawnRandomTFMObject(new_object_type)
			table.insert(pshy.rain_spawned_object_ids, new_id)
		end
	end
	if #pshy.rain_spawned_object_ids > 8 then
		tfm.exec.removeObject(table.remove(pshy.rain_spawned_object_ids, 1))
	end
end
--- Start the rain.
-- @public
-- @param types The object types/id to be summoning durring the rain.
function pshy.rain_Start(types)
	pshy.rain_enabled = true
	pshy.rain_object_types = types
end
--- Stop the rain.
-- @public
function pshy.rain_Stop()
	pshy.rain_enabled = false
	pshy.rain_object_types = nil
	for i, id in ipairs(pshy.rain_spawned_object_ids) do
		tfm.exec.removeObject(id)
	end
	pshy.rain_spawned_object_ids = {}
end
--- TFM event eventNewGame.
function eventNewGame()
	pshy.rain_next_drop_time = nil
end
--- TFM event eventLoop.
function eventLoop(time, time_remaining)
	if pshy.rain_enabled then
		pshy.rain_next_drop_time = pshy.rain_next_drop_time or time - 1
		if pshy.rain_next_drop_time < time then
			pshy.rain_next_drop_time = pshy.rain_next_drop_time + 500 -- run Tick() every 500 ms only
			pshy.rain_Drop()
		end
	end
end
--- !rain
function pshy.rain_ChatCommandRain(user, ...)
	rains_names = {...}
	if #rains_names ~= 0 then
		pshy.rain_Start(rains_names)
		pshy.Answer("Rain started!", user)
	elseif pshy.rain_enabled then
		pshy.rain_Stop()
		pshy.Answer("Rain stopped!", user)
	else
	 	pshy.rain_Start(nil)
		pshy.Answer("Random rain started!", user)
	end
end
pshy.chat_commands["rain"] = {func = pshy.rain_ChatCommandRain, desc = "start/stop an object/random object rain", argc_min = 0, argc_max = 4, arg_types = {tfm.enum.shamanObject, tfm.enum.shamanObject, tfm.enum.shamanObject, tfm.enum.shamanObject}, arg_names = {"shamanObject", "shamanObject", "shamanObject", "shamanObject"}}
pshy.help_pages["pshy_rain"].commands["rain"] = pshy.chat_commands["rain"]
pshy.perms.admins["!rain"] = true
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
	if autonewgame == nil then
		autonewgame = true
	end
	tfm.exec.disableAutoNewGame(not autonewgame)
end 
pshy.chat_commands["autonewgame"] = {func = pshy.tfm_commands_ChatCommandAutonewgame, desc = "enable (or disable) TFM automatic map changes", argc_min = 0, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_tfm_commands"].commands["autonewgame"] = pshy.chat_commands["autonewgame"]
pshy.perms.admins["!autonewgame"] = true
--- !autoshaman
function pshy.tfm_commands_ChatCommandAutoshaman(user, autoshaman)
	if autoshaman == nil then
		autoshaman = true
	end
	tfm.exec.disableAutoShaman(not autoshaman)
end 
pshy.chat_commands["autoshaman"] = {func = pshy.tfm_commands_ChatCommandAutoshaman, desc = "enable (or disable) TFM automatic shaman choice", argc_min = 0, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_tfm_commands"].commands["autoshaman"] = pshy.chat_commands["autoshaman"]
pshy.perms.admins["!autoshaman"] = true
--- !shamanskills
function pshy.tfm_commands_ChatCommandShamanskills(user, shamanskills)
	if shamanskills == nil then
		shamanskills = true
	end
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
	if autotimeleft == nil then
		autotimeleft = true
	end
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
	if autoscore == nil then
		autoscore = true
	end
	tfm.exec.disableAutoScore(not autoscore)
end 
pshy.chat_commands["autoscore"] = {func = pshy.tfm_commands_ChatCommandAutoscore, desc = "enable (or disable) TFM score handling", argc_min = 0, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_tfm_commands"].commands["autoscore"] = pshy.chat_commands["autoscore"]
pshy.perms.admins["!autoscore"] = true
--- !afkdeath
function pshy.tfm_commands_ChatCommandAfkdeath(user, afkdeath)
	if afkdeath == nil then
		afkdeath = true
	end
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
--- !colorpicker
function pshy.tfm_commands_ChatCommandColorpicker(user, target)
	target = pshy.commands_GetTarget(user, target, "!colorpicker")
	ui.showColorPicker(49, target, 0, "Get a color code:")
end 
pshy.chat_commands["colorpicker"] = {func = pshy.tfm_commands_ChatCommandColorpicker, desc = "show the colorpicker", argc_min = 0, argc_max = 1, arg_types = {"player"}}
pshy.help_pages["pshy_tfm_commands"].commands["colorpicker"] = pshy.chat_commands["colorpicker"]
pshy.perms.everyone["!colorpicker"] = true
pshy.perms.admins["!colorpicker-others"] = true
--- !getxml
-- @TODO: xml may be cut in the wrong spot!
function pshy.ChatCommandGetxml(user, force)
	if not force and (not tfm.get.room.currentMap or string.sub(tfm.get.room.currentMap, 1, 1) ~= '@') then
		return false, "This command only works on @mapcode maps."
	end
	local xml = tfm.get.room.xmlMapInfo.xml
	xml = string.gsub(xml, "<", "&lt;")
	xml = string.gsub(xml, ">", "&gt;")
	tfm.exec.chatMessage("<ch>=== MAP CODE (" .. tostring(#xml) .. "#) ===</ch>", user)
	while #xml > 0 do
		part = string.sub(xml, 1, 180)
		tfm.exec.chatMessage(part, user)
		xml = string.sub(xml, 180 + 1, #xml)
	end
	tfm.exec.chatMessage("<ch>=== END OF MAP CODE ===</ch>", user)
end
pshy.chat_commands["getxml"] = {func = pshy.ChatCommandGetxml, desc = "get the current map's xml (only for @maps)", argc_min = 0, argc_max = 1, arg_types = {"bool"}}
pshy.help_pages["pshy_tfm_commands"].commands["getxml"] = pshy.chat_commands["getxml"]
--- !clear
function pshy.ChatCommandClear(user)
	tfm.exec.chatMessage("\n\n\n\n\n\n\n\n\n\n\n\n\n", nil)
end
pshy.chat_commands["clear"] = {func = pshy.ChatCommandClear, desc = "clear the chat for everone", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_tfm_commands"].commands["clear"] = pshy.chat_commands["clear"]
pshy.perms.admins["!clear"] = true
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
local new_mod = pshy.merge_ModuleBegin("pshy_requests.lua")
function new_mod.Content()
--- pshy_requests.lua
--
-- Allow players to request room admins to use FunCorp-only commands on them.
--
-- @author TFM:Pshy#3753 DC:Pshy#7998
-- @namespace pshy
-- @require pshy_commands.lua
-- @require pshy_nicks.lua
-- @require pshy_help.lua
--- Module Help Page:
pshy.help_pages["pshy_requests"] = {back = "pshy", title = "Requests", text = "Allow players to request room admins to use FunCorp-only commands on them.\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_requests"] = pshy.help_pages["pshy_requests"]
--- Module Settings:
pshy.requests_modify_delay = 20 * 1000		-- delay before being able to modify a non accepted request
pshy.requests_types = {}					-- map of possible requests
pshy.requests_types["changenick"] = {name = "changenick", delay = 240 * 1000, players_next_use_time = {}, players_requests = {}}
pshy.requests_types["colornick"] = {name = "colornick", delay = 120 * 1000, players_next_use_time = {}, players_requests = {}}
pshy.requests_types["colormouse"] = {name = "colormouse", delay = 120 * 1000, players_next_use_time = {}, players_requests = {}}
--- Internal Use:
pshy.requests = {}							-- list of requests
pshy.requests_last_id = 0					-- next unique id to give to a request
--- Add a new player request.
-- @param player_name The Player#0000 name.
-- @param request_type The request type name
function pshy.requests_Add(player_name, request_type_name, value)
	assert(type(player_name) == "string")
	assert(type(request_type_name) == "string")
	local rt = pshy.requests_types[request_type_name]
	if rt.players_requests[player_name] then
		-- delete existing request
		local r = rt.players_requests[player_name]
		pshy.requests_Remove(r)
	end
	-- new request
	pshy.requests_last_id = pshy.requests_last_id + 1
	local r = {}
	r.id = pshy.requests_last_id
	r.request_type = rt
	r.value = value
	r.player_name = player_name
	rt.players_requests[player_name] = r
	table.insert(pshy.requests, r)
	return r.id
end
--- Remove a player request
-- @parm rt The player's request table.
function pshy.requests_Remove(r)
	assert(type(r) == "table")
	local index
	for i_request, request in ipairs(pshy.requests) do
		if request == r then
			index = i_request
			break
		end
	end
	r.request_type.players_requests[r.player_name] = nil
	table.remove(pshy.requests, index)
end
--- Get a player's request table from its id.
-- @param id The request's id.
-- @return The player's request table.
function pshy.requests_Get(id)
	for i_request, request in ipairs(pshy.requests) do
		if request.id == id then
			return request
		end
	end
end
--- !requestdeny <id> [reason]
function pshy.requests_ChatCommandRequestdeny(user, id, reason)
	local r = pshy.requests_Get(id)
	if not r then
		return false, "No request with id " .. tostring(id) .. "."
	end
	pshy.requests_Remove(r)
	if reason then
		tfm.exec.chatMessage("<r>Your " .. r.request_type.name .. " request have been denied (" .. reason .. ")</r>", r.player_name)
	else
		tfm.exec.chatMessage("<r>Your " .. r.request_type.name .. " request have been denied :c</r>", r.player_name)
	end
end
pshy.chat_commands["requestdeny"] = {func = pshy.requests_ChatCommandRequestdeny, desc = "deny a player's request for a FunCorp command", argc_min = 1, argc_max = 2, arg_types = {"number", "string"}}
pshy.help_pages["pshy_requests"].commands["requestdeny"] = pshy.chat_commands["requestdeny"]
pshy.perms.admins["!requestdeny"] = true
--- !requestaccept <id>
function pshy.requests_ChatCommandRequestaccept(user, id)
	local r = pshy.requests_Get(id)
	if not r then
		return false, "No request with id " .. tostring(id) .. "."
	end
	-- special case
	if r.request_type.name == "changenick" then
		pshy.nicks[r.player_name] = r.value
	end
	-- removing request
	pshy.requests_Remove(r)
	tfm.exec.chatMessage("<fc>Please Enter \t<b>/" .. r.request_type.name .. " <v>" .. r.player_name .. "</v> " .. r.value .. "</b></fc>", user)
	tfm.exec.chatMessage("<vp>Your " .. r.request_type.name .. " request have been accepted :></vp>", r.player_name)
	r.request_type.players_next_use_time[user] = os.time() + r.request_type.delay
end
pshy.chat_commands["requestaccept"] = {func = pshy.requests_ChatCommandRequestaccept, desc = "accept a player's request for a FunCorp command", argc_min = 1, argc_max = 1, arg_types = {"number"}}
pshy.help_pages["pshy_requests"].commands["requestaccept"] = pshy.chat_commands["requestaccept"]
pshy.perms.admins["!requestaccept"] = true
--- !requests
function pshy.requests_ChatCommandRequests(user)
	if #pshy.requests == 0 then
		tfm.exec.chatMessage("<vp>No pending request ;)</vp>", user)
		return
	end
	for i_request, request in ipairs(pshy.requests) do
		tfm.exec.chatMessage("<j>" .. request.id .. "</j>\t<d>/" .. request.request_type.name .. " <v>" .. request.player_name .. "</v> " .. request.value .. "</d>", user)
		if i_request == 8 then
			break
		end
	end
end
pshy.chat_commands["requests"] = {func = pshy.requests_ChatCommandRequests, desc = "show the oldest 8 requests", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_requests"].commands["requests"] = pshy.chat_commands["requests"]
pshy.perms.admins["!request"] = true
--- !request changenick|colornick|colormouse
function pshy.requests_ChatCommandRequest(user, request_type_name, value)
	-- get the request type
	local rt = pshy.requests_types[request_type_name]
	if not rt then
		return false, "Valid requests are changenick, colornick and colormouse."
	end
	local os_time = os.time()
	local delay = rt.players_next_use_time[user] and (rt.players_next_use_time[user] - os_time) or 0
	-- delay check
	if delay > 0 then
		return false, "You must wait " .. tostring(math.floor(delay / 1000)) .. " seconds before the next request."
	end
	-- proceed
	rt.players_next_use_time[user] = os_time + pshy.requests_modify_delay
	pshy.requests_Add(user, request_type_name, value)
	tfm.exec.chatMessage("<j>You will be notified when your " .. request_type_name .. " request will be approved or denied.</j>", user)
end
pshy.chat_commands["request"] = {func = pshy.requests_ChatCommandRequest, desc = "request a FunCorp command to be used on you", argc_min = 2, argc_max = 2, arg_types = {"string", "string"}, arg_names = {"changenick|colornick|colormouse"}}
pshy.perms.everyone["!request"] = true
pshy.help_pages["pshy_requests"].commands["request"] = pshy.chat_commands["request"]
--- !nick (same as `!request changenick <nickname>`)
function requests_ChatCommandNick(user, nickname)
	pshy.requests_ChatCommandRequest(user, "changenick", nickname)
end
--pshy.chat_commands["nick"] = {func = pshy.requests_ChatCommandNick, desc = "request a nick change", argc_min = 1, argc_max = 1, arg_types = {"string"}, arg_names = {"changenick|colornick|colormouse"}}
--pshy.perms.everyone["!nick"] = true
--pshy.help_pages["pshy_requests"].commands["nick"] = pshy.chat_commands["nick"]
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_speedfly.lua")
function new_mod.Content()
--- pshy_speedfly.lua
--
-- Fly, speed boost, and teleport features.
--
-- @author DC:Pshy#7998 TFM:Pshy#3752
-- @namespace pshy
-- @require pshy_commands.lua
-- @require pshy_help.lua
--- Module Help Page:
pshy.help_pages["pshy_speedfly"] = {back = "pshy", title = "Speed / Fly / Teleport", text = "Fly and speed boost.\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_speedfly"] = pshy.help_pages["pshy_speedfly"]
--- Settings:
pshy.speedfly_reset_on_new_game = true
--- Internal Use:
pshy.speedfly_flyers = {}		-- flying players
pshy.speedfly_speedies = {}		-- speedy players (value is the speed)
--- Give speed to a player.
function pshy.speedfly_Speed(player_name, speed)
	if speed == nil then
		speed = 20
	end
	if speed <= 1 or speed == false or speed == pshy.speedfly_speedies[player_name]then
		pshy.speedfly_speedies[player_name] = nil
		tfm.exec.chatMessage("<i><ch2>You are back to turtle speed.</ch2></i>", player_name)
	else
		pshy.speedfly_speedies[player_name] = speed
		tfm.exec.bindKeyboard(player_name, 0, true, true)
		tfm.exec.bindKeyboard(player_name, 2, true, true)
		tfm.exec.chatMessage("<i><ch>You feel like sonic!</ch></i>", player_name)
	end
end
--- Give fly to a player.
function pshy.speedfly_Fly(player_name, value)
	if value == nil then
		value = 50
	end
	if value then
		pshy.speedfly_flyers[player_name] = true
		tfm.exec.bindKeyboard(player_name, 1, true, true)
		tfm.exec.bindKeyboard(player_name, 1, false, true)
		tfm.exec.chatMessage("<i><ch>Jump to flap your wings!</ch></i>", player_name)
	else
		pshy.speedfly_flyers[player_name] = nil
		tfm.exec.chatMessage("<i><ch2>Your feet are happy again.</ch2></i>", player_name)
	end
end
--- Get the target of the command, throwing on permission issue.
-- @private
function pshy.speedfly_GetTarget(user, target, perm_prefix)
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
--- !speed
function pshy.ChatCommandSpeed(user, speed, target)
	target = pshy.speedfly_GetTarget(user, target, "!speed")
	speed = speed or (pshy.speedfly_speedies[target] and 0 or 50)
	assert(speed >= 0, "the minimum speed boost is 0")
	assert(speed <= 200, "the maximum speed boost is 200")
	pshy.speedfly_Speed(target, speed)
end 
pshy.chat_commands["speed"] = {func = pshy.ChatCommandSpeed, desc = "toggle fast acceleration mode", argc_min = 0, argc_max = 2, arg_types = {"number", "player"}, arg_names = {"speed", "target_player"}}
pshy.help_pages["pshy_speedfly"].commands["speed"] = pshy.chat_commands["speed"]
pshy.perms.cheats["!speed"] = true
pshy.perms.admins["!speed-others"] = true
--- !fly
function pshy.ChatCommandFly(user, value, target)
	target = pshy.speedfly_GetTarget(user, target, "!fly")
	value = value or not pshy.speedfly_flyers[target]
	pshy.speedfly_Fly(target, value)
end 
pshy.chat_commands["fly"] = {func = pshy.ChatCommandFly, desc = "toggle fly mode", argc_min = 0, argc_max = 2, arg_types = {"bool", "player"}}
pshy.help_pages["pshy_speedfly"].commands["fly"] = pshy.chat_commands["fly"]
pshy.perms.cheats["!fly"] = true
pshy.perms.admins["!fly-others"] = true
--- !tpp (teleport to player)
function pshy.ChatCommandTpp(user, destination, target)
	target = pshy.speedfly_GetTarget(user, target, "!tpp")
	destination = pshy.FindPlayerNameOrError(destination)
	tfm.exec.movePlayer(target, tfm.get.room.playerList[destination].x, tfm.get.room.playerList[destination].y, false, 0, 0, true)
end
pshy.chat_commands["tpp"] = {func = pshy.ChatCommandTpp, desc = "teleport to a player", argc_min = 1, argc_max = 2, arg_types = {"player", "player"}, arg_names = {"destination", "target_player"}}
pshy.help_pages["pshy_speedfly"].commands["tpp"] = pshy.chat_commands["tpp"]
pshy.perms.cheats["!tpp"] = true
pshy.perms.admins["!tpp-others"] = true
--- !tpl (teleport to location)
function pshy.ChatCommandTpl(user, x, y, target)
	target = pshy.speedfly_GetTarget(user, target, "!tpl")
	tfm.exec.movePlayer(target, x, y, false, 0, 0, true)
end
pshy.chat_commands["tpl"] = {func = pshy.ChatCommandTpl, desc = "teleport to a location", argc_min = 2, argc_max = 3, arg_types = {"number", "number", "player"}, arg_names = {"x", "y", "target_player"}}
pshy.help_pages["pshy_speedfly"].commands["tpl"] = pshy.chat_commands["tpl"]
pshy.perms.cheats["!tpl"] = true
pshy.perms.admins["!tpl-others"] = true
--- !coords
function pshy.ChatCommandTpl(user)
	tfm.exec.chatMessage(tostring(tfm.get.room.playerList[user].x) .. "\t" .. tostring(tfm.get.room.playerList[user].y), user)
end
pshy.chat_commands["coords"] = {func = pshy.ChatCommandTpl, desc = "get your coordinates", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_speedfly"].commands["coords"] = pshy.chat_commands["coords"]
pshy.perms.cheats["!coords"] = true
--- TFM event eventkeyboard
function eventKeyboard(player_name, key_code, down, x, y)
	if key_code == 1 and down and pshy.speedfly_flyers[player_name] then
		tfm.exec.movePlayer(player_name, 0, 0, true, 0, -55, false)
	elseif key_code == 0 and down and pshy.speedfly_speedies[player_name] then
		tfm.exec.movePlayer(player_name, 0, 0, true, -(pshy.speedfly_speedies[player_name]), 0, true)
	elseif key_code == 2 and down and pshy.speedfly_speedies[player_name] then
		tfm.exec.movePlayer(player_name, 0, 0, true, pshy.speedfly_speedies[player_name], 0, true)
	end
end
--- TFM event eventnewGame.
function eventNewGame()
	if pshy.speedfly_reset_on_new_game then
		pshy.speedfly_flyers = {}
		pshy.speedfly_speedies = {}
	end
end
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_bonuses.lua")
function new_mod.Content()
--- pshy_bonus.lua
--
-- Add custom bonuses.
--
-- Either use `pshy.bonuses_SetList()` to set the current bonus list.
-- Or add them individually with `pshy.bonuses_Add()`.
--
-- Fields:
--	x (bonus only):				int, bonus location
--	y (bonus only):				int, bonus location
--	image:						string, bonus image name in pshy_imagedb
--	func:						function to call when the bonus is picked
--								if func returns false then the bonus will not be considered picked by the script (but TFM will)
--	shared:						bool, do this bonus disapear when picked by any player
--	remain:						bool, do this bonus never disapear, even when picked
--	enabled (bonus only):		if this bonus is enabled/visible by default
--	autorespawn (bonus only):	bool, do this respawn automatically
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @require pshy_imagedb.lua
pshy = pshy or {}
--- Bonus types.
-- @public
-- List of bonus types and informations.
pshy.bonuses_types = {}						-- default bonus properties
--- Bonus List.
-- Keys: The bonus ids.
-- Values: A table with the folowing fields:
--	- type: Bonus type, as a table.
--	- x: Bonus coordinates.
--	- y: Bonus coordinates.
--	- enabled: Is it enabled by default (true == always, false == never/manual, nil == once only).
pshy.bonuses_list	= {}						-- list of ingame bonuses
pshy.bonuses_taken	= {}
--- Internal Use:
pshy.bonuses_players_image_ids = {}
--- Set the list of bonuses, and show them.
-- @public
function pshy.bonuses_SetList(bonus_list)
	pshy.bonuses_DisableAll()
	pshy.bonuses_list = pshy.ListCopy(bonus_list)
	pshy.bonuses_EnableAll()
end
--- Create and enable a bonus.
-- @public
-- Either use this function or `pshy.bonuses_SetList`, but not both.
-- @param bonus_type The name or table corresponding to the bonus type.
-- @param bonus_x The bonus location.
-- @param bonus_y The bonus location.
-- @param enabled Is the bonus enabled for all players by default (nil is yes but not for new players).
-- @return The id of the created bonus.
function pshy.bonuses_Add(bonus_type_name, bonus_x, bonus_y, bonus_enabled)
	local bonus_type = bonus_type_name
	if type(bonus_type) == "string" then
		assert(pshy.bonuses_types[bonus_type], "invalid bonus type " .. tostring(bonus_type))
		bonus_type = pshy.bonuses_types[bonus_type]
	end
	assert(type(bonus_type) == "table")
	-- insert
	local new_id = #pshy.bonuses_list + 1 -- @TODO: this doesnt allow removing bonuses (IN FACT IT LIMITS ALOT)
	local new_bonus = {id = new_id, type = bonus_type_name, x = bonus_x, y = bonus_y, enabled = bonus_enabled}
	pshy.bonuses_list[new_id] = new_bonus
	-- show
	if bonus_enabled ~= false then
		pshy.bonuses_Enable(new_id)
	end
	return new_id
end
--- Enable a bonus.
-- @public
-- When a bonus is enabled, it can be picked by players.
function pshy.bonuses_Enable(bonus_id, player_name)
	assert(type(bonus_id) == "number")
	if player_name == nil then
		for player_name in pairs(tfm.get.room.playerList) do
			pshy.bonuses_Enable(bonus_id, player_name)
		end
		return
	end
	pshy.bonuses_players_image_ids[player_name] = pshy.bonuses_players_image_ids[player_name] or {}
	local bonus = pshy.bonuses_list[bonus_id]
	local ids = pshy.bonuses_players_image_ids[player_name]
	-- get bonus type
	local bonus_type = bonus.type
	if type(bonus_type) == "string" then
		assert(pshy.bonuses_types[bonus_type], "invalid bonus type " .. tostring(bonus_type))
		bonus_type = pshy.bonuses_types[bonus_type]
	end
	assert(type(bonus_type) == 'table', "bonus type must be a table or a string")
	-- if already shown
	if ids[bonus_id] ~= nil then
		pshy.bonuses_Disable(bonus_id, player_name)
	end
	-- add bonus
	tfm.exec.addBonus(0, bonus.x, bonus.y, bonus_id, 0, false, player_name)
	-- add image
	--ids[bonus_id] = tfm.exec.addImage(bonus.image or bonus_type.image, "!0", bonus.x - 15, bonus.y - 20, player_name) -- todo: location
	ids[bonus_id] = pshy.imagedb_AddImage(bonus.image or bonus_type.image, "!0", bonus.x, bonus.y, player_name, nil, nil, 0, 1.0)
end
--- Hide a bonus.
-- @public
-- This prevent the bonus from being picked, without deleting it.
function pshy.bonuses_Disable(bonus_id, player_name)
	assert(type(bonus_id) == "number")
	if player_name == nil then
		for player_name in pairs(tfm.get.room.playerList) do
			pshy.bonuses_Disable(bonus_id, player_name)
		end
		return
	end
	if not pshy.bonuses_players_image_ids[player_name] then
		return
	end
	local bonus = pshy.bonuses_list[bonus_id]
	local ids = pshy.bonuses_players_image_ids[player_name]
	-- if already hidden
	if ids[bonus_id] == nil then
		return
	end
	-- remove bonus
	tfm.exec.removeBonus(bonus_id, player_name)
	-- remove image
	tfm.exec.removeImage(ids[bonus_id])
end
--- Show all bonuses, except the ones with `visible == false`.
-- @private
function pshy.bonuses_EnableAll(player_name)
	for bonus_id, bonus in pairs(pshy.bonuses_list) do
		if not bonus.hidden then
			pshy.bonuses_Enable(bonus_id, player_name)
		end
	end
end
--- Disable all bonuses for all players.
-- @private
function pshy.bonuses_DisableAll(player_name)
	for bonus_id, bonus in pairs(pshy.bonuses_list) do
		pshy.bonuses_Disable(bonus_id, player_name)
	end
end
--- TFM event eventPlayerBonusGrabbed.
function eventPlayerBonusGrabbed(player_name, id)
	--print("picked at " .. tostring(os.time()))
	local bonus = pshy.bonuses_list[id]
	local bonus_type = bonus.type
	if type(bonus_type) == "string" then
		assert(pshy.bonuses_types[bonus_type], "invalid bonus type " .. tostring(bonus_type))
		bonus_type = pshy.bonuses_types[bonus_type]
	end
	-- checking if that bonus was already taken (bug caused by TFM)
	if bonus.shared or bonus_type.shared then
		if pshy.bonuses_taken[id] then
			return false
		end
		pshy.bonuses_taken[id] = true
	end
	-- running the callback
	local func = bonus.func or bonus_type.func
	local pick_rst = nil
	if func then
		pick_rst = func(player_name, bonus)
	end
	-- disable bonus
	if pick_rst ~= false then -- if func returns false then dont unspawn the bonus
		if bonus.shared or (bonus.shared == nil and bonus_type.shared) then
			pshy.bonuses_Disable(id, nil)
			if bonus.remain or (bonus.remain == nil and bonus_type.remain) then
				pshy.bonuses_Enable(id, nil)
			end
		else
			pshy.bonuses_Disable(id, player_name)
			if bonus.remain or (bonus.remain == nil and bonus_type.remain) then
				pshy.bonuses_Enable(id, player_name)
			end
		end
	end
	-- if callback done then skip other bonus events
	--if func then
	--	return false
	--end
end
--- TFM event eventNewGame.
function eventNewGame()
	pshy.bonuses_list = {}
	pshy.bonuses_players_image_ids = {}
	pshy.bonuses_taken = {}
end
--- TFM event eventPlayerRespawn.
function eventPlayerRespawn(player_name)
	for bonuses_id, bonus in pairs(pshy.bonuses_list) do
		if bonus.enabled == true and bonus.autorespawn then
			pshy.bonuses_Enable(bonuses_id, player_name)
		end
	end
end
--- TFM event eventNewPlayer.
-- Show the bonus, but purely for the spectating player to understand what's going on.
function eventNewPlayer(player_name)
	for bonuses_id, bonus in pairs(pshy.bonuses_list) do
		if bonus.enabled == true then
			pshy.bonuses_Enable(bonuses_id, player_name)
		end
	end
end
--- TFM event eventPlayerLeft.
function eventPlayerLeft(player_name)
	pshy.bonuses_DisableAll(player_name) -- @todo: is this required?
	pshy.bonuses_players_image_ids[player_name] = nil
end
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_mario_bonuses.lua")
function new_mod.Content()
--- pshy_mario_bonuses.lua
--
-- Mario related bonuses.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @require pshy_checkpoints.lua
-- @require pshy_speedfly.lua
-- @require pshy_bonuses.lua
-- @require pshy_imagedb.lua
--- Module Settings
pshy.mario_powerball_delay = 3000
-- Internal Use:
pshy.players = pshy.players or {}			-- represent the player
--		.mario_coins						-- coint of coins grabbed
--		.mario_grown						-- if the player was grown
--		.mario_flower						-- if the player unlocked powerballs
--		.mario_thrown_powerball_id			-- object id of the thrown powerball
--		.mario_next_powerball_time			-- next time the powerball can be used
--- Touch a player.
-- @TODO: this is probably the wrong place.
local function TouchPlayer(player_name)
	pshy.players[player_name] = pshy.players[player_name] or {}
	local player = pshy.players[player_name]
	player.mario_coins = player.mario_coins or 0
	player.mario_grown = player.mario_grown or false
	player.mario_flower = player.mario_flower or false
	player.powerball_type = tfm.enum.shamanObject.snowBall --tfm.enum.shamanObject.(snowBall powerBall chicken)
	player.mario_thrown_powerball_id = player.mario_thrown_powerball_id or nil
	player.mario_next_powerball_time = player.mario_next_powerball_time or nil
	player.mario_name_color = player.mario_name_color or 0xbbbbbb
	tfm.exec.setNameColor(player_name, player.mario_name_color)
end
--- MarioCoin.
function pshy.bonuses_callback_MarioCoin(player_name, bonus)
	print("mario bonuses: picked")
	local player = pshy.players[player_name]
	player.mario_coins = player.mario_coins + 1
	tfm.exec.setPlayerScore(player_name, 1, true)
	-- update player color
	if player.mario_coins == 9 then
		player.mario_name_color = 0x6688ff -- blue
	elseif player.mario_coins == 25 then
		player.mario_name_color = 0x00eeee -- cyan
	elseif player.mario_coins == 35 then
		player.mario_name_color = 0x77ff77 -- green
	elseif player.mario_coins == 55 then
		player.mario_name_color = 0xeeee00 -- yellow
	elseif player.mario_coins == 75 then
		player.mario_name_color = 0xff7700 -- orange
	elseif player.mario_coins == 100 then
		player.mario_name_color = 0xff0000 -- red
	elseif player.mario_coins == 150 then
		player.mario_name_color = 0xff00bb -- pink
	elseif player.mario_coins == 200 then
		player.mario_name_color = 0xbb00ff -- purple
	else
		return
	end
	tfm.exec.setNameColor(player_name, player.mario_name_color)
end
pshy.bonuses_types["MarioCoin"] = {image = "17aa6f22c53.png", func = pshy.bonuses_callback_MarioCoin}
--- MarioMushroom.
function pshy.bonuses_callback_MarioMushroom(player_name, bonus)
	local player = pshy.players[player_name]
	tfm.exec.changePlayerSize(player_name, 1.4)
	player.mario_grown = true
end
pshy.bonuses_types["MarioMushroom"] = {image = "17c431c5e88.png", func = pshy.bonuses_callback_MarioMushroom}
--- MarioFlower.
function pshy.bonuses_callback_MarioFlower(player_name, bonus)
	local player = pshy.players[player_name]
	tfm.exec.bindKeyboard(player_name, 32, true, true)
	player.mario_flower = true
	player.mario_next_powerball_time = os.time()
	tfm.exec.chatMessage("<ch>Press SPACE to throw a fireball.</ch2>", player_name)
end
pshy.bonuses_types["MarioFlower"] = {image = "17c41851d61.png", func = pshy.bonuses_callback_MarioFlower}
--- MarioCheckpoint.
function pshy.bonuses_callback_MarioCheckpoint(player_name, bonus)
	local player = pshy.players[player_name]
	tfm.exec.bindKeyboard(player_name, 32, true, true)
	player.mario_flower = true
	player.mario_next_powerball_time = os.time()
	tfm.exec.chatMessage("<d>Checkpoint!</d>", player_name)
	pshy.checkpoints_SetPlayerCheckPoint(player_name)
end
-- TODO: bonus image
pshy.bonuses_types["MarioCheckpoint"] = {image = "17bf4c421bb.png", func = pshy.bonuses_callback_MarioCheckpoint, remain = true}
--- TFM event eventKeyboard
-- Handle player teleportations for pipes.
function eventKeyboard(player_name, key_code, down, x, y)
	if key_code == 32 and down then
		local player = pshy.players[player_name]
		if player.mario_flower and player.mario_next_powerball_time + pshy.mario_powerball_delay < os.time() then
			if player.mario_thrown_powerball_id then
				tfm.exec.removeObject(player.mario_thrown_powerball_id)
				player.mario_thrown_powerball_id = nil
			end
			tfm.exec.playEmote(player_name, tfm.enum.emote.highfive_1, nil)
			local speed = tfm.get.room.playerList[player_name].isFacingRight and 11 or -11
			player.mario_thrown_powerball_id = tfm.exec.addShamanObject(player.powerball_type, x + speed * 2, y, 0, speed, 0, false)
			tfm.exec.displayParticle(tfm.enum.particle.redGlitter, x + speed * 2, y, speed * 0.15, -0.15)
			tfm.exec.displayParticle(tfm.enum.particle.orangeGlitter, x + speed * 2, y, speed * 0.3, 0)
			tfm.exec.displayParticle(tfm.enum.particle.redGlitter, x + speed * 2, y, speed * 0.4, 0)
			tfm.exec.displayParticle(tfm.enum.particle.orangeGlitter, x + speed * 2, y, speed * 0.26, 0.15)
			player.mario_next_powerball_time = os.time()
		end
	end
end
--- TFM event eventPlayerDied.
function eventPlayerDied(player_name)
	local player = pshy.players[player_name]
	if player.mario_grown then
		local death_x = tfm.get.room.playerList[player_name].x
		local death_y = tfm.get.room.playerList[player_name].y
		player.mario_grown = false
		tfm.exec.changePlayerSize(player_name, 1)
		tfm.exec.respawnPlayer(player_name)
		tfm.exec.movePlayer(player_name, death_x, death_y - 30, false)
	end
end
--- Cancel changes the module have made.
local function CancelChanges()
	for player_name, player in pairs(pshy.players) do
		tfm.exec.changePlayerSize(player_name, 1.0)
		player.mario_coins = 0 -- @TODO: do i realy want to reset this ?
		player.mario_grown = false
		player.mario_flower = false -- @TODO: do i realy want to reset this ?
	end
end
--- Pshy event eventGameEnded()
function eventGameEnded()
	CancelChanges()
end
--- TFM event eventnewGame
function eventNewGame()
	for player_name, player in pairs(pshy.players) do
		player.mario_thrown_powerball_id = nil
		player.mario_next_powerball_time = 0
	end
	CancelChanges()
end
--- TFM event eventNewPlayer.
function eventNewPlayer(player_name)
	TouchPlayer(player_name)
end
--- Pshy event eventInit.
function eventInit()
	for player_name in pairs(tfm.get.room.playerList) do
		TouchPlayer(player_name)
	end
end
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_fcplatform.lua")
function new_mod.Content()
--- pshy_fcplatform.lua
--
-- This module add a command to spawn an orange plateform and tp on it.
--
--	!luaset pshy.fcplatform_w <width>
--	!luaset pshy.fcplatform_h <height>
--
-- @author TFM: Pshy#3752
-- @namespace pshy
-- @require pshy_perms.lua
-- @require pshy_commands.lua
-- @require pshy_help.lua
-- @require pshy_lua_commands.lua
--- Platform Settings.
pshy.fcplatform_x = -100
pshy.fcplatform_y = 100
pshy.fcplatform_w = 60
pshy.fcplatform_h = 10
pshy.fcplatform_friction = 0.4
pshy.fcplatform_members = {}		-- set of players to always tp on the platform
pshy.fcplatform_jail = {}		-- set of players to always tp on the platform, event when they escape ;>
pshy.fcplatform_pilots = {}		-- set of players who pilot the platform
pshy.fcplatform_autospawn = false
pshy.fcplatform_color = 0xff7000
pshy.fcplatform_spawned = false
--- Module Help Page.
pshy.help_pages["pshy_fcplatform"] = {back = "pshy", title = "FC Platform",text = "Adds a platform you can teleport on to spectate.\nThe players on the platform move with it.\n", examples = {}}
pshy.help_pages["pshy_fcplatform"].commands = {}
pshy.help_pages["pshy_fcplatform"].examples["fcp -100 100"] = "Spawn the fcplatform."
pshy.help_pages["pshy_fcplatform"].examples["luaset pshy.fcplatform_autospawn true"] = "Make the platform spawn every round."
pshy.help_pages["pshy_fcplatform"].examples["luaset pshy.fcplatform_w 80"] = "Set the fcplatform width to 80."
pshy.help_pages["pshy_fcplatform"].examples["fcpj"] = "Join or leave the fcplatform (jail you on it)."
pshy.help_pages["pshy_fcplatform"].examples["fcpp"] = "Toggle your ability to teleport the platform by clicking."
pshy.help_pages["pshy"].subpages["pshy_fcplatform"] = pshy.help_pages["pshy_fcplatform"]
--- Get a set of players on the platform.
function pshy.GetPlayersOnFcplatform()
	if not pshy.fcplatform_spawned then
		return {}
	end
	local ons = {}
	for player_name, player in pairs(tfm.get.room.playerList) do
		if player.y < pshy.fcplatform_y and player.y > pshy.fcplatform_y - 60 and player.x > pshy.fcplatform_x - pshy.fcplatform_w / 2 and player.x < pshy.fcplatform_x + pshy.fcplatform_w / 2 then
			ons[player_name] = true
		end
	end
	return ons
end
--- !fcplatform [x] [y]
-- Create a funcorp plateform and tp on it
function pshy.ChatCommandFcplatform(user, x, y)
	local ons = pshy.GetPlayersOnFcplatform() -- set of players on the platform
	local offset_x = 0
	local offset_y = 0
	if x then
		offset_x = x - pshy.fcplatform_x
		pshy.fcplatform_x = x
	end
	if y then
		offset_y = y - pshy.fcplatform_y
		pshy.fcplatform_y = y
	end
	if pshy.fcplatform_x and pshy.fcplatform_y then
		tfm.exec.addPhysicObject(199, pshy.fcplatform_x, pshy.fcplatform_y, {type = 12, width = pshy.fcplatform_w, height = pshy.fcplatform_h, foreground = false, friction = pshy.fcplatform_friction, restitution = 0.0, angle = 0, color = pshy.fcplatform_color, miceCollision = true, groundCollision = false})
		pshy.fcplatform_spawned = true
		for player_name, void in pairs(ons) do
			tfm.exec.movePlayer(player_name, offset_x, offset_y, true, 0, 0, true)
		end
		for player_name, void in pairs(pshy.fcplatform_members) do
			if not ons[player_name] or user == nil then
				tfm.exec.movePlayer(player_name, pshy.fcplatform_x, pshy.fcplatform_y - 20, false, 0, 0, false)
			end
		end
	end
end
pshy.chat_commands["fcplatform"] = {func = pshy.ChatCommandFcplatform, desc = "Create a funcorp plateform.", argc_min = 0, argc_max = 2, arg_types = {'number', 'number'}}
pshy.chat_commands["fcplatform"].help = "Create a platform at given coordinates, or recreate the previous platform. Accept variables as arguments.\n"
pshy.chat_command_aliases["fcp"] = "fcplatform"
pshy.help_pages["pshy_fcplatform"].commands["fcplatform"] = pshy.chat_commands["fcplatform"]
pshy.perms.admins["!fcplatformpilot"] = true
--- !fcplatformpilot [player_name]
function pshy.ChatCommandFcpplatformpilot(user, target)
	target = target or user
	if not pshy.fcplatform_pilots[target] then
		system.bindMouse(target, true)
		pshy.fcplatform_pilots[target] = true
		tfm.exec.chatMessage("[PshyFcp] " .. target .. " is now a pilot.", user)
	else
		pshy.fcplatform_pilots[target] = nil
		tfm.exec.chatMessage("[PshyFcp] " .. target .. " is no longer a pilot.", user)
	end
end
pshy.chat_commands["fcplatformpilot"] = {func = pshy.ChatCommandFcpplatformpilot, desc = "Set yourself or a player as a fcplatform pilot.", argc_min = 0, argc_max = 1, arg_types = {'string'}}
pshy.chat_command_aliases["fcppilot"] = "fcplatformpilot"
pshy.chat_command_aliases["fcpp"] = "fcplatformpilot"
pshy.help_pages["pshy_fcplatform"].commands["fcplatformpilot"] = pshy.chat_commands["fcplatformpilot"]
pshy.perms.admins["!fcplatformpilot"] = true
--- !fcplatformjoin [player_name]
-- Jail yourself on the fcplatform.
function pshy.ChatCommandFcpplatformjoin(user)
	local target = target or user
	if not pshy.fcplatform_autospawn then
		tfm.exec.chatMessage("[PshyFcp] The platform is disabled :c", user)
		return
	end
	if pshy.fcplatform_jail[target] ~= pshy.fcplatform_members[target] then
		tfm.exec.chatMessage("[PshyFcp] You didnt join the platform by yourself ;>", user)
		return
	end
	if not pshy.fcplatform_jail[target] then
		pshy.fcplatform_jail[target] = true
		pshy.fcplatform_members[target] = true
		tfm.exec.removeCheese(target)
		tfm.exec.chatMessage("[PshyFcp] You joined the platform!", user)
	else
		pshy.fcplatform_jail[target] = nil
		pshy.fcplatform_members[target] = nil
		tfm.exec.killPlayer(user)
		tfm.exec.chatMessage("[PshyFcp] You left the platform", user)
	end
end
pshy.chat_commands["fcplatformjoin"] = {func = pshy.ChatCommandFcpplatformjoin, desc = "Join (or leave) the fcplatform (jail mode).", argc_min = 0, argc_max = 0, arg_types = {}}
pshy.chat_command_aliases["fcpj"] = "fcplatformjoin"
pshy.chat_command_aliases["spectate"] = "fcplatformjoin"
pshy.chat_command_aliases["spectator"] = "fcplatformjoin"
pshy.help_pages["pshy_fcplatform"].commands["fcplatformjoin"] = pshy.chat_commands["fcplatformjoin"]
pshy.perms.everyone["!fcplatformjoin"] = true
--- TFM event eventNewgame
function eventNewGame()
	pshy.fcplatform_spawned = false
	if pshy.fcplatform_autospawn then
		pshy.ChatCommandFcplatform(nil)
		for player_name in pairs(pshy.fcplatform_jail) do
			local tfm_player = tfm.get.room.playerList[player_name]
			if tfm_player then
				tfm.exec.movePlayer(player_name, tfm_player.x, tfm_player.y, false, 0, 0, true)
			end
		end
	end
end
--- TFM event eventLoop
function eventLoop(currentTime, timeRemaining)
    for player_name, void in pairs(pshy.fcplatform_jail) do
    	player = tfm.get.room.playerList[player_name]
    	if player then
	    	if player.y < pshy.fcplatform_y and player.y > pshy.fcplatform_y - 60 and player.x > pshy.fcplatform_x - pshy.fcplatform_w / 2 and player.x < pshy.fcplatform_x + pshy.fcplatform_w / 2 then
				-- on already
			else
				tfm.exec.movePlayer(player_name, pshy.fcplatform_x, pshy.fcplatform_y - 20, false, 0, 0, false)
			end
		end
    end
end
--- TFM event eventMouse
function eventMouse(playerName, xMousePosition, yMousePosition)
	if pshy.fcplatform_pilots[playerName] then
		pshy.ChatCommandFcplatform(playerName, xMousePosition, yMousePosition)
	end
end
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_tools.lua")
function new_mod.Content()
--- pshy_tools.lua
--
-- Includes several scripts adding basic features for room admins.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- Scripts from this folder:
-- @require pshy_adminchat.lua
-- @require pshy_ban.lua
-- @require pshy_bindkey.lua
-- @require pshy_bindmouse.lua
-- @require pshy_fcplatform.lua
-- @require pshy_lua_commands.lua
-- @require pshy_motd.lua
-- @require pshy_nicks.lua
-- @require pshy_nofuncorp.lua
-- @require pshy_rain.lua
-- @require pshy_tfm_commands.lua
-- Additional scripts from `../fun/`:
-- @require pshy_changeimage.lua
-- @require pshy_fun_commands.lua
-- @require pshy_requests.lua
-- @require pshy_speedfly.lua
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_essentials.lua")
function new_mod.Content()
--- pshy_essentials.lua
--
-- This module include the most useful submodules i made.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- `pshy_assert.lua` increase the informations provided by your asserts.
-- @require pshy_assert.lua
-- `pshy_tools.lua` is a selection of useful room admin tools.
-- @require pshy_tools.lua
-- `pshy_utils.lua` is a selection of useful basic functions.
-- @require pshy_utils.lua
-- `pshy_xmlmap.lua` parses xml maps so you can browse them.
--- @require pshy_xmlmap.lua
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("mario.lua")
function new_mod.Content()
	local __IS_MAIN_MODULE__ = true
--- modulepack_mario.lua
--
-- This modulepack is for running Nnaaaz#0000's mario map.
--
-- @author Nnaaaz#0000 (map, lua script)
-- @author TFM:Pshy#3752 DC:Pshy#7998 (lua script)
-- @require pshy_essentials.lua
-- @require pshy_checkpoints.lua
-- @require pshy_scores.lua
-- @require pshy_splashscreen.lua
-- @require pshy_mario_bonuses.lua
--- help Page:
pshy.help_pages["mario"] = {back = "", title = "MARIO", text = "There is 3 levels and 100 coins in the game.\n\nYou can change your image to mario after collecting all the coins \n(not finished yet, but your name will become red for now).\nYou will unlock throwing snowballs after beating level 3.\n\nGood luck!\n", commands = {}}
pshy.help_pages[""].subpages["mario"] = pshy.help_pages["mario"]
--- Pshy Settings:
pshy.splashscreen_image = "17ab692dc8e.png"	-- splash image
pshy.splashscreen_x = 100					-- x location
pshy.splashscreen_y = -10					-- y location
pshy.splashscreen_sx = 1					-- scale on x
pshy.splashscreen_sy = 1					-- scale on y
pshy.splashscreen_text = nil
pshy.scores_per_first_wins = {}				-- no firsts
pshy.scores_per_bonus = 0					-- get points per bonus
pshy.scores_reset_on_leave = false
pshy.scores_show = false
pshy.perms_auto_admin_authors = false		-- add the authors as admin automatically
pshy.authors["Nnaaaz#0000"] = true
pshy.authors["Pshy#3752"] = true
--- TFM Settings:
tfm.exec.disableAutoNewGame(true)
tfm.exec.disableAfkDeath(true) 
tfm.exec.disableAutoShaman(true)
tfm.exec.disableAutoTimeLeft(true)
tfm.exec.disablePhysicalConsumables(true)
tfm.exec.disableMinimalistMode(true)
tfm.exec.disableDebugCommand(true)
tfm.exec.disableAutoScore(true)
system.disableChatCommandDisplay(nil, true)
--- Module Settings:
map_name = "Mario"
shaman_name = "Made by Nnaaaz#0000 & Pshy#3752"
map_xml = [[<C><P L="33000" H="600" G="0,5" /><Z><S><S T="12" X="16500" Y="783" L="1000" H="100" P="0,0,0.3,0.2,0,0,0,0" c="4"/><S T="13" X="-308" Y="310" L="15" P="1,999999999,0,0,0,1,0,0" c="2" nosync=""/><S T="12" X="340" Y="568" L="684" H="69" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="856" Y="516" L="166" H="39" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="1188" Y="425" L="340" H="40" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="1185" Y="255" L="211" H="38" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="1434" Y="514" L="126" H="41" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="1607" Y="345" L="214" H="42" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="1862" Y="212" L="298" H="41" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="2293" Y="558" L="168" H="41" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="2634" Y="557" L="214" H="42" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="2892" Y="558" L="210" H="41" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="3063" Y="387" L="124" H="42" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="2657" Y="213" L="170" H="39" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="3383" Y="257" L="252" H="42" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="4284" Y="472" L="170" H="41" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="4628" Y="300" L="342" H="41" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="4907" Y="556" L="125" H="38" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="5057" Y="385" L="169" H="42" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="5193" Y="553" L="169" H="41" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="5420" Y="557" L="128" H="41" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="5849" Y="568" L="643" H="64" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="6040" Y="451" L="256" H="171" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="6126" Y="345" L="85" H="301" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="6044" Y="326" L="91" H="94" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="10800" Y="559" L="210" H="41" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="11119" Y="215" L="214" H="41" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="11333" Y="387" L="298" H="45" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="11632" Y="171" L="129" H="40" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="11975" Y="216" L="211" H="42" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="11890" Y="514" L="298" H="41" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="12147" Y="385" L="124" H="38" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="12447" Y="343" L="124" H="41" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="13087" Y="559" L="211" H="42" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="13133" Y="301" L="126" H="38" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="13262" Y="129" L="127" H="42" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="13348" Y="386" L="125" H="40" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="13475" Y="217" L="210" H="42" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="13861" Y="387" L="126" H="41" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="14503" Y="472" L="127" H="43" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="14761" Y="429" L="129" H="38" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="15146" Y="386" L="211" H="41" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="15275" Y="259" L="124" H="41" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="15533" Y="559" L="300" H="46" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="15875" Y="430" L="211" H="41" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="16619" Y="569" L="762" H="64" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="16517" Y="516" L="41" H="45" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="16815" Y="309" L="373" H="14" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="16816" Y="179" L="205" H="10" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="16818" Y="90" L="127" H="10" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="13" X="16518" Y="97" L="10" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="10103" Y="437" L="211" H="18" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="10103" Y="348" L="128" H="10" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="16816" Y="492" L="51" H="86" P="0,0,0.3,0.2,0,0,0,0" o="000000" c="4"/><S T="19" X="2294" Y="525" L="29" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="25738" Y="528" L="29" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="23924" Y="310" L="29" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="13481" Y="183" L="29" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="24240" Y="527" L="29" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="14761" Y="399" L="29" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="15871" Y="399" L="29" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="20961" Y="359" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="1185" Y="394" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="21415" Y="357" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="1855" Y="182" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="2645" Y="182" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="22942" Y="353" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="22853" Y="354" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="2893" Y="524" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="4631" Y="267" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="23750" Y="394" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="4909" Y="525" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="24741" Y="355" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="25870" Y="356" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="26942" Y="521" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="5416" Y="525" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="21091" Y="529" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="11113" Y="183" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="11275" Y="354" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="11391" Y="354" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="11802" Y="483" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="11973" Y="183" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="24946" Y="526" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="21905" Y="527" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="11987" Y="483" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="13134" Y="268" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="13346" Y="356" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="15086" Y="356" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="15186" Y="356" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="15446" Y="526" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="24656" Y="354" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="15626" Y="526" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="5701" Y="525" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="13" X="2294" Y="514" L="14" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="25737" Y="517" L="14" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="23924" Y="298" L="14" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="13481" Y="171" L="14" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="24240" Y="515" L="14" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="14761" Y="387" L="14" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="15871" Y="387" L="14" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="20962" Y="344" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="1186" Y="380" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="21415" Y="343" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="1856" Y="168" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="2645" Y="168" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="22943" Y="339" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="22854" Y="340" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="2893" Y="511" L="14" P="1,0,0.3,0.4,0,1,0,0" c="3" nosync=""/><S T="13" X="4632" Y="253" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="23751" Y="380" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="4910" Y="511" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="24742" Y="341" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="25871" Y="342" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="26943" Y="507" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="5417" Y="511" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="21092" Y="515" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="11114" Y="169" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="11276" Y="340" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="11392" Y="340" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="11803" Y="469" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="11974" Y="169" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="24947" Y="512" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="21906" Y="513" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="11988" Y="469" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="13135" Y="254" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="13347" Y="342" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="15087" Y="342" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="15187" Y="342" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="15447" Y="512" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="24657" Y="340" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="15627" Y="512" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="5702" Y="511" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="19" X="21764" Y="250" L="34" H="26" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="3694" Y="325" L="34" H="26" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="25354" Y="320" L="34" H="26" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="26094" Y="420" L="34" H="26" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="12724" Y="346" L="34" H="26" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="14104" Y="316" L="34" H="26" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="13" X="21765" Y="241" L="16" P="1,0,0.3,0.2,-32767,0,0,0" c="3" nosync=""/><S T="13" X="3695" Y="315" L="15" P="1,0,0.3,0.2,-32767,0,0,0" c="3" nosync=""/><S T="13" X="25355" Y="309" L="15" P="1,0,0.3,0.2,-32767,0,0,0" c="3" nosync=""/><S T="13" X="26095" Y="409" L="15" P="1,0,0.3,0.2,-32767,0,0,0" c="3" nosync=""/><S T="13" X="12725" Y="334" L="15" P="1,0,0.3,0.2,-32767,0,0,0" c="3" nosync=""/><S T="13" X="14105" Y="305" L="15" P="1,0,0.3,0.2,-32727,0,0,0" c="3" nosync=""/><S T="12" X="2190" Y="228" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="1490" Y="203" L="55" H="10" P="0,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="22330" Y="103" L="55" H="10" P="0,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="23570" Y="143" L="55" H="10" P="0,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="23209" Y="443" L="55" H="10" P="0,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="23449" Y="444" L="55" H="10" P="0,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="24690" Y="483" L="55" H="10" P="0,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="25540" Y="463" L="55" H="10" P="0,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="22070" Y="105" L="55" H="10" P="1,0,0.3,0.2,0,0,0,0" c="3" nosync=""/><S T="12" X="3330" Y="529" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="4100" Y="278" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="3700" Y="348" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="5300" Y="298" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="21560" Y="149" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="22430" Y="469" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="24010" Y="139" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="24980" Y="249" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="26140" Y="389" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="23190" Y="239" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="12700" Y="479" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="13840" Y="199" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="14080" Y="499" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="14720" Y="199" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="2380" Y="228" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="3520" Y="528" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="4290" Y="278" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="3890" Y="348" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="5490" Y="298" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="21750" Y="149" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="22620" Y="469" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="24200" Y="139" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="25170" Y="249" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="26330" Y="389" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="23380" Y="239" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="12890" Y="479" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="14030" Y="199" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="14260" Y="199" L="55" H="10" P="1,200,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="11398" Y="171" L="55" H="10" P="1,200,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="21239" Y="472" L="55" H="10" P="1,200,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="21069" Y="242" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="21299" Y="181" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="22569" Y="262" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="25389" Y="212" L="55" H="10" P="1,200,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="26549" Y="362" L="55" H="10" P="1,200,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="11039" Y="472" L="55" H="10" P="1,400,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="4599" Y="472" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="3789" Y="551" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="1999" Y="541" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="3999" Y="521" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="6429" Y="221" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="14510" Y="199" L="55" H="10" P="1,200,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="14270" Y="499" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="14910" Y="199" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="-442" Y="381" L="145" H="209" P="1,-1,0,1,0,1,0,0" c="2" nosync=""/><S T="12" X="-177" Y="389" L="127" H="221" P="1,-1,0,1,0,1,0,0" c="2" nosync=""/><S T="12" X="-282" Y="284" L="20" H="20" P="1,99999999999,0,1,40,1,0,0" c="2" nosync=""/><S T="12" X="16517" Y="272" L="10" H="314" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="10292" Y="571" L="590" H="72" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="7013" Y="570" L="785" H="67" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="6899" Y="514" L="43" H="39" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="20341" Y="565" L="684" H="62" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="20835" Y="558" L="126" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="20965" Y="386" L="126" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="21092" Y="558" L="126" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="21415" Y="386" L="168" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="22186" Y="472" L="168" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="24243" Y="556" L="168" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="25743" Y="556" L="168" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="25871" Y="385" L="168" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="21650" Y="558" L="126" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="21908" Y="558" L="126" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="23707" Y="129" L="126" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="23922" Y="344" L="126" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="24050" Y="557" L="126" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="24479" Y="558" L="126" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="24950" Y="558" L="210" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="24693" Y="385" L="212" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="22894" Y="386" L="212" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="23750" Y="428" L="212" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="25335" Y="558" L="126" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="25722" Y="214" L="126" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="26750" Y="215" L="126" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="27274" Y="568" L="839" H="63" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="27488" Y="306" L="397" H="12" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="27481" Y="179" L="203" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="27481" Y="89" L="131" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="27179" Y="261" L="10" H="304" P="0,0,0.3,0.2,0,0,0,0"/><S T="13" X="27179" Y="96" L="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="27178" Y="515" L="41" H="42" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="20105" Y="435" L="218" H="16" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="20106" Y="347" L="123" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="6899" Y="266" L="10" H="310" P="0,0,0.3,0.2,0,0,0,0"/><S T="13" X="6898" Y="96" L="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="7205" Y="306" L="400" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="7195" Y="176" L="210" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="7197" Y="91" L="126" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="11891" Y="452" L="78" H="84" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="13069" Y="496" L="27" H="87" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="3358" Y="196" L="27" H="87" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="13121" Y="495" L="27" H="86" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="3410" Y="195" L="27" H="86" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="13112" Y="496" L="27" H="84" P="0,0,0,0,3,0,0,0"/><S T="12" X="3401" Y="196" L="27" H="84" P="0,0,0,0,3,0,0,0"/><S T="12" X="13078" Y="496" L="27" H="84" P="0,0,0,0,-3,0,0,0"/><S T="12" X="3367" Y="196" L="27" H="84" P="0,0,0,0,-3,0,0,0"/><S T="12" X="2632" Y="493" L="81" H="83" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="7196" Y="490" L="45" H="87" P="0,0,0.3,0.2,0,0,0,0" o="000000" c="4"/><S T="12" X="27477" Y="492" L="45" H="87" P="0,0,0.3,0.2,0,0,0,0" o="747474" c="4"/><S T="12" X="32445" Y="570" L="690" H="70" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="32124" Y="296" L="53" H="472" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="32399" Y="388" L="342" H="43" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="32250" Y="436" L="43" H="68" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="32552" Y="437" L="44" H="69" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="32485" Y="84" L="513" H="49" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="32767" Y="296" L="47" H="473" P="0,0,0,0.2,0,0,0,0"/><S T="12" X="32708" Y="459" L="93" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="32219" Y="59" L="230" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="29724" Y="329" L="45" H="530" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="30040" Y="558" L="683" H="45" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="30021" Y="474" L="305" H="132" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="30023" Y="84" L="307" H="39" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="30043" Y="-5" L="683" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="30373" Y="322" L="42" H="507" P="0,0,0,0.2,0,0,0,0"/><S T="12" X="30389" Y="33" L="12" H="64" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="29695" Y="31" L="10" H="68" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="30305" Y="458" L="92" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="107" Y="436" L="211" H="17" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="107" Y="348" L="126" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="30307" Y="543" L="95" H="32" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="32706" Y="539" L="86" H="28" P="0,0,0.3,0.2,0,0,0,0"/></S><D><F X="7196" Y="527"/><T X="7196" Y="532" D=""/><F X="16814" Y="525"/><T X="16816" Y="532" D=""/><F X="27477" Y="529"/><T X="27477" Y="534" D=""/><DS X="105" Y="515"/></D><O/><L><JD c="eec277,22,1,0" M1="61" M2="61" P1="20961.27,357.06" P2="20961.27,358.06"/><JD c="eec277,22,1,0" M1="62" M2="62" P1="1185.27,392.06" P2="1185.27,393.06"/><JD c="eec277,22,1,0" M1="63" M2="63" P1="21415.27,355.06" P2="21415.27,356.06"/><JD c="eec277,22,1,0" M1="64" M2="64" P1="1855.27,180.06" P2="1855.27,181.06"/><JD c="eec277,22,1,0" M1="65" M2="65" P1="2645.27,180.06" P2="2645.27,181.06"/><JD c="eec277,22,1,0" M1="66" M2="66" P1="22942.27,351.06" P2="22942.27,352.06"/><JD c="eec277,22,1,0" M1="67" M2="67" P1="22853.27,352.06" P2="22853.27,353.06"/><JD c="eec277,22,1,0" M1="68" M2="68" P1="2893.27,522.06" P2="2893.27,523.06"/><JD c="eec277,22,1,0" M1="69" M2="69" P1="4631.27,265.06" P2="4631.27,266.06"/><JD c="eec277,22,1,0" M1="70" M2="70" P1="23750.27,392.06" P2="23750.27,393.06"/><JD c="eec277,22,1,0" M1="71" M2="71" P1="4909.27,523.06" P2="4909.27,524.06"/><JD c="eec277,22,1,0" M1="72" M2="72" P1="24741.27,353.06" P2="24741.27,354.06"/><JD c="eec277,22,1,0" M1="73" M2="73" P1="25870.27,354.06" P2="25870.27,355.06"/><JD c="eec277,22,1,0" M1="74" M2="74" P1="26942.27,519.06" P2="26942.27,520.06"/><JD c="eec277,22,1,0" M1="75" M2="75" P1="5416.27,523.06" P2="5416.27,524.06"/><JD c="eec277,22,1,0" M1="76" M2="76" P1="21091.27,527.06" P2="21091.27,528.06"/><JD c="eec277,22,1,0" M1="77" M2="77" P1="11113.27,181.06" P2="11113.27,182.06"/><JD c="eec277,22,1,0" M1="78" M2="78" P1="11275.27,352.06" P2="11275.27,353.06"/><JD c="eec277,22,1,0" M1="79" M2="79" P1="11391.27,352.06" P2="11391.27,353.06"/><JD c="eec277,22,1,0" M1="80" M2="80" P1="11802.27,481.06" P2="11802.27,482.06"/><JD c="eec277,22,1,0" M1="81" M2="81" P1="11973.27,181.06" P2="11973.27,182.06"/><JD c="eec277,22,1,0" M1="82" M2="82" P1="24946.27,524.06" P2="24946.27,525.06"/><JD c="eec277,22,1,0" M1="83" M2="83" P1="21905.27,525.06" P2="21905.27,526.06"/><JD c="eec277,22,1,0" M1="84" M2="84" P1="11987.27,481.06" P2="11987.27,482.06"/><JD c="eec277,22,1,0" M1="85" M2="85" P1="13134.27,266.06" P2="13134.27,267.06"/><JD c="eec277,22,1,0" M1="86" M2="86" P1="13346.27,354.06" P2="13346.27,355.06"/><JD c="eec277,22,1,0" M1="87" M2="87" P1="15086.27,354.06" P2="15086.27,355.06"/><JD c="eec277,22,1,0" M1="88" M2="88" P1="15186.27,354.06" P2="15186.27,355.06"/><JD c="eec277,22,1,0" M1="89" M2="89" P1="15446.27,524.06" P2="15446.27,525.06"/><JD c="eec277,22,1,0" M1="90" M2="90" P1="24656.27,352.06" P2="24656.27,353.06"/><JD c="eec277,22,1,0" M1="91" M2="91" P1="15626.27,524.06" P2="15626.27,525.06"/><JD c="eec277,22,1,0" M1="92" M2="92" P1="5701.27,523.06" P2="5701.27,524.06"/><JD c="923b21,13,1,0" M1="61" M2="61" P1="20948,350" P2="20961,338"/><JD c="923b21,13,1,0" M1="62" M2="62" P1="1172,385" P2="1185,373"/><JD c="923b21,13,1,0" M1="63" M2="63" P1="21402,348" P2="21415,336"/><JD c="923b21,13,1,0" M1="64" M2="64" P1="1842,173" P2="1855,161"/><JD c="923b21,13,1,0" M1="65" M2="65" P1="2632,173" P2="2645,161"/><JD c="923b21,13,1,0" M1="66" M2="66" P1="22929,344" P2="22942,332"/><JD c="923b21,13,1,0" M1="67" M2="67" P1="22840,345" P2="22853,333"/><JD c="923b21,13,1,0" M1="68" M2="68" P1="2880,515" P2="2893,503"/><JD c="923b21,13,1,0" M1="69" M2="69" P1="4618,258" P2="4631,246"/><JD c="923b21,13,1,0" M1="70" M2="70" P1="23737,385" P2="23750,373"/><JD c="923b21,13,1,0" M1="71" M2="71" P1="4896,516" P2="4909,504"/><JD c="923b21,13,1,0" M1="72" M2="72" P1="24728,346" P2="24741,334"/><JD c="923b21,13,1,0" M1="73" M2="73" P1="25857,347" P2="25870,335"/><JD c="923b21,13,1,0" M1="74" M2="74" P1="26929,512" P2="26942,500"/><JD c="923b21,13,1,0" M1="75" M2="75" P1="5403,516" P2="5416,504"/><JD c="923b21,13,1,0" M1="76" M2="76" P1="21078,520" P2="21091,508"/><JD c="923b21,13,1,0" M1="77" M2="77" P1="11100,174" P2="11113,162"/><JD c="923b21,13,1,0" M1="78" M2="78" P1="11262,345" P2="11275,333"/><JD c="923b21,13,1,0" M1="79" M2="79" P1="11378,345" P2="11391,333"/><JD c="923b21,13,1,0" M1="80" M2="80" P1="11789,474" P2="11802,462"/><JD c="923b21,13,1,0" M1="81" M2="81" P1="11960,174" P2="11973,162"/><JD c="923b21,13,1,0" M1="82" M2="82" P1="24933,517" P2="24946,505"/><JD c="923b21,13,1,0" M1="83" M2="83" P1="21892,518" P2="21905,506"/><JD c="923b21,13,1,0" M1="84" M2="84" P1="11974,474" P2="11987,462"/><JD c="923b21,13,1,0" M1="85" M2="85" P1="13121,259" P2="13134,247"/><JD c="923b21,13,1,0" M1="86" M2="86" P1="13333,347" P2="13346,335"/><JD c="923b21,13,1,0" M1="87" M2="87" P1="15073,347" P2="15086,335"/><JD c="923b21,13,1,0" M1="88" M2="88" P1="15173,347" P2="15186,335"/><JD c="923b21,13,1,0" M1="89" M2="89" P1="15433,517" P2="15446,505"/><JD c="923b21,13,1,0" M1="90" M2="90" P1="24643,345" P2="24656,333"/><JD c="923b21,13,1,0" M1="91" M2="91" P1="15613,517" P2="15626,505"/><JD c="923b21,13,1,0" M1="92" M2="92" P1="5688,516" P2="5701,504"/><JD c="923b21,13,1,0" M1="61" M2="61" P1="20974,350" P2="20961,338"/><JD c="923b21,13,1,0" M1="62" M2="62" P1="1198,385" P2="1185,373"/><JD c="923b21,13,1,0" M1="63" M2="63" P1="21428,348" P2="21415,336"/><JD c="923b21,13,1,0" M1="64" M2="64" P1="1868,173" P2="1855,161"/><JD c="923b21,13,1,0" M1="65" M2="65" P1="2658,173" P2="2645,161"/><JD c="923b21,13,1,0" M1="66" M2="66" P1="22955,344" P2="22942,332"/><JD c="923b21,13,1,0" M1="67" M2="67" P1="22866,345" P2="22853,333"/><JD c="923b21,13,1,0" M1="68" M2="68" P1="2906,515" P2="2893,503"/><JD c="923b21,13,1,0" M1="69" M2="69" P1="4644,258" P2="4631,246"/><JD c="923b21,13,1,0" M1="70" M2="70" P1="23763,385" P2="23750,373"/><JD c="923b21,13,1,0" M1="71" M2="71" P1="4922,516" P2="4909,504"/><JD c="923b21,13,1,0" M1="72" M2="72" P1="24754,346" P2="24741,334"/><JD c="923b21,13,1,0" M1="73" M2="73" P1="25883,347" P2="25870,335"/><JD c="923b21,13,1,0" M1="74" M2="74" P1="26955,512" P2="26942,500"/><JD c="923b21,13,1,0" M1="75" M2="75" P1="5429,516" P2="5416,504"/><JD c="923b21,13,1,0" M1="76" M2="76" P1="21104,520" P2="21091,508"/><JD c="923b21,13,1,0" M1="77" M2="77" P1="11126,174" P2="11113,162"/><JD c="923b21,13,1,0" M1="78" M2="78" P1="11288,345" P2="11275,333"/><JD c="923b21,13,1,0" M1="79" M2="79" P1="11404,345" P2="11391,333"/><JD c="923b21,13,1,0" M1="80" M2="80" P1="11815,474" P2="11802,462"/><JD c="923b21,13,1,0" M1="81" M2="81" P1="11986,174" P2="11973,162"/><JD c="923b21,13,1,0" M1="82" M2="82" P1="24959,517" P2="24946,505"/><JD c="923b21,13,1,0" M1="83" M2="83" P1="21918,518" P2="21905,506"/><JD c="923b21,13,1,0" M1="84" M2="84" P1="12000,474" P2="11987,462"/><JD c="923b21,13,1,0" M1="85" M2="85" P1="13147,259" P2="13134,247"/><JD c="923b21,13,1,0" M1="86" M2="86" P1="13359,347" P2="13346,335"/><JD c="923b21,13,1,0" M1="87" M2="87" P1="15099,347" P2="15086,335"/><JD c="923b21,13,1,0" M1="88" M2="88" P1="15199,347" P2="15186,335"/><JD c="923b21,13,1,0" M1="89" M2="89" P1="15459,517" P2="15446,505"/><JD c="923b21,13,1,0" M1="90" M2="90" P1="24669,345" P2="24656,333"/><JD c="923b21,13,1,0" M1="91" M2="91" P1="15639,517" P2="15626,505"/><JD c="923b21,13,1,0" M1="92" M2="92" P1="5714,516" P2="5701,504"/><JD c="923b21,13,1,0" M1="61" M2="61" P1="20949,350" P2="20972,350"/><JD c="923b21,13,1,0" M1="62" M2="62" P1="1173,385" P2="1196,385"/><JD c="923b21,13,1,0" M1="63" M2="63" P1="21403,348" P2="21426,348"/><JD c="923b21,13,1,0" M1="64" M2="64" P1="1843,173" P2="1866,173"/><JD c="923b21,13,1,0" M1="65" M2="65" P1="2633,173" P2="2656,173"/><JD c="923b21,13,1,0" M1="66" M2="66" P1="22930,344" P2="22953,344"/><JD c="923b21,13,1,0" M1="67" M2="67" P1="22841,345" P2="22864,345"/><JD c="923b21,13,1,0" M1="68" M2="68" P1="2881,515" P2="2904,515"/><JD c="923b21,13,1,0" M1="69" M2="69" P1="4619,258" P2="4642,258"/><JD c="923b21,13,1,0" M1="70" M2="70" P1="23738,385" P2="23761,385"/><JD c="923b21,13,1,0" M1="71" M2="71" P1="4897,516" P2="4920,516"/><JD c="923b21,13,1,0" M1="72" M2="72" P1="24729,346" P2="24752,346"/><JD c="923b21,13,1,0" M1="73" M2="73" P1="25858,347" P2="25881,347"/><JD c="923b21,13,1,0" M1="74" M2="74" P1="26930,512" P2="26953,512"/><JD c="923b21,13,1,0" M1="75" M2="75" P1="5404,516" P2="5427,516"/><JD c="923b21,13,1,0" M1="76" M2="76" P1="21079,520" P2="21102,520"/><JD c="923b21,13,1,0" M1="77" M2="77" P1="11101,174" P2="11124,174"/><JD c="923b21,13,1,0" M1="78" M2="78" P1="11263,345" P2="11286,345"/><JD c="923b21,13,1,0" M1="79" M2="79" P1="11379,345" P2="11402,345"/><JD c="923b21,13,1,0" M1="80" M2="80" P1="11790,474" P2="11813,474"/><JD c="923b21,13,1,0" M1="81" M2="81" P1="11961,174" P2="11984,174"/><JD c="923b21,13,1,0" M1="82" M2="82" P1="24934,517" P2="24957,517"/><JD c="923b21,13,1,0" M1="83" M2="83" P1="21893,518" P2="21916,518"/><JD c="923b21,13,1,0" M1="84" M2="84" P1="11975,474" P2="11998,474"/><JD c="923b21,13,1,0" M1="85" M2="85" P1="13122,259" P2="13145,259"/><JD c="923b21,13,1,0" M1="86" M2="86" P1="13334,347" P2="13357,347"/><JD c="923b21,13,1,0" M1="87" M2="87" P1="15074,347" P2="15097,347"/><JD c="923b21,13,1,0" M1="88" M2="88" P1="15174,347" P2="15197,347"/><JD c="923b21,13,1,0" M1="89" M2="89" P1="15434,517" P2="15457,517"/><JD c="923b21,13,1,0" M1="90" M2="90" P1="24644,345" P2="24667,345"/><JD c="923b21,13,1,0" M1="91" M2="91" P1="15614,517" P2="15637,517"/><JD c="923b21,13,1,0" M1="92" M2="92" P1="5689,516" P2="5712,516"/><JD c="000000,8,1,0" M1="61" M2="61" P1="20951.54,366.09" P2="20953.66,367"/><JD c="000000,8,1,0" M1="62" M2="62" P1="1175.54,401.09" P2="1177.66,402"/><JD c="000000,8,1,0" M1="63" M2="63" P1="21405.54,364.09" P2="21407.66,365"/><JD c="000000,8,1,0" M1="64" M2="64" P1="1845.54,189.09" P2="1847.66,190"/><JD c="000000,8,1,0" M1="65" M2="65" P1="2635.54,189.09" P2="2637.66,190"/><JD c="000000,8,1,0" M1="66" M2="66" P1="22932.54,360.09" P2="22934.66,361"/><JD c="000000,8,1,0" M1="67" M2="67" P1="22843.54,361.09" P2="22845.66,362"/><JD c="000000,8,1,0" M1="68" M2="68" P1="2883.54,531.09" P2="2885.66,532"/><JD c="000000,8,1,0" M1="69" M2="69" P1="4621.54,274.09" P2="4623.66,275"/><JD c="000000,8,1,0" M1="70" M2="70" P1="23740.54,401.09" P2="23742.66,402"/><JD c="000000,8,1,0" M1="71" M2="71" P1="4899.54,532.09" P2="4901.66,533"/><JD c="000000,8,1,0" M1="72" M2="72" P1="24731.54,362.09" P2="24733.66,363"/><JD c="000000,8,1,0" M1="73" M2="73" P1="25860.54,363.09" P2="25862.66,364"/><JD c="000000,8,1,0" M1="74" M2="74" P1="26932.54,528.09" P2="26934.66,529"/><JD c="000000,8,1,0" M1="75" M2="75" P1="5406.54,532.09" P2="5408.66,533"/><JD c="000000,8,1,0" M1="76" M2="76" P1="21081.54,536.09" P2="21083.66,537"/><JD c="000000,8,1,0" M1="77" M2="77" P1="11103.54,190.09" P2="11105.66,191"/><JD c="000000,8,1,0" M1="78" M2="78" P1="11265.54,361.09" P2="11267.66,362"/><JD c="000000,8,1,0" M1="79" M2="79" P1="11381.54,361.09" P2="11383.66,362"/><JD c="000000,8,1,0" M1="80" M2="80" P1="11792.54,490.09" P2="11794.66,491"/><JD c="000000,8,1,0" M1="81" M2="81" P1="11963.54,190.09" P2="11965.66,191"/><JD c="000000,8,1,0" M1="82" M2="82" P1="24936.54,533.09" P2="24938.66,534"/><JD c="000000,8,1,0" M1="83" M2="83" P1="21895.54,534.09" P2="21897.66,535"/><JD c="000000,8,1,0" M1="84" M2="84" P1="11977.54,490.09" P2="11979.66,491"/><JD c="000000,8,1,0" M1="85" M2="85" P1="13124.54,275.09" P2="13126.66,276"/><JD c="000000,8,1,0" M1="86" M2="86" P1="13336.54,363.09" P2="13338.66,364"/><JD c="000000,8,1,0" M1="87" M2="87" P1="15076.54,363.09" P2="15078.66,364"/><JD c="000000,8,1,0" M1="88" M2="88" P1="15176.54,363.09" P2="15178.66,364"/><JD c="000000,8,1,0" M1="89" M2="89" P1="15436.54,533.09" P2="15438.66,534"/><JD c="000000,8,1,0" M1="90" M2="90" P1="24646.54,361.09" P2="24648.66,362"/><JD c="000000,8,1,0" M1="91" M2="91" P1="15616.54,533.09" P2="15618.66,534"/><JD c="000000,8,1,0" M1="92" M2="92" P1="5691.54,532.09" P2="5693.66,533"/><JD c="000000,8,1,0" M1="61" M2="61" P1="20971.76,365.09" P2="20969.64,367.21"/><JD c="000000,8,1,0" M1="62" M2="62" P1="1195.76,400.09" P2="1193.64,402.21"/><JD c="000000,8,1,0" M1="63" M2="63" P1="21425.76,363.09" P2="21423.64,365.21"/><JD c="000000,8,1,0" M1="64" M2="64" P1="1865.76,188.09" P2="1863.64,190.21"/><JD c="000000,8,1,0" M1="65" M2="65" P1="2655.76,188.09" P2="2653.64,190.21"/><JD c="000000,8,1,0" M1="66" M2="66" P1="22952.76,359.09" P2="22950.64,361.21"/><JD c="000000,8,1,0" M1="67" M2="67" P1="22863.76,360.09" P2="22861.64,362.21"/><JD c="000000,8,1,0" M1="68" M2="68" P1="2903.76,530.09" P2="2901.64,532.21"/><JD c="000000,8,1,0" M1="69" M2="69" P1="4641.76,273.09" P2="4639.64,275.21"/><JD c="000000,8,1,0" M1="70" M2="70" P1="23760.76,400.09" P2="23758.64,402.21"/><JD c="000000,8,1,0" M1="71" M2="71" P1="4919.76,531.09" P2="4917.64,533.21"/><JD c="000000,8,1,0" M1="72" M2="72" P1="24751.76,361.09" P2="24749.64,363.21"/><JD c="000000,8,1,0" M1="73" M2="73" P1="25880.76,362.09" P2="25878.64,364.21"/><JD c="000000,8,1,0" M1="74" M2="74" P1="26952.76,527.09" P2="26950.64,529.21"/><JD c="000000,8,1,0" M1="75" M2="75" P1="5426.76,531.09" P2="5424.64,533.21"/><JD c="000000,8,1,0" M1="76" M2="76" P1="21101.76,535.09" P2="21099.64,537.21"/><JD c="000000,8,1,0" M1="77" M2="77" P1="11123.76,189.09" P2="11121.64,191.21"/><JD c="000000,8,1,0" M1="78" M2="78" P1="11285.76,360.09" P2="11283.64,362.21"/><JD c="000000,8,1,0" M1="79" M2="79" P1="11401.76,360.09" P2="11399.64,362.21"/><JD c="000000,8,1,0" M1="80" M2="80" P1="11812.76,489.09" P2="11810.64,491.21"/><JD c="000000,8,1,0" M1="81" M2="81" P1="11983.76,189.09" P2="11981.64,191.21"/><JD c="000000,8,1,0" M1="82" M2="82" P1="24956.76,532.09" P2="24954.64,534.21"/><JD c="000000,8,1,0" M1="83" M2="83" P1="21915.76,533.09" P2="21913.64,535.21"/><JD c="000000,8,1,0" M1="84" M2="84" P1="11997.76,489.09" P2="11995.64,491.21"/><JD c="000000,8,1,0" M1="85" M2="85" P1="13144.76,274.09" P2="13142.64,276.21"/><JD c="000000,8,1,0" M1="86" M2="86" P1="13356.76,362.09" P2="13354.64,364.21"/><JD c="000000,8,1,0" M1="87" M2="87" P1="15096.76,362.09" P2="15094.64,364.21"/><JD c="000000,8,1,0" M1="88" M2="88" P1="15196.76,362.09" P2="15194.64,364.21"/><JD c="000000,8,1,0" M1="89" M2="89" P1="15456.76,532.09" P2="15454.64,534.21"/><JD c="000000,8,1,0" M1="90" M2="90" P1="24666.76,360.09" P2="24664.64,362.21"/><JD c="000000,8,1,0" M1="91" M2="91" P1="15636.76,532.09" P2="15634.64,534.21"/><JD c="000000,8,1,0" M1="92" M2="92" P1="5711.76,531.09" P2="5709.64,533.21"/><JD c="eec277,8,1,0" M1="61" M2="61" P1="20956,345" P2="20956,347"/><JD c="eec277,8,1,0" M1="62" M2="62" P1="1180,380" P2="1180,382"/><JD c="eec277,8,1,0" M1="63" M2="63" P1="21410,343" P2="21410,345"/><JD c="eec277,8,1,0" M1="64" M2="64" P1="1850,168" P2="1850,170"/><JD c="eec277,8,1,0" M1="65" M2="65" P1="2640,168" P2="2640,170"/><JD c="eec277,8,1,0" M1="66" M2="66" P1="22937,339" P2="22937,341"/><JD c="eec277,8,1,0" M1="67" M2="67" P1="22848,340" P2="22848,342"/><JD c="eec277,8,1,0" M1="68" M2="68" P1="2888,510" P2="2888,512"/><JD c="eec277,8,1,0" M1="69" M2="69" P1="4626,253" P2="4626,255"/><JD c="eec277,8,1,0" M1="70" M2="70" P1="23745,380" P2="23745,382"/><JD c="eec277,8,1,0" M1="71" M2="71" P1="4904,511" P2="4904,513"/><JD c="eec277,8,1,0" M1="72" M2="72" P1="24736,341" P2="24736,343"/><JD c="eec277,8,1,0" M1="73" M2="73" P1="25865,342" P2="25865,344"/><JD c="eec277,8,1,0" M1="74" M2="74" P1="26937,507" P2="26937,509"/><JD c="eec277,8,1,0" M1="75" M2="75" P1="5411,511" P2="5411,513"/><JD c="eec277,8,1,0" M1="76" M2="76" P1="21086,515" P2="21086,517"/><JD c="eec277,8,1,0" M1="77" M2="77" P1="11108,169" P2="11108,171"/><JD c="eec277,8,1,0" M1="78" M2="78" P1="11270,340" P2="11270,342"/><JD c="eec277,8,1,0" M1="79" M2="79" P1="11386,340" P2="11386,342"/><JD c="eec277,8,1,0" M1="80" M2="80" P1="11797,469" P2="11797,471"/><JD c="eec277,8,1,0" M1="81" M2="81" P1="11968,169" P2="11968,171"/><JD c="eec277,8,1,0" M1="82" M2="82" P1="24941,512" P2="24941,514"/><JD c="eec277,8,1,0" M1="83" M2="83" P1="21900,513" P2="21900,515"/><JD c="eec277,8,1,0" M1="84" M2="84" P1="11982,469" P2="11982,471"/><JD c="eec277,8,1,0" M1="85" M2="85" P1="13129,254" P2="13129,256"/><JD c="eec277,8,1,0" M1="86" M2="86" P1="13341,342" P2="13341,344"/><JD c="eec277,8,1,0" M1="87" M2="87" P1="15081,342" P2="15081,344"/><JD c="eec277,8,1,0" M1="88" M2="88" P1="15181,342" P2="15181,344"/><JD c="eec277,8,1,0" M1="89" M2="89" P1="15441,512" P2="15441,514"/><JD c="eec277,8,1,0" M1="90" M2="90" P1="24651,340" P2="24651,342"/><JD c="eec277,8,1,0" M1="91" M2="91" P1="15621,512" P2="15621,514"/><JD c="eec277,8,1,0" M1="92" M2="92" P1="5696,511" P2="5696,513"/><JD c="eec277,8,1,0" M1="61" M2="61" P1="20966,345" P2="20966,347"/><JD c="eec277,8,1,0" M1="62" M2="62" P1="1190,380" P2="1190,382"/><JD c="eec277,8,1,0" M1="63" M2="63" P1="21420,343" P2="21420,345"/><JD c="eec277,8,1,0" M1="64" M2="64" P1="1860,168" P2="1860,170"/><JD c="eec277,8,1,0" M1="65" M2="65" P1="2650,168" P2="2650,170"/><JD c="eec277,8,1,0" M1="66" M2="66" P1="22947,339" P2="22947,341"/><JD c="eec277,8,1,0" M1="67" M2="67" P1="22858,340" P2="22858,342"/><JD c="eec277,8,1,0" M1="68" M2="68" P1="2898,510" P2="2898,512"/><JD c="eec277,8,1,0" M1="69" M2="69" P1="4636,253" P2="4636,255"/><JD c="eec277,8,1,0" M1="70" M2="70" P1="23755,380" P2="23755,382"/><JD c="eec277,8,1,0" M1="71" M2="71" P1="4914,511" P2="4914,513"/><JD c="eec277,8,1,0" M1="72" M2="72" P1="24746,341" P2="24746,343"/><JD c="eec277,8,1,0" M1="73" M2="73" P1="25875,342" P2="25875,344"/><JD c="eec277,8,1,0" M1="74" M2="74" P1="26947,507" P2="26947,509"/><JD c="eec277,8,1,0" M1="75" M2="75" P1="5421,511" P2="5421,513"/><JD c="eec277,8,1,0" M1="76" M2="76" P1="21096,515" P2="21096,517"/><JD c="eec277,8,1,0" M1="77" M2="77" P1="11118,169" P2="11118,171"/><JD c="eec277,8,1,0" M1="78" M2="78" P1="11280,340" P2="11280,342"/><JD c="eec277,8,1,0" M1="79" M2="79" P1="11396,340" P2="11396,342"/><JD c="eec277,8,1,0" M1="80" M2="80" P1="11807,469" P2="11807,471"/><JD c="eec277,8,1,0" M1="81" M2="81" P1="11978,169" P2="11978,171"/><JD c="eec277,8,1,0" M1="82" M2="82" P1="24951,512" P2="24951,514"/><JD c="eec277,8,1,0" M1="83" M2="83" P1="21910,513" P2="21910,515"/><JD c="eec277,8,1,0" M1="84" M2="84" P1="11992,469" P2="11992,471"/><JD c="eec277,8,1,0" M1="85" M2="85" P1="13139,254" P2="13139,256"/><JD c="eec277,8,1,0" M1="86" M2="86" P1="13351,342" P2="13351,344"/><JD c="eec277,8,1,0" M1="87" M2="87" P1="15091,342" P2="15091,344"/><JD c="eec277,8,1,0" M1="88" M2="88" P1="15191,342" P2="15191,344"/><JD c="eec277,8,1,0" M1="89" M2="89" P1="15451,512" P2="15451,514"/><JD c="eec277,8,1,0" M1="90" M2="90" P1="24661,340" P2="24661,342"/><JD c="eec277,8,1,0" M1="91" M2="91" P1="15631,512" P2="15631,514"/><JD c="eec277,8,1,0" M1="92" M2="92" P1="5706,511" P2="5706,513"/><JD c="000000,2,1,0" M1="61" M2="61" P1="20953,340" P2="20960,342"/><JD c="000000,2,1,0" M1="62" M2="62" P1="1177,375" P2="1184,377"/><JD c="000000,2,1,0" M1="63" M2="63" P1="21407,338" P2="21414,340"/><JD c="000000,2,1,0" M1="64" M2="64" P1="1847,163" P2="1854,165"/><JD c="000000,2,1,0" M1="65" M2="65" P1="2637,163" P2="2644,165"/><JD c="000000,2,1,0" M1="66" M2="66" P1="22934,334" P2="22941,336"/><JD c="000000,2,1,0" M1="67" M2="67" P1="22845,335" P2="22852,337"/><JD c="000000,2,1,0" M1="68" M2="68" P1="2885,505" P2="2892,507"/><JD c="000000,2,1,0" M1="69" M2="69" P1="4623,248" P2="4630,250"/><JD c="000000,2,1,0" M1="70" M2="70" P1="23742,375" P2="23749,377"/><JD c="000000,2,1,0" M1="71" M2="71" P1="4901,506" P2="4908,508"/><JD c="000000,2,1,0" M1="72" M2="72" P1="24733,336" P2="24740,338"/><JD c="000000,2,1,0" M1="73" M2="73" P1="25862,337" P2="25869,339"/><JD c="000000,2,1,0" M1="74" M2="74" P1="26934,502" P2="26941,504"/><JD c="000000,2,1,0" M1="75" M2="75" P1="5408,506" P2="5415,508"/><JD c="000000,2,1,0" M1="76" M2="76" P1="21083,510" P2="21090,512"/><JD c="000000,2,1,0" M1="77" M2="77" P1="11105,164" P2="11112,166"/><JD c="000000,2,1,0" M1="78" M2="78" P1="11267,335" P2="11274,337"/><JD c="000000,2,1,0" M1="79" M2="79" P1="11383,335" P2="11390,337"/><JD c="000000,2,1,0" M1="80" M2="80" P1="11794,464" P2="11801,466"/><JD c="000000,2,1,0" M1="81" M2="81" P1="11965,164" P2="11972,166"/><JD c="000000,2,1,0" M1="82" M2="82" P1="24938,507" P2="24945,509"/><JD c="000000,2,1,0" M1="83" M2="83" P1="21897,508" P2="21904,510"/><JD c="000000,2,1,0" M1="84" M2="84" P1="11979,464" P2="11986,466"/><JD c="000000,2,1,0" M1="85" M2="85" P1="13126,249" P2="13133,251"/><JD c="000000,2,1,0" M1="86" M2="86" P1="13338,337" P2="13345,339"/><JD c="000000,2,1,0" M1="87" M2="87" P1="15078,337" P2="15085,339"/><JD c="000000,2,1,0" M1="88" M2="88" P1="15178,337" P2="15185,339"/><JD c="000000,2,1,0" M1="89" M2="89" P1="15438,507" P2="15445,509"/><JD c="000000,2,1,0" M1="90" M2="90" P1="24648,335" P2="24655,337"/><JD c="000000,2,1,0" M1="91" M2="91" P1="15618,507" P2="15625,509"/><JD c="000000,2,1,0" M1="92" M2="92" P1="5693,506" P2="5700,508"/><JD c="000000,2,1,0" M1="61" M2="61" P1="20968,340" P2="20961,342"/><JD c="000000,2,1,0" M1="62" M2="62" P1="1192,375" P2="1185,377"/><JD c="000000,2,1,0" M1="63" M2="63" P1="21422,338" P2="21415,340"/><JD c="000000,2,1,0" M1="64" M2="64" P1="1862,163" P2="1855,165"/><JD c="000000,2,1,0" M1="65" M2="65" P1="2652,163" P2="2645,165"/><JD c="000000,2,1,0" M1="66" M2="66" P1="22949,334" P2="22942,336"/><JD c="000000,2,1,0" M1="67" M2="67" P1="22860,335" P2="22853,337"/><JD c="000000,2,1,0" M1="68" M2="68" P1="2900,505" P2="2893,507"/><JD c="000000,2,1,0" M1="69" M2="69" P1="4638,248" P2="4631,250"/><JD c="000000,2,1,0" M1="70" M2="70" P1="23757,375" P2="23750,377"/><JD c="000000,2,1,0" M1="71" M2="71" P1="4916,506" P2="4909,508"/><JD c="000000,2,1,0" M1="72" M2="72" P1="24748,336" P2="24741,338"/><JD c="000000,2,1,0" M1="73" M2="73" P1="25877,337" P2="25870,339"/><JD c="000000,2,1,0" M1="74" M2="74" P1="26949,502" P2="26942,504"/><JD c="000000,2,1,0" M1="75" M2="75" P1="5423,506" P2="5416,508"/><JD c="000000,2,1,0" M1="76" M2="76" P1="21098,510" P2="21091,512"/><JD c="000000,2,1,0" M1="77" M2="77" P1="11120,164" P2="11113,166"/><JD c="000000,2,1,0" M1="78" M2="78" P1="11282,335" P2="11275,337"/><JD c="000000,2,1,0" M1="79" M2="79" P1="11398,335" P2="11391,337"/><JD c="000000,2,1,0" M1="80" M2="80" P1="11809,464" P2="11802,466"/><JD c="000000,2,1,0" M1="81" M2="81" P1="11980,164" P2="11973,166"/><JD c="000000,2,1,0" M1="82" M2="82" P1="24953,507" P2="24946,509"/><JD c="000000,2,1,0" M1="83" M2="83" P1="21912,508" P2="21905,510"/><JD c="000000,2,1,0" M1="84" M2="84" P1="11994,464" P2="11987,466"/><JD c="000000,2,1,0" M1="85" M2="85" P1="13141,249" P2="13134,251"/><JD c="000000,2,1,0" M1="86" M2="86" P1="13353,337" P2="13346,339"/><JD c="000000,2,1,0" M1="87" M2="87" P1="15093,337" P2="15086,339"/><JD c="000000,2,1,0" M1="88" M2="88" P1="15193,337" P2="15186,339"/><JD c="000000,2,1,0" M1="89" M2="89" P1="15453,507" P2="15446,509"/><JD c="000000,2,1,0" M1="90" M2="90" P1="24663,335" P2="24656,337"/><JD c="000000,2,1,0" M1="91" M2="91" P1="15633,507" P2="15626,509"/><JD c="000000,2,1,0" M1="92" M2="92" P1="5708,506" P2="5701,508"/><JD c="000000,3,1,0" M1="61" M2="61" P1="20956,342" P2="20956,345"/><JD c="000000,3,1,0" M1="62" M2="62" P1="1180,377" P2="1180,380"/><JD c="000000,3,1,0" M1="63" M2="63" P1="21410,340" P2="21410,343"/><JD c="000000,3,1,0" M1="64" M2="64" P1="1850,165" P2="1850,168"/><JD c="000000,3,1,0" M1="65" M2="65" P1="2640,165" P2="2640,168"/><JD c="000000,3,1,0" M1="66" M2="66" P1="22937,336" P2="22937,339"/><JD c="000000,3,1,0" M1="67" M2="67" P1="22848,337" P2="22848,340"/><JD c="000000,3,1,0" M1="68" M2="68" P1="2888,507" P2="2888,510"/><JD c="000000,3,1,0" M1="69" M2="69" P1="4626,250" P2="4626,253"/><JD c="000000,3,1,0" M1="70" M2="70" P1="23745,377" P2="23745,380"/><JD c="000000,3,1,0" M1="71" M2="71" P1="4904,508" P2="4904,511"/><JD c="000000,3,1,0" M1="72" M2="72" P1="24736,338" P2="24736,341"/><JD c="000000,3,1,0" M1="73" M2="73" P1="25865,339" P2="25865,342"/><JD c="000000,3,1,0" M1="74" M2="74" P1="26937,504" P2="26937,507"/><JD c="000000,3,1,0" M1="75" M2="75" P1="5411,508" P2="5411,511"/><JD c="000000,3,1,0" M1="76" M2="76" P1="21086,512" P2="21086,515"/><JD c="000000,3,1,0" M1="77" M2="77" P1="11108,166" P2="11108,169"/><JD c="000000,3,1,0" M1="78" M2="78" P1="11270,337" P2="11270,340"/><JD c="000000,3,1,0" M1="79" M2="79" P1="11386,337" P2="11386,340"/><JD c="000000,3,1,0" M1="80" M2="80" P1="11797,466" P2="11797,469"/><JD c="000000,3,1,0" M1="81" M2="81" P1="11968,166" P2="11968,169"/><JD c="000000,3,1,0" M1="82" M2="82" P1="24941,509" P2="24941,512"/><JD c="000000,3,1,0" M1="83" M2="83" P1="21900,510" P2="21900,513"/><JD c="000000,3,1,0" M1="84" M2="84" P1="11982,466" P2="11982,469"/><JD c="000000,3,1,0" M1="85" M2="85" P1="13129,251" P2="13129,254"/><JD c="000000,3,1,0" M1="86" M2="86" P1="13341,339" P2="13341,342"/><JD c="000000,3,1,0" M1="87" M2="87" P1="15081,339" P2="15081,342"/><JD c="000000,3,1,0" M1="88" M2="88" P1="15181,339" P2="15181,342"/><JD c="000000,3,1,0" M1="89" M2="89" P1="15441,509" P2="15441,512"/><JD c="000000,3,1,0" M1="90" M2="90" P1="24651,337" P2="24651,340"/><JD c="000000,3,1,0" M1="91" M2="91" P1="15621,509" P2="15621,512"/><JD c="000000,3,1,0" M1="92" M2="92" P1="5696,508" P2="5696,511"/><JD c="eec277,8,1,0" M1="54" M2="54" P1="2288.1,532.35" P2="2284.41,532.35"/><JD c="eec277,8,1,0" M1="55" M2="55" P1="25732.1,535.35" P2="25728.41,535.35"/><JD c="eec277,8,1,0" M1="56" M2="56" P1="23918.1,317.35" P2="23914.41,317.35"/><JD c="eec277,8,1,0" M1="57" M2="57" P1="13475.1,190.35" P2="13471.41,190.35"/><JD c="eec277,8,1,0" M1="58" M2="58" P1="24234.1,534.35" P2="24230.41,534.35"/><JD c="eec277,8,1,0" M1="59" M2="59" P1="14755.1,406.35" P2="14751.41,406.35"/><JD c="eec277,8,1,0" M1="60" M2="60" P1="15865.1,406.35" P2="15861.41,406.35"/><JD c="eec277,8,1,0" M1="132" M2="132" P1="21770.39,257.35" P2="21774.08,257.35"/><JD c="eec277,8,1,0" M1="133" M2="133" P1="3700.39,332.35" P2="3704.08,332.35"/><JD c="eec277,8,1,0" M1="134" M2="134" P1="25360.39,327.35" P2="25364.08,327.35"/><JD c="eec277,8,1,0" M1="135" M2="135" P1="26100.39,427.35" P2="26104.08,427.35"/><JD c="eec277,8,1,0" M1="136" M2="136" P1="12730.39,353.35" P2="12734.08,353.35"/><JD c="eec277,8,1,0" M1="137" M2="137" P1="14110.39,323.35" P2="14114.08,323.35"/><JD c="eec277,8,1,0" M1="54" M2="54" P1="2307.1,531.35" P2="2303.41,531.35"/><JD c="eec277,8,1,0" M1="55" M2="55" P1="25751.1,534.35" P2="25747.41,534.35"/><JD c="eec277,8,1,0" M1="56" M2="56" P1="23937.1,316.35" P2="23933.41,316.35"/><JD c="eec277,8,1,0" M1="57" M2="57" P1="13494.1,189.35" P2="13490.41,189.35"/><JD c="eec277,8,1,0" M1="58" M2="58" P1="24253.1,533.35" P2="24249.41,533.35"/><JD c="eec277,8,1,0" M1="59" M2="59" P1="14774.1,405.35" P2="14770.41,405.35"/><JD c="eec277,8,1,0" M1="60" M2="60" P1="15884.1,405.35" P2="15880.41,405.35"/><JD c="eec277,8,1,0" M1="132" M2="132" P1="21751.39,256.35" P2="21755.08,256.35"/><JD c="eec277,8,1,0" M1="133" M2="133" P1="3681.39,331.35" P2="3685.08,331.35"/><JD c="eec277,8,1,0" M1="134" M2="134" P1="25341.39,326.35" P2="25345.08,326.35"/><JD c="eec277,8,1,0" M1="135" M2="135" P1="26081.39,426.35" P2="26085.08,426.35"/><JD c="eec277,8,1,0" M1="136" M2="136" P1="12711.39,352.35" P2="12715.08,352.35"/><JD c="eec277,8,1,0" M1="137" M2="137" P1="14091.39,322.35" P2="14095.08,322.35"/><JD c="000000,3,1,0" M1="61" M2="61" P1="20966,342" P2="20966,345"/><JD c="000000,3,1,0" M1="62" M2="62" P1="1190,377" P2="1190,380"/><JD c="000000,3,1,0" M1="63" M2="63" P1="21420,340" P2="21420,343"/><JD c="000000,3,1,0" M1="64" M2="64" P1="1860,165" P2="1860,168"/><JD c="000000,3,1,0" M1="65" M2="65" P1="2650,165" P2="2650,168"/><JD c="000000,3,1,0" M1="66" M2="66" P1="22947,336" P2="22947,339"/><JD c="000000,3,1,0" M1="67" M2="67" P1="22858,337" P2="22858,340"/><JD c="000000,3,1,0" M1="68" M2="68" P1="2898,507" P2="2898,510"/><JD c="000000,3,1,0" M1="69" M2="69" P1="4636,250" P2="4636,253"/><JD c="000000,3,1,0" M1="70" M2="70" P1="23755,377" P2="23755,380"/><JD c="000000,3,1,0" M1="71" M2="71" P1="4914,508" P2="4914,511"/><JD c="000000,3,1,0" M1="72" M2="72" P1="24746,338" P2="24746,341"/><JD c="000000,3,1,0" M1="73" M2="73" P1="25875,339" P2="25875,342"/><JD c="000000,3,1,0" M1="74" M2="74" P1="26947,504" P2="26947,507"/><JD c="000000,3,1,0" M1="75" M2="75" P1="5421,508" P2="5421,511"/><JD c="000000,3,1,0" M1="76" M2="76" P1="21096,512" P2="21096,515"/><JD c="000000,3,1,0" M1="77" M2="77" P1="11118,166" P2="11118,169"/><JD c="000000,3,1,0" M1="78" M2="78" P1="11280,337" P2="11280,340"/><JD c="000000,3,1,0" M1="79" M2="79" P1="11396,337" P2="11396,340"/><JD c="000000,3,1,0" M1="80" M2="80" P1="11807,466" P2="11807,469"/><JD c="000000,3,1,0" M1="81" M2="81" P1="11978,166" P2="11978,169"/><JD c="000000,3,1,0" M1="82" M2="82" P1="24951,509" P2="24951,512"/><JD c="000000,3,1,0" M1="83" M2="83" P1="21910,510" P2="21910,513"/><JD c="000000,3,1,0" M1="84" M2="84" P1="11992,466" P2="11992,469"/><JD c="000000,3,1,0" M1="85" M2="85" P1="13139,251" P2="13139,254"/><JD c="000000,3,1,0" M1="86" M2="86" P1="13351,339" P2="13351,342"/><JD c="000000,3,1,0" M1="87" M2="87" P1="15091,339" P2="15091,342"/><JD c="000000,3,1,0" M1="88" M2="88" P1="15191,339" P2="15191,342"/><JD c="000000,3,1,0" M1="89" M2="89" P1="15451,509" P2="15451,512"/><JD c="000000,3,1,0" M1="90" M2="90" P1="24661,337" P2="24661,340"/><JD c="000000,3,1,0" M1="91" M2="91" P1="15631,509" P2="15631,512"/><JD c="000000,3,1,0" M1="92" M2="92" P1="5706,508" P2="5706,511"/><JD c="eec277,11,1,0" M1="54" M2="54" P1="2308.29,497.14" P2="2307.95,511.28"/><JD c="eec277,11,1,0" M1="55" M2="55" P1="25752.29,500.14" P2="25751.95,514.28"/><JD c="eec277,11,1,0" M1="56" M2="56" P1="23938.29,282.14" P2="23937.95,296.28"/><JD c="eec277,11,1,0" M1="57" M2="57" P1="13495.29,155.14" P2="13494.95,169.28"/><JD c="eec277,11,1,0" M1="58" M2="58" P1="24254.29,499.14" P2="24253.95,513.28"/><JD c="eec277,11,1,0" M1="59" M2="59" P1="14775.29,371.14" P2="14774.95,385.28"/><JD c="eec277,11,1,0" M1="60" M2="60" P1="15885.29,371.14" P2="15884.95,385.28"/><JD c="eec277,11,1,0" M1="132" M2="132" P1="21750.2,222.14" P2="21750.54,236.28"/><JD c="eec277,11,1,0" M1="133" M2="133" P1="3680.2,297.14" P2="3680.54,311.28"/><JD c="eec277,11,1,0" M1="134" M2="134" P1="25340.2,292.14" P2="25340.54,306.28"/><JD c="eec277,11,1,0" M1="135" M2="135" P1="26080.2,392.14" P2="26080.54,406.28"/><JD c="eec277,11,1,0" M1="136" M2="136" P1="12710.2,318.14" P2="12710.54,332.28"/><JD c="eec277,11,1,0" M1="137" M2="137" P1="14090.2,288.14" P2="14090.54,302.28"/><JD c="FFFFFF,29,1,0" M1="54" M2="54" P1="2294.94,517.09" P2="2294.94,518.09"/><JD c="FFFFFF,29,1,0" M1="55" M2="55" P1="25738.94,520.09" P2="25738.94,521.09"/><JD c="FFFFFF,29,1,0" M1="56" M2="56" P1="23924.94,302.09" P2="23924.94,303.09"/><JD c="FFFFFF,29,1,0" M1="57" M2="57" P1="13481.94,175.09" P2="13481.94,176.09"/><JD c="FFFFFF,29,1,0" M1="58" M2="58" P1="24240.94,519.09" P2="24240.94,520.09"/><JD c="FFFFFF,29,1,0" M1="59" M2="59" P1="14761.94,391.09" P2="14761.94,392.09"/><JD c="FFFFFF,29,1,0" M1="60" M2="60" P1="15871.94,391.09" P2="15871.94,392.09"/><JD c="FFFFFF,29,1,0" M1="132" M2="132" P1="21763.55,242.09" P2="21763.55,243.09"/><JD c="FFFFFF,29,1,0" M1="133" M2="133" P1="3693.55,317.09" P2="3693.55,318.09"/><JD c="FFFFFF,29,1,0" M1="134" M2="134" P1="25353.55,312.09" P2="25353.55,313.09"/><JD c="FFFFFF,29,1,0" M1="135" M2="135" P1="26093.55,412.09" P2="26093.55,413.09"/><JD c="FFFFFF,29,1,0" M1="136" M2="136" P1="12723.55,338.09" P2="12723.55,339.09"/><JD c="FFFFFF,29,1,0" M1="137" M2="137" P1="14103.55,308.09" P2="14103.55,309.09"/><JD c="0a8118,29,1,0" M1="54" M2="54" P1="2292.83,514.98" P2="2292.83,515.98"/><JD c="0a8118,29,1,0" M1="55" M2="55" P1="25736.83,517.98" P2="25736.83,518.98"/><JD c="0a8118,29,1,0" M1="56" M2="56" P1="23922.83,299.98" P2="23922.83,300.98"/><JD c="0a8118,29,1,0" M1="57" M2="57" P1="13479.83,172.98" P2="13479.83,173.98"/><JD c="0a8118,29,1,0" M1="58" M2="58" P1="24238.83,516.98" P2="24238.83,517.98"/><JD c="0a8118,29,1,0" M1="59" M2="59" P1="14759.83,388.98" P2="14759.83,389.98"/><JD c="0a8118,29,1,0" M1="60" M2="60" P1="15869.83,388.98" P2="15869.83,389.98"/><JD c="0a8118,29,1,0" M1="132" M2="132" P1="21765.66,239.98" P2="21765.66,240.98"/><JD c="0a8118,29,1,0" M1="133" M2="133" P1="3695.66,314.98" P2="3695.66,315.98"/><JD c="0a8118,29,1,0" M1="134" M2="134" P1="25355.66,309.98" P2="25355.66,310.98"/><JD c="0a8118,29,1,0" M1="135" M2="135" P1="26095.66,409.98" P2="26095.66,410.98"/><JD c="0a8118,29,1,0" M1="136" M2="136" P1="12725.66,335.98" P2="12725.66,336.98"/><JD c="0a8118,29,1,0" M1="137" M2="137" P1="14105.66,305.98" P2="14105.66,306.98"/><JD c="FFFFFF,6,1,0" M1="54" M2="54" P1="2309.33,495.04" P2="2309.33,500.56"/><JD c="FFFFFF,6,1,0" M1="55" M2="55" P1="25753.33,498.04" P2="25753.33,503.56"/><JD c="FFFFFF,6,1,0" M1="56" M2="56" P1="23939.33,280.04" P2="23939.33,285.56"/><JD c="FFFFFF,6,1,0" M1="57" M2="57" P1="13496.33,153.04" P2="13496.33,158.56"/><JD c="FFFFFF,6,1,0" M1="58" M2="58" P1="24255.33,497.04" P2="24255.33,502.56"/><JD c="FFFFFF,6,1,0" M1="59" M2="59" P1="14776.33,369.04" P2="14776.33,374.56"/><JD c="FFFFFF,6,1,0" M1="60" M2="60" P1="15886.33,369.04" P2="15886.33,374.56"/><JD c="FFFFFF,6,1,0" M1="132" M2="132" P1="21749.16,220.04" P2="21749.16,225.56"/><JD c="FFFFFF,6,1,0" M1="133" M2="133" P1="3679.16,295.04" P2="3679.16,300.56"/><JD c="FFFFFF,6,1,0" M1="134" M2="134" P1="25339.16,290.04" P2="25339.16,295.56"/><JD c="FFFFFF,6,1,0" M1="135" M2="135" P1="26079.16,390.04" P2="26079.16,395.56"/><JD c="FFFFFF,6,1,0" M1="136" M2="136" P1="12709.16,316.04" P2="12709.16,321.56"/><JD c="FFFFFF,6,1,0" M1="137" M2="137" P1="14089.16,286.04" P2="14089.16,291.56"/><JD c="0a8118,2,1,0" M1="54" M2="54" P1="2310.71,495.07" P2="2310.71,498"/><JD c="0a8118,2,1,0" M1="55" M2="55" P1="25754.71,498.07" P2="25754.71,501"/><JD c="0a8118,2,1,0" M1="56" M2="56" P1="23940.71,280.07" P2="23940.71,283"/><JD c="0a8118,2,1,0" M1="57" M2="57" P1="13497.71,153.07" P2="13497.71,156"/><JD c="0a8118,2,1,0" M1="58" M2="58" P1="24256.71,497.07" P2="24256.71,500"/><JD c="0a8118,2,1,0" M1="59" M2="59" P1="14777.71,369.07" P2="14777.71,372"/><JD c="0a8118,2,1,0" M1="60" M2="60" P1="15887.71,369.07" P2="15887.71,372"/><JD c="0a8118,2,1,0" M1="132" M2="132" P1="21747.78,220.07" P2="21747.78,223"/><JD c="0a8118,2,1,0" M1="133" M2="133" P1="3677.78,295.07" P2="3677.78,298"/><JD c="0a8118,2,1,0" M1="134" M2="134" P1="25337.78,290.07" P2="25337.78,293"/><JD c="0a8118,2,1,0" M1="135" M2="135" P1="26077.78,390.07" P2="26077.78,393"/><JD c="0a8118,2,1,0" M1="136" M2="136" P1="12707.78,316.07" P2="12707.78,319"/><JD c="0a8118,2,1,0" M1="137" M2="137" P1="14087.78,286.07" P2="14087.78,289"/><JD c="0a8118,2,1,0" M1="54" M2="54" P1="2311.74,505.07" P2="2311.74,506.07"/><JD c="0a8118,2,1,0" M1="55" M2="55" P1="25755.74,508.07" P2="25755.74,509.07"/><JD c="0a8118,2,1,0" M1="56" M2="56" P1="23941.74,290.07" P2="23941.74,291.07"/><JD c="0a8118,2,1,0" M1="57" M2="57" P1="13498.74,163.07" P2="13498.74,164.07"/><JD c="0a8118,2,1,0" M1="58" M2="58" P1="24257.74,507.07" P2="24257.74,508.07"/><JD c="0a8118,2,1,0" M1="59" M2="59" P1="14778.74,379.07" P2="14778.74,380.07"/><JD c="0a8118,2,1,0" M1="60" M2="60" P1="15888.74,379.07" P2="15888.74,380.07"/><JD c="0a8118,2,1,0" M1="132" M2="132" P1="21746.75,230.07" P2="21746.75,231.07"/><JD c="0a8118,2,1,0" M1="133" M2="133" P1="3676.75,305.07" P2="3676.75,306.07"/><JD c="0a8118,2,1,0" M1="134" M2="134" P1="25336.75,300.07" P2="25336.75,301.07"/><JD c="0a8118,2,1,0" M1="135" M2="135" P1="26076.75,400.07" P2="26076.75,401.07"/><JD c="0a8118,2,1,0" M1="136" M2="136" P1="12706.75,326.07" P2="12706.75,327.07"/><JD c="0a8118,2,1,0" M1="137" M2="137" P1="14086.75,296.07" P2="14086.75,297.07"/><JD c="5c94fc,3,1,0" M1="54" M2="54" P1="2309.33,507.14" P2="2313.12,514.04"/><JD c="000000,3,1,0" M1="55" M2="55" P1="25753.33,510.14" P2="25757.12,517.04"/><JD c="000000,3,1,0" M1="56" M2="56" P1="23939.33,292.14" P2="23943.12,299.04"/><JD c="5c94fc,3,1,0" M1="57" M2="57" P1="13496.33,165.14" P2="13500.12,172.04"/><JD c="000000,3,1,0" M1="58" M2="58" P1="24255.33,509.14" P2="24259.12,516.04"/><JD c="5c94fc,3,1,0" M1="59" M2="59" P1="14776.33,381.14" P2="14780.12,388.04"/><JD c="5c94fc,3,1,0" M1="60" M2="60" P1="15886.33,381.14" P2="15890.12,388.04"/><JD c="000000,3,1,0" M1="132" M2="132" P1="21749.16,232.14" P2="21745.37,239.04"/><JD c="5c94fc,3,1,0" M1="133" M2="133" P1="3679.16,307.14" P2="3675.37,314.04"/><JD c="000000,3,1,0" M1="134" M2="134" P1="25339.16,302.14" P2="25335.37,309.04"/><JD c="000000,3,1,0" M1="135" M2="135" P1="26079.16,402.14" P2="26075.37,409.04"/><JD c="5c94fc,3,1,0" M1="136" M2="136" P1="12709.16,328.14" P2="12705.37,335.04"/><JD c="5c94fc,3,1,0" M1="137" M2="137" P1="14089.16,298.14" P2="14085.37,305.04"/><JD c="eec277,1,1,0" M1="54" M2="54" P1="2286.66,502.79" P2="2304.33,520.7"/><JD c="eec277,1,1,0" M1="55" M2="55" P1="25730.66,505.79" P2="25748.33,523.7"/><JD c="eec277,1,1,0" M1="56" M2="56" P1="23916.66,287.79" P2="23934.33,305.7"/><JD c="eec277,1,1,0" M1="57" M2="57" P1="13473.66,160.79" P2="13491.33,178.7"/><JD c="eec277,1,1,0" M1="58" M2="58" P1="24232.66,504.79" P2="24250.33,522.7"/><JD c="eec277,1,1,0" M1="59" M2="59" P1="14753.66,376.79" P2="14771.33,394.7"/><JD c="eec277,1,1,0" M1="60" M2="60" P1="15863.66,376.79" P2="15881.33,394.7"/><JD c="eec277,1,1,0" M1="132" M2="132" P1="21771.83,227.79" P2="21754.16,245.7"/><JD c="eec277,1,1,0" M1="133" M2="133" P1="3701.83,302.79" P2="3684.16,320.7"/><JD c="eec277,1,1,0" M1="134" M2="134" P1="25361.83,297.79" P2="25344.16,315.7"/><JD c="eec277,1,1,0" M1="135" M2="135" P1="26101.83,397.79" P2="26084.16,415.7"/><JD c="eec277,1,1,0" M1="136" M2="136" P1="12731.83,323.79" P2="12714.16,341.7"/><JD c="eec277,1,1,0" M1="137" M2="137" P1="14111.83,293.79" P2="14094.16,311.7"/><JD c="eec277,1,1,0" M1="54" M2="54" P1="2280.38,509.07" P2="2299.68,527.68"/><JD c="eec277,1,1,0" M1="55" M2="55" P1="25724.38,512.07" P2="25743.68,530.68"/><JD c="eec277,1,1,0" M1="56" M2="56" P1="23910.38,294.07" P2="23929.68,312.68"/><JD c="eec277,1,1,0" M1="57" M2="57" P1="13467.38,167.07" P2="13486.68,185.68"/><JD c="eec277,1,1,0" M1="58" M2="58" P1="24226.38,511.07" P2="24245.68,529.68"/><JD c="eec277,1,1,0" M1="59" M2="59" P1="14747.38,383.07" P2="14766.68,401.68"/><JD c="eec277,1,1,0" M1="60" M2="60" P1="15857.38,383.07" P2="15876.68,401.68"/><JD c="eec277,1,1,0" M1="132" M2="132" P1="21778.11,234.07" P2="21758.81,252.68"/><JD c="eec277,1,1,0" M1="133" M2="133" P1="3708.11,309.07" P2="3688.81,327.68"/><JD c="eec277,1,1,0" M1="134" M2="134" P1="25368.11,304.07" P2="25348.81,322.68"/><JD c="eec277,1,1,0" M1="135" M2="135" P1="26108.11,404.07" P2="26088.81,422.68"/><JD c="eec277,1,1,0" M1="136" M2="136" P1="12738.11,330.07" P2="12718.81,348.68"/><JD c="eec277,1,1,0" M1="137" M2="137" P1="14118.11,300.07" P2="14098.81,318.68"/><JD c="eec277,1,1,0" M1="54" M2="54" P1="2305.73,510.47" P2="2288.05,527.68"/><JD c="eec277,1,1,0" M1="55" M2="55" P1="25749.73,513.47" P2="25732.05,530.68"/><JD c="eec277,1,1,0" M1="56" M2="56" P1="23935.73,295.47" P2="23918.05,312.68"/><JD c="eec277,1,1,0" M1="57" M2="57" P1="13492.73,168.47" P2="13475.05,185.68"/><JD c="eec277,1,1,0" M1="58" M2="58" P1="24251.73,512.47" P2="24234.05,529.68"/><JD c="eec277,1,1,0" M1="59" M2="59" P1="14772.73,384.47" P2="14755.05,401.68"/><JD c="eec277,1,1,0" M1="60" M2="60" P1="15882.73,384.47" P2="15865.05,401.68"/><JD c="eec277,1,1,0" M1="132" M2="132" P1="21752.76,235.47" P2="21770.44,252.68"/><JD c="eec277,1,1,0" M1="133" M2="133" P1="3682.76,310.47" P2="3700.44,327.68"/><JD c="eec277,1,1,0" M1="134" M2="134" P1="25342.76,305.47" P2="25360.44,322.68"/><JD c="eec277,1,1,0" M1="135" M2="135" P1="26082.76,405.47" P2="26100.44,422.68"/><JD c="eec277,1,1,0" M1="136" M2="136" P1="12712.76,331.47" P2="12730.44,348.68"/><JD c="eec277,1,1,0" M1="137" M2="137" P1="14092.76,301.47" P2="14110.44,318.68"/><JD c="eec277,1,1,0" M1="54" M2="54" P1="2297.12,502.33" P2="2280.38,520.7"/><JD c="eec277,1,1,0" M1="55" M2="55" P1="25741.12,505.33" P2="25724.38,523.7"/><JD c="eec277,1,1,0" M1="56" M2="56" P1="23927.12,287.33" P2="23910.38,305.7"/><JD c="eec277,1,1,0" M1="57" M2="57" P1="13484.12,160.33" P2="13467.38,178.7"/><JD c="eec277,1,1,0" M1="58" M2="58" P1="24243.12,504.33" P2="24226.38,522.7"/><JD c="eec277,1,1,0" M1="59" M2="59" P1="14764.12,376.33" P2="14747.38,394.7"/><JD c="eec277,1,1,0" M1="60" M2="60" P1="15874.12,376.33" P2="15857.38,394.7"/><JD c="eec277,1,1,0" M1="132" M2="132" P1="21761.37,227.33" P2="21778.11,245.7"/><JD c="eec277,1,1,0" M1="133" M2="133" P1="3691.37,302.33" P2="3708.11,320.7"/><JD c="eec277,1,1,0" M1="134" M2="134" P1="25351.37,297.33" P2="25368.11,315.7"/><JD c="eec277,1,1,0" M1="135" M2="135" P1="26091.37,397.33" P2="26108.11,415.7"/><JD c="eec277,1,1,0" M1="136" M2="136" P1="12721.37,323.33" P2="12738.11,341.7"/><JD c="eec277,1,1,0" M1="137" M2="137" P1="14101.37,293.33" P2="14118.11,311.7"/><JD c="FFFFFF,10,1,0" M1="132" M2="132" P1="21778.3,217.44" P2="21769.24,229.53"/><JD c="FFFFFF,10,1,0" M1="133" M2="133" P1="3708.3,292.44" P2="3699.24,304.53"/><JD c="FFFFFF,10,1,0" M1="134" M2="134" P1="25368.3,287.44" P2="25359.24,299.53"/><JD c="FFFFFF,10,1,0" M1="135" M2="135" P1="26108.3,387.44" P2="26099.24,399.53"/><JD c="FFFFFF,10,1,0" M1="136" M2="136" P1="12738.3,313.44" P2="12729.24,325.53"/><JD c="FFFFFF,10,1,0" M1="137" M2="137" P1="14118.3,283.44" P2="14109.24,295.53"/><JD c="eec277,1,1,0" M1="132" M2="132" P1="21775.12,217.86" P2="21767.43,227.6"/><JD c="eec277,1,1,0" M1="133" M2="133" P1="3705.12,292.86" P2="3697.43,302.6"/><JD c="eec277,1,1,0" M1="134" M2="134" P1="25365.12,287.86" P2="25357.43,297.6"/><JD c="eec277,1,1,0" M1="135" M2="135" P1="26105.12,387.86" P2="26097.43,397.6"/><JD c="eec277,1,1,0" M1="136" M2="136" P1="12735.12,313.86" P2="12727.43,323.6"/><JD c="eec277,1,1,0" M1="137" M2="137" P1="14115.12,283.86" P2="14107.43,293.6"/><JD c="000000,4,1,0" M1="132" M2="132" P1="21784.12,220.75" P2="21776.66,220.45"/><JD c="5c94fc,4,1,0" M1="133" M2="133" P1="3714.12,295.75" P2="3706.66,295.45"/><JD c="000000,4,1,0" M1="134" M2="134" P1="25374.12,290.75" P2="25366.66,290.45"/><JD c="000000,4,1,0" M1="135" M2="135" P1="26114.12,390.75" P2="26106.66,390.45"/><JD c="5c94fc,4,1,0" M1="136" M2="136" P1="12744.12,316.75" P2="12736.66,316.45"/><JD c="5c94fc,4,1,0" M1="137" M2="137" P1="14124.12,286.75" P2="14116.66,286.45"/><JD c="000000,3,1,0" M1="132" M2="132" P1="21780.25,226.06" P2="21773.58,225.55"/><JD c="5c94fc,3,1,0" M1="133" M2="133" P1="3710.25,301.06" P2="3703.58,300.55"/><JD c="000000,3,1,0" M1="134" M2="134" P1="25370.25,296.06" P2="25363.58,295.55"/><JD c="000000,3,1,0" M1="135" M2="135" P1="26110.25,396.06" P2="26103.58,395.55"/><JD c="5c94fc,3,1,0" M1="136" M2="136" P1="12740.25,322.06" P2="12733.58,321.55"/><JD c="5c94fc,3,1,0" M1="137" M2="137" P1="14120.25,292.06" P2="14113.58,291.55"/><JR M1="93" M2="54"/><JR M1="105" M2="66"/><JR M1="106" M2="67"/><JR M1="107" M2="68"/><JR M1="94" M2="55"/><JR M1="108" M2="69"/><JR M1="109" M2="70"/><JR M1="110" M2="71"/><JR M1="95" M2="56"/><JR M1="95" M2="56"/><JR M1="111" M2="72"/><JR M1="114" M2="75"/><JR M1="114" M2="75"/><JR M1="131" M2="92"/><JP M1="61" AXIS="-1,0"/><JP M1="62" AXIS="-1,0"/><JD M1="61" M2="1"/><JD M1="62" M2="1"/><JR M1="100" M2="61"/><JR M1="101" M2="62"/><JR M1="102" M2="63"/><JR M1="103" M2="64"/><JP M1="63" AXIS="-1,0"/><JP M1="64" AXIS="-1,0"/><JR M1="104" M2="65"/><JP M1="65" AXIS="-1,0"/><JD M1="1" M2="63"/><JD M1="1" M2="103"/><JD c="d62700,11,1,0" M1="144" M2="144" P1="2164,229" P2="2216,229"/><JD c="d62700,11,1,0" M1="145" M2="145" P1="1464,204" P2="1516,204"/><JD c="d62700,11,1,0" M1="145" M2="145" P1="22304,104" P2="22356,104"/><JD c="d62700,11,1,0" M1="145" M2="145" P1="23544,144" P2="23596,144"/><JD c="d62700,11,1,0" M1="145" M2="145" P1="23183,444" P2="23235,444"/><JD c="d62700,11,1,0" M1="145" M2="145" P1="23423,445" P2="23475,445"/><JD c="d62700,11,1,0" M1="145" M2="145" P1="24664,484" P2="24716,484"/><JD c="d62700,11,1,0" M1="145" M2="145" P1="25514,464" P2="25566,464"/><JD c="d62700,11,1,0" M1="152" M2="152" P1="22044,105" P2="22096,105"/><JD c="d62700,11,1,0" M1="153" M2="153" P1="3304,529" P2="3356,529"/><JD c="d62700,11,1,0" M1="154" M2="154" P1="4074,279" P2="4126,279"/><JD c="d62700,11,1,0" M1="155" M2="155" P1="3674,349" P2="3726,349"/><JD c="d62700,11,1,0" M1="156" M2="156" P1="5274,299" P2="5326,299"/><JD c="d62700,11,1,0" M1="157" M2="157" P1="21534,150" P2="21586,150"/><JD c="d62700,11,1,0" M1="158" M2="158" P1="22404,470" P2="22456,470"/><JD c="d62700,11,1,0" M1="159" M2="159" P1="23984,140" P2="24036,140"/><JD c="d62700,11,1,0" M1="160" M2="160" P1="24954,250" P2="25006,250"/><JD c="d62700,11,1,0" M1="161" M2="161" P1="26114,390" P2="26166,390"/><JD c="d62700,11,1,0" M1="162" M2="162" P1="23164,240" P2="23216,240"/><JD c="d62700,11,1,0" M1="163" M2="163" P1="12674,480" P2="12726,480"/><JD c="d62700,11,1,0" M1="164" M2="164" P1="13814,200" P2="13866,200"/><JD c="d62700,11,1,0" M1="165" M2="165" P1="14054,500" P2="14106,500"/><JD c="d62700,11,1,0" M1="166" M2="166" P1="14694,200" P2="14746,200"/><JD c="d62700,11,1,0" M1="167" M2="167" P1="2354,229" P2="2406,229"/><JD c="d62700,11,1,0" M1="168" M2="168" P1="3494,529" P2="3546,529"/><JPL c="F2F2F2,2,1,0" M1="157" M2="172" P3="21560,49" P4="21750,49"/><JPL c="F2F2F2,2,1,0" M1="158" M2="173" P3="22430,369" P4="22620,369"/><JPL c="F2F2F2,2,1,0" M1="159" M2="174" P3="24010,39" P4="24200,39"/><JPL c="F2F2F2,2,1,0" M1="160" M2="175" P3="24980,149" P4="25170,149"/><JPL c="F2F2F2,2,1,0" M1="161" M2="176" P3="26140,289" P4="26330,289"/><JPL c="F2F2F2,2,1,0" M1="162" M2="177" P3="23190,139" P4="23380,139"/><JD c="d62700,11,1,0" M1="169" M2="169" P1="4264,279" P2="4316,279"/><JD c="d62700,11,1,0" M1="170" M2="170" P1="3864,349" P2="3916,349"/><JD c="d62700,11,1,0" M1="171" M2="171" P1="5464,299" P2="5516,299"/><JD c="d62700,11,1,0" M1="172" M2="172" P1="21724,150" P2="21776,150"/><JD c="d62700,11,1,0" M1="173" M2="173" P1="22594,470" P2="22646,470"/><JD c="d62700,11,1,0" M1="174" M2="174" P1="24174,140" P2="24226,140"/><JD c="d62700,11,1,0" M1="175" M2="175" P1="25144,250" P2="25196,250"/><JD c="d62700,11,1,0" M1="176" M2="176" P1="26304,390" P2="26356,390"/><JD c="d62700,11,1,0" M1="177" M2="177" P1="23354,240" P2="23406,240"/><JD c="d62700,11,1,0" M1="178" M2="178" P1="12864,480" P2="12916,480"/><JD c="d62700,11,1,0" M1="179" M2="179" P1="14004,200" P2="14056,200"/><JD c="d62700,11,1,0" M1="180" M2="180" P1="14234,200" P2="14286,200"/><JD c="d62700,11,1,0" M1="181" M2="181" P1="11373,173" P2="11425,173"/><JD c="d62700,11,1,0" M1="182" M2="182" P1="21213,473" P2="21265,473"/><JD c="d62700,11,1,0" M1="183" M2="183" P1="21043,243" P2="21095,243"/><JD c="d62700,11,1,0" M1="184" M2="184" P1="21273,182" P2="21325,182"/><JD c="d62700,11,1,0" M1="185" M2="185" P1="22543,263" P2="22595,263"/><JD c="d62700,11,1,0" M1="186" M2="186" P1="25363,213" P2="25415,213"/><JD c="d62700,11,1,0" M1="187" M2="187" P1="26523,363" P2="26575,363"/><JD c="d62700,11,1,0" M1="188" M2="188" P1="11013,473" P2="11065,473"/><JD c="d62700,11,1,0" M1="189" M2="189" P1="4573,472" P2="4625,472"/><JD c="d62700,11,1,0" M1="190" M2="190" P1="3763,552" P2="3815,552"/><JD c="d62700,11,1,0" M1="191" M2="191" P1="1973,542" P2="2025,542"/><JD c="d62700,11,1,0" M1="192" M2="192" P1="3973,522" P2="4025,522"/><JD c="d62700,11,1,0" M1="193" M2="193" P1="6403,222" P2="6455,222"/><JD c="d62700,11,1,0" M1="194" M2="194" P1="14484,200" P2="14536,200"/><JD c="d62700,11,1,0" M1="195" M2="195" P1="14244,500" P2="14296,500"/><JD c="d62700,11,1,0" M1="196" M2="196" P1="14884,200" P2="14936,200"/><JD M1="1" M2="65"/><JD c="fd993c,8,1,0" M1="144" M2="144" P1="2164,229" P2="2216,229"/><JD c="fd993c,8,1,0" M1="145" M2="145" P1="1464,204" P2="1516,204"/><JD c="fd993c,8,1,0" M1="145" M2="145" P1="22304,104" P2="22356,104"/><JD c="fd993c,8,1,0" M1="145" M2="145" P1="23544,144" P2="23596,144"/><JD c="fd993c,8,1,0" M1="145" M2="145" P1="23183,444" P2="23235,444"/><JD c="fd993c,8,1,0" M1="145" M2="145" P1="23423,445" P2="23475,445"/><JD c="fd993c,8,1,0" M1="145" M2="145" P1="24664,484" P2="24716,484"/><JD c="fd993c,8,1,0" M1="145" M2="145" P1="25514,464" P2="25566,464"/><JD c="fd993c,8,1,0" M1="152" M2="152" P1="22044,105" P2="22096,105"/><JD c="fd993c,8,1,0" M1="153" M2="153" P1="3304,529" P2="3356,529"/><JD c="fd993c,8,1,0" M1="154" M2="154" P1="4074,279" P2="4126,279"/><JD c="fd993c,8,1,0" M1="155" M2="155" P1="3674,349" P2="3726,349"/><JD c="fd993c,8,1,0" M1="156" M2="156" P1="5274,299" P2="5326,299"/><JD c="fd993c,8,1,0" M1="157" M2="157" P1="21534,150" P2="21586,150"/><JD c="fd993c,8,1,0" M1="158" M2="158" P1="22404,470" P2="22456,470"/><JD c="fd993c,8,1,0" M1="159" M2="159" P1="23984,140" P2="24036,140"/><JD c="fd993c,8,1,0" M1="160" M2="160" P1="24954,250" P2="25006,250"/><JD c="fd993c,8,1,0" M1="161" M2="161" P1="26114,390" P2="26166,390"/><JD c="fd993c,8,1,0" M1="162" M2="162" P1="23164,240" P2="23216,240"/><JD c="fd993c,8,1,0" M1="163" M2="163" P1="12674,480" P2="12726,480"/><JD c="fd993c,8,1,0" M1="164" M2="164" P1="13814,200" P2="13866,200"/><JD c="fd993c,8,1,0" M1="165" M2="165" P1="14054,500" P2="14106,500"/><JD c="fd993c,8,1,0" M1="166" M2="166" P1="14694,200" P2="14746,200"/><JD c="fd993c,8,1,0" M1="167" M2="167" P1="2354,229" P2="2406,229"/><JD c="fd993c,8,1,0" M1="168" M2="168" P1="3494,529" P2="3546,529"/><JD c="fd993c,8,1,0" M1="169" M2="169" P1="4264,279" P2="4316,279"/><JD c="fd993c,8,1,0" M1="170" M2="170" P1="3864,349" P2="3916,349"/><JD c="fd993c,8,1,0" M1="171" M2="171" P1="5464,299" P2="5516,299"/><JD c="fd993c,8,1,0" M1="172" M2="172" P1="21724,150" P2="21776,150"/><JD c="FFFFFF,2,1,0" M1="182" P2="21238,376.1"/><JD c="FFFFFF,2,1,0" M1="183" P2="21068,146.1"/><JD c="FFFFFF,2,1,0" M1="184" P2="21298,85.1"/><JD c="FFFFFF,2,1,0" M1="185" P2="22568,166.1"/><JD c="FFFFFF,2,1,0" M1="186" P2="25388,116.1"/><JD c="FFFFFF,2,1,0" M1="187" P2="26548,266.1"/><JD c="fd993c,8,1,0" M1="173" M2="173" P1="22594,470" P2="22646,470"/><JD c="fd993c,8,1,0" M1="174" M2="174" P1="24174,140" P2="24226,140"/><JD c="fd993c,8,1,0" M1="175" M2="175" P1="25144,250" P2="25196,250"/><JD c="fd993c,8,1,0" M1="176" M2="176" P1="26304,390" P2="26356,390"/><JD c="fd993c,8,1,0" M1="177" M2="177" P1="23354,240" P2="23406,240"/><JD c="fd993c,8,1,0" M1="178" M2="178" P1="12864,480" P2="12916,480"/><JD c="fd993c,8,1,0" M1="179" M2="179" P1="14004,200" P2="14056,200"/><JD c="fd993c,8,1,0" M1="180" M2="180" P1="14234,200" P2="14286,200"/><JD c="fd993c,8,1,0" M1="181" M2="181" P1="11373,173" P2="11425,173"/><JD c="fd993c,8,1,0" M1="182" M2="182" P1="21213,473" P2="21265,473"/><JD c="fd993c,8,1,0" M1="183" M2="183" P1="21043,243" P2="21095,243"/><JD c="fd993c,8,1,0" M1="184" M2="184" P1="21273,182" P2="21325,182"/><JD c="fd993c,8,1,0" M1="185" M2="185" P1="22543,263" P2="22595,263"/><JD c="fd993c,8,1,0" M1="186" M2="186" P1="25363,213" P2="25415,213"/><JD c="fd993c,8,1,0" M1="187" M2="187" P1="26523,363" P2="26575,363"/><JD c="fd993c,8,1,0" M1="188" M2="188" P1="11013,473" P2="11065,473"/><JD c="fd993c,8,1,0" M1="189" M2="189" P1="4573,472" P2="4625,472"/><JD c="fd993c,8,1,0" M1="190" M2="190" P1="3763,552" P2="3815,552"/><JD c="fd993c,8,1,0" M1="191" M2="191" P1="1973,542" P2="2025,542"/><JD c="fd993c,8,1,0" M1="192" M2="192" P1="3973,522" P2="4025,522"/><JD c="fd993c,8,1,0" M1="193" M2="193" P1="6403,222" P2="6455,222"/><JD c="fd993c,8,1,0" M1="194" M2="194" P1="14484,200" P2="14536,200"/><JD c="fd993c,8,1,0" M1="195" M2="195" P1="14244,500" P2="14296,500"/><JD c="fd993c,8,1,0" M1="196" M2="196" P1="14884,200" P2="14936,200"/><JD c="5c94fc,6,1,0" M1="144" M2="144" P1="2167.11,229.1" P2="2167.11,230.1"/><JD c="5c94fc,6,1,0" M1="145" M2="145" P1="1467.11,204.1" P2="1467.11,205.1"/><JD c="000000,6,1,0" M1="145" M2="145" P1="22307.11,104.1" P2="22307.11,105.1"/><JD c="000000,6,1,0" M1="145" M2="145" P1="23547.11,144.1" P2="23547.11,145.1"/><JD c="000000,6,1,0" M1="145" M2="145" P1="23186.11,444.1" P2="23186.11,445.1"/><JD c="000000,6,1,0" M1="145" M2="145" P1="23426.11,445.1" P2="23426.11,446.1"/><JD c="000000,6,1,0" M1="145" M2="145" P1="24667.11,484.1" P2="24667.11,485.1"/><JD c="000000,6,1,0" M1="145" M2="145" P1="25517.11,464.1" P2="25517.11,465.1"/><JD c="000000,6,1,0" M1="152" M2="152" P1="22047.11,105.1" P2="22047.11,106.1"/><JD c="c84c0c,6,1,0" M1="153" M2="153" P1="3307.11,529.1" P2="3307.11,530.1"/><JD c="5c94fc,6,1,0" M1="154" M2="154" P1="4077.11,279.1" P2="4077.11,280.1"/><JD c="5c94fc,6,1,0" M1="155" M2="155" P1="3677.11,349.1" P2="3677.11,350.1"/><JD c="5c94fc,6,1,0" M1="156" M2="156" P1="5277.11,299.1" P2="5277.11,300.1"/><JD c="000000,6,1,0" M1="157" M2="157" P1="21537.11,150.1" P2="21537.11,151.1"/><JD c="000000,6,1,0" M1="158" M2="158" P1="22407.11,470.1" P2="22407.11,471.1"/><JD c="000000,6,1,0" M1="159" M2="159" P1="23987.11,140.1" P2="23987.11,141.1"/><JD c="000000,6,1,0" M1="160" M2="160" P1="24957.11,250.1" P2="24957.11,251.1"/><JD c="000000,6,1,0" M1="161" M2="161" P1="26117.11,390.1" P2="26117.11,391.1"/><JD c="000000,6,1,0" M1="162" M2="162" P1="23167.11,240.1" P2="23167.11,241.1"/><JD c="5c94fc,6,1,0" M1="163" M2="163" P1="12677.11,480.1" P2="12677.11,481.1"/><JD c="5c94fc,6,1,0" M1="164" M2="164" P1="13817.11,200.1" P2="13817.11,201.1"/><JD c="5c94fc,6,1,0" M1="165" M2="165" P1="14057.11,500.1" P2="14057.11,501.1"/><JD c="5c94fc,6,1,0" M1="166" M2="166" P1="14697.11,200.1" P2="14697.11,201.1"/><JD c="5c94fc,6,1,0" M1="167" M2="167" P1="2357.11,229.1" P2="2357.11,230.1"/><JD c="5c94fc,6,1,0" M1="168" M2="168" P1="3497.11,529.1" P2="3497.11,530.1"/><JD c="5c94fc,6,1,0" M1="169" M2="169" P1="4267.11,279.1" P2="4267.11,280.1"/><JD c="5c94fc,6,1,0" M1="170" M2="170" P1="3867.11,349.1" P2="3867.11,350.1"/><JD c="5c94fc,6,1,0" M1="171" M2="171" P1="5467.11,299.1" P2="5467.11,300.1"/><JD c="000000,6,1,0" M1="172" M2="172" P1="21727.11,150.1" P2="21727.11,151.1"/><JD c="000000,6,1,0" M1="173" M2="173" P1="22597.11,470.1" P2="22597.11,471.1"/><JD c="000000,6,1,0" M1="174" M2="174" P1="24177.11,140.1" P2="24177.11,141.1"/><JD c="000000,6,1,0" M1="175" M2="175" P1="25147.11,250.1" P2="25147.11,251.1"/><JD c="000000,6,1,0" M1="176" M2="176" P1="26307.11,390.1" P2="26307.11,391.1"/><JD c="000000,6,1,0" M1="177" M2="177" P1="23357.11,240.1" P2="23357.11,241.1"/><JD c="5c94fc,6,1,0" M1="178" M2="178" P1="12867.11,480.1" P2="12867.11,481.1"/><JD c="5c94fc,6,1,0" M1="179" M2="179" P1="14007.11,200.1" P2="14007.11,201.1"/><JD c="5c94fc,6,1,0" M1="180" M2="180" P1="14237.11,200.1" P2="14237.11,201.1"/><JD c="5c94fc,6,1,0" M1="181" M2="181" P1="11376.11,173.1" P2="11376.11,174.1"/><JD c="000000,6,1,0" M1="182" M2="182" P1="21216.11,473.1" P2="21216.11,474.1"/><JD c="000000,6,1,0" M1="183" M2="183" P1="21046.11,243.1" P2="21046.11,244.1"/><JD c="000000,6,1,0" M1="184" M2="184" P1="21276.11,182.1" P2="21276.11,183.1"/><JD c="000000,6,1,0" M1="185" M2="185" P1="22546.11,263.1" P2="22546.11,264.1"/><JD c="000000,6,1,0" M1="186" M2="186" P1="25366.11,213.1" P2="25366.11,214.1"/><JD c="000000,6,1,0" M1="187" M2="187" P1="26526.11,363.1" P2="26526.11,364.1"/><JD c="5c94fc,6,1,0" M1="188" M2="188" P1="11016.11,473.1" P2="11016.11,474.1"/><JD c="c84c0c,6,1,0" M1="189" M2="189" P1="4576.11,472.1" P2="4576.11,473.1"/><JD c="5c94fc,6,1,0" M1="190" M2="190" P1="3766.11,552.1" P2="3766.11,553.1"/><JD c="5c94fc,6,1,0" M1="191" M2="191" P1="1976.11,542.1" P2="1976.11,543.1"/><JD c="5c94fc,6,1,0" M1="192" M2="192" P1="3976.11,522.1" P2="3976.11,523.1"/><JD c="5c94fc,6,1,0" M1="193" M2="193" P1="6406.11,222.1" P2="6406.11,223.1"/><JD c="5c94fc,6,1,0" M1="194" M2="194" P1="14487.11,200.1" P2="14487.11,201.1"/><JD c="5c94fc,6,1,0" M1="195" M2="195" P1="14247.11,500.1" P2="14247.11,501.1"/><JD c="5c94fc,6,1,0" M1="196" M2="196" P1="14887.11,200.1" P2="14887.11,201.1"/><JD c="5c94fc,6,1,0" M1="144" M2="144" P1="2187.11,229.1" P2="2187.11,230.1"/><JD c="5c94fc,6,1,0" M1="145" M2="145" P1="1487.11,204.1" P2="1487.11,205.1"/><JD c="000000,6,1,0" M1="145" M2="145" P1="22327.11,104.1" P2="22327.11,105.1"/><JD c="000000,6,1,0" M1="145" M2="145" P1="23567.11,144.1" P2="23567.11,145.1"/><JD c="000000,6,1,0" M1="145" M2="145" P1="23206.11,444.1" P2="23206.11,445.1"/><JD c="000000,6,1,0" M1="145" M2="145" P1="23446.11,445.1" P2="23446.11,446.1"/><JD c="000000,6,1,0" M1="145" M2="145" P1="24687.11,484.1" P2="24687.11,485.1"/><JD c="000000,6,1,0" M1="145" M2="145" P1="25537.11,464.1" P2="25537.11,465.1"/><JD c="000000,6,1,0" M1="152" M2="152" P1="22067.11,105.1" P2="22067.11,106.1"/><JD c="c84c0c,6,1,0" M1="153" M2="153" P1="3327.11,529.1" P2="3327.11,530.1"/><JD c="5c94fc,6,1,0" M1="154" M2="154" P1="4097.11,279.1" P2="4097.11,280.1"/><JD c="5c94fc,6,1,0" M1="155" M2="155" P1="3697.11,349.1" P2="3697.11,350.1"/><JD c="5c94fc,6,1,0" M1="156" M2="156" P1="5297.11,299.1" P2="5297.11,300.1"/><JD c="000000,6,1,0" M1="157" M2="157" P1="21557.11,150.1" P2="21557.11,151.1"/><JD c="000000,6,1,0" M1="158" M2="158" P1="22427.11,470.1" P2="22427.11,471.1"/><JD c="000000,6,1,0" M1="159" M2="159" P1="24007.11,140.1" P2="24007.11,141.1"/><JD c="000000,6,1,0" M1="160" M2="160" P1="24977.11,250.1" P2="24977.11,251.1"/><JD c="000000,6,1,0" M1="161" M2="161" P1="26137.11,390.1" P2="26137.11,391.1"/><JD c="000000,6,1,0" M1="162" M2="162" P1="23187.11,240.1" P2="23187.11,241.1"/><JD c="5c94fc,6,1,0" M1="163" M2="163" P1="12697.11,480.1" P2="12697.11,481.1"/><JD c="5c94fc,6,1,0" M1="164" M2="164" P1="13837.11,200.1" P2="13837.11,201.1"/><JD c="5c94fc,6,1,0" M1="165" M2="165" P1="14077.11,500.1" P2="14077.11,501.1"/><JD c="5c94fc,6,1,0" M1="166" M2="166" P1="14717.11,200.1" P2="14717.11,201.1"/><JD c="5c94fc,6,1,0" M1="167" M2="167" P1="2377.11,229.1" P2="2377.11,230.1"/><JD c="5c94fc,6,1,0" M1="168" M2="168" P1="3517.11,529.1" P2="3517.11,530.1"/><JD c="5c94fc,6,1,0" M1="169" M2="169" P1="4287.11,279.1" P2="4287.11,280.1"/><JD c="5c94fc,6,1,0" M1="170" M2="170" P1="3887.11,349.1" P2="3887.11,350.1"/><JD c="5c94fc,6,1,0" M1="171" M2="171" P1="5487.11,299.1" P2="5487.11,300.1"/><JD c="000000,6,1,0" M1="172" M2="172" P1="21747.11,150.1" P2="21747.11,151.1"/><JD c="000000,6,1,0" M1="173" M2="173" P1="22617.11,470.1" P2="22617.11,471.1"/><JD c="000000,6,1,0" M1="174" M2="174" P1="24197.11,140.1" P2="24197.11,141.1"/><JD c="000000,6,1,0" M1="175" M2="175" P1="25167.11,250.1" P2="25167.11,251.1"/><JD c="000000,6,1,0" M1="176" M2="176" P1="26327.11,390.1" P2="26327.11,391.1"/><JD c="000000,6,1,0" M1="177" M2="177" P1="23377.11,240.1" P2="23377.11,241.1"/><JD c="5c94fc,6,1,0" M1="178" M2="178" P1="12887.11,480.1" P2="12887.11,481.1"/><JD c="5c94fc,6,1,0" M1="179" M2="179" P1="14027.11,200.1" P2="14027.11,201.1"/><JD c="5c94fc,6,1,0" M1="180" M2="180" P1="14257.11,200.1" P2="14257.11,201.1"/><JD c="5c94fc,6,1,0" M1="181" M2="181" P1="11396.11,173.1" P2="11396.11,174.1"/><JD c="000000,6,1,0" M1="182" M2="182" P1="21236.11,473.1" P2="21236.11,474.1"/><JD c="000000,6,1,0" M1="183" M2="183" P1="21066.11,243.1" P2="21066.11,244.1"/><JD c="000000,6,1,0" M1="184" M2="184" P1="21296.11,182.1" P2="21296.11,183.1"/><JD c="000000,6,1,0" M1="185" M2="185" P1="22566.11,263.1" P2="22566.11,264.1"/><JD c="000000,6,1,0" M1="186" M2="186" P1="25386.11,213.1" P2="25386.11,214.1"/><JD c="000000,6,1,0" M1="187" M2="187" P1="26546.11,363.1" P2="26546.11,364.1"/><JD c="5c94fc,6,1,0" M1="188" M2="188" P1="11036.11,473.1" P2="11036.11,474.1"/><JD c="c84c0c,6,1,0" M1="189" M2="189" P1="4596.11,472.1" P2="4596.11,473.1"/><JD c="5c94fc,6,1,0" M1="190" M2="190" P1="3786.11,552.1" P2="3786.11,553.1"/><JD c="5c94fc,6,1,0" M1="191" M2="191" P1="1996.11,542.1" P2="1996.11,543.1"/><JD c="5c94fc,6,1,0" M1="192" M2="192" P1="3996.11,522.1" P2="3996.11,523.1"/><JD c="5c94fc,6,1,0" M1="193" M2="193" P1="6426.11,222.1" P2="6426.11,223.1"/><JD c="5c94fc,6,1,0" M1="194" M2="194" P1="14507.11,200.1" P2="14507.11,201.1"/><JD c="5c94fc,6,1,0" M1="195" M2="195" P1="14267.11,500.1" P2="14267.11,501.1"/><JD c="5c94fc,6,1,0" M1="196" M2="196" P1="14907.11,200.1" P2="14907.11,201.1"/><JD c="5c94fc,6,1,0" M1="144" M2="144" P1="2210.11,229.1" P2="2210.11,230.1"/><JD c="5c94fc,6,1,0" M1="145" M2="145" P1="1510.11,204.1" P2="1510.11,205.1"/><JD c="000000,6,1,0" M1="145" M2="145" P1="22350.11,104.1" P2="22350.11,105.1"/><JD c="000000,6,1,0" M1="145" M2="145" P1="23590.11,144.1" P2="23590.11,145.1"/><JD c="000000,6,1,0" M1="145" M2="145" P1="23229.11,444.1" P2="23229.11,445.1"/><JD c="000000,6,1,0" M1="145" M2="145" P1="23469.11,445.1" P2="23469.11,446.1"/><JD c="000000,6,1,0" M1="145" M2="145" P1="24710.11,484.1" P2="24710.11,485.1"/><JD c="000000,6,1,0" M1="145" M2="145" P1="25560.11,464.1" P2="25560.11,465.1"/><JD c="000000,6,1,0" M1="152" M2="152" P1="22090.11,105.1" P2="22090.11,106.1"/><JD c="c84c0c,6,1,0" M1="153" M2="153" P1="3350.11,529.1" P2="3350.11,530.1"/><JD c="5c94fc,6,1,0" M1="154" M2="154" P1="4120.11,279.1" P2="4120.11,280.1"/><JD c="5c94fc,6,1,0" M1="155" M2="155" P1="3720.11,349.1" P2="3720.11,350.1"/><JD c="5c94fc,6,1,0" M1="156" M2="156" P1="5320.11,299.1" P2="5320.11,300.1"/><JD c="000000,6,1,0" M1="157" M2="157" P1="21580.11,150.1" P2="21580.11,151.1"/><JD c="000000,6,1,0" M1="158" M2="158" P1="22450.11,470.1" P2="22450.11,471.1"/><JD c="000000,6,1,0" M1="159" M2="159" P1="24030.11,140.1" P2="24030.11,141.1"/><JD c="000000,6,1,0" M1="160" M2="160" P1="25000.11,250.1" P2="25000.11,251.1"/><JD c="000000,6,1,0" M1="161" M2="161" P1="26160.11,390.1" P2="26160.11,391.1"/><JD c="000000,6,1,0" M1="162" M2="162" P1="23210.11,240.1" P2="23210.11,241.1"/><JD c="5c94fc,6,1,0" M1="163" M2="163" P1="12720.11,480.1" P2="12720.11,481.1"/><JD c="5c94fc,6,1,0" M1="164" M2="164" P1="13860.11,200.1" P2="13860.11,201.1"/><JD c="5c94fc,6,1,0" M1="165" M2="165" P1="14100.11,500.1" P2="14100.11,501.1"/><JD c="5c94fc,6,1,0" M1="166" M2="166" P1="14740.11,200.1" P2="14740.11,201.1"/><JD c="5c94fc,6,1,0" M1="167" M2="167" P1="2400.11,229.1" P2="2400.11,230.1"/><JD c="5c94fc,6,1,0" M1="168" M2="168" P1="3540.11,529.1" P2="3540.11,530.1"/><JD c="5c94fc,6,1,0" M1="169" M2="169" P1="4310.11,279.1" P2="4310.11,280.1"/><JD c="5c94fc,6,1,0" M1="170" M2="170" P1="3910.11,349.1" P2="3910.11,350.1"/><JD c="5c94fc,6,1,0" M1="171" M2="171" P1="5510.11,299.1" P2="5510.11,300.1"/><JD c="000000,6,1,0" M1="172" M2="172" P1="21770.11,150.1" P2="21770.11,151.1"/><JD c="000000,6,1,0" M1="173" M2="173" P1="22640.11,470.1" P2="22640.11,471.1"/><JD c="000000,6,1,0" M1="174" M2="174" P1="24220.11,140.1" P2="24220.11,141.1"/><JD c="000000,6,1,0" M1="175" M2="175" P1="25190.11,250.1" P2="25190.11,251.1"/><JD c="000000,6,1,0" M1="176" M2="176" P1="26350.11,390.1" P2="26350.11,391.1"/><JD c="000000,6,1,0" M1="177" M2="177" P1="23400.11,240.1" P2="23400.11,241.1"/><JD c="5c94fc,6,1,0" M1="178" M2="178" P1="12910.11,480.1" P2="12910.11,481.1"/><JD c="5c94fc,6,1,0" M1="179" M2="179" P1="14050.11,200.1" P2="14050.11,201.1"/><JD c="5c94fc,6,1,0" M1="180" M2="180" P1="14280.11,200.1" P2="14280.11,201.1"/><JD c="5c94fc,6,1,0" M1="181" M2="181" P1="11419.11,173.1" P2="11419.11,174.1"/><JD c="000000,6,1,0" M1="182" M2="182" P1="21259.11,473.1" P2="21259.11,474.1"/><JD c="000000,6,1,0" M1="183" M2="183" P1="21089.11,243.1" P2="21089.11,244.1"/><JD c="000000,6,1,0" M1="184" M2="184" P1="21319.11,182.1" P2="21319.11,183.1"/><JD c="000000,6,1,0" M1="185" M2="185" P1="22589.11,263.1" P2="22589.11,264.1"/><JD c="000000,6,1,0" M1="186" M2="186" P1="25409.11,213.1" P2="25409.11,214.1"/><JD c="000000,6,1,0" M1="187" M2="187" P1="26569.11,363.1" P2="26569.11,364.1"/><JD c="5c94fc,6,1,0" M1="188" M2="188" P1="11059.11,473.1" P2="11059.11,474.1"/><JD c="c84c0c,6,1,0" M1="189" M2="189" P1="4619.11,472.1" P2="4619.11,473.1"/><JD c="5c94fc,6,1,0" M1="190" M2="190" P1="3809.11,552.1" P2="3809.11,553.1"/><JD c="5c94fc,6,1,0" M1="191" M2="191" P1="2019.11,542.1" P2="2019.11,543.1"/><JD c="5c94fc,6,1,0" M1="192" M2="192" P1="4019.11,522.1" P2="4019.11,523.1"/><JD c="5c94fc,6,1,0" M1="193" M2="193" P1="6449.11,222.1" P2="6449.11,223.1"/><JD c="5c94fc,6,1,0" M1="194" M2="194" P1="14530.11,200.1" P2="14530.11,201.1"/><JD c="5c94fc,6,1,0" M1="195" M2="195" P1="14290.11,500.1" P2="14290.11,501.1"/><JD c="5c94fc,6,1,0" M1="196" M2="196" P1="14930.11,200.1" P2="14930.11,201.1"/><JP M1="54" AXIS="-1,0"/><JP M1="66" AXIS="-1,0"/><JP M1="67" AXIS="-1,0"/><JP M1="68" AXIS="-1,0"/><JP M1="55" AXIS="-1,0"/><JP M1="69" AXIS="-1,0"/><JP M1="70" AXIS="-1,0"/><JP M1="56" AXIS="-1,0"/><JP M1="71" AXIS="-1,0"/><JP M1="72" AXIS="-1,0"/><JP M1="75" AXIS="-1,0"/><JP M1="92" AXIS="-1,0"/><JR M2="139" P1="3814,254" MV="Infinity,0.78"/><JD M1="1" M2="54"/><JD M1="1" M2="66"/><JD M1="1" M2="67"/><JD M1="1" M2="68"/><JD M1="1" M2="55"/><JD M1="1" M2="69"/><JD M1="1" M2="70"/><JD M1="1" M2="71"/><JD M1="1" M2="56"/><JD M1="1" M2="72"/><JD M1="1" M2="75"/><JD M1="1" M2="92"/><JR M2="140" P1="25214.71,247.4" MV="Infinity,0.78"/><JR M2="138" P1="21966.75,218.83" MV="Infinity,0.52"/><JD M1="132" M2="138"/><JD M1="133" M2="139"/><JPL c="fd993c,2,1,0" M1="144" M2="167" P3="2190,128" P4="2380,128"/><JD c="d62700,6,1,0" P1="2190.94,130.11" P2="2190.94,131.11"/><JD c="d62700,6,1,0" P1="2378.41,130.11" P2="2378.41,131.11"/><JPL c="fd993c,2,1,0" M1="154" M2="169" P3="4100,178" P4="4290,178"/><JPL c="fd993c,2,1,0" M1="155" M2="170" P3="3700,248" P4="3890,248"/><JPL c="fd993c,2,1,0" M1="156" M2="171" P3="5300,198" P4="5490,198"/><JPL c="fd993c,2,1,0" M1="163" M2="178" P3="12700,379" P4="12890,379"/><JPL c="fd993c,2,1,0" M1="164" M2="179" P3="13840,99" P4="14030,99"/><JD c="d62700,6,1,0" P1="5300.94,200.11" P2="5300.94,201.11"/><JPL c="fd993c,2,1,0" M1="165" M2="195" P3="14080,399" P4="14270,399"/><JD c="d62700,6,1,0" P1="5488.41,200.11" P2="5488.41,201.11"/><JPL c="fd993c,2,1,0" M1="166" M2="196" P3="14720,99" P4="14910,99"/><JD c="5F5B5A,6,1,0" P1="21560.94,51.11" P2="21560.94,52.11"/><JD c="5F5B5A,6,1,0" P1="22430.94,371.11" P2="22430.94,372.11"/><JD c="5F5B5A,6,1,0" P1="24010.94,41.11" P2="24010.94,42.11"/><JD c="5F5B5A,6,1,0" P1="24980.94,151.11" P2="24980.94,152.11"/><JD c="5F5B5A,6,1,0" P1="26140.94,291.11" P2="26140.94,292.11"/><JD c="5F5B5A,6,1,0" P1="23190.94,141.11" P2="23190.94,142.11"/><JD c="d62700,6,1,0" P1="12700.94,381.11" P2="12700.94,382.11"/><JD c="d62700,6,1,0" P1="12888.41,381.11" P2="12888.41,382.11"/><JD c="d62700,6,1,0" P1="13840.94,101.11" P2="13840.94,102.11"/><JD c="d62700,6,1,0" P1="14028.41,101.11" P2="14028.41,102.11"/><JD c="d62700,6,1,0" P1="4597.41,373.11" P2="4597.41,374.11"/><JD c="d62700,6,1,0" P1="3787.41,453.11" P2="3787.41,454.11"/><JD c="d62700,6,1,0" P1="3997.41,423.11" P2="3997.41,424.11"/><JD c="d62700,6,1,0" P1="6427.41,123.11" P2="6427.41,124.11"/><JD c="d62700,6,1,0" P1="4100.94,180.11" P2="4100.94,181.11"/><JD c="d62700,6,1,0" P1="3700.94,250.11" P2="3700.94,251.11"/><JD c="5F5B5A,6,1,0" P1="21748.41,51.11" P2="21748.41,52.11"/><JD c="5F5B5A,6,1,0" P1="22618.41,371.11" P2="22618.41,372.11"/><JD c="5F5B5A,6,1,0" P1="24198.41,41.11" P2="24198.41,42.11"/><JD c="5F5B5A,6,1,0" P1="25168.41,151.11" P2="25168.41,152.11"/><JD c="5F5B5A,6,1,0" P1="26328.41,291.11" P2="26328.41,292.11"/><JD c="5F5B5A,6,1,0" P1="23378.41,141.11" P2="23378.41,142.11"/><JD c="d62700,6,1,0" P1="14080.94,401.11" P2="14080.94,402.11"/><JD c="d62700,6,1,0" P1="4288.41,180.11" P2="4288.41,181.11"/><JD c="d62700,6,1,0" P1="3888.41,250.11" P2="3888.41,251.11"/><JD c="d62700,6,1,0" P1="14720.94,101.11" P2="14720.94,102.11"/><JD c="d62700,6,1,0" P1="14268.41,401.11" P2="14268.41,402.11"/><JD c="d62700,6,1,0" P1="14908.41,101.11" P2="14908.41,102.11"/><JPL c="fd993c,2,1,0" M1="153" M2="168" P3="3330,428" P4="3520,428"/><JD c="d62700,6,1,0" P1="3330.94,430.11" P2="3330.94,431.11"/><JD c="d62700,6,1,0" P1="3518.41,430.11" P2="3518.41,431.11"/><JP M1="153" AXIS="0,1"/><JP M1="168" AXIS="0,1"/><JP M1="155" AXIS="0,1"/><JP M1="170" AXIS="0,1"/><JP M1="154" AXIS="0,1"/><JP M1="169" AXIS="0,1"/><JP M1="156" AXIS="0,1"/><JP M1="171" AXIS="0,1"/><JP M1="157" AXIS="0,1"/><JP M1="172" AXIS="0,1"/><JP M1="163" AXIS="0,1"/><JP M1="178" AXIS="0,1"/><JP M1="164" AXIS="0,1"/><JP M1="179" AXIS="0,1"/><JP M1="165" AXIS="0,1"/><JP M1="195" AXIS="0,1"/><JP M1="166" AXIS="0,1"/><JP M1="196" AXIS="0,1"/><JD c="fd993c,2,1,0" M1="180" P2="14259,103.1"/><JD c="d62700,6,1,0" P1="14258.41,101.11" P2="14258.41,102.11"/><JD c="fd993c,2,1,0" M1="181" P2="11398,76.1"/><JD c="fd993c,2,1,0" M1="188" P2="11038,376.1"/><JD c="fd993c,2,1,0" M1="189" P2="4598,375.1"/><JD c="fd993c,2,1,0" M1="190" P2="3788,455.1"/><JD c="fd993c,2,1,0" M1="191" P2="1998,445.1"/><JD c="fd993c,2,1,0" M1="192" P2="3998,425.1"/><JD c="fd993c,2,1,0" M1="193" P2="6428,125.1"/><JD c="fd993c,2,1,0" M1="194" P2="14509,103.1"/><JP M1="144" AXIS="0,1"/><JD c="d62700,6,1,0" P1="11397.41,74.11" P2="11397.41,75.11"/><JD c="5E5E5E,6,1,0" P1="21238.41,374.11" P2="21238.41,375.11"/><JD c="5E5E5E,6,1,0" P1="21068.41,144.11" P2="21068.41,145.11"/><JD c="5E5E5E,6,1,0" P1="21298.41,83.11" P2="21298.41,84.11"/><JD c="5E5E5E,6,1,0" P1="22568.41,164.11" P2="22568.41,165.11"/><JD c="5E5E5E,6,1,0" P1="25388.41,114.11" P2="25388.41,115.11"/><JD c="5E5E5E,6,1,0" P1="26548.41,264.11" P2="26548.41,265.11"/><JP M1="167" AXIS="0,1"/><JP M1="1" AXIS="-1,0"/><JD c="5c94fc,36,1,0" P1="13682.69,217.99" P2="13682.69,218.99"/><JD c="d62700,6,1,0" P1="11037.41,375.11" P2="11037.41,376.11"/><JD c="d62700,6,1,0" P1="14508.41,101.11" P2="14508.41,102.11"/><JP M1="76" AXIS="-1,0"/><JP M1="77" AXIS="-1,0"/><JP M1="78" AXIS="-1,0"/><JP M1="79" AXIS="-1,0"/><JP M1="80" AXIS="-1,0"/><JP M1="83" AXIS="-1,0"/><JP M1="84" AXIS="-1,0"/><JP M1="81" AXIS="-1,0"/><JP M1="82" AXIS="-1,0"/><JP M1="85" AXIS="-1,0"/><JP M1="86" AXIS="-1,0"/><JP M1="57" AXIS="-1,0"/><JP M1="58" AXIS="-1,0"/><JP M1="59" AXIS="-1,0"/><JP M1="87" AXIS="-1,0"/><JP M1="88" AXIS="-1,0"/><JP M1="89" AXIS="-1,0"/><JP M1="90" AXIS="-1,0"/><JP M1="91" AXIS="-1,0"/><JP M1="60" AXIS="-1,0"/><JR M1="60" M2="99"/><JR M1="91" M2="130"/><JR M1="90" M2="129"/><JR M1="89" M2="128"/><JR M1="88" M2="127"/><JR M1="87" M2="126"/><JR M1="59" M2="98"/><JR M1="58" M2="97"/><JD c="d62700,6,1,0" P1="1997.41,443.11" P2="1997.41,444.11"/><JR M1="57" M2="96"/><JR M1="86" M2="125"/><JR M1="85" M2="124"/><JR M1="82" M2="121"/><JR M1="81" M2="120"/><JR M1="80" M2="119"/><JR M1="83" M2="122"/><JR M1="84" M2="123"/><JR M1="79" M2="118"/><JR M1="78" M2="117"/><JR M1="77" M2="116"/><JR M1="76" M2="115"/><JD M1="1" M2="76"/><JD M1="1" M2="78"/><JD M1="1" M2="79"/><JD M1="1" M2="77"/><JD M1="1" M2="80"/><JD M1="1" M2="83"/><JD M1="1" M2="84"/><JD M1="1" M2="81"/><JD M1="1" M2="82"/><JD M1="1" M2="85"/><JD M1="1" M2="86"/><JD M1="1" M2="57"/><JD M1="1" M2="58"/><JD M1="1" M2="59"/><JD M1="1" M2="87"/><JD M1="1" M2="88"/><JD M1="1" M2="89"/><JD M1="1" M2="90"/><JD M1="1" M2="91"/><JD M1="1" M2="60"/><JD M1="134" M2="140"/><JR M2="143" P1="14345.15,265.45" MV="Infinity,0.52"/><JD M1="137" M2="143"/><JR M2="142" P1="12853.69,345.12" MV="Infinity,0.78"/><JD M1="136" M2="142"/><JP M1="158" AXIS="0,1"/><JP M1="173" AXIS="0,1"/><JP M1="159" AXIS="0,1"/><JP M1="174" AXIS="0,1"/><JP M1="162" AXIS="0,1"/><JP M1="177" AXIS="0,1"/><JR M2="152" P1="22070,104.67" LIM1="-0.78" LIM2="0.78"/><JP M1="160" AXIS="0,1"/><JP M1="175" AXIS="0,1"/><JP M1="161" AXIS="0,1"/><JP M1="176" AXIS="0,1"/><JR M1="73" M2="112"/><JR M1="113" M2="74"/><JP M1="73" AXIS="-1,0"/><JP M1="74" AXIS="-1,0"/><JD M1="1" M2="73"/><JD M1="1" M2="74"/><JD M1="141" M2="135"/><JR M2="141" P1="26283.36,313.99" MV="Infinity,0.52"/></L></Z></C>]]
level_spawns = {}	-- bstore the level spawns locations
-- level spawns coordinates:
table.insert(level_spawns, {x = 105, y = 515})		-- level 1
table.insert(level_spawns, {x = 10105, y = 515})	-- level 2
table.insert(level_spawns, {x = 20105, y = 515})	-- level 3
-- bonus points coordinates:
coins = {{x = 1435, y = 475}, {x = 1560, y = 305}, {x = 1645, y = 305}, {x = 2000, y = 515}, {x = 2190, y = 200}, {x = 2380, y = 200}, {x = 3000, y = 260}, {x = 3790, y = 405}, {x = 3960, y = 200}, {x = 4500, y = 260}, {x = 4750, y = 260}, {x = 4600, y = 450}, {x = 5020, y = 345}, {x = 5090, y = 345}, {x = 5190, y = 510}, {x = 5300, y = 275}, {x = 5490, y = 275}, {x = 5580, y = 515}, {x = 6125, y = 175}, {x = 6430, y = 195}, {x = 11330, y = 345}, {x = 11630, y = 130}, {x = 12145, y = 345}, {x = 12390, y = 210}, {x = 12700, y = 450}, {x = 12890, y = 450}, {x = 13220, y = 85}, {x = 13260, y = 85}, {x = 13300, y = 85}, {x = 14145, y = 110}, {x = 14385, y = 110}, {x = 14625, y = 110}, {x = 14480, y = 430}, {x = 14520, y = 430}, {x = 15275, y = 215}, {x = 15530, y = 515}, {x = 21355, y = 345}, {x = 21475, y = 345}, {x = 21380, y = 90}, {x = 21420, y = 90}, {x = 21460, y = 90}, {x = 21630, y = 520}, {x = 21670, y = 520}, {x = 21870, y = 110}, {x = 21910, y = 110}, {x = 22180, y = 110}, {x = 22220, y = 110}, {x = 22185, y = 435}, {x = 23190, y = 215}, {x = 23380, y = 215}, {x = 23325, y = 435}, {x = 23665, y = 90}, {x = 23705, y = 90}, {x = 23745, y = 90}, {x = 23695, y = 390}, {x = 23805, y = 390}, {x = 24105, y = 120}, {x = 24050, y = 515}, {x = 24480, y = 515}, {x = 24700, y = 345}, {x = 25315, y = 515}, {x = 25355, y = 515}, {x = 25675, y = 175}, {x = 25715, y = 175}, {x = 25755, y = 175}, {x = 26547, y = 335}, {x = 26705, y = 175}, {x = 26745, y = 175}, {x = 26785, y = 175}, {x = 26705, y = 135}, {x = 26745, y = 135}, {x = 26785, y = 135}, {x = 26705, y = 95}, {x = 26745, y = 95}, {x = 26785, y = 95}, {x = 29900, y = 383}, {x = 29977, y = 383}, {x = 30071, y = 383}, {x = 30150, y = 383}, {x = 29950, y = 317}, {x = 30030, y = 317}, {x = 30110, y = 317}, {x = 29990, y = 255}, {x = 30075, y = 255}, {x = 30030, y = 200}, {x = 32400, y = 160}, {x = 32360, y = 215}, {x = 32445, y = 215}, {x = 32320, y = 277}, {x = 32400, y = 277}, {x = 32480, y = 277}, {x = 32270, y = 343}, {x = 32347, y = 343}, {x = 32441, y = 343}, {x = 32520, y = 343}, {x = 32301, y = 441}, {x = 32370, y = 441}, {x = 32430, y = 441}, {x = 32500, y = 441}, {x = 25075, y = 235}}
--- lua images
images = {}
table.insert(images, {image = "17aa53194f5.png", target = "?0", x = 0, y = 0}) -- map level 1
table.insert(images, {image = "17aa531bc08.png", target = "?0", x = 10000, y = 0}) --map level 2
table.insert(images, {image = "17aa533f78b.png", target = "?0", x = 20000, y = 0}) --map level 3
table.insert(images, {image = "17aa5310c51.png", target = "?0", x = 29700, y = 0}) --coin room 1
table.insert(images, {image = "17aa530fcb0.png", target = "?0", x = 32100, y = 60}) --coin room 2
table.insert(images, {image = "17aa530b65a.png", target = "!0", x = 2587, y = 447}) --pipe1
table.insert(images, {image = "17aa530b65a.png", target = "!0", x = 3339, y = 147}) --pipe2
table.insert(images, {image = "17aa530b65a.png", target = "!0", x = 11846, y = 404}) --pipe3
table.insert(images, {image = "17aa530b65a.png", target = "!0", x = 13050, y = 448}) --pipe4
table.insert(images, {image = "17aa557ec41.png", target = "!0", x = 30251, y = 443}) --coin room pipe1
table.insert(images, {image = "17aa557ec41.png", target = "!0", x = 32652, y = 444}) --copin room pipe2
arbitrary_help_btn_id = 17
-- Internal Use:
pshy.players = pshy.players or {}
count = 0
--- Create a player's game infos, or handle a joining back player.
function TouchPlayer(player_name)
	pshy.players[player_name] = pshy.players[player_name] or {}
	local player = pshy.players[player_name]
	if not player.mario_level then
		player.mario_level = 1
		player.mario_max_level = 1
		--ResetPlayerCoins(player_name)
		-- or
		--SpawnPlayerCoins(player_name)
	end
	local new_spawn = level_spawns[player.mario_level]
	pshy.checkpoints_SetPlayerCheckpoint(player_name, new_spawn.x, new_spawn.y)
	BindPlayerKeys(player_name)
	ui.addTextArea(arbitrary_help_btn_id, "<p align='center'><font size='12'><a href='event:pcmd help mario'>help</a></font></p>", player_name, 5, 25, 40, 20, 0x111111, 0xFFFF00, 0.2, true)
	tfm.exec.setNameColor(player_name, player.mario_name_color)
end
--- Bind the keys used by this module for a player.
function BindPlayerKeys(player_name)
	tfm.exec.bindKeyboard(player_name, 0, false, true)
	tfm.exec.bindKeyboard(player_name, 1, false, true)
	tfm.exec.bindKeyboard(player_name, 2, false, true)
	tfm.exec.bindKeyboard(player_name, 0, true, true)
    tfm.exec.bindKeyboard(player_name, 1, true, true)
	tfm.exec.bindKeyboard(player_name, 2, true, true)
	tfm.exec.bindKeyboard(player_name, 3, true, true)
	tfm.exec.bindKeyboard(player_name, 32, true, true)
end
--- Unspawn coins for a player, but remember their state.
--function UnspawnPlayerCoins(player_name)
--	local player = pshy.players[player_name]
--	local player_coins = player.unobtained_coins
--	for i_coin in pairs(player_coins) do
--		if player_coins[i_coin] ~= true then
--			tfm.exec.removeBonus(i_coin, player_name)
--			tfm.exec.removeImage(player_coins[i_coin])
--		end
--	end
--end
--- Spawn coins a player have not yet obtained.
--function SpawnPlayerCoins(player_name)
--	UnspawnPlayerCoins(player_name)
--	local player = pshy.players[player_name]
--	local player_coins = player.unobtained_coins
--	for i_coin in pairs(player.unobtained_coins) do
--		local coin = coins[i_coin]
--		tfm.exec.addBonus(0, coin.x, coin.y, i_coin, 0, false, player_name)
--		player_coins[i_coin] = tfm.exec.addImage("17aa6f22c53.png", "?226", coin.x - 15, coin.y - 20, player_name)
--	end
--end
--- Reset Coins for a player.
local function ResetPlayerCoins(player_name)
	--local player = pshy.players[player_name]
	--local player_coins = player.unobtained_coins
	-- unspawn coins
	--for i_coin, point in pairs(coins) do
	--	tfm.exec.removeBonus(i_coin, player_name)
	--	if player_coins[i_coin] then
	--		tfm.exec.removeImage(player_coins[i_coin])
	--		player_coins[i_coin] = nil
	--	end
	--end
	-- spawn coins
	--for i_coin, point in pairs(coins) do
	--	tfm.exec.addBonus(0, point.x, point.y, i_coin, 0, false, player_name)
	--	player_coins[i_coin] = tfm.exec.addImage("17aa6f22c53.png", "?226", point.x - 15, point.y - 20, player_name)
	--end
	local player = pshy.players[player_name]
	for i_bonus, bonus in pairs(pshy.bonuses_list) do
		if bonus.type == "MarioCoin" then
			pshy.bonuses_Enable(bonus.id, player_name)
		end
	end
end
--- TFM event eventNewGame
function eventNewGame()
	-- update ui
	ui.setMapName(map_name)
	ui.setShamanName(shaman_name)
	-- spawn images for everybody
	for i_image, image in pairs(images) do
		tfm.exec.addImage(image.image, image.target, image.x, image.y)
	end
	-- reset coins for all players
	for i_coin, coin in ipairs(coins) do
		pshy.bonuses_Add("MarioCoin", coin.x, coin.y)
	end
	--for player_name in pairs(tfm.get.room.playerList) do
	--	ResetPlayerCoins(player_name)
	--end
	-- add the flower bonus to last level
	pshy.bonuses_Add("MarioFlower", 25542, 442)
	-- checkpoints
	for player_name in pairs(tfm.get.room.playerList) do
		local player = pshy.players[player_name]
		assert(player ~= nil, "player was nil")
		assert(player.mario_level ~= nil, "player.mario_level was nil")
		local new_spawn = level_spawns[player.mario_level]
		pshy.checkpoints_SetPlayerCheckpoint(player_name, new_spawn.x, new_spawn.y)
	end
end
--- TFM event eventNewPlayer
function eventNewPlayer(player_name)
	TouchPlayer(player_name)
	-- spawn images for that new player
	for i_image, image in pairs(images) do
		tfm.exec.addImage(image.image, image.target, image.x, image.y, player_name)
	end
	-- reset ui
	ui.setMapName(map_name)
	ui.setShamanName(shaman_name)
	-- respawn player
	tfm.exec.respawnPlayer(player_name)
end
--- TFM event eventPlayerLeft
--function eventPlayerleft(player_name)
--	UnspawnPlayerCoins(player_name)
--end
--- TFM event eventPlayerDied
--function eventPlayerDied(player_name)
--	tfm.exec.respawnPlayer(player_name)
--end
--- TFM event eventLoop
-- summoning the cannonballs
function eventLoop(time, remaining)
    count = count + 1
    if not bool and time >= 1500 then
        if count > 5 then
        	tfm.exec.addShamanObject(tfm.enum.shamanObject.cannon, 3030, 255, 270, 100)
        	tfm.exec.addShamanObject(tfm.enum.shamanObject.cannon, 5682, 425, 270, 100)
			tfm.exec.addShamanObject(tfm.enum.shamanObject.cannon, 12412, 210, 270, 100)
            count = 0
        end
    end
    -- reset fire status
    for player_name, player in pairs(pshy.players) do
    	if player.unlocked_powerball and player.shot_powerball < 2.0 then
    		player.shot_powerball = player.shot_powerball + 0.25			-- reset cooldown
    	end
    end
end
--- TFM event eventPlayerWon
-- send the player to the next level when they win
function eventPlayerWon(player_name)
	local player = pshy.players[player_name]
	-- show that
	tfm.exec.chatMessage("<vi>[MARIO] " .. player_name .. " just finished level " .. player.mario_level .. "!</vi>", nil)
	-- next level for that player
	player.mario_level = player.mario_level + 1
	-- if no more levels, return to 1
	if not level_spawns[player.mario_level] then
		player.mario_level = 1
		--player.unlocked_powerball = true
		--tfm.exec.chatMessage("<j>[MARIO] You can now throw powerballs with SPACE!</j>", player_name)
		-- @todo put unlocks here
	end
	-- new max level
	if player.mario_max_level < player.mario_level then
		player.mario_max_level = player.mario_level
	end
	-- next spawn
	new_spawn = level_spawns[player.mario_level]
	pshy.checkpoints_SetPlayerCheckpoint(player_name, new_spawn.x, new_spawn.y, false)
	pshy.checkpoints_PlayerCheckpoint(player_name)
end
--- TFM event eventPlayerRespawn
function eventPlayerRespawn(player_name)
	--ResetPlayerCoins(player_name)
	tfm.exec.setNameColor(player_name, pshy.players[player_name].mario_name_color)
end
--- TFM event eventPlayerBonusGrabbed
function eventPlayerBonusGrabbed(player_name, bonus_id)
	player = pshy.players[player_name]
--	if player.unobtained_coins[bonus_id] then -- may be null if deleted before this is called (caused by eventPlayerScore)
--		-- remove the coin image, then set it as `nil` so we know it no longer exists
--		tfm.exec.removeImage(player.unobtained_coins[bonus_id])
--		player.unobtained_coins[bonus_id] = nil
--	end
	if player.mario_coins > 0 and player.mario_coins % #coins == 0 then
		tfm.exec.chatMessage("<vi>[MARIO] " .. player_name .. " just finished collecting all the " .. tostring(#coins) .. " coins!</vi>", nil)
		ResetPlayerCoins(player_name)
	end
end
--- TFM event eventKeyboard
-- Handle player teleportations for pipes.
function eventKeyboard(name, keyCode, down, xPlayerPosition, yPlayerPosition)
	local player = pshy.players[name]
	--pipe from coin room to up world
	if keyCode==3 then
		if xPlayerPosition >= 2620 and xPlayerPosition <= 2640 and yPlayerPosition >= 415 and yPlayerPosition <= 450 then
			tfm.exec.movePlayer(name,29800,80,false,0,0,false)
		end
		if xPlayerPosition >= 11880 and xPlayerPosition <= 11900 and yPlayerPosition >= 380 and yPlayerPosition <= 400  then
			tfm.exec.movePlayer(name,32185,100  ,false,0,0,false)
		end
	end
	--pipe coin room 2
	if keyCode==0 or keyCode==1 or keyCode==2 then
		if xPlayerPosition >= 32680 and xPlayerPosition <= 32710 and yPlayerPosition >= 495 and yPlayerPosition <= 530 then
			tfm.exec.movePlayer(name,13095,510 ,false,0,0,false)
		end
		if xPlayerPosition >= 32710 and xPlayerPosition <= 32740 and yPlayerPosition >= 490 and yPlayerPosition <= 530 then
			tfm.exec.movePlayer(name,13095,510 ,false,0,0,false)
		end
		--pipe coin room1
		if xPlayerPosition >= 30290 and xPlayerPosition <= 30320 and yPlayerPosition >= 500 and yPlayerPosition <= 540 then
            tfm.exec.movePlayer(name,3383,207 ,false,0,0,false)
		end
		if xPlayerPosition >= 30310 and xPlayerPosition <= 30350 and yPlayerPosition >= 500 and yPlayerPosition <= 540 then
            tfm.exec.movePlayer(name,3383,207 ,false,0,0,false)
		end
	end
	-- powerball
	--if keyCode == 32 and down and player.unlocked_powerball then
	--	if player.shot_powerball >= 1.0 then
	--		if player.powerball_id then
	--			tfm.exec.removeObject(player.powerball_id)
	--		end
	--		local speed = tfm.get.room.playerList[name].isFacingRight and 11 or -11
	--		player.powerball_id = tfm.exec.addShamanObject(player.powerball_type, xPlayerPosition + speed * 2, yPlayerPosition, 0, speed, 0, false)
	--		player.shot_powerball = player.shot_powerball - 1.0
	--		tfm.exec.playEmote(name, tfm.enum.emote.highfive_1, nil)
	--		tfm.exec.displayParticle(tfm.enum.particle.redGlitter, xPlayerPosition + speed * 2, yPlayerPosition, speed * 0.15, -0.15)
	--		tfm.exec.displayParticle(tfm.enum.particle.orangeGlitter, xPlayerPosition + speed * 2, yPlayerPosition, speed * 0.3, 0)
	--		tfm.exec.displayParticle(tfm.enum.particle.redGlitter, xPlayerPosition + speed * 2, yPlayerPosition, speed * 0.4, 0)
	--		tfm.exec.displayParticle(tfm.enum.particle.orangeGlitter, xPlayerPosition + speed * 2, yPlayerPosition, speed * 0.26, 0.15)
	--	end
	--end
end
--- Pshy eventPlayerScore.
function eventPlayerScore(player_name, scored)
	local player = pshy.players[player_name]
	--local current_score = pshy.scores[player_name]
	--if current_score % #coins == 0 then
		--tfm.exec.chatMessage("<vi>[MARIO] " .. player_name .. " just finished collecting all the " .. tostring(#coins) .. " coins!</vi>", nil)
		--ResetPlayerCoins(player_name)
	--end
	-- update player color
	--if current_score == 9 then
	--	pshy.players[player_name].color = 0x6688ff -- blue
	--elseif current_score == 25 then
	--	pshy.players[player_name].color = 0x00eeee -- cyan
	--elseif current_score == 35 then
	--	pshy.players[player_name].color = 0x77ff77 -- green
	--elseif current_score == 55 then
	--	pshy.players[player_name].color = 0xeeee00 -- yellow
	--elseif current_score == 75 then
	--	pshy.players[player_name].color = 0xff7700 -- orange
	--elseif current_score == 100 then
	--	pshy.players[player_name].color = 0xff0000 -- red
	--elseif current_score == 150 then
	--	pshy.players[player_name].color = 0xff00bb -- pink
	--elseif current_score == 200 then
	--	pshy.players[player_name].color = 0xbb00ff -- purple
	--else
	--	return
	--end
	--tfm.exec.setNameColor(player_name, pshy.players[player_name].color)
end
--- !level <name>
function pshy.ChatCommandLevel(user, level)
	if (level < 1 or level > #level_spawns) then
		return false, "No such level."
	end
	local player = pshy.players[user]
	if (level < 1 or level > pshy.players[user].mario_max_level) then
		return false, "You have not unlocked this level."
	end
	player.mario_level = level
	new_spawn = level_spawns[player.mario_level]
	pshy.checkpoints_SetPlayerCheckpoint(user, new_spawn.x, new_spawn.y)
	pshy.checkpoints_PlayerCheckpoint(user)
end
pshy.chat_commands["level"] = {func = pshy.ChatCommandLevel, desc = "go to a level you have already unlocked", argc_min = 1, argc_max = 1, arg_types = {"number"}}
pshy.help_pages["mario"].commands["level"] = pshy.chat_commands["level"]
pshy.chat_command_aliases["l"] = "level"
pshy.perms.everyone["!level"] = true
--- Initialization:
function eventInit()
	tfm.exec.newGame(map_xml)
	-- players
	for player_name, v in pairs(tfm.get.room.playerList) do
		TouchPlayer(player_name)
	end
end
end
new_mod.Content()
pshy.merge_ModuleEnd()
pshy.merge_Finish()

