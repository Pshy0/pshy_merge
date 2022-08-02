--- pshy.tfm_emulator.environment.players
--
-- Simulate players.
--
-- @author TFM:Pshy#3752 DC:Pshy#7998
pshy.require("pshy.tfm_emulator.environment.base")
pshy.require("pshy.tfm_emulator.environment.controls")
local tfmenv = pshy.require("pshy.compiler.tfmenv")



--- Members:
tfmenv.pending_events = {}



--- Internal use:
local next_player_id = 10001
local lua_string_format = pshy.lua_string_format
local lua_print = pshy.lua_print



--- Get how many players are alive.
local function PlayersAlive()
	local cnt = 0
	for player_name, player in pairs(tfmenv.env.tfm.get.room.playerList) do
		if not player.isDead then
			cnt = cnt + 1
		end
	end
	return cnt
end



--- Simulate a player being in the room when the script started.
function tfmenv.init_NewPlayer(joining_player_name, properties)
	if not tfmenv.loader then
		tfmenv.loader = joining_player_name
		tfmenv.SetLauncher(joining_player_name, properties)
	end
	if not tfmenv.player_sync then
		tfmenv.player_sync = joining_player_name
	end
	-- add the new player
	tfmenv.env.tfm.get.room.playerList[joining_player_name] = {
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
		_respawn_time = tfmenv.time_Get();
	}
	next_player_id = next_player_id + 1
	if properties then
		local joining_player = new_player_map[joining_player_name]
		for p_name, p_value in pairs(properties) do
			joining_player[p_name] = p_value
		end
	end
end



--- Reimplementation of `tfm.exec.setPlayerSync`.
tfmenv.env.tfm.exec.setPlayerSync = function(sync_player)
	if sync_player and tfmenv.env.tfm.get.room.playerList[sync_player] then
		tfmenv.player_sync = sync_player
		tfmenv.sync = sync_player
	else
		for player_name in pairs(tfmenv.env.tfm.get.room.playerList) do
			tfmenv.player_sync = player_name
			tfmenv.sync = player_name
			break
		end
	end
end
tfmenv.tfm_exec_setPlayerSync = tfmenv.env.tfm.exec.setPlayerSync



--- Simulate a joining player.
-- @note The table is recreated because so do TFM.
function tfmenv.NewPlayer(joining_player_name, properties)
	-- change the player map reference:
	local old_player_map = tfmenv.env.tfm.get.room.playerList
	new_player_map = {}
	tfmenv.env.tfm.get.room.playerList = new_player_map
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
		_respawn_time = tfmenv.time_Get();
	}
	next_player_id = next_player_id + 1
	if properties then
		local joining_player = new_player_map[joining_player_name]
		for p_name, p_value in pairs(properties) do
			joining_player[p_name] = p_value
		end
	end
	-- event:
	tfmenv.CallEvent("eventNewPlayer", joining_player_name)
	tfmenv.RaiseEvents()
end



--- Simulate a leaving player.
-- @note The table is recreated because so do TFM.
function tfmenv.PlayerLeft(leaving_player_name)
	local player = tfmenv.env.tfm.get.room.playerList[leaving_player_name]
	player._leaving = true
	tfmenv.PlayerDied(leaving_player_name)
	-- unbind keys and mouse
	tfmenv.player_bound_keys[leaving_player_name] = nil
	tfmenv.player_bound_mice[leaving_player_name] = nil
	-- event:
	tfmenv.CallEvent("eventPlayerLeft", leaving_player_name)
	-- change the player map reference:
	local old_player_map = tfmenv.env.tfm.get.room.playerList
	new_player_map = {}
	tfmenv.env.tfm.get.room.playerList = new_player_map
	for player_name, player in pairs(old_player_map) do
		new_player_map[player_name] = player
	end
	-- removing the player:
	new_player_map[leaving_player_name] = nil
	-- sync
	if leaving_player_name == tfmenv.player_sync then
		tfmenv.tfm_exec_setPlayerSync()
	end
	tfmenv.RaiseEvents()
end



--- Simulate a player obtaining the cheese.
function tfmenv.PlayerGetCheese(player_name)
	local player = tfmenv.env.tfm.get.room.playerList[player_name]
	player.hasCheese = true
	player.cheeses = player.cheeses + 1
	tfmenv.CallEvent("eventPlayerGetCheese", player_name)
	tfmenv.RaiseEvents()
end



