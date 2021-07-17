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
pshy.merge_ModuleBegin("pshy_ban.lua")
--- pshy_ban.lua
--
-- Allow to ban players from the room.
-- Players are not realy made to leave the room, just prevented from playing.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
-- @require pshy_help.lua
-- @require pshy_merge.lua
-- @require pshy_commands.lua
pshy = pshy or {}
--- Module Help Page:
pshy.help_pages["pshy_anticheats"] = pshy.help_pages["pshy_anticheats"] or {back = "pshy", restricted = true, text = "", commands = {}, subpages = {}}
pshy.help_pages["pshy"].subpages["pshy_anticheats"] = pshy.help_pages["pshy_anticheats"]
--- Module Settings:
pshy.ban_mask_ui_arbitrary_id = 71
--- Internal Use:
pshy.banlist = {}
--- Ban a player
function pshy.BanPlayer(player_name)
	pshy.banlist[player_name] = true
	pshy.BanRefreshPlayer(player_name)
end
pshy.chat_commands["ban"] = {func = pshy.BanPlayer, desc = "Ban a player from the room.", no_user = true, argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_anticheats"].commands["ban"] = pshy.chat_commands["ban"]
--- Unban a player
function pshy.UnbanPlayer(player_name)
	pshy.banlist[player_name] = nil
	ui.removeTextArea(pshy.ban_mask_ui_arbitrary_id, player_name)
end
pshy.chat_commands["unban"] = {func = pshy.UnbanPlayer, desc = "Unban a player from the room.", no_user = true, argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_anticheats"].commands["unban"] = pshy.chat_commands["unban"]
--- Proceed with what have to be done on a banned player.
-- @private
function pshy.BanRefreshPlayer(player_name)
	tfm.exec.removeCheese("player_name")
	tfm.exec.movePlayer(player_name, -1001, -1001, false, 0, 0, true)
	tfm.exec.killPlayer("player_name")
	ui.addTextArea(pshy.ban_mask_ui_arbitrary_id, "", player_name, -999, -999, 800 + 2002, 400 + 2002, 0x111111, 0, 0.01, false)
	tfm.exec.setPlayerScore(player_name, -1, false)
end
--- TFM event eventNewPlayer
function eventNewPlayer(player_name)
	if pshy.banlist[player_name] then
        	pshy.BanRefreshPlayer(player_name)
        end
end
--- TFM event eventNewGame
function eventNewGame()
	for player_name, banned in pairs(pshy.banlist) do
        	pshy.BanRefreshPlayer(player_name)
        end
end
--- TFM event eventPlayerRespawn
function eventPlayerRespawn(player_name)
	if pshy.banlist[player_name] then
        	pshy.BanRefreshPlayer(player_name)
        end
end
--- TFM event eventChatCommand
-- Return false for banned players to hope that the command processing will be canceled.
function eventChatCommand(player_name, message)
        if pshy.banlist[player_name] then
        	return false
        end
end
--- Unban a player
function pshy.ChatCommandBanlist(user)
	local s = "PSHY ROOM BANS:\n"
	for player_name, banned in pairs(pshy.banlist) do
        	s = s .. player_name .. "\n"
        end
	ui.addPopup(1, 0, s, user, 0, 30, 200, true)
end
pshy.chat_commands["banlist"] = {func = pshy.ChatCommandBanlist, desc = "See the bans list.", argc_min = 0, argc_max = 0, arg_types = {}}
pshy.help_pages["pshy_anticheats"].commands["banlist"] = pshy.chat_commands["banlist"]
pshy.merge_ModuleEnd()
pshy.merge_ModuleBegin("pshy_antileve.lua")
--- pshy_antileve.lua
--
-- Allow the room admin to place leve traps.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @require pshy_ban.lua
-- @require pshy_help.lua
-- @require pshy_merge.lua
-- @require pshy_perms.lua
-- @require pshy_ui.lua
--- Module Help Page.
pshy.help_pages["pshy_anticheats"] = pshy.help_pages["pshy_anticheats"] or {back = "pshy", restricted = true, text = "", commands = {}, subpages = {}}
pshy.help_pages["pshy"].subpages["pshy_anticheats"] = pshy.help_pages["pshy_anticheats"]
pshy.help_pages["pshy_antileve"] = {back = "pshy", title = "AntiLeve", restricted = true, text = "This module allow you to place leve traps on any running map.\nPress the antileve key (F1 by default), then click once on the top of a vertical wall (but on the horizontal surface), then on the bottom edge of a wall to trap it. Try to aim for the edge, and be as accurate as possible.\nAll admins can use the key.\n", examples = {}}
pshy.help_pages["pshy_antileve"].commands = {}
pshy.help_pages["pshy_antileve"].examples["luaget pshy.antileve_key"] = "get the current key"
pshy.help_pages["pshy_antileve"].examples["luaget pshy.antileve_key"] = "set the key to TAB"
pshy.help_pages["pshy_antileve"].examples["!luaset pshy.antileve_trap_color 0xff0000"] = "traps you set will be visible"
pshy.help_pages["pshy_anticheats"].subpages["pshy_antileve"] = pshy.help_pages["pshy_antileve"]
--- Module settings.
pshy.antileve_key = 112			-- key to press to start making an antileve trap (121 -> `F10`)
pshy.antileve_arbitrary_ui_id = 69		-- id used for the inteface
pshy.antileve_arbitrary_ground_id = 380	-- first Id used for grounds
pshy.antileve_bad_keys = {}			-- set of player leve switch keys
pshy.antileve_bad_keys[9] = "TAB"
pshy.antileve_bad_keys[16] = "SHIFT"
pshy.antileve_trap_friction = 0.01		-- friction of leve traps
pshy.antileve_trap_angle = 1.2		-- angle of leve traps walls
pshy.antileve_trap_color = nil		-- angle of leve traps walls
--- Internal use.
pshy.antileve_active = false			-- is an antileve trap active this game (true after the first trap is set)
pshy.antileve_trap_setter = nil		-- admin currently setting the trap
pshy.antileve_trap_x1 = nil
pshy.antileve_trap_y1 = nil
pshy.antileve_trap_next_ground_id = pshy.antileve_arbitrary_ground_id
--- TFM event eventMouse
function eventMouse(player_name, x, y)
	if player_name == pshy.antileve_trap_setter then
		if not pshy.antileve_trap_x1 then
			pshy.antileve_trap_x1 = x
			pshy.antileve_trap_y1 = y
			tfm.exec.chatMessage("<j>[AntiLeve] Click at the bottom SIDE of the wall.</j>", player_name)
		else
			if math.abs(pshy.antileve_trap_x1 - x) < 32 then
				local new_h = math.abs(pshy.antileve_trap_y1 - y)
				if new_h > 40 then
					local new_x = (x < pshy.antileve_trap_x1) and (x + 4) or (x - 4)
					local new_y = (pshy.antileve_trap_y1 + y) / 2
					local new_angle = (x < pshy.antileve_trap_x1) and -pshy.antileve_trap_angle or pshy.antileve_trap_angle
					tfm.exec.addPhysicObject(pshy.antileve_trap_next_ground_id, new_x, new_y, {type = 12, width = 10, height = new_h, foreground = false, friction = pshy.antileve_trap_friction, restitution = 0.0, angle = new_angle, color = pshy.antileve_trap_color, miceCollision = true, groundCollision = false})
					pshy.antileve_active = true
					pshy.antileve_trap_next_ground_id = pshy.antileve_trap_next_ground_id + 1
					pshy.Log("<rose>[AntiLeve] Trap set!</rose>")
				else
					tfm.exec.chatMessage("<r>[AntiLeve] The surface is not tall enough.</r>", player_name)
				end
			else
				tfm.exec.chatMessage("[AntiLeve] You are not accurate enough.", player_name)
			end
			pshy.antileve_trap_setter = nil
			pshy.antileve_trap_x1 = nil
			pshy.antileve_trap_y1 = nil	
		end
	end
end
--- TFM event eventKeyboard
function eventKeyboard(player_name, key_code, down, x, y)
	-- start trap
	if key_code == pshy.antileve_key and pshy.admins[player_name] then
		if not pshy.antileve_trap_setter then
			pshy.antileve_trap_setter = player_name
			system.bindMouse(player_name, true)
			tfm.exec.chatMessage("<j>[AntiLeve] Click at the top of a wall to place the trap on.</j>", player_name)
		else
			tfm.exec.chatMessage("<r>[AntiLeve] A room admin is already setting the trap.</r>", player_name)
		end
	end
	-- list key trapped players
	if pshy.antileve_active and pshy.antileve_bad_keys[key_code] then
		--print("[AntiLeve] While trap active: " .. player_name .. " " .. pshy.antileve_bad_keys[key_code] .. " " .. (down and "down" or "up") .. "!")
		pshy.Log("[AntiLeve] While trap active: " .. player_name .. " " .. pshy.antileve_bad_keys[key_code] .. " " .. (down and "down" or "up") .. "!")
	end
end
--- TFM event eventNewGame
function eventNewGame()
	for admin, void in pairs(pshy.admins) do
		system.bindKeyboard(admin, pshy.antileve_key, true, true)
	end
	pshy.antileve_active = false
	pshy.antileve_trap_setter = nil
	pshy.antileve_trap_next_ground_id = pshy.antileve_arbitrary_ground_id
end
--- TFM event eventNewPlayer
function eventNewPlayer(player_name)	
	for key, void in pairs(pshy.antileve_bad_keys) do
		system.bindKeyboard(player_name, key, true, true)
		system.bindKeyboard(player_name, key, false, true)
	end
end
--- Initialization
system.bindKeyboard(pshy.host, pshy.antileve_key, true, true)	-- bind antileve key to the host
for player_name, void in pairs(tfm.get.room.playerList) do
	for key, void in pairs(pshy.antileve_bad_keys) do
		system.bindKeyboard(player_name, key, true, true)
		system.bindKeyboard(player_name, key, false, true)
	end
end
-- TMP
--tfm.exec.disableAutoShaman(true)
pshy.merge_ModuleEnd()
pshy.merge_ModuleBegin("pshy_antimacro.lua")
--- pshy_antimacro.lua
--
-- Penalize players pressing keys in a way that should not be humanly possible.
--
-- @author Pshy#3752
-- @namespace pshy
-- @require pshy_ban.lua
-- @require pshy_help.lua
-- @require pshy_merge.lua
pshy = pshy or {}
--- Module settings.
pshy.antimacro_keys = {}		-- map of keys -> display name
--pshy.antimacro_keys[0] = "[&lt;]"	-- Left
pshy.antimacro_keys[1] = "[^]"	-- Up
--pshy.antimacro_keys[2] = "[&gt;]"	-- Right
pshy.antimacro_kps_limit_1 = 12	-- Acceptable key count per second for "up" (prefer 12)
pshy.antimacro_kps_limit_2 = 16	-- Acceptable key count per second for "up" (prefer 16)
-- for a loop every 500 ms, 12 kps means pressed 6 times in half a second
--- Module's help page.
pshy.help_pages["pshy_anticheats"] = pshy.help_pages["pshy_anticheats"] or {back = "pshy", restricted = true, text = "", commands = {}, subpages = {}}
pshy.help_pages["pshy"].subpages["pshy_anticheats"] = pshy.help_pages["pshy_anticheats"]
pshy.help_pages["pshy_antimacro"] = {back = "pshy", title = "AntiMacro", restricted = true, text = "Penalize players pressing keys in a way that should not be humanly possible.\n", examples = {}}
pshy.help_pages["pshy_antimacro"].commands = {}
pshy.help_pages["pshy_antimacro"].examples["luaset pshy.antimacro_kps_limit_1 15"] = "Set the macro warning sensitivity."
pshy.help_pages["pshy_antimacro"].examples["luaset pshy.antimacro_kps_limit_2 15"] = "Set the macro freezing sensitivity."
pshy.help_pages["pshy_anticheats"].subpages["pshy_antimacro"] = pshy.help_pages["pshy_antimacro"]
--- Internal use.
pshy.antimacro_players_ups = {}	-- Count of "up"
pshy.antimacro_last_time = 0		-- last loop time in ms
pshy.antimacro_frozen_players = {}	-- set of frozen players
--- Setup the current script to watch a player for macros.
function pshy.AntimacroWatchPlayer(player_name)
	--for key, void in pairs(pshy.antimacro_keys) do
	--	system.bindKeyboard(player_name, key, true, true)
	--end
	system.bindKeyboard(player_name, 1, true, true)
	pshy.antimacro_players_ups[player_name] = 0
end
--- TFM event eventNewGame()
function eventNewgame()
	--for key, void in pairs(pshy.antimacro_keys) do
	--	pshy.antimacro_players_ups[player_name] = 0
	--end
	for player_name, void in pairs(tfm.get.room.playerList) do
		pshy.antimacro_players_ups[player_name] = 0
	end
	pshy.antimacro_last_time = 0
	for player_name, void in pairs(pshy.antimacro_frozen_players) do
		pshy.AntimacroWatchPlayer(player_name)
	end
	pshy.antimacro_frozen_players = {}
end
--- TFM event eventLoop
function eventLoop(time, time_remaining)
	local elapsed_time = time - pshy.antimacro_last_time	-- in ms
	for player_name, count in pairs(pshy.antimacro_players_ups) do
		if elapsed_time > 300 and elapsed_time < 700 then -- skip bad measures
			local rate = count / (elapsed_time / 1000.0) 	-- in k/s
			if not pshy.antimacro_frozen_players[player_name] then
				if rate > pshy.antimacro_kps_limit_2 and count > pshy.antimacro_kps_limit_2 / 2 then
					-- freeze
					tfm.exec.freezePlayer(player_name, true)
					pshy.antimacro_frozen_players[player_name] = true
					tfm.exec.chatMessage("<rose>[Macros]</rose> " .. player_name .. " Frozen because your key input is unlikely to be humanly possible :c", player_name)
					pshy.Log("<rose>[Macros]</rose> " .. player_name .. " Frozen (" .. tostring(rate) .. ")...", nil)
					system.bindKeyboard(player_name, 1, true, false)
				elseif rate > pshy.antimacro_kps_limit_1 then
					-- lag the player
					--tfm.exec.movePlayer(player_name, tfm.get.room.playerList[player_name].x, tfm.get.room.playerList[player_name].y, false, 0, 0, true)
					--tfm.exec.chatMessage("<rose>[Macros]</rose> " .. player_name .. " Hmmm...", player_name)
					pshy.Log("<rose>[Macros]</rose> " .. player_name .. " Hmmm (" .. tostring(rate) .. ")...", nil)
				end
			end
		end
		pshy.antimacro_players_ups[player_name] = 0
	end
	pshy.antimacro_last_time = time
end
--- TFM event eventKeyboard
function eventKeyboard(player_name, key_code, down, x, y)
	if key_code == 1 and down then -- [^]
		if pshy.antimacro_frozen_players[player_name] then
			return false
		end
		local ups = pshy.antimacro_players_ups[player_name]
		pshy.antimacro_players_ups[player_name] = ups + 1
	end
end
--- TFM event eventNewPlayer
function eventNewPlayer(player_name)
	pshy.AntimacroWatchPlayer(player_name)
end
--- Initialization.
for player_name, void in pairs(tfm.get.room.playerList) do
	pshy.AntimacroWatchPlayer(player_name)
end
pshy.merge_ModuleEnd()
pshy.merge_ModuleBegin("pshy_antihack.lua")
--- pshy_antihack.lua
--
-- Countermesures to common hacks:
--	- summoning while not a shaman
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
-- @require pshy_ban.lua
-- @require pshy_help.lua
-- @require pshy_merge.lua
pshy = pshy or {}
--- Module Help Page:
pshy.help_pages["pshy_anticheats"] = pshy.help_pages["pshy_anticheats"] or {back = "pshy", restricted = true, text = "", commands = {}, subpages = {}}
pshy.help_pages["pshy"].subpages["pshy_anticheats"] = pshy.help_pages["pshy_anticheats"]
pshy.help_pages["pshy_antihack"] = {back = "pshy", restricted = true, text = "Countermeasures to common hacks.\n", examples = {}}
pshy.help_pages["pshy_antihack"].commands = {}
pshy.help_pages["pshy_antihack"].title = "AntiHack"
pshy.help_pages["pshy_antihack"].examples["luaset pshy.antihack_autoban false"] = "disable autoban of hacks"
pshy.help_pages["pshy_antihack"].examples["luaset pshy.antihack_autoban true"] = "enable autoban of hacks"
pshy.help_pages["pshy_antihack"].examples["luaset pshy.antihack_delay 4"] = "wait 4 hacks before banning"
pshy.help_pages["pshy_anticheats"].subpages["pshy_antihack"] = pshy.help_pages["pshy_antihack"]
--- Module Settings:
pshy.antihack_autoban = true		-- ban detected hacks
pshy.antihack_delay = 8		-- count of hacks before banning (fake an unprotected room)
pshy.antihack_round_delay = 3000	-- time before some detections start
--- Internal Use:
pshy.antihack_hack_counter = {}
pshy.antihack_detection_started = false
pshy.antihack_just_died = {}
--- A player have hacked.
-- This bans the player if they hack too much.
function pshy.AntihackPlayerHacked(player_name)
	if not pshy.antihack_hack_counter[player_name] then
		pshy.antihack_hack_counter[player_name] = 0
	end
	if pshy.antihack_autoban and pshy.antihack_hack_counter[player_name] == pshy.antihack_delay then
		pshy.BanPlayer(player_name)
		pshy.Log("<r>[AntiHack] " .. player_name .. " room banned!</r>")
		return true
	end
	pshy.antihack_hack_counter[player_name] = pshy.antihack_hack_counter[player_name] + 1
	return false
end
--- TFM event eventNewGame
function eventNewGame()
	pshy.antihack_detection_started = false
end
--- TFM event eventPlayerDied
function eventPlayerDied(player_name)
	pshy.antihack_just_died[player_name] = true
end
--- TFM event eventLoop
function eventLoop(time, time_remaining)
	if not pshy.antihack_detection_started and time > pshy.antihack_round_delay then
		pshy.antihack_detection_started = true
	end
	pshy.antihack_just_died = {}
end
--- TFM event eventSummoningEnd
function eventSummoningEnd(player_name, object_type, x, y, angle, object_data)
	if not pshy.antihack_detection_started then
		return
	end
	if pshy.antihack_just_died[player_name] then
		-- bubbles
		return
	end
	local tfm_player = tfm.get.room.playerList[player_name]
	if not tfm_player.isShaman then
		pshy.Log("<r>[AntiHack] " .. player_name .. " summoned while not shaman (SummoningEnd, possible bug, sy==" .. tfm.exec.getPlayerSync() .. ")!</r>")
		--pshy.AntihackPlayerHacked(player_name)
	end
end
--- TFM event eventSummoningStart
function eventSummoningStart(player_name, object_type, x, y, angle)
	if not pshy.antihack_detection_started then
		return
	end
	local tfm_player = tfm.get.room.playerList[player_name]
	if not tfm_player.isShaman then
		pshy.Log("<r>[AntiHack] " .. player_name .. " possibly hacking (SummoningStart)!</r>")
		pshy.AntihackPlayerHacked(player_name)
	end
end
pshy.merge_ModuleEnd()
pshy.merge_ModuleBegin("pshy_antiguest.lua")
--- pshy_antiguest.lua
--
-- Antoban guests and new players from the room.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
-- @require pshy_ban.lua
-- @require pshy_help.lua
-- @require pshy_merge.lua
pshy = pshy or {}
--- Module Help Page:
pshy.help_pages["pshy_anticheats"] = pshy.help_pages["pshy_anticheats"] or {back = "pshy", restricted = true, text = "", commands = {}, subpages = {}}
pshy.help_pages["pshy"].subpages["pshy_anticheats"] = pshy.help_pages["pshy_anticheats"]
pshy.help_pages["pshy_antiguest"] = {back = "pshy", title = "AntiGuest", text = "Prevent guests and new accounts from joining.\n", examples = {}}
pshy.help_pages["pshy_antiguest"].commands = {}
pshy.help_pages["pshy_antiguest"].examples["luaset pshy.antiguest_required_days -1"] = "allow guests and new accounts"
pshy.help_pages["pshy_antiguest"].examples["luaset pshy.antiguest_required_days 0"] = "disallow guests but allow new accounts"
pshy.help_pages["pshy_antiguest"].examples["luaset pshy.antiguest_required_days 5"] = "disallow guests and accounts of less than 5 days"
pshy.help_pages["pshy_anticheats"].subpages["pshy_antiguest"] = pshy.help_pages["pshy_antiguest"]
--- Module Settings:
pshy.antiguest_required_days = 5		-- required play time, or 0 to only prevent guests from joining, or -1 to disable
--- Internal use:
pshy.antiguest_start_time = os.time()
pshy.antiguest_banlist = {}
--- Get an account age in days
function pshy.AntiguestGetAccountAge(player_name)
	local account_age_ms = pshy.antiguest_start_time - tfm_player.registrationDate
	local account_age_days = (((account_age_ms / 1000) / 60) / 60) / 24
	return (account_age_days)
end
--- Check a possible guest player and ban him if necessary.
function pshy.AntiguestCheckPlayer(player_name)
	if pshy.banlist[player_name] then
		return
	end
	tfm_player = tfm.get.room.playerList[player_name]
	if pshy.antiguest_required_days >= 0 and string.sub(player_name, 1, 1) == "*" then
		pshy.BanPlayer(player_name)
		pshy.antiguest_banlist[player_name] = true
		tfm.exec.chatMessage("<r>[AntiGuest] Sorry, this room is set to deny guest accounts :c</r>", player_name)
		tfm.exec.chatMessage("<r>[AntiGuest] Accounts created after this module was loaded may not be accepted either.</r>", player_name)
		print("[AntiGuest] " .. player_name .. " room banned (guest account)!")
		return
	end
	local account_age_days = pshy.AntiguestGetAccountAge(player_name)
	if account_age_days < pshy.antiguest_required_days then
		pshy.BanPlayer(player_name)
		pshy.antiguest_banlist[player_name] = true
		tfm.exec.chatMessage("<r>[AntiGuest] Sorry, this room is set to deny accounts of less than " .. tostring(pshy.antiguest_required_days) .. " days :c</r>", player_name)
		print("[AntiGuest] " .. player_name .. " room banned (" .. tostring(account_age_days) .. " days account)!")
		return
	end
end
--- TFM event eventNewPlayer 
function eventNewPlayer(player_name)
	pshy.AntiguestCheckPlayer(player_name)
end
--- TFM event eventPlayerLeft(player_name)
-- unban blocked guests who leave
function eventPlayerLeft(player_name)
	if pshy.antiguest_banlist[player_name] then
		pshy.UnbanPlayer(player_name)
		pshy.antiguest_banlist[player_name] = nil
	end
end
--- Initialization:
for player_name, player in pairs(tfm.get.room.playerList) do
	pshy.AntiguestCheckPlayer(player_name)
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
	tfm.exec.chatMessage(pshy.motd, user)
end
pshy.chat_commands["motd"] = {func = pshy.ChatCommandMotd, desc = "See the current motd.", argc_min = 0, argc_max = 0, arg_types = {}}
pshy.perms.everyone["!motd"] = true
pshy.help_pages["pshy_motd"].commands["motd"] = pshy.chat_commands["motd"]
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
function eventNewPlayer(playerName)
	if pshy.motd then
		tfm.exec.chatMessage(pshy.motd, playerName)
	end
end
--- TFM event eventChatMessage
function eventChatMessage(playerName, message)
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
-- @require pshy_ui.lua
-- @require pshy_utils.lua
-- @namespace Pshy
pshy = pshy or {}
--- Module settings:
pshy.nick_size_min = 2		-- Minimum nick size
pshy.nick_size_max = 24	-- Maximum nick size
pshy.nick_char_set = "[^%w_ ]" -- Chars not allowed in a nick (using the lua match function)
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
--- TFM event eventPlayerLeft
-- @brief deleted cause players keep names on rejoin
--function eventPlayerLeft(playerName)
--    pshy.nicks[playerName] = nil
--    pshy.nick_requests[playerName] = nil
--end
--- Debug Initialization
--pshy.nick_requests["User1#0000"] = "john shepard"
--pshy.nick_requests["Troll2#0000"] = "prout camembert"
pshy.merge_ModuleBegin("pshy_rotations.lua")
--- pshy_rotations.lua
--
-- This module allow to customize the maps rotation.
-- For antileve, see the pshy_anticheat.lua module.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @namespace pshy
-- @require pshy_commands.lua
-- @require pshy_utils.lua
-- @require pshy_help.lua
--- Module Help Page:
pshy.help_pages["pshy_rotations"] = {back = "pshy", title = "Rotations", text = "This module allows to control the way maps rotate.\nIncludes burla maps from <ch>Ctmce#0000</ch>\nIncludes troll maps from <ch>Nnaaaz#0000</ch>\n", examples = {}, commands = {}}
--pshy.help_pages["pshy_rotations"].examples["luaset pshy.rotations_alive_shorting_player_count 3"] = "Short the timer when only 3 players are alive."
--pshy.help_pages["pshy_rotations"].examples["luaset pshy.rotations_alive_shorting_time 5"] = "Set the time remaining after a few players are alive to 5 seconds."
--pshy.help_pages["pshy_rotations"].examples["luaset pshy.rotations_win_shorting_player_count 3"] = "Short the timer when 3 players won."
--pshy.help_pages["pshy_rotations"].examples["luaset pshy.rotations_win_shorting_time 10"] = "Set the time remaining after a few players won to 10 seconds."
pshy.help_pages["pshy"].subpages["pshy_rotations"] = pshy.help_pages["pshy_rotations"]
--- Module Settings:
-- Map rotations consist of the given fields:
--	maps			- list of randomly selected maps
--	duration		- duration of each game
--	weight 		- integer representing the default frequency of the rotation
--	chance 		- 0, change at runtime, used to choose the next map
--	hidden 		- if true, will not show in the interface
--	map_replace_func	- function that will be called with the map name and should return a replacement
pshy.rotations	= {}					-- map of rotations
pshy.rotations["standard"]			= {hidden = true, desc = "P0", duration = 120, weight = 0, maps = {"#0"}, chance = 0}
pshy.rotations["protected"]			= {hidden = true, desc = "P1", duration = 120, weight = 0, maps = {"#1"}, chance = 0}
pshy.rotations["mechanisms"]			= {hidden = true, desc = "P6", duration = 120, weight = 0, maps = {"#6"}, chance = 0}
pshy.rotations["nosham"]			= {desc = "P7", duration = 60, weight = 0, maps = {"#7"}, chance = 0}
pshy.rotations["nosham_troll"]		= {hidden = true, desc = "Nnaaaz#0000", duration = 60, weight = 0, maps = {"@7781189", "@7781560", "@7782831", "@7783745", "@7787472", "@7814117", "@7814126", "@7814248", "@7814488", "@7817779"}, chance = 0}
pshy.rotations["racing"]			= {desc = "P17", duration = 60, weight = 1, maps = {"#17"}, chance = 0}
pshy.rotations["racing_troll"]		= {hidden = true, desc = "Nnaaaz#0000", duration = 60, weight = 0, maps = {"@7781575", "@7783458", "@7783472", "@7784221", "@7784236", "@7786652", "@7786707", "@7786960", "@7787034", "@7788567", "@7788596", "@7788673", "@7788967", "@7788985", "@7788990", "@7789010", "@7789484", "@7789524", "@7790734", "@7790746", "@7790938", "@7791293", "@7791550", "@7791709", "@7791865", "@7791877", "@7792434", "@7765843", "@7794331", "@7794726", "@7792626", "@7794874", "@7795585", "@7796272", "@7799753", "@7800330", "@7800998", "@7801670", "@7805437", "@7792149", "@7809901", "@7809905", "@7810816", "@7812751", "@7789538", "@7813075", "@7813248", "@7814099", "@7819315", "@7815695", "@7815703", "@7816583", "@7816748", "@7817111", "@7782820"}, chance = 0}
pshy.rotations["defilante"]			= {desc = "P18", duration = 60, weight = 0, maps = {"#18"}, chance = 0}
pshy.rotations["vanilla"]			= {hidden = true, desc = "1-210", duration = 120, weight = 0, maps = {}, chance = 0} for i = 0, 210 do table.insert(pshy.rotations["vanilla"].maps, i) end
pshy.rotations["nosham_vanilla_troll"]	= {hidden = true, desc = "Nnaaaz#0000", duration = 60, weight = 0, maps = {"@7801848", "@7801850", "@7802588", "@7802592", "@7803100", "@7803618", "@7803013", "@7803900", "@7804144", "@7804211"}, chance = 0} -- https://atelier801.com/topic?f=6&t=892706&p=1
pshy.rotations["nosham_vanilla"]		= {desc = "1-210*", duration = 60, weight = 1, maps = {"2", "8", "11", "12", "14", "19", "22", "24", "26", "27", "28", "30", "31", "33", "40", "41", "44", "45", "49", "52", "53", "55", "57", "58", "59", "61", "62", "65", "67", "69", "70", "71", "73", "74", "79", "80", "85", "86", "89", "92", "96", "100", "117", "119", "120", "121", "123", "126", "127", "138", "142", "145", "148", "149", "150", "172", "173", "174", "175", "176", "185", "189"}, chance = 0}
pshy.rotations["nosham_mechanisms"]		= {desc = nil, duration = 60, weight = 0, maps = {"@1749725", "@176936", "@3514715", "@3150249", "@3506224", "@2030030", "@479001", "@3537313", "@1709809", "@169959", "@313281", "@2868361", "@73039", "@73039", "@2913703", "@2789826", "@298802", "@357666", "@1472765", "@271283", "@3702177", "@2355739", "@4652835", "@164404", "@7273005", "@3061566", "@3199177", "@157312", "@7021280", "@2093284", "@5752223", "@7070948", "@3146116", "@3613020", "@1641262", "@119884", "@3729243", "@1371302", "@6854109", "@2964944", "@3164949", "@149476", "@155262", "@6196297", "@1789012", "@422271", "@3369351", "@3138985", "@3056261", "@5848606", "@931943", "@181693", "@227600", "@2036283", "@6556301", "@3617986", "@314416", "@3495556", "@3112905", "@1953614", "@2469648", "@3493176", "@1009321", "@221535", "@2377177", "@6850246", "@5761423", "@211171", "@1746400", "@1378678", "@246966", "@2008933", "@2085784", "@627958", "@1268022", "@2815209", "@1299248", "@6883670", "@3495694", "@4678821", "@2758715", "@1849769", "@3155991", "@6555713", "@3477737", "@873175", "@141224", "@2167410", "@2629289", "@2888435", "@812822", "@4114065", "@2256415", "@3051008", "@7300333", "@158813", "@3912665", "@6014154", "@163756", "@3446092", "@509879", "@2029308", "@5546337", "@1310605", "@1345662", "@2421802", "@2578335", "@2999901", "@6205570", "@7242798", "@756418", "@2160073", "@3671421", "@5704703", "@3088801", "@7092575", "@3666756", "@3345115", "@1483745", "@3666745", "@2074413", "@2912220", "@3299750"}, chance = 0}
pshy.rotations["burlas"]			= {desc = "Ctmce#0000", duration = 60, weight = 0, maps = {"@7652017" , "@7652019" , "@7652033" , "@7652664" , "@5932565" , "@7652667" , "@7652670" , "@7652674" , "@7652679" , "@7652686" , "@7652691" , "@7652790" , "@7652791" , "@7652792" , "@7652793" , "@7652796" , "@7652797" , "@7652798" , "@7652944" , "@7652954" , "@7652958" , "@7652960" , "@7007413" , "@7653108" , "@7653124" , "@7653127" , "@7653135" , "@7653136" , "@7653139" , "@7653142" , "@7653144" , "@7653149" , "@7653151" , "@7420052" , "@7426198" , "@7426611" , "@7387658" , "@7654229" , "@7203871" , "@7014223" , "@7175013" , "@7165042" , "@7154662" , "@6889690" , "@6933442" , "@7002430" , "@6884221" , "@6886514" , "@6882315" , "@6927305" , "@7659190" , "@7659197" , "@7659203" , "@7659205" , "@7659208" , "@7660110" , "@7660117" , "@7660104" , "@7660502" , "@7660703" , "@7660704" , "@7660705" , "@7660706" , "@7660709" , "@7660710" , "@7660714" , "@7660716" , "@7660718" , "@7660721" , "@7660723" , "@7660727" , "@7661057" , "@7661060" , "@7661062" , "@7661063" , "@7661067" , "@7661072" , "@7662547" , "@7662555" , "@7662559" , "@7662562" , "@7662565" , "@7662566" , "@7662569" , "@7662759" , "@7662768" , "@7662777" , "@7662780" , "@7662796" , "@7663423" , "@7663428" , "@7663429" , "@7663430" , "@7663432" , "@7663435" , "@7663437" , "@7663438" , "@7663439" , "@7663440" , "@7663444" , "@7663445"}, chance = 0}
pshy.rotations["nosham_simple"]		= {desc = nil, duration = 120, weight = 0, maps = {"@1616913", "@383202", "@2711646", "@446656", "@815716", "@333501", "@7067867", "@973782", "@763961", "@7833293", "@7833270", "@7833269", "@7815665", "@7815151", "@7833288", "@1482492", "@1301712", "@6714567", "@834490", "@712905", "@602906", "@381669", "@4147040", "@564413", "@504951", "@1345805", "@501364"}, chance = 0} -- soso @1356823 @2048879 @2452915 @2751980
--pshy.rotations["NOSHAM_TRAPS"]		= {desc = nil, duration = 120, weight = 0, maps = {"@5940448", "@2080757", "@7453256", "@203292", "@108937", "@445078", "@133916", "@7840661", "@115767", "@2918927", "@4684884", "@2868361", "@192144", "@73039", "@1836340", "@726048"}, chance = 0} -- sham: @171290 @453115
--pshy.rotations["NOSHAM_COOP"]		= {desc = "vanilla", duration = 120, weight = 0, maps = {"@169909", "@209567", "@273077", "@7485555", "@2618581", "@133916", "@144888", "@1991022", "@7247621", "@3591685", "@6437833", "@3381659", "@121043", "@180468", "@220037", "@882270", "@3265446"}, chance = 0}
-- vanillart? @3624983 @2958393 @624650 @635128 @510084
-- coop ?:		@1327222 @161177 @3147926 @3325842
-- troll traps:	@75050
pshy.rotations_randomness = 0.5			-- randomness of the rotations selection ([0.0-1.0[)
pshy.rotations_auto_next_map = true			-- change map at the end of timer
pshy.rotations_win_shorting_player_count = 1		-- amount of players who need to win for the timer to be shorted
pshy.rotations_win_shorting_time = 5			-- time
pshy.rotations_alive_shorting_player_count = 0	-- amount of players who need to remain alive for the timer to be shorted
pshy.rotations_alive_shorting_time = 3		-- time
--- Module state (internal use)
pshy.rotations_a_player_recently_died = false
pshy.rotations_current_map_win_count = 0
pshy.rotations_skip_requested = false			-- set by !skip
pshy.rotations_next_map_name = nil			-- set by !next <map_name> (can be a rotation name as well)
pshy.rotations_current = nil				-- represent the current rotation, set before changing
--- Get Total map's probability weight
function pshy.RotationsTotalWeight()
	local total = 0
	for rot_name, rot in pairs(pshy.rotations) do
		total = total + rot.weight
	end
	return total
end
--- Pop a map in a rotation
-- @param rotation Rotation table or name.
function pshy.RotationsPopRotationMap(rotation)
	rotation = (type(rotation) == "string") and pshy.rotations[rotation] or rotation
	assert(type(rotation) == "table")
	-- reset rotation next map candidates if needed
	if not rotation.next_maps or #rotation.next_maps == 0 then
		rotation.next_maps = {}
		for i_map, map_name in ipairs(rotation.maps) do
			table.insert(rotation.next_maps, map_name)
		end
	end
	-- random map from rotation
	local i_map = math.random(1, #rotation.next_maps)
	local next_map = rotation.next_maps[i_map]
	if rotation.map_replace_func then
		next_map = rotation.map_replace_func(next_map)
	end
	table.remove(rotation.next_maps, i_map)
	return next_map
end
--- Start the next map.
-- This take the current rotation settings into account.
function pshy.RotationNext(next_map)
	local next_rotation = nil
	local total_weight = pshy.RotationsTotalWeight()
	if next_map then
		pshy.rotations_next_map_name = next_map
	end
	-- choose rotation and map
	if pshy.rotations[pshy.rotations_next_map_name] then
		-- enforced rotation
		next_rotation = pshy.rotations[pshy.rotations_next_map_name]
	elseif pshy.rotations_next_map_name then
		-- enforced map
		if string.sub(pshy.rotations_next_map_name, 1, 1) == "@" then
			pshy.rotations_next_map_name = string.sub(pshy.rotations_next_map_name, 2, #pshy.rotations_next_map_name)
		end
		pshy.rotations_current = nil
		tfm.exec.newGame(pshy.rotations_next_map_name, nil)
		pshy.rotations_next_map_name = nil
		return
	else
		-- random rotation
		for rot_name, rot in pairs(pshy.rotations) do
			if rot.weight > 0 then
				rot.random_chance = rot.chance + math.random(-total_weight, total_weight) * pshy.rotations_randomness -- randomize next rotation a little
				if not next_rotation or rot.random_chance > next_rotation.random_chance then
					next_rotation = rot
				end
			end
		end
		-- update rotation chances
		for rot_name, rot in pairs(pshy.rotations) do
			rot.chance = rot.chance + rot.weight
		end
	end
	if not next_rotation then
		tfm.exec.newGame()
		return	
	end
	next_rotation.chance = 0 + (next_rotation.chance - total_weight) * 0.9
	pshy.rotations_current = next_rotation
	-- get a map from the rotation
	local next_map = pshy.RotationsPopRotationMap(next_rotation)
	tfm.exec.newGame(next_map)
end
--- TFM event eventLoop
function eventLoop(current_time, time_remaining)
	-- check players alive
	if pshy.rotations_a_player_recently_died then
		pshy.rotations_a_player_recently_died = false
		if pshy.CountPlayersAlive() <= pshy.rotations_alive_shorting_player_count then
			tfm.exec.setGameTime(pshy.rotations_alive_shorting_time, false)
		end
	end
	-- skip checks the first 3 seconds
	if current_time <= 3500 then
		return
	end
	-- next map request
	if pshy.rotations_skip_requested then
		pshy.RotationNext()
	end
	-- check timer end
	if pshy.rotations_auto_next_map and time_remaining <= 0 then
		pshy.RotationNext()
	end
end
--- TFM event eventPlayerDied
function eventPlayerDied(player_name)
	pshy.rotations_a_player_recently_died = true
end
--- TFM event eventPlayerWon
function eventPlayerWon(player_name)
	pshy.rotations_current_map_win_count = pshy.rotations_current_map_win_count + 1
	if pshy.rotations_win_shorting_player_count >= 0 and pshy.rotations_current_map_win_count >= pshy.rotations_win_shorting_player_count then
		tfm.exec.setGameTime(pshy.rotations_win_shorting_time, false)
	end
end
--- TFM event eventNewGame
function eventNewGame()
	pshy.rotations_a_player_recently_died = false
	pshy.rotations_current_map_win_count = 0
	pshy.rotations_skip_requested = false
	pshy.rotations_next_map_name = nil
	if pshy.rotations_current then
		tfm.exec.setGameTime(pshy.rotations_current.duration, false)
	end
end
--- !rotationweight <rot> <weight>
function pshy.ChatCommandRotationweight(user, rot_name, weight)
	assert(type(rot_name) == "string")
	assert(type(weight) == "number")
	local rotation = pshy.rotations[rot_name]
	if not rotation then
		error("Invalid rotation.")
	end
	rotation.weight = weight
	--tfm.exec.chatMessage(rot_name .. "'s weight set to " .. weight, user)
end
pshy.chat_commands["rotationweight"] = {func = pshy.ChatCommandRotationweight, desc = "Set the frequency weight of a rotation.", argc_min = 2, argc_max = 2, arg_types = {"string", "number"}}
pshy.chat_command_aliases["rotw"] = "rotationweight"
pshy.help_pages["pshy_rotations"].commands["rotw"] = pshy.chat_commands["rotationweight"]
--- !rotations
function pshy.ChatCommandRotations(user, visible)
	arbitrary_id = 78
	-- close
	if visible == false then
		ui.removeTextArea(arbitrary_id, nil)
		return
	end
	-- count total weight
	local total_weight = 0
	for i_rot, rot in pairs(pshy.rotations) do
		total_weight = total_weight + rot.weight
	end
	-- html
	local html = "<b><p align='center'>ROTATIONS</p><font size='12'>"
	for i_rot, rot in pairs(pshy.rotations) do
		if not rot.hidden then
			-- buttons
			html = html .. "<font size='18'>"
			if rot.weight > 0 then
				html = html .. "<a href='event:apcmd rotw " .. i_rot .. " " .. tostring(rot.weight - 1) .. "\napcmd rots'><r> - </r></a>"
			else
				html = html .. "<g> - </g>"
			end
			html = html .. "<a href='event:apcmd rotw " .. i_rot .. " " .. tostring(rot.weight + 1) .. "\napcmd rots'><vp>+ </vp></a>"
			html = html .. "</font>"
			-- name/desc
			html = html .. "\t" .. ((rot.weight > 0) and "<vp>" or "<bl>") .. "" .. i_rot .. (rot.desc and (" (" .. rot.desc .. ")") or "")
			html = html .. ((rot.weight > 0) and "</vp>" or "</bl>")
			if rot.weight > 0 then
				html = html .. "    " .. tostring(math.floor(rot.weight * 100 / total_weight)) .. "% "
			end
			html = html .. "\n"
		end
	end
	html = html .. "</font><p align='right'><a href='event:closeall'>[close]</a></p></b>"
	local ui = pshy.UICreate(html)
	ui.id = arbitrary_id
	ui.x = 20
	ui.y = 60
	ui.w = 240
	ui.h = nil
	ui.border_color = 0xffffff
	ui.back_color = 0x003311
	ui.alpha = 0.6
	pshy.UIShow(ui, nil)
end
pshy.chat_commands["rotations"] = {func = pshy.ChatCommandRotations, desc = "Show the rotations interface ('false' to hide).", argc_min = 0, argc_max = 1, arg_types = {"boolean"}}
pshy.chat_command_aliases["rots"] = "rotations"
pshy.help_pages["pshy_rotations"].commands["rots"] = pshy.chat_commands["rotations"]
--- !skip [map]
function pshy.RotationsSkipMap(map)
	if map then
		pshy.rotations_next_map_name = map
	end
	pshy.rotations_skip_requested = true
end
pshy.chat_commands["skip"] = {func = pshy.RotationsSkipMap, desc = "Skip the current map.", no_user = true, argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.chat_command_aliases["np"] = "skip"
pshy.help_pages["pshy_rotations"].commands["skip"] = pshy.chat_commands["skip"]
--- !next <map>
function pshy.RotationsNextMap(map)
	pshy.rotations_next_map_name = map
end
pshy.chat_commands["next"] = {func = pshy.RotationsNextMap, desc = "Set the next map or rotation.", no_user = true, argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.chat_command_aliases["npp"] = "next"
pshy.help_pages["pshy_rotations"].commands["next"] = pshy.chat_commands["next"]
--- Initialization
tfm.exec.disableAutoTimeLeft(true)
tfm.exec.disableAutoNewGame(true)
pshy.merge_ModuleEnd()
pshy.merge_ModuleHard("pshy_anticheats.lua")
--- pshy_anticheats.lua
--
-- Modulepack containing all pshy's anticheat modules.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
-- @hardmerge
-- @namespace pshy
-- @require pshy_ban.lua
-- @require pshy_antileve.lua
-- @require pshy_antimacro.lua
-- @require pshy_antihack.lua
-- @require pshy_antiguest.lua
--- Module Help Page:
-- All anticheats use this page.
pshy.help_pages["pshy_anticheats"] = pshy.help_pages["pshy_anticheats"] or {text = "", commands = {}, subpages = {}}
pshy.help_pages["pshy_anticheats"].restricted = true
pshy.help_pages["pshy_anticheats"].back = "pshy"
pshy.help_pages["pshy_anticheats"].title = "Anticheats"
pshy.help_pages["pshy_anticheats"].text = "Gather anticheat features.\n" .. pshy.help_pages["pshy_anticheats"].text
pshy.help_pages["pshy"].subpages["pshy_anticheats"] = pshy.help_pages["pshy_anticheats"]
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
pshy.merge_ModuleBegin("pshy_teams.lua")
--- pshy_teams.lua
--
-- Implement team features.
--
-- @author pshy
-- @require pshy_scores.lua
-- @require pshy_help.lua
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
pshy.teams_win_map = "teams_win" 			-- win map
--- Active teams map.
-- Key is the team name.
--	name					- display name of the team
--	player_names				- set of player names
--	color					- hexadecimal string
--	score					- number
pshy.teams = {}
pshy.teams_players_team = {}			-- map of player name -> team reference in wich they are
pshy.teams_winner_name = nil			-- becomes the winning team name (indicates that the next round should be for the winner)
pshy.teams_have_played_winner_round = false	-- indicates that the round for the winner has already started
--- pshy event eventTeamWon(team_name)
function eventTeamWon(team_name)
	pshy.teams_winner_name = team_name
	local team = pshy.teams[team_name]
	tfm.exec.setGameTime(8, true)
	pshy.Title("<br><font size='64'><b><p align='center'>Team <font color='#" .. team.color .. "'>" .. team_name .. "</font> wins!</p></b></font>")
	pshy.teams_have_played_winner_round = false
	pshy.RotationsNextMap(pshy.teams_win_map)
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
pshy.rotations["teams_win"] = {desc = "", hidden = true, weight = 0, maps = {}, chance = 0, map_replace_func = pshy.TeamsReplaceRedToWinningColor}
table.insert(pshy.rotations["teams_win"].maps, [[<C><P Ca="" mc="" /><Z><S><S X="100" o="0" L="150" Y="320" c="3" H="30" P="1,0,0.3,0.2,0,0,0,0" T="12" /><S X="0" o="ff0000" L="300" Y="400" H="300" P="0,0,0.3,0.2,45,0,0,0" T="12" /><S X="700" o="0" L="150" Y="320" c="3" H="30" P="1,0,0.3,0.2,0,0,0,0" T="12" /><S X="-20" L="20" Y="-400" H="1600" P="0,0,0.3,0,0,0,0,0" T="19" /><S X="820" L="20" Y="-400" H="1600" P="0,0,0.3,0,0,0,0,0" T="19" /><S X="800" o="ff0000" L="300" Y="400" H="300" P="0,0,0.3,0.2,45,0,0,0" T="12" /><S X="400" o="0" L="200" Y="250" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /><S X="400" o="ff0000" L="100" Y="100" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /></S><D><DC X="400" Y="82" /><DS X="400" Y="229" /></D><O><O C="13" X="700" P="0" Y="320" /><O C="12" X="100" P="0" Y="320" /></O></Z></C>]])
table.insert(pshy.rotations["teams_win"].maps, [[<C><P Ca="" mc="" /><Z><S><S X="530" o="0" L="150" Y="330" c="3" H="30" P="1,0,0.3,0.2,0,0,0,0" T="12" /><S X="270" o="0" L="150" Y="330" c="3" H="30" P="1,0,0.3,0.2,0,0,0,0" T="12" /><S X="-20" L="20" Y="-400" H="1600" P="0,0,0.3,0,0,0,0,0" T="19" /><S X="820" L="20" Y="-400" H="1600" P="0,0,0.3,0,0,0,0,0" T="19" /><S X="400" o="ff0000" L="300" Y="400" H="300" P="0,0,0.3,0.2,0,0,0,0" T="12" /><S X="400" o="ff0000" L="100" Y="100" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /><S X="80" o="0" L="150" Y="190" c="3" H="20" P="0,0,0.3,0.2,10,0,0,0" T="12" /><S X="720" o="0" L="150" Y="190" c="3" H="20" P="0,0,0.3,0.2,-10,0,0,0" T="12" /></S><D><DC X="400" Y="85" /><DS X="400" Y="245" /></D><O><O C="13" X="270" P="0" Y="330" /><O C="12" X="530" P="0" Y="330" /></O></Z></C>]])
table.insert(pshy.rotations["teams_win"].maps, [[<C><P Ca="" mc="" /><Z><S><S X="250" o="0" L="150" Y="300" c="3" H="30" P="1,0,0.3,0.2,0,0,0,0" T="12" /><S X="-20" L="20" Y="-400" H="1600" P="0,0,0.3,0,0,0,0,0" T="19" /><S X="540" o="0" L="150" Y="300" c="3" H="30" P="1,0,0.3,0.2,0,0,0,0" T="12" /><S X="820" L="20" Y="-400" H="1600" P="0,0,0.3,0,0,0,0,0" T="19" /><S X="690" o="ff0000" L="300" Y="400" H="300" P="0,0,0.3,0.2,-10,0,0,0" T="12" /><S X="700" o="0" L="100" Y="100" c="3" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /><S X="110" o="ff0000" L="300" Y="400" H="300" P="0,0,0.3,0.2,10,0,0,0" T="12" /><S X="100" o="0" L="100" Y="100" c="3" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /><S X="400" o="ff0000" L="150" Y="150" c="1" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /></S><D><DC X="700" Y="85" /><DS X="100" Y="85" /></D><O><O C="13" X="540" P="0" Y="300" /><O C="12" X="260" P="0" Y="300" /></O></Z></C>]])
table.insert(pshy.rotations["teams_win"].maps, [[<C><P Ca="" mc="" /><Z><S><S X="-20" L="20" Y="-400" H="1600" P="0,0,0.3,0,0,0,0,0" T="19" /><S X="820" L="20" Y="-400" H="1600" P="0,0,0.3,0,0,0,0,0" T="19" /><S X="820" o="ff0000" L="100" Y="240" H="300" P="0,0,0.3,0.2,10,0,0,0" T="12" /><S X="400" o="0" L="100" Y="100" c="3" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /><S X="-20" o="ff0000" L="100" Y="240" H="300" P="0,0,0.3,0.2,-10,0,0,0" T="12" /><S X="400" o="0" L="150" Y="200" c="3" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /><S X="620" o="ff0000" L="150" Y="250" c="1" H="30" P="1,0,0.3,0.2,0,0,0,0" T="12" /><S X="400" o="0" L="200" Y="300" c="3" H="20" P="0,0,0.3,0.2,0,0,0,0" T="12" /><S X="180" o="ff0000" L="150" Y="250" c="1" H="30" P="1,0,0.3,0.2,0,0,0,0" T="12" /></S><D><DC X="400" Y="190" /><DS X="400" Y="85" /></D><O><O C="12" X="620" P="0" Y="250" /><O C="13" X="180" P="0" Y="250" /></O></Z></C>]])
--table.insert(pshy.rotations["teams_win"].maps, [[]])
pshy.TeamsReset(4)
pshy.TeamsShuffle()
pshy.TeamsUpdateScoreboard()
pshy.merge_ModuleEnd()
pshy.merge_ModuleHard("modulepack_pshyvs.lua")
--- modulepack_pshyvs.lua
--
-- This file builds the pshyvs modulepack.
--
-- @author pshy
-- @hardmerge
-- @require pshy_merge.lua
-- @require pshy_perms.lua
-- @require pshy_commands.lua
-- @require pshy_lua_commands.lua
-- @require pshy_fcplatform.lua
-- @require pshy_weather.lua
-- @require pshy_basic_weathers.lua
-- @require pshy_motd.lua
-- @require pshy_ui.lua
-- @require pshy_nicks.lua
-- @require pshy_rotations.lua
-- @require pshy_anticheats.lua
-- @require pshy_scores.lua
-- @require pshy_emoticons.lua
-- @require pshy_teams.lua
--- Perms:
pshy.perms.everyone["!nick"] = nil
--- TFM setup:
tfm.exec.disableWatchCommand(false)
tfm.exec.disableDebugCommand(true)
tfm.exec.disableMinimalistMode(false)
tfm.exec.disablePhysicalConsumables(true)
system.disableChatCommandDisplay(nil, true)
tfm.exec.disableAutoShaman(true)
--tfm.exec.disablePrespawnPreview(false)
pshy.merge_Finish()

