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
--	- `pshy.admins`: Set of admin names.
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
pshy.loader = string.match(({pcall(nil)})[2], "^(.-)%.")	-- script loader
pshy.admins = {}											-- set of room admins
pshy.admins[pshy.loader] = true								-- should the loader be an admin
pshy.perms = {}												-- map of players's sets of permissions (a perm is a string, preferably with no ` ` nor `.`, prefer `-`, `/` is reserved for future use)
pshy.perms.everyone = {}									-- set of permissions for everyone
pshy.perms_auto_admin_admins = true							-- add the admins as room admin automatically
pshy.perms_auto_admin_moderators = true						-- add the moderators as room admin automatically
pshy.perms_auto_admin_funcorps = true						-- add the funcorps as room admin automatically (from a list, ask to be added in it)
pshy.funcorps = {}											-- set of funcorps who asked to be added
pshy.funcorps["Pshy#3752"] = true
pshy.perms_auto_admin_authors = true						-- add the authors of the final modulepack as admin
pshy.authors = {}											-- set of modulepack authors (add them from your module script)
--- Help page:
pshy.help_pages = pshy.help_pages or {}				-- touching the help_pages table
pshy.help_pages["pshy_perms"] = {title = "Permissions", text = "Player permissions are stored in sets such as `pshy.perms.Player#0000`.\n`pshy.perms.everyone` contains default permissions.\nRoom admins from the set `pshy.admins` have all permissions.\n", commands = {}}
--- Internal use:
pshy.chat_commands = pshy.chat_commands or {}		-- touching the chat_commands table
pshy.perms_has_new_game_been = false
--- Check if a player have a permission.
-- @public
-- @param The name of the player.
-- @param perm The permission name.
-- @return true if the player have the required permission.
function pshy.HavePerm(player_name, perm)
	assert(type(perm) == "string", "permission must be a string")
	if pshy.admins[player_name] or pshy.perms.everyone[perm] or (pshy.perms[player_name] and pshy.perms[player_name][perm]) then
		return true
	end
	return false
end
--- Add an admin with a reason, and broadcast it to other admins.
-- @private
function pshy.AddAdmin(new_admin, reason)
	pshy.admins[new_admin] = true
	for admin, void in pairs(pshy.admins) do
		tfm.exec.chatMessage("<r>[PshyPerms]</r> " .. new_admin .. " added as a room admin" .. (reason and (" (" .. reason .. ")") or "") .. ".", admin)
	end
end
--- Give admin to a player if the settings allow it.
-- @private
function pshy.PermsAutoAddAdminCheck(player_name)
	if pshy.admins[player_name] then
		return
	elseif player_name == pshy.loader then
		pshy.AddAdmin(player_name, "Script Loader")
	elseif pshy.perms_auto_admin_admins and string.sub(player_name, -5) == "#0001" then
		pshy.AddAdmin(player_name, "Admin &lt;3")
	elseif pshy.perms_auto_admin_moderators and string.sub(player_name, -5) == "#0010" then
		pshy.AddAdmin(player_name, "Moderator")
	elseif pshy.perms_auto_admin_funcorps and pshy.funcorps[player_name] then
		pshy.AddAdmin(player_name, "FunCorp")
	elseif pshy.perms_auto_admin_authors and pshy.authors[player_name] then
		pshy.AddAdmin(player_name, "Author")
	end
end
--- TFM event eventNewPlayer.
-- Automatically add moderator as room admins.
function eventNewPlayer(player_name)
	pshy.PermsAutoAddAdminCheck(player_name)
end
--- TFM event eventNewGame
-- Adding admins upon the first new game event.
function eventNewGame()
	if not pshy.perms_has_new_game_been then
		pshy.perms_has_new_game_been = true
		for player_name in pairs(tfm.get.room.playerList) do
			pshy.PermsAutoAddAdminCheck(player_name)
		end
	end
end
--- !admin <NewAdmin#0000>
-- Add an admin in the pshy.admins set.
function pshy.ChatCommandAdmin(user, new_admin_name)
	pshy.admins[new_admin_name] = true
	for admin_name, void in pairs(pshy.admins) do
		tfm.exec.chatMessage("<r>[PshyPerms]</r> " .. user .. " added " .. new_admin_name .. " as room admin.", admin_name)
	end
end
pshy.chat_commands["admin"] = {func = pshy.ChatCommandAdmin, desc = "add a room admin", argc_min = 1, argc_max = 1, arg_types = {"string"}, arg_names = {"Newadmin#0000"}}
pshy.help_pages["pshy_perms"].commands["admin"] = pshy.chat_commands["admin"]
pshy.merge_ModuleEnd()
pshy.merge_ModuleHard("pshy_lua_utils.lua")
--- pshy_lua_utils.lua
--
-- This module contains basic functions related to LUA.
--
-- @author DC:Pshy#7998 TFM:Pshy#3752
-- @hardmerge
-- @namespace pshy
-- @require pshy_perms.lua
pshy = pshy and pshy or {}
--- string.isalnum(str)
-- us this instead: `not str:match("%W")`
--- Get a table's keys in a list.
-- @param t The table.
function pshy.TableKeys(t)
	local keys
	for key in pairs(t) do
		table.insert(keys, key)
	end
	return l
end
--- Count the keys in a table.
-- @param t The table.
function pshy.TableCountKeys(t)
	local count = 0
	for key, value in pairs(t) do
		count = count + 1	
	end
	return count
end
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
--- Convert a string to a boolean
-- @param string "true" or "false", or numbers 0 and 1
-- @return boolean true or false, or nil
function pshy.ToBoolean(value)
	if value == "true" or value == "1" then
		return true
	end
	if value == "false" or value == "0" then
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
-- nil value is not supported for bool, number and string
-- @param value String to convert.
-- @param type string representing the type to convert to.
-- @return the same value represented by the best type possible (bool/number/string).
function pshy.ToType(value, t)
	assert(type(value) == "string", "wrong argument type")
	assert(type(t) == "string", "wrong argument type")
	-- boolean
	if t == "bool" or t == "boolean" then
		return pshy.ToBoolean(value)
	end
	-- number
	if t == "number" then
		return tonumber(value)
	end
	-- string
	if t == "string" then
		return value
	end
	-- nil
	if value == "nil" then
		return nil
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
pshy.merge_ModuleHard("pshy_tfm_utils.lua")
--- pshy_tfm_utils.lua
--
-- Basic functions related to TFM.
--
-- @author DC:Pshy#7998 TFM:Pshy#3752
-- @hardmerge
-- @namespace pshy
-- @require pshy_perms.lua
-- @require pshy_lua_utils.lua
pshy = pshy or {}
--- Log a message and also display it to the host.
-- @param msg Message to log.
function pshy.Log(msg)
	tfm.exec.chatMessage("log: " .. tostring(msg), pshy.host)
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
--- Convert a tfm anum index to an interger, searching in all tfm enums.
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
pshy.merge_ModuleHard("pshy_utils.lua")
--- pshy_utils.lua
--
-- This module gather basic functions.
--
-- @author DC:Pshy#7998 TFM:Pshy#3752
-- @hardmerge
-- @namespace pshy
-- @require pshy_lua_utils.lua
-- @require pshy_tfm_utils.lua
pshy = pshy or {}
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
-- - no_user: true if the called function doesnt take the command user as
--   a first argument.
pshy.chat_commands = pshy.chat_commands or {}
--- Map of command aliases (string -> string)
pshy.chat_command_aliases = pshy.chat_command_aliases or {}
--- Get the real command name
-- @name Command name or alias without `!`.
function pshy.ResolveChatCommandAlias(name)
	while pshy.chat_command_aliases[name] do
		name = pshy.chat_command_aliases[name]
	end
	return name
end
--- Get a chat command by name
-- @name Can be the command name or an alias, without `!`.
function pshy.GetChatCommand(name)
	return (pshy.chat_commands[pshy.ResolveChatCommandAlias(name)])
end
--- Get a command usage.
-- The returned string represent how to use the command.
-- @param cmd_name The name of the command.
function pshy.GetChatCommandUsage(cmd_name)
	local text = "!" .. cmd_name
	local real_command = pshy.GetChatCommand(cmd_name)
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
-- @old_name The previous command name without '!'.
-- @new_name The new command name without '!'.
-- @keep_previous `true` to make old_name an alias of new_name.
function pshy.RenameChatCommand(old_name, new_name, keep_previous)
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
-- @param args Table of elements to convert.
-- @param types Table of types.
function pshy.TableStringsToType(args, types)
	for index = 1, #args do
		if types and index <= #types then
			args[index] = pshy.ToType(args[index], types[index])
		else
			args[index] = pshy.AutoType(args[index])
		end
	end	
