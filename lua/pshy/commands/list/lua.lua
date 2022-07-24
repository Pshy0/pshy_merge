--- pshy.commands.list.lua
--
-- Commands to interact with lua.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.commands")
local command_list = pshy.require("pshy.commands.list")
local help_pages = pshy.require("pshy.help.pages")
local utils_lua = pshy.require("pshy.utils.lua")
local utils_types = pshy.require("pshy.utils.types")
local perms = pshy.require("pshy.perms")



--- Module Help Page:
help_pages["pshy_commands_lua"] = {back = "pshy", title = "Lua", text = "Commands to interact with lua.\n"}
help_pages["pshy_commands_lua"].commands = {}
help_pages["pshy"].subpages["pshy_commands_lua"] = help_pages["pshy_commands_lua"]



--- Publicly set global variables:
pshy.rst1 = nil		-- store the first return of !call
pshy.rst2 = nil		-- store the second result of !call



--- Get the target of the command, throwing on permission issue.
local GetTarget = pshy.require("pshy.commands.get_target_or_error")



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



--- Get a short string representation of a table.
local function GetShortTableString(t, max)
	max = max or 16
	local result
	result = "{"
	local cnt = 0
	for key, value in pairs(t) do
		result = result .. ((cnt > 0) and "," or "") .. tostring(key)
		cnt = cnt + 1
		if cnt >= max then
			result = result .. ",[...]"
			break
		end
	end
	result = result .. "}"
	return result
end



local function GetShortColoredString(obj_name, obj)
	local result
	local obj_type = type(obj)
	local color_prefix, color_suffix = GetTypeColorMarkups(obj_type)
	if obj_type == "string" then
		result = obj_name .. " == \"" .. tostring(obj) .. "\""
	elseif obj_type == "table" then
		result = GetShortTableString(obj)
	else
		result = obj_name .. " == " .. tostring(obj)
	end
	return color_prefix .. result .. color_suffix
end



--- !luaget <path.to.object>
-- Get the value of a lua object.
local function ChatCommandLuaget(user, obj_name)
	assert(type(obj_name) == "string")
	local sep = string.find(obj_name, "/") and "/" or "."
	local obj = utils_lua.Get(obj_name, sep)
	local result = GetShortColoredString(obj_name, obj)
	return true, result
end
command_list["luaget"] = {aliases = {"get"}, perms = "admins", func = ChatCommandLuaget, desc = "get a lua object value", argc_min = 1, argc_max = 1, arg_types = {"string"}}
help_pages["pshy_commands_lua"].commands["luaget"] = command_list["luaget"]



--- !luals <path.to.object>
-- List elements in a table.
local function ChatCommandLuals(user, obj_name)
	local sep = string.find(obj_name or "", "/") and "/" or "."
	if obj_name == nil then
		obj_name = "_G"
	end
	assert(type(obj_name) == "string")
	local obj = utils_lua.Get(obj_name, sep)
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
command_list["luals"] = {aliases = {"ls"}, perms = "admins", func = ChatCommandLuals, desc = "list elements from a lua table (default _G)", argc_min = 0, argc_max = 1, arg_types = {"string"}}
help_pages["pshy_commands_lua"].commands["luals"] = command_list["luals"]



--- !luaset <path.to.object> <new_value>
-- Set the value of a lua object.
local function ChatCommandLuaset(user, obj_path, obj_value)
	local sep = string.find(obj_path, "/") and "/" or "."
	utils_lua.Set(obj_path, utils_types.AutoType(obj_value), sep)
	return ChatCommandLuaget(user, obj_path, sep)
end
command_list["luaset"] = {aliases = {"set"}, func = ChatCommandLuaset, desc = "set a lua object value", argc_min = 2, argc_max = 2, arg_types = {"string", "string"}}
help_pages["pshy_commands_lua"].commands["luaset"] = command_list["luaset"]



--- !luasetstr <path.to.object> <new_value>
-- Set the string value of a lua object.
local function ChatCommandLuasetstr(user, obj_path, obj_value)
	local sep = string.find(obj_path, "/") and "/" or "."
	obj_value = string.gsub(string.gsub(obj_value, "&lt;", "<"), "&gt;", ">")
	utils_lua.Set(obj_path, obj_value, sep)
	return ChatCommandLuaget(user, obj_path)
end
command_list["luasetstr"] = {aliases = {"setstr"}, func = ChatCommandLuasetstr, desc = "set a lua object string (support html)", argc_min = 2, argc_max = 2, arg_types = {"string", "string"}}
help_pages["pshy_commands_lua"].commands["luasetstr"] = command_list["luasetstr"]



--- !luacall <path.to.function> [args...]
-- Call a lua function.
-- @todo use variadics and put the feature un pshy_utils?
local function ChatCommandLuacall(user, funcname, ...)
	local sep = string.find(funcname, "/") and "/" or "."
	local func = utils_lua.Get(funcname, sep)
	assert(type(func) ~= "nil", "function not found")
	assert(type(func) == "function", "a function name was expected")
	local start_time = os.time()
	pshy.rst1, pshy.rst2 = func(...)
	return true, string.format("%s returned %s, %s (in %f ms).", funcname, tostring(pshy.rst1), tostring(pshy.rst2), os.time() - start_time)
end
command_list["luacall"] = {aliases = {"call", "lua"}, func = ChatCommandLuacall, desc = "run a lua function with given arguments", argc_min = 1, arg_types = {"string"}}
help_pages["pshy_commands_lua"].commands["luacall"] = command_list["luacall"]
