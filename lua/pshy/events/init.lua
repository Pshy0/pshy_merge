--- pshy.events
--
-- Adds an event `eventInit(init_duration)` called when the script was loaded.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998



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



--- Set of events only called per module.
-- Does not generate a global event function.
events.module_only_events = {
	["eventThisModuleEnabled"] = true,
	["eventThisModuleDisabled"] = true
}
 


--- Events map.
-- The key is the event function name.
-- Values are tables with the following fields:
--	- module_names:			A list of module names corresponding to entries in `original_functions`.
--	- module_indices:		A map of module names corresponding to indices of entries in the other lists.
--	- original_functions:	A list of functions corresponding to the recovered event functions.
--	- functions:			A list of functions to run when this event runs. Fields may become dummy functions or be set back to the values from `original_functions`.
events.events = {}



events.global_events = {}



--- Assertion variables.
local event_functions_created = false



local function RecoverEventFunctions(module_name)
	local module = pshy.modules[module_name]
	module.events = {}
	module.event_count = 0
	for obj_name, obj in pairs(_ENV) do
		if type(obj) == "function" and string.find(obj_name, "event", 1, true) == 1 then
			module.event_count = module.event_count + 1
			module.events[obj_name] = obj
		end
	end
	for event_name, event_function in pairs(module.events) do
		_ENV[event_name] = nil
	end
end



function events.UpdateEventFunctions(module_name)
	local module = pshy.modules[module_name]
	assert(module_name ~= nil)
	for obj_name, obj in pairs(_ENV) do
		if type(obj) == "function" then
			if not module.events or not module.events[obj_name] then
				print("<r>ERROR: cannot add new events after initialization.</r>")
			else
				module.events[obj_name] = obj
				if events.global_events[obj_name] then
					if events.global_events[obj_name] ~= obj then
						local i_module = events.events[obj_name].module_indices[module_name]
						events.events[obj_name].original_functions[i_module] = obj
						events.events[obj_name].functions[i_module] = obj
						_ENV[obj_name] = events.global_events[obj_name]
					end
				end
			end
		end
	end
end



--- Creates `events.events`.
local function CreateEventsTable()
	for i_module, module in ipairs(pshy.loaded_module_list) do
		if module.events then
			for event_name, event_function in pairs(module.events) do
				if not events.module_only_events[event_name] then
					if not events.events[event_name] then
						events.events[event_name] = {module_names = {}, module_indices = {}, functions = {}, original_functions = {}}
					end
					table.insert(events.events[event_name].module_names, module.name)
					events.events[event_name].module_indices[module.name] = #events.events[event_name].module_names
					table.insert(events.events[event_name].original_functions, event_function)
					table.insert(events.events[event_name].functions, event_function)
				end
			end
		end
	end
end



--- Create an event function.
-- The function will call a list of other functions, aborting if one returns non-nil.
-- @note This function is called just before `eventInit`, so you may override it. You're not supposed to call it yourself.
-- @param event_functions The function list to bind to this function. This is a reference so it can be updated later.
-- @return The function. Assign it to _ENV yourself.
function events.MakeEventFunction(event_name, event_functions)
	return function(...)
		for i_func, func in ipairs(event_functions) do
			if (func(...) ~= nil) then
				return
			end
		end
	end
end



--- Create a minimum event function.
-- This variant is faster but does not check the return value of event functions.
-- @note This function is called just before `eventInit`, so you may override it. You're not supposed to call it yourself.
-- @param event_functions The function list to bind to this function. This is a reference so it can be updated later.
-- @return The function. Assign it to _ENV yourself.
function events.MakeMinimumEventFunction(event_name, event_functions)
	return function(...)
		for i_func, func in ipairs(event_functions) do
			func(...)
		end
	end
end



--- Create event functions.
-- Function called by the compiler to generate global events.
-- @private
function events.CreateFunctions()
	CreateEventsTable()
	assert(event_functions_created == false)
	for event_name, event in pairs(events.events) do
		if not events.to_minimize[event_name] then
			_ENV[event_name] = events.MakeEventFunction(event_name, event.functions)
		else
			_ENV[event_name] = events.MakeMinimumEventFunction(event_name, event.functions)
		end
		events.global_events[event_name] = _ENV[event_name]
	end
	event_functions_created = true
	if eventInit then
		eventInit(os.time() - pshy.INIT_TIME)
	end
end



--- Hook `pshy.require`:
table.insert(pshy.require_postload_functions, RecoverEventFunctions)



return events
