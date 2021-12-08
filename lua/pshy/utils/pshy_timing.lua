--- pshy_timing.lua
--
-- Debug functions to measure time taken by functions.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require_priority HARDMERGE
pshy = pshy or {}



--- Internal Use:
pshy.timing_measures = {}



--- Start measuring a time.
function pshy.timing_Start(name)
	local measure = pshy.timing_measures[name]
	if not measure then
		pshy.timing_measures[name] = {}
		measure = pshy.timing_measures[name]
		measure.name = name
		measure.total_time = 0
		measure.start_count = 0
		measure.total_count = 0
	end
	measure.start_count = measure.start_count + 1
	measure.total_count = measure.total_count + 1
	measure.start_time = os.time()
end



--- Stop measuring a time.
function pshy.timing_Stop(name)
	local measure = pshy.timing_measures[name]
	assert(measure, "this measure does not exist")
	assert(measure.start_count > 0, "this measure was not started")
	measure.start_count = measure.start_count - 1
	if measure.start_count == 0 then
	local elapsed = os.time() - measure.start_time
		measure.total_time = measure.total_time + elapsed
		measure.start_time = nil
	end
end



--- Print all measures.
function pshy.timing_PrintMeasures()
	print(string.format("<vi>Times at %u:</vi>", os.time()))
	for measure_name, measure in pairs(pshy.timing_measures) do
		print(string.format("<j>%s: <o>%dms</o> / <o>%dcalls</o> == <r>%.4f ms/call</r>", measure_name, measure.total_time, measure.total_count, measure.total_time/ measure.total_count))
	end
	return true, "Printed times to logs."
end



---  Reset measures.
function pshy.timing_ResetMeasures()
	print(string.format("<o>Times at %u:</o>", os.time()))
	for measure_name, measure in pairs(pshy.timing_measures) do
		measure.total_time = 0
		measure.total_count = 0
	end
	return true, "Total times have been reset."
end
