--- pshy.debug.debugeventstiming
--
-- Extends `pshy_merge.lua` to add events time measurements.
--
-- Adds the following commands:
--	- `!eventstiming`				- toggle events timing
--	- `!eventtiming <eventName>`	- time individual modules for a given event
--	- `!eventstimingprint`			- print timing results to logs
--	- `!eventstimingreset`			- reset timings
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.bases.events")
pshy.require("pshy.debug.timing")



--- Internal Use:
local merge_debug_events = true
local merge_debug_event_name = "eventKeyboard"



--- Create the event functions (debug timing variant).
function pshy.merge_CreateEventFuntionsTiming()
	print("DEBUG: generating debug events")
	local event_count = 0
	local pshy_events = pshy.events
	local pshy_events_module_names = pshy.events_module_names
	for e_name, e_func_list in pairs(pshy_events) do
		local event_module_names = pshy_events_module_names[e_name]
		if #e_func_list > 0 then
			event_count = event_count + 1
			_G[e_name] = nil
			_G[e_name] = function(...)
				-- Event functions's code
				if merge_debug_events then
					pshy_timing_Start(e_name)
				end
				local rst = nil
				for i_func = 1, #e_func_list do
					if e_name == merge_debug_event_name then
						pshy_timing_Start(e_name .. " " .. event_module_names[i_func])
					end
					rst = e_func_list[i_func](...)
					if rst ~= nil then
						break
					end
					if e_name == merge_debug_event_name then
						pshy_timing_Stop(e_name .. " " .. event_module_names[i_func])
					end
				end
				if pshy.merge_pending_regenerate then
					pshy.merge_GenerateEvents()
					pshy.merge_pending_regenerate = false
				end
				if merge_debug_events then
					pshy_timing_Stop(e_name)
				end
			end
		end
	end
	-- return the events count
	return event_count
end



--- !eventstiming
local function ChatCommandEventstiming(user)
	merge_debug_events = not merge_debug_events
	pshy.merge_pending_regenerate = true
	if merge_debug_events then
		return true, "Enabled events timing."
	else
		return true, "Disabled events timing."
	end
end
pshy.commands["eventstiming"] = {func = ChatCommandEventstiming, desc = "Enable event timing (debug).", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_merge"].commands["eventstiming"] = pshy.commands["eventstiming"]



--- !eventtiming
local function ChatCommandEventtiming(user, event_name)
	merge_debug_event_name = event_name
	pshy.merge_pending_regenerate = true
	if merge_debug_event_name ~= nil then
		return true, string.format("Enabled %s timing.", event_name)
	else
		return true, string.format("Disabled %s timing.", event_name)
	end
end
pshy.commands["eventtiming"] = {func = ChatCommandEventtiming, desc = "Enable event timing (debug).", argc_min = 0, argc_max = 1, arg_types = {"string"}, arg_names = {"event_name"}}
pshy.help_pages["pshy_merge"].commands["eventtiming"] = pshy.commands["eventtiming"]



--- !eventstimingprint
local function ChatCommandEventstimingprint(user)
	pshy.timing_PrintMeasures()
end
pshy.commands["eventstimingprint"] = {func = ChatCommandEventstimingprint, desc = "Print event timing results.", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_merge"].commands["eventstimingprint"] = pshy.commands["eventstimingprint"]



--- !eventstimingreset
local function ChatCommandEventstimingreset(user)
	pshy.timing_ResetMeasures()
end
pshy.commands["eventstimingreset"] = {func = ChatCommandEventstimingreset, desc = "Reset event timing.", argc_min = 0, argc_max = 0}
pshy.help_pages["pshy_merge"].commands["eventstimingreset"] = pshy.commands["eventstimingreset"]



--- Init (must be done as soon as possible):
function eventInit()
	pshy.merge_CreateEventFuntionsTiming()
	pshy.merge_pending_regenerate = false
end
