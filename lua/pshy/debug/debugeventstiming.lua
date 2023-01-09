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
pshy.require("pshy.commands")
pshy.require("pshy.debug.timing")
local events = pshy.require("pshy.events")
local command_list = pshy.require("pshy.commands.list")
local help_pages = pshy.require("pshy.help.pages")



--- Module Help Page:
help_pages["eventstiming"] = {back = "pshy", title = "Dbg Evnt Timing", commands = {}}
help_pages["pshy"].subpages["eventstiming"] = help_pages["eventstiming"]



--- Internal Use:
local merge_debug_events = true
local merge_debug_event_name = nil



--- Create the event functions (debug timing variant).
function CreateEventFuntionsTiming()
	print("DEBUG: generating debug events")
	--assert(event_functions_created == false)
	for event_name, event in pairs(events.events) do
		local event_functions = event.functions
		--if not events.to_minimize[event_name] then
			_ENV[event_name] = function(...)
				-- Event functions's code
				if merge_debug_events then
					pshy_timing_Start(event_name)
				end
				local rst
				for i_func, func in ipairs(event_functions) do
					if event_name == merge_debug_event_name then
						pshy_timing_Start(event_name .. " " .. event_module_names[i_func])
					end
					rst = func(...)
					if event_name == merge_debug_event_name then
						pshy_timing_Stop(event_name .. " " .. event_module_names[i_func])
					end
					if (rst ~= nil) then
						break
					end
				end
				if merge_debug_events then
					pshy_timing_Stop(event_name)
				end
			end
		--end
	end
end



--- !eventstiming
local function ChatCommandEventstiming(user)
	merge_debug_events = not merge_debug_events
	if merge_debug_events then
		return true, "Enabled events timing."
	else
		return true, "Disabled events timing."
	end
end
command_list["eventstiming"] = {func = ChatCommandEventstiming, desc = "Enable event timing (debug).", argc_min = 0, argc_max = 0}
help_pages["eventstiming"].commands["eventstiming"] = command_list["eventstiming"]



--- !eventtiming
local function ChatCommandEventtiming(user, event_name)
	merge_debug_event_name = event_name
	if merge_debug_event_name ~= nil then
		merge_debug_events = false
		return true, string.format("Enabled %s timing.", event_name)
	else
		return true, string.format("Disabled %s timing.", event_name)
	end
end
command_list["eventtiming"] = {func = ChatCommandEventtiming, desc = "Enable event timing (debug).", argc_min = 0, argc_max = 1, arg_types = {"string"}, arg_names = {"event_name"}}
help_pages["eventstiming"].commands["eventtiming"] = command_list["eventtiming"]



--- !eventstimingprint
local function ChatCommandEventstimingprint(user)
	pshy.timing_PrintMeasures(user)
	return true
end
command_list["eventstimingprint"] = {func = ChatCommandEventstimingprint, desc = "Print event timing results.", argc_min = 0, argc_max = 0}
help_pages["eventstiming"].commands["eventstimingprint"] = command_list["eventstimingprint"]



--- !eventstimingreset
local function ChatCommandEventstimingreset(user)
	pshy.timing_ResetMeasures()
end
command_list["eventstimingreset"] = {func = ChatCommandEventstimingreset, desc = "Reset event timing.", argc_min = 0, argc_max = 0}
help_pages["eventstiming"].commands["eventstimingreset"] = command_list["eventstimingreset"]



--- Init (must be done as soon as possible):
function eventInit()
	CreateEventFuntionsTiming()
end
