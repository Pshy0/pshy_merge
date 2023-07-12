--- pshy.commands.list.lua
--
-- Commands to interact with lua.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.commands")
local help_pages = pshy.require("pshy.help.pages")
local utils_lua = pshy.require("pshy.utils.lua")
local utils_types = pshy.require("pshy.utils.types")
local utils_functions = pshy.require("pshy.utils.functions")
local perms = pshy.require("pshy.perms")



--- Module Help Page:
help_pages[__MODULE_NAME__] = {back = "pshy", title = "Lua", text = "Commands to interact with lua.\n", details = "You can access the list of locals with `~/module.name/~`.\nAccess the local with `~/module.name/local_name`\n"}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



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



local function Luaget(user, obj_name)
	assert(type(obj_name) == "string")
	local sep = string.find(obj_name, "/") and "/" or "."
	local obj = utils_lua.Get(obj_name, sep)
	local result = GetShortColoredString(obj_name, obj)
	return true, result
end



__MODULE__.commands = {
	["luaget"] = {
		aliases = {"get"},
		perms = "admins",
		desc = "get a lua object value",
		argc_min = 1,
		argc_max = 1,
		arg_types = {"string"},
		func = Luaget
	},
	["luals"] = {
		aliases = {"ls"},
		perms = "admins",
		desc = "list elements from a lua table (default _G)",
		argc_min = 0,
		argc_max = 1,
		arg_types = {"string"},
		func = function(user, obj_name)
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
	},
	["luaset"] = {
		aliases = {"set"},
		desc = "set a lua object value",
		argc_min = 2,
		argc_max = 2,
		arg_types = {"string", "string"},
		func = function(user, obj_path, obj_value)
			local sep = string.find(obj_path, "/") and "/" or "."
			utils_lua.Set(obj_path, utils_types.ToTypeFromPrefix(obj_value), sep)
			return Luaget(user, obj_path, sep)
		end
	},
	["luasetstr"] = {
		aliases = {"setstr"},
		desc = "set a lua object string (support html)",
		argc_min = 2,
		argc_max = 2,
		arg_types = {"string", "string"},
		func = function(user, obj_path, obj_value)
			local sep = string.find(obj_path, "/") and "/" or "."
			obj_value = string.gsub(string.gsub(obj_value, "&lt;", "<"), "&gt;", ">")
			utils_lua.Set(obj_path, obj_value, sep)
			return Luaget(user, obj_path)
		end
	},
	["luacall"] = {
		aliases = {"call", "lua"},
		desc = "run a lua function with given arguments",
		argc_min = 1,
		arg_types = {"string"},
		func = function(user, funcname, ...)
			local sep = string.find(funcname, "/") and "/" or "."
			local func = utils_lua.Get(funcname, sep)
			assert(type(func) ~= "nil", "function not found")
			assert(type(func) == "function", "a function name was expected")
			local start_time = os.time()
			pshy.rst1, pshy.rst2 = func(...)
			return true, string.format("%s returned %s, %s (in %f ms).", funcname, tostring(pshy.rst1), tostring(pshy.rst2), os.time() - start_time)
		end
	},
	["luabindfunc"] = {
		aliases = {"bindfunc"},
		desc = "create a function that calls another with specific arguments",
		argc_min = 2,
		arg_types = {"string"},
		func = function(user, obj_path, func, args)
			local sep = string.find(obj_path, "/") and "/" or "."
			utils_lua.Set(obj_path, utils_functions.Bind(func, args), sep)
			return Luaget(user, obj_path, sep)
		end
	}
}
