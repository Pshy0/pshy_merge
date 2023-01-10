--- pshy.debug.timing
--
-- Debug functions to measure time taken by functions.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
local command_list = pshy.require("pshy.commands.list")
local help_pages = pshy.require("pshy.help.pages")
local utils_tables = pshy.require("pshy.utils.tables")



--- Module Help Page:
help_pages["timing"] = {back = "pshy", title = "Dbg Timing", commands = {}}
help_pages["pshy"].subpages["timing"] = help_pages["timing"]



--- Namespace.
local timing = {}



--- Internal Use:
local timing_measures = {}



--- Start measuring a time.
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
function timing.Stop(name)
	local measure = timing_measures[name]
	assert(measure, "this measure does not exist")
	assert(measure.start_count > 0, "this measure was not started")
	measure.start_count = measure.start_count - 1
	if measure.start_count == 0 then
	local elapsed = os.time() - measure.start_time
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



--- !debugtimingprint
local function ChatCommandDebugtimingprint(user)
	timing.PrintMeasures(user)
	return true
end
command_list["debugtimingprint"] = {func = ChatCommandDebugtimingprint, desc = "Print event timing results.", argc_min = 0, argc_max = 0}
help_pages["timing"].commands["debugtimingprint"] = command_list["debugtimingprint"]



--- !debugtimingreset
local function ChatCommandDebugtimingreset(user)
	timing.ResetMeasures()
end
command_list["debugtimingreset"] = {func = ChatCommandDebugtimingreset, desc = "Reset event timing.", argc_min = 0, argc_max = 0}
help_pages["timing"].commands["debugtimingreset"] = command_list["debugtimingreset"]



return timing
