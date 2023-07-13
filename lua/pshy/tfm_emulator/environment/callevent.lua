--- pshy.tfm_emulator.environment.callevent
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.tfm_emulator.environment.base")
local tfmenv = pshy.require("pshy.compiler.tfmenv")
local args_utils = pshy.require("pshy.utils.args")



--- Internal use:
local ArgsToString = args_utils.ToString



--- Call an event with `tfmenv.env` as environment,
-- and prints the arguments if `tfmenv.log_events` is true.
function tfmenv.CallEvent(func_name, ...)
	assert(type(func_name) == "string")
	if tfmenv.env[func_name] then
		if tfmenv.log_events then
			print(string.format("\x1B[38;5;242m>> %s(%s)", func_name, ArgsToString(...)))
		end
		local previous_env = _ENV
		_ENV = tfmenv.env
		tfmenv.env[func_name](...)
		tfmenv.env = _ENV
		_ENV = previous_env
	end
end
