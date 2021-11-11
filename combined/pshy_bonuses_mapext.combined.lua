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
	new_player.is_facing_right = true
	system.bindKeyboard(player_name, 0, true, true)
	system.bindKeyboard(player_name, 2, true, true)
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
		player.is_facing_right = true
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
	player.is_facing_right = true
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
function eventKeyboard(player_name, keycode, down, x, y)
	if keycode == 0 then
		local player = pshy.players[player_name]
		player.is_facing_right = false
	end
	if keycode == 2 then
		local player = pshy.players[player_name]
		player.is_facing_right = true
	end
end
end
new_mod.Content()
pshy.merge_ModuleEnd()
local new_mod = pshy.merge_ModuleBegin("pshy_xmlmap.lua")
function new_mod.Content()
--- pshy_xmlmap.lua
--
-- Parse the map's xml into a tree.
-- `pshy.xm`
-- Every markup has a `type` string field,
-- as well as a `properties` and a `childs` table.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @require pshy_utils_lua.lua
pshy = pshy or {}
--- Parsed map output.
--
-- This represent a tree of markups such as every markup has the folowing fields:
--	- `type`		- the type of the markup
--	- `properties`	- a table of properties in the markup
--	- `childs`		- a list of markups that are childs of this one
--
-- The first item in the list is the "C" type markup (representing the map).
--
-- @public
pshy.xmlmap = nil
--- Get an array of strings contained the markups from an xml string.
local function GetMarkupStringContents(xml)
	-- split markups
	local markups = pshy.StrSplit(xml, ">")
	for i_content, content in ipairs(markups) do
		if #content == 0 then
			markups[i_content] = nil
			break
		end
		assert(string.sub(content, 1, 1) == "<", "malformed xml map?")
		markups[i_content] = string.sub(content, 2, #content)
	end
	return markups
end
--- Update the `pshy.xmlmap` table.
function pshy.xmlmap_Update()
	pshy.xmlmap = nil
	if not tfm.get.room.xmlMapInfo then
		return
	end
	local xml = tfm.get.room.xmlMapInfo.xml
	if not xml then
		return
	end
	start_time = os.time()
	local markups = GetMarkupStringContents(xml)
	print("A took " .. tostring(os.time() - start_time))
	start_time = os.time()
	-- convert to (type + properties/values) | closing
	local types = {}
	for i_markup, content in ipairs(markups) do
		local markup = {}
		markup.properties = {}
		if string.sub(content, 1, 1) == "/" then
			-- closing markup
			markup.closing = true
			content = string.sub(content, 2, #content)
			markup.type = content
		else
			if string.sub(content, #content, #content) == "/" then
				-- self-closing markup
				markup.self_closing = true
				content = string.sub(content, 1, #content - 1)
			end
			markup._fields = pshy.StrSplit(content, " ")
		end
		markups[i_markup] = markup
	end
	print("B took " .. tostring(os.time() - start_time) .. " for #markups " .. tostring(#markups))
	start_time = os.time()
	for i_markup, markup in ipairs(markups) do
		if markup._fields then
			local fields = markup._fields
			-- markup's type
			markup.type = fields[1]
			-- markup's fields (properties)
			for i_field, field in ipairs(fields) do
				if i_field > 1 and #field > 0 then
					local pnameandvalue = pshy.StrSplit(field, "=", 2)
					-- @todo: it looks like vanilla asserts are slow
					assert(#pnameandvalue[1] > 0, "malformed xml (empty property name)?")
					assert(string.sub(pnameandvalue[2], 1, 1) == "\"", "malformed xml (property's first quote)?")
					assert(string.sub(pnameandvalue[2], #pnameandvalue[2], #pnameandvalue[2]) == "\"", "malformed xml (property's last quote)?")
					markup.properties[pnameandvalue[1]] = string.sub(pnameandvalue[2], 2, #pnameandvalue[2] - 1)
				end
			end
		end
	end
	print("C took " .. tostring(os.time() - start_time) .. " for #markups " .. tostring(#markups))
	start_time = os.time()
	-- create the xml tree (and fill 'parent' and 'childs')
	local tree = {}
	local focus = tree
	for i_markup, markup in ipairs(markups) do
		markup.parent = focus
		--print(markup.type .. tostring(markup.closing) .. " " .. tostring(markup.self_closing))
		if markup.closing then
			assert(markup.type == focus.type, "malformed xml (closed a non-open makup)?")
			focus = focus.parent
		else
			if markup.parent == tree then
				table.insert(markup.parent, markup)
			else
				table.insert(markup.parent.childs, markup)
			end
			if not markup.self_closing then
				focus = markup
				markup.childs = {}
			end
		end
	end
	assert(focus == tree, "malformed xml (partial tree)?")
	print("D took " .. tostring(os.time() - start_time))
	-- all done ;>
	assert(tree[1].type == "C")
	pshy.xmlmap = tree[1]
end
--- Get the xml node corresponding to grounds.
function pshy.xmlmap_GetGroundNode()
	if not pshy.xmlmap then
		return nil
	end
	for i_child, child in ipairs(pshy.xmlmap.childs) do
		if child.childs then
			if child.type == "Z" then
				if child.childs then
					for i_child, child in ipairs(child.childs) do
						if child.type == "S" then
							return child
						end
					end
				end
			end
		end
	end
end
-- TFM event eventNewGame.
function eventNewGame()
	pshy.xmlmap_Update()
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
	assert(type(rotation.items) == "table", "rotation table had no item")
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
local new_mod = pshy.merge_ModuleBegin("pshy_misc_bonuses.lua")
function new_mod.Content()
--- pshy_misc_bonuses.lua
--
-- Custom bonuses list (advanced list, contains bonuses that dont look like ones).
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @require pshy_checkpoints.lua
-- @require pshy_speedfly.lua
-- @require pshy_bonuses.lua
-- @require pshy_imagedb.lua
--- MouseTrap.
-- Same as BonusCheese but with a mouse trap image and a little board, and shared.
function pshy.bonuses_callback_MouseTrap(player_name, bonus)
	tfm.exec.killPlayer(player_name)
	tfm.exec.displayParticle(tfm.enum.particle.yellowGlitter, bonus.x, bonus.y, -2, -6.8, 0, 1, nil)
	tfm.exec.displayParticle(tfm.enum.particle.yellowGlitter, bonus.x, bonus.y, -1, -7, 0, 1, nil)
	tfm.exec.displayParticle(tfm.enum.particle.yellowGlitter, bonus.x, bonus.y, 0, -7.1, 0, 1, nil)
	tfm.exec.displayParticle(tfm.enum.particle.yellowGlitter, bonus.x, bonus.y, 1, -7, 0, 1, nil)
	tfm.exec.displayParticle(tfm.enum.particle.yellowGlitter, bonus.x, bonus.y, 2, -6.8, 0, 1, nil)
	local obj_id = tfm.exec.addShamanObject(tfm.enum.shamanObject.tinyBoard, bonus.x, bonus.y, angle, 1, -4, false)
	-- TODO: use a mouse trap image:
	pshy.imagedb_AddImage("17bf4b7ddd6.png", "#" .. tostring(obj_id), 0, 0, nil, nil, nil, 0.0, 1.0)
end
pshy.bonuses_types["MouseTrap"] = {image = "17bf4b7a091.png", func = pshy.bonuses_callback_MouseTrap, shared = true}
--- GoreDeath.
-- This bonus is invisible.
-- Cause the mouse to explode into blood.
function pshy.bonuses_callback_GoreDeath(player_name, bonus)
	tfm.exec.movePlayer(player_name, bonus.x, bonus.y + 10000, false, 0, 0, false)
	tfm.exec.killPlayer(player_name)
	local redConfetti = tfm.enum.particle.redConfetti
	local redGlitter = tfm.enum.particle.redGlitter
	local blood_patches = {{-2.5, -4}, {-1, -5}, {0, -7}, {1, -6}, {2.5, -4}, {0.5, -4}, {-1.5, -4.5}}
	local rnx = math.random(0, 100) / 100
	local rny = math.random(0, 100) / 100
	for i_patch, patch in ipairs(blood_patches) do
		tfm.exec.displayParticle(redConfetti, bonus.x + 1, bonus.y + 2, patch[1] + 0.1 + rnx, patch[2] + 0.2 + rny, 0, 0.3, nil)
		tfm.exec.displayParticle(redConfetti, bonus.x + 2, bonus.y + 1, patch[1] + 0.3 + rnx, patch[2] + 0.0 + rny, 0, 0.3, nil)
		tfm.exec.displayParticle(redConfetti, bonus.x + 3, bonus.y + 2, patch[1] + 0.0 + rnx, patch[2] + 0.4 + rny, 0, 0.3, nil)
		tfm.exec.displayParticle(redConfetti, bonus.x + 2, bonus.y + 1, patch[1] + 0.2 + rnx, patch[2] + 0.1 + rny, 0, 0.3, nil)
		tfm.exec.displayParticle(redConfetti, bonus.x + 1, bonus.y + 2, patch[1] + 0.0 + rnx, patch[2] + 0.2 + rny, 0, 0.3, nil)
	end
end
pshy.bonuses_types["GoreDeath"] = {image = nil, func = pshy.bonuses_callback_GoreDeath, remain = true}
--- Cheese.
-- Act like a cheese.
function pshy.bonuses_callback_Cheese(player_name, bonus)
	if tfm.get.room.playerList[player_name].hasCheese then
		return false
	end
	tfm.exec.giveCheese(player_name)
end
pshy.bonuses_types["Cheese"] = {image = "155592fd7d0.png", func = pshy.bonuses_callback_Cheese, remain = true}
--- Hole.
-- Act like an hole.
function pshy.bonuses_callback_Hole(player_name, bonus)
	if not tfm.get.room.playerList[player_name].isDead then
		return false
	end
	tfm.exec.playerVictory(player_name)
end
pshy.bonuses_types["Hole"] = {image = "17cc269a03d.png", func = pshy.bonuses_callback_Hole, remain = true}
--- PickableCheese.
-- If a player take the cheese then others cant pick it.
function pshy.bonuses_callback_PickableCheese(player_name, bonus)
	if tfm.get.room.playerList[player_name].hasCheese then
		return false
	end
	tfm.exec.giveCheese(player_name)
end
pshy.bonuses_types["PickableCheese"] = {image = "155592fd7d0.png", func = pshy.bonuses_callback_PickableCheese, shared = true}
--- CorrectCheese.
-- Like a normal cheeze but congrats the player.
function pshy.bonuses_callback_CorrectCheese(player_name, bonus)
	tfm.exec.giveCheese(player_name)
	--pshy.imagedb_AddImage("155592fd7d0.png", "!0", bonus.x, bonus.y, player_name, nil, nil, 0.0, 1.0)
	pshy.imagedb_AddImage("17bf4f3f2fb.png", "!0", bonus.x, bonus.y, player_name, nil, nil, 0.0, 1.0)
end
pshy.bonuses_types["CorrectCheese"] = {image = "155592fd7d0.png", func = pshy.bonuses_callback_CorrectCheese}
--- WrongCheese.
-- Like a normal cheeze but kills the player.
function pshy.bonuses_callback_WrongCheese(player_name, bonus)
	tfm.exec.killPlayer(player_name)
	--pshy.imagedb_AddImage("155593003fc.png", "!0", bonus.x, bonus.y, player_name, nil, nil, 0.0, 1.0)
	pshy.imagedb_AddImage("17bf4b89eba.png", "!0", bonus.x, bonus.y, player_name, nil, nil, 0.0, 1.0)
end
pshy.bonuses_types["WrongCheese"] = {image = "155592fd7d0.png", func = pshy.bonuses_callback_WrongCheese}
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
-- @require pshy_bonuses.lua
-- @require pshy_checkpoints.lua
-- @require pshy_imagedb.lua
-- @require pshy_players.lua
-- @require pshy_speedfly.lua
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
			local speed = player.is_facing_right and 11 or -11
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
local new_mod = pshy.merge_ModuleBegin("pshy_mapdb.lua")
function new_mod.Content()
--- pshy_mapdb.lua
--
-- Handle advanced map features and rotations.
-- Override `tfm.exec.newGame` for easy usage.
--
-- Adds an event `eventGameEnded`, called just before a map change.
--
-- This script may list maps from other authors.
--
-- Listed map and rotation tables can have the folowing fields:
--	- begin_func: Function to run when the map started.
--	- end_func: Function to run when the map stopped.
--	- replace_func: Function to run on the map's xml (or name if not present) that is supposed to return the final xml.
--	- autoskip: If true, the map will change at the end of the timer.
--	- duration: Duration of the map.
--	- shamans: Count of shamans (Currently, only 0 is supported to disable the shaman).
--	- xml (maps only): The true map's xml code.
--	- hidden (rotations only): Do not show the rotation is being used to players.
--	- modules: list of module names to enable while the map is playing (to trigger events).
--	- troll: bool telling if the rotation itself is a troll (may help other modules about how to handle the rotation).
--	- unique_items: bool telling if the items are supposed to be unique (duplicates are removed on eventInit).
--
-- @author: TFM:Pshy#3752 DC:Pshy#7998 (script)
-- @require pshy_commands.lua
-- @require pshy_help.lua
-- @require pshy_rotation.lua
-- @require pshy_bonuses.lua
--- Module Help Page:
pshy.help_pages["pshy_mapdb"] = {back = "pshy", title = "Maps / Rotations", text = "Use /info to know who made the current map.\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_mapdb"] = pshy.help_pages["pshy_mapdb"]
--- Module Settings:
pshy.mapdb_default = "default"				-- default rotation, can be a rotation of rotations
pshy.mapdb_maps = {}						-- map of maps
pshy.mapdb_rotations = {}					-- map of rotations
pshy.mapdb_rotations["default"]				= {hidden = true, items = {"vanilla", "vanilla", "vanilla", "vanilla", "protected", "art", "nosham", "racing"}}					-- default rotation, can only use other rotations, no maps
pshy.mapdb_default_rotation 				= pshy.mapdb_rotations["default"]				--
--- Custom maps:
-- Shaman no objects
pshy.mapdb_maps["v0_noskills"]				= {xml = [[<C><P shaman_tools="33,63,65,80,89,95" F="0" /><Z><S><S H="50" L="800" Y="378" X="400" P="0,0,0.3,0.2,0,0,0,0" T="6" /><S H="40" L="120" Y="173" X="541" P="0,0,0.3,0.2,0,0,0,0" T="6" /><S H="27" L="35" Y="482" X="254" P="0,0,0.3,0.2,90,0,0,0" T="6" /></S><D><P X="542" P="0,1" T="12" Y="353" /><P X="49" P="1,0" T="0" Y="355" /><T X="120" Y="356" /><P X="228" P="0,0" T="3" Y="355" /><P X="249" P="0,0" T="11" Y="354" /><P X="296" P="0,1" T="11" Y="353" /><P X="311" P="0,0" T="3" Y="354" /><P X="729" P="0,0" T="11" Y="353" /><P X="672" P="0,1" T="3" Y="356" /><P X="283" P="0,0" T="3" Y="353" /><P X="273" P="0,0" T="3" Y="354" /><P X="353" P="0,1" T="3" Y="353" /><P X="692" P="0,0" T="5" Y="356" /><P X="390" P="0,1" T="3" Y="354" /><P X="706" P="0,0" T="1" Y="356" /><F X="541" Y="149" /><P X="495" P="0,0" T="11" Y="154" /><DS X="122" Y="343" /><DC X="122" Y="341" /></D><O /></Z></C>]]}
-- Test
pshy.mapdb_maps["test"]						= {xml = [[<C><P shaman_tools="1,33,102,110,111,202,302,402,608,1002,2802,2,2806" F="0" /><Z><S><S H="50" L="800" Y="378" X="400" P="0,0,0.3,0.2,0,0,0,0" T="6" /><S H="40" L="120" Y="173" X="541" P="0,0,0.3,0.2,0,0,0,0" T="6" /><S H="27" L="35" Y="482" X="254" P="0,0,0.3,0.2,90,0,0,0" T="6" /></S><D><P X="542" P="0,1" T="12" Y="353" /><P X="49" P="1,0" T="0" Y="355" /><T X="120" Y="356" /><P X="228" P="0,0" T="3" Y="355" /><P X="249" P="0,0" T="11" Y="354" /><P X="296" P="0,1" T="11" Y="353" /><P X="311" P="0,0" T="3" Y="354" /><P X="729" P="0,0" T="11" Y="353" /><P X="672" P="0,1" T="3" Y="356" /><P X="283" P="0,0" T="3" Y="353" /><P X="273" P="0,0" T="3" Y="354" /><P X="353" P="0,1" T="3" Y="353" /><P X="692" P="0,0" T="5" Y="356" /><P X="390" P="0,1" T="3" Y="354" /><P X="706" P="0,0" T="1" Y="356" /><F X="541" Y="149" /><P X="495" P="0,0" T="11" Y="154" /><DS X="122" Y="343" /><DC X="122" Y="341" /></D><O /></Z></C>]]}
--- Map Lists:
-- @TODO: The maps list names may change in future versions, but should eventually be definitive.
-- Listed by Pshy#3752:
pshy.mapdb_maps_tfm_art = {5178088, 4164063, 3219677, 3912610, 2981085, 7623034, 5779484, 6736785, 4149609, 4656673, 4346298, 2661228, 3390119, 6287276, 5047342, 3430549, 5377045, 2571307, 2148268, 2388455, 2840043, 7315810}
pshy.mapdb_maps_tfm_art_ext1 = {3665811, 7513328, 1944538, 4057263, 2922928, 3882463, 3889663, 1803212, 1711836, 2852625, 3466964, 2801395, 2156965, 2623803, 3651831}
pshy.mapdb_maps_tfm_art_ext2 = {5820090, 2641541, 2624724, 2117194, 1778762, 1782034, 1519771, 1728484}
pshy.mapdb_maps_tfm_art_aewingv2 = {3950540, 1916839, 2172603, 154859, 2311296, 1702825, 1947597, 1720912, 3035794, 2243177, 2028226, 1724122, 2605044, 3159424, 2203217, 2661228, 1936506, 2955795, 804667, 2266732, 2623223, 1959434, 2121201, 1695882, 1795000, 1704637, 1792267, 2581086, 663595, 2576455, 2973863, 1942268, 2163526, 1806133, 2521847, 2627056, 2920274, 2767545, 2956808, 2095009, 2226640, 2401105, 1822790, 3246478, 2415437, 3993637, 2149644, 1474863, 2742902, 2145552, 3831792, 1814431, 2195692, 1706288, 1791048, 2577378, 3143355, 2923270, 2391364, 2770692, 2199068, 1904664, 1720281, 3235436, 1749453, 2188489, 2635263, 2945688, 2789609, 2477782, 2433668, 2009802, 2146261, 2749187, 2720487, 2636351, 3119297, 2839982, 1949605, 2802138, 2163526, 1786967, 2055189, 2957089, 1994092, 1964673, 2805172, 3595347, 2707698, 2270344, 2684631, 666106, 2030616, 2700505, 2610838, 2750977, 1855696, 2386489, 2209037, 3205133, 2153314, 1794589, 2097415, 1779011, 1833908, 1992539, 2714086, 3210100, 2705765, 2425475, 2477782, 2454936, 334645, 2571239, 2679669, 3413453, 2542832, 2290792, 3864906, 3326059, 2146340, 1768040, 2074923, 2205008, 2285624, 1989772, 2626828, 2895406, 2348177, 2344972, 2164981, 1715891, 2392654, 2498542, 2621192, 1709589, 1728099, 2078035, 3219677, 1928276, 1807144, 1762785, 2093166, 2240697, 1930228, 1964446, 2586989, 2814018, 2517471, 2255816, 1912443, 1083194, 3190133, 4114443, 1808990, 3171824, 2930435, 1742593, 2789232, 2580252, 1707317, 1765431, 2016716, 2623223, 2165057, 1949415, 2383247, 3097937, 2412122, 2214562, 3120021, 2427867, 3864399, 2549315, 2670766, 3175494, 1728248, 2400240, 3176790, 2186777, 2116858, 1879558, 2760008, 2754663, 2749095, 3656937, 2673363, 2534765, 2649340, 2672948, 2649340, 2525761, 2573397, 2199655, 2578109, 3401577, 2160116, 3478997}
pshy.mapdb_maps_trap_mice = {2914627, 171290, 75050, 923485, 323597, 3295997, 264362, 6937385, 976524, 279568, 3754693} -- @1493128?
pshy.mapdb_maps_trap_sham = {3659540, 6584338, 171290, 453115, 2680593, 234665, 1493128, 7812024}
pshy.mapdb_maps_vanilla_troll = {7847625, 4136008, 363251}
pshy.mapdb_maps_vanistyle = {2999057, 5154237, 1310944, 3688504, 2013190, 1466862, 1280404, 2527971, 389123, 7833268, 7833282, 2174259, 2638619, 1830174, 758488}
pshy.mapdb_maps_sync_or_coop = {144888, 1327222, 161177, 3147926, 3325842, 4722827, 7108594, 423796, 7083472, 7041335, 6795659, 6400313, 269622, 1713335, 4848796, 7233643, 117269, 569959, 2808564}
pshy.mapdb_maps_meme = {7466942}
pshy.mapdb_maps_funny = {4117469, 1408189, 6827968, 7111104, 6980069, 748712, 3344068, 7169831, 7788801, 5781406, 3611575}
pshy.mapdb_maps_minigame_mice = {4140588, 7418736, 6013828, 1959098, 3146116, 250491, 7825263}
pshy.mapdb_maps_minigame_sham = {7299396}
pshy.mapdb_maps_custom_racing_list = {4933905, 277517, 333714}
-- to list: @615973, @6773628 @6860453 @6189772 @1514137 @6522457 @7439980 @6926916 @6827968 @6003432 @118564 @3828619 @1979847 4003463
-- Misc:
-- Aewing's other troll list (source: https://docs.google.com/spreadsheets/d/1zO9ifeP8EwPOU9LMTFovunl0TDHHcJfrhisooYVHHLc/edit#gid=1143900591 (2017-05-11))
pshy.mapdb_maps_trollmapsv2_other = {6125351, 5900622, 1133326, 383709, 5316364, 5463804, 5482590, 549590, 5574163, 5629308, 5836056, 585024, 585028, 5852789, 5858850, 5875457, 5919103, 5922975, 5966472, 6121905, 6137199, 6162603, 625932, 668003, 690871, 722816, 722820, 731615, 6205708, 6216966, 6216666, 6216605, 6206313, 6396394, 6134379, 6376080, 6453361, 6445328, 6212486, 2711798, 558407, 6296389, 6296422, 6299503, 6096572, 6080913, 6299597, 5940448, 6818735, 6052780, 6883328, 6839471}
-- The Holy Document of Troll Maps v3 (source: https://docs.google.com/spreadsheets/d/1f-ntqw9hidFVvqmNVUU5FyvM6wrA62a8NmOV6h9XX5w (11/01/2021-01-11))
pshy.mapdb_maps_trollmapsv3_vanilla = {5651178, 5018395, 6010060, 6124757, 6123862, 5929021, 6178788, 6127609, 6222523, 6222598, 6222662, 6113351, 6422227, 6575209, 6083498, 6355317, 7306821, 5479119, 5403145, 3067644, 7326348, 7306268, 7797096, 5018481, 5543945, 6122745, 6130459, 6313103, 7307080, 7326356, 7718570, 5966405, 5018508, 5858646, 6127224, 6123442, 5977759, 6135200, 5932565, 6110650, 6526938, 6498941, 6085234, 7326399, 7306953, 7797106, 5018552, 5528077, 7326404, 7307961, 7313763, 7797124, 5018625, 5858647, 1395371, 6207985, 6218403, 6329560, 6345898, 7316626, 7152731, 5622009, 5875455, 6192664, 4888545, 5018731, 7316586, 5858583, 5858585, 5966424, 5966445, 5704644, 6173496, 5436800, 6329565, 5018771, 5719514, 5704627, 6125960, 6127589, 6127747, 6192402, 6184390, 6329568, 6411135, 5994239, 6358824, 7317620, 5018836, 5719492, 5858628, 6124001, 5564186, 6217094, 6649205, 6501429, 7323960, 7318393, 5018961, 5858631, 5640463, 6217035, 6186461, 4040403, 7323461, 7319739, 5019057, 5621250, 6172370, 5436588, 6207483, 6222159, 6062298, 6821665, 7321072, 5019123, 7321926, 5019191, 6126005, 5436981, 4214766, 7322227, 7794773, 5019223, 6501480, 7324070, 6232081, 6232089, 6232095, 6232098, 7797132, 5019302, 5440478, 6526742, 6818892, 6206380, 6695005, 6127550, 6136351, 6217055, 7323482, 6369921, 6108198, 6623156, 6358865, 6883967, 7718563, 5873692, 5019328, 5629311, 5803326, 5858564, 5858586, 5858587, 5966392, 1193082, 6186304, 5543399, 6704726, 5019350, 5719394, 5949452, 6115548, 6477206, 6526318, 6299220, 5019382, 6173592, 6172417, 6772912, 5019421, 6186328, 7321827, 6126256, 5543671, 5019530, 5564274, 6205274, 7324153, 5048881, 6156082, 6277845, 5621395, 5724761, 5724763, 5724765, 6094395, 5565050, 6515469, 6342950, 5605309, 6277853, 6313226, 6819729, 6408356, 7324135, 5049526, 5704629, 7111346, 7323508, 6270048, 6526750, 5910464, 5966432, 5966438, 6126145, 6127710, 6127719, 6377332, 6148478, 6314518, 6299153, 6821666, 6127135, 5621346, 6526760, 6473951, 6452812, 4888705, 5049660, 5875460, 5875461, 5628930, 6172472, 6186377, 6189703, 5910501, 6127290, 6223454, 6838787, 6132502, 6127154, 6332528, 6516797, 5018652, 5836826, 5858595, 5858625, 5858639, 3195916, 6124832, 6127211, 5602310, 7324527, 6244710, 6250422, 6299335, 5595910, 6526776, 6498946, 6813933, 4891010, 6823206, 5858644, 6147952, 6474382, 3765697, 3765697, 5621139, 5621147, 6272568, 6498958, 6836851, 7723923, 5621219, 5910108, 6107893, 6821667, 6190625, 5584431, 6823223, 5605249, 6254763, 5910088, 6119333, 5966429, 5949462, 6203629, 6186396, 6205616, 6207848, 6522504, 4157329, 7322706, 5910104, 6173687, 6116175, 6819107, 7344547, 5910095, 6189594, 6313270, 3711456, 5858581, 5858632, 6104360, 5436707, 6329552, 6400422, 6823081, 6824065, 5803313, 6819128, 6819712, 5649499, 6174089, 5621196, 6125319, 6299508, 7322433, 6205095, 6205714, 6498981, 6715840, 5949349, 6062306, 6580093, 5723872, 5836910, 5858598, 5902874, 6127184, 5591651, 6201987, 6335762, 5858641, 7322471, 5902875, 7324077, 7797162, 6127705, 5605065, 4273525, 6445760, 7270457, 7793398, 6205203, 6100256, 4517700, 6300895, 6473496, 6431883, 5621555, 6411306, 5910116, 6174019, 4273441, 5910077, 6451557, 6573645, 5862868, 5862874, 6192863, 5621716, 5852948, 5854243, 5621865, 6818861, 6122725, 6113306, 6445749, 5836845, 6185835, 6613860, 5050018, 6189570, 2721399, 5875458, 6900569, 6527648, 6400412, 6794502, 6794509, 6794515, 6837067, 6794527, 6794531, 6798232, 6794500, 7276028, 6798283, 7128420, 7097044}
pshy.mapdb_maps_trollmapsv3_racing = {6273752, 6273694, 6418619, 6704790, 6883225, 6901245, 6901260, 6716047, 7106829, 7143225, 7143229, 7143231, 7143235}
pshy.mapdb_maps_trollmapsv3_rotations_noracing = {4759150, 5858703, 5858770, 5859434, 5859447, 5859532, 5859542, 5892506, 5892558, 5902822, 5902827, 5902895, 5918103, 5918111, 5921487, 5966400, 5966408, 5966409, 5966414, 5966418, 5966462, 5966473, 6019882, 6019890, 6019900, 6299490, 6299901, 5949845, 5049453, 5575085, 5858562, 5858669, 5858762, 5859410, 5859501, 5860620, 5863395, 5863423, 5875462, 5875465, 5875466, 5875467, 5966389, 5966417, 5966459, 5966465, 6019894, 6082932, 6122126, 6020836, 1746071, 6242044, 6299312, 6299328, 6299369, 6308474, 5946610, 5946626, 5946613, 4636732, 6902434, 5575159, 5575195, 5858602, 4247610, 6305517, 6305551, 6305617, 6305707, 6314480, 6299413, 6299384, 5946634, 5946669, 5951369, 5951378, 6376011, 6299277, 5951362, 6874219, 7143240, 5049384, 5575096, 5575108, 5621496, 5858558, 5858720, 5858784, 5859579, 5859594, 5859607, 5859617, 5862892, 5863475, 5863515, 5863529, 5863583, 5863631, 5863649, 5863705, 5875449, 5887738, 5902850, 5902868, 5910128, 5966453, 5982510, 5991843, 6019895, 6127308, 6123903, 6123935, 6190773, 6190661, 6190270, 6190252, 6190231, 6190196, 6280663, 6309152, 6309162, 6309194, 6314505, 6316487, 6316519, 6316552, 6627603, 6272125, 6299376, 6299378, 6299380, 6299421, 6418640, 6553484, 6689054, 6389621, 5069907, 6689069, 6627605, 6299426, 5948428, 6823381, 6191953, 5070084, 5278887, 5247557, 5541815, 6340475, 6920196, 6219374, 6105038, 6431185, 5949881, 5982422, 6050752, 6314533, 6036135, 6299351, 6840743, 6839461, 6920189, 6920187, 6920192, 6716039}
-- TODO: Troll Map Submissions 3.0 - pending newests submissions (source: https://atelier801.com/topic?f=6&t=892614&p=1)
pshy.mapdb_maps_trollmapsv3_pending_racing = {}
pshy.mapdb_maps_trollmapsv3_pending_vanilla = {}
pshy.mapdb_maps_trollmapsv3_pending_other = {}
-- Nnaaaz#0000's trolls (source: https://atelier801.com/topic?f=6&t=892706&p=1 (2021-08-23))
pshy.mapdb_maps_nnaaaz_trolls_vanilla = {7805164, 7801845, 7801848, 7801850, 7801929, 7802215, 7802221, 7802404, 7802588, 7802592, 7803100, 7803618, 7803013, 7803900, 7804144, 7804211, 7804405, 7804709, 7804243, 7805109}
pshy.mapdb_maps_nnaaaz_trolls_vanilla_nosham = {7781189, 7781560, 7782831, 7783745, 7787472, 7814117, 7814126, 7814248, 7814488, 7817779}
pshy.mapdb_maps_nnaaaz_trolls_racing = {7781575, 7783458, 7783472, 7784221, 7784236, 7786652, 7786707, 7786960, 7787034, 7788567, 7788596, 7788673, 7788967, 7788985, 7788990, 7789010, 7789484, 7789524, 7790734, 7790746, 7790938, 7791293, 7791550, 7791709, 7791865, 7791877, 7792434, 7765843, 7794331, 7794726, 7792626, 7794874, 7795585, 7796272, 7799753, 7800330, 7800998, 7801670, 7805437, 7792149, 7809901, 7809905, 7810816, 7812751, 7789538, 7813075, 7813248, 7814099, 7819315, 7815695, 7815703, 7816583, 7816748, 7817111, 7782820}
-- Pshy#3752's trolls
pshy.mapdb_maps_pshy_trolls_vanilla_nosham = {7871137, 7871139, 7871138, 7871140, 7871142, 7871141, 7871143, 7871144, 7871145, 7871146, 7871152, 7871148, 7871147, 7871154, 7871160, 7871158, 7871136, 7876183, 7876188}
pshy.mapdb_maps_pshy_trolls_vanilla_sham = {7871134, 7871157, 7871155, 7876185, 7876194, "v0_noskills"}
pshy.mapdb_maps_pshy_trolls_misc_nosham = {7840661, 7871156, 7871159, 7871161}
-- TODO: check (source: https://atelier801.com/topic?f=6&t=892706&p=1#m16)
--7819384, 7819386, 7819387, @7819388, 7819389, 7819390, 7819391, 7819394, 7819719, 7819720, 7819721, 7823948, 7823952, 7823954, 7823956, 7823957, 7823958, 7824387, 7824388, 7824390, 7824392
-- TODO: Check Aewing's mechanisms originals list
-- The Holy Document of Troll Maps v3 Rotation/Racing (originals) (source: https://docs.google.com/spreadsheets/d/1f-ntqw9hidFVvqmNVUU5FyvM6wrA62a8NmOV6h9XX5w (11/01/2021-01-11))
--	1405249, 6112855, 2101747, 407294, 1657360, 4645670, 4645670, 4645670, 7021812, 6835898, 6771291, 7062105
-- TODO: Remove racings from other_troll
-- tribehouse: @7876714
--	other: 696995, 7285161, 7821431, 1871815, 3344068
--	pending: @949687 @4405505 @7826883 @1006122 @500601 5781406 @7512702 @7512702 @2453556 @406463 @3270078 4365311 @817645 @6245851(getxml) @344332 @7279280 @625041
--	GORE TROLLABLE: @2623223
--- Rotations.
-- Basics (Classic/Sham)
pshy.mapdb_rotations["vanilla"]						= {desc = "0-210", duration = 120, items = {900}} for i = 0, 210 do table.insert(pshy.mapdb_rotations["vanilla"].items, i) end
pshy.mapdb_rotations["standard"]					= {desc = "P0", duration = 120, items = {"#0"}}
pshy.mapdb_rotations["protected"]					= {desc = "P1", duration = 120, items = {"#1"}}
pshy.mapdb_rotations["art"]							= {desc = "P5", duration = 120, items = {"#5"}}
pshy.mapdb_rotations["mechanisms"]					= {desc = "P6", duration = 120, items = {"#6"}}
-- Basics (Racing/Nosham)
pshy.mapdb_rotations["racing"]						= {desc = "P17", duration = 60, shamans = 0, items = {"#17"}}
pshy.mapdb_rotations["nosham"]						= {desc = "P7", duration = 60, shamans = 0, items = {"#7"}}
pshy.mapdb_rotations["defilante"]					= {desc = "P18", duration = 60, shamans = 0, items = {"#18"}}
pshy.mapdb_rotations["vanilla_nosham"]				= {desc = "0-210*", duration = 60, shamans = 0, items = {900, 2, 8, 11, 12, 14, 19, 22, 24, 26, 27, 28, 30, 31, 33, 40, 41, 44, 45, 49, 52, 53, 55, 57, 58, 59, 61, 62, 65, 67, 69, 70, 71, 73, 74, 79, 80, 85, 86, 89, 92, 96, 100, 117, 119, 120, 121, 123, 126, 127, 138, 142, 145, 148, 149, 150, 172, 173, 174, 175, 176, 185, 189}}
-- Customs
pshy.mapdb_rotations["mech_racing"]					= {desc = "custom rotation of racing mechanisms", duration = 60, shamans = 0, items = {3518087, 1919402, 7264140, 7000017, 7063481, 1749725, 176936, 3514715, 3150249, 3506224, 2030030, 479001, 3537313, 1709809, 169959, 313281, 2868361, 73039, 73039, 2913703, 2789826, 298802, 357666, 1472765, 271283, 3702177, 2355739, 4652835, 164404, 7273005, 3061566, 3199177, 157312, 7021280, 2093284, 5752223, 7070948, 3146116, 3613020, 1641262, 119884, 3729243, 1371302, 6854109, 2964944, 3164949, 149476, 155262, 6196297, 1789012, 422271, 3369351, 3138985, 3056261, 5848606, 931943, 181693, 227600, 2036283, 6556301, 3617986, 314416, 3495556, 3112905, 1953614, 2469648, 3493176, 1009321, 221535, 2377177, 6850246, 5761423, 211171, 1746400, 1378678, 246966, 2008933, 2085784, 627958, 1268022, 2815209, 1299248, 6883670, 3495694, 4678821, 2758715, 1849769, 3155991, 6555713, 3477737, 873175, 141224, 2167410, 2629289, 2888435, 812822, 4114065, 2256415, 3051008, 7300333, 158813, 3912665, 6014154, 163756, 3446092, 509879, 2029308, 5546337, 1310605, 1345662, 2421802, 2578335, 2999901, 6205570, 7242798, 756418, 2160073, 3671421, 5704703, 3088801, 7092575, 3666756, 3345115, 1483745, 3666745, 2074413, 2912220, 3299750}}
pshy.mapdb_rotations["nosham_simple"]				= {desc = nil, duration = 120, shamans = 0, items = {1378332, 485523, 7816865, 763608, 1616913, 383202, 2711646, 446656, 815716, 333501, 7067867, 973782, 763961, 7833293, 7833270, 7833269, 7815665, 7815151, 7833288, 1482492, 1301712, 6714567, 834490, 712905, 602906, 381669, 4147040, 564413, 504951, 1345805, 501364}} -- soso @1356823 @2048879 @2452915 @2751980
pshy.mapdb_rotations["nosham_traps"]				= {desc = nil, duration = 120, shamans = 0, items = {297063, 5940448, 2080757, 7453256, 203292, 108937, 445078, 133916, 7840661, 115767, 2918927, 4684884, 2868361, 192144, 73039, 1836340, 726048}}
pshy.mapdb_rotations["nosham_coop"]					= {desc = nil, duration = 120, shamans = 0, items = {169909, 209567, 273077, 7485555, 2618581, 133916, 144888, 1991022, 7247621, 3591685, 6437833, 3381659, 121043, 180468, 220037, 882270, 3265446}}
-- Trolls
pshy.mapdb_rotations["vanilla_troll"]				= {desc = "vanilla troll maps", duration = 120, troll = true, items = {}, unique_items = true}
pshy.ListAppend(pshy.mapdb_rotations["vanilla_troll"].items, pshy.mapdb_maps_trollmapsv3_vanilla)
pshy.ListAppend(pshy.mapdb_rotations["vanilla_troll"].items, pshy.mapdb_maps_nnaaaz_trolls_vanilla)
pshy.ListAppend(pshy.mapdb_rotations["vanilla_troll"].items, pshy.mapdb_maps_pshy_trolls_vanilla_nosham)
pshy.ListAppend(pshy.mapdb_rotations["vanilla_troll"].items, pshy.mapdb_maps_pshy_trolls_vanilla_sham)
pshy.ListAppend(pshy.mapdb_rotations["vanilla_troll"].items, pshy.mapdb_maps_trollmapsv3_pending_vanilla)
pshy.mapdb_rotations["vanilla_nosham_troll"]		= {desc = "trolls for vanilla racings", duration = 60, shamans = 0, troll = true, items = {}, unique_items = true}
pshy.ListAppend(pshy.mapdb_rotations["vanilla_nosham_troll"].items, pshy.mapdb_maps_pshy_trolls_vanilla_nosham)
pshy.mapdb_rotations["racing_troll"]				= {desc = "trolls for racings", duration = 60, shamans = 0, troll = true, items = {}, unique_items = true}
pshy.ListAppend(pshy.mapdb_rotations["racing_troll"].items, pshy.mapdb_maps_trollmapsv3_racing)
pshy.ListAppend(pshy.mapdb_rotations["racing_troll"].items, pshy.mapdb_maps_nnaaaz_trolls_racing)
pshy.ListAppend(pshy.mapdb_rotations["racing_troll"].items, pshy.mapdb_maps_trollmapsv3_pending_racing)
pshy.mapdb_rotations["other_troll"]					= {desc = "misc trolls", duration = 120, troll = true, items = {}, unique_items = true}
pshy.ListAppend(pshy.mapdb_rotations["other_troll"].items, pshy.mapdb_maps_trollmapsv2_other)
pshy.ListAppend(pshy.mapdb_rotations["other_troll"].items, pshy.mapdb_maps_pshy_trolls_misc_nosham)
pshy.ListAppend(pshy.mapdb_rotations["other_troll"].items, pshy.mapdb_maps_trollmapsv3_rotations_noracing)
pshy.ListAppend(pshy.mapdb_rotations["other_troll"].items, pshy.mapdb_maps_trollmapsv3_pending_other)
pshy.mapdb_rotations["traps"]						= {desc = "sham and no-sham traps", duration = 120, troll = false, items = {}, unique_items = true}
pshy.ListAppend(pshy.mapdb_rotations["traps"].items, pshy.mapdb_maps_trap_mice)
pshy.ListAppend(pshy.mapdb_rotations["traps"].items, pshy.mapdb_maps_trap_sham)
--- Internal Use:
pshy.mapdb_current_shamans = nil
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
--- TFM event eventNewGame.
-- Clear fields in `tfm.get` when the map is vanilla.
function eventNewGame()
	if string.sub(tfm.get.room.currentMap, 1, 1) ~= '@' then
		-- Well, some vanilla maps have an xml, start with '@' but not in the code :/
		--tfm.get.room.xmlMapInfo = nil
	end
end
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
-- @param aborted true if the map have not even been started.
function pshy.mapdb_EndMap(aborted)
	if not aborted then
		for i_func, end_func in ipairs(pshy.mapdb_current_map_end_funcs) do
			end_func(pshy.mapdb_current_map_name)
		end
		if eventGameEnded then
			eventGameEnded()
		end
	end
	pshy.mapdb_current_shamans = nil
	tfm.exec.disableAutoShaman(false)
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
	-- On every new game:
	--for player_name in pairs(tfm.get.room.playerList) do
		--tfm.exec.changePlayerSize(player_name, 1.0)
		--tfm.exec.giveTransformations(player_name, false)
		--tfm.exec.linkMice(player_name, player_name, false) -- TODO: check player.soulmate ?
	--end
	-- clean tfm.get.room.xmlMapInfo because TFM doesnt
	tfm.get.room.xmlMapInfo = nil
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
	local mapcode_number = tonumber(mapcode)
	if mapcode_number and pshy.mapdb_maps[mapcode_number] then
		return pshy.mapdb_NextDBMap(mapcode_number)
	end
	if pshy.mapdb_rotations[mapcode] then
		return pshy.mapdb_NextDBRotation(mapcode)
	end
	if tonumber(mapcode) then
		pshy.mapdb_current_map_name = mapcode
		pshy.merge_EnableModules(pshy.mapdb_current_map_modules)
		return pshy.mapdb_tfm_newGame(mapcode)
	end
	if string.sub(mapcode, 1, 1) == "<" then
		tfm.get.room.xmlMapInfo = {}
		tfm.get.room.xmlMapInfo.xml = mapcode
		return pshy.mapdb_tfm_newGame(mapcode)
	end
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
	if t.shamans ~= nil then
		assert(t.shamans == 0, "only a shaman count of 0 or nil is supported yet")
		pshy.mapdb_current_map_shamans = t.shamans 
		tfm.exec.disableAutoShaman(true)
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
		tfm.get.room.xmlMapInfo = {}
		if string.sub(map.xml, 1, 1) == "<" then
			tfm.get.room.xmlMapInfo.xml = map.xml
		end
		tfm.get.room.xmlMapInfo.author = map.author
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
	if rotation_name == "default" and #pshy.mapdb_default_rotation.items == nil then
		-- empty rotation, just not changing map
		return nil
	end
	if pshy.mapdb_current_rotations_names[rotation_name] then
		print("<r>/!\\ Cyclic map rotation (" .. rotation_name .. ")! Going to nil!</r>")
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
		if pshy.mapdb_current_map and pshy.mapdb_current_map.bonuses then
			if pshy.bonuses_SetList then
				pshy.bonuses_SetList(pshy.mapdb_current_map.bonuses)
			end
		end
		for i_func, begin_func in ipairs(pshy.mapdb_current_map_begin_funcs) do
			begin_func(pshy.mapdb_current_map_name)
		end
		if pshy.mapdb_current_map_duration then
			tfm.exec.setGameTime(pshy.mapdb_current_map_duration, true)
		end
	else
		-- tfm loaded a new map
		pshy.mapdb_EndMap()
		if pshy.mapdb_current_map then
			tfm.exec.disableAutoShaman(false)
		end
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
--- !rotationclean [rotation]
function pshy.mapdb_ChatCommandRotc(user, rotname)
	pshy.mapdb_default_rotation.items = {}
	if rotname then
		table.insert(pshy.mapdb_default_rotation.items, rotname)
	end
end
pshy.chat_commands["rotationclean"] = {func = pshy.mapdb_ChatCommandRotc, desc = "clear all rotations, and optionaly set a new one", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_mapdb"].commands["rotationclean"] = pshy.chat_commands["rotationclean"]
pshy.perms.admins["!rotationclean"] = true
pshy.chat_command_aliases["rotc"] = "rotationclean"
--- TFM event eventPlayerDied.
function eventPlayerDied(player_name)
	tfm.get.room.playerList[player_name].isDead = true
	local players_alive = pshy.CountPlayersAlive()
	if pshy.mapdb_current_map_autoskip ~= false and players_alive == 0 then
		tfm.exec.setGameTime(5, true)
		--tfm.exec.newGame(nil);
	end
end
--- TFM event eventPlayerWon.
function eventPlayerWon(player_name)
	tfm.get.room.playerList[player_name].isDead = true
	local players_alive = pshy.CountPlayersAlive()
	if pshy.mapdb_current_map_autoskip ~= false and players_alive == 0 then
		tfm.exec.setGameTime(5, true)
		--tfm.exec.newGame(nil);
	end
end
--- pshy event eventInit.
function eventInit()
	for i_rot, rot in pairs(pshy.mapdb_rotations) do
		-- @todo: use a custom compare function
		--if rot.unique_items then
		--	table.sort(rot.items)
		--	pshy.SortedListRemoveDuplicates(rot.items)
		--end
	end
	-- This module replace the automatic newgame:
	tfm.exec.disableAutoNewGame(true)
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
local new_mod = pshy.merge_ModuleBegin("pshy_basic_bonuses.lua")
function new_mod.Content()
--- pshy_basic_bonuses.lua
--
-- Custom bonuses list.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @require pshy_checkpoints.lua
-- @require pshy_speedfly.lua
-- @require pshy_bonuses.lua
-- @require pshy_imagedb.lua
-- @require pshy_mario_bonuses.lua
-- @require pshy_misc_bonuses.lua
-- Transformations, Free link, explosion, grow, shrink, shaman, vampire, balloon, snowflake, turn into cheese, checkpoint, heart/broken heart, fly, speed, loose-cheeze
-- cross, teleporter, mousetrap
--- Internal Use:
local changed_sizes = {}
local last_heart_grabber = nil
local linked_mice = {}
local transformices = {}
local strange_players = false
--- BonusShrink.
function pshy.bonuses_callback_BonusShrink(player_name, bonus)
	local new_size = bonus.value or 0.5
	tfm.exec.changePlayerSize(player_name, new_size)
	changed_sizes[player_name] = new_size
end
pshy.bonuses_types["BonusShrink"] = {image = "17bf4b63aaa.png", func = pshy.bonuses_callback_BonusShrink}
--- BonusGrow.
function pshy.bonuses_callback_BonusGrow(player_name, bonus)
	local new_size = bonus.value or 1.8
	tfm.exec.changePlayerSize(player_name, new_size)
	changed_sizes[player_name] = new_size
end
pshy.bonuses_types["BonusGrow"] = {image = "17bf4b67579.png", func = pshy.bonuses_callback_BonusGrow}
--- BonusAttachBalloon.
-- Attack a balloon to the player.
-- bonus.ghost: is the balloon ghosted.
function pshy.bonuses_callback_BonusAttachBalloon(player_name, bonus)
	tfm.exec.attachBalloon(player_name, true)
end
pshy.bonuses_types["BonusAttachBalloon"] = {image = "17bf4b80fc3.png", func = pshy.bonuses_callback_BonusAttachBalloon}
--- BonusFly.
function pshy.bonuses_callback_BonusFly(player_name, bonus)
	pshy.speedfly_Fly(player_name, 50)
end
pshy.bonuses_types["BonusFly"] = {image = "17bf4b7250e.png", func = pshy.bonuses_callback_BonusFly}
--- BonusHighSpeed.
function pshy.bonuses_callback_BonusHighSpeed(player_name, bonus)
	pshy.speedfly_Speed(player_name, 200)
end
pshy.bonuses_types["BonusHighSpeed"] = {image = "17bf4b9af56.png", func = pshy.bonuses_callback_BonusHighSpeed}
--- BonusShaman.
-- Turn the first player to grab it into shaman.
function pshy.bonuses_callback_BonusShaman(player_name, bonus)
	tfm.exec.setShaman(player_name, true)
end
pshy.bonuses_types["BonusShaman"] = {image = "17bf4b8c42d.png", func = pshy.bonuses_callback_BonusShaman, shared = true}
--- BonusTransformations.
function pshy.bonuses_callback_BonusTransformations(player_name, bonus)
	tfm.exec.giveTransformations(player_name, true)
	transformices[player_name] = true
end
pshy.bonuses_types["BonusTransformations"] = {image = "17bf4b6f226.png", func = pshy.bonuses_callback_BonusTransformations}
--- BonusFreeze.
-- Freeze the picker.
function pshy.bonuses_callback_BonusFreeze(player_name, bonus)
	tfm.exec.freezePlayer(player_name, true)
end
pshy.bonuses_types["BonusFreeze"] = {image = "17bf4b94d8a.png", func = pshy.bonuses_callback_BonusFreeze}
--- BonusIce.
-- Turn the player into an ice block.
function pshy.bonuses_callback_BonusIce(player_name, bonus)
	local tfm_player = tfm.get.room.playerList[player_name]
	local speed_x = tfm_player.vx
	local speed_y = tfm_player.vy
	tfm.exec.killPlayer(player_name)
	local obj_id = tfm.exec.addShamanObject(tfm.enum.shamanObject.iceCube, bonus.x, bonus.y, angle, speed_x, speed_y, false)
end
pshy.bonuses_types["BonusIce"] = {image = "17bf4b977f5.png", func = pshy.bonuses_callback_BonusIce}
--- BonusStrange.
function pshy.bonuses_callback_BonusStrange(player_name, bonus)
	tfm.exec.setVampirePlayer(player_name, true)
	pshy.imagedb_AddImageMin("17bf4b75aa7.png", "%" .. player_name, 0, 0, nil, 30, 30, 0, 1.0)
	strange_players = true
end
pshy.bonuses_types["BonusStrange"] = {image = "17bf4b75aa7.png", func = pshy.bonuses_callback_BonusStrange}
--- BonusCheese.
-- Turn the player into a cheese.
function pshy.bonuses_callback_BonusCheese(player_name, bonus)
	tfm.exec.killPlayer(player_name)
	tfm.exec.displayParticle(tfm.enum.particle.yellowGlitter, bonus.x, bonus.y, -2, -6.8, 0, 1, nil)
	tfm.exec.displayParticle(tfm.enum.particle.yellowGlitter, bonus.x, bonus.y, -1, -7, 0, 1, nil)
	tfm.exec.displayParticle(tfm.enum.particle.yellowGlitter, bonus.x, bonus.y, 0, -7.1, 0, 1, nil)
	tfm.exec.displayParticle(tfm.enum.particle.yellowGlitter, bonus.x, bonus.y, 1, -7, 0, 1, nil)
	tfm.exec.displayParticle(tfm.enum.particle.yellowGlitter, bonus.x, bonus.y, 2, -6.8, 0, 1, nil)
	local tfm_player = tfm.get.room.playerList[player_name]
	local speed_x = tfm_player.vx
	local speed_y = tfm_player.vy
	local obj_id = tfm.exec.addShamanObject(tfm.enum.shamanObject.littleBox, bonus.x, bonus.y, angle, speed_x, speed_y, false)
	pshy.imagedb_AddImage("155592fd7d0.png", "#" .. tostring(obj_id), 0, 0, nil, nil, nil, 0.0, 1.0)
end
pshy.bonuses_types["BonusCheese"] = {image = "17bf4b6b157.png", func = pshy.bonuses_callback_BonusCheese}
--- BonusCheckpoint.
-- Checkpoint the player (if the checkpoint module is available).
function pshy.bonuses_callback_BonusCheckpoint(player_name, bonus)
	pshy.checkpoints_SetPlayerCheckpoint(player_name, bonus.x, bonus.y)
	tfm.exec.chatMessage("<d>Checkpoint!</d>", player_name)
end
pshy.bonuses_types["BonusCheckpoint"] = {image = "17bf4c421bb.png", func = pshy.bonuses_callback_BonusCheckpoint}
--- BonusTeleporter.
-- bonus.dst_x: tp coordinates (or random).
-- bonus.dst_y: tp coordinates (or random).
function pshy.bonuses_callback_BonusTeleporter(player_name, bonus)
	local dst_x = bonus.dst_x or (400 + math.random(-400, 400))
	local dst_y = bonus.dst_y or (200 + math.random(-200, 200))
	tfm.exec.displayParticle(tfm.enum.particle.mouseTeleportation, bonus.x, bonus.y, 0, 0, 0, 0, nil)
	tfm.exec.movePlayer(player_name, dst_x, dst_y)
	tfm.exec.displayParticle(tfm.enum.particle.mouseTeleportation, dst_x, dst_y, 0, 0, 0, 0, nil)
end
pshy.bonuses_types["BonusTeleporter"] = {image = "17bf4ba4ce5.png", func = pshy.bonuses_callback_BonusTeleporter}
pshy.bonuses_types["Teleporter"] = {image = "17bf4ba4ce5.png", func = pshy.bonuses_callback_BonusTeleporter, remain = true}
--- BonusCircle.
-- If the mouse grabs it, then it become the bonus.
function pshy.bonuses_callback_BonusCircle(player_name, bonus)
	tfm.exec.killPlayer(player_name)
	pshy.imagedb_AddImage("17bf4b868c3.png", "!0", bonus.x, bonus.y, player_name, nil, nil, 0.0, 1.0)
end
pshy.bonuses_types["BonusCircle"] = {image = "17bef4f49c5.png", func = pshy.bonuses_callback_BonusCircle}
--- BonusMarry.
function pshy.bonuses_callback_BonusMarry(player_name, bonus)
	if last_heart_grabber == nil then
		last_heart_grabber = player_name
	elseif last_heart_grabber ~= player_name then
		tfm.exec.linkMice(player_name, last_heart_grabber, true)
		table.insert(linked_mice, {player_name, last_heart_grabber})
		last_heart_grabber = nil
	end
end
pshy.bonuses_types["BonusMarry"] = {image = "17bf4b8f9e4.png", func = pshy.bonuses_callback_BonusMarry}
--- BonusDivorce.
-- Remove any soulmate link this mouse has.
function pshy.bonuses_callback_BonusDivorce(player_name, bonus)
	tfm.exec.linkMice(player_name, player_name, true)
	tfm.exec.linkMice(player_name, player_name, false)
	if last_heart_grabber == player_name then
		last_heart_grabber = nil
	end
end
pshy.bonuses_types["BonusDivorce"] = {image = "17bf4b91c35.png", func = pshy.bonuses_callback_BonusDivorce}
--- TFM event eventPlayerRespawn.
function eventPlayerRespawn(player_name)
	if changed_sizes[player_name] then
		tfm.exec.changePlayerSize(player_name, 1.0)
		changed_sizes[player_name] = nil
	end
end
--- TFM event eventPlayerVampire.
function eventPlayerVampire(player_name)
	if strange_players then
		pshy.bonuses_callback_BonusStrange(player_name, nil)
	end
end
--- Cancel changes the module have made.
local function CancelChanges()
	for player_name in pairs(changed_sizes) do
		tfm.exec.changePlayerSize(player_name, 1.0)
	end
	changed_sizes = {}
	for i_link, pair in pairs(linked_mice) do
		tfm.exec.linkMice(pair[1], pair[2], false)
	end
	linked_mice = {}
	last_heart_grabber = nil
	for player_name in pairs(transformices) do
		tfm.exec.giveTransformations(player_name, false)
	end
	transformices = {}
end
--- Pshy event eventGameEnded()
function eventGameEnded()
	CancelChanges()
end
--- TFM event eventnewGame
function eventNewGame()
	CancelChanges()
	strange_players = false
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
local new_mod = pshy.merge_ModuleBegin("pshy_bonus_luamaps.lua")
function new_mod.Content()
--- pshy_bonus_luamaps.lua
--
-- Add lua maps based on special bonuses.
--
-- @require pshy_mapdb.lua
-- @require pshy_basic_bonuses.lua
-- @require pshy_misc_bonuses.lua
-- @require pshy_mario_bonuses.lua
-- @require pshy_bonuses.lua
--- Hardcoded Maps:
-- Gore trolls:
pshy.mapdb_maps["luatroll_chainsaw"]		= {xml = 2623223, shamans = nil, bonuses = {{type = "GoreDeath", x = 449, y = 288}, {type = "GoreDeath", x = 481, y = 277}, {type = "GoreDeath", x = 515, y = 272}, {type = "GoreDeath", x = 549, y = 265}, {type = "GoreDeath", x = 585, y = 260}, {type = "GoreDeath", x = 618, y = 253}, {type = "GoreDeath", x = 656, y = 249}, {type = "GoreDeath", x = 709, y = 238}, {type = "GoreDeath", x = 749, y = 255}, {type = "GoreDeath", x = 777, y = 285}}}
pshy.mapdb_maps["luatroll_blender"]			= {xml = 3358845, shamans = nil, bonuses = {{type = "GoreDeath", x = 757, y = 180}, {type = "Teleporter", x = 754, y = 210, dst_x = 754, dst_y = 100, image = "none", shared = true, remain = false}}}
-- Teleporter demo:
pshy.mapdb_maps["luatroll_v0_1"]			= {xml = 0, shamans = 0, bonuses = {{type = "Teleporter", x = 400, y = 330}}}
-- Balloon bonus demo:
pshy.mapdb_maps["luatroll_v0_2"]			= {xml = 0, shamans = 0, bonuses = {{type = "BonusAttachBalloon", x = 400, y = 330}}}
pshy.mapdb_maps["luatroll_v161_1"]			= {xml = 161, shamans = nil, bonuses = {{type = "BonusAttachBalloon", x = 400, y = 360}}}
-- Strange bonus demo:
pshy.mapdb_maps["luatroll_v0_7"]			= {xml = 0, shamans = nil, bonuses = {{type = "BonusStrange", x = 600, y = 300}}}
pshy.mapdb_maps["luatroll_v153_1"]			= {xml = 153, shamans = nil, bonuses = {{type = "BonusStrange", x = 80, y = 80}}}
-- MouseTrap demo:
pshy.mapdb_maps["luatroll_v0_3"]			= {xml = 0, bonuses = {{type = "MouseTrap", x = 400, y = 335}, {type = "MouseTrap", x = 200, y = 335}, {type = "MouseTrap", x = 250, y = 335}, {type = "MouseTrap", x = 300, y = 335}, {type = "MouseTrap", x = 350, y = 335}, {type = "MouseTrap", x = 400, y = 335}, {type = "MouseTrap", x = 450, y = 335}, {type = "MouseTrap", x = 500, y = 135}, {type = "MouseTrap", x = 550, y = 135}, {type = "MouseTrap", x = 600, y = 135}}}
pshy.mapdb_maps["luatroll_v17_0"]			= {xml = 17, shamans = nil, bonuses = {{type = "MouseTrap", x = 400, y = 335}, {type = "MouseTrap", x = 350, y = 335}, {type = "MouseTrap", x = 450, y = 335}, {type = "MouseTrap", x = 300, y = 335}, {type = "MouseTrap", x = 500, y = 335}, {type = "MouseTrap", x = 250, y = 335}, {type = "MouseTrap", x = 550, y = 335}, {type = "MouseTrap", x = 375, y = 325}, {type = "MouseTrap", x = 425, y = 325}}}
-- Shaman bonus demo:
pshy.mapdb_maps["luatroll_v0_4"]			= {xml = 0, shamans = 0, bonuses = {{type = "BonusShaman", x = 400, y = 330}}}
pshy.mapdb_maps["luatroll_v116_1"]			= {xml = 116, shamans = 0, bonuses = {{type = "BonusShaman", x = 770, y = 168}}}
-- Circle bonus demo:
pshy.mapdb_maps["luatroll_v0_5"]			= {xml = 0, shamans = nil, bonuses = {{type = "BonusCircle", x = 690, y = 140}}}
-- Speed/Fly bonus demo:
pshy.mapdb_maps["luatroll_v89_1"]			= {xml = 89, shamans = nil, bonuses = {{type = "BonusHighSpeed", x = 537, y = 280}}}
pshy.mapdb_maps["luatroll_v72_1"]			= {xml = 72, shamans = nil, bonuses = {{type = "BonusHighSpeed", x = 160, y = 350}, {type = "BonusFly", x = 640, y = 350}}}
pshy.mapdb_maps["luatroll_v77_1"]			= {xml = 77, shamans = nil, bonuses = {{type = "BonusHighSpeed", x = 420, y = 275}, {type = "BonusHighSpeed", x = 370, y = 275}, {type = "BonusHighSpeed", x = 470, y = 275}}}
pshy.mapdb_maps["luatroll_v98_1"]			= {xml = 98, shamans = nil, bonuses = {{type = "BonusFly", x = 291, y = 177}}}
pshy.mapdb_maps["luatroll_v114_1"]			= {xml = 114, shamans = 0, bonuses = {{type = "BonusHighSpeed", x = 20, y = 320}}}
pshy.mapdb_maps["luatroll_v166_1"]			= {xml = 166, shamans = 0, bonuses = {{type = "BonusFly", x = 20, y = 345}, {type = "BonusHighSpeed", x = 780, y = 345}}}
pshy.mapdb_maps["luatroll_v184_1"]			= {xml = 184, shamans = 0, bonuses = {{type = "BonusFly", x = 170, y = 335}}}
pshy.mapdb_maps["luatroll_v186_1"]			= {xml = 186, shamans = 0, bonuses = {{type = "BonusFly", x = 20, y = 335}, {type = "BonusFly", x = 780, y = 335}}}
pshy.mapdb_maps["luatroll_68_1"]			= {xml = 68, shamans = 0, bonuses = {{type = "BonusHighSpeed", x = 400, y = 200}}}
pshy.mapdb_maps["luatroll_43_1"]			= {xml = 43, shamans = nil, bonuses = {{type = "BonusHighSpeed", x = 400, y = 180}}}
-- Checkpoints demo:
pshy.mapdb_maps["luatroll_v22_1"]			= {xml = 22, shamans = 0, bonuses = {{type = "BonusCheckpoint", x = 100, y = 330}, {type = "BonusCheckpoint", x = 700, y = 330}}}
-- Freeze bonus demo:
pshy.mapdb_maps["luatroll_v56_1"]			= {xml = 56, shamans = nil, bonuses = {{type = "BonusFreeze", x = 400, y = 210}}}
pshy.mapdb_maps[7879598]					= {xml = 7879598, shamans = 0, bonuses = {{type = "BonusFreeze", x = 273, y = 303}}}
-- Marry/Divorce bonus demo:
pshy.mapdb_maps["luatroll_v67_1"]			= {xml = 67, shamans = 0, bonuses = {{type = "BonusMarry", x = 225, y = 180}, {type = "BonusDivorce", x = 620, y = 180}}}
pshy.mapdb_maps["luatroll_v182_1"]			= {xml = 182, shamans = 0, bonuses = {{type = "BonusMarry", x = 120, y = 178}, {type = "BonusMarry", x = 680, y = 178}}}
-- Transformations bonus demo:
pshy.mapdb_maps["luatroll_v86_1"]			= {xml = 86, shamans = 0, bonuses = {{type = "BonusTransformations", x = 620, y = 180}}}
-- Ice bonus demo:
pshy.mapdb_maps[7876714]					= {xml = 7876714, shamans = nil, bonuses = {{type = "BonusIce", x = 500, y = 100}}}
-- Grow bonus demo:
pshy.mapdb_maps[7876829]					= {xml = 7876829, shamans = 0, bonuses = {{type = "BonusGrow", x = 400, y = 290}}}
-- Shrink bonus demo:
pshy.mapdb_maps[7876830]					= {xml = 7876830, shamans = nil, bonuses = {{type = "BonusShrink", x = 79, y = 68}}} -- TODO: un-hardcode ?
-- Cheese bonus demo:
pshy.mapdb_maps[7876832]					= {xml = 7876832, shamans = nil, bonuses = {{type = "BonusCheese", x = 463, y = 137}}}
pshy.mapdb_maps["luatroll_v163_1"]			= {xml = 163, shamans = nil, bonuses = {{type = "BonusCheese", x = 500, y = 255}}}
-- Pickable demo:
pshy.mapdb_maps[7876834]					= {xml = 7876834, shamans = nil, bonuses = {{type = "PickableCheese", x = 592, y = 715}, {type = "PickableCheese", x = 642, y = 715}, {type = "PickableCheese", x = 690, y = 715}, {type = "PickableCheese", x = 620, y = 693}, {type = "PickableCheese", x = 672, y = 693}, {type = "PickableCheese", x = 647, y = 670}}}
-- 6x7 demo:
pshy.mapdb_maps[7876828]					= {xml = 7876828, shamans = nil, bonuses = {{type = "CorrectCheese", x = 675, y = 131}, {type = "WrongCheese", x = 80, y = 118},  {type = "WrongCheese", x = 344, y = 123},  {type = "WrongCheese", x = 634, y = 258}}}
-- Mario flower
pshy.mapdb_maps[7879591]					= {xml = 7879591, shamans = 0, bonuses = {{type = "MarioFlower", x = 60, y = 90}}}
-- Other standard ext maps:
pshy.mapdb_maps[7882270]					= {shamans = 0}
pshy.mapdb_maps[7882268]					= {shamans = 0}
pshy.mapdb_maps[7882270]					= {shamans = 0}
pshy.mapdb_maps[7882271]					= {shamans = 0}
pshy.mapdb_maps[7882273]					= {shamans = 0}
pshy.mapdb_maps[7866073]					= {shamans = 0, title = "Aneimone - @233535 (modified)"}
pshy.mapdb_maps[7883625]					= {shamans = 0}
pshy.mapdb_maps[7883626]					= {shamans = 0}
--- Map List:
pshy.mapdb_maps_hardcoded_bonus_luamaps 	= {"luatroll_v0_1", "luatroll_v0_2", "luatroll_v161_1", "luatroll_v0_7", "luatroll_v153_1", "luatroll_v153_1", "luatroll_v0_3", "luatroll_v17_0", "luatroll_v0_4", "luatroll_v116_1", "luatroll_v0_5", "luatroll_v89_1", "luatroll_v72_1", "luatroll_v77_1", "luatroll_v98_1", "luatroll_v114_1", "luatroll_v166_1", "luatroll_v184_1", "luatroll_v186_1", "luatroll_v22_1", "luatroll_v56_1", "luatroll_v67_1", "luatroll_v182_1", "luatroll_v86_1", 7876714, 7876829, 7876830, 7876832, "luatroll_v163_1", 7876834, 7876828, 7879591, 7879598, "luatroll_68_1", "luatroll_43_1"}
pshy.mapdb_maps_ext_bonus_luamaps			= {7882268, 7882270, 7882271, 7882273, 7883625, 7883626, 7883628}
pshy.mapdb_maps_ext_bonus_luamaps_nnaaaz	= {7871785, 7844308, 7849059, 7866073}
--- Rotations:
pshy.mapdb_rotations["luamaps_bonuses"]		= {desc = "Bonus lua maps", duration = 120, troll = true, items = pshy.mapdb_maps_hardcoded_bonus_luamaps}
pshy.mapdb_rotations["luamaps_bonuses_ext"]	= {desc = "Bonus lua maps (extended)", duration = 120, troll = true, items = {}}
pshy.ListAppend(pshy.mapdb_rotations["luamaps_bonuses_ext"].items, pshy.mapdb_maps_hardcoded_bonus_luamaps)
pshy.ListAppend(pshy.mapdb_rotations["luamaps_bonuses_ext"].items, pshy.mapdb_maps_ext_bonus_luamaps)
pshy.ListAppend(pshy.mapdb_rotations["luamaps_bonuses_ext"].items, pshy.mapdb_maps_ext_bonus_luamaps_nnaaaz)
--- Pshy event eventInit().
function eventInit()
	if __IS_MAIN_MODULE__ then
		pshy.mapdb_ChatCommandRotc(nil, "luamaps_bonuses")
		tfm.exec.newGame()
	end
end
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
local new_mod = pshy.merge_ModuleBegin("pshy_bonuses_mapext.lua")
function new_mod.Content()
	local __IS_MAIN_MODULE__ = true
--- pshy_bonuses_mapext.lua
--
-- Allow maps to contain custom bonuses in the form of 
-- custom foreground invisible and non-colliding circle ground.
--
-- @require pshy_mapdb.lua
-- @require pshy_bonus_luamaps.lua
-- @require pshy_bonuses.lua
-- @require pshy_xmlmap.lua
--- Bonuses Bindings:
-- from pshy_basic_bonuses.lua
local round_bonuses			= {}
round_bonuses["F00000"]		= "BonusShrink"
round_bonuses["0000F0"]		= "BonusGrow"
round_bonuses["008080"]		= "BonusAttachBalloon"
round_bonuses["F0F0F0"]		= "BonusFly"
round_bonuses["F04040"]		= "BonusHighSpeed"
round_bonuses["F080F0"]		= "BonusShaman"
round_bonuses["804020"]		= "BonusTransformations"
round_bonuses["8080F0"]		= "BonusFreeze"
round_bonuses["4040F0"]		= "BonusIce"
round_bonuses["101010"]		= "BonusStrange"
round_bonuses["F0F000"]		= "BonusCheese"
round_bonuses["E0E0E0"]		= "BonusCheckpoint"
round_bonuses["00F000"]		= "BonusTeleporter"
round_bonuses["00F001"]		= "Teleporter"			-- sprite may change, shared lasting bonus
round_bonuses["F05040"]		= "BonusCircle"
round_bonuses["F08080"]		= "BonusMarry"
round_bonuses["F08081"]		= "BonusDivorce"
-- from pshy_misc_bonuses.lua
round_bonuses["805040"]		= "MouseTrap"
round_bonuses["E00000"]		= "GoreDeath"			-- shouldnt be used
round_bonuses["D0D000"]		= "PickableCheese"
round_bonuses["D0F000"]		= "CorrectCheese"
round_bonuses["F0D000"]		= "WrongCheese"
-- from pshy_mario_bonuses.lua
round_bonuses["4d6101"]		= "MarioCoin"
round_bonuses["4d6102"]		= "MarioMushroom"		-- not working yet
round_bonuses["4d6103"]		= "MarioFlower"
round_bonuses["4d6104"]		= "MarioCheckpoint"		-- not working yet
--- Check a ground.
local function CheckGround(ground)
	if ground["T"] == "13" and ground["L"] == "10" and ground["c"] == "4" and ground["m"] == "" then --  and ground["N"] == ""
		local bonus_color = ground["o"]
		if not bonus_color then
			print("WARNING: bad xml")
			return
		end
		local bonus_x = ground["X"]
		local bonus_y = ground["Y"]
		local bonus_type = round_bonuses[bonus_color]
		if bonus_type then
			print("adding bonus")
			pshy.bonuses_Add(bonus_type, bonus_x, bonus_y)
		end
	end
end
--- TFM event eventNewGame.
function eventNewGame()
	if pshy.xmlmap then
		print("checking objects")
		local grounds_node = pshy.xmlmap_GetGroundNode()
		assert(type(grounds_node) == "table")
		for i_ground_node, ground_node in ipairs(grounds_node.childs) do
			assert(ground_node.type == "S")
			if ground_node.type == "S" then
				CheckGround(ground_node.properties)
			end
		end
	end
end
--- Pshy event eventInit().
function eventInit()
	if __IS_MAIN_MODULE__ then
		pshy.mapdb_ChatCommandRotc(nil, "luamaps_bonuses_ext")
		tfm.exec.newGame()
	end
end
end
new_mod.Content()
pshy.merge_ModuleEnd()
pshy.merge_Finish()

