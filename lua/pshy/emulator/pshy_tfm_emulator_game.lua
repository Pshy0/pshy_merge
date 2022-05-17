--- pshy_tfm_emulator_game.lua
--
-- Simulate gameplay.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_tfm_emulator_basic_environment.lua
-- @require pshy_tfm_emulator_players.lua
-- @require pshy_tfm_emulator_tfm_settings.lua
-- @require pshy_tfm_emulator_time.lua
--
-- @require_priority DEBUG
pshy = pshy or {}



--- Members:
pshy.tfm_emulator_game_start_time = pshy.tfm_emulator_time_Get() - 300
pshy.tfm_emulator_game_end_time = pshy.tfm_emulator_time_Get() + 2 * 60 * 1000
pshy.tfm_emulator_next_loop_time = pshy.tfm_emulator_time_Get() + 500



--- Internal use:
local default_map_xml = [[<C><P F="0" MEDATA=";;;;-0;0:::1-"/><Z><S><S T="6" X="400" Y="378" L="800" H="50" P="0,0,0.3,0.2,0,0,0,0"/><S T="6" X="541" Y="173" L="120" H="40" P="0,0,0.3,0.2,0,0,0,0"/></S><D><P X="542" Y="353" T="12" P="0,1"/><P X="49" Y="355" T="0" P="1,0"/><T X="120" Y="356"/><P X="249" Y="354" T="11" P="0,0"/><P X="706" Y="356" T="1" P="0,0"/><F X="541" Y="149"/><DC X="122" Y="341"/><DS X="122" Y="343"/></D><O/><L/></Z></C>]]
local newgame_map = nil
local newgame_mirrored = false
local newgame_last_call_time = pshy.tfm_emulator_time_Get() - 30000
local lua_math_max = pshy.lua_math_max
local lua_math_min = pshy.lua_math_min
local lua_math_floor = pshy.lua_math_floor
local lua_print = pshy.lua_print
local lua_string_format = pshy.lua_string_format



--- Trigger `eventLoop(time, time_remaining)`.
function pshy.tfm_emulator_Loop(time, time_remaining)
	local current_time = pshy.tfm_emulator_time_Get()
	time = lua_math_floor(time or current_time - pshy.tfm_emulator_game_start_time)
	time_remaining = lua_math_floor(time_remaining or lua_math_max(0, pshy.tfm_emulator_game_end_time - current_time))
	if eventLoop then
		if pshy.tfm_emulator_log_events then
			lua_print(lua_string_format(">> eventLoop(%s, %s)", time, time_remaining))
		end
		eventLoop(time, time_remaining)
	end
	pshy.tfm_emulator_next_loop_time = pshy.tfm_emulator_time_Get() + 505
end



--- Simulate a new map loaded.
function pshy.tfm_emulator_NewGame(mapcode, mirrored, xmlMapinfo)
	-- default args
	if mapcode == nil then
		mapcode = newgame_map or 0
	end
	newgame_map = nil
	if mirrored == nil then
		mirrored = newgame_mirrored or false
	end
	newgame_mirrored = nil
	-- update room
	local room = tfm.get.room
	room.mirroredMap = mirrored or false
	room.xmlMapInfo = {}
	if string.sub(mapcode, 1, 1) == "<" then
		room.currentMap = 0
		room.xmlMapInfo.xml = mapcode
		room.xmlMapInfo.mapCode = 0
	else
		room.currentMap = mapcode
		room.xmlMapInfo.xml = default_map_xml
		room.xmlMapInfo.mapCode = tonumber(mapcode) or 877676
	end
	room.xmlMapInfo.author = "Pshy#3752"
	room.xmlMapInfo.permCode = 22
	if xmlMapInfo then
		for k, v in pairs(xmlMapinfo) do
			room.xmlMapInfo[k] = v
		end
	end
	-- update players
	for player_name, player in pairs(tfm.get.room.playerList) do
		player.cheeses = 0
		player.hasCheese = false
		player.isDead = false
		player.isInvoking = false
		player.isJumping = false
		player.isShaman = false
		player.isVampire = false
		player.movingLeft = false
		player.movingRight = false
		player.vx = 0
		player.vy = 0
		-- emulator fields
		player._respawn_time = pshy.tfm_emulator_time_Get();
	end
	-- update time
	pshy.tfm_emulator_game_start_time = pshy.tfm_emulator_time_Get()
	pshy.tfm_emulator_game_end_time = pshy.tfm_emulator_time_Get() + 2 * 60 * 1000 + 3000
	-- event
	if eventNewGame then
		if pshy.tfm_emulator_log_events then
			lua_print(">> eventNewGame()")
		end
		eventNewGame()
	end
end



--- Reimplementation of `tfm.exec.setGameTime`.
tfm.exec.setGameTime = function(seconds, init)
	if seconds < 5 then
		seconds = 5
	end
	if init == nil then
		init = true
	end
	local ms = seconds * 1000
	local current_time = pshy.tfm_emulator_time_Get()
	local time_remaining = pshy.tfm_emulator_game_end_time - current_time
	if init or time_remaining > ms then
		pshy.tfm_emulator_game_end_time = current_time + ms
	end
end
pshy.tfm_emulator_tfm_exec_setGameTime = tfm.exec.setGameTime



--- Reimplementation of `tfm.exec.newGame`.
tfm.exec.newGame = function(map, mirrored)
	if pshy.tfm_emulator_time_Get() - newgame_last_call_time < 3000 then
		print("You can't call this function [tfm.exec.newGame] more than once per 3 seconds.")
	elseif not newgame_map then
		newgame_map = map
		newgame_mirrored = mirrored
		newgame_last_call_time = pshy.tfm_emulator_time_Get()
	else
		print("You can't call this function [tfm.exec.newGame] while another map is loading.")
	end
end



--- Get in how many ms should an asynchronous event be raised.
local function SoonestEventDelay()
	local current_time = pshy.tfm_emulator_time_Get()
	local soonest_time = 9999999
	-- eventLoop
	if current_time > pshy.tfm_emulator_next_loop_time then
		return 0
	else
		soonest_time = lua_math_min(soonest_time, pshy.tfm_emulator_next_loop_time - current_time)
	end
	-- eventNewGame
	if pshy.tfm_emulator_tfm_auto_new_game then
		if current_time > pshy.tfm_emulator_game_end_time then
			return 0
		else
			soonest_time = lua_math_min(soonest_time, pshy.tfm_emulator_game_end_time - current_time)
		end
	end
	return soonest_time
end



--- Raise async events.
local function RaiseEvents()
	local current_time = pshy.tfm_emulator_time_Get()
	-- eventLoop
	if current_time >= pshy.tfm_emulator_next_loop_time then
		pshy.tfm_emulator_Loop()
	end
	-- eventNewGame
	if newgame_map then
		pshy.tfm_emulator_NewGame()
	elseif pshy.tfm_emulator_tfm_auto_new_game then
		if current_time >= pshy.tfm_emulator_game_end_time then
			pshy.tfm_emulator_NewGame()
		end
	end
end



--- Wait some time and raise assynchronous events.
function pshy.tfm_emulator_Wait(ms)
	ms = ms or 500
	local soonest_event_delay = SoonestEventDelay()
	while soonest_event_delay < ms do
		RaiseEvents()
		pshy.tfm_emulator_time_Add(soonest_event_delay)
		ms = ms - soonest_event_delay
		soonest_event_delay = SoonestEventDelay()
	end
	pshy.tfm_emulator_time_Add(ms)
end

