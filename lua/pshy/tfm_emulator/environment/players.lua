--- pshy.tfm_emulator.environment.players
--
-- Simulate players.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.tfm_emulator.environment.base")
pshy.require("pshy.tfm_emulator.environment.controls")



--- Members:
pshy.tfm_emulator_pending_events = {}



--- Internal use:
local next_player_id = 10001
local lua_string_format = pshy.lua_string_format
local lua_print = pshy.lua_print



--- Get how many players are alive.
local function PlayersAlive()
	local cnt = 0
	for player_name, player in pairs(tfm.get.room.playerList) do
		if not player.isDead then
			cnt = cnt + 1
		end
	end
	return cnt
end



--- Simulate a player being in the room when the script started.
function pshy.tfm_emulator_init_NewPlayer(joining_player_name, properties)
	if not pshy.tfm_emulator_loader then
		pshy.tfm_emulator_loader = joining_player_name
	end
	if not pshy.tfm_emulator_player_sync then
		pshy.tfm_emulator_player_sync = joining_player_name
	end
	-- add the new player
	tfm.get.room.playerList[joining_player_name] = {
		cheeses = 0;
		community = "en";
		gender = 0;
		hasCheese = false;
		id = next_player_id;
		inHardMode = 0;
		isDead = false;
		isFacingRight = true;
		isInvoking = false;
		isJumping = false;
		isShaman = false;
		isVampire = false;
		language = "int";
		look = "1;0,0,0,0,0,0,0,0,0";
		movingLeft = false;
		movingRight = false;
		playerName = joining_player_name;
		registrationDate = 1652691762994;
		score = 0;
		shamanMode = 0;
		spouseId = 1;
		spouseName = nil;
		title = 0;
		tribeId = nil;
		tribeName = nil;
		vx = 0;
		vy = 0;
		x = 0;
		y = 0;
		-- emulator fields
		_respawn_time = pshy.tfm_emulator_time_Get();
	}
	next_player_id = next_player_id + 1
	if properties then
		local joining_player = new_player_map[joining_player_name]
		for p_name, p_value in pairs(properties) do
			joining_player[p_name] = p_value
		end
	end
end



--- Reimplementation of `tfm.exec.getPlayerSync`.
tfm.exec.getPlayerSync = function()
	return pshy.tfm_emulator_player_sync
end
pshy.tfm_emulator_tfm_exec_getPlayerSync = tfm.exec.getPlayerSync



--- Reimplementation of `tfm.exec.setPlayerSync`.
tfm.exec.setPlayerSync = function(sync_player)
	if sync_player and tfm.get.room.playerList[sync_player] then
		pshy.tfm_emulator_player_sync = sync_player
	else
		for player_name in pairs(tfm.get.room.playerList) do
			pshy.tfm_emulator_player_sync = player_name
			break
		end
	end
end
pshy.tfm_emulator_tfm_exec_setPlayerSync = tfm.exec.setPlayerSync



--- Simulate a joining player.
-- @note The table is recreated because so do TFM.
function pshy.tfm_emulator_NewPlayer(joining_player_name, properties)
	-- change the player map reference:
	local old_player_map = tfm.get.room.playerList
	new_player_map = {}
	tfm.get.room.playerList = new_player_map
	for player_name, player in pairs(old_player_map) do
		new_player_map[player_name] = player
	end
	-- add the new player
	new_player_map[joining_player_name] = {
		cheeses = 0;
		community = "en";
		gender = 0;
		hasCheese = false;
		id = next_player_id;
		inHardMode = 0;
		isDead = true;
		isFacingRight = true;
		isInvoking = false;
		isJumping = false;
		isShaman = false;
		isVampire = false;
		language = "int";
		look = "1;0,0,0,0,0,0,0,0,0";
		movingLeft = false;
		movingRight = false;
		playerName = joining_player_name;
		registrationDate = 1652691762994;
		score = 0;
		shamanMode = 0;
		spouseId = 1;
		spouseName = nil;
		title = 0;
		tribeId = nil;
		tribeName = nil;
		vx = 0;
		vy = 0;
		x = 0;
		y = 0;
		-- emulator fields
		_respawn_time = pshy.tfm_emulator_time_Get();
	}
	next_player_id = next_player_id + 1
	if properties then
		local joining_player = new_player_map[joining_player_name]
		for p_name, p_value in pairs(properties) do
			joining_player[p_name] = p_value
		end
	end
	-- event:
	if eventNewPlayer then
		if pshy.tfm_emulator_log_events then
			lua_print(lua_string_format(">> eventNewPlayer(%s)", joining_player_name))
		end
		eventNewPlayer(joining_player_name)
	end
	pshy.tfm_emulator_RaiseEvents()
