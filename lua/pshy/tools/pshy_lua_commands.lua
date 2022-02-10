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
-- @require pshy_utils_lua.lua



--- Module Help Page:
pshy.help_pages["pshy_lua_commands"] = {back = "pshy", title = "Lua Commands", text = "Commands to interact with lua.\n"}
pshy.help_pages["pshy_lua_commands"].commands = {}
pshy.help_pages["pshy"].subpages["pshy_lua_commands"] = pshy.help_pages["pshy_lua_commands"]



--- Internal Use:
pshy.rst1 = nil		-- store the first return of !call
pshy.rst2 = nil		-- store the second result of !call



--- !luaget <path.to.object>
-- Get the value of a lua object.
local function ChatCommandLuaget(user, obj_name)
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
	return true, result
end
pshy.chat_commands["luaget"] = {func = ChatCommandLuaget, desc = "get a lua object value", argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.chat_command_aliases["get"] = "luaget"
pshy.help_pages["pshy_lua_commands"].commands["luaget"] = pshy.chat_commands["luaget"]
pshy.perms.admins["!luaget"] = true



--- !luals <path.to.object>
-- List elements in a table.
local function ChatCommandLuals(user, obj_name)
	if obj_name == nil then
		obj_name = "_G"
	end
	assert(type(obj_name) == "string")
	local obj = pshy.LuaGet(obj_name)
	local result
	tfm.exec.chatMessage(string.format("%16s: %s", type(obj), obj_name), user)
	if type(obj) == "table" then
		for el_name, el_value in pairs(obj) do
			local t = type(el_value)
			if t == "string" then
				tfm.exec.chatMessage(string.format("├ %9s: %s == \"%s\"", t, el_name, tostring(el_value)), user)
			elseif t == "number" or t == "boolean" then
				tfm.exec.chatMessage(string.format("├ %9s: %s == %s", t, el_name, tostring(el_value)), user)
			else
				tfm.exec.chatMessage(string.format("├ %9s: %s", t, el_name), user)
			end
		end
	end
	return true
end
pshy.chat_commands["luals"] = {func = ChatCommandLuals, desc = "list elements from a lua table (default _G)", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.chat_command_aliases["ls"] = "luals"
pshy.help_pages["pshy_lua_commands"].commands["luals"] = pshy.chat_commands["luals"]
pshy.perms.admins["!luals"] = true



--- !luaset <path.to.object> <new_value>
-- Set the value of a lua object.
local function ChatCommandLuaset(user, obj_path, obj_value)
	pshy.LuaSet(obj_path, pshy.AutoType(obj_value))
	return ChatCommandLuaget(user, obj_path)
end
pshy.chat_commands["luaset"] = {func = ChatCommandLuaset, desc = "set a lua object value", argc_min = 2, argc_max = 2, arg_types = {"string", "string"}}
pshy.chat_command_aliases["set"] = "luaset"
pshy.help_pages["pshy_lua_commands"].commands["luaset"] = pshy.chat_commands["luaset"]



--- !luasetstr <path.to.object> <new_value>
-- Set the string value of a lua object.
local function ChatCommandLuasetstr(user, obj_path, obj_value)
	obj_value = string.gsub(string.gsub(obj_value, "&lt;", "<"), "&gt;", ">")
	pshy.LuaSet(obj_path, obj_value)
	return ChatCommandLuaget(user, obj_path)
end
pshy.chat_commands["luasetstr"] = {func = ChatCommandLuasetstr, desc = "set a lua object string (support html)", argc_min = 2, argc_max = 2, arg_types = {"string", "string"}}
pshy.chat_command_aliases["setstr"] = "luaset"
pshy.help_pages["pshy_lua_commands"].commands["luasetstr"] = pshy.chat_commands["luasetstr"]



--- !luacall <path.to.function> [args...]
-- Call a lua function.
-- @todo use variadics and put the feature un pshy_utils?
local function ChatCommandLuacall(user, funcname, ...)
	local func = pshy.LuaGet(funcname)
	assert(type(func) ~= "nil", "function not found")
	assert(type(func) == "function", "a function name was expected")
	pshy.rst1, pshy.rst2 = func(...)
	return true, string.format("%s returned %s, %s.", funcname, tostring(pshy.rst1), tostring(pshy.rst2))
end
pshy.chat_commands["luacall"] = {func = ChatCommandLuacall, desc = "run a lua function with given arguments", argc_min = 1, arg_types = {"string"}}
pshy.chat_command_aliases["call"] = "luacall"
pshy.help_pages["pshy_lua_commands"].commands["luacall"] = pshy.chat_commands["luacall"]



--- !rejoin [player]
-- Simulate a rejoin.
local function ChatCommandRejoin(user, target)
	target = target or user
	tfm.exec.killPlayer(target)
	eventPlayerLeft(target)
	eventNewPlayer(target)
	return true, "Simulating a rejoin..."
end
pshy.chat_commands["rejoin"] = {func = ChatCommandRejoin, desc = "simulate a rejoin (events left + join + died)", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.help_pages["pshy_lua_commands"].commands["rejoin"] = pshy.chat_commands["rejoin"]
pshy.perms.admins["!rejoin"] = true



--- !runas command
-- Run a command as another player (use the other player's permissions).
local function ChatCommandRunas(player_name, target_player, command)
	print_warn("Player %s running command as %s: %s", player_name, target_player, command)
	pshy.RunChatCommand(target, command)
end
pshy.chat_commands["runas"] = {func = ChatCommandRunas, desc = "run a command as another player", argc_min = 2, argc_max = 2, arg_types = {"string", "string"}}
pshy.help_pages["pshy_lua_commands"].commands["runas"] = pshy.chat_commands["runas"]



--- !exit
local function ChatCommandExit(user)
	system.exit()
end 
pshy.chat_commands["exit"] = {func = ChatCommandExit, desc = "stop the module", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_lua_commands"].commands["exit"] = pshy.chat_commands["exit"]
pshy.perms.admins["!exit"] = true



--- !pshyversion
local function ChatCommandPshyversion(user)
	return true, string.format("Pshy repository version: %s", tostring(__PSHY_VERSION__))
end
pshy.chat_commands["pshyversion"] = {func = ChatCommandPshyversion, desc = "Show the last repository version.", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_lua_commands"].commands["pshyversion"] = pshy.chat_commands["pshyversion"]
pshy.perms.everyone["!pshyversion"] = true



--- !luaversion
local function ChatCommandLuaversion(user)
	if type(_VERSION) == "string" then
		return true, string.format("LUA version: %s", tostring(_VERSION))
	else
		return false, "LUA not properly implemented."
	end
end
pshy.chat_commands["luaversion"] = {func = ChatCommandLuaversion, desc = "Show LUA's version.", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_lua_commands"].commands["luaversion"] = pshy.chat_commands["luaversion"]
pshy.perms.everyone["!luaversion"] = true



--- !jitversion
local function ChatCommandJitversion(user)
	if type(jit) == "table" then
		return true, string.format("LUA JIT version: %s", tostring(jit.version))
	else
		return false, "JIT not used or not properly implemented."
	end
end
pshy.chat_commands["jitversion"] = {func = ChatCommandJitversion, desc = "Show JIT's version.", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_lua_commands"].commands["jitversion"] = pshy.chat_commands["jitversion"]
pshy.perms.everyone["!jitversion"] = true



--- !apiversion
local function ChatCommandApiversion(user)
	return true, string.format("TFM API version: %s", tostring(tfm.get.misc.apiVersion))
end
pshy.chat_commands["apiversion"] = {func = ChatCommandApiversion, desc = "Show the API version.", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_lua_commands"].commands["apiversion"] = pshy.chat_commands["apiversion"]
pshy.perms.everyone["!apiversion"] = true



--- !tfmversion
local function ChatCommandTfmversion(user)
	return true, string.format("TFM version: %s", tostring(tfm.get.misc.transformiceVersion))
end
pshy.chat_commands["tfmversion"] = {func = ChatCommandTfmversion, desc = "Show the API version.", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_lua_commands"].commands["tfmversion"] = pshy.chat_commands["tfmversion"]
pshy.perms.everyone["!tfmversion"] = true



--- !playerid
local function ChatCommandPlayerid(user)
	return true, string.format("Your player id is %d.", tfm.get.room.playerList[user].id)
end
pshy.chat_commands["playerid"] = {func = ChatCommandPlayerid, desc = "Show your TFM player id.", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_lua_commands"].commands["playerid"] = pshy.chat_commands["playerid"]
pshy.perms.everyone["!playerid"] = true
