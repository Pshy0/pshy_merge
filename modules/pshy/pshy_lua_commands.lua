--- Pshy basic commands module
--
-- This submodule add the folowing commands:
--   !luaget <path.to.variable>		- get a lua value
--   !luaset <path.to.variable> <new_value>	- set a lua value
--   !luacall <path.to.function> [args...]	- call a lua function
--   !parseargs [args...]			- preview the parsing of arguments (useful for !luacall)
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



--- Module Help Page.
pshy.help_pages["pshy_lua_commands"] = {back = "pshy", text = "This module adds commands to interact with lua.\n", examples = {}}
pshy.help_pages["pshy_lua_commands"].commands = {}
pshy.help_pages["pshy_lua_commands"].examples["luacall tfm.exec.respawnPlayer " .. pshy.host] = "Respawn " .. pshy.host .. "."
pshy.help_pages["pshy_lua_commands"].examples["luacall tfm.exec.movePlayer Player#0000 tfm.get.room.playerList." .. pshy.host .. ".x" .. "  tfm.get.room.playerList." .. pshy.host .. ".y"] = "Teleport Player#0000 to yourself."
pshy.help_pages["pshy"].subpages["pshy_lua_commands"] = pshy.help_pages["pshy_lua_commands"]




--- !luaget <path.to.object>
-- Get the value of a lua object.
function pshy.ChatCommandLuaget(user, obj_name)
	assert(type(obj_name) == "string")
	local obj = pshy.LuaGet(obj_name)
	local result
	if type(obj) == "string" then
		result = obj_name .. " == \"" .. tostring(obj) .. "\""
	else
		result = obj_name .. " == " .. tostring(obj)
	end
	tfm.exec.chatMessage(result, user)
end
pshy.chat_commands["luaget"] = {func = pshy.ChatCommandLuaget, desc = "Get a lua object value.", argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_lua_commands"].commands["luaget"] = pshy.chat_commands["luaget"]



--- !luaset <path.to.object> <new_value>
-- Set the value of a lua object
function pshy.ChatCommandLuaset(user, obj_path, obj_value)
	pshy.LuaSet(obj_path, pshy.AutoType(obj_value))
	pshy.ChatCommandLuaget(user, obj_path)
end
pshy.chat_commands["luaset"] = {func = pshy.ChatCommandLuaset, desc = "Set a lua object value.", argc_min = 2, argc_max = 2, arg_types = {"string", "string"}}
pshy.help_pages["pshy_lua_commands"].commands["luaset"] = pshy.chat_commands["luaset"]



--- !luacall <path.to.function> [args...]
-- Call a lua function.
-- @todo use variadics and put the feature un pshy_utils?
function pshy.ChatCommandLuacall(user, funcname, a, b, c, d, e, f)
	local func = pshy.LuaGet(funcname)
	local rst1, rst2
	assert(type(func) ~= "nil", "function not found")
	assert(type(func) == "function", "a function name was expected")
	rst1, rst2 = func(a, b, c, d, e, f)
	tfm.exec.chatMessage(funcname .. " returned " .. tostring(rst1) .. ", " .. tostring(rst2), user)
end
pshy.chat_commands["luacall"] = {func = pshy.ChatCommandLuacall, desc = "Run a lua function with given arguments.", argc_min = 1, arg_types = {"string"}}
pshy.help_pages["pshy_lua_commands"].commands["luacall"] = pshy.chat_commands["luacall"]



--- !runas command
-- Run a command as another player.
function pshy.ChatCommandRunas(player_name, target_player, command)
	pshy.Log(player_name .. " running as " .. target_player .. ": " .. command)
	pshy.RunChatCommand(target, command)
end
pshy.chat_commands["runas"] = {func = pshy.ChatCommandRunas, desc = "Rdun a command as another player.", argc_min = 2, argc_max = 2, arg_types = {"string", "string"}}
pshy.help_pages["pshy_lua_commands"].commands["runas"] = pshy.chat_commands["runas"]



--- !parseargs
-- Interpret the given values and print them
function pshy.ChatCommandParseargs(player_name, ...)
	local args = {...}
	local total = "parseargs"
	for i = 1, #args do
		total = total .. " " .. type(args[i]) .. ":" .. tostring(args[i]) 
	end
	tfm.exec.chatMessage(total, player_name)
end
pshy.chat_commands["parseargs"] = {func = pshy.ChatCommandParseargs, desc = "See what your command expends to."}
pshy.help_pages["pshy_lua_commands"].commands["parseargs"] = pshy.chat_commands["parseargs"]



--- !admin <NewAdmin#0000>
-- Add an admin in the pshy.admins set.
function pshy.ChatCommandAdmin(user, new_admin_name)
	pshy.admins[new_admin_name] = true
	for admin_name, void in pairs(pshy.admins) do
		tfm.exec.chatMessage(user .. " added " .. new_admin_name .. " as room admin.", admin_name)
	end
end
pshy.chat_commands["admin"] = {func = pshy.ChatCommandAdmin, desc = "Add a room admin.", argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_lua_commands"].commands["admin"] = pshy.chat_commands["admin"]



--- One command per tfm.exec function.
-- @deprecated Use !luacall instead
--for fname, f in pairs(tfm.exec) do
--	if type(f) == "function" then
--		pshy.chat_commands[fname] = {}
--		pshy.chat_commands[fname].func = f
--		pshy.chat_commands[fname].no_user = true
--	end
--end



--- other commands renaming
-- @todo mode to pshy_more_commans.lua
pshy.chat_commands["mort"] = {func = tfm.exec.killPlayer, desc = "Commit suicide.", arg_types = {}}
pshy.RenameChatCommand("mort", "suicide", true)
--pshy.chat_commands["killPlayer"].desc = "Kill the target player."
--pshy.chat_commands["setShaman"].desc = "Toggle a player as shaman."
