--- pshy.tfm_emulator.environment.game
--
-- Simulate gameplay.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.tfm_emulator.environment.base")
pshy.require("pshy.tfm_emulator.environment.players")
pshy.require("pshy.tfm_emulator.environment.tfm_settings")
pshy.require("pshy.tfm_emulator.environment.time")
local tfmenv = pshy.require("pshy.compiler.tfmenv")



--- Members:
tfmenv.game_start_time = tfmenv.time_Get() - 300
tfmenv.game_end_time = tfmenv.time_Get() + 2 * 60 * 1000
tfmenv.next_loop_time = tfmenv.time_Get() + 500



--- Internal use:
local default_map_xml = [[<C><P F="0" MEDATA=";;;;-0;0:::1-"/><Z><S><S T="6" X="400" Y="378" L="800" H="50" P="0,0,0.3,0.2,0,0,0,0"/><S T="6" X="541" Y="173" L="120" H="40" P="0,0,0.3,0.2,0,0,0,0"/></S><D><P X="542" Y="353" T="12" P="0,1"/><P X="49" Y="355" T="0" P="1,0"/><T X="120" Y="356"/><P X="249" Y="354" T="11" P="0,0"/><P X="706" Y="356" T="1" P="0,0"/><F X="541" Y="149"/><DC X="122" Y="341"/><DS X="122" Y="343"/></D><O/><L/></Z></C>]]
local newgame_map = nil
local newgame_mirrored = false
local newgame_last_call_time = tfmenv.time_Get() - 30000



--- Trigger `eventLoop(time, time_remaining)`.
local function Loop(time, time_remaining)
	local current_time = tfmenv.time_Get()
	time = math.floor(time or current_time - tfmenv.game_start_time)
	time_remaining = math.floor(time_remaining or math.max(0, tfmenv.game_end_time - current_time))
	tfmenv.CallEvent("eventLoop", time, time_remaining)
	tfmenv.next_loop_time = tfmenv.time_Get() + 500
end



--- Simulate a new map loaded.
function tfmenv.NewGame(mapcode, mirrored, xmlMapinfo)
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
	local room = tfmenv.env.tfm.get.room
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
	for player_name, player in pairs(tfmenv.env.tfm.get.room.playerList) do
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
		player._respawn_time = tfmenv.time_Get();
		tfmenv.tfm_exec_movePlayer(player_name, 400, 200, false, 0, 0, false)
	end
	-- update time
	tfmenv.game_start_time = tfmenv.time_Get()
	tfmenv.game_end_time = tfmenv.time_Get() + 2 * 60 * 1000 + 3000
	-- event
	tfmenv.CallEvent("eventNewGame")
end



--- Reimplementation of `tfm.exec.setGameTime`.
tfmenv.env.tfm.exec.setGameTime = function(seconds, init)
	if seconds < 5 then
		seconds = 5
	end
	if init == nil then
		init = true
	end
	local ms = seconds * 1000
	local current_time = tfmenv.time_Get()
	local time_remaining = tfmenv.game_end_time - current_time
	if init or time_remaining > ms then
		tfmenv.game_end_time = current_time + ms
	end
end
tfmenv.tfm_exec_setGameTime = tfmenv.env.tfm.exec.setGameTime



--- Reimplementation of `tfm.exec.newGame`.
tfmenv.env.tfm.exec.newGame = function(map, mirrored)
	if tfmenv.time_Get() - newgame_last_call_time < 3000 then
		print("You can't call this function [tfm.exec.newGame] more than once per 3 seconds.")
	elseif not newgame_map then
		newgame_map = map
		newgame_mirrored = mirrored
		newgame_last_call_time = tfmenv.time_Get()
	else
		print("You can't call this function [tfm.exec.newGame] while another map is loading.")
	end
end



--- Get in how many ms should an asynchronous event be raised.
local function SoonestEventDelay()
	local current_time = tfmenv.time_Get()
	local soonest_time = 9999999
	-- misc events
	if tfmenv.pending_events[1] then
		return 0
	end
	-- eventLoop
	if current_time > tfmenv.next_loop_time then
		return 0
	else
		soonest_time = math.min(soonest_time, tfmenv.next_loop_time - current_time)
	end
	-- eventNewGame
	if tfmenv.tfm_auto_new_game then
		if current_time > tfmenv.game_end_time then
			return 0
		else
			soonest_time = math.min(soonest_time, tfmenv.game_end_time - current_time)
		end
	end
	return soonest_time
end



--- Raise async events.
local raising_events = false
local function RaiseEvents()
	if raising_events then
		return -- we are already currently raising events
	end
	raising_events = true
	local current_time = tfmenv.time_Get()
	-- eventLoop
	if current_time >= tfmenv.next_loop_time then
		Loop()
	end
	-- eventNewGame
	if newgame_map then
		tfmenv.NewGame()
	elseif tfmenv.tfm_auto_new_game then
		if current_time >= tfmenv.game_end_time then
			tfmenv.NewGame()
		end
	end
	-- pending events
	while tfmenv.pending_events[1] do
		for i_e, e in ipairs(tfmenv.pending_events) do
			e.func(table.unpack(e.args))
		end
		tfmenv.pending_events = {}
	end
	raising_events = false
end
tfmenv.RaiseEvents = RaiseEvents



--- Wait some time and raise assynchronous events.
function tfmenv.Wait(ms)
	ms = ms or 500
	local soonest_event_delay = SoonestEventDelay()
	while soonest_event_delay < ms do
		RaiseEvents()
		tfmenv.time_Add(soonest_event_delay)
		ms = ms - soonest_event_delay
		soonest_event_delay = SoonestEventDelay()
	end
	tfmenv.time_Add(ms)
end

