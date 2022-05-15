--- pshy_commands_lua.lua
--
-- Adds basic commands to interact with lua.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_commands.lua
-- @require pshy_help.lua
-- @require pshy_utils_lua.lua



--- Module Help Page:
pshy.help_pages["pshy_commands_lua"] = {back = "pshy", title = "Lua Commands", text = "Commands to interact with lua.\n"}
pshy.help_pages["pshy_commands_lua"].commands = {}
pshy.help_pages["pshy"].subpages["pshy_commands_lua"] = pshy.help_pages["pshy_commands_lua"]



--- Internal Use:
pshy.rst1 = nil		-- store the first return of !call
pshy.rst2 = nil		-- store the second result of !call



local function GetTypeColorMarkups(type_name)
	if type_name == "table" then
		return "<t>", "</t>"
	elseif type_name == "string" then
		return "<ps>", "</ps>"
	elseif type_name == "boolean" then
		return "<ps>", "</ps>"
	elseif type_name == "number" then
		return "<d>", "</d>"
	elseif type_name == "function" then
		return "<cep>", "</cep>"
	else
		return "<v>", "</v>"
	end
end



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
pshy.commands["luaget"] = {func = ChatCommandLuaget, desc = "get a lua object value", argc_min = 1, argc_max = 1, arg_types = {"string"}}
pshy.commands_aliases["get"] = "luaget"
pshy.help_pages["pshy_commands_lua"].commands["luaget"] = pshy.commands["luaget"]
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
			local color_prefix, color_suffix = GetTypeColorMarkups(t)
			if t == "string" then
				if #el_value < 24 then
					tfm.exec.chatMessage(string.format("├ %s%9s: %s == \"%s\"%s", color_prefix, t, el_name, el_value, color_suffix), user)
				else
					tfm.exec.chatMessage(string.format("├ %s%9s: %s #%d%s", color_prefix, t, el_name, #el_value, color_suffix), user)
				end
			elseif t == "number" or t == "boolean" then
				tfm.exec.chatMessage(string.format("├ %s%9s: %s == %s%s", color_prefix, t, el_name, tostring(el_value), color_suffix), user)
			else
				tfm.exec.chatMessage(string.format("├ %s%9s: %s%s", color_prefix, t, el_name, color_suffix), user)
			end
		end
	end
	return true
end
pshy.commands["luals"] = {func = ChatCommandLuals, desc = "list elements from a lua table (default _G)", argc_min = 0, argc_max = 1, arg_types = {"string"}}
pshy.commands_aliases["ls"] = "luals"
pshy.commands_aliases["tree"] = "luals"
pshy.help_pages["pshy_commands_lua"].commands["luals"] = pshy.commands["luals"]
pshy.perms.admins["!luals"] = true



--- !luaset <path.to.object> <new_value>
-- Set the value of a lua object.
local function ChatCommandLuaset(user, obj_path, obj_value)
	pshy.LuaSet(obj_path, pshy.AutoType(obj_value))
	return ChatCommandLuaget(user, obj_path)
end
pshy.commands["luaset"] = {func = ChatCommandLuaset, desc = "set a lua object value", argc_min = 2, argc_max = 2, arg_types = {"string", "string"}}
pshy.commands_aliases["set"] = "luaset"
pshy.help_pages["pshy_commands_lua"].commands["luaset"] = pshy.commands["luaset"]



--- !luasetstr <path.to.object> <new_value>
-- Set the string value of a lua object.
local function ChatCommandLuasetstr(user, obj_path, obj_value)
	obj_value = string.gsub(string.gsub(obj_value, "&lt;", "<"), "&gt;", ">")
	pshy.LuaSet(obj_path, obj_value)
	return ChatCommandLuaget(user, obj_path)
end
pshy.commands["luasetstr"] = {func = ChatCommandLuasetstr, desc = "set a lua object string (support html)", argc_min = 2, argc_max = 2, arg_types = {"string", "string"}}
pshy.commands_aliases["setstr"] = "luasetstr"
pshy.help_pages["pshy_commands_lua"].commands["luasetstr"] = pshy.commands["luasetstr"]



--- !luacall <path.to.function> [args...]
-- Call a lua function.
-- @todo use variadics and put the feature un pshy_utils?
local function ChatCommandLuacall(user, funcname, ...)
	local func = pshy.LuaGet(funcname)
	assert(type(func) ~= "nil", "function not found")
	assert(type(func) == "function", "a function name was expected")
	local start_time = os.time()
	pshy.rst1, pshy.rst2 = func(...)
	return true, string.format("%s returned %s, %s (in %f ms).", funcname, tostring(pshy.rst1), tostring(pshy.rst2), os.time() - start_time)
end
pshy.commands["luacall"] = {func = ChatCommandLuacall, desc = "run a lua function with given arguments", argc_min = 1, arg_types = {"string"}}
pshy.commands_aliases["call"] = "luacall"
pshy.help_pages["pshy_commands_lua"].commands["luacall"] = pshy.commands["luacall"]



--- !apiversion
local function ChatCommandApiversion(user)
	return true, string.format("TFM API version: %s", tostring(tfm.get.misc.apiVersion))
end
pshy.commands["apiversion"] = {func = ChatCommandApiversion, desc = "Show the API version.", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_commands_lua"].commands["apiversion"] = pshy.commands["apiversion"]
pshy.perms.everyone["!apiversion"] = true



--- !tfmversion
local function ChatCommandTfmversion(user)
	return true, string.format("TFM version: %s", tostring(tfm.get.misc.transformiceVersion))
end
pshy.commands["tfmversion"] = {func = ChatCommandTfmversion, desc = "Show the API version.", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_commands_lua"].commands["tfmversion"] = pshy.commands["tfmversion"]
pshy.perms.everyone["!tfmversion"] = true



--- !playerid
local function ChatCommandPlayerid(user)
	return true, string.format("Your player id is %d.", tfm.get.room.playerList[user].id)
end
pshy.commands["playerid"] = {func = ChatCommandPlayerid, desc = "Show your TFM player id.", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_commands_lua"].commands["playerid"] = pshy.commands["playerid"]
pshy.perms.everyone["!playerid"] = true