end
--- Run a command as a player
-- @param user The player inputing the command.
-- @param command The full command the player have input.
-- @return false if permission failure, true if handled and not to handle, nil otherwise
function pshy.RunChatCommand(user, command_str)
	assert(type(user) == "string")
	assert(type(command_str) == "string")
	-- log non-admin players commands use
	if not pshy.admins[user] then
		print("[PshyCmds] " .. user .. ": !" .. command_str)
	end
	-- remove 'pshy.' prefix
	if #command_str > 5 and string.sub(command_str, 1, 5) == "pshy." then
		command_str = string.sub(command_str, 6, #command_str)
	elseif pshy.commands_require_prefix then
		tfm.exec.chatMessage("[PshyCmds] Ignoring commands without a `!pshy.` prefix.", user)
		return
	end
	-- get command
	local args = pshy.StrSplit(command_str, " ", 2)
	local command_name = args[1]
	local final_command_name = pshy.ResolveChatCommandAlias(command_name)
	local command = pshy.GetChatCommand(command_name)
	-- non-existing command
	if not command then
		tfm.exec.chatMessage("[PshyCmds] Another module may handle that command.", user)
		return nil
	end
	-- disallowed command
	if not pshy.HavePerm(user, "!" .. final_command_name) then
		tfm.exec.chatMessage("<r>[PshyCmds] You cannot use this command :c</r>", user)
		return false
	end
	-- get args
	args = args[2] and pshy.StrSplit(args[2], " ", command.argc_max or 16) or {} -- max command args set to 16 to prevent abuse
	--table.remove(args, 1)
	-- missing arguments
	if command.argc_min and #args < command.argc_min then
		--tfm.exec.chatMessage("<r>[PshyCmds] This command require " .. command.argc_min .. " arguments.</r>", user)
		tfm.exec.chatMessage("<r>[PshyCmds] Usage: " .. pshy.GetChatCommandUsage(final_command_name) .. "</r>", user)
		return false
	end
	-- too many arguments
	if command.argc_max == 0 and #command_name ~= #command_str then
		tfm.exec.chatMessage("<r>[PshyCmds] This command do not use arguments.</r>", user)
		return false
	end
	-- convert arguments
	pshy.TableStringsToType(args, command.arg_types)
	-- runing
	local status, retval
	if #args > 16 then
		status = false
		retval = "does not support more than 16 command arguments"
	elseif not command.no_user then
		status, retval = pcall(command.func, user, table.unpack(args))
	else
		status, retval = pcall(command.func, table.unpack(args))
	end
	-- error handling
	if status == false then
		tfm.exec.chatMessage("<r>[PshyCmds] Command failed: " .. retval .. "</r>", user)
		tfm.exec.chatMessage("<r>[PshyCmds] Usage: " .. pshy.GetChatCommandUsage(final_command_name) .. "</r>", user)
	end
end
--- !help [command]
-- Get general help or help about a specific command.
function pshy.ChatCommandHelp(player_name, command_name)
	local help_str = ""
	local real_command = pshy.GetChatCommand(command_name)
	if command_name and real_command then
		help_str = "\n!" .. command_name .. "\t \t- " .. (real_command.desc and tostring(real_command.desc) or "No description.") .."\n"
		if real_command.help then
			help_str = help_str .. real_command.help .. "\n"
		end
		if real_command.argc_min or real_command.argc_max then
			help_str = help_str .. "\nThis command accept from " .. tostring(real_command.argc_min) .. " to " .. tostring(real_command.argc_max) .. " arguments.\n"
		end
		if not real_command.func then
			help_str = help_str .. "\nEXTERNAL COMMAND, PART OF ANOTHER MODULE\n"
		end
	else
		help_str = "\n\tPSHY MODULE COMMANDS:\n\n"
		local no_doc = "Commands with no defined help:\n"
		for command_name, command in pairs(pshy.chat_commands) do
			if command.desc then
				local cmd_str = "!" .. command_name .. "\t \t - " .. command.desc
				help_str = help_str .. cmd_str .. "\n"
			else
				no_doc = no_doc .. ", !" .. command_name
			end
		end
		help_str = help_str .. "\n" .. no_doc .. "\n"
	end
	--tfm.exec.chatMessage(help_str, player_name)
	pshy.Popup(player_name, help_str)
	return true
end
pshy.chat_commands["help"] = {func = pshy.ChatCommandHelp, desc = "list pshy's available commands", argc_min = 0, argc_max = 1, arg_types = {"string", "string"}}
--- TFM event eventChatCommand.
function eventChatCommand(player_name, message)
	return pshy.RunChatCommand(player_name, message)
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
			pshy.RunChatCommand(playerName, pshy.StrSplit(c, " ", 2)[2])
		end
		-- apcmd callback
		if (string.sub(c, 1, 6) == "apcmd ") then
			if pshy.admins[playerName] then
				pshy.RunChatCommand(playerName, pshy.StrSplit(c, " ", 2)[2])
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
	local html = html .. pshy.GetChatCommandUsage(command_name)
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
--- Get the html to display for a page.
function pshy.GetHelpPageHtml(page_name, is_admin)
	local page = pshy.help_pages[page_name]
	page = page or pshy.help_pages[""]
	local html = ""
	-- title menu
	local html = "<p align='right'>"
	html = html .. " <bl><a href='event:pcmd help " .. (page.back or "") .. "'>[ &lt; ]</a></bl>"
	html = html .. " <r><a href='event:close'>[ X ]</a></r>"
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
			--html = html .. '!' .. ex_cmd .. "\t - " .. (cmd.desc or "no description") .. '\n'
			html = html .. (pshy.perms.everyone["!" .. cmd_name] and "<v>" or "<r>")
			--html = html .. "<u><a href='event:pcmd pshy.help " .. cmd_name .. "'>" .. pshy.GetChatCommandUsage(cmd_name) .. "</a></u>"
			html = html .. "<u>" .. pshy.GetChatCommandUsage(cmd_name) .. "</u>"
			html = html .. (pshy.perms.everyone["!" .. cmd_name] and "</v>" or "</r>")
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
				html = html .. "<u><a href='event:pcmd pshy.help " .. subpage_name .. "'>" .. subpage.title .. "</a></u>\n"
			else
				html = html .. "<u><a href='event:pcmd pshy.help " .. subpage_name .. "'>" .. subpage_name .. "</a></u>\n" 
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
--- !luaset <path.to.object> <new_value>
-- Set the value of a lua object.
function pshy.ChatCommandLuaset(user, obj_path, obj_value)
	pshy.LuaSet(obj_path, pshy.AutoType(obj_value))
	pshy.ChatCommandLuaget(user, obj_path)
end
pshy.chat_commands["luaset"] = {func = pshy.ChatCommandLuaset, desc = "set a lua object value", argc_min = 2, argc_max = 2, arg_types = {"string", "string"}}
pshy.chat_command_aliases["set"] = "luaset"
pshy.help_pages["pshy_lua_commands"].commands["luaset"] = pshy.chat_commands["luaset"]
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
	pshy.LuaSet(obj_path, obj_value)
	pshy.ChatCommandLuaget(user, obj_path)
end
pshy.chat_commands["luasetstr"] = {func = pshy.ChatCommandLuasetstr, desc = "set a lua object value", argc_min = 2, argc_max = 2, arg_types = {"string", "string"}}
pshy.chat_command_aliases["setstr"] = "luaset"
pshy.help_pages["pshy_lua_commands"].commands["luasetstr"] = pshy.chat_commands["luasetstr"]
--- !luacall <path.to.function> [args...]
-- Call a lua function.
-- @todo use variadics and put the feature un pshy_utils?
function pshy.ChatCommandLuacall(user, funcname, a, b, c, d, e, f)
	local func = pshy.LuaGet(funcname)
	assert(type(func) ~= "nil", "function not found")
	assert(type(func) == "function", "a function name was expected")
	pshy.rst1, pshy.rst2 = func(a, b, c, d, e, f)
	tfm.exec.chatMessage(funcname .. " returned " .. tostring(pshy.rst1) .. ", " .. tostring(pshy.rst2), user)
end
pshy.chat_commands["luacall"] = {func = pshy.ChatCommandLuacall, desc = "run a lua function with given arguments", argc_min = 1, arg_types = {"string"}}
pshy.chat_command_aliases["call"] = "luacall"
pshy.help_pages["pshy_lua_commands"].commands["luacall"] = pshy.chat_commands["luacall"]
--- !runas command
-- Run a command as another player.
function pshy.ChatCommandRunas(player_name, target_player, command)
	pshy.Log(player_name .. " running as " .. target_player .. ": " .. command)
	pshy.RunChatCommand(target, command)
end
pshy.chat_commands["runas"] = {func = pshy.ChatCommandRunas, desc = "run a command as another player", argc_min = 2, argc_max = 2, arg_types = {"string", "string"}}
pshy.help_pages["pshy_lua_commands"].commands["runas"] = pshy.chat_commands["runas"]
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
pshy.perms.everyone["!fcplatformjoin"] = true
pshy.help_pages["pshy_fcplatform"].commands["fcplatformjoin"] = pshy.chat_commands["fcplatformjoin"]
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
pshy.merge_ModuleBegin("pshy_checkpoints.lua")
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
pshy.checkpoints_player_locations = {}
--- Set the checkpoint of a player.
-- @param player_name The player's name.
-- @param x Optional player x location.
-- @param y Optional player y location.
function pshy.CheckpointsSetPlayerCheckpoint(player_name, x, y)
	pshy.checkpoints_player_locations[player_name] = {}
	x = x or tfm.get.room.playerList[player_name].x
	y = y or tfm.get.room.playerList[player_name].y
	pshy.checkpoints_player_locations[player_name].x = x
	pshy.checkpoints_player_locations[player_name].y = y
end
--- Set the checkpoint of a player.
-- @param player_name The player's name.
-- @param x Optional player x location.
-- @param y Optional player y location.
function pshy.CheckpointsUnsetPlayerCheckpoint(player_name, x, y)
	pshy.checkpoints_player_locations[player_name] = nil
end
--- Teleport a player to its checkpoint.
-- @param player_name The player's name.
-- @param x Optional player x location.
-- @param y Optional player y location.
function pshy.CheckpointsPlayerCheckpoint(player_name)
	local checkpoint = pshy.checkpoints_player_locations[player_name]
	if checkpoint then
		tfm.exec.respawnPlayer(player_name)
		tfm.exec.movePlayer(player_name, checkpoint.x, checkpoint.y, false, 0, 0, true)
	end
end
--- !checkpoint
pshy.chat_commands["checkpoint"] = {func = pshy.CheckpointsPlayerCheckpoint, desc = "teleport to your checkpoint if you have one", argc_min = 0, argc_max = 0, arg_types = {}}
pshy.help_pages["pshy_checkpoints"].commands["checkpoint"] = pshy.chat_commands["checkpoint"]
pshy.perms.everyone["!checkpointset"] = false
--- !setcheckpoint
pshy.chat_commands["setcheckpoint"] = {func = pshy.CheckpointsSetPlayerCheckpoint, desc = "set your checkpoint to the current location", argc_min = 0, argc_max = 0, arg_types = {}}
pshy.help_pages["pshy_checkpoints"].commands["setcheckpoint"] = pshy.chat_commands["setcheckpoint"]
pshy.perms.everyone["!checkpointset"] = false
--- !setcheckpoint
pshy.chat_commands["unsetcheckpoint"] = {func = pshy.CheckpointsUnsetPlayerCheckpoint, desc = "delete your checkpoint", argc_min = 0, argc_max = 0, arg_types = {}}
pshy.help_pages["pshy_checkpoints"].commands["unsetcheckpoint"] = pshy.chat_commands["unsetcheckpoint"]
pshy.perms.everyone["!unsetcheckpoint"] = false
--- TFM event eventPlayerDied
function eventPlayerRespawn(player_name)
	pshy.CheckpointsPlayerCheckpoint(player_name)
end
--- TFM event eventNewGame
function eventNewGame(player_name)
	if pshy.checkpoints_reset_on_new_game then
		pshy.checkpoints_player_locations = {}
	end
end
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
--- Get the target of the command, throwing on permission issue.
-- @private
function pshy.fun_commands_GetTarget(user, target, perm_prefix)
	assert(type(perm_prefix) == "string")
	if not target then
		return user
	end
	target = pshy.FindPlayerNameOrError(target)
	if target == user then
		return user
	elseif not pshy.HavePerm(user, perm_prefix .. "-others") then
		error("you cant use this command on other players :c")
		return
	elseif not tfm.get.room.playerList[target] then
		error("the target player is not in the room")
		return
	end
	return target
end
--- !shaman
function pshy.ChatCommandShaman(user, target)
	target = pshy.fun_commands_GetTarget(user, target, "!shaman")
	tfm.exec.setShaman(target, not tfm.get.room.playerList[target].isShaman)
end
pshy.chat_commands["shaman"] = {func = pshy.ChatCommandShaman, desc = "switch you to a shaman", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_fun_commands"].commands["shaman"] = pshy.chat_commands["shaman"]
pshy.perms.everyone["!shaman"] = false
--- !vampire
function pshy.ChatCommandVampire(user, target)
	target = pshy.fun_commands_GetTarget(user, target, "!vampire")
	tfm.exec.setVampirePlayer(target, not tfm.get.room.playerList[target].isVampire)
end
pshy.chat_commands["vampire"] = {func = pshy.ChatCommandVampire, desc = "switch you to a vampire", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_fun_commands"].commands["vampire"] = pshy.chat_commands["vampire"]
pshy.perms.everyone["!vampire"] = false
--- !cheese
function pshy.ChatCommandCheese(user, target)
	target = pshy.fun_commands_GetTarget(user, target, "!cheese")
	if not tfm.get.room.playerList[target].hasCheese then
		tfm.exec.giveCheese(target)
	else
		tfm.exec.removeCheese(target)
	end
end
pshy.chat_commands["cheese"] = {func = pshy.ChatCommandCheese, desc = "toggle your cheese", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_fun_commands"].commands["cheese"] = pshy.chat_commands["cheese"]
pshy.perms.everyone["!cheese"] = true
--- !win
function pshy.ChatCommandWin(user, target)
	target = pshy.fun_commands_GetTarget(user, target, "!win")
	tfm.exec.giveCheese(target)
	tfm.exec.playerVictory(target)
end
pshy.chat_commands["win"] = {func = pshy.ChatCommandWin, desc = "play the win animation", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_fun_commands"].commands["win"] = pshy.chat_commands["win"]
pshy.perms.everyone["!win"] = true
--- !kill
function pshy.ChatCommandKill(user, target)
	target = pshy.fun_commands_GetTarget(user, target, "!kill")
	if not tfm.get.room.playerList[target].isDead then
		tfm.exec.killPlayer(target)
	else
		tfm.exec.respawnPlayer(target)
	end
end
pshy.chat_commands["kill"] = {func = pshy.ChatCommandKill, desc = "kill or resurect yourself", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_fun_commands"].commands["kill"] = pshy.chat_commands["kill"]
pshy.perms.everyone["!kill"] = true
--- !freeze
function pshy.ChatCommandFreeze(user, target)
	target = pshy.fun_commands_GetTarget(user, target, "!freeze")
	tfm.exec.freezePlayer(target, true)
end
pshy.chat_commands["freeze"] = {func = pshy.ChatCommandFreeze, desc = "freeze yourself", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_fun_commands"].commands["freeze"] = pshy.chat_commands["freeze"]
pshy.perms.everyone["!freeze"] = true
--- !size <n>
function pshy.ChatCommandSize(user, size, target)
	assert(size >= 0.2, "minimum size is 0.2")
	assert(size <= 5, "maximum size is 5")
	target = pshy.fun_commands_GetTarget(user, target, "!size")
	tfm.exec.changePlayerSize(target, size)
end 
pshy.chat_commands["size"] = {func = pshy.ChatCommandSize, desc = "change your size", argc_min = 1, argc_max = 2, arg_types = {"number", "string"}}
pshy.help_pages["pshy_fun_commands"].commands["size"] = pshy.chat_commands["size"]
pshy.perms.everyone["!size"] = true
--- !namecolor
function pshy.ChatCommandNamecolor(user, color, target)
	target = pshy.fun_commands_GetTarget(user, target, "!namecolor")
	tfm.exec.setNameColor(target, color)
end 
pshy.chat_commands["namecolor"] = {func = pshy.ChatCommandNamecolor, desc = "change your name's color", argc_min = 1, argc_max = 2, arg_types = {nil, "string"}}
pshy.help_pages["pshy_fun_commands"].commands["namecolor"] = pshy.chat_commands["namecolor"]
pshy.perms.everyone["!namecolor"] = true
--- !action
function pshy.ChatCommandAction(user, action)
	tfm.exec.chatMessage("<v>" .. user .. "</v> <n>" .. action .. "</n>")
end 
pshy.chat_commands["action"] = {func = pshy.ChatCommandAction, desc = "send a rp-like/action message", argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_fun_commands"].commands["action"] = pshy.chat_commands["action"]
pshy.perms.everyone["!action"] = false
--- !balloon
function pshy.ChatCommandBalloon(user, target)
	target = pshy.fun_commands_GetTarget(user, target, "!balloon")
	tfm.exec.attachBalloon(target, true, math.random(1, 4), true)
end 
pshy.chat_commands["balloon"] = {func = pshy.ChatCommandBalloon, desc = "attach a balloon to yourself", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_fun_commands"].commands["balloon"] = pshy.chat_commands["balloon"]
pshy.perms.everyone["!balloon"] = false
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
pshy.chat_commands["link"] = {func = pshy.ChatCommandLink, desc = "attach yourself to another player ('off' to stop)", argc_min = 1, argc_max = 2, arg_types = {"string", "string"}}
pshy.help_pages["pshy_fun_commands"].commands["link"] = pshy.chat_commands["link"]
pshy.perms.everyone["!link"] = true
--- !gravity
function pshy.ChatCommandGravity(user, value)
	tfm.exec.setWorldGravity(0, value)
end 
pshy.chat_commands["gravity"] = {func = pshy.ChatCommandGravity, desc = "change the gravity", argc_min = 1, argc_max = 1, arg_types = {"number"}}
pshy.help_pages["pshy_fun_commands"].commands["gravity"] = pshy.chat_commands["gravity"]
--- !colorpicker
function pshy.ChatCommandColorpicker(user, target)
	target = pshy.fun_commands_GetTarget(user, target, "!colorpicker")
	ui.showColorPicker(49, target, 0, "Get a color code:")
end 
pshy.chat_commands["colorpicker"] = {func = pshy.ChatCommandColorpicker, desc = "show the colorpicker", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_fun_commands"].commands["colorpicker"] = pshy.chat_commands["colorpicker"]
pshy.perms.everyone["!colorpicker"] = true
--- Disable commands that may give an advantage.
function pshy.fun_commands_DisableCheatCommands()
	pshy.perms.everyone["!balloon"] = false
	pshy.perms.everyone["!cheese"] = false
	pshy.perms.everyone["!gravity"] = false
	pshy.perms.everyone["!kill"] = false
	pshy.perms.everyone["!link"] = false
	pshy.perms.everyone["!shaman"] = false
	pshy.perms.everyone["!size"] = false
	pshy.perms.everyone["!vampire"] = false
	pshy.perms.everyone["!win"] = false
end
pshy.merge_ModuleEnd()
pshy.merge_ModuleBegin("pshy_speedfly.lua")
--- pshy_speedfly.lua
--
-- Fly, speed boost, and teleport features.
--
-- Disable cheat commands with `pshy.speedfly_DisableCheatCommands()`.
--
-- @author DC:Pshy#7998 TFM:Pshy#3752
-- @namespace pshy
-- @require pshy_commands.lua
-- @require pshy_help.lua
--- Module Help Page:
pshy.help_pages["pshy_speedfly"] = {back = "pshy", title = "Speed / Fly / Teleport", text = "Fly and speed boost.\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_speedfly"] = pshy.help_pages["pshy_speedfly"]
--- Internal Use:
pshy.speedfly_flyers = {}		-- flying players
pshy.speedfly_speedies = {}	-- speedy players (value is the speed)
--- Get the target of the command, throwing on permission issue.
-- @private
function pshy.speedfly_GetTarget(user, target, perm_prefix)
	assert(type(perm_prefix) == "string")
	if not target then
		return user
	end
	target = pshy.FindPlayerNameOrError(target)
	if target == user then
		return user
	elseif not pshy.HavePerm(user, perm_prefix .. "-others") then
		error("you cant use this command on other players :c")
		return
	elseif not tfm.get.room.playerList[target] then
		error("the target player is not in the room")
		return
	end
	return target
end
--- !fly
function pshy.ChatCommandFly(user, target)
	target = pshy.speedfly_GetTarget(user, target, "!fly")
	if not pshy.speedfly_flyers[target] then
		pshy.speedfly_flyers[target] = true
		tfm.exec.bindKeyboard(target, 1, true, true)
		tfm.exec.bindKeyboard(target, 1, false, true)
		tfm.exec.chatMessage("[FunCommands] Jump to swing your wings!", target)
	else
		pshy.speedfly_flyers[target] = nil
		tfm.exec.chatMessage("[FunCommands] Your feet are happy again.", target)
	end
end 
pshy.chat_commands["fly"] = {func = pshy.ChatCommandFly, desc = "toggle fly mode", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_speedfly"].commands["fly"] = pshy.chat_commands["fly"]
pshy.perms.everyone["!fly"] = true
--- !speed
function pshy.ChatCommandSpeed(user, speed, target)
	target = pshy.speedfly_GetTarget(user, target, "!speed")
	speed = speed or (pshy.speedfly_speedies[target] and 0 or 50)
	assert(speed >= 0, "the minimum speed boost is 0")
	assert(speed <= 200, "the maximum speed boost is 200")
	if speed <= 1 or speed == pshy.speedfly_speedies[target] then
		pshy.speedfly_speedies[target] = nil
		tfm.exec.chatMessage("[FunCommands] You are back to turtle speed.", target)
	else
		pshy.speedfly_speedies[target] = speed
		tfm.exec.bindKeyboard(target, 0, true, true)
		tfm.exec.bindKeyboard(target, 2, true, true)
		tfm.exec.chatMessage("[FunCommands] You feel like sonic!", target)
	end
end 
pshy.chat_commands["speed"] = {func = pshy.ChatCommandSpeed, desc = "toggle fast acceleration mode", argc_min = 0, argc_max = 2, arg_types = {"number", "string"}, arg_names = {"speed", "target_player"}}
pshy.help_pages["pshy_speedfly"].commands["speed"] = pshy.chat_commands["speed"]
pshy.perms.everyone["!speed"] = true
--- !tpp (teleport to player)
function pshy.ChatCommandTpp(user, destination, target)
	target = pshy.speedfly_GetTarget(user, target, "!tpp")
	destination = pshy.FindPlayerNameOrError(destination)
	tfm.exec.movePlayer(target, tfm.get.room.playerList[destination].x, tfm.get.room.playerList[destination].y, false, 0, 0, true)
end
pshy.chat_commands["tpp"] = {func = pshy.ChatCommandTpp, desc = "teleport to a player", argc_min = 1, argc_max = 2, arg_types = {"string", "string", "string"}, arg_names = {"destination", "target_player"}}
pshy.help_pages["pshy_speedfly"].commands["tpp"] = pshy.chat_commands["tpp"]
pshy.perms.everyone["!tpp"] = true
--- !tpl (teleport to location)
function pshy.ChatCommandTpl(user, x, y, target)
	target = pshy.speedfly_GetTarget(user, target, "!tpl")
	tfm.exec.movePlayer(target, x, y, false, 0, 0, true)
end
pshy.chat_commands["tpl"] = {func = pshy.ChatCommandTpl, desc = "teleport to a location", argc_min = 2, argc_max = 3, arg_types = {"number", "number", "string"}, arg_names = {"x", "y", "target_player"}}
pshy.help_pages["pshy_speedfly"].commands["tpl"] = pshy.chat_commands["tpl"]
pshy.perms.everyone["!tpl"] = true
--- !coords
function pshy.ChatCommandTpl(user)
	tfm.exec.chatMessage(tostring(tfm.get.room.playerList[user].x) .. "\t" .. tostring(tfm.get.room.playerList[user].y), user)
end
pshy.chat_commands["coords"] = {func = pshy.ChatCommandTpl, desc = "get your coordinates", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_speedfly"].commands["coords"] = pshy.chat_commands["coords"]
pshy.perms.everyone["!coords"] = true
--- Disable commands that may give an advantage.
function pshy.speedfly_DisableCheatCommands()
	pshy.perms.everyone["!coords"] = false
	pshy.perms.everyone["!fly"] = false
	pshy.perms.everyone["!tpp"] = false
	pshy.perms.everyone["!tpl"] = false
	pshy.perms.everyone["!speed"] = false
end
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
--- Module Help Page.
pshy.help_pages["pshy_scores"] = {back = "pshy", title = "Scores", text = "This module allows to customize how players make score points.\n", commands = {}}
pshy.help_pages["pshy"].subpages["pshy_scores"] = pshy.help_pages["pshy_scores"]
--- Module Settings.
pshy.scores_per_win = 0				-- points earned by wins
pshy.scores_per_first_wins = {}			-- points earned by the firsts to win
pshy.scores_per_first_wins[1] = 1			-- points for the very first
--pshy.teams_cheese_gathered_firsts_points[2] = 1	-- points for the second...
pshy.scores_per_cheese = 0				-- points earned per cheese touched
pshy.scores_per_first_cheeses = {}			-- points earned by the firsts to touch the cheese
pshy.scores_per_death = 0				-- points earned by death
pshy.scores_per_first_deaths = {}			-- points earned by the very first to die
pshy.scores_survivors_win = false			-- this round is a survivor round (players win if they survive) (true or the points for surviving)
pshy.scores_ui_arbitrary_id = 2918			-- arbitrary ui id
pshy.scores_show = true				-- show stats for the map
pshy.scores_per_bonus = 0				-- points earned by gettings bonuses of id <= 0
pshy.scores_reset_on_leave = true			-- reset points on leave
--- Internal use.
pshy.scores = {}					-- total scores points per player
pshy.scores_firsts_win = {}				-- total firsts points per player
pshy.scores_round_wins = {}				-- current map's first wins
pshy.scores_round_cheeses = {}			-- current map's first cheeses
pshy.scores_round_deaths = {}				-- current map's first deathes
pshy.scores_round_ended = true			-- the round already ended (now counting survivors, or not counting at all)
pshy.scores_should_update_ui = false			-- if true, scores ui have to be updated
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
		eventPlayerScore(player_name, points)
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
	pshy.ScoresResetPlayer(player_name)
end
--- Initialization
pshy.ScoresResetPlayers()
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
pshy.help_pages["pshy_emoticons"] = {back = "pshy", title = "Emoticons", text = "Adds custom emoticons\nCombine CTRL, ALT and number keys to use them.\nThanks to <ch>Nnaaaz#0000</ch>\nIncludes emoticons from <ch>Feverchild#0000</ch>\nIncludes emoticons from <ch>Rchl#3416</ch>\nThanks to <ch>Sky#1999</ch>\n", examples = {}, commands = {}}
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
pshy.emoticons["cheese_left"]				= {image = "155593003fc.png", x = -15, y = -55, sx = 0.50, sy = 0.50}
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
		pshy.emoticons_players_image_ids[player_name] = tfm.exec.addImage(emoticon.image, "$" .. player_name, emoticon.x, emoticon.y, nil, emoticon.sx or 1, emoticon.sy or 1)
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
pshy.chat_commands["emoticon"] = {func = pshy.ChatCommandEmoticon, desc = "show an emoticon", argc_min = 1, argc_max = 2, arg_types = {"string", "string"}}
pshy.help_pages["pshy_emoticons"].commands["emoticon"] = pshy.chat_commands["emoticon"]
pshy.chat_command_aliases["em"] = "emoticon"
pshy.perms.everyone["!emoticon"] = true
--- Initialization:
for player_name in pairs(tfm.get.room.playerList) do
	pshy.EmoticonsBindPlayerKeys(player_name)
end
pshy.merge_ModuleEnd()
pshy.merge_ModuleBegin("modulepack_mario.lua")
--- modulepack_mario.lua
--
-- This modulepack is for running Nnaaaz#0000's mario map.
--
-- @author Nnaaaz#0000 (map, lua script)
-- @author TFM:Pshy#3752 DC:Pshy#7998 (lua script)
-- @require pshy_merge.lua
-- @require pshy_fcplatform.lua
-- @require pshy_checkpoints.lua
-- @require pshy_fun_commands.lua
-- @require pshy_speedfly.lua
-- @require pshy_scores.lua
-- @require pshy_emoticons.lua
--- help Page:
pshy.help_pages[""] = {back = nil, title = "Mario", text = "Try to collect all the coins!\nGame made by <ch>Nnaaaz#0000</ch> and <ch>Pshy#3752</ch>.\n"}
--- Pshy Settings:
pshy.scores_per_first_wins = {}			-- no firsts
pshy.scores_per_bonus = 1				-- get points per bonus
pshy.scores_reset_on_leave = true
pshy.scores_show = false
pshy.fun_commands_DisableCheatCommands()
pshy.speedfly_DisableCheatCommands()
pshy.perms_auto_admin_authors = true	-- add the authors as admin automatically
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
map_xml='<C><P L="33000" H="600" G="0,5" /><Z><S><S T="12" X="16500" Y="783" L="1000" H="100" P="0,0,0.3,0.2,0,0,0,0" c="4"/><S T="13" X="-308" Y="310" L="15" P="1,999999999,0,0,0,1,0,0" c="2" nosync=""/><S T="12" X="340" Y="568" L="684" H="69" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="856" Y="516" L="166" H="39" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="1188" Y="425" L="340" H="40" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="1185" Y="255" L="211" H="38" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="1434" Y="514" L="126" H="41" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="1607" Y="345" L="214" H="42" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="1862" Y="212" L="298" H="41" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="2293" Y="558" L="168" H="41" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="2634" Y="557" L="214" H="42" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="2892" Y="558" L="210" H="41" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="3063" Y="387" L="124" H="42" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="2657" Y="213" L="170" H="39" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="3383" Y="257" L="252" H="42" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="4284" Y="472" L="170" H="41" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="4628" Y="300" L="342" H="41" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="4907" Y="556" L="125" H="38" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="5057" Y="385" L="169" H="42" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="5193" Y="553" L="169" H="41" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="5420" Y="557" L="128" H="41" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="5849" Y="568" L="643" H="64" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="6040" Y="451" L="256" H="171" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="6126" Y="345" L="85" H="301" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="6044" Y="326" L="91" H="94" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="10800" Y="559" L="210" H="41" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="11119" Y="215" L="214" H="41" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="11333" Y="387" L="298" H="45" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="11632" Y="171" L="129" H="40" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="11975" Y="216" L="211" H="42" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="11890" Y="514" L="298" H="41" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="12147" Y="385" L="124" H="38" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="12447" Y="343" L="124" H="41" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="13087" Y="559" L="211" H="42" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="13133" Y="301" L="126" H="38" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="13262" Y="129" L="127" H="42" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="13348" Y="386" L="125" H="40" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="13475" Y="217" L="210" H="42" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="13861" Y="387" L="126" H="41" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="14503" Y="472" L="127" H="43" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="14761" Y="429" L="129" H="38" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="15146" Y="386" L="211" H="41" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="15275" Y="259" L="124" H="41" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="15533" Y="559" L="300" H="46" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="15875" Y="430" L="211" H="41" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="16619" Y="569" L="762" H="64" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="16517" Y="516" L="41" H="45" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="16815" Y="309" L="373" H="14" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="16816" Y="179" L="205" H="10" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="16818" Y="90" L="127" H="10" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="13" X="16518" Y="97" L="10" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="10103" Y="437" L="211" H="18" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="10103" Y="348" L="128" H="10" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="16816" Y="492" L="51" H="86" P="0,0,0.3,0.2,0,0,0,0" o="000000" c="4"/><S T="19" X="2294" Y="525" L="29" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="25738" Y="528" L="29" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="23924" Y="310" L="29" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="13481" Y="183" L="29" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="24240" Y="527" L="29" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="14761" Y="399" L="29" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="15871" Y="399" L="29" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="20961" Y="359" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="1185" Y="394" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="21415" Y="357" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="1855" Y="182" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="2645" Y="182" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="22942" Y="353" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="22853" Y="354" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="2893" Y="524" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="4631" Y="267" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="23750" Y="394" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="4909" Y="525" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="24741" Y="355" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="25870" Y="356" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="26942" Y="521" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="5416" Y="525" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="21091" Y="529" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="11113" Y="183" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="11275" Y="354" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="11391" Y="354" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="11802" Y="483" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="11973" Y="183" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="24946" Y="524" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="21905" Y="527" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="11987" Y="483" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="13134" Y="268" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="13346" Y="356" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="15086" Y="356" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="15186" Y="356" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="15446" Y="526" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="24656" Y="354" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="15626" Y="526" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="5701" Y="525" L="36" H="21" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="13" X="2294" Y="514" L="14" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="25737" Y="517" L="14" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="23924" Y="298" L="14" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="13481" Y="171" L="14" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="24240" Y="515" L="14" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="14761" Y="387" L="14" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="15871" Y="387" L="14" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="20962" Y="344" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="1186" Y="380" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="21415" Y="343" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="1856" Y="168" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="2645" Y="168" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="22943" Y="339" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="22854" Y="340" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="2893" Y="511" L="14" P="1,0,0.3,0.4,0,1,0,0" c="3" nosync=""/><S T="13" X="4632" Y="253" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="23751" Y="380" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="4910" Y="511" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="24742" Y="341" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="25871" Y="342" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="26943" Y="507" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="5417" Y="511" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="21092" Y="515" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="11114" Y="169" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="11276" Y="340" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="11392" Y="340" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="11803" Y="469" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="11974" Y="169" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="24947" Y="510" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="21906" Y="513" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="11988" Y="469" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="13135" Y="254" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="13347" Y="342" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="15087" Y="342" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="15187" Y="342" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="15447" Y="512" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="24657" Y="340" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="15627" Y="512" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="13" X="5702" Y="511" L="13" P="1,0,0.3,0.3,0,1,0,0" c="3" nosync=""/><S T="19" X="21764" Y="250" L="34" H="26" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="3694" Y="325" L="34" H="26" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="25354" Y="320" L="34" H="26" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="26094" Y="420" L="34" H="26" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="12724" Y="346" L="34" H="26" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="19" X="14104" Y="316" L="34" H="26" P="1,0,0.3,0,0,1,0,0" c="3" m="" nosync=""/><S T="13" X="21765" Y="241" L="16" P="1,0,0.3,0.2,-32767,0,0,0" c="3" nosync=""/><S T="13" X="3695" Y="315" L="15" P="1,0,0.3,0.2,-32767,0,0,0" c="3" nosync=""/><S T="13" X="25355" Y="309" L="15" P="1,0,0.3,0.2,-32767,0,0,0" c="3" nosync=""/><S T="13" X="26095" Y="409" L="15" P="1,0,0.3,0.2,-32767,0,0,0" c="3" nosync=""/><S T="13" X="12725" Y="334" L="15" P="1,0,0.3,0.2,-32767,0,0,0" c="3" nosync=""/><S T="13" X="14105" Y="305" L="15" P="1,0,0.3,0.2,-32727,0,0,0" c="3" nosync=""/><S T="12" X="2190" Y="228" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="1490" Y="203" L="55" H="10" P="0,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="22330" Y="103" L="55" H="10" P="0,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="23570" Y="143" L="55" H="10" P="0,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="23209" Y="443" L="55" H="10" P="0,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="23449" Y="444" L="55" H="10" P="0,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="24690" Y="483" L="55" H="10" P="0,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="22070" Y="105" L="55" H="10" P="1,0,0.3,0.2,0,0,0,0" c="3" nosync=""/><S T="12" X="3330" Y="529" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="4100" Y="278" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="3700" Y="348" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="5300" Y="298" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="21560" Y="149" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="22430" Y="469" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="24010" Y="139" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="24980" Y="249" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="26140" Y="389" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="23190" Y="239" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="12700" Y="479" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="13840" Y="199" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="14080" Y="499" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="14720" Y="199" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="2380" Y="228" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="3520" Y="528" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="4290" Y="278" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="3890" Y="348" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="5490" Y="298" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="21750" Y="149" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="22620" Y="469" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="24200" Y="139" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="25170" Y="249" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="26330" Y="389" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="23380" Y="239" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="12890" Y="479" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="14030" Y="199" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="14260" Y="199" L="55" H="10" P="1,10,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="11399" Y="172" L="55" H="10" P="1,10,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="21239" Y="472" L="55" H="10" P="1,10,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="21069" Y="242" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="21299" Y="181" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="22569" Y="262" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="25389" Y="212" L="55" H="10" P="1,10,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="26549" Y="362" L="55" H="10" P="1,10,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="11039" Y="472" L="55" H="10" P="1,10,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="4599" Y="472" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="3789" Y="551" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="1999" Y="541" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="3999" Y="521" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="6429" Y="221" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="14510" Y="199" L="55" H="10" P="1,10,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="14270" Y="499" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="14910" Y="199" L="55" H="10" P="1,0,0.3,0.2,0,1,0,0" c="3" nosync=""/><S T="12" X="-442" Y="381" L="145" H="209" P="1,-1,0,1,0,1,0,0" c="2" nosync=""/><S T="12" X="-177" Y="389" L="127" H="221" P="1,-1,0,1,0,1,0,0" c="2" nosync=""/><S T="12" X="-282" Y="284" L="20" H="20" P="1,99999999999,0,1,40,1,0,0" c="2" nosync=""/><S T="12" X="16517" Y="272" L="10" H="314" P="0,0,0.3,0.2,0,0,0,0" c="3"/><S T="12" X="10292" Y="571" L="590" H="72" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="7013" Y="570" L="785" H="67" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="6899" Y="514" L="43" H="39" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="20341" Y="568" L="684" H="62" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="20835" Y="558" L="126" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="20965" Y="386" L="126" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="21092" Y="558" L="126" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="21415" Y="386" L="168" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="22186" Y="472" L="168" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="24243" Y="556" L="168" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="25743" Y="556" L="168" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="25871" Y="385" L="168" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="21650" Y="558" L="126" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="21908" Y="558" L="126" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="23707" Y="129" L="126" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="23922" Y="344" L="126" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="24050" Y="557" L="126" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="24479" Y="558" L="126" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="24950" Y="558" L="210" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="24693" Y="385" L="212" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="22894" Y="386" L="212" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="23750" Y="428" L="212" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="25335" Y="558" L="126" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="25722" Y="214" L="126" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="26750" Y="215" L="126" H="40" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="27274" Y="568" L="839" H="63" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="27488" Y="306" L="397" H="12" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="27481" Y="179" L="203" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="27481" Y="89" L="131" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="27179" Y="261" L="10" H="304" P="0,0,0.3,0.2,0,0,0,0"/><S T="13" X="27179" Y="96" L="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="27178" Y="515" L="41" H="42" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="20105" Y="435" L="218" H="16" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="20106" Y="347" L="123" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="6899" Y="266" L="10" H="310" P="0,0,0.3,0.2,0,0,0,0"/><S T="13" X="6898" Y="96" L="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="7205" Y="306" L="400" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="7195" Y="176" L="210" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="7197" Y="91" L="126" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="11891" Y="452" L="78" H="84" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="13069" Y="496" L="27" H="87" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="3358" Y="196" L="27" H="87" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="13121" Y="495" L="27" H="86" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="3410" Y="195" L="27" H="86" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="13112" Y="496" L="27" H="84" P="0,0,0,0,3,0,0,0"/><S T="12" X="3401" Y="196" L="27" H="84" P="0,0,0,0,3,0,0,0"/><S T="12" X="13078" Y="496" L="27" H="84" P="0,0,0,0,-3,0,0,0"/><S T="12" X="3367" Y="196" L="27" H="84" P="0,0,0,0,-3,0,0,0"/><S T="12" X="2632" Y="493" L="81" H="83" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="7196" Y="490" L="45" H="87" P="0,0,0.3,0.2,0,0,0,0" o="000000" c="4"/><S T="12" X="27477" Y="492" L="45" H="87" P="0,0,0.3,0.2,0,0,0,0" o="747474" c="4"/><S T="12" X="32445" Y="570" L="690" H="70" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="32124" Y="296" L="53" H="472" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="32399" Y="388" L="342" H="43" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="32250" Y="436" L="43" H="68" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="32552" Y="437" L="44" H="69" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="32485" Y="84" L="513" H="49" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="32767" Y="296" L="47" H="473" P="0,0,0,0.2,0,0,0,0"/><S T="12" X="32708" Y="459" L="93" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="32219" Y="59" L="230" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="29724" Y="329" L="45" H="530" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="30040" Y="558" L="683" H="45" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="30021" Y="474" L="305" H="132" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="30023" Y="84" L="307" H="39" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="30043" Y="-5" L="683" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="30373" Y="322" L="42" H="507" P="0,0,0,0.2,0,0,0,0"/><S T="12" X="30389" Y="33" L="12" H="64" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="29695" Y="31" L="10" H="68" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="30305" Y="458" L="92" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="107" Y="436" L="211" H="17" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="107" Y="348" L="126" H="10" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="30307" Y="543" L="95" H="32" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="32706" Y="539" L="86" H="28" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="24700" Y="345" L="10" H="10" P="0,0,0.3,0.2,0,0,0,0" o="324650"/></S><D><F X="7196" Y="527"/><T X="7196" Y="532" D=""/><F X="16814" Y="525"/><T X="16816" Y="532" D=""/><F X="27477" Y="529"/><T X="27477" Y="534" D=""/><DS X="105" Y="515"/></D><O/><L><JD c="eec277,22,1,0" M1="61" M2="61" P1="20961.27,357.06" P2="20961.27,358.06"/><JD c="eec277,22,1,0" M1="62" M2="62" P1="1185.27,392.06" P2="1185.27,393.06"/><JD c="eec277,22,1,0" M1="63" M2="63" P1="21415.27,355.06" P2="21415.27,356.06"/><JD c="eec277,22,1,0" M1="64" M2="64" P1="1855.27,180.06" P2="1855.27,181.06"/><JD c="eec277,22,1,0" M1="65" M2="65" P1="2645.27,180.06" P2="2645.27,181.06"/><JD c="eec277,22,1,0" M1="66" M2="66" P1="22942.27,351.06" P2="22942.27,352.06"/><JD c="eec277,22,1,0" M1="67" M2="67" P1="22853.27,352.06" P2="22853.27,353.06"/><JD c="eec277,22,1,0" M1="68" M2="68" P1="2893.27,522.06" P2="2893.27,523.06"/><JD c="eec277,22,1,0" M1="69" M2="69" P1="4631.27,265.06" P2="4631.27,266.06"/><JD c="eec277,22,1,0" M1="70" M2="70" P1="23750.27,392.06" P2="23750.27,393.06"/><JD c="eec277,22,1,0" M1="71" M2="71" P1="4909.27,523.06" P2="4909.27,524.06"/><JD c="eec277,22,1,0" M1="72" M2="72" P1="24741.27,353.06" P2="24741.27,354.06"/><JD c="eec277,22,1,0" M1="73" M2="73" P1="25870.27,354.06" P2="25870.27,355.06"/><JD c="eec277,22,1,0" M1="74" M2="74" P1="26942.27,519.06" P2="26942.27,520.06"/><JD c="eec277,22,1,0" M1="75" M2="75" P1="5416.27,523.06" P2="5416.27,524.06"/><JD c="eec277,22,1,0" M1="76" M2="76" P1="21091.27,527.06" P2="21091.27,528.06"/><JD c="eec277,22,1,0" M1="77" M2="77" P1="11113.27,181.06" P2="11113.27,182.06"/><JD c="eec277,22,1,0" M1="78" M2="78" P1="11275.27,352.06" P2="11275.27,353.06"/><JD c="eec277,22,1,0" M1="79" M2="79" P1="11391.27,352.06" P2="11391.27,353.06"/><JD c="eec277,22,1,0" M1="80" M2="80" P1="11802.27,481.06" P2="11802.27,482.06"/><JD c="eec277,22,1,0" M1="81" M2="81" P1="11973.27,181.06" P2="11973.27,182.06"/><JD c="eec277,22,1,0" M1="82" M2="82" P1="24946.27,522.06" P2="24946.27,523.06"/><JD c="eec277,22,1,0" M1="83" M2="83" P1="21905.27,525.06" P2="21905.27,526.06"/><JD c="eec277,22,1,0" M1="84" M2="84" P1="11987.27,481.06" P2="11987.27,482.06"/><JD c="eec277,22,1,0" M1="85" M2="85" P1="13134.27,266.06" P2="13134.27,267.06"/><JD c="eec277,22,1,0" M1="86" M2="86" P1="13346.27,354.06" P2="13346.27,355.06"/><JD c="eec277,22,1,0" M1="87" M2="87" P1="15086.27,354.06" P2="15086.27,355.06"/><JD c="eec277,22,1,0" M1="88" M2="88" P1="15186.27,354.06" P2="15186.27,355.06"/><JD c="eec277,22,1,0" M1="89" M2="89" P1="15446.27,524.06" P2="15446.27,525.06"/><JD c="eec277,22,1,0" M1="90" M2="90" P1="24656.27,352.06" P2="24656.27,353.06"/><JD c="eec277,22,1,0" M1="91" M2="91" P1="15626.27,524.06" P2="15626.27,525.06"/><JD c="eec277,22,1,0" M1="92" M2="92" P1="5701.27,523.06" P2="5701.27,524.06"/><JD c="923b21,13,1,0" M1="61" M2="61" P1="20948,350" P2="20961,338"/><JD c="923b21,13,1,0" M1="62" M2="62" P1="1172,385" P2="1185,373"/><JD c="923b21,13,1,0" M1="63" M2="63" P1="21402,348" P2="21415,336"/><JD c="923b21,13,1,0" M1="64" M2="64" P1="1842,173" P2="1855,161"/><JD c="923b21,13,1,0" M1="65" M2="65" P1="2632,173" P2="2645,161"/><JD c="923b21,13,1,0" M1="66" M2="66" P1="22929,344" P2="22942,332"/><JD c="923b21,13,1,0" M1="67" M2="67" P1="22840,345" P2="22853,333"/><JD c="923b21,13,1,0" M1="68" M2="68" P1="2880,515" P2="2893,503"/><JD c="923b21,13,1,0" M1="69" M2="69" P1="4618,258" P2="4631,246"/><JD c="923b21,13,1,0" M1="70" M2="70" P1="23737,385" P2="23750,373"/><JD c="923b21,13,1,0" M1="71" M2="71" P1="4896,516" P2="4909,504"/><JD c="923b21,13,1,0" M1="72" M2="72" P1="24728,346" P2="24741,334"/><JD c="923b21,13,1,0" M1="73" M2="73" P1="25857,347" P2="25870,335"/><JD c="923b21,13,1,0" M1="74" M2="74" P1="26929,512" P2="26942,500"/><JD c="923b21,13,1,0" M1="75" M2="75" P1="5403,516" P2="5416,504"/><JD c="923b21,13,1,0" M1="76" M2="76" P1="21078,520" P2="21091,508"/><JD c="923b21,13,1,0" M1="77" M2="77" P1="11100,174" P2="11113,162"/><JD c="923b21,13,1,0" M1="78" M2="78" P1="11262,345" P2="11275,333"/><JD c="923b21,13,1,0" M1="79" M2="79" P1="11378,345" P2="11391,333"/><JD c="923b21,13,1,0" M1="80" M2="80" P1="11789,474" P2="11802,462"/><JD c="923b21,13,1,0" M1="81" M2="81" P1="11960,174" P2="11973,162"/><JD c="923b21,13,1,0" M1="82" M2="82" P1="24933,515" P2="24946,503"/><JD c="923b21,13,1,0" M1="83" M2="83" P1="21892,518" P2="21905,506"/><JD c="923b21,13,1,0" M1="84" M2="84" P1="11974,474" P2="11987,462"/><JD c="923b21,13,1,0" M1="85" M2="85" P1="13121,259" P2="13134,247"/><JD c="923b21,13,1,0" M1="86" M2="86" P1="13333,347" P2="13346,335"/><JD c="923b21,13,1,0" M1="87" M2="87" P1="15073,347" P2="15086,335"/><JD c="923b21,13,1,0" M1="88" M2="88" P1="15173,347" P2="15186,335"/><JD c="923b21,13,1,0" M1="89" M2="89" P1="15433,517" P2="15446,505"/><JD c="923b21,13,1,0" M1="90" M2="90" P1="24643,345" P2="24656,333"/><JD c="923b21,13,1,0" M1="91" M2="91" P1="15613,517" P2="15626,505"/><JD c="923b21,13,1,0" M1="92" M2="92" P1="5688,516" P2="5701,504"/><JD c="923b21,13,1,0" M1="61" M2="61" P1="20974,350" P2="20961,338"/><JD c="923b21,13,1,0" M1="62" M2="62" P1="1198,385" P2="1185,373"/><JD c="923b21,13,1,0" M1="63" M2="63" P1="21428,348" P2="21415,336"/><JD c="923b21,13,1,0" M1="64" M2="64" P1="1868,173" P2="1855,161"/><JD c="923b21,13,1,0" M1="65" M2="65" P1="2658,173" P2="2645,161"/><JD c="923b21,13,1,0" M1="66" M2="66" P1="22955,344" P2="22942,332"/><JD c="923b21,13,1,0" M1="67" M2="67" P1="22866,345" P2="22853,333"/><JD c="923b21,13,1,0" M1="68" M2="68" P1="2906,515" P2="2893,503"/><JD c="923b21,13,1,0" M1="69" M2="69" P1="4644,258" P2="4631,246"/><JD c="923b21,13,1,0" M1="70" M2="70" P1="23763,385" P2="23750,373"/><JD c="923b21,13,1,0" M1="71" M2="71" P1="4922,516" P2="4909,504"/><JD c="923b21,13,1,0" M1="72" M2="72" P1="24754,346" P2="24741,334"/><JD c="923b21,13,1,0" M1="73" M2="73" P1="25883,347" P2="25870,335"/><JD c="923b21,13,1,0" M1="74" M2="74" P1="26955,512" P2="26942,500"/><JD c="923b21,13,1,0" M1="75" M2="75" P1="5429,516" P2="5416,504"/><JD c="923b21,13,1,0" M1="76" M2="76" P1="21104,520" P2="21091,508"/><JD c="923b21,13,1,0" M1="77" M2="77" P1="11126,174" P2="11113,162"/><JD c="923b21,13,1,0" M1="78" M2="78" P1="11288,345" P2="11275,333"/><JD c="923b21,13,1,0" M1="79" M2="79" P1="11404,345" P2="11391,333"/><JD c="923b21,13,1,0" M1="80" M2="80" P1="11815,474" P2="11802,462"/><JD c="923b21,13,1,0" M1="81" M2="81" P1="11986,174" P2="11973,162"/><JD c="923b21,13,1,0" M1="82" M2="82" P1="24959,515" P2="24946,503"/><JD c="923b21,13,1,0" M1="83" M2="83" P1="21918,518" P2="21905,506"/><JD c="923b21,13,1,0" M1="84" M2="84" P1="12000,474" P2="11987,462"/><JD c="923b21,13,1,0" M1="85" M2="85" P1="13147,259" P2="13134,247"/><JD c="923b21,13,1,0" M1="86" M2="86" P1="13359,347" P2="13346,335"/><JD c="923b21,13,1,0" M1="87" M2="87" P1="15099,347" P2="15086,335"/><JD c="923b21,13,1,0" M1="88" M2="88" P1="15199,347" P2="15186,335"/><JD c="923b21,13,1,0" M1="89" M2="89" P1="15459,517" P2="15446,505"/><JD c="923b21,13,1,0" M1="90" M2="90" P1="24669,345" P2="24656,333"/><JD c="923b21,13,1,0" M1="91" M2="91" P1="15639,517" P2="15626,505"/><JD c="923b21,13,1,0" M1="92" M2="92" P1="5714,516" P2="5701,504"/><JD c="923b21,13,1,0" M1="61" M2="61" P1="20949,350" P2="20972,350"/><JD c="923b21,13,1,0" M1="62" M2="62" P1="1173,385" P2="1196,385"/><JD c="923b21,13,1,0" M1="63" M2="63" P1="21403,348" P2="21426,348"/><JD c="923b21,13,1,0" M1="64" M2="64" P1="1843,173" P2="1866,173"/><JD c="923b21,13,1,0" M1="65" M2="65" P1="2633,173" P2="2656,173"/><JD c="923b21,13,1,0" M1="66" M2="66" P1="22930,344" P2="22953,344"/><JD c="923b21,13,1,0" M1="67" M2="67" P1="22841,345" P2="22864,345"/><JD c="923b21,13,1,0" M1="68" M2="68" P1="2881,515" P2="2904,515"/><JD c="923b21,13,1,0" M1="69" M2="69" P1="4619,258" P2="4642,258"/><JD c="923b21,13,1,0" M1="70" M2="70" P1="23738,385" P2="23761,385"/><JD c="923b21,13,1,0" M1="71" M2="71" P1="4897,516" P2="4920,516"/><JD c="923b21,13,1,0" M1="72" M2="72" P1="24729,346" P2="24752,346"/><JD c="923b21,13,1,0" M1="73" M2="73" P1="25858,347" P2="25881,347"/><JD c="923b21,13,1,0" M1="74" M2="74" P1="26930,512" P2="26953,512"/><JD c="923b21,13,1,0" M1="75" M2="75" P1="5404,516" P2="5427,516"/><JD c="923b21,13,1,0" M1="76" M2="76" P1="21079,520" P2="21102,520"/><JD c="923b21,13,1,0" M1="77" M2="77" P1="11101,174" P2="11124,174"/><JD c="923b21,13,1,0" M1="78" M2="78" P1="11263,345" P2="11286,345"/><JD c="923b21,13,1,0" M1="79" M2="79" P1="11379,345" P2="11402,345"/><JD c="923b21,13,1,0" M1="80" M2="80" P1="11790,474" P2="11813,474"/><JD c="923b21,13,1,0" M1="81" M2="81" P1="11961,174" P2="11984,174"/><JD c="923b21,13,1,0" M1="82" M2="82" P1="24934,515" P2="24957,515"/><JD c="923b21,13,1,0" M1="83" M2="83" P1="21893,518" P2="21916,518"/><JD c="923b21,13,1,0" M1="84" M2="84" P1="11975,474" P2="11998,474"/><JD c="923b21,13,1,0" M1="85" M2="85" P1="13122,259" P2="13145,259"/><JD c="923b21,13,1,0" M1="86" M2="86" P1="13334,347" P2="13357,347"/><JD c="923b21,13,1,0" M1="87" M2="87" P1="15074,347" P2="15097,347"/><JD c="923b21,13,1,0" M1="88" M2="88" P1="15174,347" P2="15197,347"/><JD c="923b21,13,1,0" M1="89" M2="89" P1="15434,517" P2="15457,517"/><JD c="923b21,13,1,0" M1="90" M2="90" P1="24644,345" P2="24667,345"/><JD c="923b21,13,1,0" M1="91" M2="91" P1="15614,517" P2="15637,517"/><JD c="923b21,13,1,0" M1="92" M2="92" P1="5689,516" P2="5712,516"/><JD c="000000,8,1,0" M1="61" M2="61" P1="20951.54,366.09" P2="20953.66,367"/><JD c="000000,8,1,0" M1="62" M2="62" P1="1175.54,401.09" P2="1177.66,402"/><JD c="000000,8,1,0" M1="63" M2="63" P1="21405.54,364.09" P2="21407.66,365"/><JD c="000000,8,1,0" M1="64" M2="64" P1="1845.54,189.09" P2="1847.66,190"/><JD c="000000,8,1,0" M1="65" M2="65" P1="2635.54,189.09" P2="2637.66,190"/><JD c="000000,8,1,0" M1="66" M2="66" P1="22932.54,360.09" P2="22934.66,361"/><JD c="000000,8,1,0" M1="67" M2="67" P1="22843.54,361.09" P2="22845.66,362"/><JD c="000000,8,1,0" M1="68" M2="68" P1="2883.54,531.09" P2="2885.66,532"/><JD c="000000,8,1,0" M1="69" M2="69" P1="4621.54,274.09" P2="4623.66,275"/><JD c="000000,8,1,0" M1="70" M2="70" P1="23740.54,401.09" P2="23742.66,402"/><JD c="000000,8,1,0" M1="71" M2="71" P1="4899.54,532.09" P2="4901.66,533"/><JD c="000000,8,1,0" M1="72" M2="72" P1="24731.54,362.09" P2="24733.66,363"/><JD c="000000,8,1,0" M1="73" M2="73" P1="25860.54,363.09" P2="25862.66,364"/><JD c="000000,8,1,0" M1="74" M2="74" P1="26932.54,528.09" P2="26934.66,529"/><JD c="000000,8,1,0" M1="75" M2="75" P1="5406.54,532.09" P2="5408.66,533"/><JD c="000000,8,1,0" M1="76" M2="76" P1="21081.54,536.09" P2="21083.66,537"/><JD c="000000,8,1,0" M1="77" M2="77" P1="11103.54,190.09" P2="11105.66,191"/><JD c="000000,8,1,0" M1="78" M2="78" P1="11265.54,361.09" P2="11267.66,362"/><JD c="000000,8,1,0" M1="79" M2="79" P1="11381.54,361.09" P2="11383.66,362"/><JD c="000000,8,1,0" M1="80" M2="80" P1="11792.54,490.09" P2="11794.66,491"/><JD c="000000,8,1,0" M1="81" M2="81" P1="11963.54,190.09" P2="11965.66,191"/><JD c="000000,8,1,0" M1="82" M2="82" P1="24936.54,531.09" P2="24938.66,532"/><JD c="000000,8,1,0" M1="83" M2="83" P1="21895.54,534.09" P2="21897.66,535"/><JD c="000000,8,1,0" M1="84" M2="84" P1="11977.54,490.09" P2="11979.66,491"/><JD c="000000,8,1,0" M1="85" M2="85" P1="13124.54,275.09" P2="13126.66,276"/><JD c="000000,8,1,0" M1="86" M2="86" P1="13336.54,363.09" P2="13338.66,364"/><JD c="000000,8,1,0" M1="87" M2="87" P1="15076.54,363.09" P2="15078.66,364"/><JD c="000000,8,1,0" M1="88" M2="88" P1="15176.54,363.09" P2="15178.66,364"/><JD c="000000,8,1,0" M1="89" M2="89" P1="15436.54,533.09" P2="15438.66,534"/><JD c="000000,8,1,0" M1="90" M2="90" P1="24646.54,361.09" P2="24648.66,362"/><JD c="000000,8,1,0" M1="91" M2="91" P1="15616.54,533.09" P2="15618.66,534"/><JD c="000000,8,1,0" M1="92" M2="92" P1="5691.54,532.09" P2="5693.66,533"/><JD c="000000,8,1,0" M1="61" M2="61" P1="20971.76,365.09" P2="20969.64,367.21"/><JD c="000000,8,1,0" M1="62" M2="62" P1="1195.76,400.09" P2="1193.64,402.21"/><JD c="000000,8,1,0" M1="63" M2="63" P1="21425.76,363.09" P2="21423.64,365.21"/><JD c="000000,8,1,0" M1="64" M2="64" P1="1865.76,188.09" P2="1863.64,190.21"/><JD c="000000,8,1,0" M1="65" M2="65" P1="2655.76,188.09" P2="2653.64,190.21"/><JD c="000000,8,1,0" M1="66" M2="66" P1="22952.76,359.09" P2="22950.64,361.21"/><JD c="000000,8,1,0" M1="67" M2="67" P1="22863.76,360.09" P2="22861.64,362.21"/><JD c="000000,8,1,0" M1="68" M2="68" P1="2903.76,530.09" P2="2901.64,532.21"/><JD c="000000,8,1,0" M1="69" M2="69" P1="4641.76,273.09" P2="4639.64,275.21"/><JD c="000000,8,1,0" M1="70" M2="70" P1="23760.76,400.09" P2="23758.64,402.21"/><JD c="000000,8,1,0" M1="71" M2="71" P1="4919.76,531.09" P2="4917.64,533.21"/><JD c="000000,8,1,0" M1="72" M2="72" P1="24751.76,361.09" P2="24749.64,363.21"/><JD c="000000,8,1,0" M1="73" M2="73" P1="25880.76,362.09" P2="25878.64,364.21"/><JD c="000000,8,1,0" M1="74" M2="74" P1="26952.76,527.09" P2="26950.64,529.21"/><JD c="000000,8,1,0" M1="75" M2="75" P1="5426.76,531.09" P2="5424.64,533.21"/><JD c="000000,8,1,0" M1="76" M2="76" P1="21101.76,535.09" P2="21099.64,537.21"/><JD c="000000,8,1,0" M1="77" M2="77" P1="11123.76,189.09" P2="11121.64,191.21"/><JD c="000000,8,1,0" M1="78" M2="78" P1="11285.76,360.09" P2="11283.64,362.21"/><JD c="000000,8,1,0" M1="79" M2="79" P1="11401.76,360.09" P2="11399.64,362.21"/><JD c="000000,8,1,0" M1="80" M2="80" P1="11812.76,489.09" P2="11810.64,491.21"/><JD c="000000,8,1,0" M1="81" M2="81" P1="11983.76,189.09" P2="11981.64,191.21"/><JD c="000000,8,1,0" M1="82" M2="82" P1="24956.76,530.09" P2="24954.64,532.21"/><JD c="000000,8,1,0" M1="83" M2="83" P1="21915.76,533.09" P2="21913.64,535.21"/><JD c="000000,8,1,0" M1="84" M2="84" P1="11997.76,489.09" P2="11995.64,491.21"/><JD c="000000,8,1,0" M1="85" M2="85" P1="13144.76,274.09" P2="13142.64,276.21"/><JD c="000000,8,1,0" M1="86" M2="86" P1="13356.76,362.09" P2="13354.64,364.21"/><JD c="000000,8,1,0" M1="87" M2="87" P1="15096.76,362.09" P2="15094.64,364.21"/><JD c="000000,8,1,0" M1="88" M2="88" P1="15196.76,362.09" P2="15194.64,364.21"/><JD c="000000,8,1,0" M1="89" M2="89" P1="15456.76,532.09" P2="15454.64,534.21"/><JD c="000000,8,1,0" M1="90" M2="90" P1="24666.76,360.09" P2="24664.64,362.21"/><JD c="000000,8,1,0" M1="91" M2="91" P1="15636.76,532.09" P2="15634.64,534.21"/><JD c="000000,8,1,0" M1="92" M2="92" P1="5711.76,531.09" P2="5709.64,533.21"/><JD c="eec277,8,1,0" M1="61" M2="61" P1="20956,345" P2="20956,347"/><JD c="eec277,8,1,0" M1="62" M2="62" P1="1180,380" P2="1180,382"/><JD c="eec277,8,1,0" M1="63" M2="63" P1="21410,343" P2="21410,345"/><JD c="eec277,8,1,0" M1="64" M2="64" P1="1850,168" P2="1850,170"/><JD c="eec277,8,1,0" M1="65" M2="65" P1="2640,168" P2="2640,170"/><JD c="eec277,8,1,0" M1="66" M2="66" P1="22937,339" P2="22937,341"/><JD c="eec277,8,1,0" M1="67" M2="67" P1="22848,340" P2="22848,342"/><JD c="eec277,8,1,0" M1="68" M2="68" P1="2888,510" P2="2888,512"/><JD c="eec277,8,1,0" M1="69" M2="69" P1="4626,253" P2="4626,255"/><JD c="eec277,8,1,0" M1="70" M2="70" P1="23745,380" P2="23745,382"/><JD c="eec277,8,1,0" M1="71" M2="71" P1="4904,511" P2="4904,513"/><JD c="eec277,8,1,0" M1="72" M2="72" P1="24736,341" P2="24736,343"/><JD c="eec277,8,1,0" M1="73" M2="73" P1="25865,342" P2="25865,344"/><JD c="eec277,8,1,0" M1="74" M2="74" P1="26937,507" P2="26937,509"/><JD c="eec277,8,1,0" M1="75" M2="75" P1="5411,511" P2="5411,513"/><JD c="eec277,8,1,0" M1="76" M2="76" P1="21086,515" P2="21086,517"/><JD c="eec277,8,1,0" M1="77" M2="77" P1="11108,169" P2="11108,171"/><JD c="eec277,8,1,0" M1="78" M2="78" P1="11270,340" P2="11270,342"/><JD c="eec277,8,1,0" M1="79" M2="79" P1="11386,340" P2="11386,342"/><JD c="eec277,8,1,0" M1="80" M2="80" P1="11797,469" P2="11797,471"/><JD c="eec277,8,1,0" M1="81" M2="81" P1="11968,169" P2="11968,171"/><JD c="eec277,8,1,0" M1="82" M2="82" P1="24941,510" P2="24941,512"/><JD c="eec277,8,1,0" M1="83" M2="83" P1="21900,513" P2="21900,515"/><JD c="eec277,8,1,0" M1="84" M2="84" P1="11982,469" P2="11982,471"/><JD c="eec277,8,1,0" M1="85" M2="85" P1="13129,254" P2="13129,256"/><JD c="eec277,8,1,0" M1="86" M2="86" P1="13341,342" P2="13341,344"/><JD c="eec277,8,1,0" M1="87" M2="87" P1="15081,342" P2="15081,344"/><JD c="eec277,8,1,0" M1="88" M2="88" P1="15181,342" P2="15181,344"/><JD c="eec277,8,1,0" M1="89" M2="89" P1="15441,512" P2="15441,514"/><JD c="eec277,8,1,0" M1="90" M2="90" P1="24651,340" P2="24651,342"/><JD c="eec277,8,1,0" M1="91" M2="91" P1="15621,512" P2="15621,514"/><JD c="eec277,8,1,0" M1="92" M2="92" P1="5696,511" P2="5696,513"/><JD c="eec277,8,1,0" M1="61" M2="61" P1="20966,345" P2="20966,347"/><JD c="eec277,8,1,0" M1="62" M2="62" P1="1190,380" P2="1190,382"/><JD c="eec277,8,1,0" M1="63" M2="63" P1="21420,343" P2="21420,345"/><JD c="eec277,8,1,0" M1="64" M2="64" P1="1860,168" P2="1860,170"/><JD c="eec277,8,1,0" M1="65" M2="65" P1="2650,168" P2="2650,170"/><JD c="eec277,8,1,0" M1="66" M2="66" P1="22947,339" P2="22947,341"/><JD c="eec277,8,1,0" M1="67" M2="67" P1="22858,340" P2="22858,342"/><JD c="eec277,8,1,0" M1="68" M2="68" P1="2898,510" P2="2898,512"/><JD c="eec277,8,1,0" M1="69" M2="69" P1="4636,253" P2="4636,255"/><JD c="eec277,8,1,0" M1="70" M2="70" P1="23755,380" P2="23755,382"/><JD c="eec277,8,1,0" M1="71" M2="71" P1="4914,511" P2="4914,513"/><JD c="eec277,8,1,0" M1="72" M2="72" P1="24746,341" P2="24746,343"/><JD c="eec277,8,1,0" M1="73" M2="73" P1="25875,342" P2="25875,344"/><JD c="eec277,8,1,0" M1="74" M2="74" P1="26947,507" P2="26947,509"/><JD c="eec277,8,1,0" M1="75" M2="75" P1="5421,511" P2="5421,513"/><JD c="eec277,8,1,0" M1="76" M2="76" P1="21096,515" P2="21096,517"/><JD c="eec277,8,1,0" M1="77" M2="77" P1="11118,169" P2="11118,171"/><JD c="eec277,8,1,0" M1="78" M2="78" P1="11280,340" P2="11280,342"/><JD c="eec277,8,1,0" M1="79" M2="79" P1="11396,340" P2="11396,342"/><JD c="eec277,8,1,0" M1="80" M2="80" P1="11807,469" P2="11807,471"/><JD c="eec277,8,1,0" M1="81" M2="81" P1="11978,169" P2="11978,171"/><JD c="eec277,8,1,0" M1="82" M2="82" P1="24951,510" P2="24951,512"/><JD c="eec277,8,1,0" M1="83" M2="83" P1="21910,513" P2="21910,515"/><JD c="eec277,8,1,0" M1="84" M2="84" P1="11992,469" P2="11992,471"/><JD c="eec277,8,1,0" M1="85" M2="85" P1="13139,254" P2="13139,256"/><JD c="eec277,8,1,0" M1="86" M2="86" P1="13351,342" P2="13351,344"/><JD c="eec277,8,1,0" M1="87" M2="87" P1="15091,342" P2="15091,344"/><JD c="eec277,8,1,0" M1="88" M2="88" P1="15191,342" P2="15191,344"/><JD c="eec277,8,1,0" M1="89" M2="89" P1="15451,512" P2="15451,514"/><JD c="eec277,8,1,0" M1="90" M2="90" P1="24661,340" P2="24661,342"/><JD c="eec277,8,1,0" M1="91" M2="91" P1="15631,512" P2="15631,514"/><JD c="eec277,8,1,0" M1="92" M2="92" P1="5706,511" P2="5706,513"/><JD c="000000,2,1,0" M1="61" M2="61" P1="20953,340" P2="20960,342"/><JD c="000000,2,1,0" M1="62" M2="62" P1="1177,375" P2="1184,377"/><JD c="000000,2,1,0" M1="63" M2="63" P1="21407,338" P2="21414,340"/><JD c="000000,2,1,0" M1="64" M2="64" P1="1847,163" P2="1854,165"/><JD c="000000,2,1,0" M1="65" M2="65" P1="2637,163" P2="2644,165"/><JD c="000000,2,1,0" M1="66" M2="66" P1="22934,334" P2="22941,336"/><JD c="000000,2,1,0" M1="67" M2="67" P1="22845,335" P2="22852,337"/><JD c="000000,2,1,0" M1="68" M2="68" P1="2885,505" P2="2892,507"/><JD c="000000,2,1,0" M1="69" M2="69" P1="4623,248" P2="4630,250"/><JD c="000000,2,1,0" M1="70" M2="70" P1="23742,375" P2="23749,377"/><JD c="000000,2,1,0" M1="71" M2="71" P1="4901,506" P2="4908,508"/><JD c="000000,2,1,0" M1="72" M2="72" P1="24733,336" P2="24740,338"/><JD c="000000,2,1,0" M1="73" M2="73" P1="25862,337" P2="25869,339"/><JD c="000000,2,1,0" M1="74" M2="74" P1="26934,502" P2="26941,504"/><JD c="000000,2,1,0" M1="75" M2="75" P1="5408,506" P2="5415,508"/><JD c="000000,2,1,0" M1="76" M2="76" P1="21083,510" P2="21090,512"/><JD c="000000,2,1,0" M1="77" M2="77" P1="11105,164" P2="11112,166"/><JD c="000000,2,1,0" M1="78" M2="78" P1="11267,335" P2="11274,337"/><JD c="000000,2,1,0" M1="79" M2="79" P1="11383,335" P2="11390,337"/><JD c="000000,2,1,0" M1="80" M2="80" P1="11794,464" P2="11801,466"/><JD c="000000,2,1,0" M1="81" M2="81" P1="11965,164" P2="11972,166"/><JD c="000000,2,1,0" M1="82" M2="82" P1="24938,505" P2="24945,507"/><JD c="000000,2,1,0" M1="83" M2="83" P1="21897,508" P2="21904,510"/><JD c="000000,2,1,0" M1="84" M2="84" P1="11979,464" P2="11986,466"/><JD c="000000,2,1,0" M1="85" M2="85" P1="13126,249" P2="13133,251"/><JD c="000000,2,1,0" M1="86" M2="86" P1="13338,337" P2="13345,339"/><JD c="000000,2,1,0" M1="87" M2="87" P1="15078,337" P2="15085,339"/><JD c="000000,2,1,0" M1="88" M2="88" P1="15178,337" P2="15185,339"/><JD c="000000,2,1,0" M1="89" M2="89" P1="15438,507" P2="15445,509"/><JD c="000000,2,1,0" M1="90" M2="90" P1="24648,335" P2="24655,337"/><JD c="000000,2,1,0" M1="91" M2="91" P1="15618,507" P2="15625,509"/><JD c="000000,2,1,0" M1="92" M2="92" P1="5693,506" P2="5700,508"/><JD c="000000,2,1,0" M1="61" M2="61" P1="20968,340" P2="20961,342"/><JD c="000000,2,1,0" M1="62" M2="62" P1="1192,375" P2="1185,377"/><JD c="000000,2,1,0" M1="63" M2="63" P1="21422,338" P2="21415,340"/><JD c="000000,2,1,0" M1="64" M2="64" P1="1862,163" P2="1855,165"/><JD c="000000,2,1,0" M1="65" M2="65" P1="2652,163" P2="2645,165"/><JD c="000000,2,1,0" M1="66" M2="66" P1="22949,334" P2="22942,336"/><JD c="000000,2,1,0" M1="67" M2="67" P1="22860,335" P2="22853,337"/><JD c="000000,2,1,0" M1="68" M2="68" P1="2900,505" P2="2893,507"/><JD c="000000,2,1,0" M1="69" M2="69" P1="4638,248" P2="4631,250"/><JD c="000000,2,1,0" M1="70" M2="70" P1="23757,375" P2="23750,377"/><JD c="000000,2,1,0" M1="71" M2="71" P1="4916,506" P2="4909,508"/><JD c="000000,2,1,0" M1="72" M2="72" P1="24748,336" P2="24741,338"/><JD c="000000,2,1,0" M1="73" M2="73" P1="25877,337" P2="25870,339"/><JD c="000000,2,1,0" M1="74" M2="74" P1="26949,502" P2="26942,504"/><JD c="000000,2,1,0" M1="75" M2="75" P1="5423,506" P2="5416,508"/><JD c="000000,2,1,0" M1="76" M2="76" P1="21098,510" P2="21091,512"/><JD c="000000,2,1,0" M1="77" M2="77" P1="11120,164" P2="11113,166"/><JD c="000000,2,1,0" M1="78" M2="78" P1="11282,335" P2="11275,337"/><JD c="000000,2,1,0" M1="79" M2="79" P1="11398,335" P2="11391,337"/><JD c="000000,2,1,0" M1="80" M2="80" P1="11809,464" P2="11802,466"/><JD c="000000,2,1,0" M1="81" M2="81" P1="11980,164" P2="11973,166"/><JD c="000000,2,1,0" M1="82" M2="82" P1="24953,505" P2="24946,507"/><JD c="000000,2,1,0" M1="83" M2="83" P1="21912,508" P2="21905,510"/><JD c="000000,2,1,0" M1="84" M2="84" P1="11994,464" P2="11987,466"/><JD c="000000,2,1,0" M1="85" M2="85" P1="13141,249" P2="13134,251"/><JD c="000000,2,1,0" M1="86" M2="86" P1="13353,337" P2="13346,339"/><JD c="000000,2,1,0" M1="87" M2="87" P1="15093,337" P2="15086,339"/><JD c="000000,2,1,0" M1="88" M2="88" P1="15193,337" P2="15186,339"/><JD c="000000,2,1,0" M1="89" M2="89" P1="15453,507" P2="15446,509"/><JD c="000000,2,1,0" M1="90" M2="90" P1="24663,335" P2="24656,337"/><JD c="000000,2,1,0" M1="91" M2="91" P1="15633,507" P2="15626,509"/><JD c="000000,2,1,0" M1="92" M2="92" P1="5708,506" P2="5701,508"/><JD c="000000,3,1,0" M1="61" M2="61" P1="20956,342" P2="20956,345"/><JD c="000000,3,1,0" M1="62" M2="62" P1="1180,377" P2="1180,380"/><JD c="000000,3,1,0" M1="63" M2="63" P1="21410,340" P2="21410,343"/><JD c="000000,3,1,0" M1="64" M2="64" P1="1850,165" P2="1850,168"/><JD c="000000,3,1,0" M1="65" M2="65" P1="2640,165" P2="2640,168"/><JD c="000000,3,1,0" M1="66" M2="66" P1="22937,336" P2="22937,339"/><JD c="000000,3,1,0" M1="67" M2="67" P1="22848,337" P2="22848,340"/><JD c="000000,3,1,0" M1="68" M2="68" P1="2888,507" P2="2888,510"/><JD c="000000,3,1,0" M1="69" M2="69" P1="4626,250" P2="4626,253"/><JD c="000000,3,1,0" M1="70" M2="70" P1="23745,377" P2="23745,380"/><JD c="000000,3,1,0" M1="71" M2="71" P1="4904,508" P2="4904,511"/><JD c="000000,3,1,0" M1="72" M2="72" P1="24736,338" P2="24736,341"/><JD c="000000,3,1,0" M1="73" M2="73" P1="25865,339" P2="25865,342"/><JD c="000000,3,1,0" M1="74" M2="74" P1="26937,504" P2="26937,507"/><JD c="000000,3,1,0" M1="75" M2="75" P1="5411,508" P2="5411,511"/><JD c="000000,3,1,0" M1="76" M2="76" P1="21086,512" P2="21086,515"/><JD c="000000,3,1,0" M1="77" M2="77" P1="11108,166" P2="11108,169"/><JD c="000000,3,1,0" M1="78" M2="78" P1="11270,337" P2="11270,340"/><JD c="000000,3,1,0" M1="79" M2="79" P1="11386,337" P2="11386,340"/><JD c="000000,3,1,0" M1="80" M2="80" P1="11797,466" P2="11797,469"/><JD c="000000,3,1,0" M1="81" M2="81" P1="11968,166" P2="11968,169"/><JD c="000000,3,1,0" M1="82" M2="82" P1="24941,507" P2="24941,510"/><JD c="000000,3,1,0" M1="83" M2="83" P1="21900,510" P2="21900,513"/><JD c="000000,3,1,0" M1="84" M2="84" P1="11982,466" P2="11982,469"/><JD c="000000,3,1,0" M1="85" M2="85" P1="13129,251" P2="13129,254"/><JD c="000000,3,1,0" M1="86" M2="86" P1="13341,339" P2="13341,342"/><JD c="000000,3,1,0" M1="87" M2="87" P1="15081,339" P2="15081,342"/><JD c="000000,3,1,0" M1="88" M2="88" P1="15181,339" P2="15181,342"/><JD c="000000,3,1,0" M1="89" M2="89" P1="15441,509" P2="15441,512"/><JD c="000000,3,1,0" M1="90" M2="90" P1="24651,337" P2="24651,340"/><JD c="000000,3,1,0" M1="91" M2="91" P1="15621,509" P2="15621,512"/><JD c="000000,3,1,0" M1="92" M2="92" P1="5696,508" P2="5696,511"/><JD c="eec277,8,1,0" M1="54" M2="54" P1="2288.1,532.35" P2="2284.41,532.35"/><JD c="eec277,8,1,0" M1="55" M2="55" P1="25732.1,535.35" P2="25728.41,535.35"/><JD c="eec277,8,1,0" M1="56" M2="56" P1="23918.1,317.35" P2="23914.41,317.35"/><JD c="eec277,8,1,0" M1="57" M2="57" P1="13475.1,190.35" P2="13471.41,190.35"/><JD c="eec277,8,1,0" M1="58" M2="58" P1="24234.1,534.35" P2="24230.41,534.35"/><JD c="eec277,8,1,0" M1="59" M2="59" P1="14755.1,406.35" P2="14751.41,406.35"/><JD c="eec277,8,1,0" M1="60" M2="60" P1="15865.1,406.35" P2="15861.41,406.35"/><JD c="eec277,8,1,0" M1="132" M2="132" P1="21770.39,257.35" P2="21774.08,257.35"/><JD c="eec277,8,1,0" M1="133" M2="133" P1="3700.39,332.35" P2="3704.08,332.35"/><JD c="eec277,8,1,0" M1="134" M2="134" P1="25360.39,327.35" P2="25364.08,327.35"/><JD c="eec277,8,1,0" M1="135" M2="135" P1="26100.39,427.35" P2="26104.08,427.35"/><JD c="eec277,8,1,0" M1="136" M2="136" P1="12730.39,353.35" P2="12734.08,353.35"/><JD c="eec277,8,1,0" M1="137" M2="137" P1="14110.39,323.35" P2="14114.08,323.35"/><JD c="eec277,8,1,0" M1="54" M2="54" P1="2307.1,531.35" P2="2303.41,531.35"/><JD c="eec277,8,1,0" M1="55" M2="55" P1="25751.1,534.35" P2="25747.41,534.35"/><JD c="eec277,8,1,0" M1="56" M2="56" P1="23937.1,316.35" P2="23933.41,316.35"/><JD c="eec277,8,1,0" M1="57" M2="57" P1="13494.1,189.35" P2="13490.41,189.35"/><JD c="eec277,8,1,0" M1="58" M2="58" P1="24253.1,533.35" P2="24249.41,533.35"/><JD c="eec277,8,1,0" M1="59" M2="59" P1="14774.1,405.35" P2="14770.41,405.35"/><JD c="eec277,8,1,0" M1="60" M2="60" P1="15884.1,405.35" P2="15880.41,405.35"/><JD c="eec277,8,1,0" M1="132" M2="132" P1="21751.39,256.35" P2="21755.08,256.35"/><JD c="eec277,8,1,0" M1="133" M2="133" P1="3681.39,331.35" P2="3685.08,331.35"/><JD c="eec277,8,1,0" M1="134" M2="134" P1="25341.39,326.35" P2="25345.08,326.35"/><JD c="eec277,8,1,0" M1="135" M2="135" P1="26081.39,426.35" P2="26085.08,426.35"/><JD c="eec277,8,1,0" M1="136" M2="136" P1="12711.39,352.35" P2="12715.08,352.35"/><JD c="eec277,8,1,0" M1="137" M2="137" P1="14091.39,322.35" P2="14095.08,322.35"/><JD c="000000,3,1,0" M1="61" M2="61" P1="20966,342" P2="20966,345"/><JD c="000000,3,1,0" M1="62" M2="62" P1="1190,377" P2="1190,380"/><JD c="000000,3,1,0" M1="63" M2="63" P1="21420,340" P2="21420,343"/><JD c="000000,3,1,0" M1="64" M2="64" P1="1860,165" P2="1860,168"/><JD c="000000,3,1,0" M1="65" M2="65" P1="2650,165" P2="2650,168"/><JD c="000000,3,1,0" M1="66" M2="66" P1="22947,336" P2="22947,339"/><JD c="000000,3,1,0" M1="67" M2="67" P1="22858,337" P2="22858,340"/><JD c="000000,3,1,0" M1="68" M2="68" P1="2898,507" P2="2898,510"/><JD c="000000,3,1,0" M1="69" M2="69" P1="4636,250" P2="4636,253"/><JD c="000000,3,1,0" M1="70" M2="70" P1="23755,377" P2="23755,380"/><JD c="000000,3,1,0" M1="71" M2="71" P1="4914,508" P2="4914,511"/><JD c="000000,3,1,0" M1="72" M2="72" P1="24746,338" P2="24746,341"/><JD c="000000,3,1,0" M1="73" M2="73" P1="25875,339" P2="25875,342"/><JD c="000000,3,1,0" M1="74" M2="74" P1="26947,504" P2="26947,507"/><JD c="000000,3,1,0" M1="75" M2="75" P1="5421,508" P2="5421,511"/><JD c="000000,3,1,0" M1="76" M2="76" P1="21096,512" P2="21096,515"/><JD c="000000,3,1,0" M1="77" M2="77" P1="11118,166" P2="11118,169"/><JD c="000000,3,1,0" M1="78" M2="78" P1="11280,337" P2="11280,340"/><JD c="000000,3,1,0" M1="79" M2="79" P1="11396,337" P2="11396,340"/><JD c="000000,3,1,0" M1="80" M2="80" P1="11807,466" P2="11807,469"/><JD c="000000,3,1,0" M1="81" M2="81" P1="11978,166" P2="11978,169"/><JD c="000000,3,1,0" M1="82" M2="82" P1="24951,507" P2="24951,510"/><JD c="000000,3,1,0" M1="83" M2="83" P1="21910,510" P2="21910,513"/><JD c="000000,3,1,0" M1="84" M2="84" P1="11992,466" P2="11992,469"/><JD c="000000,3,1,0" M1="85" M2="85" P1="13139,251" P2="13139,254"/><JD c="000000,3,1,0" M1="86" M2="86" P1="13351,339" P2="13351,342"/><JD c="000000,3,1,0" M1="87" M2="87" P1="15091,339" P2="15091,342"/><JD c="000000,3,1,0" M1="88" M2="88" P1="15191,339" P2="15191,342"/><JD c="000000,3,1,0" M1="89" M2="89" P1="15451,509" P2="15451,512"/><JD c="000000,3,1,0" M1="90" M2="90" P1="24661,337" P2="24661,340"/><JD c="000000,3,1,0" M1="91" M2="91" P1="15631,509" P2="15631,512"/><JD c="000000,3,1,0" M1="92" M2="92" P1="5706,508" P2="5706,511"/><JD c="eec277,11,1,0" M1="54" M2="54" P1="2308.29,497.14" P2="2307.95,511.28"/><JD c="eec277,11,1,0" M1="55" M2="55" P1="25752.29,500.14" P2="25751.95,514.28"/><JD c="eec277,11,1,0" M1="56" M2="56" P1="23938.29,282.14" P2="23937.95,296.28"/><JD c="eec277,11,1,0" M1="57" M2="57" P1="13495.29,155.14" P2="13494.95,169.28"/><JD c="eec277,11,1,0" M1="58" M2="58" P1="24254.29,499.14" P2="24253.95,513.28"/><JD c="eec277,11,1,0" M1="59" M2="59" P1="14775.29,371.14" P2="14774.95,385.28"/><JD c="eec277,11,1,0" M1="60" M2="60" P1="15885.29,371.14" P2="15884.95,385.28"/><JD c="eec277,11,1,0" M1="132" M2="132" P1="21750.2,222.14" P2="21750.54,236.28"/><JD c="eec277,11,1,0" M1="133" M2="133" P1="3680.2,297.14" P2="3680.54,311.28"/><JD c="eec277,11,1,0" M1="134" M2="134" P1="25340.2,292.14" P2="25340.54,306.28"/><JD c="eec277,11,1,0" M1="135" M2="135" P1="26080.2,392.14" P2="26080.54,406.28"/><JD c="eec277,11,1,0" M1="136" M2="136" P1="12710.2,318.14" P2="12710.54,332.28"/><JD c="eec277,11,1,0" M1="137" M2="137" P1="14090.2,288.14" P2="14090.54,302.28"/><JD c="FFFFFF,29,1,0" M1="54" M2="54" P1="2294.94,517.09" P2="2294.94,518.09"/><JD c="FFFFFF,29,1,0" M1="55" M2="55" P1="25738.94,520.09" P2="25738.94,521.09"/><JD c="FFFFFF,29,1,0" M1="56" M2="56" P1="23924.94,302.09" P2="23924.94,303.09"/><JD c="FFFFFF,29,1,0" M1="57" M2="57" P1="13481.94,175.09" P2="13481.94,176.09"/><JD c="FFFFFF,29,1,0" M1="58" M2="58" P1="24240.94,519.09" P2="24240.94,520.09"/><JD c="FFFFFF,29,1,0" M1="59" M2="59" P1="14761.94,391.09" P2="14761.94,392.09"/><JD c="FFFFFF,29,1,0" M1="60" M2="60" P1="15871.94,391.09" P2="15871.94,392.09"/><JD c="FFFFFF,29,1,0" M1="132" M2="132" P1="21763.55,242.09" P2="21763.55,243.09"/><JD c="FFFFFF,29,1,0" M1="133" M2="133" P1="3693.55,317.09" P2="3693.55,318.09"/><JD c="FFFFFF,29,1,0" M1="134" M2="134" P1="25353.55,312.09" P2="25353.55,313.09"/><JD c="FFFFFF,29,1,0" M1="135" M2="135" P1="26093.55,412.09" P2="26093.55,413.09"/><JD c="FFFFFF,29,1,0" M1="136" M2="136" P1="12723.55,338.09" P2="12723.55,339.09"/><JD c="FFFFFF,29,1,0" M1="137" M2="137" P1="14103.55,308.09" P2="14103.55,309.09"/><JD c="0a8118,29,1,0" M1="54" M2="54" P1="2292.83,514.98" P2="2292.83,515.98"/><JD c="0a8118,29,1,0" M1="55" M2="55" P1="25736.83,517.98" P2="25736.83,518.98"/><JD c="0a8118,29,1,0" M1="56" M2="56" P1="23922.83,299.98" P2="23922.83,300.98"/><JD c="0a8118,29,1,0" M1="57" M2="57" P1="13479.83,172.98" P2="13479.83,173.98"/><JD c="0a8118,29,1,0" M1="58" M2="58" P1="24238.83,516.98" P2="24238.83,517.98"/><JD c="0a8118,29,1,0" M1="59" M2="59" P1="14759.83,388.98" P2="14759.83,389.98"/><JD c="0a8118,29,1,0" M1="60" M2="60" P1="15869.83,388.98" P2="15869.83,389.98"/><JD c="0a8118,29,1,0" M1="132" M2="132" P1="21765.66,239.98" P2="21765.66,240.98"/><JD c="0a8118,29,1,0" M1="133" M2="133" P1="3695.66,314.98" P2="3695.66,315.98"/><JD c="0a8118,29,1,0" M1="134" M2="134" P1="25355.66,309.98" P2="25355.66,310.98"/><JD c="0a8118,29,1,0" M1="135" M2="135" P1="26095.66,409.98" P2="26095.66,410.98"/><JD c="0a8118,29,1,0" M1="136" M2="136" P1="12725.66,335.98" P2="12725.66,336.98"/><JD c="0a8118,29,1,0" M1="137" M2="137" P1="14105.66,305.98" P2="14105.66,306.98"/><JD c="FFFFFF,6,1,0" M1="54" M2="54" P1="2309.33,495.04" P2="2309.33,500.56"/><JD c="FFFFFF,6,1,0" M1="55" M2="55" P1="25753.33,498.04" P2="25753.33,503.56"/><JD c="FFFFFF,6,1,0" M1="56" M2="56" P1="23939.33,280.04" P2="23939.33,285.56"/><JD c="FFFFFF,6,1,0" M1="57" M2="57" P1="13496.33,153.04" P2="13496.33,158.56"/><JD c="FFFFFF,6,1,0" M1="58" M2="58" P1="24255.33,497.04" P2="24255.33,502.56"/><JD c="FFFFFF,6,1,0" M1="59" M2="59" P1="14776.33,369.04" P2="14776.33,374.56"/><JD c="FFFFFF,6,1,0" M1="60" M2="60" P1="15886.33,369.04" P2="15886.33,374.56"/><JD c="FFFFFF,6,1,0" M1="132" M2="132" P1="21749.16,220.04" P2="21749.16,225.56"/><JD c="FFFFFF,6,1,0" M1="133" M2="133" P1="3679.16,295.04" P2="3679.16,300.56"/><JD c="FFFFFF,6,1,0" M1="134" M2="134" P1="25339.16,290.04" P2="25339.16,295.56"/><JD c="FFFFFF,6,1,0" M1="135" M2="135" P1="26079.16,390.04" P2="26079.16,395.56"/><JD c="FFFFFF,6,1,0" M1="136" M2="136" P1="12709.16,316.04" P2="12709.16,321.56"/><JD c="FFFFFF,6,1,0" M1="137" M2="137" P1="14089.16,286.04" P2="14089.16,291.56"/><JD c="0a8118,2,1,0" M1="54" M2="54" P1="2310.71,495.07" P2="2310.71,498"/><JD c="0a8118,2,1,0" M1="55" M2="55" P1="25754.71,498.07" P2="25754.71,501"/><JD c="0a8118,2,1,0" M1="56" M2="56" P1="23940.71,280.07" P2="23940.71,283"/><JD c="0a8118,2,1,0" M1="57" M2="57" P1="13497.71,153.07" P2="13497.71,156"/><JD c="0a8118,2,1,0" M1="58" M2="58" P1="24256.71,497.07" P2="24256.71,500"/><JD c="0a8118,2,1,0" M1="59" M2="59" P1="14777.71,369.07" P2="14777.71,372"/><JD c="0a8118,2,1,0" M1="60" M2="60" P1="15887.71,369.07" P2="15887.71,372"/><JD c="0a8118,2,1,0" M1="132" M2="132" P1="21747.78,220.07" P2="21747.78,223"/><JD c="0a8118,2,1,0" M1="133" M2="133" P1="3677.78,295.07" P2="3677.78,298"/><JD c="0a8118,2,1,0" M1="134" M2="134" P1="25337.78,290.07" P2="25337.78,293"/><JD c="0a8118,2,1,0" M1="135" M2="135" P1="26077.78,390.07" P2="26077.78,393"/><JD c="0a8118,2,1,0" M1="136" M2="136" P1="12707.78,316.07" P2="12707.78,319"/><JD c="0a8118,2,1,0" M1="137" M2="137" P1="14087.78,286.07" P2="14087.78,289"/><JD c="0a8118,2,1,0" M1="54" M2="54" P1="2311.74,505.07" P2="2311.74,506.07"/><JD c="0a8118,2,1,0" M1="55" M2="55" P1="25755.74,508.07" P2="25755.74,509.07"/><JD c="0a8118,2,1,0" M1="56" M2="56" P1="23941.74,290.07" P2="23941.74,291.07"/><JD c="0a8118,2,1,0" M1="57" M2="57" P1="13498.74,163.07" P2="13498.74,164.07"/><JD c="0a8118,2,1,0" M1="58" M2="58" P1="24257.74,507.07" P2="24257.74,508.07"/><JD c="0a8118,2,1,0" M1="59" M2="59" P1="14778.74,379.07" P2="14778.74,380.07"/><JD c="0a8118,2,1,0" M1="60" M2="60" P1="15888.74,379.07" P2="15888.74,380.07"/><JD c="0a8118,2,1,0" M1="132" M2="132" P1="21746.75,230.07" P2="21746.75,231.07"/><JD c="0a8118,2,1,0" M1="133" M2="133" P1="3676.75,305.07" P2="3676.75,306.07"/><JD c="0a8118,2,1,0" M1="134" M2="134" P1="25336.75,300.07" P2="25336.75,301.07"/><JD c="0a8118,2,1,0" M1="135" M2="135" P1="26076.75,400.07" P2="26076.75,401.07"/><JD c="0a8118,2,1,0" M1="136" M2="136" P1="12706.75,326.07" P2="12706.75,327.07"/><JD c="0a8118,2,1,0" M1="137" M2="137" P1="14086.75,296.07" P2="14086.75,297.07"/><JD c="5c94fc,3,1,0" M1="54" M2="54" P1="2309.33,507.14" P2="2313.12,514.04"/><JD c="000000,3,1,0" M1="55" M2="55" P1="25753.33,510.14" P2="25757.12,517.04"/><JD c="000000,3,1,0" M1="56" M2="56" P1="23939.33,292.14" P2="23943.12,299.04"/><JD c="5c94fc,3,1,0" M1="57" M2="57" P1="13496.33,165.14" P2="13500.12,172.04"/><JD c="000000,3,1,0" M1="58" M2="58" P1="24255.33,509.14" P2="24259.12,516.04"/><JD c="5c94fc,3,1,0" M1="59" M2="59" P1="14776.33,381.14" P2="14780.12,388.04"/><JD c="5c94fc,3,1,0" M1="60" M2="60" P1="15886.33,381.14" P2="15890.12,388.04"/><JD c="000000,3,1,0" M1="132" M2="132" P1="21749.16,232.14" P2="21745.37,239.04"/><JD c="5c94fc,3,1,0" M1="133" M2="133" P1="3679.16,307.14" P2="3675.37,314.04"/><JD c="000000,3,1,0" M1="134" M2="134" P1="25339.16,302.14" P2="25335.37,309.04"/><JD c="000000,3,1,0" M1="135" M2="135" P1="26079.16,402.14" P2="26075.37,409.04"/><JD c="5c94fc,3,1,0" M1="136" M2="136" P1="12709.16,328.14" P2="12705.37,335.04"/><JD c="5c94fc,3,1,0" M1="137" M2="137" P1="14089.16,298.14" P2="14085.37,305.04"/><JD c="eec277,1,1,0" M1="54" M2="54" P1="2286.66,502.79" P2="2304.33,520.7"/><JD c="eec277,1,1,0" M1="55" M2="55" P1="25730.66,505.79" P2="25748.33,523.7"/><JD c="eec277,1,1,0" M1="56" M2="56" P1="23916.66,287.79" P2="23934.33,305.7"/><JD c="eec277,1,1,0" M1="57" M2="57" P1="13473.66,160.79" P2="13491.33,178.7"/><JD c="eec277,1,1,0" M1="58" M2="58" P1="24232.66,504.79" P2="24250.33,522.7"/><JD c="eec277,1,1,0" M1="59" M2="59" P1="14753.66,376.79" P2="14771.33,394.7"/><JD c="eec277,1,1,0" M1="60" M2="60" P1="15863.66,376.79" P2="15881.33,394.7"/><JD c="eec277,1,1,0" M1="132" M2="132" P1="21771.83,227.79" P2="21754.16,245.7"/><JD c="eec277,1,1,0" M1="133" M2="133" P1="3701.83,302.79" P2="3684.16,320.7"/><JD c="eec277,1,1,0" M1="134" M2="134" P1="25361.83,297.79" P2="25344.16,315.7"/><JD c="eec277,1,1,0" M1="135" M2="135" P1="26101.83,397.79" P2="26084.16,415.7"/><JD c="eec277,1,1,0" M1="136" M2="136" P1="12731.83,323.79" P2="12714.16,341.7"/><JD c="eec277,1,1,0" M1="137" M2="137" P1="14111.83,293.79" P2="14094.16,311.7"/><JD c="eec277,1,1,0" M1="54" M2="54" P1="2280.38,509.07" P2="2299.68,527.68"/><JD c="eec277,1,1,0" M1="55" M2="55" P1="25724.38,512.07" P2="25743.68,530.68"/><JD c="eec277,1,1,0" M1="56" M2="56" P1="23910.38,294.07" P2="23929.68,312.68"/><JD c="eec277,1,1,0" M1="57" M2="57" P1="13467.38,167.07" P2="13486.68,185.68"/><JD c="eec277,1,1,0" M1="58" M2="58" P1="24226.38,511.07" P2="24245.68,529.68"/><JD c="eec277,1,1,0" M1="59" M2="59" P1="14747.38,383.07" P2="14766.68,401.68"/><JD c="eec277,1,1,0" M1="60" M2="60" P1="15857.38,383.07" P2="15876.68,401.68"/><JD c="eec277,1,1,0" M1="132" M2="132" P1="21778.11,234.07" P2="21758.81,252.68"/><JD c="eec277,1,1,0" M1="133" M2="133" P1="3708.11,309.07" P2="3688.81,327.68"/><JD c="eec277,1,1,0" M1="134" M2="134" P1="25368.11,304.07" P2="25348.81,322.68"/><JD c="eec277,1,1,0" M1="135" M2="135" P1="26108.11,404.07" P2="26088.81,422.68"/><JD c="eec277,1,1,0" M1="136" M2="136" P1="12738.11,330.07" P2="12718.81,348.68"/><JD c="eec277,1,1,0" M1="137" M2="137" P1="14118.11,300.07" P2="14098.81,318.68"/><JD c="eec277,1,1,0" M1="54" M2="54" P1="2305.73,510.47" P2="2288.05,527.68"/><JD c="eec277,1,1,0" M1="55" M2="55" P1="25749.73,513.47" P2="25732.05,530.68"/><JD c="eec277,1,1,0" M1="56" M2="56" P1="23935.73,295.47" P2="23918.05,312.68"/><JD c="eec277,1,1,0" M1="57" M2="57" P1="13492.73,168.47" P2="13475.05,185.68"/><JD c="eec277,1,1,0" M1="58" M2="58" P1="24251.73,512.47" P2="24234.05,529.68"/><JD c="eec277,1,1,0" M1="59" M2="59" P1="14772.73,384.47" P2="14755.05,401.68"/><JD c="eec277,1,1,0" M1="60" M2="60" P1="15882.73,384.47" P2="15865.05,401.68"/><JD c="eec277,1,1,0" M1="132" M2="132" P1="21752.76,235.47" P2="21770.44,252.68"/><JD c="eec277,1,1,0" M1="133" M2="133" P1="3682.76,310.47" P2="3700.44,327.68"/><JD c="eec277,1,1,0" M1="134" M2="134" P1="25342.76,305.47" P2="25360.44,322.68"/><JD c="eec277,1,1,0" M1="135" M2="135" P1="26082.76,405.47" P2="26100.44,422.68"/><JD c="eec277,1,1,0" M1="136" M2="136" P1="12712.76,331.47" P2="12730.44,348.68"/><JD c="eec277,1,1,0" M1="137" M2="137" P1="14092.76,301.47" P2="14110.44,318.68"/><JD c="eec277,1,1,0" M1="54" M2="54" P1="2297.12,502.33" P2="2280.38,520.7"/><JD c="eec277,1,1,0" M1="55" M2="55" P1="25741.12,505.33" P2="25724.38,523.7"/><JD c="eec277,1,1,0" M1="56" M2="56" P1="23927.12,287.33" P2="23910.38,305.7"/><JD c="eec277,1,1,0" M1="57" M2="57" P1="13484.12,160.33" P2="13467.38,178.7"/><JD c="eec277,1,1,0" M1="58" M2="58" P1="24243.12,504.33" P2="24226.38,522.7"/><JD c="eec277,1,1,0" M1="59" M2="59" P1="14764.12,376.33" P2="14747.38,394.7"/><JD c="eec277,1,1,0" M1="60" M2="60" P1="15874.12,376.33" P2="15857.38,394.7"/><JD c="eec277,1,1,0" M1="132" M2="132" P1="21761.37,227.33" P2="21778.11,245.7"/><JD c="eec277,1,1,0" M1="133" M2="133" P1="3691.37,302.33" P2="3708.11,320.7"/><JD c="eec277,1,1,0" M1="134" M2="134" P1="25351.37,297.33" P2="25368.11,315.7"/><JD c="eec277,1,1,0" M1="135" M2="135" P1="26091.37,397.33" P2="26108.11,415.7"/><JD c="eec277,1,1,0" M1="136" M2="136" P1="12721.37,323.33" P2="12738.11,341.7"/><JD c="eec277,1,1,0" M1="137" M2="137" P1="14101.37,293.33" P2="14118.11,311.7"/><JD c="FFFFFF,10,1,0" M1="132" M2="132" P1="21778.3,217.44" P2="21769.24,229.53"/><JD c="FFFFFF,10,1,0" M1="133" M2="133" P1="3708.3,292.44" P2="3699.24,304.53"/><JD c="FFFFFF,10,1,0" M1="134" M2="134" P1="25368.3,287.44" P2="25359.24,299.53"/><JD c="FFFFFF,10,1,0" M1="135" M2="135" P1="26108.3,387.44" P2="26099.24,399.53"/><JD c="FFFFFF,10,1,0" M1="136" M2="136" P1="12738.3,313.44" P2="12729.24,325.53"/><JD c="FFFFFF,10,1,0" M1="137" M2="137" P1="14118.3,283.44" P2="14109.24,295.53"/><JD c="eec277,1,1,0" M1="132" M2="132" P1="21775.12,217.86" P2="21767.43,227.6"/><JD c="eec277,1,1,0" M1="133" M2="133" P1="3705.12,292.86" P2="3697.43,302.6"/><JD c="eec277,1,1,0" M1="134" M2="134" P1="25365.12,287.86" P2="25357.43,297.6"/><JD c="eec277,1,1,0" M1="135" M2="135" P1="26105.12,387.86" P2="26097.43,397.6"/><JD c="eec277,1,1,0" M1="136" M2="136" P1="12735.12,313.86" P2="12727.43,323.6"/><JD c="eec277,1,1,0" M1="137" M2="137" P1="14115.12,283.86" P2="14107.43,293.6"/><JD c="000000,4,1,0" M1="132" M2="132" P1="21784.12,220.75" P2="21776.66,220.45"/><JD c="5c94fc,4,1,0" M1="133" M2="133" P1="3714.12,295.75" P2="3706.66,295.45"/><JD c="000000,4,1,0" M1="134" M2="134" P1="25374.12,290.75" P2="25366.66,290.45"/><JD c="000000,4,1,0" M1="135" M2="135" P1="26114.12,390.75" P2="26106.66,390.45"/><JD c="5c94fc,4,1,0" M1="136" M2="136" P1="12744.12,316.75" P2="12736.66,316.45"/><JD c="5c94fc,4,1,0" M1="137" M2="137" P1="14124.12,286.75" P2="14116.66,286.45"/><JD c="000000,3,1,0" M1="132" M2="132" P1="21780.25,226.06" P2="21773.58,225.55"/><JD c="5c94fc,3,1,0" M1="133" M2="133" P1="3710.25,301.06" P2="3703.58,300.55"/><JD c="000000,3,1,0" M1="134" M2="134" P1="25370.25,296.06" P2="25363.58,295.55"/><JD c="000000,3,1,0" M1="135" M2="135" P1="26110.25,396.06" P2="26103.58,395.55"/><JD c="5c94fc,3,1,0" M1="136" M2="136" P1="12740.25,322.06" P2="12733.58,321.55"/><JD c="5c94fc,3,1,0" M1="137" M2="137" P1="14120.25,292.06" P2="14113.58,291.55"/><JR M1="93" M2="54"/><JR M1="105" M2="66"/><JR M1="106" M2="67"/><JR M1="107" M2="68"/><JR M1="94" M2="55"/><JR M1="108" M2="69"/><JR M1="109" M2="70"/><JR M1="110" M2="71"/><JR M1="95" M2="56"/><JR M1="95" M2="56"/><JR M1="111" M2="72"/><JR M1="114" M2="75"/><JR M1="114" M2="75"/><JR M1="131" M2="92"/><JP M1="61" AXIS="-1,0"/><JP M1="62" AXIS="-1,0"/><JD M1="61" M2="1"/><JD M1="62" M2="1"/><JR M1="100" M2="61"/><JR M1="101" M2="62"/><JR M1="102" M2="63"/><JR M1="103" M2="64"/><JP M1="63" AXIS="-1,0"/><JP M1="64" AXIS="-1,0"/><JR M1="104" M2="65"/><JP M1="65" AXIS="-1,0"/><JD M1="1" M2="63"/><JD M1="1" M2="103"/><JD c="d62700,11,1,0" M1="144" M2="144" P1="2164,229" P2="2216,229"/><JD c="d62700,11,1,0" M1="145" M2="145" P1="1464,204" P2="1516,204"/><JD c="d62700,11,1,0" M1="145" M2="145" P1="22304,104" P2="22356,104"/><JD c="d62700,11,1,0" M1="145" M2="145" P1="23544,144" P2="23596,144"/><JD c="d62700,11,1,0" M1="145" M2="145" P1="23183,444" P2="23235,444"/><JD c="d62700,11,1,0" M1="145" M2="145" P1="23423,445" P2="23475,445"/><JD c="d62700,11,1,0" M1="145" M2="145" P1="24664,484" P2="24716,484"/><JD c="d62700,11,1,0" M1="151" M2="151" P1="22044,105" P2="22096,105"/><JD c="d62700,11,1,0" M1="152" M2="152" P1="3304,529" P2="3356,529"/><JD c="d62700,11,1,0" M1="153" M2="153" P1="4074,279" P2="4126,279"/><JD c="d62700,11,1,0" M1="154" M2="154" P1="3674,349" P2="3726,349"/><JD c="d62700,11,1,0" M1="155" M2="155" P1="5274,299" P2="5326,299"/><JD c="d62700,11,1,0" M1="156" M2="156" P1="21534,150" P2="21586,150"/><JD c="d62700,11,1,0" M1="157" M2="157" P1="22404,470" P2="22456,470"/><JD c="d62700,11,1,0" M1="158" M2="158" P1="23984,140" P2="24036,140"/><JD c="d62700,11,1,0" M1="159" M2="159" P1="24954,250" P2="25006,250"/><JD c="d62700,11,1,0" M1="160" M2="160" P1="26114,390" P2="26166,390"/><JD c="d62700,11,1,0" M1="161" M2="161" P1="23164,240" P2="23216,240"/><JD c="d62700,11,1,0" M1="162" M2="162" P1="12674,480" P2="12726,480"/><JD c="d62700,11,1,0" M1="163" M2="163" P1="13814,200" P2="13866,200"/><JD c="d62700,11,1,0" M1="164" M2="164" P1="14054,500" P2="14106,500"/><JD c="d62700,11,1,0" M1="165" M2="165" P1="14694,200" P2="14746,200"/><JD c="d62700,11,1,0" M1="166" M2="166" P1="2354,229" P2="2406,229"/><JD c="d62700,11,1,0" M1="167" M2="167" P1="3494,529" P2="3546,529"/><JD c="d62700,11,1,0" M1="168" M2="168" P1="4264,279" P2="4316,279"/><JD c="d62700,11,1,0" M1="169" M2="169" P1="3864,349" P2="3916,349"/><JD c="d62700,11,1,0" M1="170" M2="170" P1="5464,299" P2="5516,299"/><JD c="d62700,11,1,0" M1="171" M2="171" P1="21724,150" P2="21776,150"/><JD c="d62700,11,1,0" M1="172" M2="172" P1="22594,470" P2="22646,470"/><JD c="d62700,11,1,0" M1="173" M2="173" P1="24174,140" P2="24226,140"/><JD c="d62700,11,1,0" M1="174" M2="174" P1="25144,250" P2="25196,250"/><JD c="d62700,11,1,0" M1="175" M2="175" P1="26304,390" P2="26356,390"/><JD c="d62700,11,1,0" M1="176" M2="176" P1="23354,240" P2="23406,240"/><JD c="d62700,11,1,0" M1="177" M2="177" P1="12864,480" P2="12916,480"/><JD c="d62700,11,1,0" M1="178" M2="178" P1="14004,200" P2="14056,200"/><JD c="d62700,11,1,0" M1="179" M2="179" P1="14234,200" P2="14286,200"/><JD c="d62700,11,1,0" M1="180" M2="180" P1="11373,173" P2="11425,173"/><JD c="d62700,11,1,0" M1="181" M2="181" P1="21213,473" P2="21265,473"/><JD c="d62700,11,1,0" M1="182" M2="182" P1="21043,243" P2="21095,243"/><JD c="d62700,11,1,0" M1="183" M2="183" P1="21273,182" P2="21325,182"/><JD c="d62700,11,1,0" M1="184" M2="184" P1="22543,263" P2="22595,263"/><JD c="d62700,11,1,0" M1="185" M2="185" P1="25363,213" P2="25415,213"/><JD c="d62700,11,1,0" M1="186" M2="186" P1="26523,363" P2="26575,363"/><JD c="d62700,11,1,0" M1="187" M2="187" P1="11013,473" P2="11065,473"/><JD c="d62700,11,1,0" M1="188" M2="188" P1="4573,472" P2="4625,472"/><JD c="d62700,11,1,0" M1="189" M2="189" P1="3763,552" P2="3815,552"/><JD c="d62700,11,1,0" M1="190" M2="190" P1="1973,542" P2="2025,542"/><JD c="d62700,11,1,0" M1="191" M2="191" P1="3973,522" P2="4025,522"/><JD c="d62700,11,1,0" M1="192" M2="192" P1="6403,222" P2="6455,222"/><JD c="d62700,11,1,0" M1="193" M2="193" P1="14484,200" P2="14536,200"/><JD c="d62700,11,1,0" M1="194" M2="194" P1="14244,500" P2="14296,500"/><JD c="d62700,11,1,0" M1="195" M2="195" P1="14884,200" P2="14936,200"/><JD M1="1" M2="65"/><JD c="fd993c,8,1,0" M1="144" M2="144" P1="2164,229" P2="2216,229"/><JD c="fd993c,8,1,0" M1="145" M2="145" P1="1464,204" P2="1516,204"/><JD c="fd993c,8,1,0" M1="145" M2="145" P1="22304,104" P2="22356,104"/><JD c="fd993c,8,1,0" M1="145" M2="145" P1="23544,144" P2="23596,144"/><JD c="fd993c,8,1,0" M1="145" M2="145" P1="23183,444" P2="23235,444"/><JD c="fd993c,8,1,0" M1="145" M2="145" P1="23423,445" P2="23475,445"/><JD c="fd993c,8,1,0" M1="145" M2="145" P1="24664,484" P2="24716,484"/><JD c="fd993c,8,1,0" M1="151" M2="151" P1="22044,105" P2="22096,105"/><JD c="fd993c,8,1,0" M1="152" M2="152" P1="3304,529" P2="3356,529"/><JD c="fd993c,8,1,0" M1="153" M2="153" P1="4074,279" P2="4126,279"/><JD c="fd993c,8,1,0" M1="154" M2="154" P1="3674,349" P2="3726,349"/><JD c="fd993c,8,1,0" M1="155" M2="155" P1="5274,299" P2="5326,299"/><JD c="fd993c,8,1,0" M1="156" M2="156" P1="21534,150" P2="21586,150"/><JD c="fd993c,8,1,0" M1="157" M2="157" P1="22404,470" P2="22456,470"/><JD c="fd993c,8,1,0" M1="158" M2="158" P1="23984,140" P2="24036,140"/><JD c="fd993c,8,1,0" M1="159" M2="159" P1="24954,250" P2="25006,250"/><JD c="fd993c,8,1,0" M1="160" M2="160" P1="26114,390" P2="26166,390"/><JD c="fd993c,8,1,0" M1="161" M2="161" P1="23164,240" P2="23216,240"/><JD c="fd993c,8,1,0" M1="162" M2="162" P1="12674,480" P2="12726,480"/><JD c="fd993c,8,1,0" M1="163" M2="163" P1="13814,200" P2="13866,200"/><JD c="fd993c,8,1,0" M1="164" M2="164" P1="14054,500" P2="14106,500"/><JD c="fd993c,8,1,0" M1="165" M2="165" P1="14694,200" P2="14746,200"/><JD c="fd993c,8,1,0" M1="166" M2="166" P1="2354,229" P2="2406,229"/><JD c="fd993c,8,1,0" M1="167" M2="167" P1="3494,529" P2="3546,529"/><JD c="fd993c,8,1,0" M1="168" M2="168" P1="4264,279" P2="4316,279"/><JD c="fd993c,8,1,0" M1="169" M2="169" P1="3864,349" P2="3916,349"/><JD c="fd993c,8,1,0" M1="170" M2="170" P1="5464,299" P2="5516,299"/><JD c="fd993c,8,1,0" M1="171" M2="171" P1="21724,150" P2="21776,150"/><JD c="fd993c,8,1,0" M1="172" M2="172" P1="22594,470" P2="22646,470"/><JD c="fd993c,8,1,0" M1="173" M2="173" P1="24174,140" P2="24226,140"/><JD c="fd993c,8,1,0" M1="174" M2="174" P1="25144,250" P2="25196,250"/><JD c="fd993c,8,1,0" M1="175" M2="175" P1="26304,390" P2="26356,390"/><JD c="fd993c,8,1,0" M1="176" M2="176" P1="23354,240" P2="23406,240"/><JD c="fd993c,8,1,0" M1="177" M2="177" P1="12864,480" P2="12916,480"/><JD c="fd993c,8,1,0" M1="178" M2="178" P1="14004,200" P2="14056,200"/><JD c="fd993c,8,1,0" M1="179" M2="179" P1="14234,200" P2="14286,200"/><JD c="fd993c,8,1,0" M1="180" M2="180" P1="11373,173" P2="11425,173"/><JD c="fd993c,8,1,0" M1="181" M2="181" P1="21213,473" P2="21265,473"/><JD c="fd993c,8,1,0" M1="182" M2="182" P1="21043,243" P2="21095,243"/><JD c="fd993c,8,1,0" M1="183" M2="183" P1="21273,182" P2="21325,182"/><JD c="fd993c,8,1,0" M1="184" M2="184" P1="22543,263" P2="22595,263"/><JD c="fd993c,8,1,0" M1="185" M2="185" P1="25363,213" P2="25415,213"/><JD c="fd993c,8,1,0" M1="186" M2="186" P1="26523,363" P2="26575,363"/><JD c="fd993c,8,1,0" M1="187" M2="187" P1="11013,473" P2="11065,473"/><JD c="fd993c,8,1,0" M1="188" M2="188" P1="4573,472" P2="4625,472"/><JD c="fd993c,8,1,0" M1="189" M2="189" P1="3763,552" P2="3815,552"/><JD c="fd993c,8,1,0" M1="190" M2="190" P1="1973,542" P2="2025,542"/><JD c="fd993c,8,1,0" M1="191" M2="191" P1="3973,522" P2="4025,522"/><JD c="fd993c,8,1,0" M1="192" M2="192" P1="6403,222" P2="6455,222"/><JD c="fd993c,8,1,0" M1="193" M2="193" P1="14484,200" P2="14536,200"/><JD c="fd993c,8,1,0" M1="194" M2="194" P1="14244,500" P2="14296,500"/><JD c="fd993c,8,1,0" M1="195" M2="195" P1="14884,200" P2="14936,200"/><JD c="5c94fc,6,1,0" M1="144" M2="144" P1="2167.11,229.1" P2="2167.11,230.1"/><JD c="5c94fc,6,1,0" M1="145" M2="145" P1="1467.11,204.1" P2="1467.11,205.1"/><JD c="000000,6,1,0" M1="145" M2="145" P1="22307.11,104.1" P2="22307.11,105.1"/><JD c="000000,6,1,0" M1="145" M2="145" P1="23547.11,144.1" P2="23547.11,145.1"/><JD c="000000,6,1,0" M1="145" M2="145" P1="23186.11,444.1" P2="23186.11,445.1"/><JD c="000000,6,1,0" M1="145" M2="145" P1="23426.11,445.1" P2="23426.11,446.1"/><JD c="000000,6,1,0" M1="145" M2="145" P1="24667.11,484.1" P2="24667.11,485.1"/><JD c="000000,6,1,0" M1="151" M2="151" P1="22047.11,105.1" P2="22047.11,106.1"/><JD c="c84c0c,6,1,0" M1="152" M2="152" P1="3307.11,529.1" P2="3307.11,530.1"/><JD c="5c94fc,6,1,0" M1="153" M2="153" P1="4077.11,279.1" P2="4077.11,280.1"/><JD c="5c94fc,6,1,0" M1="154" M2="154" P1="3677.11,349.1" P2="3677.11,350.1"/><JD c="5c94fc,6,1,0" M1="155" M2="155" P1="5277.11,299.1" P2="5277.11,300.1"/><JD c="000000,6,1,0" M1="156" M2="156" P1="21537.11,150.1" P2="21537.11,151.1"/><JD c="000000,6,1,0" M1="157" M2="157" P1="22407.11,470.1" P2="22407.11,471.1"/><JD c="000000,6,1,0" M1="158" M2="158" P1="23987.11,140.1" P2="23987.11,141.1"/><JD c="000000,6,1,0" M1="159" M2="159" P1="24957.11,250.1" P2="24957.11,251.1"/><JD c="000000,6,1,0" M1="160" M2="160" P1="26117.11,390.1" P2="26117.11,391.1"/><JD c="000000,6,1,0" M1="161" M2="161" P1="23167.11,240.1" P2="23167.11,241.1"/><JD c="5c94fc,6,1,0" M1="162" M2="162" P1="12677.11,480.1" P2="12677.11,481.1"/><JD c="5c94fc,6,1,0" M1="163" M2="163" P1="13817.11,200.1" P2="13817.11,201.1"/><JD c="5c94fc,6,1,0" M1="164" M2="164" P1="14057.11,500.1" P2="14057.11,501.1"/><JD c="5c94fc,6,1,0" M1="165" M2="165" P1="14697.11,200.1" P2="14697.11,201.1"/><JD c="5c94fc,6,1,0" M1="166" M2="166" P1="2357.11,229.1" P2="2357.11,230.1"/><JD c="5c94fc,6,1,0" M1="167" M2="167" P1="3497.11,529.1" P2="3497.11,530.1"/><JD c="5c94fc,6,1,0" M1="168" M2="168" P1="4267.11,279.1" P2="4267.11,280.1"/><JD c="5c94fc,6,1,0" M1="169" M2="169" P1="3867.11,349.1" P2="3867.11,350.1"/><JD c="5c94fc,6,1,0" M1="170" M2="170" P1="5467.11,299.1" P2="5467.11,300.1"/><JD c="000000,6,1,0" M1="171" M2="171" P1="21727.11,150.1" P2="21727.11,151.1"/><JD c="000000,6,1,0" M1="172" M2="172" P1="22597.11,470.1" P2="22597.11,471.1"/><JD c="000000,6,1,0" M1="173" M2="173" P1="24177.11,140.1" P2="24177.11,141.1"/><JD c="000000,6,1,0" M1="174" M2="174" P1="25147.11,250.1" P2="25147.11,251.1"/><JD c="000000,6,1,0" M1="175" M2="175" P1="26307.11,390.1" P2="26307.11,391.1"/><JD c="000000,6,1,0" M1="176" M2="176" P1="23357.11,240.1" P2="23357.11,241.1"/><JD c="5c94fc,6,1,0" M1="177" M2="177" P1="12867.11,480.1" P2="12867.11,481.1"/><JD c="5c94fc,6,1,0" M1="178" M2="178" P1="14007.11,200.1" P2="14007.11,201.1"/><JD c="5c94fc,6,1,0" M1="179" M2="179" P1="14237.11,200.1" P2="14237.11,201.1"/><JD c="5c94fc,6,1,0" M1="180" M2="180" P1="11376.11,173.1" P2="11376.11,174.1"/><JD c="000000,6,1,0" M1="181" M2="181" P1="21216.11,473.1" P2="21216.11,474.1"/><JD c="000000,6,1,0" M1="182" M2="182" P1="21046.11,243.1" P2="21046.11,244.1"/><JD c="000000,6,1,0" M1="183" M2="183" P1="21276.11,182.1" P2="21276.11,183.1"/><JD c="000000,6,1,0" M1="184" M2="184" P1="22546.11,263.1" P2="22546.11,264.1"/><JD c="000000,6,1,0" M1="185" M2="185" P1="25366.11,213.1" P2="25366.11,214.1"/><JD c="000000,6,1,0" M1="186" M2="186" P1="26526.11,363.1" P2="26526.11,364.1"/><JD c="5c94fc,6,1,0" M1="187" M2="187" P1="11016.11,473.1" P2="11016.11,474.1"/><JD c="c84c0c,6,1,0" M1="188" M2="188" P1="4576.11,472.1" P2="4576.11,473.1"/><JD c="5c94fc,6,1,0" M1="189" M2="189" P1="3766.11,552.1" P2="3766.11,553.1"/><JD c="5c94fc,6,1,0" M1="190" M2="190" P1="1976.11,542.1" P2="1976.11,543.1"/><JD c="5c94fc,6,1,0" M1="191" M2="191" P1="3976.11,522.1" P2="3976.11,523.1"/><JD c="5c94fc,6,1,0" M1="192" M2="192" P1="6406.11,222.1" P2="6406.11,223.1"/><JD c="5c94fc,6,1,0" M1="193" M2="193" P1="14487.11,200.1" P2="14487.11,201.1"/><JD c="5c94fc,6,1,0" M1="194" M2="194" P1="14247.11,500.1" P2="14247.11,501.1"/><JD c="5c94fc,6,1,0" M1="195" M2="195" P1="14887.11,200.1" P2="14887.11,201.1"/><JD c="5c94fc,6,1,0" M1="144" M2="144" P1="2187.11,229.1" P2="2187.11,230.1"/><JD c="5c94fc,6,1,0" M1="145" M2="145" P1="1487.11,204.1" P2="1487.11,205.1"/><JD c="000000,6,1,0" M1="145" M2="145" P1="22327.11,104.1" P2="22327.11,105.1"/><JD c="000000,6,1,0" M1="145" M2="145" P1="23567.11,144.1" P2="23567.11,145.1"/><JD c="000000,6,1,0" M1="145" M2="145" P1="23206.11,444.1" P2="23206.11,445.1"/><JD c="000000,6,1,0" M1="145" M2="145" P1="23446.11,445.1" P2="23446.11,446.1"/><JD c="000000,6,1,0" M1="145" M2="145" P1="24687.11,484.1" P2="24687.11,485.1"/><JD c="000000,6,1,0" M1="151" M2="151" P1="22067.11,105.1" P2="22067.11,106.1"/><JD c="c84c0c,6,1,0" M1="152" M2="152" P1="3327.11,529.1" P2="3327.11,530.1"/><JD c="5c94fc,6,1,0" M1="153" M2="153" P1="4097.11,279.1" P2="4097.11,280.1"/><JD c="5c94fc,6,1,0" M1="154" M2="154" P1="3697.11,349.1" P2="3697.11,350.1"/><JD c="5c94fc,6,1,0" M1="155" M2="155" P1="5297.11,299.1" P2="5297.11,300.1"/><JD c="000000,6,1,0" M1="156" M2="156" P1="21557.11,150.1" P2="21557.11,151.1"/><JD c="000000,6,1,0" M1="157" M2="157" P1="22427.11,470.1" P2="22427.11,471.1"/><JD c="000000,6,1,0" M1="158" M2="158" P1="24007.11,140.1" P2="24007.11,141.1"/><JD c="000000,6,1,0" M1="159" M2="159" P1="24977.11,250.1" P2="24977.11,251.1"/><JD c="000000,6,1,0" M1="160" M2="160" P1="26137.11,390.1" P2="26137.11,391.1"/><JD c="000000,6,1,0" M1="161" M2="161" P1="23187.11,240.1" P2="23187.11,241.1"/><JD c="5c94fc,6,1,0" M1="162" M2="162" P1="12697.11,480.1" P2="12697.11,481.1"/><JD c="5c94fc,6,1,0" M1="163" M2="163" P1="13837.11,200.1" P2="13837.11,201.1"/><JD c="5c94fc,6,1,0" M1="164" M2="164" P1="14077.11,500.1" P2="14077.11,501.1"/><JD c="5c94fc,6,1,0" M1="165" M2="165" P1="14717.11,200.1" P2="14717.11,201.1"/><JD c="5c94fc,6,1,0" M1="166" M2="166" P1="2377.11,229.1" P2="2377.11,230.1"/><JD c="5c94fc,6,1,0" M1="167" M2="167" P1="3517.11,529.1" P2="3517.11,530.1"/><JD c="5c94fc,6,1,0" M1="168" M2="168" P1="4287.11,279.1" P2="4287.11,280.1"/><JD c="5c94fc,6,1,0" M1="169" M2="169" P1="3887.11,349.1" P2="3887.11,350.1"/><JD c="5c94fc,6,1,0" M1="170" M2="170" P1="5487.11,299.1" P2="5487.11,300.1"/><JD c="000000,6,1,0" M1="171" M2="171" P1="21747.11,150.1" P2="21747.11,151.1"/><JD c="000000,6,1,0" M1="172" M2="172" P1="22617.11,470.1" P2="22617.11,471.1"/><JD c="000000,6,1,0" M1="173" M2="173" P1="24197.11,140.1" P2="24197.11,141.1"/><JD c="000000,6,1,0" M1="174" M2="174" P1="25167.11,250.1" P2="25167.11,251.1"/><JD c="000000,6,1,0" M1="175" M2="175" P1="26327.11,390.1" P2="26327.11,391.1"/><JD c="000000,6,1,0" M1="176" M2="176" P1="23377.11,240.1" P2="23377.11,241.1"/><JD c="5c94fc,6,1,0" M1="177" M2="177" P1="12887.11,480.1" P2="12887.11,481.1"/><JD c="5c94fc,6,1,0" M1="178" M2="178" P1="14027.11,200.1" P2="14027.11,201.1"/><JD c="5c94fc,6,1,0" M1="179" M2="179" P1="14257.11,200.1" P2="14257.11,201.1"/><JD c="5c94fc,6,1,0" M1="180" M2="180" P1="11396.11,173.1" P2="11396.11,174.1"/><JD c="000000,6,1,0" M1="181" M2="181" P1="21236.11,473.1" P2="21236.11,474.1"/><JD c="000000,6,1,0" M1="182" M2="182" P1="21066.11,243.1" P2="21066.11,244.1"/><JD c="000000,6,1,0" M1="183" M2="183" P1="21296.11,182.1" P2="21296.11,183.1"/><JD c="000000,6,1,0" M1="184" M2="184" P1="22566.11,263.1" P2="22566.11,264.1"/><JD c="000000,6,1,0" M1="185" M2="185" P1="25386.11,213.1" P2="25386.11,214.1"/><JD c="000000,6,1,0" M1="186" M2="186" P1="26546.11,363.1" P2="26546.11,364.1"/><JD c="5c94fc,6,1,0" M1="187" M2="187" P1="11036.11,473.1" P2="11036.11,474.1"/><JD c="c84c0c,6,1,0" M1="188" M2="188" P1="4596.11,472.1" P2="4596.11,473.1"/><JD c="5c94fc,6,1,0" M1="189" M2="189" P1="3786.11,552.1" P2="3786.11,553.1"/><JD c="5c94fc,6,1,0" M1="190" M2="190" P1="1996.11,542.1" P2="1996.11,543.1"/><JD c="5c94fc,6,1,0" M1="191" M2="191" P1="3996.11,522.1" P2="3996.11,523.1"/><JD c="5c94fc,6,1,0" M1="192" M2="192" P1="6426.11,222.1" P2="6426.11,223.1"/><JD c="5c94fc,6,1,0" M1="193" M2="193" P1="14507.11,200.1" P2="14507.11,201.1"/><JD c="5c94fc,6,1,0" M1="194" M2="194" P1="14267.11,500.1" P2="14267.11,501.1"/><JD c="5c94fc,6,1,0" M1="195" M2="195" P1="14907.11,200.1" P2="14907.11,201.1"/><JD c="5c94fc,6,1,0" M1="144" M2="144" P1="2210.11,229.1" P2="2210.11,230.1"/><JD c="5c94fc,6,1,0" M1="145" M2="145" P1="1510.11,204.1" P2="1510.11,205.1"/><JD c="000000,6,1,0" M1="145" M2="145" P1="22350.11,104.1" P2="22350.11,105.1"/><JD c="000000,6,1,0" M1="145" M2="145" P1="23590.11,144.1" P2="23590.11,145.1"/><JD c="000000,6,1,0" M1="145" M2="145" P1="23229.11,444.1" P2="23229.11,445.1"/><JD c="000000,6,1,0" M1="145" M2="145" P1="23469.11,445.1" P2="23469.11,446.1"/><JD c="000000,6,1,0" M1="145" M2="145" P1="24710.11,484.1" P2="24710.11,485.1"/><JD c="000000,6,1,0" M1="151" M2="151" P1="22090.11,105.1" P2="22090.11,106.1"/><JD c="c84c0c,6,1,0" M1="152" M2="152" P1="3350.11,529.1" P2="3350.11,530.1"/><JD c="5c94fc,6,1,0" M1="153" M2="153" P1="4120.11,279.1" P2="4120.11,280.1"/><JD c="5c94fc,6,1,0" M1="154" M2="154" P1="3720.11,349.1" P2="3720.11,350.1"/><JD c="5c94fc,6,1,0" M1="155" M2="155" P1="5320.11,299.1" P2="5320.11,300.1"/><JD c="000000,6,1,0" M1="156" M2="156" P1="21580.11,150.1" P2="21580.11,151.1"/><JD c="000000,6,1,0" M1="157" M2="157" P1="22450.11,470.1" P2="22450.11,471.1"/><JD c="000000,6,1,0" M1="158" M2="158" P1="24030.11,140.1" P2="24030.11,141.1"/><JD c="000000,6,1,0" M1="159" M2="159" P1="25000.11,250.1" P2="25000.11,251.1"/><JD c="000000,6,1,0" M1="160" M2="160" P1="26160.11,390.1" P2="26160.11,391.1"/><JD c="000000,6,1,0" M1="161" M2="161" P1="23210.11,240.1" P2="23210.11,241.1"/><JD c="5c94fc,6,1,0" M1="162" M2="162" P1="12720.11,480.1" P2="12720.11,481.1"/><JD c="5c94fc,6,1,0" M1="163" M2="163" P1="13860.11,200.1" P2="13860.11,201.1"/><JD c="5c94fc,6,1,0" M1="164" M2="164" P1="14100.11,500.1" P2="14100.11,501.1"/><JD c="5c94fc,6,1,0" M1="165" M2="165" P1="14740.11,200.1" P2="14740.11,201.1"/><JD c="5c94fc,6,1,0" M1="166" M2="166" P1="2400.11,229.1" P2="2400.11,230.1"/><JD c="5c94fc,6,1,0" M1="167" M2="167" P1="3540.11,529.1" P2="3540.11,530.1"/><JD c="5c94fc,6,1,0" M1="168" M2="168" P1="4310.11,279.1" P2="4310.11,280.1"/><JD c="5c94fc,6,1,0" M1="169" M2="169" P1="3910.11,349.1" P2="3910.11,350.1"/><JD c="5c94fc,6,1,0" M1="170" M2="170" P1="5510.11,299.1" P2="5510.11,300.1"/><JD c="000000,6,1,0" M1="171" M2="171" P1="21770.11,150.1" P2="21770.11,151.1"/><JD c="000000,6,1,0" M1="172" M2="172" P1="22640.11,470.1" P2="22640.11,471.1"/><JD c="000000,6,1,0" M1="173" M2="173" P1="24220.11,140.1" P2="24220.11,141.1"/><JD c="000000,6,1,0" M1="174" M2="174" P1="25190.11,250.1" P2="25190.11,251.1"/><JD c="000000,6,1,0" M1="175" M2="175" P1="26350.11,390.1" P2="26350.11,391.1"/><JD c="000000,6,1,0" M1="176" M2="176" P1="23400.11,240.1" P2="23400.11,241.1"/><JD c="5c94fc,6,1,0" M1="177" M2="177" P1="12910.11,480.1" P2="12910.11,481.1"/><JD c="5c94fc,6,1,0" M1="178" M2="178" P1="14050.11,200.1" P2="14050.11,201.1"/><JD c="5c94fc,6,1,0" M1="179" M2="179" P1="14280.11,200.1" P2="14280.11,201.1"/><JD c="5c94fc,6,1,0" M1="180" M2="180" P1="11419.11,173.1" P2="11419.11,174.1"/><JD c="000000,6,1,0" M1="181" M2="181" P1="21259.11,473.1" P2="21259.11,474.1"/><JD c="000000,6,1,0" M1="182" M2="182" P1="21089.11,243.1" P2="21089.11,244.1"/><JD c="000000,6,1,0" M1="183" M2="183" P1="21319.11,182.1" P2="21319.11,183.1"/><JD c="000000,6,1,0" M1="184" M2="184" P1="22589.11,263.1" P2="22589.11,264.1"/><JD c="000000,6,1,0" M1="185" M2="185" P1="25409.11,213.1" P2="25409.11,214.1"/><JD c="000000,6,1,0" M1="186" M2="186" P1="26569.11,363.1" P2="26569.11,364.1"/><JD c="5c94fc,6,1,0" M1="187" M2="187" P1="11059.11,473.1" P2="11059.11,474.1"/><JD c="c84c0c,6,1,0" M1="188" M2="188" P1="4619.11,472.1" P2="4619.11,473.1"/><JD c="5c94fc,6,1,0" M1="189" M2="189" P1="3809.11,552.1" P2="3809.11,553.1"/><JD c="5c94fc,6,1,0" M1="190" M2="190" P1="2019.11,542.1" P2="2019.11,543.1"/><JD c="5c94fc,6,1,0" M1="191" M2="191" P1="4019.11,522.1" P2="4019.11,523.1"/><JD c="5c94fc,6,1,0" M1="192" M2="192" P1="6449.11,222.1" P2="6449.11,223.1"/><JD c="5c94fc,6,1,0" M1="193" M2="193" P1="14530.11,200.1" P2="14530.11,201.1"/><JD c="5c94fc,6,1,0" M1="194" M2="194" P1="14290.11,500.1" P2="14290.11,501.1"/><JD c="5c94fc,6,1,0" M1="195" M2="195" P1="14930.11,200.1" P2="14930.11,201.1"/><JP M1="54" AXIS="-1,0"/><JP M1="66" AXIS="-1,0"/><JP M1="67" AXIS="-1,0"/><JP M1="68" AXIS="-1,0"/><JP M1="55" AXIS="-1,0"/><JP M1="69" AXIS="-1,0"/><JP M1="70" AXIS="-1,0"/><JP M1="56" AXIS="-1,0"/><JP M1="71" AXIS="-1,0"/><JP M1="72" AXIS="-1,0"/><JP M1="75" AXIS="-1,0"/><JP M1="92" AXIS="-1,0"/><JR M2="139" P1="3814,254" MV="Infinity,0.78"/><JD M1="1" M2="54"/><JD M1="1" M2="66"/><JD M1="1" M2="67"/><JD M1="1" M2="68"/><JD M1="1" M2="55"/><JD M1="1" M2="69"/><JD M1="1" M2="70"/><JD M1="1" M2="71"/><JD M1="1" M2="56"/><JD M1="1" M2="72"/><JD M1="1" M2="75"/><JD M1="1" M2="92"/><JR M2="140" P1="25214.71,247.4" MV="Infinity,0.78"/><JR M2="138" P1="21966.75,218.83" MV="Infinity,0.52"/><JD M1="132" M2="138"/><JD M1="133" M2="139"/><JPL c="fd993c,2,1,0" M1="144" M2="166" P3="2190,128" P4="2380,128"/><JD c="d62700,6,1,0" P1="2190.94,130.11" P2="2190.94,131.11"/><JD c="d62700,6,1,0" P1="2378.41,130.11" P2="2378.41,131.11"/><JPL c="fd993c,2,1,0" M1="153" M2="168" P3="4100,178" P4="4290,178"/><JPL c="fd993c,2,1,0" M1="154" M2="169" P3="3700,248" P4="3890,248"/><JPL c="fd993c,2,1,0" M1="155" M2="170" P3="5300,198" P4="5490,198"/><JPL c="F2F2F2,2,1,0" M1="156" M2="171" P3="21560,49" P4="21750,49"/><JPL c="F2F2F2,2,1,0" M1="157" M2="172" P3="22430,369" P4="22620,369"/><JPL c="F2F2F2,2,1,0" M1="158" M2="173" P3="24010,39" P4="24200,39"/><JPL c="F2F2F2,2,1,0" M1="159" M2="174" P3="24980,149" P4="25170,149"/><JPL c="F2F2F2,2,1,0" M1="160" M2="175" P3="26140,289" P4="26330,289"/><JPL c="F2F2F2,2,1,0" M1="161" M2="176" P3="23190,139" P4="23380,139"/><JPL c="fd993c,2,1,0" M1="162" M2="177" P3="12700,379" P4="12890,379"/><JPL c="fd993c,2,1,0" M1="163" M2="178" P3="13840,99" P4="14030,99"/><JD c="d62700,6,1,0" P1="5300.94,200.11" P2="5300.94,201.11"/><JPL c="fd993c,2,1,0" M1="164" M2="194" P3="14080,399" P4="14270,399"/><JD c="d62700,6,1,0" P1="5488.41,200.11" P2="5488.41,201.11"/><JPL c="fd993c,2,1,0" M1="165" M2="195" P3="14720,99" P4="14910,99"/><JD c="5F5B5A,6,1,0" P1="21560.94,51.11" P2="21560.94,52.11"/><JD c="5F5B5A,6,1,0" P1="22430.94,371.11" P2="22430.94,372.11"/><JD c="5F5B5A,6,1,0" P1="24010.94,41.11" P2="24010.94,42.11"/><JD c="5F5B5A,6,1,0" P1="24980.94,151.11" P2="24980.94,152.11"/><JD c="5F5B5A,6,1,0" P1="26140.94,291.11" P2="26140.94,292.11"/><JD c="5F5B5A,6,1,0" P1="23190.94,141.11" P2="23190.94,142.11"/><JD c="d62700,6,1,0" P1="12700.94,381.11" P2="12700.94,382.11"/><JD c="d62700,6,1,0" P1="12888.41,381.11" P2="12888.41,382.11"/><JD c="d62700,6,1,0" P1="13840.94,101.11" P2="13840.94,102.11"/><JD c="d62700,6,1,0" P1="14028.41,101.11" P2="14028.41,102.11"/><JD c="d62700,6,1,0" P1="4597.41,373.11" P2="4597.41,374.11"/><JD c="d62700,6,1,0" P1="3787.41,453.11" P2="3787.41,454.11"/><JD c="d62700,6,1,0" P1="3997.41,423.11" P2="3997.41,424.11"/><JD c="d62700,6,1,0" P1="6427.41,123.11" P2="6427.41,124.11"/><JD c="d62700,6,1,0" P1="4100.94,180.11" P2="4100.94,181.11"/><JD c="d62700,6,1,0" P1="3700.94,250.11" P2="3700.94,251.11"/><JD c="5F5B5A,6,1,0" P1="21748.41,51.11" P2="21748.41,52.11"/><JD c="5F5B5A,6,1,0" P1="22618.41,371.11" P2="22618.41,372.11"/><JD c="5F5B5A,6,1,0" P1="24198.41,41.11" P2="24198.41,42.11"/><JD c="5F5B5A,6,1,0" P1="25168.41,151.11" P2="25168.41,152.11"/><JD c="5F5B5A,6,1,0" P1="26328.41,291.11" P2="26328.41,292.11"/><JD c="5F5B5A,6,1,0" P1="23378.41,141.11" P2="23378.41,142.11"/><JD c="d62700,6,1,0" P1="14080.94,401.11" P2="14080.94,402.11"/><JD c="d62700,6,1,0" P1="4288.41,180.11" P2="4288.41,181.11"/><JD c="d62700,6,1,0" P1="3888.41,250.11" P2="3888.41,251.11"/><JD c="d62700,6,1,0" P1="14720.94,101.11" P2="14720.94,102.11"/><JD c="d62700,6,1,0" P1="14268.41,401.11" P2="14268.41,402.11"/><JD c="d62700,6,1,0" P1="14908.41,101.11" P2="14908.41,102.11"/><JPL c="fd993c,2,1,0" M1="152" M2="167" P3="3330,428" P4="3520,428"/><JD c="d62700,6,1,0" P1="3330.94,430.11" P2="3330.94,431.11"/><JD c="d62700,6,1,0" P1="3518.41,430.11" P2="3518.41,431.11"/><JP M1="152" AXIS="0,1"/><JP M1="167" AXIS="0,1"/><JP M1="154" AXIS="0,1"/><JP M1="169" AXIS="0,1"/><JP M1="153" AXIS="0,1"/><JP M1="168" AXIS="0,1"/><JP M1="155" AXIS="0,1"/><JP M1="170" AXIS="0,1"/><JP M1="156" AXIS="0,1"/><JP M1="171" AXIS="0,1"/><JP M1="162" AXIS="0,1"/><JP M1="177" AXIS="0,1"/><JP M1="163" AXIS="0,1"/><JP M1="178" AXIS="0,1"/><JP M1="164" AXIS="0,1"/><JP M1="194" AXIS="0,1"/><JP M1="165" AXIS="0,1"/><JP M1="195" AXIS="0,1"/><JD c="fd993c,2,1,0" M1="179" P2="14259,103.1"/><JD c="d62700,6,1,0" P1="14258.41,101.11" P2="14258.41,102.11"/><JD c="fd993c,2,1,0" M1="180" P2="11398,76.1"/><JD c="FFFFFF,2,1,0" M1="181" P2="21238,376.1"/><JD c="FFFFFF,2,1,0" M1="182" P2="21068,146.1"/><JD c="FFFFFF,2,1,0" M1="183" P2="21298,85.1"/><JD c="FFFFFF,2,1,0" M1="184" P2="22568,166.1"/><JD c="FFFFFF,2,1,0" M1="185" P2="25388,116.1"/><JD c="FFFFFF,2,1,0" M1="186" P2="26548,266.1"/><JD c="fd993c,2,1,0" M1="187" P2="11038,376.1"/><JD c="fd993c,2,1,0" M1="188" P2="4598,375.1"/><JD c="fd993c,2,1,0" M1="189" P2="3788,455.1"/><JD c="fd993c,2,1,0" M1="190" P2="1998,445.1"/><JD c="fd993c,2,1,0" M1="191" P2="3998,425.1"/><JD c="fd993c,2,1,0" M1="192" P2="6428,125.1"/><JD c="fd993c,2,1,0" M1="193" P2="14509,103.1"/><JP M1="144" AXIS="0,1"/><JD c="d62700,6,1,0" P1="11397.41,74.11" P2="11397.41,75.11"/><JD c="5E5E5E,6,1,0" P1="21238.41,374.11" P2="21238.41,375.11"/><JD c="5E5E5E,6,1,0" P1="21068.41,144.11" P2="21068.41,145.11"/><JD c="5E5E5E,6,1,0" P1="21298.41,83.11" P2="21298.41,84.11"/><JD c="5E5E5E,6,1,0" P1="22568.41,164.11" P2="22568.41,165.11"/><JD c="5E5E5E,6,1,0" P1="25388.41,114.11" P2="25388.41,115.11"/><JD c="5E5E5E,6,1,0" P1="26548.41,264.11" P2="26548.41,265.11"/><JP M1="166" AXIS="0,1"/><JP M1="1" AXIS="-1,0"/><JD c="5c94fc,36,1,0" P1="13682.69,217.99" P2="13682.69,218.99"/><JD c="d62700,6,1,0" P1="11037.41,375.11" P2="11037.41,376.11"/><JD c="d62700,6,1,0" P1="14508.41,101.11" P2="14508.41,102.11"/><JP M1="76" AXIS="-1,0"/><JP M1="77" AXIS="-1,0"/><JP M1="78" AXIS="-1,0"/><JP M1="79" AXIS="-1,0"/><JP M1="80" AXIS="-1,0"/><JP M1="83" AXIS="-1,0"/><JP M1="84" AXIS="-1,0"/><JP M1="81" AXIS="-1,0"/><JP M1="82" AXIS="-1,0"/><JP M1="85" AXIS="-1,0"/><JP M1="86" AXIS="-1,0"/><JP M1="57" AXIS="-1,0"/><JP M1="58" AXIS="-1,0"/><JP M1="59" AXIS="-1,0"/><JP M1="87" AXIS="-1,0"/><JP M1="88" AXIS="-1,0"/><JP M1="89" AXIS="-1,0"/><JP M1="90" AXIS="-1,0"/><JP M1="91" AXIS="-1,0"/><JP M1="60" AXIS="-1,0"/><JR M1="60" M2="99"/><JR M1="91" M2="130"/><JR M1="90" M2="129"/><JR M1="89" M2="128"/><JR M1="88" M2="127"/><JR M1="87" M2="126"/><JR M1="59" M2="98"/><JR M1="58" M2="97"/><JD c="d62700,6,1,0" P1="1997.41,443.11" P2="1997.41,444.11"/><JR M1="57" M2="96"/><JR M1="86" M2="125"/><JR M1="85" M2="124"/><JR M1="82" M2="121"/><JR M1="81" M2="120"/><JR M1="80" M2="119"/><JR M1="83" M2="122"/><JR M1="84" M2="123"/><JR M1="79" M2="118"/><JR M1="78" M2="117"/><JR M1="77" M2="116"/><JR M1="76" M2="115"/><JD M1="1" M2="76"/><JD M1="1" M2="78"/><JD M1="1" M2="79"/><JD M1="1" M2="77"/><JD M1="1" M2="80"/><JD M1="1" M2="83"/><JD M1="1" M2="84"/><JD M1="1" M2="81"/><JD M1="1" M2="82"/><JD M1="1" M2="85"/><JD M1="1" M2="86"/><JD M1="1" M2="57"/><JD M1="1" M2="58"/><JD M1="1" M2="59"/><JD M1="1" M2="87"/><JD M1="1" M2="88"/><JD M1="1" M2="89"/><JD M1="1" M2="90"/><JD M1="1" M2="91"/><JD M1="1" M2="60"/><JD M1="134" M2="140"/><JR M2="143" P1="14345.15,265.45" MV="Infinity,0.52"/><JD M1="137" M2="143"/><JR M2="142" P1="12853.69,345.12" MV="Infinity,0.78"/><JD M1="136" M2="142"/><JP M1="157" AXIS="0,1"/><JP M1="172" AXIS="0,1"/><JP M1="158" AXIS="0,1"/><JP M1="173" AXIS="0,1"/><JP M1="161" AXIS="0,1"/><JP M1="176" AXIS="0,1"/><JR M2="151" P1="22070,104.67" LIM1="-0.78" LIM2="0.78"/><JP M1="159" AXIS="0,1"/><JP M1="174" AXIS="0,1"/><JP M1="160" AXIS="0,1"/><JP M1="175" AXIS="0,1"/><JR M1="73" M2="112"/><JR M1="113" M2="74"/><JP M1="73" AXIS="-1,0"/><JP M1="74" AXIS="-1,0"/><JD M1="1" M2="73"/><JD M1="1" M2="74"/><JD M1="141" M2="135"/><JR M2="141" P1="26283.36,313.99" MV="Infinity,0.52"/></L></Z></C>'
level_spawns = {}	-- bstore the level spawns locations
-- level spawns coordinates:
table.insert(level_spawns, {x = 105, y = 515})		-- level 1
table.insert(level_spawns, {x = 10105, y = 515})	-- level 2
table.insert(level_spawns, {x = 20105, y = 515})	-- level 3
-- bonus points coordinates:
points = {{x = 1435, y = 475}, {x = 1560, y = 305}, {x = 1645, y = 305}, {x = 2000, y = 515}, {x = 2190, y = 200}, {x = 2380, y = 200}, {x = 3000, y = 260}, {x = 3790, y = 405}, {x = 3960, y = 200}, {x = 4500, y = 260}, {x = 4750, y = 260}, {x = 4600, y = 450}, {x = 5020, y = 345}, {x = 5090, y = 345}, {x = 5190, y = 510}, {x = 5300, y = 275}, {x = 5490, y = 275}, {x = 5580, y = 515}, {x = 6125, y = 175}, {x = 6430, y = 195}, {x = 11330, y = 345}, {x = 11630, y = 130}, {x = 12145, y = 345}, {x = 12390, y = 210}, {x = 12700, y = 450}, {x = 12890, y = 450}, {x = 13220, y = 85}, {x = 13260, y = 85}, {x = 13300, y = 85}, {x = 14145, y = 110}, {x = 14385, y = 110}, {x = 14625, y = 110}, {x = 14480, y = 430}, {x = 14520, y = 430}, {x = 15275, y = 215}, {x = 15530, y = 515}, {x = 21355, y = 345}, {x = 21475, y = 345}, {x = 21380, y = 90}, {x = 21420, y = 90}, {x = 21460, y = 90}, {x = 21630, y = 520}, {x = 21670, y = 520}, {x = 21870, y = 110}, {x = 21910, y = 110}, {x = 22180, y = 110}, {x = 22220, y = 110}, {x = 22185, y = 435}, {x = 23190, y = 215}, {x = 23380, y = 215}, {x = 23325, y = 435}, {x = 23665, y = 90}, {x = 23705, y = 90}, {x = 23745, y = 90}, {x = 23695, y = 390}, {x = 23805, y = 390}, {x = 24105, y = 120}, {x = 24050, y = 515}, {x = 24480, y = 515}, {x = 24700, y = 345}, {x = 25315, y = 515}, {x = 25355, y = 515}, {x = 25675, y = 175}, {x = 25715, y = 175}, {x = 25755, y = 175}, {x = 26547, y = 335}, {x = 26705, y = 175}, {x = 26745, y = 175}, {x = 26785, y = 175}, {x = 26705, y = 135}, {x = 26745, y = 135}, {x = 26785, y = 135}, {x = 26705, y = 95}, {x = 26745, y = 95}, {x = 26785, y = 95}, {x = 29900, y = 383}, {x = 29977, y = 383}, {x = 30071, y = 383}, {x = 30150, y = 383}, {x = 29950, y = 317}, {x = 30030, y = 317}, {x = 30110, y = 317}, {x = 29990, y = 255}, {x = 30075, y = 255}, {x = 30030, y = 200}, {x = 32400, y = 160}, {x = 32360, y = 215}, {x = 32445, y = 215}, {x = 32320, y = 277}, {x = 32400, y = 277}, {x = 32480, y = 277}, {x = 32270, y = 343}, {x = 32347, y = 343}, {x = 32441, y = 343}, {x = 32520, y = 343}, {x = 32301, y = 441}, {x = 32370, y = 441}, {x = 32430, y = 441}, {x = 32500, y = 441}, {x = 25075, y = 235}}
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
-- Internal Use:
players_level = {}				-- store at what level is every player
count = 0
players_coin_images_ids = {}	-- map of player's set of non-obtained coins
--- Bind the keys used by this module for a player.
function BindPlayerKeys(player_name)
	tfm.exec.bindKeyboard(player_name, 0, false, true)
	tfm.exec.bindKeyboard(player_name, 1, false, true)
	tfm.exec.bindKeyboard(player_name, 2, false, true)
	tfm.exec.bindKeyboard(player_name, 0, true, true)
    tfm.exec.bindKeyboard(player_name, 1, true, true)
	tfm.exec.bindKeyboard(player_name, 2, true, true)
	tfm.exec.bindKeyboard(player_name, 3, true, true)
end
--- Respawn Points for a player: 
function RespawnPointsForPlayer(player_name)
	players_coin_images_ids[player_name] = players_coin_images_ids[player_name] or {} -- create the table for that player if it doesnt exist
	player_coins = players_coin_images_ids[player_name]
	-- unspawn coints
	for i_point, point in pairs(points) do
		tfm.exec.removeBonus(i_point, player_name)
		if player_coins[i_point] then
			tfm.exec.removeImage(player_coins[i_point])
			player_coins[i_point] = nil
		end
	end
	-- spawn coins
	for i_point, point in pairs(points) do
		tfm.exec.addBonus(0, point.x, point.y, i_point, 0, false, player_name)
		player_coins[i_point] = tfm.exec.addImage("17aa6f22c53.png", "?226", point.x - 15, point.y - 20, player_name)
	end
end
--- TFM event eventNewGame
function eventNewGame()
	-- spawn images for everybody
	for i_image, image in pairs(images) do
		tfm.exec.addImage(image.image, image.target, image.x, image.y)
	end
	for player_name in pairs(tfm.get.room.playerList) do
		RespawnPointsForPlayer(player_name)
	end
	ui.setMapName(map_name)
	ui.setShamanName(shaman_name)
end
--- TFM event eventNewPlayer
function eventNewPlayer(player_name)
	BindPlayerKeys(player_name)
	RespawnPointsForPlayer(player_name)
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
--- TFM event eventPlayerDied
function eventPlayerDied(playerName)
	tfm.exec.respawnPlayer(playerName)
end
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
end
--- TFM event eventPlayerWon
-- send the player to the next level when they win
function eventPlayerWon(player_name)
	-- if we dont know what's the players level, default to 1
	if not players_level[player_name] then
		players_level[player_name] = 1
	end
	-- show that
	tfm.exec.chatMessage("<vi>" .. player_name .. " just finished level " .. players_level[player_name] .. "!</vi>", nil)
	-- next level for that player
	players_level[player_name] = players_level[player_name] + 1
	-- if no more levels, return to 1
	if not level_spawns[players_level[player_name]] then
		players_level[player_name] = 1
	end
	-- next spawn
	new_spawn = level_spawns[players_level[player_name]]
	pshy.CheckpointsSetPlayerCheckpoint(player_name, new_spawn.x, new_spawn.y)
	pshy.CheckpointsPlayerCheckpoint(player_name)
end
--- TFM event eventPlayerRespawn
function eventPlayerRespawn(player_name)
	--RespawnPointsForPlayer(player_name)
end
--- TFM event eventPlayerBonusGrabbed
function eventPlayerBonusGrabbed(player_name, bonus_id)
	if players_coin_images_ids[player_name][bonus_id] then -- may be null if deleted before this is called (caused by eventPlayerScore)
		-- remove the coin image, then set it as `nil` so we know it no longer exists
		tfm.exec.removeImage(players_coin_images_ids[player_name][bonus_id])
		players_coin_images_ids[player_name][bonus_id] = nil
	end
end
--- TFM event eventKeyboard
-- Handle player teleportations for pipes.
function eventKeyboard(name, keyCode, down, xPlayerPosition,yPlayerPosition)
	if keyCode==3 then
		if xPlayerPosition >= 2620 and xPlayerPosition <= 2640 and yPlayerPosition >= 415 and yPlayerPosition <= 450 then
			tfm.exec.movePlayer(name,29800,80,false,0,0,false)
		end
		if xPlayerPosition >= 11880 and xPlayerPosition <= 11900 and yPlayerPosition >= 380 and yPlayerPosition <= 400  then
			tfm.exec.movePlayer(name,32185,100  ,false,0,0,false)
		end
	end
	--pipe from coin room to up world
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
end
--- Pshy eventPlayerScore
function eventPlayerScore(player_name, scored)
	if pshy.scores[player_name] % #points == 0 then
		tfm.exec.chatMessage("<vi>" .. player_name .. " just finished collecting all the " .. tostring(#points) .. " coins!</vi>", nil)
		RespawnPointsForPlayer(player_name)
	end
end
--- Initialization:
for player_name, v in pairs(tfm.get.room.playerList) do
	BindPlayerKeys(player_name)
end
tfm.exec.newGame(map_xml)
pshy.merge_ModuleEnd()
pshy.merge_Finish()

