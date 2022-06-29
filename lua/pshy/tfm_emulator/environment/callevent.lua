--- pshy.tfm_emulator.environment.callevent
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.tfm_emulator.environment.base")
local tfmenv = pshy.require("pshy.compiler.tfmenv")



local function GetArgCount(...)
	local args = {...}
	local len = 0
	for i_arg in pairs(args) do
		len = math.max(len, i_arg)
	end
	return len
end



local function ArgListToStr(...)
	local args = {...}
	local argc = GetArgCount(...)
	local str = ""
	for i_arg = 1, argc do
		local arg = args[i_arg]
		if str ~= "" then
			str = str .. ", "
		end
		if type(arg) == "string" then
			str = str .. "\"" .. tostring(arg) .. "\""
		else
			str = str .. tostring(arg)
		end
	end
	return str
end



function tfmenv.CallEvent(func_name, ...)
	assert(type(func_name) == "string")
	if tfmenv.env[func_name] then
		if tfmenv.log_events then
			print(string.format(">> %s(%s)", func_name, ArgListToStr(...)))
		end
		local previous_env = _ENV
		_ENV = tfmenv.env
		tfmenv.env[func_name](...)
		tfmenv.env = _ENV
		_ENV = previous_env
	end
end
