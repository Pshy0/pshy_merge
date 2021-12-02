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
		pshy.timing_times[name] = {}
		measure = pshy.timing_measures[name]
		measure.name = name
		measure.total_time = 0
		measure.start_count = 0
	end
	measure.start_count = measure.start_count + 1
	measure.start_time = os.time()
end



--- Stop measuring a time.
function pshy.timing_Stop(name)
	measure.start_count = measure.start_count - 1
	assert(measure.start_count > 0)
	if measure.start_count == 0 then
		local measure = pshy.timing_measures[name]
		local elapsed = os.time() - measure.start_time
		measure.total_time = measure.total_time + elapsed
		measure.start_time = nil
	end
end



--- Print all measures.
function pshy.timing_PrintMeasures()
	for measure_name, measure in pairs(pshy.timing_measures) do
		print(string.format("<j>%s: %f", measure_name, measure.total_time))
	end
end
