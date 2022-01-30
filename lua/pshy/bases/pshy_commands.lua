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
--
-- @require_priority UTILS
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
-- @param alias_name Command name or alias without `!`.
function ResolveAlias(alias_name)
	while not pshy.commands[alias_name] and pshy.commands_aliases[alias_name] do
		alias_name = pshy.commands_aliases[alias_name]
	end
	return alias_name
end



--- Get a chat command by name
-- @param alias_name Can be the command name or an alias, without `!`.
local function GetCommand(alias_name)
	return (pshy.chat_commands[ResolveAlias(alias_name)])
end



--- Get a command usage.
-- The returned string represent how to use the command.
-- @param cmd_name The name of the command.
-- @return HTML text for the command's usage.
function pshy.commands_GetUsage(cmd_name)
	local text = "!" .. cmd_name
	local real_command = GetCommand(cmd_name)
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



--- Run a command as a player.
-- @param user The Name#0000 of the player running the command.
-- @param command_str The full command the player have input, without "!".
-- @return false on permission failure, true if handled and not to handle, nil otherwise
function pshy.commands_Run(user, command_str)
	-- input checks
	--assert(type(user) == "string")
	if not tfm.get.room.playerList[user] then
		print_error("pshy_commands: %s is not in the room!", user)
		return
	end
	assert(type(command_str) == "string")
	-- log commands used by non-admin players
	if not pshy.admins[user] then
		print("<g>[" .. user .. "] !" .. command_str)
	end
	-- remove 'pshy.' prefix
	if #command_str > 5 and string.sub(command_str, 1, 5) == "pshy." then
		command_str = string.sub(command_str, 6, #command_str)
	elseif pshy.commands_require_prefix then
		tfm.exec.chatMessage("[PshyCmds] Ignoring commands without a `!pshy.` prefix.", user)
		return
	end
	-- get command name and args
	-- TODO: check: local iterator = string.gmatch(command_str, "(.-) (.*)")
	local args = pshy.StrSplit(command_str, " ", 2)
	return pshy.commands_RunArgs(user, args[1], args[2])
end



--- Run a command (with separate arguments) as a player.
-- @param user The Name#0000 of the player running the command.
-- @param command_alias The name of the command used.
-- @param args_str A string corresponding to the argument part of the command.
-- @return false on permission failure, true if handled and not to handle, nil otherwise
function pshy.commands_RunArgs(user, command_alias, args_str)
	local command = GetCommand(command_alias)
	-- non-existing command
	if not command then
		tfm.exec.chatMessage("Another module may handle this command.", user)
		return nil
	end
	-- check permissions
	if not pshy.HavePerm(user, "!" .. command.name) then
		pshy.AnswerError("You do not have permission to use this command.", user)
		return false
	end
	-- get args
	args = args_str and pshy.StrSplit(args_str, " ", command.argc_max or 32) or {} -- max command args set to 32 to prevent abuse
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
		pshy.AnswerError("You do not longer have permission to use this command.", user)
		return false
	end
	-- missing arguments
	if command.argc_min and #argv < command.argc_min then
		pshy.AnswerError("Usage: " .. pshy.commands_GetUsage(final_command_name), user)
		return false
	end
	-- too many arguments
	if #argv > command.argc_max then
		pshy.AnswerError("This command do not use arguments.", user)
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
		pshy.AnswerError(tostring(rtn), user)
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
		pshy.AnswerError(rst, user)
	elseif rst == false then
		-- command function returned false
		pshy.AnswerError(rtn, user)
	elseif rst == nil then
		-- command function returned false
		pshy.Answer("Command executed.", user)
	elseif rst == true and rtn ~= nil then
		-- command function returned true
		if type(rtn) == "string" then
			pshy.Answer(rtn, user)
		else
			pshy.Answer(string.format("Command returned %s.", tostring(rtn)), user)
		end
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
	return true
end
pshy.commands["pshy"] = {func = pshy.commands_CommandPshy, desc = "run a command listed in `pshy.commands`", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.commands_aliases["pshycmd"] = "pshy"
pshy.perms.everyone["!pshy"] = true



function eventChatCommand(player_name, message)
	return pshy.commands_Run(player_name, message)
end



function eventInit()
	-- complete command tables with the command name
	for command_name, command in pairs(pshy.commands) do
		command.name = command_name
	end
end
