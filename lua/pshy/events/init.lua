--- events.events
--
-- Adds an event `eventInit(init_duration)` called when the script was loaded.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy = pshy or {}



--- Namespace.
local events = {}



--- Set of events to minimize.
-- Minimized events will be faster but have less functionalities.
events.to_minimize = {}
events.to_minimize["eventEmotePlayed"] = true
events.to_minimize["eventKeyboard"] = true
events.to_minimize["eventPlayerCrouchKey"] = true
events.to_minimize["eventPlayerGetCheese"] = true
events.to_minimize["eventPlayerJumpKey"] = true
events.to_minimize["eventPlayerMeep"] = true
events.to_minimize["eventPlayerMeepKey"] = true



--- Events map.
-- The key is the event function name.
-- Values are tables with the following fields:
--	- module_names:			A list of module names corresponding to entries in `original_functions`.
--	- module_indices:		A map of module names corresponding to indices of entries in the other lists.
--	- original_functions:	A list of functions corresponding to the recovered event functions.
--	- functions:			A list of functions to run when this event runs. Fields may become dummy functions or be set back to the values from `original_functions`.
events.events = {}



--- Assertion variables.
local event_functions_created = false



--- Get all new event functions.
local function RecoverEventFunctions(last_module_name)
	if event_functions_created ~= false then
		print(string.format("<r>ERROR: <n>RecoverEventFunctions: Events were already created when processing `%s`!", last_module_name))
	end
	local event_functions = {}
	local module = pshy.modules[last_module_name]
	module.event_count = 0
	for obj_name, obj in pairs(_G) do
		if type(obj) == "function" then
			if string.find(obj_name, "event", 1, true) == 1 then
				event_functions[obj_name] = obj
				module.event_count = module.event_count + 1
			end
		end
	end
	for event_name, event_function in pairs(event_functions) do
		if not events.events[event_name] then
			events.events[event_name] = {module_names = {}, module_indices = {}, functions = {}, original_functions = {}}
		end
		table.insert(events.events[event_name].module_names, last_module_name)
		events.events[event_name].module_indices[last_module_name] = #events.events[event_name].module_names
		table.insert(events.events[event_name].original_functions, event_function)
		table.insert(events.events[event_name].functions, event_function)
		_G[event_name] = nil
	end
end



--- Create the event functions
-- A call to this is added by the compiler and run at the end of initialization.
function events.CreateFunctions()
	assert(event_functions_created == false)
	for event_name, event in pairs(events.events) do
		local event_functions = event.functions
		if not events.to_minimize[event_name] then
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



return events
