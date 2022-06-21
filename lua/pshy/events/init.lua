--- pshy.events
--
-- Adds an event `eventInit(init_duration)` called when the script was loaded.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy = pshy or {}



--- Set of events to minimize.
-- Minimized events will be faster but have less functionalities.
pshy.events_to_minimize = {}
pshy.events_to_minimize["eventEmotePlayed"] = true
pshy.events_to_minimize["eventKeyboard"] = true
pshy.events_to_minimize["eventPlayerCrouchKey"] = true
pshy.events_to_minimize["eventPlayerGetCheese"] = true
pshy.events_to_minimize["eventPlayerJumpKey"] = true
pshy.events_to_minimize["eventPlayerMeep"] = true
pshy.events_to_minimize["eventPlayerMeepKey"] = true



--- Events map.
-- The key is the event function name.
-- Values are tables with the following fields:
--	- module_names:			A list of module names corresponding to entries in `original_functions`.
--	- module_indices:		A map of module names corresponding to indices of entries in the other lists.
--	- original_functions:	A list of functions corresponding to the recovered event functions.
--	- functions:			A list of functions to run when this event runs. Fields may become dummy functions or be set back to the values from `original_functions`.
local events = {}



--- Assertion variables.
local event_functions_created = false



--- Get all new event functions.
local function RecoverEventFunctions(last_module_name)
	assert(event_functions_created == false)
	for obj_name, obj in pairs(_G) do
		if type(obj) == "function" then
			if string.find("event", 1, true) == 1 then
				if not events[obj_name] then
					events[obj_name] = {module_names = {}, module_indices = {}, functions = {}, original_functions = {}}
				end
				table.insert(events[obj_name].module_names, last_module_name)
				events[obj_name].module_indices[last_module_name] = #events[obj_name].module_names
				table.insert(events[obj_name].original_functions, obj)
				table.insert(events[obj_name].functions, obj)
				_G[obj_name] = nil
			end
		end
	end
end



--- Create the event functions
-- A call to this is added by the compiler and run at the end of initialization.
function pshy.events_CreateFunctions()
	assert(event_functions_created == false)
	for event_name, event in pairs(events) do
		local event_functions = event.functions
		if not pshy.events_to_minimize[event_name] then
			_G[event_name] = function(...)
				for i_func, func in ipairs(event_functions) do
					if (func(...) ~= nil) then
						return
					end
				end
			end
		else
			_G[event_name] = function(...)
				for i_func, func in ipairs(event_functions) do
					func(...)
				end
			end
		end
	end
	event_functions_created = true
	if eventInit then
		local init_duration = os.time() - pshy.INIT_TIME
		eventInit(init_duration)
	end
end



--- Hook `pshy.require`:
table.insert(pshy.require_postload_functions, RecoverEventFunctions)
