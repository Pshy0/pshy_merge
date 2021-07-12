--- pshy_weathers.lua
--
-- Add weathers.
-- A weather is an object with the folowing optional members:
--   Begin()			- Start the weather
--   Tick()			- Tick (called ms)
--   End()			- Weather end
--
-- @author Pshy
-- @namespace pshy
-- @require pshy_commands.lua
-- @require pshy_help.lua
pshy = pshy or {}



--- Module settings:
pshy.weather_auto = false -- Change weather between rounds



--- Module's help page.
pshy.help_pages["pshy_weather"] = {back = "pshy", title = "Weather", text = "This module allow to start 'weathers'.\nIn lua, a weather is simply a table of Begin(), Tick() and End() functions.\n\nThis module does not provide weather definitions by itself. You may have to require pshy_basic_weathers or provide your own ones.\n", examples = {}, subpages = {}}
pshy.help_pages["pshy_weather"].commands = {}
pshy.help_pages["pshy_weather"].examples["weather random_object_rain"] = "Start the weather 'random_object_rain'."
pshy.help_pages["pshy_weather"].examples["luaset pshy.weather_auto"] = "Set weathers to randomly be started every map."
pshy.help_pages["pshy_weather"].examples["luaset pshy.weathers.snow nil"] = "Permanently disable the snow weather."
pshy.help_pages["pshy"].subpages["pshy_weather"] = pshy.help_pages["pshy_weather"]



--- Weathers
-- Contains loaded weathers
pshy.weathers = {}
-- Currently active weathers
pshy.active_weathers = {}
-- internal use
pshy.next_weather_time = 0



--- Change the weather
-- @param new_weather_names List of new weathers.
function pshy.Weather(new_weather_names)
	local new_weathers = {}
	for i, weather_name in ipairs(new_weather_names) do
		if weather_name ~= "clear" and not pshy.weathers[weather_name] then
			error("invalid weather " .. weather_name)
		end
		new_weathers[weather_name] = pshy.weathers[weather_name]
		if not pshy.active_weathers[weather_name] then
			if new_weathers[weather_name].Begin then
				new_weathers[weather_name].Begin()
			end
		end
	end
	for weather_name, weather in pairs(pshy.active_weathers) do
		if not new_weathers[weather_name] then
			if weather.End then 
				weather.End() 
			end
		end
	end
	pshy.active_weathers = new_weathers
end



--- events
function eventNewGame()
	pshy.next_weather_time = 0
	if pshy.weather_auto then
		pshy.Weather({})
		pshy.Weather({pshy.LuaRandomTableKey(pshy.weathers)})
	end
end



--- TFM loop event
function eventLoop(currentTime, timeRemaining)
	if pshy.next_weather_time < currentTime then
		pshy.next_weather_time = pshy.next_weather_time + 500 -- run Tick() every 500 ms only
		for weather_name, weather in pairs(pshy.active_weathers) do
			if weather.Tick then
				weather.Tick()
			end
		end
	end
end



--- !weather [weathers...]
function pshy.ChatCommandWeather(...)
	new_weather_names = {...}
	pshy.Weather(new_weather_names)
end
pshy.chat_commands["weather"] = {func = pshy.ChatCommandWeather, desc = "Set the active weathers. No argument == 'clear'.", no_user = true, argc_min = 0, argc_max = 4, arg_types = {"string", "string", "string", "string"}}
pshy.help_pages["pshy_weather"].commands["weather"] = pshy.chat_commands["weather"]