end



--- Simulate a leaving player.
-- @note The table is recreated because so do TFM.
function pshy.tfm_emulator_PlayerLeft(leaving_player_name)
	local player = tfm.get.room.playerList[leaving_player_name]
	player._leaving = true
	pshy.tfm_emulator_PlayerDied(leaving_player_name)
	-- unbind keys and mouse
	pshy.tfm_emulator_player_bound_keys[leaving_player_name] = nil
	pshy.tfm_emulator_player_bound_mice[leaving_player_name] = nil
	-- event:
	if eventPlayerLeft then
		if pshy.tfm_emulator_log_events then
			lua_print(lua_string_format(">> eventPlayerLeft(%s)", leaving_player_name))
		end
		eventPlayerLeft(leaving_player_name)
	end
	-- change the player map reference:
	local old_player_map = tfm.get.room.playerList
	new_player_map = {}
	tfm.get.room.playerList = new_player_map
	for player_name, player in pairs(old_player_map) do
		new_player_map[player_name] = player
	end
	-- removing the player:
	new_player_map[leaving_player_name] = nil
	-- sync
	if leaving_player_name == pshy.tfm_emulator_player_sync then
		pshy.tfm_emulator_tfm_exec_setPlayerSync()
	end
	pshy.tfm_emulator_RaiseEvents()
end



--- Simulate a player obtaining the cheese.
function pshy.tfm_emulator_PlayerGetCheese(player_name)
	local player = tfm.get.room.playerList[player_name]
	player.hasCheese = true
	player.cheeses = player.cheeses + 1
	if eventPlayerGetCheese then
		if pshy.tfm_emulator_log_events then
			lua_print(lua_string_format(">> eventPlayerGetCheese(%s)", player_name))
		end
		eventPlayerGetCheese(player_name)
	end
	pshy.tfm_emulator_RaiseEvents()
end



--- Reimplementation of `tfm.exec.giveCheese`.
tfm.exec.giveCheese = function(player_name)
	table.insert(pshy.tfm_emulator_pending_events, {func = pshy.tfm_emulator_PlayerGetCheese, args = {player_name}})
end



local function RemoveCheese(player_name)
	local player = tfm.get.room.playerList[player_name]
	if not player then
		print("not " .. player_name)
	end
	player.hasCheese = false
	player.cheeses = 0
	pshy.tfm_emulator_RaiseEvents()
end



--- Reimplementation of `tfm.exec.removeCheese`.
tfm.exec.removeCheese = function(player_name)
	local player = tfm.get.room.playerList[player_name]
	table.insert(pshy.tfm_emulator_pending_events, {func = RemoveCheese, args = {player_name}})
end



--- Simulate a player dying.
function pshy.tfm_emulator_PlayerDied(player_name)
	local player = tfm.get.room.playerList[player_name]
	if player.isDead then
		return
	end
	player.isDead = true
	if eventPlayerDied then
		if pshy.tfm_emulator_log_events then
			lua_print(lua_string_format(">> eventPlayerDied(%s)", player_name))
		end
		eventPlayerDied(player_name)
	end
	-- auto time left
	if pshy.tfm_emulator_tfm_auto_time_left then
		if PlayersAlive() <= 2 then
			pshy.tfm_emulator_tfm_exec_setGameTime(20, false)
		end
	end
	pshy.tfm_emulator_RaiseEvents()
