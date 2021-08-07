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
	eventInit()
	print("<vp>[PshyMerge] </vp><v>Finished loading " .. tostring(count_events) .. " events in " .. tostring(pshy.merge_standard_modules_count) .. " modules (+ " .. tostring(pshy.merge_hard_modules_count) .. " hard merged modules).</v>")
end
--- Pshy event eventInit
-- Happen when merging is finished
function eventInit()
end
pshy.tfm_events["eventInit"] = {}
table.insert(pshy.tfm_events["eventInit"], eventInit)
eventInit = nil
pshy.merge_ModuleBegin("pshy_perms.lua")
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
pshy.merge_ModuleEnd()
pshy.merge_ModuleHard("pshy_keycodes.lua")
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
pshy.merge_ModuleHard("pshy_utils_lua.lua")
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
		if str.sub(value, 1, 1) == '#' then
			value = str.sub(value, 2, #value)
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
pshy.merge_ModuleHard("pshy_utils_math.lua")
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
pshy.merge_ModuleHard("pshy_utils_tfm.lua")
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
pshy.merge_ModuleHard("pshy_utils_tables.lua")
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
pshy.merge_ModuleHard("pshy_utils_messages.lua")
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
pshy.merge_ModuleHard("pshy_utils.lua")
--- pshy_utils.lua
--
-- This module gather basic functions.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @hardmerge
-- @namespace pshy
-- @require pshy_keycodes.lua
-- @require pshy_utils_lua.lua
-- @require pshy_utils_math.lua
-- @require pshy_utils_tfm.lua
-- @require pshy_utils_tables.lua
-- @require pshy_utils_messages.lua
pshy = pshy or {}
pshy.merge_ModuleHard("pshy_rotation.lua")
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
pshy.merge_ModuleBegin("pshy_commands.lua")
--- pshy_commands.lua
--
-- This module can be used to implement in-game commands.
--
-- To give an idea of what this module makes possible, these commands could be valid:
-- "!luacall tfm.exec.explosion tfm.get.room.playerList.Pshy#3752.x tfm.get.room.playerList.Pshy#3752.y 10 10 true"
-- "!luacall tfm.exec.addShamanObject littleBox 200 300 0 0 0 false"
-- "!luacall tfm.exec.addShamanObject ball tfm.get.room.playerList.Pshy#3752.x tfm.get.room.playerList.Pshy#3752.y 0 0 0 false"
--
-- To add a command 'demo':
--   function my.function.demo(user, arg_int, arg_str)
--       print("hello " .. user .. "! " .. tostring(arg_int) .. tostring(arg_str))
--   end
--   pshy.chat_commands["demo"] = {func = my.function.demo}		-- actually, func is optional
--   pshy.chat_commands["demo"].desc = "my demo function"		-- short description
--   pshy.chat_commands["demo"].no_user = false			-- true to not pass the command user as the 1st arg
--   pshy.chat_commands["demo"].argc_min = 1				-- need at least 1 arg	
--   pshy.chat_commands["demo"].argc_max = 2				-- max args (remaining args will be considered a single one)
--   pshy.chat_commands["demo"].arg_types = {"int", "string"}	-- omit for auto (also interpret lua.path.to.value)
--   pshy.chat_commands["demo"].help = "longer help message to detail how this command works"
--   pshy.chat_command_aliases["ddeemmoo"] = "demo"			-- create an alias
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
		error("you cant use this command on other players :c")
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
			if real_command.arg_types and i <= #real_command.arg_types then
				text = text .. real_command.arg_types[i]
			else
				text = text .. "?"
			end
			if real_command.arg_names and i <= #real_command.arg_names then
				text = text .. ":" .. real_command.arg_names[i]
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
		print("[PshyCmds] Warning: command not renamed!")
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
		tfm.exec.chatMessage("<r>[PshyCmds] You cannot use this command :c</r>", user)
		return false
	end
	local command = pshy.commands_Get(command_name)
	-- non-existing command
	local command = pshy.commands_Get(command_name)
	if not command then
		if had_prefix then
			tfm.exec.chatMessage("<r>[PshyCmds] Unknown pshy command.</r>", user)
			return false
		else
			tfm.exec.chatMessage("[PshyCmds] Another module may handle that command.", user)
			return nil
		end
	end
	-- get args
	args = args_str and pshy.StrSplit(args_str, " ", command.argc_max or 32) or {} -- max command args set to 32 to prevent abuse
	--table.remove(args, 1)
	-- missing arguments
	if command.argc_min and #args < command.argc_min then
		--tfm.exec.chatMessage("<r>[PshyCmds] This command require " .. command.argc_min .. " arguments.</r>", user)
		tfm.exec.chatMessage("<r>[PshyCmds] Usage: " .. pshy.commands_GetUsage(final_command_name) .. "</r>", user)
		return false
	end
	-- too many arguments
	if command.argc_max == 0 and args_str ~= nil then
		tfm.exec.chatMessage("<r>[PshyCmds] This command do not use arguments.</r>", user)
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
		tfm.exec.chatMessage("<r>[PshyCmds] " .. tostring(rtn) .. ".</r>", user)
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
		tfm.exec.chatMessage("<r>[PshyCmds] Command failed: " .. rst .. "</r>", user)
	elseif rst == false then
		-- command function returned false
		tfm.exec.chatMessage("<r>[PshyCmds] " .. rtn .. "</r>", user)
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
pshy.merge_ModuleEnd()
pshy.merge_ModuleBegin("pshy_ui.lua")
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
pshy.merge_ModuleEnd()
pshy.merge_ModuleHard("pshy_help.lua")
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
pshy.help_pages["pshy"] = {back = "", title = "Pshy Modules (pshy_*)", text = "You may optionaly prefix pshy's commands by `pshy.`\n", subpages = {}}
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
	html = "<font size='12' color='#ddffdd'><b>" .. html .. "</b></font>"
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
pshy.merge_ModuleBegin("pshy_weather.lua")
--- pshy_weathers.lua
--
-- Add weathers.
-- A weather is an object with the folowing optional members:
--   Begin()			- Start the weather
--   Tick()			- Tick (called ms)
--   End()			- Weather end
--
-- @author Pshy
-- @namespace pshy
-- @require pshy_commands.lua
-- @require pshy_help.lua
pshy = pshy or {}
--- Module settings:
pshy.weather_auto = false	-- Change weather between rounds
--- Module's help page.
pshy.help_pages["pshy_weather"] = {back = "pshy", title = "Weather", text = "This module allow to start 'weathers'.\nIn lua, a weather is simply a table of Begin(), Tick() and End() functions.\n\nThis module does not provide weather definitions by itself. You may have to require pshy_basic_weathers or provide your own ones.\n", examples = {}, subpages = {}}
pshy.help_pages["pshy_weather"].commands = {}
pshy.help_pages["pshy_weather"].examples["weather random_object_rain"] = "Start the weather 'random_object_rain'."
pshy.help_pages["pshy_weather"].examples["luaset pshy.weather_auto"] = "Set weathers to randomly be started every map."
pshy.help_pages["pshy_weather"].examples["luaset pshy.weathers.snow nil"] = "Permanently disable the snow weather."
pshy.help_pages["pshy"].subpages["pshy_weather"] = pshy.help_pages["pshy_weather"]
--- Internal use:
pshy.weathers = {}			-- loaded weathers
pshy.active_weathers = {}	-- active weathers
pshy.next_weather_time = 0
--- Random TFM objects
-- List of objects for random selection.
pshy.random_objects = {}
table.insert(pshy.random_objects, 1) -- little box
table.insert(pshy.random_objects, 2) -- box
table.insert(pshy.random_objects, 3) -- little board
table.insert(pshy.random_objects, 6) -- ball
table.insert(pshy.random_objects, 7) -- trampoline
table.insert(pshy.random_objects, 10) -- anvil
table.insert(pshy.random_objects, 17) -- cannon
table.insert(pshy.random_objects, 33) -- chicken
table.insert(pshy.random_objects, 39) -- apple
table.insert(pshy.random_objects, 40) -- sheep
table.insert(pshy.random_objects, 45) -- little board ice
table.insert(pshy.random_objects, 54) -- ice cube
table.insert(pshy.random_objects, 68) -- triangle
table.insert(pshy.random_objects, 85) -- rock
--- Get a random TFM object
function pshy.RandomTFMObjectId()
	return pshy.random_objects[math.random(1, #pshy.random_objects)]
end
--- Spawn a random TFM object in the sky.
function pshy.SpawnRandomTFMObject()
	tfm.exec.addShamanObject(pshy.RandomTFMObjectId(), math.random(200, 600), -60, math.random(0, 359), 0, 0, math.random(0, 8) == 0)
end
--- Change the weather
-- @param new_weather_names List of new weathers.
function pshy.Weather(new_weather_names)
	local new_weathers = {}
	for i, weather_name in ipairs(new_weather_names) do
		if weather_name ~= "clear" and not pshy.weathers[weather_name] then
			error("invalid weather " .. weather_name)
		end
		new_weathers[weather_name] = pshy.weathers[weather_name]
		if not pshy.active_weathers[weather_name] then
			if new_weathers[weather_name].Begin then
				new_weathers[weather_name].Begin()
			end
		end
	end
	for weather_name, weather in pairs(pshy.active_weathers) do
		if not new_weathers[weather_name] then
			if weather.End then 
				weather.End() 
			end
		end
	end
	pshy.active_weathers = new_weathers
end
--- events
function eventNewGame()
	pshy.next_weather_time = 0
	if pshy.weather_auto then
		pshy.Weather({})
		pshy.Weather({pshy.LuaRandomTableKey(pshy.weathers)})
	end
end
--- TFM loop event
function eventLoop(currentTime, timeRemaining)
	if pshy.next_weather_time < currentTime then
		pshy.next_weather_time = pshy.next_weather_time + 500 -- run Tick() every 500 ms only
		for weather_name, weather in pairs(pshy.active_weathers) do
			if weather.Tick then
				weather.Tick()
			end
		end
	end
end
--- !weather [weathers...]
function pshy.ChatCommandWeather(...)
	new_weather_names = {...}
	pshy.Weather(new_weather_names)
end
pshy.chat_commands["weather"] = {func = pshy.ChatCommandWeather, desc = "Set the active weathers. No argument == 'clear'.", no_user = true, argc_min = 0, argc_max = 4, arg_types = {"string", "string", "string", "string"}}
pshy.help_pages["pshy_weather"].commands["weather"] = pshy.chat_commands["weather"]
pshy.merge_ModuleEnd()
pshy.merge_ModuleBegin("pshy_scores.lua")
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
pshy.merge_ModuleEnd()
pshy.merge_ModuleBegin("pshy_mapdb.lua")
--- pshy_mapdb.lua
--
-- Handle advanced map features and rotations.
-- Override `tfm.exec.newGame` for easy usage.
--
-- This script may list maps from other authors.
--
-- Listed map and rotation tables can have the folowing fields:
--	- func_begin (map only): Function to run when the map started.
--	- func_end (map only): Function to run when the map stopped.
--	- func_replace (map only): Function to run on the rotation item to get the final map.
--	- autoskip: If true, the map will change at the end of the timer.
--	- duration: Duration of the map.
--
-- @author: TFM:Pshy#3752 DC:Pshy#7998 (script)
-- @require pshy_commands.lua
-- @require pshy_help.lua
-- @require pshy_rotation.lua
--- Module Help Page:
pshy.help_pages["pshy_mapdb"] = {back = "pshy", title = "Custom maps and rotations.\n", text = "Includes maps from <ch>Nnaaaz#0000</ch>\nIncludes maps from <ch>Pshy#3752</ch>\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_mapdb"] = pshy.help_pages["pshy_mapdb"]
--- Module Settings:
pshy.mapdb_default = "default"			-- default rotation, can be a rotation of rotations
pshy.mapdb_maps = {}					-- map of maps
pshy.mapdb_rotations = {}				-- map of rotations
pshy.mapdb_rotations["default"]			= {hidden = true, items = {}}					-- default rotation, can only use other rotations, no maps
pshy.mapdb_default_rotation 			= pshy.mapdb_rotations["default"]				--
--- Defaults/Examples:
--pshy.mapdb_maps["pshy_first_troll"] = {author = "Pshy#3752", func_begin = nil, func_end = nil, func_replace = nil, xml = '<C><P F="0" /><Z><S><S H="250" X="400" L="100" Y="275" c="3" P="0,0,0.3,0.2,0,0,0,0" T="5" /><S H="250" X="430" L="30" Y="290" c="1" P="1,0,0,1.2,0,0,0,0" T="2" /><S H="250" L="30" Y="290" c="1" X="370" P="1,0,0,1.2,0,0,0,0" T="2" /><S X="400" L="10" Y="392" H="10" P="0,0,0,14.0,0,0,0,0" T="2" /><S X="406" L="10" Y="184" H="10" P="1,0,0,0.2,0,0,5,0" T="1" /><S X="394" L="10" Y="184" H="10" P="1,0,0,0.2,0,0,5,0" T="1" /><S X="400" L="10" Y="170" H="10" P="0,0,0,1.2,0,0,0,0" T="2" /><S X="400" L="98" Y="156" H="10" P="0,0,0.3,0.2,0,0,0,0" T="0" /><S X="400" L="100" Y="275" c="4" H="250" P="0,0,0.3,0.2,0,0,0,0" T="6" /></S><D><DS X="435" Y="134" /><DC X="367" Y="133" /><T X="400" Y="148" /><F X="312" Y="358" /><F X="484" Y="357" /></D><O><O C="11" X="430" P="0" Y="410" /><O C="11" X="370" P="0" Y="410" /></O></Z></C>'}
--pshy.mapdb_rotations["pshy_troll_maps"] = {items = "pshy_first_troll"}
--- Rotations.
-- Basics:
pshy.mapdb_rotations["standard"]				= {desc = "P0", duration = 120, items = {"#0"}}
pshy.mapdb_rotations["protected"]				= {desc = "P1", duration = 120, items = {"#1"}}
pshy.mapdb_rotations["mechanisms"]				= {desc = "P6", duration = 120, items = {"#6"}}
pshy.mapdb_rotations["nosham"]					= {desc = "P7", duration = 60, items = {"#7"}}
pshy.mapdb_rotations["racing"]					= {desc = "P17", duration = 60, items = {"#17"}}
pshy.mapdb_rotations["defilante"]				= {desc = "P18", duration = 60, items = {"#18"}}
pshy.mapdb_rotations["vanilla"]					= {hidden = true, desc = "1-210", duration = 120, items = {}} for i = 0, 210 do table.insert(pshy.mapdb_rotations["vanilla"].items, i) end
pshy.mapdb_rotations["nosham_vanilla"]			= {desc = "1-210*", duration = 60, items = {"2", "8", "11", "12", "14", "19", "22", "24", "26", "27", "28", "30", "31", "33", "40", "41", "44", "45", "49", "52", "53", "55", "57", "58", "59", "61", "62", "65", "67", "69", "70", "71", "73", "74", "79", "80", "85", "86", "89", "92", "96", "100", "117", "119", "120", "121", "123", "126", "127", "138", "142", "145", "148", "149", "150", "172", "173", "174", "175", "176", "185", "189"}}
-- Nnaaaz#0000:
pshy.mapdb_rotations["nosham_troll"]			= {hidden = true, desc = "Nnaaaz#0000", duration = 60, items = {"@7781189", "@7781560", "@7782831", "@7783745", "@7787472", "@7814117", "@7814126", "@7814248", "@7814488", "@7817779"}}
pshy.mapdb_rotations["racing_troll"]			= {hidden = true, desc = "Nnaaaz#0000", duration = 60, items = {"@7781575", "@7783458", "@7783472", "@7784221", "@7784236", "@7786652", "@7786707", "@7786960", "@7787034", "@7788567", "@7788596", "@7788673", "@7788967", "@7788985", "@7788990", "@7789010", "@7789484", "@7789524", "@7790734", "@7790746", "@7790938", "@7791293", "@7791550", "@7791709", "@7791865", "@7791877", "@7792434", "@7765843", "@7794331", "@7794726", "@7792626", "@7794874", "@7795585", "@7796272", "@7799753", "@7800330", "@7800998", "@7801670", "@7805437", "@7792149", "@7809901", "@7809905", "@7810816", "@7812751", "@7789538", "@7813075", "@7813248", "@7814099", "@7819315", "@7815695", "@7815703", "@7816583", "@7816748", "@7817111", "@7782820"}}
pshy.mapdb_rotations["nosham_vanilla_troll"]	= {hidden = true, desc = "Nnaaaz#0000", duration = 60, items = {"@7801848", "@7801850", "@7802588", "@7802592", "@7803100", "@7803618", "@7803013", "@7803900", "@7804144", "@7804211"}} -- https://atelier801.com/topic?f=6&t=892706&p=1
-- Misc:
pshy.mapdb_rotations["nosham_mechanisms"]		= {desc = nil, duration = 60, items = {"@1919402", "@7264140", "@1749725", "@176936", "@3514715", "@3150249", "@3506224", "@2030030", "@479001", "@3537313", "@1709809", "@169959", "@313281", "@2868361", "@73039", "@73039", "@2913703", "@2789826", "@298802", "@357666", "@1472765", "@271283", "@3702177", "@2355739", "@4652835", "@164404", "@7273005", "@3061566", "@3199177", "@157312", "@7021280", "@2093284", "@5752223", "@7070948", "@3146116", "@3613020", "@1641262", "@119884", "@3729243", "@1371302", "@6854109", "@2964944", "@3164949", "@149476", "@155262", "@6196297", "@1789012", "@422271", "@3369351", "@3138985", "@3056261", "@5848606", "@931943", "@181693", "@227600", "@2036283", "@6556301", "@3617986", "@314416", "@3495556", "@3112905", "@1953614", "@2469648", "@3493176", "@1009321", "@221535", "@2377177", "@6850246", "@5761423", "@211171", "@1746400", "@1378678", "@246966", "@2008933", "@2085784", "@627958", "@1268022", "@2815209", "@1299248", "@6883670", "@3495694", "@4678821", "@2758715", "@1849769", "@3155991", "@6555713", "@3477737", "@873175", "@141224", "@2167410", "@2629289", "@2888435", "@812822", "@4114065", "@2256415", "@3051008", "@7300333", "@158813", "@3912665", "@6014154", "@163756", "@3446092", "@509879", "@2029308", "@5546337", "@1310605", "@1345662", "@2421802", "@2578335", "@2999901", "@6205570", "@7242798", "@756418", "@2160073", "@3671421", "@5704703", "@3088801", "@7092575", "@3666756", "@3345115", "@1483745", "@3666745", "@2074413", "@2912220", "@3299750"}}
pshy.mapdb_rotations["nosham_simple"]			= {desc = nil, duration = 120, items = {"@1378332", "@485523", "@7816865", "@763608", "@1616913", "@383202", "@2711646", "@446656", "@815716", "@333501", "@7067867", "@973782", "@763961", "@7833293", "@7833270", "@7833269", "@7815665", "@7815151", "@7833288", "@1482492", "@1301712", "@6714567", "@834490", "@712905", "@602906", "@381669", "@4147040", "@564413", "@504951", "@1345805", "@501364"}} -- soso @1356823 @2048879 @2452915 @2751980
pshy.mapdb_rotations["nosham_traps"]			= {desc = nil, duration = 120, items = {"@297063", "@5940448", "@2080757", "@7453256", "@203292", "@108937", "@445078", "@133916", "@7840661", "@115767", "@2918927", "@4684884", "@2868361", "@192144", "@73039", "@1836340", "@726048"}}
pshy.mapdb_rotations["nosham_coop"]				= {desc = nil, duration = 120, items = {"@169909", "@209567", "@273077", "@7485555", "@2618581", "@133916", "@144888", "@1991022", "@7247621", "@3591685", "@6437833", "@3381659", "@121043", "@180468", "@220037", "@882270", "@3265446"}}
-- vanillart? @3624983 @2958393 @624650 @635128 @510084 @7404832
-- coop ?:		@1327222 @161177 @3147926 @3325842
-- troll traps:	@75050 @923485
-- sham troll: @3659540
-- almost vanilla sham: @3688504 @2013190
-- lol: @7466942 @696995 @4117469
-- almost lol: @7285161 @1408189
-- sham traps: @171290 @453115
--- Internal Use:
pshy.mapdb_current_map_name = nil
pshy.mapdb_current_map = nil
pshy.mapdb_current_map_autoskip = false
pshy.mapdb_current_map_duration = 60
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
	--print("called pshy.mapdb_newGame " .. tostring(mapcode))
	pshy.mapdb_EndMap()
	pshy.mapdb_event_new_game_triggered = false
	return pshy.mapdb_Next(mapcode)
end
pshy.mapdb_tfm_newGame = tfm.exec.newGame
tfm.exec.newGame = pshy.mapdb_newGame
--- End the previous map.
-- @private
function pshy.mapdb_EndMap()
	if pshy.mapdb_current_map and pshy.mapdb_current_map.func_end then
		pshy.mapdb_current_map.func_end(pshy.mapdb_current_map_name)
	end
	pshy.mapdb_current_map_name = nil
	pshy.mapdb_current_map = nil
	pshy.mapdb_current_map_autoskip = nil
	pshy.mapdb_current_map_duration = nil
	pshy.mapdb_current_rotations_names = {}
end
--- Setup the next map (possibly a rotation), calling newGame.
-- @private
function pshy.mapdb_Next(mapcode)
	--print("called pshy.mapdb_Next " .. tostring(mapcode))
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
		return pshy.mapdb_tfm_newGame(mapcode)
	end
	--if #mapcode > 32 then
	--	-- probably an xml
	--	return pshy.mapdb_tfm_newGame(mapcode)
	--end
	return pshy.mapdb_tfm_newGame(mapcode)
end
--- pshy.mapdb_newGame but only for maps listed to this module.
-- @private
function pshy.mapdb_NextDBMap(map_name)
	--print("called pshy.mapdb_NextDBMap " .. tostring(mapcode))
	local map = pshy.mapdb_maps[map_name]
	if map.autoskip ~= nil then
		pshy.mapdb_current_map_autoskip = map.autoskip 
	end
	if map.duration ~= nil then
		pshy.mapdb_current_map_duration = map.duration 
	end
	pshy.mapdb_current_map_name = map_name
	pshy.mapdb_current_map = map
	local map_xml
	if map.xml then
		map_xml = map.xml
	else
		map_xml = map_name
	end
	if map.func_replace then
		map_xml = map.func_replace(map.xml)
	end
	return pshy.mapdb_tfm_newGame(map_xml)
end
--- pshy.mapdb_newGame but only for rotations listed to this module.
-- @private
function pshy.mapdb_NextDBRotation(rotation_name)
	--print("called pshy.mapdb_NextDBRotation " .. tostring(mapcode))
	if pshy.mapdb_current_rotations_names[rotation_name] then
		print("<r>/!\\ Cyclic map rotation! Going to nil!</r>")
		return pshy.mapdb_tfm_newGame(nil)
	end
	pshy.mapdb_current_rotations_names[rotation_name] = true
	local rotation = pshy.mapdb_rotations[rotation_name]
	if rotation.autoskip ~= nil then
		pshy.mapdb_current_map_autoskip = rotation.autoskip 
	end
	if rotation.duration ~= nil then
		pshy.mapdb_current_map_duration = rotation.duration 
	end
	pshy.mapdb_current_rotation_name = rotation_name
	pshy.mapdb_current_rotation = rotation
	local next_map_name = pshy.rotation_Next(rotation)
	return pshy.mapdb_Next(next_map_name)
end
--- TFM event eventNewGame.
function eventNewGame()
	if not pshy.mapdb_event_new_game_triggered then
		if pshy.mapdb_current_map and pshy.mapdb_current_map.func_begin then
			pshy.mapdb_current_map.func_begin(pshy.mapdb_current_map_name)
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
--- !rotations
function pshy.mapdb_ChatCommandRotations(user)
	pshy.Answer("Available rotations:", user)
	for rot_name, rot in pairs(pshy.mapdb_rotations) do
		if rot ~= pshy.mapdb_default_rotation then
			local count = pshy.TableCountValue(pshy.mapdb_default_rotation.items, rot_name)
			local s = ((count > 0) and "<vp>" or "<fc>")
			s = s .. ((count > 0) and ("<b> ⚖ " .. tostring(count) .. "</b> \t") or "  - \t\t") .. rot_name
			s = s .. ((count > 0) and "</vp>" or "</fc>")
			s = s ..  "\t - " .. tostring(rot.desc) .. " (" .. #rot.items .. "#)"
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
pshy.merge_ModuleEnd()
pshy.merge_ModuleBegin("pshy_emoticons.lua")
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
pshy.merge_ModuleEnd()
pshy.merge_ModuleHard("pshy_lua_commands.lua")
--- Pshy basic commands module
--
-- This submodule add the folowing commands:
--   !(lua)get <path.to.variable>					- get a lua value
--   !(lua)set <path.to.variable> <new_value>		- set a lua value
--   !(lua)setstr <path.to.variable> <new_value>	- set a lua string value
--   !(lua)call <path.to.function> [args...]		- call a lua function
--
-- Additionally, when using the pshy_perms module:
--   !addadmin NewAdmin#0000			- add NewAdmin#0000 as an admin
--      equivalent `!luaset pshy.admins.NewAdmin#0000 true`
--
-- Additionally, this add a command per function in tfm.exec.
--
-- @author Pshy
-- @hardmerge
-- @namespace pshy
-- @require pshy_commands.lua
-- @require pshy_help.lua
--- Module Help Page:
pshy.help_pages["pshy_lua_commands"] = {back = "pshy", title = "Lua Commands", text = "Commands to interact with lua.\n", examples = {}}
pshy.help_pages["pshy_lua_commands"].commands = {}
pshy.help_pages["pshy_lua_commands"].examples["luacall tfm.exec.respawnPlayer " .. pshy.loader] = "Respawn " .. pshy.loader .. "."
pshy.help_pages["pshy_lua_commands"].examples["luacall tfm.exec.movePlayer Player#0000 tfm.get.room.playerList." .. pshy.loader .. ".x" .. "  tfm.get.room.playerList." .. pshy.loader .. ".y"] = "Teleport Player#0000 to yourself."
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
pshy.merge_ModuleBegin("pshy_tfm_commands.lua")
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
	target = pshy.commands_GetTarget(user, target, "!playerscore")
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
	tfm.exec.disableChatCommandDisplay(nil, not display)
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
pshy.merge_ModuleEnd()
pshy.merge_ModuleBegin("pshy_fun_commands.lua")
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
pshy.merge_ModuleEnd()
pshy.merge_ModuleBegin("pshy_fcplatform.lua")
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
pshy.help_pages["pshy_fcplatform"] = {back = "pshy", title = "FC Platform",text = "This module add a platform you can teleport on to spectate.\nThe players on the platform move with it.\n", examples = {}}
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
pshy.merge_ModuleEnd()
pshy.merge_ModuleHard("pshy_basic_weathers.lua")
--- pshy_basic_weathers.lua
--
-- Some basic weathers.
--
-- @cf pshy_weather.lua
-- @author Pshy
-- @require pshy_weather.lua
-- @require pshy_utils.lua
-- @hardmerge
-- @namespace pshy
pshy = pshy or {}
--- Random Rain weather
pshy.weathers.random_object_rain = {}
function pshy.weathers.random_object_rain.Begin()
	pshy.weathers.random_object_rain.object_type_id = pshy.RandomTFMObjectId()
	pshy.weathers.random_object_rain.spawned_object_ids = {}
end
function pshy.weathers.random_object_rain.Tick()
	local self = pshy.weathers.random_object_rain
	if math.random(0, 2) == 0 then 
		local new_id = tfm.exec.addShamanObject(self.object_type_id, math.random(0, 800), -60, math.random(0, 359), 0, 0, math.random(0, 8) == 0)
		table.insert(self.spawned_object_ids, new_id)
	end
	if #self.spawned_object_ids > 8 then
		tfm.exec.removeObject(table.remove(self.spawned_object_ids, 1))
	end
end
function pshy.weathers.random_object_rain.End()
	for i, id in ipairs(pshy.weathers.random_object_rain.spawned_object_ids) do
		tfm.exec.removeObject(id)
	end
	pshy.weathers.random_object_rain.spawned_object_ids = {}
end
--- Snow weather
pshy.weathers.snow = {}
function pshy.weathers.snow.Tick()
	tfm.exec.snow(2, 10)
end
pshy.merge_ModuleBegin("pshy_motd.lua")
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
--- !clear
function pshy.ChatCommandClear(user)
	tfm.exec.chatMessage("\n\n\n\n\n\n\n\n\n\n\n\n\n", nil)
end
pshy.chat_commands["clear"] = {func = pshy.ChatCommandClear, desc = "clear the chat for everone", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_motd"].commands["clear"] = pshy.chat_commands["clear"]
pshy.perms.admins["!clear"] = true
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
pshy.merge_ModuleEnd()
pshy.merge_ModuleHard("pshy_nicks.lua")
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
pshy.merge_ModuleBegin("pshy_teams.lua")
--- pshy_teams.lua
--
-- Implement team features.
--
-- @author pshy
-- @require pshy_help.lua
-- @require pshy_scores.lua
-- @require pshy_mapdb.lua
-- @namespace pshy
--- Help page:
pshy.help_pages["pshy_teams"] = {back = "pshy", title = "Teams", text = "This module adds team features.\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_teams"] = pshy.help_pages["pshy_teams"]
--- Module settings:
pshy.teams_auto = true					-- automatically players in a team
pshy.teams_rejoin = true				-- players leaving a team will rejoin the same one
pshy.teams_target_score = 10				-- score a team must reach to win
pshy.teams_alternate_scoreboard_ui_arbitrary_id = 768 --
pshy.teams_use_map_name = true
local EMPTY_MAP = [[<C><P /><Z><S /><D /><O /></Z></C>]]
local EMPTY_MAP_PLUS = [[<C><P mc="" Ca="" /><Z><S /><D /><O /></Z></C>]]
local PSHY_WIN_MAP_1 = [[<C><P F="2" /><Z><S><S X="42" o="f8331" L="38" Y="343" H="10" P="0,0,0.0,1.2,30,0,0,0" T="12" /><S X="400" L="2000" Y="400" H="36" P="0,0,,,,0,0,0" T="9" /><S X="400" L="80" Y="110" c="1" H="20" P="0,0,0.3,0,0,0,0,0" T="10" /><S X="400" L="80" Y="250" c="4" H="300" P="0,0,0.3,0,0,0,0,0" T="10" /><S X="400" L="400" Y="400" H="200" P="0,0,0.3,0.2,-10,0,0,0" T="6" /><S X="312" L="120" Y="403" H="200" P="0,0,0.3,0.2,-20,0,0,0" T="6" /><S X="625" L="120" Y="400" H="200" P="0,0,0.3,0.2,10,0,0,0" T="6" /><S X="74" o="324650" L="70" Y="117" H="10" P="0,0,0.3,0.2,0,0,0,0" T="12" /></S><D><P X="602" P="1,0" T="5" Y="299" /><DS X="538" Y="242" /><DC X="398" Y="72" /><P X="216" P="0,0" T="2" Y="331" /><P X="540" P="0,0" T="1" Y="277" /><F X="384" Y="96" /><F X="399" Y="87" /><F X="414" Y="95" /><P X="666" P="0,0" T="252" Y="310" /><P X="468" P="0,0" T="254" Y="288" /><P X="347" P="0,1" T="254" Y="310" /><P X="160" P="0,0" T="249" Y="399" /><P X="81" P="0,1" T="249" Y="403" /><P X="110" P="0,0" T="250" Y="401" /><P X="484" P="0,0" T="230" Y="284" /><P X="17" P="1,0" T="251" Y="400" /><P X="64" P="1,0" T="217" Y="111" /></D><O /></Z></C>]]
pshy.teams_win_map = "teams_win" 			-- win map name
--- Pshy Settings:
pshy.scores_per_first_wins[1] = 1		-- the first earns a point
--- Internal Use:
pshy.teams = {}								-- teams (team_name -> {name, player_names (set of player names), color (hex string), score (number)})
pshy.teams_players_team = {}				-- map of player name -> team reference in wich they are
pshy.teams_winner_name = nil				-- becomes the winning team name (indicates that the next round should be for the winner)
pshy.teams_have_played_winner_round = false	-- indicates that the round for the winner has already started
--- pshy event eventTeamWon(team_name)
function eventTeamWon(team_name)
	pshy.teams_winner_name = team_name
	local team = pshy.teams[team_name]
	tfm.exec.setGameTime(8, true)
	pshy.Title("<br><font size='64'><b><p align='center'>Team <font color='#" .. team.color .. "'>" .. team_name .. "</font> wins!</p></b></font>")
	pshy.teams_have_played_winner_round = false
	pshy.mapdb_SetNextMap(pshy.teams_win_map)
end
--- Get a string line representing the teams scores
function pshy.TeamsGetScoreLine()
	local leading = pshy.TeamsGetWinningTeam()
	local text = "<g>"
	for team_name, team in pairs(pshy.teams) do
		if #text > 3 then
			text = text .. " - "
		end
		text = text .. ((leading and leading.name == team_name) and "<b>" or "")
		text = text .. "<font color='#" .. team.color .. "'>" 
		text = text .. team.name .. ": " .. tostring(team.score)
		text = text .. "</font>"
		text = text .. ((leading and leading.name == team_name) and "</b>" or "")
	end
	text = text .. "  |  GOAL: " .. tostring(pshy.teams_target_score) .. "</g>"
	return text
end
--- Update the teams scoreboard
-- @brief player_name optional player name who will see the changes
function pshy.TeamsUpdateScoreboard(player_name)
	local text = pshy.TeamsGetScoreLine()
	if pshy.TableCountKeys(pshy.teams) <= 4 then
		ui.removeTextArea(pshy.teams_alternate_scoreboard_ui_arbitrary_id, nil)
		ui.setMapName(pshy.TeamsGetScoreLine())
	else
		text = "<p align='left'>" .. text .. "</p>"
		ui.addTextArea(pshy.teams_alternate_scoreboard_ui_arbitrary_id, text, player_name, 0, 20, 800, 0, 0, 0, 1.0, false)
	end
end
--- Add a new active team.
-- @param name The team's name.
-- @param hex_color A hex string representing the team color (without # or 0x).
function pshy.TeamsAddTeam(name, hex_color)
	local new_team = {}
	new_team.name = name
	new_team.color = hex_color
	new_team.score = 0
	new_team.player_names = {}
	pshy.teams[name] = new_team
end
--- Remove all players from teams.
function pshy.TeamsReset(count)
	-- optional new team count
	count = count or 2
	assert(count > 0)
	assert(count <= #pshy.teams_default)
	-- clear
	pshy.teams = {}
	pshy.teams_players_team = {}
	-- add default teams
	for i_team = 1, count do
		pshy.TeamsAddTeam(pshy.teams_default[i_team].name, pshy.teams_default[i_team].color)
	end
end
pshy.teams_default = {}					-- default teams list
pshy.teams_default[1] = {name = "Red", color = "ff7777"} -- Edam
pshy.teams_default[2] = {name = "Green", color = "77ff77"} -- Roquefort
pshy.teams_default[3] = {name = "Blue", color = "77aaff"} -- Blue
pshy.teams_default[4] = {name = "Yellow", color = "ffff77"} -- Gouda -- Emmental -- Camembert
pshy.teams_default[5] = {name = "Magenta", color = "ff77ff"} -- Gorgonzola
pshy.teams_default[7] = {name = "Cyan", color = "77ffff"}
pshy.teams_default[8] = {name = "Purple", color = "aa77ff"}
pshy.teams_default[6] = {name = "Orange", color = "ffaa77"} -- Cheddar
--- Reset teams scores
function pshy.TeamsResetScores()
	for team_name, team in pairs(pshy.teams) do
		team.score = 0
	end
end
--- Get the team {} with the highest score, or nil on draw
function pshy.TeamsGetWinningTeam()
	local winning = nil
	local draw = false
	for team_name, team in pairs(pshy.teams) do
		if winning and team.score == winning.score then
			draw = true
		elseif not winning or team.score > winning.score then 
			winning = team
			draw = false
		end
	end
	return (not draw) and winning or nil
end
--- Get one of the teams {} with the fewest players in
function pshy.TeamsGetUndernumerousTeam()
	local undernumerous = nil
	for team_name, team in pairs(pshy.teams) do
		if not undernumerous or pshy.TableCountKeys(team.player_names) < pshy.TableCountKeys(undernumerous.player_names) then
			undernumerous = team
		end
	end
	return undernumerous
end
--- Remove players from teams
function pshy.TeamsClearPlayers()
	for team_name, team in pairs(pshy.teams) do
		team.player_names = {}
	end
	pshy.teams_players_team = {}
end
--- Add a player to a team.
-- The player is also removed from other teams.
-- @team_name The player's team name.
-- @player_name The player's name.
function pshy.TeamsAddPlayer(team_name, player_name)
	local team = pshy.teams[team_name]
	assert(type(team) == "table")
	-- unjoin current team
	if pshy.teams_players_team[player_name] then
		pshy.teams_players_team[player_name].player_names[player_name] = nil
	end
	-- join new team
	team.player_names[player_name] = true
	pshy.teams_players_team[player_name] = team
	tfm.exec.setNameColor(player_name, team and tonumber(team.color, 16) or 0xff7777)
end
--- Update player's nick color
function pshy.TeamsRefreshNamesColor()
	for player_name, team in pairs(pshy.teams_players_team) do
		tfm.exec.setNameColor(player_name, tonumber(team.color, 16))
	end
end
--- Shuffle teams
-- Randomly set players in a single team.
function pshy.TeamsShuffle()
	pshy.TeamsClearPlayers()
	local unassigned_players = {}
	for player_name, player in pairs(tfm.get.room.playerList) do
		table.insert(unassigned_players, player_name)
	end
	while #unassigned_players > 0 do
		for team_name, team in pairs(pshy.teams) do
			if #unassigned_players > 0 then
				local player_name = table.remove(unassigned_players, math.random(1, #unassigned_players))
				pshy.TeamsAddPlayer(team_name, player_name)
			end
		end
	end
end
--- pshy event eventPlayerScore
function eventPlayerScore(player_name, score)
	local team = pshy.teams_players_team[player_name]
	if team then
		team.score = team.score + score
		pshy.TeamsUpdateScoreboard()
		if not pshy.teams_winner_name and team.score >= pshy.teams_target_score then
			eventTeamWon(team.name)
		end
	end
end
--- TFM event eventNewPlayer
function eventNewPlayer(player_name)
	if pshy.TableCountKeys(pshy.teams) > 0 and pshy.teams_auto then
		local team = nil
		-- default team is the previous one
		if pshy.teams_rejoin then
			team = pshy.teams_players_team[player_name]
		end
		-- get either the previous team or an undernumerous one
		if not team then
			team = pshy.TeamsGetUndernumerousTeam()
		end
		pshy.TeamsAddPlayer(team.name, player_name)
	end
	pshy.TeamsUpdateScoreboard(player_name)
end
--- TFM event eventPlayerLeft
-- Remove the player from the team list when he leave, but still remember his previous team
function eventPlayerLeft(player_name)
	local team = pshy.teams_players_team[player_name]
	if team then
		team.player_names[player_name] = nil
	end
end
--- TFM event eventPlayerWon.
function eventPlayerWon(player_name)
	tfm.exec.setGameTime(5, false)
end
--- TFM event eventPlayerDied.
function eventPlayerDied(player_name)
	if pshy.CountPlayersAlive() == 0 then
		tfm.exec.setGameTime(5, false)
	end
end
--- TFM event eventNewGame
function eventNewGame()
	if pshy.teams_winner_name then
		if not pshy.teams_have_played_winner_round then
			-- winner round
			pshy.teams_have_played_winner_round = true
			tfm.exec.setGameTime(13, true)
			local winner_team = pshy.teams[pshy.teams_winner_name]
			for player_name, void in pairs(winner_team.player_names) do
				tfm.exec.setShaman(player_name, true)
			end
			pshy.Title(nil)
			pshy.mapdb_SetNextMap("lobby")
		else
			-- first round of new match
			pshy.teams_winner_name = nil
			pshy.teams_have_played_winner_round = false
			pshy.TeamsResetScores()
			pshy.Title(nil)
		end
	end
	pshy.TeamsRefreshNamesColor()
	pshy.TeamsUpdateScoreboard()
end
--- Replace #ff0000 by the winner team color
function pshy.TeamsReplaceRedToWinningColor(map)
	local winner_team = pshy.teams[pshy.teams_winner_name]
	return string.gsub(map, "ff0000", winner_team.color)
end
--- Initialization
-- winner maps rotation:
pshy.mapdb_maps["teams_win_1"] = {author = "Pshy#3752", func_begin = nil, func_end = nil, func_replace = pshy.TeamsReplaceRedToWinningColor, xml = '<C><P Ca="" mc="" /><Z><S><S X="100" o="0" L="150" Y="320" c="3" H="30" P="1,0,0.3,0.2,0,0,0,0" T="12" /><S X="0" o="ff0000" L="300" Y="400" H="300" P="0,0,0.3,0.2,45,0,0,0" T="12" /><S X="700" o="0" L="150" Y="320" c="3" H="30" P="1,0,0.3,0.2,0,0,0,0" T="12" /><S X="-20" L="20" Y="-400" H="1600" P="0,0,0.3,0,0,0,0,0" T="19" /><S X="820" L="20" Y="-400" H="1600" P="0,0,0.3,0,0,0,0,0" T="19" /><S X="800" o="ff0000" L="300" Y="400" H="300" P="0,0,0.3,0.2,45,0,0,0" T="12" /><S X="400" o="0" L="200" Y="250" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /><S X="400" o="ff0000" L="100" Y="100" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /></S><D><DC X="400" Y="82" /><DS X="400" Y="229" /></D><O><O C="13" X="700" P="0" Y="320" /><O C="12" X="100" P="0" Y="320" /></O></Z></C>'}
pshy.mapdb_maps["teams_win_2"] = {author = "Pshy#3752", func_begin = nil, func_end = nil, func_replace = pshy.TeamsReplaceRedToWinningColor, xml = '<C><P Ca="" mc="" /><Z><S><S X="530" o="0" L="150" Y="330" c="3" H="30" P="1,0,0.3,0.2,0,0,0,0" T="12" /><S X="270" o="0" L="150" Y="330" c="3" H="30" P="1,0,0.3,0.2,0,0,0,0" T="12" /><S X="-20" L="20" Y="-400" H="1600" P="0,0,0.3,0,0,0,0,0" T="19" /><S X="820" L="20" Y="-400" H="1600" P="0,0,0.3,0,0,0,0,0" T="19" /><S X="400" o="ff0000" L="300" Y="400" H="300" P="0,0,0.3,0.2,0,0,0,0" T="12" /><S X="400" o="ff0000" L="100" Y="100" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /><S X="80" o="0" L="150" Y="190" c="3" H="20" P="0,0,0.3,0.2,10,0,0,0" T="12" /><S X="720" o="0" L="150" Y="190" c="3" H="20" P="0,0,0.3,0.2,-10,0,0,0" T="12" /></S><D><DC X="400" Y="85" /><DS X="400" Y="245" /></D><O><O C="13" X="270" P="0" Y="330" /><O C="12" X="530" P="0" Y="330" /></O></Z></C>'}
pshy.mapdb_maps["teams_win_3"] = {author = "Pshy#3752", func_begin = nil, func_end = nil, func_replace = pshy.TeamsReplaceRedToWinningColor, xml = '<C><P Ca="" mc="" /><Z><S><S X="250" o="0" L="150" Y="300" c="3" H="30" P="1,0,0.3,0.2,0,0,0,0" T="12" /><S X="-20" L="20" Y="-400" H="1600" P="0,0,0.3,0,0,0,0,0" T="19" /><S X="540" o="0" L="150" Y="300" c="3" H="30" P="1,0,0.3,0.2,0,0,0,0" T="12" /><S X="820" L="20" Y="-400" H="1600" P="0,0,0.3,0,0,0,0,0" T="19" /><S X="690" o="ff0000" L="300" Y="400" H="300" P="0,0,0.3,0.2,-10,0,0,0" T="12" /><S X="700" o="0" L="100" Y="100" c="3" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /><S X="110" o="ff0000" L="300" Y="400" H="300" P="0,0,0.3,0.2,10,0,0,0" T="12" /><S X="100" o="0" L="100" Y="100" c="3" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /><S X="400" o="ff0000" L="150" Y="150" c="1" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /></S><D><DC X="700" Y="85" /><DS X="100" Y="85" /></D><O><O C="13" X="540" P="0" Y="300" /><O C="12" X="260" P="0" Y="300" /></O></Z></C>'}
pshy.mapdb_maps["teams_win_4"] = {author = "Pshy#3752", func_begin = nil, func_end = nil, func_replace = pshy.TeamsReplaceRedToWinningColor, xml = '<C><P Ca="" mc="" /><Z><S><S X="-20" L="20" Y="-400" H="1600" P="0,0,0.3,0,0,0,0,0" T="19" /><S X="820" L="20" Y="-400" H="1600" P="0,0,0.3,0,0,0,0,0" T="19" /><S X="820" o="ff0000" L="100" Y="240" H="300" P="0,0,0.3,0.2,10,0,0,0" T="12" /><S X="400" o="0" L="100" Y="100" c="3" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /><S X="-20" o="ff0000" L="100" Y="240" H="300" P="0,0,0.3,0.2,-10,0,0,0" T="12" /><S X="400" o="0" L="150" Y="200" c="3" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /><S X="620" o="ff0000" L="150" Y="250" c="1" H="30" P="1,0,0.3,0.2,0,0,0,0" T="12" /><S X="400" o="0" L="200" Y="300" c="3" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /><S X="180" o="ff0000" L="150" Y="250" c="1" H="30" P="1,0,0.3,0.2,0,0,0,0" T="12" /></S><D><DC X="400" Y="190" /><DS X="400" Y="85" /></D><O><O C="12" X="620" P="0" Y="250" /><O C="13" X="180" P="0" Y="250" /></O></Z></C>'}
pshy.mapdb_rotations["teams_win"]				= {desc = "P0", duration = 30, items = {"teams_win_1", "teams_win_2", "teams_win_3", "teams_win_4"}}
pshy.TeamsReset(4)
pshy.TeamsShuffle()
pshy.TeamsUpdateScoreboard()
pshy.merge_ModuleEnd()
pshy.merge_ModuleBegin("pshy_lobby.lua")
--- pshy_lobby.lua
--
-- @author: TFM:Pshy#3752 DC:Pshy#7998
-- @require pshy_commands.lua
-- @require pshy_help.lua
-- @require pshy_mapdb.lua
--- Module Help Page:
pshy.help_pages["pshy_lobby"] = {back = "pshy", title = "Lobby", text = "Adds a lobby for players to wait before the game starts.", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_lobby"] = pshy.help_pages["pshy_lobby"]
--- Internal Use:
pshy.lobby_message = ""
pshy.lobby_running = false
--- Map began callback.
-- @private
function pshy.lobby_Began()
	print("called lobby_Began")
	pshy.lobby_running = true
	pshy.lobby_UpdateTitle()
	tfm.exec.disableAutoNewGame(true)
end
--- Map ended callback.
-- @private
function pshy.lobby_Ended()
	print("called lobby_Ended")
	pshy.lobby_running = false
	ui.removeTextArea(9, nil)
end
--- Module Settings:
pshy.lobby_map_name = "lobby"
pshy.mapdb_maps[pshy.lobby_map_name] = {}					-- lobby map in mapdb
pshy.mapdb_maps[pshy.lobby_map_name].author = "Pshy#3752"
pshy.mapdb_maps[pshy.lobby_map_name].xml = '<C><P DS="m;391,267,223,80,25,233,256,266,476,266" Ca="" MEDATA=";2,1;;;-0;0:::1-"/><Z><S><S T="17" X="400" Y="380" L="400" H="200" P="0,0,0.3,0.2,0,0,0,0"/><S T="9" X="400" Y="375" L="800" H="50" P="0,0,0,0,0,0,0,0"/><S T="17" X="837" Y="384" L="80" H="200" P="0,0,0.3,0.2,-30,0,0,0" N=""/><S T="12" X="400" Y="400" L="800" H="100" P="0,0,0.3,1,0,0,0,0" o="008F00" c="4"/><S T="17" X="865" Y="308" L="80" H="200" P="0,0,0.3,0.2,-40,0,0,0" N=""/><S T="17" X="514" Y="444" L="200" H="200" P="0,0,0.3,0.2,-8,0,0,0" N=""/><S T="17" X="888" Y="216" L="80" H="200" P="0,0,0.3,0.2,-70,0,0,0" N=""/><S T="17" X="890" Y="121" L="80" H="200" P="0,0,0.3,0.2,-90,0,0,0" N=""/><S T="17" X="250" Y="422" L="120" H="200" P="0,0,0.3,0.2,-10,0,0,0" N=""/><S T="17" X="371" Y="430" L="200" H="200" P="0,0,0.3,0.2,10,0,0,0" N=""/><S T="17" X="-29" Y="169" L="80" H="200" P="0,0,0.3,0.2,4,0,0,0" N=""/><S T="17" X="-12" Y="344" L="80" H="200" P="0,0,0.3,0.2,4,0,0,0" N=""/><S T="17" X="-7" Y="375" L="80" H="200" P="0,0,0.3,0.2,20,0,0,0" N=""/><S T="19" X="68" Y="286" L="10" H="10" P="1,200,0,1,40,1,0,0"/><S T="19" X="172" Y="323" L="10" H="10" P="1,200,0,1,40,1,0,0"/><S T="19" X="655" Y="324" L="10" H="10" P="1,200,0,1,40,1,0,0"/><S T="19" X="762" Y="303" L="10" H="10" P="1,200,0,1,40,1,0,0"/><S T="2" X="693" Y="369" L="172" H="10" P="0,0,0,1.2,-10,0,0,0" c="2" N="" m=""/><S T="2" X="684" Y="370" L="172" H="10" P="0,0,0,1.2,10,0,0,0" c="2" N="" m=""/><S T="2" X="112" Y="367" L="172" H="10" P="0,0,0,1.2,-10,0,0,0" c="2" N="" m=""/><S T="2" X="109" Y="367" L="172" H="10" P="0,0,0,1.2,10,0,0,0" c="2" N="" m=""/><S T="17" X="869" Y="-22" L="80" H="200" P="0,0,0.3,0.2,-120,0,0,0" N=""/><S T="17" X="-64" Y="-42" L="80" H="200" P="0,0,0.3,0.2,-230,0,0,0" N=""/><S T="12" X="219" Y="101" L="75" H="10" P="0,0,0.3,0.2,0,0,0,0" o="FFFFFF" N="" m=""/><S T="13" X="592" Y="156" L="10" P="0,0,0.3,0.2,0,0,0,0" o="FFFFFF" N="" m=""/><S T="13" X="495" Y="171" L="10" P="0,0,0.3,0.2,0,0,0,0" o="FFFFFF" N="" m=""/><S T="13" X="548" Y="103" L="10" P="0,0,0.3,0.2,0,0,0,0" o="FFFFFF" N="" m=""/><S T="13" X="547" Y="177" L="10" P="0,0,0.3,0.2,0,0,0,0" o="FFFFFF" N="" m=""/></S><D><P X="0" Y="0" T="34" C="00062C" P="0,0"/><P X="211" Y="277" T="2" P="0,0"/><P X="310" Y="279" T="5" P="1,0"/><P X="29" Y="246" T="11" P="0,0"/><P X="209" Y="89" T="156" P="0,0"/><P X="538" Y="340" T="11" P="1,0"/><P X="429" Y="280" T="11" P="0,0"/><P X="536" Y="278" T="42" P="0,0"/><P X="452" Y="345" T="252" P="1,0"/></D><O/><L/></Z></C>'
pshy.mapdb_maps[pshy.lobby_map_name].func_begin = pshy.lobby_Began
pshy.mapdb_maps[pshy.lobby_map_name].func_end = pshy.lobby_Ended
pshy.mapdb_maps[pshy.lobby_map_name].autoskip = false
--- Update the lobby's title message.
-- @param player_name The player who will see the update, or nil for everybody.
-- @private
function pshy.lobby_UpdateTitle(player_name)
	ui.setMapName("<fc>L o b b y</fc>")
	ui.addTextArea(9, "<b><p align='center'><font size='64'><n>L o b b y</n></font>\n<fc>" .. pshy.lobby_message .. "</fc></p></b>", player_name, 200, 20, 400, 0, 0x1, 0x0, 0.0, false)
end
--- TFM event eventNewPlayer()
function eventNewPlayer(player_name)
	if pshy.lobby_running then
		pshy.lobby_UpdateTitle(player_name)
	end
end
--- !lobby [message]
function pshy.lobby_ChatCommandLobby(user, message)
	message = message or "Setting up the room..."
	pshy.lobby_message = message
	if not pshy.lobby_running then
		tfm.exec.disableAutoShaman(true)
		tfm.exec.newGame(pshy.lobby_map_name)
	else
		pshy.lobby_UpdateTitle()
	end
end
pshy.chat_commands["lobby"] = {func = pshy.lobby_ChatCommandLobby, desc = "start or update the lobby with a message", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_lobby"].commands["lobby"] = pshy.chat_commands["lobby"]
pshy.perms.admins["!lobby"] = true
--- Initialization:
function eventInit()
	pshy.lobby_ChatCommandLobby(nil, nil)
end
pshy.merge_ModuleEnd()
pshy.merge_ModuleHard("modulepack_pshyvs.lua")
--- modulepack_pshyvs.lua
--
-- This file builds the pshyvs modulepack.
--
-- @author pshy
-- @hardmerge
-- @require pshy_emoticons.lua
-- @require pshy_lua_commands.lua
-- @require pshy_tfm_commands.lua
-- @require pshy_fun_commands.lua
-- @require pshy_fcplatform.lua
-- @require pshy_basic_weathers.lua
-- @require pshy_motd.lua
-- @require pshy_nicks.lua
-- @require pshy_teams.lua
-- @require pshy_lobby.lua
--- TFM setup:
tfm.exec.disableWatchCommand(false)
tfm.exec.disableDebugCommand(true)
tfm.exec.disableMinimalistMode(false)
tfm.exec.disablePhysicalConsumables(true)
system.disableChatCommandDisplay(nil, true)
tfm.exec.disableAutoShaman(true)
--tfm.exec.disablePrespawnPreview(false)
pshy.merge_Finish()

