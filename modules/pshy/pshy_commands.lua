--- pshy_commands.lua
--
-- This module can be used to implement in-game commands.
--
-- To give an idea of what this module makes possible, these commands could be valid:
-- "!explosion tfm.get.room.playerList.Pshy#3752.x tfm.get.room.playerList.Pshy#3752.y 10 10 true"
-- "!addShamanObject littleBox 200 300 0 0 0 false"
-- "!addShamanObject ball tfm.get.room.playerList.Pshy#3752.x tfm.get.room.playerList.Pshy#3752.y 0 0 0 false"
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
pshy.chat_commands = {}



--- Map of command aliases (string -> string)
pshy.chat_command_aliases = {}



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
		status, retval = pcall(command.func, user, pshy.Unpack(args))
	else
		status, retval = pcall(command.func, pshy.Unpack(args))
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



--- TFM event for chat commands.
function eventChatCommand(playerName, message)
	return pshy.RunChatCommand(playerName, message)
end
