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
--   pshy.commands["demo"].restricted = true					-- hide this command from non admins, even with `!commands`
--   pshy.commands["demo"].no_user = false						-- true to not pass the command user as the 1st arg
--   pshy.commands["demo"].argc_min = 1							-- need at least 1 arg	
--   pshy.commands["demo"].argc_max = 2							-- max args (remaining args will be considered a single one)
--   pshy.commands["demo"].arg_types = {"number", "string"}		-- argument type as a string, nil for auto, a table to use as an enum, or a function to use for the conversion
--   pshy.commands["demo"].arg_names = {"index", "message"}		-- argument names
--   pshy.commands_aliases["ddeemmoo"] = "demo"					-- create an alias
--   pshy.perms.everyone["!demo"] = true							-- everyone can run the command
--   pshy.perms.cheats["!demo"] = true							-- everyone can run the command when cheats are enabled (useless in this example)
--   pshy.perms.admins["!demo"] = true							-- admins can run the command (useless in this example)
--
-- This submodule add the folowing commands:
--   !help [command]				- show general or command help
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_dialog.lua
-- @require pshy_utils_lua.lua
-- @require pshy_utils_tfm.lua
-- @require pshy_merge.lua
-- @require pshy_perms.lua
--
-- @require_priority UTILS
pshy = pshy or {}



--- Module Settings:
pshy.commands_require_prefix = false		-- if true, all commands must start with `!pshy.`
pshy.commands_always_enable_ui = true



--- Internal Use:
local ignore_next_command = false

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
pshy.commands = pshy.commands or {}
pshy.commands_names_ordered = {}



--- Map of command aliases (string -> string)
pshy.commands_aliases = pshy.commands_aliases or {}



--- Get a command target player or throw on permission issue.
-- This function can be used to check if a player can run a command on another one.
-- @private
function pshy.commands_GetTargetOrError(user, target, perm_prefix)
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
-- @param alias_name Command name or alias without `!`.
local function ResolveAlias(alias_name)
	while not pshy.commands[alias_name] and pshy.commands_aliases[alias_name] do
		alias_name = pshy.commands_aliases[alias_name]
	end
	return alias_name
end



--- Get a chat command by name
-- @param alias_name Can be the command name or an alias, without `!`.
local function GetCommand(alias_name)
	return (pshy.commands[ResolveAlias(alias_name)])
end
--- Alias for GetCommand
-- @deprecated
pshy.GetChatCommand = GetCommand



--- Get html things to add before and after a command to display it with the right color.
function pshy.commands_GetPermColorMarkups(perm)
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



--- Get a command usage.
-- The returned string represent how to use the command.
-- @param cmd_name The name of the command.
-- @return HTML text for the command's usage.
function pshy.commands_GetUsage(cmd_name)
	local text = "!" .. cmd_name
	local real_command = GetCommand(cmd_name)
	if not real_command then
		return "This command does not exist or is unavailable."
	end
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



--- Convert string arguments of a table to the specified types, 
-- or attempt to guess the types.
-- @param args Table of elements to convert.
-- @param types Table of types.
-- @return true or (false, reason)
local function ConvertArgs(args, types)
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