end



--- Reimplementation of `tfm.exec.killPlayer`.
tfm.exec.killPlayer = function(player_name)
	table.insert(pshy.tfm_emulator_pending_events, {func = pshy.tfm_emulator_PlayerDied, args = {player_name}})
end



--- Simulate a player winning.
function pshy.tfm_emulator_PlayerWon(player_name)
	local player = tfm.get.room.playerList[player_name]
	if not player.hasCheese or player.isDead then
		return
	end
	player.isDead = true
	player._won = true
	if eventPlayerWon then
		local time_since_game_start = (pshy.tfm_emulator_time_Get() - pshy.tfm_emulator_game_start_time) / 10 -- tfm use centiseconds here
		local time_since_respawn = (pshy.tfm_emulator_time_Get() - tfm.get.room.playerList[player_name]._respawn_time) / 10 -- tfm use centiseconds here
		if pshy.tfm_emulator_log_events then
			lua_print(lua_string_format(">> eventPlayerWon(%s, %f, %f)", player_name, time_since_game_start, time_since_respawn))
		end
		eventPlayerWon(player_name, time_since_game_start, time_since_respawn)
	end
	-- auto time left
	if pshy.tfm_emulator_tfm_auto_time_left then
		if PlayersAlive() <= 2 then
			pshy.tfm_emulator_tfm_exec_setGameTime(20, false)
		end
	end
end



--- Reimplementation of `tfm.exec.playerVictory`.
tfm.exec.playerVictory = function(player_name)
	local player = tfm.get.room.playerList[player_name]
	table.insert(pshy.tfm_emulator_pending_events, {func = pshy.tfm_emulator_PlayerWon, args = {player_name}})
end



--- Simulate the respawning of a player.
function pshy.tfm_emulator_PlayerRespawn(player_name)
	local player = tfm.get.room.playerList[player_name]
	if not player.isDead then
		return
	end
	player.isDead = false
	player._respawn_time = pshy.tfm_emulator_time_Get()
	if player._won then
		player.cheeses = 0
		player.hasCheese = 0
	end
	if eventPlayerRespawn then
		eventPlayerRespawn(player_name)
	end
	-- move
	pshy.tfm_emulator_tfm_exec_movePlayer(joining_player_name, 400, 200, false, 0, 0, false)
end



--- Reimplementation of `tfm.exec.respawnPlayer`.
tfm.exec.respawnPlayer = function(player_name)
	local player = tfm.get.room.playerList[player_name]
	if player._leaving then
		return
	end
	table.insert(pshy.tfm_emulator_pending_events, {func = pshy.tfm_emulator_PlayerRespawn, args = {player_name}})
	player._won = true -- in practice causes this function to not respawn players with their cheese
end



--- Simulate a player moved.
function PlayerMoved(player_name, x, y, rel_pos, vx, vy, rel_speed)
	local player = tfm.get.room.playerList[player_name]
	if not player then
		return
	end
	if rel_pos then
		if x then
			player.x = player.x + x
		end
		if y then
			player.x = player.x + x
		end
	else
		if x then
			player.x = x
		end
		if y then
			player.x = x
		end
	end
	if rel_speed then
		if vx then
			player.vx = player.vx + vx
		end
		if vy then
			player.vx = player.vx + vx
		end
	else
		if vx then
			player.vx = vx
		end
		if vy then
			player.vx = vx
		end
	end
end



--- Reimplementation of `tfm.exec.movePlayer`.
tfm.exec.movePlayer = function(player_name, x, y, rel_pos, vx, vy, rel_speed)
	table.insert(pshy.tfm_emulator_pending_events, {func = PlayerMoved, args = {player_name, x, y, rel_pos, vx, vy, rel_speed}})
end
pshy.tfm_emulator_tfm_exec_movePlayer = tfm.exec.movePlayer