--- Reimplementation of `tfm.exec.giveCheese`.
tfmenv.env.tfm.exec.giveCheese = function(player_name)
	table.insert(tfmenv.pending_events, {func = tfmenv.PlayerGetCheese, args = {player_name}})
end



local function RemoveCheese(player_name)
	local player = tfmenv.env.tfm.get.room.playerList[player_name]
	if not player then
		print("not " .. player_name)
	end
	player.hasCheese = false
	player.cheeses = 0
	tfmenv.RaiseEvents()
end



--- Reimplementation of `tfm.exec.removeCheese`.
tfmenv.env.tfm.exec.removeCheese = function(player_name)
	local player = tfmenv.env.tfm.get.room.playerList[player_name]
	table.insert(tfmenv.pending_events, {func = RemoveCheese, args = {player_name}})
end



--- Simulate a player dying.
function tfmenv.PlayerDied(player_name)
	local player = tfmenv.env.tfm.get.room.playerList[player_name]
	if player.isDead then
		return
	end
	player.isDead = true
	tfmenv.CallEvent("eventPlayerDied", player_name)
	-- auto time left
	if tfmenv.tfm_auto_time_left then
		if PlayersAlive() <= 2 then
			tfmenv.tfm_exec_setGameTime(20, false)
		end
	end
	tfmenv.RaiseEvents()
end



--- Reimplementation of `tfm.exec.killPlayer`.
tfmenv.env.tfm.exec.killPlayer = function(player_name)
	table.insert(tfmenv.pending_events, {func = tfmenv.PlayerDied, args = {player_name}})
end



--- Simulate a player winning.
function tfmenv.PlayerWon(player_name)
	local player = tfmenv.env.tfm.get.room.playerList[player_name]
	if not player.hasCheese or player.isDead then
		return
	end
	player.isDead = true
	player._won = true
	if tfmenv.env.eventPlayerWon then
		local time_since_game_start = (tfmenv.time_Get() - tfmenv.game_start_time) / 10 -- tfm use centiseconds here
		local time_since_respawn = (tfmenv.time_Get() - tfmenv.env.tfm.get.room.playerList[player_name]._respawn_time) / 10 -- tfm use centiseconds here
		tfmenv.CallEvent("eventPlayerWon", player_name, time_since_game_start, time_since_respawn)
	end
	-- auto time left
	if tfmenv.tfm_auto_time_left then
		if PlayersAlive() <= 2 then
			tfmenv.tfm_exec_setGameTime(20, false)
		end
	end
end



--- Reimplementation of `tfm.exec.playerVictory`.
tfmenv.env.tfm.exec.playerVictory = function(player_name)
	local player = tfmenv.env.tfm.get.room.playerList[player_name]
	table.insert(tfmenv.pending_events, {func = tfmenv.PlayerWon, args = {player_name}})
end



--- Simulate the respawning of a player.
function tfmenv.PlayerRespawn(player_name)
	local player = tfmenv.env.tfm.get.room.playerList[player_name]
	if not player.isDead then
		return
	end
	player.isDead = false
	player._respawn_time = tfmenv.time_Get()
	if player._won then
		player.cheeses = 0
		player.hasCheese = 0
	end
	tfmenv.CallEvent("eventPlayerRespawn", player_name)
	-- move
	tfmenv.tfm_exec_movePlayer(joining_player_name, 400, 200, false, 0, 0, false)
end



--- Reimplementation of `tfm.exec.respawnPlayer`.
tfmenv.env.tfm.exec.respawnPlayer = function(player_name)
	local player = tfmenv.env.tfm.get.room.playerList[player_name]
	if player._leaving then
		return
	end
	table.insert(tfmenv.pending_events, {func = tfmenv.PlayerRespawn, args = {player_name}})
	player._won = true -- in practice causes this function to not respawn players with their cheese
end



--- Simulate a player moved.
function PlayerMoved(player_name, x, y, rel_pos, vx, vy, rel_speed)
	local player = tfmenv.env.tfm.get.room.playerList[player_name]
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
tfmenv.env.tfm.exec.movePlayer = function(player_name, x, y, rel_pos, vx, vy, rel_speed)
	table.insert(tfmenv.pending_events, {func = PlayerMoved, args = {player_name, x, y, rel_pos, vx, vy, rel_speed}})
end
tfmenv.tfm_exec_movePlayer = tfmenv.env.tfm.exec.movePlayer
