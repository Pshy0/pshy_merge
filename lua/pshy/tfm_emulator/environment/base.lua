--- pshy.tfm_emulator.environment.base
--
-- Define basic values and placeholder functions accessible to TFM modules.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local tfmenv = pshy.require("pshy.compiler.tfmenv")



--- Abort if the emulator is ran in TFM or with itself:
if not os.exit and system.exit and tfm then
	error("<r>The emulator script cannot run in TFM! Run it in a Lua terminal instead!</r>")
end
if pshy.tfm_emulator then
	print("/!\\ The emulator script cannot run in TFM! Run it in a Lua terminal instead!")
	return
end



--- Global variable indication this is the emulator.
pshy.tfm_emulator = true



--- Settings:
pshy.tfm_emulator_log_events = true
pshy.tfm_emulator_loader = nil



--- Backups of lua functions:
pshy.lua_assert = assert
pshy.lua_error = string.error
pshy.lua_os_clock = os.clock
pshy.lua_os_exit = os.exit
pshy.lua_os_time = os.time
pshy.lua_math_floor = math.floor
pshy.lua_math_max = math.max
pshy.lua_math_min = math.min
pshy.lua_pcall = pcall
pshy.lua_print = print
pshy.lua_string_format = string.format



--- Dummy function that does nothing.
function pshy.tfm_emulator_dummy_function()
end



for item_name, item in pairs(tfmenv.env) do
	_G[item_name] = item
end