local players_resumable_commands = {}
local function AnsweredArg(user, answer)
	local resumable_command = players_resumable_commands[user]
	if not resumable_command then
		print_warn("pshy_commands: no command to resume for %s", user)
		return
	end
	local arg_type = "string"
	if resumable_command.command.arg_types then
		arg_type = resumable_command.command.arg_types[#resumable_command.argv + 1] or "string"
	end
	if arg_type == "color" and type(answer) == "number" then
		answer = string.format("#%06x", answer)
	end
	print_debug("chosen answer: %s", answer)
	table.insert(resumable_command.argv, tostring(answer))
	local command = resumable_command.command
	local argv = resumable_command.argv
	players_resumable_commands[user] = nil
	pshy.commands_RunCommandWithArgs(user, command, argv)
end



--- Ask the player for a missing information.
local function AskNextArg(user, command, argv)
	local arg_type = "string"
	local arg_index = #argv + 1
	if command.arg_types then
		arg_type = command.arg_types[#argv + 1] or "string"
	end
	local arg_name = nil
	if command.arg_names and command.arg_names[arg_index] then
		arg_name = command.arg_names[arg_index]
	end
	local text
	if arg_name then
		text = string.format("<n><b>%s</b></n> (argument %d):", arg_name, arg_index)
	else
		text = string.format("<n><b>%s</b></n> (argument %d):", arg_type, arg_index)
	end
	players_resumable_commands[user] = {command = command, argv = argv}
	if arg_type == "bool" or arg_type == "boolean" then
		pshy.dialog_AskForYesOrNo(user, text, AnsweredArg)
	elseif arg_type == "color" then
		pshy.dialog_AskForColor(user, (arg_type or arg_name or "anything"), AnsweredArg)
	else
		pshy.dialog_AskForText(user, text, AnsweredArg)
	end
end



--- Answer a player's command.
-- @param msg The message to send.
-- @param player_name The player who will receive the message.
local function Answer(msg, player_name)
	assert(player_name ~= nil)
	tfm.exec.chatMessage("<n> ↳ " .. tostring(msg), player_name)
end



--- Answer a player's command (on error).
-- @param msg The message to send.
-- @param player_name The player who will receive the message.
local function AnswerError(msg, player_name)
	assert(player_name ~= nil)
	tfm.exec.chatMessage("<r> × " .. tostring(msg), player_name)
end



--- Run a command as a player.
-- @param user The Name#0000 of the player running the command.
-- @param command_str The full command the player have input, without "!".
-- @return false on permission failure, true if handled and not to handle, nil otherwise
function pshy.commands_Run(user, command_str)
	-- input asserts
	assert(type(user) == "string")
	assert(type(command_str) == "string")
	-- log commands used by non-admin players
	if not pshy.admins[user] then
		print("<g>[" .. user .. "] !" .. command_str)
	end
	-- ignore 'other.' commands
	if ignore_next_command then
		ignore_next_command = false
		return
	end
	if string.sub(command_str, 1, 6) == "other." then
		ignore_next_command = true
		return eventChatCommand(user, command_str)
	end
	-- remove 'pshy.' prefix
	local had_pshy_prefix = false
	if string.sub(command_str, 1, 5) == "pshy." then
		command_str = string.sub(command_str, 6, #command_str)
		had_pshy_prefix = true
	elseif pshy.commands_require_prefix then
		return
	end
	-- get the command alias (command name) and the argument string
	local command_alias_and_args_str = pshy.StrSplit(command_str, " ", 2)
	local command_alias = command_alias_and_args_str[1]
	local args_str = command_alias_and_args_str[2]
	local command = GetCommand(command_alias)
	-- non-existing command
	if not command then
		if had_pshy_prefix then
			AnswerError("Unknown pshy command.", user)
			return nil
		end
		tfm.exec.chatMessage("Another module may handle this command.", user)
		return nil
	end
	-- check permissions
	if not pshy.HavePerm(user, "!" .. command.name) then
		AnswerError("You do not have permission to use this command.", user)
		return false
	end
	-- get args
	args = args_str and pshy.StrSplit(args_str, " ", command.argc_max or 16) or {} -- max command args set to 16 to prevent abuse
	return pshy.commands_RunCommandWithArgs(user, command, args)
end



--- Run a command (from a command table) with given args.
-- @param user Name#0000 of the user to run the command as.
-- @param command The command table representing the command to run.
-- @param argv List of arguments (strings).
-- @return false on permission failure, true if handled and not to handle, nil otherwise
function pshy.commands_RunCommandWithArgs(user, command, argv)
	-- check permissions
	if not pshy.HavePerm(user, "!" .. command.name) then
		AnswerError("You do not longer have permission to use this command.", user)
		return false
	end
	-- missing arguments
	if command.argc_min and #argv < command.argc_min then
		if command.ui or pshy.commands_always_enable_ui then
			AskNextArg(user, command, argv)
			return true
		end
		AnswerError("Usage: " .. pshy.commands_GetUsage(final_command_name), user)
		return false
	end
	-- too many arguments
	if command.argc_max and #argv > command.argc_max then
		AnswerError("This command do not use arguments.", user)
		return false
	end
	-- multiple players args
	local multiple_players_index = nil
	if command.arg_types then
		for i_type, type in ipairs(command.arg_types) do
			if type == "player" and argv[i_type] == '*' then
				multiple_players_index = i_type
			end
		end
	end
	-- convert arguments
	local rst, rtn = ConvertArgs(argv, command.arg_types)
	if not rst then
		AnswerError(tostring(rtn), user)
		return not had_prefix
	end
	-- runing the command
	local pcallrst, rst, rtn
	if multiple_players_index then
		-- command affect all players
		for player_name in pairs(tfm.get.room.playerList) do
			argv[multiple_players_index] = player_name
			if not command.no_user then
				pcallrst, rst, rtn = pcall(command.func, user, table.unpack(argv))
			else
				pcallrst, rst, rtn = pcall(command.func, table.unpack(argv))
			end
			if pcallrst == false or rst == false then 
				break
			end
		end
	else
		-- command affect at most 1 player		
		if not command.no_user then
			pcallrst, rst, rtn = pcall(command.func, user, table.unpack(argv))
		else
			pcallrst, rst, rtn = pcall(command.func, table.unpack(argv))
		end
	end
	-- display command results
	if pcallrst == false then
		-- pcall failed
		AnswerError(rst, user)
	elseif rst == false then
		-- command function returned false
		AnswerError(rtn, user)
	elseif rst == nil then
		-- command function returned false
		Answer("Command executed.", user)
	elseif rst == true and rtn ~= nil then
		-- command function returned true
		if type(rtn) == "string" then
			Answer(rtn, user)
		else
			Answer(string.format("Command returned %s.", tostring(rtn)), user)
		end
	end
end



--- !commands(cmds,help) []
-- List commands.
local function ChatCommandCommands(user, page_index)
	page_index = page_index or 1
	local commands_per_page = 10
	tfm.exec.chatMessage(string.format("<n>Commands (page %d/%d):</n>", page_index, #pshy.commands_names_ordered / commands_per_page), user)
	local i_command_first = ((page_index - 1) * commands_per_page) + 1
	local i_command_last = ((page_index - 1) * commands_per_page + 10)
	for i_command = i_command_first, i_command_last do
		local command_name = pshy.commands_names_ordered[i_command]
		if command_name then
			local real_command = GetCommand(command_name)
			local is_admin = pshy.admins[user]
			if not real_command.restricted or is_admin then
				local usage = pshy.commands_GetUsage(command_name)
				local markup_1, markup_2 = pshy.commands_GetPermColorMarkups("!" .. command_name)
				tfm.exec.chatMessage(string.format("  %s%s%s", markup_1, usage, markup_2), user)
			end
		else
			break
		end
	end
	return true
end
pshy.commands["commands"] = {func = ChatCommandCommands, desc = "list commands", argc_min = 0, argc_max = 1, arg_types = {"number"}}
pshy.perms.everyone["!commands"] = true
pshy.commands_aliases["cmds"] = "commands"



function eventChatCommand(player_name, message)
	return pshy.commands_Run(player_name, message)
end



function eventNewGame()
	system.disableChatCommandDisplay(nil, true)
end



function eventInit()
	-- complete command tables with the command name
	for command_name, command in pairs(pshy.commands) do
		command.name = command_name
		table.insert(pshy.commands_names_ordered, command_name)
	end
	table.sort(pshy.commands_names_ordered)
end
