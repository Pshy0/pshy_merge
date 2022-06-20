--- pshy.tfm_emulator.environment.time
--
-- Allow to emulate a TFM Lua module outside of TFM.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy = pshy or {}



--- Real os_time function.
pshy.tfm_emulator_real_os_time_function = os.time
pshy.tfm_emulator_emulated_time = pshy.tfm_emulator_real_os_time_function() * 1000
pshy.tfm_emulator_emulated_time_clock_start = os.clock() * 1000
pshy.tfm_emulator_emulated_time_paused = false



--- Pause the emulated time.
function pshy.tfm_emulator_time_Pause()
	if not pshy.tfm_emulator_emulated_time_paused then
		pshy.tfm_emulator_emulated_time = pshy.tfm_emulator_emulated_time + (os.clock() * 1000 - pshy.tfm_emulator_emulated_time_clock_start)
		pshy.tfm_emulator_emulated_time_clock_start = os.clock()
		pshy.tfm_emulator_emulated_time_paused = true
	end
end



--- Resume the emulated time.
function pshy.tfm_emulator_time_Resume()
	pshy.tfm_emulator_time_Pause()
	pshy.tfm_emulator_emulated_time_clock_start = os.clock()
	pshy.tfm_emulator_emulated_time_paused = false
end



--- Add to the time seen by the emulated script.
function pshy.tfm_emulator_time_Add(ms)
	pshy.tfm_emulator_emulated_time = pshy.tfm_emulator_emulated_time + ms
end



--- Get the current time seen by the emulated script.
function pshy.tfm_emulator_time_Get()
	if pshy.tfm_emulator_emulated_time_paused then
		return pshy.tfm_emulator_emulated_time
	else
		return pshy.tfm_emulator_emulated_time + (os.clock() * 1000 - pshy.tfm_emulator_emulated_time_clock_start)
	end
end



--- Override of `os.time`.
os.time = function()
	return math.floor(pshy.tfm_emulator_time_Get())
end
