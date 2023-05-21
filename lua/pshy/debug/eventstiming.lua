--- pshy.debug.eventstiming
--
-- Extends `pshy_merge.lua` to add events time measurements.
--
-- Adds the following commands:
--	- `!eventstiming`				- toggle events timing
--	- `!eventtiming <eventName>`	- time individual modules for a given event
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.commands")
local timing = pshy.require("pshy.debug.timing")
local events = pshy.require("pshy.events")
local command_list = pshy.require("pshy.commands.list")
local help_pages = pshy.require("pshy.help.pages")



--- Module Help Page:
help_pages[__MODULE_NAME__] = {back = "pshy", title = "Dbg Evnt Timing", commands = {}}
help_pages["pshy"].subpages[__MODULE_NAME__] = help_pages[__MODULE_NAME__]



local merge_debug_events = true



--- Make a debug event function.
local function MakeDebugEventFunction(event_name, event_functions)
	return function(...)
		-- Event functions's code
		if merge_debug_events then
			pshy_timing_Start(event_name)
		end
		local rst
		for i_func, func in ipairs(event_functions) do
			rst = func(...)
			if (rst ~= nil) then
				break
			end
		end
		if merge_debug_events then
			pshy_timing_Stop(event_name)
		end
	end
end



--- Override event function creators:
events.MakeEventFunction = MakeDebugEventFunction
events.MakeMinimumEventFunction = MakeDebugEventFunction



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
help_pages[__MODULE_NAME__].commands["eventstiming"] = command_list["eventstiming"]
