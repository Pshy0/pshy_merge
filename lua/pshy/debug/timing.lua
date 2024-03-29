--- pshy.debug.timing
--
-- Debug functions to measure time taken by functions.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local help_pages = pshy.require("pshy.help.pages")
local utils_tables = pshy.require("pshy.utils.tables")



--- Module Help Page:
help_pages[__MODULE_NAME__] = {back = "pshy", title = "Dbg Timing"}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



--- Namespace.
local timing = {}



--- Internal Use:
local timing_measures = {}



--- Start measuring a time.
-- Use `pshy_timing_Start` to avoid a table lookup.
function timing.Start(name)
	local measure = timing_measures[name]
	if not measure then
		timing_measures[name] = {}
		measure = timing_measures[name]
		measure.name = name
		measure.total_time = 0
		measure.start_count = 0
		measure.total_count = 0
	end
	measure.start_count = measure.start_count + 1
	measure.total_count = measure.total_count + 1
	measure.start_time = os.time()
end
pshy_timing_Start = timing.Start



--- Stop measuring a time.
-- Use `pshy_timing_Stop` to avoid a table lookup.
function timing.Stop(name)
	local os_time = os.time()
	local measure = timing_measures[name]
	assert(measure, "this measure does not exist")
	assert(measure.start_count > 0, "this measure was not started")
	measure.start_count = measure.start_count - 1
	if measure.start_count == 0 then
		local elapsed = os_time - measure.start_time
		measure.total_time = measure.total_time + elapsed
		measure.start_time = nil
	end
end
pshy_timing_Stop = timing.Stop



--- Print all measures.
function timing.PrintMeasures(user)
	if not user then
		print(string.format("<vi>Times at %u:</vi>", os.time()))
	else
		tfm.exec.chatMessage(string.format("<vi>Times at %u:</vi>", os.time()), user)
	end
	local keys = utils_tables.SortedKeys(timing_measures)
	for i_measure, measure_name in ipairs(keys) do
		local measure = timing_measures[measure_name]
		local ms_per_call = string.sub(string.format("%.6f", measure.total_time / measure.total_count), 1, 8)
		if not user then
			print(string.format("<j>%s: <o>%dms</o> / <o>%dcalls</o> == <r>%s ms/call</r>", measure_name, measure.total_time, measure.total_count, ms_per_call))
		else
			tfm.exec.chatMessage(string.format("<j>%s: <o>%dms</o> / <o>%dcalls</o> == <r>%s ms/call</r>", measure_name, measure.total_time, measure.total_count, ms_per_call), user)
		end
	end
	return true, "Printed times to logs."
end



--- Reset measures.
function timing.ResetMeasures()
	for measure_name, measure in pairs(timing_measures) do
		measure.total_time = 0
		measure.total_count = 0
	end
	return true, "Total times have been reset."
end



__MODULE__.commands = {
	["debugtimingprint"] = {
		desc = "Print event timing results to chat.",
		argc_min = 0,
		argc_max = 0,
		func = function(user)
			timing.PrintMeasures(user)
			return true
		end
	},
	["debugtiminglog"] = {
		desc = "Print event timing results to log.",
		argc_min = 0,
		argc_max = 0,
		func = function(user)
			timing.PrintMeasures()
			return true, "Timings outputted to log."
		end
	},
	["debugtimingreset"] = {
		desc = "Reset event timing.",
		argc_min = 0,
		argc_max = 0,
		func = function(user)
			timing.ResetMeasures()
		end
	}
}



return timing
