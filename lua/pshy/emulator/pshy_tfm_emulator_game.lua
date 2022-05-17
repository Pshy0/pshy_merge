--- pshy_tfm_emulator_game.lua
--
-- Simulate gameplay.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
--
-- @require pshy_tfm_emulator_basic_environment.lua
-- @require pshy_tfm_emulator_players.lua
-- @require pshy_tfm_emulator_time.lua
--
-- @require_priority DEBUG
pshy = pshy or {}



--- Members:
pshy.tfm_emulator_game_start_time = pshy.tfm_emulator_time_Get()



--- Internal use:
local default_map_xml = [[<C><P F="0" MEDATA=";;;;-0;0:::1-"/><Z><S><S T="6" X="400" Y="378" L="800" H="50" P="0,0,0.3,0.2,0,0,0,0"/><S T="6" X="541" Y="173" L="120" H="40" P="0,0,0.3,0.2,0,0,0,0"/></S><D><P X="542" Y="353" T="12" P="0,1"/><P X="49" Y="355" T="0" P="1,0"/><T X="120" Y="356"/><P X="249" Y="354" T="11" P="0,0"/><P X="706" Y="356" T="1" P="0,0"/><F X="541" Y="149"/><DC X="122" Y="341"/><DS X="122" Y="343"/></D><O/><L/></Z></C>]]



--- Trigger `eventLoop(time, time_remaining)`.
function pshy.tfm_emulator_Loop(time, time_remaining)
	if eventLoop then
		eventLoop(time, time_remaining)
	end
end



--- Simulate a new map loaded.
function pshy.tfm_emulator_NewGame(mapcode, mirrored, xmlMapinfo)
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
	for k, v in pairs(xmlMapinfo) do
		room.xmlMapInfo[k] = v
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
	-- event
	if eventNewGame then
		eventNewGame()
	end
end
