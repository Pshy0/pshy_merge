--- pshy.tfm_emulator.environment.time
--
-- Allow to emulate a TFM Lua module outside of TFM.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local tfmenv = pshy.require("pshy.compiler.tfmenv")



--- Real os_time function.
tfmenv.emulated_time = os.time() * 1000
tfmenv.emulated_time_clock_start = os.clock() * 1000
tfmenv.emulated_time_paused = false



--- Pause the emulated time.
function tfmenv.time_Pause()
	if not tfmenv.emulated_time_paused then
		tfmenv.emulated_time = tfmenv.emulated_time + (os.clock() * 1000 - tfmenv.emulated_time_clock_start)
		tfmenv.emulated_time_clock_start = os.clock()
		tfmenv.emulated_time_paused = true
	end
end



--- Resume the emulated time.
function tfmenv.time_Resume()
	tfmenv.time_Pause()
	tfmenv.emulated_time_clock_start = os.clock()
	tfmenv.emulated_time_paused = false
end



--- Add to the time seen by the emulated script.
function tfmenv.time_Add(ms)
	tfmenv.emulated_time = tfmenv.emulated_time + ms
end



--- Get the current time seen by the emulated script.
function tfmenv.time_Get()
	if tfmenv.emulated_time_paused then
		return tfmenv.emulated_time
	else
		return tfmenv.emulated_time + (os.clock() * 1000 - tfmenv.emulated_time_clock_start)
	end
end



--- Override of `os.time`.
os.time = function()
	return math.floor(tfmenv.time_Get())
end
